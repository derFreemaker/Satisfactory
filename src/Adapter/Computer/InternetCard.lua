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
    if not internetCard:Refresh() then
        error("no internet card found")
    end

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
