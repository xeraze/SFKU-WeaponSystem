local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataStore = require(ReplicatedStorage.Modules.DataStore)

local Server = ServerScriptService.Server
local System = Server:WaitForChild("System")

local DoorSystem = require(System:WaitForChild("DoorSystem"))
local RoleSystem = require(System:WaitForChild("RoleSystem"))
local ControlRoom = require(System:WaitForChild("ControlRoom"))
local WantedSystem = require(System:WaitForChild("WantedSystem"))
local BriefcaseSystem = require(System:WaitForChild("BriefcaseSystem"))
local ManagerComputer = require(System:WaitForChild("ManagerComputer"))
local SurveillanceSystem = require(System:WaitForChild("SurveillanceSystem"))
local HealthSystem = require(System:WaitForChild("HealthSystem"))
local VirologySystem = require(System:WaitForChild("VirologySystem"))
local WeaponSystem = require(System:WaitForChild("Weapon"):WaitForChild("WeaponSystem"))

local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

local function CreateRemoteEvent(name)
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = RemoteEvents
	return event
end

local function CreateRemoteFunction(name)
	local func = Instance.new("RemoteFunction")
	func.Name = name
	func.Parent = RemoteEvents
	return func
end

local Remotes = {
	OpenDoor = CreateRemoteEvent("OpenDoor"),
	CloseDoor = CreateRemoteEvent("CloseDoor"),
	SelectRole = CreateRemoteFunction("SelectRole"),
	GetAvailableRoles = CreateRemoteFunction("GetAvailableRoles"),
	GetPlayerMinutes = CreateRemoteFunction("GetPlayerMinutes"),
	ToggleAlarm = CreateRemoteEvent("ToggleAlarm"),
	ToggleContainment = CreateRemoteEvent("ToggleContainment"),
	ToggleExperimentBlock = CreateRemoteEvent("ToggleExperimentBlock"),
	DeclareWanted = CreateRemoteEvent("DeclareWanted"),
	ArrestPlayer = CreateRemoteEvent("ArrestPlayer"),
	UseBriefcase = CreateRemoteEvent("UseBriefcase"),
	ManagerFire = CreateRemoteEvent("ManagerFire"),
	ManagerDeclareWanted = CreateRemoteEvent("ManagerDeclareWanted"),
	ManagerWarning = CreateRemoteEvent("ManagerWarning"),
	ManagerBonus = CreateRemoteEvent("ManagerBonus"),
	UseMedkit = CreateRemoteEvent("UseMedkit"),
	UseAdrenaline = CreateRemoteEvent("UseAdrenaline"),
	OfferPill = CreateRemoteEvent("OfferPill"),
	AcceptPill = CreateRemoteEvent("AcceptPill"),
	DeclinePill = CreateRemoteEvent("DeclinePill"),
	InjectSyringe = CreateRemoteEvent("InjectSyringe"),
	UseAntidote = CreateRemoteEvent("UseAntidote"),
	ActivateCamera = CreateRemoteEvent("ActivateCamera"),
	DeactivateCamera = CreateRemoteEvent("DeactivateCamera"),
	InteractShield = CreateRemoteEvent("InteractShield"),
	SelectFactionRole = CreateRemoteFunction("SelectFactionRole"),
	BuyItem = CreateRemoteEvent("BuyItem"),
	GetCiphers = CreateRemoteFunction("GetCiphers"),
	GetWantedPlayers = CreateRemoteFunction("GetWantedPlayers"),
	EquipWeapon = CreateRemoteEvent("EquipWeapon"),
	ShootWeapon = CreateRemoteEvent("ShootWeapon"),
	ReloadWeapon = CreateRemoteEvent("ReloadWeapon"),
	StartADS = CreateRemoteEvent("StartADS"),
	StopADS = CreateRemoteEvent("StopADS"),
	GetAmmo = CreateRemoteFunction("GetAmmo"),
}

DoorSystem:Init()
SurveillanceSystem:Init()
WeaponSystem:Init()

ReplicatedStorage:SetAttribute("AlarmActive", false)
ReplicatedStorage:SetAttribute("ContainmentLocked", false)
ReplicatedStorage:SetAttribute("ExperimentLocked", false)
ReplicatedStorage:SetAttribute("WantedCount", 0)

