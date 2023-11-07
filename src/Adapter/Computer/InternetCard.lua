local ComputerPartReference = require("Core.References.PCIDeviceReference")

---@class Adapter.InternetCard : object
---@field m_internetCard FIN.Components.FINComputerMod.InternetCard_C
local InternetCard = {}

---@param index number
function InternetCard:__init(index)
    if not index then
        index = 1
    end

    local internetCard = ComputerPartReference(findClass('InternetCard_C'), index)
    internetCard:Raw__Check()

    ---@diagnostic disable-next-line
    self.m_internetCard = internetCard
end

---@param url string
---@param logger Core.Logger?
---@return boolean success, string? data, number statusCode
function InternetCard:Download(url, logger)
    if logger then
        logger:LogTrace("downloading from: '" .. url .. "'...")
    end

    local req = self.m_internetCard:request(url, 'GET', '')
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

return Utils.Class.CreateClass(InternetCard, "Adapter.InternetCard")
