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
local Comm = require(ReplicatedStorage.Packages.Comm).ServerComm

local PlayHumanoidTransparency = require(script.PlayHumanoidTransparency)

local ProfilAttachment = ProfilsComponent.ProfilesAttach
local EffectsPackages = ServerStorage.EffectsEmitter

local DeathJoints = Knit.CreateService{
	Name = "DeathsJointsService",
	Client = {
		Update = Knit.CreateSignal()
	}
}


function DeathJoints:BreakJoints(humanoid : Humanoid)
	if humanoid.BreakJointsOnDeath == true then
		humanoid.BreakJointsOnDeath = false
		return warn("BreakJoint's refreshed for ["..`{humanoid:GetFullName()}]`)
	else
		return warn("BreakJoint's server doesn't do the refresh function for ["..`{humanoid:GetFullName()}]`)
	end
end

function DeathJoints:GetHumanoid(humanoid) 
	if (humanoid) then
		return Option.Wrap(humanoid)
	end
end

function DeathJoints:Ragdoll()
	
end

function DeathJoints:Apply(root,vfx : Instance)
	local player = Players:GetPlayerFromCharacter(root.Parent)
	
	local clVfx = vfx:Clone()
	clVfx.Parent = workspace.FX
	clVfx.Position = root.Position + Vector3.new(0,1,0)
	
	if (clVfx:IsA("Part")) then
		for i,childs in pairs(clVfx:GetChildren()) do
			if (childs.ClassName == "PointLight") then
				childs.Enabled = true
			elseif (childs.ClassName == "ParticleEmitter") then
				childs.Enabled = true
			elseif (childs.ClassName == "Attachment") then
				for i,emitter in pairs(childs:GetChildren()) do
					if emitter.ClassName == "ParticleEmitter" then
						emitter.Enabled = true
						emitter:Emit(clVfx:GetAttribute("Emit"))
					end
				end
			end
		end
		Promise.delay(3.2):andThen(function()
			for i,childs in pairs(clVfx:GetChildren()) do
				if (childs.ClassName == "PointLight") then
					childs.Enabled = false
				elseif (childs.ClassName == "ParticleEmitter") then
					childs.Enabled = false
				elseif (childs.ClassName == "Attachment") then
					for i,emitter in pairs(childs:GetChildren()) do
						if emitter.ClassName == "ParticleEmitter" then
							emitter.Enabled = false
							emitter:Emit(clVfx:GetAttribute("Emit"))
						end
					end
				end
			end
		end):catch(warn):finally(function()
			task.delay(.8,function()
				return clVfx:Destroy()
			end)
		end)
	end
	
	self.Client.Update:Fire(player)
	return self
end

function DeathJoints:DeathEffect(character : Model)
	if (character) then
		local humanoid = self:GetHumanoid(character:WaitForChild("Humanoid"))
		
		humanoid:Match{
			Some = function(humanoid)
				local player = Players:GetPlayerFromCharacter(character)
				if (player) then
					local data = ProfilAttachment[player.UserId].Data.Settings.DeathsEffects
					if (data.Selected ~= "classic") then
						PlayHumanoidTransparency(character)
						if (EffectsPackages:FindFirstChild(tostring(data.Selected))) then
							return self:Apply(character:FindFirstChild("HumanoidRootPart"),EffectsPackages:FindFirstChild(tostring(data.Selected)))
						end
					else 
					
					end
				end
			end,
			
			None = function () end,
		}
	end
end


function DeathJoints:Start(player)
	local data = ProfilAttachment[player.UserId].Data.Settings.DeathsEffects
	if (data) then
		if (data.Selected ~= nil) then
			print("[Death Joints Service (to controller)]: death sound changed.")
			return data
		end
	else
		return false
	end
end


function DeathJoints.Client:Start(plr:Player)
	local getDataFromClient = self.Server:Start(plr)
	if (getDataFromClient) then
		return getDataFromClient
	end
	return self
end

function DeathJoints:KnitStart()
	game.Players.PlayerAdded:Connect(function(player)
		if (player) then
			local characterPromises = Promise.new(function(resolve,reject,onCancel)	
				player.CharacterAdded:Connect(function(character)
					if (character) then
						local humanoid = character:WaitForChild("Humanoid")
						if (humanoid) then self:BreakJoints(humanoid) end
						
						humanoid.Died:Connect(function()
							character.HumanoidRootPart.Anchored = true
							self:DeathEffect(character)
						end)
						
						return self.Client.Update:Fire(player)			
					end
				end)		
			end):catch(warn)
		end
	end)
end

return DeathJoints
