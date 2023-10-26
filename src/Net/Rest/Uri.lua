---@class Net.Rest.Uri : Core.Json.Serializable
---@field private m_path string
---@field private m_query table<string, string>
---@overload fun(paht: string, query: table<string, string>) : Net.Rest.Uri
local Uri = {}

---@param uri string
---@return Net.Rest.Uri uri
function Uri.Static__Parse(uri)
    local splittedUri = Utils.String.Split(uri, "?")
    local path = splittedUri[1]

    local query = {}
    local splittedQuery = Utils.String.Split(splittedUri[2], "&")
    for _, queryPart in ipairs(splittedQuery) do
        if not splittedQuery == "" then
            local splittedQueryPart = Utils.String.Split(queryPart, "=")
            query[splittedQueryPart[1]] = splittedQueryPart[2]
        end
    end

    return Uri(path, query)
end

---@private
---@param path string
---@param query table<string, string>
function Uri:__init(path, query)
    self.m_path = path
    self.m_query = query or {}
end

---@param name string
---@param value string
function Uri:AddToQuery(name, value)
    self.m_query[name] = value
end

---@return string url
function Uri:GetUrl()
    local str = self.m_path
    if #self.m_query > 0 then
        str = str .. "?"
        for name, value in pairs(self.m_query) do
            str = str .. name .. "=" .. value .. "&"
        end
    end
    return str
end

---@private
function Uri:__tostring()
    return self:GetUrl()
end

---@return string path, table<string, string> query
function Uri:Serialize()
    return self.m_path, self.m_query
end

return Utils.Class.CreateClass(Uri, "Net.Rest.Uri",
    require("Core.Json.Serializable"))
