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
---@field private m_internetCard FIN.Components.FINComputerMod.InternetCard_C
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
---@param forceDownload boolean
---@return boolean, Github_Loading.Package?
function PackageLoader:internalDownloadPackage(url, path, forceDownload)
	local infoFileUrl = url .. '/Info.lua'
	local infoFilePath = filesystem.path(path, 'Info.lua')
	---@type Github_Loading.Package.InfoFile?
	local oldInfoContent = nil
	if filesystem.exists(infoFilePath) then
		oldInfoContent = filesystem.doFile(infoFilePath)
	end
	if not self:internalDownload(infoFileUrl, infoFilePath, true) then
		return false
	end

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
---@param internetCard FIN.Components.FINComputerMod.InternetCard_C
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
---@return boolean, Github_Loading.Package?
function PackageLoader:DownloadPackage(packageName, forceDownload)
	self.Logger:LogTrace("downloading package: '" .. packageName .. "'...")

	forceDownload = forceDownload or false
	packageName = packageName:gsub('%.', '/')

	local packagePath = self.m_packagesPath .. '/' .. packageName
	assert(not (not filesystem.exists(packagePath) and not filesystem.createDir(packagePath, true)),
		"Unable to create folder for package: '" .. packageName .. "'")

	local packageUrl = self.m_packagesUrl .. '/' .. packageName
	local success, package = self:internalDownloadPackage(packageUrl, packagePath, forceDownload)
	if not success or not package or not package:Download(packageUrl, packagePath) then
		return false
	end

	self.Logger:LogTrace("downloaded package: '" .. packageName .. "'")
	return true, package
end

---@param packageName string
---@return Github_Loading.Package
function PackageLoader:LoadPackage(packageName, forceDownload)
	self.Logger:LogTrace("loading package: '" .. packageName .. "'...")

	local package = self:GetPackage(packageName)
	if package then
		self.Logger:LogTrace("found package: '" .. packageName .. "'")
		return package
	end

	local success
	success, package = self:DownloadPackage(packageName, forceDownload)
	if success then
		---@cast package Github_Loading.Package
		table.insert(self.Packages, package)
		package:Load()
	else
		computer.panic("could not find or download package: '" .. packageName .. "'")
	end

	---@cast package Github_Loading.Package
	self.Logger:LogDebug("loaded package: '" .. package.Name .. "'")
	return package
end

---@param moduleToGet string
---@return Github_Loading.Module
function PackageLoader:GetModule(moduleToGet)
	self.Logger:LogTrace("geting module: '" .. moduleToGet .. "'")

	local module = self.m_moduleCache[moduleToGet]
	if module then
		self.Logger:LogDebug("geted module: '" .. moduleToGet .. "' from cache")
		return module
	end

	for _, package in ipairs(self.Packages) do
		module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("geted module: '" .. moduleToGet .. "'")
			self.m_moduleCache[moduleToGet] = module
			return module
		end
	end

	moduleToGet = moduleToGet .. ".init"

	for _, package in ipairs(self.Packages) do
		module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("geted module: '" .. moduleToGet .. "'")
			self.m_moduleCache[moduleToGet] = module
			return module
		end
	end

	error("module could not be found: '" .. moduleToGet .. "'")
end

---@param moduleToGet string
---@param outModule Out<Github_Loading.Module>
function PackageLoader:TryGetModule(moduleToGet, outModule)
	self.Logger:LogTrace("try geting module: '" .. moduleToGet .. "'")

	for _, package in ipairs(self.Packages) do
		local module = package:GetModule(moduleToGet)
		if module then
			self.Logger:LogDebug("try geted module: '" .. moduleToGet .. "'")
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
