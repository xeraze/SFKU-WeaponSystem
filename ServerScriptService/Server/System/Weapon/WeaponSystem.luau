local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WeaponConfig = require(ReplicatedStorage.Modules.Weapon.WeaponConfig)
local WeaponParser = require(ReplicatedStorage.Modules.Weapon.WeaponParser)

local WeaponSystem = {}
WeaponSystem.__index = WeaponSystem

local weaponStates = {}
local currentWeapon = {}
local prompts = {}
local cooldowns = {}
local activeReloads = {}

local WEAPON_FOLDERS = {"AR's", "Rifles", "Handguns", "SMG's", "Machine Guns"}

local function dropToGround(model)
	local bboxCf, bboxSize = model:GetBoundingBox()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {model}
	local result = workspace:Raycast(bboxCf.Position, Vector3.new(0, -500, 0), params)
	if result then
		local groundY = result.Position.Y + bboxSize.Y / 2 + 0.05
		local deltaY = groundY - bboxCf.Position.Y
		model:PivotTo(model:GetPivot() * CFrame.new(0, deltaY, 0))
	end
end

local function cleanWeaponName(name)
	return (name:match("^[^,(]+") or name):gsub("%s+$", "")
end

function WeaponSystem:Init()
	for _, folderName in ipairs(WEAPON_FOLDERS) do
		local folder = workspace:FindFirstChild(folderName)
		if not folder then
			warn("WeaponSystem: folder not found: " .. folderName)
		else
			local count = 0
			for _, model in ipairs(folder:GetChildren()) do
				if model:IsA("Model") and not model:GetAttribute("WeaponReady") then
					model:SetAttribute("WeaponReady", true)
					for _, desc in ipairs(model:GetDescendants()) do
						if desc:IsA("BasePart") then
							desc.Anchored = true
						end
					end
					dropToGround(model)

					local promptPart = Instance.new("Part")
					promptPart.Name = "PromptPart"
					promptPart.Anchored = true
					promptPart.CanCollide = false
					promptPart.Transparency = 1
					promptPart.Size = Vector3.new(1, 1, 1)
					promptPart.CFrame = model:GetPivot()
					promptPart.Parent = model

					local prompt = Instance.new("ProximityPrompt")
					prompt.ActionText = "Взять"
					prompt.ObjectText = cleanWeaponName(model.Name)
					prompt.HoldDuration = 0
					prompt.RequiresLineOfSight = false
					prompt.Parent = promptPart
					prompt.Triggered:Connect(function(player)
						local ok, err = pcall(function()
							return self:Equip(player, model)
						end)
						if not ok then
							warn("WeaponSystem: Equip error (" .. model.Name .. "): " .. tostring(err))
						end
					end)
					prompts[model] = prompt
					count += 1
				end
			end
			print("WeaponSystem: " .. folderName .. " - prompts: " .. count)
		end
	end
end

