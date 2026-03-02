--[[
    VOID NULLIFICATION PROTOCOL
    Architect: Callum
    Target: Workspace.FallenPartsDestroyHeight & Engine-Level Deletion
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Engine-Level Bypass
-- We set the destruction height to the lowest possible 64-bit float.
-- This effectively tells the engine: "Never delete anything, no matter how far it falls."
Workspace.FallenPartsDestroyHeight = -math.huge

-- 2. State Persistence (Preventing the game from resetting it)
-- Some games have scripts that periodically reset this value to -500. 
-- We use a metatable hook to "lock" our value.
local mt = getrawmetatable(game)
local old_newindex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if t == Workspace and k == "FallenPartsDestroyHeight" then
        -- If the game tries to set a 'normal' kill height, we force it back to infinity.
        return old_newindex(t, k, -math.huge)
    end
    return old_newindex(t, k, v)
end)

setreadonly(mt, true)

-- 3. The "Snap-Back" Logic
-- Even if you don't die, falling forever is useless. 
-- This script detects if you've fallen past a "danger zone" and snaps you back.
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

RunService.Heartbeat:Connect(function()
    local root = getRoot()
    if root then
        -- If we fall below -400 (just before the usual -500 kill zone)
        if root.Position.Y < -400 then
            -- Kill all downward momentum
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            -- Teleport back to the center of the map or a safe height
            -- We add a small offset so you don't get stuck in the floor
            root.CFrame = CFrame.new(0, 100, 0) 
            
            print("[TITANIUM] Void descent intercepted. Character repositioned.")
        end
    end
end)

-- 4. Anti-Deletion (The ultimate fail-safe)
-- If an admin command tries to call :Destroy() on your character while you're in the void.
LocalPlayer.CharacterAdded:Connect(function(char)
    char.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            -- If the character is being deleted/parented to nil, we log it.
            -- Note: Real God Mode usually involves local-character cloning, 
            -- but this alert lets you know a deletion attempt was made.
            warn("[TITANIUM] Character deletion attempt detected.")
        end
    end)
end)

print("[TITANIUM] FallenPartsDestroyHeight set to Infinity. Void is now a playground.")