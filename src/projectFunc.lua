-- projectFunc.lua
-- Author: cndy1860
-- Date: 2018-11-20
-- function: 项目相关函数

require("func")
require("page")

function switchMainPage(pageName)	--在主界面4个子界面切换
	if page.isCurrentPage(PAGE_MAIN) ~= true then
		dialog("请先返回主界面！")
		
		local startTime = os.time()
		while true do
			if isCurrentPage(PAGE_MAIN) then
				break
			end
			
			if os.time() - startTime > CFG.DEFAULT_TIMEOUT then
				catchError(ERR_TIMEOUT, "cant back to main face!")
			end
			sleep(100)
		end
	end
	Log("swich to "..pageName)
	if pageName == PAGE_MAIN_MATCH then
		tap(130,80)
	elseif pageName == PAGE_MAIN_CLUB then
		tap(360,80)
	elseif pageName == PAGE_MAIN_CONCTRACT then
		tap(600,80)
	elseif pageName == PAGE_MAIN_EXTRAS then
		tap(830,80)
	else
		catchError(ERR_PARAM, "swich a wrong page")
	end
end

local function getFixStatusPlayers(area, status)	--获取某种状态的所有球员
	local playerStatusInfo = {}
	local colorStr = ""
	
	if status == "excellent" then	--状态极好
		colorStr = "467|452|0x003b2c,492|452|0x003b2c,492|477|0x003b2c,468|477|0x003b2c,480|465|0x00ffc2"
	elseif status == "good" then	--状态较好
		colorStr = "467|452|0x263900,492|452|0x263900,492|477|0x263900,468|477|0x263900,480|465|0x97dc00"
	elseif status == "bad" then		--状态较差
		colorStr = "467|452|0x3c2200,492|452|0x3c2200,492|477|0x3c2200,468|477|0x3c2200,480|465|0xb36600"
	elseif status == "worse" then	--状态极差
		colorStr = "467|452|0x3c0e0e,492|452|0x3c0e0e,492|477|0x3c0e0e,468|477|0x3c0e0e,480|465|0xb90000"
	elseif status == "normal" then	--状态一般
		colorStr = "467|452|0x363000,492|452|0x363000,492|477|0x363000,468|477|0x363000,480|465|0xc4bc00"
	else
		catchError(ERR_PARAM, "get a worong status in getFixStatusPlayers")
	end
	
	local points = findColors(area, colorStr, 95, 0, 0, 0)
	if #points == 0 then
		Log("cant find point on :"..status)
		return playerStatusInfo
	end
	
	for k, v in pairs(points) do
		local exsitFlag = false
		for _k, _v in pairs(playerStatusInfo) do
			if math.abs(v.x - _v.x) < 20 and math.abs(v.y - _v.y) < 20 then
				exsitFlag = true
				break
			end
		end
		
		if exsitFlag == false then
			table.insert(playerStatusInfo, v)
		end
	end
	
	prt("status: "..status.." count "..#playerStatusInfo)
	
	return playerStatusInfo
end

local function getPlayerStatusInfo(seats)	--获取所有场上球员的状态信息，包括状态和排布位置，分场上球员和替补席位
	local players = {}	--球员的坐标及状态
	local searchArea = {}
	if seats == "field" then	--场上球员
		searchArea = {208,73,744,486}
	elseif seats == "benchFirstHalf" then		--替补席前半部分
		searchArea = {25,48,132,480}
	elseif seats == "benchLatterHalf" then		--替补席后半部分
		searchArea = {25,200,132,480}
	else
		catchError(ERR_PARAM, "get a worong seats in getPlayerStatusInfo")
	end
	
	local statusList = {"worse", "bad", "normal", "good", "excellent"}
	for k, v in pairs(statusList) do
		local fixStatusPlayers = getFixStatusPlayers(searchArea, v)
		if #fixStatusPlayers ~= 0 then
			for _k, _v in pairs(fixStatusPlayers) do
				_v.status = k	--将状态写入对应的球员,用数值表示
				table.insert(players, _v)	--加入到球员总表
			end
		end
	end
	
	local sortMethod = function(a, b)
		if a.x == nil or a.y == nil or b.x == nil or b.y == nil then
			return
		end
		
		if a.y == b.y then
			return a.x < b.x
		else
			return a.y < b.y
		end
	end
	
	table.sort(players, sortMethod)
	
	return players
end

function processSwitchPlayer()
	tap(609,491)	--切换状态界面
	sleep(1000)	--一定要留够时间
	local fieldPlayers = getPlayerStatusInfo("field")	--获取场上球员信息
	prt(fieldPlayers)
	
	tap(68,314)		--打开贴补席
	sleep(500)
	
	local benchPlayersFirstHalf = getPlayerStatusInfo("benchFirstHalf")	--获取替补席球员信息，显现出的前半部分
	if #CFG.SUBSTITUTE_INDEX_LIST > 0 then		--将用户的对应关系写入benchPlayersInfo
		for k, v in pairs(benchPlayersFirstHalf) do
			v.fieldIndex = CFG.SUBSTITUTE_INDEX_LIST[k]
		end
	else	--将默认的对应关系写入benchPlayersInfo
		for k, v in pairs(benchPlayersFirstHalf) do
			v.fieldIndex = k
		end
	end
	
	touchMoveTo(20, 500, 20, 110) --滑动替补至下半部分
	
	local benchPlayersLatterHalf = getPlayerStatusInfo("benchLatterHalf")	--获取替补席球员信息，未显示的后半部分
	if #CFG.SUBSTITUTE_INDEX_LIST > 0 then		--将用户的对应关系写入benchPlayersInfo
		for k, v in pairs(benchPlayersLatterHalf) do
			v.fieldIndex = CFG.SUBSTITUTE_INDEX_LIST[k + #benchPlayersFirstHalf]
		end
	else	--将默认的对应关系写入benchPlayersInfo
		for k, v in pairs(benchPlayersLatterHalf) do
			v.fieldIndex = k + #benchPlayersFirstHalf
			prt(v.fieldIndex)
		end
	end
	
	for k, v in pairs(benchPlayersLatterHalf) do	--先换下半部分的
		local substituteFlag = false	--是否换过人标志
		if v.fieldIndex ~= 0 then
			if CFG.SUBSTITUTE_CONDITION == 0 then	--主力为极差的时候才换
				if fieldPlayers[v.fieldIndex].status == 1 and v.status > 1 then
					substituteFlag = true
					touchMoveTo(v.x, v.y, fieldPlayers[v.fieldIndex].x, fieldPlayers[v.fieldIndex].y)
				end
			else	--根据状态档次替换
				--Log("v.status="..v.status.."  fieldPlayers.status="..fieldPlayers[v.fieldIndex].status)
				if v.status - fieldPlayers[v.fieldIndex].status >= CFG.SUBSTITUTE_CONDITION then
					substituteFlag = true
					touchMoveTo(v.x, v.y, fieldPlayers[v.fieldIndex].x, fieldPlayers[v.fieldIndex].y)
				end
			end
			
			if substituteFlag then	--换人了需要再次调出替补名单
				--sleep(200)
				page.goNextByCatchPoint({5, 238, 146, 390}, "63|316|0x0079fd,53|322|0xfdfdfd,88|320|0xfdfdfd,61|345|0xfdfdfd")
				sleep(500)
			end
		end
	end
	sleep(200)
	
	touchMoveTo(20, 110, 20, 500) --滑滑动替补回到上半部分
	sleep(500)
	
	for k, v in pairs(benchPlayersFirstHalf) do		--换上半部分
		local substituteFlag = false	--是否换过人标志
		if v.fieldIndex ~= 0 then
			if CFG.SUBSTITUTE_CONDITION == 0 then	--主力为极差的时候才换
				if fieldPlayers[v.fieldIndex].status == 1 and v.status > 1 then
					substituteFlag = true
					touchMoveTo(v.x, v.y, fieldPlayers[v.fieldIndex].x, fieldPlayers[v.fieldIndex].y)
				end
			else	--根据状态档次替换
				if v.status - fieldPlayers[v.fieldIndex].status >= CFG.SUBSTITUTE_CONDITION then
					--Log("-----"..fieldPlayers[v.fieldIndex].x.." y="..fieldPlayers[v.fieldIndex].y)
					substituteFlag = true
					touchMoveTo(v.x, v.y, fieldPlayers[v.fieldIndex].x, fieldPlayers[v.fieldIndex].y)
				end
			end
			
			if k < #benchPlayersFirstHalf and substituteFlag then	--换人了需要再次调出替补名单, 除开最后一次
				--sleep(200)
				page.goNextByCatchPoint({5, 238, 146, 390}, "63|316|0x0079fd,53|322|0xfdfdfd,88|320|0xfdfdfd,61|345|0xfdfdfd")
				sleep(500)
			end
		end
		
		if k == #benchPlayersFirstHalf and substituteFlag == false then	--最后一次没换过人需要退出替补名单
			tap(480, 465)
		end
	end
end
