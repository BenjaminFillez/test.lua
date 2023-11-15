local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local Option = require(Knit.Util.Option)
local Items = require(Knit.Util.Menu["InventoryModule.all"]).Items

local Component = {}
Component.__index = Component


function Component:Items(instance,result)
	local player = Players.LocalPlayer
	local uiInventory = player:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi"):WaitForChild("coutainer")
	local frameInventory = uiInventory:WaitForChild("Items")
	local itemsParent = frameInventory:WaitForChild("inventory"):WaitForChild("TitlesInventory")
	
	local playerGui = player:WaitForChild("PlayerGui")
	
	local t = {p = true,
		GuiToParent = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi"):WaitForChild("coutainer"):WaitForChild("Items"):WaitForChild("inventory"):WaitForChild("TitlesInventory"),
		obj = instance}
	
	if (instance) then
		local items = Items.new()
		local function screenOnPurchase()
			local ui = playerGui:FindFirstChild("RequestSend")
			if (ui) then
				return Promise.new(function(resolve,reject,OnCancel)
					local templateToMove = script:WaitForChild("template"):Clone()
					templateToMove.Parent = ui
					templateToMove.Name = instance
					if (itemsParent:FindFirstChild(instance) and result == nil) then
						templateToMove:WaitForChild("requestText").Text = "Item déjà acheté :".." ("..instance..") 🙄"
						TweenService:Create(templateToMove:FindFirstChild("requestText"),TweenInfo.new(.15),{TextColor3 = Color3.new(.8,0,0)}):Play()
						TweenService:Create(templateToMove:FindFirstChild("bar"),TweenInfo.new(.15),{BackgroundColor3 = Color3.new(.85,0,0)}):Play()
					elseif (result == "Sale") then
						templateToMove:Remove()
						return "Refresh"
						--templateToMove:WaitForChild("requestText").Text = "Item Vendue :".." ("..instance.Name..")"
					elseif (result == "Purchase") then
						items:OnPurchased(t)
						templateToMove:WaitForChild("requestText").Text = "Item acheté :".." ("..instance..") 👌"
					end
					TweenService:Create(templateToMove:FindFirstChild("requestText"),TweenInfo.new(.15),{TextTransparency = 0}):Play()
					TweenService:Create(templateToMove:FindFirstChild("bar").UIScale,TweenInfo.new(.15,Enum.EasingStyle.Back),{Scale = 1}):Play()
					task.wait(1.7)
					TweenService:Create(templateToMove:FindFirstChild("requestText"),TweenInfo.new(.15),{TextTransparency = 1}):Play()
					TweenService:Create(templateToMove:FindFirstChild("bar").UIScale,TweenInfo.new(.15,Enum.EasingStyle.Back),{Scale = 0}):Play()
					task.wait(.5)
					templateToMove:Destroy()
				end)			
			end
		end
		screenOnPurchase()
		return self
	end
end

function Component:Equip(item)
	return Knit.GetService("InventoryKnitMain"):Equip(item)
end

function Component:UnEquip(item)
	return Knit.GetService("InventoryKnitMain"):UnEquip(item)
end

return Component
