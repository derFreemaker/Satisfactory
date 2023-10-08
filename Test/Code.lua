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

benchmarkFunction(UUID.Static__New, 100000)
