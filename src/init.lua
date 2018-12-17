-- init.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 负责初始化相关
require("global")
require("func")
require("task")
require("page")
require("config")

--检测是否为支持的分辨率
local function checkResolution()
	local width, height = getScreenSize()
	
	for k, v in pairs(CFG.SUPPORT_RESOLUTION) do
		if (width == v[1] and height == v[2]) or (width == v[2] and height == v[1]) then
			return true
		end
	end
	
	return false
end

--从ui的返回值表中解析用户设置参数
local function parseUserSetting(uiParam)
	if uiParam._cancel then
		lua_exit()
	end
	prt(retParam)
	
	if uiParam.radioCoachMode.联赛 == true then		--选择模式
		CURRENT_TASK = TASK_LEAGUE_SIM
	elseif uiParam.radioCoachMode.天梯 == true then
		CURRENT_TASK = TASK_SIM
	else
		CURRENT_TASK = TASK_NONE
	end
	setStringConfig("CURRENT_TASK", CURRENT_TASK)
	
	if uiParam.radioSubstitute.开启 == true then		--开场换人开关
		CFG.ALLOW_SUBSTITUTE = true
	else
		CFG.ALLOW_SUBSTITUTE = false
	end
	setStringConfig("ALLOW_SUBSTITUTE", tostring(CFG.ALLOW_SUBSTITUTE))
	
	if uiParam.radioRefreshConctract.开启 == true then		--自动续约
		CFG.REFRESH_CONCTRACT = true
	else
		CFG.REFRESH_CONCTRACT = false
	end
	setStringConfig("REFRESH_CONCTRACT", tostring(CFG.REFRESH_CONCTRACT))
	
	if uiParam.radioRestoredEnergy.开启 == true then		--体力恢复
		CFG.RESTORED_ENERGY = true
	else
		CFG.RESTORED_ENERGY = false
	end
	setStringConfig("RESTORED_ENERGY", tostring(CFG.RESTORED_ENERGY))
	
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
	
	--将位置*转换成对应的数字
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
	
	--将换人条件转为为数字
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

--当游戏异常，脚本重启应用后会跳过UI，直接加载重启之前保存的设置参数
function loadLastUserSetting()
	IS_BREAKING_TASK = true
	CFG.APP_ID = getStringConfig("APP_ID", CFG.DEFAULT_APP_ID)
	CURRENT_TASK = getStringConfig("CURRENT_TASK", TASK_NONE)
	CFG.ALLOW_SUBSTITUTE = (getStringConfig("ALLOW_SUBSTITUTE", "false") == "true" and {true} or {false})[1]
	CFG.ALLOW_RESTART = (getStringConfig("ALLOW_RESTART", "false") == "true" and {true} or {false})[1]
	CFG.RESTORED_ENERGY = (getStringConfig("RESTORED_ENERGY", "false") == "true" and {true} or {false})[1]
	CFG.REFRESH_CONCTRACT = (getStringConfig("REFRESH_CONCTRACT", "false") == "true" and {true} or {false})[1]
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

--检测是否为断点任务(脚本重启过应用)，resatart会在task.run()中重置
local function isExsitLastBreakTask()
	local status = getStringConfig("CurrentTaskStatus", "end")
	Log(status)
	if status == "restart" then
		return true
	end
	
	return false
end

--初始化，包括弹出UI，解析设置参数，加载各种配置文件
function initEnv()
	init("0", 1)
	
	if checkResolution() ~= true then
		dialog("不支持的分辨率，请联系作者适配")
		lua_exit()
	end
	
	local appid = frontAppName()
	if appid == nil then
		dialog("未检测到任何应用")
		lua_exit()
	else
		if appid ~= CFG.APP_ID then
			if string.find(appid, CFG.APP_ID) == nil then
				dialog("请先打开实况足球再开启脚本")
				lua_exit()
			else
				CFG.APP_ID = appid
			end
		end
		setStringConfig("APP_ID", CFG.APP_ID)
	end
	
	Log(CFG.APP_ID)
	
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