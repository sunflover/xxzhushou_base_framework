-- sim.lua
-- Author: cndy1860
-- Date: 2018-11-20
-- function: 实况教练天梯模式
require("global")
require("config")
require("task")
require("func")
require("projectFunc")
require("page")

local M = {}

local taskSim = {
	name = TASK_SIM,
	process = {
		--{name = PAGE_NOTICE, justBreakingRun = true},
		{name = PAGE_MAIN, justFirstRun = true},
		{name = PAGE_ONLINE_MATCH, justFirstRun = true},
		{name = PAGE_COACH_RANK},
		{name = PAGE_MATCHED},
		{name = PAGE_ROSTER},
		{name = PAGE_PLAYING, timeout = 50},	--无action，但是可用于续接playing状态的断点流程,不允许skip
		{name = PAGE_INTERVAL, timeout = 600, checkInterval = 1000},	--半场需要时间比较就
		{name = PAGE_INTERVAL_READY},
		{name = PAGE_INTERVAL, timeout = 600, checkInterval = 1000},	--90分钟结束
		
		{name = PAGE_INTERVAL_READY},		--90分钟结束需进入加时赛
		{name = PAGE_INTERVAL, timeout = 300, checkInterval = 500},	--加时赛上半场结束
		{name = PAGE_INTERVAL_READY},
		{name = PAGE_INTERVAL, timeout = 300, checkInterval = 500},	--加时赛下半场结束需点球
		{name = PAGE_INTERVAL_READY},
		{name = PAGE_INTERVAL, timeout = 300, checkInterval = 500},	--点球结束
		
		{name = PAGE_END_READY},
		{name = PAGE_OFFLINE_FAIL, justBreakingRun = true},
		{name = PAGE_RANK_UP},
	}
}

local funcList = {}
local waitFuncList = {}

funcList[PAGE_NOTICE] = function()
	page.goNextByCatchPoint({822, 8, 953, 80}, 	--关闭消息
		"920|39|0x007aff,913|39|0xccdff2,920|32|0xccdff2,927|39|0xccdff2,920|47|0xccdff2")
	
	sleep(200)
	
	local startTime = os.time()
	while true do
		local nextPage = page.catchFewProbabilityPage(PAGE_MAIN,{
				"65|23|0x12326a,73|22|0x080808,83|3|0xffffff,919|39|0x007aff,912|39|0xccdff2,927|39|0xccdff2,920|32|0xccdff2,920|47|0xccdff2"	--还有通知
			})
		
		if nextPage == 1 then	--关闭消息
			page.goNextByCatchPoint({822, 8, 953, 80}, 	--关闭消息
				"920|39|0x007aff,913|39|0xccdff2,920|32|0xccdff2,927|39|0xccdff2,920|47|0xccdff2")
		elseif nextPage == 0 then
			break
		end
		
		if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
			catchError(ERR_TIMEOUT, "time out at close notice")
		end
		sleep(50)
	end
end

funcList[PAGE_MAIN] = function()
	switchMainPage(PAGE_MAIN_MATCH)
	page.goNextByCatchPoint({642, 181, 782, 305},
		"706|240|0x007aff,718|239|0x007aff,712|211|0xf8f9fb,680|240|0xf8f9fb,743|242|0xf8f9fb,712|270|0xf8f9fb", 500)
end

funcList[PAGE_ONLINE_MATCH] = function()
	page.goNextByCatchPoint({60, 50, 899, 489},
		"476|268|0x007aff,486|267|0x007aff,480|238|0xf8f9fb,399|83|0xef476c,397|101|0xf64f75")
end

funcList[PAGE_COACH_RANK] = function()
	sleep(200)
	
	local startTime = os.time()
	while true do
		page.goNextByCatchPoint({753, 469, 957, 533},
			"828|520|0x0079fd,782|528|0x0079fd,804|501|0x0079fd,937|526|0x0079fd")
		--低概率出现，不加入skip机制，skip机制需要等待CFG.WAIT_SKIP_NIL_PAGE时间后才能进入
		local nextPage = page.catchFewProbabilityPage(PAGE_MATCHED, "439|168|0xf5f5f5,442|182|0xdedede,411|276|0xffffff,408|315|0xdedede,401|361|0xcaddf0")
		if nextPage == 1 then	--能量不足
			page.goNextByCatchPoint({208, 281, 749, 442}, "434|374|0xcaddf0,233|358|0xcaddf0,715|387|0xcaddf0,464|333|0xf5f5f5")
			if CFG.RESTORED_ENERGY == true then
				dialog("能量不足100分钟内后继续，请勿操作", 5)
				local _startTime = os.time()
				while true do
					if os.time() - _startTime > 110 * 60 then
						dialog("已续足能量，即将继续任务", 5)
						startTime = os.time()	--重置startTime
						break
					end
					sleep(60 * 1000)	--每分钟检测一次
				end
			else
				Log("能量不足，请退出")
				dialog("能量不足，请退出")
				lua_exit()
			end
		elseif nextPage == 0 then
			break
		end
		
		if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
			catchError(ERR_TIMEOUT, "time out in PAGE_COACH_RANK")
		end
		sleep(50)
	end
