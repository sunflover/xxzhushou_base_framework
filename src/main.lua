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

function checkResolution()
	local width, height = getScreenSize()
	
	for k, v in pairs(CFG.SUPPORT_RESOLUTION) do
		if width == v[1] and height == v[2] then
			return true
		end
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
	setScreenScale(w <= h and w or h, w > h and w or h)	
end


function processUiParam(retParam)
	--prt(retParam)
	if type(retParam.editerCircleTimes) == "number" then	--循环次数
		CFG.REPEAT_TIMES = retParam.editerCircleTimes
	else
		CFG.REPEAT_TIMES = 99
	end
	setStringConfig("REPEAT_TIMES", tostring(CFG.REPEAT_TIMES))
	
	if retParam.radioSubstitute.开启 == true then		--开场换人开关
		CFG.ALLOW_SUBSTITUTE = true
	end
	setStringConfig("ALLOW_SUBSTITUTE", tostring(CFG.ALLOW_SUBSTITUTE))
	
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
				if v ~= 0 and v == _v then
					return false	--对应有重复情况，报错
				end
			end
		end
	end
	for k, v in pairs(tmp) do
		table.insert(CFG.SUBSTITUTE_INDEX_LIST, v)
	end
	setStringConfig("SUBSTITUTE_INDEX_1", tostring(retParam.comboBoxBench1))
	setStringConfig("SUBSTITUTE_INDEX_2", tostring(retParam.comboBoxBench2))
	setStringConfig("SUBSTITUTE_INDEX_3", tostring(retParam.comboBoxBench3))
	setStringConfig("SUBSTITUTE_INDEX_4", tostring(retParam.comboBoxBench4))
	setStringConfig("SUBSTITUTE_INDEX_5", tostring(retParam.comboBoxBench5))
	setStringConfig("SUBSTITUTE_INDEX_6", tostring(retParam.comboBoxBench6))
	setStringConfig("SUBSTITUTE_INDEX_7", tostring(retParam.comboBoxBench7))
	
	if retParam.comboBoxSubstituteConditon == "主力状态为红" then
		CFG.SUBSTITUTE_CONDITION = 0
	elseif retParam.comboBoxSubstituteConditon == "替补状态更好" then
		CFG.SUBSTITUTE_CONDITION = 1
	elseif retParam.comboBoxSubstituteConditon == "替补状态好两档" then
		CFG.SUBSTITUTE_CONDITION = 2
	else
		CFG.SUBSTITUTE_CONDITION = 0
	end
	setStringConfig("SUBSTITUTE_CONDITION", tostring(CFG.SUBSTITUTE_CONDITION))
	
	return true
end

function reloadUserSetting()
	CFG.REPEAT_TIMES = tonumber(getStringConfig("REPEAT_TIMES", "5"))
	CFG.ALLOW_SUBSTITUTE = (getStringConfig("ALLOW_SUBSTITUTE", "false") == "true") == false or true
	Log(tostring(CFG.ALLOW_SUBSTITUTE))
	CFG.SUBSTITUTE_INDEX_LIST[1] = tonumber(getStringConfig("SUBSTITUTE_INDEX_1", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[2] = tonumber(getStringConfig("SUBSTITUTE_INDEX_2", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[3] = tonumber(getStringConfig("SUBSTITUTE_INDEX_3", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[4] = tonumber(getStringConfig("SUBSTITUTE_INDEX_4", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[5] = tonumber(getStringConfig("SUBSTITUTE_INDEX_5", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[6] = tonumber(getStringConfig("SUBSTITUTE_INDEX_6", "0"))
	CFG.SUBSTITUTE_INDEX_LIST[7] = tonumber(getStringConfig("SUBSTITUTE_INDEX_7", "0"))
	CFG.SUBSTITUTE_CONDITION = tonumber(getStringConfig("SUBSTITUTE_CONDITION", "0"))
end

function setCurrentTaskStatus(status)
	setStringConfig("CurrentTaskStatus", status)
end

function isLastTaskFinish()
	local status = getStringConfig("CurrentTaskStatus", "end")
	if status == "restart" then
		return false
	end
	
	return true
end

function main()
	initEnv()
	
	if isLastTaskFinish() then	--非自动重启脚本的情况下才弹出UI
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
	else	--自动重启脚本的情况下不弹出UI，直接导入上一次的参数
		reloadUserSetting()
		setCurrentTaskStatus("end")
	end
	
	local satrtPage = ""
	local startTime = os.time()
	while true do	--等出现init或者可用界面
		satrtPage = page.getCurrentPage()
		if satrtPage ~= nil then
			break
		end
		
		if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
			catchError(ERR_TIMEOUT, "time out at wait a not nil page befor run task")
		end
		sleep(200)
	end
	
	startTime = os.time()
	if satrtPage == PAGE_INIT then	--如果为init就点击跳过进入游戏主界面
		Log("catch PAGE_INIT")
		sleep(5000)		--等待init界面连网等状态
		while true do
			tap(CFG.RESOLUTION.w / 3, CFG.RESOLUTION.w / 3)
			if page.isCurrentPage(PAGE_INIT) ~= true then	--确认点击init界面生效
				sleep(3000)
				break
			end
			
			if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
				catchError(ERR_TIMEOUT, "time out in init page")
			end
			sleep(500)
		end
		Log("relase PAGE_INIT")
	end
	
	setCurrentTaskStatus("start")
	task.run(TASK_SIM, CFG.REPEAT_TIMES)
	setCurrentTaskStatus("end")
	
	lua_exit()
end

xpcall(main(), catchError(ERR_MAIN, "main err"))
init(0,1)
setScreenScale(540,960)
if page.getCurrentPage() ~= nil then page.getCurrentPage() end
