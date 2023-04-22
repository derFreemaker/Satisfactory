local Module = require("Satisfactory.Compiler.Module")

---@class Bundler
---@field Config BundlerConfig
---@field CurrentPath string
---@field DataFile File
local Bundler = {}
Bundler.__index = Bundler

---@param config BundlerConfig
---@return Bundler
function Bundler.new(config)
    return setmetatable({
        Config = config,
        CurrentPath = compilerFilesystem.get_script_path() .. "../"
    }, Bundler)
end

---@private
---@return string
local function generateRandomUUID()
    local random = math.random(os.time())
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local uuid = string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
    return uuid
end

---@private
---@param str string
---@param sep string
---@return string[]
local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

---@private
---@param path string
function Bundler:compileModule(filePath, path)
    self.DataFile = compilerFilesystem.getFile(filePath)

    local uuid = generateRandomUUID()

    local splittedPath = split(path:gsub("\\", "/"), "/")
    local fullName = splittedPath[#splittedPath]

    local module = Module.new(uuid, filePath, path, fullName, split(fullName, ".")[1])

    local compiledModule = module:Compile(self);
    self.DataFile:Append(compiledModule)
end

function Bundler:compileInfoFile()
    local infoFile = compilerFilesystem.getFile(self.Config.Path .. "Info.lua")
    local compiledInfoFile = compilerFilesystem.getFile(self.CurrentPath .. "Info.lua")
    local content = infoFile:ReadFile()
    if content == nil or content == "" or content == " " then
        error("Info file has no content")
    end
    compiledInfoFile:Create()
    compiledInfoFile:Write(content)
end

function Bundler:Compile()

end

return Bundler