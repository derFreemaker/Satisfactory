local PackageData = {}

-- ########## Hosting ##########

PackageData.MFYoiWSx = {
    Namespace = "Hosting.Host",
    Name = "Host",
    FullName = "Host.lua",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Host = {}
function Host:__init(logger)
    EventPullAdapter:Initialize(logger:subLogger("EventPullAdapter"))
end
return Utils.Class.CreateClass(Host, "Hosting.Host")
]]
}

-- ########## Hosting ########## --

return PackageData
