local CONFIG = {
    ENABLED           = true,
    TOGGLE_KEY        = Enum.KeyCode.Plus,
    MAX_DISTANCE      = 500,
    REFRESH_RATE      = 1.5,
    BOX_TRANSPARENCY  = 0.45,
    COLOR_NEAR        = Color3.fromRGB(255, 80,  80),
    COLOR_MID         = Color3.fromRGB(255, 200, 50),
    COLOR_FAR         = Color3.fromRGB(80,  180, 255),
    COLOR_NEAR_DIST   = 50,
    COLOR_FAR_DIST    = 300,
    LABEL_FONT        = Enum.Font.Code,
    LABEL_TEXT_SIZE   = 14,
    LABEL_NAME_COLOR  = Color3.fromRGB(220, 220, 255),
    LABEL_DIST_COLOR  = Color3.fromRGB(180, 220, 180),
    LABEL_HP_COLOR    = Color3.fromRGB(100, 230, 120),
    LABEL_HP_LOW_COLOR= Color3.fromRGB(230, 80,  80),
}
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace      = game:GetService("Workspace")
local LocalPlayer    = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local espData = {}
local enabled = CONFIG.ENABLED
local function getDistanceColor(dist)
    local t = math.clamp(
        (dist - CONFIG.COLOR_NEAR_DIST) / (CONFIG.COLOR_FAR_DIST - CONFIG.COLOR_NEAR_DIST),
        0, 1
    )
    if t <= 0.5 then
        return CONFIG.COLOR_NEAR:Lerp(CONFIG.COLOR_MID, t * 2)
    else
        return CONFIG.COLOR_MID:Lerp(CONFIG.COLOR_FAR, (t - 0.5) * 2)
    end
end
local function isActualPlayer(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then
            return true
        end
    end
    return false
end
local function isValidNPC(model)
    if not model or not model.Parent then return false end
    if model == LocalPlayer.Character then return false end
    if isActualPlayer(model) then return false end
    return model:FindFirstChild("HumanoidRootPart") ~= nil
end
local function createESP(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if espData[model] then
        pcall(function()
            if espData[model].box then espData[model].box:Destroy() end
            if espData[model].billboard then espData[model].billboard:Destroy() end
            for _, c in ipairs(espData[model].connections or {}) do c:Disconnect() end
        end)
    end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_ESP_Box"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = hrp.Size + Vector3.new(0.4, 0.4, 0.4)
    box.Color3 = CONFIG.COLOR_NEAR
    box.Transparency = CONFIG.BOX_TRANSPARENCY
    box.Parent = hrp
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP_Label"
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 54)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.ResetOnSpawn = false
    billboard.Parent = hrp
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = CONFIG.LABEL_FONT
    nameLabel.TextSize = CONFIG.LABEL_TEXT_SIZE
    nameLabel.TextColor3 = CONFIG.LABEL_NAME_COLOR
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.Text = model.Name
    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 16)
    distLabel.Position = UDim2.new(0, 0, 0, 19)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = CONFIG.LABEL_FONT
    distLabel.TextSize = CONFIG.LABEL_TEXT_SIZE - 1
    distLabel.TextColor3 = CONFIG.LABEL_DIST_COLOR
    distLabel.TextStrokeTransparency = 0.4
    distLabel.Text = "? studs"
    local hpLabel = Instance.new("TextLabel", billboard)
    hpLabel.Name = "HpLabel"
    hpLabel.Size = UDim2.new(1, 0, 0, 16)
    hpLabel.Position = UDim2.new(0, 0, 0, 36)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Font = CONFIG.LABEL_FONT
    hpLabel.TextSize = CONFIG.LABEL_TEXT_SIZE - 1
    hpLabel.TextStrokeTransparency = 0.4
    hpLabel.Text = ""
    local connections = {}
    table.insert(connections, model.AncestryChanged:Connect(function()
        if not model.Parent then
            pcall(function() box:Destroy() end)
            pcall(function() billboard:Destroy() end)
            for _, c in ipairs(connections) do c:Disconnect() end
            espData[model] = nil
        end
    end))
    espData[model] = {
        box = box,
        billboard = billboard,
        nameLabel = nameLabel,
        distLabel = distLabel,
        hpLabel = hpLabel,
        connections = connections,
    }
end
local function removeESP(model)
    local data = espData[model]
    if not data then return end
    pcall(function() data.box:Destroy() end)
    pcall(function() data.billboard:Destroy() end)
    for _, c in ipairs(data.connections or {}) do pcall(function() c:Disconnect() end) end
    espData[model] = nil
end
local function clearAllESP()
    for model in pairs(espData) do
        removeESP(model)
    end
end
local function scanWorkspace()
    local seen = {}
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and isValidNPC(descendant) then
            seen[descendant] = true
            if not espData[descendant] then
                createESP(descendant)
            end
        end
    end
    for model in pairs(espData) do
        if not seen[model] then
            removeESP(model)
        end
    end
end
RunService.RenderStepped:Connect(function()
    if not enabled then return end
    local camPos = Camera.CFrame.Position
    for model, data in pairs(espData) do
        if not model.Parent or not data.box.Parent then
            removeESP(model)
            continue
        end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then
            removeESP(model)
            continue
        end
        local dist = (camPos - hrp.Position).Magnitude
        local withinRange = CONFIG.MAX_DISTANCE == 0 or dist <= CONFIG.MAX_DISTANCE
        data.box.Visible = withinRange
        data.billboard.Enabled = withinRange
        if not withinRange then continue end
        data.distLabel.Text = string.format("%.0f studs", dist)
        local col = getDistanceColor(dist)
        data.box.Color3 = col
        data.nameLabel.TextColor3 = col
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local hp    = math.floor(humanoid.Health)
            local maxHp = math.floor(humanoid.MaxHealth)
            local ratio = maxHp > 0 and (hp / maxHp) or 0
            data.hpLabel.Text = string.format("HP: %d / %d", hp, maxHp)
            data.hpLabel.TextColor3 = ratio > 0.4
                and CONFIG.LABEL_HP_COLOR
                or  CONFIG.LABEL_HP_LOW_COLOR
        else
            data.hpLabel.Text = ""
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(CONFIG.REFRESH_RATE)
        if enabled then
            scanWorkspace()
        end
    end
end)
Workspace.DescendantAdded:Connect(function(descendant)
    if not enabled then return end
    task.defer(function()
        if descendant:IsA("Model") and isValidNPC(descendant) and not espData[descendant] then
            createESP(descendant)
        end
    end)
end)
Workspace.DescendantRemoving:Connect(function(descendant)
    if descendant:IsA("Model") and espData[descendant] then
        removeESP(descendant)
    end
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.TOGGLE_KEY then
        enabled = not enabled
        if not enabled then
            clearAllESP()
            warn("NPC ESP: Disabled")
        else
            scanWorkspace()
            warn("NPC ESP: Enabled")
        end
    end
end)
scanWorkspace()
warn("NPC ESP loaded. Toggle: " .. CONFIG.TOGGLE_KEY.Name)
