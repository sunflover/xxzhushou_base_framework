-- main.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 程序入口
require("global")
require("func")
require("task")
require("page")
require("task_list/sim")
require("task_list/test")

function processUiParam(retParam)
	--prt(retParam)
	if type(retParam.editerCircleTimes) == "number" then	--循环次数
		CFG.REPEAT_TIMES = retParam.editerCircleTimes
	else
		CFG.REPEAT_TIMES = 99
	end
	
	if retParam.radioSubstitute.开启 == true then		--开场换人开关
		CFG.ALLOW_SUBSTITUTE = true
	end
	
	tmp = {}											--获取替补换人对应位置
	table.insert(tmp, retParam.comboBoxBench1)
	table.insert(tmp, retParam.comboBoxBench2)
	table.insert(tmp, retParam.comboBoxBench3)
	table.insert(tmp, retParam.comboBoxBench4)
	table.insert(tmp, retParam.comboBoxBench5)
	table.insert(tmp, retParam.comboBoxBench6)
	table.insert(tmp, retParam.comboBoxBench7)
	for k, v in pairs(tmp) do		--检测一个替补有无对应多个位置
		for _k, _v in pairs(tmp) do
			if _k > k then
				if v == _v then
					return false	--对应有重复情况，报错
				end
			end
		end
	end
	for k, v in pairs(tmp) do
		table.insert(CFG.SUBSTITUTE_INDEX_LIST, v)
	end
	--prt(CFG.SUBSTITUTE_INDEX_LIST)
	
	if retParam.comboBoxSubstituteConditon == "主力状态为红" then
		CFG.SUBSTITUTE_CONDITION = 0
	elseif retParam.comboBoxSubstituteConditon == "替补状态更好" then
		CFG.SUBSTITUTE_CONDITION = 1
	elseif retParam.comboBoxSubstituteConditon == "替补状态好两档" then
		CFG.SUBSTITUTE_CONDITION = 2
	else
		CFG.SUBSTITUTE_CONDITION = 2
	end

	
	return true
end

function main()
	
	initEnv()
	
	local taskReapetTimes = 0
	
	while true do
		local UI=require("zui/base_ui")
		local uiRet = UI():show(3)
		if uiRet._cancel then
			return
		end
		
		local ret = processUiParam(uiRet)
		if ret == true then
			break
		else
			dialog("一个替补不能对应多个位置")
		end
	end
	
	--task.runTask(TASK_SIM, CFG.REPEAT_TIMES)
	--task.runTask(TASK_TEST, 1)
	
	lua_exit()
end

xpcall(main(), catchError(ERR_MAIN, "main err"))
init(0,1)
setScreenScale(540,960)
--if page.getCurrentPage() ~= nil then page.getCurrentPage() else Log("nil page") end
