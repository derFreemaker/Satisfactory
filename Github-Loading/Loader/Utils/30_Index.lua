local LoadedLoaderFiles = ({ ... })[1]

---@class Utils
local Utils = {}

---@param ms number defines how long the function will wait in Milliseconds
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

---@param url string
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@param logger (Github_Loading.Logger | Core.Logger)?
---@return boolean success, string? data
function Utils.Download(url, internetCard, logger)
    if logger then logger:LogTrace("downloading from: '" .. url .. "'...") end
    local req = internetCard:request(url, "GET", "")
    repeat until req:canGet()
    local code, data = req:get()
    if code ~= 200 or data == nil then return false, nil end
    if logger then logger:LogTrace("downloaded from: '" .. url .. "'") end
    return true, data
end

---@param url string
---@param path string
---@param forceDownload boolean
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@param logger (Github_Loading.Logger | Core.Logger)?
---@return boolean
function Utils.DownloadToFile(url, path, forceDownload, internetCard, logger)
    if forceDownload == nil then forceDownload = false end
    if filesystem.exists(path) and not forceDownload then
        return true
    end
    local success, data = Utils.Download(url, internetCard, logger)
    if not success or not data then
        return false
    end
    local file = filesystem.open(path, "w")
    if file == nil then
        return false
    end
    file:write(data)
    file:close()
    return true
end

---@type Utils.File
Utils.File = LoadedLoaderFiles["/Github-Loading/Loader/Utils/File"][1]

---@type Utils.Function
Utils.Function = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Function"][1]

---@type Utils.String
Utils.String = LoadedLoaderFiles["/Github-Loading/Loader/Utils/String"][1]

---@type Utils.Table
Utils.Table = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Table"][1]

---@type Utils.Class
Utils.Class = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class"][1]

return Utils