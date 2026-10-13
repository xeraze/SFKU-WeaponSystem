local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Client = {}
Client.__index = Client

local interactionTarget = nil
local interactionRange = 8
local currentDoor = nil
local wantedLabel = nil
local cipherLabel = nil

function Client:Init()
	self:SetupInteraction()
	self:SetupHUD()
	self:SetupDoorInteraction()
	self:SetupWantedDisplay()
end

function Client:SetupInteraction()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end

		if input.KeyCode == Enum.KeyCode.E then
			self:HandleInteraction("E")
		elseif input.KeyCode == Enum.KeyCode.F then
			self:HandleInteraction("F")
		end
	end)
end

function Client:HandleInteraction(key)
	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local target = self:GetClosestInteractable(rootPart, interactionRange)
	if not target then return end

	local interactType = target:GetAttribute("InteractType")

	if key == "E" then
		if interactType == "Door" then
			Remotes.OpenDoor:FireServer(target)
		elseif interactType == "BriefcaseTarget" then
			Remotes.UseBriefcase:FireServer(player)
		elseif interactType == "PillAccept" then
			Remotes.AcceptPill:FireServer()
		elseif interactType == "DShop" then
			self:OpenDShop()
		elseif interactType == "Shield" then
			Remotes.InteractShield:FireServer(target:GetAttribute("ShieldId"))
		elseif interactType == "CameraDesk" then
			self:OpenCameraSystem()
		elseif interactType == "ManagerComputer" then
			self:OpenManagerMenu()
		end
	elseif key == "F" then
		if interactType == "SyringeTarget" then
			Remotes.InjectSyringe:FireServer(player)
		end
	end
end

function Client:GetClosestInteractable(rootPart, range)
	local closest = nil
	local closestDist = range

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("InteractType") then
			local dist = (rootPart.Position - obj.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = obj
			end
		end
	end

	return closest
end

function Client:SetupHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui

	cipherLabel = Instance.new("TextLabel")
	cipherLabel.Name = "CipherDisplay"
	cipherLabel.Size = UDim2.new(0, 200, 0, 40)
	cipherLabel.Position = UDim2.new(0, 10, 1, -50)
	cipherLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	cipherLabel.BackgroundTransparency = 0.3
	cipherLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	cipherLabel.Font = Enum.Font.GothamBold
	cipherLabel.TextSize = 18
	cipherLabel.Text = "Шифры: 0"
	cipherLabel.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = cipherLabel

	task.spawn(function()
		while true do
			task.wait(2)
			local ok, ciphers = pcall(function()
				return Remotes.GetCiphers:InvokeServer()
			end)
			if ok and ciphers and cipherLabel then
				cipherLabel.Text = "Шифры: " .. tostring(ciphers)
			end
		end
	end)
end

function Client:SetupWantedDisplay()
	wantedLabel = Instance.new("TextLabel")
	wantedLabel.Name = "WantedDisplay"
	wantedLabel.Size = UDim2.new(0, 300, 0, 50)
	wantedLabel.Position = UDim2.new(0.5, -150, 0, 10)
	wantedLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	wantedLabel.BackgroundTransparency = 0.2
	wantedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	wantedLabel.Font = Enum.Font.GothamBold
	wantedLabel.TextSize = 24
	wantedLabel.Text = "РОЗЫСК"
	wantedLabel.Visible = false
	wantedLabel.Parent = player.PlayerGui:WaitForChild("GameHUD")

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = wantedLabel

	player:GetAttributeChangedSignal("IsWanted"):Connect(function()
		wantedLabel.Visible = player:GetAttribute("IsWanted") == true
	end)
end

function Client:SetupDoorInteraction()
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Открыть"
	prompt.ObjectText = "Дверь"
	prompt.MaxActivationDistance = interactionRange
	prompt.HoldDuration = 0
	prompt.KeyboardKeyCode = Enum.KeyCode.E

	workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Model") and obj:GetAttribute("DoorType") then
			local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
			if primaryPart then
				local doorPrompt = prompt:Clone()
				doorPrompt.Parent = primaryPart
				doorPrompt.Triggered:Connect(function()
					Remotes.OpenDoor:FireServer(obj)
				end)
			end
		end
	end)
end

