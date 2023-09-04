---@meta


---@class FicsIt_Networks.Components.FINComputerMod.FINInternetCard : FicsIt_Networks.Components.FINComputerMod
local InternetCard = {}


---@alias FicsIt_Networks.Components.FINComputerMod.FINInternetCard.HttpMethods
---|"CREATE"
---|"GET"
---|"HEAD"
---|"POST"
---|"PUT"
---|"DELETE"
---|"CONNECT"
---|"OPTIONS"
---|"TRACE"
---|"PATCH"

--- Does an HTTP-Request. If a payload is given, the Content-Type header has to be set. All additional parameters have to be strings and in pairs of two for defining the http headers and values.
---@param url string The Url for which you want to make an HTTP Request.
---@param method FicsIt_Networks.Components.FINComputerMod.FINInternetCard.HttpMethods The http request method/verb you want to make the request.
---@param data string The http request payload you want to sent. Leave empty: ```""``` if you want to send no data.
---@return FicsIt_Networks.Components.Future ReturnValue
function InternetCard:request(url, method, data) end


--- A Internet Card!
---@class FicsIt_Networks.Components.FINComputerMod.InternetCard_C : FicsIt_Networks.Components.FINComputerMod.FINInternetCard
local InternetCard_C = {}