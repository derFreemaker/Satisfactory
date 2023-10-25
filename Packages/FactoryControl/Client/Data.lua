---@meta
local PackageData = {}

PackageData["FactoryControlClient__events"] = {
    Location = "FactoryControl.Client.__events",
    Namespace = "FactoryControl.Client.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- Button
        require("FactoryControl.Client.Entities.Controller.Feature.Button.Pressed"):Static__GetType(),

        -- Switch
        require("FactoryControl.Client.Entities.Controller.Feature.Switch.Update"):Static__GetType(),

        -- Radial
        require("FactoryControl.Client.Entities.Controller.Feature.Radial.Update"):Static__GetType(),

        -- Chart
        require("FactoryControl.Client.Entities.Controller.Feature.Chart.Update"):Static__GetType(),
    })
end

return Events
]]
}

PackageData["FactoryControlClientClient"] = {
    Location = "FactoryControl.Client.Client",
    Namespace = "FactoryControl.Client.Client",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage.Usage")

local DataClient = require("FactoryControl.Client.DataClient")
local NetworkClient = require("Net.Core.NetworkClient")

local Controller = require("FactoryControl.Client.Entities.Controller.Controller")
local CreateController = require("FactoryControl.Core.Entities.Controller.CreateDto")

---@class FactoryControl.Client : object
---@field CurrentController FactoryControl.Client.Entities.Controller
---@field private _Client FactoryControl.Client.DataClient
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, client: FactoryControl.Client.DataClient?, networkClient: Net.Core.NetworkClient?) : FactoryControl.Client
local Client = {}

---@private
---@param logger Core.Logger
---@param client FactoryControl.Client.DataClient?
---@param networkClient Net.Core.NetworkClient?
function Client:__init(logger, client, networkClient)
    self._Logger = logger
    self._Client = client or DataClient(logger:subLogger("DataClient"))
    self._NetClient = networkClient or NetworkClient(logger:subLogger("NetClient"))
end

---@param name string
---@param features FactoryControl.Core.Entities.Controller.FeatureDto?
---@return FactoryControl.Client.Entities.Controller
function Client:Connect(name, features)
    local controllerDto = self._Client:Connect(name, self._NetClient:GetIPAddress())

    local created = false
    if not controllerDto then
        controllerDto = self._Client:CreateController(CreateController(name, self._NetClient:GetIPAddress(), features))

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
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return boolean success, FactoryControl.Client.Entities.Controller?
function Client:ModfiyControllerById(id, modifyController)
    local controllerDto = self._Client:ModifyControllerById(id, modifyController)

    if not controllerDto then
        return false
    end

    return true, Controller(controllerDto, self)
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

---@param name string
---@return FactoryControl.Client.Entities.Controller?
function Client:GetControllerByName(name)
    local controllerDto = self._Client:GetControllerByName(name)
    if not controllerDto then
        return
    end

    return Controller(controllerDto, self)
end

---@param ipAddress Net.Core.IPAddress
---@param buttonPressed FactoryControl.Client.Entities.Controller.Feature.Button.Pressed
function Client:ButtonPressed(ipAddress, buttonPressed)
    self._NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        buttonPressed
    )
end

---@param ipAddress Net.Core.IPAddress
---@param switchUpdate FactoryControl.Client.Entities.Controller.Feature.Switch.Update
function Client:UpdateSwitch(ipAddress, switchUpdate)
    self._NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        switchUpdate
    )
end

---@param ipAddress Net.Core.IPAddress
---@param radialUpdate FactoryControl.Client.Entities.Controller.Feature.Radial.Update
function Client:UpdateRadial(ipAddress, radialUpdate)
    self._NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        radialUpdate
    )
end

---@param ipAddress Net.Core.IPAddress
---@param chartUpdate FactoryControl.Client.Entities.Controller.Feature.Radial.Update
function Client:UpdateChart(ipAddress, chartUpdate)
    self._NetClient:Send(
        ipAddress,
        Usage.Ports.FactoryControl,
        Usage.Events.FactoryControl,
        chartUpdate
    )
