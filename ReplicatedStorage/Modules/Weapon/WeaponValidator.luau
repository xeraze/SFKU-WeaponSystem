local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponConfig = require(ReplicatedStorage.Modules.Weapon.WeaponConfig)
local WeaponParser = require(ReplicatedStorage.Modules.Weapon.WeaponParser)

local WeaponValidator = {}
WeaponValidator.__index = WeaponValidator

function WeaponValidator:ValidateWeapon(weaponModel)
	local parts = WeaponParser:ParseWeapon(weaponModel)
	local result = {
		name = weaponModel.Name,
		hasBarrel = parts.barrel ~= nil,
		hasMag = parts.mag ~= nil,
		hasBody = parts.body ~= nil,
		hasBolt = parts.bolt ~= nil,
		hasStock = parts.stock ~= nil,
		hasGrip = parts.grip ~= nil,
		partsCount = #parts.allParts,
		isUsable = false,
		reasons = {},
		warnings = {},
	}

	local weaponData = WeaponConfig:GetWeaponData(weaponModel.Name)
	if not weaponData then
		table.insert(result.reasons, "Нет конфига в WeaponConfig")
		return result
	end

	if not result.hasBody then
		table.insert(result.reasons, "Нет тела (Body)")
	end

	if not result.hasBarrel then
		table.insert(result.warnings, "Нет Barrel (стрельба от Body)")
	end

	if not result.hasMag then
		table.insert(result.warnings, "Нет Mag (перезарядка без анимации)")
	end

	if result.partsCount < 2 then
		table.insert(result.reasons, "Слишком мало частей: " .. result.partsCount)
	end

	result.isUsable = #result.reasons == 0

	return result
end

function WeaponValidator:ScanAll()
	local report = {
		usable = {},
		unusable = {},
		totalScanned = 0,
		categories = {},
	}

	local function scanFolder(folder)
		if not folder then return end
		for _, weapon in ipairs(folder:GetChildren()) do
			if weapon:IsA("Model") then
				local result = self:ValidateWeapon(weapon)
				report.totalScanned += 1

				if result.isUsable then
					table.insert(report.usable, result)
				else
					table.insert(report.unusable, result)
				end
			end
		end
	end

	local workspaceFolders = {"AR's", "Rifles", "Handguns", "SMG's", "Machine Guns"}
	for _, folderName in ipairs(workspaceFolders) do
		local folder = workspace:FindFirstChild(folderName)
		if folder then
			report.categories[folderName] = {usable = 0, unusable = 0}
			for _, weapon in ipairs(folder:GetChildren()) do
				if weapon:IsA("Model") then
					local result = self:ValidateWeapon(weapon)
					report.totalScanned += 1

					if result.isUsable then
						table.insert(report.usable, result)
						report.categories[folderName].usable += 1
					else
						table.insert(report.unusable, result)
						report.categories[folderName].unusable += 1
					end
				end
			end
		end
	end

	return report
end

function WeaponValidator:PrintReport(report)
	print("========== ОТЧЁТ ВАЛИДАЦИИ ОРУЖИЯ ==========")
	print("Всего проверено: " .. report.totalScanned)
	print("Работоспособных: " .. #report.usable)
	print("Неработоспособных: " .. #report.unusable)
	print("")

	print("--- ПО КАТЕГОРИЯМ ---")
	for catName, stats in pairs(report.categories) do
		local total = stats.usable + stats.unusable
		local percent = total > 0 and math.floor((stats.usable / total) * 100) or 0
		print(catName .. ": " .. stats.usable .. "/" .. total .. " (" .. percent .. "%)")
	end

	print("")
	print("--- РАБОТАЮЩЕЕ ОРУЖИЕ ---")
	for _, weapon in ipairs(report.usable) do
		local flags = {}
		if weapon.hasBarrel then table.insert(flags, "BRL") end
		if weapon.hasMag then table.insert(flags, "MAG") end
		if weapon.hasBolt then table.insert(flags, "BLT") end
		if weapon.hasStock then table.insert(flags, "STK") end
		if weapon.hasGrip then table.insert(flags, "GRP") end
		print("[OK] " .. weapon.name .. " | " .. weapon.partsCount .. " parts | " .. table.concat(flags, ", "))
	end

	print("")
	print("--- НЕ РАБОТАЮЩЕЕ ОРУЖИЕ ---")
	for _, weapon in ipairs(report.unusable) do
		print("[X] " .. weapon.name .. " | Причины: " .. table.concat(weapon.reasons, "; "))
	end

	print("")
	print("--- РАБОТАЮЩЕЕ С ПРЕДУПРЕЖДЕНИЯМИ ---")
	for _, weapon in ipairs(report.usable) do
		if weapon.warnings and #weapon.warnings > 0 then
			print("[!] " .. weapon.name .. " | " .. table.concat(weapon.warnings, "; "))
		end
	end

	print("")
	print("========== КОНЕЦ ОТЧЁТА ==========")
end

function WeaponValidator:CreateHandles(report)
	local created = 0
	for _, weaponInfo in ipairs(report.usable) do
		local weaponModel = self:FindWeaponModel(weaponInfo.name)
		if weaponModel then
			local parts = WeaponParser:ParseWeapon(weaponModel)
			WeaponParser:CreateHandle(weaponModel, parts)
			WeaponParser:CreateBarrelAttachment(weaponModel, parts)
			created += 1
		end
	end
	return created
end

function WeaponValidator:FindWeaponModel(name)
	local folders = {"AR's", "Rifles", "Handguns", "SMG's", "Machine Guns"}
	for _, folderName in ipairs(folders) do
		local folder = workspace:FindFirstChild(folderName)
		if folder then
			local found = folder:FindFirstChild(name)
			if found then return found end
		end
	end
	return nil
end

function WeaponValidator:ExportReport(report)
	local lines = {}

	table.insert(lines, "VALIDATION REPORT - SFKU Weapons")
	table.insert(lines, "================================")
	table.insert(lines, "Total: " .. report.totalScanned)
	table.insert(lines, "Usable: " .. #report.usable)
	table.insert(lines, "Unusable: " .. #report.unusable)
	table.insert(lines, "")

	table.insert(lines, "CATEGORIES:")
	for catName, stats in pairs(report.categories) do
		local total = stats.usable + stats.unusable
		local percent = total > 0 and math.floor((stats.usable / total) * 100) or 0
		table.insert(lines, "  " .. catName .. ": " .. stats.usable .. "/" .. total .. " (" .. percent .. "%)")
	end
	table.insert(lines, "")

	table.insert(lines, "USABLE WEAPONS:")
	for _, weapon in ipairs(report.usable) do
		table.insert(lines, "  [OK] " .. weapon.name)
	end
	table.insert(lines, "")

	table.insert(lines, "UNUSABLE WEAPONS:")
	for _, weapon in ipairs(report.unusable) do
		table.insert(lines, "  [X] " .. weapon.name .. " - " .. table.concat(weapon.reasons, "; "))
	end

	return table.concat(lines, "\n")
end

return WeaponValidator
