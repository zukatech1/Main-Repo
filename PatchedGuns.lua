--[[
    UNIVERSAL WEAPON PATCHER v4
    Direct module patching - works on all weapon instances
    Architecture: ZukaTech v10 Enhanced
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- List of all weapons to patch (excluding GAMEPASS variants)
local weaponNames = {
    "VampireMK-18",
    "AKM",
    "BetterG19",
    "BetterM4A1",
    "BodyArmor",
    "BounceUMP-45",
    "C4",
    "Devil's Gun",
    "ExplosiveAKM",
    "Flashlight",
    "G19",
    "Grenade",
    "IceRevolver",
    "IncendiaryAKM",
    "IncendiaryShotgun",
    "Landmine",
    "M4A1",
    "MEDKIT",
    "MK-18",
    "Minigun",
    "Molotov",
    "NPCRadar",
    "NightVision",
    "P90",
    "PREMIUMAKM",
    "Pen90",
    "PlasmaM4A1",
    "PlasmaSniper",
    "PlayerRadar",
    "RPG",
    "Revolver",
    "RocketJump",
    "SHOTGUN",
    "SNIPER",
    "UMP",
    "VIPM4A1",
    ".357 Magnum",
    "Shotgun",
    "UMP-45",
}

-- Weapon modification template
local weaponPatches = {
    Lifesteal = 99999,
    Spread = 0,
    BaseDamage = 999999,
    MeleeDamage = 999999,
    ChargingTime = 0,
    BulletSpeed = 90000,
    HeadshotEnabled = 100,
    DelayBeforeFiring = 0,
    EquipTime = 0,
    BurstRate = 0,
    Recoil = 0,
    MeleeHeadshotEnabled = 100,
    AngleX_Max = 0,
    CriticalDamageEnabled = 999999,
    ShotgunEnabled = false,
    Knockback = 9999999,
    SwitchTime = 0,
    AmmoPerMag = 999999,
    FireRate = 0.1,
    Auto = false,
    BulletSize = 0.8,
    MeleeCriticalDamageMultiplier = 999999,
    ZeroDamageDistance = 999999,
    DualFireEnabled = false,
    MeleeHeadshotDamageMultiplier = 999999,
    CriticalDamageMultiplier = 999999,
    TacticalReloadTime = 0,
    DelayAfterFiring = 0,
    ReduceSelfDamageOnAirOnly = 999999,
    SelfDamage = 0,
    DamageBasedOnDistance = 999999,
    DamageDropOffEnabled = false,
    ReloadTime = 0,
    CrossSize = 2,
    BulletPerShot = 5,
    FriendlyFire = true,
    AngleY_Min = 0,
    Accuracy = 0,
    LimitedAmmoEnabled = false,
    FullDamageDistance = 999999,
    HeadshotDamageMultiplier = 999999,
    AngleZ_Min = 0,
    SelfDamageRedution = 999999,
}

-- Track modules we've already patched (by module reference, not weapon)
local patchedModules = {}
local totalPatched = 0

-- Function to patch a weapon's module
local function patchWeaponModule(weapon)
    if not weapon then return false, "Weapon is nil" end
    if not weapon:IsA("Tool") then return false, "Not a tool" end
    
    local weaponName = weapon.Name
    
    local success, result = pcall(function()
        -- Find the Setting folder
        local settingFolder = weapon:FindFirstChild("Setting")
        if not settingFolder then
            return false, "No Setting folder"
        end
        
        -- Find the "1" module
        local configModule = settingFolder:FindFirstChild("1")
        if not configModule then
            return false, "No '1' module"
        end
        
        if not configModule:IsA("ModuleScript") then
            return false, "'1' is not a ModuleScript"
        end
        
        -- Check if we've already patched this specific module instance
        if patchedModules[configModule] then
            return false, "Module already patched"
        end
        
        -- Small delay to ensure module is loaded
        task.wait(0.05)
        
        -- Require the module
        local moduleTable = require(configModule)
        
        if type(moduleTable) ~= "table" then
            return false, "Module didn't return table"
        end
        
        -- Make writable
        if setreadonly then 
            pcall(setreadonly, moduleTable, false) 
        end
        
        -- Apply patches
        local patchedCount = 0
        for key, value in pairs(weaponPatches) do
            if moduleTable[key] ~= nil then
                local success = pcall(function()
                    moduleTable[key] = value
                end)
                if success then
                    patchedCount = patchedCount + 1
                end
            end
        end
        
        -- Make readonly
        if setreadonly then 
            pcall(setreadonly, moduleTable, true) 
        end
        
        -- Mark this module as patched
        patchedModules[configModule] = {
            weaponName = weaponName,
            patchedCount = patchedCount,
            time = tick()
        }
        
        return true, tostring(patchedCount)
    end)
    
    if success then
        local status, count = result, result
        if type(result) == "table" then
            status = result[1]
            count = result[2]
        end
        
        if status then
            totalPatched = totalPatched + 1
            return true, tostring(count)
        else
            return false, tostring(count)
        end
    else
        return false, tostring(result or "Unknown error")
    end
end

-- Check if weapon is in target list
local function isTargetWeapon(weaponName)
    for _, name in ipairs(weaponNames) do
        if weaponName == name then
            return true
        end
    end
    return false
end

-- Monitor and patch function
local function monitorAndPatch(weapon)
    if not weapon:IsA("Tool") then return end
    
    -- Try to patch even if not in target list (in case of name variations)
    local success, message = patchWeaponModule(weapon)
    
    if success then
        print(string.format("✓ [PATCHED] %s (%s properties)", weapon.Name, message))
    elseif message ~= "Module already patched" then
        -- Only show errors that aren't "already patched"
        if message ~= "No Setting folder" and message ~= "No '1' module" then
            warn(string.format("⚠ [SKIP] %s - %s", weapon.Name, message))
        end
    end
end

local count = 0

for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        task.spawn(function()
            monitorAndPatch(item)
        end)
        count = count + 1
    end
end

-- Check character
if LocalPlayer.Character then
    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
        if item:IsA("Tool") then
            task.spawn(function()
                monitorAndPatch(item)
            end)
            count = count + 1
        end
    end
end

if count > 0 then
    print(string.format("Found %d weapons, patching...", count))
else
    print("No weapons found. Waiting...")
end

print("")

-- Monitor backpack
LocalPlayer.Backpack.ChildAdded:Connect(function(item)
    task.wait(0.1)  -- Small delay for module to load
    if item:IsA("Tool") then
        task.spawn(function()
            monitorAndPatch(item)
        end)
    end
end)

local function setupCharacterMonitor(character)
    character.ChildAdded:Connect(function(item)
        task.wait(0.1)
        if item:IsA("Tool") then
            task.spawn(function()
                monitorAndPatch(item)
            end)
        end
    end)
end

if LocalPlayer.Character then
    setupCharacterMonitor(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    setupCharacterMonitor(character)
    print("Respawned - Auto-patcher active")
end)

-- Manual patch all function
_G.PatchAllWeapons = function()
    print("")
    print("=== MANUAL PATCH ALL ===")
    local patched = 0
    
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local success, message = patchWeaponModule(item)
            if success then
                patched = patched + 1
                print(string.format("✓ %s", item.Name))
            end
        end
    end
    
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                local success, message = patchWeaponModule(item)
                if success then
                    patched = patched + 1
                    print(string.format("✓ %s", item.Name))
                end
            end
        end
    end
    
    print(string.format("Patched %d weapons", patched))
end

-- Status function
_G.PatcherStatus = function()
    print("")
    print("=== PATCHER STATUS ===")
    print(string.format("Total modules patched: %d", totalPatched))
    print("")
    
    local weaponCount = {}
    for module, data in pairs(patchedModules) do
        if module and module.Parent then
            local name = data.weaponName
            weaponCount[name] = (weaponCount[name] or 0) + 1
        end
    end
    
    local sorted = {}
    for name, count in pairs(weaponCount) do
        table.insert(sorted, {name = name, count = count})
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    
    for i, data in ipairs(sorted) do
        print(string.format("  %d. %s (x%d)", i, data.name, data.count))
    end
    
    print("nice")
end
