local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local HealthSystem = {}
HealthSystem.__index = HealthSystem

local activeAdrenaline = {}

function HealthSystem:UseMedkit(player)
	local character = player.Character
	if not character then return false end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	if humanoid.Health >= humanoid.MaxHealth then
		return false, "Полное здоровье"
	end

	humanoid.Health = math.min(humanoid.Health + Config.MEDKIT_HEAL, humanoid.MaxHealth)

	return true, "Аптечка использована"
end

function HealthSystem:UseAdrenaline(player)
	local userId = player.UserId
	if activeAdrenaline[userId] then
		return false, "Адреналин уже активен"
	end

	local character = player.Character
	if not character then return false end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local walkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = walkSpeed * Config.ADRENALINE_SPEED_MULT

	activeAdrenaline[userId] = true

	task.delay(Config.ADRENALINE_DURATION, function()
		activeAdrenaline[userId] = nil
		if character and character.Parent then
			local h = character:FindFirstChildOfClass("Humanoid")
			if h then
				h.WalkSpeed = walkSpeed
			end
		end
	end)

	return true, "Адреналин активирован"
end

function HealthSystem:OnPlayerRemoving(player)
	activeAdrenaline[player.UserId] = nil
end

return HealthSystem
