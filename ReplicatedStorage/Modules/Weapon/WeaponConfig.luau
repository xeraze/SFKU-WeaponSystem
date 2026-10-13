local WeaponConfig = {}

WeaponConfig.Categories = {
	AR = {
		name = "Автоматы",
		weapons = {
			["ACE 23"] = {damage = 25, fireRate = 0.1, magSize = 30, reloadTime = 2.2, recoil = 1.5, range = 200, spread = 0.02},
			["M4A1"] = {damage = 24, fireRate = 0.09, magSize = 30, reloadTime = 2.1, recoil = 1.3, range = 180, spread = 0.018},
			["AK12"] = {damage = 28, fireRate = 0.11, magSize = 30, reloadTime = 2.3, recoil = 1.8, range = 200, spread = 0.022},
			["FAMAS"] = {damage = 22, fireRate = 0.07, magSize = 25, reloadTime = 2.0, recoil = 1.6, range = 160, spread = 0.025},
			["Grau 5.56 (Default)"] = {damage = 26, fireRate = 0.1, magSize = 30, reloadTime = 2.2, recoil = 1.2, range = 200, spread = 0.015},
			["ACR"] = {damage = 24, fireRate = 0.095, magSize = 30, reloadTime = 2.1, recoil = 1.1, range = 190, spread = 0.016},
			["Kilo 141 (Default)"] = {damage = 26, fireRate = 0.1, magSize = 30, reloadTime = 2.2, recoil = 1.4, range = 210, spread = 0.017},
			["Honey Badger"] = {damage = 28, fireRate = 0.09, magSize = 30, reloadTime = 2.0, recoil = 1.3, range = 170, spread = 0.02},
			["AS Val (Default, Ah nuu Cheeki Breeki?)"] = {damage = 30, fireRate = 0.085, magSize = 20, reloadTime = 2.0, recoil = 1.5, range = 150, spread = 0.022},
			["AUG (Default)"] = {damage = 27, fireRate = 0.1, magSize = 30, reloadTime = 2.3, recoil = 1.3, range = 200, spread = 0.018},
			["FAL (Default)"] = {damage = 35, fireRate = 0.15, magSize = 20, reloadTime = 2.4, recoil = 2.0, range = 250, spread = 0.025},
			["HK416D"] = {damage = 26, fireRate = 0.095, magSize = 30, reloadTime = 2.1, recoil = 1.3, range = 200, spread = 0.017},
			["SCAR-H SV"] = {damage = 34, fireRate = 0.13, magSize = 20, reloadTime = 2.3, recoil = 1.9, range = 240, spread = 0.023},
		},
	},
	Rifles = {
		name = "Снайперские",
		weapons = {
			["M82A3"] = {damage = 90, fireRate = 1.5, magSize = 10, reloadTime = 3.5, recoil = 5.0, range = 500, spread = 0.005, boltAction = true},
			["AX-50 (Default)"] = {damage = 85, fireRate = 1.3, magSize = 5, reloadTime = 3.8, recoil = 4.5, range = 480, spread = 0.004, boltAction = true},
			["Kar98k (Default, Scope and Clip Included)"] = {damage = 80, fireRate = 1.4, magSize = 5, reloadTime = 3.0, recoil = 4.0, range = 450, spread = 0.005, boltAction = true},
			["Dragunov (Default)"] = {damage = 70, fireRate = 0.4, magSize = 10, reloadTime = 2.5, recoil = 3.5, range = 400, spread = 0.008},
			["M40 Sniper"] = {damage = 82, fireRate = 1.2, magSize = 5, reloadTime = 3.2, recoil = 4.2, range = 460, spread = 0.004, boltAction = true},
			["M98B"] = {damage = 88, fireRate = 1.3, magSize = 5, reloadTime = 3.5, recoil = 4.8, range = 500, spread = 0.003, boltAction = true},
			["HDR (Default)"] = {damage = 92, fireRate = 1.5, magSize = 5, reloadTime = 3.8, recoil = 5.2, range = 520, spread = 0.003, boltAction = true},
			["CS5(Default)"] = {damage = 65, fireRate = 0.35, magSize = 10, reloadTime = 2.3, recoil = 2.5, range = 350, spread = 0.01},
			["L96A1(CR)"] = {damage = 85, fireRate = 1.3, magSize = 10, reloadTime = 3.0, recoil = 4.0, range = 470, spread = 0.004, boltAction = true},
			["Rytec AMR (Default)"] = {damage = 95, fireRate = 1.8, magSize = 5, reloadTime = 4.0, recoil = 6.0, range = 550, spread = 0.002, boltAction = true},
		},
	},
	SMG = {
		name = "Пистолеты-пулемёты",
		weapons = {
			["MP7 (Default)"] = {damage = 18, fireRate = 0.065, magSize = 40, reloadTime = 1.8, recoil = 0.8, range = 120, spread = 0.03},
			["MP7"] = {damage = 18, fireRate = 0.065, magSize = 40, reloadTime = 1.8, recoil = 0.8, range = 120, spread = 0.03},
			["MP5 SD"] = {damage = 20, fireRate = 0.08, magSize = 30, reloadTime = 1.9, recoil = 0.9, range = 130, spread = 0.028},
			["UMP-45"] = {damage = 24, fireRate = 0.1, magSize = 25, reloadTime = 2.0, recoil = 1.0, range = 140, spread = 0.025},
			["Vector CRB"] = {damage = 16, fireRate = 0.05, magSize = 30, reloadTime = 1.7, recoil = 0.7, range = 110, spread = 0.032},
			["P90"] = {damage = 17, fireRate = 0.055, magSize = 50, reloadTime = 2.2, recoil = 0.6, range = 120, spread = 0.035},
			["CBJ-MS"] = {damage = 19, fireRate = 0.07, magSize = 30, reloadTime = 1.8, recoil = 0.8, range = 125, spread = 0.03},
			["MX4"] = {damage = 20, fireRate = 0.075, magSize = 30, reloadTime = 1.9, recoil = 0.85, range = 130, spread = 0.028},
			["MPX"] = {damage = 22, fireRate = 0.08, magSize = 30, reloadTime = 1.9, recoil = 0.9, range = 135, spread = 0.026},
		},
	},
	Handguns = {
		name = "Пистолеты",
		weapons = {
			["M1911"] = {damage = 30, fireRate = 0.2, magSize = 12, reloadTime = 1.5, recoil = 1.5, range = 80, spread = 0.04},
			["Glock 17"] = {damage = 22, fireRate = 0.12, magSize = 17, reloadTime = 1.3, recoil = 1.0, range = 70, spread = 0.045},
			["Desert Eagle"] = {damage = 50, fireRate = 0.3, magSize = 7, reloadTime = 1.8, recoil = 2.5, range = 100, spread = 0.035},
			[".357 (Default, Speedloader Included)"] = {damage = 55, fireRate = 0.4, magSize = 6, reloadTime = 2.5, recoil = 3.0, range = 90, spread = 0.03, revolver = true},
			["P226"] = {damage = 25, fireRate = 0.15, magSize = 15, reloadTime = 1.4, recoil = 1.2, range = 75, spread = 0.042},
			["M9"] = {damage = 24, fireRate = 0.13, magSize = 15, reloadTime = 1.3, recoil = 1.1, range = 70, spread = 0.043},
			["CZ-75"] = {damage = 26, fireRate = 0.14, magSize = 16, reloadTime = 1.4, recoil = 1.15, range = 75, spread = 0.04},
			["Deagle 44"] = {damage = 48, fireRate = 0.28, magSize = 8, reloadTime = 1.7, recoil = 2.3, range = 95, spread = 0.036},
		},
	},
	MG = {
		name = "Пулемёты",
		weapons = {
			["M249"] = {damage = 22, fireRate = 0.075, magSize = 100, reloadTime = 5.0, recoil = 1.8, range = 180, spread = 0.04},
			["M60"] = {damage = 28, fireRate = 0.1, magSize = 100, reloadTime = 5.5, recoil = 2.2, range = 220, spread = 0.035},
			["RPD"] = {damage = 25, fireRate = 0.09, magSize = 100, reloadTime = 5.0, recoil = 2.0, range = 200, spread = 0.038},
			["RPK-74M"] = {damage = 26, fireRate = 0.1, magSize = 45, reloadTime = 3.0, recoil = 1.8, range = 200, spread = 0.032},
			["MG4"] = {damage = 24, fireRate = 0.085, magSize = 100, reloadTime = 5.2, recoil = 1.9, range = 190, spread = 0.036},
			["PKM (Default, Is it Reused from MWR?)"] = {damage = 30, fireRate = 0.11, magSize = 100, reloadTime = 5.5, recoil = 2.3, range = 230, spread = 0.034},
			["Bruen MK9 (Default, BRU-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH)"] = {damage = 23, fireRate = 0.08, magSize = 100, reloadTime = 5.0, recoil = 1.7, range = 185, spread = 0.037},
			["Holger-26 (Default, GUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH-DUH)"] = {damage = 22, fireRate = 0.075, magSize = 100, reloadTime = 5.0, recoil = 1.6, range = 180, spread = 0.038},
			["M27"] = {damage = 24, fireRate = 0.085, magSize = 100, reloadTime = 5.0, recoil = 1.7, range = 190, spread = 0.035},
		},
	},
}

