--[[Toute communication avec les modules et ces updates]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")

ContentProvider:PreloadAsync({game})
task.wait(2)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

local Signal = require(ReplicatedStorage:WaitForChild("Packages").Signal)
local Maid = require(ReplicatedStorage:WaitForChild("Packages").Maid)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)
local Promise = require(ReplicatedStorage:WaitForChild("Packages").Promise)
local RemoteClientComponent = require(ReplicatedStorage:WaitForChild("Packages").RemoteClientComponent)

local function get(parent,name :string)
	if parent:FindFirstChild(name) then
		return parent:FindFirstChild(name)
	else
		return warn(debug.traceback(`{parent:WaitForChild(name)} ne doit pas être nil`,2))
	end
end

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScript = player.PlayerScripts
local MainRequirementUi = playerGui:WaitForChild("MainRequirementUi")
local coutainer = MainRequirementUi:WaitForChild("coutainer")
local Items = coutainer:WaitForChild("Items")
local Boutique = Items:WaitForChild("Boutique")
local EffectFrame = Boutique:WaitForChild("EffectFrame")
local ItemsFrame = Boutique:WaitForChild("ItemsFrame")

--Modules
local ItemComponent = require(playerScript:WaitForChild("Mains").Knit_Installation.Component:WaitForChild("inventory.Component.Client"))
local ItemsFrameWork = require(ReplicatedStorage:WaitForChild("Packages").Menu["InventoryModule.all"]).Items.new()
local EffectFrameWork = require(ReplicatedStorage:WaitForChild("Packages").Menu["InventoryModule.all"]["inventory.emitter"])
local DeathsJointService = Knit.GetService("DeathsJointsService")


--Knit Start/Update
local function DeathJointsStart()
	local joinsData = DeathsJointService:Start()
	if (type(joinsData) == "table") then
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character.HumanoidRootPart
		Promise.delay(1):andThen(function()
			humanoidRootPart:WaitForChild("Died").SoundId = EffectFrameWork.sound[joinsData.Selected]
			humanoidRootPart:WaitForChild("Died").Volume = .15
		end):catch(warn)
	end	
end

DeathJointsStart()

DeathsJointService.Update:Connect(function()
	local joinsData = DeathsJointService:Start()
	if (type(joinsData) == "table") then
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character.HumanoidRootPart
		Promise.delay(task.wait()):andThen(function()
			humanoidRootPart:WaitForChild("Died").SoundId = EffectFrameWork.sound[joinsData.Selected]
			humanoidRootPart:WaitForChild("Died").Volume = .15
		end):catch(warn)
	end
end)

local getEffectButton = get(EffectFrame,"TextButton")
local getItemsFrameButton = get(ItemsFrame,"TextButton")
local getMainGroup = get(Boutique,"MainGroup")

local ScrollingFrame = getMainGroup:WaitForChild("ScrollingFrame")
local SwordUnCommunFrame = get(ScrollingFrame,"SwordUmcommunFrame")
local SwordFrame = SwordUnCommunFrame:WaitForChild("SwordFrame")
local PurchaseFrame = get(SwordFrame,"PurchaseFrame")
local PurchaseButtonFrame = PurchaseFrame:WaitForChild("PurchaseButtonFrame")
local RarityFrame = SwordFrame:WaitForChild("RarityFrame")
local SwordImageFrame = SwordFrame:WaitForChild("SwordImage")

local PurchaseButton = get(PurchaseButtonFrame,"TextButton")

local FlashlightRareFrame = ScrollingFrame:WaitForChild("FlashlightRareFrame")
local FlashlightFrame = FlashlightRareFrame.FlashlightFrame
local FlashlightPurchaseFrame = FlashlightFrame.PurchaseFrame
local FlashlightPurchaseButtonFrame = FlashlightPurchaseFrame.PurchaseButtonFrame

local HollowPurpleFrame = ScrollingFrame:WaitForChild("HollowPurpleFrame")
local childFrameForHollowPurple = HollowPurpleFrame:WaitForChild("HollowPurpleFrame")
local HollowPurplePurchaseFrame = childFrameForHollowPurple.PurchaseFrame
local buyHollowPurple = HollowPurplePurchaseFrame.PurchaseButtonFrame
	
