---@class Module
---@field Name string
---@field FullName string
---@field Namespace string
---@field IsRunnable boolean
---@field Data string
local Module = {}
Module.__index = Module

---@param moduleData table
---@return Module
function Module.new(moduleData)
    return setmetatable({
        Namespace = moduleData.Namespace,
        Name = moduleData.Name,
        FullName = moduleData.FullName,
        IsRunnable = moduleData.IsRunnable,
        Data = moduleData.Data
    }, Module)
end

---@return table | string
function Module:GetData()
    if self.IsRunnable then
        return load(self.Data)()
    end
    return self.Data
end

-- ########## Module ########## --

---@class Package
---@field private PackageLoader PackageLoader
---@field Name string
---@field Namespace string
---@field RequiredPackages Array<string>
---@field Modules Dictionary<Module>
local Package = {}
Package.__index = Package

---@param info table
---@param packageData table
---@param packageLoader PackageLoader
---@return Package
function Package.new(info, packageData, packageLoader)
    ---@type Dictionary<Module>
    local modules = {}
    for id, module in pairs(packageData) do
        modules[id] = module
    end

    return setmetatable({
        Name = info.Name,
        Namespace = info.Namesapce,
        RequiredPackages = info.RequiredPackages,
        Modules = modules,
        PackageLoader = packageLoader
    }, Package)
end

---@param moduleToGet string
---@return Module | nil
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
end

-- ########## Package ########## --

---@class PackageLoader
---@field private packagesUrl string
---@field private packagesPath string
---@field private logger Logger
---@field private internetCard table
---@field Packages Array<Package>
local PackageLoader = {}

---@private
---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean
function PackageLoader:internalDownload(url, path, forceDownload)
    if forceDownload == nil then forceDownload = false end
    if filesystem.exists(path) and not forceDownload then
        return true
    end
    if self.logger ~= nil then
        self.logger:LogTrace("downloading '" .. path .. "' from: '" .. url .. "'...")
    end
    local req = self.internetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or data == nil then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    if self.logger ~= nil then
        self.logger:LogTrace("downloaded '" .. path .. "' from: '" .. url .. "'")
    end
    return true
end

---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean, Package | nil
function PackageLoader:internalDownloadPackage(url, path, forceDownload)
    local infoFileUrl = url .. "/Info.lua"
    local infoFilePath = filesystem.combinePaths(path, "Info.lua")
    local dataFileUrl = url .. "/Data.lua"
    local dataFilePath = filesystem.combinePaths(path, "Data.lua")

    if not filesystem.exists(path) then
        filesystem.createDir(path)
    end

    if not self:internalDownload(infoFileUrl, infoFilePath, forceDownload) then return false end
    if not self:internalDownload(dataFileUrl, dataFilePath, forceDownload) then return false end

    local infoContent = Utils.File.Read(infoFilePath)
    local dataContent = Utils.File.Read(dataFilePath)

    return true, Package.new(load(infoContent)(), load(dataContent)(), self)
end

---@param packagesUrl string
---@param packagesPath string
---@param logger Logger
function PackageLoader.new(packagesUrl, packagesPath, logger)
    return setmetatable({
        packagesUrl = packagesUrl,
        packagesPath = packagesPath,
        logger = logger,
        Packages = {}
    }, PackageLoader)
end

---@param packageName string
---@param forceDownload boolean | nil
---@return boolean, Package | nil
function PackageLoader:DownloadPackage(packageName, forceDownload)
    self.logger:LogDebug("downloading package: '" .. packageName .. "'...")
    forceDownload = forceDownload or false
    local path = filesystem.combinePaths(self.packagesPath, packageName)
    local success, package = self:internalDownloadPackage(self.packagesUrl .. "/" .. packageName, path, forceDownload)
    if not success or not package then
        return false
    end
    self.logger:LogDebug("downloaded package: '" .. packageName .. "'")
    return true, package
end

---@param packageName string
---@return Package | nil
function PackageLoader:GetPackage(packageName)
    for _, package in ipairs(self.Packages) do
        if package.Name == packageName then
            return package
        end
    end
end

---@param packageName string
---@return Package
function PackageLoader:LoadPackage(packageName, forceDownload)
    self.logger:LogDebug("loading package: '" .. packageName .. "'...")
    local package = self:GetPackage(packageName)
    if package then
        self.logger:LogDebug("found package: '" .. packageName .. "'")
        package:Load()
        return package
    end

    local success, package = self:DownloadPackage(packageName, forceDownload)
    if not success then
        computer.panic("could not find or download package: '" .. packageName .. "'")
    end
    ---@cast package Package
    return package
end

function PackageLoader:GetModule(moduleToGet)
    self.logger:LogDebug("geting module: '" .. moduleToGet .. "'")
    local namespace = moduleToGet:find([[^(.+)\.+]])
    for _, package in ipairs(PackageLoader.Packages) do
        if (package.Namespace) == namespace then
            local module = package:GetModule(moduleToGet)
            if module then
                self.logger:LogDebug("geted module: '" .. moduleToGet .. "'")
                return module
            end
        end
    end

    error("module could not be found: '" .. moduleToGet .. "'")
end

---@param moduleToGet string
---@return table | string
function require(moduleToGet)
    local module = PackageLoader.GetModule(PackageLoader, moduleToGet)
    return module:GetData()
end

return PackageLoader
