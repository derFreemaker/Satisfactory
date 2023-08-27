local LoadedLoaderFiles = table.pack(...)[1]
---@type object
local Object = LoadedLoaderFiles["/Github-Loading/Loader/Object"][1]

---@class Utils
local Utils = {}

---@param ms number defines how long the function will wait in Milliseconds
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

---@class Utils.Function
local Function = {}

---@param func function
---@param parent any
---@param args any[]
---@return any[] returns
function Function.DynamicInvoke(func, parent, args)
    local results
    if parent ~= nil then
        results = table.pack(func(parent, table.unpack(args)))
    else
        results = table.pack(func(table.unpack(args)))
    end
    return results
end

---@param func function
---@param parent any
---@param ... any
---@return thread thread, boolean success, any[] returns
function Function.InvokeProtected(func, parent, ...)
    local function invokeFunc(...)
        coroutine.yield(func(...))
    end
    local thread = coroutine.create(invokeFunc)
    local results
    if parent ~= nil then
        results = table.pack(coroutine.resume(thread, parent, ...))
    else
        results = table.pack(coroutine.resume(thread, ...))
    end
    coroutine.close(thread)
    local success = Utils.Table.Retrive(results, 1)
    return thread, success, results
end

---@param func function
---@param parent any
---@param args any[]
---@return thread thread, boolean success, any[] returns
function Function.DynamicInvokeProtected(func, parent, args)
    return Function.InvokeProtected(func, parent, table.unpack(args))
end

Utils.Function = Function
---@class Utils.File
local File = {}

---@alias Utils.File.writeModes
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@param path string
---@param mode Utils.File.writeModes
---@param data string?
---@param createPath boolean?
function File.Write(path, mode, data, createPath)
    data = data or ""
    createPath = createPath or false

    local fileName = filesystem.path(3, path)
    local folderPath = path:gsub(fileName, "")
    if not filesystem.exists(folderPath) then
        if not createPath then
            error("folder does not exists: '" .. folderPath .. "'", 2)
        end
        filesystem.createDir(folderPath)
    end

    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

---@param path string
---@return string?
function File.ReadAll(path)
    if not filesystem.exists(path) then
        return nil
    end
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(8192)
        if not buf then
            break
        end
        str = str .. buf
    end
    file:close()
    return str
end

---@param path string
function File.Clear(path)
    if not filesystem.exists(path) then
        return
    end
    local file = filesystem.open(path, "w")
    file:write("")
    file:close()
end

Utils.File = File
---@class Utils.Table
local Table = {}

---@param t table
---@return table table
function Table.Copy(t)
    local seen = {}

    ---@param obj any?
    ---@return any
    local function copyTable(obj)
        if obj == nil then return nil end
        if seen[obj] then return seen[obj] end

        local copy = {}
        seen[obj] = copy
        setmetatable(copy, copyTable(getmetatable(obj)))

        for key, value in next, obj, nil do
            key = (type(key) == "table") and copyTable(key) or key
            value = (type(value) == "table") and copyTable(value) or value
            copy[key] = value
        end

        return copy
    end

    return copyTable(t)
end

--- removes all margins like table[1] = "1", table[2] = nil, table[3] = "3" -> table[2] would be removed meaning table[3] would be table[2] now and so on. Removes no named values (table["named"]). And sets n to number of cleaned results. Should only be used on arrays really.
---@generic T
---@param t T[]
---@return T[] table cleaned table
---@return integer numberOfCleanedValues
function Table.Clean(t)
    ---@generic T
    ---@param tableToLook T[]
    ---@param index integer
    ---@return integer
    local function findNearestNilValueDownward(tableToLook, index)
        if tableToLook[index] == nil then
            return index
        end
        return findNearestNilValueDownward(tableToLook, index - 1)
    end

    local numberOfCleanedValues = 0
    for index = 1, #t, 1 do
        local value = t[index]
        if index ~= 1 and type(index) == "number" then
            local nearestNilValue = findNearestNilValueDownward(t, index)
            t[nearestNilValue] = value
            t[index] = nil
            numberOfCleanedValues = numberOfCleanedValues + 1
        elseif value ~= nil and type(index) == "number" then
            numberOfCleanedValues = numberOfCleanedValues + 1
        end
    end
    return t, numberOfCleanedValues
