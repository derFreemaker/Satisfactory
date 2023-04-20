---@class Module
---@field private filePath string
---@field Path string
---@field FullName string
---@field Name string
local Module = {}
Module.__index = Module

---@param path string
---@return Module
function Module.new(filePath, path, fullName, name)
    return setmetatable({
        filePath = filePath,
        Path = path,
        FullName = fullName,
        Name = name
    }, Module)
end

---@return string
function Module:Compile()
    local file = compilerFilesystem.getFile(self.filePath)

    return "\n\n\n"
        + "#-------------------- " + self.Name + " --------------------#\n"

        + "FullName: " + self.FullName + "\n"
        + "Path: " + self.Path + "\n"

        + "function Modules." + self.Path:gsub(".lua", ""):gsub("/", "."):gsub("\\", ".") + ".GetModule()\n"
        + "    return loadstring(\"" + file:ReadFile():gsub("\n", "") + "\")\n"
        + "end"

        + "#-------------------- " + self.Name + " --------------------#\n"
end

return Module