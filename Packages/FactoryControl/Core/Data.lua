---@meta
local PackageData = {}

PackageData["FactoryControlCoreConfig"] = {
    Location = "FactoryControl.Core.Config",
    Namespace = "FactoryControl.Core.Config",
    IsRunnable = true,
    Data = [[
return {
	DOMAIN = 'FactoryControl'
}
]]
}

PackageData["FactoryControlCoreEntitiesControllerControllerDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.ControllerDto",
    Namespace = "FactoryControl.Core.Entities.Controller.ControllerDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.ControllerDto : object
---@field Id Core.UUID
---@field IPAddress Net.Core.IPAddress
local ControllerDto = {}



return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.ControllerDto")
]]
}

return PackageData
