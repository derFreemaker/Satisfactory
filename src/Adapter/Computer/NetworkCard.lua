local Reference = require("Core.References.Reference")
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

---@class Adapter.Computer.NetworkCard : object
---@field private m_networkCard FIN.Components.FINComputerMod.NetworkCard_C
---@field private m_openPorts table<integer, true>
---@overload fun(idOrIndexOrNetworkCard: FIN.UUID | integer) : Adapter.Computer.NetworkCard
local NetworkCard = {}

local firstNetworkCard = true
---@private
---@param idOrIndex FIN.UUID | integer
function NetworkCard:__init(idOrIndex)
	self.m_openPorts = {}
	if not idOrIndex then
		idOrIndex = 1
	end

	local networkCard
	if type(idOrIndex) == 'string' then
		---@cast idOrIndex FIN.UUID
		networkCard = Reference(idOrIndex)
	else
		---@cast idOrIndex integer
		networkCard = PCIDeviceReference(findClass('NetworkCard_C'), idOrIndex)
	end
	networkCard:Raw__Check()

	---@diagnostic disable-next-line
	self.m_networkCard = networkCard

	if firstNetworkCard then
		self:CloseAllPorts()
		firstNetworkCard = false
	end
end

---@return FIN.UUID
function NetworkCard:GetIPAddress()
	return self.m_networkCard.id
end

---@return string nick
function NetworkCard:GetNick()
	return self.m_networkCard.nick
end

function NetworkCard:Listen()
	event.listen(self.m_networkCard)
end

---@param port integer
---@return boolean openedPort
function NetworkCard:OpenPort(port)
	if self.m_openPorts[port] then
		return false
	end

	self.m_networkCard:open(port)
	self.m_openPorts[port] = true
	return true
end

---@param port integer
function NetworkCard:ClosePort(port)
	self.m_openPorts[port] = nil

	self.m_networkCard:close(port)
end

function NetworkCard:CloseAllPorts()
	self.m_openPorts = {}

	self.m_networkCard:closeAll()
end

---@param address Net.Core.IPAddress
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.m_networkCard:send(address:GetAddress(), port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.m_networkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
