local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local DataStore = {}
DataStore.__index = DataStore

local store = DataStoreService:GetDataStore(Config.DATASTORE_NAME)

local sessionData = {}

local function getDefaultData()
	return {
		minutes = 0,
		ciphers = Config.CIPHERS_INITIAL,
		role = nil,
		faction = nil,
		factionRole = nil,
		wanted = false,
		wantedTimer = 0,
		fired = false,
		firedRoles = {},
		warnings = 0,
		punishments = {},
	}
end

function DataStore:Load(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return store:GetAsync(key)
	end)

	if success and data then
		for k, v in pairs(getDefaultData()) do
			if data[k] == nil then
				data[k] = v
			end
		end
	else
		data = getDefaultData()
	end

	sessionData[player.UserId] = data
	return data
end

function DataStore:Save(player)
	local key = "Player_" .. player.UserId
	local data = sessionData[player.UserId]
	if not data then return end

	pcall(function()
		store:SetAsync(key, data)
	end)
end

function DataStore:Get(player)
	return sessionData[player.UserId]
end

function DataStore:Update(player, fn)
	local data = sessionData[player.UserId]
	if data then
		fn(data)
	end
end

function DataStore:IncrementMinutes(player)
	local data = sessionData[player.UserId]
	if data then
		data.minutes += 1
	end
end

function DataStore:AddCiphers(player, amount)
	local data = sessionData[player.UserId]
	if data then
		data.ciphers += amount
	end
end

function DataStore:RemoveCiphers(player, amount)
	local data = sessionData[player.UserId]
	if data and data.ciphers >= amount then
		data.ciphers -= amount
		return true
	end
	return false
end

function DataStore:SetWanted(player, state, timer)
	local data = sessionData[player.UserId]
	if data then
		data.wanted = state
		data.wantedTimer = timer or 0
	end
end

function DataStore:DecrementWantedTimer(player)
	local data = sessionData[player.UserId]
	if data and data.wanted and data.wantedTimer > 0 then
		data.wantedTimer -= 1
		if data.wantedTimer <= 0 then
			data.wanted = false
			data.wantedTimer = 0
			return true
		end
	end
	return false
end

function DataStore:FireEmployee(player, roleId)
	local data = sessionData[player.UserId]
	if data then
		data.fired = true
		data.firedRoles[roleId] = true
	end
end

function DataStore:ClearSession(player)
	sessionData[player.UserId] = nil
end

function DataStore:IsMinuteUnlocked(player, requiredMinutes)
	local data = sessionData[player.UserId]
	return data and data.minutes >= requiredMinutes
end

function DataStore:IsRoleFired(player, roleId)
	local data = sessionData[player.UserId]
	return data and data.firedRoles[roleId]
end

Players.PlayerRemoving:Connect(function(player)
	DataStore:Save(player)
	DataStore:ClearSession(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataStore:Save(player)
	end
end)

return DataStore
