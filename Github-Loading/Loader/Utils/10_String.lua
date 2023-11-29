---@class Utils.String
local String = {}

---@param str string?
---@param seperator string?
---@return string[]
function String.Split(str, seperator)
    if str == nil then
        return {} end
    if seperator == nil then
        seperator = "%s" end
    local tbl = {}
    for splittedStr in string.gmatch(str, "([^" .. seperator .. "]+)") do
        tbl[#tbl + 1] = splittedStr
    end
    return tbl
end

---@param str string?
---@return boolean
function String.IsNilOrEmpty(str)
    if str == nil then
        return true
    end
    if str == "" then
        return true
    end
    return false
end

---@param array string[]
---@param sep string
---@return string
function String.Join(array, sep)
    local str = ""

    str = array[1]
    for _, value in next, array, 1 do
        str = str .. sep .. value
    end

    return str
end

return String
