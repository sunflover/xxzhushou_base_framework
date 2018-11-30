-- init.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 负责初始化相关
require("global")
require("func")
require("task")
require("page")
require("config")

local function checkResolution()
	local width, height = getScreenSize()
	
	for k, v in pairs(CFG.SUPPORT_RESOLUTION) do
		if (width == v[1] and height == v[2]) or (width == v[2] and height == v[1]) then
			return true
		end
	end
	
	return false
end

local function parseUserSetting(uiParam)
	if uiParam._cancel then
		lua_exit()
	end
	prt(retParam)
	
	if uiParam.radioSubstitute.开启 == true then		--开场换人开关
		CFG.ALLOW_SUBSTITUTE = true
	else
		CFG.ALLOW_SUBSTITUTE = false
	end
	setStringConfig("ALLOW_SUBSTITUTE", tostring(CFG.ALLOW_SUBSTITUTE))
	
	if uiParam.radioRestart.开启 == true then		--崩溃自动重启开关
		CFG.ALLOW_RESTART = true
	else
		CFG.ALLOW_RESTART = false
	end
	setStringConfig("ALLOW_RESTART", tostring(CFG.ALLOW_RESTART))
	
	if type(uiParam.editerCircleTimes) == "number" then	--循环次数
		CFG.REPEAT_TIMES = uiParam.editerCircleTimes
	else
		CFG.REPEAT_TIMES = CFG.DEFAULT_REPEAT_TIMES
	end
	setStringConfig("REPEAT_TIMES", tostring(CFG.REPEAT_TIMES))
	
	local function _convertIndex(posation)
		if type(posation) ~= "string" then
			return 0
		end
		
		if posation == "位置1" then
			return 1
		elseif posation == "位置2" then
			return 2
		elseif posation == "位置3" then
			return 3
		elseif posation == "位置4" then
			return 4
		elseif posation == "位置5" then
			return 5
		elseif posation == "位置6" then
			return 6
		elseif posation == "位置7" then
			return 7
		elseif posation == "位置8" then
			return 8
		elseif posation == "位置9" then
			return 9
		elseif posation == "位置10" then
			return 10
		elseif posation == "位置11" then
			return 11
		elseif posation == "不换" then
			return 0
		else
			return 0
		end
	end
	
	local function _convertCondition(condition)
		if type(condition) ~= "string" then
			return 0
		end
		
		if condition == "主力红才换" then
			return 0
		elseif condition == "好一档就换" then
			return 1
		elseif condition == "好两档才换" then
			return 2
		else
			return 0
		end
	end
	
	local tbIndex = {}	--获取换人对应位置关系
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench1))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench2))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench3))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench4))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench5))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench6))
	table.insert(tbIndex, _convertIndex(uiParam.comboBoxBench7))
	
	local tbCondition = {}	--获取换人条件
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition1))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition2))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition3))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition4))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition5))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition6))
	table.insert(tbCondition, _convertCondition(uiParam.comboBoxBenchCondition7))
	
	for k, v in pairs(tbIndex) do		--检测一个替补有无对应多个位置
		for _k, _v in pairs(tbIndex) do
			if _k > k then
				if v ~= 0 and v == _v then
					return false	--对应有重复情况，报错
				end
			end
		end
	end
	
	for k, v in pairs(tbIndex) do	--将换人对应位置和条件写入CFG.SUBSTITUTE_INDEX_LIST中
		CFG.SUBSTITUTE_INDEX_LIST[k].fieldIndex = tbIndex[k]
		CFG.SUBSTITUTE_INDEX_LIST[k].substituteCondition = tbCondition[k]
	end
	
	setStringConfig("SUBSTITUTE_INDEX_1", tostring(tbIndex[1]))
	setStringConfig("SUBSTITUTE_INDEX_2", tostring(tbIndex[2]))
	setStringConfig("SUBSTITUTE_INDEX_3", tostring(tbIndex[3]))
	setStringConfig("SUBSTITUTE_INDEX_4", tostring(tbIndex[4]))
	setStringConfig("SUBSTITUTE_INDEX_5", tostring(tbIndex[5]))
	setStringConfig("SUBSTITUTE_INDEX_6", tostring(tbIndex[6]))
	setStringConfig("SUBSTITUTE_INDEX_7", tostring(tbIndex[7]))
	
	setStringConfig("SUBSTITUTE_CONDITION_1", tostring(tbCondition[1]))
	setStringConfig("SUBSTITUTE_CONDITION_2", tostring(tbCondition[2]))
	setStringConfig("SUBSTITUTE_CONDITION_3", tostring(tbCondition[3]))
	setStringConfig("SUBSTITUTE_CONDITION_4", tostring(tbCondition[4]))
	setStringConfig("SUBSTITUTE_CONDITION_5", tostring(tbCondition[5]))
	setStringConfig("SUBSTITUTE_CONDITION_6", tostring(tbCondition[6]))
	setStringConfig("SUBSTITUTE_CONDITION_7", tostring(tbCondition[7]))
	
	prt(CFG.SUBSTITUTE_INDEX_LIST)
	return true
end

local function loadLastUserSetting()		--加载重启前的UI设置参数
	CFG.ALLOW_SUBSTITUTE = (getStringConfig("ALLOW_SUBSTITUTE", "false") == "true") == false or true
	CFG.ALLOW_RESTART = (getStringConfig("ALLOW_RESTART", "false") == "true") == false or true
	CFG.REPEAT_TIMES = tonumber(getStringConfig("REPEAT_TIMES", tostring(CFG.DEFAULT_REPEAT_TIMES)))
	
	CFG.SUBSTITUTE_INDEX_LIST[1].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_1", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[2].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_2", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[3].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_3", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[4].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_4", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[5].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_5", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[6].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_6", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[7].fieldIndex = tonumber(getStringConfig("SUBSTITUTE_INDEX_7", "0"))
	
	CFG.SUBSTITUTE_INDEX_LIST[1].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_1", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[2].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_2", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[3].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_3", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[4].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_4", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[5].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_5", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[6].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_6", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[7].substituteCondition = tonumber(getStringConfig("SUBSTITUTE_CONDITION_7", "0"))
	
	prt(CFG.ALLOW_SUBSTITUTE)
	prt(CFG.ALLOW_RESTART)
	prt(CFG.REPEAT_TIMES)
	prt(CFG.SUBSTITUTE_INDEX_LIST)
end

local function isExsitLastBreakTask()
	local status = getStringConfig("CurrentTaskStatus", "end")
	if status == "restart" then
		return true
	end
	
	return false
end

function initEnv()		--初始化
	init("0", 1)
	
	if checkResolution() ~= true then
		dialog("不支持的分辨率，请联系作者适配")
		lua_exit()
	end
	
	local w, h = CFG.RESOLUTION.w, CFG.RESOLUTION.h
	setScreenScale((w <= h) and w or h, (w > h) and w or h)
	
	if isExsitLastBreakTask() ~= true then	--没有上一次的中断任务，开始新任务弹出UI
		while true do
			local UI=require("zui/base_ui")
			local uiRet = UI():show(3)
			if uiRet._cancel then
				lua_exit()
			end
			--prt(uiRet)
			local ret = parseUserSetting(uiRet)
			if ret == true then
				break
			else
				dialog("多个替补不能对应同一位置")
			end
			
			sleep(200)
		end
	else	--有上一次的中断的任务，读取上一次保存的配置，不弹出UI
		loadLastUserSetting()
	end
end