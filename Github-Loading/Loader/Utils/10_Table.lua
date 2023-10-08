---@class Utils.Table
local Table = {}

---@param obj any?
---@param seen any[]
---@return any
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

---@param t table
---@return table table
function Table.Copy(t)
    return copyTable(t, {}, {})
end

---@param from table
---@param to table
function Table.CopyTo(from, to)
    copyTable(from, to, {})
end

---@param t table
function Table.Clear(t)
    for key, _ in pairs(t) do
        t[key] = nil
    end
    setmetatable(t, nil)
end

---@param t table
---@param value any
---@return boolean
function Table.Contains(t, value)
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
function Table.ContainsKey(t, key)
    if t[key] ~= nil then
        return true
    end
    return false
end

return Table
