local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
Workspace.FallenPartsDestroyHeight = -math.huge
local mt = getrawmetatable(game)
local old_newindex = mt.__newindex
setreadonly(mt, false)
mt.__newindex = newcclosure(function(t, k, v)
    if t == Workspace and k == "FallenPartsDestroyHeight" then
        return old_newindex(t, k, -math.huge)
    end
    return old_newindex(t, k, v)
end)
setreadonly(mt, true)
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end
RunService.Heartbeat:Connect(function()
    local root = getRoot()
    if root then
        if root.Position.Y < -400 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(0, 100, 0) 
            print("Void descent intercepted. Character repositioned.")
        end
    end
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    char.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            warn("Character deletion attempt detected.")
        end
    end)
end)
print("Void is now a playground.")
