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
---@return boolean success, any[] returns
function Function.InvokeProtected(func, parent, ...)
    local results
    if parent ~= nil then
        results = table.pack(pcall(func, parent, ...))
    else
        results = table.pack(pcall(func, ...))
    end
    local success = Utils.Table.Retrive(results, 1)
    return success, results
end

---@param func function
---@param parent any
---@param args any[]
---@return any[] returns
function Function.DynamicInvoke(func, parent, args)
    local results
    if parent ~= nil then
        results = table.pack(func(parent, table.unpack(args)))
    else
        results = table.pack(func(table.unpack(args)))
    end
    return results
end

---@param func function
---@param parent any
---@param args any[]
---@return boolean success, any[] returns
function Function.DynamicInvokeProtected(func, parent, args)
    local results
    if parent ~= nil then
        results = table.pack(pcall(func, parent, table.unpack(args)))
    else
        results = table.pack(pcall(func, table.unpack(args)))
    end
    local success = Utils.Table.Retrive(results, 1)
    return success, results
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
    local file = filesystem.open(path, "w")
    file:write("")
    file:close()
end

Utils.File = File
---@class Utils.Table
local Table = {}

---@param T table
---@return table table
function Table.Copy(T)
    local copy = {}
    for key, value in pairs(T) do copy[key] = value end
    return setmetatable(copy, getmetatable(T))
end

--- removes all margins like table[1] = "1", table[2] = nil, table[3] = "3" -> table[2] would be removed meaning table[3] would be table[2] now and so on. Removes no named values (table["named"]). And sets n to number of cleaned results. Should only be used on arrays really.
---@generic T
---@param t T[]
---@return T[] table cleaned table
---@return integer numberOfCleanedValues
function Table.Clean(t)
    ---@generic T
    ---@param tableToLook T[]
    ---@param index integer
    ---@return integer
    local function findNearestNilValueDownward(tableToLook, index)
        if tableToLook[index] == nil then
            return index
        end
        return findNearestNilValueDownward(tableToLook, index - 1)
    end

    local numberOfCleanedValues = 0
    for index = 1, #t, 1 do
        local value = t[index]
        if index ~= 1 and type(index) == "number" then
            local nearestNilValue = findNearestNilValueDownward(t, index)
            t[nearestNilValue] = value
            t[index] = nil
            numberOfCleanedValues = numberOfCleanedValues + 1
        elseif value ~= nil and type(index) == "number" then
            numberOfCleanedValues = numberOfCleanedValues + 1
        end
    end
    return t, numberOfCleanedValues
end

--- Gets the value out of the array at specifyed index if not nil.
--- And fills the removed value by sorting the array.
--- Uses ```Table.Clean``` so ```t.n``` will be used.
---@generic T
---@param t T[]
---@param index integer
---@return T value
function Table.Retrive(t, index)
    local value = t[index]
    t[index] = nil
    t = Table.Clean(t)
    return value
end

Utils.Table = Table

return Utils