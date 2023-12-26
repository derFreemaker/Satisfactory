---@class Utils.Function
local Function = {}

---@param func function
---@param ... any
---@return boolean success, string? error, any[] returns
function Function.InvokeProtected(func, ...)
	local results = {}
	local function invokeFunc(...)
		results = { func(...) }
	end
	local thread = coroutine.create(invokeFunc)
	local success, error = coroutine.resume(thread, ...)
	if not success then
		error = debug.traceback(thread, error)
	end
	coroutine.close(thread)
	return success, error, results
end

---@param message string
function Function.LogTraceback(message)
	if not log then
		return
	end

	log(debug.traceback(message or "traceback", 2))
end

return Function
