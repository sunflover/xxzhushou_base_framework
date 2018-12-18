-- func.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 通用函数,需导出的均注册到_G

--记录最后一次tap()的坐标
local lastTap={x = 0, y = 0, delay = 0}

--检测当前游戏应用是否还在运行中
function isAppRunning()
	local appName = frontAppName()
	if appName == CFG.APP_ID then
		return true
	end
	
	return false
end

--将LOG信息写入日志文件,不受CFG.LOG的影响
local function writeLog(content)		--写日志文件
	if content == nil then
		return
	end
	
	local file = io.open(CFG.PATH_LOG, "a")
	if file then
		file:write("["..os.date("%d %H:%M:%S", os.time()).."]"..content.."\r\n")
		io.close(file)
	end
end

--打印LOG信息至调试信息板，允许content = nil的情况，用于排错
function Log(content)
	if CFG.WRITE_LOG == true then
		writeLog(content)
	end
	
	if CFG.LOG ~= true then
		return
	end
	
	sysLog(content)
end

--catchError专用Log函数，不受CFG.LOG的影响
local function LogError(content)
	if CFG.WRITE_LOG == true then
		writeLog(content)
	end
	
	sysLog(content)
end

--捕获捕获处理函数
function catchError(errType, errMsg, forceContinueFlag)
	local etype = errType or ERR_UNKOWN
	local emsg = errMsg or "some error"
	local eflag = forceContinueFlag or false
	
	--打印错误类型和具体信息
	if etype == ERR_MAIN or etype == ERR_TASK_ABORT then
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
	
	--强制忽略错误处理
	if forceContinueFlag then
		LogError("WARNING:  ------!!!!!!!!!! FORCE CONTINUE !!!!!!!!!!------")
		return
	end
	
	--错误处理模块
	if etype == ERR_MAIN or etype == ERR_TASK_ABORT then	--核心错误仅允许exit
		dialog(errMsg.."\r\n即将退出")
		LogError("!!!cant recover task, program will end now!!!")
		lua_exit()
	elseif etype == ERR_FILE or etype == ERR_PARAM then	--关键错误仅允许exit
		dialog(errMsg.."\r\n即将退出")
		LogError("!!!cant recover task, program will endlater!!!")
		lua_exit()
	elseif etype == ERR_WARNING then		--警告任何时候只提示
		LogError("!!!maybe some err in here, care it!!!")
	elseif etype == ERR_TIMEOUT then		--超时错误允许exit，restart
		if CFG.ALLOW_RESTART == true then	--允许重启
			dialog(errMsg.."\r\n等待超时，即将重启", 5)
			if frontAppName() == CFG.APP_ID then
				Log("TIME OUT BUT APP STILL RUNNING！")
			else
				Log("TIME OUT AND APP NOT RUNNING YET！")
			end
			
			LogError("!!!its will close app!!!")
			closeApp(CFG.APP_ID);
			sleep(1000)
			LogError("!!!its will restart app!!!")
			if runApp(CFG.APP_ID) then
				LogError("!!!its will restart script 15s later after restart app!!!")
				--记录重启状态，重启之后会直接读取上一次保存的设置信息和相关变量，并不会弹出UI以实现自动续接任务
				task.setCurrentTaskStatus("restart")
				sleep(15000)
				lua_restart()
			else
				LogError("!!!restart app faild, script will exit!!!")
				lua_exit()
			end
		else	--不允许重启直接退出
			dialog(errMsg.."\r\n等待超时，即将退出")
			LogError("!!!not allow restart, script will exit later!!!")
			lua_exit()
		end
	else
		LogError("some err in task\r\n -----!!!program will exit later!!!-----")
		lua_exit()
	end
end

--点击
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

--长按
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

--重新执行最后一次点击操作，用于处理个别点击未生效的情况
function reTap()
	if lastTap.x == nil or lastTap.y == nil then
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

--打印输出table,请注意不要传入对象,会无限循环卡死
function printTbl(tbl)
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

--万能输出
function prt(...)
	if CFG.LOG ~= true then
		return
	end
	
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

--滑动操作
function touchMoveTo(x1, y1, x2, y2)
	if x1 ~= x2 then	--非竖直滑动
		--将x,y移动距离按移动步长CFG.TOUCH_MOVE_STEP分解为步数
		local stepX = x2 > x1 and CFG.TOUCH_MOVE_STEP or -CFG.TOUCH_MOVE_STEP
		local stepY = (y2 - y1) / math.abs((x2 - x1) / stepX)
		--Log("x1="..x1.." y1="..y1.." x2="..x2.." y2="..y2)
		
		touchDown(1, x1, y1)
		sleep(200)
		for i = 1, math.abs((x2 - x1) / stepX), 1 do
			touchMove(1, x1 + i * stepX, y1 + i * stepY)
			sleep(50)
		end
		touchMove(1, x2, y2)
		sleep(200)
		touchUp(1, x2, y2)
	else	--竖直滑动，0不能作为除数所以单独处理
		touchDown(1, x1, y1)
		sleep(20)
		local stepY = y2 > y1 and CFG.TOUCH_MOVE_STEP or -CFG.TOUCH_MOVE_STEP
		for i = 1, math.abs((y2 - y1) / stepY), 1 do
			touchMove(1, x2, y1 + i * stepY)
			sleep(50)
		end
		touchMove(1, x2, y2)
		sleep(200)
		touchUp(1, x2, y2)
	end
end