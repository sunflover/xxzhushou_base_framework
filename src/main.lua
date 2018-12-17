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
require("ocr")
require("task_list/sim")
require("task_list/leagueSim")
--local bb = require("badboy")


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
if page.getCurrentPage() ~= nil then Log(page.getCurrentPage()) else Log("nil page") end

--sleep(3000)

--[[

url = 'http://113.110.228.79:9091',



bb.loadluasocket()
local http = bb.http
local response_body = {}
local post_data = 'id=18502821860&type=start&time=20181212';  
res, code = http.request{  
    url = 'http://113.110.228.79:9091',  
    method = "POST",  
    headers =   
    {  
        ['Content-Type'] = 'application/x-www-form-urlencoded',  
        ['Content-Length'] = #post_data,  
    },  
    source = ltn12.source.string(post_data),  
    sink = ltn12.sink.table(response_body) 
	
}
prt(response_body)
]]
