local ProxyReference = require("Core.References.ProxyReference")
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

local Cache = require("Core.Adapter.Cache")()

---@class Adapter.Computer.NetworkCard : Adapter.IAdapter
---@field private m_refNetworkCard Core.IReference<FIN.Components.NetworkCard_C>
---@field private m_openPorts table<integer, true>
---@overload fun(idOrIndexOrNetworkCard: (FIN.UUID | integer)?) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndex (FIN.UUID | integer)?
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
	if type(idOrIndex) == 'string' then
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

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
