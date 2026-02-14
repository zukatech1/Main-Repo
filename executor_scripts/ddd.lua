
--[[ 
GENERATED PATCH: Setting
	ENGINE: Basic Weapon '1' Architecture
	ARCHITECT: Made with - (ZukaTech v10)
	TARGET: game:GetService("Players").OverZuka.Backpack["RR-10"].Setting
--]]

local targetModule = require(game:GetService("Players").OverZuka.Backpack["RR-10"].Setting)
if setreadonly then setreadonly(targetModule, false) end

targetModule.FireRate = 0 -- [PATCHED]
targetModule.Lifesteal = 99999 -- [PATCHED]
targetModule.DelayBeforeFiring = 0 -- [PATCHED]
targetModule.Spread = 0 -- [PATCHED]
targetModule.Auto = false -- [PATCHED]
targetModule.BaseDamage = 999999 -- [PATCHED]
targetModule.DelayAfterFiring = 0 -- [PATCHED]
targetModule.ChargingTime = 0 -- [PATCHED]
targetModule.BurstRate = 0 -- [PATCHED]
targetModule.BulletSpeed = 90000 -- [PATCHED]
targetModule.Knockback = 9999999 -- [PATCHED]
targetModule.BulletPerShot = 5 -- [PATCHED]
targetModule.ShotgunEnabled = true -- [PATCHED]
targetModule.HeadshotDamageMultiplier = 999999 -- [PATCHED]
targetModule.FlamingBullet = true -- [PATCHED]
targetModule.HeadshotEnabled = 100 -- [PATCHED]
targetModule.ReloadTime = 0 -- [PATCHED]

if setreadonly then setreadonly(targetModule, true) end
print('--> [Poison]: Setting has been neutralized.')