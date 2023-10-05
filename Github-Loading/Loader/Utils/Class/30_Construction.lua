local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Modifier.Metatable
local Metatable = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class/Metatable"][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@alias Utils.Class.ConstructionState
---|"constructing"
---|"waiting"
---|"running"
---|"finished"
---|"deconstructed"

---@param class object
---@param classMetatable Utils.Class.Metatable
---@param baseClass object
---@param baseClassMetatable Utils.Class.Metatable
---@param ... any
local function executeConstructor(class, classMetatable, baseClass, baseClassMetatable, ...)
    local constructor = classMetatable.MetaMethods.Constructor
    if not classMetatable.HasConstructor then
        baseClass = baseClass()
        return
    end

    ---@cast constructor fun(self: object, ...: any)
    if baseClassMetatable.HasConstructor then
        if #{ ... } == 0 then
            constructor(class, baseClass)
        else
            constructor(class, ..., baseClass)
        end
        if baseClassMetatable.ConstructionState ~= "finished" then
            error("base class from class '" .. classMetatable.Type .. "' did not get constructed or didn't finish", 3)
        end
        return
    end

    baseClass = baseClass()
    constructor(class, ...)
end

---@param class object
---@param ... any
local function construct(class, ...)
    class = Table.Copy(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)
    classMetatable.__call = nil
    classMetatable.ConstructionState = "running"
    Metatable.FreeMetaMethods(classMetatable)
    setmetatable(class, classMetatable)

    local baseClass = classMetatable.Base
    local baseClassMetatable = getmetatable(baseClass)
    executeConstructor(class, classMetatable, baseClass, baseClassMetatable, ...)

    Metatable.UnBlockMetaMethods(classMetatable)
    setmetatable(class, classMetatable)
    classMetatable.ConstructionState = "finished"
    return class
end

---@param class object
local function deconstruct(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)

    if classMetatable.ConstructionState ~= "finished" then
        return
    end

    if classMetatable.HasDeconstructor then
        classMetatable.MetaMethods.Deconstructor(class)
    end

    local baseClass = classMetatable.Base
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(classMetatable.Base)
    baseClassMetatable.__gc(baseClass)
end

---@param classMetatable Utils.Class.Metatable
---@param baseClass object
local function addBaseClass(classMetatable, baseClass)
    classMetatable.Base = baseClass
    classMetatable.IsBaseClass = false
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(baseClass)
    baseClassMetatable.IsBaseClass = true
end

---@param metatable Utils.Class.Metatable
local function addConstructor(metatable)
    metatable.__call = construct

    if metatable.MetaMethods.Constructor then
        metatable.HasConstructor = true
        return
    end

    metatable.HasConstructor = false
    ---@type Utils.Class.Metatable
    local baseClassMetatable = getmetatable(metatable.Base)
    if baseClassMetatable.HasConstructor then
        error(
            "can not create class: '" ..
            metatable.Type ..
            "' with no constructor when the base class: '" .. baseClassMetatable.Type .. "' has a constructor.", 3)
    end
end

---@param metatable Utils.Class.Metatable
local function addDeconstructor(metatable)
    metatable.__gc = deconstruct

    if metatable.MetaMethods.Deconstructor then
        metatable.HasDeconstructor = true
        return
    end

    metatable.HasDeconstructor = false
end

---@class Utils.Class.Construction
local Construction = {}

---@param metatable Utils.Class.Metatable
---@param baseClass object
function Construction.Prepare(metatable, baseClass)
    addBaseClass(metatable, baseClass)
    addConstructor(metatable)
    addDeconstructor(metatable)
end

---@param class object
function Construction.Deconstruct(class)
    ---@type Utils.Class.Metatable
    local classMetatable = getmetatable(class)

    if not classMetatable.__gc then
        return
    end

    classMetatable.__gc(class)

    classMetatable.__gc = nil
    Metatable.Deconstruct(classMetatable)
    classMetatable.ConstructionState = "deconstructed"
end

return Construction
