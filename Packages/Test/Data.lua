local PackageData = {}

-- ########## Test ##########

PackageData.MFYoiWSx = {
    Namespace = "Test.Main",
    Name = "Main",
    FullName = "Main.lua",
    IsRunnable = true,
    Data = function(...)
local Test = {}
function Test:Configure()
    self.Logger:LogDebug("called configure function")
end
function Test:Run()
    self.Logger:LogInfo("called run function")
    return 0
end
return Test
end
}

-- ########## Test ########## --

return PackageData
