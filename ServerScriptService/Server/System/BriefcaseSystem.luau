local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local BriefcaseSystem = {}
BriefcaseSystem.__index = BriefcaseSystem

local cooldowns = {}

local weaponPool = {
	"Pistol",
	"Shotgun",
	"SMG",
	"Rifle",
}

function BriefcaseSystem:Use(briefcaseTool, supplierPlayer, targetPlayer)
	local supplierId = supplierPlayer.UserId

	if cooldowns[supplierId] then
		return false, "Перезарядка"
	end

	if not targetPlayer or not targetPlayer.Character then
		return false, "Цель не найдена"
	end

	local distance = (supplierPlayer.Character:GetPivot().Position - targetPlayer.Character:GetPivot().Position).Magnitude
	if distance > 5 then
		return false, "Слишком далеко"
	end

	local randomWeapon = weaponPool[math.random(1, #weaponPool)]

	local weaponTemplate = ReplicatedStorage:FindFirstChild("Weapons"):FindFirstChild(randomWeapon)
	if weaponTemplate then
		local weaponClone = weaponTemplate:Clone()
		weaponClone.Parent = targetPlayer.Backpack
	end

	cooldowns[supplierId] = true
	task.delay(Config.BRIEFCASE_COOLDOWN, function()
		cooldowns[supplierId] = nil
	end)

	return true, "Оружие выдано: " .. randomWeapon
end

function BriefcaseSystem:IsOnCooldown(player)
	return cooldowns[player.UserId] == true
end

function BriefcaseSystem:GetCooldownRemaining(player)
	if not cooldowns[player.UserId] then return 0 end
	return Config.BRIEFCASE_COOLDOWN
end

function BriefcaseSystem:OnPlayerRemoving(player)
	cooldowns[player.UserId] = nil
end

return BriefcaseSystem
