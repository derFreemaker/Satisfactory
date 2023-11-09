---@class Github_Loading.Module.Data
---@field Location string
---@field Namespace string
---@field IsRunnable boolean
---@field Data string

---@class Github_Loading.Module : Github_Loading.Module.Data
---@field StoredData table
local Module = {}

---@param moduleData Github_Loading.Module.Data
---@return Github_Loading.Module
function Module.new(moduleData)
    moduleData.Data = moduleData.Data:gsub("{{{", "[["):gsub("}}}", "]]")
    ---@cast moduleData table
    return setmetatable(moduleData, { __index = Module })
end

---@param ... any
---@return any ...
function Module:Load(...)
    if self.StoredData then
        return table.unpack(self.StoredData)
    end

    local result
    if self.IsRunnable then
        result = { load(self.Data, self.Location)(...) }
    else
        result = { self.Data }
    end
    self.StoredData = result

    self.Data = nil
    return table.unpack(result)
end

return Module
