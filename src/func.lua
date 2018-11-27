-- func.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 通用函数,需导出的均注册到_G

local lastTap={x = 0, y = 0, delay = 0}

local function getRestartedStatus()		--在启动时获取上一次运行是否执行了重启脚本的命令
	local status = getStringConfig("resartScriptStatus", "false")
	if status == "true" then
		IS_RESTARTED_SCRIPT = true
	else
		IS_RESTARTED_SCRIPT = false
	end
	setStringConfig("resartScriptStatus", "false")	--取得状态之后清空
end

local function setRestartedStatus(status)	--在重启脚本前保存重启脚本状态，用以告知下一次启动
	if status == true then
		setStringConfig("resartScriptStatus", "true")
	else
		setStringConfig("resartScriptStatus", "false")
	end
end

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
	
	setScreenScale(CFG.RESOLUTION.w, CFG.RESOLUTION.h)
	getRestartedStatus()
end

local function writeLog(content)		--写日志文件
	local file = io.open(CFG.PATH_LOG, "a")
	if file then
		file:write(content)
		io.close(file)
	end
end

function Log(content)		--打印log
	if CFG.WRITE_LOG == true then
		writeLog(content)
	end
	
	if CFG.IS_DEBUG ~= true or CFG.LOG ~= true then
		return
	end
	
	sysLog(content)
end

local function LogError(content)	--catchError专用，不受CFG.LOG的影响
	if CFG.WRITE_LOG == true then
		writeLog(content)
	end
	
	if CFG.IS_DEBUG ~= true then
		return
	end
	
	sysLog(content)
end

function catchError(errType, errMsg, forceContinueFlag)	--捕获异常，输出信息写入log文件，执行重启
	local etype = errType or ERR_UNKOWN
	local emsg = errMsg or "some error"
	local eflag = forceContinueFlag or false
	
	if etype == ERR_MAIN then
		LogError("CORE ERR------->> "..emsg)
	elseif etype == ERR_NORMAL then
		LogError("NORMAL ERR------->> "..emsg)
	elseif etype == ERR_FILE then
		LogError("FILE ERR------->> "..emsg)
	elseif etype == ERR_PARAM then
		LogError("PARAM ERR------->> "..emsg)
	elseif etype == ERR_TIMEOUT then
		LogError("TIME OUT ERR------->> "..emsg)
	elseif etype == ERR_WARNING then
		LogError("WARNING ERR------->> "..emsg)
	else
		LogError("UNKOWN ERR------->> "..emsg)
	end
	
	LogError("Interrupt time-------------->> "..os.date("%Y-%m-%d %H:%M:%S", os.time()))
	
	if forceContinueFlag then
		LogError("WARNING:  ------!!!!!!!!!! FORCE CONTINUE !!!!!!!!!!------")
		return
	end
	if etype == ERR_MAIN then	--核心错误仅允许exit
		LogError("!!!cant recover task, program will end now!!!")
		lua_exit()
	elseif etype == ERR_FILE or etype == ERR_PARAM then	--核心错误仅允许exit
		LogError("!!!cant recover task, program will end 10s later!!!")
		sleep(10000)
		lua_exit()
	elseif etype == ERR_WARNING then		--警告任何时候只提示
		LogError("!!!maybe some err in here, care it!!!")
	elseif etype == ERR_TIMEOUT then		--超时错误允许exit，restart
		if CFG.ALLOW_RESTART == true then
			if IS_RESTARTED_SCRIPT ~= true then	--首先尝试重启脚本，已经尝试过启动脚本的情况下不行再重启
				LogError("!!!its will restart script first!!!")
				setRestartedStatus(true)
				sleep(1000)
				lua_restart()
			else
				LogError("!!!its will restart app!!!")
				if restartApp(CFG.APP_ID) then
					LogError("!!!its will restart script 10s later after restart app!!!")
					sleep(10000)
					lua_restart()
				else
					LogError("!!!restart app faild, script will exit!!!")
					lua_exit()
				end
			end
		else
			LogError("!!!not allow restart, script will exit 10s later!!!")
			sleep(10000)
			lua_exit()
		end
	else
		LogError("some err in task\r\n -----!!!program will exit 10s later!!!-----")
		sleep(10000)
		lua_exit()
	end
	
end

function tap(x, y, delay)
	local d = delay or CFG.DEFAULT_TAP_TIME
	if x == nil or y == nil then
		x = 0
		y = 0
	end
	
	lastTap.x, lastTap.y, lastTap.delay= x, y, d
	touchDown(1, x, y)
	sleep(d)
	touchUp(1, x, y)
end

function longTap(x, y, delay)
	local d = delay or DEFAULT_LONG_TAP_TIME
	if x == nil or y == nil then
		x = 0
		y = 0
	end
	
	lastTap.x, lastTap.y, lastTap.delay= x, y, d
	touchDown(1, x, y)
	sleep(d)
	touchUp(1, x,y)
end

function reTap()
	if lastTap.x == nil or lastTap.y == nil or lastTap.y == nil then
		catchError(ERR_WARNING, "reTap get nil x and y")
		return
	end
	
	if lastTap.x + lastTap.y + lastTap.delay > 0 then
		catchError(ERR_WARNING, "reTap at x:"..x.." y:"..y)
		touchDown(1, lastTap.x, lastTap.y)
		sleep(lastTap.delay)
		touchUp(1, lastTap.x, lastTap.y)
	else
		catchError(ERR_WARNING, "not get lastTap info in reTap")
	end
	
	lastTap.x, lastTap.y, lastTap.delay= 0, 0, 0
end

function printTbl(tbl)--table输出,请注意不要传入对象,会无限循环卡死
	local function prt(tbl,tabnum)
		tabnum=tabnum or 0
		if not tbl then return end
		for k,v in pairs(tbl)do
			if type(v)=="table" then
				print(string.format("%s[%s](%s) = {",string.rep("\t",tabnum),tostring(k),"table"))
				prt(v,tabnum+1)
				print(string.format("%s}",string.rep("\t",tabnum)))
			else
				print(string.format("%s[%s](%s) = %s",string.rep("\t",tabnum),tostring(k),type(v),tostring(v)))
			end
		end
	end
	print("Print Table = {")
	prt(tbl,1)
	print("}")
end

function prt(...)--万能输出
	local con={...}
	for key,value in ipairs(con) do
		if(type(value)=="table")then
			printTbl(value)
			con[key]=""
		else
			con[key]=tostring(value)
		end
	end
	sysLog(table.concat(con,"  "))
end

function touchMoveTo(x1, y1, x2, y2)
	if x1 ~= x2 then
		local stepX = x2 > x1 and CFG.TOUCH_MOVE_STEP or -CFG.TOUCH_MOVE_STEP
		local stepY = (y2 - y1) / math.abs((x2 - x1) / stepX)
		
		--Log("x1="..x1.." y1="..y1.." x2="..x2.." y2="..y2)
		
		touchDown(1, x1, y1)
		sleep(200)
		for i = 1, math.abs((x2 - x1) / stepX), 1 do
			touchMove(1, x1 + i * stepX, y1 + i * stepY)
		end
		touchMove(1, x2, y2)
		sleep(200)
		touchUp(1, x2, y2)
	else
		touchDown(1, x1, y1)
		sleep(20)
		local stepY = y2 > y1 and CFG.TOUCH_MOVE_STEP or -CFG.TOUCH_MOVE_STEP
		for i = 1, math.abs((y2 - y1) / stepY), 1 do
			touchMove(1, x2, y1 + i * stepY)
		end
		touchMove(1, x2, y2)
		sleep(200)
		touchUp(1, x2, y2)
	end
end