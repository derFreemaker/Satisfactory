---@class Ficsit_Networks_Sim.Utils.Tools
local Tools = {}

---@param func function
---@param object table | nil
---@param ... any | nil
---@return thread, boolean, 'result'
function Tools.ExecuteFunctionAsThread(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end

local charset = {} do -- [0-9a-zA-Z]
    for c = 48, 57 do table.insert(charset, string.char(c)) end
    for c = 65, 90 do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end
math.randomseed(os.time())
---@param length integer
---@return string
function Tools.RandomString(length)
    local str = {}
    for _ = 1, length do
        table.insert(str, charset[math.random(1, #charset)])
    end
    return table.concat(str)
end

---@param value any
---@param typesToCheck type | Array<type>
---@param parameterPos integer | nil
---@param errorLevel integer | nil
function Tools.CheckParameterType(value, typesToCheck, parameterPos, errorLevel)
    errorLevel = 3 + (errorLevel or 0)
    local debugInfo = debug.getinfo(2)
    local valueType = type(value)
    if type(typesToCheck) == "table" then
        for _, type in ipairs(typesToCheck) do
            if type == valueType then
                return
            end
        end
        typesToCheck = table.concat(typesToCheck, "','")
    else
        if valueType == typesToCheck then
            return
        end
    end

    local errorMessage = "bad argument to '" .. debugInfo.name .. "("
    if parameterPos == nil or parameterPos < 1 then
        errorMessage = errorMessage .. typesToCheck .. " expected, got " .. valueType .. ")"
        error(errorMessage, errorLevel)
    end

    for i = 1, parameterPos - 1 do
        if i == 1 then
            errorMessage = errorMessage .. "..."
        else
            errorMessage = errorMessage .. ", ..."
        end
    end
    if parameterPos - 1 ~= 0 then
        errorMessage = errorMessage .. ", "
    end
    errorMessage = errorMessage .. "{'" .. typesToCheck .. "' expected, got '" .. valueType .. "'}"
    for _ = 1, debugInfo.nparams - parameterPos do
        errorMessage = errorMessage .. ", ..."
    end

    errorMessage = errorMessage .. ")'"
    error(errorMessage, errorLevel)
end

local Table = {}

---@generic Table
---@param table Table
---@return Table
function Table.Copy(table)
    local copy = {}
    for key, value in pairs(table) do copy[key] = value end
    return setmetatable(copy, getmetatable(table))
end

Tools.Table = Table

return Tools
