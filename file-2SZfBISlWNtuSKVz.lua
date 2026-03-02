--[[
    TITANIUM KILL-BRICK NEUTRALIZER (GHOST PROTOCOL)
    Architect: Callum
    Description: Actively strips TouchInterests from the environment to bypass .Touched triggers.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local GhostSettings = {
    Enabled = true, -- Your toggle variable
    Radius = 25, -- How far ahead to "cleanse" kill-bricks
    WhitelistedNames = {"BasePlate", "Floor"}, -- Don't touch these to prevent world breakage
    CheckColors = {BrickColor.new("Bright red"), BrickColor.new("Really red")} -- Common kill-brick colors
}

-- Utility: Check if a part is likely a Kill-Brick
local function isDangerous(part)
    if not part:IsA("BasePart") then return false end
    
    local name = part.Name:lower()
    if name:find("kill") or name:find("lava") or name:find("acid") or name:find("deadly") then
        return true
    end
    
    for _, color in ipairs(GhostSettings.CheckColors) do
        if part.BrickColor == color then
            return true
        end
    end
    
    return false
end

-- The Neutralizer Loop
RunService.Stepped:Connect(function()
    if not GhostSettings.Enabled then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Get all parts in a radius around the player
        local parts = game.Workspace:GetPartBoundsInRadius(root.Position, GhostSettings.Radius)
        
        for _, part in ipairs(parts) do
            -- Optimization: Ensure we don't break the actual map floors
            local isWhitelisted = false
            for _, whiteName in ipairs(GhostSettings.WhitelistedNames) do
                if part.Name == whiteName then
                    isWhitelisted = true
                    break
                end
            end
            
            if not isWhitelisted and isDangerous(part) then
                -- Locate and destroy the TouchInterest locally
                -- This makes the part "invisible" to the server's .Touched events
                local touchInterest = part:FindFirstChildOfClass("TouchInterest")
                if touchInterest then
                    touchInterest:Destroy()
                end
            end
        end
    end
end)

-- INTEGRATION WITH HP LOCK (The Fail-Safe)
-- If a kill-brick uses 'GetTouchingParts' instead of '.Touched', this catches it.
local mt = getrawmetatable(game)
local old_newindex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and GhostSettings.Enabled then
        if t:IsA("Humanoid") and k == "Health" and v < t.Health then
            -- If HP tries to drop while Ghosting is on, block it.
            return nil
        end
    end
    return old_newindex(t, k, v)
end)

setreadonly(mt, true)

-- COMMAND INTERFACE (Example of how to toggle)
-- You can bind this to your existing UI toggle logic.
local function ToggleGhostMode(state)
    GhostSettings.Enabled = state
    print("[TITANIUM] Ghost Protocol: " .. (state and "ENABLED" or "DISABLED"))
end

-- Example: Pressing 'K' to toggle (optional, for testing)
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        ToggleGhostMode(not GhostSettings.Enabled)
    end
end)

print("[TITANIUM] Kill-Brick Neutralizer loaded. Press 'K' to toggle.")