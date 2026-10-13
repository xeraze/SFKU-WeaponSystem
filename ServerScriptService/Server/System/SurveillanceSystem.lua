local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SurveillanceSystem = {}
SurveillanceSystem.__index = SurveillanceSystem

local cameraStates = {}
local shieldStates = {}

function SurveillanceSystem:Init()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("CameraId") then
			cameraStates[obj:GetAttribute("CameraId")] = {
				part = obj,
				active = true,
			}
		end
		if obj:IsA("BasePart") and obj:GetAttribute("ShieldId") then
			shieldStates[obj:GetAttribute("ShieldId")] = {
				part = obj,
				intact = true,
			}
		end
	end
end

function SurveillanceSystem:ActivateCamera(player, cameraId)
	local camData = cameraStates[cameraId]
	if not camData or not camData.active then return false end

	local camPart = camData.part
	if camPart then
		player.Camera.CameraType = Enum.CameraType.Scriptable
		player.Camera.CFrame = camPart.CFrame * CFrame.new(0, 0, -5)
		player.Camera.CFrame = CFrame.lookAt(player.Camera.CFrame.Position, camPart.Position)
	end

	return true
end

function SurveillanceSystem:DeactivateCamera(player)
	player.Camera.CameraType = Enum.CameraType.Custom
end

function SurveillanceSystem:GetAllCameras()
	local list = {}
	for id, data in pairs(cameraStates) do
		if data.active then
			table.insert(list, {
				id = id,
				part = data.part,
			})
		end
	end
	return list
end

function SurveillanceSystem:BreakShield(shieldId)
	local shield = shieldStates[shieldId]
	if shield then
		shield.intact = false
		ReplicatedStorage:SetAttribute("Shield_" .. shieldId, false)
	end
end

function SurveillanceSystem:RepairShield(player, shieldId)
	local shield = shieldStates[shieldId]
	if not shield or shield.intact then return false end

	local tool = player.Character and player.Character:FindFirstChild("Toolbox")
	if not tool then return false, "Нет инструментов" end

	shield.intact = true
	ReplicatedStorage:SetAttribute("Shield_" .. shieldId, true)
	return true, "Щиток починен"
end

function SurveillanceSystem:InteractShield(player, shieldId)
	local shield = shieldStates[shieldId]
	if not shield then return false end

	if shield.intact then
		return false, "Щиток уже работает"
	end

	if player:GetAttribute("CurrentRole") ~= "Technician" then
		return false, "Только техник может чинить"
	end

	local tool = player.Character and player.Character:FindFirstChild("Toolbox")
	if not tool then return false, "Возьмите коробку с инструментами" end

	return self:RepairShield(player, shieldId)
end

return SurveillanceSystem
