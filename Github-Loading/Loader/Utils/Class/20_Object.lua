local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class Utils.Class.ObjectMetaMethods
---@field protected __init (fun(self: object, ...))? self(...) before construction
---@field protected __call (fun(self: object, ...) : ...)? self(...) after construction
---@field protected __gc fun(self: object)? Utils.Class.Deconstruct(self) or garbageCollection
---@field protected __add (fun(self: object, other: any) : any)? (self) + (value)
---@field protected __sub (fun(self: object, other: any) : any)? (self) - (value)
---@field protected __mul (fun(self: object, other: any) : any)? (self) * (value)
---@field protected __div (fun(self: object, other: any) : any)? (self) / (value)
---@field protected __mod (fun(self: object, other: any) : any)? (self) % (value)
---@field protected __pow (fun(self: object, other: any) : any)? (self) ^ (value)
---@field protected __idiv (fun(self: object, other: any) : any)? (self) // (value)
---@field protected __band (fun(self: object, other: any) : any)? (self) & (value)
---@field protected __bor (fun(self: object, other: any) : any)? (self) | (value)
---@field protected __bxor (fun(self: object, other: any) : any)? (self) ~ (value)
---@field protected __shl (fun(self: object, other: any) : any)? (self) << (value)
---@field protected __shr (fun(self: object, other: any) : any)? (self) >> (value)
---@field protected __concat (fun(self: object, other: any) : any)? (self) .. (value)
---@field protected __eq (fun(self: object, other: any) : any)? (self) == (value)
---@field protected __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field protected __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field protected __unm (fun(self: object) : any)? -(self)
---@field protected __bnot (fun(self: object) : any)?  ~(self)
---@field protected __len (fun(self: object) : any)? #(self)
---@field protected __pairs (fun(t: table) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field protected __ipairs (fun(t: table) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)
---@field protected __tostring (fun(t):string)? tostring(self)
---@field protected __index (fun(class, key) : any)? xxx = self.xxx | self[xxx]
---@field protected __newindex fun(class, key, value)? self.xxx | self[xxx] = xxx

---@type table<string, boolean>
local metaMethods = {
	__init = true,
	__gc = true,
	__call = true,
	__index = true,
	__newindex = true,
	__pairs = true,
	__ipairs = true,
	__tostring = true,
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
	__le = true
}

---@class object : Utils.Class.ObjectMetaMethods, function
local Object = {}

---@protected
---@return string typeName
function Object:__tostring()
	return typeof(self).Name
end

---@protected
---@return string
function Object.__concat(left, right)
	return tostring(left) .. tostring(right)
end

---@class object.Modify
---@field DisableCustomIndexing boolean?

---@protected
---@param modify object.Modify
function Object:__modifyBehavior(modify)
	local metatable = getmetatable(self)

	if modify.DisableCustomIndexing ~= nil then
		metatable.Type.IndexingDisabled = modify.DisableCustomIndexing
	end
end

----------------------------------------
-- Type Info
----------------------------------------

local typeInfo = {}
---@cast typeInfo Utils.Class.Type

typeInfo.Name = 'object'

typeInfo.Static = {}
typeInfo.MetaMethods = {}
typeInfo.Members = {}

for key, value in pairs(Object) do
	if metaMethods[key] then
		typeInfo.MetaMethods[key] = value
	else
		if type(key) == 'string' then
			local splittedKey = String.Split(key, '__')
			if Table.Contains(splittedKey, 'Static') then
				typeInfo.Static[key] = value
			else
				typeInfo.Members[key] = value
			end
		else
			typeInfo.Members[key] = value
		end
	end
end

typeInfo.HasConstructor = false
typeInfo.HasDeconstructor = false
typeInfo.HasIndex = false
typeInfo.HasNewIndex = false

typeInfo.Instances = setmetatable({}, { __mode = 'v' })

return typeInfo
