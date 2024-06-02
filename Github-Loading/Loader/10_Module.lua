---@class Github_Loading.Module.Info
---@field Location string
---@field Namespace string
---@field IsRunnable boolean

---@class Github_Loading.Module : Github_Loading.Module.Info
---@field Package Github_Loading.Package
---@field Data string?
---@field StoredData table
local Module = {}

---@param moduleInfo Github_Loading.Module.Info
---@param package Github_Loading.Package
---@return Github_Loading.Module
function Module.new(moduleInfo, package)
    ---@type Github_Loading.Module
    ---@diagnostic disable-next-line
    local instance = moduleInfo
    instance.Package = package

    return setmetatable(instance, { __index = Module })
end

---@return any ...
function Module:Load()
    if self.StoredData then
        return table.unpack(self.StoredData)
    end

    if not self.Data then
        error("the package of this module is not downloaded")
    end

    if self.IsRunnable then
        if NotInGame then
            self.StoredData = { require(self.Namespace) }
        else
            self.StoredData = { load(self.Data, self.Location)() }
        end
    else
        self.StoredData = { self.Data }
    end

    return table.unpack(self.StoredData)
end

return Module
