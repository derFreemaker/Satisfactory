local function testFunc()
    print("Test Hi")
    return coroutine.yield(nil)
end

---@param success boolean
---@param ... any
---@return boolean success, table returns
local function extractData(success, ...)
    return success, { ... }
end

local testThread = coroutine.create(testFunc)

local success, results = extractData(coroutine.resume(testThread))

print(success)
for key, value in pairs(results) do
    print(key, value)
end

local noError, errorObject = coroutine.close(testThread)

print(noError, errorObject)