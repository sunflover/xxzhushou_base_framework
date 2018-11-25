require("zui/Z_ui")
require("global")

function GetUI()
	DevScreen={--开发设备的参数
		Width=CFG.RESOLUTION.h,--注意Width要大于Height,开发机分辨率是啥就填啥
		Height=CFG.RESOLUTION.w --注意Width要大于Height,开发机分辨率是啥就填啥
	}

	local myui=UI:new(DevScreen,{align="left",w=90,h=90,size=40,cancelname="取消",okname="OK",countdown=0,config="zui.dat",bg="bk.png"})--在page中传入的size会成为所有page中所有控件的默认字体大小,同时也会成为所有page控件的最小行距
	local pageCoach = Page:new(myui,{text = "自动刷天梯(教练模式)", size = 24})
	local pageTestting = Page:new(myui,{text = "测试说明",size = 24})
	pageCoach:nextLine()
	pageCoach:nextLine()
	pageCoach:addLabel({text="自动使用能量   ",size=30})
	pageCoach:addRadioGroup({id="radioGropUseChage",list="使用,不使用",select=1,w=70,h=10})
	pageCoach:nextLine()
	pageCoach:nextLine()
	pageCoach:addLabel({text="循环次数       ",size=30})
	pageCoach:addEdit({id="editerCircleTimes",prompt="提示文本1",text="1",color="0,0,255",w=30,h=14,align="right",size=26})
	
	return myui
end

return GetUI