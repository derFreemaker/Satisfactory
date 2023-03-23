---@class Request
---@field Url string
---@field Path string
---@field Request table
---@field Try number
local Request = {}
Request.__index = Request

---@param url string
---@param path string
---@param request table
---@return Request
function Request.new(url, path, request)
	return setmetatable({
		Url = url,
		Path = path,
		Request = request,
		Try = 0
	}, Request)
end

---@param logger Logger
---@return boolean
function Request:LoadFile(logger)
	logger:LogTrace("downloading file: '" .. self.Path .. "'...")
	local code, data = self.Request:get()
	if code ~= 200 or not data then
		self.Try = self.Try + 1
		logger:LogError("unable to request file '" .. self.Path .. "' from '" .. self.Url .. "'")
		return false
	end
	Utils.File.Write(self.Path, "w", data)
	logger:LogTrace("downloaded file: '" .. self.Path .. "'")
	return true
end


---@class GithubFileLoader
---@field requests Request[]
---@field basePath string
---@field logger Logger
local FileLoader = {}
FileLoader.__index = FileLoader

---@private
---@param logger Logger
---@return GithubFileLoader
function FileLoader.new(logger)
    return setmetatable({
		requests = {},
		basePath = "",
		logger = logger:create("FileDownloader")
	}, FileLoader)
end

---@private
---@param url string
---@param path string
function FileLoader:requestFile(url, path)
	self.logger:LogTrace("request file '"..path.."' from '"..url.."'")
	if filesystem.exists(path) then
		self.logger:LogTrace("found requested file '"..path.."'")
		return
	end
	local request = InternetCard:request(url, "GET", "")
	table.insert(self.requests, Request.new(url, path, request))
end

---@private
---@param entry Entry
---@param force boolean
function FileLoader:doEntry(entry, force)
	if entry.IgnoreDownload == true then return end
	if entry.IsFolder == true then
		self:doFolder(entry, force)
	else
		self:doFile(entry, force)
	end
end

---@private
---@param fileEntry Entry
---@param force boolean
function FileLoader:doFile(fileEntry, force)
	if not filesystem.exists(fileEntry.Path) or force then
		self:requestFile(self.basePath .. fileEntry.Path, fileEntry.Path)
	end
end

---@private
---@param folderEntry Entry
---@param force boolean
function FileLoader:doFolder(folderEntry, force)
	filesystem.createDir(folderEntry.Path)
	for _, child in pairs(folderEntry.Childs) do
		if type(child) == "table" then
			self:doEntry(child, force)
		end
	end
end

---@private
---@return boolean
function FileLoader:loadFiles()
	self.logger:LogTrace("loading program files...")
    while #self.requests > 0 do
        local i = 1
        while i <= #self.requests do
			local done = false
            local request = self.requests[i]
            if request.Request:canGet() then
                done = request:LoadFile(self.logger)
				if request.Try == 5 then
					computer.panic("could not load requested file")
				end
			end
			if done then
				table.remove(self.requests, i)
			end
            i = i + 1
        end
    end
	self.logger:LogInfo("loaded program files")
	return true
end

---@private
---@param tree Entry
---@param force boolean
function FileLoader:requestFileTree(tree, force)
    self:doFolder(tree, force)
end

---@param basePath string
---@param tree Entry
---@param force boolean
---@return boolean
function FileLoader:DownloadFileTree(basePath, tree, force)
	if basePath == nil then return false end
	if tree == nil then
		self.logger:LogDebug("download tree was empty")
		return true
	end
	if force == nil then force = false end
	self.basePath = basePath
	self:requestFileTree(tree, force)
	return self:loadFiles()
end

return FileLoader