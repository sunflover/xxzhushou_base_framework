-- global.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 任务
require("global")
require("config")
require("page")

local pairs = _G.pairs
local getCurrentTime = os.time

local currentTask = TASK_NONE
local currentProcess = PROCESS_NONE

local modName = "task"
local M = {}

_G[modName] = M
package.loaded[modName] = M

M.taskList = {	--任务列表，01预留给断点任务
	{name = TASK_BREAK_POINT},
}

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
	if currentTask ~= TASK_NONE and currentTask ~= nil then
		return currentTask
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
	
	local currentProcess = M.getTaskProcess(currentTask)
	for k, v in pairs(currentProcess) do
		if v.name == currentPage then
			return true
		end
	end
	return false
end

function M.runTask(taskName, repeatTimes, breakPointFlag)	--执行任务，param:任务名称，任务重复次数（默认为一次0），是否为断点任务
	local reTimes = repeatTimes or 1
	local firstRunProcess = true
	local breakTaskFlag = breakPointFlag ~= false
	
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
	
	for i = 1, reTimes, 1 do
		Log("-----------------------START RUN A ROUND OF TASK: "..taskName.."-----------------------")
		for k, v in pairs(taskProcess) do
			v.skipStatus = false
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
				end
				
				if getCurrentTime() - startTime > timeout then	--流程超时
					catchError(ERR_TIMEOUT, "have waitting process: "..v.name.." "..tostring(getCurrentTime()-startTime).."s yet, try end it")
				end
				
				if getCurrentTime() - startTime > CFG.WAIT_CHECK_BREAKING_TASK then	--中断任务
					if breakTaskFlag == false and firstRunProcess and CFG.ALLOW_BREAKING_TASK == TRUE then--非中断任务才可执行中断任务，否则无限循环
						Log("try load breakPoint task")
						firstRunProcess = false
						runBreakPointTask(taskName)
						startTime = getCurrentTime()	--重置startTime，防止在breakingTask后超时
					end
				end
				
				if getCurrentTime() - startTime > CFG.WAIT_CHECK_SKIP then	--跳过
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
								--Log("_v.allowSkip=".._v.allowSkip)
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
			sleep(200)
		end
		Log("-------------------------END OF THIS ROUND TASK: "..taskName.."-----------------------")
	end
end

function M.runBreakPointTask(taskName)
	local lastStaticPage = PAGE_NONE
	local lastStaticPageStartTime = 0
	
	local startTime = getCurrentTime()
	while true do	--跳过启动界面
		lastStaticPage = getCurrentPage()
		if lastStaticPage ~= nil then
			lastStaticPageStartTime = getCurrentTime()
			Log("catch a lastStaticPage info")
			break
		end
		
		if getCurrentTime() - startTime > CFG.DEFAULT_TIMEOUT then
			catch(TIMEOUT, "cant catch a no nil page in befor break point task")
		end
		sleep(100)
	end
	
	startTime = getCurrentTime()
	while true do
		if lastStaticPage ~= nil and getCurrentTime() - lastStaticPageStartTime >= 3 then		--获取到一个页面稳定3秒不变
			Log("catch a static page")
			--根据情况选择是否需要跳过一些重启后不好判断的初始界面
			--if isCurrentPage("init") then	--init对应的可能是多种情况，直接跳转下一种
			--	Log("catch a init page, skip this page")
			--	tap(100,100)
			--	--sleep(1000)
			--elseif isCurrentPage("agreement") then
			--	Log("catch a agreement page, skip this page")
			--	goNextByFindPoint({962, 749, 1078, 806}, "1018|772|0xb8e6cc,988|767|0xffffff,1035|776|0xc1e9d2,1063|776|0x65c990,990|787|0x23b260")
			--elseif isCurrentPage("tryTeamMange") then
			--	Log("catch a tryTeamMange page, skip this page")
			--	goNextByFindPoint({751, 675, 842, 733},
			--		"788|707|0x0078fd,772|701|0x2b8dfa,825|701|0x1382fc,796|710|0x0078fd,792|715|0xcaddf0")
			--else
			--	break
			--end
		end
		
		local currentPage = getCurrentPage()
		if currentPage ~= lastStaticPage then
			lastStaticPage = currentPage
			lastStaticPageStartTime = getCurrentTime()
			if currentPage ~= nil then
				Log("catch a new page")
			else
				Log("catch a new nil page")
			end
		end
		
		if getCurrentTime() - startTime > CFG.DEFAULT_TIMEOUT then
			catchError(ERR_TIMEOUT, "time out at catch a static page in break point task")
		end
	end
	
	Log("the final static page is: "..lastStaticPage)
	local taskStartPageName = lastStaticPage
	local findBreakProcessFlag = false
	local originTaskProcess = PROCESS_NONE
	
	for k, v in pairs(M.taskList) do
		if taskName == v.name then
			Log("find originTask: "..v.name)
			originTaskProcess = v.process
			break
		end
	end
	if originTaskProcess == PROCESS_NONE then
		catchError(ERR_PARAM, "cant find the break point task process")
	end
	
	Log("taskStartPageName="..taskStartPageName)
	for k, v in pairs(originTaskProcess) do		--将断点任务加入breakpoint task
		if taskStartPageName == v.name then		--找到当前界面对应的流程起始点
			Log("catch the break point page: "..v.name)
			if k == 1 then	--就在流程首个界面，应该执行正常流程
				catchError(ERR_WARNING, "break point page: "..v.name.." is the 1st process page, should go normal process")
				return true
			end
			
			findBreakProcessFlag = true
		end
		
		if findBreakProcessFlag == true then	--将流程加入breakpoint task
			Log("insert process: "..v.name.." into breakPoint process!")
			for _k, _v in pairs(M.taskList) do
				if _v.name == "breakPointTask" then
					table.insert(M.taskList[_k].process, v)
				end
			end
		end
	end
	
	Log("----------------------------------start run breakPointTask----------------------------------")
	runTask(TASK_BREAK_POINT, 1, true)
	Log("------------------------------------end run breakPointTask----------------------------------")
end

return M
