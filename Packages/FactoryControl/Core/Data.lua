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

return PackageData
