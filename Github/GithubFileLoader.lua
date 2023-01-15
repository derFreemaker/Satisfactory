---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

FileLoader = {}
FileLoader.__index = FileLoader

function FileLoader.new()
    local instace = setmetatable({}, FileLoader)
	return instace
end

FileLoader.requests = {}

function FileLoader:requestFile(url, path)
	print("Requests file '" .. path .. "' from '" .. url .. "'")
	local request = InternetCard:request(url, "GET", "")
	table.insert(self.requests, {
		request = request,
		func = function(req)
			print("Write file '" .. path .. "'")
			local file = filesystem.open(path, "w")
			local code, data = req:get()
			if code ~= 200 or not data then
				print("ERROR! Unable to request file '" .. path .. "' from '" .. url .. "'")
				return false
			end
			file:write(data)
			file:close()
			return true
		end
	})
end

function FileLoader:doEntry(parentPath, entry)
	if #entry == 1 then
		self:doFile(parentPath, entry)
	else
		self:doFolder(parentPath, entry)
	end
end

function FileLoader:doFile(parentPath, file)
	local path = filesystem.path(parentPath, file[1])
	self:requestFile("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main" .. path, path)
end

function FileLoader:doFolder(parentPath, folder)
	local path = filesystem.path(parentPath, folder[1])
	table.remove(folder, 1)
	filesystem.createDir(path)
	for _, child in pairs(folder) do
		self:doEntry(path, child)
	end
end

function FileLoader:loadFiles()
    print("Loading files...")
    while #self.requests > 0 do
        local i = 1
        while i <= #self.requests do
            local request = self.requests[i]
            if request.request:canGet() then
                table.remove(self.requests, i)
                local done = request.func(request.request)
                if not done then
                    computer.beep(0.2)
                    return
                end
            end
            i = i + 1
        end
    end
    print("loaded files...")
end

function FileLoader:requestFileTree(tree)
    self:doFolder("", tree)
end

function FileLoader:downloadFileTree(tree)
	if tree == nil then return end
	self:requestFileTree(tree)
	self:loadFiles()
end

return FileLoader