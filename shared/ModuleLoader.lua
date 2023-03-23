---@class Module
---@field Info Entry
---@field Data 'ModuleType'
local Module = {}
Module.__index = {}

---@param info Entry
---@param data 'ModuleType'
---@return Module
function Module.new(info, data)
    return setmetatable({
        Info = info,
        Data = data
    }, Module)
end

---@class WaitingModule
---@field AwaitingModule string
---@field Waiters Entry[]
local WaitingModule = {}
WaitingModule.__index = WaitingModule

---@param awaitingModule string
---@param waiters Entry[]
---@return WaitingModule
function WaitingModule.new(awaitingModule, waiters)
    return setmetatable({
        AwaitingModule = awaitingModule,
        Waiters = waiters
    }, WaitingModule)
end

---@class ModuleLoader
---@field private libs Module[]
---@field private waitingForLoad WaitingModule[]
---@field private loadingPhase boolean
---@field private getGetWithName boolean
---@field private logger Logger
ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader.extractCallerInfo(path)
    local callerData = {
        FullName = filesystem.path(3, path),
        Path = path
    }
    return ModuleLoader.entry.Check(callerData, nil)
end

---@private
---@param entry Entry
function ModuleLoader.doEntry(entry)
    if entry.IgnoreLoad then return end
    if entry.IsFolder == true then
        ModuleLoader.doFolder(entry)
    else
        ModuleLoader.doFile(entry)
    end
end

---@private
---@param file Entry
function ModuleLoader.doFile(file)
    if file.IgnoreLoad == true then return end
    if filesystem.exists(file.Path) then
        ModuleLoader.LoadModule(file)
    else
        ModuleLoader.logger:LogDebug("Unable to find module: " .. file.Path)
    end
end

---@private
---@param folder Entry
function ModuleLoader.doFolder(folder)
    for _, child in pairs(folder.Childs) do
        if type(child) == "table" then
            ModuleLoader.doEntry(child)
        end
    end
end

---@private
---@param awaitingModule Module
function ModuleLoader.loadWaitingModules(awaitingModule)
    for i, moduleWaiters in pairs(ModuleLoader.waitingForLoad) do
        if string.gsub(moduleWaiters.AwaitingModule, "%.", "/") .. ".lua" == awaitingModule.Info.Path then
            for x, waitingModule in pairs(moduleWaiters.Waiters) do
                local success = ModuleLoader.LoadModule(waitingModule)
                if success then
                    table.remove(moduleWaiters.Waiters, x)
                end
            end
        end
        if #moduleWaiters.Waiters == 0 then
            table.remove(ModuleLoader.waitingForLoad, i)
        end
    end
end

---@private
---@param moduleCouldNotLoad string
function ModuleLoader.handleCouldNotLoadModule(moduleCouldNotLoad)
    local caller = ModuleLoader.extractCallerInfo(debug.getinfo(3).short_src)
    if caller == nil then
        ModuleLoader.logger:LogError("caller was nil")
        return
    end
    for _, moduleWaiters in pairs(ModuleLoader.waitingForLoad) do
        if moduleWaiters.AwaitingModule == moduleCouldNotLoad then
            table.insert(moduleWaiters.Waiters, caller)
            ModuleLoader.logger:LogDebug("added: '" ..
            caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
            return
        end
    end
    table.insert(ModuleLoader.waitingForLoad, WaitingModule.new(moduleCouldNotLoad, { caller }))
    ModuleLoader.logger:LogDebug("added: '" .. caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
end

---@private
---@param moduleToGet string
function ModuleLoader.internalGetModule(moduleToGet)
    for _, lib in pairs(ModuleLoader.libs) do
        if lib.Info.Path == string.gsub(moduleToGet, "%.", "/") .. ".lua" then
            return lib
        end
        if ModuleLoader.getGetWithName and lib.Info.Name == moduleToGet then
            return lib
        end
    end
end

---@private
function ModuleLoader.checkForSameModuleNames()
    local dupes = {}
    for _, lib in pairs(ModuleLoader.libs) do
        for _, dupeLibInfo in pairs(dupes) do
            if lib.Info.Name == dupeLibInfo.Name then
                ModuleLoader.getGetWithName = false
                return
            end
        end
        table.insert(dupes, lib.Info)
    end
end

---@param logger Logger
function ModuleLoader.Initialize(logger)
    ModuleLoader.libs = {}
    ModuleLoader.waitingForLoad = {}
    ModuleLoader.loadingPhase = false
    ModuleLoader.getGetWithName = false
    ModuleLoader.logger = logger:create("ModuleLoader")
end

function ModuleLoader.GetModules()
    local clone = {}
    for _, value in pairs(ModuleLoader.libs) do
        table.insert(clone, value)
    end
    return clone
end

---@param fileEntry Entry
---@return boolean
function ModuleLoader.LoadModule(fileEntry)
    if fileEntry.IgnoreLoad == true then return true end
    ModuleLoader.logger:LogTrace("loading module: '" .. fileEntry.Name .. "' from path: '" .. fileEntry.Path .. "'")
    local success, fileData = pcall(filesystem.doFile, fileEntry.Path)
    if not success then
        ModuleLoader.logger:LogTrace("unable to load module: '" .. fileEntry.Name .. "'")
        return false
    end
    local module = Module.new(fileEntry, fileData)
    table.insert(ModuleLoader.libs, module)
    ModuleLoader.logger:LogTrace("loaded module: '" .. fileEntry.Name .. "'")

    ModuleLoader.loadWaitingModules(module)
    return true
end

---@param modulesTree table
---@param loadingPhase boolean
---@return boolean
function ModuleLoader.LoadModules(modulesTree, loadingPhase)
    loadingPhase = loadingPhase or false
    ModuleLoader.logger:LogDebug("loading modules...")
    if modulesTree == nil then
        ModuleLoader.logger:LogDebug("modules tree was empty")
        return true
    end
    ModuleLoader.doFolder(Utils.Entry.Check(modulesTree))
    if #ModuleLoader.waitingForLoad > 0 then
        for _, waiters in pairs(ModuleLoader.waitingForLoad) do
            ModuleLoader.logger:LogError("Unable to load: '" .. waiters.AwaitingModule ..
                "' for '" .. #waiters.Waiters .. "' modules")
        end
        ModuleLoader.logger:LogError("Unable to load modules")
        return false
    end
    ModuleLoader.logger:LogDebug("loaded modules")
    loadingPhase = false
    ModuleLoader.checkForSameModuleNames()
    return true
end

---@param moduleToLoad string
---@return 'ModuleType'
function ModuleLoader.PreLoadModule(moduleToLoad)
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib ~= nil then
        ModuleLoader.logger:LogTrace("pre loaded module: '" .. lib.Info.Name .. "'")
        return lib.Data
    end
    ModuleLoader.handleCouldNotLoadModule(moduleToLoad)
    error("unable to load module: '" .. moduleToLoad .. "'")
end

---@param moduleToLoad string
---@return 'ModuleType'
function ModuleLoader.GetModule(moduleToLoad)
    if ModuleLoader.loadingPhase then
        computer.panic("can't get module while being in loading phase")
    end
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib == nil then
        error("could not get module: '" .. moduleToLoad .. "'")
    end
    ModuleLoader.logger:LogTrace("geted module: '" .. lib.Info.Name .. "'")
    return lib.Data
end

---@param moduleToLoad string
---@return 'ModuleType'
function require(moduleToLoad)
    if ModuleLoader.loadingPhase then
        return ModuleLoader.PreLoadModule(moduleToLoad)
    end
    return ModuleLoader.GetModule(moduleToLoad)
end
