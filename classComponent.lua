--[=[
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(packages.Knit)
local Signal = require(Knit.Util.Signal)
local Symbol = require(Knit.Util.Symbol)
local Promise = require(Knit.Util.Promise)
local Trove = require(Knit.Util.Trove)

local _tableIndex = {}
_tableIndex.__index = _tableIndex

do
	local function onRejectMethods(rejectTable : {})
		if type(rejectTable) ~= "table" then error(type(rejectTable).."doit être une table") end
		error(`{table.unpack(rejectTable)} ,{debug.traceback("possède une erreur",2)}`)
	end
	
	--[=[
		```lua
			_tableIndex.new(className) = crée une class : {}
		
			local ServerStorage = game:GetService("ServerStorage")
			local moduleScript = require(ServerStorage.Services.Components.old._test.ModuleScript)

			local newClass = moduleScript.methods.new("Bonjour")
			print(newClass) -> {[1] = "Bonjour"}
		```
	]=]
	
	function _tableIndex.new(className)
		local self = setmetatable({},_tableIndex)
		if self[className] ~= nil then return onRejectMethods(self) end
		self.class = className
		return self
	end
	
	--[=[
		```lua
			_tableIndex.class(class) = class = newClass (table: {})
			local ServerStorage = game:GetService("ServerStorage")
			local moduleScript = require(ServerStorage.Services.Components.old._test.ModuleScript)

			local newClass = moduleScript.methods.new("Bonjour")
			local getClass = moduleScript.methods.class(newClass)
			print(getClass) -> = {total = 1,value = {[1]  = "Bonjour" } }

		```
	]=]
	
	function _tableIndex.get(self,a1,a2)
		if type(a1) ~= "number" then return onRejectMethods({a1,a2}) end
		self["lenght ="] = a1
		self[tostring(a2).."main ="] = a2
		local data = {total = self["lenght ="],value = self[tostring(a2).."main ="]}
		return data 		
	end
	
	local function callback(self,...)
		local t = (...)
		local n:number = table.getn(t)
		return self:get(n,t)
	end

	
	local function _currentClass(self,class)
		if (self.class ~= class) then return onRejectMethods(self) end
		return callback(self,{self.class})
	end
	
	function _tableIndex.class(self)
		return _currentClass(self,self.class)
	end

end

local main = {}
main.__index = main
main.methods = _tableIndex

return main
