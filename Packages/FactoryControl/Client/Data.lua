---@meta
local PackageData = {}

PackageData["FactoryControlClientClient"] = {
    Location = "FactoryControl.Client.Client",
    Namespace = "FactoryControl.Client.Client",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage")
local Config = require("FactoryControl.Core.Config")

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

local DataClient = require("FactoryControl.Client.DataClient")

local Controller = require("FactoryControl.Client.Entities.Controller.Controller")
local CreateController = require("FactoryControl.Core.Entities.Controller.CreateDto")
local ConnectController = require("FactoryControl.Core.Entities.Controller.ConnectDto")

local FeatureFactory = require("FactoryControl.Client.Entities.Controller.Feature.Factory")

local Callback = require("Services.Callback.Client.Callback")
local CallbackService = require("Services.Callback.Client.CallbackService")

---@class FactoryControl.Client : object
---@field CurrentController FactoryControl.Client.Entities.Controller
---@field NetClient Net.Core.NetworkClient
---@field private m_callbackService Services.Callback.Client.CallbackService
---@field private m_client FactoryControl.Client.DataClient
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, client: FactoryControl.Client.DataClient?, networkClient: Net.Core.NetworkClient?) : FactoryControl.Client
local Client = {}

---@private
---@param logger Core.Logger
---@param client FactoryControl.Client.DataClient?
---@param networkClient Net.Core.NetworkClient?
function Client:__init(logger, client, networkClient)
    self.NetClient = networkClient or NetworkClient(logger:subLogger("NetClient"))

    self.m_callbackService = CallbackService(
        Config.CallbackServiceNameForFeatures,
        logger:subLogger("CallbackService"),
        self.NetClient
    )
    self.m_client = client or DataClient(logger:subLogger("DataClient"), self.NetClient)
    self.m_logger = logger
end

------------------------------------------------------------------------------
-- Controller
------------------------------------------------------------------------------

---@param name string
---@param features FactoryControl.Client.Entities.Controller.Feature[]?
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
        controller:Modify(function(modify)
            if not features then
                return
            end

            for _, feature in pairs(features) do
                modify.Features[feature.Name] = feature
            end
        end)
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

------------------------------------------------------------------------------
-- Feature
------------------------------------------------------------------------------

---@param feature FactoryControl.Client.Entities.Controller.Feature
function Client:WatchFeature(feature)
    local callback = Callback(
        feature.Id,
        Usage.Events.FactoryControl_Feature_Update,
        Task(self.OnFeatureUpdate, self, feature)
    )
    self.m_callbackService:AddCallback(callback)

    for _, value in pairs(self.CurrentController:GetFeatureIds()) do
        if value:Equals(value) then
            return
        end
    end

    self.m_client:WatchFeature(feature.Id)
end

---@param featureId Core.UUID
function Client:UnwatchFeature(featureId)
    self.m_callbackService:RemoveCallback(featureId, Usage.Events.FactoryControl_Feature_Update)

    for _, value in pairs(self.CurrentController:GetFeatureIds()) do
        if value:Equals(featureId) then
            return
        end
    end

    self.m_client:UnwatchFeature(featureId)
end

---@private
---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function Client:OnFeatureUpdate(feature, featureUpdate)
    local logger = self.m_logger:subLogger("Feature[" .. feature.Id:ToString() .. "]")
    feature:OnUpdate(featureUpdate)
    feature.OnChanged:Trigger(logger, featureUpdate)
end

---@param feature FactoryControl.Client.Entities.Controller.Feature
---@return FactoryControl.Client.Entities.Controller.Feature?
function Client:CreateFeature(feature)
    local featureDto = self.m_client:CreateFeature(feature:ToDto())
    if not featureDto then
        return
    end

    return FeatureFactory.Create(featureDto, self)
end

---@param featureId Core.UUID
---@return boolean
function Client:DeleteFeatureById(featureId)
    return self.m_client:DeleteFeatureById(featureId)
end

---@param featureIds Core.UUID[]
---@return FactoryControl.Client.Entities.Controller.Feature?
function Client:GetFeatureByIds(featureIds)
    local featureDtos = self.m_client:GetFeatureByIds(featureIds)

    ---@type FactoryControl.Client.Entities.Controller.Feature[]
    local features = {}

    for _, featureDto in pairs(featureDtos) do
        local feature = FeatureFactory.Create(featureDto, self)
        table.insert(features, feature)
    end

    return features
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function Client:UpdateFeature(featureUpdate)
    self.m_client:UpdateFeature(featureUpdate)
