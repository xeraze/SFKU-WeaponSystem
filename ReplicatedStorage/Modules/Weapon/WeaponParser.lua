local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponConfig = require(ReplicatedStorage.Modules.Weapon.WeaponConfig)

local WeaponParser = {}
WeaponParser.__index = WeaponParser

local KEYWORDS = {
	Barrel = {"barrel", "muzzle", "flash", "hider", "suppressor", "thread", "cylinder"},
	Mag = {"mag", "magazine", "clip", "drum", "box", "round"},
	Bolt = {"bolt", "charging", "handle", "charge", "slide"},
	Stock = {"stock", "brace", "buffer", "tube", "back"},
	Grip = {"grip", "handle", "hold"},
	Body = {"receiver", "body", "frame", "lower", "upper", "main", "base", "default"},
}

local function findByNames(weaponModel, targetKey)
	local names = WeaponConfig.PartNames[targetKey]
	for _, name in ipairs(names) do
		local found = weaponModel:FindFirstChild(name, true)
		if found then
			if found:IsA("Model") then
				local base = found:FindFirstChild("Base") or found:FindFirstChildWhichIsA("MeshPart") or found:FindFirstChildWhichIsA("Part")
				return base or found
			end
			return found
		end
	end
	return nil
end

local function findByKeywords(weaponModel, targetKey, exclude)
	local keywords = KEYWORDS[targetKey]
	if not keywords then return nil end
	for _, desc in ipairs(weaponModel:GetDescendants()) do
		if (desc:IsA("MeshPart") or desc:IsA("Part")) and desc ~= exclude then
			local lower = desc.Name:lower()
			for _, kw in ipairs(keywords) do
				if lower:find(kw, 1, true) then
					return desc
				end
			end
		end
	end
	return nil
end

local function getCenter(allParts)
	local sum = Vector3.new(0, 0, 0)
	for _, p in ipairs(allParts) do
		sum = sum + p.Position
	end
	return sum / #allParts
end

local function findBarrelByGeometry(allParts, body)
	if #allParts < 2 then return nil end

	local minX, maxX = math.huge, -math.huge
	local minZ, maxZ = math.huge, -math.huge
	for _, p in ipairs(allParts) do
		minX = math.min(minX, p.Position.X)
		maxX = math.max(maxX, p.Position.X)
		minZ = math.min(minZ, p.Position.Z)
		maxZ = math.max(maxZ, p.Position.Z)
	end

	local axis = (maxX - minX) > (maxZ - minZ) and "X" or "Z"
	local extreme = axis == "X" and maxX or maxZ
	local threshold = axis == "X" and (maxX - minX) * 0.15 or (maxZ - minZ) * 0.15

	local best, bestArea = nil, math.huge
	for _, p in ipairs(allParts) do
		local pos = axis == "X" and p.Position.X or p.Position.Z
		if math.abs(pos - extreme) <= threshold then
			local area = p.Size.X * p.Size.Y + p.Size.X * p.Size.Z + p.Size.Y * p.Size.Z
			if area < bestArea then
				bestArea = area
				best = p
			end
		end
	end

	return best
end

local function findMagByGeometry(allParts, body)
	if not body then return nil end
	local bodyPos = body.Position

	local best, bestDist = nil, math.huge
	for _, p in ipairs(allParts) do
		if p ~= body then
			local offset = p.Position - bodyPos
			if offset.Y < -0.3 then
				local dist = math.sqrt(offset.X * offset.X + offset.Z * offset.Z)
				if dist < bestDist then
					bestDist = dist
					best = p
				end
			end
		end
	end

	return best
end

