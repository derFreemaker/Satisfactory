local Data={
["Adapter.Computer.InternetCard"] = [==========[
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

---@type Core.Cache<(string | integer), Adapter.Computer.InternetCard>
local Cache = require("Core.Common.Cache")()

---@class Adapter.Computer.InternetCard : object
---@field m_refInternetCard Core.Reference<FIN.InternetCard_C>
---@overload fun(index: integer?) : Adapter.Computer.InternetCard
local InternetCard = {}

---@private
---@param index integer?
function InternetCard:__init(index)
    if not index then
        index = 1
    end

    ---@type Out<Adapter.Computer.InternetCard>
    local internetCardAdapter = {}
    if Cache:TryGet(index, internetCardAdapter) then
        return internetCardAdapter.Value
    end

    local internetCard = PCIDeviceReference(classes.InternetCard_C, index)
    if not internetCard:Fetch() then
        error("no internet card found")
    end

    self.m_refInternetCard = internetCard
    Cache:Add(index, self)
end

---@param url string
---@param logger Core.Logger?
---@return boolean success, string? data, number statusCode
function InternetCard:Download(url, logger)
    if logger then
        logger:LogTrace("downloading from: " .. url .. "...")
    end

    local req = self.m_refInternetCard:Get():request(url, "GET", "")
    repeat until req:canGet()

    local code, data = req:get()

    if logger then
        logger:LogTrace("downloaded from: " .. url)
    end

    if code > 302 then
        return false, data, code
    end

    return true, data, code
end

return class("Adapter.Computer.InternetCard", InternetCard)

]==========],
["Adapter.Computer.NetworkCard"] = [==========[
local ProxyReference = require("Core.References.ProxyReference")
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

---@type Core.Cache<(string | integer), Adapter.Computer.NetworkCard>
local Cache = require("Core.Common.Cache")()

---@class Adapter.Computer.NetworkCard : object
---@field private m_refNetworkCard Core.Reference<FIN.NetworkCard_C>
---@field private m_openPorts table<integer, true>
---@overload fun(idOrIndexOrNetworkCard: (FIN.UUID | integer) | nil) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndex (FIN.UUID | integer) | nil
function NetworkCard:__init(idOrIndex)
	self.m_openPorts = {}
	if not idOrIndex then
		idOrIndex = 1
	end

	---@type Out<Adapter.Computer.NetworkCard>
	local networkCardAdapter = {}
	if Cache:TryGet(idOrIndex, networkCardAdapter) then
		return networkCardAdapter.Value
	end

	local networkCard
	if type(idOrIndex) == "string" then
		---@cast idOrIndex FIN.UUID
		networkCard = ProxyReference(idOrIndex)
	else
		---@cast idOrIndex integer
		networkCard = PCIDeviceReference(classes.NetworkCard_C, idOrIndex)
	end
	if not networkCard:Fetch() then
		error("no network card found")
	end

	self.m_refNetworkCard = networkCard
	Cache:Add(idOrIndex, self)

	self:CloseAllPorts()
end

---@return FIN.UUID
function NetworkCard:GetIPAddress()
	return self.m_refNetworkCard:Get().id
end

---@return string nick
function NetworkCard:GetNick()
	return self.m_refNetworkCard:Get().nick
end

function NetworkCard:Listen()
	event.listen(self.m_refNetworkCard)
end

---@param port integer
---@return boolean openedPort
function NetworkCard:OpenPort(port)
	if self.m_openPorts[port] then
		return false
	end

	self.m_refNetworkCard:Get():open(port)
	self.m_openPorts[port] = true
	return true
end

---@param port integer
function NetworkCard:ClosePort(port)
	self.m_openPorts[port] = nil

	self.m_refNetworkCard:Get():close(port)
end

function NetworkCard:CloseAllPorts()
	self.m_openPorts = {}

	self.m_refNetworkCard:Get():closeAll()
end

---@param address FIN.UUID
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.m_refNetworkCard:Get():send(address, port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.m_refNetworkCard:Get():broadcast(port, ...)
end

return class("Adapter.Computer.NetworkCard", NetworkCard)

]==========],
}

return Data
