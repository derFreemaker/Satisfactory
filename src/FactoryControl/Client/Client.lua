local PortUsage = require("Core.Usage_Port")
local EventNameUsage = require("Core.Usage_EventName")

local Controller = require("FactoryControl.Client.Entities.Controller.Controller")

local ButtonPressed = require("FactoryControl.Client.Entities.Controller.Feature.Button.Pressed")

---@class FactoryControl.Client.Client : object
---@field private _Client FactoryControl.Client.DataClient
---@field private _NetClient Net.Core.NetworkClient
---@overload fun(client: FactoryControl.Client.DataClient, networkClient: Net.Core.NetworkClient) : FactoryControl.Client.Client
local Client

---@private
---@param client FactoryControl.Client.DataClient
---@param networkClient Net.Core.NetworkClient
function Client:__init(client, networkClient)
    self._Client = client
    self._NetClient = networkClient
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Client.Entities.Controller? controller
function Client:CreateController(createController)
    local controllerDto = self._Client:CreateController(createController)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param id Core.UUID
---@return boolean success
function Client:DeleteControllerById(id)
    return self._Client:DeleteControllerById(id)
end

---@param id Core.UUID
---@return FactoryControl.Client.Entities.Controller? controller
function Client:GetControllerById(id)
    local controllerDto = self._Client:GetControllerById(id)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param button FactoryControl.Client.Entities.Controller.Feature.Button
function Client:PressButton(button)
    self._NetClient:Send(
        button.Owner.IPAddress,
        PortUsage.FactoryControl,
        EventNameUsage.FactoryControl,
        ButtonPressed(button.Id)
    )
end

return Utils.Class.CreateClass(Client, "FactoryControl.Client.Client")
