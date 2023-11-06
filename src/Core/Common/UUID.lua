local math = math
local string = string

---@class Core.UUID : Core.Json.Serializable
---@field private m_head number[]
---@field private m_body number[]
---@field private m_tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

---@type integer
UUID.Static__GeneratedCount = 1

--- Replaces 'x' in template with random character.
---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}
    for i = 1, amount, 1 do
        local j = math.random(1, 3)

        if j == 1 then
            chars[i] = math.random(48, 57)
        elseif j == 2 then
            chars[i] = math.random(65, 90)
        elseif j == 3 then
            chars[i] = math.random(97, 122)
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
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

    self:__modifyBehavior({ DisableCustomIndexing = true })
    self.m_head = headOrSring
    self.m_body = body
    self.m_tail = tail
    self:__modifyBehavior({ DisableCustomIndexing = false })
end

---@param other Core.UUID
---@return boolean isSame
function UUID:Equals(other)
    for i, char in ipairs(self.m_head) do
        if char ~= other.m_head[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_body) do
        if char ~= other.m_body[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_tail) do
        if char ~= other.m_tail[i] then
            return false
        end
    end

    return true
end

function UUID:ToString()
    local str = ""

    for _, char in ipairs(self.m_head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_tail) do
        str = str .. string.char(char)
    end

    return str
end

function UUID:Serialize()
    return self:ToString()
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
function UUID:__tostring()
    return self:ToString()
end

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