end

--- Gets the value out of the array at specifyed index if not nil.
--- And fills the removed value by sorting the array.
--- Uses ```Table.Clean``` so ```t.n``` will be used.
---@generic T
---@param t T[]
---@param index integer
---@return T value
function Table.Retrive(t, index)
    local value = t[index]
    t[index] = nil
    t = Table.Clean(t)
    return value
end

---@param t table
---@return integer count
function Table.Count(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

Utils.Table = Table
---@class Utils.Class
local Class = {}
Class.SearchValueInBase = {}


local metatableMethods = {
    __add = true,
    __sub = true,
    __mul = true,
    __div = true,
    __mod = true,
    __pow = true,
    __unm = true,
    __idiv = true,
    __band = true,
    __bor = true,
    __bxor = true,
    __bnot = true,
    __shl = true,
    __shr = true,
    __concat = true,
    __len = true,
    __eq = true,
    __lt = true,
    __le = true,
    __index = true,
    __newindex = true,
    __pairs = true,
    __ipairs = true,
    __tostring = true,
    __gc = true
}

---@param obj table
---@param metatable Utils.Class.Metatable
local function HideMembers(obj, metatable)
    ---@diagnostic disable-next-line
    metatable.HiddenMembers = {}
    for key, value in pairs(obj) do
        if not metatable.HiddenMembers[key] then
            -- //TODO: maybe remove function wrapper
            -- if type(value) == "function" then
            --     local func = value
            --     local function call(class, ...)
            --         return func(class, ...)
            --     end
            --     value = call
            -- end
            metatable.HiddenMembers[key] = value
            obj[key] = nil
        end
    end
end

---@param obj table
---@param metatable Utils.Class.Metatable
local function ShowMembers(obj, metatable)
    for key, value in pairs(metatable.HiddenMembers) do
        if metatableMethods[key] then
            metatable[key] = value
        else
            rawset(obj, key, value)
        end
    end
    metatable.HiddenMembers = nil
    setmetatable(obj, metatable)
end


---@param class object
---@param key any
local function index(class, key)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.ConstructorState == 1 then
        error("cannot get values if class: ".. classMetatable.Type .." was not constructed", 2)
    end
    local value
    if classMetatable.HasIndex then
        value = classMetatable.Index(class, key)
    else
        value = rawget(class, key) or Class.SearchValueInBase
    end
    if value ~= Class.SearchValueInBase then
        return value
    end
    local baseClass = classMetatable.Base
    value = baseClass[key]
    return value
end
---@param baseClass table
---@param metatable Utils.Class.Metatable
local function AddBaseClass(baseClass, metatable)
    metatable.Base = baseClass
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(baseClass)
    baseClassMetatable.IsBaseClass = true
    metatable.HasBaseClass = true

    local __index = metatable.HiddenMembers.__index
    if type(__index) == "function" then
        metatable.Index = __index
        metatable.HiddenMembers.__index = nil
        metatable.HasIndex = true
    else
        metatable.HasIndex = false
    end

    metatable.__index = index
end


---@param class object
---@param key any
---@param value any
local function newIndex(class, key, value)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.ConstructorState == 1 then
        error("cannot assign values if class: " .. classMetatable.Type .. " was not constructed", 2)
    end
    if classMetatable.HasNewIndex then
        classMetatable.__newindex = classMetatable.NewIndex
        classMetatable.NewIndex(class, key, value)
        classMetatable.NewIndex = nil
        return
    end
    rawset(class, key, value)
end
---@param metatable Utils.Class.Metatable
local function AddNewIndex(metatable)
    local __newindex = metatable.HiddenMembers.__newindex
    if type(__newindex) == "function" then
        metatable.NewIndex = __newindex
        metatable.HiddenMembers.__newindex = nil
        metatable.HasNewIndex = true
    else
        metatable.HasNewIndex = false
    end

    metatable.__newindex = newIndex
end


---@generic TBaseClass
---@param class TBaseClass
---@return TBaseClass
local function CopyIfNotBaseClass(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.IsBaseClass then
        return class
    end
    return Utils.Table.Copy(class)
end
---@param metatable Utils.Class.Metatable
local function AddConstructor(metatable)
    local constructorKey = metatable.Type

    ---@type fun(self: object, ...: any, base: object | nil)
    local constructor = metatable.HiddenMembers[constructorKey]

    ---@param class object
    ---@param ... any
    local function construct(class, ...) ---@diagnostic disable-line: redefined-local
        class = CopyIfNotBaseClass(class)
        ---@type Utils.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__call = nil
        classMetatable.ConstructorState = 2
        ShowMembers(class, classMetatable)

        if classMetatable.HasBaseClass then
            local baseClass = classMetatable.Base
            ---@type Utils.Class.Metatable
            local baseClassMetatable = getmetatable(baseClass)

            if classMetatable.HasConstructor and baseClassMetatable.HasConstructor then
                if #{ ... } == 0 then
                    constructor(class, baseClass)
                else
                    constructor(class, ..., baseClass)
                end
                if baseClassMetatable.ConstructorState ~= 3 then
                    error(
                    "base class from class: '" .. classMetatable.Type .. "' did not get constructed or didn't finish", 2)
                end
            elseif classMetatable.HasConstructor and not baseClassMetatable.HasConstructor then
                baseClass = baseClass()
                constructor(class, ...)
            else
                baseClass = baseClass()
            end
        elseif classMetatable.HasConstructor then
            constructor(class, ...)
        end

        classMetatable.ConstructorState = 3
        return class
    end

    metatable.__call = construct
    metatable.ConstructorState = 1
    if type(constructor) == "function" then
        metatable.HasConstructor = true
        metatable.HiddenMembers[constructorKey] = nil
        return
    end

    metatable.HasConstructor = false
    if metatable.HasBaseClass then
        ---@type Utils.Class.Metatable
        local baseClassMetatable = getmetatable(metatable.Base)
        if baseClassMetatable.HasConstructor then
            error("create class: '" .. metatable.Type .. "' with no constructor when the base class has a constructor", 2)
        end
    end
end


---@param metatable Utils.Class.Metatable
local function AddDeconstructor(metatable)
    local deconstructorKey = "_" .. metatable.Type
    ---@type fun(class: object)?
    local deconstructor = metatable.HiddenMembers[deconstructorKey]

    ---@param class object
    local function deconstruct(class)
        ---@cast deconstructor fun(class: object)

        ---@type Utils.Class.Metatable
        local classMetatable = getmetatable(class)
        classMetatable.__gc = nil

        deconstructor(class)
    end

    if type(deconstructor) == "function" then
        metatable.HiddenMembers[deconstructorKey] = nil
        metatable.HiddenMembers.__gc = deconstruct
        metatable.HasDeconstructor = true
        return
    end
    metatable.HasDeconstructor = false
end


---@generic TClass
---@generic TBaseClass
---@param class TClass
---@param classType string
---@param baseClass TBaseClass
---@return TClass
function Class.CreateSubClass(class, classType, baseClass)
    baseClass = Utils.Table.Copy(baseClass)
    if not Class.HasClassOfType(baseClass, "object") then
        error("base class argument is not a class", 2)
    end
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable == nil then
        ---@diagnostic disable-next-line
        classMetatable = {}
        setmetatable(class, classMetatable)
    end
    classMetatable.Type = classType
    classMetatable.IsBaseClass = false
    ---@cast class table
    HideMembers(class, classMetatable)
    AddNewIndex(classMetatable)
    AddBaseClass(baseClass, classMetatable)
    AddDeconstructor(classMetatable)
    AddConstructor(classMetatable)
    setmetatable(class, classMetatable)
    return class
end

---@generic TClass
---@param class TClass
---@param classType string
---@return TClass
function Class.CreateClass(class, classType)
    return Class.CreateSubClass(class, classType, Object)
end

---@param class object
---@param classType string
---@return boolean hasClassOfType
function Class.HasClassOfType(class, classType)
    ---@type Utils.Class.Metatable
    local metatable = getmetatable(class)
    if metatable.Type == classType then
        return true
    end
    if metatable.HasBaseClass then
        return Class.HasClassOfType(metatable.Base, classType)
    end
    return false
end

---@param class object
---@return object? base
function Class.GetBaseClass(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    if classMetatable.HasBaseClass then
        return classMetatable.Base
    end
    return nil
end

Utils.Class = Class

return Utils