WeaponConfig.Attachments = {
	Suppressors = {
		{"Suppressor", soundReduction = 0.5, damagePenalty = -2, rangePenalty = -20},
	},
	Scopes = {
		{"Red Dot", zoomMultiplier = 1.5, adsSpeed = 1.2},
		{"ACOG", zoomMultiplier = 3.0, adsSpeed = 1.5},
		{"Sniper Scope", zoomMultiplier = 6.0, adsSpeed = 1.8},
	},
	Grips = {
		{"Vertical Grip", recoilReduction = 0.2},
		{"Angled Grip", adsSpeedBonus = 0.15},
	},
	Stocks = {
		{"Collapsed Stock", mobilityBonus = 0.1, stabilityPenalty = 0.1},
		{"Heavy Stock", stabilityBonus = 0.15, mobilityPenalty = -0.05},
	},
	Barrels = {
		{"Long Barrel", rangeBonus = 50, damageBonus = 3},
		{"Short Barrel", rangePenalty = -30, mobilityBonus = 0.1},
	},
}

WeaponConfig.PartNames = {
	Barrel = {"Barrel", "barrel", "Barrel Base", "Cylinder Barrel", "Barrel Main", "Barrel Cover", "Flash Hider", "Muzzle"},
	Bolt = {"Bolt", "Bolt Part", "Bolt Back", "Bolt Handle", "Bolt1", "Bolt2", "Charging Handle", "Bolt Extraction Handle", "Charge"},
	Mag = {"Mag", "Magazine", "Drum", "Box Mag", "Box", "20 Round Magazine", "30 Round Magazine", "30rnd 5.56mm NATO Magazine", "20rnd 7.62mm NATO Magazine", "5rnd 7.62mm Rimmed Tactical Magazine"},
	Stock = {"Stock", "Back Stock", "Stock Details", "Stock Part", "Stock Wire", "Buffer Tube", "Brace"},
	Grip = {"Grip", "Pistol Grip", "FakeGrip", "VerticleGrip"},
	Trigger = {"Trigger", "Trigger Guard", "Trigger Group", "Match Trigger"},
	Body = {"Default", "MeshPart", "Body", "Main", "Receiver", "Recevier", "Base", "Frame", "Lower", "Upper"},
	Slide = {"Slide", "Topper"},
}