end

return Utils.Class.CreateClass(Client, "FactoryControl.Client.Client")
]]
}

PackageData["FactoryControlClientDataClient"] = {
    Location = "FactoryControl.Client.DataClient",
    Namespace = "FactoryControl.Client.DataClient",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage")
local EndpointUrlConstructors = require("FactoryControl.Core.EndpointUrls")[2]
local ControllerUrlConstructors = EndpointUrlConstructors.Controller
local FeatureUrlConstructors = EndpointUrlConstructors.Feature

local Uri = require("Net.Rest.Uri")

local FactoryControlConfig = require("FactoryControl.Core.Config")
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')

---@class FactoryControl.Client.DataClient : object
---@field private m_client Net.Http.Client
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, networkClient: Net.Core.NetworkClient?) : FactoryControl.Client.DataClient
local DataClient = {}

---@param networkClient Net.Core.NetworkClient
function DataClient.Static__WaitForHeartbeat(networkClient)
	networkClient:WaitForEvent(Usage.Events.FactoryControl_Heartbeat, Usage.Ports.FactoryControl_Heartbeat)
end

---@private
---@param logger Core.Logger
---@param networkClient Net.Core.NetworkClient?
function DataClient:__init(logger, networkClient)
	self.m_logger = logger
	self.m_client = HttpClient(self.m_logger:subLogger('RestApiClient'), nil, networkClient)

	self.m_logger:LogDebug("waiting for server heartbeat...")
	self.Static__WaitForHeartbeat(self.m_client:GetNetworkClient())
end

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Net.Http.Request.Options?
---@return Net.Http.Response response
function DataClient:request(method, endpoint, body, options)
	local request = HttpRequest(method, FactoryControlConfig.DOMAIN, Uri.Static__Parse(endpoint), body, options)
	return self.m_client:Send(request)
end

-------------------------------------------------------------------------
-- Controller
-------------------------------------------------------------------------

---@param connect FactoryControl.Core.Entities.Controller.ConnectDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:Connect(connect)
	local response = self:request("CONNECT", ControllerUrlConstructors.Connect(), connect)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param createController FactoryControl.Core.Entities.Controller.CreateDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:CreateController(createController)
	local response = self:request('CREATE', ControllerUrlConstructors.Create(), createController)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return boolean success
function DataClient:DeleteControllerById(id)
	local response = self:request("DELETE", ControllerUrlConstructors.Delete(id))

	return response:IsSuccess() and response:GetBody()
end

---@param id Core.UUID
---@param modifyController FactoryControl.Core.Entities.Controller.ModifyDto
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:ModifyControllerById(id, modifyController)
	local response = self:request("POST", ControllerUrlConstructors.Modify(id), modifyController)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerById(id)
	local response = self:request("GET", ControllerUrlConstructors.GetById(id))

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param name string
---@return FactoryControl.Core.Entities.ControllerDto?
function DataClient:GetControllerByName(name)
	local response = self:request("GET", ControllerUrlConstructors.GetByName(name))

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

-------------------------------------------------------------------------
-- Feature
-------------------------------------------------------------------------

---@param featureId Core.UUID
---@return boolean
function DataClient:WatchFeature(featureId)
	local response = self:request(
		"POST",
		FeatureUrlConstructors.Watch(featureId),
		self.m_client:GetNetworkClient():GetIPAddress()
	)

	if response:IsFaulted() then
		return false
	end

	return response:GetBody()
end

---@param featureId Core.UUID
---@return boolean
function DataClient:UnwatchFeature(featureId)
	local response = self:request(
		"POST",
		FeatureUrlConstructors.Unwatch(featureId),
		self.m_client:GetNetworkClient():GetIPAddress()
	)

	if response:IsFaulted() then
		return false
	end

	return response:GetBody()
end

---@param feature FactoryControl.Core.Entities.Controller.FeatureDto
---@return FactoryControl.Core.Entities.Controller.FeatureDto?
function DataClient:CreateFeature(feature)
	local response = self:request("CREATE", FeatureUrlConstructors.Create(), feature)

	if response:IsFaulted() then
		return
	end

	return response:GetBody()
