
--[[ 
GENERATED PATCH: 1
	ENGINE: Basic Weapon '1' Architecture
	ARCHITECT: Made with - (ZukaTech v10)
	TARGET: game:GetService("Players").OverZuka.Backpack.IceRevolver.Setting["1"]
--]]

local targetModule = require(game:GetService("Players").OverZuka.Backpack.IceRevolver.Setting["1"])
if setreadonly then setreadonly(targetModule, false) end

targetModule.Lifesteal = 99999 -- [PATCHED]
targetModule.Spread = 0 -- [PATCHED]
targetModule.ReloadTime = 0 -- [PATCHED]
targetModule.FriendlyFire = true -- [PATCHED]
targetModule.Accuracy = 0 -- [PATCHED]
targetModule.LimitedAmmoEnabled = false -- [PATCHED]

if setreadonly then setreadonly(targetModule, true) end
print('--> [Poison]: 1 has been neutralized.')