local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

type SpreadData = {
	Min: number,
	Max: number,
	Inc: number,
	Rec: number
}

type WeaponStats = {
	Damage: number,
	Length: number,
	Firerate: number,
	HeadshotMultiplier: number,
	Automatic: boolean,
	BulletsPerShot: number,
	Type: string,
	BackOffset: CFrame,
	Spread: SpreadData,
	BulletColor: ColorSequence
}

local function PoisonWeaponModule(moduleInstance: ModuleScript): boolean
	local success: boolean, weaponTable: any = pcall(require, moduleInstance)

	if not success or type(weaponTable) ~= "table" then
		return false
	end

	for weaponName: string, stats: WeaponStats in pairs(weaponTable) do
		if type(stats) == "table" then
			stats.Damage = 999999
			stats.Firerate = 50
			stats.HeadshotMultiplier = 100
			stats.Automatic = true
			
			if stats.Spread then
				stats.Spread.Min = 0
				stats.Spread.Max = 0
				stats.Spread.Inc = 0
				stats.Spread.Rec = 0
			end
		end
	end

	return true
end

local function InitiatePoisoning(): ()
	local targetModule: ModuleScript? = nil
	
	for _: number, v: Instance in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("ModuleScript") and v.Name == "WeaponData" then
			targetModule = v
			break
		end
	end

	if targetModule then
		PoisonWeaponModule(targetModule)
	end
end

InitiatePoisoning()