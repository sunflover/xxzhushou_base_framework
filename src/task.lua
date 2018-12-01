-- global.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 任务
require("global")
require("config")
require("page")

local pairs = _G.pairs
local getCurrentTime = os.time

local modName = "task"
local M = {}

_G[modName] = M
package.loaded[modName] = M

M.taskList = {	--任务列表，01预留给断点任务
	{name = TASK_BREAK_POINT},
}

function M.setCurrentTaskStatus(status)
	setStringConfig("CurrentTaskStatus", status)
end

function M.insertTask(task)
	table.insert(M.taskList, task)
end

function M.isExistTask(taskName)	--是否存在任务taskName
	for _, v in pairs(M.taskList) do
		if taskName == v.name then
			return true
		end
	end
	
	return false
end

function M.getCurrentTask()		--获取当前任务
	if CURRENT_TASK ~= TASK_NONE and CURRENT_TASK ~= nil then
		return CURRENT_TASK
	end
end

function M.getTaskProcess(taskName)
	for k, v in pairs(M.taskList) do
		if v.name == taskName then
			return v.process
		end
	end
end

function M.isInTaskPage()
	local currentPage = M.getCurrentPage()
	if currentPage == nil or currentPage == PAGE_NONE then
		return false
	end
	
	local currentProcess = M.getTaskProcess(CURRENT_TASK)
	for k, v in pairs(currentProcess) do
		if v.name == currentPage then
			return true
		end
	end
	return false
end

function M.run(taskName, repeatTimes, breakPointFlag)	--执行任务，param:任务名称，任务重复次数（默认为一次0），是否为断点任务
	local reTimes = repeatTimes or 1
	local firstRunProcess = true
	local breakTaskFlag = breakPointFlag ~= false
	local allowSkipBackup = {}
	
	if M.isExistTask(taskName) ~= true then		--检查任务是否存在
		catchError(ERR_PARAM, "have no task: "..taskName)
	end
	
	local taskProcess = M.getTaskProcess(taskName)	--检查任务流程是否存在
	if taskProcess == nil then
		catchError(ERR_PARAM, "task:"..taskName.." have no process!")
	end
	
	if page.getCurrentPage() == nil then	--等待获取一个已定义界面(非过度界面)
		Log("waiting until catch a not nil page")
		local continueFlag = true
		local startTime = os.time()
		while true do
			if page.getCurrentPage() then
				break
			end
			
			if os.time() - startTime > CFG.WAIT_SKIP_NIL_PAGE then
				Log("always still a nil page, please skip it")
				dialog("always still a nil page, please skip it")
				startTime = os.time()
				while true do
					if page.getCurrentPage() then
						continueFlag = false
						break
					end
					if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
						catchError(ERR_TIMEOUT, "still start from a unkown page! can not work!")
					end
					sleep(200)
				end
			end
			
			if continueFlag == false then
				break
			end
			sleep(200)
		end
	end
	
	CURRENT_TASK = taskName
	M.setCurrentTaskStatus("start")
	
	for k, v in pairs(taskProcess) do	--第一次运行可能是重启过应用，允许直接跳转至任何流程片
		table.insert(allowSkipBackup, v.allowSkip)	--备份原allowSkip属性
		v.allowSkip = true
	end
	
	for i = 1, reTimes, 1 do
		Log("-----------------------START RUN A ROUND OF TASK: "..taskName.."-----------------------")		
		for k, v in pairs(taskProcess) do	
			if i == 1 then	--首次运行默认均不跳过
				v.skipStatus = false
			else	--非首次运行跳过仅首次运行的流程片
				if v.justFirstRun then	--只允许首次运行的流程片
					v.skipStatus = true
				else
					v.skipStatus = false
				end
			end
		end
		
		if i == 2 then
			for k, v in pairs(taskProcess) do	--第一次运行过后恢复原来的allowSkip属性
				v.allowSkip = allowSkipBackup[k]
			end
		end
		
		local waitCheckSkipTime = 0
		if i == i then		--第一次运行就快速检测是否可以跳过主界面
			waitCheckSipTime = 1
		else
			waitCheckSkipTime = CFG.WAIT_CHECK_SKIP
		end
		
		for k, v in pairs(taskProcess) do
			local checkInterval = v.checkInterval or CFG.DEFAULT_PAGE_CHECK_INTERVAL
			local timeout = v.timeout or CFG.DEFAULT_TIMEOUT
			local startTime = getCurrentTime()
			
			while true do
				--Log("now wait process page: "..v.name)
				if v.skipStatus == true then	--跳过当前界面流程
					Log("skip page: "..v.name)
					break
				end
				
				if page.isCurrentPage(v.name) then
					if v.actionFunc == nil then		--允许空载流程界面
						catchError(ERR_WARNING, "process: "..v.name.." have no actionFunc")
					else
						Log("------start execute process: "..v.name)
						v.actionFunc()
						Log("--------end execute process: "..v.name)
					end
					
					if firstRunProcess then		--执行过一个流程后就不再考虑存在断点任务
						firstRunProcess = false
					end
					break
				--else
				--	Log("cant find page "..v.name)
				end
				
				if v.waitFunc ~= nil then --等待期间执行的process的等待函数
					v.waitFunc(k)
				end
				
				Log(k.." -- wait current process has : "..(getCurrentTime() - startTime))
				if getCurrentTime() - startTime > timeout then	--流程超时
					catchError(ERR_TIMEOUT, "have waitting process: "..v.name.." "..tostring(getCurrentTime()-startTime).."s yet, try end it")
				end
				
				if getCurrentTime() - startTime > waitCheckSkipTime then	--跳过
					local currentPage = page.getCurrentPage()
					if currentPage ~= nil and currentPage ~= PAGE_NONE then
						local isProcessPage = false
						local pageIndex = 0
						for _k, _v in pairs(taskProcess) do
							if _v.name == currentPage then	--当前界面确认处于流程中某界面
								Log("have a not current process page")
								isProcessPage = true
								pageIndex = _k
								break
							end
						end
						
						local continuousSkipFlag = false
						for _k, _v in pairs(taskProcess) do
							if _k >= k and _k < pageIndex then	--从当前流程界面至当前实际界面均存在skip才可能是正常skip流程
								Log("have a part at currentProcessPage to currentPage")
								Log("k="..k.." pageIndex="..pageIndex)
								Log("_v.allowSkip="..tostring(_v.allowSkip))
								continuousSkipFlag = true
								if _v.allowSkip ~= true then
									Log("continuousSkipFlag break")
									continuousSkipFlag = false
									break
								end
							end
						end
						
						if continuousSkipFlag == true then
							Log("have a can skip page")
							for _k, _v in pairs(taskProcess) do
								if _k >= k and _k < pageIndex then	--从当前流程界面至当前实际界面前一个均存在skip才可能是正常skip流程
									_v.skipStatus = true
								end
							end
						end
					end
				end
				
				sleep(checkInterval)
			end
			
			sleep(50)
		end
		Log("-------------------------END OF THIS ROUND TASK: "..taskName.."-----------------------")
	end
	
	M.setCurrentTaskStatus("end")
	CURRENT_TASK = TASK_NONE
end

return M
