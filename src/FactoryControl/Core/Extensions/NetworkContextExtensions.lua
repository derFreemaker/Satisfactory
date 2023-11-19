---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

---@return FactoryControl.Core.Entities.Controller.Feature.Update
function NetworkContextExtensions:GetFeatureUpdate()
    return self.Body
end

Utils.Class.ExtendClass(NetworkContextExtensions,
    require("Net.Core.NetworkContext"))
