local NetworkClient = require("Net.Core.NetworkClient")

local FacotryControlClient = require("FactoryControl.Client.Client")

---@class Test.FacotryControl.Helper : object
local Helper = {}

---@param logger Core.Logger
---@return FactoryControl.Client
function Helper.CreateFactoryControlClient(logger)
    return FacotryControlClient(logger:subLogger("Client"), nil, NetworkClient(logger:subLogger("NetworkClient")))
end

---@param logger Core.Logger
---@param name string
---@return FactoryControl.Client.Entities.Controller
function Helper.CreateController(logger, name)
    local client = Helper.CreateFactoryControlClient(logger)
    return client:Connect(name)
end

return Helper
