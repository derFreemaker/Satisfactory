---@class Utils.Function
local Function = {}

---@param success boolean
---@param ... any
---@return boolean success, table data
local function extractSuccess(success, ...)
	return success, {...}
end
---@param func function
---@param ... any
---@return thread thread, boolean success, any[] returns
function Function.InvokeProtected(func, ...)
	local function invokeFunc(...)
		coroutine.yield(func(...))
	end
	local thread = coroutine.create(invokeFunc)
	local results = {coroutine.resume(thread, ...)}
	local success,
		filteredResults = extractSuccess(table.unpack(results))
	return thread, success, filteredResults
end

return Function
