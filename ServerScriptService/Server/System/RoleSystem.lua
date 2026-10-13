local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local RoleSystem = {}
RoleSystem.__index = RoleSystem

local playerRoles = {}

function RoleSystem:SetRole(player, roleId, isFaction)
	local roleData
	if isFaction then
		roleData = Config.FactionRoles[roleId]
	else
		roleData = Config.Roles[roleId]
	end

	if not roleData then return false, "Роль не найдена" end

	if not isFaction then
		local DataStore = require(ReplicatedStorage.Modules.DataStore)
		local data = DataStore:Get(player)
		if not data then return false, "Данные не загружены" end

		if data.firedRoles[roleId] then
			return false, "Вы уволены с этой роли"
		end

		if data.minutes < roleData.minutes then
			return false, "Недостаточно минут"
		end
	end

	if roleData.faction then
		local factionConfig = Config.Factions[roleData.faction]
		if factionConfig and factionConfig.groupId > 0 then
			local success, rank = pcall(function()
				return Players:GetRankInGroup(player, factionConfig.groupId)
			end)
			if not success or rank == 0 then
				return false, "Вы не состоите в группе фракции"
			end
		end
	end

	player:SetAttribute("CurrentRole", roleId)
	player:SetAttribute("CurrentCard", roleData.card)
	player:SetAttribute("AccessLevel", roleData.accessLevel)

	if roleData.faction then
		player:SetAttribute("Faction", roleData.faction)
	end

	playerRoles[player.UserId] = {
		roleId = roleId,
		isFaction = isFaction,
		faction = roleData.faction,
	}

	return true, "Роль назначена"
end

function RoleSystem:RemoveRole(player)
	player:SetAttribute("CurrentRole", nil)
	player:SetAttribute("CurrentCard", nil)
	player:SetAttribute("AccessLevel", 0)
	player:SetAttribute("Faction", nil)
	playerRoles[player.UserId] = nil
end

function RoleSystem:GetRole(player)
	return playerRoles[player.UserId]
end

function RoleSystem:GetAvailableRoles(player)
	local DataStore = require(ReplicatedStorage.Modules.DataStore)
	local data = DataStore:Get(player)
	if not data then return {} end

	local available = {}
	for roleId, roleData in pairs(Config.Roles) do
		if data.minutes >= roleData.minutes and not data.firedRoles[roleId] then
			table.insert(available, {
				id = roleId,
				displayName = roleData.displayName,
				requiredMinutes = roleData.minutes,
			})
		end
	end
	return available
end

function RoleSystem:GetAvailableFactionRoles(player)
	local available = {}
	for roleId, roleData in pairs(Config.FactionRoles) do
		local factionConfig = Config.Factions[roleData.faction]
		local groupId = factionConfig and factionConfig.groupId or 0
		local include = false
		if groupId > 0 then
			local success, rank = pcall(function()
				return Players:GetRankInGroup(player, groupId)
			end)
			include = success and rank > 0
		else
			include = true
		end
		if include then
			table.insert(available, {
				id = roleId,
				displayName = roleData.displayName,
				faction = factionConfig and factionConfig.displayName or roleData.faction,
			})
		end
	end
	return available
end

function RoleSystem:GetPlayerMinutes(player)
	local DataStore = require(ReplicatedStorage.Modules.DataStore)
	local data = DataStore:Get(player)
	return data and data.minutes or 0
end

function RoleSystem:OnPlayerAdded(player)
	player:SetAttribute("CurrentRole", nil)
	player:SetAttribute("CurrentCard", nil)
	player:SetAttribute("AccessLevel", 0)
	player:SetAttribute("Faction", nil)
	player:SetAttribute("IsWanted", false)
end

function RoleSystem:OnPlayerRemoving(player)
	playerRoles[player.UserId] = nil
end

return RoleSystem
