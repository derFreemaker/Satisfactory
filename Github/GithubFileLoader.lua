local version = "1.0.6"

local FileLoader = {}
FileLoader.__index = FileLoader

FileLoader._logger = {}
FileLoader._requests = {}
FileLoader._basePath = ""

function FileLoader.new(logger)
    local instance = setmetatable({}, FileLoader)
	instance._logger = logger:create("FileDownloader")
	return instance
end

local function checkEntry(entry, parentPath)
	parentPath = (parentPath or "")

	if entry.Name == nil then
		if entry.FullName ~= nil then
			entry.Name = entry.FullName
		else
			entry.Name = entry[1]
		end
	end

	entry.FullName = (entry.FullName or entry.Name)

	if entry.IsFolder == nil then
		local childs = 0
		for _, child in pairs(entry) do
			if type(child) == "table" then
				childs = childs + 1
			end
		end
		if childs == 0 then
			entry.IsFolder = false
		else
			entry.IsFolder = true
		end
	end

	entry.IgnoreDownload = (entry.IgnoreDownload or false)
	entry.IgnoreLoad = (entry.IgnoreDownload or false)
	entry.Path = (entry.Path or parentPath .. entry.FullName)

	local checkedEntry = {
		Name = entry.Name,
		FullName = entry.FullName,
		IsFolder = entry.IsFolder,
		IgnoreDownload = entry.IgnoreDownload,
		IgnoreLoad = entry.IgnoreLoad,
		Path = entry.Path
	}

	if entry.IsFolder and not entry.IgnoreLoad then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkEntry(child, checkedEntry.Path))
			end
		end
		checkedEntry.Childs = childs
	else
		local nameLength = entry.Name:len()
		if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
			checkedEntry.Name = entry.Name:sub(0, nameLength - 4)
		end
		nameLength = entry.FullName:len()
		if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
			checkedEntry.FullName = entry.FullName .. ".lua"
		end
	end

	return checkedEntry
end

function FileLoader:requestFile(url, path)
	self._logger:LogTrace("request file '"..path.."' from '"..url.."'")
	if filesystem.exists(path) then
		self._logger:LogTrace("found requested file '"..path.."'")
		return
	end
	local request = InternetCard:request(url, "GET", "")
	table.insert(self._requests, {
		Request = request,
		Path = path,
		Url = url
	})
end

function FileLoader:doEntry(entry, force)
	if entry.IgnoreDownload == true then return end
	if entry.IsFolder == true then
		self:doFolder(entry, force)
	else
		self:doFile(entry, force)
	end
end

function FileLoader:doFile(file, force)
	if not filesystem.exists(file.Path) or force then
		self:requestFile(self._basePath .. file.Path, file.Path)
	end
end

function FileLoader:doFolder(folder, force)
	filesystem.createDir(folder.Path)
	for _, child in pairs(folder.Childs) do
		if type(child) == "table" then
			self:doEntry(child, force)
		end
	end
end

function  FileLoader:loadFile(req)
	self._logger:LogTrace("downloading file: '" .. req.Path .. "'...")
	local code, data = req.Request:get()
	if code ~= 200 or not data then
		self._logger:LogError("unable to request file '" .. req.Path .. "' from '" .. req.Url .. "'")
		return false
	end
	Utils.WriteToFile(req.Path, "w", data)
	self._logger:LogDebug("downloaded file: '" .. req.Path .. "'")
	return true
end

function FileLoader:loadFiles()
	self._logger:LogDebug("loading program files...")
    while #self._requests > 0 do
        local i = 1
        while i <= #self._requests do
			local done = false
            local request = self._requests[i]
            if request.Request:canGet() then
                done = self:loadFile(request)
            end
			if done then
				table.remove(self._requests, i)
			end
            i = i + 1
        end
    end
	self._logger:LogInfo("loaded program files")
	return true
end

function FileLoader:requestFileTree(tree, force)
    self:doFolder(checkEntry(tree), force)
end

function FileLoader:DownloadFileTree(basePath, tree, force)
	self._logger:LogDebug("Github File Loader Version: "..version)
	if basePath == nil then return false end
	if tree == nil then
		self._logger:LogDebug("download tree was empty")
		return true
	end
	if force == nil then force = false end
	self._basePath = basePath
	self:requestFileTree(tree, force)
	return self:loadFiles()
end

return FileLoader