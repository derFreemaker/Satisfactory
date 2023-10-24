---@class Net.Rest.Uri : Core.Json.Serializable
---@field private _Path string
---@field private _Query Dictionary<string, string>
---@overload fun(uri: string) : Net.Rest.Uri
local Uri = {}

---@private
---@param uri string
function Uri:__init(uri)
    local splittedUri = Utils.String.Split(uri, "?")
    self._Path = splittedUri[1]

    self._Query = {}
    local splittedQuery = Utils.String.Split(splittedUri[2], "&")
    for _, queryPart in ipairs(splittedQuery) do
        if not splittedQuery == "" then
            local splittedQueryPart = Utils.String.Split(queryPart, "=")
            self._Query[splittedQueryPart[1]] = splittedQueryPart[2]
        end
    end
end

---@param name string
---@param value string
function Uri:AddToQuery(name, value)
    self._Query[name] = value
end

---@return string url
function Uri:GetUrl()
    local str = self._Path
    if Utils.Table.Count(self._Query) > 0 then
        str = str .. "?"
        for name, value in pairs(self._Query) do
            str = str .. name .. "=" .. value .. "&"
        end
    end
    return str
end

---@private
function Uri:__tostring()
    return self:GetUrl()
end

function Uri:Serialize()
    return self:GetUrl()
end

return Utils.Class.CreateClass(Uri, "Net.Rest.Uri",
    require("Core.Json.Serializable"))