end

---@param featureId Core.UUID
---@return boolean
function DataClient:DeleteFeatureById(featureId)
	local response = self:request("DELETE", FeatureUrlConstructors.Delete(featureId))

	if response:IsFaulted() then
		return false
	end

	return response:GetBody()
end

---@param featureIds Core.UUID[]
---@return FactoryControl.Core.Entities.Controller.FeatureDto[]
function DataClient:GetFeatureByIds(featureIds)
	local response = self:request("GET", FeatureUrlConstructors.GetByIds(), featureIds)

	if response:IsFaulted() then
		return {}
	end

	return response:GetBody()
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Update
function DataClient:UpdateFeature(featureUpdate)
	local ipAddress = self.m_client:GetAddress(FactoryControlConfig.DOMAIN)
	if not ipAddress then
		return
	end

	self.m_client:GetNetworkClient():Send(
		ipAddress,
		Usage.Ports.FactoryControl,
		Usage.Events.FactoryControl_Feature_Update,
		featureUpdate
	)
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

PackageData["FactoryControlClientEntitiesEntity"] = {
    Location = "FactoryControl.Client.Entities.Entity",
    Namespace = "FactoryControl.Client.Entities.Entity",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Client.Entities.Entity : object
---@field Id Core.UUID
---@field protected m_client FactoryControl.Client
---@overload fun(id: Core.UUID, client: FactoryControl.Client) : FactoryControl.Client.Entities.Entity
local Entity = {}

---@alias FactoryControl.Client.Entities.Entity.Constructor fun(id: Core.UUID, client: FactoryControl.Client)

---@private
---@param id Core.UUID
---@param client FactoryControl.Client
function Entity:__init(id, client)
    self.Id = id
    self.m_client = client
end

return Utils.Class.CreateClass(Entity, "FactoryControl.Client.Entities.Entity")
]]
}