local InventoryFrame = get(Items,"inventory")
local InventoryCoutainer = InventoryFrame:WaitForChild("TitlesInventory")
local InventoryScreen = get(Players.LocalPlayer:WaitForChild("PlayerGui"),"InventoryScreen")

local EffectScrollingFrame = Boutique.MainGroup.EmitterScrollingFrame
local DeathLoverFrame = EffectScrollingFrame.DeathLoverUmcommunFrame


local function CheckIfAlreadyExist(i)
	if InventoryCoutainer:FindFirstChild(i) then
		return "Refusé"
	else
		return "Succès"
	end
end

local keys = {}
local items = {}

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.refreshItem_bar.Event:Connect(function(plr,args,i)
	assert(type(args) == "table",`{type(args)} must be a table Value {debug.traceback("__index error",2)}`)
	local function refresh()
		for i,v in ipairs(args) do
			if not (table.find(keys,v)) then table.insert(keys,v) end
			if not (table.find(items,v)) then table.insert(items,v) end
		end
		if (i ~= nil) then
			if table.find(items,i) then
				table.remove(items,table.find(items,i))
				print("[Items Controller (Client)]: removed from table", i)
				for _i,item in ipairs(items) do
					if (InventoryScreen.Selectable.Value == tostring(item) or InventoryScreen.Selectable.Value == tostring(i) or InventoryScreen.Selectable.Value ~= "") then
						InventoryScreen.Selectable.Value = ""
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIScale").Scale = 1
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIStroke").Thickness = 1
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIStroke").Transparency = 1
					end
				end
				if #items <=0 then
					InventoryScreen.Selectable.Value = ""
				end
			end
		end
		task.wait(.25)
		for i,item in ipairs(items) do
			if (InventoryScreen.coutainer:WaitForChild(tostring(item))) then
				InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("_index").Text = tostring(i)
			end
		end
		print("[Items Controller (Client)]: refresh initialized")
	end
	task.spawn(refresh)
end)

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.event.Event:Connect(function(item,fn)
	if (not item) or not fn then return end
	if (fn == "Equip") then
		return ItemComponent:Equip(item)
	elseif (fn == "UnEquip") or (fn == "Player Die") then
		return ItemComponent:UnEquip(item)
	end
	error("[Items Controller (Client)]: fn is not longer [Equip] or UnEquip]"..`{debug.traceback("__",2)}`)
end)


Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.ClientService.__ReceiveServer.OnClientInvoke = function(t,b)
	if (type(t) == "table") then
		for i,str in ipairs(t.Item) do
			local item = ItemsFrameWork.Knit:GetItemFromName(str)
			if (item) then
				ItemComponent:Items(item,"Purchase")
			end
		end
	end
end

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.ClientService.RefreshItemSignal.OnClientEvent:Connect(function(item)
	if (item) then
		for i,frame in pairs(InventoryScreen.coutainer:GetChildren()) do
			if (frame.Name == tostring(item)) then
				TweenService:Create(frame:WaitForChild("UIScale"),TweenInfo.new(.15),{Scale = 1}):Play()
				TweenService:Create(frame:WaitForChild("UIStroke"),TweenInfo.new(.15),{
					Thickness = 1,
					Transparency = 1
				}):Play()
				TweenService:Create(frame.CurrentItem.UIScale,TweenInfo.new(.15),{Scale = 0}):Play()
			end 
		end
	end
end)

Knit.Util.Menu["InventoryModule.all"]["inventory.emitter"].LoadComponent.OnClientInvoke = function(data)
	EffectFrameWork:LoadComponent(data)
	return true
end

EffectFrameWork.signal.CancelPromise.OnInvoke = function(fn)
	if (fn == "cancel") and (type(fn) == "string") then
		return ItemsFrameWork:CancelPromiseReview()
	elseif type(fn) == "table" and (fn._v == "cancel") then
		return EffectFrameWork:CancelPromiseReview()
	end