function WeaponConfig:GetWeaponData(weaponName)
	for categoryName, category in pairs(self.Categories) do
		if category.weapons[weaponName] then
			return category.weapons[weaponName], categoryName
		end
	end

	local base = weaponName:match("^(.-)%s*%(") or weaponName
	base = base:match("^(.-)%s*,") or base
	base = base:gsub("%s+$", ""):gsub("^%s+", "")

	for categoryName, category in pairs(self.Categories) do
		if category.weapons[base] then
			return category.weapons[base], categoryName
		end
	end

	local lower = weaponName:lower()
	for categoryName, category in pairs(self.Categories) do
		for key, data in pairs(category.weapons) do
			local keyLower = key:lower()
			local keyBase = keyLower:match("^(.-)%s*%(") or keyLower
			keyBase = keyBase:match("^(.-)%s*,") or keyBase
			keyBase = keyBase:gsub("%s+$", "")
			if lower:find(keyBase, 1, true) or keyBase:find(base:lower(), 1, true) then
				return data, categoryName
			end
		end
	end

	return {damage = 25, fireRate = 0.1, magSize = 30, reloadTime = 2.2, recoil = 1.5, range = 180, spread = 0.02}, "Default"
end

function WeaponConfig:GetAllWeaponNames()
	local names = {}
	for _, category in pairs(self.Categories) do
		for weaponName, _ in pairs(category.weapons) do
			table.insert(names, weaponName)
		end
	end
	return names
end

return WeaponConfig
