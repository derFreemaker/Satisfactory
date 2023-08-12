local PackageData = {}

-- ########## Core ##########

PackageData.MFYoiWSx = {
    Namespace = "Core.Test",
    Name = "Test",
    FullName = "Test.lua",
    IsRunnable = true,
    Data = function(...)
local function Test()
    return "Test"
end
return Test
end
}

-- ########## Core ########## --

return PackageData
