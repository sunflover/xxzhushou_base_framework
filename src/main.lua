-- main.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 程序入口
require("global")
require("func")
require("task")
require("page")
require("task_list/sim")

function main()
	
	initEnv()
	
	local taskReapetTimes = 0
	
	local UI=require("zui/base_ui")
	local uiRet = UI():show(3)
	if uiRet._cancel then
		return
	else
		Log("type="..type(uiRet.editerCircleTimes))
		if type(uiRet.editerCircleTimes) == "number" then
			taskReapetTimes = uiRet.editerCircleTimes
			Log("taskReapetTimes="..taskReapetTimes)
		end
	end
	
	
	task.runTask(TASK_SIM, taskReapetTimes)
	lua_exit()
end

xpcall(main(), catchError(ERR_MAIN, "main err"))
--init(0,1)
--setScreenScale(540,960)
--if page.getCurrentPage() ~= nil then Log(page.getCurrentPage()) else Log("nil page") end
