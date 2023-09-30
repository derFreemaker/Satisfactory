---@class Adapter.Computer.NetworkCard : object
---@field private id FicsIt_Networks.UUID
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
---@overload fun(idOrIndexOrNetworkCard: FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndexOrNetworkCard FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
function NetworkCard:__init(idOrIndexOrNetworkCard)
	if type(idOrIndexOrNetworkCard) == 'string' then
		---@cast idOrIndexOrNetworkCard FicsIt_Networks.UUID
		self.networkCard = component.proxy(idOrIndexOrNetworkCard) --[[@as FicsIt_Networks.Components.FINComputerMod.NetworkCard_C]]
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		---@cast idOrIndexOrNetworkCard integer
		self.networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
	self.networkCard = idOrIndexOrNetworkCard
end

---@return FicsIt_Networks.UUID
function NetworkCard:GetId()
	if self.id then
		return self.id
	end

	local splittedPrint = Utils.String.Split(tostring(self.networkCard), ' ')
	self.id = splittedPrint[#splittedPrint] --[[@as FicsIt_Networks.UUID]]
	return self.id
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

---@param address string
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.networkCard:send(address, port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.networkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
