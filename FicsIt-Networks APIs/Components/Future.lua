---@meta

--- A Future struct MAY BE HANDLED BY CPU IMPLEMENTATION diffrently, generaly, this is used to make resources available on a later point in time. Like if data won't be available right away and you have to wait for it to process first. Like when you do a HTTP Request, then it takes some time to get the data from the web server. And sinve we don't want to halt the game and wait for the data, you can use a future to check if the data is available, or let just the Lua Code wait, till the data becomes available.
---@class FicsIt_Networks.Components.Future
local Future = {}

--- Waits for the future to finish processing and returns the result.
--- ### Flags:
--- * Unkown
---@async
---@return ... data
function Future:await()
end

--- Gets the data.
--- ### Flags:
--- * Unkown
---@return ... data
function Future:get()
end

--- Checks if the Future is done processing.
--- ### Flags:
--- * Unkown
---@return boolean isDone
function Future:canGet()
end
