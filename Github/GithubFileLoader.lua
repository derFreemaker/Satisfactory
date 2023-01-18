local version = "1.0.3"

local FileLoader = {}
FileLoader.__index = FileLoader

function FileLoader.new(logger)
    local instace = setmetatable({}, FileLoader)
	instace.logger = logger
	return instace
end

FileLoader.logger = {}
FileLoader.requests = {}
FileLoader.basePath = ""

local function checkTree(entry)
    if entry.Name == nil and entry.FullName ~= nil then
        entry.Name = entry.FullName
    else
        entry.Name = entry.Name
	end

	if entry.FullName == nil then
		entry.FullName = entry.Name
	else
        entry.FullName = entry.FullName
    end

    if entry.IsFolder == true then
        entry.IsFolder = true
    else
        entry.IsFolder = false
    end

    if entry.IsFolder ~= true then
		local nameLength = entry.Name:len()
    	if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
			entry.Name = entry.Name:sub(0, nameLength - 4)
		end
		nameLength = entry.FullName:len()
		if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
			entry.FullName = entry.FullName..".lua"
	 	end
	end

    local checkedEntry = {
        Name = "",
        FullName = "",
        IsFolder = false,
    }

    checkedEntry.Name = entry.Name
    checkedEntry.FullName = entry.FullName
    checkedEntry.IsFolder = entry.IsFolder

	if entry.IsFolder then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkTree(child))
			end
		end
		checkedEntry.Childs = childs
	end

	return checkedEntry
end

function FileLoader:requestFile(url, path)
	self.logger:LogDebug("Requests file '" .. path .. "' from '" .. url .. "'")
	local request = InternetCard:request(url, "GET", "")
	table.insert(self.requests, {
		request = request,
		func = function(req)
			self.logger:LogDebug("Write file '" .. path .. "'")
			local file = filesystem.open(path, "w")
			local code, data = req:get()
			if code ~= 200 or not data then
				self.logger:LogError("Unable to request file '" .. path .. "' from '" .. url .. "'")
				return false
			end
			file:write(data)
			file:close()
			return true
		end
	})
end

function FileLoader:doEntry(parentPath, entry, force)
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
	table.remove(folder, 1)
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
    self:doFolder("", checkTree(tree), force)
end

function FileLoader:DownloadFileTree(basePath, tree, force)
	if basePath == nil then return false end
	if tree == nil then return false end
	if force == nil then force = false end

	self.logger:LogDebug("Github File Loader Version: "..version)

	self.basePath = basePath
	self:requestFileTree(tree, force)
	return self:loadFiles()
end

return FileLoader