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
	
	if M.isExistTask(taskName) ~= true then		--检查任务是否存在
		M.setCurrentTaskStatus("end")	--清空断点任务状态，防止错误卡死
		catchError(ERR_PARAM, "have no task: "..taskName)
	end
	
	local taskProcess = M.getTaskProcess(taskName)	--检查任务流程是否存在
	if taskProcess == nil then
		catchError(ERR_PARAM, "task:"..taskName.." have no process!")
	end
	
	if page.getCurrentPage() == nil then	--等待获取一个已定义界面(非过度界面)
		Log("waiting until catch a not nil page")
		local startTime = os.time()
		while true do
			if page.getCurrentPage() then
				break
			end
			
			if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
				catchError(ERR_TIMEOUT, "still start from a unkown page! can not work!")
			end
			
			sleep(200)
		end
	end
	
	M.setCurrentTaskStatus("start")
	
	for i = 1, reTimes, 1 do
		Log("-----------------------START RUN A ROUND OF TASK: "..taskName.."-----------------------")
		for k, v in pairs(taskProcess) do
			if i == 1 then	--首次运行断点流程(断点未发生的情况下)均不跳过
				if v.justBreakingRun == true then
					if IS_BREAKING_TASK then
						v.skipStatus = false
					else
						v.skipStatus = true
					end
				else
					v.skipStatus = false
				end
			else	--非首次运行跳过仅首次运行和续接断点流程片的流程片
				if v.justFirstRun or v.justBreakingRun then	--跳过只允许首次运行的流程片和断点流程片
					v.skipStatus = true
				else
					v.skipStatus = false
				end
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
					
					break	--完成当前流程片
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
							if _v.name == currentPage then	--当前界面为其后的某个流程片中界面
								Log("set it skip between current process page and a next process page")
								for __k, __v  in pairs(taskProcess) do
									if __k >= k and __k < _k then
										__v.skipStatus = true
									end
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
end

return M
