local FileSystem = require("Satisfactory.Compiler.FileSystem")

---@class Compiler
---@field Config CompilerConfig
---@field CurrentPath string
---@field DataFile File
local Compiler = {}
Compiler.__index = Compiler

---@param config CompilerConfig
---@return Compiler
function Compiler.new(config)
    return setmetatable({
        Config = config,
        CurrentPath = FileSystem.get_script_path() .. "../"
    }, Compiler)
end

function Compiler:compileDataFile(shortPath, path, parentFolder)
    local dataFile = FileSystem.getFile(path)
    local data = dataFile:ReadFile()
    if data == nil then
        print("data in file: '" .. path .. "' was nil")
        return
    end
    self.DataFile:Append("\n#---------------" .. shortPath .. "---------------#")
    self.DataFile:Append(data)
    self.DataFile:Append("#---------------" .. shortPath .. "---------------#\n") 
end

function Compiler:compileDataFileFolder(path)
    
end

function Compiler:compileData()
    self.DataFile = FileSystem.getFile(self.CurrentPath .. "Data.lua")
end

function Compiler:compileInfoFile()
    local infoFile = FileSystem.getFile(self.Config.Path .. "Info.lua")
    local compiledInfoFile = FileSystem.getFile(self.CurrentPath .. "Info.lua")
    local content = infoFile:ReadFile()
    if content == nil then
        error("Unable to write Info file")
    end
    compiledInfoFile:Create()
    compiledInfoFile:Write(content)
end

function Compiler:Compile()

end

return Compiler