PackageData["FactoryControlClientEntitiesControllerController"] = {
    Location = "FactoryControl.Client.Entities.Controller.Controller",
    Namespace = "FactoryControl.Client.Entities.Controller.Controller",
    IsRunnable = true,
    Data = [[
local UUID = require("Core.Common.UUID")

local Modify = require("FactoryControl.Client.Entities.Controller.Modify")

local ButtonDto = require("FactoryControl.Core.Entities.Controller.Feature.Button.ButtonDto")
local Button = require("FactoryControl.Client.Entities.Controller.Feature.Button.Button")

local SwitchDto = require("FactoryControl.Core.Entities.Controller.Feature.Switch.SwitchDto")
local Switch = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Switch")

local RadialDto = require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto")
local Radial = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Radial")

local ChartDto = require("FactoryControl.Core.Entities.Controller.Feature.Chart.ChartDto")
local Chart = require("FactoryControl.Client.Entities.Controller.Feature.Chart.Chart")

---@class FactoryControl.Client.Entities.Controller : FactoryControl.Client.Entities.Entity
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field private m_featuresIds Core.UUID[]
---@field private m_features table<string, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(controllerDto: FactoryControl.Core.Entities.ControllerDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller
local Controller = {}

---@private
---@param controllerDto FactoryControl.Core.Entities.ControllerDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Entity.Constructor
function Controller:__init(super, controllerDto, client)
    super(controllerDto.Id, client)

    self.Name = controllerDto.Name
    self.IPAddress = controllerDto.IPAddress
    self.m_featuresIds = controllerDto.Features
end

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Modify)
function Controller:Modify(func)
    local modify = Modify(self.Name, self.IPAddress, self.m_featuresIds)

    func(modify)

    self.m_client:ModfiyControllerById(self.Id, modify:ToDto())
end

---@return Core.UUID[]
function Controller:GetFeatureIds()
    return self.m_featuresIds
end

---@return FactoryControl.Client.Entities.Controller.Feature[]
function Controller:GetFeatures()
    if self.m_features then
        return self.m_features
    end

    local features = {}
    for _, feature in pairs(self.m_client:GetFeatureByIds(self.m_featuresIds) or {}) do
        features[feature.Id:ToString()] = feature
    end

    self.m_features = features
    return self.m_features
end

---@param name string
---@return FactoryControl.Client.Entities.Controller.Feature?
function Controller:GetFeatureByName(name)
    for _, feature in pairs(self:GetFeatures()) do
        if feature.Name == name then
            return feature
        end
    end
end

---@param name string
---@return FactoryControl.Client.Entities.Controller.Feature.Button?
function Controller:AddButton(name)
    local buttonDto = ButtonDto(UUID.Static__New(), name, self.Id)
    local button = self.m_client:CreateFeature(Button(buttonDto, self.m_client))
    ---@cast button FactoryControl.Client.Entities.Controller.Feature.Button?
    return button
end

---@param name string
---@param isEnabled boolean?
---@return FactoryControl.Client.Entities.Controller.Feature.Switch?
function Controller:AddSwitch(name, isEnabled)
    if isEnabled == nil then
        isEnabled = false
    end

    local switchDto = SwitchDto(UUID.Static__New(), name, self.Id, isEnabled)
    local switch = self.m_client:CreateFeature(Switch(switchDto, self.m_client))
    ---@cast switch FactoryControl.Client.Entities.Controller.Feature.Switch?
    return switch
end

---@param name string
---@param data FactoryControl.Client.Entities.Controller.Feature.Radial.Data?
function Controller:AddRadial(name, data)
    if data == nil then
        data = {}
    end
    local min = data.Min or 0
    local max = data.Max or 1
    local setting = data.Setting or 1

    if max < min then
        error("max (" .. max .. ") cannot be smaller then min (" .. min .. ")", 2)
    end

    if setting < min or setting > max then
        error("setting (" .. setting .. ") is out of bounds of " .. min .. " - " .. max, 2)
    end

    local radialDto = RadialDto(UUID.Static__New(), name, self.Id, min, max, setting)
    local radial = self.m_client:CreateFeature(Radial(radialDto, self.m_client))
    ---@cast radial FactoryControl.Client.Entities.Controller.Feature.Radial?
    return radial
end

---@param name string
---@param data FactoryControl.Client.Entities.Controller.Feature.Chart.Data?
function Controller:AddChart(name, data)
    data = data or {}
    local xAxisName = data.XAxisName or "X"
    local yAxisName = data.YAxisName or "Y"
    data = data.Data or {}

    local chartDto = ChartDto(UUID.Static__New(), name, self.Id, xAxisName, yAxisName, data)
    local chart = self.m_client:CreateFeature(Chart(chartDto, self.m_client))
    ---@cast chart FactoryControl.Client.Entities.Controller.Feature.Chart?
    return chart
end

return Utils.Class.CreateClass(Controller, "FactoryControl.Client.Entities.Controller",
    require("FactoryControl.Client.Entities.Entity"))

-- //TODO: implement some kind of status like online and offline
]]
}

