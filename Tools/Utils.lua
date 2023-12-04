---@class Tools.Utils
local Utils = {}

---@param str string
---@param pattern string
---@param plain boolean
---@return string?, integer
local function findNext(str, pattern, plain)
    local found = str:find(pattern, 0, plain)
    if found == nil then
        return nil, 0
    end
    return str:sub(0, found - 1), found - 1
end

---@param str string?
---@param sep string?
---@param plain boolean? default `true`
---@return string[]
function Utils.SplitStr(str, sep, plain)
    if str == nil then
        return {}
    end
    if plain == nil then
        plain = true
    end

    local strLen = str:len()
    local sepLen

    if sep == nil then
        sep = "%s"
        sepLen = 2
    else
        sepLen = sep:len()
    end

    local tbl = {}
    local i = 0
    while true do
        i = i + 1
        local foundStr, foundPos = findNext(str, sep, plain)

        if foundStr == nil then
            tbl[i] = str
            return tbl
        end

        tbl[i] = foundStr
        str = str:sub(foundPos + sepLen + 1, strLen)
    end
end

---@param array string[]
---@param sep string
---@return string
function Utils.JoinStr(array, sep)
    local str = ""

    str = array[1]
    for _, value in next, array, 1 do
        str = str .. sep .. value
    end

    return str
end

---@param t table
---@param value any
---@return boolean
function Utils.TableContains(t, value)
    for _, tValue in pairs(t) do
        if value == tValue then
            return true
        end
    end
    return false
end

---@param t table
---@param key any
---@return boolean
function Utils.TableContainsKey(t, key)
    if t[key] ~= nil then
        return true
    end
    return false
end

---@generic TTable
---@param t TTable
---@return TTable table
function Utils.CopyTable(t)
    ---@param obj table?
    ---@param seen table[]
    ---@return table?
    local function copyTable(obj, copy, seen)
        if obj == nil then return nil end
        if seen[obj] then return seen[obj] end

        seen[obj] = copy
        setmetatable(copy, copyTable(getmetatable(obj), {}, seen))

        for key, value in next, obj, nil do
            key = (type(key) == "table") and copyTable(key, {}, seen) or key
            value = (type(value) == "table") and copyTable(value, {}, seen) or value
            rawset(copy, key, value)
        end

        return copy
    end

    return copyTable(t, {}, {})
end

return Utils
