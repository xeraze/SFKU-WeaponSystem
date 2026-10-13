local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MainMenu = {}
MainMenu.__index = MainMenu

local LOADING_STAGES = {
	"Загрузка ассетов",
	"Прогрузка карты",
	"Инициализация систем",
	"Подключение к серверу",
	"Готово",
}

function MainMenu:CreateLoadingScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingScreen"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	bg.BorderSizePixel = 0
	bg.Parent = screenGui

	local logo = Instance.new("ImageLabel")
	logo.Size = UDim2.new(0, 200, 0, 200)
	logo.Position = UDim2.new(0.5, -100, 0.3, -100)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://0"
	logo.Parent = bg

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 60)
	titleLabel.Position = UDim2.new(0, 0, 0.5, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "SFKU.inc"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 48
	titleLabel.Parent = bg

	local progressFrame = Instance.new("Frame")
	progressFrame.Size = UDim2.new(0.6, 0, 0, 4)
	progressFrame.Position = UDim2.new(0.2, 0, 0.7, 0)
	progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	progressFrame.BorderSizePixel = 0
	progressFrame.Parent = bg

	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressFrame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, 0, 0, 30)
	statusLabel.Position = UDim2.new(0, 0, 0.7, 15)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = LOADING_STAGES[1]
	statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 16
	statusLabel.Parent = bg

	for i, stage in ipairs(LOADING_STAGES) do
		statusLabel.Text = stage
		local tween = TweenService:Create(progressFill, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Size = UDim2.new(i / #LOADING_STAGES, 0, 1, 0)
		})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.3)
	end

	local fadeOut = TweenService:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 1,
	})
	for _, desc in ipairs(bg:GetDescendants()) do
		if desc:IsA("TextLabel") then
			TweenService:Create(desc, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1,
				TextTransparency = 1,
			}):Play()
		elseif desc:IsA("ImageLabel") then
			TweenService:Create(desc, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1,
				ImageTransparency = 1,
			}):Play()
		elseif desc:IsA("Frame") then
			TweenService:Create(desc, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1,
			}):Play()
		end
	end
	fadeOut:Play()
	fadeOut.Completed:Wait()

	screenGui:Destroy()
end

