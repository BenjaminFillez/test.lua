local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Thread = require(ReplicatedStorage.Packages.Thread)

local module = {}
module.__index = module

function module.new()
	local self = setmetatable({
		_state = "Disable",
		_profil = debug.profilebegin,
		_profilend = debug.profileend,
		_delay = 7,
		_raycastParams = RaycastParams.new(),
		_callback = nil
	},module)
	if (not self._folder) or script:FindFirstChild(script.Name.."Folder") == nil then
		self._folder = Instance.new("Folder",script)
		self._folder.Name = script.Name.."Folder"
	end
	return self
end

function module:Start(InstancePosition,RaycastFilterType,FilterDescendants)
	if (self._state == "Disable") and (self._callback == nil) then
		self._state = "Enable"
		self._raycastParams.FilterDescendantsInstances = FilterDescendants
		self._raycastParams.FilterType = RaycastFilterType
		self.instance = InstancePosition
		
		self._callback = Promise.new(function(resolve,reject,OnCancel)
			local connection = RunService.Stepped:Connect(function()
				self._profil("RaycastDebris")
				local part = Instance.new("Part",self._folder)
				part.Size = Vector3.new(1,1,1)
				part.Anchored = true
				part.Transparency = 1
				part.Color = Color3.fromRGB(35,35,35)
				part.CanCollide = false
				part.TopSurface = Enum.SurfaceType.Smooth
				part.BottomSurface = Enum.SurfaceType.Smooth
				part.CFrame = InstancePosition.CFrame * CFrame.fromEulerAnglesXYZ(0,math.random(180,360),0) * CFrame.new(5,-4.95,0)

				local raycast = workspace:Raycast(part.CFrame.p,part.CFrame.UpVector * -10,self._raycastParams)
				if (raycast) then
					part.Position = raycast.Position + Vector3.new(3,-.25,0)
					TweenService:Create(part,TweenInfo.new(.15),{Transparency = 0,Size = Vector3.new(math.random(2,3),math.random(2,3),math.random(2,3))}):Play()
					part.Material = raycast.Instance.Material
					part.Color = raycast.Instance.Color
					part.Orientation = Vector3.new(math.random(180,360),math.random(180,360),math.random(180,360))
				end
				self._profilend()
			end)
			
			OnCancel(function()
				if (self._state == "Enable") then
					self._state = "Disable"
				end
				connection:Disconnect()
				self._callback = nil
				for i,parts in self._folder:GetChildren() do
					if (parts:IsA("Part")) then
						TweenService:Create(parts,TweenInfo.new(1.5),{Position = parts.Position + Vector3.new(0,-5,0),Size = Vector3.new(0,0,0),Transparency = 1}):Play()
					end
				end
				task.delay(3,function()
					return self._folder:ClearAllChildren()
				end)
			end)
			
		end)
		return self._callback
	end
end

function module:StopWithDelay(breakChild:boolean)
	return Thread.Delay(self._delay,function()
		if (self._state == "Enable") and (self._callback ~= nil) then
			self:Destroy(self.instance,breakChild)
			return self:_ProtectPromiseCancel(self)
		end
	end)
end

function module:Stop(breakChild:boolean)
	if (self._state == "Enable") and (self._callback ~= nil) then
		self:Destroy(self.instance,breakChild)
		return self:_ProtectPromiseCancel(self)
	end
end

function module:Destroy(instance,breakChild:boolean)
	if (instance) and (self._state == "Enable") then
		if not (breakChild) then
			return instance.Parent:Destroy()
		elseif (breakChild == true) then
			for i,children in instance:GetDescendants() do
				if (children:IsA("ParticleEmitter")) then
					children.Enabled = false
				elseif (children:IsA("PointLight")) then
					TweenService:Create(children,TweenInfo.new(.15),{Brightness = 0,Range = 0}):Play()
				end
			end
			Thread.Delay(.65,function()
				instance.Parent.Parent:Destroy()
				return self:DestroyTarget()
			end)
		end
	end
end

function module._ProtectPromiseCancel(self)
	if (type(self)) == "table" then
		if (Promise.is(self._callback) == true) then
			self._callback:cancel()
			self._callback = nil
		else
			return
		end
	end
end

function module:DestroyTarget()
	if not (self._folder) then return end
	return self._folder:Destroy()
end

return module