end


local _maid = nil
local _instances = {}

getEffectButton.MouseButton1Down:Connect(function()
	TweenService:Create(ScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(1,0)}):Play()
	TweenService:Create(EffectScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(0,0)}):Play()
	SoundService:PlayLocalSound(SoundService["UI Click"])
end)

getItemsFrameButton.MouseButton1Down:Connect(function()
	TweenService:Create(ScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(0,0)}):Play()
	TweenService:Create(EffectScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(1,0)}):Play()
	SoundService:PlayLocalSound(SoundService["UI Click"])
end)

DeathLoverFrame.DeathLoverFrame.PurchaseFrame.PurchaseButtonFrame.TextButton.MouseButton1Down:Connect(function()
	return EffectFrameWork:Purchase("DeathLover")
end)


PurchaseButton.MouseButton1Down:Connect(function()
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	
	local item = ItemsFrameWork.Knit:GetItemFromName("ClassicSword")
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)
	
	if (purchaseGrandedResult == false) and ((item ~= nil)) and (CheckIfAlreadyExist(item) == "Succès") then
		return ItemComponent:Items(item,"Purchase")
	elseif (item) and (CheckIfAlreadyExist(item) == "Refusé") or (purchaseGrandedResult == true) then
		return warn("[Items Controller (Client)]: failed cause its already purchase.")
	end
end)

FlashlightPurchaseButtonFrame.TextButton.MouseButton1Down:Connect(function()
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	
	local item = ItemsFrameWork.Knit:GetItemFromName("Flashlight")
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)

	if (purchaseGrandedResult == false) and ((item ~= nil)) and (CheckIfAlreadyExist(item) == "Succès") then
		return ItemComponent:Items(item,"Purchase")
	elseif (item) and (CheckIfAlreadyExist(item) == "Refusé") or (purchaseGrandedResult == true) then
		return warn("[Items Controller (Client)]: failed cause its already purchase.")
	end
end)

buyHollowPurple.TextButton.MouseButton1Down:Connect(function()
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	local item = ItemsFrameWork.Knit:GetItemFromName("Hollow")
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)

	if (purchaseGrandedResult == false) and ((item ~= nil)) and (CheckIfAlreadyExist(item) == "Succès") then
		return ItemComponent:Items(item,"Purchase")
	elseif (item) and (CheckIfAlreadyExist(item) == "Refusé") or (purchaseGrandedResult == true) then
		return warn("[Items Controller (Client)]: failed cause its already purchase.")
	end
end)


EffectFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(getEffectButton.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
	TweenService:Create(getEffectButton,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
	TweenService:Create(getEffectButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
	TweenService:Create(getEffectButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1,1,1)}):Play()
end)

PurchaseButtonFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(PurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

FlashlightPurchaseButtonFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(FlashlightPurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

buyHollowPurple.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(buyHollowPurple.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

buyHollowPurple.MouseLeave:Connect(function()
	TweenService:Create(buyHollowPurple.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

FlashlightPurchaseButtonFrame.MouseLeave:Connect(function()
	TweenService:Create(FlashlightPurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

PurchaseButtonFrame.MouseLeave:Connect(function()
	TweenService:Create(PurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

EffectFrame.MouseLeave:Connect(function()
	TweenService:Create(getEffectButton.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
	TweenService:Create(getEffectButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
	TweenService:Create(getEffectButton,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
	TweenService:Create(getEffectButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0,0,0)}):Play()
end)

ItemsFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(getItemsFrameButton.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
	TweenService:Create(getItemsFrameButton,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
	TweenService:Create(getItemsFrameButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
	TweenService:Create(getItemsFrameButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1,1,1)}):Play()
end)

ItemsFrame.MouseLeave:Connect(function()
	TweenService:Create(getItemsFrameButton.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
	TweenService:Create(getItemsFrameButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
	TweenService:Create(getItemsFrameButton,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
	TweenService:Create(getItemsFrameButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0,0,0)}):Play()
end)
