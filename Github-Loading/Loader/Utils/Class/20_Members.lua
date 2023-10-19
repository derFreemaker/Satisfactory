local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class Utils.Class.MetaMethods
---@field __init (fun(self: object, ...))? self(...) before construction
---@field __gc fun(self: object)? Class.Deconstruct(self) or garbageCollection
---@field __call (fun(self: object, ...) : ...)? self(...) after construction
---@field __index (fun(class, key) : any)? xxx = self.xxx | self[xxx]
---@field __newindex fun(class, key, value)? self.xxx | self[xxx] = xxx
---@field __tostring (fun(t):string)? tostring(self)
---@field __add (fun(self: object, other: any) : any)? (self) + (value)
---@field __sub (fun(self: object, other: any) : any)? (self) - (value)
---@field __mul (fun(self: object, other: any) : any)? (self) * (value)
---@field __div (fun(self: object, other: any) : any)? (self) / (value)
---@field __mod (fun(self: object, other: any) : any)? (self) % (value)
---@field __pow (fun(self: object, other: any) : any)? (self) ^ (value)
---@field __idiv (fun(self: object, other: any) : any)? (self) // (value)
---@field __band (fun(self: object, other: any) : any)? (self) & (value)
---@field __bor (fun(self: object, other: any) : any)? (self) | (value)
---@field __bxor (fun(self: object, other: any) : any)? (self) ~ (value)
---@field __shl (fun(self: object, other: any) : any)? (self) << (value)
---@field __shr (fun(self: object, other: any) : any)? (self) >> (value)
---@field __concat (fun(self: object, other: any) : any)? (self) .. (value)
---@field __eq (fun(self: object, other: any) : any)? (self) == (value)
---@field __lt (fun(t1: any, t2: any) : any)? (self) < (value)
---@field __le (fun(t1: any, t2: any) : any)? (self) <= (value)
---@field __unm (fun(self: object) : any)? -(self)
---@field __bnot (fun(self: object) : any)?  ~(self)
---@field __len (fun(self: object) : any)? #(self)
---@field __pairs (fun(self: object) : ((fun(t: table, key: any) : key: any, value: any), t: table, startKey: any))? pairs(self)
---@field __ipairs (fun(self: object) : ((fun(t: table, key: number) : key: number, value: any), t: table, startKey: number))? ipairs(self)

---@type Dictionary<string, boolean>
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

---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function isNormalFunction(typeInfo, name, func)
	if Table.ContainsKey(metaMethods, name) then
		typeInfo.MetaMethods[name] = func
		return
	end

	typeInfo.Members[name] = func
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function isNormalMember(typeInfo, name, value)
	if type(value) == 'function' then
		isNormalFunction(typeInfo, name, value)
		return
	end

	typeInfo.Members[name] = value
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function isStaticMember(typeInfo, name, value)
	typeInfo.Static[name] = value
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function sortMember(typeInfo, key, value)
	if type(key) == 'string' then
		local splittedKey = String.Split(key, '__')
		if Table.Contains(splittedKey, 'Static') then
			isStaticMember(typeInfo, key, value)
			return
		end

		isNormalMember(typeInfo, key, value)
		return
	end

	typeInfo.Members[key] = value
end


---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function UpdateMethods(typeInfo, name, func)
	if Table.ContainsKey(typeInfo.Members, name) then
		error("trying to extend already existing meta method: " .. name)
	end

	typeInfo.MetaMethods[name] = func

	for _, instance in ipairs(typeInfo.Instances) do
		local instanceMetatable = getmetatable(instance)

		if not Table.ContainsKey(instanceMetatable, name) then
			rawset(instanceMetatable, name, func)
		end
	end
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function UpdateMember(typeInfo, key, value)
	if Table.ContainsKey(typeInfo.Members, key) then
		error("trying to extend already existing member: " .. tostring(key))
	end

	typeInfo.Members[key] = value

	for _, instance in ipairs(typeInfo.Instances) do
		if not Table.ContainsKey(instance, key) then
			rawset(instance, key, value)
		end
	end
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function extendIsStaticMember(typeInfo, name, value)
	if Table.ContainsKey(typeInfo.Static, name) then
		error("trying to extend already existing static member: " .. name)
	end

	typeInfo.Static[name] = value
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param func function
local function extendIsNormalFunction(typeInfo, name, func)
	if Table.ContainsKey(metaMethods, name) then
		UpdateMethods(typeInfo, name, func)
	end

	UpdateMember(typeInfo, name, func)
end

---@param typeInfo Utils.Class.Type
---@param name string
---@param value any
local function extendIsNormalMember(typeInfo, name, value)
	if type(value) == 'function' then
		extendIsNormalFunction(typeInfo, name, value)
		return
	end

	UpdateMember(typeInfo, name, value)
end

---@param typeInfo Utils.Class.Type
---@param key any
---@param value any
local function extendMember(typeInfo, key, value)
	if type(key) == 'string' then
		local splittedKey = String.Split(key, '__')
		if Table.Contains(splittedKey, 'Static') then
			extendIsStaticMember(typeInfo, key, value)
			return
		end

		extendIsNormalMember(typeInfo, key, value)
		return
	end

	if not Table.ContainsKey(typeInfo.Members, key) then
		typeInfo.Members[key] = value
	end
end

---@class Utils.Class.MembersHandler
local MembersHandler = {}

---@param data table
---@param typeInfo Utils.Class.Type
function MembersHandler.SortMembers(data, typeInfo)
	typeInfo.Static = {}
	typeInfo.MetaMethods = {}
	typeInfo.Members = {}

	for key, value in pairs(data) do
		sortMember(typeInfo, key, value)
	end

	typeInfo.HasConstructor = typeInfo.MetaMethods.__init ~= nil
	typeInfo.HasDeconstructor = typeInfo.MetaMethods.__gc ~= nil
	typeInfo.HasIndex = typeInfo.MetaMethods.__index ~= nil
	typeInfo.HasNewIndex = typeInfo.MetaMethods.__newindex ~= nil
end

---@param data table
---@param typeInfo Utils.Class.Type
function MembersHandler.ExtendMembers(data, typeInfo)
	for key, value in pairs(data) do
		extendMember(typeInfo, key, value)
	end

	typeInfo.HasConstructor = typeInfo.MetaMethods.__init ~= nil
	typeInfo.HasDeconstructor = typeInfo.MetaMethods.__gc ~= nil
	typeInfo.HasIndex = typeInfo.MetaMethods.__index ~= nil
	typeInfo.HasNewIndex = typeInfo.MetaMethods.__newindex ~= nil
end

return MembersHandler
