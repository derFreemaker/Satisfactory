local LoadedLoaderFiles = table.pack(...)[1]
---@type Github_Loading.Package
local Package = LoadedLoaderFiles["/Github-Loading/Loader/Package"][1]

---@class Github_Loading.PackageLoader
---@field Packages Github_Loading.Package[]
---@field private packagesUrl string
---@field private packagesPath string
---@field private logger Github_Loading.Logger
---@field private internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
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
    self.logger:LogTrace("downloading '" .. path .. "' from: '" .. url .. "'...")
    local req = self.internetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or data == nil then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    self.logger:LogTrace("downloaded '" .. path .. "' from: '" .. url .. "'")
    return true
end

---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean, Github_Loading.Package?
function PackageLoader:internalDownloadPackage(url, path, forceDownload)
    local infoFileUrl = url .. "/Info.lua"
    local infoFilePath = filesystem.path(path, "Info.lua")
    if not self:internalDownload(infoFileUrl, infoFilePath, forceDownload) then return false end

    local dataFileUrl = url .. "/Data.lua"
    local dataFilePath = filesystem.path(path, "Data.lua")
    if not self:internalDownload(dataFileUrl, dataFilePath, forceDownload) then return false end

    local infoContent = filesystem.doFile(infoFilePath)
    local dataContent = filesystem.doFile(dataFilePath)

    return true, Package.new(infoContent, dataContent, self)
end

---@param packagesUrl string
---@param packagesPath string
---@param logger Github_Loading.Logger
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@return Github_Loading.PackageLoader
function PackageLoader.new(packagesUrl, packagesPath, logger, internetCard)
    assert(not (not filesystem.exists(packagesPath) and not filesystem.createDir(packagesPath)), 
            "Unable to create folder for packages")
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
    local path = self.packagesPath .. "/" .. packageName
    assert(not (not filesystem.exists(path) and not filesystem.createDir(path, true)), "Unable to create folder for package: '" .. packageName .. "'")
    local success, package = self:internalDownloadPackage(self.packagesUrl .. "/" .. packageName, path, forceDownload)
    if not success or not package then
        return false
    end
    self.logger:LogTrace("downloaded package: '" .. packageName .. "'")
    return true, package
end

---@param packageName string
---@return Github_Loading.Package
function PackageLoader:LoadPackage(packageName, forceDownload)
    self.logger:LogDebug("loading package: '" .. packageName .. "'...")
    local package = self:GetPackage(packageName)
    if package then
        self.logger:LogDebug("found package: '" .. packageName .. "'")
        return package
    end

    local success, package = self:DownloadPackage(packageName, forceDownload)
    if success then
        ---@cast package Github_Loading.Package
        table.insert(self.Packages, package)
        self.logger:LogDebug("")
        self.logger:LogDebug("loading required packages: ".. #package.RequiredPackages .."...")
        package:Load()
        self.logger:LogDebug("loaded required packages")
    else
        computer.panic("could not find or download package: '" .. packageName .. "'")
    end
    ---@cast package Github_Loading.Package
    self.logger:LogDebug("loaded package: '" .. package.Name .. "'")
    return package
end

---@param moduleToGet string
function PackageLoader:GetModule(moduleToGet)
    self.logger:LogDebug("geting module: '" .. moduleToGet .. "'")
    local namespace = moduleToGet:find([[^(.+)\.+]])
    for _, package in ipairs(self.Packages) do
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
