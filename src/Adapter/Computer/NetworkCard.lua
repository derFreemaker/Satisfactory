---@class Adapter.Computer.NetworkCard : object
---@field private m_networkCard FIN.Components.FINComputerMod.NetworkCard_C
---@overload fun(idOrIndexOrNetworkCard: FIN.UUID | integer | FIN.Components.FINComputerMod.NetworkCard_C) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndexOrNetworkCard FIN.UUID | integer | FIN.Components.FINComputerMod.NetworkCard_C
function NetworkCard:__init(idOrIndexOrNetworkCard)
	if not idOrIndexOrNetworkCard then
		idOrIndexOrNetworkCard = 1
	end

	if type(idOrIndexOrNetworkCard) == 'string' then
		---@cast idOrIndexOrNetworkCard FIN.UUID
		self.m_networkCard = component.proxy(idOrIndexOrNetworkCard) --[[@as FIN.Components.FINComputerMod.NetworkCard_C]]
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		self.m_networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.m_networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FIN.Components.FINComputerMod.NetworkCard_C
	self.m_networkCard = idOrIndexOrNetworkCard
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
function NetworkCard:OpenPort(port)
	self.m_networkCard:open(port)
end

---@param port integer
function NetworkCard:ClosePort(port)
	self.m_networkCard:close(port)
end

function NetworkCard:CloseAllPorts()
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
