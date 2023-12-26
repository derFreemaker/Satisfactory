---@meta

---@class FIN.Components.FINInternetCard : FIN.Components.FINComputerModule, FIN.PCIDevice
local InternetCard = {}

---@alias FIN.Components.FINComputerMod.FINInternetCard.HttpMethods
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
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Variable Arguments - Can have any additional arguments as described.
---@param url string The Url for which you want to make an HTTP Request.
---@param method FIN.Components.FINComputerMod.FINInternetCard.HttpMethods The http request method/verb you want to make the request.
---@param data string The http request payload you want to sent. Leave empty: ```""``` if you want to send no data.
---@return FIN.Components.Future responseFuture returns `integer code, string data`
function InternetCard:request(url, method, data)
end
