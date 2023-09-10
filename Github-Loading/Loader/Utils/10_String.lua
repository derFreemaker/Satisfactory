---@class Utils.String
local String = {}

---@param str string
---@param seperator string
---@return string[]
function String.Split(str, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t = {}
    for splittedStr in string.gmatch(str, "([^" .. seperator .. "]+)") do
        table.insert(t, splittedStr)
    end
    return t
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

return String