PackageData["FactoryControlClientEntitiesControllerModify"] = {
    Location = "FactoryControl.Client.Entities.Controller.Modify",
    Namespace = "FactoryControl.Client.Entities.Controller.Modify",
    IsRunnable = true,
    Data = [[
local FeatureDto = require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto")

local ModfiyDto = require("FactoryControl.Core.Entities.Controller.ModifyDto")

---@class FactoryControl.Client.Entities.Controller.Modify : object
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(name: string, ipAddress: Net.Core.IPAddress, features: table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>) : FactoryControl.Client.Entities.Controller.Modify
local Modify = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features table<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
function Modify:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features
end

function Modify:ToDto()
    ---@type table<Core.UUID, FactoryControl.Core.Entities.Controller.FeatureDto>
    local featureDtos = {}
    for key, feature in pairs(self.Features) do
        featureDtos[key] = feature:ToDto()
    end

    return ModfiyDto(self.Name, self.IPAddress, featureDtos)
end

return Utils.Class.CreateClass(Modify, "FactoryControl.Client.Entities.Controller.Modify")
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureFactory"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Factory",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Factory",
    IsRunnable = true,
    Data = [[
local ButtonFeature = require("FactoryControl.Client.Entities.Controller.Feature.Button.Button")
local ChartFeature = require("FactoryControl.Client.Entities.Controller.Feature.Chart.Chart")
local RadialFeature = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Radial")
local SwitchFeature = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Switch")

---@class FactoyControl.Client.Entities.Controller.Feature.Factory
local Factory = {}

---@param featureDto FactoryControl.Core.Entities.Controller.FeatureDto
---@param client FactoryControl.Client
---@return FactoryControl.Client.Entities.Controller.Feature
function Factory.Create(featureDto, client)
    if featureDto.Type == "Button" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
        return ButtonFeature(featureDto, client)
    elseif featureDto.Type == "Chart" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
        return ChartFeature(featureDto, client)
    elseif featureDto.Type == "Radial" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
        return RadialFeature(featureDto, client)
    elseif featureDto.Type == "Switch" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
        return SwitchFeature(featureDto, client)
    else
        error("unsupported feature type")
    end
end

return Factory
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureFeature"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Feature",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Feature",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Common.Task")
local LazyEventHandler = require("Core.Common.LazyEventHandler")

---@class FactoryControl.Client.Entities.Controller.Feature : FactoryControl.Client.Entities.Entity
---@field Name string
---@field ControllerId Core.UUID
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field OnChanged Core.LazyEventHandler
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@alias FactoryControl.Client.Entities.Controller.Feature.Constructor fun(dto: FactoryControl.Core.Entities.Controller.FeatureDto, client: FactoryControl.Client)

---@private
---@param dto FactoryControl.Core.Entities.Controller.FeatureDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Entity.Constructor
function Feature:__init(super, dto, client)
    super(dto.Id, client)

    self.Name = dto.Name
    self.ControllerId = dto.ControllerId
    self.Type = dto.Type

    ---@param lazyEventHandler Core.LazyEventHandler
    local function onSetup(lazyEventHandler)
        self.m_client:WatchFeature(self)
    end

    ---@param lazyEventHandler Core.LazyEventHandler
    local function onClose(lazyEventHandler)
        self.m_client:UnwatchFeature(self.Id)
    end

    self.OnChanged = LazyEventHandler(onSetup, onClose)
end

---@param update FactoryControl.Core.Entities.Controller.Feature.Update
function Feature:OnUpdate(update)
    error("OnUpdate not implemented")
end

---@return FactoryControl.Core.Entities.Controller.FeatureDto
function Feature:ToDto()
    error("ToDto not implemented")
end

return Utils.Class.CreateClass(Feature, "FactoryControl.Client.Entities.Controller.Feature",
    require("FactoryControl.Client.Entities.Entity"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureButtonButton"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
    IsRunnable = true,
    Data = [[
local ButtonDto = require("FactoryControl.Core.Entities.Controller.Feature.Button.ButtonDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Button.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Button : FactoryControl.Client.Entities.Controller.Feature
---@overload fun(buttonDto: FactoryControl.Core.Entities.Controller.Feature.ButtonDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Button
local Button = {}

---@private
---@param buttonDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Button:__init(super, buttonDto, client)
    super(buttonDto, client)
end

---@private
function Button:OnUpdate()
end

---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function Button:ToDto()
    return ButtonDto(self.Id, self.Name, self.ControllerId)
end

function Button:Press()
    local update = Update(self.Id)
    self.m_client:UpdateFeature(update)
end

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureChartChart"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
    IsRunnable = true,
    Data = [[
local ChartDto = require("FactoryControl.Core.Entities.Controller.Feature.Chart.ChartDto")
local Update = require("FactoryControl.Core.Entities.Controller.Feature.Chart.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Data
---@field XAxisName string?
---@field YAxisName string?
---@field Data table<number, any>?

---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private m_xAxisName string
---@field private m_yAxisName string
---@field private m_data table<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Chart = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Chart:__init(super, chartDto, client)
    super(chartDto, client)

    self.m_xAxisName = chartDto.XAxisName
    self.m_yAxisName = chartDto.YAxisName
    self.m_data = chartDto.Data
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Chart.Update
function Chart:OnUpdate(update)
    for key, value in pairs(update.Data) do
        self.m_data[key] = value
    end
end

---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto
function Chart:ToDto()
    return ChartDto(self.Id, self.Name, self.ControllerId, self.m_xAxisName, self.m_yAxisName, self.m_data)
end

---@return string x, string y
function Chart:GetAxisNames()
    return self.m_xAxisName, self.m_yAxisName
end

---@return table<number, any>
function Chart:GetData()
    return Utils.Table.Copy(self.m_data)
end

---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Modify
---@field Data table<number, any>

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Feature.Chart.Modify)
function Chart:Modify(func)
    ---@type FactoryControl.Client.Entities.Controller.Feature.Chart.Modify
    local modify = { Data = {} }

    func(modify)

    local update = Update(self.Id, modify.Data)
    self.m_client:UpdateFeature(update)
end

return Utils.Class.CreateClass(Chart, "FactoryControl.Client.Entities.Controller.Feature.Chart",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureRadialRadial"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
    IsRunnable = true,
    Data = [[
local RadialDto = require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Radial.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Data
---@field Min number?
---@field Max number?
---@field Setting number?

---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field m_min number
---@field m_max number
---@field m_setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Radial:__init(super, radialDto, client)
    super(radialDto, client)

    self.m_min = radialDto.Min
    self.m_max = radialDto.Max
    self.m_setting = radialDto.Setting

    if self.m_max < self.m_min then
        error("max cannot be smaller then min")
    end

    if self.m_setting < self.m_min or self.m_setting > self.m_max then
        error("setting is out of bounds of " .. self.m_min .. " - " .. self.m_max)
    end
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Radial.Update
function Radial:OnUpdate(update)
    self.m_min = update.Min
    self.m_max = update.Max
    self.m_setting = update.Setting
end

---@return FactoryControl.Core.Entities.Controller.Feature.RadialDto
function Radial:ToDto()
    return RadialDto(self.Id, self.Name, self.ControllerId, self.m_min, self.m_max, self.m_setting)
end

---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Modify
---@field Min number
---@field Max number
---@field Setting number

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Feature.Radial.Modify)
function Radial:Modify(func)
    ---@type FactoryControl.Client.Entities.Controller.Feature.Radial.Modify
    local modify = { Min = self.m_min, Max = self.m_max, Setting = self.m_setting }

    func(modify)

    if modify.Max < modify.Min then
        error("max cannot be smaller then min")
    end

    if modify.Setting < modify.Min or modify.Setting > modify.Max then
        error("setting is out of bounds of " .. self.m_min .. " - " .. self.m_max)
    end

    local update = Update(self.Id, self.m_min, self.m_max, self.m_setting)
    self.m_client:UpdateFeature(update)
end

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
]]
}

PackageData["FactoryControlClientEntitiesControllerFeatureSwitchSwitch"] = {
    Location = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
    Namespace = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
    IsRunnable = true,
    Data = [[
local SwitchDto = require("FactoryControl.Core.Entities.Controller.Feature.Switch.SwitchDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Switch.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Switch : FactoryControl.Client.Entities.Controller.Feature
---@field private m_isEnabled boolean
---@field private m_old_isEnabled boolean
---@overload fun(switchDto: FactoryControl.Core.Entities.Controller.Feature.SwitchDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Switch
local Switch = {}

---@private
---@param switchDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Switch:__init(super, switchDto, client)
    super(switchDto, client)

    self.m_isEnabled = switchDto.IsEnabled
    self.m_old_isEnabled = switchDto.IsEnabled
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Switch.Update
function Switch:OnUpdate(update)
    self.m_isEnabled = update.IsEnabled
    self.m_old_isEnabled = update.IsEnabled
end

---@return FactoryControl.Core.Entities.Controller.Feature.SwitchDto
function Switch:ToDto()
    return SwitchDto(self.Id, self.Name, self.ControllerId, self.m_isEnabled)
end

---@private
function Switch:update()
    if self.m_isEnabled == self.m_old_isEnabled then
        return
    end

    local update = Update(self.Id, self.m_isEnabled)
    self.m_client:UpdateFeature(update)
end

---@return boolean isEnabled
function Switch:IsEnabled()
    return self.m_isEnabled
end

function Switch:Enable()
    self.m_isEnabled = true

    self:update()
end

function Switch:Disable()
    self.m_isEnabled = false

    self:update()
end

function Switch:Toggle()
    self.m_isEnabled = not self.m_isEnabled

    self:update()
end

return Utils.Class.CreateClass(Switch, "FactoryControl.Client.Entities.Controller.Feature.Switch",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
]]
}

return PackageData
