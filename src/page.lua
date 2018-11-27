-- page.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 界面相关处理
require("global")
require("config")

local type = type
local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local strFormat = string.format
local getCurrentTime = os.time
local strSub = string.sub
local strFind = string.find
local tbInsert = table.insert

local modName = "page"
local M = {}

_G[modName] = M
package.loaded[modName] = M

M.pageEigenvalueList = {
	{pageName = PAGE_MAIN, points = "136|21|0x000000,264|26|0x000000,712|18|0x007aff,122|513|0xe2e2e2,155|511|0xffffff,258|512|0xc6c6c6"},
	{pageName = PAGE_ONLINE_MATCH, points = "146|23|0x000000,265|18|0x000000,712|20|0x007aff,128|512|0x0079fd,196|439|0xffffff,745|270|0x007bfd"},
	{pageName = PAGE_COACH_RANK, points = "137|21|0x000000,712|19|0x007aff,295|82|0x1f1f1f,64|109|0x0079fd,74|408|0x0079fd,228|514|0x696969"},
	{pageName = PAGE_MATCHED, points = "140|23|0x000000,713|18|0xc6c6c9,127|515|0x5c5c5c,824|504|0x0079fd"},
	{pageName = PAGE_ROSTER, points = "139|24|0x000000,713|21|0xc6c6c9,60|303|0x0079fd,852|120|0x005cbf,780|433|0x1f1f1f,812|513|0x0079fd"},
	{pageName = PAGE_PLAYING, points = "105|23|0x24353f,222|21|0x21323d,125|54|0x0ce0f1,205|50|0x08dca8", fuzzy = 80},
	{pageName = PAGE_INTERVAL, points = "378|106|0xe7fbfc,446|104|0x283944,625|271|0xebfef8,529|366|0x293943,479|455|0x1e3133"},
	{pageName = PAGE_INTERVAL_READY, points = "398|244|0xffffff,706|244|0x0079fd,804|391|0xffffff,829|510|0x0079fd"},
	{pageName = PAGE_END_READY, points = "398|244|0x0079fd,706|244|0xffffff,674|392|0x0079fd,689|391|0x12a42b,829|510|0x0079fd"},
	{pageName = PAGE_RANK_UP, points = "267|25|0x000000,619|22|0xc6c6c9,598|20|0xffffff,713|18|0xc6c6c9,818|22|0xc6c6c9,824|512|0x0079fd"},
	
	{pageName = PAGE_SUBSTITUTED, points = "73|35|0xffffff,177|119|0xffffff,785|138|0x131313,827|125|0x003773,788|433|0x131313"},
	{pageName = PAGE_PLAYER_STATUS, points = "124|510|0x0079fd,68|407|0xfdfdfd,825|128|0x005cbf,800|275|0xff9500,797|421|0x1f1f1f"},
	
}
function M.toPointsString(pointsTable)		--将{{x1, y1, c1},{x2, y2, c2},}转换成"x1|y1|c1,x2|y2|c2"格式
	local strr = ""
	for k, v in pairs(points) do
		strr = strr..tostring(v[1]).."|"..tostring(v[2]).."|"..strFormat("0x%06x",v[3])..","
	end
	strr = strSub(strr,1,-2)
	return strr
end

function M.toPointsTable(pointString)		--将"x1|y1|c1,x2|y2|c2"转换成{{x1, y1, c1},{x2, y2, c2},}格式
	local pointsTable = {}
	local lastI = 0
	local lastJ = 0
	local i = 0
	local j = 0
	local pointStr = ""
	local tmpStr = pointString..","
	
	while true do
		local tmpTable = {}
		i = strFind(tmpStr, ",", i + 1)
		if i == nil then
			break
		end
		pointStr = strSub(tmpStr, lastI + 1, i - 1)
		j = strFind(pointStr, "|")
		
		tbInsert(tmpTable,tonumber(strSub(pointStr, 1, j-1)))
		
		lastJ = j
		j = strFind(pointStr, "|", j + 1)
		
		tbInsert(tmpTable, tonumber(strSub(pointStr, lastJ + 1, j-1)))
		tbInsert(tmpTable,tonumber(strSub(pointStr, j + 1, -1)))
		tbInsert(pointsTable, tmpTable)
		lastI = i
	end
	
	return pointsTable
end

function M.isColor(x,y,c,s)   --x,y为坐标值，c为颜色值，s为相似度，范围0~100。
	local fl,abs = math.floor,math.abs
	s = fl(0xff*(100-s)*0.01)
	local r,g,b = fl(c/0x10000),fl(c%0x10000/0x100),fl(c%0x100)
	local rr,gg,bb = getColorRGB(x,y)
	if abs(r-rr)<s and abs(g-gg)<s and abs(b-bb)<s then
		return true
	end
	return false
end

function M.matchColors(points, fuzzy)		--匹配界面
	f = fuzzy or CFG.DEFAULT_FUZZY
	local tmpPoints = {}
	if type(points) == "string" then
		tmpPoints = M.toPointsTable(points)
	elseif type(points) == "table" then
		tmpPoints = points
	else
		catchError(ERR_PARAM, "get a wrong type value in matchColors")
	end
	
	for k, v in pairs(tmpPoints) do
		if M.isColor(v[1], v[2], v[3], f) == false then
			return false
		end
	end
	return true
end

function M.getCurrentPage()		--获取当前界面
	for _, v in pairs(M.pageEigenvalueList) do
		local f = v.fuzzy or CFG.DEFAULT_FUZZY
		local isMatch = M.matchColors(v.points, f)
		if isMatch then
			Log("get current page : "..v.pageName)
			return v.pageName
		end
		--sleep(10)
	end
end

function M.isCurrentPage(pageName)		--验证当前界面是否为pageName界面
	for k, v in pairs(M.pageEigenvalueList) do
		if v.pageName == pageName then
			local f = v.fuzzy or CFG.DEFAULT_FUZZY
			return page.matchColors(v.points, f)
		end
	end
	return false
end

function M.catchPage(points, waitTime,fuzzy)		--等待捕获到指定界面再释放
	local wt = waitTime or DEFAULT_TIMEOUT
	local f = fuzzy or CFG.DEFAULT_FUZZY
	
	local startTime = getCurrentTime()
	while true do
		if matchColors(points, f) then
			break
		end
		if getCurrentTime() - startTime > wt then
			catchError(ERR_TIMEOUT, "catchPage timeout")
			break
		end
		sleep(50)
	end
end

function M.goNextByCatchPoint(rect, points, delay, fuzzy)	--通过找点然后点击进入下一步
	Log("in goNextByFindPoint")
	f = fuzzy or CFG.DEFAULT_FUZZY
	d = delay or CFG.DEFAULT_WAIT_AFTER_FIND
	local tmpPoints = {}
	if type(points) == "table" then
		tmpPoints = M.toPointsString(points)
	elseif type(points) == "string" then
		tmpPoints = points
	else
		catchError(ERR_PARAM, "get a wrong type value in matchColors")
	end
	
	local startTime = getCurrentTime()
	while true do
		x, y = findColor(rect, tmpPoints, f)
		if x ~= -1 and y ~= -1 then
			Log("get the next point x:"..x.."  y:"..y)
			sleep(d)
			tap(x, y)
			break
		end
		
		if getCurrentTime() - startTime > d then
			catchError(ERR_TIMEOUT, "execute goNextByCatchPoint timeout")
		end
		
		sleep(50)
	end
end

function M.goNextByPoint(x, y)		--通过固定点点击进入下一步
	tap(x, y)
end

return M
