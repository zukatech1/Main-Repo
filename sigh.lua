


local targetModule = require(game:GetService("ReplicatedStorage").Modules.WeaponSettings.Gun.Revolver.Setting["1"]) -- You can also change the revolver to whatever gun in the game, and yes. it does work best with the pumpkin launcher.
if setreadonly then setreadonly(targetModule, false) end



-- These are the most important two, having them on nil will prevent your client from crashing.
targetModule.BulletType = nil 
targetModule.ProjectileType = nil

-- the higher the number the laggier it will be for other players, 1000 is enough to cause a massive drop to them but no crash. the highest i've tested was 10k which will fucking freeze everyones phone or pc. but you still remain cause swag
targetModule.BulletPerShot = 1000 
targetModule.ShotgunEnabled = true 





--Misc Settings.
targetModule.Spread = 0 
targetModule.EquipTime = 0 
targetModule.Recoil = 0 
targetModule.Auto = true
targetModule.Knockback = 9999999 
targetModule.AmmoPerMag = 999999 
targetModule.FireRate = 0 
targetModule.TacticalReloadTime = 0 
targetModule.DelayAfterFiring = 0 
targetModule.DelayBeforeFiring = 0 
targetModule.Range = 90000 
targetModule.BulletSpeed = 90000 
targetModule.Lifetime = 9999
targetModule.BulletSize = 10
targetModule.ReloadTime = 0 
targetModule.SwitchTime = 0 
targetModule.SilenceEffect = true 
targetModule.Accuracy = 0 

if setreadonly then setreadonly(targetModule, true) end
