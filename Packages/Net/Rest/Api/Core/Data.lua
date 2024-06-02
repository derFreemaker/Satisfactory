local Data={
["Net.Rest.Api.__events"] = [==========[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- Api
        require("Net.Rest.Api.Request"),
        require("Net.Rest.Api.Response"),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
end

return Events

]==========],
["Net.Rest.Api.NetworkContextExtensions"] = [==========[
local NetworkContext = require("Net.Core.NetworkContext")

---@class Net.Core.NetworkContext
local NetworkContextExtensions = {}

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Request
function NetworkContextExtensions:GetApiRequest()
	return self.Body
end

--- ## Extension from Net.Rest
---@return Net.Rest.Api.Response
function NetworkContextExtensions:GetApiResponse()
	return self.Body
end

Utils.Class.Extend(NetworkContext, NetworkContextExtensions)

]==========],
["Net.Rest.Api.Request"] = [==========[
---@class Net.Rest.Api.Request : object, Core.Json.ISerializable
---@field Method Net.Core.Method
---@field Endpoint Net.Rest.Uri
---@field Headers table<string, any>
---@field Body any
---@overload fun(method: Net.Core.Method, endpoint: Net.Rest.Uri, body: any, headers: table<string, any>?) : Net.Rest.Api.Request
local Request = {}

---@private
---@param method Net.Core.Method
---@param endpoint Net.Rest.Uri
---@param body any
---@param headers table<string, any>?
function Request:__init(method, endpoint, body, headers)
    self.Method = method
    self.Endpoint = endpoint
    self.Body = body
    self.Headers = headers or {}
end

---@return Net.Core.Method method, Net.Rest.Uri endpoint, any body, table<string, any> headers
function Request:Serialize()
    return self.Method, self.Endpoint, self.Body, self.Headers
end

return class("Net.Rest.Api.Request", Request,
    { Inherit = require("Core.Json.ISerializable") })

]==========],
["Net.Rest.Api.Response"] = [==========[
---@class Net.Rest.Api.Response.Header : table<string, any>
---@field Code Net.Core.StatusCodes

---@class Net.Rest.Api.Response : object, Core.Json.ISerializable
---@field Headers Net.Rest.Api.Response.Header
---@field Body any
---@field WasSuccessful boolean
---@overload fun(body: any, header: (Net.Rest.Api.Response.Header)?) : Net.Rest.Api.Response
local Response = {}

---@private
---@param body any
---@param header (Net.Rest.Api.Response.Header)?
function Response:__init(body, header)
    self.Body = body
    self.Headers = header or {}
    if type(self.Headers.Code) == "number" then
        self.WasSuccessful = self.Headers.Code < 300
    else
        self.WasSuccessful = false
    end
end

---@return Net.Rest.Api.Response.Header headers, any body
function Response:Serialize()
    return self.Body, self.Headers
end

return class("Net.Rest.Api.Response", Response,
    { Inherit = require("Core.Json.ISerializable") })

]==========],
}

return Data
