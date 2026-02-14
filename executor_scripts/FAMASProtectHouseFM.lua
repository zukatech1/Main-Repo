
--[[ 
	POISONED PATCH: 1
	ENGINE: Standard Weapon '1' Architecture
	ARCHITECT: Callum (ZukaTech v10)
	TARGET: game:GetService("ReplicatedStorage").Modules.WeaponSettings.Gun.FAMAS.Setting["1"]
--]]

local targetModule = require(game:GetService("ReplicatedStorage").Modules.WeaponSettings.Gun.FAMAS.Setting["1"])
if setreadonly then setreadonly(targetModule, false) end

targetModule.LaserTrailConstantDamage = 999999 -- [PATCHED]
targetModule.PenetrationIgnoreDelay = 0 -- [PATCHED]
targetModule.AngleX_Min = 0 -- [PATCHED]
targetModule.Spread = 0 -- [PATCHED]
targetModule.BaseDamage = 999999 -- [PATCHED]
targetModule.LaserTrailDamageRate = 999999 -- [PATCHED]
targetModule.ChargingTime = 0 -- [PATCHED]
targetModule.EquipTime = 0 -- [PATCHED]
targetModule.BurstRate = 0 -- [PATCHED]
targetModule.Recoil = 0 -- [PATCHED]
targetModule.LaserTrailDamage = 999999 -- [PATCHED]
targetModule.ShotgunEnabled = false -- [PATCHED]
targetModule.Knockback = 9999 -- [PATCHED]
targetModule.AmmoPerMag = 999999 -- [PATCHED]
targetModule.FireRate = 0 -- [PATCHED]
targetModule.ZeroDamageDistance = 999999 -- [PATCHED]
targetModule.HeadshotHitmarker = 100 -- [PATCHED]
targetModule.TacticalReloadTime = 0 -- [PATCHED]
targetModule.ReduceSelfDamageOnAirOnly = 999999 -- [PATCHED]
targetModule.LaserTrailCriticalDamageMultiplier = 999999 -- [PATCHED]
targetModule.DelayAfterFiring = 0 -- [PATCHED]
targetModule.DelayBeforeFiring = 0 -- [PATCHED]
targetModule.DamageDropOffEnabled = 999999 -- [PATCHED]
targetModule.LaserTrailCriticalDamageEnabled = 999999 -- [PATCHED]
targetModule.Range = 90000 -- [PATCHED]
targetModule.BulletSpeed = 90000 -- [PATCHED]
targetModule.DamageableLaserTrail = 999999 -- [PATCHED]
targetModule.SelfDamage = 999999 -- [PATCHED]
targetModule.ReloadTime = 0 -- [PATCHED]
targetModule.DamageBasedOnDistance = 999999 -- [PATCHED]
targetModule.ExplosionRadius = 9999 -- [PATCHED]
targetModule.SwitchTime = 0 -- [PATCHED]
targetModule.FriendlyFire = true -- [PATCHED]
targetModule.BulletPerShot = 5 -- [PATCHED]
targetModule.FullDamageDistance = 999999 -- [PATCHED]
targetModule.SilenceEffect = true -- [PATCHED]
targetModule.HeadshotDamageMultiplier = 999999 -- [PATCHED]
targetModule.Accuracy = 0 -- [PATCHED]
targetModule.AngleX_Max = 0 -- [PATCHED]
targetModule.SelfDamageRedution = 999999 -- [PATCHED]

if setreadonly then setreadonly(targetModule, true) end
print('--> [Poison]: 1 has been neutralized.')