---@class Adapter.IAdapter : object

---@class Adapter.Cache
---@field m_cache table<string, table<string|integer, Adapter.IAdapter>>
---@overload fun(): Adapter.Cache
local Cache = {}

function Cache:__init()
    self.m_cache = setmetatable({}, { __mode = "v" })
end

---@param name string
---@param indexOrId string | integer
---@param adapter Adapter.IAdapter
function Cache:Add(name, indexOrId, adapter)
    local adapterGroup = self.m_cache[name]
    if not adapterGroup then
        adapterGroup = {}
        adapterGroup[indexOrId] = adapter
        self.m_cache[name] = adapterGroup
        return
    end

    adapterGroup[indexOrId] = adapter
end

---@generic TAdapter : Adapter.IAdapter
---@param name string
---@param idOrIndex string | integer
---@return TAdapter
function Cache:Get(name, idOrIndex)
    local adapterGroup = self.m_cache[name]
    if not adapterGroup then
        error("no adapter group found name: " .. name)
    end

    local adapter = adapterGroup[idOrIndex]
    if not adapter then
        error("no adapter found with idOrIndex: " .. idOrIndex)
    end

    return adapter
end

---@generic TAdapter : Adapter.IAdapter
---@param name string
---@param idOrIndex string | integer
---@param outAdapter Out<TAdapter>
---@return boolean
function Cache:TryGet(name, idOrIndex, outAdapter)
    local adapterGroup = self.m_cache[name]
    if not adapterGroup then
        return false
    end

    local adapter = adapterGroup[idOrIndex]
    if not adapter then
        return false
    end

    outAdapter.Value = adapter
    return true
end

return Utils.Class.CreateClass(Cache, "Adapter.Cache")()
