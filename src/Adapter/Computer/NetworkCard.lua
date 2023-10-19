---@class Adapter.Computer.NetworkCard : object
---@field private _NetworkCard FIN.Components.FINComputerMod.NetworkCard_C
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
		self._NetworkCard = component.proxy(idOrIndexOrNetworkCard) --[[@as FIN.Components.FINComputerMod.NetworkCard_C]]
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		self._NetworkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self._NetworkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FIN.Components.FINComputerMod.NetworkCard_C
	self._NetworkCard = idOrIndexOrNetworkCard
end

---@return FIN.UUID
function NetworkCard:GetIPAddress()
	return self._NetworkCard.id
end

---@return string nick
function NetworkCard:GetNick()
	return self._NetworkCard.nick
end

function NetworkCard:Listen()
	event.listen(self._NetworkCard)
end

---@param port integer
function NetworkCard:OpenPort(port)
	self._NetworkCard:open(port)
end

---@param port integer
function NetworkCard:ClosePort(port)
	self._NetworkCard:close(port)
end

function NetworkCard:CloseAllPorts()
	self._NetworkCard:closeAll()
end

---@param address Net.Core.IPAddress
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self._NetworkCard:send(address:GetAddress(), port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self._NetworkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
