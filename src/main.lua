-- main.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 程序入口
require("global")
require("config")
require("init")
require("func")
require("task")
require("page")
require("task_list/sim")
require("task_list/leagueSim")


function main()
	initEnv()		--初始化用户参数，UI

	page.waitSkipNilPage()	--跳过启动应用时的过度动画
	
	skipInitPage()	--跳过init界面
	
	task.run(CURRENT_TASK, CFG.REPEAT_TIMES)
	
	lua_exit()
end

xpcall(main(), catchError(ERR_MAIN, "main err"))
init(0,1)
setScreenScale(540,960)
--if page.getCurrentPage() ~= nil then dialog(page.getCurrentPage()) else Log("手机即将爆炸，快找作者反馈") end
--dialog(CFG.APP_ID)  
--loadLastUserSetting()
sleep(3000)
processSwitchPlayer()