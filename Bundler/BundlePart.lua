---@class Module
---@field private filePath string
---@field UUID string
---@field Path string
---@field FullName string
---@field Name string
local Module = {}
Module.__index = Module

---@param path string
---@return Module
function Module.new(uuid, filePath, path, fullName, name)
    return setmetatable({
        filePath = filePath,
        UUID = uuid,
        Path = path,
        FullName = fullName,
        Name = name
    }, Module)
end

---@param compiler Compiler
---@return string
function Module:Compile(compiler)
    local file = compilerFilesystem.getFile(self.filePath)

    return "\n\n\n"
        .. "#-------------------- " .. self.Name .. " --------------------#\n"

        .. "FullName: " .. self.FullName .. "\n"
        .. "Path: " .. self.Path .. "\n"

        .. "function Modules." .. self.UUID .. ".GetModule()\n"
        .. "    return loadstring(\"" .. file:ReadFile():gsub("\n", "") .. "\")\n"
        .. "end"

        .. "#-------------------- " .. self.Name .. " --------------------#\n"
end

return Module