local function setupPlayer(player)
	DataStore:Load(player)
	RoleSystem:OnPlayerAdded(player)

	player:SetAttribute("CurrentCard", nil)
	player:SetAttribute("CurrentRole", nil)
	player:SetAttribute("AccessLevel", 0)
	player:SetAttribute("IsWanted", false)
	player:SetAttribute("InKPZ", false)
end

local function minutesLoop()
	while true do
		task.wait(Config.MINUTES_UPDATE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			DataStore:IncrementMinutes(player)
		end
	end
end

local wantedTick = 0
RunService.Heartbeat:Connect(function(dt)
	wantedTick += dt
	if wantedTick >= 1 then
		wantedTick = 0
		WantedSystem:Tick(1)
	end
end)

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	RoleSystem:OnPlayerRemoving(player)
	BriefcaseSystem:OnPlayerRemoving(player)
	WantedSystem:OnPlayerRemoving(player)
	HealthSystem:OnPlayerRemoving(player)
	VirologySystem:OnPlayerRemoving(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

task.spawn(minutesLoop)

Remotes.OpenDoor.OnServerEvent:Connect(function(player, doorModel)
	if not doorModel or not doorModel:IsA("Model") then return end

	local doorKey = DoorSystem:GetDoorKey(doorModel)
	if DoorSystem:CanOpen(player, doorKey) then
		DoorSystem:Open(doorKey)
	end
end)

Remotes.CloseDoor.OnServerEvent:Connect(function(player, doorModel)
	if not doorModel or not doorModel:IsA("Model") then return end
	local doorKey = DoorSystem:GetDoorKey(doorModel)
	DoorSystem:Close(doorKey)
end)

Remotes.SelectRole.OnServerInvoke = function(player, roleId)
	return RoleSystem:SetRole(player, roleId, false)
end

Remotes.SelectFactionRole.OnServerInvoke = function(player, roleId)
	return RoleSystem:SetRole(player, roleId, true)
end

Remotes.GetPlayerMinutes.OnServerInvoke = function(player)
	return RoleSystem:GetPlayerMinutes(player)
end

Remotes.ToggleAlarm.OnServerEvent:Connect(function(player)
	if player:GetAttribute("CurrentRole") ~= "Manager" and player:GetAttribute("CurrentRole") ~= "SecurityCommander" then
		return
	end
	local state = not ReplicatedStorage:GetAttribute("AlarmActive")
	ControlRoom:ToggleAlarm(state)
end)

Remotes.ToggleContainment.OnServerEvent:Connect(function(player)
	if player:GetAttribute("CurrentRole") ~= "Manager" then return end
	local state = not ReplicatedStorage:GetAttribute("ContainmentLocked")
	ControlRoom:ToggleContainment(state)
end)

Remotes.ToggleExperimentBlock.OnServerEvent:Connect(function(player)
	if player:GetAttribute("CurrentRole") ~= "Manager" then return end
	local state = not ReplicatedStorage:GetAttribute("ExperimentLocked")
	ControlRoom:ToggleExperimentBlock(state)
end)

Remotes.DeclareWanted.OnServerEvent:Connect(function(player, targetName, reason, duration)
	local role = player:GetAttribute("CurrentRole")
	local faction = player:GetAttribute("Faction")

	local canDeclare = false
	if role == "Manager" or role == "SecurityCommander" then
		canDeclare = true
	end
	if faction == "Snezhok" then
		local factionRole = RoleSystem:GetRole(player)
		if factionRole and factionRole.roleId == "SnezhokOfficer" then
			canDeclare = true
		end
	end

	if not canDeclare then return end

	local target = Players:FindFirstChild(targetName)
	if target then
		WantedSystem:DeclareWanted(target, player, duration)
	end
end)

Remotes.ArrestPlayer.OnServerEvent:Connect(function(player, targetName, kpzDuration)
	local faction = player:GetAttribute("Faction")
	if faction ~= "Snezhok" then return end

	local target = Players:FindFirstChild(targetName)
	if target then
		WantedSystem:ArrestPlayer(target, player, kpzDuration)
	end
end)

Remotes.UseBriefcase.OnServerEvent:Connect(function(player, targetPlayer)
	if player:GetAttribute("CurrentRole") ~= "ArmsDealer" then return end
	BriefcaseSystem:Use(nil, player, targetPlayer)
end)

Remotes.ManagerFire.OnServerEvent:Connect(function(player, targetName, reason)
	ManagerComputer:FireEmployee(player, targetName, reason)
end)

Remotes.ManagerDeclareWanted.OnServerEvent:Connect(function(player, targetName, reason, duration)
	ManagerComputer:DeclareWanted(player, targetName, reason, duration)
end)

Remotes.ManagerWarning.OnServerEvent:Connect(function(player, targetName, reason)
	ManagerComputer:IssueWarning(player, targetName, reason)
end)

Remotes.ManagerBonus.OnServerEvent:Connect(function(player, targetName, amount, reason)
	ManagerComputer:GiveBonus(player, targetName, amount, reason)
end)

Remotes.UseMedkit.OnServerEvent:Connect(function(player)
	HealthSystem:UseMedkit(player)
end)

Remotes.UseAdrenaline.OnServerEvent:Connect(function(player)
	HealthSystem:UseAdrenaline(player)
end)

Remotes.OfferPill.OnServerEvent:Connect(function(player, targetPlayer, isForced)
	VirologySystem:OfferPill(player, targetPlayer, isForced)
end)

Remotes.AcceptPill.OnServerEvent:Connect(function(player)
	VirologySystem:AcceptPill(player)
end)

Remotes.DeclinePill.OnServerEvent:Connect(function(player)
	VirologySystem:DeclinePill(player)
end)

Remotes.InjectSyringe.OnServerEvent:Connect(function(player, targetPlayer)
	VirologySystem:InjectSyringe(player, targetPlayer)
end)

Remotes.UseAntidote.OnServerEvent:Connect(function(player, targetPlayer)
	VirologySystem:UseAntidote(player, targetPlayer)
end)

Remotes.ActivateCamera.OnServerEvent:Connect(function(player, cameraId)
	SurveillanceSystem:ActivateCamera(player, cameraId)
end)

Remotes.DeactivateCamera.OnServerEvent:Connect(function(player)
	SurveillanceSystem:DeactivateCamera(player)
end)

Remotes.InteractShield.OnServerEvent:Connect(function(player, shieldId)
	SurveillanceSystem:InteractShield(player, shieldId)
end)

Remotes.BuyItem.OnServerEvent:Connect(function(player, itemId, price)
	local data = DataStore:Get(player)
	if not data then return end

	if data.ciphers >= price then
		DataStore:RemoveCiphers(player, price)

		local toolTemplate = ReplicatedStorage:FindFirstChild("ShopItems"):FindFirstChild(itemId)
		if toolTemplate then
			local clone = toolTemplate:Clone()
			clone.Parent = player.Backpack
		end
	end
end)

Remotes.GetCiphers.OnServerInvoke = function(player)
	local data = DataStore:Get(player)
	return data and data.ciphers or 0
end

Remotes.GetWantedPlayers.OnServerInvoke = function()
	return WantedSystem:GetWantedPlayers()
end

Remotes.GetAvailableRoles.OnServerInvoke = function(player)
	return {
		minuteRoles = RoleSystem:GetAvailableRoles(player),
		factionRoles = RoleSystem:GetAvailableFactionRoles(player),
	}
end

Remotes.EquipWeapon.OnServerEvent:Connect(function(player, weaponModel)
	if not weaponModel or not weaponModel:IsA("Model") then return end
	WeaponSystem:Equip(player, weaponModel)
end)

Remotes.ShootWeapon.OnServerEvent:Connect(function(player)
	WeaponSystem:Shoot(player)
end)

Remotes.ReloadWeapon.OnServerEvent:Connect(function(player)
	WeaponSystem:Reload(player)
end)

Remotes.StartADS.OnServerEvent:Connect(function(player)
	player:SetAttribute("IsAiming", true)
end)

Remotes.StopADS.OnServerEvent:Connect(function(player)
	player:SetAttribute("IsAiming", false)
end)

Remotes.GetAmmo.OnServerInvoke = function(player)
	return WeaponSystem:GetAmmo(player)
end

Players.PlayerRemoving:Connect(function(player)
	WeaponSystem:OnPlayerRemoving(player)
end)
