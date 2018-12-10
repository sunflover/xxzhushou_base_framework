-- leagueSim.lua
-- Author: cndy1860
-- Date: 2018-11-30
-- function: 实况联赛教练模式

require("global")
require("config")
require("task")
require("func")
require("projectFunc")
require("page")

local M = {}

local taskLeagueSim = {
	name = TASK_LEAGUE_SIM,
	process = {
		{name = PAGE_MAIN, allowSkip = true},	--设置为justFirstRun会影响断点任务，因为联赛断点回回到主界面去
		{name = PAGE_LEAGUE, allowSkip = true},
		{name = PAGE_LEAGUE_SIM, allowSkip = true},
		{name = PAGE_LEAGUE_MATCHED, allowSkip = true},
		{name = PAGE_ROSTER, allowSkip = true},
		{name = PAGE_LEAGUE_BREAKING, allowSkip = true, justBreakingRun = true},	--仅仅用来续接断点任务
		{name = PAGE_PLAYING, timeout = 50},	--无action，但是可用于续接playing状态的断点流程,不允许skip
		{name = PAGE_INTERVAL, timeout = 600, allowSkip = true, checkInterval = 1000},	--半场需要时间比较就
		{name = PAGE_INTERVAL_READY, allowSkip = true},
		{name = PAGE_INTERVAL, timeout = 600, allowSkip = true, checkInterval = 1000},	--90分钟结束
		{name = PAGE_END_READY},
		{name = PAGE_LEAGUE_POINTS},
		{name = PAGE_LEAGUE_RESULT},
		{name = PAGE_LEAGUE_SCOUT},
	}
}

local funcList = {}
local waitFuncList = {}


funcList[PAGE_MAIN] = function()
	switchMainPage(PAGE_MAIN_MATCH)
	page.goNextByCatchPoint({141, 364, 359, 497},
		"246|426|0x007aff,238|420|0x007aff,253|422|0x007aff,233|405|0xf8f9fb,271|439|0xf8f9fb,297|444|0xfdfdfd", 500)
end

funcList[PAGE_LEAGUE] = function()
	page.goNextByCatchPoint({25, 55, 903, 492},
		"480|267|0x000000,470|261|0x000000,489|272|0x000000,401|83|0xf52563,585|450|0x007aff")
end

funcList[PAGE_LEAGUE_SIM] = function()
	--可跳过余下比赛
	while true do
		sleep(500)
		if page.matchColors("510|501|0xcaddf0,510|522|0xcaddf0,677|511|0xcaddf0,705|506|0xcaddf0", 90) then
			page.goNextByCatchPoint({477, 449, 757, 538},	--恭喜联赛升级
				"540|511|0xcaddf0,505|498|0xcaddf0,707|520|0xcaddf0,707|499|0xcaddf0")
			sleep(500)
			page.goNextByCatchPoint({163, 120, 797, 408}, 	--确定跳到下个阶段
				"566|321|0xcaddf0,265|294|0xcaddf0,683|330|0xcaddf0,205|272|0x999999,756|270|0x131313")
			sleep(500)
			page.goNextByCatchPoint({46, 27, 869, 525},
				"438|420|0xcaddf0,265|406|0xcaddf0,683|441|0xcaddf0,187|145|0x00d422,778|153|0x00d422")
			sleep(500)
			page.goNextByCatchPoint({188, 34, 792, 502}, 	--赛季奖励
				"438|423|0xcaddf0,267|405|0xcaddf0,689|444|0xcaddf0,447|185|0xf05674,515|191|0xf05674")
		end
		
		page.goNextByCatchPoint({717, 472, 954, 536},
			"833|513|0x0079fd,771|535|0x0079fd,941|499|0x0079fd,762|501|0x696969")
		
		--低概率出现，不加入skip机制，skip机制需要等待CFG.WAIT_SKIP_NIL_PAGE时间后才能进入
		if page.catchFewProbabilityPage(PAGE_LEAGUE_MATCHED, "439|168|0xf5f5f5,442|182|0xdedede,411|276|0xffffff,408|315|0xdedede,401|361|0xcaddf0") == 1 then
			page.goNextByCatchPoint({208, 281, 749, 442}, "434|374|0xcaddf0,233|358|0xcaddf0,715|387|0xcaddf0,464|333|0xf5f5f5")
			sleep(200)
			if CFG.RESTORED_ENERGY == true then
				dialog("能量不足100分钟内后继续，请勿操作", 5)
				local startTime = os.time()
				while true do
					if os.time() - startTime > 110 * 60 then
						dialog("已续足能量，即将继续任务", 5)
						break
					end
					sleep(60 * 1000)	--每分钟检测一次
				end
			else
				Log("能量不足，请退出")
				dialog("能量不足，请退出")
				lua_exit()
			end
		else
			break	--没有能量不足就直接跳出
		end
		sleep(200)
	end
