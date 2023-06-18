---@class Utils
Utils = {}

---@param ms number defines how long the function will wait in Milliseconds
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

---@param func function
---@param object table | nil
---@param ... any | nil
---@return thread, boolean, 'result'
function Utils.ExecuteFunctionAsThread(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end


Utils.File = {}

---@param path string
---@param mode string
---@param data string | nil
---@param createPath boolean | nil
function Utils.File.Write(path, mode, data, createPath)
    data = data or ""
    createPath = createPath or false

    local fileName = filesystem.path(3, path)
    local folderPath = path:gsub(fileName, "")
    if not filesystem.exists(folderPath) then
        if not createPath then
            error("folder does not exists: '".. folderPath .."'", 2)
        end
        filesystem.createDir(folderPath)
    end

    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

---@param path string
---@return string
function Utils.File.Read(path)
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(256)
        if not buf then
            break
        end
        str = str .. buf
    end
    return str
end

Utils.Table = {}

---@generic Table
---@param table Table
---@return Table
function Utils.Table.Copy(table)
    local copy = {}
    for key, value in pairs(table) do copy[key] = value end
    return setmetatable(copy, getmetatable(table))
end


-- Types and Classes --

---@class Dictionary<T>: { [string]: T }
---@class Array<T>: { [integer]: T }