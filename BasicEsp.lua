local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local espObjects = {}
local function createESP(player)
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        healthBar = Drawing.new("Line"),
        healthBarBg = Drawing.new("Line")
    }
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Color = Color3.new(1, 0, 0)
    esp.box.Transparency = 1
    esp.box.Visible = false
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = Color3.new(1, 1, 1)
    esp.name.Size = 14
    esp.name.Visible = false
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Color = Color3.new(1, 1, 1)
    esp.distance.Size = 12
    esp.distance.Visible = false
    esp.healthBar.Thickness = 3
    esp.healthBar.Color = Color3.new(0, 1, 0)
    esp.healthBar.Visible = false
    esp.healthBarBg.Thickness = 3
    esp.healthBarBg.Color = Color3.new(0.2, 0.2, 0.2)
    esp.healthBarBg.Visible = false
    espObjects[player] = esp
    return esp
end
local function removeESP(player)
    local esp = espObjects[player]
    if esp then
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
        espObjects[player] = nil
    end
end
local function updateESP()
    for player, esp in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                local leg = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = math.abs(head.Y - leg.Y)
                local width = height / 2
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                esp.box.Visible = true
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(vector.X, head.Y - 20)
                esp.name.Visible = true
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                esp.distance.Text = string.format("%.0f studs", distance)
                esp.distance.Position = Vector2.new(vector.X, leg.Y + 5)
                esp.distance.Visible = true
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barHeight = height
                local barX = vector.X - width / 2 - 8
                esp.healthBarBg.From = Vector2.new(barX, vector.Y - height / 2)
                esp.healthBarBg.To = Vector2.new(barX, vector.Y - height / 2 + barHeight)
                esp.healthBarBg.Visible = true
                esp.healthBar.From = Vector2.new(barX, vector.Y - height / 2 + barHeight)
                esp.healthBar.To = Vector2.new(barX, vector.Y - height / 2 + barHeight - (barHeight * healthPercent))
                esp.healthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                esp.healthBar.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.distance.Visible = false
                esp.healthBar.Visible = false
                esp.healthBarBg.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.distance.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBg.Visible = false
        end
    end
end
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)
Players.PlayerRemoving:Connect(removeESP)
RunService.RenderStepped:Connect(updateESP)
