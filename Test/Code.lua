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

require('Test.Simulator.Simulator')

benchmarkFunction(function()
    Utils.String.Split("/Test/../Test/Path/./log.txt", "/")
end, 1000000)

-- local Path = require("Core.Path_new")

-- local test = Path("/Github-Loading/Loader/../")

-- print(test)
