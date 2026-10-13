local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function waitForRemotes()
	return ReplicatedStorage:WaitForChild("RemoteEvents", 30)
end

local function initModules()
	local modules = ReplicatedStorage:WaitForChild("Modules", 30)
	if not modules then return false end
	return modules:WaitForChild("Config", 10) ~= nil
end

local function tryInit(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		warn(name .. " init failed: " .. tostring(err))
	end
end

task.spawn(function()
	if not initModules() then
		warn("Modules not loaded")
		return
	end

	waitForRemotes()

	tryInit("ClientController", function()
		local clientController = require(player.PlayerScripts:WaitForChild("ClientController", 30))
		if clientController and clientController.Init then
			clientController:Init()
		end
	end)

	tryInit("WeaponClient", function()
		local weaponClient = require(player.PlayerScripts:WaitForChild("WeaponClient", 30))
		if weaponClient and weaponClient.Init then
			weaponClient:Init()
		end
	end)

	tryInit("MainMenu", function()
		local mainMenu = require(player.PlayerGui:WaitForChild("MainMenu"):WaitForChild("MainMenuClient", 30))
		if mainMenu and mainMenu.Start then
			mainMenu:Start()
		end
	end)
end)
