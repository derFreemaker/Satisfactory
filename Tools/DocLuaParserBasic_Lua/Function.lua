---@alias Tools.DocLuaParserBasic.Function.Parameter { Name: string, Type: string, Description: string }

---@class Tools.DocLuaParserBasic.Function
---@field Name string
---@field Args table<string, Tools.DocLuaParserBasic.Function.Parameter>
---@field Returns table<string, Tools.DocLuaParserBasic.Function.Parameter>
---@field Description string[]
local Function = {}

---@param name string
---@param args table<string, Tools.DocLuaParserBasic.Function.Parameter>
---@param returns table<string, Tools.DocLuaParserBasic.Function.Parameter>
---@param description string[]
---@return Tools.DocLuaParserBasic.Function
function Function.new(name, args, returns, description)
    local instance = {
        Name = name,
        Args = args,
        Returns = returns,
        Description = description
    }
    return setmetatable(instance, { __index = Function })
end

return Function
