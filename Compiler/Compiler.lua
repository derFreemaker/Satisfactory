---@class Compiler
local Compiler = {}
Compiler.__index = Compiler

---@param config CompilerConfig
---@return Compiler
function Compiler.new(config)
    return setmetatable({
        Config = config
    }, Compiler)
end

function Compiler:Compile()

end

return Compiler