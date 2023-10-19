local math = math
local string = string
local random = math.random

---@class Core.UUID : Core.Json.Serializable
---@field private _Head number[]
---@field private _Body number[]
---@field private _Tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

---@type integer
UUID.Static__GeneratedCount = 0

--- Replaces 'x' in template with random character.
---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}
    for i = 1, amount, 1 do
        local j = random(1, 3)

        if j == 1 then
            chars[i] = random(48, 57)
        elseif j == 2 then
            chars[i] = random(65, 90)
        elseif j == 3 then
            chars[i] = random(97, 122)
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(computer.millis() + computer.time() + UUID.Static__GeneratedCount)
    local head = generateRandomChars(6)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(6)
    return UUID(head, body, tail)
end

local emptyHead = { 48, 48, 48, 48, 48, 48 }
local emptyBody = { 48, 48, 48, 48 }
local emptyTail = { 48, 48, 48, 48, 48, 48 }

---@return number[] head, number[] body, number[] tail
local function getEmptyData()
    return emptyHead, emptyBody, emptyTail
end

local emptyUUID = nil
---@return Core.UUID
function UUID.Static__Empty()
    if emptyUUID then
        return emptyUUID
    end

    emptyUUID = UUID(getEmptyData())

    return UUID.Static__Empty()
end

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@return number[] head, number[] body, number[] tail
local function parse(str)
    local splitedStr = Utils.String.Split(str, "-")
    if not splitedStr[1] or splitedStr[1]:len() ~= 6
        or not splitedStr[2] or splitedStr[2]:len() ~= 4
        or not splitedStr[3] or splitedStr[3]:len() ~= 6
    then
        error("Unable to parse: " .. tostring(str))
        return getEmptyData()
    end

    local head = convertStringToCharArray(splitedStr[1])
    local body = convertStringToCharArray(splitedStr[2])
    local tail = convertStringToCharArray(splitedStr[3])

    return head, body, tail
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
    return UUID(parse(str))
end

---@private
---@param headOrSring number[]
---@param body number[]
---@param tail number[]
function UUID:__init(headOrSring, body, tail)
    if type(headOrSring) == "string" then
        headOrSring, body, tail = parse(headOrSring)
    end

    self._Head = headOrSring
    self._Body = body
    self._Tail = tail
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
---@param other Core.UUID
---@return boolean isSame
function UUID:__eq(other)
    if type(other) ~= "table" or not other.Static__GetType or other:Static__GetType() ~= "Core.UUID" then
        local typeString = type(other)
        if type(other) == "table" and other.Static__GetType then
            typeString = other:Static__GetType().Name
        end
        error("wrong argument #2: (Core.UUID expected; got " .. typeString .. ")")
        return false
    end

    for i, char in ipairs(self._Head) do
        if char ~= other._Head[i] then
            return false
        end
    end

    for i, char in ipairs(self._Body) do
        if char ~= other._Body[i] then
            return false
        end
    end

    for i, char in ipairs(self._Tail) do
        if char ~= other._Tail[i] then
            return false
        end
    end

    return true
end

---@private
function UUID:__tostring()
    local str = ""

    for _, char in ipairs(self._Head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self._Body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self._Tail) do
        str = str .. string.char(char)
    end

    return str
end

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
