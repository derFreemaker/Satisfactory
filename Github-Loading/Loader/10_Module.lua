---@class Github_Loading.Module.Info
---@field Location string
---@field Namespace string
---@field IsRunnable boolean
---@field StartPos integer
---@field EndPos integer

---@class Github_Loading.Module : Github_Loading.Module.Info
---@field Package Github_Loading.Package
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

    local data = self.Package:ReadModuleChunk(self.StartPos, self.EndPos)
    local result
    if self.IsRunnable then
        result = { load(data, self.Location)() }
    else
        result = { data }
    end
    self.StoredData = result

    return table.unpack(result)
end

return Module
