--[[
    â•”â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•—
    â•‘      POISON++ ADVANCED MODULE PATCH                   â•‘
    â•šâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    
    Target:        Setting
    Path:          game:GetService("Players").OverZuka.Backpack.LXD.Setting
    Architecture:  1_ENGINE (75% confidence)
    Generated:     2026-02-13 19:44:15
    Engine:        ZukaTech Poison++ v2.1 (Stability Fix)
--]]

local targetModule = require(game:GetService("Players").OverZuka.Backpack.LXD.Setting)
assert(type(targetModule) == 'table', 'Module must return a table')

-- Disable read-only protection
if setreadonly then 
    pcall(setreadonly, targetModule, false)
end

-- Apply patches
targetModule.ShellClipinSpeed = 999999 -- [PATCHED]
targetModule.FireRate = 0.01 -- [PATCHED]
targetModule.IdleAnimationSpeed = 999999 -- [PATCHED]
targetModule.Lifesteal = 99999 -- [PATCHED]
targetModule.Spread = 0 -- [PATCHED]
targetModule.SpreadRedution = 0 -- [PATCHED]
targetModule.BaseDamage = 999999 -- [PATCHED]
targetModule.ReloadAnimationID = 0.05 -- [PATCHED]
targetModule.ShotgunClipinAnimationSpeed = 999999 -- [PATCHED]
targetModule.DualEnabled = false -- [PATCHED]
targetModule.Knockback = 9999 -- [PATCHED]
targetModule.FireAnimationSpeed = 999999 -- [PATCHED]
targetModule.ReloadAnimationSpeed = 0.05 -- [PATCHED]
targetModule.BulletSpeed = 999999 -- [PATCHED]
targetModule.BulletPerShot = 15 -- [PATCHED]
targetModule.CameraShakingEnabled = false -- [PATCHED]
targetModule.ExplosiveEnabled = false -- [PATCHED]
targetModule.Radius = 999999 -- [PATCHED]
targetModule.VisualizerEnabled = false -- [PATCHED]
targetModule.HeadshotDamageMultiplier = 999999 -- [PATCHED]
targetModule.BurstRate = 0.01 -- [PATCHED]
targetModule.HeadshotEnabled = false -- [PATCHED]
targetModule.SecondaryFireAnimationEnabled = false -- [PATCHED]
targetModule.ReloadTime = 0.05 -- [PATCHED]
targetModule.AmmoPerClip = 999999 -- [PATCHED]

-- Re-enable read-only protection
if setreadonly then 
    pcall(setreadonly, targetModule, true)
end

print('[Poison++] Setting neutralized (25 patches applied)')
return targetModule
