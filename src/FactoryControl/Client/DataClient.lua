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
---@overload fun(logger: Core.Logger) : FactoryControl.Client.DataClient
local DataClient = {}

---@param networkClient Net.Core.NetworkClient
function DataClient.Static__WaitForHeartbeat(networkClient)
	networkClient:WaitForEvent(Usage.Events.FactoryControl_Heartbeat, Usage.Ports.FactoryControl_Heartbeat)
end

---@private
---@param logger Core.Logger
function DataClient:__init(logger)
	self.m_logger = logger
	self.m_client = HttpClient(self.m_logger:subLogger('RestApiClient'))

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
		Usage.Ports.FactoryControl_FeatureUpdate,
		Usage.Events.FactoryControl_Feature_Invoked,
		featureUpdate
	)
end

return Utils.Class.CreateClass(DataClient, "FactoryControl.Client.DataClient")
