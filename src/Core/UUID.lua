local math = math
local string = string
local random = math.random

---@class Core.UUID : Core.Json.Serializable
---@field private head number[]
---@field private body number[]
---@field private tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

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
    math.randomseed(os.time())
    local head = generateRandomChars(6)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(6)
    return UUID(head, body, tail)
end

local emptyUUID = nil
---@return Core.UUID
function UUID.Static__Empty()
    if emptyUUID then
        return emptyUUID
    end

    emptyUUID = UUID({ 48, 48, 48, 48, 48, 48 }, { 48, 48, 48, 48 }, { 48, 48, 48, 48, 48, 48 })

    return UUID.Static__Empty()
end

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
    local splitedStr = Utils.String.Split(str, "-")
    if not splitedStr[1] or splitedStr[1]:len() ~= 6
        or not splitedStr[2] or splitedStr[2]:len() ~= 4
        or not splitedStr[3] or splitedStr[3]:len() ~= 6
    then
        return nil
    end

    local head = convertStringToCharArray(splitedStr[1])
    local body = convertStringToCharArray(splitedStr[2])
    local tail = convertStringToCharArray(splitedStr[3])

    return UUID(head, body, tail)
end

---@private
---@param head number[]
---@param body number[]
---@param tail number[]
function UUID:__init(head, body, tail)
    self.head = head
    self.body = body
    self.tail = tail
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

    for i, char in ipairs(self.head) do
        if char ~= other.head[i] then
            return false
        end
    end

    for i, char in ipairs(self.body) do
        if char ~= other.body[i] then
            return false
        end
    end

    for i, char in ipairs(self.tail) do
        if char ~= other.tail[i] then
            return false
        end
    end

    return true
end

---@private
function UUID:__tostring()
    local str = ""

    for _, char in ipairs(self.head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.tail) do
        str = str .. string.char(char)
    end

    return str
end

--#region - Serializable -

---@return string data
function UUID:Static__Serialize()
    return tostring(self)
end

---@param data string
---@return Core.UUID?
function UUID.Static__Deserialize(data)
    return UUID.Static__Parse(data)
end

--#endregion

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
