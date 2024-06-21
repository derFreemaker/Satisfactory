---@class Core.Url : object
---@overload fun(urlOrParts: string | string[] | nil) : Core.Url
local Url = {}

---@private
---@param urlOrParts string | string[] | nil
function Url:__init(urlOrParts)
    if type(urlOrParts) == "table" then
        self.m_parts = urlOrParts
        return
    end

    self.m_parts = Utils.String.Split(urlOrParts, "/")
end

---@return string url
function Url:GetUrl()
    return Utils.String.Join(self.m_parts, "/")
end

Url.ToString = Url.GetUrl
---@private
Url.__tostring = Url.GetUrl

---@param url string
---@return Core.Url
function Url:Append(url)
    local newParts = Utils.String.Split(url, "/")
    for _, part in ipairs(newParts) do
        table.insert(self.m_parts, part)
    end
    return self
end

---@param url string
---@return Core.Url
function Url:Extend(url)
    local copy = self:Copy()
    copy:Append(url)
    return copy
end

---@return Core.Url
function Url:Copy()
    local copy = Utils.Table.Copy(self.m_parts)
    return Url(copy)
end

return class("Core.Url", Url)