function WeaponParser:ParseWeapon(weaponModel)
	local parts = {
		barrel = nil,
		bolt = nil,
		mag = nil,
		stock = nil,
		grip = nil,
		trigger = nil,
		body = nil,
		slide = nil,
		allParts = {},
		magPart = nil,
		magModel = nil,
	}

	for _, desc in ipairs(weaponModel:GetDescendants()) do
		if desc:IsA("MeshPart") or desc:IsA("Part") then
			table.insert(parts.allParts, desc)
		end
	end

	parts.barrel = findByNames(weaponModel, "Barrel")
	parts.bolt = findByNames(weaponModel, "Bolt")
	parts.stock = findByNames(weaponModel, "Stock")
	parts.grip = findByNames(weaponModel, "Grip")
	parts.trigger = findByNames(weaponModel, "Trigger")
	parts.slide = findByNames(weaponModel, "Slide")

	for _, name in ipairs(WeaponConfig.PartNames.Mag) do
		local found = weaponModel:FindFirstChild(name, true)
		if found then
			if found:IsA("Model") then
				parts.magModel = found
				parts.mag = found:FindFirstChild("Base") or found:FindFirstChildWhichIsA("MeshPart") or found:FindFirstChildWhichIsA("Part")
			else
				parts.mag = found
			end
			break
		end
	end

	for _, name in ipairs(WeaponConfig.PartNames.Body) do
		local found = weaponModel:FindFirstChild(name, true)
		if found and not found:IsA("Model") then
			parts.body = found
			break
		end
	end

	if not parts.body then
		for _, child in ipairs(weaponModel:GetChildren()) do
			if child:IsA("MeshPart") then
				parts.body = child
				break
			end
		end
	end

	if not parts.body and #parts.allParts > 0 then
		parts.body = parts.allParts[1]
	end

	if not parts.barrel then
		parts.barrel = findByKeywords(weaponModel, "Barrel", parts.body)
	end
	if not parts.barrel and parts.body then
		parts.barrel = findBarrelByGeometry(parts.allParts, parts.body)
	end

	if not parts.mag then
		parts.mag = findByKeywords(weaponModel, "Mag", parts.body)
	end
	if not parts.mag and parts.body then
		parts.mag = findMagByGeometry(parts.allParts, parts.body)
	end

	if not parts.stock then
		parts.stock = findByKeywords(weaponModel, "Stock", parts.body)
	end
	if not parts.grip then
		parts.grip = findByKeywords(weaponModel, "Grip", parts.body)
	end
	if not parts.bolt then
		parts.bolt = findByKeywords(weaponModel, "Bolt", parts.body)
	end

	return parts
end

function WeaponParser:CreateHandle(weaponModel, parts)
	local existing = weaponModel:FindFirstChild("Handle")
	if existing then return existing end

	local handleSource = parts.grip or parts.body
	if not handleSource then return nil end

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 0.2, 0.2)
	handle.CFrame = handleSource.CFrame
	handle.Transparency = 1
	handle.CanCollide = false
	handle.Anchored = false
	handle.Massless = true
	handle.Parent = weaponModel

	return handle
end

function WeaponParser:WeldAllParts(parts)
	local base = parts.grip or parts.body
	if not base then return end
	for _, p in ipairs(parts.allParts) do
		if p ~= base and p.Name ~= "Handle" then
			local wc = Instance.new("WeldConstraint")
			wc.Part0 = base
			wc.Part1 = p
			wc.Parent = p
		end
	end
end

function WeaponParser:CreateBarrelAttachment(weaponModel, parts)
	local barrel = parts.barrel
	if not barrel then return nil end

	local attachment = Instance.new("Attachment")
	attachment.Name = "MuzzleAttachment"
	attachment.Parent = barrel

	local offset = barrel.Size.Z / 2
	attachment.CFrame = CFrame.new(0, 0, -offset)

	return attachment
end

function WeaponParser:GetShootOrigin(weaponModel, parts)
	local attachment = weaponModel:FindFirstChild("MuzzleAttachment", true)
	if attachment then
		return attachment.WorldCFrame.Position, attachment.WorldCFrame.LookVector
	end

	if parts.barrel then
		local barrelCF = parts.barrel.CFrame
		return barrelCF.Position + barrelCF.LookVector * (-parts.barrel.Size.Z / 2), barrelCF.LookVector
	end

	if parts.body then
		local bodyCF = parts.body.CFrame
		return bodyCF.Position + bodyCF.LookVector * (-bodyCF.Size.Z / 2), bodyCF.LookVector
	end

	return nil, nil
end

function WeaponParser:HideMagDuringReload(parts, hidden)
	if parts.mag then
		parts.mag.Transparency = hidden and 1 or 0
	end
	if parts.magModel then
		for _, child in ipairs(parts.magModel:GetDescendants()) do
			if child:IsA("MeshPart") or child:IsA("Part") then
				child.Transparency = hidden and 1 or 0
			end
		end
	end
end

return WeaponParser
