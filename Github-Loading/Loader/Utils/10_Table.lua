---@class Utils.Table
local Table = {}

---@param obj any?
---@param seen any[]
---@return any
local function copyTable(obj, seen)
    if obj == nil then return nil end
    if seen[obj] then return seen[obj] end

    local copy = {}
    seen[obj] = copy
    setmetatable(copy, copyTable(getmetatable(obj), seen))

    for key, value in next, obj, nil do
        key = (type(key) == "table") and copyTable(key, seen) or key
        value = (type(value) == "table") and copyTable(value, seen) or value
        rawset(copy, key, value)
    end

    return copy
end

---@param t table
---@return table table
function Table.Copy(t)
    return copyTable(t, {})
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

---@param t table
---@return integer count
function Table.Count(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
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

return Table