end

funcList[PAGE_MATCHED] = function()
	page.goNextByCatchPoint({9, 469, 948, 534},
		"836|510|0x0079fd,782|530|0x0079fd,946|499|0x0079fd,15|526|0x5c5c5c,150|505|0x5c5c5c")
end

funcList[PAGE_ROSTER] = function()
	if CFG.ALLOW_SUBSTITUTE then
		processSwitchPlayer()
	end
	page.goNextByCatchPoint({17, 34, 951, 531},
		"820|513|0x0079fd,947|513|0x0079fd,60|302|0x0079fd,65|354|0xfdfdfd,790|132|0x1f1f1f,916|147|0x1f1f1f")
end

funcList[PAGE_PLAYING] = function()
	Log("wait playing")
end

funcList[PAGE_INTERVAL] = function()
	page.goNextByCatchPoint({354, 447, 946, 535},
		"833|517|0x0079fd,783|529|0x0079fd,942|501|0x0079fd,361|64|0x192a35,575|64|0x142733")
end

local lastPlayingPageTime = 0
local lastProcessIndex = 0
waitFuncList[PAGE_INTERVAL] = function(processIndex)
	if processIndex == 15 then		--点球时不检测,不是playing界面
		Log("on penaltyKick not execute waitFuncList!")
		return
	end
	
	if processIndex ~= lastProcessIndex then	--当切换流程片时更新
		lastPlayingPageTime = 0
		lastProcessIndex = processIndex
	end
	
	if page.isCurrentPage(PAGE_PLAYING) then
		lastPlayingPageTime = os.time()
	end
	
	if lastPlayingPageTime == 0 then	--未检测到起始playing界面，跳过
		return
	end
	
	local timeAfterLastPlayingPage = os.time() - lastPlayingPageTime	--距离最后一个playing界面的时间间隔
	
	if timeAfterLastPlayingPage >= 4 and timeAfterLastPlayingPage <= 10 and isAppRunning() then	--跳过进球回放什么的,--游戏崩溃的情况下不点击
		tap(10, 60)
		sleep(1000)
	end
	
	if lastPlayingPageTime > 0 then Log("timeAfterLastPlayingPage = "..timeAfterLastPlayingPage.."s yet")	 end
	
	--因为半场为超长时间等待，如果长时间不在playing判定为异常,因为有精彩回放所以超时为两倍(还有点球)
	if timeAfterLastPlayingPage > CFG.DEFAULT_TIMEOUT * 1.5 then
		catchError(ERR_TIMEOUT, "cant check playing at wait PAGE_INTERVAL")
	end
end

funcList[PAGE_INTERVAL_READY] = function()
	page.goNextByCatchPoint({48, 183, 952, 533},
		"834|513|0x0079fd,799|499|0x0079fd,782|531|0x0079fd,947|529|0x0079fd,271|403|0xffffff,897|241|0xffffff")
end

funcList[PAGE_END_READY] = function()
	page.goNextByCatchPoint({330, 224, 952, 532},
		"819|514|0x0079fd,947|503|0x0079fd,371|253|0x0079fd,689|391|0x12a42b,913|408|0xffffff")
end

funcList[PAGE_OFFLINE_FAIL] = function()
	page.goNextByCatchPoint({169, 132, 790, 447},
		"443|326|0xcaddf0,268|311|0xcaddf0,682|345|0xcaddf0,200|351|0x767676,745|397|0x7a7a7a")
end

funcList[PAGE_RANK_UP] = function()
	page.goNextByCatchPoint({15, 0, 943, 532},
		"832|515|0x0079fd,789|530|0x0079fd,916|13|0xffffff,247|15|0x000000")
	
	page.catchFewProbabilityPage(PAGE_COACH_RANK, "441|418|0xcaddf0,518|422|0xcaddf0,470|380|0xf5f5f5,458|463|0xf5f5f5,140|512|0x373737,406|508|0x767677,805|512|0x373737")
	sleep(1000)
	
	--可能会领取天梯奖励
	if page.catchFewProbabilityPage(PAGE_COACH_RANK, "441|418|0xcaddf0,518|422|0xcaddf0,470|380|0xf5f5f5,458|463|0xf5f5f5,140|512|0x373737,406|508|0x767677,805|512|0x373737") == 1 then
		page.goNextByCatchPoint({228, 365, 735, 474}, "445|421|0xcaddf0,460|381|0xf5f5f5,460|465|0xf5f5f5,234|420|0xf5f5f5,723|422|0xf5f5f5")
	end
end

local function initTask()
	for k, v in pairs(taskSim.process) do
		for _k, _v in pairs(funcList) do
			if v.name == _k then
				v.actionFunc = _v
			end
		end
	end
	
	for k, v in pairs(taskSim.process) do
		for _k, _v in pairs(waitFuncList) do
			if v.name == _k then
				v.waitFunc = _v
			end
		end
	end
	task.insertTask(taskSim)
end

initTask()

return M