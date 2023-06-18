local filesystem = {}

---@param obj any
---@param typeToCheck type
---@param functionName string
---@param parameterPositionBefore integer
---@param parameterPositionAfter integer
function filesystem.checkType(obj, typeToCheck, functionName, parameterPositionBefore, parameterPositionAfter)
    local objType = type(obj)
    if objType == typeToCheck then
        return
    end
    local message = functionName .. "("
    local i = 0
    while i < parameterPositionBefore do
        message = message .. "..., "
        i = i + 1
    end
    message = message .. "expexted '" .. typeToCheck .. "', got '" .. objType .. "'"
    i = 0
    while i < parameterPositionAfter do
        message = message .. ", ..."
        i = i + 1
    end
    message = message .. ")"
    error(message, 2)
end

local function test()
    local test = {}

    filesystem.checkType(test, "string", "test.lol", 0, 1)
end

test()