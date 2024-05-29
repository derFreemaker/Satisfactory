---@alias Core.Cache.ValidKeyTypes string | integer

---@generic TKey : Core.Cache.ValidKeyTypes
---@class Core.Cache<TKey, TValue> : { m_cache: { [TKey]: TValue }, Add: (fun(self: Core.Cache<TKey, TValue>, key: TKey, value: TValue) : nil), Get: (fun(self: Core.Cache<TKey, TValue>, key: TKey) : TValue), TryGet: (fun(self: Core.Cache<TKey, TValue>, key: TKey, outValue: (Out<TValue>)) : boolean) }, object
---@field m_cache table<string|integer, any>
---@overload fun(): Core.Cache
local Cache = {}

---@private
function Cache:__init()
    self.m_cache = setmetatable({}, { __mode = "v" })
end

---@param indexOrId Core.Cache.ValidKeyTypes
---@param adapter any
function Cache:Add(indexOrId, adapter)
    self.m_cache[indexOrId] = adapter
end

---@param idOrIndex Core.Cache.ValidKeyTypes
---@return any
function Cache:Get(idOrIndex)
    local adapter = self.m_cache[idOrIndex]
    if not adapter then
        error("no adapter found with idOrIndex: " .. idOrIndex)
    end

    return adapter
end

---@param idOrIndex Core.Cache.ValidKeyTypes
---@param outAdapter Out<any>
---@return boolean
function Cache:TryGet(idOrIndex, outAdapter)
    local adapter = self.m_cache[idOrIndex]
    if not adapter then
        return false
    end

    outAdapter.Value = adapter
    return true
end

return class("Core.Cache", Cache)
