local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local WeaponClient = {}
WeaponClient.__index = WeaponClient

local Remotes = nil
local isAiming = false
local defaultFOV = 70
local adsFOV = 45
local recoilOffset = Vector3.new()
local currentSpread = 0

local ammoGui = nil
local ammoLabel = nil
local reserveLabel = nil
local crosshair = nil
local firing = false

local function isFirstPerson()
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head then return false end
	return (camera.CFrame.Position - head.Position).Magnitude < 2
end

function WeaponClient:Init()
	Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
	self:SetupUI()
	self:SetupInput()
	self:SetupRenderStep()
end

function WeaponClient:SetupUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WeaponHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui

	crosshair = Instance.new("Frame")
	crosshair.Name = "Crosshair"
	crosshair.Size = UDim2.new(0, 20, 0, 20)
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
	crosshair.BackgroundTransparency = 1
	crosshair.Parent = screenGui

	local crossDot = Instance.new("Frame")
	crossDot.Size = UDim2.new(0, 2, 0, 2)
	crossDot.AnchorPoint = Vector2.new(0.5, 0.5)
	crossDot.Position = UDim2.new(0.5, 0, 0.5, 0)
	crossDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	crossDot.BorderSizePixel = 0
	crossDot.Parent = crosshair

	local crossUp = Instance.new("Frame")
	crossUp.Size = UDim2.new(0, 1, 0, 6)
	crossUp.AnchorPoint = Vector2.new(0.5, 1)
	crossUp.Position = UDim2.new(0.5, 0, 0.5, -4)
	crossUp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	crossUp.BorderSizePixel = 0
	crossUp.Parent = crosshair

	local crossDown = Instance.new("Frame")
	crossDown.Size = UDim2.new(0, 1, 0, 6)
	crossDown.AnchorPoint = Vector2.new(0.5, 0)
	crossDown.Position = UDim2.new(0.5, 0, 0.5, 4)
	crossDown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	crossDown.BorderSizePixel = 0
	crossDown.Parent = crosshair

	local crossLeft = Instance.new("Frame")
	crossLeft.Size = UDim2.new(0, 6, 0, 1)
	crossLeft.AnchorPoint = Vector2.new(1, 0.5)
	crossLeft.Position = UDim2.new(0.5, -4, 0.5, 0)
	crossLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	crossLeft.BorderSizePixel = 0
	crossLeft.Parent = crosshair

	local crossRight = Instance.new("Frame")
	crossRight.Size = UDim2.new(0, 6, 0, 1)
	crossRight.AnchorPoint = Vector2.new(0, 0.5)
	crossRight.Position = UDim2.new(0.5, 4, 0.5, 0)
	crossRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	crossRight.BorderSizePixel = 0
	crossRight.Parent = crosshair

	local ammoFrame = Instance.new("Frame")
	ammoFrame.Name = "AmmoDisplay"
	ammoFrame.Size = UDim2.new(0, 160, 0, 50)
	ammoFrame.Position = UDim2.new(1, -170, 1, -60)
	ammoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ammoFrame.BackgroundTransparency = 0.3
	ammoFrame.Parent = screenGui

	local ammoCorner = Instance.new("UICorner")
	ammoCorner.CornerRadius = UDim.new(0, 8)
	ammoCorner.Parent = ammoFrame

	ammoLabel = Instance.new("TextLabel")
	ammoLabel.Name = "Ammo"
	ammoLabel.Size = UDim2.new(0.6, 0, 1, 0)
	ammoLabel.Position = UDim2.new(0, 5, 0, 0)
	ammoLabel.BackgroundTransparency = 1
	ammoLabel.Text = "30"
	ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ammoLabel.Font = Enum.Font.GothamBlack
	ammoLabel.TextSize = 32
	ammoLabel.TextXAlignment = Enum.TextXAlignment.Left
	ammoLabel.Parent = ammoFrame

	reserveLabel = Instance.new("TextLabel")
	reserveLabel.Name = "Reserve"
	reserveLabel.Size = UDim2.new(0.35, 0, 1, 0)
	reserveLabel.Position = UDim2.new(0.6, 0, 0, 0)
	reserveLabel.BackgroundTransparency = 1
	reserveLabel.Text = "/ 90"
	reserveLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	reserveLabel.Font = Enum.Font.Gotham
	reserveLabel.TextSize = 18
	reserveLabel.TextXAlignment = Enum.TextXAlignment.Left
	reserveLabel.Parent = ammoFrame

	ammoGui = screenGui
end

function WeaponClient:SetupInput()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:StartADS()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not player:GetAttribute("EquippedWeapon") then return end
			firing = true
			if player:GetAttribute("EquippedWeaponAuto") then
				task.spawn(function()
					while firing do
						Remotes.ShootWeapon:FireServer()
						task.wait(0.05)
					end
				end)
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			Remotes.ReloadWeapon:FireServer()
		end
	end)

	UserInputService.InputEnded:Connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:StopADS()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			firing = false
		end
	end)
end

function WeaponClient:StartADS()
	if isAiming then return end
	if not player:GetAttribute("EquippedWeapon") then return end
	if not isFirstPerson() then return end
	isAiming = true

	local tween = TweenService:Create(camera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = adsFOV
	})
	tween:Play()

	Remotes.StartADS:FireServer()
end

function WeaponClient:StopADS()
	if not isAiming then return end
	isAiming = false

	local tween = TweenService:Create(camera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = defaultFOV
	})
	tween:Play()

	Remotes.StopADS:FireServer()
end

function WeaponClient:SetupRenderStep()
	local ammoTimer = 0
	RunService.RenderStepped:Connect(function(dt)
		local weaponName = player:GetAttribute("EquippedWeapon")
		if not weaponName then
			if ammoGui then
				ammoGui.Enabled = false
			end
			if crosshair then
				crosshair.Visible = false
			end
			return
		end

		if ammoGui then
			ammoGui.Enabled = true
		end

		if crosshair then
			crosshair.Visible = isFirstPerson()
		end

		if isAiming and not isFirstPerson() then
			self:StopADS()
		end

		recoilOffset = recoilOffset:Lerp(Vector3.new(), dt * 10)

		ammoTimer += dt
		if ammoTimer >= 0.2 and ammoLabel and reserveLabel then
			ammoTimer = 0
			local ok, ammo, reserve = pcall(function()
				return Remotes.GetAmmo:InvokeServer()
			end)
			if ok and ammo then
				ammoLabel.Text = tostring(ammo)
				reserveLabel.Text = "/ " .. tostring(reserve)
			end
		end
	end)
end

function WeaponClient:ApplyRecoil(vertical, horizontal)
	recoilOffset += Vector3.new(horizontal, vertical, 0)
	camera.CFrame = camera.CFrame * CFrame.Angles(
		math.rad(-recoilOffset.Y),
		math.rad(recoilOffset.X),
		0
	)
end

function WeaponClient:UpdateCrosshairSpread(spread)
	local size = 20 + spread * 500
	if crosshair then
		crosshair.Size = UDim2.new(0, size, 0, size)
	end
end

return WeaponClient
