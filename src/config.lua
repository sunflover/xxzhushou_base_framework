-- config.lua
-- Author: cndy1860
-- Date: 2018-11-19
-- function: 配置参数，注册在全局表CFG中

CFG = {}	--配置文件总表，注册在_G下

-----------------版本信息-----------------
CFG.VERSION = "v0.1.2"
CFG.BIULD_TIME = "20181128"

-----------------开发分辨率-----------------
CFG.RESOLUTION = {w = 540, h = 960}

-----------------调试参数-----------------
CFG.IS_DEBUG = false		--调试
CFG.LOG = false				--是否允许输出LOG信息，必须在IS_DEBUG为TRUE的时候有效
CFG.WRITE_LOG = false		--是否将LOG写入log.txt文件


-----------------重启脚本及应用参数-----------------
CFG.ALLOW_BREAKING_TASK = false		--是否允许中断任务
CFG.ALLOW_RESTART = true			--是否允许重启脚本来解决异常
CFG.APP_ID = "com.netease.pes"		--应用名称


-----------------文件路径-----------------
CFG.PATH_LOG = "[public]log.txt"		--日志文件


-----------------超时参数-----------------
CFG.DEFAULT_TIMEOUT	= 30		--默认超时时间/s

CFG.WAIT_SKIP_NIL_PAGE = 20 	--任务开始执行时，遇到非定义界面的等待时间/s
CFG.WAIT_CHECK_SKIP = 3			--检查是否需要跳过当前界面的等待时间，需保证WAIT_CHECK_SKIP < WAIT_CHECK_BREAKING_TASK
CFG.WAIT_CHECK_BREAKING_TASK = 5	--第一次在执行流程时，如界面不在流程首界面，进入断点任务的等待时间/s

CFG.DEFAULT_TAP_TIME = 50		--默认tap时间/ms
CFG.DEFAULT_LONG_TAP_TIME = 800	--默认longtap时间/ms
CFG.DEFAULT_PAGE_CHECK_INTERVAL = 100	--等待进入流程(catched Page)时检测page(while循环中)的时间间隔/ms

CFG.DEFAULT_WAIT_AFTER_FIND = 200	--goNextByCatchPoint找到点后等待点击的默认时间/ms


-----------------找色参数-----------------
CFG.DEFAULT_FUZZY = 95		--默认颜色模糊相似度

-----------------touch参数-----------------
CFG.TOUCH_MOVE_STEP = 50	--touchMoveTo的移动步长


-----------------用户设置-----------------
CFG.ALLOW_SUBSTITUTE = false		--是否允许开场换人
CFG.SUBSTITUTE_CONDITION = 1		--换人条件:0为只有当场上状态极差才考虑换，1为好状态好一档就换，2为状态好2档才换
CFG.SUBSTITUTE_INDEX_LIST = {}			--贴补席对应关系表
CFG.REPEAT_TIMES = 0				--任务循环次数

-----------------支持分辨率-----------------
CFG.SUPPORT_RESOLUTION = {
	--9:16
	{540, 960},
	{720, 1280},
	{1080, 1920},
	{1440, 2560},
	{640, 1136},
	{750, 1334},
	--[[
	--9:18
	{1440*2880},
	{1080*2160},
	{720*1440},
	
	--10:16
	{800*1280},
	{1200*1920},
	{1600*2560},
	
	--3:5
	{1080*1800},
	{1152*1920},
	{1536*2560},
	{480*800},
	
	--3:4
	{768*1024}
	{1536*2048}]]
}
