-- if option is empty it will show you all options
local option = ""
local extendOptionDetails = false

-- logLevel
-- 0 = Trace / 1 = Debug / 2 = Info / 3 = Warning / 4 = Error
local loaderLogLevel = 2
local programLogLevel = 2

-- forceDownload
local loaderForceDownload = false
local programForceDownload = false

-- Config --
-- to define any config variables
--Config = {}

local GithubLoaderBaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Module-Bundling"



---@param obj any
---@param typeToCheck type
---@param functionName string
---@param parameterPositionBefore integer
---@param parameterPositionAfter integer
function filesystem.checkType(obj, typeToCheck, functionName, parameterPositionBefore, parameterPositionAfter)
    local objType = type(obj)
    if objType == typeToCheck then
        return
    end
    local message = functionName .. "("
    local i = 0
    while i < parameterPositionBefore do
        message = message .. "..., "
        i = i + 1
    end
    message = message .. "expexted '" .. typeToCheck .. "', got '" .. objType .. "'"
    i = 0
    while i < parameterPositionAfter do
        message = message .. ", ..."
        i = i + 1
    end
    message = message .. ")"
    error(message, 3)
end

---@param path string
---@return string
function filesystem.fixPath(path)
    filesystem.checkType(path, "string", "filesystem.fixPath", 0, 0)
    if path == nil then
        return ""
    end
    path = path:gsub("\\\\", "/")
    path = path:gsub("\\", "/")
    return path
end

---@param path1 string
---@param path2 string
---@return string
function filesystem.combinePaths(path1, path2)
    filesystem.checkType(path1, "string", "filesystem.combinePaths", 0, 1)
    filesystem.checkType(path2, "string", "filesystem.combinePaths", 1, 0)
    if path1 == "" then
        return path2
    end
    if path2 == "" then
        return path1
    end
    path1 = filesystem.fixPath(path1)
    path2 = filesystem.fixPath(path2)
    if (path1:find("./$") or path1 == "/") and path2:find("^[^/].") then
        return path1 .. path2
    end
    if path1 == "/" and (path2:find("^/.") or path2 == "/") then
        return path2
    end
    if path1:find(".[^/]$") and (path2:find("^/.") or path2 == "/") then
        return path1 .. path2
    end
    if (path1:find("./$") or path1 == "/") and path2 == "/" then
        return path1
    end
    if path1:find(".[^/]$") and path2:find("^[^/].") then
        return path1 .. "/" .. path2
    end
    error("could not combine paths: '" .. path1 .. "' <-> '" .. path2 .. "'")
end

local GithubLoaderUrl = GithubLoaderBaseUrl .. "/Github-Loading/GithubLoader.lua"
local GithubLoaderFilesFolderPath = "Github-Loading"
local GithubLoaderPath = filesystem.combinePaths(GithubLoaderFilesFolderPath, "GithubLoader.lua")

computer.beep(5.0)
local internetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not internetCard then
    print("[Computer] ERROR! No internet-card found! Please install a internet card!")
    computer.beep(0.2)
    return
end
print("[Computer] INFO! found internet-card")

filesystem.initFileSystem("/dev")

local drive = ""
for _, child in pairs(filesystem.childs("/dev")) do
    if not (child == "serial") then
        drive = child
        break
    end
end
if drive:len() < 1 then
    print("[Computer] ERROR! Unable to find filesystem to load on! Please insert a drive or floppy!")
    computer.beep(0.2)
    return
end
filesystem.mount("/dev/" .. drive, "/")
print("[Computer] INFO! mounted filesystem on drive: " .. drive)

if not filesystem.exists(GithubLoaderFilesFolderPath) then
    filesystem.createDir(GithubLoaderFilesFolderPath)
end

if not filesystem.exists(GithubLoaderPath) then
    print("[Computer] INFO! downloading Github loader...")
    local req = internetCard:request(GithubLoaderUrl, "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open(GithubLoaderPath, "w")
    if file == nil then
        error("Unable to open file: '".. GithubLoaderPath .."'")
    end
    file:write(libdata)
    file:close()
    print("[Computer] INFO! downloaded Github loader")
end

-- Initialize([logLevel:int], [forceDownload:boolean])
---@type GithubLoader
local GithubLoader = filesystem.doFile(GithubLoaderPath)
if GithubLoader == nil then
    error("Unable to load GithubLoader")
end
GithubLoader = GithubLoader.new(GithubLoaderBaseUrl, "", loaderForceDownload, internetCard)
GithubLoader:Initialize(loaderLogLevel)

if option == "" then
    -- GithubLoader:ShowOptions([extended:boolean])
    GithubLoader:ShowOptions(extendOptionDetails)
else
    -- GithubLoader:Run([option:string], [logLevel:int], [forceDownload:boolean])
    GithubLoader:Run(option, programLogLevel, programForceDownload)
end
