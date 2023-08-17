---@alias Github_Loading.Module.LoadFunction fun(...) : any

---@class Github_Loading.Module
---@field Name string
---@field FullName string
---@field Namespace string
---@field IsRunnable boolean
---@field Data Github_Loading.Module.LoadFunction | string
---@field StoredData table
local Module = {}

---@param moduleData table
---@return Github_Loading.Module
function Module.new(moduleData)
    local metatable = Module
    metatable.__index = Module
    return setmetatable({
        Namespace = moduleData.Namespace,
        Name = moduleData.Name,
        FullName = moduleData.FullName,
        IsRunnable = moduleData.IsRunnable,
        Data = moduleData.Data
    }, metatable)
end

---@param ... any
---@return any ...
function Module:Load(...)
    if self.StoredData then
        return table.unpack(self.StoredData)
    end
    local result
    if type(self.Data) == "function" then
        result = table.pack(self.Data(...))
    else
        result = table.pack(self.Data)
    end
    self.StoredData = result
    return table.unpack(result)
end

return Module