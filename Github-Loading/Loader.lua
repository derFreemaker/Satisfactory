-- //TODO: hold up-to-date
local LoaderFiles = {
    "Github-Loading",
    {
        "Loader",
        { "10_Entities.lua" },
        { "10_Event.lua" },
        { "10_Module.lua" },
        { "10_Option.lua" },
        { "10_Utils.lua" },
        { "20_Listener.lua" },
        { "20_Logger.lua" },
        { "30_Package.lua" },
        { "40_PackageLoader.lua" },
    },
    { "100_Options.lua" },
}


---@param url string
---@param path string
---@param forceDownload boolean
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@return boolean
local function internalDownload(url, path, forceDownload, internetCard)
    if forceDownload == nil then forceDownload = false end
    if filesystem.exists(path) and not forceDownload then
        return true
    end
    local req = internetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or data == nil then return false end
    local file = filesystem.open(path, "w")
    if file == nil then
        return false
    end
    file:write(data)
    file:close()
    return true
end


---@class Github_Loading.FilesTreeTools
local FileTreeTools = {}

---@private
---@param parentPath string
---@param entry table | string
---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
---@return boolean
function FileTreeTools:doEntry(parentPath, entry, fileFunc, folderFunc)
    if #entry == 1 then
        ---@cast entry string
        return self:doFile(parentPath, entry, fileFunc)
    else
        ---@cast entry table
        return self:doFolder(parentPath, entry, fileFunc, folderFunc)
    end
end

---@private
---@param parentPath string
---@param file string
---@param func fun(path: string) : boolean
---@return boolean
function FileTreeTools:doFile(parentPath, file, func)
    local path = filesystem.path(parentPath, file[1])
    return func(path)
end

---@param parentPath string
---@param folder table
---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
---@return boolean
function FileTreeTools:doFolder(parentPath, folder, fileFunc, folderFunc)
    local path = filesystem.path(parentPath, folder[1])
    if not folderFunc(path) then
        return false
    end
    for index, child in pairs(folder) do
        if index ~= 1 then
            local success = self:doEntry(path, child, fileFunc, folderFunc)
            if not success then
                return false
            end
        end
    end
    return true
end


---@param loaderBaseUrl string
---@param loaderBasePath string
---@param forceDownload boolean
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@return boolean
local function downloadFiles(loaderBaseUrl, loaderBasePath, forceDownload, internetCard)
    ---@param path string
    ---@return boolean success
    local function downloadFile(path)
        local url = loaderBaseUrl .. path
        path = loaderBasePath .. path
        assert(internalDownload(url, path, forceDownload, internetCard), "Unable to download file: '".. path .."'")
        return true
    end

    ---@param path string
    ---@return boolean success
    local function createFolder(path)
        if not filesystem.exists(loaderBasePath .. path) then
            return filesystem.createDir(loaderBasePath .. path)
        end
        return true
    end

    return FileTreeTools:doFolder("/", LoaderFiles, downloadFile, createFolder)
end


---@param loaderBasePath string
---@return Dictionary<string, any> loadedLoaderFiles
local function loadFiles(loaderBasePath)
    ---@type string[][]
    local loadEntries = {}
    ---@type integer[]
    local loadOrder = {}

    ---@param path string
    ---@return boolean success
    local function retrivePath(path)
        local fileName = filesystem.path(4, path)
        local num = fileName:match("^(%d+)_.+$")
        if num then
            num = tonumber(num)
            ---@cast num integer
            local entries = loadEntries[num]
            if not entries then
                entries = {}
                loadEntries[num] = entries
                table.insert(loadOrder, num)
            end
            table.insert(entries, path)
        end
        return true
    end

    assert(FileTreeTools:doFolder("/", LoaderFiles, retrivePath, function() return true end),
            "Unable to load loader Files")

    table.sort(loadOrder)
    ---@type Dictionary<string, any>
    local loadedLoaderFiles = {}
    for _, num in ipairs(loadOrder) do
        for _, path in pairs(loadEntries[num]) do
            local loadedFile = table.pack(filesystem.loadFile(loaderBasePath .. path)(loadedLoaderFiles))
            loadedLoaderFiles[path] = loadedFile
        end
    end

    return loadedLoaderFiles
end


---@class Github_Loading.Loader
---@field private loaderBaseUrl string
---@field private loaderBasePath string
---@field private forceDownload boolean
---@field private internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@field private loadedLoaderFiles Dictionary<string, any>
local Loader = {}

---@param loaderBaseUrl string
---@param loaderBasePath string
---@param forceDownload boolean
---@param internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
---@return Github_Loading.Loader
function Loader.new(loaderBaseUrl, loaderBasePath, forceDownload, internetCard)
    local loader = Loader
    loader.__index = loader
    return setmetatable({
        loaderBaseUrl = loaderBaseUrl,
        loaderBasePath = loaderBasePath,
        forceDownload = forceDownload,
        internetCard = internetCard,
        loadedLoaderFiles = {}
    }, loader)
end


---@return boolean success
function Loader:Download()
    return downloadFiles(self.loaderBaseUrl, self.loaderBasePath, self.forceDownload, self.internetCard)
end


function Loader:Load()
    self.loadedLoaderFiles = loadFiles(self.loaderBasePath)
end

---@param moduleToGet string
---@return any ...
function Loader:Get(moduleToGet)
    local module = self.loadedLoaderFiles[moduleToGet]
    if not module then
        return
    end
    return table.unpack(module)
end

return Loader