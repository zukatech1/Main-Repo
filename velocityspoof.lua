local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Config = {
    Enabled = true,
    PoisonVector = Vector3.new(0, -10000, 0), 
}
local RootPart = nil
local function applyVelocityChanger()
    if not RootPart or not Config.Enabled then return end
    local realVelocity = RootPart.AssemblyLinearVelocity
    RootPart.AssemblyLinearVelocity = Config.PoisonVector
    RunService.RenderStepped:Wait()
    if RootPart then
        RootPart.AssemblyLinearVelocity = realVelocity
    end
end
RunService.Heartbeat:Connect(function()
    if not RootPart and LocalPlayer.Character then
        RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    if RootPart and Config.Enabled then
        applyVelocityChanger()
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
        end
    end
end)
