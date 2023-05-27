local PackageData = {}

-- ########## Test ##########

-- ########## Test.Entities ##########

PackageData.oVIzFPpX = {
    Namespace = "Test.Entities.Controller",
    Name = "Controller",
    FullName = "Controller.lua",
    IsRunable = true,
    Data = [[
local Controller = {}
Controller.__index = Controller
function Controller.Test()
    return "Controller"
end
return Controller
]] }

-- ########## Test.Entities ########## --

PackageData.PksKdJNx = {
    Namespace = "Test.Config",
    Name = "Config",
    FullName = "Config.json",
    IsRunable = false,
    Data = [[

]] }

PackageData.qzdVACkX = {
    Namespace = "Test.File1",
    Name = "File1",
    FullName = "File1.lua",
    IsRunable = true,
    Data = [[
local Test = {}
Test.__index = Test
function Test.Test()
    return "Test"
end
return Test
]] }

PackageData.RONgYwHx = {
    Namespace = "Test.File2",
    Name = "File2",
    FullName = "File2.lua",
    IsRunable = true,
    Data = [[

]] }

PackageData.seyrvpeX = {
    Namespace = "Test.Main",
    Name = "Main",
    FullName = "Main.lua",
    IsRunable = true,
    Data = [[
local Test = {}
function Test:Configure(logger)
    self.logger = logger
end
return Test
]] }

-- ########## Test ########## --

return PackageData
