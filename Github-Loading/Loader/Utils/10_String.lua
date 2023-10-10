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
    for splittedStr in string.gmatch(str, "([^" .. seperator .. "]*)") do
        t[#t + 1] = splittedStr
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

---@param array string[]
---@param sep string
---@return string
function String.Join(array, sep)
    local str = ""

    for index, value in ipairs(array) do
        if index == 1 then
            str = value
        else
            str = str .. sep .. value
        end
    end

    return str
end

return String
