---@class Adapter.InternetCard : object
---@field m_internetCard FIN.Components.FINComputerMod.InternetCard_C
local InternetCard = {}

---@param indexOrInternetCard number | FIN.Components.FINComputerMod.InternetCard_C
function InternetCard:__init(indexOrInternetCard)
    if not indexOrInternetCard then
        indexOrInternetCard = 1
    end

    if type(indexOrInternetCard) == "number" then
        self.m_internetCard = computer.getPCIDevices(findClass('InternetCard_C'))[indexOrInternetCard]
        if self.m_internetCard == nil then
            error('no internetCard was found')
        end
        return
    end

    ---@cast indexOrInternetCard FIN.Components.FINComputerMod.InternetCard_C
    self.m_internetCard = indexOrInternetCard
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
