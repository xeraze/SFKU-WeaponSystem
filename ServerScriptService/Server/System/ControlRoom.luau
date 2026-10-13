local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DoorSystem = require(script.Parent.DoorSystem)

local ControlRoom = {}
ControlRoom.__index = ControlRoom

local alarmActive = false
local containmentLocked = false
local experimentLocked = false

function ControlRoom:ToggleAlarm(state)
	alarmActive = state

	local alarmLights = workspace:FindFirstChild("AlarmLights")
	if alarmLights then
		for _, light in ipairs(alarmLights:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Enabled = state
				if state then
					light.Color = Color3.fromRGB(255, 0, 0)
				end
			end
		end
	end

	local siren = SoundService:FindFirstChild("Siren")
	if siren then
		if state then
			siren:Play()
		else
			siren:Stop()
		end
	end

	ReplicatedStorage:SetAttribute("AlarmActive", state)
end

function ControlRoom:ToggleContainment(state)
	containmentLocked = state

	if state then
		DoorSystem:LockAllByType("Hermetic")
	else
		DoorSystem:UnlockAllByType("Hermetic")
	end

	ReplicatedStorage:SetAttribute("ContainmentLocked", state)
end

function ControlRoom:ToggleExperimentBlock(state)
	experimentLocked = state

	if state then
		DoorSystem:LockAllByType("ExperimentDoor")
	else
		DoorSystem:UnlockAllByType("ExperimentDoor")
	end

	ReplicatedStorage:SetAttribute("ExperimentLocked", state)
end

function ControlRoom:GetState()
	return {
		alarmActive = alarmActive,
		containmentLocked = containmentLocked,
		experimentLocked = experimentLocked,
	}
end

return ControlRoom
