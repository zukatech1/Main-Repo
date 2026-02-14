--[[

    Gaming Chair  v2
    Made by Zuka
    
    Press INSERT to toggle GUI
    Hold RMB to lock on targets 

    PID Controller is buggy so disable it, Aim randomization is still a wip 
    The delete tool can be used on games with bad security, so you can delete a wall or anything a player is hiding behind and be able to kill them.

    idk if this will work on mobile lmk

]]



local Modules = {}
Modules.ZukaAimbot = {
    State = {
        IsEnabled = false,
        Window = nil,
        Connections = {},
        AimbotCore = nil,
        Aimbot = {
            Enabled = true,
            IsAiming = false,
            CurrentTarget = nil,
            VelocityHistory = {},
            TargetIndex = {},
            LastIndexUpdate = 0,
            FOVCircle = nil,
            ESPObjects = {},
            ToggleKey = Enum.UserInputType.MouseButton2,
            AimPart = "Head",
            FOVRadius = 100,
            ShowFOVCircle = false,
            SmoothingEnabled = true,
            SmoothingFactor = 0.2,
            DistanceBasedSmoothing = true,
            WallCheckEnabled = false,
            IgnoreTeam = false,
            StickyTarget = true,
            PredictionEnabled = true,
            PredictionMultiplier = 1.0,
            HitboxPriority = false,
            UpdateRate = 0.5,
            PredictionSamples = 3,
            StickyDistanceMultiplier = 1.5,
            UsePIDController = false,
            UseAdvancedScoring = true,
            AimRandomization = false,
            RandomizationMin = 0.92,
            RandomizationMax = 0.98,
            HealthPriority = 0.3,
            DistancePriority = 0.2
        },
        DeleteTool = {
            Enabled = false,
            DeleteMode = "Part",
            MaxDistance = 500,
            IgnorePlayers = true,
            IgnoreTerrain = true,
            ShowHighlight = false,
            DeleteBind = Enum.KeyCode.V,
            DeletedParts = {},
            CurrentHighlight = nil
        }
    }
}
local HITBOX_PRIORITIES = {
    {Name = "Head", Priority = 1, DamageMultiplier = 2.0},
    {Name = "UpperTorso", Priority = 2, DamageMultiplier = 1.5},
    {Name = "HumanoidRootPart", Priority = 3, DamageMultiplier = 1.0},
    {Name = "Torso", Priority = 4, DamageMultiplier = 1.5},
    {Name = "LowerTorso", Priority = 5, DamageMultiplier = 1.0},
}
local PID = {}
PID.__index = PID
function PID:new(kp, ki, kd)
    local obj = {
        kp = kp or 0.5,
        ki = ki or 0.1,
        kd = kd or 0.2,
        prev_error = 0,
        integral = 0,
        dt = 1/60
    }
    setmetatable(obj, PID)
    return obj
end
function PID:calculate(setpoint, measurement)
    local error = setpoint - measurement
    self.integral = self.integral + error * self.dt
    self.integral = math.clamp(self.integral, -10, 10)
    local derivative = (error - self.prev_error) / self.dt
    local output = self.kp * error + 
                   self.ki * self.integral + 
                   self.kd * derivative
    self.prev_error = error
    return output
end
function PID:reset()
    self.prev_error = 0
    self.integral = 0
end
local function DoNotif(message, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Zuka Aimbot";
            Text = message;
            Duration = duration or 3;
        })
    end)
