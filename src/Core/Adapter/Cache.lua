---@class Adapter.IAdapter : object

---@generic TAdapter : Adapter.IAdapter
---@class Adapter.Cache<TAdapter> : { m_cache: { [string|integer]: TAdapter } }, object
---@field m_cache table<string|integer, Adapter.IAdapter>
---@overload fun(): Adapter.Cache
local Cache = {}
return class("Adapter.Cache", Cache, function()
    ---@private
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
    ---@return TAdapter
    function Cache:Get(idOrIndex)
        local adapter = self.m_cache[idOrIndex]
        if not adapter then
            error("no adapter found with idOrIndex: " .. idOrIndex)
        end

        return adapter
    end

    ---@generic TAdapter : Adapter.IAdapter
    ---@param idOrIndex string | integer
    ---@param outAdapter Out<TAdapter>
    ---@return boolean
    function Cache:TryGet(idOrIndex, outAdapter)
        local adapter = self.m_cache[idOrIndex]
        if not adapter then
            return false
        end

        outAdapter.Value = adapter
        return true
    end
end)
