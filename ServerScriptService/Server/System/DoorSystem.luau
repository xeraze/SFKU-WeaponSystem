local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local DoorSystem = {}
DoorSystem.__index = DoorSystem

local doorInstances = {}
local doorStates = {}

function DoorSystem:Init()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:GetAttribute("DoorType") then
			self:RegisterDoor(obj)
		end
	end

	workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Model") and obj:GetAttribute("DoorType") then
			self:RegisterDoor(obj)
		end
	end)
end

function DoorSystem:RegisterDoor(doorModel)
	local doorType = doorModel:GetAttribute("DoorType")
	local roomId = doorModel:GetAttribute("RoomId")
	local cardRequired = doorModel:GetAttribute("CardRequired")

	local config = Config.DoorTypes[doorType]
	if not config then return end

	doorInstances[doorModel:GetFullName()] = {
		model = doorModel,
		config = config,
		roomId = roomId,
		cardRequired = cardRequired,
	}

	doorStates[doorModel:GetFullName()] = {
		open = false,
		locked = false,
		cooldown = false,
	}
end

function DoorSystem:CanOpen(player, doorKey)
	local doorData = doorInstances[doorKey]
	local state = doorStates[doorKey]
	if not doorData or not doorData.model then return false end
	if state.locked then return false end
	if state.cooldown then return false end

	local playerCard = player:GetAttribute("CurrentCard")
	if not playerCard then return false end

	local cardData = Config.CardPermissions[playerCard]
	if not cardData then return false end

	local doorType = doorData.model:GetAttribute("DoorType")
	if doorType == "Regular" or doorType == "Armored" or doorType == "Hermetic" then
		local allowedDoors = cardData.openDoors or {}
		local doorTypeName = doorData.model:GetAttribute("DoorTypeName")
		if not table.find(allowedDoors, doorTypeName) then
			return false
		end
	end

	if cardData.blockedRooms and doorData.roomId then
		if table.find(cardData.blockedRooms, doorData.roomId) then
			return false
		end
	end

	if cardData.factionLock then
		local playerFaction = player:GetAttribute("Faction")
		if playerFaction ~= cardData.factionLock then
			return false
		end
	end

	return true
end

function DoorSystem:Open(doorKey)
	local doorData = doorInstances[doorKey]
	local state = doorStates[doorKey]
	if not doorData or state.open then return end

	state.open = true
	state.cooldown = true

	local doorModel = doorData.model
	local config = doorData.config

	if config.animationType == "swing" then
		local pivot = doorModel.PrimaryPart
		if pivot then
			local hinge = doorModel:FindFirstChild("Hinge")
			if hinge then
				pivot = hinge
			end
			local tweenInfo = TweenInfo.new(config.openSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goal = {CFrame = pivot.CFrame * CFrame.Angles(0, math.rad(config.openAngle), 0)}
			local tween = TweenService:Create(pivot, tweenInfo, goal)
			tween:Play()
		end
	elseif config.animationType == "slide_up" then
		for _, part in ipairs(doorModel:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("IsDoor") then
				local tweenInfo = TweenInfo.new(config.openSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {CFrame = part.CFrame + config.openOffset}
				local tween = TweenService:Create(part, tweenInfo, goal)
				tween:Play()
			end
		end
	end

	task.delay(5, function()
		state.cooldown = false
	end)
end

function DoorSystem:Close(doorKey)
	local doorData = doorInstances[doorKey]
	local state = doorStates[doorKey]
	if not doorData or not state.open then return end

	state.open = false
	state.cooldown = true

	local doorModel = doorData.model
	local config = doorData.config

	if config.animationType == "swing" then
		local pivot = doorModel.PrimaryPart
		if pivot then
			local hinge = doorModel:FindFirstChild("Hinge")
			if hinge then
				pivot = hinge
			end
			local tweenInfo = TweenInfo.new(config.openSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local goal = {CFrame = pivot.CFrame * CFrame.Angles(0, math.rad(-config.openAngle), 0)}
			local tween = TweenService:Create(pivot, tweenInfo, goal)
			tween:Play()
		end
	elseif config.animationType == "slide_up" then
		for _, part in ipairs(doorModel:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("IsDoor") then
				local tweenInfo = TweenInfo.new(config.openSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {CFrame = part.CFrame - config.openOffset}
				local tween = TweenService:Create(part, tweenInfo, goal)
				tween:Play()
			end
		end
	end

	task.delay(5, function()
		state.cooldown = false
	end)
end

function DoorSystem:LockDoor(doorKey)
	local state = doorStates[doorKey]
	if state then
		state.locked = true
	end
end

function DoorSystem:UnlockDoor(doorKey)
	local state = doorStates[doorKey]
	if state then
		state.locked = false
	end
end

function DoorSystem:LockAllByType(doorTypeName)
	for key, data in pairs(doorInstances) do
		if data.model:GetAttribute("DoorTypeName") == doorTypeName then
			DoorSystem:LockDoor(key)
		end
	end
end

function DoorSystem:UnlockAllByType(doorTypeName)
	for key, data in pairs(doorInstances) do
		if data.model:GetAttribute("DoorTypeName") == doorTypeName then
			DoorSystem:UnlockDoor(key)
		end
	end
end

function DoorSystem:GetDoorKey(doorModel)
	return doorModel:GetFullName()
end

return DoorSystem
