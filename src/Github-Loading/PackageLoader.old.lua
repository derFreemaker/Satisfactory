local Utils = require("src (Outdated).Core.shared.Utils.Index")

---@class PackageOld
---@field Info Entry
---@field Data 'PackageData'
local PackageOld = {}
PackageOld.__index = PackageOld

---@param info Entry
---@param data table
---@return PackageOld
function PackageOld.new(info, data)
    return setmetatable({
        Info = info,
        Data = data
    }, PackageOld)
end

---@class WaitingPackageOld
---@field AwaitingPackage string
---@field Waiters Entry[]
local WaitingPackageOld = {}
WaitingPackageOld.__index = WaitingPackageOld

---@param awaitingPackage string
---@param waiters Entry[]
function WaitingPackageOld.new(awaitingPackage, waiters)
    return setmetatable({
        AwaitingPackage = awaitingPackage,
        Waiters = waiters
    }, WaitingPackageOld)
end

---@class PackageLoaderOld
---@field private packages PackageOld[]
---@field private waitingPackages WaitingPackageOld[]
---@field private loadingPhase boolean
---@field private logger Logger
PackageLoaderOld = {}

---@private
---@param packageToGet string
---@return PackageOld | nil
function PackageLoaderOld.internalGetPackage(packageToGet)
    for _, package in ipairs(PackageLoaderOld.packages) do
        if package.Info.Path == "/" .. packageToGet:gsub("%.", "/") .. ".lua" then
            return package
        end
    end
    return nil
end

---@private
---@param entry Entry
function PackageLoaderOld.doEntry(entry)
    if entry.IgnoreLoad then return end
    if entry.IsFolder then
        for _, childEntry in ipairs(entry.Childs) do
            PackageLoaderOld.doEntry(childEntry)
        end
    else
        if filesystem.exists(entry.Path) then
            PackageLoaderOld.LoadPackage(entry)
        else
            PackageLoaderOld.logger:LogWarning("unable to find package: '" .. entry.Path .. "'")
        end
    end
end

---@return Entry | nil, boolean
local function getCallerInfo()
    local caller = debug.getinfo(4, "S")
    local callerData = {
        FullName = filesystem.path(3, caller.short_src),
        Path = caller.short_src
    }
    return Utils.Entry.Parse(callerData)
end

---@param packageCouldNotLoad string
function PackageLoaderOld.handleCouldNotLoadPackage(packageCouldNotLoad)
    local caller = getCallerInfo()
    if not caller then
        PackageLoaderOld.logger:LogError("caller was nil")
        error("caller was nil")
    end
    for _, packageWaiters in ipairs(PackageLoaderOld.waitingPackages) do
        if packageWaiters.AwaitingPackage == packageCouldNotLoad then
            table.insert(packageWaiters.Waiters, caller)
            PackageLoaderOld.logger:LogTrace("added: '" ..
                caller.Name .. "' to load after '" .. packageCouldNotLoad .. "' was loaded")
            return
        end
    end
    table.insert(PackageLoaderOld.waitingPackages, WaitingPackageOld.new(packageCouldNotLoad, { caller }))
    PackageLoaderOld.logger:LogTrace("added: '" ..
        caller.Name .. "' to load after '" .. packageCouldNotLoad .. "' was loaded")
end

---@param awaitingPackage PackageOld
function PackageLoaderOld.loadWaitingPackages(awaitingPackage)
    for i, packageWaiters in ipairs(PackageLoaderOld.waitingPackages) do
        local path = "/" .. packageWaiters.AwaitingPackage:gsub("%.", "/") .. ".lua"
        if path == awaitingPackage.Info.Path then
            for _, waiter in ipairs(packageWaiters.Waiters) do
                PackageLoaderOld.LoadPackage(waiter)
            end
            table.remove(PackageLoaderOld.waitingPackages, i)
        end
    end
end

