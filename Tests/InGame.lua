---@type FIN.Components.NetworkCard_C
local networkCard = computer.getPCIDevices(findClass("NetworkCard_C"))[1]

function InvokeProtected(func, ...)
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

local function foo()
    print(networkCard, networkCard.hash)
end

local function foo2()
    print(InvokeProtected(foo))
end

local function foo3()
    print(InvokeProtected(foo2))
end

local function foo4()
    print(InvokeProtected(foo3))
end

local function foo5()
    print(InvokeProtected(foo4))
end

local function foo6()
    print(InvokeProtected(foo5))
end

local function foo7()
    print(InvokeProtected(foo6))
end

local function foo8()
    print(InvokeProtected(foo7))
end

local function foo9()
    print(InvokeProtected(foo8))
end

local function foo10()
    print(InvokeProtected(foo9))
end

InvokeProtected(foo10)
