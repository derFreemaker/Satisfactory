---@class TestClass : Object
---@field str string
---@operator add(integer) : integer
---@overload fun(str: string) : TestClass
local TestClass = {}

---@private
---@param str string
function TestClass:TestClass(str)
    self.str = str
end

---@private
function TestClass:_TestClass()
    print("deconstructor called: '".. self.str .."'")
end

---@private
---@param other integer
---@return integer
function TestClass:__add(other)
    return other
end


function TestClass:Test()
    print(self.str)
end


return Utils.Class.CreateClass(TestClass, "TestClass")