end
function Modules.ZukaAimbot:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/Luna.lua"))()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Aimbot = self.State.Aimbot
    local DeleteTool = self.State.DeleteTool
    local pitchPID = PID:new(0.4, 0.08, 0.15)
    local yawPID = PID:new(0.4, 0.08, 0.15)
    local wallCheckParams = RaycastParams.new()
    wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
    local function updateTargetIndex(force)
        local now = tick()
        if not force and (now - Aimbot.LastIndexUpdate) < Aimbot.UpdateRate then
            return
        end
        Aimbot.LastIndexUpdate = now
        Aimbot.TargetIndex = {}
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
                local humanoid = descendant:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    table.insert(Aimbot.TargetIndex, descendant)
                end
            end
        end
    end
    local function isTeammate(player)
        if not Aimbot.IgnoreTeam or not player then
            return false
        end
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
            return true
        end
        if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then
            return true
        end
        return false
    end
    local function isPartVisible(targetPart)
        if not Aimbot.WallCheckEnabled then
            return true
        end
        if not LocalPlayer.Character or not targetPart or not targetPart.Parent then
            return false
        end
        local targetCharacter = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent
        local origin = Camera.CFrame.Position
        local filterList = {LocalPlayer.Character, targetCharacter}
        wallCheckParams.FilterDescendantsInstances = filterList
        local result = Workspace:Raycast(origin, targetPart.Position - origin, wallCheckParams)
        return not result
    end
    local function getSmartHitbox(model)
        if not Aimbot.HitboxPriority then
            return model:FindFirstChild(Aimbot.AimPart)
        end
        for _, hitbox in ipairs(HITBOX_PRIORITIES) do
            local part = model:FindFirstChild(hitbox.Name)
            if part and isPartVisible(part) then
                return part
            end
        end
        for _, hitbox in ipairs(HITBOX_PRIORITIES) do
            local part = model:FindFirstChild(hitbox.Name)
            if part then
                return part
            end
        end
        return nil
    end
    local function calculateTargetScore(model, targetPart, screenDistance)
        if not Aimbot.UseAdvancedScoring then
            return screenDistance
        end
        local score = 1000 / (screenDistance + 1)
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local healthFactor = 1.0 - (humanoid.Health / humanoid.MaxHealth) * Aimbot.HealthPriority
            score = score * healthFactor
        end
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local distance = (LocalPlayer.Character.PrimaryPart.Position - targetPart.Position).Magnitude
            local distanceFactor = 1.0 / (1.0 + distance / 1000)
            score = score * (1.0 + distanceFactor * Aimbot.DistancePriority)
        end
        if Aimbot.WallCheckEnabled then
            score = score * 1.2
        end
        score = score + math.random() * 10
        return score
    end
    local function getClosestTarget()
        local mousePos = UserInputService:GetMouseLocation()
        local minScore = -math.huge
        local closestTarget = nil
        local closestPart = nil
        if Aimbot.StickyTarget and Aimbot.CurrentTarget and Aimbot.CurrentTarget.Parent then
            local player = Players:GetPlayerFromCharacter(Aimbot.CurrentTarget)
            if not (player and player == LocalPlayer) and not (player and isTeammate(player)) then
                local targetPart = getSmartHitbox(Aimbot.CurrentTarget)
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist <= (Aimbot.FOVRadius * Aimbot.StickyDistanceMultiplier) then
                            local score = calculateTargetScore(Aimbot.CurrentTarget, targetPart, dist) * 1.3
                            if score > minScore then
                                minScore = score
                                closestTarget = Aimbot.CurrentTarget
                                closestPart = targetPart
                            end
                        end
                    end
                end
            end
        end
        for _, model in ipairs(Aimbot.TargetIndex) do
            if model and model.Parent then
                local player = Players:GetPlayerFromCharacter(model)
                if not (player and player == LocalPlayer) and not (player and isTeammate(player)) then
                    local targetPart = getSmartHitbox(model)
                    if targetPart then
                        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist <= Aimbot.FOVRadius then
                                local score = calculateTargetScore(model, targetPart, dist)
                                if score > minScore then
                                    minScore = score
                                    closestTarget = model
                                    closestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
        return closestTarget, closestPart
    end
    local function predictPosition(targetPart)
        if not Aimbot.PredictionEnabled then
            return targetPart.Position
        end
        local velocity = Vector3.new(0, 0, 0)
        if targetPart.AssemblyLinearVelocity then
            velocity = targetPart.AssemblyLinearVelocity
        elseif targetPart.Velocity then
            velocity = targetPart.Velocity
        end
        table.insert(Aimbot.VelocityHistory, velocity)
        if #Aimbot.VelocityHistory > Aimbot.PredictionSamples then
            table.remove(Aimbot.VelocityHistory, 1)
        end
        local avgVelocity = Vector3.new(0, 0, 0)
        for _, vel in ipairs(Aimbot.VelocityHistory) do
            avgVelocity = avgVelocity + vel
        end
        avgVelocity = avgVelocity / #Aimbot.VelocityHistory
        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        local predictionTime = (distance / 2000) * Aimbot.PredictionMultiplier
        return targetPart.Position + (avgVelocity * predictionTime)
    end
    local function getDistanceBasedSmoothness(distance)
        if not Aimbot.DistanceBasedSmoothing then
            return Aimbot.SmoothingFactor
        end
        local minDistance = 10
        local maxDistance = 300
        local normalizedDist = math.clamp((distance - minDistance) / (maxDistance - minDistance), 0, 1)
        local smoothnessMult = 1 - (normalizedDist * 0.5)
        return Aimbot.SmoothingFactor * smoothnessMult
    end
    local function aimAtTarget(targetPart, deltaTime)
        if not targetPart or not targetPart.Parent then
            return false
        end
        local predictedPosition = predictPosition(targetPart)
        local targetScreenPos = Camera:WorldToViewportPoint(predictedPosition)
        local mousePos = UserInputService:GetMouseLocation()
        local delta = Vector2.new(
            targetScreenPos.X - mousePos.X,
            targetScreenPos.Y - mousePos.Y
        )
        if Aimbot.AimRandomization then
            local randomFactor = Aimbot.RandomizationMin + 
                               math.random() * (Aimbot.RandomizationMax - Aimbot.RandomizationMin)
            delta = delta * randomFactor
        end
        if Aimbot.UsePIDController then
            local pitchCorrection = pitchPID:calculate(0, delta.Y)
            local yawCorrection = yawPID:calculate(0, delta.X)
            pitchCorrection = math.clamp(pitchCorrection, -2.0, 2.0)
            yawCorrection = math.clamp(yawCorrection, -2.0, 2.0)
            local sensitivity = 0.01
            local cameraCF = Camera.CFrame
            local newCF = cameraCF * CFrame.Angles(
                math.rad(-pitchCorrection * sensitivity),
                math.rad(-yawCorrection * sensitivity),
                0
            )
            Camera.CFrame = newCF
        else
            local goalCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPosition)
            if Aimbot.SmoothingEnabled then
                local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
                local smoothness = getDistanceBasedSmoothness(distance)
                local adjustedSmoothFactor = math.clamp(1 - (1 - smoothness) ^ (60 * deltaTime), 0, 1)
                Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, adjustedSmoothFactor)
            else
                Camera.CFrame = goalCFrame
            end
        end
        return true
    end
    local function createESP(part, color)
        if not part or not part.Parent then return end
        if Aimbot.ESPObjects[part] then
            local esp = Aimbot.ESPObjects[part]
            esp.Color3 = color
            esp.Size = part.Size
            return
        end
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = "AimbotESP"
        espBox.Adornee = part
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 10
        espBox.Size = part.Size
        espBox.Color3 = color
        espBox.Transparency = 0.4
        espBox.Parent = part
        Aimbot.ESPObjects[part] = espBox
    end
    local function clearESP(part)
        if part then
            if Aimbot.ESPObjects[part] then
                pcall(function()
                    Aimbot.ESPObjects[part]:Destroy()
                end)
                Aimbot.ESPObjects[part] = nil
            end
        else
            for _, espBox in pairs(Aimbot.ESPObjects) do
                pcall(function()
                    espBox:Destroy()
                end)
            end
            Aimbot.ESPObjects = {}
        end
    end
    local function GetPartUnderCursor()
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        raycastParams.IgnoreWater = true
        local result = Workspace:Raycast(ray.Origin, ray.Direction * DeleteTool.MaxDistance, raycastParams)
        if result and result.Instance then
            if DeleteTool.IgnorePlayers then
                local isPlayer = result.Instance:FindFirstAncestorOfClass("Model") and result.Instance:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid")
                if isPlayer then
                    return nil
                end
            end
            if DeleteTool.IgnoreTerrain and result.Instance:IsA("Terrain") then
                return nil
            end
            return result.Instance
        end
        return nil
    end
    local function CreateHighlight(part)
        if DeleteTool.CurrentHighlight then
            pcall(function()
                DeleteTool.CurrentHighlight:Destroy()
            end)
        end
        if not part then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = part
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = part
        DeleteTool.CurrentHighlight = highlight
    end
    local historyLabel = nil
    local function DeletePart(part)
        if not part then
            DoNotif("Delete Tool: No part under cursor", 2)
            return
        end
        local toDelete = nil
        if DeleteTool.DeleteMode == "Part" then
            toDelete = part
        elseif DeleteTool.DeleteMode == "Model" then
            toDelete = part:FindFirstAncestorOfClass("Model") or part
        elseif DeleteTool.DeleteMode == "Descendants" then
            toDelete = part.Parent
            if not toDelete then
                DoNotif("Delete Tool: Part has no parent", 2)
                return
            end
        end
        if toDelete then
            table.insert(DeleteTool.DeletedParts, {
                Instance = toDelete,
                Parent = toDelete.Parent,
                Name = toDelete.Name
            })
            pcall(function()
                toDelete:Destroy()
            end)
            DoNotif("Deleted: " .. toDelete.Name .. " (" .. DeleteTool.DeleteMode .. ")", 2)
            if historyLabel then
                historyLabel:Set("Deleted: " .. #DeleteTool.DeletedParts .. " parts")
            end
        end
    end
    if Drawing and typeof(Drawing.new) == "function" then
        Aimbot.FOVCircle = Drawing.new("Circle")
        Aimbot.FOVCircle.Visible = false
        Aimbot.FOVCircle.Thickness = 2
        Aimbot.FOVCircle.NumSides = 64
        Aimbot.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        Aimbot.FOVCircle.Transparency = 0.6
        Aimbot.FOVCircle.Filled = false
    end
    local renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if Aimbot.FOVCircle then
            Aimbot.FOVCircle.Position = UserInputService:GetMouseLocation()
            Aimbot.FOVCircle.Radius = Aimbot.FOVRadius
            Aimbot.FOVCircle.Visible = Aimbot.ShowFOVCircle and Aimbot.Enabled and Aimbot.IsAiming
        end
        updateTargetIndex()
        if Aimbot.Enabled and Aimbot.IsAiming then
            local targetModel, targetPart = getClosestTarget()
            if targetModel ~= Aimbot.CurrentTarget then
                pitchPID:reset()
                yawPID:reset()
            end
            Aimbot.CurrentTarget = targetModel
            if targetModel and targetPart then
                if aimAtTarget(targetPart, deltaTime) then
                    createESP(targetPart, Color3.fromRGB(255, 80, 80))
                else
                    clearESP()
                end
            else
                clearESP()
                Aimbot.VelocityHistory = {}
                pitchPID:reset()
                yawPID:reset()
            end
            for part, _ in pairs(Aimbot.ESPObjects) do
                if not part.Parent or part ~= targetPart then
                    clearESP(part)
                end
            end
        else
            Aimbot.CurrentTarget = nil
            Aimbot.VelocityHistory = {}
            clearESP()
            pitchPID:reset()
            yawPID:reset()
        end
        if DeleteTool.Enabled and DeleteTool.ShowHighlight then
            local targetPart = GetPartUnderCursor()
            if targetPart then
                CreateHighlight(targetPart)
            elseif DeleteTool.CurrentHighlight then
                pcall(function()
                    DeleteTool.CurrentHighlight:Destroy()
                end)
                DeleteTool.CurrentHighlight = nil
            end
        elseif DeleteTool.CurrentHighlight then
            pcall(function()
                DeleteTool.CurrentHighlight:Destroy()
            end)
            DeleteTool.CurrentHighlight = nil
        end
    end)
    local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if DeleteTool.Enabled and input.KeyCode == DeleteTool.DeleteBind then
            local targetPart = GetPartUnderCursor()
            if targetPart then
                DeletePart(targetPart)
            end
        end
        if Aimbot.Enabled and input.UserInputType == Aimbot.ToggleKey then
            Aimbot.IsAiming = true
        end
    end)
    local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Aimbot.ToggleKey then
            Aimbot.IsAiming = false
            clearESP()
            pitchPID:reset()
            yawPID:reset()
        end
    end)
    table.insert(self.State.Connections, renderConnection)
    table.insert(self.State.Connections, inputBeganConnection)
    table.insert(self.State.Connections, inputEndedConnection)
    updateTargetIndex(true)
    local Window = Luna:CreateWindow({
        Name = "GamingChair 2.0",
        Subtitle = "The best utility for lazy assholes like us.",
        LogoID = "6031097225",
        LoadingEnabled = true,
        LoadingTitle = "Gaming Chair",
        LoadingSubtitle = "Sit back, lock in gamer.",
        ConfigSettings = {
            ConfigFolder = "ZukaAimbot"
        },
        KeySystem = false
    })
    self.State.Window = Window
    local MainTab = Window:CreateTab({
        Name = "Aimbot",
        Icon = "home_filled",
        ImageSource = "Material",
        ShowTitle = true
    })
    local AdvancedTab = Window:CreateTab({
        Name = "Advanced",
        Icon = "tune",
        ImageSource = "Material",
        ShowTitle = true
    })
    local DeleteTab = Window:CreateTab({
        Name = "Delete Tool",
        Icon = "delete",
        ImageSource = "Material",
        ShowTitle = true
    })
    local VisualsTab = Window:CreateTab({
        Name = "Visuals",
        Icon = "visibility",
        ImageSource = "Material",
        ShowTitle = true
    })
    local SettingsTab = Window:CreateTab({
        Name = "Settings",
        Icon = "settings",
        ImageSource = "Material",
        ShowTitle = true
    })
    local AimbotSection = MainTab:CreateSection("Aimbot Controls")
    AimbotSection:CreateToggle({
        Name = "Enable Aimbot",
        Description = "Hold RIGHT MOUSE BUTTON to aim",
        CurrentValue = false,
        Callback = function(value)
            Aimbot.Enabled = value
            if not value then
                Aimbot.IsAiming = false
                clearESP()
            end
            DoNotif("Aimbot: " .. (value and "ENABLED" or "DISABLED"), 2)
        end,
    }, "AimbotEnabled")
    AimbotSection:CreateLabel({
        Text = " HOLD Right Mouse Button to lock onto targets",
        Style = 3
    })
    AimbotSection:CreateSlider({
        Name = "FOV Radius",
        Range = {50, 500},
        Increment = 5,
        CurrentValue = 100,
        Callback = function(value)
            Aimbot.FOVRadius = value
        end,
    }, "FOVRadius")
    AimbotSection:CreateSlider({
        Name = "Smoothness",
        Range = {0.05, 1.0},
        Increment = 0.01,
        CurrentValue = 0.2,
        Callback = function(value)
            Aimbot.SmoothingFactor = value
        end,
    }, "Smoothness")
    AimbotSection:CreateDropdown({
        Name = "Preferred Hitbox",
        Description = "Will auto-switch if priority is enabled",
        Options = {"Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso"},
        CurrentOption = {"Head"},
        MultipleOptions = false,
        Callback = function(option)
            Aimbot.AimPart = option
        end,
    }, "AimPart")
    local ChecksSection = MainTab:CreateSection("Targeting Checks")
    ChecksSection:CreateToggle({
        Name = "Ignore Team",
        Description = "Don't target teammates",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.IgnoreTeam = value
        end,
    }, "IgnoreTeam")
    ChecksSection:CreateToggle({
        Name = "Wall Check",
        Description = "Only target visible players",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.WallCheckEnabled = value
        end,
    }, "WallCheck")
    local SmartSection = AdvancedTab:CreateSection("Smart Targeting")
    SmartSection:CreateToggle({
        Name = "Hitbox Priority",
        Description = "Auto-select best visible hitbox",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.HitboxPriority = value
        end,
    }, "HitboxPriority")
    SmartSection:CreateToggle({
        Name = "Sticky Target",
        Description = "Maintain lock on current target",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.StickyTarget = value
        end,
    }, "StickyTarget")
    SmartSection:CreateToggle({
        Name = "Distance-Based Smoothing",
        Description = "Smoother aim for closer targets",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.DistanceBasedSmoothing = value
        end,
    }, "DistanceSmoothing")
    SmartSection:CreateLabel({
        Text = " Priority: Head → UpperTorso → HumanoidRootPart → Torso",
        Style = 2
    })
    local AlgorithmSection = AdvancedTab:CreateSection("Algorithm Settings")
    AlgorithmSection:CreateToggle({
        Name = "Use PID Controller",
        Description = "More human-like aim with acceleration",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.UsePIDController = value
            if value then
                pitchPID:reset()
                yawPID:reset()
            end
            DoNotif("PID Controller: " .. (value and "ENABLED" or "DISABLED"), 2)
        end,
    }, "UsePID")
    AlgorithmSection:CreateToggle({
        Name = "Advanced Scoring",
        Description = "Multi-factor target prioritization",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.UseAdvancedScoring = value
            DoNotif("Advanced Scoring: " .. (value and "ENABLED" or "DISABLED"), 2)
        end,
    }, "AdvancedScoring")
    AlgorithmSection:CreateToggle({
        Name = "Aim Randomization",
        Description = "Add slight randomness for realism",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.AimRandomization = value
            DoNotif("Randomization: " .. (value and "ENABLED" or "DISABLED"), 2)
        end,
    }, "AimRandom")
    AlgorithmSection:CreateLabel({
        Text = " PID = Smoother, more realistic aim movement",
        Style = 2
    })
    local PrioritySection = AdvancedTab:CreateSection("Target Priority Weights")
    PrioritySection:CreateSlider({
        Name = "Health Priority",
        Range = {0, 1.0},
        Increment = 0.05,
        CurrentValue = 0.3,
        Callback = function(value)
            Aimbot.HealthPriority = value
        end,
    }, "HealthPriority")
    PrioritySection:CreateSlider({
        Name = "Distance Priority",
        Range = {0, 1.0},
        Increment = 0.05,
        CurrentValue = 0.2,
        Callback = function(value)
            Aimbot.DistancePriority = value
        end,
    }, "DistancePriority")
    PrioritySection:CreateSlider({
        Name = "Randomization Min",
        Range = {0.8, 1.0},
        Increment = 0.01,
        CurrentValue = 0.92,
        Callback = function(value)
            Aimbot.RandomizationMin = value
        end,
    }, "RandomMin")
    PrioritySection:CreateSlider({
        Name = "Randomization Max",
        Range = {0.8, 1.0},
        Increment = 0.01,
        CurrentValue = 0.98,
        Callback = function(value)
            Aimbot.RandomizationMax = value
        end,
    }, "RandomMax")
    PrioritySection:CreateLabel({
        Text = " Higher values = stronger influence on targeting",
        Style = 2
    })
    local PredictionSection = AdvancedTab:CreateSection("Prediction System")
    PredictionSection:CreateToggle({
        Name = "Enable Prediction",
        Description = "Predict target movement",
        CurrentValue = true,
        Callback = function(value)
            Aimbot.PredictionEnabled = value
        end,
    }, "Prediction")
    PredictionSection:CreateSlider({
        Name = "Prediction Multiplier",
        Range = {0.1, 3.0},
        Increment = 0.1,
        CurrentValue = 1.0,
        Callback = function(value)
            Aimbot.PredictionMultiplier = value
        end,
    }, "PredictionMult")
    PredictionSection:CreateLabel({
        Text = " Uses velocity averaging for accurate predictions",
        Style = 2
    })
    local DeleteMainSection = DeleteTab:CreateSection("Delete Tool")
    DeleteMainSection:CreateToggle({
        Name = "Enable Delete Tool",
        Description = "Enable part deletion mode",
        CurrentValue = false,
        Callback = function(value)
            DeleteTool.Enabled = value
            DoNotif("Delete Tool: " .. (value and "ENABLED" or "DISABLED"), 2)
        end,
    }, "DeleteEnabled")
    DeleteMainSection:CreateLabel({
        Text = " Press X to delete the part under your cursor",
        Style = 3
    })
    DeleteMainSection:CreateBind({
        Name = "Delete Keybind",
        Description = "Press this key to delete",
        CurrentBind = "X",
        HoldToInteract = false,
        Callback = function(key)
            DeleteTool.DeleteBind = Enum.KeyCode[key]
            DoNotif("Delete keybind: " .. key, 2)
        end,
    }, "DeleteBind")
    DeleteMainSection:CreateDropdown({
        Name = "Delete Mode",
        Description = "What to delete when pressing keybind",
        Options = {"Part", "Model", "Descendants"},
        CurrentOption = {"Part"},
        MultipleOptions = false,
        Callback = function(option)
            DeleteTool.DeleteMode = option
            DoNotif("Delete mode: " .. option, 2)
        end,
    }, "DeleteMode")
    DeleteMainSection:CreateLabel({
        Text = " Part: Single part only",
        Style = 2
    })
    DeleteMainSection:CreateLabel({
        Text = " Model: Entire model containing part",
        Style = 2
    })
    DeleteMainSection:CreateLabel({
        Text = " Descendants: All parts in parent container",
        Style = 2
    })
    local DeleteOptionsSection = DeleteTab:CreateSection("Options")
    DeleteOptionsSection:CreateSlider({
        Name = "Max Distance",
        Range = {50, 2000},
        Increment = 10,
        CurrentValue = 500,
        Callback = function(value)
            DeleteTool.MaxDistance = value
        end,
    }, "DeleteDistance")
    DeleteOptionsSection:CreateToggle({
        Name = "Ignore Players",
        Description = "Cannot delete player characters",
        CurrentValue = true,
        Callback = function(value)
            DeleteTool.IgnorePlayers = value
        end,
    }, "IgnorePlayers")
    DeleteOptionsSection:CreateToggle({
        Name = "Ignore Terrain",
        Description = "Cannot delete terrain",
        CurrentValue = true,
        Callback = function(value)
            DeleteTool.IgnoreTerrain = value
        end,
    }, "IgnoreTerrain")
    DeleteOptionsSection:CreateToggle({
        Name = "Show Highlight",
        Description = "Red highlight on target",
        CurrentValue = true,
        Callback = function(value)
            DeleteTool.ShowHighlight = value
        end,
    }, "ShowHighlight")
    local DeleteHistorySection = DeleteTab:CreateSection("History")
    historyLabel = DeleteHistorySection:CreateLabel({
        Text = "Deleted: 0 parts",
        Style = 1
    })
    DeleteHistorySection:CreateButton({
        Name = "Clear History",
        Description = "Clear deletion history",
        Callback = function()
            DeleteTool.DeletedParts = {}
            historyLabel:Set("Deleted: 0 parts")
            DoNotif("Delete history cleared", 2)
        end,
    })
    local FOVSection = VisualsTab:CreateSection("FOV Circle")
    FOVSection:CreateToggle({
        Name = "Show FOV Circle",
        Description = "Display targeting circle",
        CurrentValue = false,
        Callback = function(value)
            Aimbot.ShowFOVCircle = value
        end,
    }, "ShowFOV")
    FOVSection:CreateColorPicker({
        Name = "FOV Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(color)
            if Aimbot.FOVCircle then
                Aimbot.FOVCircle.Color = color
            end
        end,
    }, "FOVColor")
    FOVSection:CreateSlider({
        Name = "FOV Transparency",
        Range = {0, 1},
        Increment = 0.1,
        CurrentValue = 0.6,
        Callback = function(value)
            if Aimbot.FOVCircle then
                Aimbot.FOVCircle.Transparency = value
            end
        end,
    }, "FOVTransparency")
    local ESPSection = VisualsTab:CreateSection("Target ESP")
    ESPSection:CreateLabel({
        Text = "Red box shows current target",
        Style = 1
    })
    ESPSection:CreateLabel({
        Text = " ESP automatically appears when aiming",
        Style = 2
    })
    local InfoSection = VisualsTab:CreateSection("Target Info")
    local targetLabel = InfoSection:CreateLabel({
        Text = "No target",
        Style = 2
    })
    local statusLabel = InfoSection:CreateLabel({
        Text = "Status: Standby",
        Style = 1
    })
    local infoConnection = RunService.Heartbeat:Connect(function()
        if Aimbot.Enabled and Aimbot.IsAiming and Aimbot.CurrentTarget then
            local player = Players:GetPlayerFromCharacter(Aimbot.CurrentTarget)
            local targetName = player and player.Name or "Unknown"
            targetLabel:Set("Target: " .. targetName)
            statusLabel:Set("Status: LOCKED & TRACKING" .. (Aimbot.UsePIDController and " [PID]" or ""))
        else
            targetLabel:Set("No target")
            statusLabel:Set("Status: " .. (Aimbot.Enabled and "Ready (Hold RMB)" or "Disabled"))
        end
    end)
    local ConfigSystem = {
        ConfigFolder = "ZukaAimbot",
        CurrentConfig = "default"
    }
    function ConfigSystem:SaveConfig(configName)
        configName = configName or self.CurrentConfig
        local config = {
            AimbotEnabled = Aimbot.Enabled,
            FOVRadius = Aimbot.FOVRadius,
            SmoothingFactor = Aimbot.SmoothingFactor,
            AimPart = Aimbot.AimPart,
            ShowFOVCircle = Aimbot.ShowFOVCircle,
            IgnoreTeam = Aimbot.IgnoreTeam,
            WallCheckEnabled = Aimbot.WallCheckEnabled,
            HitboxPriority = Aimbot.HitboxPriority,
            StickyTarget = Aimbot.StickyTarget,
            DistanceBasedSmoothing = Aimbot.DistanceBasedSmoothing,
            PredictionEnabled = Aimbot.PredictionEnabled,
            PredictionMultiplier = Aimbot.PredictionMultiplier,
            UsePIDController = Aimbot.UsePIDController,
            UseAdvancedScoring = Aimbot.UseAdvancedScoring,
            AimRandomization = Aimbot.AimRandomization,
            RandomizationMin = Aimbot.RandomizationMin,
            RandomizationMax = Aimbot.RandomizationMax,
            HealthPriority = Aimbot.HealthPriority,
            DistancePriority = Aimbot.DistancePriority,
            DeleteToolEnabled = DeleteTool.Enabled,
            DeleteMode = DeleteTool.DeleteMode,
            DeleteMaxDistance = DeleteTool.MaxDistance,
            DeleteIgnorePlayers = DeleteTool.IgnorePlayers,
            DeleteIgnoreTerrain = DeleteTool.IgnoreTerrain,
            DeleteShowHighlight = DeleteTool.ShowHighlight
        }
        local success, err = pcall(function()
            writefile(self.ConfigFolder .. "/" .. configName .. ".json", game:GetService("HttpService"):JSONEncode(config))
        end)
        if success then
            DoNotif("Config saved: " .. configName, 3)
            return true
        else
            DoNotif("Failed to save config: " .. tostring(err), 3)
            return false
        end
    end
    function ConfigSystem:LoadConfig(configName)
        configName = configName or self.CurrentConfig
        local success, result = pcall(function()
            return readfile(self.ConfigFolder .. "/" .. configName .. ".json")
        end)
        if not success then
            DoNotif("Config not found: " .. configName, 3)
            return false
        end
        local config = game:GetService("HttpService"):JSONDecode(result)
        if config.AimbotEnabled ~= nil then Aimbot.Enabled = config.AimbotEnabled end
        if config.FOVRadius then Aimbot.FOVRadius = config.FOVRadius end
        if config.SmoothingFactor then Aimbot.SmoothingFactor = config.SmoothingFactor end
        if config.AimPart then Aimbot.AimPart = config.AimPart end
        if config.ShowFOVCircle ~= nil then Aimbot.ShowFOVCircle = config.ShowFOVCircle end
        if config.IgnoreTeam ~= nil then Aimbot.IgnoreTeam = config.IgnoreTeam end
        if config.WallCheckEnabled ~= nil then Aimbot.WallCheckEnabled = config.WallCheckEnabled end
        if config.HitboxPriority ~= nil then Aimbot.HitboxPriority = config.HitboxPriority end
        if config.StickyTarget ~= nil then Aimbot.StickyTarget = config.StickyTarget end
        if config.DistanceBasedSmoothing ~= nil then Aimbot.DistanceBasedSmoothing = config.DistanceBasedSmoothing end
        if config.PredictionEnabled ~= nil then Aimbot.PredictionEnabled = config.PredictionEnabled end
        if config.PredictionMultiplier then Aimbot.PredictionMultiplier = config.PredictionMultiplier end
        if config.UsePIDController ~= nil then Aimbot.UsePIDController = config.UsePIDController end
        if config.UseAdvancedScoring ~= nil then Aimbot.UseAdvancedScoring = config.UseAdvancedScoring end
        if config.AimRandomization ~= nil then Aimbot.AimRandomization = config.AimRandomization end
        if config.RandomizationMin then Aimbot.RandomizationMin = config.RandomizationMin end
        if config.RandomizationMax then Aimbot.RandomizationMax = config.RandomizationMax end
        if config.HealthPriority then Aimbot.HealthPriority = config.HealthPriority end
        if config.DistancePriority then Aimbot.DistancePriority = config.DistancePriority end
        if config.DeleteToolEnabled ~= nil then DeleteTool.Enabled = config.DeleteToolEnabled end
        if config.DeleteMode then DeleteTool.DeleteMode = config.DeleteMode end
        if config.DeleteMaxDistance then DeleteTool.MaxDistance = config.DeleteMaxDistance end
        if config.DeleteIgnorePlayers ~= nil then DeleteTool.IgnorePlayers = config.DeleteIgnorePlayers end
        if config.DeleteIgnoreTerrain ~= nil then DeleteTool.IgnoreTerrain = config.DeleteIgnoreTerrain end
        if config.DeleteShowHighlight ~= nil then DeleteTool.ShowHighlight = config.DeleteShowHighlight end
        DoNotif("Config loaded: " .. configName, 3)
        return true
    end
    function ConfigSystem:DeleteConfig(configName)
        local success, err = pcall(function()
            delfile(self.ConfigFolder .. "/" .. configName .. ".json")
        end)
        if success then
            DoNotif("Config deleted: " .. configName, 3)
            return true
        else
            DoNotif("Failed to delete config", 3)
            return false
        end
    end
    function ConfigSystem:ListConfigs()
        local success, files = pcall(function()
            return listfiles(self.ConfigFolder)
        end)
        if not success then
            return {}
        end
        local configs = {}
        for _, file in ipairs(files) do
            local configName = file:match("([^/]+)%.json$")
            if configName then
                table.insert(configs, configName)
            end
        end
        return configs
    end
    pcall(function()
        if not isfolder(ConfigSystem.ConfigFolder) then
            makefolder(ConfigSystem.ConfigFolder)
        end
    end)
    table.insert(self.State.Connections, infoConnection)
    local configSuccess = pcall(function()
        SettingsTab:BuildConfigSection()
    end)
    if not configSuccess then
        local ManualConfigSection = SettingsTab:CreateSection("Configuration")
        ManualConfigSection:CreateButton({
            Name = "Save Config",
            Description = "Save current settings",
            Callback = function()
                ConfigSystem:SaveConfig("default")
            end,
        })
        ManualConfigSection:CreateButton({
            Name = "Load Config",
            Description = "Load saved settings",
            Callback = function()
                ConfigSystem:LoadConfig("default")
            end,
        })
        ManualConfigSection:CreateButton({
            Name = "Reset Config",
            Description = "Reset to defaults",
            Callback = function()
                ConfigSystem:DeleteConfig("default")
                DoNotif("Config reset - restart script to apply defaults", 3)
            end,
        })
        ManualConfigSection:CreateLabel({
            Text = " Config auto-saves as 'default.json'",
            Style = 2
        })
    end
    SettingsTab:BuildThemeSection()
    Luna:LoadAutoloadConfig()
    DoNotif("Gaming Chair v2.0: LOADED | PID + Smart Scoring Active | Press INSERT to toggle UI", 5)
