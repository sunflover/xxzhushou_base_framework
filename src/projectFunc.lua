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