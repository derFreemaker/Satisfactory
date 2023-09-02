local LoadedLoaderFiles = table.pack(...)[1]

---@class Utils
local Utils = {}

---@param ms number defines how long the function will wait in Milliseconds
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

---@type Utils.String
Utils.String = LoadedLoaderFiles["/Github-Loading/Loader/Utils/String"][1]

---@type Utils.Function
Utils.Function = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Function"][1]

---@type Utils.File
Utils.File = LoadedLoaderFiles["/Github-Loading/Loader/Utils/File"][1]

---@type Utils.Table
Utils.Table = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Table"][1]

---@type Utils.Class
Utils.Class = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class"][1]

return Utils