end
function Modules.ZukaAimbot:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for _, connection in ipairs(self.State.Connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
    self.State.Connections = {}
    if self.State.Aimbot.FOVCircle then
        pcall(function()
            self.State.Aimbot.FOVCircle:Remove()
        end)
        self.State.Aimbot.FOVCircle = nil
    end
    for _, espBox in pairs(self.State.Aimbot.ESPObjects) do
        pcall(function()
            espBox:Destroy()
        end)
    end
    self.State.Aimbot.ESPObjects = {}
    if self.State.DeleteTool.CurrentHighlight then
        pcall(function()
            self.State.DeleteTool.CurrentHighlight:Destroy()
        end)
        self.State.DeleteTool.CurrentHighlight = nil
    end
    if self.State.Window then
        self.State.Window = nil
    end
    self.State.Aimbot.Enabled = false
    self.State.Aimbot.IsAiming = false
    self.State.Aimbot.CurrentTarget = nil
    self.State.Aimbot.VelocityHistory = {}
    self.State.DeleteTool.Enabled = false
    DoNotif("Zuka Aimbot Suite: DISABLED", 2)
end
function Modules.ZukaAimbot:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Modules.ZukaAimbot:Toggle()
    end
end)
DoNotif("we lit", 3)
Modules.ZukaAimbot:Enable()
