local Utils = require("Tools.Utils")

local ParseFunctions = require("Tools.DocLuaParserBasic.ParseFunctions")

local Function = require("Tools.DocLuaParserBasic.Function")
local Context = require("Tools.DocLuaParserBasic.Context")

---@class Tools.DocLuaParserBasic.Parser
local Parser = {}

function Parser.new()
    local instance = {}
    return setmetatable(instance, { __index = Parser })
end

---@param str string
---@return Tools.DocLuaParserBasic.Context
function Parser:ParseStr(str)
    local lines = Utils.SplitStr(str, "\n", false)

    local context = Context.new()
    ---@type string[]
    local comments = {}
    ---@type table<string, Tools.DocLuaParserBasic.Function.Parameter>
    local args = {}
    ---@type table<string, Tools.DocLuaParserBasic.Function.Parameter>
    local returns = {}

    -- I am sorry
    for _, line in ipairs(lines) do
        if ParseFunctions.IsComment(line) then
            if ParseFunctions.IsParameter(line) then
                local name, type, description = ParseFunctions.ParseParameter(line)
                args[name] = { Name = name, Type = type, Description = description }
                goto continue
            elseif ParseFunctions.IsReturn(line) then
                local name, type, description = ParseFunctions.ParseReturn(line)
                returns[name] = { Name = name, Type = type, Description = description }
                goto continue
            else
                table.insert(comments, ParseFunctions.ParseComment(line))
                goto continue
            end
        elseif ParseFunctions.IsFunction(line) then
            local name, funcArgs = ParseFunctions.ParseFunction(line)
            for argName in pairs(args) do
                if not Utils.TableContains(funcArgs, argName) then
                    args[argName] = nil
                end
            end
            local func = Function.new(name, args, returns, comments)
            context:SetFunction(func)
            comments = {}
            args = {}
            returns = {}
            goto continue
        else
            comments = {}
            args = {}
            returns = {}
        end

        ::continue::
    end

    return context
end

-- ---@return Tools.DocLuaParserBasic.Context
-- function Parser:ParseFile(path)
--     -- do shit
-- end

return Parser
