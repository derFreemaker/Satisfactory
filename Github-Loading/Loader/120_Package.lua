local LoadedLoaderFiles = ({ ... })[1]
---@type Github_Loading.Module
local Module = LoadedLoaderFiles["/Github-Loading/Loader/Module"][1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Package.InfoFile
---@field Name string
---@field Namespace string
---@field Version string
---@field RequiredPackages string[]?

---@class Github_Loading.Package : Github_Loading.Package.InfoFile
---@field private m_forceDownload boolean
---@field private m_packageLoader Github_Loading.PackageLoader
---@field Modules table<string, Github_Loading.Module>
local Package = {}

---@param info Github_Loading.Package.InfoFile
---@param forceDownload boolean
---@param packageLoader Github_Loading.PackageLoader
---@return Github_Loading.Package
function Package.new(info, forceDownload, packageLoader)
    return setmetatable({
        Name = info.Name,
        Namespace = info.Namespace,
        Version = info.Version or 0.01,
        RequiredPackages = info.RequiredPackages,
        m_forceDownload = forceDownload,
        m_packageLoader = packageLoader
    }, { __index = Package })
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

---@param url string
---@param path string
---@return boolean success
function Package:Download(url, path)
    local dataFileUrl = url .. "/Data.lua"
    local dataFilePath = filesystem.path(path, "Data.lua")
    if not self.m_packageLoader:internalDownload(dataFileUrl, dataFilePath, self.m_forceDownload) then return false end

    ---@type table<string, Github_Loading.Module.Data>
    local dataContent = filesystem.doFile(dataFilePath)

    ---@type table<string, Github_Loading.Module>
    local modules = {}
    for id, module in pairs(dataContent) do
        modules[id] = Module.new(module)
    end

    self.Modules = modules
    return true
end

function Package:Load()
    if self.RequiredPackages and #self.RequiredPackages ~= 0 then
        self.m_packageLoader.Logger:LogDebug("loading required packages: " .. #self.RequiredPackages .. "...")
        for _, packageName in ipairs(self.RequiredPackages) do
            if not Utils.String.IsNilOrEmpty(packageName) then
                self.m_packageLoader:LoadPackage(packageName)
            end
        end
        self.m_packageLoader.Logger:LogDebug("loaded required packages")
    end

    local eventsModule = self:GetModule(self.Namespace .. ".__events")
    if eventsModule == nil then
        return
    end

    ---@type Github_Loading.Entities.Events
    local eventsModuleLoaded = eventsModule:Load()

    -- ######## OnLoaded ######## --
    if type(eventsModuleLoaded.OnLoaded) == "function" then
        eventsModuleLoaded:OnLoaded()
    end
end

return Package
