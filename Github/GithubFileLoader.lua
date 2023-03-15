local version = "1.0.6"

local FileLoader = {}
FileLoader.__index = FileLoader

FileLoader.logger = {}
FileLoader.requests = {}
FileLoader.basePath = ""

function FileLoader.new(logger)
    local instance = setmetatable({}, FileLoader)
	instance.logger = logger
	return instance
end

local function checkEntry(entry)
    if entry.Name == nil then
		if entry.FullName ~= nil then
        	entry.Name = entry.FullName
		else
			entry.Name = entry[1]
		end
	end

	if entry.FullName == nil then
		entry.FullName = entry.Name
	end

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

	if entry.IgnoreDownload == true then
		entry.IgnoreDownload = true
	else
		entry.IgnoreDownload = false
	end

	if entry.IgnoreLoad == true then
		entry.IgnoreLoad = true
	else
		entry.IgnoreLoad = false
	end

	local checkedEntry = {
		Name = entry.Name,
		FullName = entry.FullName,
		IsFolder = entry.IsFolder,
		IgnoreDownload = entry.IgnoreDownload,
		IgnoreLoad = entry.IgnoreLoad
	}

	if entry.IsFolder and not entry.IgnoreLoad then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkEntry(child))
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
			checkedEntry.FullName = entry.FullName..".lua"
	 	end
	end

	return checkedEntry
end

function FileLoader:requestFile(url, path)
	self.logger:LogTrace("Requests file '" .. path .. "' from '" .. url .. "'")
	if filesystem.exists(path) then
		self.logger:LogTrace("Found requested file '"..path.."'")
		return
	end
	local request = InternetCard:request(url, "GET", "")
	table.insert(self.requests, {
		request = request,
		func = function(req)
			self.logger:LogTrace("downloading file '"..path.."'")
			local code, data = req:get()
			local file = filesystem.open(path, "w")
			if code ~= 200 or not data then
				self.logger:LogError("Unable to request file '" .. path .. "' from '" .. url .. "'")
				return false
			end
			file:write(data)
			file:close()
			self.logger:LogTrace("downloaded file")
			return true
		end
	})
end

function FileLoader:doEntry(parentPath, entry, force)
	if entry.IgnoreDownload == true then return end
	if entry.IsFolder == true then
		self:doFolder(parentPath, entry, force)
	else
		self:doFile(parentPath, entry, force)
	end
end

function FileLoader:doFile(parentPath, file, force)
	local path = filesystem.path(parentPath, file.FullName)
	if not filesystem.exists(path) or force then
		self:requestFile(self.basePath .. path, path)
	end
end

function FileLoader:doFolder(parentPath, folder, force)
	local path = filesystem.path(parentPath, folder.FullName)
	filesystem.createDir(path)
	for _, child in pairs(folder.Childs) do
		if type(child) == "table" then
			self:doEntry(path, child, force)
		end
	end
end

function FileLoader:loadFiles()
	if #self.requests > 0 then
		self.logger:LogDebug("downloading program files...")
	end
	local downloadedFiles = false
    while #self.requests > 0 do
        local i = 1
        while i <= #self.requests do
            local request = self.requests[i]
            if request.request:canGet() then
                table.remove(self.requests, i)
                local done = request.func(request.request)
                if not done then
                    computer.beep(0.2)
                    return false
                end
				downloadedFiles = true
            end
            i = i + 1
        end
    end
	if downloadedFiles then
		self.logger:LogInfo("downloaded program files")
	end
	return true
end

function FileLoader:requestFileTree(tree, force)
    self:doFolder("", checkEntry(tree), force)
end

function FileLoader:DownloadFileTree(basePath, tree, force)
	self.logger:LogDebug("Github File Loader Version: "..version)
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