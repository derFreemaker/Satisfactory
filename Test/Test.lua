Utils = require("/Github-Loading/Loader/10_Utils")

local TestClass = require("Test.TestClass")

local test = TestClass("Test1")
local testValue = test + 20
print(testValue)
test = nil ---@diagnostic disable-line
collectgarbage()

local TestClass2 = require("Test.TestClass2")

local test2 = TestClass2()

test2:Test()
print(test2[1])
print(test2:GetType())
test2[1] = 123
test2["TestValue"] = "Hi"



print("#### END ####")