end

funcList[PAGE_LEAGUE_MATCHED] = function()
	page.goNextByCatchPoint({764, 474, 954, 535}, "843|516|0x0079fd,781|531|0x0079fd,948|502|0x0079fd,805|501|0x0079fd")
end

funcList[PAGE_ROSTER] = function()
	if CFG.ALLOW_SUBSTITUTE then
		processSwitchPlayer()
	end
	page.goNextByCatchPoint({17, 34, 951, 531},
		"820|513|0x0079fd,947|513|0x0079fd,60|302|0x0079fd,65|354|0xfdfdfd,790|132|0x1f1f1f,916|147|0x1f1f1f")
end

funcList[PAGE_LEAGUE_BREAKING] = function()
	page.goNextByCatchPoint({221, 277, 762, 431}, 	--继续
		"538|355|0xcaddf0,265|332|0xcaddf0,691|366|0xcaddf0,480|347|0xf5f5f5")
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

funcList[PAGE_LEAGUE_POINTS] = function()
	page.goNextByCatchPoint({722, 471, 956, 534},
		"841|513|0x0079fd,771|534|0x0079fd,953|493|0x0079fd,953|493|0x0079fd")
end

funcList[PAGE_LEAGUE_RESULT] = function()
	page.goNextByCatchPoint({722, 471, 956, 534},
		"841|513|0x0079fd,771|534|0x0079fd,953|493|0x0079fd,953|493|0x0079fd")
end

funcList[PAGE_LEAGUE_SCOUT] = function()
	page.goNextByCatchPoint({722, 471, 956, 534},
		"841|513|0x0079fd,771|534|0x0079fd,953|493|0x0079fd,953|493|0x0079fd")
	
	--经验值不好区分放在球探里一起跳过
	sleep(500)
	page.goNextByCatchPoint({722, 471, 956, 534},
		"841|513|0x0079fd,771|534|0x0079fd,953|493|0x0079fd,953|493|0x0079fd")
	
	--教练续约和球员续约也放在这儿快速跳过
	sleep(500)
	local startTime = os.time()
	while true do
		local nextPage = page.catchFewProbabilityPage(PAGE_LEAGUE_SIM,	--可能续约教练和球员
			{"442|337|0xcaddf0,268|319|0xcaddf0,687|349|0xcaddf0,344|198|0x4cd964,786|206|0x2e823c",	--教练续约
				"206|105|0x13304d,450|165|0xffa2a8,509|166|0xffffff,485|199|0xff3261,440|404|0xcaddf0,445|450|0xf5f5f5",
				"136|21|0x000000,264|26|0x000000,712|18|0x007aff,122|513|0xe2e2e2,760|511|0xffffff,258|512|0xc6c6c6"})--球员续约
		if nextPage == 1 then	--教练续约
			page.goNextByCatchPoint({167, 103, 792, 426},	--清除定额确定
				"442|337|0xcaddf0,268|319|0xcaddf0,687|349|0xcaddf0,344|198|0x4cd964,786|206|0x2e823c")
			sleep(500)
			page.goNextByCatchPoint({625, 171, 954, 533}, 	--续约选项确定
				"852|523|0x0079fd,781|529|0x0079fd,695|209|0x4cd964")
		elseif nextPage == 2 then	--球员续约
			if CFG.REFRESH_CONCTRACT == true then
				page.goNextByCatchPoint({188, 46, 766, 493}, 	--确定
					"443|414|0xcaddf0,266|391|0xcaddf0,681|423|0xcaddf0,479|199|0xfe3261")
				processFreshPlayerContract()
			else
				catchError(ERR_TASK_ABORT, "球员合同已用完")
			end
		elseif nextPage == 0 or nextPage == 3 then	--已经返回到教练模式主界面，3为断点任务返回到main界面
			break
		end
		
		if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
			--catchError(ERR_TIMEOUT, "timeout at wait cocah or player expired")
			break
		end
		sleep(50)
	end
end



local function initTask()
	for k, v in pairs(taskLeagueSim.process) do
		for _k, _v in pairs(funcList) do
			if v.name == _k then
				v.actionFunc = _v
			end
		end
	end
	
	for k, v in pairs(taskLeagueSim.process) do
		for _k, _v in pairs(waitFuncList) do
			if v.name == _k then
				v.waitFunc = _v
			end
		end
	end
	task.insertTask(taskLeagueSim)
end

initTask()

return M