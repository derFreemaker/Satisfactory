---@alias Core.Cache.ValidKeyTypes string | integer

---@class Core.Cache.Entry<T> : { Value: { [1]: T }, Expires: integer | nil }

-- ### Constructor
-- If weak is `true` all values will get stored as weak reference
---@generic TKey : Core.Cache.ValidKeyTypes
---@class Core.Cache<TKey, TValue> : { m_cache: { [TKey]: TValue }, Add: (fun(self: Core.Cache<TKey, TValue>, key: TKey, value: TValue) : nil), Remove: (fun(self: Core.Cache<TKey, TValue>, key: TKey)), Get: (fun(self: Core.Cache<TKey, TValue>, key: TKey) : TValue | nil), TryGet: (fun(self: Core.Cache<TKey, TValue>, key: TKey, outValue: (Out<TValue>)) : boolean) }, object
---@field m_cache table<Core.Cache.ValidKeyTypes, Core.Cache.Entry<any>>
---@field m_expireDelay integer
---@field m_weakReferences boolean
---@overload fun(expireDelay: integer | nil, weakReferences: boolean | nil): Core.Cache
local Cache = {}

---@private
---@param expireDelay integer | nil
---@param weakReferences boolean | nil
function Cache:__init(expireDelay, weakReferences)
    self.m_cache = {}
    self.m_expireEnabled = expireDelay ~= nil
    self.m_expireDelay = expireDelay or 0
    self.m_weakReferences = weakReferences or false
end

---@param key Core.Cache.ValidKeyTypes
---@param adapter any
function Cache:Add(key, adapter)
    ---@type Core.Cache.Entry<any>
    local entry = { Value = { adapter } }
    if self.m_expireDelay then
        entry.Expires = computer.millis() + self.m_expireDelay
    end

    if self.m_weakReferences then
        setmetatable(entry.Value, { __mode = 'v' })
    end

    self.m_cache[key] = entry
end

---@param key Core.Cache.ValidKeyTypes
function Cache:Remove(key)
    self.m_cache[key] = nil
end

---@param key Core.Cache.ValidKeyTypes
---@return any | nil
function Cache:Get(key)
    local entry = self.m_cache[key]
    if not entry then
        return nil
    end

    -- check weak reference
    if not entry.Value[1] then
        return nil
    end

    -- check expired
    if entry.Expires and entry.Expires < computer.millis() then
        return nil
    end

    return entry.Value[1]
end

---@param key Core.Cache.ValidKeyTypes
---@param outEntry Out<any>
---@return boolean
function Cache:TryGet(key, outEntry)
    local entry = self:Get(key)
    if not entry then
        return false
    end

    outEntry.Value = entry.Value[1]
    return true
end

return class("Core.Cache", Cache)
