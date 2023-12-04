local Utils = require("Tools.Utils")

---@class Tools.DocLuaParserBasic.ParseFunctions
local ParseFunctions = {}

---@param line string
---@return boolean
function ParseFunctions.IsComment(line)
    return line:find("^%-%-") ~= nil
end

---@param line string
---@return string comment
function ParseFunctions.ParseComment(line)
    return line:match("^%-%-%-? (.*)")
end

---@param line string
---@return boolean
function ParseFunctions.IsFunction(line)
    if line:find("^local ", nil, true) then
        line = line:sub(7, line:len())
    end
    return line:find("^function .+%(.*%)") ~= nil
end

---@param line string
---@return string name, string[] args
function ParseFunctions.ParseFunction(line)
    local name, argsStr = line:match("function (.+)%((.*)%)")
    return name, Utils.SplitStr(argsStr, ", ")
end

---@param line string
---@return boolean
function ParseFunctions.IsParameter(line)
    return line:find("^%-%-%-@param ") ~= nil
end

---@param line string
---@return string name, string type, string description
function ParseFunctions.ParseParameter(line)
    local name, type, description = line:match("^%-%-%-@param (.+) (.+) ?(.*)$")
    return name, type, description
end

---@param line string
---@return boolean
function ParseFunctions.IsReturn(line)
    return line:find("^%-%-%-@return ") ~= nil
end

---@return string name
---@return string type
---@return string description
function ParseFunctions.ParseReturn(line)
    local type, name, description = line:match("^%-%-%-@return (.+) (.+) ?(.*)$")
    return name, type, description
end

return ParseFunctions
