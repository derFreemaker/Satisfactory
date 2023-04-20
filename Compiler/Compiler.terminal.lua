compilerFilesystem = require("Satisfactory.Compiler.FileSystem")
local Config = require("Compiler.CompilerConfig")

local function main(args)
    local config = Config.new(args)
    local compiler = require("Satisfactory.Compiler.Compiler").new(config:Build())
    compiler:Compile()
end

main(arg)