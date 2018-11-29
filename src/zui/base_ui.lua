require("zui/Z_ui")
require("global")

function GetUI()
	DevScreen={--开发设备的参数
		Width=CFG.RESOLUTION.h,--注意Width要大于Height,开发机分辨率是啥就填啥
		Height=CFG.RESOLUTION.w --注意Width要大于Height,开发机分辨率是啥就填啥
	}

	local myui=UI:new(DevScreen,{align="left",w=90,h=90,size=40,cancelname="取消",okname="OK",countdown=0,config="zui.dat",bg="bk.png"})--在page中传入的size会成为所有page中所有控件的默认字体大小,同时也会成为所有page控件的最小行距
	--local pageSubstituteSet = Page:new(myui,{text = "换人设置",size = 24})
	local pageBaseSet = Page:new(myui,{text = "基本设置", size = 24})
	pageBaseSet:nextLine()
	--pageBaseSet:addLabel({text="自动使用能量   ",size=30})
	--pageBaseSet:addRadioGroup({id="radioGropUseChage",list="使用,不使用",select=1,w=70,h=10})
	pageBaseSet:addLabel({text="开场按状态换人  ",size=30})
	pageBaseSet:addRadioGroup({id="radioSubstitute",list="开启,关闭",select=0,w=70,h=13})
	pageBaseSet:nextLine()
	pageBaseSet:nextLine()
	pageBaseSet:addLabel({text="崩溃自动重启    ",size=30})
	pageBaseSet:addRadioGroup({id="radioRestart",list="开启,关闭",select=1,w=70,h=13})
	pageBaseSet:nextLine()
	pageBaseSet:nextLine()
	pageBaseSet:addLabel({text="任务循环次数      ",size=26})
	pageBaseSet:addEdit({id="editerCircleTimes",prompt="提示文本1",text=tostring(CFG.DEFAULT_REPEAT_TIMES),color="0,0,255",w=30,h=14,align="right",size=24})
	
	
	local feildPositionStr = "位置1,位置2,位置3,位置4,位置5,位置6,位置7,位置8,位置9,位置10,位置11,不换"
	local feildPositionSubstituteCondition = "主力红才换,好一档就换,好两档才换"
	
	local pageSubstituteSet = Page:new(myui,{text = "换人设置",size = 24})
	--pageSubstituteSet:addLabel({text="    替补席按从上到下分别编号为1-7号位，球场上11个球员按从上到下，从左到右为1-11号为，可",size=15})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补1 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench1",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition1",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="                  换人说明",size=24})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补2 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench2",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition2",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="        对位换人，替补席从上到下",size=20})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补3 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench3",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition3",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="    依次为替补1-7号，场上球员严",size=20})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补4 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench4",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition4",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="    格按照从上到下（请参考编号",size=20})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补5 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench5",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition5",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="    图示），从左到右的顺序编为",size=20})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补6 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench6",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition6",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="    1-11号位置，自行对应，可设",size=20})
	pageSubstituteSet:nextLine()
	pageSubstituteSet:addLabel({text="替补7 ->",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBench7",list=feildPositionStr,select=11,w=17,h=12, size = 15})
	pageSubstituteSet:addLabel({text=" ",size=24})
	pageSubstituteSet:addComboBox({id="comboBoxBenchCondition7",list=feildPositionSubstituteCondition,select=0,w=24,h=12, size = 15})
	pageSubstituteSet:addLabel({text="    置每个位置的换人条件。",size=20})
	
	
	local pageSubstitutePic = Page:new(myui,{text = "编号图示",size = 24})
	pageSubstitutePic:addLabel({text="        ",size=20})
	pageSubstitutePic:addImage({src="substitute.jpg",w=60,h=100,xpos=0,align="cnter"})
	
	local pageTestting = Page:new(myui,{text = "相关说明",size = 24})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        注意事项：启动脚本前请先切换至主界面或天梯教练模式界面。 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        已实现的功能：自动循环刷教练天梯模式，支持加时赛和点球，支持开场 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="根据球员状态自动换人，支持游戏崩溃自动重启续接任务。  ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        需要下半场换人的请打开自动换人，另外请关闭自动铲球防止黄牌禁赛。 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        目前为测试期，功能陆续添加中。关于分辨率的问题，目前只适配了16:9 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="的比例，请其他比例分辨率用户暂时使用模拟器尝试。 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        另外不喜欢XX助手的用户，可以进群下载本脚本专用小精灵应用，无其他 ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="应用、脚本和广告（还是需要登录XX账号的）。  ",size=20, align="cnter"})
	pageTestting:nextLine()
	pageTestting:addLabel({text="        有任何问题及建议请反馈给作者，Q群：951492232",size=20, align="cnter"})
	
	return myui
end

return GetUI