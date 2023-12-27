local luaunit = require('Tools.Testing.Luaunit')
local functions = require("Tools.Testing.Functions")
require('Tools.Testing.Simulator'):Initialize(1)

function TestCreateClassBenchmark()
    functions.benchmarkFunction(
        function()
            Utils.Class.Create({}, 'CreateEmpty')
        end,
        100000
    )
end

function TestCreateClassWithBaseClassBenchmark()
    local test = Utils.Class.Create({}, 'EmptyClass')

    functions.benchmarkFunction(
        function()
            Utils.Class.Create({}, 'CreateEmptyClassWithBaseClass', test)
        end,
        100000
    )
end

function TestConstructClassBenchmark()
    local test = Utils.Class.Create({}, 'EmptyClass')

    functions.benchmarkFunction(test --[[@as function]], 100000)
end

function TestExtendClassBenchmark()
    local amount = 100000

    local testClasses = {}
    for i = 1, amount, 1 do
        testClasses[i] = Utils.Class.Create({}, 'EmptyClass')
    end

    local extensions = {}
    extensions.Test = "hi"

    functions.benchmarkFunction(function(num)
        Utils.Class.Extend(testClasses[num], extensions)
    end, amount)
end

function TestExtendClassInstancesBenchmark()
    local testClass = Utils.Class.Create({}, 'EmptyClass')
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

    functions.captureFunction(function()
        Utils.Class.Extend(testClass, extensions)
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
    local test = Utils.Class.Create({}, 'EmptyClass')
    local amount = 100000

    local testClasses = {}
    for i = 1, amount, 1 do
        testClasses[i] = test()
    end

    functions.benchmarkFunction(function(num)
        local class = testClasses[num]
        Utils.Class.Deconstruct(class)
    end, amount)
end

function TestAccessModifier()
    local test = Utils.Class.Create({ Static__Test = "hi" }, "TestAccessModifierClass")
    local amount = 100000

    functions.benchmarkFunction(function()
        _ = test.Static__Test
    end, amount)
end

os.exit(luaunit.LuaUnit.run())
