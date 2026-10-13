local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local VirologySystem = {}
VirologySystem.__index = VirologySystem

local activeMutations = {}

function VirologySystem:OfferPill(scientistPlayer, targetPlayer, isForced)
	if not targetPlayer or not targetPlayer.Character then return false, "Цель не найдена" end

	local role = scientistPlayer:GetAttribute("CurrentRole")
	if role ~= "ResearcherLab" and role ~= "ResearcherChem" then
		return false, "Нет доступа"
	end

	if isForced then
		return self:ApplyPill(targetPlayer, scientistPlayer)
	end

	ReplicatedStorage:SetAttribute("PillOffer_" .. targetPlayer.UserId, true)
	ReplicatedStorage:SetAttribute("PillOfferer_" .. targetPlayer.UserId, scientistPlayer.UserId)

	return true, "Предложение таблетки"
end

function VirologySystem:AcceptPill(targetPlayer)
	local offerKey = "PillOffer_" .. targetPlayer.UserId
	local offererKey = "PillOfferer_" .. targetPlayer.UserId

	ReplicatedStorage:SetAttribute(offerKey, false)
	local offererId = ReplicatedStorage:GetAttribute(offererKey)
	ReplicatedStorage:SetAttribute(offererKey, nil)

	local offerer = Players:GetPlayerByUserId(offererId)
	return self:ApplyPill(targetPlayer, offerer)
end

function VirologySystem:DeclinePill(targetPlayer)
	ReplicatedStorage:SetAttribute("PillOffer_" .. targetPlayer.UserId, false)
	ReplicatedStorage:SetAttribute("PillOfferer_" .. targetPlayer.UserId, nil)
end

function VirologySystem:ApplyPill(targetPlayer, sourcePlayer)
	local role = sourcePlayer and sourcePlayer:GetAttribute("CurrentRole")
	if role ~= "ResearcherLab" and role ~= "ResearcherChem" then
		return false, "Нет доступа"
	end

	local userId = targetPlayer.UserId
	if activeMutations[userId] then return false, "Уже в процессе" end

	activeMutations[userId] = true

	task.delay(Config.Virology.TABLET_MUTATION_DELAY, function()
		activeMutations[userId] = nil
		if targetPlayer and targetPlayer.Parent then
			targetPlayer:SetAttribute("IsMutating", true)
			ReplicatedStorage:SetAttribute("Mutation_" .. userId, true)

			task.delay(30, function()
				targetPlayer:SetAttribute("IsMutating", false)
				ReplicatedStorage:SetAttribute("Mutation_" .. userId, false)
			end)
		end
	end)

	return true, "Таблетка применена"
end

function VirologySystem:InjectSyringe(scientistPlayer, targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return false, "Цель не найдена" end

	local role = scientistPlayer:GetAttribute("CurrentRole")
	if role ~= "ResearcherChem" then
		return false, "Только химик"
	end

	local distance = (scientistPlayer.Character:GetPivot().Position - targetPlayer.Character:GetPivot().Position).Magnitude
	if distance > 5 then
		return false, "Слишком далеко"
	end

	local syringeType = scientistPlayer:GetAttribute("HeldSyringeType") or "virus"

	targetPlayer:SetAttribute("SyringeEffect_" .. syringeType, true)
	ReplicatedStorage:SetAttribute("SyringeEffect_" .. targetPlayer.UserId .. "_" .. syringeType, true)

	task.delay(10, function()
		targetPlayer:SetAttribute("SyringeEffect_" .. syringeType, false)
		ReplicatedStorage:SetAttribute("SyringeEffect_" .. targetPlayer.UserId .. "_" .. syringeType, false)
	end)

	return true, "Шприц введён"
end

function VirologySystem:UseAntidote(scientistPlayer, targetPlayer)
	if not targetPlayer or not targetPlayer.Character then return false, "Цель не найдена" end

	local role = scientistPlayer:GetAttribute("CurrentRole")
	if role ~= "ResearcherChem" then
		return false, "Только химик"
	end

	targetPlayer:SetAttribute("IsMutating", false)
	ReplicatedStorage:SetAttribute("Mutation_" .. targetPlayer.UserId, false)

	for effectType, _ in pairs(Config.Virology.ANTIDOTE_EFFECTS) do
		targetPlayer:SetAttribute("SyringeEffect_" .. effectType, false)
		ReplicatedStorage:SetAttribute("SyringeEffect_" .. targetPlayer.UserId .. "_" .. effectType, false)
	end

	return true, "Антидот применён"
end

function VirologySystem:OnPlayerRemoving(player)
	activeMutations[player.UserId] = nil
end

return VirologySystem
