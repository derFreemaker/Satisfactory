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

---@class Utils.Function
local Function = {}

---@param func function
---@param parent any
---@param ... any
---@return thread thread, boolean success, table results
function Function.InvokeFunctionAsThread(func, parent, ...)
    local thread = coroutine.create(func)
    local result = {}
    if parent == nil then
        result = table.pack(coroutine.resume(thread, ...))
    else
        result = table.pack(coroutine.resume(thread, parent, ...))
    end
    ---@type boolean
    local success = result[1]
    result[1] = nil
    result = Utils.Table.Clean(result)
    return thread, success, result
end

---@param func function
---@param parent any
---@param args table
---@return table results
function Function.InvokeDynamic(func, parent, args)
    if parent == nil then
        return table.pack(func(table.unpack(args)))
    else
        return table.pack(func(parent, table.unpack(args)))
    end
end

---@param func function
---@param parent any
---@param args table
---@return thread thread, boolean success, table results
function Function.InvokeDynamicAsThread(func, parent, args)
    return Function.InvokeFunctionAsThread(func, parent, table.unpack(args))
end

Utils.Function = Function
---@class Utils.File
local File = {}

---@alias Utils.File.writeModes
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@param path string
---@param mode Utils.File.writeModes
---@param data string?
---@param createPath boolean?
function File.Write(path, mode, data, createPath)
    data = data or ""
    createPath = createPath or false

    local fileName = filesystem.path(3, path)
    local folderPath = path:gsub(fileName, "")
    if not filesystem.exists(folderPath) then
        if not createPath then
            error("folder does not exists: '" .. folderPath .. "'", 2)
        end
        filesystem.createDir(folderPath)
    end

    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

---@param path string
---@return string
function File.ReadAll(path)
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(8192)
        if not buf then
            break
        end
        str = str .. buf
    end
    file:close()
    return str
end

---@param path string
function File.Clear(path)
    if not filesystem.exists(path) then
        return
    end
    local file = filesystem.open(path, "+r")
    file:close()
end

Utils.File = File
---@class Utils.Table
local Table = {}

---@generic Table
---@param table Table
---@return Table
function Table.Copy(table)
    local copy = {}
    for key, value in pairs(table) do copy[key] = value end
    return setmetatable(copy, getmetatable(table))
end

--- removes all margins like table[1] = "1", table[2] = nil, table[3] = "3" -> table[2] would be removed meaning table[3] would be table[2] now and so on. Removes no named values (table["named"]). And sets n to number of cleaned results. Should only be used on arrays really.
---@param table table
---@return table table cleaned table
function Table.Clean(table)
    ---@param t table
    ---@param index integer
    ---@return integer
    local function findNearestNilValueDownward(t, index)
        if index == 1 then
            return index
        end
        if t[index] == nil then
            return index
        end
        return findNearestNilValueDownward(t, index - 1)
    end
    local numberOfCleanedValues = 0
    for index, value in ipairs(table) do
        local nearestNilValue = findNearestNilValueDownward(table, index)
        table[nearestNilValue] = value
        table[index] = nil
        numberOfCleanedValues = numberOfCleanedValues + 1
    end
    table.n = numberOfCleanedValues
    return table
end

Utils.Table = Table

return Utils