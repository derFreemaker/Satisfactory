local luaunit = require('Test.Luaunit')
require('Test.Simulator')

---@param func function
---@param amount integer
local function benchmarkFunction(func, amount)
	local startTime = os.clock()

	for i = 1, amount, 1 do
		func()
	end

	local endTime = os.clock()

	local totalTime = endTime - startTime

	print('total time: ' .. totalTime .. 's amount: ' .. amount)
	print('each time : ' .. (totalTime / amount) * 1000 * 1000 .. 'us')
end

function TestCreateClass()
	benchmarkFunction(
		function()
			Utils.Class.CreateClass({}, 'CreateEmpty')
		end,
		100000
	)
end

local testClass = Utils.Class.CreateClass({}, 'EmptyBaseClass')

function TestCreateClassWithBaseClass()
	benchmarkFunction(
		function()
			Utils.Class.CreateClass({}, 'CreateEmptyWithBaseClass', testClass)
		end,
		100000
	)
end

function TestConstructClass()
	benchmarkFunction(testClass --[[@as function]], 100000)
end

-- function TestConstructAndDeconstructClass()
--     benchmarkFunction(function()
--         local class = testClass()
--         Utils.Class.Deconstruct(class)
--     end, 100000)
-- end

os.exit(luaunit.LuaUnit.run())
