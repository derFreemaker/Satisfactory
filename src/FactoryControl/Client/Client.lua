local Usage = require("Core.Usage.Usage")

local DataClient = require("FactoryControl.Client.DataClient")
local NetworkClient = require("Net.Core.NetworkClient")

local Controller = require("FactoryControl.Client.Entities.Controller.Controller")
local CreateController = require("FactoryControl.Core.Entities.Controller.CreateDto")
local ConnectController = require("FactoryControl.Core.Entities.Controller.ConnectDto")

---@class FactoryControl.Client : object
---@field CurrentController FactoryControl.Client.Entities.Controller
---@field NetClient Net.Core.NetworkClient
---@field private m_client FactoryControl.Client.DataClient
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, client: FactoryControl.Client.DataClient?, networkClient: Net.Core.NetworkClient?) : FactoryControl.Client
local Client = {}

---@private
---@param logger Core.Logger
---@param client FactoryControl.Client.DataClient?
---@param networkClient Net.Core.NetworkClient?
function Client:__init(logger, client, networkClient)
    self.m_logger = logger
    self.m_client = client or DataClient(logger:subLogger("DataClient"))
    self.NetClient = networkClient or NetworkClient(logger:subLogger("NetClient"))
end

---@param name string
---@param features FactoryControl.Core.Entities.Controller.FeatureDto?
---@return FactoryControl.Client.Entities.Controller
function Client:Connect(name, features)
    local controllerDto = self.m_client:Connect(ConnectController(name, self.NetClient:GetIPAddress()))

    local created = false
    if not controllerDto then
        controllerDto = self.m_client:CreateController(CreateController(name, self.NetClient:GetIPAddress(), features))

        if not controllerDto then
            error("Unable to connect to server")
        end

        created = true
    end

    local controller = Controller(controllerDto, self)
    self.CurrentController = controller

    if not created then
        self:ModfiyControllerById(controller.Id, controller:GetFeatures())
    end

    return controller
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Client.Entities.Controller? controller
function Client:CreateController(createController)
    local controllerDto = self.m_client:CreateController(createController)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param id Core.UUID
---@return boolean success
function Client:DeleteControllerById(id)
    return self.m_client:DeleteControllerById(id)
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return boolean success, FactoryControl.Client.Entities.Controller?
function Client:ModfiyControllerById(id, modifyController)
    local controllerDto = self.m_client:ModifyControllerById(id, modifyController)

    if not controllerDto then
        return false
    end

    return true, Controller(controllerDto, self)
end

---@param id Core.UUID
---@return FactoryControl.Client.Entities.Controller? controller
function Client:GetControllerById(id)
    local controllerDto = self.m_client:GetControllerById(id)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param name string
---@return FactoryControl.Client.Entities.Controller?
function Client:GetControllerByName(name)
    local controllerDto = self.m_client:GetControllerByName(name)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param ipAddress Net.Core.IPAddress
---@param buttonPressed FactoryControl.Client.Entities.Controller.Feature.Button.Pressed
function Client:ButtonPressed(ipAddress, buttonPressed)
    self.NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        buttonPressed
    )
end

---@param ipAddress Net.Core.IPAddress
---@param switchUpdate FactoryControl.Client.Entities.Controller.Feature.Switch.Update
function Client:UpdateSwitch(ipAddress, switchUpdate)
    self.NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        switchUpdate
    )
end

---@param ipAddress Net.Core.IPAddress
---@param radialUpdate FactoryControl.Client.Entities.Controller.Feature.Radial.Update
function Client:UpdateRadial(ipAddress, radialUpdate)
    self.NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        radialUpdate
    )
end

---@param ipAddress Net.Core.IPAddress
---@param chartUpdate FactoryControl.Client.Entities.Controller.Feature.Radial.Update
function Client:UpdateChart(ipAddress, chartUpdate)
    self.NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        chartUpdate
    )
end

return Utils.Class.CreateClass(Client, "FactoryControl.Client.Client")
