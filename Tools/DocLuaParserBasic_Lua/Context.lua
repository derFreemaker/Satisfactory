---@class Tools.DocLuaParserBasic.Context
-- ---@field Classes table<string, Tools.DocLuaParserBasic.Class>
---@field Functions table<string, Tools.DocLuaParserBasic.Function>
local Context = {}

---@return Tools.DocLuaParserBasic.Context
function Context.new()
    local instance = {
        Classes = {},
        Functions = {}
    }
    return setmetatable(instance, { __index = Context })
end

---@param func Tools.DocLuaParserBasic.Function
function Context:SetFunction(func)
    self.Functions[func.Name] = func
end

-- ---@param class Tools.DocLuaParserBasic.Class
-- function Context:SetClass(class)
--     self.Classes[class.Name] = class
-- end

return Context
