local Config = {}

Config.DATASTORE_NAME = "SFKU_PlayerData_v1"
Config.MINUTES_UPDATE_INTERVAL = 60

Config.CIPHERS_INITIAL = 0

Config.PREMIUM_LIMIT = 5000
Config.WANTED_DURATION = 600
Config.KPZ_MAX_DURATION = 1800
Config.WANTED_COOLDOWN = 300

Config.ADRENALINE_DURATION = 180
Config.ADRENALINE_SPEED_MULT = 1.5
Config.MEDKIT_HEAL = 50
Config.BRIEFCASE_COOLDOWN = 180

Config.Roles = {
	DClass = {
		id = "DClass",
		displayName = "D-class",
		minutes = 0,
		accessLevel = 0,
		card = "Card0",
		faction = nil,
	},
	Cleaner = {
		id = "Cleaner",
		displayName = "Уборщик",
		minutes = 20,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	Technician = {
		id = "Technician",
		displayName = "Техник",
		minutes = 40,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	Medic = {
		id = "Medic",
		displayName = "Медик",
		minutes = 60,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	Security = {
		id = "Security",
		displayName = "Охрана",
		minutes = 100,
		accessLevel = 2,
		card = "Card2",
		faction = nil,
	},
	ResearcherLab = {
		id = "ResearcherLab",
		displayName = "Учёный лаборант",
		minutes = 150,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	ResearcherChem = {
		id = "ResearcherChem",
		displayName = "Учёный химик",
		minutes = 250,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	ArmsDealer = {
		id = "ArmsDealer",
		displayName = "Поставщик оружия D-class",
		minutes = 300,
		accessLevel = 1,
		card = "Card1",
		faction = nil,
	},
	SecurityCommander = {
		id = "SecurityCommander",
		displayName = "Командир охраны",
		minutes = 350,
		accessLevel = 3,
		card = "Card3",
		faction = nil,
	},
	ManagerSecretary = {
		id = "ManagerSecretary",
		displayName = "Секретарь менеджера",
		minutes = 400,
		accessLevel = 3,
		card = "Card3",
		faction = nil,
	},
	Manager = {
		id = "Manager",
		displayName = "Менеджер",
		minutes = 650,
		accessLevel = 3,
		card = "Card3",
		faction = nil,
	},
}

Config.Factions = {
	BST = {
		id = "BST",
		displayName = "B.S.T.",
		groupId = 0,
		ranks = {},
	},
	ATF = {
		id = "ATF",
		displayName = "A.T.F.",
		groupId = 0,
		ranks = {},
	},
	Snezhok = {
		id = "Snezhok",
		displayName = 'PMC "Snezhok"',
		groupId = 0,
		ranks = {},
	},
	GDF = {
		id = "GDF",
		displayName = "G.D.F.",
		groupId = 0,
		ranks = {},
	},
	Raider = {
		id = "Raider",
		displayName = "Рейдеры",
		groupId = 0,
		ranks = {},
	},
	Zashchitki = {
		id = "Zashchitki",
		displayName = "Защитки",
		groupId = 0,
		ranks = {},
	},
}

Config.FactionRoles = {
	BSTOfficer = {
		id = "BSTOfficer",
		displayName = "Офицер BST",
		faction = "BST",
		accessLevel = 2,
		card = "CardFactionBST",
	},
	ATFOfficer = {
		id = "ATFOfficer",
		displayName = "Офицер ATF",
		faction = "ATF",
		accessLevel = 2,
		card = "CardFactionATF",
	},
	SnezhokSoldier = {
		id = "SnezhokSoldier",
		displayName = "Боец Snezhok",
		faction = "Snezhok",
		accessLevel = 2,
		card = "CardFactionSnezhok",
	},
	SnezhokOfficer = {
		id = "SnezhokOfficer",
		displayName = "Офицер Snezhok",
		faction = "Snezhok",
		accessLevel = 3,
		card = "CardFactionSnezhok",
	},
	GDFOfficer = {
		id = "GDFOfficer",
		displayName = "Офицер G.D.F.",
		faction = "GDF",
		accessLevel = 2,
		card = "CardFactionGDF",
	},
	RaiderLeader = {
		id = "RaiderLeader",
		displayName = "Лидер рейдеров",
		faction = "Raider",
		accessLevel = 2,
		card = "CardFactionRaider",
	},
}

Config.CardPermissions = {
	Card0 = {
		accessLevel = 0,
		name = "Карта D-class",
		openDoors = {"CellDoor"},
	},
	Card1 = {
		accessLevel = 1,
		name = "Карта уровня 1",
		openDoors = {"CellDoor", "AdminDoor"},
		blockedRooms = {"ControlRoom", "MeetingHall", "ManagerOffice", "DSCOffice", "ExperimentZone"},
	},
	Card2 = {
		accessLevel = 2,
		name = "Карта уровня 2",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"ControlRoom", "MeetingHall", "ManagerOffice", "DSCOffice"},
	},
	Card3 = {
		accessLevel = 3,
		name = "Карта уровня 3",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
	},
	CardFactionBST = {
		accessLevel = 2,
		name = "Карта BST",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
		factionLock = "BST",
	},
	CardFactionATF = {
		accessLevel = 2,
		name = "Карта ATF",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
		factionLock = "ATF",
	},
	CardFactionSnezhok = {
		accessLevel = 2,
		name = "Карта Snezhok",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
		factionLock = "Snezhok",
	},
	CardFactionGDF = {
		accessLevel = 2,
		name = "Карта G.D.F.",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
		factionLock = "GDF",
	},
	CardFactionRaider = {
		accessLevel = 2,
		name = "Карта Рейдеров",
		openDoors = {"CellDoor", "AdminDoor", "ExperimentDoor"},
		blockedRooms = {"MeetingHall", "DSCOffice"},
		factionLock = "Raider",
	},
}

Config.DoorTypes = {
	Regular = {
		openAngle = 90,
		openSpeed = 1,
		animationType = "swing",
	},
	Armored = {
		openOffset = Vector3.new(0, 6, 0),
		openSpeed = 2,
		animationType = "slide_up",
	},
	Hermetic = {
		openOffset = Vector3.new(0, 8, 0),
		openSpeed = 0.5,
		animationType = "slide_up",
	},
}

Config.DShopItems = {
	{weaponId = "Pistol", price = 100},
	{weaponId = "Knife", price = 50},
	{weaponId = "Shotgun", price = 250},
}

Config.DoctorShopItems = {
	{itemId = "Medkit", price = 75},
	{itemId = "Adrenaline", price = 100},
}

Config.Virology = {
	TABLET_MUTATION_DELAY = 15,
	TABLET_EFFECTS = {},
	SYRINGE_EFFECTS = {},
	ANTIDOTE_EFFECTS = {},
}

return Config
