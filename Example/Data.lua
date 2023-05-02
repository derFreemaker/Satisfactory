local PackageData = {}

-- ########## Example ##########

-- ########## Example.Entities ##########

PackageData.oVIzFPpX = {
    Namespace = "Example.Entities.Controller",
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

-- ########## Example.Entities ########## --

PackageData.PksKdJNx = {
    Namespace = "Example.Config",
    Name = "Config",
    FullName = "Config.json",
    IsRunable = false,
    Data = [[

]] }


PackageData.qzdVACkX = {
    Namespace = "Example.File1",
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
    Namespace = "Example.File2",
    Name = "File2",
    FullName = "File2.lua",
    IsRunable = true,
    Data = [[

]] }

-- ########## Example ########## --

return PackageData
