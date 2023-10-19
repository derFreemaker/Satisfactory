---@class Adapter.Computer.NetworkCard : object
---@field private networkCard FIN.Components.FINComputerMod.NetworkCard_C
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
		self.networkCard = component.proxy(idOrIndexOrNetworkCard) --[[@as FIN.Components.FINComputerMod.NetworkCard_C]]
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		self.networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FIN.Components.FINComputerMod.NetworkCard_C
	self.networkCard = idOrIndexOrNetworkCard
end

---@return FIN.UUID
function NetworkCard:GetIPAddress()
	return self.networkCard.id
end

---@return string nick
function NetworkCard:GetNick()
	return self.networkCard.nick
end

function NetworkCard:Listen()
	event.listen(self.networkCard)
end

---@param port integer
function NetworkCard:OpenPort(port)
	self.networkCard:open(port)
end

---@param port integer
function NetworkCard:ClosePort(port)
	self.networkCard:close(port)
end

function NetworkCard:CloseAllPorts()
	self.networkCard:closeAll()
end

---@param address Net.Core.IPAddress
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.networkCard:send(address:GetAddress(), port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.networkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