---@param logger Logger
function PackageLoaderOld.Initialize(logger)
    PackageLoaderOld.packages = {}
    PackageLoaderOld.waitingPackages = {}
    PackageLoaderOld.loadingPhase = false
    PackageLoaderOld.logger = logger:create("PackageLoader")
end

---@param fileEntry Entry
function PackageLoaderOld.LoadPackage(fileEntry)
    PackageLoaderOld.logger:LogDebug("loading package: '" .. fileEntry.Name .. "'...")
    local success, fileData = pcall(filesystem.doFile, fileEntry.Path)
    if not success then
        PackageLoaderOld.logger:LogDebug("unable to load package: '" .. fileEntry.FullName .. "'")
        return
    end
    local package = PackageOld.new(fileEntry, fileData)
    table.insert(PackageLoaderOld.packages, package)
    PackageLoaderOld.logger:LogDebug("loaded package: '" .. fileEntry.Name .. "'")
    PackageLoaderOld.loadWaitingPackages(package)
    PackageLoaderOld.logger:LogDebug("loaded waiting packages")
end

---@param packageTree Entry
---@param loadingPhase boolean
---@return boolean
function PackageLoaderOld.LoadPackages(packageTree, loadingPhase)
    PackageLoaderOld.loadingPhase = loadingPhase or false
    PackageLoaderOld.logger:LogDebug("loading packages...")
    if not packageTree then
        PackageLoaderOld.logger:LogInfo("package tree was empty")
        return true
    end
    PackageLoaderOld.doEntry(packageTree)
    if #PackageLoaderOld.waitingPackages ~= 0 then
        for _, waiters in ipairs(PackageLoaderOld.waitingPackages) do
            local waitersNames = waiters.Waiters[1].Name
            for i, waiter in ipairs(waiters.Waiters) do
                if i ~= 1 then
                    waitersNames = waitersNames .. ", '" .. waiter.Name .. "'"
                end
            end
            PackageLoaderOld.logger:LogError("Unable to load: '" .. waiters.AwaitingPackage ..
                "' for '" .. waitersNames .. "'")
        end
        PackageLoaderOld.logger:LogError("Unable to load modules")
        return false
    end
    PackageLoaderOld.loadingPhase = false
    PackageLoaderOld.logger:LogDebug("loaded packages")
    return true
end

---@param packageToLoad string
---@return 'PackageData'
function PackageLoaderOld.PreLoadPackage(packageToLoad)
    local package = PackageLoaderOld.internalGetPackage(packageToLoad)
    if package ~= nil then
        PackageLoaderOld.logger:LogTrace("pre loaded package: '" .. package.Info.Name .. "'")
        return package.Data
    end
    PackageLoaderOld.handleCouldNotLoadPackage(packageToLoad)
    error("unable to load package: '" .. packageToLoad .. "'")
end

---@param packageToGet string
---@return 'PackageData'
function PackageLoaderOld.GetPackage(packageToGet)
    if PackageLoaderOld.loadingPhase then
        computer.panic("unable to use 'PackageLoader.GetPackage' while being in loading Phase")
    end
    local package = PackageLoaderOld.internalGetPackage(packageToGet)
    if not package then
        error("unable to get package: '" .. packageToGet .. "'")
    end
    PackageLoaderOld.logger:LogTrace("geted package: '" .. package.Info.Name .. "'")
    return package.Data
end

---@return PackageOld[]
function PackageLoaderOld.GetPackages()
    ---@type PackageOld[]
    local clone = {}
    for _, package in ipairs(PackageLoaderOld.packages) do
        table.insert(clone, package)
    end
    return clone
end

-- ---@param packageToLoadOrGet string
-- ---@return 'PackageData'
-- function require(packageToLoadOrGet)
--     if PackageLoaderOld.loadingPhase then
--         return PackageLoaderOld.PreLoadPackage(packageToLoadOrGet)
--     end
--     return PackageLoaderOld.GetPackage(packageToLoadOrGet)
-- end
