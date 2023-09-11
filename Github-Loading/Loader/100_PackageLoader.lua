local LoadedLoaderFiles = ({ ... })[1]
---@type Github_Loading.Package
local Package = LoadedLoaderFiles["/Github-Loading/Loader/Package"][1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]


---@class Github_Loading.PackageLoader
---@field Packages Github_Loading.Package[]
---@field logger Github_Loading.Logger
---@field private packagesUrl string
---@field private packagesPath string
---@field private internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
local PackageLoader = {}

---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean
function PackageLoader:internalDownload(url, path, forceDownload)
    return Utils.DownloadToFile(url, path, forceDownload, self.internetCard, self.logger)
end

---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean, Github_Loading.Package?
function PackageLoader:internalDownloadPackage(url, path, forceDownload)
    local infoFileUrl = url .. "/Info.lua"
    local infoFilePath = filesystem.path(path, "Info.lua")
    ---@type Github_Loading.Package.InfoFile?
    local oldInfoContent = nil
    if filesystem.exists(infoFilePath) then
        oldInfoContent = filesystem.doFile(infoFilePath)
    end
    if not self:internalDownload(infoFileUrl, infoFilePath, true) then return false end

    ---@type Github_Loading.Package.InfoFile
    local infoContent = filesystem.doFile(infoFilePath)
    local differentVersionFound = false
    if oldInfoContent then
        differentVersionFound = oldInfoContent.Version ~= infoContent.Version
    end

    local forceDownloadData = differentVersionFound or forceDownload
    return true, Package.new(infoContent, forceDownloadData, self)
end

---@param packagesUrl string
---@param packagesPath string
---@param logger Github_Loading.Logger
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@return Github_Loading.PackageLoader
function PackageLoader.new(packagesUrl, packagesPath, logger, internetCard)
    assert(not (not filesystem.exists(packagesPath) and not filesystem.createDir(packagesPath)), "Unable to create folder for packages")
    local metatable = {
        __index = PackageLoader
    }
    return setmetatable({
        Packages = {},
        packagesUrl = packagesUrl,
        packagesPath = packagesPath,
        logger = logger,
        internetCard = internetCard,
    }, metatable)
end

function PackageLoader:setGlobal()
    _G.PackageLoader = self
end

---@param packageName string
---@return Github_Loading.Package?
function PackageLoader:GetPackage(packageName)
    for _, package in ipairs(self.Packages) do
        if package.Name == packageName then
            return package
        end
    end
end

---@param packageName string
---@param forceDownload boolean?
---@return boolean, Github_Loading.Package?
function PackageLoader:DownloadPackage(packageName, forceDownload)
    self.logger:LogTrace("downloading package: '" .. packageName .. "'...")
    forceDownload = forceDownload or false
    packageName = packageName:gsub("%.", "/")
    local packagePath = self.packagesPath .. "/" .. packageName
    assert(not (not filesystem.exists(packagePath) and not filesystem.createDir(packagePath, true)), "Unable to create folder for package: '" .. packageName .. "'")
    local packageUrl = self.packagesUrl .. "/" .. packageName
    local success, package = self:internalDownloadPackage(packageUrl, packagePath, forceDownload)
    if not success or not package or not package:Download(packageUrl, packagePath) then
        return false
    end
    self.logger:LogTrace("downloaded package: '" .. packageName .. "'")
    return true, package
end

---@param packageName string
---@return Github_Loading.Package
function PackageLoader:LoadPackage(packageName, forceDownload)
    self.logger:LogTrace("loading package: '" .. packageName .. "'...")
    local package = self:GetPackage(packageName)
    if package then
        self.logger:LogTrace("found package: '" .. packageName .. "'")
        return package
    end
    local success
    success, package = self:DownloadPackage(packageName, forceDownload)
    if success then
        ---@cast package Github_Loading.Package
        table.insert(self.Packages, package)
        self.logger:FreeLine(1)
        package:Load()
    else
        computer.panic("could not find or download package: '" .. packageName .. "'")
    end
    ---@cast package Github_Loading.Package
    self.logger:LogDebug("loaded package: '" .. package.Name .. "'")
    return package
end

---@param moduleToGet string
function PackageLoader:GetModule(moduleToGet)
    self.logger:LogTrace("geting module: '" .. moduleToGet .. "'")

    for _, package in ipairs(self.Packages) do
        if moduleToGet:find(package.Namespace) then
            local module = package:GetModule(moduleToGet)
            if module then
                self.logger:LogDebug("geted module: '" .. moduleToGet .. "'")
                return module
            end
        end
    end

    error("module could not be found: '" .. moduleToGet .. "'", 2)
end

---@param moduleToGet string
---@param ... any
---@return any ...
function require(moduleToGet, ...)
    if _G.PackageLoader == nil then
        computer.panic("'PackageLoader' was not set")
    end
    local module = _G.PackageLoader:GetModule(moduleToGet)
    return module:Load(...)
end

return PackageLoader