end

return Utils.Class.CreateClass(Client, "FactoryControl.Client.Client")
]]
}

PackageData["FactoryControlClientDataClient"] = {
    Location = "FactoryControl.Client.DataClient",
    Namespace = "FactoryControl.Client.DataClient",
    IsRunnable = true,
    Data = [[
local Uri = require("Net.Rest.Uri")

local FactoryControlConfig = require("FactoryControl.Core.Config")
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')

---@class FactoryControl.Client.DataClient : object
---@field private _Client Net.Http.Client
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger) : FactoryControl.Client.DataClient
local DataClient = {}

---@private
---@param logger Core.Logger
function DataClient:__init(logger)
	self._Logger = logger
	self._Client = HttpClient(self._Logger:subLogger('RestApiClient'))
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Net.Http.Request.Options?
---@return Net.Http.Response response
function DataClient:request(method, endpoint, body, options)
	local request = HttpRequest(method, FactoryControlConfig.DOMAIN, Uri.Static__Parse(endpoint), body, options)
	return self._Client:Send(request)
end

---@param name string
---@param ipAddress Net.Core.IPAddress
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:Connect(name, ipAddress)
	local response = self:request("CONNECT", "Controller", { name, ipAddress })

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:CreateController(createController)
	local response = self:request('CREATE', 'Controller', createController)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return boolean success
function DataClient:DeleteControllerById(id)
	local response = self:request("DELETE", "ControllerById", id)

	return response:IsSuccess() and response:GetBody()
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:ModifyControllerById(id, modifyController)
	local response = self:request("POST", "ModifyControllerById", { id, modifyController })

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerById(id)
	local response = self:request("GET", "ControllerById", id)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param name string
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerByName(name)
	local response = self:request("GET", "ControllerByName", name)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

return Utils.Class.CreateClass(DataClient, "FactoryControl.Client.DataClient")
]]
}

PackageData["FactoryControlClientEventNames"] = {
    Location = "FactoryControl.Client.EventNames",
    Namespace = "FactoryControl.Client.EventNames",
    IsRunnable = true,
    Data = [[
---@enum FactoryControl.Client.EventNames
local EventNames = {
    ButtonPressed = "FactoryControl__Feature__ButtonPressed"
}

return EventNames
]]
}

PackageData["FactoryControlClientEntitiesEntitiy"] = {
    Location = "FactoryControl.Client.Entities.Entitiy",
    Namespace = "FactoryControl.Client.Entities.Entitiy",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Entity : object
---@field Id Core.UUID
---@field protected _Client FactoryControl.Client
local Entity = {}

---@private
---@param id Core.UUID
---@param client FactoryControl.Client
function Entity:__init(id, client)
    self.Id = id
    self._Client = client
end

return Utils.Class.CreateClass(Entity, "FactoryControl.Client.Entities.Entity")
]]
}

