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
		--{name = PAGE_MAIN},
		--{name = PAGE_ONLINE_MATCH},
		{name = PAGE_COACH_RANK},
		{name = PAGE_MATCHED},
		{name = PAGE_ROSTER},
		{name = PAGE_PLAYING},	--无流程，但是用于skip流程
		{name = PAGE_INTERVAL, timeout = 600, checkInterval = 1000},	--半场需要时间比较就
		{name = PAGE_INTERVAL_READY},
		{name = PAGE_INTERVAL, timeout = 600, checkInterval = 1000},	--90分钟结束
		
		{name = PAGE_INTERVAL_READY, allowSkip = true},		--90分钟结束需进入加时赛
		{name = PAGE_INTERVAL, timeout = 300, allowSkip = true, checkInterval = 500},	--加时赛上半场结束
		{name = PAGE_INTERVAL_READY, allowSkip = true},
		{name = PAGE_INTERVAL, timeout = 300, allowSkip = true, checkInterval = 500},	--加时赛下半场结束需点球
		{name = PAGE_INTERVAL_READY, allowSkip = true},
		{name = PAGE_INTERVAL, timeout = 300, allowSkip = true, checkInterval = 500},	--点球结束
		
		{name = PAGE_END_READY},
		{name = PAGE_RANK_UP},
	}
}

local funcList = {}


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
	page.goNextByCatchPoint({751, 476, 955, 534},
		"823|511|0x0079fd,950|494|0x0079fd,943|526|0x0079fd,789|526|0x0079fd,765|507|0x696969")
end

funcList[PAGE_MATCHED] = function()
	page.goNextByCatchPoint({9, 469, 948, 534},
		"836|510|0x0079fd,782|530|0x0079fd,946|499|0x0079fd,15|526|0x5c5c5c,150|505|0x5c5c5c")
end

funcList[PAGE_ROSTER] = function()
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

funcList[PAGE_INTERVAL_READY] = function()
	page.goNextByCatchPoint({48, 183, 952, 533},
		"834|513|0x0079fd,799|499|0x0079fd,782|531|0x0079fd,947|529|0x0079fd,271|403|0xffffff,897|241|0xffffff")
end

funcList[PAGE_END_READY] = function()
	page.goNextByCatchPoint({330, 224, 952, 532},
		"819|514|0x0079fd,947|503|0x0079fd,371|253|0x0079fd,689|391|0x12a42b,913|408|0xffffff")
end

funcList[PAGE_RANK_UP] = function()
	page.goNextByCatchPoint({15, 0, 943, 532},
		"832|515|0x0079fd,789|530|0x0079fd,916|13|0xffffff,247|15|0x000000")
end

local function initTask()
	for k, v in pairs(taskSim.process) do
		for _k, _v in pairs(funcList) do
			if v.name == _k then
				v.actionFunc = _v
			end
		end
	end
	
	task.insertTask(taskSim)
end

initTask()

return M