---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

---@return FactoryControl.Core.Entities.Controller.Feature.Update
function NetworkContextExtensions:GetFeatureUpdate()
    return self.Body
end

Utils.Class.Extend(require("Net.NetworkContext"), NetworkContextExtensions)
