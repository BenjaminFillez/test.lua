local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")
local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Thread = require(ReplicatedStorage.Packages.Thread)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Option = require(ReplicatedStorage.Packages.Option)
local ProfilsComponent = require(ServerScriptService.Mains.Modules.DataComponent.ProfilesComponents)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ProfilsAttachment = ProfilsComponent.ProfilesAttach

local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm
local comm = Comm.new(ReplicatedStorage.Packages,"EmitterService")

comm:BindFunction("PurchaseServiceLoaded",function(player : Player,instance) 
	if (player) and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		if (data) then
			local DeathEffectFX = ReplicatedStorage.Packages.Menu["InventoryModule.all"]["inventory.emitter"].DeathEffectsFX
			if (DeathEffectFX:FindFirstChild(instance)) or table.find(data.purchased,instance) then
				return nil	
			else
				local cl = ServerStorage.EffectsEmitter:FindFirstChild(instance):Clone()
				cl.Parent = DeathEffectFX
				cl.Name = instance
				if not (table.find(data.purchased,instance)) then
					table.insert(data.purchased,instance)
				end
				return Option.Wrap(data)
			end
		end
	end
end)

comm:BindFunction("UpdateDeathEffect",function(player,instance)
	if (player) and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		if (table.find(data.purchased,instance)) then
			data.Selected = instance
			return Option.Wrap(data.Selected)
		else
			return false
		end
	end
end)

comm:BindFunction("RemoveEffect",function(player,instance)
	if (player) and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		if (data.Selected == instance) then
			data.Selected = "classic" 
		else
			return "[Emitter Service]: enlèvement impossible car l'effet n'a jamais était équipé."
		end
	end
end)

comm:BindFunction("RemoveObjectFromComponent",function(player,instance)
	if (player) and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		local DeathEffectFX = ReplicatedStorage.Packages.Menu["InventoryModule.all"]["inventory.emitter"].DeathEffectsFX
		if (table.find(data.purchased,instance)) then
			if (data.Selected == instance) then
				data.Selected = "classic"
			end
			if (DeathEffectFX:FindFirstChild(instance)) then DeathEffectFX:FindFirstChild(instance):Destroy() end
			table.remove(data.purchased,table.find(data.purchased,instance))
		end
		return data
	end
end)

comm:BindFunction("RemoveEmitter",function(player,instance)
	if player and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		if (data.Selected == instance) then
			data.Selected = "classic"
			return "Changement effectué sans problème"
		else
			return nil
		end
	end
end)

comm:BindFunction("ReloadComponentService",function(player,instance)
	if (player) and (instance) then
		local data = ProfilsAttachment[player.UserId].Data.Settings.DeathsEffects
		if (data) then
			local DeathEffectFX = ReplicatedStorage.Packages.Menu["InventoryModule.all"]["inventory.emitter"].DeathEffectsFX
			if (table.find(data.purchased,instance)) then
				return data
			else
				return false
			end
		end
	end
end)
