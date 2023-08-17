local loadedFiles = {}
local ObjectClass = require("/Github-Loading/Loader/10_Object")
loadedFiles["/Github-Loading/Loader/10_Object.lua"] = { ObjectClass }
Utils = loadfile("C:/Coding/Lua/Satisfactory/Github-Loading/Loader/20_Utils.lua")(loadedFiles)

local TestClass = require("Test.TestClass")

local test = TestClass("Test1")
local testValue = test + 20
print(testValue)
print(#test)
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