function WeaponSystem:Equip(player, weaponModel)
	if weaponModel:GetAttribute("Equipped") then
		warn("WeaponSystem: model already equipped: " .. weaponModel.Name)
		return false
	end

	local character = player.Character
	if not character then
		warn("WeaponSystem: no character: " .. player.Name)
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local weaponName = weaponModel.Name
	local weaponData, categoryName = WeaponConfig:GetWeaponData(weaponName)
	if not weaponData then
		warn("WeaponSystem: no weapon data: " .. weaponName)
		return false
	end

	local originalParent = weaponModel.Parent

	local parts = WeaponParser:ParseWeapon(weaponModel)
	local handle = WeaponParser:CreateHandle(weaponModel, parts)
	if not handle then
		warn("WeaponSystem: no handle (no grip/body): " .. weaponName)
		return false
	end

	WeaponParser:CreateBarrelAttachment(weaponModel, parts)

	for _, desc in ipairs(weaponModel:GetDescendants()) do
		if desc:IsA("Weld") or desc:IsA("WeldConstraint") then
			desc:Destroy()
		end
	end

	WeaponParser:WeldAllParts(parts)

	for _, desc in ipairs(weaponModel:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
			desc.Massless = true
		end
	end

	weaponModel:SetAttribute("Equipped", true)

	local prompt = prompts[weaponModel]
	if prompt then
		prompt.Enabled = false
	end

	local state = {
		model = weaponModel,
		data = weaponData,
		category = categoryName,
		parts = parts,
		ammo = weaponData.magSize,
		reserve = weaponData.magSize * 3,
		reloading = false,
		originalParent = originalParent,
	}
	weaponStates[weaponModel] = state

	local tool = Instance.new("Tool")
	tool.Name = cleanWeaponName(weaponName)
	tool.CanBeDropped = false
	tool:SetAttribute("FullAuto", not weaponData.boltAction and not weaponData.revolver and categoryName ~= "Handguns")

	handle.Parent = tool
	weaponModel.Parent = tool
	tool.Parent = player.Backpack

	tool.Destroying:Connect(function()
		if weaponModel and weaponModel.Parent then
			weaponModel.Parent = originalParent
			for _, desc in ipairs(weaponModel:GetDescendants()) do
				if desc:IsA("BasePart") then
					desc.Anchored = true
					desc.CanCollide = true
					desc.Massless = false
				elseif desc:IsA("Weld") or desc:IsA("WeldConstraint") then
					desc:Destroy()
				end
			end
			dropToGround(weaponModel)
			weaponModel:SetAttribute("Equipped", nil)
			if prompt then
				prompt.Enabled = true
			end
		end
		weaponStates[weaponModel] = nil
		if currentWeapon[player.UserId] == state then
			currentWeapon[player.UserId] = nil
			player:SetAttribute("EquippedWeapon", nil)
			player:SetAttribute("EquippedWeaponAuto", nil)
		end
	end)

	tool.Equipped:Connect(function()
		currentWeapon[player.UserId] = state
		player:SetAttribute("EquippedWeapon", cleanWeaponName(weaponName))
		player:SetAttribute("EquippedWeaponAuto", tool:GetAttribute("FullAuto"))
		WeaponSystem:OnEquip(player, weaponModel, parts)
	end)

	tool.Unequipped:Connect(function()
		if currentWeapon[player.UserId] == state then
			currentWeapon[player.UserId] = nil
			player:SetAttribute("EquippedWeapon", nil)
			player:SetAttribute("EquippedWeaponAuto", nil)
		end
		WeaponSystem:OnUnequip(player)
	end)

	tool.Activated:Connect(function()
		WeaponSystem:Shoot(player, state)
	end)

	humanoid:EquipTool(tool)

	return true
end

function WeaponSystem:OnEquip(player, weaponModel, parts)
	for _, part in ipairs(parts.allParts) do
		part.LocalTransparencyModifier = 0
	end
end

function WeaponSystem:OnUnequip(player)
end

function WeaponSystem:Shoot(player, state)
	state = state or currentWeapon[player.UserId]
	if not state then return end
	if state.reloading then return end
	if state.ammo <= 0 then
		self:Reload(player, state)
		return
	end

	local userId = player.UserId
	local lastShot = cooldowns[userId] or 0
	if tick() - lastShot < state.data.fireRate then return end
	cooldowns[userId] = tick()

	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local origin, direction = WeaponParser:GetShootOrigin(state.model, state.parts)
	if not origin then
		origin = rootPart.Position + rootPart.CFrame.LookVector * 2
		direction = rootPart.CFrame.LookVector
	end

	local adsBonus = player:GetAttribute("IsAiming") and 0.5 or 1
	local spread = state.data.spread * adsBonus
	local spreadOffset = Vector3.new(
		math.random() * spread * 2 - spread,
		math.random() * spread * 2 - spread,
		0
	)
	local shootDirection = (direction + rootPart.CFrame:VectorToWorldSpace(spreadOffset)).Unit

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character, state.model}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, shootDirection * state.data.range, raycastParams)

	state.ammo -= 1

	self:PlayShootEffect(player, state, origin, shootDirection, result)

	if result and result.Instance then
		local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
		if hitCharacter then
			local hitHumanoid = hitCharacter:FindFirstChildOfClass("Humanoid")
			if hitHumanoid then
				local distance = (origin - result.Position).Magnitude
				local damageMult = math.clamp(1 - (distance / state.data.range) * 0.5, 0.5, 1)
				local finalDamage = state.data.damage * damageMult

				if result.Instance.Name == "Head" then
					finalDamage *= 2
				end

				hitHumanoid:TakeDamage(finalDamage)
			end
		end
	end

	if state.ammo <= 0 then
		self:Reload(player, state)
	end
end

function WeaponSystem:Reload(player, state)
	state = state or currentWeapon[player.UserId]
	if not state then return end
	if state.reloading then return end
	if state.ammo == state.data.magSize then return end
	if state.reserve <= 0 then return end

	local userId = player.UserId
	state.reloading = true
	activeReloads[userId] = state

	WeaponParser:HideMagDuringReload(state.parts, true)

	task.delay(state.data.reloadTime, function()
		if activeReloads[userId] ~= state then
			WeaponParser:HideMagDuringReload(state.parts, false)
			state.reloading = false
			return
		end

		local needed = state.data.magSize - state.ammo
		local toLoad = math.min(needed, state.reserve)
		state.ammo += toLoad
		state.reserve -= toLoad

		WeaponParser:HideMagDuringReload(state.parts, false)
		state.reloading = false
		activeReloads[userId] = nil
	end)
end

function WeaponSystem:PlayShootEffect(player, state, origin, direction, result)
	ReplicatedStorage:SetAttribute("ShootEffect_" .. player.UserId, true)

	local attachment = state.model:FindFirstChild("MuzzleAttachment", true)
	if attachment then
		ReplicatedStorage:SetAttribute("MuzzleFlash_" .. player.UserId, true)
	end

	task.delay(0.1, function()
		ReplicatedStorage:SetAttribute("ShootEffect_" .. player.UserId, false)
	end)
end

function WeaponSystem:GetAmmo(player)
	local state = currentWeapon[player.UserId]
	if not state then return 0, 0 end
	return state.ammo, state.reserve
end

function WeaponSystem:Unequip(player)
	currentWeapon[player.UserId] = nil
	cooldowns[player.UserId] = nil
	activeReloads[player.UserId] = nil
end

function WeaponSystem:OnPlayerRemoving(player)
	self:Unequip(player)
end

return WeaponSystem