function MainMenu:CreateMainMenu()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainMenu"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 99
	screenGui.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	bg.BorderSizePixel = 0
	bg.Parent = screenGui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 60)
	titleLabel.Position = UDim2.new(0, 0, 0.15, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "SFKU.inc"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 56
	titleLabel.Parent = bg

	local function createMenuButton(text, position, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 280, 0, 50)
		btn.Position = position
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 20
		btn.BorderSizePixel = 0
		btn.Parent = bg

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Size = UDim2.new(0, 290, 0, 52),
			}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				Size = UDim2.new(0, 280, 0, 50),
			}):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			callback()
		end)

		return btn
	end

	local mainButtons = Instance.new("Frame")
	mainButtons.Name = "MainButtons"
	mainButtons.Size = UDim2.new(1, 0, 1, 0)
	mainButtons.BackgroundTransparency = 1
	mainButtons.Parent = bg

	createMenuButton("Играть", UDim2.new(0.5, -140, 0.4, 0), function()
		TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		for _, desc in ipairs(bg:GetDescendants()) do
			if desc:IsA("TextLabel") or desc:IsA("TextButton") then
				TweenService:Create(desc, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
			end
		end
		task.wait(0.5)
		screenGui:Destroy()
	end)

	createMenuButton("Выбор роли", UDim2.new(0.5, -140, 0.4, 70), function()
		self:OpenRoleSelection(screenGui, bg)
	end)

	createMenuButton("Разработчики", UDim2.new(0.5, -140, 0.4, 140), function()
		self:OpenDevelopers(screenGui, bg)
	end)
end

function MainMenu:OpenRoleSelection(parentGui, mainBg)
	local roleFrame = Instance.new("Frame")
	roleFrame.Name = "RoleSelection"
	roleFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
	roleFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
	roleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	roleFrame.BorderSizePixel = 0
	roleFrame.Parent = parentGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = roleFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "Выбор роли"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = roleFrame

	local tabsFrame = Instance.new("Frame")
	tabsFrame.Size = UDim2.new(1, 0, 0, 40)
	tabsFrame.Position = UDim2.new(0, 0, 0, 45)
	tabsFrame.BackgroundTransparency = 1
	tabsFrame.Parent = roleFrame

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabsLayout.Padding = UDim.new(0, 10)
	tabsLayout.Parent = tabsFrame

	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "Content"
	contentFrame.Size = UDim2.new(1, -20, 1, -100)
	contentFrame.Position = UDim2.new(0, 10, 0, 95)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ScrollBarThickness = 6
	contentFrame.Parent = roleFrame

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 6)
	contentLayout.Parent = contentFrame

	local function switchTab(tabName)
		for _, child in ipairs(contentFrame:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end

		if tabName == "minutes" then
			local roles = Remotes.GetAvailableRoles:InvokeServer()
			if roles and roles.minuteRoles then
				for _, role in ipairs(roles.minuteRoles) do
					local roleBtn = Instance.new("TextButton")
					roleBtn.Size = UDim2.new(1, 0, 0, 35)
					roleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					roleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					roleBtn.Text = role.displayName .. " | " .. role.requiredMinutes .. " мин"
					roleBtn.Font = Enum.Font.Gotham
					roleBtn.TextSize = 14
					roleBtn.Parent = contentFrame

					local btnCorner = Instance.new("UICorner")
					btnCorner.CornerRadius = UDim.new(0, 6)
					btnCorner.Parent = roleBtn

					roleBtn.MouseButton1Click:Connect(function()
						Remotes.SelectRole:InvokeServer(role.id)
					end)
				end
			end
		elseif tabName == "faction" then
			local roles = Remotes.GetAvailableRoles:InvokeServer()
			if roles and roles.factionRoles then
				for _, role in ipairs(roles.factionRoles) do
					local roleBtn = Instance.new("TextButton")
					roleBtn.Size = UDim2.new(1, 0, 0, 35)
					roleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					roleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					roleBtn.Text = role.displayName .. " | " .. role.faction
					roleBtn.Font = Enum.Font.Gotham
					roleBtn.TextSize = 14
					roleBtn.Parent = contentFrame

					local btnCorner = Instance.new("UICorner")
					btnCorner.CornerRadius = UDim.new(0, 6)
					btnCorner.Parent = roleBtn

					roleBtn.MouseButton1Click:Connect(function()
						Remotes.SelectFactionRole:InvokeServer(role.id)
					end)
				end
			end
		elseif tabName == "project" then
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 30)
			label.BackgroundTransparency = 1
			label.Text = "Роли руководства доступны только для администрации"
			label.TextColor3 = Color3.fromRGB(150, 150, 150)
			label.Font = Enum.Font.Gotham
			label.TextSize = 14
			label.Parent = contentFrame
		end

		contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
	end

	local function createTab(text, tabName)
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 150, 0, 35)
		tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		tab.TextColor3 = Color3.fromRGB(200, 200, 200)
		tab.Text = text
		tab.Font = Enum.Font.Gotham
		tab.TextSize = 14
		tab.Parent = tabsFrame

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 6)
		tabCorner.Parent = tab

		tab.MouseButton1Click:Connect(function()
			switchTab(tabName)
		end)

		return tab
	end

	createTab("Роли за минуты", "minutes")
	createTab("Фракционные роли", "faction")
	createTab("Роли руководства", "project")

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 100, 0, 30)
	closeBtn.Position = UDim2.new(1, -110, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "Назад"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = roleFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		roleFrame:Destroy()
	end)

	switchTab("minutes")
end

function MainMenu:OpenDevelopers(parentGui, mainBg)
	local devFrame = Instance.new("Frame")
	devFrame.Name = "Developers"
	devFrame.Size = UDim2.new(0.7, 0, 0.6, 0)
	devFrame.Position = UDim2.new(0.15, 0, 0.2, 0)
	devFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	devFrame.BorderSizePixel = 0
	devFrame.Parent = parentGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = devFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "Разработчики"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.Parent = devFrame

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -60)
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = devFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = scrollFrame

	local developers = {
		{name = "Разработчик 1", role = "Главный разработчик"},
		{name = "Разработчик 2", role = "Скриптер"},
		{name = "Разработчик 3", role = "Моделлер"},
	}

	for _, dev in ipairs(developers) do
		local devCard = Instance.new("Frame")
		devCard.Size = UDim2.new(1, 0, 0, 60)
		devCard.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		devCard.BorderSizePixel = 0
		devCard.Parent = scrollFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 8)
		cardCorner.Parent = devCard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -10, 0, 25)
		nameLabel.Position = UDim2.new(0, 10, 0, 5)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = dev.name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = devCard

		local roleLabel = Instance.new("TextLabel")
		roleLabel.Size = UDim2.new(1, -10, 0, 20)
		roleLabel.Position = UDim2.new(0, 10, 0, 32)
		roleLabel.BackgroundTransparency = 1
		roleLabel.Text = dev.role
		roleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		roleLabel.Font = Enum.Font.Gotham
		roleLabel.TextSize = 13
		roleLabel.TextXAlignment = Enum.TextXAlignment.Left
		roleLabel.Parent = devCard
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 100, 0, 30)
	closeBtn.Position = UDim2.new(1, -110, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Text = "Назад"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = devFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		devFrame:Destroy()
	end)
end

function MainMenu:Start()
	self:CreateLoadingScreen()
	self:CreateMainMenu()
end

return MainMenu
