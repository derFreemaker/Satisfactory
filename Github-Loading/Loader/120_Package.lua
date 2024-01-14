local LoadedLoaderFiles = ({ ... })[1]
---@type Github_Loading.Module
local Module = LoadedLoaderFiles["/Github-Loading/Loader/Module"][1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Package.InfoFile
---@field Name string
---@field Namespace string
---@field Version string
---@field PackageType "Library" | "Application"
---@field RequiredPackages string[]?
---@field ModuleIndex table<string, Github_Loading.Module.Info>

---@class Github_Loading.Package
---@field Name string
---@field Namespace string
---@field Location string
---@field Version string
---@field PackageType "Library" | "Application"
---@field RequiredPackages string[]?
---@field Modules table<string, Github_Loading.Module>
---@field m_forceDownload boolean
---@field m_packageLoader Github_Loading.PackageLoader
local Package = {}

---@param info Github_Loading.Package.InfoFile
---@param location string
---@param forceDownload boolean
---@param packageLoader Github_Loading.PackageLoader
---@return Github_Loading.Package
function Package.new(info, location, forceDownload, packageLoader)
    local instance = setmetatable({
        Name = info.Name,
        Namespace = info.Namespace,
        Location = location,
        Version = info.Version or 0.01,
        PackageType = info.PackageType,
        RequiredPackages = info.RequiredPackages,
        m_forceDownload = forceDownload,
        m_packageLoader = packageLoader,
        Modules = {}
    }, { __index = Package })

    for id, moduleInfo in pairs(info.ModuleIndex) do
        instance.Modules[id] = Module.new(moduleInfo, instance)
    end

    return instance
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

---@param packagesUrl string
---@param packagesPath string
---@return boolean success
function Package:Download(packagesUrl, packagesPath)
    local packageUrl = packagesUrl .. "/" .. self.Location
    local packagePath = packagesPath .. "/" .. self.Location
    local dataFileUrl = packageUrl .. "/Data.lua"
    local dataFilePath = filesystem.path(packagePath, "__data.lua")

    if not self.m_packageLoader:internalDownload(dataFileUrl, dataFilePath, self.m_forceDownload) then
        return false
    end

    ---@type table<string, string>
    local data = filesystem.doFile(dataFilePath)

    for id, value in pairs(data) do
        self.Modules[id].Data = value
    end

    --- clear data
    ---@diagnostic disable-next-line
    data = nil

    return true
end

function Package:Load()
    if self.RequiredPackages and #self.RequiredPackages ~= 0 then
        local log = "loading required packages:"
            .. " (" .. #self.RequiredPackages .. ") "
            .. Utils.String.Join(self.RequiredPackages, ";")
            .. " ..."

        self.m_packageLoader.Logger:LogDebug(log)

        for _, packageName in ipairs(self.RequiredPackages) do
            self.m_packageLoader:DownloadPackage(packageName)
        end

        self.m_packageLoader.Logger:LogDebug("loaded required packages")
    end
end

function Package:OnLoaded()
    local eventsModule = self:GetModule(self.Namespace .. ".__events")
    if eventsModule == nil then
        return
    end

    ---@type Github_Loading.Entities.Events?
    local eventsModuleLoaded = eventsModule:Load()
    if not eventsModuleLoaded then
        return
    end

    -- ######## OnLoaded ######## --
    if type(eventsModuleLoaded.OnLoaded) == "function" then
        eventsModuleLoaded:OnLoaded()
    end
end

return Package
