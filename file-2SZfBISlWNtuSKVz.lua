local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local GhostSettings = {
    Enabled = true,
    Radius = 25,
    WhitelistedNames = {"BasePlate", "Floor"},
    CheckColors = {BrickColor.new("Bright red"), BrickColor.new("Really red")}
}
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
RunService.Stepped:Connect(function()
    if not GhostSettings.Enabled then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local parts = game.Workspace:GetPartBoundsInRadius(root.Position, GhostSettings.Radius)
        for _, part in ipairs(parts) do
            local isWhitelisted = false
            for _, whiteName in ipairs(GhostSettings.WhitelistedNames) do
                if part.Name == whiteName then
                    isWhitelisted = true
                    break
                end
            end
            if not isWhitelisted and isDangerous(part) then
                local touchInterest = part:FindFirstChildOfClass("TouchInterest")
                if touchInterest then
                    touchInterest:Destroy()
                end
            end
        end
    end
end)
local mt = getrawmetatable(game)
local old_newindex = mt.__newindex
setreadonly(mt, false)
mt.__newindex = newcclosure(function(t, k, v)
    if not checkcaller() and GhostSettings.Enabled then
        if t:IsA("Humanoid") and k == "Health" and v < t.Health then
            return nil
        end
    end
    return old_newindex(t, k, v)
end)
setreadonly(mt, true)
local function ToggleGhostMode(state)
    GhostSettings.Enabled = state
    print("[TITANIUM] Ghost Protocol: " .. (state and "ENABLED" or "DISABLED"))
end
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.K then
        ToggleGhostMode(not GhostSettings.Enabled)
    end
end)
print("[TITANIUM] Kill-Brick Neutralizer loaded. Press 'K' to toggle.")
