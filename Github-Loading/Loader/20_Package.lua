local LoadedLoaderFiles = table.pack(...)[1]
---@type Github_Loading.Module
local Module = LoadedLoaderFiles["/Github-Loading/Loader/10_Module.lua"][1]

---@class Github_Loading.Package
---@field private PackageLoader Github_Loading.PackageLoader
---@field Name string
---@field Namespace string
---@field Version number
---@field RequiredPackages string[]
---@field Modules Dictionary<string, Github_Loading.Module>
local Package = {}


---@param info table
---@param packageData table
---@param packageLoader Github_Loading.PackageLoader
---@return Github_Loading.Package
function Package.new(info, packageData, packageLoader)
    ---@type Dictionary<string, Github_Loading.Module>
    local modules = {}
    for id, module in pairs(packageData) do
        modules[id] = Module.new(module)
    end

    local metatable = Package
    metatable.__index = Package
    return setmetatable({
        Name = info.Name,
        Namespace = info.Namesapce,
        VERSION = info.Version or 0.01,
        RequiredPackages = (info.RequiredPackages or {}),
        Modules = modules,
        PackageLoader = packageLoader
    }, metatable)
end

---@param moduleToGet string
---@return Github_Loading.Module?
function Package:GetModule(moduleToGet)
    for _, module in pairs(self.Modules) do
        if module.Namespace == moduleToGet then
            return module
        end
    end
end

function Package:Load()
    for _, packageName in ipairs(self.RequiredPackages) do
        self.PackageLoader:LoadPackage(packageName)
    end

    local eventsModule = self:GetModule(self.Namespace .. ".__events")
    if eventsModule == nil then
        return
    end

    -- ######## OnLoaded ######## --
    ---@type Github_Loading.Entities.Events
    local eventsModuleLoaded = eventsModule:Load()
    if type(eventsModuleLoaded.OnLoaded) == "function" then
        eventsModuleLoaded.OnLoaded()
    end
end

return Package
