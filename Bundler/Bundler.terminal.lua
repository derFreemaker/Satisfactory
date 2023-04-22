compilerFilesystem = require("Satisfactory.Bundler.FileSystem")
local Config = require("Compiler.BundlerConfig")

local function main(args)
    local config = Config.new(args)
    local compiler = require("Satisfactory.Bundler.Bundler").new(config:Build())
    compiler:Compile()
end

main(arg)