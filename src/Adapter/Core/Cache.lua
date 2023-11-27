---@class Adapter.IAdapter : object

---@class Adapter.Cache
---@field m_cache table<string|integer, Adapter.IAdapter>
---@overload fun(): Adapter.Cache
local Cache = {}

function Cache:__init()
    self.m_cache = setmetatable({}, { __mode = "v" })
end

---@param indexOrId string | integer
---@param adapter Adapter.IAdapter
function Cache:Add(indexOrId, adapter)
    self.m_cache[indexOrId] = adapter
end

---@generic TAdapter : Adapter.IAdapter
---@param idOrIndex string | integer
---@return TAdapter?
function Cache:Get(idOrIndex)
    return self.m_cache[idOrIndex]
end

---@generic TAdapter : Adapter.IAdapter
---@param idOrIndex string | integer
---@param outAdapter Out<TAdapter>
function Cache:TryGet(idOrIndex, outAdapter)
    local adapter = self.m_cache[idOrIndex]
    if adapter == nil then
        return false
    end

    outAdapter.Value = adapter
    return true
end

return Utils.Class.CreateClass(Cache, "Adapter.Cache")()



-- What is the main goal of outr clothing style, according to the video?
-- What is message of the protray by Peter Black?
-- What role do clothes play when we communicate with friends and
