local WeaponValidator = require(game.ReplicatedStorage.Modules.Weapon.WeaponValidator)

local report = WeaponValidator:ScanAll()
WeaponValidator:PrintReport(report)

local handlesCreated = WeaponValidator:CreateHandles(report)
print("Создано Handle: " .. handlesCreated)

local export = WeaponValidator:ExportReport(report)
return export