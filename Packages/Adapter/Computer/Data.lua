---@meta
local PackageData = {}

PackageData["AdapterComputerInternetCard"] = {
    Location = "Adapter.Computer.InternetCard",
    Namespace = "Adapter.Computer.InternetCard",
    IsRunnable = true,
    Data = [[
local ComputerPartReference = require("Core.References.PCIDeviceReference")

local InternetCards = setmetatable({}, { __mode = 'v' })

---@class Adapter.Computer.InternetCard : object
---@field m_refInternetCard Core.IReference<FIN.Components.FINComputerMod.InternetCard_C>
local InternetCard = {}

---@param index number
function InternetCard:__init(index)
    if not index then
        index = 1
    end

    if Utils.Table.ContainsKey(InternetCards, index) then
        return InternetCards[index]
    end

    local internetCard = ComputerPartReference(findClass('InternetCard_C'), index)
    internetCard:Check()

    self.m_refInternetCard = internetCard
    InternetCards[index] = self
end

---@param url string
---@param logger Core.Logger?
---@return boolean success, string? data, number statusCode
function InternetCard:Download(url, logger)
    if logger then
        logger:LogTrace("downloading from: '" .. url .. "'...")
    end

    local req = self.m_refInternetCard:Get():request(url, 'GET', '')
    repeat until req:canGet()

    local code, data = req:get()

    if logger then
        logger:LogTrace("downloaded from: '" .. url .. "'")
    end

    if code > 302 then
        return false, data, code
    end

    return true, data, code
end

return Utils.Class.CreateClass(InternetCard, "Adapter.Computer.InternetCard")
]]
}

PackageData["AdapterComputerNetworkCard"] = {
    Location = "Adapter.Computer.NetworkCard",
    Namespace = "Adapter.Computer.NetworkCard",
    IsRunnable = true,
    Data = [[
local Reference = require("Core.References.Reference")
local PCIDeviceReference = require("Core.References.PCIDeviceReference")

---@type { [integer | string]: Adapter.Computer.NetworkCard }
local NetworkCards = setmetatable({}, { __mode = 'v' })

---@class Adapter.Computer.NetworkCard : object
---@field private m_refNetworkCard Core.IReference<FIN.Components.NetworkCard_C>
---@field private m_openPorts table<integer, true>
---@overload fun(idOrIndexOrNetworkCard: FIN.UUID | integer) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndex FIN.UUID | integer
function NetworkCard:__init(idOrIndex)
	self.m_openPorts = {}
	if not idOrIndex then
		idOrIndex = 1
	end

	if Utils.Table.ContainsKey(NetworkCards, idOrIndex) then
		return NetworkCards[idOrIndex]
	end

	local networkCard
	if type(idOrIndex) == 'string' then
		---@cast idOrIndex FIN.UUID
		networkCard = Reference(idOrIndex)
	else
		---@cast idOrIndex integer
		networkCard = PCIDeviceReference(findClass('NetworkCard_C'), idOrIndex)
	end
	networkCard:Check()

	self.m_refNetworkCard = networkCard
	NetworkCards[idOrIndex] = self

	self:CloseAllPorts()
end

---@private
function NetworkCard:__gc()
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

---@param address Net.Core.IPAddress
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.m_refNetworkCard:Get():send(address:GetAddress(), port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.m_refNetworkCard:Get():broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
]]
}

return PackageData
