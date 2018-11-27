-- test.lua
-- Author: cndy1860
-- Date: 2018-11-20
-- function: 测试
require("global")
require("config")
require("task")
require("func")
require("projectFunc")
require("page")

local M = {}

local taskTest = {
	name = TASK_TEST,
	process = {
		{name = PAGE_ROSTER},
	}
}

local funcList = {}



funcList[PAGE_ROSTER] = function()
	processSwitchPlayer()
end



local function initTask()
	for k, v in pairs(taskTest.process) do
		for _k, _v in pairs(funcList) do
			if v.name == _k then
				v.actionFunc = _v
			end
		end
	end
	
	task.insertTask(taskTest)
end

initTask()

return M