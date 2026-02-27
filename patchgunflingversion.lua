--[[Gun Flinger Version]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local weaponNames = {
    "Devil's Gun",
    "G19",
    "IceRevolver",
    "IncendiaryShotgun",
    "M4A1",
    "MK-18",
    "RPG",
    "RocketJump",
}
local weaponPatches = {
    Lifesteal = 0,
    Spread = 0,
    BaseDamage = 0,
    MeleeDamage = 0,
    ChargingTime = 0,
    BulletSpeed = 90000,
    HeadshotEnabled = 0,
    DelayBeforeFiring = 0,
    EquipTime = 0,
    BurstRate = 0,
    Recoil = 0,
    MeleeHeadshotEnabled = 0,
    AngleX_Max = 0,
    CriticalDamageEnabled = 0,
    ShotgunEnabled = true,
    Knockback = 99999999999,
    SwitchTime = 0,
    AmmoPerMag = 999999,
    FireRate = 0,
    Auto = true,
    BulletSize = 1,
    MeleeCriticalDamageMultiplier = 0,
    ZeroDamageDistance = 0,
    DualFireEnabled = false,
    MeleeHeadshotDamageMultiplier = 0,
    CriticalDamageMultiplier = 0,
    TacticalReloadTime = 0,
    DelayAfterFiring = 0,
    ReduceSelfDamageOnAirOnly = 0,
    SelfDamage = 0,
    DamageBasedOnDistance = 0,
    DamageDropOffEnabled = false,
    ReloadTime = 0,
    CrossSize = 2,
    BulletPerShot = 50,
    FriendlyFire = true,
    AngleY_Min = 0,
    Accuracy = 0,
    LimitedAmmoEnabled = false,
    FullDamageDistance = 0,
    HeadshotDamageMultiplier = 0,
    AngleZ_Min = 0,
    SelfDamageRedution = 0,
}
local patchedModules = {}
local totalPatched = 0
local function patchWeaponModule(weapon)
    if not weapon then return false, "Weapon is nil" end
    if not weapon:IsA("Tool") then return false, "Not a tool" end
    local weaponName = weapon.Name
    local success, result = pcall(function()
        local settingFolder = weapon:FindFirstChild("Setting")
        if not settingFolder then
            return false, "No Setting folder"
        end
        local configModule = settingFolder:FindFirstChild("1")
        if not configModule then
            return false, "No '1' module"
        end
        if not configModule:IsA("ModuleScript") then
            return false, "'1' is not a ModuleScript"
        end
        if patchedModules[configModule] then
            return false, "Module already patched"
        end
        task.wait(0.05)
        local moduleTable = require(configModule)
        if type(moduleTable) ~= "table" then
            return false, "Module didn't return table"
        end
        if setreadonly then 
            pcall(setreadonly, moduleTable, false) 
        end
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
        if setreadonly then 
            pcall(setreadonly, moduleTable, true) 
        end
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
local function isTargetWeapon(weaponName)
    for _, name in ipairs(weaponNames) do
        if weaponName == name then
            return true
        end
    end
    return false
end
local function monitorAndPatch(weapon)
    if not weapon:IsA("Tool") then return end
    local success, message = patchWeaponModule(weapon)
    if success then
        print(string.format("✓ [PATCHED] %s (%s properties)", weapon.Name, message))
    elseif message ~= "Module already patched" then
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
    print(string.format("Found %d, patching...", count))
else
    print("Waiting...")
end
print("")
LocalPlayer.Backpack.ChildAdded:Connect(function(item)
    task.wait(0.1)
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
end)
_G.PatchAllWeapons = function()
    print("")
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
    print(string.format("FLinger for %d Active", patched))
end
_G.PatcherStatus = function()
    print("")
    print("=== Fling STATUS ===")
    print(string.format("Fling Applied: %d", totalPatched))
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
