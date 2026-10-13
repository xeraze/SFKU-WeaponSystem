local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataStore = require(ReplicatedStorage.Modules.DataStore)
local WantedSystem = require(script.Parent.WantedSystem)

local ManagerComputer = {}
ManagerComputer.__index = ManagerComputer

function ManagerComputer:FireEmployee(managerPlayer, targetName, reason)
	if managerPlayer:GetAttribute("CurrentRole") ~= "Manager" then
		return false, "Нет доступа"
	end

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Игрок не найден"
	end

	local targetRole = target:GetAttribute("CurrentRole")
	if not targetRole then
		return false, "Игрок без роли"
	end

	local DataStoreModule = require(ReplicatedStorage.Modules.DataStore)
	DataStoreModule:FireEmployee(target, targetRole)

	target:SetAttribute("CurrentRole", nil)
	target:SetAttribute("CurrentCard", nil)
	target:SetAttribute("AccessLevel", 0)

	return true, targetName .. " уволен"
end

function ManagerComputer:DeclareWanted(managerPlayer, targetName, reason, duration)
	if managerPlayer:GetAttribute("CurrentRole") ~= "Manager" then
		return false, "Нет доступа"
	end

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Игрок не найден"
	end

	local success, msg = WantedSystem:DeclareWanted(target, managerPlayer, duration)
	return success, msg
end

function ManagerComputer:IssueWarning(managerPlayer, targetName, reason)
	if managerPlayer:GetAttribute("CurrentRole") ~= "Manager" then
		return false, "Нет доступа"
	end

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Игрок не найден"
	end

	DataStore:Update(target, function(data)
		data.warnings += 1
		table.insert(data.punishments, {
			type = "warning",
			reason = reason,
			time = os.time(),
		})
	end)

	return true, "Выговор выдан " .. targetName
end

function ManagerComputer:GiveBonus(managerPlayer, targetName, amount, reason)
	if managerPlayer:GetAttribute("CurrentRole") ~= "Manager" then
		return false, "Нет доступа"
	end

	amount = math.clamp(amount, 0, Config.PREMIUM_LIMIT)

	local target = Players:FindFirstChild(targetName)
	if not target then
		return false, "Игрок не найден"
	end

	DataStore:AddCiphers(target, amount)

	return true, "Премия " .. amount .. " шифров выдана " .. targetName
end

return ManagerComputer
