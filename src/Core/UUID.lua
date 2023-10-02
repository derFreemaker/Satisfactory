local math = math
local string = string

---@class Core.UUID : object
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
        chars[i] = string.byte(string.format("%x", math.random(0, 0xf) or math.random(8, 0xb)))
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed()
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

    emptyUUID = UUID({ 0, 0, 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 0 })

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
    error("Core.UUID is completely read only")
end

---@private
---@param other Core.UUID
---@return boolean isSame
function UUID:__eq(other)
    if type(other) ~= "table" or not other.GetType or other:GetType() ~= "Core.UUID" then
        local typeString = type(other)
        if type(other) == "table" and other.GetType then
            typeString = other:GetType()
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

return Utils.Class.CreateClass(UUID, 'Core.UUID')
