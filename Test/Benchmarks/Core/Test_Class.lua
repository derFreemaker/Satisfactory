local luaunit = require('Test.Luaunit')
require('Test.Simulator.Simulator')

---@param func fun(num: integer?)
---@param amount integer
local function benchmarkFunction(func, amount)
    local startTime = os.clock()

    for i = 1, amount, 1 do
        func(i)
    end

    local endTime = os.clock()
    local totalTime = endTime - startTime

    print('total time: ' .. totalTime .. 's amount: ' .. amount)
    print('each time : ' .. (totalTime / amount) * 1000 * 1000 .. 'us')
end

---@param func function
---@param amount integer
local function captureFunction(func, amount)
    local startTime = os.clock()

    func()

    local endTime = os.clock()
    local totalTime = endTime - startTime

    print('total time: ' .. totalTime .. 's amount: ' .. amount)
    print('each time : ' .. (totalTime / amount) * 1000 * 1000 .. 'us')
end

function TestCreateClassBenchmark()
    benchmarkFunction(
        function()
            Utils.Class.CreateClass({}, 'CreateEmpty')
        end,
        100000
    )
end

function TestCreateClassWithBaseClassBenchmark()
    local test = Utils.Class.CreateClass({}, 'EmptyClass')

    benchmarkFunction(
        function()
            Utils.Class.CreateClass({}, 'CreateEmptyClassWithBaseClass', test)
        end,
        100000
    )
end

function TestConstructClassBenchmark()
    local test = Utils.Class.CreateClass({}, 'EmptyClass')

    benchmarkFunction(test --[[@as function]], 100000)
end

function TestExtendClassBenchmark()
    local amount = 100000

    local testClasses = {}
    for i = 1, amount, 1 do
        testClasses[i] = Utils.Class.CreateClass({}, 'EmptyClass')
    end

    local extensions = {}
    extensions.Test = "hi"

    benchmarkFunction(function(num)
        Utils.Class.ExtendClass(extensions, testClasses[num])
    end, amount)
end

function TestExtendClassInstancesBenchmark()
    local testClass = Utils.Class.CreateClass({}, 'EmptyClass')
    local amount = 100000

    local testClassInstances = {}
    for i = 1, amount, 1 do
        testClassInstances[i] = testClass()
    end

    local extensions = {
        Test0 = "hi",
        Test1 = "hi",
        Test2 = "hi",
        Test3 = "hi",
        Test4 = "hi",
        Test5 = "hi",
        Test6 = "hi",
        Test7 = "hi",
        Test8 = "hi",
        Test9 = "hi",
    }

    captureFunction(function()
        Utils.Class.ExtendClass(extensions, testClass)
    end, amount)

    for _, instance in ipairs(testClassInstances) do
        luaunit.assertEquals(instance.Test0, "hi")
        luaunit.assertEquals(instance.Test1, "hi")
        luaunit.assertEquals(instance.Test2, "hi")
        luaunit.assertEquals(instance.Test3, "hi")
        luaunit.assertEquals(instance.Test4, "hi")
        luaunit.assertEquals(instance.Test5, "hi")
        luaunit.assertEquals(instance.Test6, "hi")
        luaunit.assertEquals(instance.Test7, "hi")
        luaunit.assertEquals(instance.Test8, "hi")
        luaunit.assertEquals(instance.Test9, "hi")
    end
end

function TestDeconstructClassBenchmark()
    local test = Utils.Class.CreateClass({}, 'EmptyClass')
    local amount = 100000

    local testClasses = {}
    for i = 1, amount, 1 do
        testClasses[i] = test()
    end

    benchmarkFunction(function(num)
        local class = testClasses[num]
        Utils.Class.Deconstruct(class)
    end, amount)
end

os.exit(luaunit.LuaUnit.run())
