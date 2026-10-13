local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataStore = require(ReplicatedStorage.Modules.DataStore)

local WantedSystem = {}
WantedSystem.__index = WantedSystem

local wantedPlayers = {}

function WantedSystem:DeclareWanted(targetPlayer, reporterPlayer, duration)
	if not targetPlayer or not targetPlayer.Parent then return false, "Игрок не найден" end
	if not reporterPlayer then return false, "Не указан инициатор" end

	local targetData = DataStore:Get(targetPlayer)
	if not targetData then return false, "Данные цели не загружены" end

	duration = math.clamp(duration or Config.WANTED_DURATION, 0, Config.WANTED_DURATION)

	DataStore:SetWanted(targetPlayer, true, duration)
	targetPlayer:SetAttribute("IsWanted", true)
	targetPlayer:SetAttribute("WantedLabel", true)

	wantedPlayers[targetPlayer.UserId] = {
		player = targetPlayer,
		reporter = reporterPlayer,
		timer = duration,
		found = false,
		kpzDuration = 0,
	}

	ReplicatedStorage:SetAttribute("WantedCount", ReplicatedStorage:GetAttribute("WantedCount") + 1)

	return true, "Розыск объявлен"
end

function WantedSystem:RemoveWanted(targetPlayer)
	local userId = targetPlayer.UserId
	wantedPlayers[userId] = nil

	DataStore:SetWanted(targetPlayer, false, 0)
	targetPlayer:SetAttribute("IsWanted", false)
	targetPlayer:SetAttribute("WantedLabel", false)

	ReplicatedStorage:SetAttribute("WantedCount", ReplicatedStorage:GetAttribute("WantedCount") - 1)
end

function WantedSystem:ArrestPlayer(targetPlayer, captorPlayer, kpzDuration)
	local entry = wantedPlayers[targetPlayer.UserId]
	if not entry then return false, "Игрок не в розыске" end

	kpzDuration = math.clamp(kpzDuration or 300, 0, Config.KPZ_MAX_DURATION)

	entry.found = true
	entry.kpzDuration = kpzDuration

	targetPlayer:SetAttribute("InKPZ", true)
	targetPlayer:SetAttribute("KPZTimer", kpzDuration)

	return true, "Игрок арестован"
end

function WantedSystem:Tick(deltaTime)
	for userId, entry in pairs(wantedPlayers) do
		if not entry.found then
			entry.timer -= deltaTime
			if entry.timer <= 0 then
				self:RemoveWanted(entry.player)
			end
		else
			entry.kpzDuration -= deltaTime
			if entry.kpzDuration <= 0 then
				entry.player:SetAttribute("InKPZ", false)
				entry.player:SetAttribute("KPZTimer", 0)
				wantedPlayers[userId] = nil
			end
		end
	end
end

function WantedSystem:GetWantedPlayers()
	local result = {}
	for userId, entry in pairs(wantedPlayers) do
		if not entry.found then
			table.insert(result, {
				player = entry.player,
				timer = entry.timer,
			})
		end
	end
	return result
end

function WantedSystem:IsWanted(player)
	return wantedPlayers[player.UserId] ~= nil
end

function WantedSystem:OnPlayerRemoving(player)
	wantedPlayers[player.UserId] = nil
end

return WantedSystem
