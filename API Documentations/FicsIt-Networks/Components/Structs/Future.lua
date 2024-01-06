---@meta

--- A Future struct MAY BE HANDLED BY CPU IMPLEMENTATION differently, generally, this is used to make resources available on a later point in time. Like if data won't be available right away and you have to wait for it to process first. Like when you do a HTTP Request, then it takes some time to get the data from the web server. And since we don't want to halt the game and wait for the data, you can use a future to check if the data is available, or let just the Lua Code wait, till the data becomes available.
---@class FIN.Components.Future : FIN.Struct
local Future = {}

--- Waits for the future to finish processing and returns the result.
--- ### Flags:
--- * Unknown
---@async
---@return any ...
function Future:await()
end

--- Gets the data.
--- ### Flags:
--- * Unknown
---@return any ...
function Future:get()
end

--- Checks if the Future is done processing.
--- ### Flags:
--- * Unknown
---@return boolean isDone
function Future:canGet()
end
