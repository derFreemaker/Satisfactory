local TestClass = require("Test.TestClass")

---@class TestClass2 : TestClass
---@overload fun() : TestClass2
local TestClass2 = {}

---@private
---@param base fun(str: string)
function TestClass2:TestClass2(base)
    base("TestClass2")
end

---@private
---@param key any
function TestClass2:__index(key)
    if type(key) == "number" then
        return true
    end
    return Utils.Class.SearchValueInBase
end

---@private
---@param key any
---@param value any
function TestClass2:__newindex(key, value)
    if type(key) == "number" then
        print(value)
        self.LastNumber = key
    end
    rawset(self, key, value)
end

return Utils.Class.CreateSubClass(TestClass2, "TestClass2", TestClass)
