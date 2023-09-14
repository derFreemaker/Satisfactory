---@class Http.HttpRequest : object
---@field private Client Http.HttpClient
---@overload fun(client: Http.HttpClient) : Http.HttpRequest
local HttpRequest = {}

---@private
---@param client Http.HttpClient
function HttpRequest:__init(client)
    self.Client = client
end


function HttpRequest:Send()
    self.Client:Request()
end

-- //TODO: request

return Utils.Class.CreateClass(HttpRequest, "Http.HttpRequest")