function Client:OpenDShop()
	Remotes.BuyItem:FireServer("Medkit", 75)
end

function Client:OpenCameraSystem()
	local cameras = Remotes.GetAllCameras and Remotes.GetAllCameras:InvokeServer() or {}
	local currentCameraIndex = 1

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CameraSystem"
	screenGui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.Parent = screenGui

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 100, 0, 40)
	closeButton.Position = UDim2.new(1, -110, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Text = "Закрыть"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.Parent = frame

	local nextButton = Instance.new("TextButton")
	nextButton.Size = UDim2.new(0, 60, 0, 40)
	nextButton.Position = UDim2.new(1, -80, 0.5, -20)
	nextButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.Text = ">"
	nextButton.Font = Enum.Font.GothamBold
	nextButton.TextSize = 20
	nextButton.Parent = frame

	local prevButton = Instance.new("TextButton")
	prevButton.Size = UDim2.new(0, 60, 0, 40)
	prevButton.Position = UDim2.new(0, 20, 0.5, -20)
	prevButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	prevButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	prevButton.Text = "<"
	prevButton.Font = Enum.Font.GothamBold
	prevButton.TextSize = 20
	prevButton.Parent = frame

	closeButton.MouseButton1Click:Connect(function()
		Remotes.DeactivateCamera:FireServer()
		screenGui:Destroy()
	end)

	nextButton.MouseButton1Click:Connect(function()
		if #cameras > 0 then
			currentCameraIndex = currentCameraIndex % #cameras + 1
			Remotes.ActivateCamera:FireServer(cameras[currentCameraIndex].id)
		end
	end)

	prevButton.MouseButton1Click:Connect(function()
		if #cameras > 0 then
			currentCameraIndex = (currentCameraIndex - 2) % #cameras + 1
			Remotes.ActivateCamera:FireServer(cameras[currentCameraIndex].id)
		end
	end)
end

function Client:OpenManagerMenu()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ManagerMenu"
	screenGui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.4, 0, 0.5, 0)
	frame.Position = UDim2.new(0.3, 0, 0.25, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "Панель менеджера"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.LayoutOrder = 1
	title.Parent = frame

	local function createButton(text, order, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.8, 0, 0, 40)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.LayoutOrder = order
		btn.Parent = frame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(callback)

		return btn
	end

	local function createInputDialog(titleText, callback)
		local dialog = Instance.new("Frame")
		dialog.Size = UDim2.new(0.3, 0, 0.3, 0)
		dialog.Position = UDim2.new(0.35, 0, 0.35, 0)
		dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		dialog.BorderSizePixel = 0
		dialog.Parent = screenGui

		local dialogCorner = Instance.new("UICorner")
		dialogCorner.CornerRadius = UDim.new(0, 8)
		dialogCorner.Parent = dialog

		local dialogTitle = Instance.new("TextLabel")
		dialogTitle.Size = UDim2.new(1, 0, 0, 30)
		dialogTitle.BackgroundTransparency = 1
		dialogTitle.Text = titleText
		dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		dialogTitle.Font = Enum.Font.GothamBold
		dialogTitle.TextSize = 16
		dialogTitle.Parent = dialog

		local nameInput = Instance.new("TextBox")
		nameInput.Size = UDim2.new(0.8, 0, 0, 30)
		nameInput.Position = UDim2.new(0.1, 0, 0, 40)
		nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameInput.PlaceholderText = "Ник игрока"
		nameInput.Font = Enum.Font.Gotham
		nameInput.TextSize = 14
		nameInput.ClearTextOnFocus = false
		nameInput.Parent = dialog

		local reasonInput = Instance.new("TextBox")
		reasonInput.Size = UDim2.new(0.8, 0, 0, 30)
		reasonInput.Position = UDim2.new(0.1, 0, 0, 80)
		reasonInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		reasonInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		reasonInput.PlaceholderText = "Причина"
		reasonInput.Font = Enum.Font.Gotham
		reasonInput.TextSize = 14
		reasonInput.ClearTextOnFocus = false
		reasonInput.Parent = dialog

		local confirmBtn = Instance.new("TextButton")
		confirmBtn.Size = UDim2.new(0.8, 0, 0, 30)
		confirmBtn.Position = UDim2.new(0.1, 0, 0, 120)
		confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
		confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		confirmBtn.Text = "Готово"
		confirmBtn.Font = Enum.Font.GothamBold
		confirmBtn.TextSize = 14
		confirmBtn.Parent = dialog

		local confirmCorner = Instance.new("UICorner")
		confirmCorner.CornerRadius = UDim.new(0, 6)
		confirmCorner.Parent = confirmBtn

		confirmBtn.MouseButton1Click:Connect(function()
			callback(nameInput.Text, reasonInput.Text)
			dialog:Destroy()
		end)
	end

	createButton("Уволить сотрудника", 2, function()
		createInputDialog("Увольнение", function(name, reason)
			Remotes.ManagerFire:FireServer(name, reason)
		end)
	end)

	createButton("Объявить в розыск", 3, function()
		createInputDialog("Розыск", function(name, reason)
			Remotes.ManagerDeclareWanted:FireServer(name, reason, Config.WANTED_DURATION)
		end)
	end)

	createButton("Выдать выговор", 4, function()
		createInputDialog("Выговор", function(name, reason)
			Remotes.ManagerWarning:FireServer(name, reason)
		end)
	end)

	createButton("Выдать премию", 5, function()
		local dialog = Instance.new("Frame")
		dialog.Size = UDim2.new(0.3, 0, 0.3, 0)
		dialog.Position = UDim2.new(0.35, 0, 0.35, 0)
		dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		dialog.BorderSizePixel = 0
		dialog.Parent = screenGui

		local dialogCorner = Instance.new("UICorner")
		dialogCorner.CornerRadius = UDim.new(0, 8)
		dialogCorner.Parent = dialog

		local dialogTitle = Instance.new("TextLabel")
		dialogTitle.Size = UDim2.new(1, 0, 0, 30)
		dialogTitle.BackgroundTransparency = 1
		dialogTitle.Text = "Премия"
		dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		dialogTitle.Font = Enum.Font.GothamBold
		dialogTitle.TextSize = 16
		dialogTitle.Parent = dialog

		local nameInput = Instance.new("TextBox")
		nameInput.Size = UDim2.new(0.8, 0, 0, 30)
		nameInput.Position = UDim2.new(0.1, 0, 0, 40)
		nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameInput.PlaceholderText = "Ник игрока"
		nameInput.Font = Enum.Font.Gotham
		nameInput.TextSize = 14
		nameInput.ClearTextOnFocus = false
		nameInput.Parent = dialog

		local amountInput = Instance.new("TextBox")
		amountInput.Size = UDim2.new(0.8, 0, 0, 30)
		amountInput.Position = UDim2.new(0.1, 0, 0, 80)
		amountInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		amountInput.PlaceholderText = "Количество шифров"
		amountInput.Font = Enum.Font.Gotham
		amountInput.TextSize = 14
		amountInput.ClearTextOnFocus = false
		amountInput.Parent = dialog

		local confirmBtn = Instance.new("TextButton")
		confirmBtn.Size = UDim2.new(0.8, 0, 0, 30)
		confirmBtn.Position = UDim2.new(0.1, 0, 0, 120)
		confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
		confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		confirmBtn.Text = "Выдать"
		confirmBtn.Font = Enum.Font.GothamBold
		confirmBtn.TextSize = 14
		confirmBtn.Parent = dialog

		local confirmCorner = Instance.new("UICorner")
		confirmCorner.CornerRadius = UDim.new(0, 6)
		confirmCorner.Parent = confirmBtn

		confirmBtn.MouseButton1Click:Connect(function()
			local amount = tonumber(amountInput.Text) or 0
			Remotes.ManagerBonus:FireServer(nameInput.Text, amount, "Премия от менеджера")
			dialog:Destroy()
		end)
	end)

	local closeFrame = Instance.new("TextButton")
	closeFrame.Size = UDim2.new(0.8, 0, 0, 35)
	closeFrame.Position = UDim2.new(0.1, 0, 1, -45)
	closeFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	closeFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeFrame.Text = "Закрыть"
	closeFrame.Font = Enum.Font.GothamBold
	closeFrame.TextSize = 14
	closeFrame.LayoutOrder = 6
	closeFrame.Parent = frame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeFrame

	closeFrame.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
end

return Client