PackageData["FactoryControlClientEntitiesControllerController"] = {
    Location = "FactoryControl.Client.Entities.Controller.Controller",
    Namespace = "FactoryControl.Client.Entities.Controller.Controller",
    IsRunnable = true,
    Data = [[
local ButtonFeature = require("FactoryControl.Client.Entities.Controller.Feature.Button.Button")
local SwitchFeature = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Switch")
local RadialFeature = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Radial")
local ChartFeature = require("FactoryControl.Client.Entities.Controller.Feature.Chart.Chart")

---@class FactoryControl.Client.Entities.Controller : FactoryControl.Client.Entities.Entity
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field protected Features Dictionary<string, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(controllerDto: FactoryControl.Core.Entities.ControllerDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller
local Controller = {}

---@private
---@param controllerDto FactoryControl.Core.Entities.ControllerDto
---@param client FactoryControl.Client
---@param baseFunc fun(id: Core.UUID, client: FactoryControl.Client)
function Controller:__init(baseFunc, controllerDto, client)
    baseFunc(controllerDto.Id, client)

    self.Name = controllerDto.Name
    self.IPAddress = controllerDto.IPAddress

    ---@type Dictionary<string, FactoryControl.Client.Entities.Controller.Feature>
    local features = {}

    for id, feature in pairs(controllerDto.Features) do
        if feature.Type == "Button" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ButtonDto
            features[id] = ButtonFeature(feature, self)
        elseif feature.Type == "Switch" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.SwitchDto
            features[id] = SwitchFeature(feature, self)
        elseif feature.Type == "Radial" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.RadialDto
            features[id] = RadialFeature(feature, self)
        elseif feature.Type == "Chart" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ChartDto
            features[id] = ChartFeature(feature, self)
        end
    end

    self.Features = features
end

---@return Dictionary<string, FactoryControl.Client.Entities.Controller.Feature>
function Controller:GetFeatures()
    return self.Features
end

return Utils.Class.CreateClass(Controller, "FactoryControl.Client.Entities.Controller",
    require("FactoryControl.Client.Entities.Entitiy"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureFeature"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Feature",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Feature",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.

---@class FactoryControl.Client.Entities.Controller.Feature : FactoryControl.Client.Entities.Entity
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field Owner FactoryControl.Client.Entities.Controller
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@private
---@param id Core.UUID
---@param name string
---@param featureType FactoryControl.Core.Entities.Controller.Feature.Type
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, client: FactoryControl.Client)
function Feature:__init(baseFunc, id, name, featureType, controller)
    baseFunc(id, controller._Client)

    self.Name  = name
    self.Type  = featureType
    self.Owner = controller
end

return Utils.Class.CreateClass(Feature, "FactoryControl.Client.Entities.Controller.Feature",
    require("FactoryControl.Client.Entities.Entitiy"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureButtonButton"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
    IsRunnable = true,
    Data = [[
local Pressed = require("FactoryControl.Client.Entities.Controller.Feature.Button.Pressed")

---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Button:__init(baseFunc, buttonDto, controller)
    baseFunc(buttonDto.Id, buttonDto.Name, "Button", controller)
end

function Button:Press()
    local pressed = Pressed(self.Id)

    self._Client:ButtonPressed(self.Owner.IPAddress, pressed)
end

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --{{{@as FactoryControl.Client.Entities.Controller.Feature}}})
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureButtonPressed"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Button.Pressed",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Button.Pressed",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.Button.Pressed : Core.Json.Serializable
---@field Id Core.UUID
---@overload fun(id: Core.UUID) : FactoryControl.Client.Entities.Controller.Feature.Button.Pressed
local Pressed = {}

---@private
---@param id Core.UUID
function Pressed:__init(id)
    self.Id = id
end

---@return Core.UUID id
function Pressed:Serialize()
    return self.Id
end

return Utils.Class.CreateClass(Pressed, "FactoryControl.Client.Entities.Controller.Feature.Button.Pressed",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureChartChart"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private _XAxisName string
---@field private _YAxisName string
---@field private _Data Dictionary<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Button = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Button:__init(baseFunc, chartDto, controller)
    baseFunc(chartDto.Id, chartDto.Name, "Button", controller)

    self._XAxisName = chartDto.XAxisName
    self._YAxisName = chartDto.YAxisName
    self._Data = chartDto.Data
end

-- //TODO: complete

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --{{{@as FactoryControl.Client.Entities.Controller.Feature}}})
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureChartUpdate"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Chart.Update",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Chart.Update",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Update : Core.Json.Serializable
---@field Id Core.UUID
---@field Data Dictionary<number, any>
---@overload fun(id: Core.UUID, data: Dictionary<number, any>) : FactoryControl.Client.Entities.Controller.Feature.Chart.Update
local Update = {}

---@private
---@param id Core.UUID
---@param data Dictionary<number, any>
function Update:__init(id, data)
    self.Id = id
    self.Data = data
end

---@return Core.UUID id, Dictionary<number, any> data
function Update:Serialize()
    return self.Id, self.Data
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Chart.Update",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureRadialRadial"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
    IsRunnable = true,
    Data = [[
local Update = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field Min number
---@field Max number
---@field Setting number
---@field private _Old_Min number
---@field private _Old_Max number
---@field private _Old_Setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Radial:__init(baseFunc, radialDto, controller)
    baseFunc(radialDto.Id, radialDto.Name, "Radial", controller)

    self.Min = radialDto.Min
    self._Old_Min = radialDto.Min

    self.Max = radialDto.Max
    self._Old_Max = radialDto.Max

    self.Setting = radialDto.Setting
    self._Old_Setting = radialDto.Setting
end

function Radial:Update()
    if self.Min < self.Max then
        error("max cannot be smaller then min")
    end

    if self.Min > self.Setting or self.Setting > self.Max then
        error("setting is out of bounds of " .. self.Min .. " - " .. self.Max)
    end

    if self._Old_Min == self.Min and self._Old_Max == self.Max and self._Old_Setting == self.Setting then
        return
    end

    local update = Update(self.Id, self.Min, self.Max, self.Setting)

    self._Client:UpdateRadial(self.Owner.IPAddress, update)
end

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --{{{@as FactoryControl.Client.Entities.Controller.Feature}}})
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureRadialUpdate"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Radial.Update",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Radial.Update",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Update : Core.Json.Serializable
---@field Id Core.UUID
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, min: number, max: number, setting: number) : FactoryControl.Client.Entities.Controller.Feature.Radial.Update
local Update = {}

---@private
---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
function Update:__init(id, min, max, setting)
    self.Id = id
    self.Min = min
    self.Max = max
    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function Update:Serialize()
    return self.Id, self.Min, self.Max, self.Setting
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Radial.Update",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureSwitchSwitch"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
    IsRunnable = true,
    Data = [[
local Update = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Switch : FactoryControl.Client.Entities.Controller.Feature
---@field private _IsEnabled boolean
---@field private _Old_IsEnabled boolean
---@overload fun(switchDto: FactoryControl.Core.Entities.Controller.Feature.SwitchDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Switch
local Switch = {}

---@private
---@param switchDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Switch:__init(baseFunc, switchDto, controller)
    baseFunc(switchDto.Id, switchDto.Name, "Button", controller)

    self._IsEnabled = switchDto.IsEnabled
    self._Old_IsEnabled = switchDto.IsEnabled
end

---@private
function Switch:Update()
    if self._IsEnabled == self._Old_IsEnabled then
        return
    end

    local update = Update(self.Id, self._IsEnabled)

    self._Client:UpdateSwitch(self.Owner.IPAddress, update)
end

---@return boolean isEnabled
function Switch:IsEnabled()
    return self._IsEnabled
end

function Switch:Enable()
    self._IsEnabled = true

    self:Update()
end

function Switch:Disable()
    self._IsEnabled = false

    self:Update()
end

function Switch:Toggle()
    self._IsEnabled = not self._IsEnabled

    self:Update()
end

return Utils.Class.CreateClass(Switch, "FactoryControl.Client.Entities.Controller.Feature.Switch",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --{{{@as FactoryControl.Client.Entities.Controller.Feature}}})
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureSwitchUpdate"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Switch.Update",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Switch.Update",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Controller.Feature.Switch.Update : Core.Json.Serializable
---@field Id Core.UUID
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Client.Entities.Controller.Feature.Switch.Update
local Update = {}

---@private
function Update:__init(id, IsEnabled)
    self.Id = id
    self.IsEnabled = IsEnabled
end

---@return Core.UUID id, boolean isEnabled
function Update:Serialize()
    return self.Id, self.IsEnabled
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Switch.Update",
    require("Core.Json.Serializable"))
]]
}

return PackageData
