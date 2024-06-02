local LoadedLoaderFiles = ({ ... })[1]
---@type Github_Loading.Package
local Package = LoadedLoaderFiles['/Github-Loading/Loader/Package'][1]
---@type Utils
local Utils = LoadedLoaderFiles['/Github-Loading/Loader/Utils'][1]

---@class Github_Loading.PackageLoader
---@field CurrentPackage Github_Loading.Package?
---@field Packages Github_Loading.Package[]
---@field Logger Github_Loading.Logger
---@field private m_moduleCache table<string, Github_Loading.Module?>
---@field private m_packagesUrl string
---@field private m_packagesPath string
---@field private m_internetCard FIN.InternetCard_C
local PackageLoader = {}

---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean
function PackageLoader:internalDownload(url, path, forceDownload)
	return Utils.DownloadToFile(url, path, forceDownload, self.m_internetCard, self.Logger)
end

---@param url string
---@param path string
---@param packageName string
---@param forceDownload boolean
---@return Github_Loading.Package?
function PackageLoader:internalDownloadPackage(url, path, packageName, forceDownload)
	local infoFileUrl = url .. '/Info.lua'
	local infoFilePath = filesystem.path(path, '__info.lua')

	---@type Github_Loading.Package.InfoFile?
	local oldInfoContent = nil
	if filesystem.exists(infoFilePath) then
		oldInfoContent = filesystem.doFile(infoFilePath)
	end
	if not self:internalDownload(infoFileUrl, infoFilePath, true) then
		return
	end

	---@type Github_Loading.Package.InfoFile
	local infoContent = filesystem.doFile(infoFilePath)
	local differentVersionFound = false
	if oldInfoContent then
		differentVersionFound = oldInfoContent.Version ~= infoContent.Version
	end

	local forceDownloadData = differentVersionFound or forceDownload
	return Package.new(infoContent, packageName, forceDownloadData, self)
end

---@param packagesUrl string
---@param packagesPath string
---@param logger Github_Loading.Logger
---@param internetCard FIN.InternetCard_C
---@return Github_Loading.PackageLoader
function PackageLoader.new(packagesUrl, packagesPath, logger, internetCard)
	assert(not (not filesystem.exists(packagesPath) and not filesystem.createDir(packagesPath)),
		'Unable to create folder for packages')
	return setmetatable(
		{
			Packages = {},
			Logger = logger,
			m_moduleCache = {},
			m_packagesUrl = packagesUrl,
			m_packagesPath = packagesPath,
			m_internetCard = internetCard
		},
		{ __index = PackageLoader }
	)
end

---@param package Github_Loading.Package
function PackageLoader:SetCurrentPackage(package)
	self.CurrentPackage = package
end

function PackageLoader:SetGlobal()
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
---@return Github_Loading.Package?, boolean fromCache
function PackageLoader:LoadPackage(packageName, forceDownload)
	self.Logger:LogTrace("loading package: '" .. packageName .. "'...")

	local package = self:GetPackage(packageName)
	if package then
		self.Logger:LogTrace("found package: '" .. packageName .. "'")
		return package, true
	end

	forceDownload = forceDownload or false
	packageName = packageName:gsub('%.', '/')

	local packagePath = self.m_packagesPath .. '/' .. packageName
	assert(not (not filesystem.exists(packagePath) and not filesystem.createDir(packagePath, true)),
		"Unable to create folder for package: '" .. packageName .. "'")

	local packageUrl = self.m_packagesUrl .. '/' .. packageName
	package = self:internalDownloadPackage(packageUrl, packagePath, packageName, forceDownload)
	if not package then
		return nil, false
	end

	table.insert(self.Packages, package)

	self.Logger:LogTrace("loaded package: '" .. packageName .. "'")
	return package, false
end

---@param packageName string
---@param forceDownload boolean?
---@return Github_Loading.Package
function PackageLoader:DownloadPackage(packageName, forceDownload)
	self.Logger:LogTrace("downloading package: '" .. packageName .. "'...")

	local package, fromCache = self:LoadPackage(packageName, forceDownload)
	if not package or not package:Download(self.m_packagesUrl, self.m_packagesPath) then
		computer.panic("could not download package: '" .. packageName .. "'")
	end
	---@cast package Github_Loading.Package

	if not fromCache then
		package:Load()
	end

	self.Logger:LogDebug("downloaded package: '" .. package.Name .. "'")
	return package
end

---@param moduleToGet string
---@return Github_Loading.Module
function PackageLoader:GetModule(moduleToGet)
	self.Logger:LogTrace("getting module: '" .. moduleToGet .. "'")

	local module = self.m_moduleCache[moduleToGet]
	if module then
		self.Logger:LogDebug("got module: '" .. moduleToGet .. "' from cache")
		return module
	end

	for _, package in ipairs(self.Packages) do
		module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("got module: '" .. moduleToGet .. "'")
			self.m_moduleCache[moduleToGet] = module
			return module
		end
	end

	self.Logger:LogDebug("module could not be found: '" .. moduleToGet .. "'")

	moduleToGet = moduleToGet .. ".init"

	for _, package in ipairs(self.Packages) do
		module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("got module: '" .. moduleToGet .. "'")
			self.m_moduleCache[moduleToGet] = module
			return module
		end
	end

	error("module could not be found: '" .. moduleToGet .. "'")
end

---@param moduleToGet string
---@param outModule Out<Github_Loading.Module>
function PackageLoader:TryGetModule(moduleToGet, outModule)
	self.Logger:LogTrace("try got module: '" .. moduleToGet .. "'")

	for _, package in ipairs(self.Packages) do
		local module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("try got module: '" .. moduleToGet .. "'")
			outModule.Value = module
			return true
		end
	end

	return false
end

function PackageLoader:OnLoaded()
	for _, package in pairs(self.Packages) do
		package:OnLoaded()
	end
end

---@param moduleToGet string
---@return any ...
function require(moduleToGet)
	if _G.PackageLoader == nil then
		computer.panic("'PackageLoader' was not set")
	end
	local module = _G.PackageLoader:GetModule(moduleToGet)
	return module:Load()
end

return PackageLoader
