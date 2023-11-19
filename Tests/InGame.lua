local function test1(bool)
    return bool
end

local thread1 = coroutine.create(test1)
print(coroutine.resume(thread1, false))



local function test2(bool)
    error("test error")
end

local thread2 = coroutine.create(test2)
print(coroutine.resume(thread2, false))



local function test3(bool)
    return bool, 2
end

local thread3 = coroutine.create(test3)
print(coroutine.resume(thread3, false))



local function test4(bool)
    return bool, 2, 3
end

local thread4 = coroutine.create(test4)
print(coroutine.resume(thread4, false))

-- Standard Lua 5.4 Outputs:
-- ```text
-- true	false
-- false	[Source]:[line]: test error
-- true	false	2
-- true	false	2	3
-- ```

-- In Update 7 before Update 8 comp.
-- You get with in the mod back:
-- ```text
-- true
-- false	[Source]:[line]: test error
-- true
-- true
-- ```

-- And now after the Update 8 comp.
-- You get:
-- ```text
-- [DateTimeStamp] [Info]
-- [DateTimeStamp] [Info]
-- [DateTimeStamp] [Info] 2
-- [DateTimeStamp] [Info] 2 3
-- ```
