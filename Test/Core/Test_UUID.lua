local luaunit = require('Test.Luaunit')
require('Test.Simulator')

local UUID = require('Core.UUID')

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
	--                           ms -> us -> ns
end

function TestNewUUID()
	benchmarkFunction(UUID.Static__New, 100000)
end

function TestEmptyUUID()
	benchmarkFunction(UUID.Static__Empty, 10000000)
end

function TestParseUUID()
	benchmarkFunction(
		function()
			UUID.Static__Parse('000000-0000-000000')
		end,
		100000
	)
end

os.exit(luaunit.LuaUnit.run())
