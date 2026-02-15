--[[  This won't be fully functional on xeno or solara. Use a better executor.

loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatechlive/ZukaTechPanel/refs/heads/main/MainPanel.lua"))()

Made By Zuka. @OverRuka on ROBLOX.

spoofid 82347291 -example

]]



print("- Zukas Panel -")

local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
do
    local THEME = {
        Title = "Loading...",
        Subtitle = "Made by @OverZuka — We're so back...",
        IconAssetId = "rbxassetid://7243158473",
        BackgroundColor = Color3.fromRGB(15, 15, 20),
        AccentColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(240, 240, 240),
        FadeInTime = 0.45,
        HoldTime = 1.2,
        FadeOutTime = 0.35
    }
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "SplashScreen_" .. math.random(1000, 9999)
    splashGui.IgnoreGuiInset = true
    splashGui.ResetOnSpawn = false
    splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    splashGui.Parent = CoreGui
    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = THEME.BackgroundColor
    background.BackgroundTransparency = 1
    background.Parent = splashGui
    local blur = Instance.new("BlurEffect")
    blur.Size = 1
    blur.Parent = Lighting
    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(320, 260)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 1
    card.Parent = background
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = THEME.AccentColor
    stroke.Transparency = 1
    stroke.Parent = card
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(96, 96)
    icon.Position = UDim2.fromScale(0.5, 0.32)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.ImageTransparency = 0.5
    icon.ImageColor3 = THEME.AccentColor
    icon.Image = THEME.IconAssetId
    icon.Parent = card
    pcall(function()
        ContentProvider:PreloadAsync({ icon })
    end)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 36)
    title.Position = UDim2.fromScale(0.5, 0.62)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Oswald
    title.Text = THEME.Title
    title.TextSize = 27
    title.TextColor3 = THEME.TextColor
    title.TextTransparency = 0.6
    title.Parent = card
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 24)
    subtitle.Position = UDim2.fromScale(0.5, 0.75)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Bangers
    subtitle.Text = THEME.Subtitle
    subtitle.TextSize = 14
    subtitle.TextColor3 = THEME.TextColor
    subtitle.TextTransparency = 0
    subtitle.Parent = card
    card.Size = card.Size - UDim2.fromOffset(40, 40)
    local tweenIn = TweenInfo.new(THEME.FadeInTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenOut = TweenInfo.new(THEME.FadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(background, tweenIn, { BackgroundTransparency = 0.35 }):Play()
    TweenService:Create(blur, tweenIn, { Size = 16 }):Play()
    TweenService:Create(card, tweenIn, { Size = UDim2.fromOffset(320, 260) }):Play()
    TweenService:Create(icon, tweenIn, { ImageTransparency = 0 }):Play()
    TweenService:Create(title, tweenIn, { TextTransparency = 0 }):Play()
    TweenService:Create(subtitle, tweenIn, { TextTransparency = 0.25 }):Play()
    task.wait(THEME.FadeInTime + THEME.HoldTime)
    TweenService:Create(background, tweenOut, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blur, tweenOut, { Size = 0 }):Play()
    TweenService:Create(icon, tweenOut, { ImageTransparency = 1 }):Play()
    TweenService:Create(title, tweenOut, { TextTransparency = 1 }):Play()
    TweenService:Create(subtitle, tweenOut, { TextTransparency = 1 }):Play()
    task.wait(THEME.FadeOutTime)
    blur:Destroy()
    splashGui:Destroy()
end
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local oldKick
oldKick = hookfunction(LocalPlayer.Kick, newcclosure(function(self, ...)
    if not checkcaller() and self == LocalPlayer then
        return nil
    end
    return oldKick(self, ...)
end))
local function detectEnvironment()
    local env = {
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        functions = {},
        level = 0
    }
    local testFunctions = {
        "getgenv", "getrenv", "getrawmetatable", "setreadonly",
        "hookmetamethod", "hookfunction", "newcclosure",
        "getnamecallmethod", "checkcaller", "getconnections",
        "firesignal", "Drawing", "WebSocket", "request",
        "http_request", "syn_request", "readfile", "writefile",
        "isfile", "isfolder", "makefolder", "delfile"
    }
    for _, funcName in ipairs(testFunctions) do
        local func = getfenv()[funcName]
        if func then
            env.functions[funcName] = type(func)
            env.level = env.level + 1
        end
    end
    env.rating = env.level >= 20 and "Peak Executor" or env.level >= 10 and "Decent" or "Dog shit"
    return env
end
local env = detectEnvironment()
print("Executor:", env.executor) if Xeno
then print("Oh no! Module poisoning is not possible with xeno") end
print("Good Executor?:", env.rating)
print("Available Functions:", env.level)
local debug = debug
local getgc = getgc or get_gc_objects
local setupvalue = debug.setupvalue or setupvalue
local getupvalues = debug.getupvalues or getupvalues
if getgenv().ZukaTech_Loaded then
    return
end
getgenv().ZukaTech_Loaded = true
if not game:IsLoaded() then
    game.Loaded:Wait()
end
local Players = game:GetService("Players")
local function getLocalPlayer()
    local lp = Players.LocalPlayer
    while not lp do
        task.wait(0.1)
        lp = Players.LocalPlayer
    end
    return lp
end
local _GC_START = collectgarbage("count")
local _TIMESTAMP = os.clock()
local set_ro = setreadonly or (make_writeable and function(t, v) if v then make_readonly(t) else make_writeable(t) end end)
local get_mt = getrawmetatable or debug.getmetatable
local hook_meta = hookmetamethod
local new_ccl = newcclosure or function(f) return f end
local check_caller = checkcaller or function() return false end
local clone_func = clonefunction or function(f) return f end
local function dismantle_readonly(target)
    if type(target) ~= "table" then return end
    pcall(function()
        if set_ro then set_ro(target, false) end
        local mt = get_mt(target)
        if mt and set_ro then set_ro(mt, false) end
    end)
end
local function protect_interface(instance)
    local protector = (get_hidden_gui or (syn and syn.protect_gui))
    if protector then pcall(protector, instance) end
end
local function get_memory_signature(target_name)
    local found = 0
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info.name == target_name or (info.source and info.source:find(target_name)) then
                found = found + 1
            end
        end
    end
    return found
end
local Services = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        if s then t[k] = s end
        return s
    end
})
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera
local Utilities = {}
function Utilities.findPlayer(inputName)
    local input = tostring(inputName):lower()
    if input == "" then return nil end
        local exactMatch = nil
        local partialMatch = nil
        if input == "me" then return Players.LocalPlayer end
            for _, player in ipairs(Players:GetPlayers()) do
                local username = player.Name:lower()
                local displayName = player.DisplayName:lower()
                if username == input or displayName == input then
                    exactMatch = player
                    break
                end
                if not partialMatch then
                    if username:sub(1, #input) == input or displayName:sub(1, #input) == input then
                        partialMatch = player
                    end
                end
            end
            return exactMatch or partialMatch
        end
function Utilities.calculateLevenshteinDistance(s1: string, s2: string): number
    local len1, len2 = #s1, #s2
    if len1 == 0 then return len2 end
    if len2 == 0 then return len1 end
    local matrix = {}
    for i = 0, len1 do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end
    for i = 1, len1 do
        for j = 1, len2 do
            local cost = (s1:sub(i, i) == s2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i - 1][j] + 1,
                matrix[i][j - 1] + 1,
                matrix[i - 1][j - 1] + cost
            )
        end
    end
    return matrix[len1][len2]
end
        local Prefix = ";"
        local Commands = {}
        local CommandInfo = {}
        local Modules = {}
        local NotificationManager = {}
        do
            local queue = {}
            local isActive = false
            local tweenService = game:GetService("TweenService")
            local coreGui = game:GetService("CoreGui")
            local textService = game:GetService("TextService")
            local notifGui = Instance.new("ScreenGui", coreGui)
            notifGui.Name = "ZukaNotifGui_v2"
            notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            notifGui.ResetOnSpawn = false
            local function processNext()
            if isActive or #queue == 0 then
                return
            end
            isActive = true
            local data = table.remove(queue, 1)
            local text, duration = data[1], data[2]
            local notif = Instance.new("TextLabel")
            notif.Font = Enum.Font.GothamSemibold
            notif.TextSize = 12
            notif.Text = text
            notif.TextWrapped = true
            notif.Size = UDim2.fromOffset(300, 0)
            local textBounds = textService:GetTextSize(notif.Text, notif.TextSize, notif.Font, Vector2.new(notif.Size.X.Offset, 1000))
            local verticalPadding = 20
            notif.Size = UDim2.fromOffset(300, textBounds.Y + verticalPadding)
            notif.Position = UDim2.new(0.5, -150, 0, -60)
            notif.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            notif.TextColor3 = Color3.fromRGB(255, 255, 255)
            local corner = Instance.new("UICorner", notif)
            corner.CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", notif)
            stroke.Color = Color3.fromRGB(80, 80, 100)
            notif.Parent = notifGui
            local tweenInfoIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            local goalIn = { Position = UDim2.new(0.5, -150, 0, 10) }
            local goalOut = { Position = UDim2.new(0.5, -150, 0, -60) }
            local inTween = tweenService:Create(notif, tweenInfoIn, goalIn)
            inTween:Play()
            inTween.Completed:Wait()
            task.wait(duration)
            local outTween = tweenService:Create(notif, tweenInfoOut, goalOut)
            outTween:Play()
            outTween.Completed:Wait()
            notif:Destroy()
            isActive = false
            task.spawn(processNext)
        end
        function NotificationManager.Send(text, duration)
            table.insert(queue, {tostring(text), duration or 1})
            task.spawn(processNext)
        end
    end
    function DoNotif(text, duration)
        NotificationManager.Send(text, duration)
    end
function RegisterCommand(info, func)
    if not info or not info.Name or not func then
        warn("Command registration failed: Missing info, name, or function.")
        return
    end
    local name = info.Name:lower()
    if Commands[name] then
        warn("Command registration skipped: Command '" .. name .. "' already exists.")
        return
    end
    Commands[name] = func
    if info.Aliases then
        for _, alias in ipairs(info.Aliases) do
            local aliasLower = alias:lower()
            if Commands[aliasLower] then
                warn("Alias '" .. aliasLower .. "' for command '" .. name .. "' conflicts with an existing command and was not registered.")
            else
                Commands[aliasLower] = func
            end
        end
    end
    table.insert(CommandInfo, info)
end
print("This Panel is managed by Zuka")
function RegisterCommandDual(info, func)
    RegisterCommand(info, func)
    if cmd and cmd.add and info.Aliases then
        for _, alias in ipairs(info.Aliases) do
            cmd.add(alias, func, info.Description or "")
        end
    end
end
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
            UsePIDController = true,
            UseAdvancedScoring = true,
            AimRandomization = true,
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
        Text = "💡 HOLD Right Mouse Button to lock onto targets",
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
        Text = "💡 Priority: Head → UpperTorso → HumanoidRootPart → Torso",
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
        Text = "💡 PID = Smoother, more realistic aim movement",
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
        Text = "💡 Higher values = stronger influence on targeting",
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
        Text = "💡 Uses velocity averaging for accurate predictions",
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
        Text = "💡 Press X to delete the part under your cursor",
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
        Text = "💡 Part: Single part only",
        Style = 2
    })
    DeleteMainSection:CreateLabel({
        Text = "💡 Model: Entire model containing part",
        Style = 2
    })
    DeleteMainSection:CreateLabel({
        Text = "💡 Descendants: All parts in parent container",
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
        Text = "✅ Red box shows current target",
        Style = 1
    })
    ESPSection:CreateLabel({
        Text = "💡 ESP automatically appears when aiming",
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
            targetLabel:Set("🎯 Target: " .. targetName)
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
        Text = "💡 Config auto-saves as 'default.json'",
        Style = 2
    })
end    SettingsTab:BuildThemeSection()
    Luna:LoadAutoloadConfig()
    DoNotif("Zuka Aimbot Suite v2.0: LOADED | PID + Smart Scoring Active | Press INSERT to toggle UI", 5)
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
DoNotif("Zuka Aimbot v2.0 loaded! Press INSERT to open", 3)
Modules.Performance = {
    State = {
        IsEnabled = false,
        OriginalProperties = {}
    }
}
function Modules.Performance:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.OriginalProperties = {}
    local lighting = game:GetService("Lighting")
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    local materialService = game:GetService("MaterialService")
    self.State.OriginalProperties.Lighting = {
        Technology = lighting.Technology,
        GlobalShadows = lighting.GlobalShadows,
        EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = lighting.EnvironmentSpecularScale
    }
    lighting.Technology = Enum.Technology.Compatibility
    lighting.GlobalShadows = false
    lighting.EnvironmentDiffuseScale = 0
    lighting.EnvironmentSpecularScale = 0
    if terrain then
        self.State.OriginalProperties.Terrain = {
            Decoration = terrain.Decoration
        }
        terrain.Decoration = false
    end
    self.State.OriginalProperties.MaterialService = {
        MaterialQuality = materialService.MaterialQuality
    }
    materialService.MaterialQuality = Enum.MaterialQuality.Low
	self.State.OriginalProperties.LightingEffects = {}
	for _, effect in ipairs(lighting:GetChildren()) do
		if effect:IsA("Atmosphere") or effect:IsA("Clouds") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
			self.State.OriginalProperties.LightingEffects[effect] = {
				Enabled = effect.Enabled
			}
			effect.Enabled = false
		end
	end
    DoNotif("Performance Mode: ENABLED. Shadows and effects disabled.", 2)
end
function Modules.Performance:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    local lighting = game:GetService("Lighting")
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    local materialService = game:GetService("MaterialService")
    if self.State.OriginalProperties.Lighting then
        for prop, value in pairs(self.State.OriginalProperties.Lighting) do
            pcall(function() lighting[prop] = value end)
        end
    end
    if terrain and self.State.OriginalProperties.Terrain then
        for prop, value in pairs(self.State.OriginalProperties.Terrain) do
            pcall(function() terrain[prop] = value end)
        end
    end
    if self.State.OriginalProperties.MaterialService then
        for prop, value in pairs(self.State.OriginalProperties.MaterialService) do
            pcall(function() materialService[prop] = value end)
        end
    end
	if self.State.OriginalProperties.LightingEffects then
		for effect, props in pairs(self.State.OriginalProperties.LightingEffects) do
			if effect and effect.Parent then
				pcall(function() effect.Enabled = props.Enabled end)
			end
		end
	end
    self.State.OriginalProperties = {}
    DoNotif("Performance Mode: DISABLED. Graphics restored.", 2)
end
function Modules.Performance:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({ Name = "fpsboost", Aliases = { "noshadows", "performance" }, Description = "Toggles performance mode by disabling shadows and other intensive graphical features." }, function()
    Modules.Performance:Toggle()
end)
Modules.AstralProjection = {
    State = {
        isProjecting = false,
        isSpawning = false,
        originalHRP = nil,
        originalParent = nil,
        deathConnection = nil,
        positionMarker = nil
    },
    Config = {
        TOGGLE_KEY = Enum.KeyCode.End,
        SPAWN_PROTECTION_DURATION = 2
    },
    GUI = {},
    Services = {}
}
function Modules.AstralProjection:_makeDraggable(guiObject)
    local UIS = self.Services.UserInputService
    local dragging = false
    local dragStart
    local startPos
    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input)
        end
    end)
end
function Modules.AstralProjection:_updateUIState()
    local button = self.GUI.astralButton
    if not button then return end
    if self.State.isSpawning then
        button.BackgroundColor3 = Color3.fromRGB(255, 160, 0)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif self.State.isProjecting then
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        button.TextColor3 = Color3.fromRGB(10, 10, 10)
    else
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        button.TextColor3 = Color3.fromRGB(200, 200, 220)
    end
end
function Modules.AstralProjection:_applyVisuals(character, isAstral)
    local highlight = character:FindFirstChild("AstralHighlight")
    if isAstral and not highlight then
        highlight = Instance.new("Highlight", character)
        highlight.Name = "AstralHighlight"
        highlight.FillColor = Color3.fromRGB(0, 200, 255)
        highlight.OutlineColor = Color3.fromRGB(200, 255, 255)
        highlight.FillTransparency = 0.5
    elseif not isAstral and highlight then
        highlight:Destroy()
    end
end
function Modules.AstralProjection:_setState(shouldProject)
    if self.State.isSpawning then return end
    if self.State.isProjecting == shouldProject then return end
    local character = self.Services.LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if shouldProject then
        if not hrp or not humanoid or not hrp.Parent then return end
        self.State.originalHRP = hrp
        self.State.originalParent = character
        local originalCFrame = hrp.CFrame
        hrp.Parent = nil
        self.State.isProjecting = true
        if self.State.positionMarker then
            self.State.positionMarker:Destroy()
        end
        local marker = Instance.new("Part")
        marker.Name = "PhysicalAnchor"
        marker.Size = Vector3.new(4, 5, 2)
        marker.CFrame = originalCFrame
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 0.7
        marker.Parent = self.Services.Workspace
        self.State.positionMarker = marker
        local highlight = Instance.new("Highlight", marker)
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.6
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        self:_applyVisuals(character, true)
        DoNotif("Desync: ENABLED", 1.5)
    else
        if not self.State.originalHRP or not self.State.originalParent then
            self.State.isProjecting = false
            return
        end
        if self.State.positionMarker then
            self.State.positionMarker:Destroy()
            self.State.positionMarker = nil
        end
        self.State.originalHRP.Parent = self.State.originalParent
        self.State.originalHRP = nil
        self.State.originalParent = nil
        self.State.isProjecting = false
        self:_applyVisuals(character, false)
        DoNotif("Desync: DISABLED", 1.5)
    end
    self:_updateUIState()
end
function Modules.AstralProjection:_onDied()
    self:_setState(false)
end
function Modules.AstralProjection:_onCharacterAdded(character)
    self.State.isSpawning = true
    self:_updateUIState()
    if self.State.isProjecting then
        self:_setState(false)
    end
    if self.State.deathConnection then
        self.State.deathConnection:Disconnect()
    end
    local humanoid = character:WaitForChild("Humanoid")
    self.State.deathConnection = humanoid.Died:Connect(function()
        self:_onDied()
    end)
    task.wait(self.Config.SPAWN_PROTECTION_DURATION)
    self.State.isSpawning = false
    self:_updateUIState()
end
function Modules.AstralProjection:Toggle()
    self:_setState(not self.State.isProjecting)
end
function Modules.AstralProjection:Initialize()
    self.Services.Players = game:GetService("Players")
    self.Services.UserInputService = game:GetService("UserInputService")
    self.Services.Workspace = game:GetService("Workspace")
    self.Services.LocalPlayer = self.Services.Players.LocalPlayer
    local PLAYER_GUI = self.Services.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AstralStatusGUI_V2"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PLAYER_GUI
    self.GUI.screenGui = screenGui
    local astralButton = Instance.new("TextButton")
    astralButton.Name = "AstralToggleButton"
    astralButton.Size = UDim2.fromOffset(64, 64)
    astralButton.AnchorPoint = Vector2.new(1, 1)
    astralButton.Position = UDim2.new(1, -20, 1, -100)
    astralButton.Font = Enum.Font.GothamBold
    astralButton.Text = "DSYNC"
    astralButton.TextSize = 14
    astralButton.Parent = screenGui
    Instance.new("UICorner", astralButton).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", astralButton)
    stroke.Color = Color3.fromRGB(100, 100, 120)
    stroke.Thickness = 1.5
    self.GUI.astralButton = astralButton
    self:_updateUIState()
    self:_makeDraggable(astralButton)
    astralButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    self.Services.UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.Config.TOGGLE_KEY then
            self:Toggle()
        end
    end)
    if self.Services.LocalPlayer.Character then
        self:_onCharacterAdded(self.Services.LocalPlayer.Character)
    end
    self.Services.LocalPlayer.CharacterAdded:Connect(function(character)
        self:_onCharacterAdded(character)
    end)
end
RegisterCommand({
    Name = "desyn",
    Aliases = {},
    Description = "Toggles desync, remaining invisible to others."
}, function()
    Modules.AstralProjection:Toggle()
end)
Modules.AnchorSelf = {
    State = {
        IsEnabled = false,
        CharacterAddedConnection = nil
    }
}
function Modules.AnchorSelf:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local function applyAnchor(character)
        if not character then return end
        local hrp = character:WaitForChild("HumanoidRootPart", 2)
        if hrp then
            hrp.Anchored = true
        end
    end
    if LocalPlayer.Character then
        applyAnchor(LocalPlayer.Character)
    end
    self.State.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(applyAnchor)
    DoNotif("Self Anchor: ENABLED.", 2)
end
function Modules.AnchorSelf:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
        end
    end
    if self.State.CharacterAddedConnection then
        self.State.CharacterAddedConnection:Disconnect()
        self.State.CharacterAddedConnection = nil
    end
    DoNotif("Self Anchor: DISABLED.", 2)
end
function Modules.AnchorSelf:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({ Name = "anchor", Aliases = { "lock", "lockpos" }, Description = "Toggles anchoring your character in place." }, function()
    Modules.AnchorSelf:Toggle()
end)
Modules.AutoComplete = {};
function Modules.AutoComplete:GetMatches(prefix)
    local matches = {}
    if typeof(prefix) ~= "string" or #prefix == 0 then return matches end
        prefix = prefix:lower()
        for cmdName, _ in pairs(Commands) do
            if cmdName:sub(1, #prefix) == prefix then
                table.insert(matches, cmdName)
            end
        end
        table.sort(matches)
        return matches
    end
Modules.CommandList = {
    State = {
        UI = nil,
        IsEnabled = false,
        IsMinimized = false,
        IsAnimating = false,
    },
}
function Modules.CommandList:Initialize()
    local self = self
    local ui = Instance.new("ScreenGui")
    ui.Name = "CommandListUI_v7_Radiant"
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ui.Enabled = false
    self.State.UI = ui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(450, 350)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(34, 32, 38)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    local uiStroke = Instance.new("UIStroke", mainFrame)
    uiStroke.Color = Color3.fromRGB(255, 105, 180)
    uiStroke.Thickness = 2
    local glowConnection
    glowConnection = RunService.RenderStepped:Connect(function()
        if not (uiStroke and uiStroke.Parent) then
            glowConnection:Disconnect()
            return
        end
        local sine = math.sin(os.clock() * 4)
        uiStroke.Thickness = 2 + (sine * 0.5)
        uiStroke.Transparency = 0.3 + (sine * 0.2)
    end)
    local canvasGroup = Instance.new("CanvasGroup", mainFrame)
    canvasGroup.Name = "Canvas"
    canvasGroup.Size = UDim2.fromScale(1, 1)
    canvasGroup.BackgroundTransparency = 1
    canvasGroup.GroupTransparency = 1
    local title = Instance.new("TextLabel", canvasGroup)
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamSemibold
    title.Text = "Command List"
    title.TextColor3 = Color3.fromRGB(255, 182, 193)
    title.TextSize = 20
    local closeButton = Instance.new("TextButton", canvasGroup)
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.fromOffset(25, 25)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.new(1, -10, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.MouseButton1Click:Connect(function() self:Toggle() end)
    local minimizeButton = Instance.new("TextButton", canvasGroup)
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.fromOffset(25, 25)
    minimizeButton.AnchorPoint = Vector2.new(1, 0)
    minimizeButton.Position = UDim2.new(1, -40, 0, 10)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Text = "-"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.TextSize = 24
    local scrollingFrame = Instance.new("ScrollingFrame", canvasGroup)
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollingFrame.Position = UDim2.fromOffset(10, 40)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
    local listLayout = Instance.new("UIListLayout", scrollingFrame)
    listLayout.Padding = UDim.new(0, 5)
    local function drag(input)
        local dragStart = input.Position
        local startPos = mainFrame.Position
        local moveConn, endConn
        moveConn = UserInputService.InputChanged:Connect(function(moveInput)
            if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = moveInput.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                moveConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then drag(input) end
    end)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    minimizeButton.MouseButton1Click:Connect(function()
        self.State.IsMinimized = not self.State.IsMinimized
        local goalSize
        if self.State.IsMinimized then
            goalSize = UDim2.fromOffset(mainFrame.AbsoluteSize.X, 40)
            minimizeButton.Text = "+"
            scrollingFrame.Visible = false
        else
            goalSize = UDim2.fromOffset(mainFrame.AbsoluteSize.X, 350)
            minimizeButton.Text = "-"
            scrollingFrame.Visible = true
        end
        TweenService:Create(mainFrame, tweenInfo, { Size = goalSize }):Play()
    end)
    ui.Parent = CoreGui
end
function Modules.CommandList:Populate()
    local scrollingFrame = self.State.UI.MainFrame.Canvas:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then return end
    scrollingFrame:ClearAllChildren()
    local listLayout = Instance.new("UIListLayout", scrollingFrame)
    listLayout.Padding = UDim.new(0, 8)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y)
    end)
    table.sort(CommandInfo, function(a, b) return a.Name < b.Name end)
    for _, info in ipairs(CommandInfo) do
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = info.Name .. "_Entry"
        entryFrame.BackgroundTransparency = 0.8
        entryFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        entryFrame.Size = UDim2.new(1, 0, 0, 0)
        entryFrame.AutomaticSize = Enum.AutomaticSize.Y
        entryFrame.Parent = scrollingFrame
        Instance.new("UICorner", entryFrame).CornerRadius = UDim.new(0, 6)
        local frameLayout = Instance.new("UIListLayout", entryFrame)
        frameLayout.Padding = UDim.new(0, 5)
        local framePadding = Instance.new("UIPadding", entryFrame)
        framePadding.PaddingLeft = UDim.new(0, 10)
        framePadding.PaddingRight = UDim.new(0, 10)
        framePadding.PaddingTop = UDim.new(0, 8)
        framePadding.PaddingBottom = UDim.new(0, 8)
        local entry = Instance.new("TextLabel")
        entry.Name = info.Name
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.Font = Enum.Font.Gotham
        entry.TextSize = 15
        entry.RichText = true
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextWrapped = true
        entry.Parent = entryFrame
        local aliases = ""
        if info.Aliases and #info.Aliases > 0 then
            aliases = string.format("<font size='12' color='#AAAAAA'><i>(%s)</i></font>", table.concat(info.Aliases, ", "))
        end
        local description = info.Description or "No description provided."
        entry.Text = string.format(
            "<font face='GothamBold' color='#FF69B4'>;%s</font> %s\n<font face='Gotham' size='13' color='#E0E0E0'>  %s</font>",
            info.Name,
            aliases,
            description
        )
    end
end
function Modules.CommandList:Toggle()
    if self.State.IsAnimating then return end
    self.State.IsAnimating = true
    self.State.IsEnabled = not self.State.IsEnabled
    local mainFrame = self.State.UI.MainFrame
    local canvasGroup = mainFrame.Canvas
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if self.State.IsEnabled then
        self.State.UI.Enabled = true
        if self.State.IsMinimized then
            self.State.IsMinimized = false
            mainFrame.Size = UDim2.fromOffset(450, 350)
            mainFrame.Canvas.ScrollingFrame.Visible = true
            mainFrame.Canvas.MinimizeButton.Text = "-"
        end
        self:Populate()
        mainFrame.Size = UDim2.fromOffset(450, 320)
        canvasGroup.GroupTransparency = 1
        local sizeAnim = TweenService:Create(mainFrame, tweenInfo, { Size = UDim2.fromOffset(450, 350) })
        local fadeAnim = TweenService:Create(canvasGroup, tweenInfo, { GroupTransparency = 0 })
        sizeAnim:Play()
        fadeAnim:Play()
        fadeAnim.Completed:Connect(function() self.State.IsAnimating = false end)
    else
        local sizeAnim = TweenService:Create(mainFrame, tweenInfo, { Size = UDim2.fromOffset(450, 320) })
        local fadeAnim = TweenService:Create(canvasGroup, tweenInfo, { GroupTransparency = 1 })
        sizeAnim:Play()
        fadeAnim:Play()
        fadeAnim.Completed:Connect(function()
            self.State.UI.Enabled = false
            self.State.IsAnimating = false
        end)
    end
end
Modules.CommandBar = {
    State = {
        UI = nil,
        Container = nil,
        TextBox = nil,
        LogFrame = nil,
        SuggestionLabel = nil,
        PrefixKey = Enum.KeyCode.Semicolon,
        IsAnimating = false,
        IsEnabled = false,
        MaxLogs = 900,
        CurrentSuggestion = "",
        MinSize = Vector2.new(400, 250),
        SelectionStart = nil,
        SelectionEnd = nil,
        IsSelecting = false,
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = nil,
        PreMaximizePosition = nil
    },
    Theme = {
        Background = Color3.fromRGB(0, 0, 0),
        WindowGray = Color3.fromRGB(192, 192, 192),
        DarkGray = Color3.fromRGB(128, 128, 128),
        LightGray = Color3.fromRGB(223, 223, 223),
        White = Color3.fromRGB(255, 255, 255),
        Blue = Color3.fromRGB(0, 0, 128),
        Accent = Color3.fromRGB(0, 255, 0),
        Text = Color3.fromRGB(192, 192, 192),
        Suggestion = Color3.fromRGB(0, 128, 0),
        Font = Enum.Font.Code
    },
    Dependencies = {"UserInputService", "TweenService", "SoundService"}
}
function Modules.CommandBar:PlayBeep(): ()
    local beep = Instance.new("Sound")
    beep.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    beep.Volume = 0.5
    beep.Parent = game:GetService("SoundService")
    beep:Play()
    beep.Ended:Connect(function() beep:Destroy() end)
end
function Modules.CommandBar:CopyOutputToClipboard(): ()
    if not self.State.LogFrame then return end
    local allText: string = ""
    local children: {Instance} = self.State.LogFrame:GetChildren()
    for _, child in ipairs(children) do
        if child:IsA("TextLabel") then
            allText = allText .. child.Text .. "\n"
        end
    end
    setclipboard(allText)
end
function Modules.CommandBar:CopySelectedText(): ()
    if not self.State.LogFrame then return end
    if self.State.TextBox.Text ~= "" then
        setclipboard(self.State.TextBox.Text)
        return
    end
    if self.State.SelectionStart and self.State.SelectionEnd then
        local children: {Instance} = self.State.LogFrame:GetChildren()
        local selectedText: string = ""
        local startIdx = math.min(self.State.SelectionStart, self.State.SelectionEnd)
        local endIdx = math.max(self.State.SelectionStart, self.State.SelectionEnd)
        for i = startIdx, endIdx do
            if children[i] and children[i]:IsA("TextLabel") then
                selectedText = selectedText .. children[i].Text .. "\n"
            end
        end
        if selectedText ~= "" then
            setclipboard(selectedText)
            return
        end
    end
    self:CopyOutputToClipboard()
end
function Modules.CommandBar:Minimize(): ()
    if self.State.IsMinimized then return end
    self.State.IsMinimized = true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.State.Container, tweenInfo, {
        Position = UDim2.new(0.5, -self.State.Container.Size.X.Offset/2, 1, 50),
        Size = UDim2.new(0, self.State.Container.Size.X.Offset, 0, 30)
    })
    tween:Play()
end
function Modules.CommandBar:Restore(): ()
    if not self.State.IsMinimized then return end
    self.State.IsMinimized = false
    local targetSize = self.State.PreMaximizeSize or UDim2.new(0, 600, 0, 400)
    local targetPos = self.State.PreMaximizePosition or UDim2.new(0.5, -300, 0.5, -200)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.State.Container, tweenInfo, {
        Position = targetPos,
        Size = targetSize
    })
    tween:Play()
end
function Modules.CommandBar:Maximize(): ()
    if self.State.IsMaximized then
        self.State.IsMaximized = false
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.State.Container, tweenInfo, {
            Position = self.State.PreMaximizePosition,
            Size = self.State.PreMaximizeSize
        })
        tween:Play()
    else
        self.State.PreMaximizeSize = self.State.Container.Size
        self.State.PreMaximizePosition = self.State.Container.Position
        self.State.IsMaximized = true
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.State.Container, tweenInfo, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
    end
end
function Modules.CommandBar:Toggle(): ()
    if self.State.IsAnimating then return end
    self.State.IsAnimating = true
    self.State.IsEnabled = not self.State.IsEnabled
    local isOpening: boolean = self.State.IsEnabled
    local tweenInfo: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    if isOpening then
        self.State.UI.Enabled = true
        local goalPosition: UDim2 = UDim2.new(0.5, -self.State.Container.Size.X.Offset/2, 0.5, -self.State.Container.Size.Y.Offset/2)
        local anim = TweenService:Create(self.State.Container, tweenInfo, {
            Position = goalPosition,
            BackgroundTransparency = 0
        })
        anim:Play()
        self.State.TextBox:CaptureFocus()
        task.spawn(function()
            task.wait()
            if self.State.IsEnabled then
                self.State.TextBox.Text = ""
                self.State.SuggestionLabel.Text = ""
                self.State.CurrentSuggestion = ""
            end
        end)
        anim.Completed:Connect(function() self.State.IsAnimating = false end)
    else
        self.State.TextBox:ReleaseFocus()
        local anim = TweenService:Create(self.State.Container, tweenInfo, {
            Position = UDim2.new(0.5, -self.State.Container.Size.X.Offset/2, 1, 50),
            BackgroundTransparency = 1
        })
        anim:Play()
        anim.Completed:Connect(function()
            self.State.UI.Enabled = false
            self.State.IsAnimating = false
        end)
    end
end
function Modules.CommandBar:AddOutput(text: string, color: Color3?): ()
    if not self.State.LogFrame then return end
    local line: TextLabel = Instance.new("TextLabel")
    line.Name = "TerminalLine"
    line.Parent = self.State.LogFrame
    line.BackgroundTransparency = 1
    line.Size = UDim2.new(1, -15, 0, 0)
    line.AutomaticSize = Enum.AutomaticSize.Y
    line.Font = self.Theme.Font
    line.Text = text
    line.TextColor3 = color or self.Theme.Accent
    line.TextSize = 14
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.RichText = true
    line.TextWrapped = true
    local children: {Instance} = self.State.LogFrame:GetChildren()
    if #children > self.State.MaxLogs then
        for i = 1, (#children - self.State.MaxLogs) do
            if children[i]:IsA("TextLabel") then children[i]:Destroy() end
        end
    end
    task.defer(function()
        if self.State.LogFrame then
            self.State.LogFrame.CanvasPosition = Vector2.new(0, self.State.LogFrame.AbsoluteCanvasSize.Y)
        end
    end)
end
function Modules.CommandBar:ListCommands(): ()
    self:AddOutput("════════════════════════════════════════════", self.Theme.Accent)
    self:AddOutput("Zuka-Tech Version 13.77 (C)Copyright Microslop Corp 1981-1994.", self.Theme.Text)
    self:AddOutput("════════════════════════════════════════════", self.Theme.Accent)
    self:AddOutput("")
    local sorted: {any} = {}
    for _, info in ipairs(CommandInfo) do
        table.insert(sorted, info)
    end
    table.sort(sorted, function(a, b) return a.Name < b.Name end)
    for _, info in ipairs(sorted) do
        local aliasStr: string = ""
        if info.Aliases and #info.Aliases > 0 then
            aliasStr = " [" .. table.concat(info.Aliases, ", ") .. "]"
        end
        local desc: string = info.Description or "No description"
        self:AddOutput(string.format("%s%s", info.Name:upper(), aliasStr), self.Theme.Accent)
        self:AddOutput("  " .. desc, self.Theme.Text)
    end
    self:AddOutput("")
    self:AddOutput("════════════════════════════════════════════", self.Theme.Accent)
    self:AddOutput(#sorted .. " command(s) available.", self.Theme.Text)
end
function Modules.CommandBar:UpdateSuggestions(): ()
    local input: string = self.State.TextBox.Text:lower()
    if input == "" then
        self.State.SuggestionLabel.Text = ""
        self.State.CurrentSuggestion = ""
        return
    end
    local match: string = ""
    for cmdName, _ in pairs(Commands) do
        if cmdName:lower():sub(1, #input) == input then
            match = cmdName:lower()
            break
        end
    end
    if match ~= "" then
        self.State.CurrentSuggestion = match
        self.State.SuggestionLabel.Text = match
    else
        self.State.CurrentSuggestion = ""
        self.State.SuggestionLabel.Text = ""
    end
end
function Modules.CommandBar:Initialize(): ()
    local CommandBarUI: ScreenGui = Instance.new("ScreenGui")
    CommandBarUI.Name = "CommandPrompt"
    CommandBarUI.Parent = CoreGui
    CommandBarUI.ResetOnSpawn = false
    CommandBarUI.Enabled = false
    local MainContainer: Frame = Instance.new("Frame")
    MainContainer.Name = "WindowFrame"
    MainContainer.Parent = CommandBarUI
    MainContainer.Size = UDim2.new(0, 600, 0, 400)
    MainContainer.Position = UDim2.new(0.5, -300, 1, 50)
    MainContainer.BackgroundColor3 = self.Theme.WindowGray
    MainContainer.BackgroundTransparency = 0
    MainContainer.BorderSizePixel = 0
    MainContainer.Active = true
    MainContainer.ClipsDescendants = false
    local function CreateWin95Border(parent: Frame, isInset: boolean): ()
        local topColor = isInset and self.Theme.DarkGray or self.Theme.White
        local bottomColor = isInset and self.Theme.White or self.Theme.DarkGray
        local topBorder = Instance.new("Frame", parent)
        topBorder.Name = "TopBorder"
        topBorder.Size = UDim2.new(1, 0, 0, 2)
        topBorder.Position = UDim2.new(0, 0, 0, 0)
        topBorder.BackgroundColor3 = topColor
        topBorder.BorderSizePixel = 0
        topBorder.ZIndex = parent.ZIndex + 1
        local leftBorder = Instance.new("Frame", parent)
        leftBorder.Name = "LeftBorder"
        leftBorder.Size = UDim2.new(0, 2, 1, 0)
        leftBorder.Position = UDim2.new(0, 0, 0, 0)
        leftBorder.BackgroundColor3 = topColor
        leftBorder.BorderSizePixel = 0
        leftBorder.ZIndex = parent.ZIndex + 1
        local bottomBorder = Instance.new("Frame", parent)
        bottomBorder.Name = "BottomBorder"
        bottomBorder.Size = UDim2.new(1, 0, 0, 2)
        bottomBorder.Position = UDim2.new(0, 0, 1, -2)
        bottomBorder.BackgroundColor3 = bottomColor
        bottomBorder.BorderSizePixel = 0
        bottomBorder.ZIndex = parent.ZIndex + 1
        local rightBorder = Instance.new("Frame", parent)
        rightBorder.Name = "RightBorder"
        rightBorder.Size = UDim2.new(0, 2, 1, 0)
        rightBorder.Position = UDim2.new(1, -2, 0, 0)
        rightBorder.BackgroundColor3 = bottomColor
        rightBorder.BorderSizePixel = 0
        rightBorder.ZIndex = parent.ZIndex + 1
    end
    CreateWin95Border(MainContainer, false)
    local TitleBar: Frame = Instance.new("Frame", MainContainer)
    TitleBar.Name = "TitleBar"
    TitleBar.Position = UDim2.new(0, 3, 0, 3)
    TitleBar.Size = UDim2.new(1, -6, 0, 22)
    TitleBar.BackgroundColor3 = self.Theme.Blue
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    local TitleGradient = Instance.new("UIGradient", TitleBar)
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
    }
    TitleGradient.Rotation = 90
    local TitleLabel: TextLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Name = "Title"
    TitleLabel.Position = UDim2.new(0, 4, 0, 0)
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = "C:\\ROBLOX\\system32\\cmd.exe"
    TitleLabel.TextColor3 = self.Theme.White
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    TitleLabel.ZIndex = 3
    local MinimizeButton: TextButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Position = UDim2.new(1, -54, 0, 2)
    MinimizeButton.Size = UDim2.new(0, 16, 0, 16)
    MinimizeButton.BackgroundColor3 = self.Theme.WindowGray
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeButton.TextSize = 14
    MinimizeButton.TextYAlignment = Enum.TextYAlignment.Top
    MinimizeButton.ZIndex = 4
    CreateWin95Border(MinimizeButton, false)
    MinimizeButton.MouseButton1Click:Connect(function()
        if self.State.IsMinimized then
            self:Restore()
        else
            self:Minimize()
        end
    end)
    local MaximizeButton: TextButton = Instance.new("TextButton", TitleBar)
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Position = UDim2.new(1, -36, 0, 2)
    MaximizeButton.Size = UDim2.new(0, 16, 0, 16)
    MaximizeButton.BackgroundColor3 = self.Theme.WindowGray
    MaximizeButton.BorderSizePixel = 0
    MaximizeButton.Font = Enum.Font.SourceSansBold
    MaximizeButton.Text = "□"
    MaximizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    MaximizeButton.TextSize = 14
    MaximizeButton.ZIndex = 4
    CreateWin95Border(MaximizeButton, false)
    MaximizeButton.MouseButton1Click:Connect(function()
        self:Maximize()
    end)
    local CloseButton: TextButton = Instance.new("TextButton", TitleBar)
    CloseButton.Name = "CloseButton"
    CloseButton.Position = UDim2.new(1, -18, 0, 2)
    CloseButton.Size = UDim2.new(0, 16, 0, 16)
    CloseButton.BackgroundColor3 = self.Theme.WindowGray
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    CloseButton.TextSize = 16
    CloseButton.ZIndex = 4
    CreateWin95Border(CloseButton, false)
    CloseButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    local TerminalContainer: Frame = Instance.new("Frame", MainContainer)
    TerminalContainer.Name = "TerminalContainer"
    TerminalContainer.Position = UDim2.new(0, 6, 0, 28)
    TerminalContainer.Size = UDim2.new(1, -12, 1, -34)
    TerminalContainer.BackgroundColor3 = self.Theme.Background
    TerminalContainer.BorderSizePixel = 0
    TerminalContainer.ZIndex = 1
    CreateWin95Border(TerminalContainer, true)
    local ScanlineOverlay = Instance.new("Frame", TerminalContainer)
    ScanlineOverlay.Name = "Scanlines"
    ScanlineOverlay.Size = UDim2.new(1, 0, 1, 0)
    ScanlineOverlay.BackgroundTransparency = 0.95
    ScanlineOverlay.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    ScanlineOverlay.BorderSizePixel = 0
    ScanlineOverlay.ZIndex = 10
    for i = 0, 50 do
        local line = Instance.new("Frame", ScanlineOverlay)
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, i / 50, 0)
        line.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        line.BackgroundTransparency = 0.8
        line.BorderSizePixel = 0
    end
    local AnimatedScanline = Instance.new("Frame", ScanlineOverlay)
    AnimatedScanline.Name = "AnimatedScan"
    AnimatedScanline.Size = UDim2.new(1, 0, 0, 3)
    AnimatedScanline.Position = UDim2.new(0, 0, 0, 0)
    AnimatedScanline.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    AnimatedScanline.BackgroundTransparency = 0.9
    AnimatedScanline.BorderSizePixel = 0
    task.spawn(function()
        while task.wait(0.05) do
            if not AnimatedScanline or not AnimatedScanline.Parent then break end
            AnimatedScanline.Position = UDim2.new(0, 0, (AnimatedScanline.Position.Y.Scale + 0.02) % 1, 0)
        end
    end)
    local OutputLog: ScrollingFrame = Instance.new("ScrollingFrame")
    OutputLog.Name = "Buffer"
    OutputLog.Parent = TerminalContainer
    OutputLog.Position = UDim2.new(0, 4, 0, 4)
    OutputLog.Size = UDim2.new(1, -8, 1, -32)
    OutputLog.BackgroundTransparency = 1
    OutputLog.BorderSizePixel = 0
    OutputLog.ScrollBarThickness = 16
    OutputLog.ScrollBarImageColor3 = self.Theme.WindowGray
    OutputLog.CanvasSize = UDim2.new(0, 0, 0, 0)
    OutputLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OutputLog.ScrollingDirection = Enum.ScrollingDirection.Y
    OutputLog.ZIndex = 2
    local LogLayout: UIListLayout = Instance.new("UIListLayout", OutputLog)
    LogLayout.Padding = UDim.new(0, 0)
    LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local InputArea: Frame = Instance.new("Frame", TerminalContainer)
    InputArea.Position = UDim2.new(0, 4, 1, -24)
    InputArea.Size = UDim2.new(1, -8, 0, 20)
    InputArea.BackgroundTransparency = 1
    InputArea.ZIndex = 2
    local Prompt: TextLabel = Instance.new("TextLabel", InputArea)
    Prompt.Size = UDim2.new(0, 40, 1, 0)
    Prompt.BackgroundTransparency = 1
    Prompt.Font = self.Theme.Font
    Prompt.Text = "C:\\>"
    Prompt.TextColor3 = self.Theme.Accent
    Prompt.TextSize = 14
    Prompt.TextXAlignment = Enum.TextXAlignment.Left
    Prompt.ZIndex = 3
    local SuggestionLabel: TextLabel = Instance.new("TextLabel", InputArea)
    SuggestionLabel.Name = "Suggestion"
    SuggestionLabel.Position = UDim2.new(0, 40, 0, 0)
    SuggestionLabel.Size = UDim2.new(1, -40, 1, 0)
    SuggestionLabel.BackgroundTransparency = 1
    SuggestionLabel.Font = self.Theme.Font
    SuggestionLabel.Text = ""
    SuggestionLabel.TextColor3 = self.Theme.Suggestion
    SuggestionLabel.TextSize = 14
    SuggestionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SuggestionLabel.ZIndex = 3
    local InputField: TextBox = Instance.new("TextBox", InputArea)
    InputField.Name = "Prompt"
    InputField.Position = UDim2.new(0, 40, 0, 0)
    InputField.Size = UDim2.new(1, -40, 1, 0)
    InputField.BackgroundTransparency = 1
    InputField.Font = self.Theme.Font
    InputField.Text = ""
    InputField.TextColor3 = self.Theme.Accent
    InputField.TextSize = 14
    InputField.TextXAlignment = Enum.TextXAlignment.Left
    InputField.ClearTextOnFocus = false
    InputField.ZIndex = 4
    local Cursor: Frame = Instance.new("Frame", InputArea)
    Cursor.Name = "Cursor"
    Cursor.Size = UDim2.new(0, 8, 0, 16)
    Cursor.Position = UDim2.new(0, 40, 0, 2)
    Cursor.BackgroundColor3 = self.Theme.Accent
    Cursor.BorderSizePixel = 0
    Cursor.ZIndex = 5
    task.spawn(function()
        while task.wait(0.5) do
            if not Cursor or not Cursor.Parent then break end
            if InputField:IsFocused() then
                Cursor.BackgroundTransparency = Cursor.BackgroundTransparency == 0 and 1 or 0
            else
                Cursor.BackgroundTransparency = 1
            end
        end
    end)
    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.fromOffset(16, 16)
    ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
    ResizeHandle.BackgroundColor3 = self.Theme.WindowGray
    ResizeHandle.BorderSizePixel = 0
    ResizeHandle.ZIndex = 10
    ResizeHandle.Parent = MainContainer
    for i = 0, 2 do
        local line = Instance.new("Frame", ResizeHandle)
        line.Size = UDim2.new(0, 2, 1, -4 * i)
        line.Position = UDim2.new(0, 4 + (4 * i), 0, 4 * i)
        line.BackgroundColor3 = self.Theme.DarkGray
        line.BorderSizePixel = 0
        line.Rotation = 45
    end
    self.State.UI = CommandBarUI
    self.State.Container = MainContainer
    self.State.TextBox = InputField
    self.State.LogFrame = OutputLog
    self.State.SuggestionLabel = SuggestionLabel
    local dragging, resizing = false, false
    local dragStart, resizeStart, startPos, startSize
    TitleBar.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    ResizeHandle.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = MainContainer.Size
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta: Vector3 = input.Position - dragStart
                MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif resizing then
                local delta: Vector2 = Vector2.new(input.Position.X - resizeStart.X, input.Position.Y - resizeStart.Y)
                local newX = math.max(self.State.MinSize.X, startSize.X.Offset + delta.X)
                local newY = math.max(self.State.MinSize.Y, startSize.Y.Offset + delta.Y)
                MainContainer.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    OutputLog.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.State.IsSelecting = true
            local children: {Instance} = OutputLog:GetChildren()
            local mousePos: Vector3 = input.Position
            for i, child in ipairs(children) do
                if child:IsA("TextLabel") then
                    local absPos: Vector2 = child.AbsolutePosition
                    local absSize: Vector2 = child.AbsoluteSize
                    if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                       mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
                        self.State.SelectionStart = i
                        break
                    end
                end
            end
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.State.IsSelecting = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    OutputLog.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.State.IsSelecting then
            local children: {Instance} = OutputLog:GetChildren()
            local mousePos: Vector3 = input.Position
            for i, child in ipairs(children) do
                if child:IsA("TextLabel") then
                    local absPos: Vector2 = child.AbsolutePosition
                    local absSize: Vector2 = child.AbsoluteSize
                    if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                       mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
                        self.State.SelectionEnd = i
                        for j, c in ipairs(children) do
                            if c:IsA("TextLabel") then
                                local startIdx = math.min(self.State.SelectionStart, self.State.SelectionEnd)
                                local endIdx = math.max(self.State.SelectionStart, self.State.SelectionEnd)
                                if j >= startIdx and j <= endIdx then
                                    c.BackgroundTransparency = 0
                                    c.BackgroundColor3 = self.Theme.Accent
                                    c.TextColor3 = self.Theme.Background
                                else
                                    c.BackgroundTransparency = 1
                                    c.TextColor3 = self.Theme.Accent
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end)
    InputField:GetPropertyChangedSignal("Text"):Connect(function()
        self:UpdateSuggestions()
        local textService = game:GetService("TextService")
        local textWidth = textService:GetTextSize(
            InputField.Text, 
            14, 
            self.Theme.Font, 
            Vector2.new(10000, 20)
        ).X
        Cursor.Position = UDim2.new(0, 40 + textWidth, 0, 2)
    end)
    InputField.FocusLost:Connect(function(enter: boolean)
        if enter then
            local raw: string = InputField.Text
            local cmd: string = string.match(raw, "^%s*(.-)%s*$")
            if cmd ~= "" then
                self:AddOutput("C:\\>" .. cmd, self.Theme.Accent)
                if cmd:lower() == "cmds" or cmd:lower() == "help" or cmd:lower() == "dir" then
                    self:ListCommands()
                elseif cmd:lower() == "cls" or cmd:lower() == "clear" then
                    for _, child in ipairs(OutputLog:GetChildren()) do
                        if child:IsA("TextLabel") then child:Destroy() end
                    end
                else
                    local wasProcessed: boolean = processCommand(Prefix .. cmd)
                    if not wasProcessed then
                        self:AddOutput("Bad command or file name", Color3.fromRGB(255, 255, 255))
                        self:PlayBeep()
                    end
                end
                InputField.Text = ""
            end
            self:Toggle()
        end
    end)
    UserInputService.InputBegan:Connect(function(input: InputObject, gpe: boolean)
        if input.KeyCode == Enum.KeyCode.Tab and InputField:IsFocused() then
            if self.State.CurrentSuggestion ~= "" then
                InputField.Text = self.State.CurrentSuggestion
                InputField.CursorPosition = #InputField.Text + 1
            end
        end
        if not gpe and input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if self.State.IsEnabled then
                self:CopySelectedText()
                self:AddOutput("Copied to clipboard.", self.Theme.Text)
            end
        end
        if not gpe and input.KeyCode == self.State.PrefixKey then 
            self:Toggle() 
        end
    end)
    self:AddOutput("Microslop(R) Windows DOS", self.Theme.Text)
    self:AddOutput("(C)Copyright Microslop Corp 1990-1994.", self.Theme.Text)
    self:AddOutput("")
    self:AddOutput("C:\\WINDOWS>", self.Theme.Accent)
end
function DoNotif(text: string, duration: number?): ()
    NotificationManager.Send(text, duration)
    if Modules.CommandBar and Modules.CommandBar.AddOutput then
        Modules.CommandBar:AddOutput(tostring(text), Modules.CommandBar.Theme.Text)
    end
end
Modules.UnlockMouse = { State = { Enabled = false, Connection = nil } }
RegisterCommand({ Name = "unlockmouse", Aliases = {"unlockcursor", "freemouse", "um"}, Description = "Toggles a persistent loop to unlock the mouse cursor." }, function()
local State = Modules.UnlockMouse.State
State.Enabled = not State.Enabled
if State.Enabled then
    if State.Connection then State.Connection:Disconnect() end
        State.Connection = RunService.RenderStepped:Connect(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end)
    DoNotif("Mouse Unlock Enabled", 2)
else
if State.Connection then State.Connection:Disconnect(); State.Connection = nil end
    DoNotif("Mouse Unlock Disabled", 2)
end
end)
Modules.ESP = {
    State = {
        PlayersEnabled = false,
        Connections = {},
        TrackedPlayers = setmetatable({}, {__mode="k"})
    }
}
function Modules.ESP:_cleanup()
    for name, conn in pairs(self.State.Connections) do 
        conn:Disconnect() 
        self.State.Connections[name] = nil
    end
    for player, _ in pairs(self.State.TrackedPlayers) do
        self:_removePlayerEsp(player)
    end
    table.clear(self.State.TrackedPlayers)
end
function Modules.ESP:_createPlayerEsp(player)
    if player == LocalPlayer then return end
    if self.State.Connections["CharAdded_" .. player.UserId] then return end
    local function setupVisuals(character)
        local existing = self.State.TrackedPlayers[player]
        if existing then
            if existing.Highlight then pcall(function() existing.Highlight:Destroy() end) end
            if existing.Billboard then pcall(function() existing.Billboard:Destroy() end) end
            if existing.InternalConns then
                for _, c in pairs(existing.InternalConns) do c:Disconnect() end
            end
        end
        local head = character:WaitForChild("Head", 10)
        local humanoid = character:WaitForChild("Humanoid", 10)
        local hrp = character:WaitForChild("HumanoidRootPart", 10)
        if not head or not humanoid or not hrp then return end
        local teamColor = player.TeamColor.Color
        local highlight = Instance.new("Highlight")
        highlight.Name = "v_Highlight"
        highlight.Parent = character
        highlight.FillColor = teamColor
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.75
        highlight.OutlineTransparency = 0.1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "v_Billboard"
        billboard.Parent = head
        billboard.Adornee = head
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.MaxDistance = 2500
        local container = Instance.new("Frame", billboard)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        local healthBarBg = Instance.new("Frame", container)
        healthBarBg.Size = UDim2.new(0, 3, 0.5, 0)
        healthBarBg.Position = UDim2.new(0.5, -65, 0.25, 0)
        healthBarBg.BackgroundColor3 = Color3.new(0, 0, 0)
        healthBarBg.BorderSizePixel = 0
        local healthBar = Instance.new("Frame", healthBarBg)
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        healthBar.BorderSizePixel = 0
        local infoLabel = Instance.new("TextLabel", container)
        infoLabel.Size = UDim2.new(1, 0, 0.4, 0)
        infoLabel.Position = UDim2.new(0.5, -55, 0.2, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.BuilderSansBold
        infoLabel.TextColor3 = Color3.new(1, 1, 1)
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.TextSize = 14
        infoLabel.Text = player.DisplayName
        local infoStroke = Instance.new("UIStroke", infoLabel)
        infoStroke.Thickness = 1.5
        local subLabel = Instance.new("TextLabel", container)
        subLabel.Size = UDim2.new(1, 0, 0.3, 0)
        subLabel.Position = UDim2.new(0.5, -55, 0.5, 0)
        subLabel.BackgroundTransparency = 1
        subLabel.Font = Enum.Font.BuilderSansMedium
        subLabel.TextColor3 = teamColor
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.TextSize = 12
        subLabel.Text = "DISTANCE: 0m"
        local subStroke = Instance.new("UIStroke", subLabel)
        subStroke.Thickness = 1.2
        local function update()
            if not hrp or not LocalPlayer.Character then return end
            local lHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not lHrp then return end
            local hp = humanoid.Health / humanoid.MaxHealth
            healthBar.Size = UDim2.new(1, 0, hp, 0)
            healthBar.Position = UDim2.new(0, 0, 1 - hp, 0)
            healthBar.BackgroundColor3 = Color3.fromHSV(hp * 0.35, 1, 1)
            local dist = (hrp.Position - lHrp.Position).Magnitude
            subLabel.Text = string.format("%s | %d STUDS", (player.Team and player.Team.Name:upper() or "NEUTRAL"), math.floor(dist))
        end
        local hConn = humanoid.HealthChanged:Connect(update)
        local rConn = game:GetService("RunService").Heartbeat:Connect(update)
        self.State.TrackedPlayers[player] = {
            Highlight = highlight,
            Billboard = billboard,
            InternalConns = {hConn, rConn}
        }
    end
    if player.Character then task.spawn(setupVisuals, player.Character) end
    self.State.Connections["CharAdded_" .. player.UserId] = player.CharacterAdded:Connect(function(char)
        task.spawn(setupVisuals, char)
    end)
end
function Modules.ESP:_removePlayerEsp(player)
    local data = self.State.TrackedPlayers[player]
    if data then
        if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
        if data.Billboard then pcall(function() data.Billboard:Destroy() end) end
        if data.InternalConns then
            for _, c in pairs(data.InternalConns) do c:Disconnect() end
        end
        self.State.TrackedPlayers[player] = nil
    end
    local charConn = self.State.Connections["CharAdded_" .. player.UserId]
    if charConn then
        charConn:Disconnect()
        self.State.Connections["CharAdded_" .. player.UserId] = nil
    end
end
function Modules.ESP:Toggle(argument)
    argument = (argument or "players"):lower()
    if argument == "players" or argument == "p" or argument == "all" then
        self.State.PlayersEnabled = not self.State.PlayersEnabled
        DoNotif("Visuals: " .. (self.State.PlayersEnabled and "ACTIVE" or "OFFLINE"), 2)
        if self.State.PlayersEnabled then
            self.State.Connections.MainAdded = Players.PlayerAdded:Connect(function(p) 
                self:_createPlayerEsp(p) 
            end)
            self.State.Connections.MainRemoving = Players.PlayerRemoving:Connect(function(p) 
                self:_removePlayerEsp(p) 
            end)
            for _, player in ipairs(Players:GetPlayers()) do 
                self:_createPlayerEsp(player) 
            end
        else
            self:_cleanup()
        end
    else
        local targetPlayer = Utilities.findPlayer(argument)
        if not targetPlayer then return DoNotif("Target not found", 3) end
        if self.State.TrackedPlayers[targetPlayer] or self.State.Connections["CharAdded_" .. targetPlayer.UserId] then
            self:_removePlayerEsp(targetPlayer)
            DoNotif("ESP Disabled for " .. targetPlayer.DisplayName, 2)
        else
            self:_createPlayerEsp(targetPlayer)
            DoNotif("ESP Enabled for " .. targetPlayer.DisplayName, 2)
        end
    end
end
RegisterCommand({
    Name = "esp",
    Aliases = {},
    Description = "Toggles ESP for all players or a specific player."
}, function(args)
    Modules.ESP:Toggle(args[1])
end)
        Modules.ClickTP = { State = { IsActive = false, Connection = nil } };
        function Modules.ClickTP:Toggle()
            self.State.IsActive = not self.State.IsActive
            local UserInputService = game:GetService("UserInputService")
            local Workspace = game:GetService("Workspace")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            if self.State.IsActive then
                self.State.Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                        local camera = Workspace.CurrentCamera
                        local mousePos = UserInputService:GetMouseLocation()
                        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Blacklist
                        params.FilterDescendantsInstances = {LocalPlayer.Character}
                        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
                        if result and result.Position then
                            hrp.CFrame = CFrame.new(result.Position) + Vector3.new(0, 3, 0)
                        end
                    end
                end)
                DoNotif("Click TP Enabled", 2)
            else
            if self.State.Connection then
                self.State.Connection:Disconnect()
                self.State.Connection = nil
            end
            DoNotif("Click TP Disabled", 2)
        end
    end
    RegisterCommand({Name = "clicktp", Aliases = {}, Description = "Hold Left CTRL and click to teleport."}, function(args)
    Modules.ClickTP:Toggle(args)
end)
Modules.HighlightPlayer = { State = { TargetPlayer = nil, HighlightInstance = nil, CharacterAddedConnection = nil } }
local function findFirstPlayer(partialName)
local lowerPartialName = string.lower(partialName)
for _, player in ipairs(Players:GetPlayers()) do
    if string.lower(player.Name):sub(1, #lowerPartialName) == lowerPartialName then return player end
    end
    return nil
end
function Modules.HighlightPlayer:ApplyHighlight(character)
    if not character then return end
        if self.State.HighlightInstance then self.State.HighlightInstance:Destroy() end
            local highlight = Instance.new("Highlight", character)
            highlight.FillColor, highlight.OutlineColor = Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency, highlight.OutlineTransparency = 0.7, 0.2
            self.State.HighlightInstance = highlight
        end
        function Modules.HighlightPlayer:ClearHighlight()
            if self.State.HighlightInstance then self.State.HighlightInstance:Destroy(); self.State.HighlightInstance = nil end
            if self.State.CharacterAddedConnection then self.State.CharacterAddedConnection:Disconnect(); self.State.CharacterAddedConnection = nil end
            if self.State.TargetPlayer then DoNotif("Highlight cleared from: " .. self.State.TargetPlayer.Name, 2); self.State.TargetPlayer = nil end
        end
        RegisterCommand({ Name = "highlight", Aliases = {"find", "findplayer"}, Description = "Highlights a player." }, function(args)
            local argument = args[1]
            if not argument then DoNotif("Usage: highlight <PlayerName|clear>", 3); return end
            if string.lower(argument) == "clear" or string.lower(argument) == "reset" then Modules.HighlightPlayer:ClearHighlight(); return end
            local targetPlayer = findFirstPlayer(argument)
            if not targetPlayer then DoNotif("Player '" .. argument .. "' not found.", 3); return end
            Modules.HighlightPlayer:ClearHighlight()
            Modules.HighlightPlayer.State.TargetPlayer = targetPlayer
            DoNotif("Now highlighting: " .. targetPlayer.Name, 2)
            if targetPlayer.Character then Modules.HighlightPlayer:ApplyHighlight(targetPlayer.Character) end
            Modules.HighlightPlayer.State.CharacterAddedConnection = targetPlayer.CharacterAdded:Connect(function(newCharacter) Modules.HighlightPlayer:ApplyHighlight(newCharacter) end)
        end)
Modules.FovChanger = {
    State = {
        IsEnabled = false,
        TargetFov = 70,
        DefaultFov = 70,
        Connection = nil
    }
}
local function updateFovOnRenderStep()
    local camera = Workspace.CurrentCamera
    local state = Modules.FovChanger.State
    if camera and state.IsEnabled and camera.FieldOfView ~= state.TargetFov then
        camera.FieldOfView = state.TargetFov
    end
end
local function enableFovLock()
    local state = Modules.FovChanger.State
    if not state.Connection then
        state.Connection = RunService.RenderStepped:Connect(updateFovOnRenderStep)
    end
    state.IsEnabled = true
end
local function disableFovLock()
    local state = Modules.FovChanger.State
    state.IsEnabled = false
    if state.Connection then
        state.Connection:Disconnect()
        state.Connection = nil
    end
end
pcall(function()
    Modules.FovChanger.State.DefaultFov = Workspace.CurrentCamera.FieldOfView
end)
RegisterCommand({ Name = "fov", Aliases = {"fieldofview", "camfov"}, Description = "Changes and locks FOV." }, function(args)
    local camera = Workspace.CurrentCamera
    if not camera then
        DoNotif("Could not find camera.", 3)
        return
    end
    local argument = args[1]
    if not argument then
        DoNotif("Current FOV is: " .. camera.FieldOfView, 3)
        return
    end
    if string.lower(argument) == "reset" then
        disableFovLock()
        camera.FieldOfView = Modules.FovChanger.State.DefaultFov
        DoNotif("FOV lock disabled and reset to " .. Modules.FovChanger.State.DefaultFov, 2)
        return
    end
    local newFov = tonumber(argument)
    if not newFov then
        DoNotif("Invalid argument. Provide a number or 'reset'.", 3)
        return
    end
    local clampedFov = math.clamp(newFov, 1, 120)
    Modules.FovChanger.State.TargetFov = clampedFov
    enableFovLock()
    DoNotif("FOV locked to " .. clampedFov, 2)
end)
RegisterCommand({ Name = "cmds", Aliases = {"commands", "help"}, Description = "Opens a UI that lists all available commands." }, function()
    Modules.CommandList:Toggle()
end)
Modules.Fly = {
    State = {
        IsActive = false,
        Speed = 60,
        SprintMultiplier = 2.5,
        Connections = {},
        BodyMovers = {}
    }
}
        function Modules.Fly:SetSpeed(s)
            local n = tonumber(s)
            if n and n > 0 then
                self.State.Speed = n
                DoNotif("Fly speed set to: " .. n, 1)
            else
            DoNotif("Invalid speed.", 1)
        end
    end
    function Modules.Fly:Disable()
        if not self.State.IsActive then return end
            self.State.IsActive = false
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand = false end
                for _, mover in pairs(self.State.BodyMovers) do
                    if mover and mover.Parent then
                        mover:Destroy()
                    end
                end
                for _, connection in ipairs(self.State.Connections) do
                    connection:Disconnect()
                end
                table.clear(self.State.BodyMovers)
                table.clear(self.State.Connections)
                DoNotif("Fly disabled.", 1)
            end
            function Modules.Fly:Enable()
                local self = self
                if self.State.IsActive then return end
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if not (hrp and humanoid) then
                        DoNotif("Character required.", 1)
                        return
                    end
                    self.State.IsActive = true
                    DoNotif("Fly Enabled.", 1)
                    humanoid.PlatformStand = true
                    local hrpAttachment = Instance.new("Attachment", hrp)
                    local worldAttachment = Instance.new("Attachment", workspace.Terrain)
                    worldAttachment.WorldCFrame = hrp.CFrame
                    local alignOrientation = Instance.new("AlignOrientation")
                    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                    alignOrientation.Attachment0 = hrpAttachment
                    alignOrientation.Responsiveness = 200
                    alignOrientation.MaxTorque = math.huge
                    alignOrientation.Parent = hrp
                    local linearVelocity = Instance.new("LinearVelocity")
                    linearVelocity.Attachment0 = hrpAttachment
                    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                    linearVelocity.MaxForce = math.huge
                    linearVelocity.VectorVelocity = Vector3.zero
                    linearVelocity.Parent = hrp
                    self.State.BodyMovers.HRPAttachment = hrpAttachment
                    self.State.BodyMovers.WorldAttachment = worldAttachment
                    self.State.BodyMovers.AlignOrientation = alignOrientation
                    self.State.BodyMovers.LinearVelocity = linearVelocity
                    local keys = {}
                    local function onInput(input, gameProcessed)
                    if not gameProcessed then
                        keys[input.KeyCode] = (input.UserInputState == Enum.UserInputState.Begin)
                    end
                end
                table.insert(self.State.Connections, UserInputService.InputBegan:Connect(onInput))
                table.insert(self.State.Connections, UserInputService.InputEnded:Connect(onInput))
                local loop = RunService.RenderStepped:Connect(function()
                    if not self.State.IsActive or not hrp.Parent then return end
                    local camera = workspace.CurrentCamera
                    alignOrientation.CFrame = camera.CFrame
                    local direction = Vector3.new()
                    if keys[Enum.KeyCode.W] then direction += camera.CFrame.LookVector end
                    if keys[Enum.KeyCode.S] then direction -= camera.CFrame.LookVector end
                    if keys[Enum.KeyCode.D] then direction += camera.CFrame.RightVector end
                    if keys[Enum.KeyCode.A] then direction -= camera.CFrame.RightVector end
                    if keys[Enum.KeyCode.Space] or keys[Enum.KeyCode.E] then direction += Vector3.yAxis end
                    if keys[Enum.KeyCode.LeftControl] or keys[Enum.KeyCode.Q] then direction -= Vector3.yAxis end
                    local speed = keys[Enum.KeyCode.LeftShift] and self.State.Speed * self.State.SprintMultiplier or self.
                    State.Speed
                    linearVelocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * speed or Vector3.zero
                end)
            table.insert(self.State.Connections, loop)
        end
        function Modules.Fly:Toggle()
            if self.State.IsActive then
                self:Disable()
            else
                self:Enable()
             end
         end
    RegisterCommand({ Name = "fly", Aliases = {"flight"}, Description = "The most boring exploit anyone can use." }, function()
         Modules.Fly:Toggle()
    end)
Modules.NoClip = {
    State = {
    IsEnabled = false,
    Connections = {},
    TrackedParts = setmetatable({}, {__mode = "k"})
    },
    Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}
}
function Modules.NoClip:_addPart(part)
    if not part:IsA("BasePart") then return end
    self.State.TrackedParts[part] = true
    part.CanCollide = false
end
function Modules.NoClip:_processCharacter(character)
    if not character then return end
    if self.State.Connections[character] then
        for _, conn in ipairs(self.State.Connections[character]) do conn:Disconnect() end
    end
    self.State.Connections[character] = {}
    for _, descendant in ipairs(character:GetDescendants()) do
        self:_addPart(descendant)
    end
    local descAddedConn = character.DescendantAdded:Connect(function(descendant)
        self:_addPart(descendant)
    end)
    local descRemovingConn = character.DescendantRemoving:Connect(function(descendant)
        if self.State.TrackedParts[descendant] then
            self.State.TrackedParts[descendant] = nil
        end
    end)
    table.insert(self.State.Connections[character], descAddedConn)
    table.insert(self.State.Connections[character], descRemovingConn)
end
function Modules.NoClip:_cleanup()
    for key, conn in pairs(self.State.Connections) do
        if type(conn) == "table" then
            for _, innerConn in ipairs(conn) do innerConn:Disconnect() end
        else
            conn:Disconnect()
        end
    end
    table.clear(self.State.Connections)
    for part in pairs(self.State.TrackedParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    table.clear(self.State.TrackedParts)
end
function Modules.NoClip:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then
        self:_processCharacter(localPlayer.Character)
    end
    self.State.Connections.CharacterAdded = localPlayer.CharacterAdded:Connect(function(char)
        self:_processCharacter(char)
    end)
    self.State.Connections.Enforcer = self.Services.RunService.Stepped:Connect(function()
        for part in pairs(self.State.TrackedParts) do
            if part and part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
    DoNotif("Persistent NoClip Enabled", 2)
end
function Modules.NoClip:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    self:_cleanup()
    DoNotif("NoClip Disabled", 2)
end
function Modules.NoClip:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({ Name = "noclip", Aliases = {"nc"}, Description = "Allows you to walk through walls" }, function()
    Modules.NoClip:Toggle()
end)
Modules.AnimationFreezer = {
    State = {
        IsEnabled = false,
        CharacterConnection = nil,
        Originals = {}
    }
}
function Modules.AnimationFreezer:_applyFreeze(character)
    if not character or self.State.Originals[character] then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    self.State.Originals[character] = animator
    local fakeAnimationTrack = {
        IsPlaying = false,
        Length = 0,
        TimePosition = 0,
        Speed = 0,
        Play = function() end,
        Stop = function() end,
        Pause = function() end,
        AdjustSpeed = function() end,
        GetMarkerReachedSignal = function() return { Connect = function() end } end,
        GetTimeOfKeyframe = function() return 0 end,
        Destroy = function() end
    }
    local animatorProxy = {}
    local animatorMetatable = {
        __index = function(t, key)
            if tostring(key):lower() == "loadanimation" then
                return function()
                    return fakeAnimationTrack
                end
            else
                return self.State.Originals[character][key]
            end
        end
    }
    setmetatable(animatorProxy, animatorMetatable)
    animator.Parent = nil
    animatorProxy.Name = "Animator"
    animatorProxy.Parent = humanoid
end
function Modules.AnimationFreezer:_removeFreeze(character)
    if not character or not self.State.Originals[character] then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local proxy = humanoid:FindFirstChild("Animator")
    local original = self.State.Originals[character]
    if proxy then proxy:Destroy() end
    if original then original.Parent = humanoid end
    self.State.Originals[character] = nil
end
function Modules.AnimationFreezer:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        DoNotif("Animation Freezer Enabled", 2)
        if LocalPlayer.Character then
            self:_applyFreeze(LocalPlayer.Character)
        end
        self.State.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            self:_applyFreeze(character)
        end)
    else
        DoNotif("Animation Freezer Disabled", 2)
        if LocalPlayer.Character then
            self:_removeFreeze(LocalPlayer.Character)
        end
        if self.State.CharacterConnection then
            self.State.CharacterConnection:Disconnect()
            self.State.CharacterConnection = nil
        end
        for char, animator in pairs(self.State.Originals) do
            self:_removeFreeze(char)
        end
    end
end
RegisterCommand({
    Name = "freezeanim",
    Aliases = {},
    Description = "Freezes all local character animations to skip delays (e.g., weapon swings)."
}, function()
    Modules.AnimationFreezer:Toggle()
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
Modules.RespawnAtDeath = {
    State = {
        Enabled = false,
        LastDeathCFrame = nil,
        DiedConnection = nil,
        CharacterConnection = nil,
    }
}
function Modules.RespawnAtDeath.OnDied()
    local character = Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        Modules.RespawnAtDeath.State.LastDeathCFrame = root.CFrame
        print("Death location saved.")
    end
end
function Modules.RespawnAtDeath.OnCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    if Modules.RespawnAtDeath.State.DiedConnection then
        Modules.RespawnAtDeath.State.DiedConnection:Disconnect()
    end
    Modules.RespawnAtDeath.State.DiedConnection = humanoid.Died:Connect(Modules.RespawnAtDeath.OnDied)
    local deathCFrame = Modules.RespawnAtDeath.State.LastDeathCFrame
    if deathCFrame then
        coroutine.wrap(function()
            print("Teleporting to saved death location...")
            task.wait(0.1)
            local root = character:WaitForChild("HumanoidRootPart")
            if not root then return end
            local originalAnchored = root.Anchored
            root.Anchored = true
            root.CFrame = deathCFrame
            RunService.Heartbeat:Wait()
            root.Anchored = originalAnchored
            Modules.RespawnAtDeath.State.LastDeathCFrame = nil
            print("Teleport successful.")
        end)()
    end
end
function Modules.RespawnAtDeath.Toggle()
    local localPlayer = Players.LocalPlayer
    Modules.RespawnAtDeath.State.Enabled = not Modules.RespawnAtDeath.State.Enabled
    if Modules.RespawnAtDeath.State.Enabled then
        print("revert: ENABLED")
        Modules.RespawnAtDeath.State.CharacterConnection = localPlayer.CharacterAdded:Connect(Modules.RespawnAtDeath.  OnCharacterAdded)
        if localPlayer.Character then
            Modules.RespawnAtDeath.OnCharacterAdded(localPlayer.Character)
        end
    else
        print("revert: DISABLED")
        if Modules.RespawnAtDeath.State.DiedConnection then
            Modules.RespawnAtDeath.State.DiedConnection:Disconnect()
            Modules.RespawnAtDeath.State.DiedConnection = nil
        end
        if Modules.RespawnAtDeath.State.CharacterConnection then
            Modules.RespawnAtDeath.State.CharacterConnection:Disconnect()
            Modules.RespawnAtDeath.State.CharacterConnection = nil
        end
        Modules.RespawnAtDeath.State.LastDeathCFrame = nil
    end
end
RegisterCommand({
    Name = "revert",
    Aliases = {"deathspawn", "spawnondeath"},
    Description = "Toggles respawning at your last death location."
}, function(args)
    Modules.RespawnAtDeath.Toggle()
end)
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
Modules.RejoinServer = {
    State = {}
}
RegisterCommand({
    Name = "rejoin",
    Aliases = {"rj", "reconnect"},
    Description = "Teleports you back to the current server."
}, function(args)
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        print("Error: Could not find LocalPlayer.")
        return
    end
    local placeId = game.PlaceId
    local jobId = game.JobId
    print("Rejoining server... Please wait.")
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
    end)
    if not success then
        print("Rejoin failed: " .. errorMessage)
    end
end)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
Modules.AutoAttack = {
    State = {
        Enabled = false,
        ClickDelay = 0.1,
        Connection = nil,
        LastClickTime = 0,
        ToggleKey = Enum.KeyCode.H
    }
}
function Modules.AutoAttack:AttackLoop()
    if UserInputService:GetFocusedTextBox() then
        return
    end
    local currentTime = os.clock()
    if currentTime - self.State.LastClickTime > self.State.ClickDelay then
        mouse1press()
        task.wait()
        mouse1release()
        self.State.LastClickTime = currentTime
    end
end
function Modules.AutoAttack:Enable()
    self.State.Enabled = true
    self.State.LastClickTime = 0
    self.State.Connection = RunService.Heartbeat:Connect(function()
        self:AttackLoop()
    end)
    DoNotif("Auto-Attack: [Enabled] | Delay: " .. self.State.ClickDelay * 1000 .. "ms", 2)
end
function Modules.AutoAttack:Disable()
    self.State.Enabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    DoNotif("Auto-Attack: [Disabled]", 2)
end
function Modules.AutoAttack:Toggle()
    if self.State.Enabled then
        self:Disable()
    else
        self:Enable()
    end
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Modules.AutoAttack.State.ToggleKey then
        Modules.AutoAttack:Toggle()
    end
end)
RegisterCommand({
    Name = "autoattack",
    Aliases = {"autoclick"},
    Description = "Toggles auto-click. Usage: ;aa [delay_ms | key key_name]"
}, function(args)
    local subCommand = args[1] and args[1]:lower()
    local value = args[2]
    if subCommand == "key" then
        if value and Enum.KeyCode[value:upper()] then
            local newKey = Enum.KeyCode[value:upper()]
            Modules.AutoAttack.State.ToggleKey = newKey
            DoNotif("Auto-Attack toggle key set to: " .. value:upper(), 2)
        else
            DoNotif("Invalid key name. Example: E, Q, F, MouseButton1", 3)
        end
        return
    end
    local newDelay = tonumber(subCommand)
    if newDelay and newDelay > 0 then
        Modules.AutoAttack.State.ClickDelay = newDelay / 1000
        DoNotif("Auto-Attack delay set to: " .. newDelay .. "ms", 2)
        return
    end
    Modules.AutoAttack:Toggle()
end)
Modules.killbrick = {
    State = {
        Tracked = setmetatable({}, {__mode = "k"}),
        Originals = setmetatable({}, {__mode = "k"}),
        Signals = setmetatable({}, {__mode = "k"}),
        Connections = {},
        Enabled = false,
        LastCleanup = 0,
        Stats = {
            PartsProtected = 0,
            AttemptsBlocked = 0,
            LastReset = tick()
        }
    },
    Config = {
        CleanupInterval = 30,
        UseHeartbeat = false,
        ProtectAccessories = true,
        ProtectTools = true,
        WhitelistedParts = {},
        DebugMode = false
    }
}
local function debugLog(message)
    if Modules.killbrick.Config.DebugMode then
        print("[KillBrick Debug]", message)
    end
end
local function cleanupAntiKillbrick()
    local state = Modules.killbrick.State
    debugLog("Starting cleanup...")
    for i = #state.Connections, 1, -1 do
        local conn = state.Connections[i]
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
        state.Connections[i] = nil
    end
    for part, signalTable in pairs(state.Signals) do
        if signalTable then
            for i = #signalTable, 1, -1 do
                local conn = signalTable[i]
                if conn and typeof(conn) == "RBXScriptConnection" then
                    pcall(function() conn:Disconnect() end)
                end
                signalTable[i] = nil
            end
        end
    end
    for part, originalValue in pairs(state.Originals) do
        if typeof(part) == "Instance" and part:IsA("BasePart") then
            pcall(function()
                part.CanTouch = originalValue
            end)
        end
    end
    table.clear(state.Signals)
    table.clear(state.Tracked)
    table.clear(state.Originals)
    state.LastCleanup = tick()
    debugLog("Cleanup completed")
end
local function isPartWhitelisted(part)
    local state = Modules.killbrick.State
    for _, whitelistedPart in ipairs(Modules.killbrick.Config.WhitelistedParts) do
        if part == whitelistedPart or part:IsDescendantOf(whitelistedPart) then
            return true
        end
    end
    return false
end
local function shouldProtectPart(part)
    if not (part and typeof(part) == "Instance" and part:IsA("BasePart")) then
        return false
    end
    if isPartWhitelisted(part) then
        return false
    end
    local character = Players.LocalPlayer.Character
    if not character or not part:IsDescendantOf(character) then
        return false
    end
    if not Modules.killbrick.Config.ProtectAccessories and part:FindFirstAncestorOfClass("Accessory") then
        return false
    end
    if not Modules.killbrick.Config.ProtectTools and part:FindFirstAncestorOfClass("Tool") then
        return false
    end
    return true
end
local function applyProtection(part)
    local state = Modules.killbrick.State
    if not shouldProtectPart(part) then
        return
    end
    if state.Originals[part] == nil then
        state.Originals[part] = part.CanTouch
    end
    local success = pcall(function()
        part.CanTouch = false
    end)
    if not success then
        debugLog("Failed to protect part: " .. tostring(part))
        return
    end
    state.Tracked[part] = true
    state.Stats.PartsProtected = state.Stats.PartsProtected + 1
    if not state.Signals[part] then
        local connection = part:GetPropertyChangedSignal("CanTouch"):Connect(function()
            if not state.Enabled then return end
            if part.CanTouch ~= false then
                pcall(function()
                    part.CanTouch = false
                    state.Stats.AttemptsBlocked = state.Stats.AttemptsBlocked + 1
                    debugLog("Blocked CanTouch change on: " .. tostring(part))
                end)
            end
        end)
        state.Signals[part] = {connection}
    end
end
local function setupCharacter(character)
    if not character then return end
    local state = Modules.killbrick.State
    debugLog("Setting up character: " .. tostring(character))
    for _, descendant in ipairs(character:GetDescendants()) do
        applyProtection(descendant)
    end
    local addedConn = character.DescendantAdded:Connect(function(descendant)
        if state.Enabled then
            task.defer(applyProtection, descendant)
        end
    end)
    table.insert(state.Connections, addedConn)
    local removingConn = character.DescendantRemoving:Connect(function(descendant)
        if state.Signals[descendant] then
            for _, conn in ipairs(state.Signals[descendant]) do
                pcall(function() conn:Disconnect() end)
            end
            state.Signals[descendant] = nil
        end
        state.Tracked[descendant] = nil
        state.Originals[descendant] = nil
    end)
    table.insert(state.Connections, removingConn)
end
local function onCharacterAdded(character)
    debugLog("Character added, reinitializing...")
    task.wait(0.1)
    cleanupAntiKillbrick()
    if Modules.killbrick.State.Enabled then
        setupCharacter(character)
    end
end
function Modules.killbrick.Enable()
    local state = Modules.killbrick.State
    if state.Enabled then
        warn("[KillBrick] Already enabled")
        return
    end
    state.Enabled = true
    state.Stats.LastReset = tick()
    cleanupAntiKillbrick()
    local localPlayer = Players.LocalPlayer
    if localPlayer.Character then
        setupCharacter(localPlayer.Character)
    end
    local charAddedConn = localPlayer.CharacterAdded:Connect(onCharacterAdded)
    table.insert(state.Connections, charAddedConn)
    local charRemovingConn = localPlayer.CharacterRemoving:Connect(function()
        debugLog("Character removing...")
    end)
    table.insert(state.Connections, charRemovingConn)
    local updateEvent = Modules.killbrick.Config.UseHeartbeat and RunService.Heartbeat or RunService.Stepped
    local updateConn = updateEvent:Connect(function()
        if not state.Enabled then return end
        local character = localPlayer.Character
        if not character then return end
        if tick() - state.LastCleanup > Modules.killbrick.Config.CleanupInterval then
            local tracked = {}
            for part in pairs(state.Tracked) do
                if typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent then
                    tracked[part] = true
                else
                    state.Tracked[part] = nil
                    state.Originals[part] = nil
                    if state.Signals[part] then
                        for _, conn in ipairs(state.Signals[part]) do
                            pcall(function() conn:Disconnect() end)
                        end
                        state.Signals[part] = nil
                    end
                end
            end
            state.LastCleanup = tick()
        end
        for part in pairs(state.Tracked) do
            if typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent then
                if part.CanTouch ~= false then
                    pcall(function()
                        part.CanTouch = false
                        state.Stats.AttemptsBlocked = state.Stats.AttemptsBlocked + 1
                    end)
                end
            end
        end
    end)
    table.insert(state.Connections, updateConn)
    DoNotif("Anti-KillBrick Enabled", 2)
    debugLog("Protection enabled with " .. state.Stats.PartsProtected .. " parts")
end
function Modules.killbrick.Disable()
    local state = Modules.killbrick.State
    if not state.Enabled then
        warn("[KillBrick] Already disabled")
        return
    end
    state.Enabled = false
    cleanupAntiKillbrick()
    DoNotif("Anti-KillBrick Disabled", 2)
    debugLog("Protection disabled")
end
function Modules.killbrick.Toggle()
    if Modules.killbrick.State.Enabled then
        Modules.killbrick.Disable()
    else
        Modules.killbrick.Enable()
    end
end
function Modules.killbrick.GetStats()
    local state = Modules.killbrick.State
    local uptime = tick() - state.Stats.LastReset
    return {
        Enabled = state.Enabled,
        PartsProtected = state.Stats.PartsProtected,
        AttemptsBlocked = state.Stats.AttemptsBlocked,
        Uptime = uptime,
        TrackedParts = 0
    }
end
function Modules.killbrick.AddWhitelist(part)
    if not (part and typeof(part) == "Instance") then
        return false
    end
    table.insert(Modules.killbrick.Config.WhitelistedParts, part)
    debugLog("Added whitelist: " .. tostring(part))
    return true
end
function Modules.killbrick.RemoveWhitelist(part)
    for i, whitelisted in ipairs(Modules.killbrick.Config.WhitelistedParts) do
        if whitelisted == part then
            table.remove(Modules.killbrick.Config.WhitelistedParts, i)
            debugLog("Removed whitelist: " .. tostring(part))
            return true
        end
    end
    return false
end
function Modules.killbrick.ClearWhitelist()
    table.clear(Modules.killbrick.Config.WhitelistedParts)
    debugLog("Cleared whitelist")
end
RegisterCommand({
    Name = "antikillbrick",
    Aliases = {"antikb", "akb"},
    Description = "Prevents kill bricks from killing you."
}, function(args)
    Modules.killbrick.Enable()
end)
RegisterCommand({
    Name = "unantikillbrick",
    Aliases = {"unantikb", "unakb"},
    Description = "Allows kill bricks to kill you again."
}, function(args)
    Modules.killbrick.Disable()
end)
RegisterCommand({
    Name = "togglekillbrick",
    Aliases = {"tkb"},
    Description = "Toggles kill brick protection."
}, function(args)
    Modules.killbrick.Toggle()
end)
RegisterCommand({
    Name = "killbrickstats",
    Aliases = {"kbstats"},
    Description = "Shows kill brick protection statistics."
}, function(args)
    local stats = Modules.killbrick.GetStats()
    print("=== Kill Brick Protection Stats ===")
    print("Enabled:", stats.Enabled)
    print("Parts Protected:", stats.PartsProtected)
    print("Attempts Blocked:", stats.AttemptsBlocked)
    print("Uptime:", string.format("%.1f", stats.Uptime) .. "s")
end)
Modules.FlingProtection = {
State = {
IsEnabled = false,
SteppedConnection = nil,
PlayerConnections = {}
},
Config = {
MAX_VELOCITY_MAGNITUDE = 200,
LOCAL_PLAYER_GROUP = "LocalPlayerCollisionGroup",
OTHER_PLAYERS_GROUP = "OtherPlayersCollisionGroup"
}
}
function Modules.FlingProtection:_setCollisionGroupForCharacter(character, groupName)
    if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CollisionGroup = groupName end)
            end
        end
    end
    function Modules.FlingProtection:_setupPlayerCollisions()
        local PhysicsService = game:GetService("PhysicsService")
        pcall(function() PhysicsService:CreateCollisionGroup(self.Config.LOCAL_PLAYER_GROUP) end)
        pcall(function() PhysicsService:CreateCollisionGroup(self.Config.OTHER_PLAYERS_GROUP) end)
        PhysicsService:CollisionGroupSetCollidable(self.Config.LOCAL_PLAYER_GROUP, self.Config.OTHER_PLAYERS_GROUP, false)
        for _, player in ipairs(Players:GetPlayers()) do
            local group = (player == LocalPlayer) and self.Config.LOCAL_PLAYER_GROUP or self.Config.OTHER_PLAYERS_GROUP
            if player.Character then
                self:_setCollisionGroupForCharacter(player.Character, group)
            end
            local conn = player.CharacterAdded:Connect(function(character)
            self:_setCollisionGroupForCharacter(character, group)
        end)
        table.insert(self.State.PlayerConnections, conn)
    end
    local conn = Players.PlayerAdded:Connect(function(player)
    local group = self.Config.OTHER_PLAYERS_GROUP
    local charConn = player.CharacterAdded:Connect(function(character)
    self:_setCollisionGroupForCharacter(character, group)
end)
table.insert(self.State.PlayerConnections, charConn)
end)
table.insert(self.State.PlayerConnections, conn)
end
function Modules.FlingProtection:_revertPlayerCollisions()
    for _, conn in ipairs(self.State.PlayerConnections) do
        conn:Disconnect()
    end
    self.State.PlayerConnections = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            self:_setCollisionGroupForCharacter(player.Character, "Default")
        end
    end
end
function Modules.FlingProtection:_enforceStability()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (hrp and not hrp.Anchored) then return end
        if hrp.AssemblyLinearVelocity.Magnitude > self.Config.MAX_VELOCITY_MAGNITUDE then
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
    function Modules.FlingProtection:Toggle()
        self.State.IsEnabled = not self.State.IsEnabled
        if self.State.IsEnabled then
            DoNotif("Fling & Player Collision Protection: ENABLED", 2)
            self:_setupPlayerCollisions()
            self.State.SteppedConnection = RunService.Stepped:Connect(function() self:_enforceStability() end)
        else
        DoNotif("Fling & Player Collision Protection: DISABLED", 2)
        self:_revertPlayerCollisions()
        if self.State.SteppedConnection then
            self.State.SteppedConnection:Disconnect()
            self.State.SteppedConnection = nil
        end
    end
end
do
	local ATTRIBUTE_OG_SIZE = "Zuka_OriginalSize"
	local SELECTION_BOX_NAME = "Zuka_ReachSelectionBox"
	local activeTool: Tool? = nil
	local modifiedPart: BasePart? = nil
	local persistentToolName: string? = nil
	local persistentPartName: string? = nil
	local currentReachSize: number = 20
	local currentReachType: "directional" | "box" = "directional"
	Modules.ReachController = {
		State = {
			IsEnabled = false,
			UI = nil,
			Connections = {}
		}
	}
	local function updatePartModification(part: BasePart, newSize: number?, reachType: string?)
		if not part or not part.Parent then return end
		local originalSize = part:GetAttribute(ATTRIBUTE_OG_SIZE)
		if not newSize then
			if originalSize then part.Size = originalSize; part:SetAttribute(ATTRIBUTE_OG_SIZE, nil) end
			local selectionBox = part:FindFirstChild(SELECTION_BOX_NAME)
			if selectionBox then selectionBox:Destroy() end
			return
		end
		if not originalSize then part:SetAttribute(ATTRIBUTE_OG_SIZE, part.Size) end
		local selectionBox = part:FindFirstChild(SELECTION_BOX_NAME) or Instance.new("SelectionBox")
		selectionBox.Name = SELECTION_BOX_NAME; selectionBox.Adornee = part; selectionBox.LineThickness = 0.02; selectionBox.Parent = part
		selectionBox.Color3 = reachType == "box" and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 0, 0)
		if reachType == "box" then part.Size = Vector3.one * newSize else part.Size = Vector3.new(part.Size.X, part.Size.Y, newSize) end
		part.Massless = true
	end
	local function resetReach()
		if not modifiedPart and not persistentToolName then print("Reach is not active."); return end
		local tool; if persistentToolName then tool = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(persistentToolName)) or (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(persistentToolName)) end
		local partToReset = modifiedPart or (tool and persistentPartName and tool:FindFirstChild(persistentPartName, true))
		if partToReset then updatePartModification(partToReset, nil, nil) end
		modifiedPart, persistentToolName, persistentPartName = nil, nil, nil
		print("Tool reach has been fully reset.")
	end
	function Modules.ReachController:Enable()
		if self.State.IsEnabled then return end
		self.State.IsEnabled = true
		local ui = Instance.new("ScreenGui"); ui.Name = "ReachController_Zuka"; ui.ZIndexBehavior = Enum.ZIndexBehavior.Global; ui.ResetOnSpawn = false
		self.State.UI = ui
		local mainFrame = Instance.new("Frame", ui); mainFrame.Size = UDim2.fromOffset(250, 320); mainFrame.Position = UDim2.fromScale(0, 0); mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); mainFrame.BorderSizePixel = 0; mainFrame.ClipsDescendants = true
		Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(80, 80, 100)
		local titleBar = Instance.new("Frame", mainFrame); titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1, 0, 0, 30); titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35); titleBar.BorderSizePixel = 0
		local title = Instance.new("TextLabel", titleBar); title.Size = UDim2.new(1, -30, 1, 0); title.Position = UDim2.fromOffset(10, 0); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamSemibold; title.Text = "Reach Controller"; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left
		local contentFrame = Instance.new("Frame", mainFrame); contentFrame.Name = "Content"; contentFrame.Size = UDim2.new(1, 0, 1, -30); contentFrame.Position = UDim2.new(0, 0, 0, 30); contentFrame.BackgroundTransparency = 1
		local toggleButton = Instance.new("TextButton", titleBar); toggleButton.Size = UDim2.fromOffset(20, 20); toggleButton.Position = UDim2.new(1, -10, 0.5, 0); toggleButton.AnchorPoint = Vector2.new(1, 0.5); toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100); toggleButton.Text = "-"; toggleButton.Font = Enum.Font.GothamBold; toggleButton.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 4)
		titleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then local dragStart, startPos = input.Position, mainFrame.Position; local moveConn, endConn; moveConn = UserInputService.InputChanged:Connect(function(moveInput) if moveInput.UserInputType == Enum.UserInputType.MouseMovement then local delta = moveInput.Position - dragStart; mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end); endConn = UserInputService.InputEnded:Connect(function(endInput) if endInput.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect(); endConn:Disconnect() end end) end end)
		local sizeLabel = Instance.new("TextLabel", contentFrame); sizeLabel.Size = UDim2.fromOffset(80, 20); sizeLabel.Position = UDim2.fromOffset(10, 10); sizeLabel.BackgroundTransparency = 1; sizeLabel.Font = Enum.Font.Gotham; sizeLabel.Text = "Reach Size:"; sizeLabel.TextColor3 = Color3.new(1, 1, 1); sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
		local sizeInput = Instance.new("TextBox", contentFrame); sizeInput.Size = UDim2.fromOffset(130, 30); sizeInput.Position = UDim2.fromOffset(110, 5); sizeInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65); sizeInput.Font = Enum.Font.Code; sizeInput.Text = tostring(currentReachSize); sizeInput.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", sizeInput).CornerRadius = UDim.new(0, 4)
		local directionalBtn = Instance.new("TextButton", contentFrame); directionalBtn.Size = UDim2.fromOffset(110, 30); directionalBtn.Position = UDim2.fromOffset(10, 40); directionalBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100); directionalBtn.Font = Enum.Font.GothamSemibold; directionalBtn.Text = "Directional"; directionalBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", directionalBtn).CornerRadius = UDim.new(0, 4)
		local boxBtn = Instance.new("TextButton", contentFrame); boxBtn.Size = UDim2.fromOffset(110, 30); boxBtn.Position = UDim2.fromOffset(130, 40); boxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65); boxBtn.Font = Enum.Font.GothamSemibold; boxBtn.Text = "Box"; boxBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", boxBtn).CornerRadius = UDim.new(0, 4)
		local partsLabel = Instance.new("TextLabel", contentFrame); partsLabel.Size = UDim2.fromOffset(80, 20); partsLabel.Position = UDim2.fromOffset(10, 75); partsLabel.BackgroundTransparency = 1; partsLabel.Font = Enum.Font.Gotham; partsLabel.Text = "Tool Parts:"; partsLabel.TextColor3 = Color3.new(1, 1, 1); partsLabel.TextXAlignment = Enum.TextXAlignment.Left
		local scroll = Instance.new("ScrollingFrame", contentFrame); scroll.Size = UDim2.new(1, -20, 1, -140); scroll.Position = UDim2.fromOffset(10, 100); scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35); scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 6
		local resetBtn = Instance.new("TextButton", contentFrame); resetBtn.Size = UDim2.new(1, -20, 0, 30); resetBtn.Position = UDim2.new(0.5, 0, 1, -10); resetBtn.AnchorPoint = Vector2.new(0.5, 1); resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); resetBtn.Font = Enum.Font.GothamBold; resetBtn.Text = "Reset Reach"; resetBtn.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
		local function populatePartSelector()
			scroll:ClearAllChildren(); if not activeTool then return end
			local parts = {}; for _, d in ipairs(activeTool:GetDescendants()) do if d:IsA("BasePart") then table.insert(parts, d) end end
			if #parts == 0 then return end
			local listLayout = Instance.new("UIListLayout", scroll); listLayout.Padding = UDim.new(0, 5); listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			for _, part in ipairs(parts) do
				local btn = Instance.new("TextButton", scroll); btn.Size = UDim2.new(1, -10, 0, 30); btn.Position = UDim2.fromScale(0.5, 0); btn.AnchorPoint = Vector2.new(0.5, 0); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65); btn.TextColor3 = Color3.fromRGB(220, 220, 230); btn.Font = Enum.Font.Code; btn.Text = part.Name; btn.TextSize = 14; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
				btn.MouseButton1Click:Connect(function()
					if not part or not part.Parent or not activeTool then print("Reach Error: Part/tool missing."); return end
					persistentToolName, persistentPartName = activeTool.Name, part.Name
					if modifiedPart and modifiedPart ~= part then updatePartModification(modifiedPart, nil, nil) end
					modifiedPart = part; updatePartModification(part, currentReachSize, currentReachType)
					print(string.format("Reach set for '%s' on tool '%s'.", part.Name, activeTool.Name))
				end)
			end
		end
		sizeInput.FocusLost:Connect(function() local num = tonumber(sizeInput.Text); if num and num > 0 then currentReachSize = num else sizeInput.Text = tostring(currentReachSize) end end)
		directionalBtn.MouseButton1Click:Connect(function() currentReachType = "directional"; directionalBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100); boxBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end)
		boxBtn.MouseButton1Click:Connect(function() currentReachType = "box"; boxBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100); directionalBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end)
		resetBtn.MouseButton1Click:Connect(resetReach)
		toggleButton.MouseButton1Click:Connect(function() contentFrame.Visible = not contentFrame.Visible; toggleButton.Text = contentFrame.Visible and "-" or "+"; mainFrame.Size = contentFrame.Visible and UDim2.fromOffset(250, 320) or UDim2.fromOffset(250, 30) end)
		local function onToolEquipped(tool)
			activeTool = tool; populatePartSelector()
			if self.State.Connections.Unequipped then self.State.Connections.Unequipped:Disconnect() end
			self.State.Connections.Unequipped = tool.Unequipped:Connect(function() activeTool = nil; populatePartSelector() end)
		end
		local function onCharacterAdded(character)
			if persistentToolName and persistentPartName then
				local function reapply(tool) if tool and tool.Name == persistentToolName then local part = tool:WaitForChild(persistentPartName, 2); if part and part:IsA("BasePart") then updatePartModification(part, currentReachSize, currentReachType); modifiedPart = part end end end
				reapply(character:FindFirstChild(persistentToolName)); self.State.Connections["Reapply"..character.Name] = character.ChildAdded:Connect(function(child) if child:IsA("Tool") then reapply(child) end end)
			end
			self.State.Connections["ToolListener"..character.Name] = character.ChildAdded:Connect(function(child) if child:IsA("Tool") then onToolEquipped(child) end end)
			local firstTool = character:FindFirstChildOfClass("Tool"); if firstTool then onToolEquipped(firstTool) end
		end
		if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
		self.State.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
		ui.Parent = CoreGui
		DoNotif("Reach Controller: ENABLED.", 2)
	end
	function Modules.ReachController:Disable()
		if not self.State.IsEnabled then return end
		self.State.IsEnabled = false
		resetReach()
		if self.State.UI and self.State.UI.Parent then self.State.UI:Destroy() end
		self.State.UI = nil
		for _, conn in pairs(self.State.Connections) do conn:Disconnect() end
		table.clear(self.State.Connections)
		DoNotif("Reach Controller: DISABLED.", 2)
	end
	function Modules.ReachController:Toggle()
		if self.State.IsEnabled then self:Disable() else self:Enable() end
	end
end
RegisterCommand({ Name = "reachgui", Aliases = { "reachcontroller" }, Description = "Toggles a GUI for advanced tool reach modification." }, function() Modules.ReachController:Toggle() end)
Modules.Reach = {
Connections = {},
State = {
IsEnabled = false,
ActiveTool = nil,
ModifiedPart = nil,
PersistentToolName = nil,
PersistentPartName = nil,
ReachType = nil,
ReachSize = nil,
UI = {
ScreenGui = nil,
Frame = nil,
ScrollingFrame = nil,
CloseButton = nil
}
}
}
local ATTRIBUTE_OG_SIZE = "OriginalSize"
local SELECTION_BOX_NAME = "ReachSelectionBox"
function Modules.Reach:_updatePartModification(part, newSize, reachType)
    if not part or not part.Parent then return end
        local originalSize = part:GetAttribute(ATTRIBUTE_OG_SIZE)
        if not newSize then
            if originalSize then
                part.Size = originalSize
                part:SetAttribute(ATTRIBUTE_OG_SIZE, nil)
            end
            if part:FindFirstChild(SELECTION_BOX_NAME) then
                part[SELECTION_BOX_NAME]:Destroy()
            end
            return
        end
        if not originalSize then
            part:SetAttribute(ATTRIBUTE_OG_SIZE, part.Size)
        end
        local selectionBox = part:FindFirstChild(SELECTION_BOX_NAME)
        if not selectionBox then
            selectionBox = Instance.new("SelectionBox", part)
            selectionBox.Name = SELECTION_BOX_NAME
            selectionBox.Adornee = part
            selectionBox.LineThickness = 0.02
        end
        selectionBox.Color3 = reachType == "box" and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 0, 0)
        if reachType == "box" then
            part.Size = Vector3.one * newSize
        else
        part.Size = Vector3.new(part.Size.X, part.Size.Y, newSize)
    end
    part.Massless = true
end
function Modules.Reach:_populatePartSelector()
    local self = Modules.Reach
    local scroll = self.State.UI.ScrollingFrame
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    if not self.State.ActiveTool then return end
        local parts = {}
        for _, descendant in ipairs(self.State.ActiveTool:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
        if #parts == 0 then
            DoNotif("Equipped tool has no physical parts.", 3)
            return
        end
        for _, part in ipairs(parts) do
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            btn.TextColor3 = Color3.fromRGB(220, 220, 230)
            btn.Font = Enum.Font.Code
            btn.Text = part.Name
            btn.TextSize = 14
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
            if not part or not part.Parent or not self.State.ActiveTool then
                self.State.UI.ScreenGui.Enabled = false
                return DoNotif("The selected part or tool no longer exists.", 3)
            end
            self.State.PersistentToolName = self.State.ActiveTool.Name
            self.State.PersistentPartName = part.Name
            if self.State.ModifiedPart and self.State.ModifiedPart ~= part then
                self:_updatePartModification(self.State.ModifiedPart)
            end
            self.State.IsEnabled = true
            self.State.ModifiedPart = part
            self:_updatePartModification(part, self.State.ReachSize, self.State.ReachType)
            self.State.UI.ScreenGui.Enabled = false
            DoNotif("Persistently set reach for " .. part.Name .. " on " .. self.State.PersistentToolName, 3)
        end)
    end
end
function Modules.Reach:_onToolEquipped(tool)
    local self = Modules.Reach
    self.State.ActiveTool = tool
    self:_populatePartSelector()
    if self.Connections.Unequipped then self.Connections.Unequipped:Disconnect() end
        self.Connections.Unequipped = tool.Unequipped:Connect(function()
        self.State.ActiveTool = nil
        self.State.UI.ScreenGui.Enabled = false
    end)
end
function Modules.Reach:_onCharacterAdded(character)
    local self = Modules.Reach
    if self.State.PersistentToolName and self.State.PersistentPartName then
        local function reapplyModification(tool)
        if tool and tool.Name == self.State.PersistentToolName then
            local part = tool:WaitForChild(self.State.PersistentPartName, 5)
            if part then
                self:_updatePartModification(part, self.State.ReachSize, self.State.ReachType)
                self.State.ModifiedPart = part
                self.State.IsEnabled = true
            end
        end
    end
    local equippedTool = character:FindFirstChild(self.State.PersistentToolName)
    reapplyModification(equippedTool)
    character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        reapplyModification(child)
    end
end)
end
character.ChildAdded:Connect(function(child)
if child:IsA("Tool") then self:_onToolEquipped(child) end
end)
local firstEquippedTool = character:FindFirstChildOfClass("Tool")
if firstEquippedTool then self:_onToolEquipped(firstEquippedTool) end
end
function Modules.Reach:Apply(reachType, size)
    local self = Modules.Reach
    if not self.State.ActiveTool then
        return DoNotif("You must have a tool equipped to select a part.", 3)
    end
    self.State.ReachType = reachType
    self.State.ReachSize = size
    self:_populatePartSelector()
    self.State.UI.ScreenGui.Enabled = true
end
function Modules.Reach:Reset()
    local self = Modules.Reach
    if not self.State.IsEnabled and not self.State.PersistentToolName then
        return DoNotif("Reach is not active and no part is set.", 3)
    end
    local tool
    if self.State.PersistentToolName then
        tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(self.State.PersistentToolName)
        if not tool then
            tool = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(self.State.PersistentToolName)
        end
    end
    if tool and self.State.PersistentPartName then
        local part = tool:FindFirstChild(self.State.PersistentPartName, true)
        if part then
            self:_updatePartModification(part)
        end
    end
    self.State.IsEnabled = false
    self.State.ModifiedPart = nil
    self.State.PersistentToolName = nil
    self.State.PersistentPartName = nil
    self.State.ReachType = nil
    self.State.ReachSize = nil
    if self.State.UI.ScreenGui then
        self.State.UI.ScreenGui.Enabled = false
    end
    DoNotif("Tool reach has been fully reset and persistence cleared.", 3)
end
function Modules.Reach:Initialize()
    local self = Modules.Reach
    local ui = Instance.new("ScreenGui")
    ui.Name = "ReachPartSelector_Persistent"
    ui.Parent = CoreGui
    ui.Enabled = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ui.ResetOnSpawn = false
    self.State.UI.ScreenGui = ui
    local frame = Instance.new("Frame", ui)
    frame.Size = UDim2.fromOffset(250, 220)
    frame.Position = UDim2.new(0.5, -125, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    self.State.UI.Frame = frame
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.Code
    title.Text = "Select a Part to Modify"
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.TextSize = 16
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.fromOffset(10, 35)
    scroll.BackgroundColor3 = frame.BackgroundColor3
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    self.State.UI.ScrollingFrame = scroll
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.fromOffset(20, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 50)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
    closeBtn.MouseButton1Click:Connect(function() ui.Enabled = false end)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    self.State.UI.CloseButton = closeBtn
    if LocalPlayer.Character then
        self:_onCharacterAdded(LocalPlayer.Character)
    end
    self.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(char)
    self:_onCharacterAdded(char)
end)
RegisterCommand({Name = "reach", Aliases = {"swordreach"}, Description = "Extends sword reach. ;reach [num]"}, function(args)
self:Apply("directional", tonumber(args[1]) or 15)
end)
RegisterCommand({Name = "boxreach", Aliases = {}, Description = "Creates a box hitbox. ;boxreach [num]"}, function(args)
self:Apply("box", tonumber(args[1]) or 15)
end)
RegisterCommand({Name = "resetreach", Aliases = {"unreach"}, Description = "Resets tool reach and clears persistent setting."}, function()
self:Reset()
end)
end
RegisterCommand({Name = "goto", Aliases = {}, Description = "Teleports to a player. ;goto [player]"}, function(args)
if not args[1] then
    return DoNotif("Specify a player's name.", 3)
end
local targetPlayer = Utilities.findPlayer(args[1])
if targetPlayer then
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localHRP and targetHRP then
        localHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        DoNotif("Teleported to " .. targetPlayer.Name, 3)
    else
    DoNotif("Target player's character could not be found.", 3)
end
else
DoNotif("Player not found.", 3)
end
end)
Modules.AdvancedFling = {
    State = {
        IsFlinging = false
    }
}
local function findFlingTargets(targetName)
    local targets = {}
    local localPlayer = Players.LocalPlayer
    local lowerTargetName = targetName and targetName:lower() or "nil"
    if not targetName or lowerTargetName == "me" then
        return { localPlayer }
    end
    if lowerTargetName == "all" then
        return Players:GetPlayers()
    end
    if lowerTargetName == "others" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer then table.insert(targets, p) end
        end
        return targets
    end
    if lowerTargetName == "random" then
        local allPlayers = Players:GetPlayers()
        if #allPlayers > 1 then
            local potentialTargets = {}
            for _, p in ipairs(allPlayers) do
                if p ~= localPlayer then table.insert(potentialTargets, p) end
            end
            if #potentialTargets > 0 then
                return { potentialTargets[math.random(1, #potentialTargets)] }
            end
        end
        return {}
    end
    if lowerTargetName == "nearest" then
        local nearestPlayer, minDist = nil, math.huge
        local localRoot = localPlayer.Character and localPlayer.Character.PrimaryPart
        if not localRoot then return {} end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer and p.Character and p.Character.PrimaryPart then
                local dist = (p.Character.PrimaryPart.Position - localRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestPlayer = p
                end
            end
        end
        if nearestPlayer then return { nearestPlayer } end
        return {}
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():match("^"..lowerTargetName) or p.DisplayName:lower():match("^"..lowerTargetName) then
            table.insert(targets, p)
        end
    end
    return targets
end
function Modules.AdvancedFling:Execute(targetPlayer)
    if self.State.IsFlinging then return DoNotif("Fling already in progress.", 2) end
    local localCharacter = LocalPlayer.Character
    local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    local localRootPart = localHumanoid and localHumanoid.RootPart
    if not (localRootPart and targetPlayer.Character) then
        return DoNotif("Cannot fling: A required character is missing.", 3)
    end
    self.State.IsFlinging = true
    local originalPosition = localRootPart.CFrame
    local originalCameraSubject = Workspace.CurrentCamera.CameraSubject
    local originalDestroyHeight = Workspace.FallenPartsDestroyHeight
    task.spawn(function()
        local success, err = pcall(function()
            local TCharacter = targetPlayer.Character
            local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
            local TRootPart = THumanoid and THumanoid.RootPart
            local THead = TCharacter and TCharacter:FindFirstChild("Head")
            local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
            local Handle = Accessory and Accessory:FindFirstChild("Handle")
            if not (TCharacter and THumanoid) then
                error("Target character or humanoid not found.")
            end
            if THumanoid.Sit then
                return DoNotif("Fling failed: Target is sitting.", 3)
            end
            if THead then
                Workspace.CurrentCamera.CameraSubject = THead
            elseif Handle then
                Workspace.CurrentCamera.CameraSubject = Handle
            elseif THumanoid then
                Workspace.CurrentCamera.CameraSubject = THumanoid
            end
            if not TCharacter:FindFirstChildWhichIsA("BasePart") then
                return
            end
            local function FPos(BasePart, Pos, Ang)
                localRootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                localCharacter:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                localRootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                localRootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            end
            local function SFBasePart(BasePart)
                local TimeToWait = 2
                local Time = tick()
                local Angle = 0
                repeat
                    if localRootPart and THumanoid and BasePart and BasePart.Parent then
                        if BasePart.Velocity.Magnitude < 50 then
                            Angle = Angle + 100
                            FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                            task.wait()
                        else
                            FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                            task.wait()
                            FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                            task.wait()
                        end
                    else
                        break
                    end
                until BasePart.Velocity.Magnitude > 500
                    or not BasePart.Parent
                    or BasePart.Parent ~= TCharacter
                    or not targetPlayer.Parent
                    or THumanoid.Sit
                    or localHumanoid.Health <= 0
                    or tick() > Time + TimeToWait
            end
            Workspace.FallenPartsDestroyHeight = 0/0
            localHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            local primaryFlingPart
            if TRootPart and THead and (TRootPart.Position - THead.Position).Magnitude > 5 then
                primaryFlingPart = THead
            elseif TRootPart then
                primaryFlingPart = TRootPart
            elseif THead then
                primaryFlingPart = THead
            elseif Handle then
                primaryFlingPart = Handle
            else
                return DoNotif("Fling failed: Target is missing critical parts.", 3)
            end
            SFBasePart(primaryFlingPart)
        end)
        pcall(function()
            localHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            Workspace.CurrentCamera.CameraSubject = localCharacter
            Workspace.FallenPartsDestroyHeight = originalDestroyHeight
            repeat
                if localRootPart and localRootPart.Parent then
                    localRootPart.CFrame = originalPosition
                    localRootPart.Velocity, localRootPart.RotVelocity = Vector3.new(), Vector3.new()
                end
                task.wait()
            until not self.State.IsFlinging or not localRootPart.Parent or (localRootPart.Position - originalPosition.Position).Magnitude < 25
        end)
        if not success then
            warn("Fling Error:", err)
            DoNotif("Fling failed. Target may have reset or left.", 3)
        else
            DoNotif("Fling sequence complete.", 2)
        end
        self.State.IsFlinging = false
    end)
end
RegisterCommand({ Name = "fling", Aliases = {"fl"}, Description = "Fling a player." }, function(args)
    local targetName = args[1]
    if not targetName then
        return DoNotif("Usage: ;fling <player|all|others|random|nearest>", 3)
    end
    local targets = findFlingTargets(targetName)
    if #targets == 0 then
        return DoNotif("No valid target found.", 3)
    end
    if #targets > 1 then
        DoNotif("Flinging multiple targets...", 2)
    else
        DoNotif("Target found: " .. targets[1].Name, 2)
    end
    for _, targetPlayer in ipairs(targets) do
        if targetPlayer ~= LocalPlayer then
            Modules.AdvancedFling:Execute(targetPlayer)
            task.wait(0.1)
        end
    end
end)
Modules.SetSpawnPoint = {
State = {
CustomSpawnCFrame = nil,
CharacterAddedConnection = nil
}
}
function Modules.SetSpawnPoint:OnCharacterAdded(newCharacter)
    if not self.State.CustomSpawnCFrame then return end
        local rootPart = newCharacter:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            task.wait()
            rootPart.CFrame = self.State.CustomSpawnCFrame
        end
    end
    RegisterCommand({
    Name = "setspawnpoint",
    Aliases = {"setspawn", "ssp"},
    Description = "Sets your respawn point to your current location. Use 'clear' to reset."
    }, function(args)
    local localPlayer = Players.LocalPlayer
    local commandArg = args[1] and string.lower(args[1])
    if commandArg == "clear" or commandArg == "reset" then
        if Modules.SetSpawnPoint.State.CustomSpawnCFrame then
            Modules.SetSpawnPoint.State.CustomSpawnCFrame = nil
            print("Custom spawn point cleared. You will now use the default spawn.")
            if Modules.SetSpawnPoint.State.CharacterAddedConnection then
                Modules.SetSpawnPoint.State.CharacterAddedConnection:Disconnect()
                Modules.SetSpawnPoint.State.CharacterAddedConnection = nil
            end
        else
        print("No custom spawn point was set.")
    end
    return
end
local character = localPlayer and localPlayer.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
if not rootPart then
    print("Error: Could not set spawn point. Player character not found.")
    return
end
Modules.SetSpawnPoint.State.CustomSpawnCFrame = rootPart.CFrame
print("Custom spawn point set at: " .. tostring(rootPart.Position))
if not Modules.SetSpawnPoint.State.CharacterAddedConnection then
    Modules.SetSpawnPoint.State.CharacterAddedConnection = localPlayer.CharacterAdded:Connect(function(char)
    Modules.SetSpawnPoint:OnCharacterAdded(char)
end)
end
end)
Modules.NoclipStabilizer = {
State = {
Enabled = false,
Connection = nil
}
}
function Modules.NoclipStabilizer:_OnStepped()
    local character = Players.LocalPlayer and Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end
function Modules.NoclipStabilizer:Enable()
    if self.State.Enabled then return end
        self.State.Enabled = true
        self.State.Connection = RunService.Stepped:Connect(function()
        self:_OnStepped()
    end)
    DoNotif("Noclip Stabilizer: [Enabled]", 3)
end
function Modules.NoclipStabilizer:Disable()
    if not self.State.Enabled then return end
        self.State.Enabled = false
        if self.State.Connection then
            self.State.Connection:Disconnect()
            self.State.Connection = nil
        end
        DoNotif("Noclip Stabilizer: [Disabled]", 3)
    end
    RegisterCommand({
    Name = "antirubberband",
    Aliases = {"antirb", "arb"},
    Description = "Toggles the Noclip Stabilizer to prevent server-side rubberbanding."
    }, function(args)
    if Modules.NoclipStabilizer.State.Enabled then
        Modules.NoclipStabilizer:Disable()
    else
    Modules.NoclipStabilizer:Enable()
end
end)
Modules.AntiReset = {
    State = {
        IsEnabled = false,
        CharacterConnections = {}
    }
}
function Modules.AntiReset:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local function applyAntiReset(character)
        if not character then return end
        local humanoid = character:WaitForChild("Humanoid", 2)
        local hrp = character:WaitForChild("HumanoidRootPart", 2)
        if not (humanoid and hrp) then return end
        for _, connection in pairs(self.State.CharacterConnections) do
            if connection then connection:Disconnect() end
        end
        table.clear(self.State.CharacterConnections)
        local isResetting = false
        self.State.CharacterConnections.HealthChanged = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 and not isResetting then
                isResetting = true
                humanoid.Health = humanoid.MaxHealth
                isResetting = false
            end
        end)
        local lastSafePosition = hrp.Position
        local fallenPartsHeight = Workspace.FallenPartsDestroyHeight
        self.State.CharacterConnections.Heartbeat = RunService.Heartbeat:Connect(function()
            if not hrp or not hrp.Parent then return end
            if hrp.Position.Y < fallenPartsHeight then
                hrp.CFrame = CFrame.new(lastSafePosition)
                hrp.Velocity = Vector3.new(0, 0, 0)
            elseif humanoid.FloorMaterial ~= Enum.Material.Air then
                lastSafePosition = hrp.Position
            end
        end)
    end
    if LocalPlayer.Character then
        applyAntiReset(LocalPlayer.Character)
    end
    self.State.CharacterConnections.Added = LocalPlayer.CharacterAdded:Connect(applyAntiReset)
    DoNotif("Anti-Reset: ENABLED.", 2)
end
function Modules.AntiReset:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for _, connection in pairs(self.State.CharacterConnections) do
        if connection then connection:Disconnect() end
    end
    table.clear(self.State.CharacterConnections)
    DoNotif("Anti-Reset: DISABLED.", 2)
end
function Modules.AntiReset:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
Modules.NetCommander = {
    State = {
        PinnedRemote = nil,
        PinnedPath = "",
        LastResult = nil
    },
    Dependencies = {"HttpService", "ReplicatedStorage"}
}
function Modules.NetCommander:_resolvePath(path)
    if not path or path == "" then return nil end
    local current = game
    path = path:gsub("^RS%.", "ReplicatedStorage.")
    path = path:gsub("^WS%.", "Workspace.")
    path = path:gsub("^game%.", "")
    path = path:gsub("^Workspace%.", "workspace.")
    local serviceName = path:match("^:GetService%(['\"](.+)['\"]%)")
    if serviceName then
        local success, service = pcall(game.GetService, game, serviceName)
        if success and service then
            current = service
            path = path:gsub("^:GetService%(['\"](.+)['\"]%)%.?", "")
        end
    end
    if path == "" then return current end
    for segment in string.gmatch(path, "([^%.]+)") do
        if current then
            local found = current:FindFirstChild(segment)
            if not found then
                local midService = segment:match("GetService%(['\"](.+)['\"]%)")
                if midService then
                    current = game:GetService(midService)
                else
                    current = nil
                    break
                end
            else
                current = found
            end
        end
    end
    return current
end
function Modules.NetCommander:_parseArgs(argsTable)
    local processed = {}
    for _, arg in ipairs(argsTable) do
        local lower = arg:lower()
        if tonumber(arg) then
            table.insert(processed, tonumber(arg))
        elseif lower == "true" then
            table.insert(processed, true)
        elseif lower == "false" then
            table.insert(processed, false)
        elseif lower == "nil" then
            table.insert(processed, nil)
        elseif arg:sub(1,1) == "{" and arg:sub(-1,-1) == "}" then
            local success, tbl = pcall(function()
                return game:GetService("HttpService"):JSONDecode(arg)
            end)
            table.insert(processed, success and tbl or arg)
        elseif lower == "me" or lower == "localplayer" then
            table.insert(processed, game:GetService("Players").LocalPlayer)
        else
            table.insert(processed, arg)
        end
    end
    return processed
end
function Modules.NetCommander:Execute(pathArray, isInvoke)
    local target = nil
    local remainingArgs = {}
    local resolvedPath = ""
    for i = 1, #pathArray do
        local testPath = table.concat(pathArray, " ", 1, i)
        local result = self:_resolvePath(testPath)
        if result then
            target = result
            resolvedPath = testPath
            remainingArgs = {}
            for j = i + 1, #pathArray do
                table.insert(remainingArgs, pathArray[j])
            end
        end
    end
    if not target then
        return DoNotif("Target not found: " .. table.concat(pathArray, " "), 3)
    end
    local cleanArgs = self:_parseArgs(remainingArgs)
    if target:IsA("RemoteEvent") then
        local success, err = pcall(function() target:FireServer(unpack(cleanArgs)) end)
        if success then
            DoNotif("Fired Event: " .. target.Name, 2)
        else
            warn("--> [NET]: FireServer Error:", err)
            DoNotif("FireServer Failed. Check F9.", 3)
        end
    elseif target:IsA("RemoteFunction") then
        DoNotif("Invoking Function...", 1.5)
        task.spawn(function()
            local success, result = pcall(function() return target:InvokeServer(unpack(cleanArgs)) end)
            if success then
                print("--> [NET]: Invoke Result for " .. target.Name .. ":", result)
                self.State.LastResult = result
                DoNotif("Invoke Success. Result in F9.", 3)
            else
                warn("--> [NET]: Invoke Failed:", result)
                DoNotif("Invoke FAILED.", 3)
            end
        end)
    else
        DoNotif("Error: '" .. target.Name .. "' is a " .. target.ClassName .. " (Not a Remote).", 3)
    end
end
function Modules.NetCommander:Initialize()
    local module = self
    module.Services = {
        HttpService = game:GetService("HttpService"),
        Players = game:GetService("Players")
    }
    RegisterCommand({
        Name = "fire",
        Aliases = {"fremote", "rf"},
        Description = "Fires a RemoteEvent. Handles paths with spaces."
    }, function(args)
        if #args < 1 then return DoNotif("Usage: ;fire [Path] [Args]", 3) end
        module:Execute(args, false)
    end)
    RegisterCommand({
        Name = "invoke",
        Aliases = {"inv", "rfcall"},
        Description = "Invokes a RemoteFunction. Handles paths with spaces."
    }, function(args)
        if #args < 1 then return DoNotif("Usage: ;inv [Path] [Args]", 3) end
        module:Execute(args, true)
    end)
    RegisterCommand({
        Name = "pin",
        Aliases = {"mark"},
        Description = "Pins a remote path."
    }, function(args)
        if not args[1] then return DoNotif("Usage: ;pin [Path]", 3) end
        module.State.PinnedPath = table.concat(args, " ")
        DoNotif("Pinned: " .. module.State.PinnedPath, 2)
    end)
    RegisterCommand({
        Name = "runpin",
        Aliases = {"r"},
        Description = "Runs the pinned remote."
    }, function(args)
        if module.State.PinnedPath == "" then return DoNotif("No remote pinned.", 3) end
        local combinedArgs = {}
        for part in string.gmatch(module.State.PinnedPath, "%S+") do
            table.insert(combinedArgs, part)
        end
        for _, arg in ipairs(args) do
            table.insert(combinedArgs, arg)
        end
        module:Execute(combinedArgs, false)
    end)
end
RegisterCommand({
    Name = "antireset",
    Aliases = {"noreset", "ar"},
    Description = "Toggles a system that prevents your character from resetting."
}, function()
    Modules.AntiReset:Toggle()
end)
Modules.AntiCFrameTeleport = {
MAX_SPEED = 70,
MAX_STEP_DIST = 8,
REPEAT_THRESHOLD = 3,
LOCK_TIME = 0.1,
State = {
Enabled = false,
HeartbeatConnection = nil,
CharacterAddedConnection = nil,
LastCFrame = nil,
LastTimestamp = 0,
DetectionHits = 0
}
}
function Modules.AntiCFrameTeleport:_zeroVelocity(character)
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.AssemblyLinearVelocity = Vector3.zero
            descendant.AssemblyAngularVelocity = Vector3.zero
        end
    end
end
function Modules.AntiCFrameTeleport:_getFlyAllowances(deltaTime)
    local maxSpeed, maxDist = self.MAX_SPEED, self.MAX_STEP_DIST
    if not (getfenv(0).NAmanage and NAmanage._state and getfenv(0).FLYING) then
        return maxSpeed, maxDist
    end
    local mode = NAmanage._state.mode or "none"
    local flyVars = getfenv(0).flyVariables or {}
    if mode == "fly" then
        local speed = tonumber(flyVars.flySpeed) or 1
        local velocity = speed * 50
        maxSpeed = math.max(maxSpeed, velocity * 1.4)
        maxDist = math.max(maxDist, velocity * deltaTime * 3)
    elseif mode == "vfly" then
        local speed = tonumber(flyVars.vFlySpeed) or 1
        local velocity = speed * 50
        maxSpeed = math.max(maxSpeed, velocity * 1.4)
        maxDist = math.max(maxDist, velocity * deltaTime * 3)
    elseif mode == "cfly" then
        local speed = tonumber(flyVars.cFlySpeed) or 1
        local step = speed * 2
        maxDist = math.max(self.MAX_STEP_DIST, step)
        maxSpeed = math.max(self.MAX_SPEED, (maxDist / deltaTime) * 1.25)
    elseif mode == "tfly" then
        local speed = tonumber(flyVars.TflySpeed) or 1
        local step = speed * 2.5
        maxDist = math.max(self.MAX_STEP_DIST, step)
        maxSpeed = math.max(self.MAX_SPEED, (maxDist / deltaTime) * 1.5)
    end
    return maxSpeed, maxDist
end
function Modules.AntiCFrameTeleport:_onCharacterAdded(character)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if rootPart then
        self.State.LastCFrame = rootPart.CFrame
        self.State.LastTimestamp = os.clock()
        self.State.DetectionHits = 0
    end
end
function Modules.AntiCFrameTeleport:_onHeartbeat()
    local character = Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
        local now = os.clock()
        local deltaTime = math.max(now - (self.State.LastTimestamp or now), 1/240)
        local currentCFrame = rootPart.CFrame
        if not self.State.LastCFrame then
            self.State.LastCFrame, self.State.LastTimestamp = currentCFrame, now
            return
        end
        local distance = (currentCFrame.Position - self.State.LastCFrame.Position).Magnitude
        local speed = distance / deltaTime
        local maxAllowedSpeed, maxAllowedDistance = self:_getFlyAllowances(deltaTime)
        if distance > maxAllowedDistance or speed > maxAllowedSpeed then
            character:PivotTo(self.State.LastCFrame)
            self:_zeroVelocity(character)
            self.State.DetectionHits += 1
            if self.State.DetectionHits >= self.REPEAT_THRESHOLD then
                task.delay(self.LOCK_TIME, function()
                self.State.DetectionHits = 0
            end)
        end
    else
    self.State.DetectionHits = math.max(self.State.DetectionHits - 1, 0)
    self.State.LastCFrame = currentCFrame
end
self.State.LastTimestamp = now
end
function Modules.AntiCFrameTeleport:Enable()
    if self.State.Enabled then return end
        self.State.Enabled = true
        if Players.LocalPlayer.Character then
            self:_onCharacterAdded(Players.LocalPlayer.Character)
        end
        self.State.CharacterAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(char)
        self:_onCharacterAdded(char)
    end)
    self.State.HeartbeatConnection = RunService.Heartbeat:Connect(function()
    self:_onHeartbeat()
end)
DoNotif("Anti-CFrame Teleport: [Enabled]", 3)
end
function Modules.AntiCFrameTeleport:Disable()
    if not self.State.Enabled then return end
        self.State.Enabled = false
        if self.State.HeartbeatConnection then
            self.State.HeartbeatConnection:Disconnect()
            self.State.HeartbeatConnection = nil
        end
        if self.State.CharacterAddedConnection then
            self.State.CharacterAddedConnection:Disconnect()
            self.State.CharacterAddedConnection = nil
        end
        self.State.LastCFrame = nil
        self.State.LastTimestamp = 0
        self.State.DetectionHits = 0
        DoNotif("Anti-CFrame Teleport: [Disabled]", 3)
    end
    RegisterCommand({
    Name = "anticframetp",
    Aliases = {"acftp", "antiteleport"},
    Description = "Toggles a client-side anti-teleport to prevent CFrame changes."
    }, function(args)
    if Modules.AntiCFrameTeleport.State.Enabled then
        Modules.AntiCFrameTeleport:Disable()
    else
    Modules.AntiCFrameTeleport:Enable()
end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
Modules.FireRemotes = {
State = {
Enabled = false,
},
}
function Modules.FireRemotes:Initialize()
    RegisterCommand({
    Name = "fireremotes",
    Aliases = {"fremotes", "frem"},
    Description = "Attempts to fire every discoverable RemoteEvent and RemoteFunction."
    }, function(args)
    local CoreGui = game:GetService("CoreGui")
    local remoteCount = 0
    local failedCount = 0
    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not obj:IsDescendantOf(CoreGui) then
            task.spawn(function()
            local success, err
            if obj:IsA("RemoteEvent") then
                success, err = pcall(function()
                obj:FireServer()
            end)
        elseif obj:IsA("RemoteFunction") then
            success, err = pcall(function()
            obj:InvokeServer()
        end)
    end
    if success then
        remoteCount = remoteCount + 1
    else
    failedCount = failedCount + 1
end
end)
end
end
task.delay(2, function()
DoNotif("Fired " .. remoteCount .. " remotes.\nFailed: " .. failedCount .. " remotes.")
end)
end)
end
Modules.RemoveForces = {
State = {},
}
function Modules.RemoveForces:Initialize()
    RegisterCommand({
    Name = "deletevelocity",
    Aliases = {"dv", "removevelocity", "removeforces"},
    Description = "Removes all force/velocity instances from your character to counter flings or fix physics glitches."
    }, function(args)
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then
        return DoNotif("Character not found.", 3)
    end
    local forcesRemoved = 0
    for _, instance in ipairs(character:GetDescendants()) do
        if  instance:isA("BodyVelocity") or
            instance:isA("BodyGyro") or
            instance:isA("RocketPropulsion") or
            instance:isA("BodyAngularVelocity") or
            instance:isA("BodyForce") or
            instance:isA("BodyThrust") or
            instance:isA("VectorForce") or
            instance:isA("LineForce") or
            instance:isA("AngularVelocity")
            then
                instance:Destroy()
                forcesRemoved = forcesRemoved + 1
            end
        end
        DoNotif("Removed " .. forcesRemoved .. " force instances from your character.", 3)
    end)
end
Modules.TeleportToPlace = {
State = {},
}
function Modules.TeleportToPlace:Initialize()
    RegisterCommand({
    Name = "teleporttoplace",
    Aliases = {"toplace", "ttp"},
    Description = "Teleports you to a specific Roblox place using its ID."
    }, function(args)
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    if not args[1] then
        return DoNotif("Usage: teleporttoplace [PlaceId]", 5)
    end
    local placeId = tonumber(args[1])
    if not placeId then
        return DoNotif("Invalid PlaceId. It must be a number.", 5)
    end
    DoNotif("Attempting to teleport to " .. placeId .. "...", 3)
    local success, result = pcall(function()
    TeleportService:Teleport(placeId, localPlayer)
end)
if not success then
    DoNotif("Teleport failed: " .. tostring(result), 5)
end
end)
end
Modules.ToSpawn = {
State = {
Enabled = false,
},
}
function Modules.ToSpawn:Initialize()
    RegisterCommand({
    Name = "tospawn",
    Aliases = {"ts"},
    Description = "Teleports you to the nearest SpawnLocation."
    }, function(args)
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local localPlayer = Players.LocalPlayer
    local character = localPlayer.Character
    if not character then
        return DoNotif("Character not found.", 3)
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return DoNotif("HumanoidRootPart not found.", 3)
    end
    local closestSpawn = nil
    local shortestDistance = math.huge
    local rootPosition = root.Position
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("SpawnLocation") then
            local distance = (part.Position - rootPosition).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestSpawn = part
            end
        end
    end
    if closestSpawn then
        root.CFrame = closestSpawn.CFrame * CFrame.new(0, 3, 0)
    else
    return DoNotif("No SpawnLocation found in workspace.", 3)
end
end)
end
Modules.TriggerRemoteTouch = {
    State = {
        IsExecuting = false,
        FoundParts = {}
    },
    Services = {
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        RunService = game:GetService("RunService")
    }
}
function Modules.TriggerRemoteTouch:_triggerPart(targetPart)
    if not targetPart then return end
    local hrp = self.Services.Players.LocalPlayer.Character and self.Services.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    DoNotif("Triggering: " .. targetPart:GetFullName(), 1)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, targetPart, 0)
            self.Services.RunService.Heartbeat:Wait()
            firetouchinterest(hrp, targetPart, 1)
        end)
    else
        warn("TriggerRemoteTouch: 'firetouchinterest' not found. Using CFrame fallback.")
        local originalCFrame = hrp.CFrame
        pcall(function()
            hrp.CFrame = targetPart.CFrame
            self.Services.RunService.Heartbeat:Wait()
            hrp.CFrame = originalCFrame
        end)
    end
end
function Modules.TriggerRemoteTouch:Scan()
    if self.State.IsExecuting then return DoNotif("An operation is already in progress.", 2) end
    self.State.IsExecuting = true
    DoNotif("Scanning for all touch-interactive parts...", 3)
    task.spawn(function()
        table.clear(self.State.FoundParts)
        local count = 0
        for i, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
            if descendant:IsA("TouchInterest") then
                local part = descendant.Parent
                if part and part:IsA("BasePart") then
                    table.insert(self.State.FoundParts, part)
                    count = count + 1
                end
            end
            if i % 200 == 0 then task.wait() end
        end
        DoNotif("Scan complete. Found " .. count .. " interactive parts.", 3)
        self.State.IsExecuting = false
    end)
end
function Modules.TriggerRemoteTouch:TriggerAll()
    if self.State.IsExecuting then return DoNotif("An operation is already in progress.", 2) end
    if #self.State.FoundParts == 0 then
        return DoNotif("No parts found. Run ';touch scan' first.", 3)
    end
    self.State.IsExecuting = true
    DoNotif("Beginning sequence to trigger all " .. #self.State.FoundParts .. " parts.", 3)
    task.spawn(function()
        for _, part in ipairs(self.State.FoundParts) do
            if not self.State.IsExecuting then break end
            self:_triggerPart(part)
            task.wait(0.5)
        end
        DoNotif("Trigger sequence finished.", 2)
        self.State.IsExecuting = false
    end)
end
function Modules.TriggerRemoteTouch:TriggerSingle(keyword)
    if not keyword then return DoNotif("Usage: ;touch single <keyword>", 3) end
    if self.State.IsExecuting then return DoNotif("An operation is already in progress.", 2) end
    if #self.State.FoundParts == 0 then
        return DoNotif("No parts found. Run ';touch scan' first.", 3)
    end
    local lowerKeyword = keyword:lower()
    for _, part in ipairs(self.State.FoundParts) do
        if part:GetFullName():lower():find(lowerKeyword, 1, true) then
            self:_triggerPart(part)
            return
        end
    end
    DoNotif("No scanned part found matching '" .. keyword .. "'.", 3)
end
function Modules.TriggerRemoteTouch:Initialize()
    local module = self
    RegisterCommand({
        Name = "touch",
        Aliases = {"remotetouch", "trigger"},
        Description = "Scans and triggers touch-interest parts."
    }, function(args)
        local subCommand = args[1] and args[1]:lower()
        if subCommand == "scan" then
            module:Scan()
        elseif subCommand == "all" then
            module:TriggerAll()
        elseif subCommand == "single" then
            module:TriggerSingle(args[2])
        else
            DoNotif("Usage: ;touch <scan|all|single> [keyword]", 4)
        end
    end)
end
Modules.ScriptHunter = {
    State = {
        IsScanning = false
    }
}
function Modules.ScriptHunter:Execute(keywords)
    local self = Modules.ScriptHunter
    if self.State.IsScanning then return DoNotif("A script scan is already in progress.", 2) end
    if not keywords or #keywords == 0 then return DoNotif("Usage: ;huntscript <keyword1> [keyword2] ...", 3) end
    self.State.IsScanning = true
    DoNotif("Beginning script hunt for keywords: " .. table.concat(keywords, ", "), 3)
    task.spawn(function()
        local findings = {}
        local scriptsScanned = 0
        for _, script in ipairs(game:GetDescendants()) do
            if script:IsA("LuaSourceContainer") then
                local success, source = pcall(function() return script.Source end)
                if success and source then
                    scriptsScanned = scriptsScanned + 1
                    local lowerSource = source:lower()
                    local allKeywordsFound = true
                    for _, keyword in ipairs(keywords) do
                        if not lowerSource:find(keyword:lower(), 1, true) then
                            allKeywordsFound = false
                            break
                        end
                    end
                    if allKeywordsFound then
                        table.insert(findings, script:GetFullName())
                    end
                end
            end
            if scriptsScanned % 100 == 0 then task.wait() end
        end
        if #findings > 0 then
            DoNotif("Scan complete. Found " .. #findings .. " matching script(s). Results printed to console (F9).", 4)
            print("--- [Zuka's ScriptHunter Report] ---")
            for _, path in ipairs(findings) do
                print("  [!] Match Found: " .. path)
            end
            print("--------------------------------------")
        else
            DoNotif("Scan complete. No scripts found containing all specified keywords.", 3)
        end
        self.State.IsScanning = false
    end)
end
function Modules.ScriptHunter:Initialize()
    local module = self
    RegisterCommand({
        Name = "huntscript",
        Aliases = {"findscript", "scripthunt"},
        Description = "Scans all client scripts for keywords."
    }, function(args)
        module:Execute(args)
    end)
end
local ContextActionService = game:GetService("ContextActionService")
Modules.AdvancedAirwalk = {
    State = {
        IsEnabled = false,
        AirwalkPart = nil,
        RenderConnection = nil,
        Connections = {},
        GUIs = {},
        IsTyping = false,
        Increase = false,
        Decrease = false,
        Offset = 0,
        LastValidRoot = nil,
        SmoothOffset = 0
    },
    Config = {
        VerticalSpeed = 1.75,
        SmoothSpeed = 0.15,
        Keybinds = {
            Increase = Enum.KeyCode.Space,
            Decrease = Enum.KeyCode.LeftControl
        },
        DisableOnDeath = false,
        ShowPlatform = false
    },
    Services = {
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        CoreGui = game:GetService("CoreGui")
    }
}
function Modules.AdvancedAirwalk:Disable()
    if not self.State.IsEnabled then
        return
    end
    if self.State.RenderConnection then
        self.State.RenderConnection:Disconnect()
        self.State.RenderConnection = nil
    end
    if self.State.AirwalkPart and self.State.AirwalkPart.Parent then
        self.State.AirwalkPart:Destroy()
    end
    self.State.AirwalkPart = nil
    for key, conn in pairs(self.State.Connections) do
        if conn then
            conn:Disconnect()
        end
        self.State.Connections[key] = nil
    end
    for key, gui in pairs(self.State.GUIs) do
        if gui and gui.Parent then
            gui:Destroy()
        end
        self.State.GUIs[key] = nil
    end
    self.State.IsEnabled = false
    self.State.IsTyping = false
    self.State.Increase = false
    self.State.Decrease = false
    self.State.Offset = 0
    self.State.SmoothOffset = 0
    self.State.LastValidRoot = nil
    DoNotif("Advanced Airwalk: OFF", 2)
end
function Modules.AdvancedAirwalk:Enable()
    if self.State.IsEnabled then
        self:Disable()
    end
    self.State.IsEnabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    local uis = self.Services.UserInputService
    local isMobile = uis.TouchEnabled
    DoNotif(isMobile and "Advanced Airwalk: ON" or "Advanced Airwalk: ON (Space & LCtrl)", 2)
    local function createMobileButton(parent, text, position, callbackDown, callbackUp)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.Position = position
        button.Size = UDim2.new(0.08, 0, 0.12, 0)
        button.Font = Enum.Font.SourceSansBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        Instance.new("UICorner", button).CornerRadius = UDim.new(0.2, 0)
        local stroke = Instance.new("UIStroke", button)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1.5
        button.MouseButton1Down:Connect(callbackDown)
        button.MouseButton1Up:Connect(callbackUp)
        button.TouchTap:Connect(callbackDown)
        button.TouchEnded:Connect(callbackUp)
        return button
    end
    if isMobile then
        local mobileGui = Instance.new("ScreenGui", self.Services.CoreGui)
        mobileGui.Name = "AdvancedAirwalkMobileControls"
        mobileGui.ResetOnSpawn = false
        self.State.GUIs.MobileControls = mobileGui
        createMobileButton(mobileGui, "UP", UDim2.new(0.9, 0, 0.55, 0),
            function() self.State.Increase = true end,
            function() self.State.Increase = false end)
        createMobileButton(mobileGui, "DOWN", UDim2.new(0.9, 0, 0.7, 0),
            function() self.State.Decrease = true end,
            function() self.State.Decrease = false end)
    else
        self.State.Connections.Focused = uis.TextBoxFocused:Connect(function() self.State.IsTyping = true end)
        self.State.Connections.Released = uis.TextBoxFocusReleased:Connect(function() self.State.IsTyping = false end)
        self.State.Connections.InputBegan = uis.InputBegan:Connect(function(input, gpe)
            if gpe or self.State.IsTyping then return end
            if input.KeyCode == self.Config.Keybinds.Increase then self.State.Increase = true end
            if input.KeyCode == self.Config.Keybinds.Decrease then self.State.Decrease = true end
        end)
        self.State.Connections.InputEnded = uis.InputEnded:Connect(function(input)
            if input.KeyCode == self.Config.Keybinds.Increase then self.State.Increase = false end
            if input.KeyCode == self.Config.Keybinds.Decrease then self.State.Decrease = false end
        end)
    end
    local awPart = Instance.new("Part")
    awPart.Name = "Zuka_AirwalkPart"
    awPart.Size = Vector3.new(8, 1.5, 8)
    awPart.Transparency = self.Config.ShowPlatform and 0.7 or 1
    awPart.Anchored = true
    awPart.CanCollide = true
    awPart.CanQuery = false
    awPart.Parent = self.Services.Workspace
    if self.Config.ShowPlatform then
        awPart.Color = Color3.fromRGB(100, 150, 255)
        awPart.Material = Enum.Material.Neon
    end
    self.State.AirwalkPart = awPart
    if not self.Config.DisableOnDeath then
        self.State.Connections.CharacterAdded = localPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            self.State.Offset = 0
            self.State.SmoothOffset = 0
        end)
    end
    self.State.RenderConnection = self.Services.RunService.RenderStepped:Connect(function(deltaTime)
        if not self.State.IsEnabled then
            self:Disable()
            return
        end
        if not (self.State.AirwalkPart and self.State.AirwalkPart.Parent) then
            self:Disable()
            return
        end
        local success, char, root, hum = pcall(function()
            local c = localPlayer.Character
            return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
        end)
        if not (success and char and root and hum) then
            if self.State.LastValidRoot then
                self.State.AirwalkPart.CanCollide = false
            else
                if self.Config.DisableOnDeath then
                    self:Disable()
                else
                    self.State.AirwalkPart.CanCollide = false
                end
            end
            return
        end
        if hum.Health <= 0 then
            if self.Config.DisableOnDeath then
                self:Disable()
            else
                self.State.AirwalkPart.CanCollide = false
            end
            return
        end
        self.State.AirwalkPart.CanCollide = true
        self.State.LastValidRoot = root.Position
        local hrpHalf = root.Size.Y * 0.5
        local feetFromRoot
        if hum.RigType == Enum.HumanoidRigType.R6 then
            feetFromRoot = hrpHalf + (hum.HipHeight > 0 and hum.HipHeight or 2)
        else
            feetFromRoot = hrpHalf + (hum.HipHeight or 2)
        end
        local baseOffset = feetFromRoot + (self.State.AirwalkPart.Size.Y * 0.5)
        local delta = 0
        if self.State.Increase then delta = -self.Config.VerticalSpeed end
        if self.State.Decrease then delta = self.Config.VerticalSpeed end
        self.State.Offset = self.State.Offset + delta
        self.State.SmoothOffset = self.State.SmoothOffset + (self.State.Offset - self.State.SmoothOffset) * self.Config.SmoothSpeed
        local newY = root.Position.Y - baseOffset - self.State.SmoothOffset
        self.State.AirwalkPart.CFrame = CFrame.new(root.Position.X, newY, root.Position.Z)
    end)
end
RegisterCommand({
    Name = "airwalk",
    Aliases = {"float", "aw"},
    Description = "Toggles an advanced airwalk. Use Space/LCtrl or GUI to move."
}, function()
    if Modules.AdvancedAirwalk.State.IsEnabled then
        Modules.AdvancedAirwalk:Disable()
    else
        Modules.AdvancedAirwalk:Enable()
    end
end)
RegisterCommand({
    Name = "unairwalk",
    Aliases = {"unfloat", "unaw"},
    Description = "Explicitly disables the advanced airwalk."
}, function()
    Modules.AdvancedAirwalk:Disable()
end)
RegisterCommand({
    Name = "airwalkplatform",
    Aliases = {"awplatform"},
    Description = "Toggles visibility of the airwalk platform."
}, function()
    Modules.AdvancedAirwalk.Config.ShowPlatform = not Modules.AdvancedAirwalk.Config.ShowPlatform
    if Modules.AdvancedAirwalk.State.AirwalkPart then
        local part = Modules.AdvancedAirwalk.State.AirwalkPart
        part.Transparency = Modules.AdvancedAirwalk.Config.ShowPlatform and 0.7 or 1
        if Modules.AdvancedAirwalk.Config.ShowPlatform then
            part.Color = Color3.fromRGB(100, 150, 255)
            part.Material = Enum.Material.Neon
        end
    end
    DoNotif("Platform Visibility: " .. (Modules.AdvancedAirwalk.Config.ShowPlatform and "ON" or "OFF"), 2)
end)
RegisterCommand({
    Name = "airwalkreset",
    Aliases = {"awreset"},
    Description = "Resets airwalk offset to ground level."
}, function()
    Modules.AdvancedAirwalk.State.Offset = 0
    Modules.AdvancedAirwalk.State.SmoothOffset = 0
    DoNotif("Airwalk offset reset", 2)
end)
Modules.VoidShield = {
    State = {
        IsEnabled = false,
        ShieldPart = nil,
        CharacterAddedConn = nil,
        ToolConn = nil
    },
    Config = {
        Size = Vector3.new(12, 12, 1),
        Distance = 5,
        Transparency = 0.5,
        Color = Color3.fromRGB(0, 255, 255),
        Material = Enum.Material.ForceField,
    }
}
function Modules.VoidShield:_applyNoCollision(part)
    local character = LocalPlayer.Character
    if not character or not part then return end
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("BasePart") then
            local constraint = Instance.new("NoCollisionConstraint")
            constraint.Part0 = part
            constraint.Part1 = v
            constraint.Parent = part
        end
    end
end
function Modules.VoidShield:_createShield()
    if self.State.ShieldPart then self.State.ShieldPart:Destroy() end
    local part = Instance.new("Part")
    part.Name = "Callum_ShieldWall"
    part.Size = self.Config.Size
    part.Transparency = self.Config.Transparency
    part.Color = self.Config.Color
    part.Material = self.Config.Material
    part.CanCollide = true
    part.CanQuery = true
    part.Anchored = true
    part.CastShadow = false
    part.Massless = true
    self:_applyNoCollision(part)
    if LocalPlayer.Character then
        if self.State.ToolConn then self.State.ToolConn:Disconnect() end
        self.State.ToolConn = LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and self.State.ShieldPart then
                task.wait()
                self:_applyNoCollision(self.State.ShieldPart)
            end
        end)
    end
    part.Parent = Workspace
    self.State.ShieldPart = part
    self:_updatePosition()
end
function Modules.VoidShield:_updatePosition()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not self.State.ShieldPart then return end
    local targetCF = root.CFrame * CFrame.new(0, 0, -self.Config.Distance)
    self.State.ShieldPart.CFrame = targetCF
end
function Modules.VoidShield:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self:_createShield()
    self.State.CharacterAddedConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if self.State.IsEnabled then self:_createShield() end
    end)
    if typeof(DoNotif) == "function" then DoNotif("Shield Wall: [ACTIVE]", 2) end
end
function Modules.VoidShield:Disable()
    self.State.IsEnabled = false
    if self.State.CharacterAddedConn then self.State.CharacterAddedConn:Disconnect() end
    if self.State.ToolConn then self.State.ToolConn:Disconnect() end
    if self.State.ShieldPart then self.State.ShieldPart:Destroy(); self.State.ShieldPart = nil end
    if typeof(DoNotif) == "function" then DoNotif("Shield Wall: [DISABLED]", 2) end
end
function Modules.VoidShield:Toggle()
    if self.State.IsEnabled then self:Disable() else self:Enable() end
end
function Modules.VoidShield:Initialize()
    if typeof(RegisterCommand) == "function" then
        RegisterCommand({Name = "cshield", Aliases = {"clientshield"}}, function(args)
            local sizeVal = tonumber(args[1])
            if sizeVal then
                self.Config.Size = Vector3.new(sizeVal, sizeVal, 1)
                if self.State.ShieldPart then self.State.ShieldPart.Size = self.Config.Size end
            end
            self:Toggle()
        end)
    end
end
Modules.Blackhole = {
    State = {
        IsEnabled = false,
        IsForceActive = false,
        TargetCFrame = CFrame.new(),
        BlackholePart = nil,
        BlackholeAttachment = nil,
        Connections = {},
        UI = {}
    },
    Config = {
        ForceResponsiveness = 200,
        TorqueMagnitude = 100000,
        MoveKey = Enum.KeyCode.E,
        MoverName = "Zuka_BlackholeMover"
    },
    Dependencies = {"RunService", "UserInputService", "Players", "Workspace", "CoreGui"},
    Services = {}
}
function Modules.Blackhole:_cleanupForces()
    for _, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
        if descendant.Name == self.Config.MoverName and descendant:IsA("Instance") then
            descendant:Destroy()
        end
        if descendant:IsA("BasePart") and not descendant.CanCollide then
            pcall(function() descendant.CanCollide = true end)
        end
    end
end
function Modules.Blackhole:_applyForce(part)
    if not self.State.IsForceActive or not (part and part:IsA("BasePart")) then return end
    if part.Anchored or part:FindFirstAncestorOfClass("Humanoid") then return end
    if part:IsDescendantOf(self.Services.Players.LocalPlayer.Character) then return end
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("BodyMover") or child:IsA("RocketPropulsion") then
            child:Destroy()
        end
        if child.Name == self.Config.MoverName then
            child:Destroy()
        end
    end
    part.CanCollide = false
    local attachment = Instance.new("Attachment", part)
    attachment.Name = self.Config.MoverName
    local align = Instance.new("AlignPosition", attachment)
    align.Attachment0 = attachment
    align.Attachment1 = self.State.BlackholeAttachment
    align.MaxForce = 1e9
    align.MaxVelocity = math.huge
    align.Responsiveness = self.Config.ForceResponsiveness
    local torque = Instance.new("Torque", attachment)
    torque.Attachment0 = attachment
    torque.Torque = Vector3.new(self.Config.TorqueMagnitude, self.Config.TorqueMagnitude, self.Config.TorqueMagnitude)
end
function Modules.Blackhole:Disable()
    if not self.State.IsEnabled then return end
    for _, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    pcall(function()
        for _, plr in ipairs(self.Services.Players:GetPlayers()) do
            plr.MaximumSimulationRadius = -1
        end
    end)
    self:_cleanupForces()
    if self.State.BlackholePart and self.State.BlackholePart.Parent then
        self.State.BlackholePart:Destroy()
    end
    if self.State.UI.ScreenGui and self.State.UI.ScreenGui.Parent then
        self.State.UI.ScreenGui:Destroy()
    end
    self.State = {
        IsEnabled = false,
        IsForceActive = false,
        TargetCFrame = CFrame.new(),
        Connections = {},
        UI = {}
    }
    DoNotif("Blackhole destroyed.", 2)
end
function Modules.Blackhole:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    local bhPart = Instance.new("Part")
    bhPart.Name = "Zuka_BlackholeCore"
    bhPart.Anchored = true
    bhPart.CanCollide = false
    bhPart.Transparency = 1
    bhPart.Size = Vector3.one
    self.State.BlackholePart = bhPart
    self.State.BlackholeAttachment = Instance.new("Attachment", bhPart)
    local mouse = localPlayer:GetMouse()
    self.State.TargetCFrame = mouse.Hit + Vector3.new(0, 5, 0)
    bhPart.Parent = self.Services.Workspace
    self.State.Connections.SimRadius = self.Services.RunService.Heartbeat:Connect(function()
        pcall(function()
            for _, plr in ipairs(self.Services.Players:GetPlayers()) do
                if plr ~= localPlayer then plr.MaximumSimulationRadius = 0 end
            end
            localPlayer.MaximumSimulationRadius = 1e9
        end)
    end)
    self.State.Connections.PositionUpdate = self.Services.RunService.RenderStepped:Connect(function()
        if self.State.BlackholeAttachment then
            self.State.BlackholeAttachment.WorldCFrame = self.State.TargetCFrame
        end
    end)
    self.State.Connections.DescendantAdded = self.Services.Workspace.DescendantAdded:Connect(function(desc)
        self:_applyForce(desc)
    end)
    self.State.Connections.Input = self.Services.UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Config.MoveKey then
            self.State.TargetCFrame = mouse.Hit + Vector3.new(0, 5, 0)
        end
    end)
    local screenGui = Instance.new("ScreenGui", self.Services.CoreGui)
    screenGui.Name = "BlackholeControlGUI"
    screenGui.ResetOnSpawn = false
    self.State.UI.ScreenGui = screenGui
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Text = "Enable Blackhole"
    toggleBtn.AnchorPoint = Vector2.new(0.5, 1)
    toggleBtn.Size = UDim2.fromOffset(160, 40)
    toggleBtn.Position = UDim2.new(0.5, 0, 0.93, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.SourceSansBold
    toggleBtn.TextSize = 18
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0.25, 0)
    local moveBtn = toggleBtn:Clone()
    moveBtn.Name = "MoveButton"
    moveBtn.Text = "Move Blackhole (E)"
    moveBtn.Position = UDim2.new(0.5, 0, 0.99, 0)
    moveBtn.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
    moveBtn.Parent = screenGui
    toggleBtn.MouseButton1Click:Connect(function()
        self.State.IsForceActive = not self.State.IsForceActive
        toggleBtn.Text = self.State.IsForceActive and "Disable Blackhole" or "Enable Blackhole"
        if self.State.IsForceActive then
            DoNotif("Blackhole force enabled", 2)
            for _,v in ipairs(self.Services.Workspace:GetDescendants()) do self:_applyForce(v) end
        else
            self:_cleanupForces()
            DoNotif("Blackhole force disabled", 2)
        end
    end)
    moveBtn.MouseButton1Click:Connect(function()
        self.State.TargetCFrame = mouse.Hit + Vector3.new(0, 5, 0)
    end)
    DoNotif("Blackhole created. Tap button or press E to move.", 3)
end
function Modules.Blackhole:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "blackhole",
        Aliases = {"bhole"},
        Description = "Toggles a client-sided black hole that pulls all unanchored parts."
    }, function()
        if module.State.IsEnabled then
            module:Disable()
        else
            module:Enable()
        end
    end)
end
Modules.PathfinderFollow = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        FollowConnection = nil,
        Path = nil,
        CurrentWaypointIndex = 1,
        LastPathRecalculation = 0,
        LastSourcePos = Vector3.new(),
        LastTargetPos = Vector3.new()
    },
    Config = {
        RECALCULATION_INTERVAL = 0.5,
        RECALCULATION_DISTANCE = 3,
        WAYPOINT_PROXIMITY = 4,
        PATH_PARAMS = {
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
        }
    },
    Dependencies = {"PathfindingService", "RunService", "Players"},
    Services = {}
}
function Modules.PathfinderFollow:_onHeartbeat()
    if not (self.State.IsEnabled and self.State.TargetPlayer and self.State.TargetPlayer.Parent) then
        self:Disable()
        return
    end
    local localPlayer = self.Services.Players.LocalPlayer
    local localChar = localPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local localHum = localChar and localChar:FindFirstChildOfClass("Humanoid")
    local targetChar = self.State.TargetPlayer.Character
    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not (localHrp and localHum and targetHrp and localHum.Health > 0) then
        return
    end
    local sourcePos = localHrp.Position
    local targetPos = targetHrp.Position
    local timeSinceRecalc = os.clock() - self.State.LastPathRecalculation
    local sourceMoved = (sourcePos - self.State.LastSourcePos).Magnitude > self.Config.RECALCULATION_DISTANCE
    local targetMoved = (targetPos - self.State.LastTargetPos).Magnitude > self.Config.RECALCULATION_DISTANCE
    if timeSinceRecalc > self.Config.RECALCULATION_INTERVAL and (sourceMoved or targetMoved) then
        self.State.LastPathRecalculation = os.clock()
        self.State.LastSourcePos = sourcePos
        self.State.LastTargetPos = targetPos
        local success = pcall(function() self.State.Path:ComputeAsync(sourcePos, targetPos) end)
        if success and self.State.Path.Status == Enum.PathStatus.Success then
            self.State.CurrentWaypointIndex = 1
        end
    end
    if self.State.Path and self.State.Path.Status == Enum.PathStatus.Success then
        local waypoints = self.State.Path:GetWaypoints()
        if #waypoints == 0 or self.State.CurrentWaypointIndex > #waypoints then return end
        local currentWaypoint = waypoints[self.State.CurrentWaypointIndex]
        local distanceToWaypoint = (localHrp.Position - currentWaypoint.Position).Magnitude
        if distanceToWaypoint < self.Config.WAYPOINT_PROXIMITY then
            self.State.CurrentWaypointIndex = self.State.CurrentWaypointIndex + 1
        else
            if currentWaypoint.Action == Enum.PathWaypointAction.Jump then
                localHum.Jump = true
            end
            localHum:MoveTo(currentWaypoint.Position)
        end
    end
end
function Modules.PathfinderFollow:Disable()
    if not self.State.IsEnabled then return end
    if self.State.FollowConnection then
        self.State.FollowConnection:Disconnect()
        self.State.FollowConnection = nil
    end
    pcall(function()
        local char = self.Services.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:MoveTo(hum.RootPart.Position) end
    end)
    DoNotif("Pathfinder follow disabled.", 2)
    self.State.IsEnabled = false
    self.State.TargetPlayer = nil
    self.State.Path = nil
end
function Modules.PathfinderFollow:Enable(targetPlayer)
    if not targetPlayer or targetPlayer == self.Services.Players.LocalPlayer then
        DoNotif("Invalid target for pathfinding.", 3)
        return
    end
    self:Disable()
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    self.State.Path = self.Services.PathfindingService:CreatePath(self.Config.PATH_PARAMS)
    self.State.LastPathRecalculation = 0
    self.State.FollowConnection = self.Services.RunService.Heartbeat:Connect(function() self:_onHeartbeat() end)
    DoNotif("Pathfinder following: " .. targetPlayer.Name, 2)
end
function Modules.PathfinderFollow:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "pathfind",
        Aliases = {"follow"},
        Description = "Follow a player using PathfindingService."
    }, function(args)
        local argument = args[1]
        if not argument or (argument:lower() == "stop" or argument:lower() == "off") then
            module:Disable()
            return
        end
        local target = Utilities.findPlayer(argument)
        if target then
            module:Enable(target)
        else
            DoNotif("Player '" .. argument .. "' not found.", 3)
        end
    end)
end
Modules.CharacterMorph = {
    State = {
        IsMorphed = false,
        OriginalDescription = nil,
        CharacterAddedConnection = nil
    },
    Dependencies = {"Players"},
    Services = {}
}
function Modules.CharacterMorph:_resolveDescription(target)
    local targetId = tonumber(target)
    if not targetId then
        local success, idFromName = pcall(function()
            return self.Services.Players:GetUserIdFromNameAsync(target)
        end)
        if not success or not idFromName then
            DoNotif("Could not find a user with the name: " .. tostring(target), 3)
            return nil
        end
        targetId = idFromName
    end
    DoNotif("Loading avatar for ID: " .. targetId, 1.5)
    local success, description = pcall(function()
        return self.Services.Players:GetHumanoidDescriptionFromUserId(targetId)
    end)
    if not success or not description then
        DoNotif("Unable to load avatar description for that user.", 3)
        return nil
    end
    return description
end
function Modules.CharacterMorph:_applyAndRespawn(description)
    local localPlayer = self.Services.Players.LocalPlayer
    if not description then return end
    if self.State.CharacterAddedConnection then
        self.State.CharacterAddedConnection:Disconnect()
        self.State.CharacterAddedConnection = nil
    end
    self.State.CharacterAddedConnection = localPlayer.CharacterAdded:Once(function(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            pcall(humanoid.ApplyDescription, humanoid, description)
        end
    end)
    localPlayer:LoadCharacter()
end
function Modules.CharacterMorph:Morph(target)
    if not target then
        DoNotif("Usage: ;char <username/userid>", 3)
        return
    end
    if not self.State.OriginalDescription then
        local success, originalDesc = pcall(function()
            return self.Services.Players:GetHumanoidDescriptionFromUserId(self.Services.Players.LocalPlayer.UserId)
        end)
        if success then
            self.State.OriginalDescription = originalDesc
        else
            warn("[CharacterMorph] Could not cache original character description.")
        end
    end
    task.spawn(function()
        local newDescription = self:_resolveDescription(target)
        if newDescription then
            self.State.IsMorphed = true
            self:_applyAndRespawn(newDescription)
            DoNotif("Applying character morph...", 2)
        end
    end)
end
function Modules.CharacterMorph:Revert()
    if not self.State.IsMorphed then
        DoNotif("You are not currently morphed.", 2)
        return
    end
    if not self.State.OriginalDescription then
        DoNotif("Could not find original avatar to revert to. Re-fetching...", 3)
        local success, originalDesc = pcall(function()
            return self.Services.Players:GetHumanoidDescriptionFromUserId(self.Services.Players.LocalPlayer.UserId)
        end)
        if success then self.State.OriginalDescription = originalDesc end
    end
    if self.State.OriginalDescription then
        self:_applyAndRespawn(self.State.OriginalDescription)
        self.State.IsMorphed = false
        DoNotif("Reverting to original character...", 2)
    else
        DoNotif("Failed to revert character: Original description is missing.", 4)
    end
end
function Modules.CharacterMorph:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "char",
        Aliases = {"character", "morph"},
        Description = "Change your character's appearance to someone else's."
    }, function(args)
        module:Morph(args[1])
    end)
    RegisterCommand({
        Name = "unchar",
        Aliases = {},
        Description = "Reverts your character's appearance to your own."
    }, function()
        module:Revert()
    end)
end
Modules.StalkerBot = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Path = nil,
        CurrentWaypointIndex = 1,
        LastPathRecalculation = 0,
        HasLineOfSight = false,
        OriginalNeckC0 = nil,
        Connections = {}
    },
    Config = {
        FollowDistance = 25,
        StopDistance = 15,
        RecalculationInterval = 1.0,
        LineOfSightInterval = 0.25,
        PATH_PARAMS = {
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
        }
    },
    Services = {}
}
function Modules.StalkerBot:_onRenderStepped()
    if not (self.State.IsEnabled and self.State.TargetPlayer) then return end
    local success, myChar, targetChar = pcall(function()
        return self.Services.LocalPlayer.Character, self.State.TargetPlayer.Character
    end)
    if not (success and myChar and targetChar) then return end
    local myHead = myChar:FindFirstChild("Head")
    local targetHead = targetChar:FindFirstChild("Head")
    local myTorso = myChar:FindFirstChild("HumanoidRootPart")
    local neck = myChar:FindFirstChild("Neck", true) or (myTorso and myTorso:FindFirstChild("Neck", true))
    if not (myHead and targetHead and neck and neck:IsA("Motor6D")) then return end
    if not self.State.OriginalNeckC0 then
        self.State.OriginalNeckC0 = neck.C0
    end
    local lookAtCFrame = CFrame.lookAt(neck.Part0.Position, targetHead.Position)
    local objectSpaceRotation = neck.Part0.CFrame:ToObjectSpace(lookAtCFrame)
    neck.C0 = CFrame.new(self.State.OriginalNeckC0.Position) * (objectSpaceRotation - objectSpaceRotation.Position)
end
function Modules.StalkerBot:_onHeartbeat()
    if not self.State.IsEnabled then return end
    if not (self.State.TargetPlayer and self.State.TargetPlayer.Parent) then
        return self:Disable()
    end
    local myChar = self.Services.LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local targetChar = self.State.TargetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and myHumanoid and targetRoot and myHumanoid.Health > 0) then
        return
    end
    local distanceToTarget = (myRoot.Position - targetRoot.Position).Magnitude
    if distanceToTarget < self.Config.StopDistance then
        myHumanoid:MoveTo(myRoot.Position)
        return
    end
    local now = os.clock()
    if (now - self.State.LastPathRecalculation) > self.Config.RecalculationInterval then
        self.State.LastPathRecalculation = now
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {myChar, targetChar}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = self.Services.Workspace:Raycast(myRoot.Position, (targetRoot.Position - myRoot.Position).Unit * 1000, raycastParams)
        self.State.HasLineOfSight = (not raycastResult or raycastResult.Instance:IsDescendantOf(targetChar))
        local success, err = pcall(function()
            self.State.Path:ComputeAsync(myRoot.Position, targetRoot.Position)
        end)
        if success and self.State.Path.Status == Enum.PathStatus.Success then
            self.State.CurrentWaypointIndex = 2
        else
            myHumanoid:MoveTo(myRoot.Position)
        end
    end
    if self.State.Path and self.State.Path.Status == Enum.PathStatus.Success then
        local waypoints = self.State.Path:GetWaypoints()
        if self.State.CurrentWaypointIndex > #waypoints then
            myHumanoid:MoveTo(myRoot.Position)
            return
        end
        local currentWaypoint = waypoints[self.State.CurrentWaypointIndex]
        if not self.State.HasLineOfSight or distanceToTarget > self.Config.FollowDistance then
            myHumanoid:MoveTo(currentWaypoint.Position)
            if (currentWaypoint.Position - myRoot.Position).Magnitude < 6 then
                self.State.CurrentWaypointIndex += 1
            end
        else
            myHumanoid:MoveTo(targetRoot.Position)
        end
    end
end
function Modules.StalkerBot:Enable(targetPlayer: Player)
    if not targetPlayer or targetPlayer == self.Services.LocalPlayer then
        return DoNotif("Invalid target for StalkerBot.", 3)
    end
    if self.State.IsEnabled then self:Disable() end
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    self.State.Path = self.Services.PathfindingService:CreatePath(self.Config.PATH_PARAMS)
    self.State.Connections.Heartbeat = self.Services.RunService.Heartbeat:Connect(function() self:_onHeartbeat() end)
    self.State.Connections.RenderStepped = self.Services.RunService.RenderStepped:Connect(function() self:_onRenderStepped() end)
    DoNotif("StalkerBot Enabled: Now following " .. targetPlayer.Name, 3)
end
function Modules.StalkerBot:Disable()
    if not self.State.IsEnabled then return end
    for _, conn in pairs(self.State.Connections) do conn:Disconnect() end
    table.clear(self.State.Connections)
    if self.State.OriginalNeckC0 then
        pcall(function()
            local myChar = self.Services.LocalPlayer.Character
            local myTorso = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local neck = myChar and (myChar:FindFirstChild("Neck", true) or (myTorso and myTorso:FindFirstChild("Neck", true)))
            if neck and neck:IsA("Motor6D") then
                neck.C0 = self.State.OriginalNeckC0
            end
        end)
    end
    pcall(function()
        local myHumanoid = self.Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if myHumanoid then myHumanoid:MoveTo(myHumanoid.RootPart.Position) end
    end)
    self.State = {
        IsEnabled = false, TargetPlayer = nil, Path = nil, CurrentWaypointIndex = 1,
        LastPathRecalculation = 0, HasLineOfSight = false, OriginalNeckC0 = nil,
        Connections = {}
    }
    DoNotif("StalkerBot Disabled.", 2)
end
function Modules.StalkerBot:Initialize()
    self.Services.Players = game:GetService("Players")
    self.Services.RunService = game:GetService("RunService")
    self.Services.Workspace = game:GetService("Workspace")
    self.Services.PathfindingService = game:GetService("PathfindingService")
    self.Services.LocalPlayer = self.Services.Players.LocalPlayer
    RegisterCommand({
        Name = "stalk",
        Aliases = {},
        Description = "Follows a player with uncanny pathfinding."
    }, function(args)
        local argument = args[1]
        if not argument or (argument:lower() == "stop" or argument:lower() == "off") then
            self:Disable()
            return
        end
        local target = Utilities.findPlayer(argument)
        if target then
            self:Enable(target)
        else
            DoNotif("Player '" .. argument .. "' not found.", 3)
        end
    end)
end
Modules.InfoPanel = {
    State = {
        IsEnabled = false,
        UI = {},
        Connections = {},
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = nil,
        PreMaximizePosition = nil
    },
    Theme = {
        Background = Color3.fromRGB(0, 0, 0),
        WindowGray = Color3.fromRGB(192, 192, 192),
        DarkGray = Color3.fromRGB(128, 128, 128),
        LightGray = Color3.fromRGB(223, 223, 223),
        White = Color3.fromRGB(255, 255, 255),
        Blue = Color3.fromRGB(0, 0, 128),
        Accent = Color3.fromRGB(0, 255, 0),
        Text = Color3.fromRGB(192, 192, 192),
        Font = Enum.Font.Code
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        CoreGui = game:GetService("CoreGui"),
        Workspace = game:GetService("Workspace"),
        TweenService = game:GetService("TweenService")
    }
}
function Modules.InfoPanel:Minimize()
    if self.State.IsMinimized then return end
    self.State.IsMinimized = true
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = self.Services.TweenService:Create(self.State.UI.MainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -self.State.UI.MainFrame.Size.X.Offset/2, 1, 50),
        Size = UDim2.new(0, self.State.UI.MainFrame.Size.X.Offset, 0, 30)
    })
    tween:Play()
end
function Modules.InfoPanel:Restore()
    if not self.State.IsMinimized then return end
    self.State.IsMinimized = false
    local targetSize = self.State.PreMaximizeSize or UDim2.new(0, 400, 0, 500)
    local targetPos = self.State.PreMaximizePosition or UDim2.new(0.5, -200, 0.5, -250)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = self.Services.TweenService:Create(self.State.UI.MainFrame, tweenInfo, {
        Position = targetPos,
        Size = targetSize
    })
    tween:Play()
end
function Modules.InfoPanel:Maximize()
    if self.State.IsMaximized then
        self.State.IsMaximized = false
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(self.State.UI.MainFrame, tweenInfo, {
            Position = self.State.PreMaximizePosition,
            Size = self.State.PreMaximizeSize
        })
        tween:Play()
    else
        self.State.PreMaximizeSize = self.State.UI.MainFrame.Size
        self.State.PreMaximizePosition = self.State.UI.MainFrame.Position
        self.State.IsMaximized = true
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(self.State.UI.MainFrame, tweenInfo, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
    end
end
function Modules.InfoPanel:Toggle()
    if self.State.IsEnabled then
        if self.State.Connections.Updater then
            self.State.Connections.Updater:Disconnect()
        end
        if self.State.UI.ScreenGui then
            self.State.UI.ScreenGui:Destroy()
        end
        self.State = { 
            IsEnabled = false, 
            UI = {}, 
            Connections = {},
            IsMinimized = false,
            IsMaximized = false,
            PreMaximizeSize = nil,
            PreMaximizePosition = nil
        }
        DoNotif("System Information closed.", 2)
        return
    end
    self.State.IsEnabled = true
    DoNotif("System Information opened.", 2)
    local localPlayer = self.Services.Players.LocalPlayer
    local function CreateWin95Border(parent, isInset)
        local topColor = isInset and self.Theme.DarkGray or self.Theme.White
        local bottomColor = isInset and self.Theme.White or self.Theme.DarkGray
        local topBorder = Instance.new("Frame", parent)
        topBorder.Name = "TopBorder"
        topBorder.Size = UDim2.new(1, 0, 0, 2)
        topBorder.Position = UDim2.new(0, 0, 0, 0)
        topBorder.BackgroundColor3 = topColor
        topBorder.BorderSizePixel = 0
        topBorder.ZIndex = parent.ZIndex + 1
        local leftBorder = Instance.new("Frame", parent)
        leftBorder.Name = "LeftBorder"
        leftBorder.Size = UDim2.new(0, 2, 1, 0)
        leftBorder.Position = UDim2.new(0, 0, 0, 0)
        leftBorder.BackgroundColor3 = topColor
        leftBorder.BorderSizePixel = 0
        leftBorder.ZIndex = parent.ZIndex + 1
        local bottomBorder = Instance.new("Frame", parent)
        bottomBorder.Name = "BottomBorder"
        bottomBorder.Size = UDim2.new(1, 0, 0, 2)
        bottomBorder.Position = UDim2.new(0, 0, 1, -2)
        bottomBorder.BackgroundColor3 = bottomColor
        bottomBorder.BorderSizePixel = 0
        bottomBorder.ZIndex = parent.ZIndex + 1
        local rightBorder = Instance.new("Frame", parent)
        rightBorder.Name = "RightBorder"
        rightBorder.Size = UDim2.new(0, 2, 1, 0)
        rightBorder.Position = UDim2.new(1, -2, 0, 0)
        rightBorder.BackgroundColor3 = bottomColor
        rightBorder.BorderSizePixel = 0
        rightBorder.ZIndex = parent.ZIndex + 1
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SystemInformation_Win95"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.State.UI.ScreenGui = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "WindowFrame"
    mainFrame.Size = UDim2.fromOffset(400, 500)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.Theme.WindowGray
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui
    self.State.UI.MainFrame = mainFrame
    CreateWin95Border(mainFrame, false)
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Position = UDim2.new(0, 3, 0, 3)
    titleBar.Size = UDim2.new(1, -6, 0, 22)
    titleBar.BackgroundColor3 = self.Theme.Blue
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
    }
    titleGradient.Rotation = 90
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Name = "Title"
    titleLabel.Position = UDim2.new(0, 4, 0, 0)
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "System Information"
    titleLabel.TextColor3 = self.Theme.White
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 3
    local minimizeButton = Instance.new("TextButton", titleBar)
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Position = UDim2.new(1, -54, 0, 2)
    minimizeButton.Size = UDim2.new(0, 16, 0, 16)
    minimizeButton.BackgroundColor3 = self.Theme.WindowGray
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeButton.TextSize = 14
    minimizeButton.TextYAlignment = Enum.TextYAlignment.Top
    minimizeButton.ZIndex = 4
    CreateWin95Border(minimizeButton, false)
    minimizeButton.MouseButton1Click:Connect(function()
        if self.State.IsMinimized then
            self:Restore()
        else
            self:Minimize()
        end
    end)
    local maximizeButton = Instance.new("TextButton", titleBar)
    maximizeButton.Name = "MaximizeButton"
    maximizeButton.Position = UDim2.new(1, -36, 0, 2)
    maximizeButton.Size = UDim2.new(0, 16, 0, 16)
    maximizeButton.BackgroundColor3 = self.Theme.WindowGray
    maximizeButton.BorderSizePixel = 0
    maximizeButton.Font = Enum.Font.SourceSansBold
    maximizeButton.Text = "□"
    maximizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    maximizeButton.TextSize = 14
    maximizeButton.ZIndex = 4
    CreateWin95Border(maximizeButton, false)
    maximizeButton.MouseButton1Click:Connect(function()
        self:Maximize()
    end)
    local closeButton = Instance.new("TextButton", titleBar)
    closeButton.Name = "CloseButton"
    closeButton.Position = UDim2.new(1, -18, 0, 2)
    closeButton.Size = UDim2.new(0, 16, 0, 16)
    closeButton.BackgroundColor3 = self.Theme.WindowGray
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.TextSize = 16
    closeButton.ZIndex = 4
    CreateWin95Border(closeButton, false)
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    local contentContainer = Instance.new("Frame", mainFrame)
    contentContainer.Name = "ContentContainer"
    contentContainer.Position = UDim2.new(0, 6, 0, 28)
    contentContainer.Size = UDim2.new(1, -12, 1, -34)
    contentContainer.BackgroundColor3 = self.Theme.WindowGray
    contentContainer.BorderSizePixel = 0
    contentContainer.ZIndex = 1
    CreateWin95Border(contentContainer, true)
    local scroll = Instance.new("ScrollingFrame", contentContainer)
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 16
    scroll.ScrollBarImageColor3 = self.Theme.WindowGray
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingTop = UDim.new(0, 6)
    local function createHeader(text)
        local headerFrame = Instance.new("Frame")
        headerFrame.Size = UDim2.new(1, -12, 0, 20)
        headerFrame.BackgroundColor3 = self.Theme.Blue
        headerFrame.BorderSizePixel = 0
        headerFrame.Parent = scroll
        local headerLabel = Instance.new("TextLabel", headerFrame)
        headerLabel.Size = UDim2.new(1, -4, 1, 0)
        headerLabel.Position = UDim2.new(0, 2, 0, 0)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Font = Enum.Font.SourceSansBold
        headerLabel.Text = text
        headerLabel.TextColor3 = self.Theme.White
        headerLabel.TextSize = 14
        headerLabel.TextXAlignment = Enum.TextXAlignment.Left
        CreateWin95Border(headerFrame, false)
    end
    local function createInfoEntry(key, value)
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, -12, 0, 18)
        entry.BackgroundColor3 = self.Theme.White
        entry.BorderSizePixel = 0
        entry.Parent = scroll
        CreateWin95Border(entry, true)
        local entryLabel = Instance.new("TextLabel", entry)
        entryLabel.Size = UDim2.new(1, -6, 1, 0)
        entryLabel.Position = UDim2.new(0, 3, 0, 0)
        entryLabel.BackgroundTransparency = 1
        entryLabel.Font = self.Theme.Font
        entryLabel.TextSize = 12
        entryLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        entryLabel.TextXAlignment = Enum.TextXAlignment.Left
        entryLabel.RichText = true
        entryLabel.Text = string.format("<b>%s:</b> %s", key, tostring(value))
        return entryLabel
    end
    createHeader("▼ Client Information")
    createInfoEntry("Display Name", localPlayer.DisplayName)
    createInfoEntry("Username", localPlayer.Name)
    createInfoEntry("User ID", localPlayer.UserId)
    createInfoEntry("Account Age", localPlayer.AccountAge .. " days")
    local fpsLabel = createInfoEntry("Client FPS", "Calculating...")
    createHeader("▼ Game Information")
    createInfoEntry("Place ID", game.PlaceId)
    createInfoEntry("Job ID", game.JobId)
    createInfoEntry("Creator Type", game.CreatorType.Name)
    createInfoEntry("Creator ID", game.CreatorId)
    createHeader("▼ Server Players")
    local playerListFrame = Instance.new("Frame", scroll)
    playerListFrame.Size = UDim2.new(1, -12, 0, 0)
    playerListFrame.BackgroundTransparency = 1
    playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
    local playerListLayout = Instance.new("UIListLayout", playerListFrame)
    playerListLayout.Padding = UDim.new(0, 2)
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(16, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3 = self.Theme.WindowGray
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = mainFrame
    for i = 0, 2 do
        local line = Instance.new("Frame", resizeHandle)
        line.Size = UDim2.new(0, 2, 1, -4 * i)
        line.Position = UDim2.new(0, 4 + (4 * i), 0, 4 * i)
        line.BackgroundColor3 = self.Theme.DarkGray
        line.BorderSizePixel = 0
        line.Rotation = 45
    end
    local dragging, resizing = false, false
    local dragStart, resizeStart, startPos, startSize
    local UserInputService = game:GetService("UserInputService")
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif resizing then
                local delta = Vector2.new(input.Position.X - resizeStart.X, input.Position.Y - resizeStart.Y)
                local newX = math.max(300, startSize.X.Offset + delta.X)
                local newY = math.max(250, startSize.Y.Offset + delta.Y)
                mainFrame.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    local lastTick = 0
    self.State.Connections.Updater = self.Services.RunService.Heartbeat:Connect(function(step)
        if not screenGui.Parent then
            self:Toggle()
            return
        end
        local now = tick()
        if now - lastTick > 0.5 then
            lastTick = now
            fpsLabel.Text = string.format("<b>Client FPS:</b> %.1f", 1 / step)
            for _, child in ipairs(playerListFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            local players = self.Services.Players:GetPlayers()
            for _, player in ipairs(players) do
                local playerEntry = Instance.new("Frame", playerListFrame)
                playerEntry.Size = UDim2.new(1, 0, 0, 16)
                playerEntry.BackgroundColor3 = self.Theme.White
                playerEntry.BorderSizePixel = 0
                CreateWin95Border(playerEntry, true)
                local playerLabel = Instance.new("TextLabel", playerEntry)
                playerLabel.Size = UDim2.new(1, -6, 1, 0)
                playerLabel.Position = UDim2.new(0, 3, 0, 0)
                playerLabel.BackgroundTransparency = 1
                playerLabel.Font = self.Theme.Font
                playerLabel.TextSize = 11
                playerLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                playerLabel.Text = string.format("• %s (@%s)", player.DisplayName, player.Name)
                playerLabel.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
    end)
    screenGui.Parent = self.Services.CoreGui
end
RegisterCommand({
    Name = "infopanel",
    Aliases = {"info", "gameinfo", "serverinfo"},
    Description = "Toggles a panel with information about the game, server, and players."
}, function(args)
    Modules.InfoPanel:Toggle()
end)
Modules.StalkBot = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Path = nil,
        CurrentWaypointIndex = 1,
        LastPathRecalculation = 0,
        HasLineOfSight = false,
        Connections = {}
    },
    Config = {
        FollowDistance = 80,
        StopDistance = 15,
        RecalculationInterval = 1.0,
        LineOfSightInterval = 0.25,
        PATH_PARAMS = {
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
        }
    },
    Services = {}
}
function Modules.StalkerBot:_onRenderStepped()
    if not (self.State.IsEnabled and self.State.TargetPlayer) then return end
    local success, myChar, targetChar = pcall(function()
        return self.Services.LocalPlayer.Character, self.State.TargetPlayer.Character
    end)
    if not (success and myChar and targetChar) then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and targetRoot) then return end
    local lookAtCFrame = CFrame.lookAt(myRoot.Position, targetRoot.Position)
    myRoot.CFrame = CFrame.fromMatrix(myRoot.Position, lookAtCFrame.XVector, myRoot.CFrame.YVector)
end
function Modules.StalkerBot:_onHeartbeat()
    if not self.State.IsEnabled then return end
    if not (self.State.TargetPlayer and self.State.TargetPlayer.Parent) then
        return self:Disable()
    end
    local myChar = self.Services.LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local targetChar = self.State.TargetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and myHumanoid and targetRoot and myHumanoid.Health > 0) then
        return
    end
    local distanceToTarget = (myRoot.Position - targetRoot.Position).Magnitude
    if distanceToTarget < self.Config.StopDistance then
        myHumanoid:MoveTo(myRoot.Position)
        return
    end
    local now = os.clock()
    if (now - self.State.LastPathRecalculation) > self.Config.RecalculationInterval then
        self.State.LastPathRecalculation = now
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {myChar}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = self.Services.Workspace:Raycast(myRoot.Position, (targetRoot.Position - myRoot.Position), raycastParams)
        self.State.HasLineOfSight = (not raycastResult or raycastResult.Instance:IsDescendantOf(targetChar))
        local success, err = pcall(function()
            self.State.Path:ComputeAsync(myRoot.Position, targetRoot.Position)
        end)
        if success and self.State.Path.Status == Enum.PathStatus.Success then
            self.State.CurrentWaypointIndex = 2
        else
            myHumanoid:MoveTo(myRoot.Position)
        end
    end
    if self.State.Path and self.State.Path.Status == Enum.PathStatus.Success then
        local waypoints = self.State.Path:GetWaypoints()
        if self.State.CurrentWaypointIndex > #waypoints then
            myHumanoid:MoveTo(myRoot.Position)
            return
        end
        local currentWaypoint = waypoints[self.State.CurrentWaypointIndex]
        if not self.State.HasLineOfSight or distanceToTarget > self.Config.FollowDistance then
            myHumanoid:MoveTo(currentWaypoint.Position)
            if (currentWaypoint.Position - myRoot.Position).Magnitude < 6 then
                self.State.CurrentWaypointIndex += 1
            end
        else
            myHumanoid:MoveTo(targetRoot.Position)
        end
    end
end
function Modules.StalkerBot:Enable(targetPlayer: Player)
    if not targetPlayer or targetPlayer == self.Services.LocalPlayer then
        return DoNotif("Invalid target for StalkerBot.", 3)
    end
    if self.State.IsEnabled then self:Disable() end
    pcall(function()
        self.Services.LocalPlayer.Character.Humanoid.AutoRotate = false
    end)
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    self.State.Path = self.Services.PathfindingService:CreatePath(self.Config.PATH_PARAMS)
    self.State.Connections.Heartbeat = self.Services.RunService.Heartbeat:Connect(function() self:_onHeartbeat() end)
    self.State.Connections.RenderStepped = self.Services.RunService.RenderStepped:Connect(function() self:_onRenderStepped() end)
    DoNotif("StalkBot Enabled: Now following " .. targetPlayer.Name, 3)
end
function Modules.StalkerBot:Disable()
    if not self.State.IsEnabled then return end
    for _, conn in pairs(self.State.Connections) do conn:Disconnect() end
    table.clear(self.State.Connections)
    pcall(function()
        local humanoid = self.Services.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid:MoveTo(humanoid.RootPart.Position)
        end
    end)
    self.State = {
        IsEnabled = false, TargetPlayer = nil, Path = nil, CurrentWaypointIndex = 1,
        LastPathRecalculation = 0, HasLineOfSight = false, Connections = {}
    }
    DoNotif("StalkBot Disabled.", 2)
end
function Modules.StalkerBot:Initialize()
    RegisterCommand({
        Name = "stalkstare",
        Aliases = {},
        Description = "Follow a player + Stare"
    }, function(args)
        local argument = args[1]
        if not argument or (argument:lower() == "stop" or argument:lower() == "off") then
            self:Disable()
            return
        end
        local target = Utilities.findPlayer(argument)
        if target then
            self:Enable(target)
        else
            DoNotif("Player '" .. argument .. "' not found.", 3)
        end
    end)
end
Modules.TimeStop = {
    State = {
        IsEnabled = false,
        Connections = {}
    },
    Dependencies = {"Players"},
    Services = {}
}
function Modules.TimeStop:_freezeCharacter(character)
    if not character then return end
    task.wait()
    local success, err = pcall(function()
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Anchored = true
            end
        end
    end)
    if not success then warn("[TimeStop] Failed to freeze character:", err) end
end
function Modules.TimeStop:_unfreezeCharacter(character)
    if not character then return end
    pcall(function()
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.Anchored = false
            end
        end
    end)
end
function Modules.TimeStop:Disable()
    if not self.State.IsEnabled then return end
    for key, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        if player.Character then
            self:_unfreezeCharacter(player.Character)
        end
    end
    self.State.IsEnabled = false
    DoNotif("Time has resumed.", 2)
end
function Modules.TimeStop:Enable()
    if self.State.IsEnabled then return end
    self:Disable()
    self.State.IsEnabled = true
    local function setupPlayer(player)
        if player == self.Services.Players.LocalPlayer then return end
        if player.Character then
            self:_freezeCharacter(player.Character)
        end
        local conn = player.CharacterAdded:Connect(function(character)
            self:_freezeCharacter(character)
        end)
        self.State.Connections[player.UserId] = conn
    end
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        setupPlayer(player)
    end
    self.State.Connections.PlayerAdded = self.Services.Players.PlayerAdded:Connect(setupPlayer)
    DoNotif("ZA WARUDO! Time has been stopped.", 3)
end
function Modules.TimeStop:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "timestop",
        Aliases = {"tstop"},
        Description = "Toggles a client-sided freeze for all other players."
    }, function()
        if module.State.IsEnabled then
            module:Disable()
        else
            module:Enable()
        end
    end)
    RegisterCommand({
        Name = "untimestop",
        Aliases = {"untstop"},
        Description = "Explicitly disables the time stop effect."
    }, function()
        module:Disable()
    end)
end
Modules.AnimationSpeed = {
    State = {
        IsEnabled = false,
        TargetSpeed = 1,
        LoopConnection = nil
    },
    Dependencies = {"RunService", "Players"},
    Services = {}
}
function Modules.AnimationSpeed:Disable()
    if not self.State.IsEnabled then return end
    if self.State.LoopConnection then
        self.State.LoopConnection:Disconnect()
        self.State.LoopConnection = nil
    end
    self.State.IsEnabled = false
    task.spawn(function()
        local char = self.Services.Players.LocalPlayer.Character
        if not char then return end
        local animator = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("AnimationController")
        if not animator then return end
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(1)
            end
        end)
    end)
    DoNotif("Animation speed control disabled.", 2)
end
function Modules.AnimationSpeed:Enable(speed)
    local targetSpeed = tonumber(speed)
    if not targetSpeed or targetSpeed < 0 then
        DoNotif("Invalid speed. Must be a positive number.", 3)
        return
    end
    self.State.TargetSpeed = targetSpeed
    if self.State.IsEnabled then
        DoNotif("Animation speed updated to " .. targetSpeed, 2)
        return
    end
    self.State.IsEnabled = true
    self.State.LoopConnection = self.Services.RunService.Stepped:Connect(function()
        local char = self.Services.Players.LocalPlayer.Character
        if not char then return end
        local animator = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChildOfClass("AnimationController")
        if not animator then return end
        local success, err = pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Speed ~= self.State.TargetSpeed then
                    track:AdjustSpeed(self.State.TargetSpeed)
                end
            end
        end)
        if not success then
            warn("[AnimationSpeed] Error during loop:", err)
            self:Disable()
        end
    end)
    DoNotif("Animation speed set to " .. targetSpeed, 2)
end
function Modules.AnimationSpeed:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "animspeed",
        Aliases = {},
        Description = "Adjusts local animation speed."
    }, function(args)
        local argument = args[1]
        if not argument or (argument:lower() == "off" or argument:lower() == "stop" or argument:lower() == "reset") then
            module:Disable()
        else
            module:Enable(argument)
        end
    end)
    RegisterCommand({
        Name = "unanimspeed",
        Aliases = {"unaspeed", "unanimationspeed"},
        Description = "Stops the animation speed adjustment loop."
    }, function()
        module:Disable()
    end)
end
Modules.Attacher = {
    State = {
        isGuiBuilt = false,
        followSpeed = 1,
        selectedPlayerName = "Nearest Player",
        isFollowing = false,
        isAttaching = false,
        isAutoAttacking = false,
        attackSpeed = 1,
        isChaosMode = false,
        flingStrength = 0.5,
        oscillationValue = 1,
        lastChaosTime = 0,
        chaosInterval = 0.1,
        UI = {},
        Connections = {}
    },
    Services = {}
}
function Modules.Attacher:Deactivate()
    if not self.State.isGuiBuilt then return end
    for _, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    if self.State.UI.window and self.State.UI.window.Parent then
        self.State.UI.window:Destroy()
    end
    if self.State.UI.currentHighlight and self.State.UI.currentHighlight.Parent then
        self.State.UI.currentHighlight:Destroy()
    end
    table.clear(self.State.UI)
    self.State.isGuiBuilt = false
    DoNotif("Attacher module deactivated.", 2)
end
function Modules.Attacher:Activate()
    if self.State.isGuiBuilt then return end
    local self = self
    self.Services.Players = self.Services.Players or game:GetService("Players")
    self.Services.RunService = self.Services.RunService or game:GetService("RunService")
    self.Services.StarterGui = self.Services.StarterGui or game:GetService("StarterGui")
    local LocalPlayer = self.Services.Players.LocalPlayer
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
    local w = library:CreateWindow("Attacher")
    self.State.UI.window = w
    local function notify(title, text, duration)
        pcall(function()
            self.Services.StarterGui:SetCore("SendNotification", {
                Title = title; Text = text; Duration = duration or 3;
            })
        end)
    end
    local function clearHighlight()
        if self.State.UI.currentHighlight and self.State.UI.currentHighlight.Parent then
            self.State.UI.currentHighlight:Destroy()
            self.State.UI.currentHighlight = nil
        end
    end
    local function applyHighlight(targetPlayer)
        clearHighlight()
        if targetPlayer and targetPlayer.Character then
            local h = Instance.new("Highlight", targetPlayer.Character)
            h.Name = "TargetHighlight"
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.45
            h.Adornee = targetPlayer.Character
            self.State.UI.currentHighlight = h
        end
    end
    local function findPlayerByPartialName(partialName)
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = localChar.HumanoidRootPart.Position
        local lowerPartialName = partialName:lower()
        local matches = {}
        for _, p in ipairs(self.Services.Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Name:lower():find(lowerPartialName, 1, true) or p.DisplayName:lower():find(lowerPartialName, 1, true) then
                    table.insert(matches, p)
                end
            end
        end
        if #matches == 0 then return nil end
        if #matches == 1 then return matches[1] end
        local closestPlayer, closestDist = nil, math.huge
        for _, matchedPlayer in ipairs(matches) do
            if matchedPlayer.Character and matchedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (matchedPlayer.Character.HumanoidRootPart.Position - myPos).Magnitude
                if dist < closestDist then
                    closestDist, closestPlayer = dist, matchedPlayer
                end
            end
        end
        return closestPlayer
    end
    local function updateNearestPlayerButton()
        if not self.State.UI.nearestPlayerButton then return end
        if self.State.selectedPlayerName == "Nearest Player" then
            self.State.UI.nearestPlayerButton.Name = "-> Nearest Player"
        else
            self.State.UI.nearestPlayerButton.Name = "Nearest Player"
        end
    end
    local mainFolder = w:CreateFolder("Follow Settings")
    mainFolder:Slider("Speed", {min = 0; max = 5; precise = true;}, function(value)
        self.State.followSpeed = value
    end)
    mainFolder:Box("Enter Username", "string", function(value)
        if value == "" then notify("Input Error", "Please type a valid username.", 3) return end
        local found = findPlayerByPartialName(value)
        if found and found ~= LocalPlayer then
            self.State.selectedPlayerName = found.Name
            applyHighlight(found)
            notify("Player Selected", "Targeting " .. found.Name, 2)
            updateNearestPlayerButton()
        else
            self.State.selectedPlayerName = "Nearest Player"
            updateNearestPlayerButton()
            notify("Player Not Found", "Could not find player: " .. value, 3)
        end
    end)
    self.State.UI.nearestPlayerButton = mainFolder:Button("-> Nearest Player", function()
        self.State.selectedPlayerName = "Nearest Player"
        clearHighlight()
        notify("Player Selected", "Nearest Player", 2)
        updateNearestPlayerButton()
    end)
    mainFolder:Toggle("Enable Following", function(bool)
        self.State.isFollowing = bool
        notify("Following", bool and "Enabled" or "Disabled")
    end)
    mainFolder:Toggle("Attach", function(bool)
        self.State.isAttaching = bool
        notify("Attach", bool and "Enabled" or "Disabled")
    end)
    local combatFolder = w:CreateFolder("Combat")
    combatFolder:Slider("Attack Speed", {min = 0.1; max = 5; precise = true;}, function(value)
        self.State.attackSpeed = value
    end)
    combatFolder:Toggle("Auto Attack (M1)", function(bool)
        self.State.isAutoAttacking = bool
        notify("Auto Attack", bool and "ENABLED - Spamming M1" or "Disabled")
    end)
    local chaosFolder = w:CreateFolder("Anti-Aimbot")
    chaosFolder:Slider("Fling Strength", {min = 0.1; max = 2; precise = true;}, function(value)
        self.State.flingStrength = value
    end)
    chaosFolder:Toggle("Chaos Movement", function(bool)
        self.State.isChaosMode = bool
        notify("Chaos Mode", bool and "ENABLED - Breaking Aimbots" or "Disabled")
    end)
    local function getNearestPlayer()
        local localChar = LocalPlayer.Character
        if not (localChar and localChar:FindFirstChild("HumanoidRootPart")) then return nil end
        local myPos = localChar.HumanoidRootPart.Position
        local closest, dist = nil, math.huge
        for _, p in ipairs(self.Services.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < dist then closest, dist = p, d end
            end
        end
        return closest
    end
    local function getSelectedPlayer()
        if self.State.selectedPlayerName == "Nearest Player" then
            local n = getNearestPlayer()
            if n then applyHighlight(n) else clearHighlight() end
            return n
        elseif self.State.selectedPlayerName and self.Services.Players:FindFirstChild(self.State.selectedPlayerName) then
            local p = self.Services.Players[self.State.selectedPlayerName]
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                return p
            end
        end
        clearHighlight()
        return nil
    end
    local lastAttackTime = 0
    self.State.Connections.RenderStepped = self.Services.RunService.RenderStepped:Connect(function()
        local target = getSelectedPlayer()
        if (self.State.isFollowing or self.State.isAttaching) and target then
            local localChar, targetChar = LocalPlayer.Character, target.Character
            if localChar and targetChar then
                local part, targetPart = localChar:FindFirstChild("HumanoidRootPart"), targetChar:FindFirstChild("HumanoidRootPart")
                if part and targetPart then
                    local hum = localChar:FindFirstChildOfClass("Humanoid")
                    if hum then hum.AutoRotate = false end
                    if self.State.isAttaching then
                        part.CFrame = part.CFrame:Lerp(targetPart.CFrame, self.State.followSpeed)
                        local thum = targetChar:FindFirstChildOfClass("Humanoid")
                        if thum and thum.Jump then hum.Jump = true end
                    elseif self.State.isFollowing then
                        part.CFrame = part.CFrame:Lerp(CFrame.new(part.Position, targetPart.Position), self.State.followSpeed)
                        hum:MoveTo(targetPart.Position)
                    end
                end
            end
        else
            local c = LocalPlayer.Character
            if c and c:FindFirstChildOfClass("Humanoid") then c:FindFirstChildOfClass("Humanoid").AutoRotate = true end
        end
        if self.State.isChaosMode then
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local currentTime = tick()
                if currentTime - self.State.lastChaosTime >= self.State.chaosInterval then
                    self.State.lastChaosTime = currentTime
                    self.State.oscillationValue = -self.State.oscillationValue
                    local offsetX = math.sin(currentTime * 8) * self.State.flingStrength * 5
                    local offsetY = self.State.oscillationValue * self.State.flingStrength * 3
                    local offsetZ = math.cos(currentTime * 8) * self.State.flingStrength * 5
                    rootPart.CFrame = rootPart.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
                    local oscillationVelocity = Vector3.new(
                        math.sin(currentTime * 5) * self.State.flingStrength * 30,
                        self.State.oscillationValue * self.State.flingStrength * 15,
                        math.cos(currentTime * 5) * self.State.flingStrength * 30
                    )
                    rootPart.Velocity = rootPart.Velocity + oscillationVelocity
                end
            end
        end
        if self.State.isAutoAttacking and target then
            local localChar = LocalPlayer.Character
            if localChar then
                local currentTime = tick()
                local attackDelay = 1 / self.State.attackSpeed
                if currentTime - lastAttackTime >= attackDelay then
                    lastAttackTime = currentTime
                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                    local equippedTool = localChar:FindFirstChildOfClass("Tool")
                    if not equippedTool and backpack then
                        local tool = backpack:FindFirstChildOfClass("Tool")
                        if tool then
                            tool.Parent = localChar
                            equippedTool = tool
                        end
                    end
                    if equippedTool and equippedTool:FindFirstChild("Handle") then
                        local targetChar = target.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            local handle = equippedTool:FindFirstChild("Handle")
                            if handle then
                                handle.CFrame = CFrame.new(handle.Position, targetChar.HumanoidRootPart.Position)
                            end
                            equippedTool:Activate()
                        end
                    end
                end
            end
        end
    end)
    self.State.Connections.KeyDown = LocalPlayer:GetMouse().KeyDown:Connect(function(k)
        k = k:lower()
        if k == "x" then
            self.State.isFollowing = not self.State.isFollowing
            notify("Following", self.State.isFollowing and "Enabled" or "Disabled")
        elseif k == "z" then
            self.State.isAttaching = not self.State.isAttaching
            notify("Attach", self.State.isAttaching and "Enabled" or "Disabled")
        elseif k == "c" then
            self.State.isAutoAttacking = not self.State.isAutoAttacking
            notify("Auto Attack", self.State.isAutoAttacking and "ENABLED - Spamming M1" or "Disabled")
        elseif k == "v" then
            self.State.isChaosMode = not self.State.isChaosMode
            notify("Chaos Mode", self.State.isChaosMode and "ENABLED - Breaking Aimbots" or "Disabled")
        end
    end)
    self.State.isGuiBuilt = true
    DoNotif("Attacher module activated.", 2)
end
function Modules.Attacher:Toggle()
    if self.State.isGuiBuilt then
        self:Deactivate()
    else
        self:Activate()
    end
end
RegisterCommand({
    Name = "attacher",
    Aliases = {"attachui", "followui"},
    Description = "Toggles the Player Attacher/Follower UI."
}, function()
    if not Modules.Attacher.Toggle then
        local originalFunctions = loadfile("path/to/your/AttacherModule.lua")()
        Modules.Attacher.Activate = originalFunctions.Activate
        Modules.Attacher.Deactivate = originalFunctions.Deactivate
        Modules.Attacher.Toggle = originalFunctions.Toggle
    end
    Modules.Attacher:Toggle()
end)
Modules.StaffSentry = {
    State = {
        IsEnabled = false,
        AutoJoinConnection = nil,
        StaffGroups = {1200769, 2868472, 4199740}
    }
}
function Modules.StaffSentry:Scan()
    local found = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local isStaff = false
        for _, groupId in ipairs(self.State.StaffGroups) do
            if player:GetRankInGroup(groupId) > 0 then
                isStaff = true
                break
            end
        end
        if isStaff or player:IsFriendsWith(LocalPlayer.UserId) == false and (player.AccountAge < 5) then
            table.insert(found, player.Name)
        end
    end
    if #found > 0 then
        DoNotif("Staff/Suspects Found: " .. table.concat(found, ", "), 5)
    else
        DoNotif("No staff members detected in current server.", 3)
    end
end
function Modules.StaffSentry:Initialize()
    RegisterCommand({
        Name = "staffcheck",
        Aliases = {"scheck", "admins"},
        Description = "Scans the server for players in common staff groups or with suspicious account ages."
    }, function()
        self:Scan()
    end)
end
Modules.KnockbackNullifier = {
    State = {
        IsEnabled = false,
        Connection = nil
    }
}
function Modules.KnockbackNullifier:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        self.State.Connection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 0 and not UserInputService:GetFocusedTextBox() then
                    local moveDir = char:FindFirstChildOfClass("Humanoid").MoveDirection
                    if moveDir.Magnitude == 0 then
                        hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                    end
                end
            end
        end)
        DoNotif("Knockback Nullifier: ENABLED", 2)
    else
        if self.State.Connection then
            self.State.Connection:Disconnect()
            self.State.Connection = nil
        end
        DoNotif("Knockback Nullifier: DISABLED", 2)
    end
end
function Modules.KnockbackNullifier:Initialize()
    RegisterCommand({
        Name = "noknockb",
        Aliases = {"noknockback", "steady"},
        Description = "Negates external physics impulses to prevent being pushed around."
    }, function()
        self:Toggle()
    end)
end
Modules.AntiVoid = {
    State = {
        IsEnabled = false,
        Connection = nil,
    },
    Config = {
        SafetyBuffer = 20,
    }
}
function Modules.AntiVoid:_getSafeCFrame()
    local spawns = {}
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("SpawnLocation") and desc.Enabled then
            table.insert(spawns, desc)
        end
    end
    if #spawns > 0 then
        return spawns[1].CFrame + Vector3.new(0, 5, 0)
    end
    return CFrame.new(0, 100, 0)
end
function Modules.AntiVoid:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.Connection = RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local killHeight = Workspace.FallenPartsDestroyHeight
        if hrp.Position.Y < (killHeight + self.Config.SafetyBuffer) then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local targetCFrame = self:_getSafeCFrame()
            hrp.CFrame = targetCFrame
            DoNotif("Anti-Void: Saved from the abyss!", 2)
        end
    end)
    DoNotif("Anti-Void: SECURED", 2)
end
function Modules.AntiVoid:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then self.State.Connection:Disconnect() end
    DoNotif("Anti-Void: UNSECURED", 2)
end
function Modules.AntiVoid:Toggle()
    if self.State.IsEnabled then self:Disable() else self:Enable() end
end
RegisterCommand({
    Name = "antivoid",
    Aliases = {"av", "novoid", "safety"},
    Description = "Prevents you from dying to the void by teleporting you to safety."
}, function()
    Modules.AntiVoid:Toggle()
end)
Modules.codedoor = {
    State = {
        LastFoundCode = nil
    },
    Config = {
        Paths = {
            {Root = "CodeDoor", Target = "Code", Property = "Value"},
            {Root = "Staff_Code", Target = "Code.SurfaceGui.Desc", Property = "Text"}
        }
    }
}
function Modules.codedoor:GetCode()
    local foundCode = nil
    local workspaceService = game:GetService("Workspace")
    for _, config in ipairs(self.Config.Paths) do
        local rootObject = workspaceService:FindFirstChild(config.Root)
        if rootObject then
            local current = rootObject
            local segments = string.split(config.Target, ".")
            for _, segment in ipairs(segments) do
                current = current and current:FindFirstChild(segment)
            end
            if current then
                local success, val = pcall(function() return current[config.Property] end)
                if success and val ~= "" then
                    foundCode = tostring(val)
                    break
                end
            end
        end
    end
    if foundCode then
        self.State.LastFoundCode = foundCode
        DoNotif("Success: Code extracted.", 3)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Door Unlocker",
            Text = "Code: " .. foundCode,
            Duration = 9
        })
        if Modules.CommandBar and Modules.CommandBar.AddOutput then
            Modules.CommandBar:AddOutput("[DECRYPTED]: Door Code is " .. foundCode, Modules.CommandBar.Theme.Accent)
        end
    else
        DoNotif("Error: No codedoor detected in Workspace.", 3)
    end
end
function Modules.codedoor:Initialize()
    local module = self
    RegisterCommand({
        Name = "codedoor",
        Aliases = {"unlock", "getcode", "doorcode"},
        Description = "Scans and extracts the PIN from common free-model codedoors."
    }, function()
        module:GetCode()
    end)
end
Modules.AdvancedShiftLock = {
    State = {
        IsEnabled = false,
        IsLocked = false,
        UI = {},
        Connections = {},
        Originals = {},
        CurrentOffset = Vector3.zero
    },
    Config = {
        Icons = {
            On = "rbxasset://textures/ui/mouseLock_on.png",
            Off = "rbxasset://textures/ui/mouseLock_off.png"
        },
        CameraOffset = Vector3.new(1.75, 0, 0),
        Smoothing = 0.25,
        ToggleKey = Enum.KeyCode.LeftShift
    },
    Dependencies = {"Players", "TweenService", "UserInputService", "RunService", "Workspace", "CoreGui"},
    Services = {}
}
function Modules.AdvancedShiftLock:_makeDraggable(guiObject, dragHandle)
    local UIS = self.Services.UserInputService
    local dragging = false
    local dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            local changedConn; changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changedConn:Disconnect()
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
function Modules.AdvancedShiftLock:_updateLogic(deltaTime)
    local char = self.Services.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local camera = self.Services.Workspace.CurrentCamera
    if not (hum and hrp and camera and hum.Health > 0) then return end
    if self.State.IsLocked then
        local lookVector = camera.CFrame.LookVector
        local flatVector = Vector3.new(lookVector.X, 0, lookVector.Z)
        if flatVector.Magnitude > 1e-4 then
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + flatVector.Unit), 0.4)
        end
        hum.CameraOffset = hum.CameraOffset:Lerp(self.Config.CameraOffset, self.Config.Smoothing)
        self.Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        if hum.CameraOffset.Magnitude > 0.01 then
            hum.CameraOffset = hum.CameraOffset:Lerp(Vector3.zero, self.Config.Smoothing)
        end
    end
end
function Modules.AdvancedShiftLock:_setLockState(newState)
    local char = self.Services.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if newState and hum and hum.Sit then return end
    self.State.IsLocked = newState
    if newState then
        if hum then
            self.State.Originals.AutoRotate = hum.AutoRotate
            hum.AutoRotate = false
        end
    else
        if hum and self.State.Originals.AutoRotate ~= nil then
            hum.AutoRotate = self.State.Originals.AutoRotate
        end
        self.Services.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    local ui = self.State.UI
    if ui.Button then
        local targetColor = newState and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(0, 140, 255)
        local targetBg = newState and Color3.fromRGB(20, 35, 30) or Color3.fromRGB(25, 25, 30)
        self.Services.TweenService:Create(ui.Stroke, TweenInfo.new(0.2), {Color = targetColor, Thickness = newState and 3 or 2}):Play()
        self.Services.TweenService:Create(ui.Button, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        ui.Icon.Image = newState and self.Config.Icons.On or self.Config.Icons.Off
    end
end
function Modules.AdvancedShiftLock:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local ui = self.State.UI
    ui.ScreenGui = Instance.new("ScreenGui", self.Services.CoreGui)
    ui.ScreenGui.Name = "ForensicShiftLock_V2"
    ui.ScreenGui.ResetOnSpawn = false
    ui.Button = Instance.new("ImageButton", ui.ScreenGui)
    ui.Button.Size = UDim2.fromOffset(55, 55)
    ui.Button.Position = UDim2.new(1, -75, 1, -150)
    ui.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Instance.new("UICorner", ui.Button).CornerRadius = UDim.new(1, 0)
    ui.Stroke = Instance.new("UIStroke", ui.Button)
    ui.Stroke.Color = Color3.fromRGB(0, 140, 255)
    ui.Stroke.Thickness = 2
    ui.Icon = Instance.new("ImageLabel", ui.Button)
    ui.Icon.Size = UDim2.fromScale(0.6, 0.6)
    ui.Icon.Position = UDim2.fromScale(0.2, 0.2)
    ui.Icon.BackgroundTransparency = 1
    ui.Icon.Image = self.Config.Icons.Off
    self:_makeDraggable(ui.Button, ui.Button)
    self.State.Connections.Main = self.Services.RunService.RenderStepped:Connect(function(dt)
        self:_updateLogic(dt)
    end)
    self.State.Connections.Input = self.Services.UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Config.ToggleKey then
            self:_setLockState(not self.State.IsLocked)
        end
    end)
    ui.Button.Activated:Connect(function()
        self:_setLockState(not self.State.IsLocked)
    end)
    DoNotif("Advanced Shift-Lock V2 Enabled.", 3)
end
function Modules.AdvancedShiftLock:Disable()
    if not self.State.IsEnabled then return end
    self:_setLockState(false)
    for _, conn in pairs(self.State.Connections) do conn:Disconnect() end
    if self.State.UI.ScreenGui then self.State.UI.ScreenGui:Destroy() end
    self.State.IsEnabled = false
    table.clear(self.State.Connections)
    self.State.UI = {}
    DoNotif("Shift-Lock Disabled.", 2)
end
function Modules.AdvancedShiftLock:Initialize()
    local module = self
    module.Services = {}
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "shiftlock",
        Aliases = {"sl", "lockcam"},
        Description = "Toggles an advanced Over-The-Shoulder Shift Lock."
    }, function()
        if module.State.IsEnabled then
            module:Disable()
        else
            module:Enable()
        end
    end)
end
Modules.AntiTrip = {
    State = {
        IsEnabled = false,
        OriginalStateCache = setmetatable({}, {__mode = "k"}),
        Connections = {}
    },
    Config = {
        StatesToBlock = {
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.PlatformStanding
        }
    },
    Dependencies = {"Players", "RunService", "ReplicatedService", "ReplicatedStorage"},
    Services = {}
}
function Modules.AntiTrip:_forceRecovery(humanoid)
    if not humanoid then return end
    pcall(function()
        local character = humanoid.Parent
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.zero
        end
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
end
function Modules.AntiTrip:_applyToCharacter(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local savedStates = {}
    for _, stateType in ipairs(self.Config.StatesToBlock) do
        local success, isEnabled = pcall(humanoid.GetStateEnabled, humanoid, stateType)
        if success then
            savedStates[stateType] = isEnabled
            pcall(humanoid.SetStateEnabled, humanoid, stateType, false)
        end
    end
    self.State.OriginalStateCache[humanoid] = savedStates
    local loopConnection = self.Services.RunService.Stepped:Connect(function()
        local currentState = humanoid:GetState()
        for _, blockedState in ipairs(self.Config.StatesToBlock) do
            if currentState == blockedState then
                self:_forceRecovery(humanoid)
                break
            end
        end
    end)
    self.State.Connections[character] = loopConnection
end
function Modules.AntiTrip:_revertForCharacter(character)
    if not character then return end
    if self.State.Connections[character] then
        self.State.Connections[character]:Disconnect()
        self.State.Connections[character] = nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and self.State.OriginalStateCache[humanoid] then
        for stateType, wasEnabled in pairs(self.State.OriginalStateCache[humanoid]) do
            pcall(humanoid.SetStateEnabled, humanoid, stateType, wasEnabled)
        end
        self.State.OriginalStateCache[humanoid] = nil
    end
end
function Modules.AntiTrip:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then
        self:_applyToCharacter(localPlayer.Character)
    end
    self.State.Connections.CharacterAdded = localPlayer.CharacterAdded:Connect(function(char) self:_applyToCharacter(char) end)
    self.State.Connections.CharacterRemoving = localPlayer.CharacterRemoving:Connect(function(char) self:_revertForCharacter(char) end)
    DoNotif("Anti-Trip Enabled", 2)
end
function Modules.AntiTrip:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connections.CharacterAdded then self.State.Connections.CharacterAdded:Disconnect() end
    if self.State.Connections.CharacterRemoving then self.State.Connections.CharacterRemoving:Disconnect() end
    self.State.Connections.CharacterAdded, self.State.Connections.CharacterRemoving = nil, nil
    if self.Services.Players.LocalPlayer.Character then
        self:_revertForCharacter(self.Services.Players.LocalPlayer.Character)
    end
    DoNotif("Anti-Trip Disabled", 2)
end
function Modules.AntiTrip:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.AntiTrip:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "antitrip",
        Description = "Toggles a system to prevent your character from tripping or ragdolling."
    }, function()
        module:Toggle()
    end)
end
Modules.AdBlock = {
    State = {
        IsEnabled = false,
        Connections = {},
        RemovedAds = 0,
        Whitelist = {},
        ProcessedInstances = setmetatable({}, {__mode = "k"})
    },
    Dependencies = {"Workspace", "Players", "CoreGui"},
    Services = {},
    Config = {
        AggressiveMode = false,
        RemoveBillboards = true,
        RemoveSurfaceGuis = false,
        ProtectCoreGuis = true,
        DebugMode = false,
        WhitelistPatterns = {
            "^roblox",
            "^core",
            "^system",
            "health", "hotbar", "backpack", "chat",
            "leaderboard", "playerlist", "nametag",
            "menu", "settings", "inventory", "hud"
        },
        BlacklistPatterns = {
            "ad[sv]?$", "advert", "sponsor", "promo",
            "donation", "robux", "gamepass", "purchase",
            "vip", "premium", "buy", "shop"
        }
    }
}
local function debugLog(message)
    if Modules.AdBlock.Config.DebugMode then
        print("[AdBlock Debug]", message)
    end
end
local function isWhitelisted(name)
    name = name:lower()
    for instance in pairs(Modules.AdBlock.State.Whitelist) do
        if typeof(instance) == "Instance" and instance.Name:lower() == name then
            return true
        end
    end
    for _, pattern in ipairs(Modules.AdBlock.Config.WhitelistPatterns) do
        if name:match(pattern) then
            debugLog("Whitelisted by pattern: " .. name .. " (" .. pattern .. ")")
            return true
        end
    end
    return false
end
local function isBlacklisted(name)
    name = name:lower()
    for _, pattern in ipairs(Modules.AdBlock.Config.BlacklistPatterns) do
        if name:match(pattern) then
            debugLog("Blacklisted by pattern: " .. name .. " (" .. pattern .. ")")
            return true
        end
    end
    return false
end
local function hasAdCharacteristics(gui)
    local suspicionScore = 0
    local imageLabels = gui:GetDescendants()
    local imageCount = 0
    for _, obj in ipairs(imageLabels) do
        if obj:IsA("ImageLabel") then
            imageCount = imageCount + 1
        end
    end
    if imageCount > 3 then
        suspicionScore = suspicionScore + 2
    end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            local text = obj.Text:lower()
            if text:match("buy") or text:match("purchase") or text:match("robux") 
                or text:match("vip") or text:match("premium") or text:match("gamepass") then
                suspicionScore = suspicionScore + 3
            end
        end
    end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local image = obj.Image
            if image and (image:match("rbxhttp") or image:match("http")) then
                suspicionScore = suspicionScore + 1
            end
        end
    end
    if gui:IsA("ScreenGui") then
        for _, frame in ipairs(gui:GetChildren()) do
            if frame:IsA("GuiObject") then
                local size = frame.AbsoluteSize
                local position = frame.AbsolutePosition
                if size.Y < 100 and size.X > 200 then
                    suspicionScore = suspicionScore + 1
                end
            end
        end
    end
    return suspicionScore >= (Modules.AdBlock.Config.AggressiveMode and 2 or 4)
end
local function isCoreGui(gui)
    if gui:IsDescendantOf(game:GetService("CoreGui")) then
        return true
    end
    local name = gui.Name:lower()
    if name:match("^roblox") or name:match("^core") then
        return true
    end
    return false
end
function Modules.AdBlock:_destroy(instance, reason)
    if not instance or not instance.Parent then return end
    if isWhitelisted(instance.Name) then
        debugLog("Skipped whitelisted: " .. instance.Name)
        return
    end
    if self.Config.ProtectCoreGuis and isCoreGui(instance) then
        debugLog("Protected core GUI: " .. instance.Name)
        return
    end
    local success = pcall(function()
        debugLog("Removing: " .. instance.Name .. " (" .. (reason or "unknown reason") .. ")")
        instance:Destroy()
        self.State.RemovedAds = self.State.RemovedAds + 1
    end)
    if not success then
        debugLog("Failed to remove: " .. instance.Name)
    end
end
function Modules.AdBlock:_processObject(obj)
    if not obj or not obj.Parent then return end
    if self.State.ProcessedInstances[obj] then
        return
    end
    self.State.ProcessedInstances[obj] = true
    if isWhitelisted(obj.Name) then
        return
    end
    if self.Config.RemoveBillboards and obj:IsA("BillboardGui") then
        local parent = obj.Parent
        if parent and parent:IsA("BasePart") then
            local humanoid = parent.Parent and parent.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then
                debugLog("Skipped character billboard: " .. obj.Name)
                return
            end
        end
        if isBlacklisted(obj.Name) then
            self:_destroy(obj, "blacklisted billboard")
            return
        end
    end
    if self.Config.RemoveSurfaceGuis and obj:IsA("SurfaceGui") then
        if isBlacklisted(obj.Name) or (self.Config.AggressiveMode and hasAdCharacteristics(obj)) then
            self:_destroy(obj, "suspicious surface GUI")
            return
        end
    end
    if obj:IsA("ScreenGui") then
        local shouldRemove = false
        local reason = ""
        if isBlacklisted(obj.Name) then
            shouldRemove = true
            reason = "blacklisted name"
        end
        if not shouldRemove and hasAdCharacteristics(obj) then
            shouldRemove = true
            reason = "ad characteristics detected"
        end
        if not shouldRemove and obj:FindFirstChild("AdGuiAdornee", true) then
            shouldRemove = true
            reason = "AdGuiAdornee marker"
        end
        if shouldRemove then
            self:_destroy(obj, reason)
            return
        end
    end
    if obj:IsA("BasePart") and self.Config.RemoveBillboards then
        local billboard = obj:FindFirstChildWhichIsA("BillboardGui")
        if billboard and (isBlacklisted(obj.Name) or isBlacklisted(billboard.Name)) then
            self:_destroy(obj, "part with ad billboard")
            return
        end
    end
    if self.Config.AggressiveMode and isBlacklisted(obj.Name) then
        if obj:IsA("GuiObject") or obj:IsA("LayerCollector") then
            self:_destroy(obj, "blacklisted name")
        end
    end
end
function Modules.AdBlock:Enable()
    if self.State.IsEnabled then
        DoNotif("AdBlock already enabled.", 2)
        return
    end
    self.State.IsEnabled = true
    self.State.RemovedAds = 0
    local function scan(container, containerName)
        debugLog("Scanning: " .. containerName)
        local count = 0
        for _, obj in ipairs(container:GetDescendants()) do
            self:_processObject(obj)
            count = count + 1
        end
        debugLog("Scanned " .. count .. " objects in " .. containerName)
    end
    scan(self.Services.Workspace, "Workspace")
    local player = self.Services.Players.LocalPlayer
    if player then
        local gui = player:FindFirstChild("PlayerGui")
        if not gui then
            gui = player:WaitForChild("PlayerGui", 5)
        end
        if gui then
            scan(gui, "PlayerGui")
        end
    end
    if not self.Config.ProtectCoreGuis then
        scan(self.Services.CoreGui, "CoreGui")
    end
    local function watch(container, containerName)
        local conn = container.DescendantAdded:Connect(function(obj)
            if self.State.IsEnabled then
                task.defer(function()
                    self:_processObject(obj)
                end)
            end
        end)
        table.insert(self.State.Connections, conn)
        debugLog("Watching: " .. containerName)
    end
    watch(self.Services.Workspace, "Workspace")
    if player and player:FindFirstChild("PlayerGui") then
        watch(player.PlayerGui, "PlayerGui")
    end
    if not self.Config.ProtectCoreGuis then
        watch(self.Services.CoreGui, "CoreGui")
    end
    DoNotif("AdBlock enabled. Removed " .. self.State.RemovedAds .. " ads.", 3)
end
function Modules.AdBlock:Disable()
    if not self.State.IsEnabled then
        DoNotif("AdBlock not active.", 2)
        return
    end
    self.State.IsEnabled = false
    for _, c in ipairs(self.State.Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(self.State.Connections)
    table.clear(self.State.ProcessedInstances)
    DoNotif("AdBlock disabled. Total ads removed: " .. self.State.RemovedAds, 3)
end
function Modules.AdBlock:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.AdBlock:AddWhitelist(instance)
    if typeof(instance) == "Instance" then
        self.State.Whitelist[instance] = true
        debugLog("Added to whitelist: " .. instance.Name)
        return true
    end
    return false
end
function Modules.AdBlock:RemoveWhitelist(instance)
    if self.State.Whitelist[instance] then
        self.State.Whitelist[instance] = nil
        debugLog("Removed from whitelist: " .. instance.Name)
        return true
    end
    return false
end
function Modules.AdBlock:GetStats()
    return {
        Enabled = self.State.IsEnabled,
        RemovedAds = self.State.RemovedAds,
        WhitelistedCount = 0
    }
end
function Modules.AdBlock:Initialize()
    for _, serviceName in ipairs(self.Dependencies) do
        self.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "adblock",
        Aliases = {"removeads", "blockads"},
        Description = "Toggles automatic ad removal."
    }, function()
        self:Toggle()
    end)
    RegisterCommand({
        Name = "adblockstats",
        Aliases = {"abstats"},
        Description = "Shows AdBlock statistics."
    }, function()
        local stats = self:GetStats()
        print("=== AdBlock Stats ===")
        print("Enabled:", stats.Enabled)
        print("Ads Removed:", stats.RemovedAds)
    end)
    RegisterCommand({
        Name = "adblockmode",
        Aliases = {"abmode"},
        Description = "Toggle aggressive mode."
    }, function(args)
        self.Config.AggressiveMode = not self.Config.AggressiveMode
        DoNotif("AdBlock Aggressive Mode: " .. tostring(self.Config.AggressiveMode), 2)
    end)
end
Modules.Fakeout = {
    State = {
        IsExecuting = false
    },
    Dependencies = {"Players", "Workspace"},
    Services = {}
}
function Modules.Fakeout:Execute()
    if self.State.IsExecuting then
        DoNotif("A fakeout is already in progress.", 1.5)
        return
    end
    local localPlayer = self.Services.Players.LocalPlayer
    local character = localPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        DoNotif("Fakeout failed: Character root not found.", 2)
        return
    end
    self.State.IsExecuting = true
    task.spawn(function()
        local originalCFrame = rootPart.CFrame
        local originalDestroyHeight = self.Services.Workspace.FallenPartsDestroyHeight
        local wasAntiVoidEnabled = false
        if Modules.AntiVoid and Modules.AntiVoid.State.IsEnabled then
            wasAntiVoidEnabled = true
            Modules.AntiVoid:Disable()
        end
        local success, err = pcall(function()
            self.Services.Workspace.FallenPartsDestroyHeight = -1e9
            rootPart.CFrame = CFrame.new(originalCFrame.Position.X, originalDestroyHeight - 50, originalCFrame.Position.Z)
            task.wait(1)
            if rootPart and rootPart.Parent then
                rootPart.CFrame = originalCFrame
            end
        end)
        if not success then
            warn("[Fakeout] Sequence failed:", err)
        end
        self.Services.Workspace.FallenPartsDestroyHeight = originalDestroyHeight
        if wasAntiVoidEnabled and Modules.AntiVoid then
            Modules.AntiVoid:Enable()
        end
        self.State.IsExecuting = false
    end)
end
function Modules.Fakeout:Initialize()
    local module = self
    for _, serviceName in ipairs(self.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "fakeout",
        Description = "Teleports you to the void and back"
    }, function()
        module:Execute()
    end)
end
Modules.AntiPlayerPhysics = {
    State = {
        IsEnabled = false,
        SteppedConnection = nil,
        OriginalProperties = setmetatable({}, {__mode = "k"})
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService")
    }
}
function Modules.AntiPlayerPhysics:_revertCharacter(character)
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and self.State.OriginalProperties[part] then
            part.CanCollide = self.State.OriginalProperties[part].CanCollide
            part.Massless = self.State.OriginalProperties[part].Massless
            self.State.OriginalProperties[part] = nil
        end
    end
end
function Modules.AntiPlayerPhysics:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.SteppedConnection = self.Services.RunService.Stepped:Connect(function()
        for _, player in ipairs(self.Services.Players:GetPlayers()) do
            if player ~= self.Services.Players.LocalPlayer and player.Character then
                pcall(function()
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            if not self.State.OriginalProperties[part] then
                                self.State.OriginalProperties[part] = {
                                    CanCollide = part.CanCollide,
                                    Massless = part.Massless
                                }
                            end
                            part.CanCollide = false
                            if part.Name == "Torso" then
                                part.Massless = true
                            end
                            part.Velocity = Vector3.new()
                            part.RotVelocity = Vector3.new()
                        end
                    end
                end)
            end
        end
    end)
    DoNotif("Anti-Player Physics: ENABLED.", 2)
end
function Modules.AntiPlayerPhysics:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.SteppedConnection then
        self.State.SteppedConnection:Disconnect()
        self.State.SteppedConnection = nil
    end
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        if player.Character then
            self:_revertCharacter(player.Character)
        end
    end
    table.clear(self.State.OriginalProperties)
    DoNotif("Anti-Player Physics: DISABLED.", 2)
end
function Modules.AntiPlayerPhysics:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.AntiPlayerPhysics:Initialize()
    local module = self
    RegisterCommand({
        Name = "antifling",
        Aliases = {"nofling"},
        Description = "Toggles a simple anti-fling that makes other players non-collidable."
    }, function()
        module:Toggle()
    end)
end
Modules.AntiKill = {
    State = {
        IsEnabled = false,
        RenderConnection = nil,
        CameraConnection = nil
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        Workspace = game:GetService("Workspace")
    }
}
function Modules.AntiKill:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local Player = self.Services.Players.LocalPlayer
    local Camera = self.Services.Workspace.CurrentCamera
    local function onCameraChanged()
       Camera = self.Services.Workspace.CurrentCamera
    end
    self.State.CameraConnection = self.Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(onCameraChanged)
    local function protectionLoop()
        local Character = Player.Character
        if not Character then return end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not (Humanoid and RootPart) then return end
        if self.Services.UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            local _, cameraY, _ = Camera.CFrame:ToEulerAnglesYXZ()
            RootPart.CFrame = CFrame.new(RootPart.Position) * CFrame.Angles(0, cameraY, 0)
        end
        Humanoid.Sit = true
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    end
    self.State.RenderConnection = self.Services.RunService.RenderStepped:Connect(protectionLoop)
    DoNotif("Anti-Kill System: ENABLED.", 2)
end
function Modules.AntiKill:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.RenderConnection then
        self.State.RenderConnection:Disconnect()
        self.State.RenderConnection = nil
    end
    if self.State.CameraConnection then
        self.State.CameraConnection:Disconnect()
        self.State.CameraConnection = nil
    end
    pcall(function()
        local Humanoid = self.Services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.Sit = false
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end
    end)
    DoNotif("Anti-Kill System: DISABLED.", 2)
end
function Modules.AntiKill:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.AntiKill:Initialize()
    local module = self
    RegisterCommand({
        Name = "antikill",
        Aliases = {},
        Description = "Toggles a client-sided system to resist death and character manipulation."
    }, function()
        module:Toggle()
    end)
end
Modules.SpectateController = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Connections = {}
    },
    Services = {
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace")
    }
}
function Modules.SpectateController:_cleanup()
    for _, conn in pairs(self.State.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.State.Connections)
    self.State.IsEnabled = false
    self.State.TargetPlayer = nil
end
function Modules.SpectateController:Disable()
    if not self.State.IsEnabled then return end
    local localPlayer = self.Services.Players.LocalPlayer
    self:_cleanup()
    if self.Services.Workspace.CurrentCamera and localPlayer.Character then
        self.Services.Workspace.CurrentCamera.CameraSubject = localPlayer.Character
    end
    DoNotif("Spectate disabled.", 2)
end
function Modules.SpectateController:Enable(targetPlayer: Player)
    self:Disable()
    if not targetPlayer or targetPlayer == self.Services.Players.LocalPlayer then
        return DoNotif("Invalid or self-targeted player.", 3)
    end
    if not targetPlayer.Character then
        return DoNotif("Target player does not have a character to spectate.", 3)
    end
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    local camera = self.Services.Workspace.CurrentCamera
    camera.CameraSubject = targetPlayer.Character
    local function resetView()
        if self.State.IsEnabled and self.State.TargetPlayer and self.State.TargetPlayer.Character then
            if camera.CameraSubject ~= self.State.TargetPlayer.Character then
                camera.CameraSubject = self.State.TargetPlayer.Character
            end
        else
            self:Disable()
        end
    end
    self.State.Connections.TargetRespawn = targetPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait()
        resetView()
    end)
    self.State.Connections.CameraGuard = camera:GetPropertyChangedSignal("CameraSubject"):Connect(resetView)
    self.State.Connections.LocalPlayerRespawn = self.Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        resetView()
    end)
    DoNotif("Now spectating " .. targetPlayer.Name, 2)
end
function Modules.SpectateController:Initialize()
    RegisterCommand({
        Name = "view",
        Aliases = {"spectate"},
        Description = "Spectates a specified player."
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;view <PlayerName>", 3)
        end
        local target = Utilities.findPlayer(args[1])
        if target then
            self:Enable(target)
        else
            DoNotif("Player '" .. args[1] .. "' not found.", 3)
        end
    end)
    RegisterCommand({
        Name = "unview",
        Aliases = {"unspectate"},
        Description = "Stops spectating and returns to your character."
    }, function()
        self:Disable()
    end)
end
Modules.AstralHead = {
State = {
IsEnabled = false,
OriginalProperties = {},
Connections = {}
}
}
function Modules.AstralHead:_getCharacterHeadParts(character)
    local parts = {}
    if not character then return parts end
        local head = character:FindFirstChild("Head")
        if head then table.insert(parts, head) end
            for _, accessory in ipairs(character:GetChildren()) do
                if accessory:IsA("Accessory") then
                    local handle = accessory:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then
                        table.insert(parts, handle)
                    end
                end
            end
            return parts
        end
        function Modules.AstralHead:_enableForCharacter(character)
            local self = Modules.AstralHead
            if not character then return end
                local partsToModify = self:_getCharacterHeadParts(character)
                for _, part in ipairs(partsToModify) do
                    if not self.State.OriginalProperties[part] then
                        self.State.OriginalProperties[part] = {
                        Transparency = part.Transparency,
                        CanQuery = part.CanQuery,
                        CanTouch = part.CanTouch
                        }
                    end
                    part.Transparency = 1
                    part.CanQuery = false
                    part.CanTouch = false
                end
            end
            function Modules.AstralHead:_disableForCharacter(character)
                local self = Modules.AstralHead
                for part, properties in pairs(self.State.OriginalProperties) do
                    pcall(function()
                    if part and part.Parent then
                        part.Transparency = properties.Transparency
                        part.CanQuery = properties.CanQuery
                        part.CanTouch = properties.CanTouch
                    end
                end)
            end
            table.clear(self.State.OriginalProperties)
        end
        function Modules.AstralHead:Toggle()
            local self = Modules.AstralHead
            self.State.IsEnabled = not self.State.IsEnabled
            if self.State.IsEnabled then
                DoNotif("Astral Head Enabled. Head is now untargetable.", 2)
                if LocalPlayer.Character then
                    self:_enableForCharacter(LocalPlayer.Character)
                end
            else
            DoNotif("Astral Head Disabled. Head restored.", 2)
            if LocalPlayer.Character then
                self:_disableForCharacter(LocalPlayer.Character)
            else
            table.clear(self.State.OriginalProperties)
        end
    end
end
function Modules.AstralHead:Initialize()
    local module = self
    module.State.Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.1)
    if module.State.IsEnabled then
        module:_enableForCharacter(character)
    end
end)
module.State.Connections.CharacterRemoving = LocalPlayer.CharacterRemoving:Connect(function(character)
if module.State.IsEnabled then
    module:_disableForCharacter(character)
end
end)
RegisterCommand({
Name = "astralhead",
Aliases = {"hidehead", "nohead"},
Description = "Toggles head invisibility to counter aimbots."
}, function()
module:Toggle()
end)
end
Modules.LocalAntiTeamChange = {
State = {
IsEnabled = false,
OriginalTeam = nil,
PropertyConnection = nil
},
Dependencies = {"Players"}
}
function Modules.LocalAntiTeamChange:Enable()
    if self.State.IsEnabled then return end
        local localPlayer = self.Services.Players.LocalPlayer
        if not localPlayer then
            warn("[LocalAntiTeamChange] Could not find LocalPlayer to monitor.")
            return
        end
        self.State.IsEnabled = true
        self.State.OriginalTeam = localPlayer.Team
        if self.State.PropertyConnection then self.State.PropertyConnection:Disconnect() end
            self.State.PropertyConnection = localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
            if self.State.IsEnabled and localPlayer.Team ~= self.State.OriginalTeam then
                pcall(function()
                localPlayer.Team = self.State.OriginalTeam
                DoNotif("Reverted personal team change.", 2)
            end)
        end
    end)
    DoNotif("Personal Team Lock: [Enabled]", 3)
end
function Modules.LocalAntiTeamChange:Disable()
    if not self.State.IsEnabled then return end
        self.State.IsEnabled = false
        if self.State.PropertyConnection then
            self.State.PropertyConnection:Disconnect()
            self.State.PropertyConnection = nil
        end
        self.State.OriginalTeam = nil
        DoNotif("Personal Team Lock: [Disabled]", 3)
    end
    function Modules.LocalAntiTeamChange:Toggle()
        if self.State.IsEnabled then
            self:Disable()
        else
        self:Enable()
    end
end
function Modules.LocalAntiTeamChange:Initialize()
    local module = self
    module.Services = {}
    for _, serviceName in ipairs(module.Dependencies or {}) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
    Name = "lockteam",
    Aliases = {"localantiteamchange", "latc"},
    Description = "Toggles a lock that prevents YOUR team from being changed."
    }, function(args)
    module:Toggle()
end)
end
Modules.HumanoidIntegrity = {
State = {
IsEnabled = false,
Connections = {}
},
Dependencies = {"Players"}
}
function Modules.HumanoidIntegrity:_protectCharacter(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
        self:_cleanupCharacter(character)
        local charConnections = { Character = character }
        charConnections.StateChanged = humanoid.StateChanged:Connect(function(old, new)
        if not self.State.IsEnabled then return end
            if new == Enum.HumanoidStateType.Ragdoll or new == Enum.HumanoidStateType.Physics or new == Enum.HumanoidStateType.FallingDown then
                pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.GettingUp)
            end
        end)
        charConnections.JointRemoved = character.DescendantRemoving:Connect(function(descendant)
        if not self.State.IsEnabled then return end
            if descendant:IsA("Motor6D") then
                task.defer(humanoid.BuildRigFromAttachments, humanoid)
            end
        end)
        charConnections.PlatformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not self.State.IsEnabled then return end
            if humanoid.PlatformStand then
                humanoid.PlatformStand = false
            end
        end)
        self.State.Connections[character] = charConnections
    end
    function Modules.HumanoidIntegrity:_cleanupCharacter(character)
        if self.State.Connections[character] then
            for _, conn in pairs(self.State.Connections[character]) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            self.State.Connections[character] = nil
        end
    end
    function Modules.HumanoidIntegrity:Enable()
        if self.State.IsEnabled then return end
            self.State.IsEnabled = true
            local localPlayer = self.Services.Players.LocalPlayer
            if localPlayer.Character then
                self:_protectCharacter(localPlayer.Character)
            end
            self.State.Connections.CharacterAdded = localPlayer.CharacterAdded:Connect(function(char)
            self:_protectCharacter(char)
        end)
        self.State.Connections.CharacterRemoving = localPlayer.CharacterRemoving:Connect(function(char)
        self:_cleanupCharacter(char)
    end)
    DoNotif("Humanoid Integrity System: [Enabled]", 3)
end
function Modules.HumanoidIntegrity:Disable()
    if not self.State.IsEnabled then return end
        self.State.IsEnabled = false
        for key, conn in pairs(self.State.Connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            elseif type(conn) == "table" then
                self:_cleanupCharacter(key)
            end
        end
        table.clear(self.State.Connections)
        DoNotif("Humanoid Integrity System: [Disabled]", 3)
    end
    function Modules.HumanoidIntegrity:Toggle()
        if self.State.IsEnabled then
            self:Disable()
        else
        self:Enable()
    end
end
function Modules.HumanoidIntegrity:Initialize()
    local module = self
    module.Services = { Players = game:GetService("Players") }
    RegisterCommand({
    Name = "antiragdoll",
    Aliases = {"noragdoll", "integrity"},
    Description = "Toggles a system to aggressively counter character ragdolling and joint breaking."
    }, function()
    module:Toggle()
end)
end
Modules.UniversalExploitDetector = {
    State = {
        Enabled = false,
        TrackedPlayers = {},
        SuspicionScores = {},
        ConfirmedExploiters = {},
        Connections = {},
        HighlightCache = {},
        ConfidenceThreshold = 75,
        ScanInterval = 0.5,
        HistoryDuration = 10,
        EnableESP = true,
        EnableNotifications = true,
        AutoCounter = false,
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        Workspace = game:GetService("Workspace"),
    }
}
local DetectionPatterns = {
    MovementAnomaly = {
        weight = 20,
        check = function(player, data)
            if not player.Character then return 0 end
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return 0 end
            local currentPos = hrp.Position
            local lastPos = data.LastPosition
            local lastTime = data.LastPosTime or tick()
            local currentTime = tick()
            if lastPos then
                local distance = (currentPos - lastPos).Magnitude
                local timeDelta = currentTime - lastTime
                if timeDelta > 0 then
                    local speed = distance / timeDelta
                    if speed > 100 then
                        return 95
                    elseif speed > 70 then
                        return 60
                    elseif speed > 50 then
                        return 30
                    end
                end
            end
            data.LastPosition = currentPos
            data.LastPosTime = currentTime
            return 0
        end
    },
    VerticalAnomaly = {
        weight = 15,
        check = function(player, data)
            if not player.Character then return 0 end
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return 0 end
            local yPos = hrp.Position.Y
            if yPos > 200 then
                data.HighAltitudeTime = (data.HighAltitudeTime or 0) + 1
                if data.HighAltitudeTime > 5 then
                    return 80
                elseif data.HighAltitudeTime > 3 then
                    return 50
                end
            else
                data.HighAltitudeTime = 0
            end
            return 0
        end
    },
    SpawnAnomaly = {
        weight = 25,
        check = function(player, data)
            if not player.Character then return 0 end
            local currentChildCount = #player.Character:GetChildren()
            local lastCount = data.LastChildCount or currentChildCount
            local childDelta = currentChildCount - lastCount
            data.LastChildCount = currentChildCount
            if childDelta > 10 then
                return 90
            elseif childDelta > 5 then
                return 60
            end
            return 0
        end
    },
    HumanoidAnomaly = {
        weight = 30,
        check = function(player, data)
            if not player.Character then return 0 end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return 0 end
            local suspicion = 0
            if hum.WalkSpeed > 100 then
                suspicion = suspicion + 70
            elseif hum.WalkSpeed > 50 then
                suspicion = suspicion + 30
            end
            if hum.JumpPower > 100 or hum.JumpHeight > 20 then
                suspicion = suspicion + 50
            end
            if hum.Health > hum.MaxHealth then
                suspicion = suspicion + 85
            end
            if hum.Health == hum.MaxHealth then
                data.MaxHealthTime = (data.MaxHealthTime or 0) + 1
                if data.MaxHealthTime > 20 then
                    suspicion = suspicion + 20
                end
            else
                data.MaxHealthTime = 0
            end
            return math.min(suspicion, 100)
        end
    },
    AnimationAnomaly = {
        weight = 15,
        check = function(player, data)
            if not player.Character then return 0 end
            local animator = player.Character:FindFirstChild("Humanoid")
                and player.Character.Humanoid:FindFirstChildOfClass("Animator")
            if not animator then return 0 end
            local suspicion = 0
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Speed > 3 then
                    suspicion = suspicion + 70
                elseif track.Speed > 2 then
                    suspicion = suspicion + 40
                elseif track.Speed > 1.5 then
                    suspicion = suspicion + 20
                end
            end
            return math.min(suspicion, 100)
        end
    },
    WorkspacePollution = {
        weight = 25,
        check = function(player, data)
            local suspicion = 0
            local suspiciousPatterns = {
                "Acid",
                "Landmine",
                "Exploit",
                "Spam",
                "Clone"
            }
            local pollutionCount = 0
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    for _, pattern in ipairs(suspiciousPatterns) do
                        if obj.Name:find(pattern) then
                            if obj:FindFirstChild("Creator") and obj.Creator.Value == player then
                                pollutionCount = pollutionCount + 1
                            end
                        end
                    end
                end
            end
            if pollutionCount > 50 then
                suspicion = 95
            elseif pollutionCount > 20 then
                suspicion = 70
            elseif pollutionCount > 10 then
                suspicion = 40
            end
            return suspicion
        end
    },
    RemoteSpam = {
        weight = 35,
        check = function(player, data)
            local remoteCallCount = data.RemoteCallCount or 0
            local timeSinceReset = (tick() - (data.RemoteResetTime or tick()))
            if timeSinceReset >= 1 then
                data.LastRemoteRate = remoteCallCount
                data.RemoteCallCount = 0
                data.RemoteResetTime = tick()
                remoteCallCount = 0
            end
            local rate = data.LastRemoteRate or 0
            if rate > 100 then
                return 95
            elseif rate > 50 then
                return 75
            elseif rate > 30 then
                return 40
            end
            return 0
        end
    },
    CharacterModification = {
        weight = 10,
        check = function(player, data)
            if not player.Character then return 0 end
            local suspicion = 0
            local criticalParts = {"Head", "HumanoidRootPart"}
            for _, partName in ipairs(criticalParts) do
                if not player.Character:FindFirstChild(partName) then
                    suspicion = suspicion + 40
                end
            end
            local partCount = 0
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj:IsA("BasePart") then
                    partCount = partCount + 1
                end
            end
            if partCount > 100 then
                suspicion = suspicion + 30
            end
            return math.min(suspicion, 100)
        end
    },
}
function Modules.UniversalExploitDetector:InitializePlayerTracking(player)
    if self.State.TrackedPlayers[player] then return end
    self.State.TrackedPlayers[player] = {
        JoinTime = tick(),
        LastPosition = nil,
        LastPosTime = nil,
        LastChildCount = 0,
        HighAltitudeTime = 0,
        MaxHealthTime = 0,
        RemoteCallCount = 0,
        RemoteResetTime = tick(),
        LastRemoteRate = 0,
        DetectionHistory = {},
    }
    self.State.SuspicionScores[player] = 0
end
function Modules.UniversalExploitDetector:AnalyzePlayer(player)
    if not player.Character then return end
    local data = self.State.TrackedPlayers[player]
    if not data then
        self:InitializePlayerTracking(player)
        data = self.State.TrackedPlayers[player]
    end
    local totalSuspicion = 0
    local detections = {}
    for patternName, pattern in pairs(DetectionPatterns) do
        local score = pattern.check(player, data)
        if score > 0 then
            totalSuspicion = totalSuspicion + (score * pattern.weight / 100)
            table.insert(detections, {
                pattern = patternName,
                score = score,
                weight = pattern.weight
            })
        end
    end
    local currentScore = self.State.SuspicionScores[player] or 0
    local decayRate = 2
    if totalSuspicion > 0 then
        self.State.SuspicionScores[player] = math.min(currentScore + totalSuspicion, 100)
    else
        self.State.SuspicionScores[player] = math.max(currentScore - decayRate, 0)
    end
    if #detections > 0 then
        table.insert(data.DetectionHistory, {
            time = tick(),
            detections = detections,
            totalScore = totalSuspicion
        })
        while #data.DetectionHistory > 20 do
            table.remove(data.DetectionHistory, 1)
        end
    end
    local finalScore = self.State.SuspicionScores[player]
    local wasExploiter = self.State.ConfirmedExploiters[player]
    local isExploiter = finalScore >= self.State.ConfidenceThreshold
    if isExploiter and not wasExploiter then
        self:MarkAsExploiter(player, detections)
    elseif not isExploiter and wasExploiter then
        self:ClearExploiter(player)
    elseif isExploiter then
        self:UpdateExploiterESP(player, finalScore)
    end
end
function Modules.UniversalExploitDetector:MarkAsExploiter(player, detections)
    self.State.ConfirmedExploiters[player] = true
    if self.State.EnableESP then
        self:CreateExploiterHighlight(player)
    end
    if self.State.EnableNotifications then
        local patterns = {}
        for _, det in ipairs(detections) do
            table.insert(patterns, det.pattern)
        end
        local score = self.State.SuspicionScores[player]
        DoNotif(string.format(
            "🎯 EXPLOITER DETECTED: %s [%d%% confidence]",
            player.Name,
            math.floor(score)
        ), 5)
        if #patterns > 0 then
            DoNotif("Detected: " .. table.concat(patterns, ", "), 4)
        end
    end
    if self.State.AutoCounter then
        self:EnableCounterMeasures(player, detections)
    end
end
function Modules.UniversalExploitDetector:ClearExploiter(player)
    self.State.ConfirmedExploiters[player] = nil
    if self.State.HighlightCache[player] then
        self.State.HighlightCache[player]:Destroy()
        self.State.HighlightCache[player] = nil
    end
    if self.State.EnableNotifications then
        DoNotif(string.format("✓ %s no longer flagged", player.Name), 2)
    end
end
function Modules.UniversalExploitDetector:CreateExploiterHighlight(player)
    if not player.Character then return end
    if self.State.HighlightCache[player] then
        self.State.HighlightCache[player]:Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ExploiterESP"
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    self.State.HighlightCache[player] = highlight
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if self.State.ConfirmedExploiters[player] then
            self:CreateExploiterHighlight(player)
        end
    end)
end
function Modules.UniversalExploitDetector:UpdateExploiterESP(player, score)
    local highlight = self.State.HighlightCache[player]
    if not highlight or not highlight.Parent then
        self:CreateExploiterHighlight(player)
        return
    end
    local intensity = score / 100
    highlight.FillColor = Color3.fromRGB(255, 255 * (1 - intensity), 0)
end
function Modules.UniversalExploitDetector:EnableCounterMeasures(player, detections)
    for _, det in ipairs(detections) do
        if det.pattern == "RemoteSpam" and Modules.ApexCounter then
            Modules.ApexCounter:NullifySkidRemotes()
        elseif det.pattern == "SpawnAnomaly" and Modules.ApexCounter then
            Modules.ApexCounter:ToggleLagShield(true)
        end
    end
end
function Modules.UniversalExploitDetector:HookRemoteTracking()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end
function Modules.UniversalExploitDetector:StartScanning()
    if self.State.Connections.Scanner then return end
    self.State.Connections.Scanner = self.Services.RunService.Heartbeat:Connect(function()
        if not self.State.Enabled then return end
        for _, player in ipairs(self.Services.Players:GetPlayers()) do
            if player ~= self.Services.Players.LocalPlayer then
                pcall(function()
                    self:AnalyzePlayer(player)
                end)
            end
        end
        task.wait(self.State.ScanInterval)
    end)
end
function Modules.UniversalExploitDetector:StopScanning()
    if self.State.Connections.Scanner then
        self.State.Connections.Scanner:Disconnect()
        self.State.Connections.Scanner = nil
    end
end
function Modules.UniversalExploitDetector:Initialize()
    local module = self
    RegisterCommand({
        Name = "detectexploits",
        Aliases = {"exdet", "ed"},
        Description = "Toggle universal exploit detection"
    }, function(args)
        module.State.Enabled = not module.State.Enabled
        if module.State.Enabled then
            module:StartScanning()
            DoNotif("🎯 Exploit Detector: ACTIVE (Universal Mode)", 3)
            DoNotif("Confidence threshold: " .. module.State.ConfidenceThreshold .. "%", 2)
        else
            module:StopScanning()
            for player, highlight in pairs(module.State.HighlightCache) do
                highlight:Destroy()
            end
            module.State.HighlightCache = {}
            module.State.ConfirmedExploiters = {}
            DoNotif("Exploit Detector: DISABLED", 2)
        end
    end)
    RegisterCommand({
        Name = "detthreshold",
        Aliases = {"dth"},
        Description = "Set detection confidence threshold (0-100)"
    }, function(args)
        local threshold = tonumber(args[1])
        if not threshold then
            DoNotif("Current threshold: " .. module.State.ConfidenceThreshold .. "%", 2)
            return
        end
        threshold = math.clamp(threshold, 0, 100)
        module.State.ConfidenceThreshold = threshold
        DoNotif("Detection threshold set to: " .. threshold .. "%", 2)
    end)
    RegisterCommand({
        Name = "listexploiters",
        Aliases = {"lex"},
        Description = "Show all detected exploiters"
    }, function(args)
        local count = 0
        for player, _ in pairs(module.State.ConfirmedExploiters) do
            if player and player.Parent then
                local score = module.State.SuspicionScores[player] or 0
                DoNotif(string.format("%s - %d%% confidence", player.Name, math.floor(score)), 3)
                count = count + 1
            end
        end
        if count == 0 then
            DoNotif("No exploiters detected", 2)
        else
            DoNotif(string.format("Total exploiters: %d", count), 2)
        end
    end)
    RegisterCommand({
        Name = "checkplayer",
        Aliases = {"checkp"},
        Description = "Check a specific player for exploits"
    }, function(args)
        local target = Utilities.findPlayer(args[1])
        if not target then
            DoNotif("Player not found", 2)
            return
        end
        local score = module.State.SuspicionScores[target] or 0
        local data = module.State.TrackedPlayers[target]
        DoNotif(string.format("%s - Suspicion: %d%%", target.Name, math.floor(score)), 3)
        if data and #data.DetectionHistory > 0 then
            local recent = data.DetectionHistory[#data.DetectionHistory]
            for _, det in ipairs(recent.detections) do
                DoNotif(string.format("  • %s: %d%%", det.pattern, math.floor(det.score)), 2)
            end
        end
    end)
    RegisterCommand({
        Name = "autocounter",
        Aliases = {"acounter"},
        Description = "Toggle automatic counter activation"
    }, function(args)
        module.State.AutoCounter = not module.State.AutoCounter
        DoNotif("Auto-Counter: " .. (module.State.AutoCounter and "ENABLED" or "DISABLED"), 2)
    end)
    RegisterCommand({
        Name = "markexploiter",
        Aliases = {"mex"},
        Description = "Manually mark a player as exploiter"
    }, function(args)
        local target = Utilities.findPlayer(args[1])
        if not target then
            DoNotif("Player not found", 2)
            return
        end
        module.State.SuspicionScores[target] = 100
        module:MarkAsExploiter(target, {})
        DoNotif("Marked " .. target.Name .. " as exploiter", 2)
    end)
    RegisterCommand({
        Name = "unmarkexploiter",
        Aliases = {"uex"},
        Description = "Remove exploiter mark from player"
    }, function(args)
        local target = Utilities.findPlayer(args[1])
        if not target then
            DoNotif("Player not found", 2)
            return
        end
        module.State.SuspicionScores[target] = 0
        module:ClearExploiter(target)
        DoNotif("Unmarked " .. target.Name, 2)
    end)
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        if player ~= self.Services.Players.LocalPlayer then
            self:InitializePlayerTracking(player)
        end
    end
    self.Services.Players.PlayerAdded:Connect(function(player)
        self:InitializePlayerTracking(player)
    end)
    self.Services.Players.PlayerRemoving:Connect(function(player)
        self.State.TrackedPlayers[player] = nil
        self.State.SuspicionScores[player] = nil
        self.State.ConfirmedExploiters[player] = nil
        if self.State.HighlightCache[player] then
            self.State.HighlightCache[player]:Destroy()
            self.State.HighlightCache[player] = nil
        end
    end)
end
Modules.TeleporterScanner = {
	State = {
		UI = nil,
		IsScanning = false,
		Highlights = {},
		ScanCache = {},
		LastScan = 0,
		Stats = {
			TotalScanned = 0,
			PotentalFound = 0,
			LastScanTime = 0
		}
	},
	Config = {
		CacheExpiry = 60,
		YieldInterval = 250,
		MaxResults = 100,
		AutoScanOnOpen = false,
		HighlightDuration = 0,
		DeepScan = false,
		ScanHiddenObjects = true,
		DebugMode = false
	}
}
local function debugLog(message)
	if Modules.TeleporterScanner.Config.DebugMode then
		print("[TeleporterScanner Debug]", message)
	end
end
function Modules.TeleporterScanner:ToggleGUI()
	local self = Modules.TeleporterScanner
	if self.State.UI and self.State.UI.Parent then
		self:CleanupHighlights()
		self.State.UI:Destroy()
		self.State.UI = nil
		DoNotif("Teleporter Scanner closed.", 2)
		return
	end
	DoNotif("Forensic Teleporter Scanner opened.", 2)
	local Workspace = game:GetService("Workspace")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local CoreGui = game:GetService("CoreGui")
	local Players = game:GetService("Players")
	local SCRIPT_KEYWORDS = {
		{pattern = "TeleportService", confidence = 1.0},
		{pattern = ":Teleport%(", confidence = 1.0},
		{pattern = ":TeleportToPlaceInstance%(", confidence = 1.0},
		{pattern = "TeleportAsync", confidence = 1.0},
		{pattern = "fireproximityprompt", confidence = 0.9},
		{pattern = "firetouchinterest", confidence = 0.85},
		{pattern = "game:GetService%([\"']TeleportService", confidence = 0.95},
		{pattern = "placeId%s*=%s*%d+", confidence = 0.7},
		{pattern = "JobId", confidence = 0.6},
		{pattern = "PrivateServerId", confidence = 0.6},
		{pattern = "CFrame%.new%(", confidence = 0.3},
		{pattern = "HumanoidRootPart%.CFrame", confidence = 0.4}
	}
	local NAME_KEYWORDS = {
		{pattern = "teleport", confidence = 0.6},
		{pattern = "portal", confidence = 0.6},
		{pattern = "warp", confidence = 0.5},
		{pattern = "transport", confidence = 0.5},
		{pattern = "gateway", confidence = 0.5},
		{pattern = "door", confidence = 0.3},
		{pattern = "exit", confidence = 0.4}
	}
	local DATA_PAYLOAD_NAMES = {
		{name = "placeid", confidence = 0.9},
		{name = "gameid", confidence = 0.9},
		{name = "targetplace", confidence = 0.9},
		{name = "destination", confidence = 0.7},
		{name = "teleportdata", confidence = 0.85},
		{name = "tpid", confidence = 0.8}
	}
	local screenGui = Instance.new("ScreenGui")
	self.State.UI = screenGui
	screenGui.Name = "TeleporterScannerGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.IgnoreGuiInset = true
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 380, 0, 500)
	mainFrame.Position = UDim2.new(0, 10, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(85, 85, 125)
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 35)
	titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	titleLabel.Text = "🔍 Forensic Teleporter Scanner"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Parent = mainFrame
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 8)
	titleCorner.Parent = titleLabel
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -32, 0, 2.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeButton.Text = "✕"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 16
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Parent = titleLabel
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 4)
	closeCorner.Parent = closeButton
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "StatsLabel"
	statsLabel.Size = UDim2.new(1, -10, 0, 20)
	statsLabel.Position = UDim2.new(0, 5, 0, 40)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "Ready to scan | 0 objects scanned"
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextSize = 11
	statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.Parent = mainFrame
	local scanButton = Instance.new("TextButton")
	scanButton.Name = "ScanButton"
	scanButton.Size = UDim2.new(1, -10, 0, 32)
	scanButton.Position = UDim2.new(0.5, 0, 0, 65)
	scanButton.AnchorPoint = Vector2.new(0.5, 0)
	scanButton.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
	scanButton.Font = Enum.Font.GothamBold
	scanButton.TextSize = 13
	scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	scanButton.Text = "🔍 Begin Workspace Scan"
	scanButton.Parent = mainFrame
	local scanCorner = Instance.new("UICorner")
	scanCorner.CornerRadius = UDim.new(0, 6)
	scanCorner.Parent = scanButton
	local deepScanToggle = Instance.new("TextButton")
	deepScanToggle.Name = "DeepScanToggle"
	deepScanToggle.Size = UDim2.new(0.48, 0, 0, 24)
	deepScanToggle.Position = UDim2.new(0, 5, 0, 102)
	deepScanToggle.BackgroundColor3 = self.Config.DeepScan and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
	deepScanToggle.Font = Enum.Font.Gotham
	deepScanToggle.TextSize = 11
	deepScanToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	deepScanToggle.Text = "Deep Scan: " .. (self.Config.DeepScan and "ON" or "OFF")
	deepScanToggle.Parent = mainFrame
	local deepCorner = Instance.new("UICorner")
	deepCorner.CornerRadius = UDim.new(0, 4)
	deepCorner.Parent = deepScanToggle
	local clearButton = Instance.new("TextButton")
	clearButton.Name = "ClearButton"
	clearButton.Size = UDim2.new(0.48, 0, 0, 24)
	clearButton.Position = UDim2.new(0.52, 0, 0, 102)
	clearButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	clearButton.Font = Enum.Font.Gotham
	clearButton.TextSize = 11
	clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	clearButton.Text = "🗑️ Clear Results"
	clearButton.Parent = mainFrame
	local clearCorner = Instance.new("UICorner")
	clearCorner.CornerRadius = UDim.new(0, 4)
	clearCorner.Parent = clearButton
	local filterLabel = Instance.new("TextLabel")
	filterLabel.Name = "FilterLabel"
	filterLabel.Size = UDim2.new(1, -10, 0, 18)
	filterLabel.Position = UDim2.new(0, 5, 0, 131)
	filterLabel.BackgroundTransparency = 1
	filterLabel.Text = "Min Confidence: 0%"
	filterLabel.Font = Enum.Font.Gotham
	filterLabel.TextSize = 10
	filterLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	filterLabel.TextXAlignment = Enum.TextXAlignment.Left
	filterLabel.Parent = mainFrame
	local filterSlider = Instance.new("Frame")
	filterSlider.Name = "FilterSlider"
	filterSlider.Size = UDim2.new(1, -10, 0, 6)
	filterSlider.Position = UDim2.new(0, 5, 0, 150)
	filterSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	filterSlider.BorderSizePixel = 0
	filterSlider.Parent = mainFrame
	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius = UDim.new(1, 0)
	sliderCorner.Parent = filterSlider
	local sliderFill = Instance.new("Frame")
	sliderFill.Name = "Fill"
	sliderFill.Size = UDim2.new(0, 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(80, 60, 200)
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = filterSlider
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = sliderFill
	local resultsFrame = Instance.new("ScrollingFrame")
	resultsFrame.Name = "ResultsFrame"
	resultsFrame.Size = UDim2.new(1, -10, 1, -165)
	resultsFrame.Position = UDim2.new(0, 5, 0, 160)
	resultsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	resultsFrame.BorderSizePixel = 0
	resultsFrame.ScrollBarThickness = 6
	resultsFrame.Parent = mainFrame
	local resultsCorner = Instance.new("UICorner")
	resultsCorner.CornerRadius = UDim.new(0, 6)
	resultsCorner.Parent = resultsFrame
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 3)
	listLayout.Parent = resultsFrame
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingLeft = UDim.new(0, 5)
	listPadding.PaddingRight = UDim.new(0, 5)
	listPadding.PaddingTop = UDim.new(0, 5)
	listPadding.PaddingBottom = UDim.new(0, 5)
	listPadding.Parent = resultsFrame
	local minConfidence = 0
	local function updateFilter()
		for _, child in ipairs(resultsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				local conf = tonumber(child:GetAttribute("Confidence"))
				child.Visible = conf and (conf >= minConfidence)
			end
		end
	end
	filterSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local function updateSlider()
				local mouse = UserInputService:GetMouseLocation()
				local relativeX = math.clamp((mouse.X - filterSlider.AbsolutePosition.X) / filterSlider.AbsoluteSize.X, 0, 1)
				minConfidence = relativeX
				sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
				filterLabel.Text = string.format("Min Confidence: %.0f%%", minConfidence * 100)
				updateFilter()
			end
			local conn
			conn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
					conn:Disconnect()
				end
			end)
			local moveConn
			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
					updateSlider()
				end
			end)
			UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
					moveConn:Disconnect()
				end
			end)
			updateSlider()
		end
	end)
	local function highlightPart(part, confidence)
		if self.State.Highlights[part] then return end
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		local hue = confidence * 0.33
		highlight.FillColor = Color3.fromHSV(hue, 0.8, 1)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.4
		highlight.OutlineTransparency = 0
		highlight.Parent = part
		self.State.Highlights[part] = highlight
		if self.Config.HighlightDuration > 0 then
			task.delay(self.Config.HighlightDuration, function()
				if highlight and highlight.Parent then
					highlight:Destroy()
				end
				self.State.Highlights[part] = nil
			end)
		end
		debugLog("Highlighted: " .. part:GetFullName() .. " (Confidence: " .. string.format("%.0f%%", confidence * 100) .. ")")
	end
	local function addResultToList(part, confidence, reasons)
		local resultButton = Instance.new("TextButton")
		resultButton.Name = part.Name
		local reasonText = table.concat(reasons, ", ")
		resultButton.Text = string.format("[%.0f%%] %s\n%s", confidence * 100, part.Name, reasonText)
		resultButton.Size = UDim2.new(1, -10, 0, 40)
		resultButton.BackgroundColor3 = Color3.fromHSV(confidence * 0.33, 0.4, 0.3)
		resultButton.Font = Enum.Font.Gotham
		resultButton.TextSize = 11
		resultButton.TextXAlignment = Enum.TextXAlignment.Left
		resultButton.TextYAlignment = Enum.TextYAlignment.Top
		resultButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		resultButton.TextWrapped = true
		resultButton.LayoutOrder = math.floor(-confidence * 1000)
		resultButton:SetAttribute("Confidence", confidence)
		resultButton.Parent = resultsFrame
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 4)
		btnCorner.Parent = resultButton
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 8)
		btnPadding.PaddingTop = UDim.new(0, 4)
		btnPadding.Parent = resultButton
		resultButton.MouseButton1Click:Connect(function()
			if not part or not part.Parent then
				DoNotif("Target no longer exists", 2)
				return
			end
			local targetPart = part:IsA("Model") and part:FindFirstChildWhichIsA("BasePart", true) or part
			if not targetPart or not targetPart:IsA("BasePart") then
				DoNotif("Cannot teleport camera to this object", 2)
				return
			end
			local camera = Workspace.CurrentCamera
			local player = Players.LocalPlayer
			local originalCameraType = camera.CameraType
			camera.CameraType = Enum.CameraType.Scriptable
			local distance = 15
			local targetCFrame = CFrame.new(targetPart.Position + (targetPart.CFrame.LookVector * distance) + Vector3.new(0, 5, 0), targetPart.Position)
			local tween = TweenService:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCFrame})
			tween:Play()
			task.delay(3, function()
				camera.CameraType = originalCameraType
			end)
		end)
		resultButton.MouseButton2Click:Connect(function()
			if setclipboard then
				setclipboard(part:GetFullName())
				DoNotif("Copied path to clipboard", 2)
			end
		end)
	end
	local function clearResults()
		self:CleanupHighlights()
		for _, child in ipairs(resultsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		scanButton.Text = "🔍 Begin Workspace Scan"
		scanButton.Active = true
		statsLabel.Text = "Results cleared | 0 objects scanned"
		debugLog("Results cleared")
	end
	local function analyzeScript(script)
		local success, source = pcall(function()
			return script.Source
		end)
		if not success or not source then
			return 0, {}
		end
		local lowerSource = source:lower()
		local maxConfidence = 0
		local reasons = {}
		for _, keyword in ipairs(SCRIPT_KEYWORDS) do
			local pattern = keyword.pattern:lower()
			if lowerSource:find(pattern, 1, true) or (self.Config.DeepScan and lowerSource:match(pattern)) then
				if keyword.confidence > maxConfidence then
					maxConfidence = keyword.confidence
				end
				table.insert(reasons, "Script: " .. keyword.pattern)
				if not self.Config.DeepScan then
					break
				end
			end
		end
		return maxConfidence, reasons
	end
	local function analyzeBasePart(part)
		local confidence = 0
		local reasons = {}
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("ValueBase") then
				local childName = child.Name:lower()
				for _, data in ipairs(DATA_PAYLOAD_NAMES) do
					if childName == data.name or childName:find(data.name, 1, true) then
						confidence = math.max(confidence, data.confidence)
						table.insert(reasons, "Data: " .. child.Name)
						break
					end
				end
			end
		end
		local partName = part.Name:lower()
		for _, keyword in ipairs(NAME_KEYWORDS) do
			if partName:find(keyword.pattern, 1, true) then
				confidence = math.max(confidence, keyword.confidence)
				table.insert(reasons, "Name: " .. keyword.pattern)
				if not self.Config.DeepScan then
					break
				end
			end
		end
		if part:FindFirstChildOfClass("ProximityPrompt") then
			confidence = math.max(confidence, 0.7)
			table.insert(reasons, "ProximityPrompt")
		end
		if part:FindFirstChildOfClass("ClickDetector") then
			confidence = math.max(confidence, 0.5)
			table.insert(reasons, "ClickDetector")
		end
		return confidence, reasons
	end
	local function scanWorkspace()
		self.State.IsScanning = true
		scanButton.Text = "⏳ Scanning..."
		scanButton.Active = false
		local findings = {}
		local scannedCount = 0
		local startTime = tick()
		task.spawn(function()
			local descendants = Workspace:GetDescendants()
			local totalCount = #descendants
			debugLog("Starting scan of " .. totalCount .. " objects")
			for i, descendant in ipairs(descendants) do
				scannedCount = i
				if i % self.Config.YieldInterval == 0 then
					statsLabel.Text = string.format("Scanning... %d/%d (%.1f%%)", i, totalCount, (i / totalCount) * 100)
					task.wait()
				end
				if not descendant.Parent then
					continue
				end
				local part, confidence, reasons = nil, 0, {}
				if descendant:IsA("LuaSourceContainer") then
					local scriptConf, scriptReasons = analyzeScript(descendant)
					if scriptConf > 0 then
						part = descendant:FindFirstAncestorWhichIsA("Model") or descendant:FindFirstAncestorWhichIsA("BasePart") or descendant.Parent
						if part and (part:IsA("BasePart") or part:IsA("Model")) then
							confidence = scriptConf
							reasons = scriptReasons
						end
					end
				end
				if descendant:IsA("BasePart") and not part then
					local partConf, partReasons = analyzeBasePart(descendant)
					if partConf > 0 then
						part = descendant
						confidence = partConf
						reasons = partReasons
					end
				end
				if part and (not findings[part] or confidence > findings[part].confidence) then
					findings[part] = {
						confidence = confidence,
						reasons = reasons
					}
				end
			end
			local partsFound = 0
			local sortedFindings = {}
			for part, data in pairs(findings) do
				table.insert(sortedFindings, {part = part, data = data})
			end
			table.sort(sortedFindings, function(a, b)
				return a.data.confidence > b.data.confidence
			end)
			local maxResults = math.min(#sortedFindings, self.Config.MaxResults)
			for i = 1, maxResults do
				local finding = sortedFindings[i]
				partsFound = partsFound + 1
				highlightPart(finding.part, finding.data.confidence)
				addResultToList(finding.part, finding.data.confidence, finding.data.reasons)
			end
			local scanTime = tick() - startTime
			self.State.Stats.TotalScanned = scannedCount
			self.State.Stats.PotentalFound = partsFound
			self.State.Stats.LastScanTime = scanTime
			self.State.LastScan = tick()
			scanButton.Text = string.format("✓ Scan Complete! (%d found)", partsFound)
			statsLabel.Text = string.format("Found %d teleporters | Scanned %d objects in %.1fs", partsFound, scannedCount, scanTime)
			DoNotif(string.format("Scan complete: %d potential teleporters found", partsFound), 3)
			self.State.IsScanning = false
			debugLog(string.format("Scan complete: %d found in %.2fs", partsFound, scanTime))
		end)
	end
	scanButton.MouseButton1Click:Connect(function()
		if self.State.IsScanning then return end
		clearResults()
		scanWorkspace()
	end)
	clearButton.MouseButton1Click:Connect(clearResults)
	closeButton.MouseButton1Click:Connect(function()
		self:ToggleGUI()
	end)
	deepScanToggle.MouseButton1Click:Connect(function()
		self.Config.DeepScan = not self.Config.DeepScan
		deepScanToggle.Text = "Deep Scan: " .. (self.Config.DeepScan and "ON" or "OFF")
		deepScanToggle.BackgroundColor3 = self.Config.DeepScan and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(80, 80, 90)
		DoNotif("Deep scan " .. (self.Config.DeepScan and "enabled" or "disabled"), 2)
	end)
	local isDragging, dragStart, startPosition = false, nil, nil
	titleLabel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = input.Position
			startPosition = mainFrame.Position
		end
	end)
	titleLabel.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	screenGui.Parent = CoreGui
	if self.Config.AutoScanOnOpen then
		task.wait(0.1)
		scanWorkspace()
	end
end
function Modules.TeleporterScanner:CleanupHighlights()
	for part, highlight in pairs(self.State.Highlights) do
		if highlight and highlight.Parent then
			pcall(function()
				highlight:Destroy()
			end)
		end
	end
	table.clear(self.State.Highlights)
end
function Modules.TeleporterScanner:GetStats()
	return {
		TotalScanned = self.State.Stats.TotalScanned,
		PotentialsFound = self.State.Stats.PotentalFound,
		LastScanTime = self.State.Stats.LastScanTime,
		IsScanning = self.State.IsScanning
	}
end
RegisterCommand({
	Name = "tpscan",
	Aliases = {"teleporterscan", "findtp", "scanteleports"},
	Description = "Opens a GUI that scans the workspace for potential teleporters."
}, function(args)
	Modules.TeleporterScanner:ToggleGUI()
end)
Modules.AuthorityHijacker = {
    State = {
        IsEnabled = false,
        UnlockedTables = {},
        OriginalNewIndex = nil,
        SpoofMap = {}
    }
}
function Modules.AuthorityHijacker:_deepUnlock(root, depth)
    if depth > 10 or self.State.UnlockedTables[root] then return end
    if type(root) ~= "table" then return end
    self.State.UnlockedTables[root] = true
    if setreadonly then
        pcall(setreadonly, root, false)
    elseif make_writeable then
        pcall(make_writeable, root)
    end
    for k, v in pairs(root) do
        if type(v) == "table" then
            self:_deepUnlock(v, depth + 1)
        end
    end
end
function Modules.AuthorityHijacker:ApplyKernelHook()
if key == "WalkSpeed" or key == "JumpPower" then
    if self.State.IsEnabled then
        return self.State.SpoofMap[t] and self.State.SpoofMap[t][key] or originalIndex(t, key)
    end
end
    if self.State.OriginalNewIndex then return end
    local success, mt = pcall(getrawmetatable, game)
    if not success then return end
    self.State.OriginalNewIndex = mt.__newindex
    local old = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(t, k, v)
        if Modules.AuthorityHijacker.State.IsEnabled then
            local ok = pcall(old, t, k, v)
            if not ok then
                if not Modules.AuthorityHijacker.State.SpoofMap[t] then
                    Modules.AuthorityHijacker.State.SpoofMap[t] = {}
                end
                Modules.AuthorityHijacker.State.SpoofMap[t][k] = v
                warn(string.format("--> [Hijacker] Seized property: %s.%s", t.Name, k))
                return nil
            end
        end
        return old(t, k, v)
    end)
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(t, k)
        if Modules.AuthorityHijacker.State.IsEnabled and Modules.AuthorityHijacker.State.SpoofMap[t] then
            local fakeVal = Modules.AuthorityHijacker.State.SpoofMap[t][k]
            if fakeVal ~= nil then return fakeVal end
        end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
end
function Modules.AuthorityHijacker:UnlockEnvironment()
    DoNotif("Unlocking Global Environment...", 2)
    self:_deepUnlock(getgenv(), 0)
    self:_deepUnlock(getrenv(), 0)
    self:_deepUnlock(getreg(), 0)
    DoNotif("Global Read-Only states dismantled.", 3)
end
RegisterCommand({
    Name = "unlockengine",
    Aliases = {"writeall"},
    Description = "Dismantles Read-Only protection on all Luau tables (getgenv/getreg)."
}, function()
    Modules.AuthorityHijacker:UnlockEnvironment()
end)
RegisterCommand({
    Name = "hijack",
    Aliases = {"forcewrite", "seize"},
    Description = "Toggles Kernel-level property hijacking. Allows 'writing' to read-only engine properties."
}, function()
    local state = Modules.AuthorityHijacker.State
    state.IsEnabled = not state.IsEnabled
    if state.IsEnabled then
        Modules.AuthorityHijacker:ApplyKernelHook()
        DoNotif("Kernel Hijack: ACTIVE. Engine constraints ignored.", 3)
    else
        DoNotif("Kernel Hijack: DISABLED.", 2)
    end
end)
Modules.InventoryVault = {
    State = {
        IsEnabled = false,
        Vault = {},
        Connections = {},
        HookActive = false,
        OriginalNewIndex = nil
    },
    Dependencies = {"Players", "CoreGui", "RunService"}
}
function Modules.InventoryVault:Snapshot()
    local backpack = Players.LocalPlayer:FindFirstChildOfClass("Backpack")
    local char = Players.LocalPlayer.Character
    if not (backpack or char) then return end
    table.clear(self.State.Vault)
    local count = 0
    local function save(tool)
        if tool:IsA("Tool") and not self.State.Vault[tool.Name] then
            self.State.Vault[tool.Name] = tool:Clone()
            count = count + 1
        end
    end
    for _, t in ipairs(backpack:GetChildren()) do save(t) end
    for _, t in ipairs(char:GetChildren()) do save(t) end
    DoNotif("Vault: Saved " .. count .. " tools to local memory.", 3)
end
function Modules.InventoryVault:Restore()
    local backpack = Players.LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local restored = 0
    for name, toolTemplate in pairs(self.State.Vault) do
        if not backpack:FindFirstChild(name) and not (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild(name)) then
            local clone = toolTemplate:Clone()
            clone.Parent = backpack
            restored = restored + 1
        end
    end
    DoNotif("Vault: Restored " .. restored .. " tools.", 2)
end
function Modules.InventoryVault:ApplyShield()
    if self.State.HookActive then return end
    local success, mt = pcall(getrawmetatable, game)
    if not success then return end
    self.State.OriginalNewIndex = mt.__newindex
    local old = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(t, k, v)
        if Modules.InventoryVault.State.IsEnabled and t:IsA("Tool") and k == "Parent" and v ~= Players.LocalPlayer:FindFirstChildOfClass("Backpack") and v ~= Players.LocalPlayer.Character then
            if not checkcaller() then
                warn("--> [Vault] Blocked attempt to remove tool: " .. t.Name)
                return nil
            end
        end
        return old(t, k, v)
    end)
    setreadonly(mt, true)
    self.State.HookActive = true
end
function Modules.InventoryVault:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        self:ApplyShield()
        self:Snapshot()
        DoNotif("Inventory Shield: ACTIVE", 2)
    else
        DoNotif("Inventory Shield: DISABLED", 2)
    end
end
function Modules.InventoryVault:Initialize()
    local module = self
    module.Services = {}
    for _, s in ipairs(module.Dependencies) do module.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "saveinv",
        Aliases = {"vaultsave"},
        Description = "Saves your current tools so you can restore them after death/stripping."
    }, function()
        module:Snapshot()
    end)
    RegisterCommand({
        Name = "restoreinv",
        Aliases = {"getvault"},
        Description = "Brings back all tools saved in your vault."
    }, function()
        module:Restore()
    end)
    RegisterCommand({
        Name = "antitoolremove",
        Aliases = {"atr"},
        Description = "Toggles a shield that blocks scripts from removing your tools."
    }, function()
        module:Toggle()
    end)
end
Modules.PropertyForensics = {
    State = {
        OriginalSizes = setmetatable({}, {__mode = "k"})
    }
}
function Modules.PropertyForensics:_resolvePath(path)
    local current = game
    local segments = string.split(path, ".")
    for i, name in ipairs(segments) do
        if i == 1 then
            if name:lower() == "workspace" then
                current = workspace
                continue
            elseif name:lower() == "game" then
                continue
            end
            local success, service = pcall(game.GetService, game, name)
            if success and service then
                current = service
            else
                current = current:FindFirstChild(name)
            end
        else
            current = current and current:FindFirstChild(name)
        end
        if not current then break end
    end
    return current
end
function Modules.PropertyForensics:Resize(path, x, y, z)
    local obj = self:_resolvePath(path)
    if not obj then
        return DoNotif("Resize Error: Path could not be resolved.", 3)
    end
    if obj:IsA("Model") then
        local scale = tonumber(x)
        if scale then
            local success, err = pcall(function() obj:ScaleTo(scale) end)
            if success then
                DoNotif("Model Scaled to: " .. scale, 2)
            else
                warn("Resize Error:", err)
            end
        else
            DoNotif("Usage for Models: ;size [path] [Multiplier]", 3)
        end
        return
    end
    if obj:IsA("BasePart") or obj:IsA("GuiObject") then
        local newSize
        if x and y and z then
            newSize = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
        elseif x and not y then
            local factor = tonumber(x)
            newSize = obj.Size * factor
        end
        if newSize then
            if not self.State.OriginalSizes[obj] then
                self.State.OriginalSizes[obj] = obj.Size
            end
            pcall(function() obj.Size = newSize end)
            DoNotif("Resized: " .. obj.Name, 2)
        end
    else
        DoNotif("Error: Object type does not support Size.", 3)
    end
end
function Modules.PropertyForensics:Restore(path)
    local obj = self:_resolvePath(path)
    local original = self.State.OriginalSizes[obj]
    if obj and original then
        pcall(function() obj.Size = original end)
        self.State.OriginalSizes[obj] = nil
        DoNotif("Restored original size for: " .. obj.Name, 2)
    end
end
RegisterCommand({
    Name = "size",
    Aliases = {"resize", "scale"},
    Description = "Resizes an object by path. Usage: ;size [path] [multiplier] OR ;size [path] [x] [y] [z]"
}, function(args)
    if #args < 2 then
        return DoNotif("Usage: ;size workspace.Part 5", 3)
    end
    local path = args[1]
    local x = args[2]
    local y = args[3]
    local z = args[4]
    Modules.PropertyForensics:Resize(path, x, y, z)
end)
RegisterCommand({
    Name = "unsize",
    Aliases = {"revertsize"},
    Description = "Restores the original size of an object. Usage: ;unsize [path]"
}, function(args)
    if not args[1] then return end
    Modules.PropertyForensics:Restore(args[1])
end)
RegisterCommand({
    Name = "hsize",
    Aliases = {"hitboxsize", "ext"},
    Description = "Quick hitbox extender for players. Usage: ;hsize [Name] [Size]"
}, function(args)
    local target = Utilities.findPlayer(args[1])
    local size = args[2] or 10
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            Modules.PropertyForensics:Resize(hrp:GetFullName(), size)
            hrp.CanCollide = false
            hrp.Transparency = 0.7
        end
    else
        DoNotif("Target player character not found.", 3)
    end
end)
Modules.GrabTools = {
State = {
IsEnabled = false,
Connection = nil
}
}
function Modules.GrabTools:_onHeartbeat()
    local localPlayerBackpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    if not localPlayerBackpack then return end
        for _, child in ipairs(Workspace:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("Handle") and not child.Handle.Anchored then
                child.Parent = localPlayerBackpack
                DoNotif("Grabbed Tool: " .. child.Name, 1.5)
            end
        end
    end
    function Modules.GrabTools:Toggle()
        local self = Modules.GrabTools
        self.State.IsEnabled = not self.State.IsEnabled
        if self.State.IsEnabled then
            if self.State.Connection then self.State.Connection:Disconnect() end
                self.State.Connection = RunService.Heartbeat:Connect(function() self:_onHeartbeat() end)
                DoNotif("Tool Grabber Enabled", 2)
            else
            if self.State.Connection then
                self.State.Connection:Disconnect()
                self.State.Connection = nil
            end
            DoNotif("Tool Grabber Disabled", 2)
        end
    end
    function Modules.GrabTools:Initialize()
        local module = self
        RegisterCommand({
        Name = "grabtools",
        Aliases = {"gt", "toolgrab"},
        Description = "Toggles an auto-grabber for all dropped tools in the workspace."
        }, function(args)
        module:Toggle()
    end)
end
Modules.AdminSpoofDemonstration = {
    State = {
        IsSpoofing = false,
        SpoofedId = -1,
        SpoofedName = nil,
        SpoofedDisplayName = nil,
        OriginalIndex = nil,
        OriginalNamecall = nil,
        PlayerMetatable = nil,
        GameMetatable = nil,
        HookEnabled = true,
        Stats = {
            InterceptedCalls = 0,
            LastSpoof = 0
        }
    },
    Dependencies = {"Players"},
    Config = {
        SpoofName = true,
        SpoofDisplayName = true,
        InterceptRemoteCalls = true,
        StealthMode = true,
        DebugMode = false,
        AllowedProperties = {
            "UserId",
            "Name", 
            "DisplayName",
            "AccountAge"
        }
    }
}
local function debugLog(message)
    if Modules.AdminSpoofDemonstration.Config.DebugMode then
        print("[AdminSpoof Debug]", message)
    end
end
local function fetchUserInfo(userId)
    local success, result = pcall(function()
        local HttpService = game:GetService("HttpService")
        local url = "https://users.roblox.com/v1/users/" .. userId
        if request then
            local response = request({
                Url = url,
                Method = "GET"
            })
            if response.StatusCode == 200 then
                return HttpService:JSONDecode(response.Body)
            end
        end
        local data = game:HttpGet(url)
        return HttpService:JSONDecode(data)
    end)
    if success and result then
        return {
            name = result.name,
            displayName = result.displayName,
            id = result.id
        }
    end
    return nil
end
function Modules.AdminSpoofDemonstration:Enable(targetId, targetName, targetDisplayName)
    if self.State.IsSpoofing then
        DoNotif("Already spoofing. Reset first with ;spoofid reset", 3)
        return false
    end
    local localPlayer = self.Services.Players.LocalPlayer
    if not localPlayer then
        DoNotif("Error: LocalPlayer not found", 3)
        return false
    end
    local originalUserId = localPlayer.UserId
    local originalName = localPlayer.Name
    local originalDisplayName = localPlayer.DisplayName
    self.State.SpoofedId = tonumber(targetId) or -1
    if self.State.SpoofedId <= 0 then
        DoNotif("Invalid UserId. Must be positive.", 3)
        return false
    end
    if not targetName or not targetDisplayName then
        DoNotif("Fetching user info...", 2)
        local userInfo = fetchUserInfo(self.State.SpoofedId)
        if userInfo then
            targetName = userInfo.name
            targetDisplayName = userInfo.displayName
            debugLog("Fetched info: " .. targetName .. " | " .. targetDisplayName)
        else
            debugLog("Failed to fetch user info, using defaults")
            targetName = targetName or "Player" .. self.State.SpoofedId
            targetDisplayName = targetDisplayName or targetName
        end
    end
    self.State.SpoofedName = targetName
    self.State.SpoofedDisplayName = targetDisplayName
    local success, playerMetatable = pcall(getrawmetatable, localPlayer)
    if not success or typeof(playerMetatable) ~= "table" then
        DoNotif("Error: Could not access player metatable", 4)
        return false
    end
    self.State.PlayerMetatable = playerMetatable
    self.State.OriginalIndex = playerMetatable.__index
    self.State.OriginalNamecall = playerMetatable.__namecall
    local originalIndexCache = self.State.OriginalIndex
    local originalNamecallCache = self.State.OriginalNamecall
    pcall(setreadonly, playerMetatable, false)
    playerMetatable.__index = newcclosure(function(self, key)
        if Modules.AdminSpoofDemonstration.State.IsSpoofing and Modules.AdminSpoofDemonstration.State.HookEnabled then
            if key == "UserId" then
                Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls = Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls + 1
                debugLog("Intercepted UserId access")
                return Modules.AdminSpoofDemonstration.State.SpoofedId
            elseif key == "Name" and Modules.AdminSpoofDemonstration.Config.SpoofName then
                Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls = Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls + 1
                debugLog("Intercepted Name access")
                return Modules.AdminSpoofDemonstration.State.SpoofedName
            elseif key == "DisplayName" and Modules.AdminSpoofDemonstration.Config.SpoofDisplayName then
                Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls = Modules.AdminSpoofDemonstration.State.Stats.InterceptedCalls + 1
                debugLog("Intercepted DisplayName access")
                return Modules.AdminSpoofDemonstration.State.SpoofedDisplayName
            end
        end
        if typeof(originalIndexCache) == "function" then
            return originalIndexCache(self, key)
        else
            return originalIndexCache[key]
        end
    end)
    if self.Config.InterceptRemoteCalls then
        playerMetatable.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if Modules.AdminSpoofDemonstration.State.IsSpoofing and (method == "FireServer" or method == "InvokeServer") then
                for i, arg in ipairs(args) do
                    if arg == originalUserId then
                        args[i] = Modules.AdminSpoofDemonstration.State.SpoofedId
                        debugLog("Spoofed UserId in remote call")
                    elseif arg == originalName and Modules.AdminSpoofDemonstration.Config.SpoofName then
                        args[i] = Modules.AdminSpoofDemonstration.State.SpoofedName
                        debugLog("Spoofed Name in remote call")
                    end
                end
            end
            return originalNamecallCache(self, unpack(args))
        end)
    end
    pcall(setreadonly, playerMetatable, true)
    self.State.IsSpoofing = true
    self.State.Stats.LastSpoof = tick()
    DoNotif(string.format("Spoofing enabled:\nUserId: %d\nName: %s\nDisplay: %s", 
        self.State.SpoofedId, 
        self.State.SpoofedName, 
        self.State.SpoofedDisplayName
    ), 4)
    debugLog("Spoof enabled successfully")
    return true
end
function Modules.AdminSpoofDemonstration:Disable()
    if not self.State.IsSpoofing then
        DoNotif("Not currently spoofing", 2)
        return false
    end
    if self.State.PlayerMetatable then
        pcall(setreadonly, self.State.PlayerMetatable, false)
        if self.State.OriginalIndex then
            self.State.PlayerMetatable.__index = self.State.OriginalIndex
        end
        if self.State.OriginalNamecall then
            self.State.PlayerMetatable.__namecall = self.State.OriginalNamecall
        end
        pcall(setreadonly, self.State.PlayerMetatable, true)
    end
    local interceptCount = self.State.Stats.InterceptedCalls
    self.State.IsSpoofing = false
    self.State.SpoofedId = -1
    self.State.SpoofedName = nil
    self.State.SpoofedDisplayName = nil
    self.State.OriginalIndex = nil
    self.State.OriginalNamecall = nil
    self.State.PlayerMetatable = nil
    self.State.Stats.InterceptedCalls = 0
    DoNotif(string.format("Spoof disabled. Intercepted %d calls.", interceptCount), 3)
    debugLog("Spoof disabled, cleaned up hooks")
    return true
end
function Modules.AdminSpoofDemonstration:Toggle()
    if self.State.IsSpoofing then
        self:Disable()
    else
        DoNotif("Usage: ;spoofid <userid> or ;spoofid <username>", 3)
    end
end
function Modules.AdminSpoofDemonstration:ToggleHook(enabled)
    self.State.HookEnabled = enabled
    DoNotif("Spoof hook " .. (enabled and "enabled" or "disabled"), 2)
end
function Modules.AdminSpoofDemonstration:GetStats()
    return {
        IsSpoofing = self.State.IsSpoofing,
        SpoofedId = self.State.SpoofedId,
        SpoofedName = self.State.SpoofedName,
        InterceptedCalls = self.State.Stats.InterceptedCalls,
        Uptime = self.State.IsSpoofing and (tick() - self.State.Stats.LastSpoof) or 0
    }
end
function Modules.AdminSpoofDemonstration:SpoofByUsername(username)
    local success, result = pcall(function()
        local Players = game:GetService("Players")
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success and result then
        return self:Enable(result)
    else
        DoNotif("Failed to find user: " .. username, 3)
        return false
    end
end
function Modules.AdminSpoofDemonstration:Initialize()
    local module = self
    module.Services = {}
    for _, serviceName in ipairs(module.Dependencies or {}) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "spoofid",
        Aliases = {"setid", "fakeid", "adminspoof"},
        Description = "Spoofs your UserId/Name for vulnerable admin scripts."
    }, function(args)
        local argument = args[1]
        if not argument then
            return DoNotif("Usage: ;spoofid <userid|username|reset>", 3)
        end
        if argument:lower() == "reset" or argument:lower() == "clear" or argument:lower() == "off" then
            module:Disable()
        elseif argument:lower() == "stats" then
            local stats = module:GetStats()
            print("=== Admin Spoof Stats ===")
            print("Spoofing:", stats.IsSpoofing)
            print("Spoofed ID:", stats.SpoofedId)
            print("Spoofed Name:", stats.SpoofedName or "N/A")
            print("Intercepted Calls:", stats.InterceptedCalls)
            print("Uptime:", string.format("%.1f", stats.Uptime) .. "s")
        elseif argument:lower() == "toggle" then
            module:Toggle()
        else
            local targetId = tonumber(argument)
            if targetId and targetId > 0 then
                module:Enable(targetId)
            else
                module:SpoofByUsername(argument)
            end
        end
    end)
    RegisterCommand({
        Name = "spoofname",
        Aliases = {"fakename"},
        Description = "Toggle name spoofing on/off."
    }, function(args)
        module.Config.SpoofName = not module.Config.SpoofName
        DoNotif("Name spoofing: " .. (module.Config.SpoofName and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "spoofdisplay",
        Aliases = {"fakedisplay"},
        Description = "Toggle display name spoofing on/off."
    }, function(args)
        module.Config.SpoofDisplayName = not module.Config.SpoofDisplayName
        DoNotif("Display name spoofing: " .. (module.Config.SpoofDisplayName and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "spoofstats",
        Aliases = {"spoofinfo"},
        Description = "Shows spoofing statistics."
    }, function(args)
        local stats = module:GetStats()
        print("=== Admin Spoof Stats ===")
        print("Active:", stats.IsSpoofing)
        if stats.IsSpoofing then
            print("Spoofed ID:", stats.SpoofedId)
            print("Spoofed Name:", stats.SpoofedName)
            print("Intercepted:", stats.InterceptedCalls)
            print("Uptime:", string.format("%.1fs", stats.Uptime))
        end
    end)
end
Modules.OrbitController = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Rotation = 0,
        Connections = {}
    },
    Config = {
        DefaultSpeed = 0.2,
        DefaultDistance = 6
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService")
    }
}
function Modules.OrbitController:Disable(shouldNotify: boolean)
    if not self.State.IsEnabled then return end
    for _, conn in pairs(self.State.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(self.State.Connections)
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
        end
    end
    self.State.IsEnabled = false
    self.State.TargetPlayer = nil
    if shouldNotify then
        DoNotif("Orbit stopped.", 2)
    end
end
function Modules.OrbitController:Enable(targetPlayer: Player, speed: number?, distance: number?)
    self:Disable(false)
    local localPlayer = self.Services.Players.LocalPlayer
    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local targetChar = targetPlayer and targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not (myRoot and myHumanoid and targetRoot) then
        return DoNotif("Orbit failed: A character part could not be found.", 3)
    end
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    self.State.Rotation = 0
    myHumanoid.AutoRotate = false
    local orbitSpeed = tonumber(speed) or self.Config.DefaultSpeed
    local orbitDistance = tonumber(distance) or self.Config.DefaultDistance
    self.State.Connections.Heartbeat = self.Services.RunService.Heartbeat:Connect(function()
        pcall(function()
            if not (self.State.IsEnabled and self.State.TargetPlayer and self.State.TargetPlayer.Character) then
                return self:Disable(true)
            end
            local currentTargetRoot = self.State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not currentTargetRoot then return self:Disable(true) end
            self.State.Rotation = self.State.Rotation + orbitSpeed
            myRoot.CFrame = CFrame.new(currentTargetRoot.Position) * CFrame.Angles(0, self.State.Rotation, 0) * CFrame.new(orbitDistance, 0, 0)
        end)
    end)
    self.State.Connections.RenderStepped = self.Services.RunService.RenderStepped:Connect(function()
        pcall(function()
            if not (self.State.IsEnabled and self.State.TargetPlayer and self.State.TargetPlayer.Character) then
                return self:Disable(true)
            end
            local currentTargetRoot = self.State.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not currentTargetRoot then return self:Disable(true) end
            myRoot.CFrame = CFrame.new(myRoot.Position, currentTargetRoot.Position)
        end)
    end)
    self.State.Connections.Died = myHumanoid.Died:Connect(function() self:Disable(true) end)
    self.State.Connections.Seated = myHumanoid.Seated:Connect(function(isSeated)
        if isSeated then self:Disable(true) end
    end)
    DoNotif("Orbiting " .. targetPlayer.Name, 2)
end
function Modules.OrbitController:Initialize()
    RegisterCommand({
        Name = "orbit",
        Aliases = {},
        Description = "Orbits your character around a target player."
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;orbit <PlayerName> [speed] [distance]", 3)
        end
        local target = Utilities.findPlayer(args[1])
        if target then
            self:Enable(target, args[2], args[3])
        else
            DoNotif("Player '" .. args[1] .. "' not found.", 3)
        end
    end)
    RegisterCommand({
        Name = "unorbit",
        Aliases = {},
        Description = "Stops orbiting the current target."
    }, function(args)
        local shouldNotify = not (args[1] and args[1]:lower() == "nonotify")
        self:Disable(shouldNotify)
    end)
end
local function readTable(tbl: table): string
    local function serialize(value: any, indent: number, visited: {[table]: boolean}): string
        local valueType: string = typeof(value)
        if valueType == "string" then
            return string.format("%q", value)
        elseif valueType == "number" or valueType == "boolean" or valueType == "nil" then
            return tostring(value)
        elseif valueType == "function" or valueType == "thread" or valueType == "userdata" then
            return string.format("\"<%s>\"", valueType)
        elseif valueType == "Instance" then
            return string.format("\"%s (%s)\"", value, value.ClassName)
        elseif valueType == "table" then
            if visited[value] then
                return "\"*Circular Reference*\""
            end
            visited[value] = true
            local str: string = "{\n"
            local indentation: string = string.rep("    ", indent + 1)
            local isNumeric: boolean = true
            local count: number = 0
            for i: number = 1, #value do
                str ..= indentation .. serialize(value[i], indent + 1, visited) .. ",\n"
                count += 1
            end
            for k: any, v: any in pairs(value) do
                if type(k) ~= "number" or k < 1 or k > #value or k % 1 ~= 0 then
                    isNumeric = false
                    break
                end
            end
            if not isNumeric then
                for k: any, v: any in pairs(value) do
                     local keyStr: string
                     if typeof(k) == "string" then
                         keyStr = string.format("[\"%s\"]", k)
                     else
                         keyStr = string.format("[%s]", tostring(k))
                     end
                     str ..= indentation .. keyStr .. " = " .. serialize(v, indent + 1, visited) .. ",\n"
                 end
            end
            str ..= string.rep("    ", indent) .. "}"
            visited[value] = false
            return str
        else
            return tostring(value)
        end
    end
    return serialize(tbl, 0, {})
end
Modules.RemoteInterceptor = {
    State = {
        IsEnabled = false,
        InterceptedRemotes = {}
    },
    Dependencies = {"CoreGui"},
    Services = {}
}
function Modules.RemoteInterceptor:_getInstanceFromPath(path: string): Instance?
    local current = game
    for component in string.gmatch(path, "[^%.]+") do
        if not current then return nil end
        if string.find(component, ":GetService") then
            local serviceName = component:match("'(.-)'") or component:match('"(.-)"')
            current = serviceName and current:GetService(serviceName) or nil
        else
            current = current:FindFirstChild(component)
        end
    end
    return current
end
function Modules.RemoteInterceptor:_logCall(remote: Instance, ...: any)
    local args = {...}
    local log = {"--> [Interceptor] Call detected on: " .. remote:GetFullName()}
    for i, arg in ipairs(args) do
        local argType = typeof(arg)
        local serializedValue
        if argType == "table" then
            serializedValue = readTable(arg)
        else
            serializedValue = tostring(arg)
        end
        table.insert(log, string.format("    - Arg #%d [%s]: %s", i, argType, serializedValue))
    end
    print(table.concat(log, "\n"))
end
function Modules.RemoteInterceptor:Intercept(remotePath: string)
    if self.State.InterceptedRemotes[remotePath] then
        return DoNotif("This remote is already being intercepted.", 3)
    end
    local originalRemote = self:_getInstanceFromPath(remotePath)
    if not (originalRemote and (originalRemote:IsA("RemoteEvent") or originalRemote:IsA("RemoteFunction"))) then
        return DoNotif("Remote not found or invalid type at path: " .. remotePath, 4)
    end
    local originalParent = originalRemote.Parent
    local originalName = originalRemote.Name
    local proxy = {}
    local metatable = {
        __index = function(_, key)
            if key == "FireServer" and originalRemote:IsA("RemoteEvent") then
                return function(_, ...)
                    self:_logCall(originalRemote, ...)
                    return originalRemote:FireServer(...)
                end
            elseif key == "InvokeServer" and originalRemote:IsA("RemoteFunction") then
                return function(_, ...)
                    self:_logCall(originalRemote, ...)
                    return originalRemote:InvokeServer(...)
                end
            end
            return originalRemote[key]
        end,
        __newindex = function(_, key, value)
            originalRemote[key] = value
        end
    }
    setmetatable(proxy, metatable)
    local proxyInstance = Instance.new("RemoteEvent")
    proxyInstance.Name = originalName
    local success, err = pcall(function()
        for i = 1, 20 do
            if originalParent:FindFirstChild(originalName) == originalRemote then
                break
            end
            task.wait()
        end
        originalRemote.Parent = self.Services.CoreGui
        proxyInstance.Parent = originalParent
    end)
    if not success then
        DoNotif("Failed to swap remote. It may be protected.", 4)
        if originalRemote.Parent ~= originalParent then
            originalRemote.Parent = originalParent
        end
        return
    end
    self.State.InterceptedRemotes[remotePath] = {
        Original = originalRemote,
        Proxy = proxy,
        ProxyInstance = proxyInstance,
        Parent = originalParent,
        Name = originalName
    }
    proxyInstance.OnServerEvent:Connect(function(_, ...)
        if originalRemote:IsA("RemoteEvent") then
            self:_logCall(originalRemote, ...)
            originalRemote:FireServer(...)
        end
    end)
    DoNotif("Successfully intercepted: " .. originalName, 3)
end
function Modules.RemoteInterceptor:Restore(remotePath: string)
    local data = self.State.InterceptedRemotes[remotePath]
    if not data then
        return DoNotif("Remote is not currently intercepted.", 3)
    end
    if data.ProxyInstance and data.ProxyInstance.Parent then
        data.ProxyInstance:Destroy()
    end
    data.Original.Parent = data.Parent
    self.State.InterceptedRemotes[remotePath] = nil
    DoNotif("Restored original remote: " .. data.Name, 2)
end
function Modules.RemoteInterceptor:Initialize()
    for _, serviceName in ipairs(self.Dependencies) do
        self.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "intercept",
        Aliases = {"spy"},
        Description = "Intercepts a remote to spy on its arguments."
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;intercept <path.to.remote>", 3)
        end
        self:Intercept(args[1])
    end)
    RegisterCommand({
        Name = "unintercept",
        Aliases = {"unspy"},
        Description = "Restores an intercepted remote."
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;unintercept <path.to.remote>", 3)
        end
        self:Restore(args[1])
    end)
    RegisterCommand({
        Name = "intercepted",
        Description = "Lists all currently intercepted remotes."
    }, function()
        local count = 0
        print("--- [Active Interceptors] ---")
        for path, _ in pairs(self.State.InterceptedRemotes) do
            print("- " .. path)
            count = count + 1
        end
        DoNotif("Listed " .. count .. " intercepted remote(s) in the F9 console.", 2)
    end)
end
Modules.ClientCanary = {
    State = {
        IsEnabled = false,
        HeartbeatConnection = nil,
        ViolationData = {},
        HighlightedPlayers = {}
    },
    Config = {
        MAX_REASONABLE_SPEED = 75,
        VIOLATION_THRESHOLD = 8,
        VIOLATION_DECAY_TIME = 2.5,
        CHECK_INTERVAL_SECONDS = 0.25
    }
}
function Modules.ClientCanary:_onHeartbeat(deltaTime)
    local now = os.clock()
    for player, data in pairs(self.State.ViolationData) do
        if now - data.LastCheck > self.Config.VIOLATION_DECAY_TIME then
            data.Level = math.max(0, data.Level - 1)
            data.LastCheck = now
        end
        if not player.Parent then
            self.State.ViolationData[player] = nil
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and self.State.HighlightedPlayers[player] == nil then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid.Health > 0 then
                local horizontalVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
                if horizontalVelocity.Magnitude > self.Config.MAX_REASONABLE_SPEED then
                    local data = self.State.ViolationData[player] or { Level = 0, LastCheck = now }
                    data.Level = data.Level + 1
                    data.LastCheck = now
                    self.State.ViolationData[player] = data
                    if data.Level >= self.Config.VIOLATION_THRESHOLD then
                        DoNotif(string.format("Exploiter Detected: %s (Reason: Sustained Speed)", player.Name), 4)
                        pcall(function()
                            Modules.HighlightPlayer:ApplyHighlight(player.Character)
                        end)
                        self.State.HighlightedPlayers[player] = true
                        self.State.ViolationData[player] = nil
                    end
                end
            end
        end
    end
end
function Modules.ClientCanary:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local lastCheck = 0
    self.State.HeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if os.clock() - lastCheck > self.Config.CHECK_INTERVAL_SECONDS then
            self:_onHeartbeat(deltaTime)
            lastCheck = os.clock()
        end
    end)
    DoNotif("Client Canary: ENABLED. Automated exploiter detection is active.", 2)
end
function Modules.ClientCanary:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.HeartbeatConnection then
        self.State.HeartbeatConnection:Disconnect()
        self.State.HeartbeatConnection = nil
    end
    for player, _ in pairs(self.State.HighlightedPlayers) do
        if Modules.HighlightPlayer.State.TargetPlayer == player then
            Modules.HighlightPlayer:ClearHighlight()
        end
    end
    table.clear(self.State.ViolationData)
    table.clear(self.State.HighlightedPlayers)
    DoNotif("Client Canary: DISABLED.", 2)
end
function Modules.ClientCanary:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.ClientCanary:Initialize()
    local module = self
    RegisterCommand({
        Name = "autodetect",
        Aliases = {"canary", "watchdog"},
        Description = "Toggles the automated client-side exploiter detection system."
    }, function()
        module:Toggle()
    end)
end
Modules.TweenClickTP = {
	State = {
		IsEnabled = false,
		Connection = nil,
		IsTweening = false
	},
	Config = {
		MODIFIER_KEY = Enum.KeyCode.LeftAlt,
		TWEEN_DURATION = 0.25,
		TWEEN_STYLE = Enum.EasingStyle.Quint
	}
}
function Modules.TweenClickTP:_executeTween(destination)
	if self.State.IsTweening then return end
	self.State.IsTweening = true
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local localPlayer = Players.LocalPlayer
	local character = localPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera
	if not (hrp and camera) then
		self.State.IsTweening = false
		return
	end
	local cameraAnchor = Instance.new("Part")
	cameraAnchor.Size = Vector3.one
	cameraAnchor.Transparency = 1
	cameraAnchor.Anchored = true
	cameraAnchor.CanCollide = false
	cameraAnchor.CFrame = camera.CFrame
	cameraAnchor.Parent = Workspace
	local tweenInfo = TweenInfo.new(self.Config.TWEEN_DURATION, self.Config.TWEEN_STYLE)
	local targetCFrame = CFrame.lookAt(destination, destination + camera.CFrame.LookVector)
	local tween = TweenService:Create(cameraAnchor, tweenInfo, { CFrame = targetCFrame })
	camera.CameraType = Enum.CameraType.Scriptable
	local camConnection = RunService.RenderStepped:Connect(function()
		camera.CFrame = cameraAnchor.CFrame
	end)
	tween:Play()
	tween.Completed:Connect(function()
		camConnection:Disconnect()
		hrp.CFrame = CFrame.new(destination) + Vector3.new(0, 3, 0)
		camera.CameraType = Enum.CameraType.Custom
		cameraAnchor:Destroy()
		self.State.IsTweening = false
	end)
end
function Modules.TweenClickTP:Enable()
	if self.State.IsEnabled then return end
	self.State.IsEnabled = true
	self.State.Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or self.State.IsTweening then return end
		if UserInputService:IsKeyDown(self.Config.MODIFIER_KEY) and input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = UserInputService:GetMouseLocation()
			local ray = Workspace.CurrentCamera:ViewportPointToRay(mousePos.X, mousePos.Y)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Blacklist
			params.FilterDescendantsInstances = { Players.LocalPlayer.Character }
			local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			if result and result.Position then
				self:_executeTween(result.Position)
			end
		end
	end)
	DoNotif("Tween ClickTP: [Enabled]. Hold LeftAlt and click to teleport.", 3)
end
function Modules.TweenClickTP:Disable()
	if not self.State.IsEnabled then return end
	self.State.IsEnabled = false
	if self.State.Connection then
		self.State.Connection:Disconnect()
		self.State.Connection = nil
	end
	DoNotif("Tween ClickTP: [Disabled].", 2)
end
function Modules.TweenClickTP:Toggle()
	if self.State.IsEnabled then
		self:Disable()
	else
		self:Enable()
	end
end
RegisterCommand({
	Name = "tweenclicktp",
	Aliases = {"tctp", "smoothtp", "blinktp"},
	Description = "Toggles a smooth, camera-animated teleport. Hold Left Alt and click to use."
}, function(args)
	Modules.TweenClickTP:Toggle()
end)
Modules.UniversalESP = {
    State = {
        ActiveFolders = {} :: {[Instance]: ESPData}
    },
    Config = {
        FILL_COLOR = Color3.fromRGB(147, 112, 219),
        OUTLINE_COLOR = Color3.fromRGB(255, 255, 255),
        FILL_TRANSPARENCY = 0.5,
        OUTLINE_TRANSPARENCY = 0,
        HIGHLIGHT_LIMIT = 31
    }
}
function Modules.UniversalESP:_resolvePath(path: string): Instance?
    local success, result = pcall(function()
        local segments = string.split(path, ".")
        local current: any = game
        for i, name in ipairs(segments) do
            if i == 1 then
                if name:lower() == "game" then
                    continue
                elseif name:lower() == "workspace" then
                    current = workspace
                    continue
                else
                    current = game:GetService(name) or game:FindFirstChild(name)
                end
            else
                current = current:FindFirstChild(name)
            end
            if not current then break end
        end
        return current
    end)
    return success and result or nil
end
function Modules.UniversalESP:_highlight(instance: Instance, storage: {[Instance]: Highlight}): ()
    if not (instance:IsA("BasePart") or instance:IsA("Model")) then return end
    if storage[instance] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Universal_ESP_Layer"
    highlight.Adornee = instance
    highlight.FillColor = self.Config.FILL_COLOR
    highlight.OutlineColor = self.Config.OUTLINE_COLOR
    highlight.FillTransparency = self.Config.FILL_TRANSPARENCY
    highlight.OutlineTransparency = self.Config.OUTLINE_TRANSPARENCY
    highlight.Parent = CoreGui
    storage[instance] = highlight
end
function Modules.UniversalESP:Disable(folder: Instance): ()
    local data = self.State.ActiveFolders[folder]
    if not data then return end
    if data.Added then data.Added:Disconnect() end
    if data.Removed then data.Removed:Disconnect() end
    for item, highlight in pairs(data.Highlights) do
        pcall(function() highlight:Destroy() end)
    end
    self.State.ActiveFolders[folder] = nil
    DoNotif("Deactivated ESP for: " .. folder.Name, 2)
end
function Modules.UniversalESP:Enable(folder: Instance): ()
    if self.State.ActiveFolders[folder] then return end
    local data: ESPData = {
        Highlights = {},
        Added = nil,
        Removed = nil
    }
    local function process(child: Instance)
        if child:IsA("BasePart") or child:IsA("Model") then
            self:_highlight(child, data.Highlights)
        elseif child:IsA("Folder") or child:IsA("Configuration") then
            for _, subChild in ipairs(child:GetChildren()) do
                process(subChild)
            end
        end
    end
    data.Added = folder.DescendantAdded:Connect(function(descendant)
        task.defer(process, descendant)
    end)
    data.Removed = folder.DescendantRemoving:Connect(function(descendant)
        if data.Highlights[descendant] then
            pcall(function() data.Highlights[descendant]:Destroy() end)
            data.Highlights[descendant] = nil
        end
    end)
    self.State.ActiveFolders[folder] = data
    for _, child in ipairs(folder:GetChildren()) do
        process(child)
    end
    DoNotif("Activated ESP for: " .. folder.Name, 2)
end
function Modules.UniversalESP:Initialize(): ()
    local module = self
    RegisterCommand({
        Name = "espfolder",
        Aliases = {"fesp", "highf"},
        Description = "Recursive highlight for objects in a specified path."
    }, function(args: {string})
        local path = args[1]
        if not path then return DoNotif("Argument Required: Path", 3) end
        local folder = module:_resolvePath(path)
        if not folder then return DoNotif("Invalid Object Path: " .. path, 3) end
        if module.State.ActiveFolders[folder] then
            module:Disable(folder)
        else
            module:Enable(folder)
        end
    end)
end
Modules.FolderAimbot = {
    State = {
        IsEnabled = false,
        IsAiming = false,
        TargetFolder = nil,
        Connection = nil,
        InputBegan = nil,
        InputEnded = nil
    },
    Config = {
        FOV = 200,
        SMOOTHING = 0.25,
        AIM_KEY = Enum.UserInputType.MouseButton2
    }
}
function Modules.FolderAimbot:_resolvePath(path: string): Instance?
    local current: Instance = game
    for component in string.gmatch(path, "[^%.]+") do
        if string.find(component, ":GetService") then
            local serviceName = component:match("'(.-)'") or component:match('"(.-)"')
            current = serviceName and game:GetService(serviceName) or current
        else
            current = current and current:FindFirstChild(component)
        end
    end
    return current
end
function Modules.FolderAimbot:_getTargetPos(model: Model): Vector3?
    local priority = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
    for _, name in ipairs(priority) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part.Position
        end
    end
    return model.PrimaryPart and model.PrimaryPart.Position
end
function Modules.FolderAimbot:GetClosestTarget(): Model?
    local folder = self.State.TargetFolder
    if not folder then return nil end
    local closestTarget = nil
    local shortestDist = self.Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            local pos = self:_getTargetPos(child)
            if pos then
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestTarget = child
                    end
                end
            end
        end
    end
    return closestTarget
end
function Modules.FolderAimbot:Enable(folder: Instance, fov: number?): ()
    self:Disable()
    self.State.IsEnabled = true
    self.State.TargetFolder = folder
    if fov then self.Config.FOV = fov end
    self.State.InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == self.Config.AIM_KEY then
            self.State.IsAiming = true
        end
    end)
    self.State.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == self.Config.AIM_KEY then
            self.State.IsAiming = false
        end
    end)
    self.State.Connection = RunService.RenderStepped:Connect(function()
        if not self.State.IsAiming then return end
        local target = self:GetClosestTarget()
        if target then
            local pos = self:_getTargetPos(target)
            if pos then
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local deltaX = (screenPos.X - mousePos.X) * self.Config.SMOOTHING
                    local deltaY = (screenPos.Y - mousePos.Y) * self.Config.SMOOTHING
                    if mousemoverel then
                        mousemoverel(deltaX, deltaY)
                    end
                end
            end
        end
    end)
    DoNotif("Folder Aimbot: ENABLED for " .. folder.Name, 2)
end
function Modules.FolderAimbot:Disable(): ()
    self.State.IsEnabled = false
    self.State.IsAiming = false
    if self.State.Connection then self.State.Connection:Disconnect() end
    if self.State.InputBegan then self.State.InputBegan:Disconnect() end
    if self.State.InputEnded then self.State.InputEnded:Disconnect() end
    self.State.Connection = nil
    self.State.InputBegan = nil
    self.State.InputEnded = nil
    self.State.TargetFolder = nil
end
function Modules.FolderAimbot:Initialize(): ()
    local module = self
    RegisterCommand({
        Name = "faim",
        Aliases = {"folderamt", "targetfolder"},
        Description = "Aimbot for all models in a folder. Usage: ;faim Workspace.Zombies 300"
    }, function(args: {string})
        local path = args[1]
        local fov = tonumber(args[2])
        if not path then
            if module.State.IsEnabled then
                module:Disable()
                return DoNotif("Folder Aimbot: DISABLED", 2)
            end
            return DoNotif("Usage: ;faim <Path> [FOV]", 3)
        end
        local folder = module:_resolvePath(path)
        if folder then
            module:Enable(folder, fov)
        else
            DoNotif("Error: Invalid path.", 3)
        end
    end)
end
Modules.RespawnOnPlayer = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Connection = nil
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService")
    }
}
function Modules.RespawnOnPlayer:_onCharacterAdded(character)
    task.defer(function()
        if not self.State.IsEnabled or not self.State.TargetPlayer or not self.State.TargetPlayer.Parent then
            DoNotif("Respawn target lost. Disabling.", 3)
            self:Disable()
            return
        end
        local myRoot = character and character:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local targetCharacter = self.State.TargetPlayer.Character
        local targetRoot = nil
        if not targetCharacter then
            DoNotif("Waiting for " .. self.State.TargetPlayer.Name .. " to spawn...", 2)
            for i = 1, 10 do
                targetCharacter = self.State.TargetPlayer.Character
                if targetCharacter then break end
                task.wait(0.5)
            end
        end
        if targetCharacter then
            targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        end
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            DoNotif("Respawned on " .. self.State.TargetPlayer.Name, 2)
        else
            DoNotif("Could not respawn on target: Character not found (they may be respawning or have left).", 3)
        end
    end)
end
function Modules.RespawnOnPlayer:Enable(targetPlayer)
    if not targetPlayer or targetPlayer == self.Services.Players.LocalPlayer then
        return DoNotif("Invalid or self-targeted player.", 3)
    end
    self:Disable()
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    local module = self
    self.State.Connection = self.Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        module:_onCharacterAdded(char)
    end)
    DoNotif("Respawn on Target: ENABLED. Will respawn on " .. targetPlayer.Name, 3)
end
function Modules.RespawnOnPlayer:Disable()
    if not self.State.IsEnabled then return end
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    self.State.TargetPlayer = nil
    self.State.IsEnabled = false
    DoNotif("Respawn on Target: DISABLED.", 2)
end
RegisterCommand({
    Name = "respawnontarget",
    Aliases = {"spon", "respawnon"},
    Description = "Sets your respawn point to a target player's location."
}, function(args)
    local argument = table.concat(args, " ")
    if not argument or argument == "" then
        return DoNotif("Usage: ;spon <PlayerName|clear>", 3)
    end
    if argument:lower() == "clear" or argument:lower() == "reset" or argument:lower() == "off" then
        Modules.RespawnOnPlayer:Disable()
        return
    end
    local targetPlayer = Utilities.findPlayer(argument)
    if targetPlayer then
        Modules.RespawnOnPlayer:Enable(targetPlayer)
    else
        DoNotif("Player not found: '" .. argument .. "'", 3)
    end
end)
Modules.VariableSniper = { State = { IsScanning = false } }
function Modules.VariableSniper:Search(varName, newValue)
    local foundCount = 0
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, varName) ~= nil then
            rawset(obj, varName, newValue)
            foundCount = foundCount + 1
        end
    end
    DoNotif("Sniper: Patched " .. foundCount .. " instances of '" .. varName .. "'", 3)
end
RegisterCommand({
    Name = "snipe",
    Aliases = {"patchvar", "memedit"},
    Description = "Scans memory for a variable name and overwrites its value. ;snipe isAdmin true"
}, function(args)
    local var = args[1]
    local val = args[2]
    if val == "true" then val = true elseif val == "false" then val = false end
    Modules.VariableSniper:Search(var, val)
end)
Modules.SignalRespawn = {
    State = {
        IsExecuting = false
    },
    Dependencies = {"Players", "Workspace", "ReplicateSignal"},
    Services = {}
}
function Modules.SignalRespawn:_getAllTools()
    local lp = self.Services.Players.LocalPlayer
    local tools = {}
    local backpack = lp:FindFirstChildOfClass("Backpack")
    local char = lp.Character
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(tools, tool) end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then table.insert(tools, tool) end
        end
    end
    return tools
end
function Modules.SignalRespawn:Execute()
    if self.State.IsExecuting then return end
    if not replicatesignal then
        return DoNotif("SignalRespawn: Your executor lacks 'replicatesignal'.", 4)
    end
    local lp = self.Services.Players.LocalPlayer
    local players = self.Services.Players
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = self.Services.Workspace.CurrentCamera
    if not hum or not root then
        return DoNotif("SignalRespawn: Character root not found.", 3)
    end
    self.State.IsExecuting = true
    DoNotif("Initiating signal-based respawn...", 1.5)
    pcall(function()
        replicatesignal(lp.ConnectDiedSignalBackend)
    end)
    local savedCFrame = root.CFrame
    local savedTools = self:_getAllTools()
    task.wait(players.RespawnTime - 0.165)
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Dead)
    end)
    local newChar = lp.CharacterAdded:Wait()
    local newRoot = newChar:WaitForChild("HumanoidRootPart", 5)
    if newRoot then
        task.wait(0.1)
        newRoot.CFrame = savedCFrame
        self.Services.Workspace.CurrentCamera = cam
        DoNotif("Respawn complete. Position restored.", 2)
    end
    self.State.IsExecuting = false
end
function Modules.SignalRespawn:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "signalrespawn",
        Aliases = {"instaspawn"},
        Description = "Advanced instant respawn using signal replication. Restores position."
    }, function()
        module:Execute()
    end)
end
Modules.ExternalChatter = {
    State = {
        IsEnabled = true
    },
    Dependencies = {"TextChatService", "ReplicatedStorage", "Players"},
    Services = {}
}
function Modules.ExternalChatter:Say(args)
    local message = table.concat(args, " ")
    if not message or message == "" then
        return DoNotif("External Chatter: No message provided.", 2)
    end
    local textChatService = self.Services.TextChatService
    local replicatedStorage = self.Services.ReplicatedStorage
    if textChatService and textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = textChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            pcall(function()
                generalChannel:SendAsync(message)
            end)
            return
        end
    end
    local chatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local sayMessageRequest = chatEvents and chatEvents:FindFirstChild("SayMessageRequest")
    if sayMessageRequest and sayMessageRequest:IsA("RemoteEvent") then
        pcall(function()
            sayMessageRequest:FireServer(message, "All")
        end)
    else
        local lp = self.Services.Players.LocalPlayer
        if lp then
            pcall(lp.Chat, lp, message)
        end
    end
end
function Modules.ExternalChatter:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "chat",
        Aliases = {"message"},
        Description = "Forces your character to chat. Bypasses some UI mutes."
    }, function(args)
        module:Say(args)
    end)
end
Modules.StareController = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Mode = nil,
        Connection = nil,
        PrevAutoRotate = true
    },
    Dependencies = {"Players", "RunService"},
    Services = {}
}
function Modules.StareController:_facePosition(targetPos)
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local targetLook = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
        if (targetLook - root.Position).Magnitude > 0.01 then
            root.CFrame = CFrame.lookAt(root.Position, targetLook)
        end
    end
end
function Modules.StareController:_getClosestPlayer()
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, dist = nil, math.huge
    for _, p in ipairs(self.Services.Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = p
            end
        end
    end
    return closest
end
function Modules.StareController:Disable()
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    local lp = self.Services.Players.LocalPlayer
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = self.State.PrevAutoRotate
    end
    self.State.IsEnabled = false
    self.State.TargetPlayer = nil
    self.State.Mode = nil
end
function Modules.StareController:Enable(target, mode)
    self:Disable()
    local lp = self.Services.Players.LocalPlayer
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    self.State.PrevAutoRotate = hum.AutoRotate
    hum.AutoRotate = false
    self.State.IsEnabled = true
    self.State.Mode = mode
    if mode == "Direct" then
        self.State.TargetPlayer = target
        self.State.Connection = self.Services.RunService.RenderStepped:Connect(function()
            if target and target.Parent and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                self:_facePosition(target.Character.HumanoidRootPart.Position)
            else
                self:Disable()
                DoNotif("Stare: Target lost. Disabling.", 2)
            end
        end)
        DoNotif("Staring at: " .. target.Name, 2)
    elseif mode == "Nearest" then
        self.State.Connection = self.Services.RunService.RenderStepped:Connect(function()
            local closest = self:_getClosestPlayer()
            if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                self:_facePosition(closest.Character.HumanoidRootPart.Position)
            end
        end)
        DoNotif("Staring at nearest player.", 2)
    end
end
function Modules.StareController:Initialize()
    local module = self
    for _, s in ipairs(module.Dependencies) do module.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "lookat",
        Aliases = {"stare", "face"},
        Description = "Forces your character to persistently face a player."
    }, function(args)
        local target = Utilities.findPlayer(args[1] or "")
        if target then
            module:Enable(target, "Direct")
        else
            DoNotif("Stare: Player not found.", 3)
        end
    end)
    RegisterCommand({
        Name = "unlookat",
        Aliases = {"unstare", "unface"},
        Description = "Stops the stare effect and restores movement rotation."
    }, function()
        module:Disable()
        DoNotif("Stare disabled.", 2)
    end)
    RegisterCommand({
        Name = "starenear",
        Aliases = {"stareclosest", "snear"},
        Description = "Persistently stare at whoever is closest to you."
    }, function()
        module:Enable(nil, "Nearest")
    end)
    RegisterCommand({
        Name = "unstarenear",
        Aliases = {"unstareclosest"},
        Description = "Stops staring at the closest player."
    }, function()
        module:Disable()
        DoNotif("Nearest Stare disabled.", 2)
    end)
end
Modules.ProximityStalker = {
    State = {
        IsEnabled = false,
        IsFollowing = false,
        TargetPlayer = nil,
        LastDistances = {},
        Connections = {}
    },
    Config = {
        ProximityRadius = 25,
        StopDistance = 5
    },
    Dependencies = {"RunService", "Players"},
    Services = {}
}
function Modules.ProximityStalker:_cleanup()
    for key, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    local lp = self.Services.Players.LocalPlayer
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:MoveTo(lp.Character.PrimaryPart and lp.Character.PrimaryPart.Position or Vector3.zero)
    end
    self.State.LastDistances = {}
    self.State.IsFollowing = false
    self.State.TargetPlayer = nil
    self.State.IsEnabled = false
end
function Modules.ProximityStalker:_setupFollowLogic(target)
    local lp = self.Services.Players.LocalPlayer
    local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not myHum then return end
    self.State.Connections.FollowLoop = self.Services.RunService.Heartbeat:Connect(function()
        local tChar = target.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local myChar = lp.Character
        if myChar and tRoot and tChar.Parent then
            local dist = (tRoot.Position - myChar.PrimaryPart.Position).Magnitude
            if dist > self.Config.StopDistance then
                myHum:MoveTo(tRoot.Position)
            end
        else
            if self.State.Connections.FollowLoop then
                self.State.Connections.FollowLoop:Disconnect()
            end
            self.State.IsFollowing = false
            self.State.TargetPlayer = nil
            DoNotif("Proximity Stalker: Target lost. Resuming scan.", 2)
        end
    end)
    local tHum = target.Character:FindFirstChildOfClass("Humanoid")
    if tHum then
        self.State.Connections.TargetDied = tHum.Died:Connect(function()
            if self.State.Connections.FollowLoop then self.State.Connections.FollowLoop:Disconnect() end
            self.State.IsFollowing = false
            self.State.TargetPlayer = nil
        end)
    end
end
function Modules.ProximityStalker:Start()
    self:_cleanup()
    self.State.IsEnabled = true
    local lp = self.Services.Players.LocalPlayer
    DoNotif("Proximity Stalker: ACTIVE (Radius: " .. self.Config.ProximityRadius .. ")", 2)
    self.State.Connections.Scanner = self.Services.RunService.Heartbeat:Connect(function()
        if self.State.IsFollowing or not self.State.IsEnabled then return end
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        for _, plr in ipairs(self.Services.Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = plr.Character.HumanoidRootPart
                local currentDist = (myRoot.Position - tRoot.Position).Magnitude
                local lastDist = self.State.LastDistances[plr]
                if lastDist and lastDist > self.Config.ProximityRadius and currentDist <= self.Config.ProximityRadius then
                    self.State.IsFollowing = true
                    self.State.TargetPlayer = plr
                    DoNotif("Stalker: Locked onto " .. plr.Name, 2)
                    self:_setupFollowLogic(plr)
                    self.State.Connections.TargetRespawn = plr.CharacterAdded:Connect(function(newChar)
                        task.wait(0.5)
                        if self.State.IsEnabled and self.State.TargetPlayer == plr then
                            self:_setupFollowLogic(plr)
                        end
                    end)
                    break
                end
                self.State.LastDistances[plr] = currentDist
            end
        end
    end)
end
function Modules.ProximityStalker:Initialize()
    local module = self
    for _, s in ipairs(module.Dependencies) do module.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "autofollow",
        Aliases = {"autostalk", "proxfollow", "stalkonapproach"},
        Description = "Automatically follows any player who walks into your proximity radius."
    }, function()
        module:Start()
    end)
    RegisterCommand({
        Name = "unautofollow",
        Aliases = {"stopautostalk", "unproxfollow"},
        Description = "Disables the proximity stalker and stops current movement."
    }, function()
        module:_cleanup()
        DoNotif("Proximity Stalker: DISABLED", 2)
    end)
end
Modules.ForceRespawn = {
}
function Modules.ForceRespawn:Execute()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        DoNotif("Cannot respawn: LocalPlayer not found.", 3)
        return
    end
    DoNotif("Attempting to force respawn...", 2)
    local success, err = pcall(function()
        LocalPlayer:LoadCharacter()
    end)
    if not success then
        warn("[ForceRespawn] LoadCharacter failed:", err)
        DoNotif("Respawn request failed. The server may have rejected it.", 4)
    end
end
function Modules.ForceRespawn:Initialize()
    RegisterCommand({
        Name = "respawn",
        Aliases = {"rr"},
        Description = "Forces your character to respawn. Useful if you are stuck or punished."
    }, function()
        Modules.ForceRespawn:Execute()
    end)
end
RegisterCommand({
    Name = "gclog",
    Aliases = {"memcheck", "gcinfo"},
    Description = "Dumps current Garbage Collector stats to the console."
}, function()
    local current = collectgarbage("count")
    local objects = #getgc()
    local diff = current - _GC_START
    print("--- [GC] ---")
    print(string.format("Baseline Memory: %.2f KB", _GC_START))
    print(string.format("Current Memory: %.2f KB", current))
    print(string.format("Memory Delta: %.2f KB", diff))
    print(string.format("Live Lua Objects: %d", objects))
    print("----------------------------")
    DoNotif(string.format("Memory Usage: %.2f KB", current), 2)
end)
Modules.AntiAim = {
    State = {
        IsEnabled = false,
        Connection = nil,
        CharacterConnection = nil,
        HealthConnection = nil,
        CameraConnection = nil,
        CounterAttachConnection = nil,
        RealVisualizer = nil,
        DesyncVisualizer = nil,
        CurrentPattern = nil,
        PatternStartTime = 0,
        LastHitTime = 0,
        HitCount = 0,
        AdaptiveMode = false,
        OriginalNeckC0 = nil,
        InversionActive = false,
        AttachedPlayers = {},
        CurrentAttachTarget = nil
    },
    Config = {
        VelocityStrength = 9000,
        SnapBack = true,
        Visuals = true,
        StrengthVariation = true,
        MinStrength = 5000,
        MaxStrength = 15000,
        SnapBackMode = "random",
        SnapBackDelay = 0.05,
        MultiPartDesync = false,
        AdaptiveDetection = true,
        JitterEnabled = true,
        JitterStrength = 500,
        InversionEnabled = false,
        InversionOffset = -3.5,
        RandomInversion = false,
        CameraCorrection = true,
        CounterAttachEnabled = false,
        CounterAttachMode = "reverse",
        CounterAttachDistance = 5,
        CounterAttachNotify = true
    }
}
function Modules.AntiAim:_getDynamicStrength()
    if self.Config.StrengthVariation then
        return math.random(self.Config.MinStrength, self.Config.MaxStrength)
    end
    return self.Config.VelocityStrength
end
function Modules.AntiAim:_generateDesyncVector()
    local strength = self:_getDynamicStrength()
    local patterns = {
        function(t)
            return Vector3.new(
                math.cos(t * 10) * strength,
                math.sin(t * 5) * strength,
                math.sin(t * 10) * strength
            )
        end,
        function(t)
            return Vector3.new(
                math.sin(t * 8) * strength,
                math.cos(t * 4) * strength * 0.5,
                math.sin(t * 4) * math.cos(t * 4) * strength
            )
        end,
        function(t)
            local noise = math.noise(t * 20, t * 15, t * 10) or 0.5
            return Vector3.new(
                math.random(-100, 100) * noise,
                math.random(-100, 100) * noise,
                math.random(-100, 100) * noise
            ).Unit * strength
        end,
        function(t)
            local burstIndex = math.floor(t * 30) % 6
            local directions = {
                Vector3.new(1, 0, 0),
                Vector3.new(-1, 0, 0),
                Vector3.new(0, 1, 0),
                Vector3.new(0, -1, 0),
                Vector3.new(0, 0, 1),
                Vector3.new(0, 0, -1)
            }
            return directions[burstIndex + 1] * strength
        end,
        function(t)
            local angle = t * 15
            return Vector3.new(
                math.cos(angle) * strength,
                math.random(-1, 1) * strength * 0.3,
                math.sin(angle) * strength
            )
        end
    }
    if not self.State.CurrentPattern or math.random() < 0.15 then
        self.State.CurrentPattern = patterns[math.random(1, #patterns)]
        self.State.PatternStartTime = tick()
    end
    local baseVector = self.State.CurrentPattern(tick() - self.State.PatternStartTime)
    if self.Config.JitterEnabled then
        local jitter = Vector3.new(
            math.random(-self.Config.JitterStrength, self.Config.JitterStrength),
            math.random(-self.Config.JitterStrength, self.Config.JitterStrength),
            math.random(-self.Config.JitterStrength, self.Config.JitterStrength)
        )
        baseVector = baseVector + jitter
    end
    return baseVector
end
function Modules.AntiAim:_applyPartDesync()
    local character = LocalPlayer.Character
    if not character then return end
    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
        character:FindFirstChild("LeftUpperArm"),
        character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("LeftLowerArm"),
        character:FindFirstChild("RightLowerArm")
    }
    for i, part in ipairs(parts) do
        if part and part:IsA("BasePart") then
            local offset = Vector3.new(
                math.random(-1, 1),
                math.random(-1, 1),
                math.random(-1, 1)
            ).Unit * (self:_getDynamicStrength() * (i * 0.25))
            part.AssemblyLinearVelocity = self:_generateDesyncVector() + offset
        end
    end
end
function Modules.AntiAim:_detectAttachers()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local theirRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local theirHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if theirRoot and theirHumanoid and theirHumanoid.Health > 0 then
                local distance = (myRoot.Position - theirRoot.Position).Magnitude
                if distance < 8 and distance > 0.1 then
                    local relativeVel = (theirRoot.AssemblyLinearVelocity - myRoot.AssemblyLinearVelocity).Magnitude
                    if relativeVel < 50 then
                        if not self.State.AttachedPlayers[player.UserId] then
                            self.State.AttachedPlayers[player.UserId] = {
                                Player = player,
                                DetectedTime = tick(),
                                Confirmed = false
                            }
                        else
                            if tick() - self.State.AttachedPlayers[player.UserId].DetectedTime > 0.5 then
                                self.State.AttachedPlayers[player.UserId].Confirmed = true
                                if self.Config.CounterAttachNotify and not self.State.CurrentAttachTarget then
                                    DoNotif("🎯 ATTACHER DETECTED: " .. player.Name, 2)
                                end
                                self.State.CurrentAttachTarget = player
                            end
                        end
                    else
                        self.State.AttachedPlayers[player.UserId] = nil
                    end
                else
                    self.State.AttachedPlayers[player.UserId] = nil
                    if self.State.CurrentAttachTarget == player then
                        self.State.CurrentAttachTarget = nil
                    end
                end
            end
        end
    end
end
function Modules.AntiAim:_applyCounterAttach()
    if not self.State.CurrentAttachTarget then return end
    local target = self.State.CurrentAttachTarget
    if not target.Character then
        self.State.CurrentAttachTarget = nil
        return
    end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then
        self.State.CurrentAttachTarget = nil
        return
    end
    local mode = self.Config.CounterAttachMode
    local distance = self.Config.CounterAttachDistance
    if mode == "reverse" then
        local offset = Vector3.new(0, 2, distance)
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(offset)
        myRoot.AssemblyLinearVelocity = targetRoot.AssemblyLinearVelocity
    elseif mode == "orbit" then
        local angle = tick() * 5
        local offset = Vector3.new(
            math.cos(angle) * distance,
            2,
            math.sin(angle) * distance
        )
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(offset)
        myRoot.AssemblyLinearVelocity = Vector3.zero
    elseif mode == "spinattack" then
        local angle = tick() * 10
        local offset = Vector3.new(
            math.cos(angle) * 3,
            math.sin(angle * 2) * 2,
            math.sin(angle) * 3
        )
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(offset)
        myRoot.AssemblyLinearVelocity = Vector3.new(
            math.random(-100, 100),
            math.random(-100, 100),
            math.random(-100, 100)
        )
    end
end
function Modules.AntiAim:_setupCounterAttach()
    if self.State.CounterAttachConnection then
        self.State.CounterAttachConnection:Disconnect()
        self.State.CounterAttachConnection = nil
    end
    if not self.Config.CounterAttachEnabled then return end
    self.State.CounterAttachConnection = RunService.Heartbeat:Connect(function()
        if not self.State.IsEnabled then return end
        self:_detectAttachers()
        if self.State.CurrentAttachTarget then
            self:_applyCounterAttach()
        end
    end)
end
function Modules.AntiAim:_setupCameraCorrection()
    if self.State.CameraConnection then
        self.State.CameraConnection:Disconnect()
        self.State.CameraConnection = nil
    end
    if not self.Config.CameraCorrection then return end
    self.State.CameraConnection = RunService.RenderStepped:Connect(function()
        if not self.State.IsEnabled or not self.Config.InversionEnabled then return end
        local camera = workspace.CurrentCamera
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not camera or not humanoid then return end
        if self.State.InversionActive then
            local currentCF = camera.CFrame
            local pos = currentCF.Position
            local lookVector = currentCF.LookVector
            local upVector = Vector3.new(0, 1, 0)
            local rightVector = lookVector:Cross(upVector).Unit
            upVector = rightVector:Cross(lookVector).Unit
            camera.CFrame = CFrame.fromMatrix(pos, rightVector, upVector, -lookVector)
        end
    end)
end
function Modules.AntiAim:_applyInversion()
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    if self.Config.RandomInversion and math.random() < 0.05 then
        self.State.InversionActive = not self.State.InversionActive
    end
    if self.State.InversionActive then
        local currentCF = root.CFrame
        local invertedCF = currentCF * CFrame.Angles(math.pi, 0, 0)
        invertedCF = invertedCF + Vector3.new(0, self.Config.InversionOffset, 0)
        root.CFrame = invertedCF
        if humanoid.Sit then
            humanoid.Sit = false
        end
    end
end
function Modules.AntiAim:_setupAdaptiveDetection()
    if not self.Config.AdaptiveDetection then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and not self.State.HealthConnection then
        self.State.HealthConnection = humanoid.HealthChanged:Connect(function(health)
            if not self.State.IsEnabled then return end
            local now = tick()
            if now - self.State.LastHitTime < 2 then
                self.State.HitCount += 1
                if self.State.HitCount >= 3 and not self.State.AdaptiveMode then
                    self.State.AdaptiveMode = true
                    local oldStrength = self.Config.VelocityStrength
                    self.Config.VelocityStrength = math.min(oldStrength * 2.5, 25000)
                    if self.Config.InversionEnabled and not self.State.InversionActive then
                        self.State.InversionActive = true
                    end
                    DoNotif("⚠️ TRACKING DETECTED - ADAPTIVE AA ENGAGED", 2)
                    task.delay(5, function()
                        if self.State.IsEnabled then
                            self.State.AdaptiveMode = false
                            self.Config.VelocityStrength = oldStrength
                            self.State.HitCount = 0
                            DoNotif("Adaptive AA: [RESET]", 1.5)
                        end
                    end)
                end
            else
                self.State.HitCount = 1
            end
            self.State.LastHitTime = now
        end)
    end
end
function Modules.AntiAim:_updateVisualizer()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if self.State.IsEnabled and self.Config.Visuals and root then
        if not self.State.RealVisualizer then
            local sb = Instance.new("SelectionBox")
            sb.Name = "AA_Real_Visualizer"
            sb.Color3 = Color3.fromRGB(0, 255, 0)
            sb.LineThickness = 0.05
            sb.Adornee = root
            sb.Parent = root
            self.State.RealVisualizer = sb
        else
            self.State.RealVisualizer.Adornee = root
            self.State.RealVisualizer.Parent = root
        end
        if not self.State.DesyncVisualizer then
            local ghost = Instance.new("Part")
            ghost.Name = "AA_Desync_Ghost"
            ghost.CanCollide = false
            ghost.CanTouch = false
            ghost.CanQuery = false
            ghost.Anchored = true
            ghost.Size = root.Size
            ghost.Color = Color3.fromRGB(255, 0, 0)
            ghost.Material = Enum.Material.Neon
            ghost.Transparency = 0.6
            ghost.Parent = workspace.Terrain
            local outline = Instance.new("SelectionBox")
            outline.Color3 = Color3.fromRGB(255, 255, 255)
            outline.LineThickness = 0.03
            outline.Adornee = ghost
            outline.Parent = ghost
            self.State.DesyncVisualizer = ghost
        end
    else
        if self.State.RealVisualizer then
            self.State.RealVisualizer:Destroy()
            self.State.RealVisualizer = nil
        end
        if self.State.DesyncVisualizer then
            self.State.DesyncVisualizer:Destroy()
            self.State.DesyncVisualizer = nil
        end
    end
end
function Modules.AntiAim:_onHeartbeat()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not self.State.IsEnabled then return end
    if self.Config.CounterAttachEnabled and self.State.CurrentAttachTarget then
        return
    end
    local oldCFrame = root.CFrame
    local oldVelocity = root.AssemblyLinearVelocity
    if self.Config.InversionEnabled then
        self:_applyInversion()
        oldCFrame = root.CFrame
    end
    if self.Config.MultiPartDesync then
        self:_applyPartDesync()
    else
        root.AssemblyLinearVelocity = self:_generateDesyncVector()
    end
    local snapMode = self.Config.SnapBackMode
    if snapMode == "random" then
        local modes = {"instant", "delayed", "partial"}
        snapMode = modes[math.random(1, #modes)]
    end
    if snapMode == "instant" then
        RunService.RenderStepped:Wait()
        if root and root.Parent and self.State.IsEnabled then
            if self.Config.Visuals and self.State.DesyncVisualizer then
                self.State.DesyncVisualizer.CFrame = root.CFrame
            end
            if self.Config.SnapBack then
                root.CFrame = oldCFrame
            end
            root.AssemblyLinearVelocity = oldVelocity
        end
    elseif snapMode == "delayed" then
        RunService.RenderStepped:Wait()
        local desyncedCFrame = root.CFrame
        task.wait(self.Config.SnapBackDelay)
        if root and root.Parent and self.State.IsEnabled then
            if self.Config.Visuals and self.State.DesyncVisualizer then
                self.State.DesyncVisualizer.CFrame = desyncedCFrame
            end
            if self.Config.SnapBack then
                root.CFrame = oldCFrame
            end
            root.AssemblyLinearVelocity = oldVelocity
        end
    elseif snapMode == "partial" then
        RunService.RenderStepped:Wait()
        if root and root.Parent and self.State.IsEnabled then
            local desyncedCFrame = root.CFrame
            if self.Config.Visuals and self.State.DesyncVisualizer then
                self.State.DesyncVisualizer.CFrame = desyncedCFrame
            end
            if self.Config.SnapBack then
                root.CFrame = oldCFrame:Lerp(desyncedCFrame, 0.3)
            end
            root.AssemblyLinearVelocity = oldVelocity
        end
    end
end
function Modules.AntiAim:Enable()
    if self.State.IsEnabled then return end
    self:Disable(true)
    self.State.IsEnabled = true
    self.State.Connection = RunService.Heartbeat:Connect(function()
        self:_onHeartbeat()
    end)
    self.State.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        if self.State.IsEnabled then
            self:_updateVisualizer()
            self:_setupAdaptiveDetection()
            self:_setupCameraCorrection()
            self:_setupCounterAttach()
            self.State.OriginalNeckC0 = nil
        end
    end)
    self:_updateVisualizer()
    self:_setupAdaptiveDetection()
    self:_setupCameraCorrection()
    self:_setupCounterAttach()
    local mode = self.Config.SnapBackMode == "random" and "RANDOM" or self.Config.SnapBackMode:upper()
    local invStatus = self.Config.InversionEnabled and " | INVERTED" or ""
    local caStatus = self.Config.CounterAttachEnabled and " | CA" or ""
    DoNotif("Anti-Aim: [ENABLED] | Mode: " .. mode .. invStatus .. caStatus, 2)
end
function Modules.AntiAim:Disable(silent)
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    if self.State.CharacterConnection then
        self.State.CharacterConnection:Disconnect()
        self.State.CharacterConnection = nil
    end
    if self.State.HealthConnection then
        self.State.HealthConnection:Disconnect()
        self.State.HealthConnection = nil
    end
    if self.State.CameraConnection then
        self.State.CameraConnection:Disconnect()
        self.State.CameraConnection = nil
    end
    if self.State.CounterAttachConnection then
        self.State.CounterAttachConnection:Disconnect()
        self.State.CounterAttachConnection = nil
    end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    self.State.InversionActive = false
    self.State.OriginalNeckC0 = nil
    self.State.AttachedPlayers = {}
    self.State.CurrentAttachTarget = nil
    self:_updateVisualizer()
    if not silent then
        DoNotif("Anti-Aim: [DISABLED]", 2)
    end
end
function Modules.AntiAim:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.AntiAim:Initialize()
    local module = self
    RegisterCommand({
        Name = "antiaim",
        Aliases = {"aa"},
        Description = "Toggles velocity-based Anti-Aim."
    }, function(args)
        local strength = tonumber(args[1])
        if strength then
            module.Config.VelocityStrength = strength
            DoNotif("Anti-Aim Strength: " .. strength, 2)
        end
        module:Toggle()
    end)
    RegisterCommand({
        Name = "aasnap",
        Aliases = {"snapback"},
        Description = "Toggles CFrame snapback."
    }, function()
        module.Config.SnapBack = not module.Config.SnapBack
        DoNotif("Snapback: " .. (module.Config.SnapBack and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aavis",
        Description = "Toggles Anti-Aim Hitbox Visuals."
    }, function()
        module.Config.Visuals = not module.Config.Visuals
        module:_updateVisualizer()
        DoNotif("AA Visuals: " .. (module.Config.Visuals and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aamode",
        Description = "Sets snapback mode: instant, delayed, partial, random"
    }, function(args)
        local modes = {instant = true, delayed = true, partial = true, random = true}
        local mode = string.lower(args[1] or "")
        if modes[mode] then
            module.Config.SnapBackMode = mode
            DoNotif("AA Mode: " .. mode:upper(), 2)
        else
            DoNotif("Valid modes: instant, delayed, partial, random", 2)
        end
    end)
    RegisterCommand({
        Name = "aavary",
        Aliases = {"aavariation"},
        Description = "Toggles strength variation"
    }, function()
        module.Config.StrengthVariation = not module.Config.StrengthVariation
        DoNotif("Strength Variation: " .. (module.Config.StrengthVariation and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aamulti",
        Description = "Toggles multi-part desync"
    }, function()
        module.Config.MultiPartDesync = not module.Config.MultiPartDesync
        DoNotif("Multi-Part Desync: " .. (module.Config.MultiPartDesync and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aajitter",
        Description = "Toggles micro-jitter"
    }, function()
        module.Config.JitterEnabled = not module.Config.JitterEnabled
        DoNotif("Jitter: " .. (module.Config.JitterEnabled and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aaadaptive",
        Description = "Toggles adaptive tracking detection"
    }, function()
        module.Config.AdaptiveDetection = not module.Config.AdaptiveDetection
        DoNotif("Adaptive Detection: " .. (module.Config.AdaptiveDetection and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aainvert",
        Aliases = {"aaflip"},
        Description = "Toggles character inversion (upside down)"
    }, function()
        module.Config.InversionEnabled = not module.Config.InversionEnabled
        if module.Config.InversionEnabled then
            module.State.InversionActive = true
            module:_setupCameraCorrection()
        else
            module.State.InversionActive = false
        end
        DoNotif("Inversion: " .. (module.Config.InversionEnabled and "ON 🙃" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aaoffset",
        Description = "Sets inversion ground offset (negative = lower)"
    }, function(args)
        local offset = tonumber(args[1])
        if offset then
            module.Config.InversionOffset = offset
            DoNotif("Inversion Offset: " .. offset, 2)
        else
            DoNotif("Current Offset: " .. module.Config.InversionOffset, 2)
        end
    end)
    RegisterCommand({
        Name = "aarandom",
        Description = "Toggles random inversion flipping"
    }, function()
        module.Config.RandomInversion = not module.Config.RandomInversion
        DoNotif("Random Inversion: " .. (module.Config.RandomInversion and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aacamera",
        Description = "Toggles camera correction for inversion"
    }, function()
        module.Config.CameraCorrection = not module.Config.CameraCorrection
        if module.Config.CameraCorrection then
            module:_setupCameraCorrection()
        else
            if module.State.CameraConnection then
                module.State.CameraConnection:Disconnect()
                module.State.CameraConnection = nil
            end
        end
        DoNotif("Camera Correction: " .. (module.Config.CameraCorrection and "ON" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aacounter",
        Aliases = {"aaca"},
        Description = "Toggles counter-attach system"
    }, function()
        module.Config.CounterAttachEnabled = not module.Config.CounterAttachEnabled
        if module.Config.CounterAttachEnabled then
            module:_setupCounterAttach()
        else
            if module.State.CounterAttachConnection then
                module.State.CounterAttachConnection:Disconnect()
                module.State.CounterAttachConnection = nil
            end
            module.State.AttachedPlayers = {}
            module.State.CurrentAttachTarget = nil
        end
        DoNotif("Counter-Attach: " .. (module.Config.CounterAttachEnabled and "ON 🎯" or "OFF"), 2)
    end)
    RegisterCommand({
        Name = "aacamode",
        Description = "Sets counter-attach mode: reverse, orbit, spinattack"
    }, function(args)
        local modes = {reverse = true, orbit = true, spinattack = true}
        local mode = string.lower(args[1] or "")
        if modes[mode] then
            module.Config.CounterAttachMode = mode
            DoNotif("Counter-Attach Mode: " .. mode:upper(), 2)
        else
            DoNotif("Valid modes: reverse, orbit, spinattack", 2)
        end
    end)
    RegisterCommand({
        Name = "aacadist",
        Description = "Sets counter-attach distance"
    }, function(args)
        local dist = tonumber(args[1])
        if dist then
            module.Config.CounterAttachDistance = dist
            DoNotif("Counter-Attach Distance: " .. dist, 2)
        else
            DoNotif("Current Distance: " .. module.Config.CounterAttachDistance, 2)
        end
    end)
    RegisterCommand({
        Name = "aacatarget",
        Description = "Shows current counter-attach target"
    }, function()
        if module.State.CurrentAttachTarget then
            DoNotif("Current Target: " .. module.State.CurrentAttachTarget.Name, 2)
        else
            DoNotif("No active counter-attach target", 2)
        end
    end)
    RegisterCommand({
        Name = "aaconfig",
        Aliases = {"aastatus"},
        Description = "Shows current AA configuration"
    }, function()
        local config = string.format(
            "AA CONFIG:\nStrength: %d\nMode: %s\nVariation: %s\nMulti-Part: %s\nJitter: %s\nAdaptive: %s\nInversion: %s\nCamera Fix: %s\nCounter-Attach: %s (%s)",
            module.Config.VelocityStrength,
            module.Config.SnapBackMode:upper(),
            module.Config.StrengthVariation and "ON" or "OFF",
            module.Config.MultiPartDesync and "ON" or "OFF",
            module.Config.JitterEnabled and "ON" or "OFF",
            module.Config.AdaptiveDetection and "ON" or "OFF",
            module.Config.InversionEnabled and "ON" or "OFF",
            module.Config.CameraCorrection and "ON" or "OFF",
            module.Config.CounterAttachEnabled and "ON" or "OFF",
            module.Config.CounterAttachMode:upper()
        )
        DoNotif(config, 6)
    end)
end
Modules.Overseer = {
    State = {
        IsEnabled = false,
        ActivePatches = {},
        SelectedModule = nil,
        CurrentTable = nil,
        PathStack = {},
        Minimized = false,
        ViewingCode = false,
        CurrentMode = "modules",
        ExplorerPath = {},
        ExplorerInstance = nil,
        UI = nil,
        SidebarButtons = {},
        ValueHooks = {},
        HookedConnections = {},
        PropertyHooks = {},
        RemoteSpyData = {},
        CallFrequency = {},
        CurrentTypeFilter = nil,
        FilteredResults = {},
        SpyCallLog = {},
        IsSpying = false,
        SelectedRemote = nil,
        DisabledModules = {}
    },
    Config = {
        ACCENT_COLOR = Color3.fromRGB(0, 255, 170),
        BG_COLOR = Color3.fromRGB(10, 10, 12),
        HEADER_COLOR = Color3.fromRGB(15, 15, 18),
        SECONDARY_COLOR = Color3.fromRGB(18, 18, 22),
        HOOK_COLOR = Color3.fromRGB(0, 200, 150),
        DANGER_COLOR = Color3.fromRGB(200, 50, 50),
        BUTTON_HEIGHT = 24,
        ROW_HEIGHT = 35,
        FILTER_HEIGHT = 40,
        PADDING = 4,
        CORNER_RADIUS = 2,
        CODE_BUTTON_HEIGHT = 30
    },
    RemoteSpy = {
        MaxLogSize = 500,
        RecordingTypes = { "FireServer", "FireClient", "InvokeServer" }
    }
}
function Modules.Overseer:_applyStyle(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = obj
end
function Modules.Overseer:_setClipboard(txt)
    if setclipboard then setclipboard(txt) end
end
function Modules.Overseer:_showErrorInGrid(errorText)
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local errorLabel = Instance.new("TextLabel", ui.Grid)
    errorLabel.Size = UDim2.new(1, 0, 0, 40)
    errorLabel.Text = errorText
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    errorLabel.BackgroundTransparency = 0.3
    errorLabel.Font = Enum.Font.Code
    errorLabel.TextSize = 10
    errorLabel.TextWrapped = true
    self:_applyStyle(errorLabel, 2)
end
function Modules.Overseer:_cleanupModuleHooks(mod)
    if self.State.ActivePatches[mod] then
        self.State.ActivePatches[mod] = nil
    end
    for hookKey, hook in pairs(self.State.ValueHooks) do
        if hook.table == mod then
            self.State.ValueHooks[hookKey] = nil
        end
    end
    for propKey, hook in pairs(self.State.PropertyHooks) do
        if hook.instance and hook.instance:IsDescendantOf(mod) then
            if self.State.HookedConnections[propKey] then
                pcall(function() self.State.HookedConnections[propKey]:Disconnect() end)
                self.State.HookedConnections[propKey] = nil
            end
            self.State.PropertyHooks[propKey] = nil
        end
    end
end
function Modules.Overseer:_validatePatches()
    for tbl, keys in pairs(self.State.ActivePatches) do
        if type(tbl) ~= "table" then
            return false
        end
        for key, data in pairs(keys) do
            if data.Value == nil then
                return false
            end
        end
    end
    return true
end
function Modules.Overseer:_validateHooks()
    for hookKey, hook in pairs(self.State.ValueHooks) do
        if hook.enabled and hook.value == nil then
            return false
        end
    end
    for propKey, hook in pairs(self.State.PropertyHooks) do
        if hook.enabled and hook.value == nil then
            return false
        end
    end
    return true
end
function Modules.Overseer:_generateObfuscatedName()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = math.random(10, 20)
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    return result
end
function Modules.Overseer:_applyEnvironment(func, scriptInstance)
    local fenv = {}
    local realFenv = {script = scriptInstance}
    local fenvMt = {}
    fenvMt.__index = function(_, key)
        return realFenv[key] or getfenv()[key]
    end
    fenvMt.__newindex = function(_, key, value)
        if realFenv[key] == nil then
            getfenv()[key] = value
        else
            realFenv[key] = value
        end
    end
    setmetatable(fenv, fenvMt)
    setfenv(func, fenv)
    return func
end
function Modules.Overseer:_createButton(parent, text, size, position, bgColor, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = bgColor or self.Config.HOOK_COLOR
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Code
    btn.TextSize = 9
    self:_applyStyle(btn, self.Config.CORNER_RADIUS)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end
function Modules.Overseer:_createLabel(parent, text, size, position, textColor, bgColor)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = size
    lbl.Position = position
    lbl.Text = text
    lbl.TextColor3 = textColor or Color3.fromRGB(150, 150, 150)
    lbl.BackgroundColor3 = bgColor or Color3.new(0, 0, 0)
    lbl.BackgroundTransparency = (bgColor == nil and 1 or 0.3)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    return lbl
end
function Modules.Overseer:_createRow(parent, labelText, labelSize, labelColor)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
    row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row)
    label.Size = labelSize or UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = labelColor or Color3.fromRGB(150, 150, 150)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ClipsDescendants = true
    return row, label
end
function Modules.Overseer:_initRemoteSpy()
    if self.State.IsSpying then return end
    self.State.IsSpying = true
    local function hookRemotes(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                pcall(function()
                    if child.FireServer and not child:GetAttribute("_OverseerHooked") then
                        local original = child.FireServer
                        if setreadonly then setreadonly(child, false) end
                        child.FireServer = function(remoteself, ...)
                            local args = {...}
                            local parentName = remoteself.Parent and remoteself.Parent.Name or "Unknown"
                            table.insert(Modules.Overseer.State.SpyCallLog, {
                                Type = "FireServer",
                                Remote = remoteself.Name or "Unknown",
                                Parent = parentName,
                                Args = args,
                                Time = tick()
                            })
                            if #Modules.Overseer.State.SpyCallLog > Modules.Overseer.RemoteSpy.MaxLogSize then
                                table.remove(Modules.Overseer.State.SpyCallLog, 1)
                            end
                            return original(remoteself, ...)
                        end
                        child:SetAttribute("_OverseerHooked", true)
                        if setreadonly then setreadonly(child, true) end
                    end
                end)
            elseif child:IsA("RemoteFunction") then
                pcall(function()
                    if child.InvokeServer and not child:GetAttribute("_OverseerHooked") then
                        local original = child.InvokeServer
                        if setreadonly then setreadonly(child, false) end
                        child.InvokeServer = function(remoteself, ...)
                            local args = {...}
                            local parentName = remoteself.Parent and remoteself.Parent.Name or "Unknown"
                            table.insert(Modules.Overseer.State.SpyCallLog, {
                                Type = "InvokeServer",
                                Remote = remoteself.Name or "Unknown",
                                Parent = parentName,
                                Args = args,
                                Time = tick()
                            })
                            if #Modules.Overseer.State.SpyCallLog > Modules.Overseer.RemoteSpy.MaxLogSize then
                                table.remove(Modules.Overseer.State.SpyCallLog, 1)
                            end
                            return original(remoteself, ...)
                        end
                        child:SetAttribute("_OverseerHooked", true)
                        if setreadonly then setreadonly(child, true) end
                    end
                end)
            end
        end
    end
    hookRemotes(ReplicatedStorage)
    hookRemotes(game)
    local hookConnection; hookConnection = game.DescendantAdded:Connect(function(child)
        if self.State.IsSpying then
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                task.wait(0.1)
                pcall(function()
                    if child:IsA("RemoteEvent") and child.FireServer and not child:GetAttribute("_OverseerHooked") then
                        local original = child.FireServer
                        if setreadonly then setreadonly(child, false) end
                        child.FireServer = function(remoteself, ...)
                            local args = {...}
                            local parentName = remoteself.Parent and remoteself.Parent.Name or "Unknown"
                            table.insert(Modules.Overseer.State.SpyCallLog, {
                                Type = "FireServer",
                                Remote = remoteself.Name or "Unknown",
                                Parent = parentName,
                                Args = args,
                                Time = tick()
                            })
                            if #Modules.Overseer.State.SpyCallLog > Modules.Overseer.RemoteSpy.MaxLogSize then
                                table.remove(Modules.Overseer.State.SpyCallLog, 1)
                            end
                            return original(remoteself, ...)
                        end
                        child:SetAttribute("_OverseerHooked", true)
                        if setreadonly then setreadonly(child, true) end
                    elseif child:IsA("RemoteFunction") and child.InvokeServer and not child:GetAttribute("_OverseerHooked") then
                        local original = child.InvokeServer
                        if setreadonly then setreadonly(child, false) end
                        child.InvokeServer = function(remoteself, ...)
                            local args = {...}
                            local parentName = remoteself.Parent and remoteself.Parent.Name or "Unknown"
                            table.insert(Modules.Overseer.State.SpyCallLog, {
                                Type = "InvokeServer",
                                Remote = remoteself.Name or "Unknown",
                                Parent = parentName,
                                Args = args,
                                Time = tick()
                            })
                            if #Modules.Overseer.State.SpyCallLog > Modules.Overseer.RemoteSpy.MaxLogSize then
                                table.remove(Modules.Overseer.State.SpyCallLog, 1)
                            end
                            return original(remoteself, ...)
                        end
                        child:SetAttribute("_OverseerHooked", true)
                        if setreadonly then setreadonly(child, true) end
                    end
                end)
            end
        end
    end)
    table.insert(self.State.HookedConnections, hookConnection)
end
function Modules.Overseer:_showRemoteSpy()
    local ui = self.State.UI
    ui.Grid.Visible = true
    ui.CodeFrame.Visible = false
    ui.Title.Text = "REMOTE SPY - " .. #self.State.SpyCallLog .. " CALLS"
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local spyStatusLabel = Instance.new("TextLabel", ui.Grid)
    spyStatusLabel.Size = UDim2.new(1, -10, 0, 30)
    spyStatusLabel.BackgroundColor3 = self.State.IsSpying and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(40, 20, 20)
    spyStatusLabel.Text = "SPY STATUS: " .. (self.State.IsSpying and "ACTIVE" or "INACTIVE")
    spyStatusLabel.TextColor3 = self.State.IsSpying and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    spyStatusLabel.Font = Enum.Font.Code
    spyStatusLabel.TextSize = 10
    self:_applyStyle(spyStatusLabel, 2)
    if not self.State.IsSpying then
        local startBtn = Instance.new("TextButton", ui.Grid)
        startBtn.Size = UDim2.new(0.9, 0, 0, 35)
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
        startBtn.Text = "START SPYING ON ALL REMOTES"
        startBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        startBtn.Font = Enum.Font.Code
        startBtn.TextSize = 10
        self:_applyStyle(startBtn, 2)
        startBtn.MouseButton1Click:Connect(function()
            self:_initRemoteSpy()
            self:_showRemoteSpy()
        end)
    end
    if #self.State.SpyCallLog > 0 then
        local logLabel = Instance.new("TextLabel", ui.Grid)
        logLabel.Size = UDim2.new(1, 0, 0, 20)
        logLabel.Text = " CALL HISTORY (Most Recent First)"
        logLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        logLabel.BackgroundTransparency = 1
        logLabel.Font = Enum.Font.Code
        logLabel.TextSize = 9
        for i = math.min(30, #self.State.SpyCallLog), 1, -1 do
            local call = self.State.SpyCallLog[i]
            if call and call.Remote then
                local row, label = self:_createRow(ui.Grid, "", UDim2.new(0.7, 0, 1, 0))
                local parentName = call.Parent or "Unknown"
                local callText = "[" .. call.Type .. "] " .. call.Remote .. " | Parent: " .. parentName
                label.Text = callText
                label.TextColor3 = (call.Type == "FireServer" and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(150, 100, 255))
                local argsBtn = Instance.new("TextButton", row)
                argsBtn.Size = UDim2.new(0, 60, 0, 24)
                argsBtn.Position = UDim2.fromScale(0.72, 0.15)
                argsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
                argsBtn.Text = "ARGS (" .. (#call.Args or 0) .. ")"
                argsBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
                argsBtn.Font = Enum.Font.Code
                argsBtn.TextSize = 7
                self:_applyStyle(argsBtn, 2)
                argsBtn.MouseButton1Click:Connect(function()
                    self:_showRemoteArgs(call)
                end)
            end
        end
    end
end
function Modules.Overseer:_showRemoteArgs(callInfo)
    local ui = self.State.UI
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "REMOTE ARGS: " .. callInfo.Remote
    local argText = "[" .. callInfo.Type .. "] " .. callInfo.Remote .. "\n\n"
    for i, arg in ipairs(callInfo.Args) do
        local argType = type(arg)
        if argType == "table" then
            argText = argText .. "Arg[" .. i .. "]: TABLE\n"
            for k, v in pairs(arg) do
                argText = argText .. "  [" .. tostring(k) .. "] = " .. tostring(v) .. "\n"
            end
        else
            argText = argText .. "Arg[" .. i .. "]: " .. argType:upper() .. " = " .. tostring(arg) .. "\n"
        end
    end
    ui.CodeBox.Text = argText
    ui.CodeBox.TextEditable = false
end
local c_check = clonefunction(checkcaller)
local c_rawset = clonefunction(rawset)
local c_getmt = clonefunction(getrawmetatable)
function Modules.Overseer:_hookValue(tbl, key, value, valueType)
    local hookKey = tostring(tbl) .. ":" .. tostring(key)
    if self.State.ValueHooks[hookKey] then
        self.State.ValueHooks[hookKey].enabled = true
        return
    end
    self.State.ValueHooks[hookKey] = {
        table = tbl,
        key = key,
        value = value,
        type = valueType,
        enabled = true,
        originalMt = getrawmetatable and getrawmetatable(tbl)
    }
    pcall(function()
        if setreadonly then setreadonly(tbl, false) elseif make_writeable then make_writeable(tbl) end
        rawset(tbl, key, value)
        if setreadonly then setreadonly(tbl, true) end
    end)
    if getrawmetatable then
        local mt = getrawmetatable(tbl)
        if mt then
            pcall(function()
                if setreadonly then setreadonly(mt, false) elseif make_writeable then make_writeable(mt) end
                local originalNewindex = rawget(mt, "__newindex")
                rawset(mt, "__newindex", function(t, k, v)
                    if k == key then
                        rawset(tbl, key, value)
                    elseif type(originalNewindex) == "function" then
                        originalNewindex(t, k, v)
                    else
                        rawset(t, k, v)
                    end
                end)
                if setreadonly then setreadonly(mt, true) end
            end)
        end
    end
end
function Modules.Overseer:_unhookValue(tbl, key)
    local hookKey = tostring(tbl) .. ":" .. tostring(key)
    self.State.ValueHooks[hookKey] = nil
end
function Modules.Overseer:_hookProperty(instance, property, value)
    if not instance or not instance:IsA("Instance") then return end
    local propKey = tostring(instance) .. ":" .. property
    self.State.PropertyHooks[propKey] = {
        instance = instance,
        property = property,
        value = value,
        enabled = true
    }
    pcall(function()
        instance[property] = value
    end)
    if self.State.HookedConnections[propKey] then
        pcall(function() self.State.HookedConnections[propKey]:Disconnect() end)
    end
    self.State.HookedConnections[propKey] = RunService.Heartbeat:Connect(function()
        if self.State.PropertyHooks[propKey] and self.State.PropertyHooks[propKey].enabled then
            pcall(function()
                if instance and instance.Parent and instance[property] ~= value then
                    instance[property] = value
                elseif not instance or not instance.Parent then
                    self:_unhookProperty(instance, property)
                end
            end)
        end
    end)
end
function Modules.Overseer:_unhookProperty(instance, property)
    local propKey = tostring(instance) .. ":" .. property
    if self.State.HookedConnections[propKey] then
        self.State.HookedConnections[propKey]:Disconnect()
        self.State.HookedConnections[propKey] = nil
    end
    self.State.PropertyHooks[propKey] = nil
end
function Modules.Overseer:_getPatchStatus()
    local active = 0
    local valueHooks = 0
    local propHooks = 0
    for _, _ in pairs(self.State.ActivePatches) do active = active + 1 end
    for _, hook in pairs(self.State.ValueHooks) do if hook.enabled then valueHooks = valueHooks + 1 end end
    for _, hook in pairs(self.State.PropertyHooks) do if hook.enabled then propHooks = propHooks + 1 end end
    return active, valueHooks, propHooks
end
function Modules.Overseer:_filterTableByType(tbl, typeFilter)
    if not tbl or type(tbl) ~= "table" then return {} end
    local results = {}
    for k, v in pairs(tbl) do
        local vType = type(v)
        if typeFilter == "all" or vType == typeFilter then
            table.insert(results, {key = k, value = v, type = vType})
        end
    end
    return results
end
function Modules.Overseer:_searchInTable(tbl, searchTerm)
    local results = {}
    searchTerm = searchTerm:lower()
    for k, v in pairs(tbl) do
        local keyStr = tostring(k):lower()
        local valStr = tostring(v):lower()
        if keyStr:find(searchTerm) or valStr:find(searchTerm) then
            table.insert(results, {key = k, value = v, type = type(v)})
        end
    end
    return results
end
function Modules.Overseer:_getAllValuesOfType(typeFilter, searchDepth)
    searchDepth = searchDepth or 2
    local results = {}
    local scanned = {}
    local maxResults = 100
    local function scanTable(tbl, depth, path)
        if scanned[tbl] or depth <= 0 or #results >= maxResults then return end
        if type(tbl) ~= "table" then return end
        scanned[tbl] = true
        local success, pairs_result = pcall(function()
            local count = 0
            for k, v in pairs(tbl) do
                if count > 50 then break end
                count = count + 1
                if type(v) == typeFilter then
                    table.insert(results, {
                        path = path .. "." .. tostring(k),
                        key = k,
                        value = v,
                        type = typeFilter,
                        table = tbl
                    })
                elseif type(v) == "table" and depth > 0 and not scanned[v] then
                    local tableSafe, _ = pcall(function() return pairs(v) end)
                    if tableSafe then
                        scanTable(v, depth - 1, path .. "." .. tostring(k))
                    end
                end
                if #results >= maxResults then break end
            end
        end)
        if not success then
            return
        end
    end
    pcall(function()
        if _G then scanTable(_G, searchDepth, "_G") end
    end)
    return results
end
function Modules.Overseer:_applyPatch(tbl, key, val, isFunc)
    if not tbl or type(tbl) ~= "table" then return false end
    if not self.State.ActivePatches[tbl] then
        self.State.ActivePatches[tbl] = {}
    end
    self.State.ActivePatches[tbl][key] = {Value = val, Locked = true, IsFunction = isFunc}
    pcall(function()
        if setreadonly then setreadonly(tbl, false) elseif make_writeable then make_writeable(tbl) end
        if isFunc then
            if val == "TRUE" then
                rawset(tbl, key, function() return true end)
            elseif val == "FALSE" then
                rawset(tbl, key, function() return false end)
            else
                rawset(tbl, key, val)
            end
        else
            rawset(tbl, key, val)
        end
        if setreadonly then setreadonly(tbl, true) end
    end)
    if getrawmetatable then
        pcall(function()
            local mt = getrawmetatable(tbl)
            if mt then
                if setreadonly then setreadonly(mt, false) end
                local oldIndex = rawget(mt, "__index")
                rawset(mt, "__index", function(t, k)
                    if k == key then
                        return val
                    elseif type(oldIndex) == "function" then
                        return oldIndex(t, k)
                    elseif type(oldIndex) == "table" then
                        return oldIndex[k]
                    end
                end)
                if setreadonly then setreadonly(mt, true) end
            end
        end)
    end
    return true
end
function Modules.Overseer:_getUpvalues(func, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 5
    if depth > maxDepth then return {} end
    local upvalues = {}
    local success, result = pcall(debug.getupvalues, func)
    if success and result then
        for i, uv in ipairs(result) do
            local uvType = type(uv)
            upvalues[i] = {
                Index = i,
                Value = uv,
                Type = uvType,
                IsFunction = uvType == "function",
                IsTable = uvType == "table",
                ChildUpvalues = uvType == "function" and self:_getUpvalues(uv, depth + 1, maxDepth) or {}
            }
        end
    end
    return upvalues
end
function Modules.Overseer:_patchEnvironment(func, varName, varValue)
    if type(func) ~= "function" then return false end
    return pcall(function()
        local env = getfenv(func)
        if not env then env = {} end
        if setreadonly then setreadonly(env, false) end
        env[varName] = varValue
        if setreadonly then setreadonly(env, true) end
        setfenv(func, env)
    end)
end
function Modules.Overseer:_batchPatch(tbl, patches)
    if type(patches) ~= "table" then return 0 end
    local count = 0
    for key, value in pairs(patches) do
        if self:_applyPatch(tbl, key, value, false) then
            count = count + 1
        end
    end
    return count
end
function Modules.Overseer:_clearPatches(tbl)
    if not tbl or type(tbl) ~= "table" then return false end
    pcall(function()
        if setreadonly then setreadonly(tbl, false) end
        if self.State.ActivePatches[tbl] then
            for key, _ in pairs(self.State.ActivePatches[tbl]) do
                if not key:find("^__") then
                    pcall(function() rawset(tbl, key, nil) end)
                end
            end
        end
        if setreadonly then setreadonly(tbl, true) end
    end)
    self.State.ActivePatches[tbl] = nil
    return true
end
function Modules.Overseer:_scanMetatable(tbl)
    if not getrawmetatable then return nil end
    local mt = c_getmt(tbl)
    if not mt then return nil end
    if setreadonly then setreadonly(mt, false) elseif make_writeable then make_writeable(mt) end
    local metamethods = {}
    for k, v in pairs(mt) do
        if type(v) == "function" then
            metamethods[k] = {
                Value = v,
                Type = "function",
                Upvalues = self:_getUpvalues(v),
                OriginalUpvalues = self:_getUpvalues(v)
            }
        else
            metamethods[k] = {Value = v, Type = type(v)}
        end
    end
    return {
        Metatable = mt,
        Methods = metamethods
    }
end
function Modules.Overseer:_patchMetamethod(tbl, metamethod, newFunc)
    if not getrawmetatable then return false end
    if not tbl or type(tbl) ~= "table" then return false end
    return pcall(function()
        local mt = getrawmetatable(tbl)
        if not mt then
            mt = {}
            setmetatable(tbl, mt)
        end
        if setreadonly then setreadonly(mt, false) end
        rawset(mt, metamethod, newFunc)
        if setreadonly then setreadonly(mt, true) end
        if not self.State.ActivePatches[tbl] then
            self.State.ActivePatches[tbl] = {}
        end
        self.State.ActivePatches[tbl][metamethod] = {
            Value = newFunc,
            Locked = true,
            IsFunction = true,
            IsMetamethod = true
        }
    end)
end
function Modules.Overseer:_createUpvalueRow(uvIndex, uvData, parentFunc, ui)
    local row = Instance.new("Frame", ui.Grid)
    row.Size = UDim2.new(1, -10, 0, 35)
    row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = "  [" .. uvIndex .. "] " .. uvData.Type
    label.TextColor3 = Color3.fromRGB(100, 200, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ClipsDescendants = true
    if uvData.IsTable then
        local diveBtn = Instance.new("TextButton", row)
        diveBtn.Size = UDim2.new(0, 100, 0, 24)
        diveBtn.Position = UDim2.fromScale(0.42, 0.15)
        diveBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 80)
        diveBtn.Text = "DIVE UV >"
        diveBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        diveBtn.Font = Enum.Font.Code
        diveBtn.TextSize = 8
        self:_applyStyle(diveBtn, 2)
        diveBtn.MouseButton1Click:Connect(function()
            table.insert(self.State.PathStack, self.State.CurrentTable)
            self.State.CurrentTable = uvData.Value
            self:PopulateGrid(uvData.Value, "[UV:" .. uvIndex .. "]")
        end)
    elseif uvData.IsFunction then
        local uvBtn = Instance.new("TextButton", row)
        uvBtn.Size = UDim2.new(0, 80, 0, 24)
        uvBtn.Position = UDim2.fromScale(0.42, 0.15)
        uvBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
        uvBtn.Text = "UVALS"
        uvBtn.TextColor3 = Color3.fromRGB(150, 100, 255)
        uvBtn.Font = Enum.Font.Code
        uvBtn.TextSize = 8
        self:_applyStyle(uvBtn, 2)
        uvBtn.MouseButton1Click:Connect(function()
            self:_showUpvaluesUI(uvData.Value, "[UV:" .. uvIndex .. "] Function")
        end)
        local viewBtn = Instance.new("TextButton", row)
        viewBtn.Size = UDim2.new(0, 60, 0, 24)
        viewBtn.Position = UDim2.fromScale(0.55, 0.15)
        viewBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 60)
        viewBtn.Text = "VIEW"
        viewBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
        viewBtn.Font = Enum.Font.Code
        viewBtn.TextSize = 8
        self:_applyStyle(viewBtn, 2)
        viewBtn.MouseButton1Click:Connect(function() self:_showSource(uvData.Value) end)
    else
        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(0, 100, 0, 24)
        box.Position = UDim2.fromScale(0.42, 0.15)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.Text = tostring(uvData.Value)
        box.TextColor3 = Color3.fromRGB(100, 200, 255)
        box.Font = Enum.Font.Code
        box.TextSize = 9
        self:_applyStyle(box, 2)
        box.FocusLost:Connect(function(enter)
            if enter and parentFunc then
                local newVal = tonumber(box.Text) or box.Text
                self:_patchUpvalue(parentFunc, uvIndex, newVal)
                box.Text = tostring(newVal)
            end
        end)
    end
end
function Modules.Overseer:_showUpvaluesUI(func, funcName)
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "UPVALUES: " .. funcName
    ui.CodeBox.Text = "-- Scanning upvalues..."
    task.spawn(function()
        for _, v in ipairs(ui.Grid:GetChildren()) do
            if not v:IsA("UIListLayout") then v:Destroy() end
        end
        ui.CodeFrame.Visible = false
        ui.Grid.Visible = true
        local upvalues = self:_getUpvalues(func)
        if #upvalues == 0 then
            local noUvLabel = Instance.new("TextLabel", ui.Grid)
            noUvLabel.Size = UDim2.new(1, 0, 0, 20)
            noUvLabel.Text = "  -- NO UPVALUES FOUND -- "
            noUvLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
            noUvLabel.BackgroundTransparency = 1
            noUvLabel.Font = Enum.Font.Code
            noUvLabel.TextSize = 9
        else
            for _, uvData in ipairs(upvalues) do
                self:_createUpvalueRow(uvData.Index, uvData, func, ui)
                if uvData.IsFunction and #uvData.ChildUpvalues > 0 then
                    for _, childUv in ipairs(uvData.ChildUpvalues) do
                        local childRow = Instance.new("Frame", ui.Grid)
                        childRow.Size = UDim2.new(1, -30, 0, 35)
                        childRow.BackgroundTransparency = 1
                        childRow.Position = UDim2.new(0, 20, 0, 0)
                        local childLabel = Instance.new("TextLabel", childRow)
                        childLabel.Size = UDim2.new(1, 0, 1, 0)
                        childLabel.Text = "    └─[" .. childUv.Index .. "] " .. childUv.Type
                        childLabel.TextColor3 = Color3.fromRGB(150, 150, 100)
                        childLabel.Font = Enum.Font.Code
                        childLabel.TextSize = 8
                        childLabel.TextXAlignment = Enum.TextXAlignment.Left
                        childLabel.BackgroundTransparency = 1
                    end
                end
            end
        end
    end)
end
function Modules.Overseer:_showSource(target)
    if not target or not self.State.UI then return end
    local decompiler = (decompile or decompile_script)
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.CodeFrame.Name = "ViewMode"
    local targetName = "Closure"
    if type(target) == "table" and target.Name then
        targetName = target.Name
    elseif type(target) == "function" then
        targetName = "Function"
    end
    ui.Title.Text = "DECOMPILING: " .. targetName
    ui.CodeBox.Text = "-- Generating Source, please wait..."
    task.spawn(function()
        local success, src
        if decompiler then
            success, src = pcall(decompiler, target)
        else
            success, src = false, "-- [ERROR] Decompiler not available (decompile/decompile_script required)"
        end
        if self.State.UI and self.State.UI.CodeBox then
            ui.CodeBox.Text = success and src or "-- [FAILURE] Decompilation error: " .. tostring(src)
        end
    end)
end
function Modules.Overseer:_showEditUI(target, targetName)
    if not target or not self.State.UI then return end
    local decompiler = (decompile or decompile_script)
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.CodeFrame.Name = "EditMode"
    ui.Title.Text = "EDIT: " .. targetName
    ui.CodeBox.Text = "-- Loading source..."
    ui.CodeBox.TextEditable = true
    ui.CodeBox.ClearTextOnFocus = false
    task.spawn(function()
        local success, src
        if decompiler then
            success, src = pcall(decompiler, target)
        else
            success, src = false, "-- [ERROR] Decompiler not available (decompile/decompile_script required)\n-- Module source editing not supported"
        end
        if self.State.UI and self.State.UI.CodeBox then
            ui.CodeBox.Text = success and src or "-- [ERROR] Failed to decompile source\n" .. tostring(src)
        end
    end)
end
function Modules.Overseer:_createTableRow(k, v, src)
    local ui = self.State.UI
    local row = Instance.new("Frame", ui.Grid)
    row.Size = UDim2.new(1, -10, 0, 35)
    row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.35, 0, 1, 0)
    label.Text = " " .. tostring(k)
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.Font = Enum.Font.Code
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ClipsDescendants = true
    if type(v) == "table" then
        local diveBtn = Instance.new("TextButton", row)
        diveBtn.Size = UDim2.new(0, 100, 0, 24)
        diveBtn.Position = UDim2.fromScale(0.37, 0.15)
        diveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        diveBtn.Text = "DIVE >"
        diveBtn.TextColor3 = self.Config.ACCENT_COLOR
        diveBtn.Font = Enum.Font.Code
        diveBtn.TextSize = 8
        self:_applyStyle(diveBtn, 2)
        diveBtn.MouseButton1Click:Connect(function()
            table.insert(self.State.PathStack, src)
            self:PopulateGrid(v, tostring(k))
        end)
    elseif type(v) == "function" then
        local spoofBtn = Instance.new("TextButton", row)
        spoofBtn.Size = UDim2.new(0, 40, 0, 24)
        spoofBtn.Position = UDim2.fromScale(0.37, 0.15)
        spoofBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        spoofBtn.Text = "SPOOF"
        spoofBtn.TextColor3 = Color3.new(1, 1, 1)
        spoofBtn.Font = Enum.Font.Code
        spoofBtn.TextSize = 7
        self:_applyStyle(spoofBtn, 2)
        local uvBtn = Instance.new("TextButton", row)
        uvBtn.Size = UDim2.new(0, 40, 0, 24)
        uvBtn.Position = UDim2.fromScale(0.45, 0.15)
        uvBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
        uvBtn.Text = "UVALS"
        uvBtn.TextColor3 = Color3.fromRGB(150, 100, 255)
        uvBtn.Font = Enum.Font.Code
        uvBtn.TextSize = 7
        self:_applyStyle(uvBtn, 2)
        uvBtn.MouseButton1Click:Connect(function()
            self:_showUpvaluesUI(v, tostring(k))
        end)
        local viewBtn = Instance.new("TextButton", row)
        viewBtn.Size = UDim2.new(0, 35, 0, 24)
        viewBtn.Position = UDim2.fromScale(0.54, 0.15)
        viewBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 60)
        viewBtn.Text = "V"
        viewBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
        viewBtn.Font = Enum.Font.Code
        viewBtn.TextSize = 7
        self:_applyStyle(viewBtn, 2)
        viewBtn.MouseButton1Click:Connect(function()
            self.State.EditTarget = src
            self:_showSource(v)
        end)
        local editBtn = Instance.new("TextButton", row)
        editBtn.Size = UDim2.new(0, 35, 0, 24)
        editBtn.Position = UDim2.fromScale(0.615, 0.15)
        editBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 50)
        editBtn.Text = "E"
        editBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
        editBtn.Font = Enum.Font.Code
        editBtn.TextSize = 7
        self:_applyStyle(editBtn, 2)
        editBtn.MouseButton1Click:Connect(function()
            self.State.EditTarget = src
            self:_showEditUI(v, tostring(k) .. "()")
        end)
        local modes = {"NORMAL", "TRUE", "FALSE"}
        local cur = 1
        spoofBtn.MouseButton1Click:Connect(function()
            cur = (cur % 3) + 1
            local mode = modes[cur]
            spoofBtn.Text = "F" .. string.sub(mode, 1, 1)
            spoofBtn.BackgroundColor3 = (mode == "TRUE" and Color3.fromRGB(0, 200, 100)) or (mode == "FALSE" and Color3.fromRGB(200, 50, 50)) or Color3.fromRGB(50, 50, 70)
            if mode == "NORMAL" then
                if self.State.ActivePatches[src] then self.State.ActivePatches[src][k] = nil end
            else
                self:_applyPatch(src, k, mode, true)
            end
        end)
    else
        local valueType = type(v)
        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(0, 90, 0, 24)
        box.Position = UDim2.fromScale(0.37, 0.15)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.Text = tostring(v)
        box.TextColor3 = self.Config.ACCENT_COLOR
        box.Font = Enum.Font.Code
        box.TextSize = 9
        self:_applyStyle(box, 2)
        box.FocusLost:Connect(function(enter)
            if enter then
                self:_applyPatch(src, k, tonumber(box.Text) or box.Text, false)
            end
        end)
        if valueType == "number" then
            local hookBtn = Instance.new("TextButton", row)
            hookBtn.Size = UDim2.new(0, 45, 0, 24)
            hookBtn.Position = UDim2.fromScale(0.545, 0.15)
            hookBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
            hookBtn.Text = "HOOK"
            hookBtn.TextColor3 = self.Config.HOOK_COLOR
            hookBtn.Font = Enum.Font.Code
            hookBtn.TextSize = 7
            self:_applyStyle(hookBtn, 2)
            hookBtn.MouseButton1Click:Connect(function()
                local newVal = tonumber(box.Text) or v
                self:_hookValue(src, k, newVal, valueType)
                hookBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                hookBtn.Text = "HOOKED"
                task.wait(0.5)
                hookBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                hookBtn.Text = "HOOK"
            end)
        end
    end
end
function Modules.Overseer:PopulateGrid(targetTable, name)
    local ui = self.State.UI
    self.State.CurrentTable = targetTable
    self.State.CurrentTypeFilter = nil
    local active, valueHooks, propHooks = self:_getPatchStatus()
    ui.Title.Text = "PATH: " .. (name or "Main") .. " [" .. active .. " patches | " .. valueHooks .. " value hooks]"
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local filterFrame = Instance.new("Frame", ui.Grid)
    filterFrame.Size = UDim2.new(1, -10, 0, 40)
    filterFrame.BackgroundTransparency = 0.8
    filterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self:_applyStyle(filterFrame, 2)
    local types = {"number", "string", "boolean", "function", "table"}
    local typeButtons = {}
    for i, typeStr in ipairs(types) do
        local typeBtn = Instance.new("TextButton", filterFrame)
        typeBtn.Size = UDim2.new(0, 80, 0, 25)
        typeBtn.Position = UDim2.new(0, 10 + (i-1) * 90, 0.5, -12.5)
        typeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        typeBtn.Text = typeStr:upper()
        typeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        typeBtn.Font = Enum.Font.Code
        typeBtn.TextSize = 8
        self:_applyStyle(typeBtn, 2)
        typeBtn.MouseButton1Click:Connect(function()
            self:_applyTypeFilter(targetTable, typeStr, name)
            for _, btn in ipairs(typeButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            typeBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
            typeBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
        end)
        table.insert(typeButtons, typeBtn)
    end
    local clearBtn = Instance.new("TextButton", filterFrame)
    clearBtn.Size = UDim2.new(0, 60, 0, 25)
    clearBtn.Position = UDim2.new(0, 10 + 5 * 90, 0.5, -12.5)
    clearBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    clearBtn.Text = "ALL"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.Code
    clearBtn.TextSize = 8
    self:_applyStyle(clearBtn, 2)
    clearBtn.MouseButton1Click:Connect(function()
        for _, btn in ipairs(typeButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        clearBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 40)
        clearBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
        self.State.CurrentTypeFilter = nil
        self:_populateGridRows(targetTable)
    end)
    clearBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 40)
    clearBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
    self:_populateGridRows(targetTable)
end
function Modules.Overseer:_populateGridRows(targetTable)
    if not self.State.UI or not self.State.UI.Grid then return end
    local ui = self.State.UI
    if type(targetTable) ~= "table" then
        local errorLabel = Instance.new("TextLabel", ui.Grid)
        errorLabel.Size = UDim2.new(1, 0, 0, 30)
        errorLabel.Text = "-- ERROR: Cannot display non-table value --"
        errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        errorLabel.BackgroundTransparency = 1
        errorLabel.Font = Enum.Font.Code
        errorLabel.TextSize = 10
        return
    end
    local children = ui.Grid:GetChildren()
    for i = #children, 1, -1 do
        local v = children[i]
        if v and v.Parent and not v:IsA("UIListLayout") and v.Name ~= "FilterFrame" then
            v:Destroy()
        end
    end
    local rowsToDisplay = targetTable
    local isFiltered = false
    if self.State.CurrentTypeFilter then
        rowsToDisplay = self:_filterTableByType(targetTable, self.State.CurrentTypeFilter)
        isFiltered = true
    end
    if isFiltered then
        for _, item in ipairs(rowsToDisplay) do
            if item and item.key then
                self:_createTableRow(item.key, item.value, targetTable)
            end
        end
    else
        for k, v in pairs(rowsToDisplay) do
            self:_createTableRow(k, v, targetTable)
        end
    end
    local mt = getrawmetatable and getrawmetatable(targetTable)
    if mt then
        if setreadonly then setreadonly(mt, false) elseif make_writeable then make_writeable(mt) end
        if mt.__index and type(mt.__index) == "table" then
            local ghostLabel = Instance.new("TextLabel", ui.Grid)
            ghostLabel.Size = UDim2.new(1, 0, 0, 20)
            ghostLabel.Text = " -- GHOST INDEX (__index) -- "
            ghostLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
            ghostLabel.BackgroundTransparency = 1
            ghostLabel.Font = Enum.Font.Code
            ghostLabel.TextSize = 9
            for k, v in pairs(mt.__index) do
                self:_createTableRow(k, v, mt.__index)
            end
        end
        local metamethods = {}
        for mmKey, mmVal in pairs(mt) do
            if mmKey ~= "__index" and type(mmVal) == "function" then
                table.insert(metamethods, {Key = mmKey, Value = mmVal})
            end
        end
        if #metamethods > 0 then
            local mmLabel = Instance.new("TextLabel", ui.Grid)
            mmLabel.Size = UDim2.new(1, 0, 0, 20)
            mmLabel.Text = " -- METAMETHODS -- "
            mmLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            mmLabel.BackgroundTransparency = 1
            mmLabel.Font = Enum.Font.Code
            mmLabel.TextSize = 9
            for _, mmData in ipairs(metamethods) do
                local mmRow = Instance.new("Frame", ui.Grid)
                mmRow.Size = UDim2.new(1, -10, 0, 35)
                mmRow.BackgroundTransparency = 1
                local mmLabel2 = Instance.new("TextLabel", mmRow)
                mmLabel2.Size = UDim2.new(0.4, 0, 1, 0)
                mmLabel2.Text = " " .. mmData.Key .. "()"
                mmLabel2.TextColor3 = Color3.fromRGB(255, 200, 100)
                mmLabel2.Font = Enum.Font.Code
                mmLabel2.TextSize = 9
                mmLabel2.TextXAlignment = Enum.TextXAlignment.Left
                mmLabel2.BackgroundTransparency = 1
                mmLabel2.ClipsDescendants = true
                local uvBtn = Instance.new("TextButton", mmRow)
                uvBtn.Size = UDim2.new(0, 65, 0, 24)
                uvBtn.Position = UDim2.fromScale(0.42, 0.15)
                uvBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
                uvBtn.Text = "UVALS"
                uvBtn.TextColor3 = Color3.fromRGB(150, 100, 255)
                uvBtn.Font = Enum.Font.Code
                uvBtn.TextSize = 8
                self:_applyStyle(uvBtn, 2)
                uvBtn.MouseButton1Click:Connect(function()
                    self:_showUpvaluesUI(mmData.Value, mmData.Key .. "() metamethod")
                end)
                local viewBtn = Instance.new("TextButton", mmRow)
                viewBtn.Size = UDim2.new(0, 65, 0, 24)
                viewBtn.Position = UDim2.fromScale(0.54, 0.15)
                viewBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 60)
                viewBtn.Text = "VIEW"
                viewBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
                viewBtn.Font = Enum.Font.Code
                viewBtn.TextSize = 8
                self:_applyStyle(viewBtn, 2)
                viewBtn.MouseButton1Click:Connect(function()
                    self:_showSource(mmData.Value)
                end)
            end
        end
    end
end
function Modules.Overseer:_applyTypeFilter(targetTable, typeFilter, name)
    self.State.CurrentTypeFilter = typeFilter
    local ui = self.State.UI
    ui.Title.Text = "FILTERED BY: " .. typeFilter:upper() .. " in " .. (name or "Main")
    self:_populateGridRows(targetTable)
end
function Modules.Overseer:AddModuleToList(mod)
    local n = mod.Name:lower()
    if n:find("chat") or n:find("roblox") then return end
    local ui = self.State.UI
    local container = Instance.new("Frame", ui.Sidebar)
    container.Size = UDim2.new(1, -5, 0, 25)
    container.BackgroundTransparency = 1
    local isScript = mod:IsA("LocalScript") or mod:IsA("Script")
    local displayName = " [" .. mod.ClassName .. "] " .. mod.Name
    local isDisabled = self.State.DisabledModules[mod]
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(0.55, 0, 1, 0)
    b.Text = displayName
    b.BackgroundColor3 = isDisabled and Color3.fromRGB(40, 20, 20) or (isScript and Color3.fromRGB(25, 20, 20) or Color3.fromRGB(20, 20, 25))
    b.TextColor3 = isDisabled and Color3.fromRGB(100, 50, 50) or Color3.new(0.8, 0.8, 0.8)
    b.Font = Enum.Font.Code
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.ClipsDescendants = true
    self:_applyStyle(b, 2)
    local disB = Instance.new("TextButton", container)
    disB.Size = UDim2.new(0.12, 0, 1, 0)
    disB.Position = UDim2.fromScale(0.55, 0)
    disB.BackgroundColor3 = isDisabled and Color3.fromRGB(80, 40, 40) or Color3.fromRGB(40, 80, 40)
    disB.Text = isDisabled and "✗" or "✓"
    disB.TextColor3 = Color3.new(1, 1, 1)
    disB.Font = Enum.Font.Code
    disB.TextSize = 10
    self:_applyStyle(disB, 2)
    local srcB = Instance.new("TextButton", container)
    srcB.Size = UDim2.new(0.12, 0, 1, 0)
    srcB.Position = UDim2.fromScale(0.67, 0)
    srcB.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    srcB.Text = "V"
    srcB.TextColor3 = Color3.fromRGB(100, 200, 255)
    srcB.Font = Enum.Font.Code
    srcB.TextSize = 8
    self:_applyStyle(srcB, 2)
    local editB = Instance.new("TextButton", container)
    editB.Size = UDim2.new(0.16, 0, 1, 0)
    editB.Position = UDim2.fromScale(0.79, 0)
    editB.BackgroundColor3 = Color3.fromRGB(50, 40, 30)
    editB.Text = "E"
    editB.TextColor3 = Color3.fromRGB(255, 180, 100)
    editB.Font = Enum.Font.Code
    editB.TextSize = 8
    self:_applyStyle(editB, 2)
    self.State.SidebarButtons[container] = mod.Name
    disB.MouseButton1Click:Connect(function()
        local isCurrentlyDisabled = self.State.DisabledModules[mod]
        self.State.DisabledModules[mod] = not isCurrentlyDisabled
        if self.State.DisabledModules[mod] then
            disB.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
            disB.Text = "✗"
            b.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            b.TextColor3 = Color3.fromRGB(100, 50, 50)
            self:_cleanupModuleHooks(mod)
        else
            disB.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
            disB.Text = "✓"
            b.BackgroundColor3 = isScript and Color3.fromRGB(25, 20, 20) or Color3.fromRGB(20, 20, 25)
            b.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        end
    end)
    b.MouseButton1Click:Connect(function()
        if self.State.DisabledModules[mod] then
            self:_showErrorInGrid("-- ERROR: Module is disabled --")
            return
        end
        if not mod or not mod.Parent then
            self:_showErrorInGrid("-- ERROR: Module has been destroyed --")
            return
        end
        self.State.SelectedModule = mod
        self.State.PathStack = {}
        if isScript then
            self:_showSource(mod)
        else
            local success, result = pcall(function()
                if not mod or not mod.Parent then
                    error("Module has been destroyed")
                end
                return require(mod)
            end)
            if success and type(result) == "table" then
                self:PopulateGrid(result, mod.Name)
            else
                self:_showSource(mod)
            end
        end
    end)
    srcB.MouseButton1Click:Connect(function()
        if self.State.DisabledModules[mod] then
            self.State.UI.CodeBox.Text = "-- ERROR: Module is disabled --"
            return
        end
        if not mod or not mod.Parent then
            self.State.UI.CodeBox.Text = "-- ERROR: Module has been destroyed --"
            return
        end
        self.State.EditTarget = mod
        self:_showSource(mod)
    end)
    editB.MouseButton1Click:Connect(function()
        if self.State.DisabledModules[mod] then
            self.State.UI.CodeBox.Text = "-- ERROR: Module is disabled --"
            return
        end
        if not mod or not mod.Parent then
            self.State.UI.CodeBox.Text = "-- ERROR: Module has been destroyed --"
            return
        end
        self.State.EditTarget = mod
        self:_showEditUI(mod, displayName)
    end)
end
function Modules.Overseer:_createInstanceRow(inst, parent)
    local ui = self.State.UI
    local row = Instance.new("Frame", ui.Grid)
    row.Size = UDim2.new(1, -10, 0, 35)
    row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Text = " " .. inst.Name .. " (" .. inst.ClassName .. ")"
    label.TextColor3 = Color3.fromRGB(150, 200, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ClipsDescendants = true
    if #inst:GetChildren() > 0 then
        local expandBtn = Instance.new("TextButton", row)
        expandBtn.Size = UDim2.new(0, 50, 0, 24)
        expandBtn.Position = UDim2.fromScale(0.57, 0.15)
        expandBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        expandBtn.Text = "EXPAND"
        expandBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        expandBtn.Font = Enum.Font.Code
        expandBtn.TextSize = 7
        self:_applyStyle(expandBtn, 2)
        expandBtn.MouseButton1Click:Connect(function()
            table.insert(self.State.ExplorerPath, inst)
            self:PopulateExplorer(inst)
        end)
    end
    if inst:IsA("ModuleScript") or inst:IsA("Script") or inst:IsA("LocalScript") then
        local poisonBtn = Instance.new("TextButton", row)
        poisonBtn.Size = UDim2.new(0, 50, 0, 24)
        poisonBtn.Position = UDim2.fromScale(0.72, 0.15)
        poisonBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 60)
        poisonBtn.Text = "POISON"
        poisonBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
        poisonBtn.Font = Enum.Font.Code
        poisonBtn.TextSize = 7
        self:_applyStyle(poisonBtn, 2)
        poisonBtn.MouseButton1Click:Connect(function()
            self.State.SelectedModule = inst
            self.State.PathStack = {}
            self.State.CurrentMode = "modules"
            if inst:IsA("ModuleScript") then
                local success, result = pcall(require, inst)
                if success then
                    self:PopulateGrid(result, inst.Name)
                end
            else
                self:_showSource(inst)
            end
        end)
    elseif inst:IsA("GuiObject") or inst:IsA("Part") or inst:IsA("BasePart") then
        local propBtn = Instance.new("TextButton", row)
        propBtn.Size = UDim2.new(0, 50, 0, 24)
        propBtn.Position = UDim2.fromScale(0.72, 0.15)
        propBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 40)
        propBtn.Text = "PROPS"
        propBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
        propBtn.Font = Enum.Font.Code
        propBtn.TextSize = 7
        self:_applyStyle(propBtn, 2)
        propBtn.MouseButton1Click:Connect(function()
            self:_showInstanceProperties(inst)
        end)
    end
end
function Modules.Overseer:PopulateExplorer(instance)
    local ui = self.State.UI
    self.State.ExplorerInstance = instance
    local pathStr = ""
    for i, inst in ipairs(self.State.ExplorerPath) do
        pathStr = pathStr .. inst.Name .. "/"
    end
    pathStr = pathStr .. instance.Name
    ui.Title.Text = "EXPLORER: " .. pathStr
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local children = instance:GetChildren()
    if #children == 0 then
        local emptyLabel = Instance.new("TextLabel", ui.Grid)
        emptyLabel.Size = UDim2.new(1, 0, 0, 20)
        emptyLabel.Text = "  -- NO CHILDREN -- "
        emptyLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Code
        emptyLabel.TextSize = 9
    else
        for _, child in ipairs(children) do
            self:_createInstanceRow(child, instance)
        end
    end
end
function Modules.Overseer:_showGlobalTypeSearch()
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "GLOBAL TYPE SEARCH"
    ui.CodeBox.TextEditable = false
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local searchLabel = Instance.new("TextLabel", ui.Grid)
    searchLabel.Size = UDim2.new(1, -10, 0, 30)
    searchLabel.Text = "Select a type to search globally..."
    searchLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    searchLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    searchLabel.Font = Enum.Font.Code
    searchLabel.TextSize = 10
    self:_applyStyle(searchLabel, 2)
    local types = {"number", "string", "boolean", "function", "table"}
    for i, typeStr in ipairs(types) do
        local typeBtn = Instance.new("TextButton", ui.Grid)
        typeBtn.Size = UDim2.new(0.9, 0, 0, 35)
        typeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        typeBtn.Text = "SEARCH: " .. typeStr:upper() .. " (Click to start)"
        typeBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
        typeBtn.Font = Enum.Font.Code
        typeBtn.TextSize = 9
        self:_applyStyle(typeBtn, 2)
        typeBtn.MouseButton1Click:Connect(function()
            self:_displayGlobalSearchResults(typeStr)
        end)
    end
end
function Modules.Overseer:_displayGlobalSearchResults(typeFilter)
    local ui = self.State.UI
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    ui.CodeBox.Text = "Searching for all " .. typeFilter .. " values...\nThis may take a moment...\n\n"
    local results = self:_getAllValuesOfType(typeFilter, 3)
    ui.CodeBox.Text = "Found " .. #results .. " " .. typeFilter .. " values:\n\n"
    local headerLabel = Instance.new("TextLabel", ui.Grid)
    headerLabel.Size = UDim2.new(1, -10, 0, 25)
    headerLabel.Text = "FOUND " .. #results .. " RESULTS - Click to dive into"
    headerLabel.TextColor3 = self.Config.HOOK_COLOR
    headerLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
    headerLabel.Font = Enum.Font.Code
    headerLabel.TextSize = 10
    self:_applyStyle(headerLabel, 2)
    for i, result in ipairs(results) do
        if i > 50 then
            local moreLabel = Instance.new("TextLabel", ui.Grid)
            moreLabel.Size = UDim2.new(1, -10, 0, 20)
            moreLabel.Text = "... and " .. (#results - 50) .. " more"
            moreLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            moreLabel.BackgroundTransparency = 1
            moreLabel.Font = Enum.Font.Code
            moreLabel.TextSize = 9
            break
        end
        local resultRow = Instance.new("Frame", ui.Grid)
        resultRow.Size = UDim2.new(1, -10, 0, 35)
        resultRow.BackgroundTransparency = 1
        local resultLabel = Instance.new("TextLabel", resultRow)
        resultLabel.Size = UDim2.new(0.7, 0, 1, 0)
        resultLabel.Text = " " .. result.path
        resultLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        resultLabel.Font = Enum.Font.Code
        resultLabel.TextSize = 8
        resultLabel.TextXAlignment = Enum.TextXAlignment.Left
        resultLabel.BackgroundTransparency = 1
        resultLabel.ClipsDescendants = true
        local diveBtn = Instance.new("TextButton", resultRow)
        diveBtn.Size = UDim2.new(0, 55, 0, 24)
        diveBtn.Position = UDim2.fromScale(0.72, 0.15)
        diveBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        diveBtn.Text = "DIVE"
        diveBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        diveBtn.Font = Enum.Font.Code
        diveBtn.TextSize = 8
        self:_applyStyle(diveBtn, 2)
        diveBtn.MouseButton1Click:Connect(function()
            if type(result.value) == "table" then
                table.insert(self.State.PathStack, self.State.CurrentTable)
                self.State.CurrentTable = result.value
                self:PopulateGrid(result.value, result.path)
            end
        end)
    end
end
function Modules.Overseer:_showInstanceProperties(inst)
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "PROPERTIES: " .. inst.Name
    ui.CodeBox.TextEditable = false
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local properties = {}
    pcall(function()
        properties = inst:GetProperties()
    end)
    if #properties == 0 then
        ui.CodeBox.Text = "-- No properties accessible"
        return
    end
    for _, prop in ipairs(properties) do
        local success, val = pcall(function() return inst[prop] end)
        if success then
            local propRow = Instance.new("Frame", ui.Grid)
            propRow.Size = UDim2.new(1, -10, 0, 35)
            propRow.BackgroundTransparency = 1
            local label = Instance.new("TextLabel", propRow)
            label.Size = UDim2.new(0.4, 0, 1, 0)
            label.Text = " " .. prop
            label.TextColor3 = Color3.fromRGB(150, 200, 255)
            label.Font = Enum.Font.Code
            label.TextSize = 8
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.ClipsDescendants = true
            if type(val) == "number" then
                local box = Instance.new("TextBox", propRow)
                box.Size = UDim2.new(0, 80, 0, 24)
                box.Position = UDim2.fromScale(0.42, 0.15)
                box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
                box.Text = tostring(val)
                box.TextColor3 = Color3.fromRGB(100, 200, 255)
                box.Font = Enum.Font.Code
                box.TextSize = 8
                self:_applyStyle(box, 2)
                box.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(function()
                            inst[prop] = tonumber(box.Text) or val
                        end)
                    end
                end)
                local hookBtn = Instance.new("TextButton", propRow)
                hookBtn.Size = UDim2.new(0, 45, 0, 24)
                hookBtn.Position = UDim2.fromScale(0.545, 0.15)
                hookBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                hookBtn.Text = "HOOK"
                hookBtn.TextColor3 = self.Config.HOOK_COLOR
                hookBtn.Font = Enum.Font.Code
                hookBtn.TextSize = 7
                self:_applyStyle(hookBtn, 2)
                hookBtn.MouseButton1Click:Connect(function()
                    local newVal = tonumber(box.Text) or val
                    self:_hookProperty(inst, prop, newVal)
                    hookBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                    hookBtn.Text = "HOOKED"
                    task.wait(0.5)
                    hookBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                    hookBtn.Text = "HOOK"
                end)
            else
                local label2 = Instance.new("TextLabel", propRow)
                label2.Size = UDim2.new(0.5, 0, 1, 0)
                label2.Position = UDim2.fromScale(0.42, 0)
                label2.Text = tostring(val)
                label2.TextColor3 = Color3.fromRGB(150, 150, 150)
                label2.Font = Enum.Font.Code
                label2.TextSize = 8
                label2.TextXAlignment = Enum.TextXAlignment.Left
                label2.BackgroundTransparency = 1
                label2.ClipsDescendants = true
            end
        end
    end
end
function Modules.Overseer:_generatePoisonedVersion(originalCode)
    local poisonedCode = "local ORIGINAL_SCRIPT = [[\n" .. originalCode .. "\n]]\n\n"
    poisonedCode = poisonedCode .. "-- Poison execution environment\n"
    poisonedCode = poisonedCode .. "local function applyPoison()\n"
    poisonedCode = poisonedCode .. "    local success, result = pcall(function()\n"
    poisonedCode = poisonedCode .. "        local func, err = loadstring(ORIGINAL_SCRIPT, 'PoisonedScript')\n"
    poisonedCode = poisonedCode .. "        if func then\n"
    poisonedCode = poisonedCode .. "            return func()\n"
    poisonedCode = poisonedCode .. "        else\n"
    poisonedCode = poisonedCode .. "            error('Compilation failed: ' .. tostring(err))\n"
    poisonedCode = poisonedCode .. "        end\n"
    poisonedCode = poisonedCode .. "    end)\n"
    poisonedCode = poisonedCode .. "    return success, result\n"
    poisonedCode = poisonedCode .. "end\n\n"
    poisonedCode = poisonedCode .. "local success, result = applyPoison()\n"
    poisonedCode = poisonedCode .. "if not success then warn('Poisoned execution error: ' .. tostring(result)) end\n"
    return poisonedCode
end
function Modules.Overseer:_generateAdvancedPoisonVersion(originalCode, options)
    options = options or {}
    local poisonedCode = "-- ============================================================================\n"
    poisonedCode = poisonedCode .. "-- POISONED SCRIPT - OVERSEER INJECTION\n"
    poisonedCode = poisonedCode .. "-- Patches: " .. (options.includePatches and "ACTIVE" or "NONE") .. " | Hooks: " .. (options.includeHooks and "ACTIVE" or "NONE") .. "\n"
    poisonedCode = poisonedCode .. "-- ============================================================================\n\n"
    poisonedCode = poisonedCode .. "local PATCHES_ENABLED = " .. (options.patchesEnabled and "true" or "false") .. "\n"
    poisonedCode = poisonedCode .. "local HOOKS_ENABLED = " .. (options.includeHooks and "true" or "false") .. "\n\n"
    poisonedCode = poisonedCode .. "local ORIGINAL_SCRIPT = [[\n"
    poisonedCode = poisonedCode .. originalCode .. "\n]]\n\n"
    if options.includePatches then
        poisonedCode = poisonedCode .. "local ACTIVE_PATCHES = {\n"
        for tbl, keys in pairs(self.State.ActivePatches) do
            for key, data in pairs(keys) do
                local valStr = tostring(data.Value)
                if type(data.Value) == "string" then
                    valStr = "\"" .. data.Value:gsub("\"", "\\\"") .. "\""
                elseif type(data.Value) == "boolean" then
                    valStr = data.Value and "true" or "false"
                end
                poisonedCode = poisonedCode .. "    [" .. tostring(key) .. "] = {value = " .. valStr .. ", locked = " .. (data.Locked and "true" or "false") .. "},\n"
            end
        end
        poisonedCode = poisonedCode .. "}\n\n"
    else
        poisonedCode = poisonedCode .. "local ACTIVE_PATCHES = {}\n\n"
    end
    if options.includeHooks then
        poisonedCode = poisonedCode .. "local HOOKED_VALUES = {\n"
        for hookKey, hook in pairs(self.State.ValueHooks) do
            if hook.enabled then
                poisonedCode = poisonedCode .. "    [" .. hookKey .. "] = {value = " .. tostring(hook.value) .. ", enabled = true},\n"
            end
        end
        poisonedCode = poisonedCode .. "}\n\n"
    else
        poisonedCode = poisonedCode .. "local HOOKED_VALUES = {}\n\n"
    end
    poisonedCode = poisonedCode .. "-- Apply patches and hooks before execution\n"
    poisonedCode = poisonedCode .. "local function applyPoisonLogic()\n"
    poisonedCode = poisonedCode .. "    if PATCHES_ENABLED then\n"
    poisonedCode = poisonedCode .. "        for key, patchData in pairs(ACTIVE_PATCHES) do\n"
    poisonedCode = poisonedCode .. "            if patchData.locked then\n"
    poisonedCode = poisonedCode .. "                _G[key] = patchData.value\n"
    poisonedCode = poisonedCode .. "            end\n"
    poisonedCode = poisonedCode .. "        end\n"
    poisonedCode = poisonedCode .. "    end\n"
    poisonedCode = poisonedCode .. "    if HOOKS_ENABLED then\n"
    poisonedCode = poisonedCode .. "        for hookKey, hookData in pairs(HOOKED_VALUES) do\n"
    poisonedCode = poisonedCode .. "            if hookData.enabled then\n"
    poisonedCode = poisonedCode .. "                _G[hookKey] = hookData.value\n"
    poisonedCode = poisonedCode .. "            end\n"
    poisonedCode = poisonedCode .. "        end\n"
    poisonedCode = poisonedCode .. "    end\n"
    poisonedCode = poisonedCode .. "end\n\n"
    poisonedCode = poisonedCode .. "-- Execute with poison applied\n"
    poisonedCode = poisonedCode .. "local success, result = pcall(function()\n"
    poisonedCode = poisonedCode .. "    applyPoisonLogic()\n"
    poisonedCode = poisonedCode .. "    local func, err = loadstring(ORIGINAL_SCRIPT, 'PoisonedExecution')\n"
    poisonedCode = poisonedCode .. "    if func then\n"
    poisonedCode = poisonedCode .. "        return func()\n"
    poisonedCode = poisonedCode .. "    else\n"
    poisonedCode = poisonedCode .. "        error('Compilation: ' .. tostring(err))\n"
    poisonedCode = poisonedCode .. "    end\n"
    poisonedCode = poisonedCode .. "end)\n\n"
    poisonedCode = poisonedCode .. "if success then\n"
    poisonedCode = poisonedCode .. "    print('[POISON] Script executed with ' .. (PATCHES_ENABLED and 'patches' or 'no patches') .. ' & ' .. (HOOKS_ENABLED and 'hooks' or 'no hooks'))\n"
    poisonedCode = poisonedCode .. "else\n"
    poisonedCode = poisonedCode .. "    warn('[POISON] Execution failed: ' .. tostring(result))\n"
    poisonedCode = poisonedCode .. "end\n"
    return poisonedCode
end
function Modules.Overseer:_showPoisonOptions()
    local ui = self.State.UI
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    ui.CodeFrame.Visible = false
    ui.Grid.Visible = true
    ui.Title.Text = "POISON OPTIONS"
    local titleLabel = Instance.new("TextLabel", ui.Grid)
    titleLabel.Size = UDim2.new(1, -10, 0, 30)
    titleLabel.Text = "Generate Poisoned Version - Select Options:"
    titleLabel.TextColor3 = Color3.fromRGB(200, 100, 255)
    titleLabel.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 10
    self:_applyStyle(titleLabel, 2)
    local options = {
        {name = "Simple Wrapper", desc = "Wrap in basic execution", value = "simple"},
        {name = "Include Patches", desc = "Include active patches", value = "patches"},
        {name = "Include Hooks", desc = "Include value hooks", value = "hooks"},
        {name = "Advanced (All)", desc = "Patches + Hooks + Comments", value = "advanced"}
    }
    for _, option in ipairs(options) do
        local optRow = Instance.new("Frame", ui.Grid)
        optRow.Size = UDim2.new(1, -10, 0, 35)
        optRow.BackgroundTransparency = 1
        local optLabel = Instance.new("TextLabel", optRow)
        optLabel.Size = UDim2.new(0.6, 0, 1, 0)
        optLabel.Text = " " .. option.name .. "\n " .. option.desc
        optLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        optLabel.Font = Enum.Font.Code
        optLabel.TextSize = 9
        optLabel.TextXAlignment = Enum.TextXAlignment.Left
        optLabel.TextYAlignment = Enum.TextYAlignment.Center
        optLabel.BackgroundTransparency = 1
        local execBtn = Instance.new("TextButton", optRow)
        execBtn.Size = UDim2.new(0, 70, 0, 24)
        execBtn.Position = UDim2.fromScale(0.62, 0.25)
        execBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
        execBtn.Text = "GENERATE"
        execBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
        execBtn.Font = Enum.Font.Code
        execBtn.TextSize = 8
        self:_applyStyle(execBtn, 2)
        execBtn.MouseButton1Click:Connect(function()
            local codeBox = ui.CodeBox
            local originalCode = codeBox.Text
            if (option.value == "patches" or option.value == "advanced") and not self:_validatePatches() then
                self:_showErrorInGrid("-- ERROR: Invalid patches detected --")
                return
            end
            if (option.value == "hooks" or option.value == "advanced") and not self:_validateHooks() then
                self:_showErrorInGrid("-- ERROR: Invalid hooks detected --")
                return
            end
            local poisonedCode = ""
            if option.value == "simple" then
                poisonedCode = self:_generatePoisonedVersion(originalCode)
            else
                local opts = {
                    patchesEnabled = true,
                    includePatches = (option.value == "patches" or option.value == "advanced"),
                    includeHooks = (option.value == "hooks" or option.value == "advanced")
                }
                poisonedCode = self:_generateAdvancedPoisonVersion(originalCode, opts)
            end
            self:_showPoisonedCode(poisonedCode, option.name)
        end)
    end
end
function Modules.Overseer:_showPoisonedCode(poisonedCode, optionName)
    local ui = self.State.UI
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "POISONED VERSION (" .. optionName .. ")"
    ui.CodeBox.Text = poisonedCode
    ui.CodeBox.TextEditable = false
    local children = ui.CodeFrame:GetChildren()
    for _, btn in ipairs(children) do
        if btn:IsA("TextButton") then
            if btn.Text == "COPY" then
                btn.Visible = true
            elseif btn.Text == "EDIT" then
                btn.Visible = true
            elseif btn.Text == "APPLY" then
                btn.Visible = true
                btn.Text = "EXECUTE"
                btn.BackgroundColor3 = Color3.fromRGB(150, 80, 20)
                btn.TextColor3 = Color3.new(1, 1, 1)
            end
        end
    end
end
function Modules.Overseer:_showPatchManager()
    local ui = self.State.UI
    self.State.ViewingCode = true
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "PATCH MANAGER"
    ui.CodeBox.TextEditable = false
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local active, valueHooks, propHooks = self:_getPatchStatus()
    local headerLabel = Instance.new("TextLabel", ui.Grid)
    headerLabel.Size = UDim2.new(1, 0, 0, 30)
    headerLabel.Text = "ACTIVE PATCHES: " .. active .. " | VALUE HOOKS: " .. valueHooks .. " | PROPERTY HOOKS: " .. propHooks
    headerLabel.TextColor3 = self.Config.HOOK_COLOR
    headerLabel.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
    headerLabel.Font = Enum.Font.Code
    headerLabel.TextSize = 10
    self:_applyStyle(headerLabel, 2)
    if valueHooks > 0 then
        local vhLabel = Instance.new("TextLabel", ui.Grid)
        vhLabel.Size = UDim2.new(1, 0, 0, 20)
        vhLabel.Text = " -- VALUE HOOKS --"
        vhLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        vhLabel.BackgroundTransparency = 1
        vhLabel.Font = Enum.Font.Code
        vhLabel.TextSize = 9
        for hookKey, hook in pairs(self.State.ValueHooks) do
            if hook.enabled then
                local hookRow = Instance.new("Frame", ui.Grid)
                hookRow.Size = UDim2.new(1, -10, 0, 35)
                hookRow.BackgroundTransparency = 1
                local hookLabel = Instance.new("TextLabel", hookRow)
                hookLabel.Size = UDim2.new(0.7, 0, 1, 0)
                hookLabel.Text = " " .. hookKey .. " = " .. tostring(hook.value)
                hookLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                hookLabel.Font = Enum.Font.Code
                hookLabel.TextSize = 8
                hookLabel.TextXAlignment = Enum.TextXAlignment.Left
                hookLabel.BackgroundTransparency = 1
                hookLabel.ClipsDescendants = true
                local toggleBtn = Instance.new("TextButton", hookRow)
                toggleBtn.Size = UDim2.new(0, 50, 0, 24)
                toggleBtn.Position = UDim2.fromScale(0.72, 0.15)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                toggleBtn.Text = "DISABLE"
                toggleBtn.TextColor3 = Color3.new(1, 1, 1)
                toggleBtn.Font = Enum.Font.Code
                toggleBtn.TextSize = 7
                self:_applyStyle(toggleBtn, 2)
                toggleBtn.MouseButton1Click:Connect(function()
                    hook.enabled = false
                    hookRow:Destroy()
                end)
            end
        end
    end
    if propHooks > 0 then
        local phLabel = Instance.new("TextLabel", ui.Grid)
        phLabel.Size = UDim2.new(1, 0, 0, 20)
        phLabel.Text = " -- PROPERTY HOOKS --"
        phLabel.TextColor3 = Color3.fromRGB(255, 180, 100)
        phLabel.BackgroundTransparency = 1
        phLabel.Font = Enum.Font.Code
        phLabel.TextSize = 9
        for propKey, hook in pairs(self.State.PropertyHooks) do
            if hook.enabled then
                local hookRow = Instance.new("Frame", ui.Grid)
                hookRow.Size = UDim2.new(1, -10, 0, 35)
                hookRow.BackgroundTransparency = 1
                local hookLabel = Instance.new("TextLabel", hookRow)
                hookLabel.Size = UDim2.new(0.7, 0, 1, 0)
                hookLabel.Text = " " .. hook.property .. " = " .. tostring(hook.value)
                hookLabel.TextColor3 = Color3.fromRGB(255, 180, 100)
                hookLabel.Font = Enum.Font.Code
                hookLabel.TextSize = 8
                hookLabel.TextXAlignment = Enum.TextXAlignment.Left
                hookLabel.BackgroundTransparency = 1
                hookLabel.ClipsDescendants = true
                local toggleBtn = Instance.new("TextButton", hookRow)
                toggleBtn.Size = UDim2.new(0, 50, 0, 24)
                toggleBtn.Position = UDim2.fromScale(0.72, 0.15)
                toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
                toggleBtn.Text = "DISABLE"
                toggleBtn.TextColor3 = Color3.new(1, 1, 1)
                toggleBtn.Font = Enum.Font.Code
                toggleBtn.TextSize = 7
                self:_applyStyle(toggleBtn, 2)
                toggleBtn.MouseButton1Click:Connect(function()
                    self:_unhookProperty(hook.instance, hook.property)
                    hookRow:Destroy()
                end)
            end
        end
    end
    if active > 0 then
        local patchLabel = Instance.new("TextLabel", ui.Grid)
        patchLabel.Size = UDim2.new(1, 0, 0, 20)
        patchLabel.Text = " -- TABLE PATCHES --"
        patchLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
        patchLabel.BackgroundTransparency = 1
        patchLabel.Font = Enum.Font.Code
        patchLabel.TextSize = 9
        for tbl, keys in pairs(self.State.ActivePatches) do
            for key, data in pairs(keys) do
                local patchRow = Instance.new("Frame", ui.Grid)
                patchRow.Size = UDim2.new(1, -10, 0, 35)
                patchRow.BackgroundTransparency = 1
                local patchLabel2 = Instance.new("TextLabel", patchRow)
                patchLabel2.Size = UDim2.new(0.7, 0, 1, 0)
                patchLabel2.Text = " [" .. key .. "] = " .. tostring(data.Value)
                patchLabel2.TextColor3 = Color3.fromRGB(150, 100, 255)
                patchLabel2.Font = Enum.Font.Code
                patchLabel2.TextSize = 8
                patchLabel2.TextXAlignment = Enum.TextXAlignment.Left
                patchLabel2.BackgroundTransparency = 1
                patchLabel2.ClipsDescendants = true
                local clearBtn = Instance.new("TextButton", patchRow)
                clearBtn.Size = UDim2.new(0, 50, 0, 24)
                clearBtn.Position = UDim2.fromScale(0.72, 0.15)
                clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                clearBtn.Text = "CLEAR"
                clearBtn.TextColor3 = Color3.new(1, 1, 1)
                clearBtn.Font = Enum.Font.Code
                clearBtn.TextSize = 7
                self:_applyStyle(clearBtn, 2)
                clearBtn.MouseButton1Click:Connect(function()
                    if self.State.ActivePatches[tbl] then
                        self.State.ActivePatches[tbl][key] = nil
                    end
                    patchRow:Destroy()
                end)
            end
        end
    end
end
function Modules.Overseer:_initFunctionTracer()
    if self.State.TracerActive then return end
    self.State.TracerActive = true
    self.State.CallTrace = {}
    self.State.CallFrequency = {}
    local function traceCall(func, name, args, returns)
        local call = {
            Function = name or "Unknown",
            Args = args,
            Returns = returns,
            Time = tick()
        }
        table.insert(self.State.CallTrace, call)
        if #self.State.CallTrace > self.State.MaxTraceSize then
            table.remove(self.State.CallTrace, 1)
        end
        if not self.State.CallFrequency[name] then
            self.State.CallFrequency[name] = 0
        end
        self.State.CallFrequency[name] = self.State.CallFrequency[name] + 1
    end
    self.State.TracerCallback = traceCall
end
function Modules.Overseer:_showFunctionTracer()
    local ui = self.State.UI
    ui.Grid.Visible = true
    ui.CodeFrame.Visible = false
    ui.Title.Text = "FUNCTION CALL TRACER - " .. #self.State.CallTrace .. " CALLS"
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local tracerStatusLabel = Instance.new("TextLabel", ui.Grid)
    tracerStatusLabel.Size = UDim2.new(1, -10, 0, 30)
    tracerStatusLabel.BackgroundColor3 = self.State.TracerActive and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(40, 20, 20)
    tracerStatusLabel.Text = "TRACER STATUS: " .. (self.State.TracerActive and "ACTIVE" or "INACTIVE")
    tracerStatusLabel.TextColor3 = self.State.TracerActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    tracerStatusLabel.Font = Enum.Font.Code
    tracerStatusLabel.TextSize = 10
    self:_applyStyle(tracerStatusLabel, 2)
    if not self.State.TracerActive then
        local startBtn = Instance.new("TextButton", ui.Grid)
        startBtn.Size = UDim2.new(0.9, 0, 0, 35)
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
        startBtn.Text = "START TRACING FUNCTIONS"
        startBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        startBtn.Font = Enum.Font.Code
        startBtn.TextSize = 10
        self:_applyStyle(startBtn, 2)
        startBtn.MouseButton1Click:Connect(function()
            self:_initFunctionTracer()
            self:_showFunctionTracer()
        end)
    else
        local clearBtn = Instance.new("TextButton", ui.Grid)
        clearBtn.Size = UDim2.new(0.9, 0, 0, 35)
        clearBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        clearBtn.Text = "CLEAR TRACE LOG"
        clearBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        clearBtn.Font = Enum.Font.Code
        clearBtn.TextSize = 10
        self:_applyStyle(clearBtn, 2)
        clearBtn.MouseButton1Click:Connect(function()
            self.State.CallTrace = {}
            self.State.CallFrequency = {}
            self:_showFunctionTracer()
        end)
    end
    if #self.State.CallTrace > 0 then
        local freqLabel = Instance.new("TextLabel", ui.Grid)
        freqLabel.Size = UDim2.new(1, 0, 0, 20)
        freqLabel.Text = " CALL FREQUENCY (Top 10)"
        freqLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        freqLabel.BackgroundTransparency = 1
        freqLabel.Font = Enum.Font.Code
        freqLabel.TextSize = 9
        local sorted = {}
        for func, count in pairs(self.State.CallFrequency) do
            table.insert(sorted, {name = func, count = count})
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)
        for i = 1, math.min(10, #sorted) do
            local data = sorted[i]
            local row, label = self:_createRow(ui.Grid, "", UDim2.new(0.7, 0, 1, 0))
            label.Text = "[" .. i .. "] " .. data.name .. " (" .. data.count .. " calls)"
            label.TextColor3 = Color3.fromRGB(100, 150, 255)
        end
    end
    if #self.State.CallTrace > 0 then
        local callLabel = Instance.new("TextLabel", ui.Grid)
        callLabel.Size = UDim2.new(1, 0, 0, 20)
        callLabel.Text = " RECENT CALLS"
        callLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        callLabel.BackgroundTransparency = 1
        callLabel.Font = Enum.Font.Code
        callLabel.TextSize = 9
        for i = math.min(20, #self.State.CallTrace), 1, -1 do
            local call = self.State.CallTrace[i]
            if call then
                local row, label = self:_createRow(ui.Grid, "", UDim2.new(0.8, 0, 1, 0))
                local argCount = call.Args and #call.Args or 0
                local status = call.Returns and call.Returns[1] and "OK" or "ERR"
                label.Text = call.Function .. " [" .. argCount .. " args] - " .. status
                label.TextColor3 = (call.Returns and call.Returns[1]) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            end
        end
    end
end
function Modules.Overseer:_initEventSpy()
    if self.State.EventSpyActive then return end
    self.State.EventSpyActive = true
    self.State.EventLog = {}
    local function hookEvent(bindable, eventName)
        if not bindable or bindable:GetAttribute("_OverseerEventHooked") then return end
        pcall(function()
            bindable.Event:Connect(function(...)
                local args = {...}
                table.insert(Modules.Overseer.State.EventLog, {
                    Event = eventName,
                    Parent = bindable.Parent and bindable.Parent.Name or "Unknown",
                    Args = args,
                    Time = tick(),
                    Type = bindable.ClassName
                })
                if #Modules.Overseer.State.EventLog > Modules.Overseer.State.MaxEventLogSize then
                    table.remove(Modules.Overseer.State.EventLog, 1)
                end
            end)
            bindable:SetAttribute("_OverseerEventHooked", true)
        end)
    end
    local function scanEvents(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("BindableEvent") or child:IsA("BindableFunction") then
                hookEvent(child, child.Name)
            end
        end
    end
    scanEvents(ReplicatedStorage)
    scanEvents(game)
    table.insert(self.State.HookedConnections, game.DescendantAdded:Connect(function(child)
        if self.State.EventSpyActive and (child:IsA("BindableEvent") or child:IsA("BindableFunction")) then
            task.wait(0.05)
            hookEvent(child, child.Name)
        end
    end))
end
function Modules.Overseer:_showEventSpy()
    local ui = self.State.UI
    ui.Grid.Visible = true
    ui.CodeFrame.Visible = false
    ui.Title.Text = "EVENT/SIGNAL SPY - " .. #self.State.EventLog .. " FIRES"
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local spyStatusLabel = Instance.new("TextLabel", ui.Grid)
    spyStatusLabel.Size = UDim2.new(1, -10, 0, 30)
    spyStatusLabel.BackgroundColor3 = self.State.EventSpyActive and Color3.fromRGB(20, 40, 20) or Color3.fromRGB(40, 20, 20)
    spyStatusLabel.Text = "EVENT SPY STATUS: " .. (self.State.EventSpyActive and "ACTIVE" or "INACTIVE")
    spyStatusLabel.TextColor3 = self.State.EventSpyActive and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    spyStatusLabel.Font = Enum.Font.Code
    spyStatusLabel.TextSize = 10
    self:_applyStyle(spyStatusLabel, 2)
    if not self.State.EventSpyActive then
        local startBtn = Instance.new("TextButton", ui.Grid)
        startBtn.Size = UDim2.new(0.9, 0, 0, 35)
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
        startBtn.Text = "START SPYING ON EVENTS"
        startBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        startBtn.Font = Enum.Font.Code
        startBtn.TextSize = 10
        self:_applyStyle(startBtn, 2)
        startBtn.MouseButton1Click:Connect(function()
            self:_initEventSpy()
            self:_showEventSpy()
        end)
    end
    if #self.State.EventLog > 0 then
        local logLabel = Instance.new("TextLabel", ui.Grid)
        logLabel.Size = UDim2.new(1, 0, 0, 20)
        logLabel.Text = " SIGNAL FIRE HISTORY"
        logLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
        logLabel.BackgroundTransparency = 1
        logLabel.Font = Enum.Font.Code
        logLabel.TextSize = 9
        for i = math.min(30, #self.State.EventLog), 1, -1 do
            local event = self.State.EventLog[i]
            if event then
                local row, label = self:_createRow(ui.Grid, "", UDim2.new(0.8, 0, 1, 0))
                local parentName = event.Parent or "Unknown"
                local argCount = #event.Args
                local eventText = "[" .. event.Type .. "] " .. event.Event .. " (" .. argCount .. " args)"
                label.Text = eventText
                label.TextColor3 = (event.Type == "BindableEvent" and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(150, 150, 255))
            end
        end
    end
end
function Modules.Overseer:_inspectScriptEnvironment(script)
    if not script or not script:IsA("LuaSourceContainer") then return false end
    self.State.ViewingCode = true
    local ui = self.State.UI
    ui.Grid.Visible = false
    ui.CodeFrame.Visible = true
    ui.Title.Text = "SCRIPT STATE: " .. script.Name
    local envInfo = "SCRIPT: " .. script:GetFullName() .. "\n"
    envInfo = envInfo .. "CLASS: " .. script.ClassName .. "\n"
    envInfo = envInfo .. "ENABLED: " .. tostring(script.Enabled) .. "\n\n"
    envInfo = envInfo .. "--- SOURCE CODE ---\n"
    envInfo = envInfo .. script.Source .. "\n"
    ui.CodeBox.Text = envInfo
    ui.CodeBox.TextEditable = false
end
function Modules.Overseer:_showScriptStateInspector()
    local ui = self.State.UI
    self.State.ViewingCode = false
    ui.Grid.Visible = true
    ui.CodeFrame.Visible = false
    ui.Title.Text = "SCRIPT STATE INSPECTOR"
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local infoLabel = Instance.new("TextLabel", ui.Grid)
    infoLabel.Size = UDim2.new(1, -10, 0, 40)
    infoLabel.Text = "Browse scripts in workspace and ReplicatedStorage"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    infoLabel.Font = Enum.Font.Code
    infoLabel.TextSize = 10
    infoLabel.TextWrapped = true
    self:_applyStyle(infoLabel, 2)
    local scanLabel = Instance.new("TextLabel", ui.Grid)
    scanLabel.Size = UDim2.new(1, -10, 0, 20)
    scanLabel.Text = " AVAILABLE SCRIPTS"
    scanLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
    scanLabel.BackgroundTransparency = 1
    scanLabel.Font = Enum.Font.Code
    scanLabel.TextSize = 9
    local scripts = {}
    local function scanScripts(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("LocalScript") or child:IsA("Script") or child:IsA("ModuleScript") then
                table.insert(scripts, child)
            end
        end
    end
    scanScripts(Workspace)
    scanScripts(ReplicatedStorage)
    for i, script in ipairs(scripts) do
        if i > 30 then break end
        local row = Instance.new("Frame", ui.Grid)
        row.Size = UDim2.new(1, -10, 0, 35)
        row.BackgroundTransparency = 1
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Text = " " .. script.Name .. " [" .. script.ClassName .. "]"
        label.TextColor3 = Color3.fromRGB(150, 200, 255)
        label.Font = Enum.Font.Code
        label.TextSize = 9
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1
        label.ClipsDescendants = true
        local inspectBtn = Instance.new("TextButton", row)
        inspectBtn.Size = UDim2.new(0, 70, 0, 24)
        inspectBtn.Position = UDim2.fromScale(0.62, 0.15)
        inspectBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        inspectBtn.Text = "INSPECT"
        inspectBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
        inspectBtn.Font = Enum.Font.Code
        inspectBtn.TextSize = 8
        self:_applyStyle(inspectBtn, 2)
        inspectBtn.MouseButton1Click:Connect(function()
            self:_inspectScriptEnvironment(script)
        end)
    end
end
function Modules.Overseer:CreateUI()
    if self.State.UI then self.State.UI.Main.Visible = true return end
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "Overseer_Merged_V1"
    screenGui.ResetOnSpawn = false
    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.fromOffset(850, 570)
    main.Position = UDim2.new(0.5, -425, 0.5, -285)
    main.BackgroundColor3 = self.Config.BG_COLOR
    main.BackgroundTransparency = 0.4
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    self:_applyStyle(main, 6)
    local toolbar = Instance.new("Frame", main)
    toolbar.Size = UDim2.new(1, 0, 0, 30)
    toolbar.Position = UDim2.fromOffset(0, 0)
    toolbar.BackgroundColor3 = self.Config.SECONDARY_COLOR
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 35)
    header.Position = UDim2.fromOffset(0, 30)
    header.BackgroundColor3 = self.Config.HEADER_COLOR
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -280, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.Text = "Overseer - Unified Module & Instance Explorer"
    title.TextColor3 = self.Config.ACCENT_COLOR
    title.Font = Enum.Font.Code
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    local modeBtn = Instance.new("TextButton", header)
    modeBtn.Size = UDim2.new(0, 70, 0, 24)
    modeBtn.Position = UDim2.new(1, -210, 0.5, -11)
    modeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
    modeBtn.Text = "EXPLORER"
    modeBtn.TextColor3 = Color3.new(1, 1, 1)
    modeBtn.Font = Enum.Font.Code
    modeBtn.TextSize = 9
    self:_applyStyle(modeBtn, 2)
    local patchBtn = Instance.new("TextButton", header)
    patchBtn.Size = UDim2.new(0, 70, 0, 24)
    patchBtn.Position = UDim2.new(1, -285, 0.5, -11)
    patchBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 40)
    patchBtn.Text = "PATCHES"
    patchBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
    patchBtn.Font = Enum.Font.Code
    patchBtn.TextSize = 9
    self:_applyStyle(patchBtn, 2)
    local searchBtn = Instance.new("TextButton", header)
    searchBtn.Size = UDim2.new(0, 70, 0, 24)
    searchBtn.Position = UDim2.new(1, -360, 0.5, -11)
    searchBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
    searchBtn.Text = "SEARCH"
    searchBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    searchBtn.Font = Enum.Font.Code
    searchBtn.TextSize = 9
    self:_applyStyle(searchBtn, 2)
    local spyBtn = Instance.new("TextButton", header)
    spyBtn.Size = UDim2.new(0, 70, 0, 24)
    spyBtn.Position = UDim2.new(1, -435, 0.5, -11)
    spyBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 100)
    spyBtn.Text = "SPY"
    spyBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
    spyBtn.Font = Enum.Font.Code
    spyBtn.TextSize = 9
    self:_applyStyle(spyBtn, 2)
    local backBtn = Instance.new("TextButton", header)
    backBtn.Size = UDim2.new(0, 60, 0, 24)
    backBtn.Position = UDim2.new(1, -510, 0.5, -11)
    backBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    backBtn.Text = "< BACK"
    backBtn.TextColor3 = Color3.new(1, 1, 1)
    backBtn.Font = Enum.Font.Code
    backBtn.TextSize = 10
    self:_applyStyle(backBtn, 2)
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.Code
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, 0, 1, -65)
    content.Position = UDim2.fromOffset(0, 65)
    content.BackgroundTransparency = 1
    local searchInput = Instance.new("TextBox", content)
    searchInput.Size = UDim2.new(0, 230, 0, 30)
    searchInput.Position = UDim2.fromOffset(10, 10)
    searchInput.BackgroundColor3 = self.Config.SECONDARY_COLOR
    searchInput.PlaceholderText = "SEARCH..."
    searchInput.Text = ""
    searchInput.TextColor3 = self.Config.ACCENT_COLOR
    searchInput.Font = Enum.Font.Code
    searchInput.TextSize = 10
    self:_applyStyle(searchInput, 4)
    local sidebar = Instance.new("ScrollingFrame", content)
    sidebar.Size = UDim2.new(0, 230, 1, -60)
    sidebar.Position = UDim2.fromOffset(10, 50)
    sidebar.BackgroundTransparency = 1
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollBarThickness = 2
    local sidebarList = Instance.new("UIListLayout", sidebar)
    sidebarList.Padding = UDim.new(0, 4)
    local grid = Instance.new("ScrollingFrame", content)
    grid.Size = UDim2.new(1, -270, 1, -20)
    grid.Position = UDim2.fromOffset(260, 10)
    grid.BackgroundColor3 = self.Config.SECONDARY_COLOR
    grid.BackgroundTransparency = 0.3
    grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
    grid.ScrollBarThickness = 2
    self:_applyStyle(grid, 4)
    local gridList = Instance.new("UIListLayout", grid)
    gridList.SortOrder = Enum.SortOrder.LayoutOrder
    local codeFrame = Instance.new("Frame", content)
    codeFrame.Size = grid.Size
    codeFrame.Position = grid.Position
    codeFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    codeFrame.Visible = false
    self:_applyStyle(codeFrame, 4)
    local codeScroller = Instance.new("ScrollingFrame", codeFrame)
    codeScroller.Size = UDim2.new(1, -20, 1, -60)
    codeScroller.Position = UDim2.fromOffset(10, 10)
    codeScroller.BackgroundTransparency = 1
    codeScroller.ScrollBarThickness = 2
    codeScroller.AutomaticCanvasSize = Enum.AutomaticSize.XY
    local codeBox = Instance.new("TextBox", codeScroller)
    codeBox.Size = UDim2.new(1, 0, 1, 0)
    codeBox.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
    codeBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 10
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.TextEditable = false
    codeBox.MultiLine = true
    codeBox.AutomaticSize = Enum.AutomaticSize.XY
    self:_applyStyle(codeBox, 4)
    local copyBtn = Instance.new("TextButton", codeFrame)
    copyBtn.Size = UDim2.new(0, 90, 0, 30)
    copyBtn.Position = UDim2.new(1, -280, 1, -40)
    copyBtn.BackgroundColor3 = self.Config.ACCENT_COLOR
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = Color3.new(0, 0, 0)
    copyBtn.Font = Enum.Font.Code
    copyBtn.TextSize = 10
    self:_applyStyle(copyBtn, 4)
    local editBtn = Instance.new("TextButton", codeFrame)
    editBtn.Size = UDim2.new(0, 90, 0, 30)
    editBtn.Position = UDim2.new(1, -185, 1, -40)
    editBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 50)
    editBtn.Text = "EDIT"
    editBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
    editBtn.Font = Enum.Font.Code
    editBtn.TextSize = 10
    self:_applyStyle(editBtn, 4)
    local applyBtn = Instance.new("TextButton", codeFrame)
    applyBtn.Size = UDim2.new(0, 90, 0, 30)
    applyBtn.Position = UDim2.new(1, -280, 1, -40)
    applyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    applyBtn.Text = "APPLY"
    applyBtn.TextColor3 = Color3.new(1, 1, 1)
    applyBtn.Font = Enum.Font.Code
    applyBtn.TextSize = 10
    applyBtn.Visible = false
    self:_applyStyle(applyBtn, 4)
    local discardBtn = Instance.new("TextButton", codeFrame)
    discardBtn.Size = UDim2.new(0, 90, 0, 30)
    discardBtn.Position = UDim2.new(1, -185, 1, -40)
    discardBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    discardBtn.Text = "DISCARD"
    discardBtn.TextColor3 = Color3.new(1, 1, 1)
    discardBtn.Font = Enum.Font.Code
    discardBtn.TextSize = 10
    discardBtn.Visible = false
    self:_applyStyle(discardBtn, 4)
    local closeCode = Instance.new("TextButton", codeFrame)
    closeCode.Size = UDim2.new(0, 90, 0, 30)
    closeCode.Position = UDim2.new(0, 10, 1, -40)
    closeCode.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    closeCode.Text = "EXIT"
    closeCode.TextColor3 = Color3.new(1, 1, 1)
    closeCode.Font = Enum.Font.Code
    closeCode.TextSize = 10
    self:_applyStyle(closeCode, 4)
    local poisonBtn = Instance.new("TextButton", codeFrame)
    poisonBtn.Size = UDim2.new(0, 90, 0, 30)
    poisonBtn.Position = UDim2.new(1, -90, 1, -40)
    poisonBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 100)
    poisonBtn.Text = "POISON"
    poisonBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
    poisonBtn.Font = Enum.Font.Code
    poisonBtn.TextSize = 10
    self:_applyStyle(poisonBtn, 4)
    self.State.UI = {
        ScreenGui = screenGui,
        Main = main,
        Title = title,
        Grid = grid,
        Sidebar = sidebar,
        CodeFrame = codeFrame,
        CodeBox = codeBox,
        Search = searchInput,
        EditMode = false,
        EditTarget = nil,
        OriginalCode = ""
    }
    local scannedModules = {}
    local function RescanModules()
        for btn, _ in pairs(self.State.SidebarButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        self.State.SidebarButtons = {}
        scannedModules = {}
        for _, v in ipairs(grid:GetChildren()) do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
        grid.Visible = true
        codeFrame.Visible = false
        title.Text = "Overseer - Unified Module & Instance Explorer"
        self.State.CurrentTable = nil
        self.State.PathStack = {}
        self.State.SelectedModule = nil
        sidebar.CanvasPosition = Vector2.new(0, 0)
        grid.CanvasPosition = Vector2.new(0, 0)
        local function scan(root)
            for _, m in ipairs(root:GetDescendants()) do
                if (m:IsA("ModuleScript") or m:IsA("LocalScript") or m:IsA("Script")) and not scannedModules[m] then
                    scannedModules[m] = true
                    self:AddModuleToList(m)
                end
            end
        end
        if ReplicatedFirst then scan(ReplicatedFirst) end
        if ReplicatedStorage then scan(ReplicatedStorage) end
        if Players.LocalPlayer then scan(Players.LocalPlayer) end
        if Workspace then scan(Workspace) end
        if getloadedmodules then
            for _, m in ipairs(getloadedmodules()) do
                if not scannedModules[m] then
                    scannedModules[m] = true
                    self:AddModuleToList(m)
                end
            end
        end
    end
    local rescanBtn = Instance.new("TextButton", toolbar)
    rescanBtn.Size = UDim2.new(0, 80, 0, 22)
    rescanBtn.Position = UDim2.new(0, 10, 0.5, -11)
    rescanBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 40)
    rescanBtn.Text = "RESCAN"
    rescanBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
    rescanBtn.Font = Enum.Font.Code
    rescanBtn.TextSize = 10
    self:_applyStyle(rescanBtn, 3)
    modeBtn.MouseButton1Click:Connect(function()
        if self.State.CurrentMode == "modules" then
            self.State.CurrentMode = "explorer"
            self.State.ExplorerPath = {}
            modeBtn.Text = "MODULES"
            modeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
            self:PopulateExplorer(game)
        else
            self.State.CurrentMode = "modules"
            modeBtn.Text = "EXPLORER"
            modeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
            RescanModules()
        end
    end)
    patchBtn.MouseButton1Click:Connect(function()
        self:_showPatchManager()
    end)
    searchBtn.MouseButton1Click:Connect(function()
        self:_showGlobalTypeSearch()
    end)
    spyBtn.MouseButton1Click:Connect(function()
        self:_showRemoteSpy()
    end)
    local tracerBtn = Instance.new("TextButton", header)
    tracerBtn.Size = UDim2.new(0, 70, 0, 24)
    tracerBtn.Position = UDim2.new(1, -510, 0.5, -11)
    tracerBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 60)
    tracerBtn.Text = "TRACE"
    tracerBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
    tracerBtn.Font = Enum.Font.Code
    tracerBtn.TextSize = 9
    self:_applyStyle(tracerBtn, 2)
    local eventBtn = Instance.new("TextButton", header)
    eventBtn.Size = UDim2.new(0, 70, 0, 24)
    eventBtn.Position = UDim2.new(1, -585, 0.5, -11)
    eventBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 60)
    eventBtn.Text = "EVENT"
    eventBtn.TextColor3 = Color3.fromRGB(200, 255, 100)
    eventBtn.Font = Enum.Font.Code
    eventBtn.TextSize = 9
    self:_applyStyle(eventBtn, 2)
    local stateBtn = Instance.new("TextButton", header)
    stateBtn.Size = UDim2.new(0, 70, 0, 24)
    stateBtn.Position = UDim2.new(1, -660, 0.5, -11)
    stateBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
    stateBtn.Text = "STATE"
    stateBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
    stateBtn.Font = Enum.Font.Code
    stateBtn.TextSize = 9
    self:_applyStyle(stateBtn, 2)
    tracerBtn.MouseButton1Click:Connect(function()
        self:_showFunctionTracer()
    end)
    eventBtn.MouseButton1Click:Connect(function()
        self:_initEventSpy()
        self:_showEventSpy()
    end)
    stateBtn.MouseButton1Click:Connect(function()
        self:_showScriptStateInspector()
    end)
    backBtn.Position = UDim2.new(1, -735, 0.5, -11)
    rescanBtn.MouseButton1Click:Connect(RescanModules)
    backBtn.MouseButton1Click:Connect(function()
        if self.State.CurrentMode == "modules" then
            if #self.State.PathStack > 0 then
                local prev = table.remove(self.State.PathStack)
                if type(prev) == "table" then
                    self:PopulateGrid(prev, "Parent")
                else
                    self:_showErrorInGrid("-- ERROR: Parent reference is invalid --")
                end
            end
        else
            if #self.State.ExplorerPath > 0 then
                local prev = table.remove(self.State.ExplorerPath)
                if prev and prev:IsA("Instance") and prev.Parent then
                    self:PopulateExplorer(prev)
                else
                    self:_showErrorInGrid("-- ERROR: Instance was destroyed --")
                end
            end
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)
    closeCode.MouseButton1Click:Connect(function()
        self.State.ViewingCode = false
        self.State.UI.EditMode = false
        codeFrame.Visible = false
        grid.Visible = true
        codeBox.Text = ""
        codeBox.TextEditable = false
        codeBox.ClearTextOnFocus = false
        copyBtn.Visible = true
        editBtn.Visible = true
        applyBtn.Visible = false
        discardBtn.Visible = false
        poisonBtn.Visible = false
        self.State.EditTarget = nil
        self.State.UI.OriginalCode = ""
        title.Text = "PATH: " .. (self.State.SelectedModule and self.State.SelectedModule.Name or "Main")
    end)
    poisonBtn.MouseButton1Click:Connect(function()
        self:_showPoisonOptions()
    end)
    copyBtn.MouseButton1Click:Connect(function()
        self:_setClipboard(codeBox.Text)
        copyBtn.Text = "COPIED!"
        task.wait(1)
        copyBtn.Text = "COPY"
    end)
    editBtn.MouseButton1Click:Connect(function()
        self.State.UI.EditMode = true
        self.State.UI.OriginalCode = codeBox.Text
        codeBox.TextEditable = true
        copyBtn.Visible = false
        editBtn.Visible = false
        applyBtn.Visible = true
        discardBtn.Visible = true
        title.Text = title.Text .. " [EDITING]"
    end)
    applyBtn.MouseButton1Click:Connect(function()
        local editedCode = codeBox.Text
        local success, result = pcall(function()
            local compiled = loadstring(editedCode, "EditedModule")
            if compiled then
                compiled()
                return true
            end
            return false
        end)
        if success and result then
            applyBtn.Text = "APPLIED!"
            applyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(1.5)
            applyBtn.Text = "APPLY"
            applyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            if self.State.EditTarget then
                self.State.ActivePatches[self.State.EditTarget] = self.State.ActivePatches[self.State.EditTarget] or {}
                self.State.ActivePatches[self.State.EditTarget]["_EditedCode"] = {
                    Value = editedCode,
                    Locked = false,
                    IsFunction = false,
                    IsEdit = true
                }
            end
        else
            applyBtn.Text = "ERROR!"
            applyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            codeBox.Text = "-- [ERROR] " .. tostring(result) .. "\n\n" .. editedCode
            task.wait(2)
            applyBtn.Text = "APPLY"
            applyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end
    end)
    discardBtn.MouseButton1Click:Connect(function()
        self.State.UI.EditMode = false
        codeBox.Text = self.State.UI.OriginalCode
        codeBox.TextEditable = false
        copyBtn.Visible = true
        editBtn.Visible = true
        applyBtn.Visible = false
        discardBtn.Visible = false
        title.Text = title.Text:gsub(" %[EDITING%]", "")
    end)
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = searchInput.Text:lower()
        local visibleCount = 0
        for container, name in pairs(self.State.SidebarButtons) do
            local isVisible = filter == "" or name:lower():find(filter, 1, true) ~= nil
            container.Visible = isVisible
            if isVisible then visibleCount = visibleCount + 1 end
        end
        if filter ~= "" and visibleCount == 0 then
            local noResultsMsg = sidebar:FindFirstChild("NoResults")
            if not noResultsMsg then
                noResultsMsg = Instance.new("TextLabel", sidebar)
                noResultsMsg.Name = "NoResults"
                noResultsMsg.Size = UDim2.new(1, 0, 0, 30)
                noResultsMsg.Text = "No matching modules found"
                noResultsMsg.TextColor3 = Color3.fromRGB(150, 100, 100)
                noResultsMsg.BackgroundTransparency = 1
                noResultsMsg.Font = Enum.Font.Code
                noResultsMsg.TextSize = 9
            end
            noResultsMsg.Visible = true
        else
            local noResultsMsg = sidebar:FindFirstChild("NoResults")
            if noResultsMsg then noResultsMsg.Visible = false end
        end
    end)
    local dragging, dragStart, startPos
    local inputBegan; inputBegan = header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    local inputChanged; inputChanged = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    local inputEnded; inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(self.State.HookedConnections, inputBegan)
    table.insert(self.State.HookedConnections, inputChanged)
    table.insert(self.State.HookedConnections, inputEnded)
    table.insert(self.State.HookedConnections, screenGui.Destroying:Connect(function()
        for _, conn in ipairs(self.State.HookedConnections) do
            if conn and typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            end
        end
        self.State.HookedConnections = {}
        self.State.UI = nil
    end))
    task.spawn(function()
        local paths = {ReplicatedStorage, Players.LocalPlayer, Workspace}
        for _, p in ipairs(paths) do
            if p then
                for _, m in ipairs(p:GetDescendants()) do
                    if m and (m:IsA("ModuleScript") or m:IsA("LocalScript") or m:IsA("Script")) and m.Parent then
                        self:AddModuleToList(m)
                    end
                end
                task.wait()
            end
        end
    end)
end
function Modules.Overseer:Initialize()
    local module = self
    RunService.Heartbeat:Connect(function()
        for tbl, keys in pairs(module.State.ActivePatches) do
            for key, data in pairs(keys) do
                if data.Locked then
                    pcall(function()
                        if setreadonly then setreadonly(tbl, false) elseif make_writeable then make_writeable(tbl) end
                        if data.IsFunction then
                            if data.Value == "TRUE" then
                                rawset(tbl, key, function() return true end)
                            elseif data.Value == "FALSE" then
                                rawset(tbl, key, function() return false end)
                            end
                        else
                            rawset(tbl, key, data.Value)
                        end
                        if setreadonly then setreadonly(tbl, true) end
                    end)
                end
            end
        end
    end)
    RegisterCommand({
        Name = "os",
        Aliases = {"opensource"},
        Description = "Opens the ultimate Overseer module, Use at your own risk."
    }, function()
        module:CreateUI()
    end)
end
Modules.ApexCounter = {
    State = {
        IsEnabled = false,
        LagShieldActive = false,
        GhostMode = false,
        Blender = false,
        AcidProtection = false,
        Connections = {},
        BlacklistedRemotes = {
            "AcidSpit",
            "PLACE_LANDMINE",
            "AbilityPlayer",
            "PlayerAttack",
            "ReplicateAcidAbility",
            "AcidDamageVisual",
        },
        AcidSpamCounter = 0,
        LastAcidTime = 0,
        AcidThreshold = 10,
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        Workspace = game:GetService("Workspace"),
        Debris = game:GetService("Debris")
    }
}
function Modules.ApexCounter:ToggleLagShield(state)
    self.State.LagShieldActive = state
    if state then
        local targetFolder = self.Services.Workspace:FindFirstChild("Interaction") 
            and self.Services.Workspace.Interaction:FindFirstChild("PlayerPlaced")
        if targetFolder then
            for _, child in ipairs(targetFolder:GetChildren()) do
                if child.Name:find("Landmine") or child.Name:find("Acid") then
                    child:Destroy()
                end
            end
            self.State.Connections.LagMonitor = targetFolder.ChildAdded:Connect(function(child)
                task.defer(function()
                    if child and child.Parent then
                        if child.Name:find("Landmine") or child.Name:find("Acid") then
                            child:Destroy()
                            local currentTime = tick()
                            if currentTime - self.State.LastAcidTime < 1 then
                                self.State.AcidSpamCounter = self.State.AcidSpamCounter + 1
                            else
                                self.State.AcidSpamCounter = 0
                            end
                            self.State.LastAcidTime = currentTime
                            if self.State.AcidSpamCounter > self.State.AcidThreshold then
                                DoNotif("⚠ HEAVY ACID SPAM DETECTED - Deflecting", 1)
                            end
                        end
                    end
                end)
            end)
        end
        DoNotif("🛡 Lag Deflector: ACTIVE (Blocking Exploit Spam)", 2)
    else
        if self.State.Connections.LagMonitor then
            self.State.Connections.LagMonitor:Disconnect()
        end
        self.State.AcidSpamCounter = 0
        DoNotif("Lag Deflector: DISABLED", 2)
    end
end
function Modules.ApexCounter:ToggleGhost(state)
    self.State.GhostMode = state
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    if state and char then
        pcall(function()
            char:SetAttribute("Team", "Ghost")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local mt = getrawmetatable(game)
                local oldIndex = mt.__index
                setreadonly(mt, false)
                mt.__index = newcclosure(function(t, k)
                    if t == hum and k == "Health" and not checkcaller() then
                        return 0
                    end
                    return oldIndex(t, k)
                end)
                setreadonly(mt, true)
            end
        end)
        DoNotif("👻 Ghost Mode: ACTIVE (Invisible to Kill Aura)", 2)
    else
        DoNotif("Ghost Mode: DISABLED", 2)
    end
end
function Modules.ApexCounter:RunBlender()
    if self.State.BlenderActive then return end
    self.State.BlenderActive = true
    local lp = self.Services.Players.LocalPlayer
    local meleeRemote = self.Services.ReplicatedStorage:FindFirstChild("Remotes") 
        and self.Services.ReplicatedStorage.Remotes:FindFirstChild("Melee") 
        and self.Services.ReplicatedStorage.Remotes.Melee:FindFirstChild("Damage")
    local zombieRemote = self.Services.ReplicatedStorage:FindFirstChild("Remotes")
        and self.Services.ReplicatedStorage.Remotes:FindFirstChild("ZombieRelated") 
        and self.Services.ReplicatedStorage.Remotes.ZombieRelated:FindFirstChild("PlayerAttack")
    local isProcessing = false
    local lastCall = 0
    local callDelay = 0.05
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if (self == meleeRemote or self == zombieRemote) and method == "InvokeServer" and not checkcaller() then
            local currentTime = tick()
            if not isProcessing and (currentTime - lastCall) > callDelay then
                isProcessing = true
                lastCall = currentTime
                for i = 1, 6 do
                    task.spawn(function()
                        pcall(function()
                            oldNamecall(self, unpack(args))
                        end)
                    end)
                end
                isProcessing = false
                return nil
            end
        end
        return oldNamecall(self, ...)
    end))
    DoNotif("⚔ Kill Blender: ACTIVE (6x Multiplier)", 2)
end
function Modules.ApexCounter:NullifySkidRemotes()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() then
            local remoteName = self.Name
            for _, blocked in ipairs(Modules.ApexCounter.State.BlacklistedRemotes) do
                if remoteName == blocked and (method == "FireServer" or method == "InvokeServer") then
                    return nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
    DoNotif("🔒 Remote Shield: ACTIVE (Blocking Exploit Remotes)", 2)
end
function Modules.ApexCounter:ToggleAcidProtection(state)
    self.State.AcidProtection = state
    if state then
        self.State.Connections.AcidReplication = self.Services.ReplicatedStorage
            :FindFirstChild("Remotes", true) and self.Services.ReplicatedStorage.Remotes
            :FindFirstChild("Replication", true) and self.Services.ReplicatedStorage.Remotes.Replication
            :FindFirstChild("ReplicateAcidAbility")
        if self.State.Connections.AcidReplication then
            local oldConnect = self.State.Connections.AcidReplication.OnClientEvent.Connect
            self.State.Connections.AcidReplication.OnClientEvent.Connect = function(...)
                return {Disconnect = function() end}
            end
        end
        task.spawn(function()
            while self.State.AcidProtection do
                for _, v in ipairs(self.Services.Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name:find("Acid") then
                        v:Destroy()
                    end
                end
                task.wait(0.5)
            end
        end)
        local acidDamageModule = self.Services.ReplicatedStorage:FindFirstChild("Modules", true)
            and self.Services.ReplicatedStorage.Modules:FindFirstChild("MostRandomStuff", true)
            and self.Services.ReplicatedStorage.Modules.MostRandomStuff:FindFirstChild("AcidDamage")
        if acidDamageModule then
            local mt = getrawmetatable(game)
            local oldRequire = mt.__index
            setreadonly(mt, false)
            local originalAcidDamage = require(acidDamageModule)
            mt.__index = newcclosure(function(t, k)
                if k == acidDamageModule then
                    return function() end
                end
                return oldRequire(t, k)
            end)
            setreadonly(mt, true)
        end
        DoNotif("☣ Acid Protection: MAXIMUM (Full Immunity)", 2)
    else
        if self.State.Connections.AcidReplicationHook then
            self.State.Connections.AcidReplicationHook:Disconnect()
        end
        DoNotif("Acid Protection: DISABLED", 2)
    end
end
function Modules.ApexCounter:CleanVisualEffects()
    if not self.State.IsEnabled then return end
    task.spawn(function()
        while self.State.IsEnabled do
            for _, player in ipairs(self.Services.Players:GetPlayers()) do
                if player.Character then
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("ParticleEmitter") and part.Name == "ParticleEmitter" then
                            part:Destroy()
                        elseif part:IsA("Sound") and part.Name == "Burn" then
                            part:Destroy()
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end
function Modules.ApexCounter:EnableNetworkProtection()
    local eventCounter = {}
    local threshold = 50
    local oldFireServer
    oldFireServer = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            local currentTime = tick()
            if not eventCounter[remoteName] then
                eventCounter[remoteName] = {count = 0, lastReset = currentTime}
            end
            local data = eventCounter[remoteName]
            if currentTime - data.lastReset >= 1 then
                data.count = 0
                data.lastReset = currentTime
            end
            data.count = data.count + 1
            if data.count > threshold then
                if not checkcaller() then
                    return nil
                end
            end
        end
        return oldFireServer(self, ...)
    end))
    DoNotif("🌐 Network Protection: ENABLED", 2)
end
function Modules.ApexCounter:Initialize()
    local module = self
    RegisterCommand({
        Name = "zcounter",
        Aliases = {"zc"},
        Description = "Toggles the counter-exploit suite (APEX Edition)."
    }, function(args)
        module.State.IsEnabled = not module.State.IsEnabled
        if module.State.IsEnabled then
            DoNotif("⚡ APEX SUITE: INITIALIZING...", 1.5)
            task.wait(0.5)
            module:ToggleLagShield(true)
            module:ToggleGhost(true)
            module:ToggleAcidProtection(true)
            module:RunBlender()
            module:NullifySkidRemotes()
            module:CleanVisualEffects()
            module:EnableNetworkProtection()
            task.wait(0.5)
            DoNotif("✅ APEX SUITE: FULLY OPERATIONAL", 3)
            DoNotif("🛡 All Protections: ACTIVE", 2)
        else
            module:ToggleLagShield(false)
            module:ToggleGhost(false)
            module:ToggleAcidProtection(false)
            for _, conn in pairs(module.State.Connections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            module.State.Connections = {}
            module.State.BlenderActive = false
            DoNotif("🔴 APEX SUITE: DEACTIVATED", 3)
        end
    end)
    RegisterCommand({
        Name = "acidblock",
        Aliases = {"ab"},
        Description = "Toggle acid-specific protection only."
    }, function(args)
        local newState = not module.State.AcidProtection
        module:ToggleAcidProtection(newState)
    end)
end
    RegisterCommand({
        Name = "minigunsniper",
        Aliases = {"spawnsniper"},
        Description = "For Zombie Game Series."
    }, function()
        local shop = game:GetService("ReplicatedStorage").Remotes.Shop.EquipWeapon
        shop:InvokeServer("Sniper")
        find.Sniper(true)
        task.wait(0.2)
        local gun = localplayer.Character:FindFirstChild("Sniper") or localplayer.Backpack:FindFirstChild("Sniper")
        if gun then
            local scr = getsenv(gun:FindFirstChildOfClass("LocalScript"))
            if scr and scr.FireGun then
                self.Services.RunService.Heartbeat:Connect(function()
                    if localplayer:GetMouse().Button1Down then
                        pcall(scr.FireGun, lp:GetMouse().X, lp:GetMouse().Y)
                    end
                end)
                DoNotif("Rapid Fire: ENABLED", 2)
            end
        end
    end)
    RegisterCommand({
        Name = "spwnShotgun",
        Aliases = {"spawnsgun"},
        Description = "For Zombie Game Series."
    }, function()
        local shop = game:GetService("ReplicatedStorage").Remotes.Shop.EquipWeapon
        shop:InvokeServer("Shotgun")
        find.Shotgun(true)
        task.wait(0.2)
        local gun = localplayer.Character:FindFirstChild("Shotgun") or localplayer.Backpack:FindFirstChild("Shotgun")
        if gun then
            local scr = getsenv(gun:FindFirstChildOfClass("LocalScript"))
            if scr and scr.FireGun then
                self.Services.RunService.Heartbeat:Connect(function()
                    if localplayer:GetMouse().Button1Down then
                        pcall(scr.FireGun, lp:GetMouse().X, lp:GetMouse().Y)
                    end
                end)
                DoNotif("Rapid Fire: ENABLED", 2)
            end
        end
    end)
Modules.ModuleEditor = {
    State = {
        IsEnabled = false,
        UI = nil,
        CurrentTable = nil,
        TableStack = {},
        Connections = {},
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = nil,
        PreMaximizePosition = nil
    },
    Theme = {
        Background = Color3.fromRGB(0, 0, 0),
        WindowGray = Color3.fromRGB(192, 192, 192),
        DarkGray = Color3.fromRGB(128, 128, 128),
        LightGray = Color3.fromRGB(223, 223, 223),
        White = Color3.fromRGB(255, 255, 255),
        Blue = Color3.fromRGB(0, 0, 128),
        Accent = Color3.fromRGB(0, 255, 0),
        Text = Color3.fromRGB(0, 0, 0),
        Font = Enum.Font.Code
    },
    Services = {
        Workspace = game:GetService("Workspace"),
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        CoreGui = game:GetService("CoreGui"),
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService")
    }
}
function Modules.ModuleEditor:Minimize()
    if self.State.IsMinimized then return end
    self.State.IsMinimized = true
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 1, 50),
        Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 30)
    })
    tween:Play()
end
function Modules.ModuleEditor:Restore()
    if not self.State.IsMinimized then return end
    self.State.IsMinimized = false
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    local targetSize = self.State.PreMaximizeSize or UDim2.new(0, 600, 0, 450)
    local targetPos = self.State.PreMaximizePosition or UDim2.new(0.5, -300, 0.5, -225)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
        Position = targetPos,
        Size = targetSize
    })
    tween:Play()
end
function Modules.ModuleEditor:Maximize()
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    if self.State.IsMaximized then
        self.State.IsMaximized = false
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
            Position = self.State.PreMaximizePosition,
            Size = self.State.PreMaximizeSize
        })
        tween:Play()
    else
        self.State.PreMaximizeSize = mainFrame.Size
        self.State.PreMaximizePosition = mainFrame.Position
        self.State.IsMaximized = true
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
    end
end
function Modules.ModuleEditor:DestroyUI()
    if self.State.UI then
        self.State.UI:Destroy()
        self.State.UI = nil
    end
    self.State.TableStack = {}
    self.State.CurrentTable = nil
    self.State.IsMinimized = false
    self.State.IsMaximized = false
end
function Modules.ModuleEditor:ShowTable(tbl, tableScroll, backBtn)
    tableScroll:ClearAllChildren()
    self.State.CurrentTable = tbl
    backBtn.Visible = #self.State.TableStack > 0
    local count = 0
    for key, value in pairs(tbl) do
        if typeof(value) == "function" then
            continue
        end
        count += 1
        local isTable = typeof(value) == "table"
        local displayValue
        if isTable then
            displayValue = "[table]"
        elseif typeof(value) == "string" then
            displayValue = '"' .. value .. '"'
        else
            displayValue = tostring(value)
        end
        local keyContainer = Instance.new("Frame", tableScroll)
        keyContainer.Size = UDim2.new(0.35, -5, 0, 22)
        keyContainer.Position = UDim2.new(0, 3, 0, (count - 1) * 27)
        keyContainer.BackgroundColor3 = self.Theme.White
        keyContainer.BorderSizePixel = 0
        local function CreateWin95Border(parent, isInset)
            local topColor = isInset and self.Theme.DarkGray or self.Theme.White
            local bottomColor = isInset and self.Theme.White or self.Theme.DarkGray
            local topBorder = Instance.new("Frame", parent)
            topBorder.Size = UDim2.new(1, 0, 0, 1)
            topBorder.Position = UDim2.new(0, 0, 0, 0)
            topBorder.BackgroundColor3 = topColor
            topBorder.BorderSizePixel = 0
            topBorder.ZIndex = parent.ZIndex + 1
            local leftBorder = Instance.new("Frame", parent)
            leftBorder.Size = UDim2.new(0, 1, 1, 0)
            leftBorder.Position = UDim2.new(0, 0, 0, 0)
            leftBorder.BackgroundColor3 = topColor
            leftBorder.BorderSizePixel = 0
            leftBorder.ZIndex = parent.ZIndex + 1
            local bottomBorder = Instance.new("Frame", parent)
            bottomBorder.Size = UDim2.new(1, 0, 0, 1)
            bottomBorder.Position = UDim2.new(0, 0, 1, -1)
            bottomBorder.BackgroundColor3 = bottomColor
            bottomBorder.BorderSizePixel = 0
            bottomBorder.ZIndex = parent.ZIndex + 1
            local rightBorder = Instance.new("Frame", parent)
            rightBorder.Size = UDim2.new(0, 1, 1, 0)
            rightBorder.Position = UDim2.new(1, -1, 0, 0)
            rightBorder.BackgroundColor3 = bottomColor
            rightBorder.BorderSizePixel = 0
            rightBorder.ZIndex = parent.ZIndex + 1
        end
        CreateWin95Border(keyContainer, true)
        local keyLabel = Instance.new("TextLabel", keyContainer)
        keyLabel.Size = UDim2.new(1, -4, 1, 0)
        keyLabel.Position = UDim2.new(0, 2, 0, 0)
        keyLabel.BackgroundTransparency = 1
        keyLabel.TextColor3 = self.Theme.Text
        keyLabel.Font = self.Theme.Font
        keyLabel.TextSize = 12
        keyLabel.TextXAlignment = Enum.TextXAlignment.Left
        keyLabel.Text = tostring(key)
        if isTable then
            local hasEditable = false
            for _, v in pairs(value) do
                if typeof(v) ~= "table" and typeof(v) ~= "function" then
                    hasEditable = true
                    break
                end
            end
            local icon = hasEditable and "✔" or "✖"
            local openBtn = Instance.new("TextButton", tableScroll)
            openBtn.Size = UDim2.new(0.65, -8, 0, 22)
            openBtn.Position = UDim2.new(0.35, 5, 0, (count - 1) * 27)
            openBtn.BackgroundColor3 = self.Theme.WindowGray
            openBtn.BorderSizePixel = 0
            openBtn.TextColor3 = self.Theme.Text
            openBtn.Font = self.Theme.Font
            openBtn.TextSize = 12
            openBtn.Text = icon .. " » [table]"
            CreateWin95Border(openBtn, false)
            openBtn.MouseButton1Click:Connect(function()
                table.insert(self.State.TableStack, tbl)
                self:ShowTable(value, tableScroll, backBtn)
            end)
        else
            local valueBox = Instance.new("TextBox", tableScroll)
            valueBox.Size = UDim2.new(0.65, -8, 0, 22)
            valueBox.Position = UDim2.new(0.35, 5, 0, (count - 1) * 27)
            valueBox.BackgroundColor3 = self.Theme.White
            valueBox.BorderSizePixel = 0
            valueBox.TextColor3 = self.Theme.Text
            valueBox.Font = self.Theme.Font
            valueBox.TextSize = 12
            valueBox.ClearTextOnFocus = false
            valueBox.TextWrapped = false
            valueBox.TextTruncate = Enum.TextTruncate.AtEnd
            valueBox.Text = displayValue
            CreateWin95Border(valueBox, true)
            valueBox.FocusLost:Connect(function()
                local input = valueBox.Text
                local newValue
                if input:match('^".*"$') then
                    newValue = input:sub(2, -2)
                elseif input == "true" then
                    newValue = true
                elseif input == "false" then
                    newValue = false
                elseif input == "nil" then
                    newValue = nil
                else
                    newValue = tonumber(input) or input
                end
                tbl[key] = newValue
                print("[ModuleEditor] Patch Applied:", key, "=", newValue)
                DoNotif("Patched: " .. tostring(key), 2)
            end)
        end
    end
    tableScroll.CanvasSize = UDim2.new(0, 0, 0, count * 27 + 10)
end
function Modules.ModuleEditor:CreateUI()
    if self.State.UI then self.State.UI.Enabled = true return end
    local module = self
    local function CreateWin95Border(parent, isInset)
        local topColor = isInset and module.Theme.DarkGray or module.Theme.White
        local bottomColor = isInset and module.Theme.White or module.Theme.DarkGray
        local topBorder = Instance.new("Frame", parent)
        topBorder.Name = "TopBorder"
        topBorder.Size = UDim2.new(1, 0, 0, 2)
        topBorder.Position = UDim2.new(0, 0, 0, 0)
        topBorder.BackgroundColor3 = topColor
        topBorder.BorderSizePixel = 0
        topBorder.ZIndex = parent.ZIndex + 1
        local leftBorder = Instance.new("Frame", parent)
        leftBorder.Name = "LeftBorder"
        leftBorder.Size = UDim2.new(0, 2, 1, 0)
        leftBorder.Position = UDim2.new(0, 0, 0, 0)
        leftBorder.BackgroundColor3 = topColor
        leftBorder.BorderSizePixel = 0
        leftBorder.ZIndex = parent.ZIndex + 1
        local bottomBorder = Instance.new("Frame", parent)
        bottomBorder.Name = "BottomBorder"
        bottomBorder.Size = UDim2.new(1, 0, 0, 2)
        bottomBorder.Position = UDim2.new(0, 0, 1, -2)
        bottomBorder.BackgroundColor3 = bottomColor
        bottomBorder.BorderSizePixel = 0
        bottomBorder.ZIndex = parent.ZIndex + 1
        local rightBorder = Instance.new("Frame", parent)
        rightBorder.Name = "RightBorder"
        rightBorder.Size = UDim2.new(0, 2, 1, 0)
        rightBorder.Position = UDim2.new(1, -2, 0, 0)
        rightBorder.BackgroundColor3 = bottomColor
        rightBorder.BorderSizePixel = 0
        rightBorder.ZIndex = parent.ZIndex + 1
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ModuleTableEditor_Win95"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = self.Services.CoreGui
    self.State.UI = screenGui
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "WindowFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    mainFrame.BackgroundColor3 = self.Theme.WindowGray
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = false
    CreateWin95Border(mainFrame, false)
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Position = UDim2.new(0, 3, 0, 3)
    titleBar.Size = UDim2.new(1, -6, 0, 22)
    titleBar.BackgroundColor3 = self.Theme.Blue
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
    }
    titleGradient.Rotation = 90
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Name = "Title"
    titleLabel.Position = UDim2.new(0, 4, 0, 0)
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Text = "Module Table Editor - Overseer Mini"
    titleLabel.TextColor3 = self.Theme.White
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 3
    local minimizeButton = Instance.new("TextButton", titleBar)
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Position = UDim2.new(1, -54, 0, 2)
    minimizeButton.Size = UDim2.new(0, 16, 0, 16)
    minimizeButton.BackgroundColor3 = self.Theme.WindowGray
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Font = Enum.Font.SourceSansBold
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeButton.TextSize = 14
    minimizeButton.TextYAlignment = Enum.TextYAlignment.Top
    minimizeButton.ZIndex = 4
    CreateWin95Border(minimizeButton, false)
    minimizeButton.MouseButton1Click:Connect(function()
        if module.State.IsMinimized then
            module:Restore()
        else
            module:Minimize()
        end
    end)
    local maximizeButton = Instance.new("TextButton", titleBar)
    maximizeButton.Name = "MaximizeButton"
    maximizeButton.Position = UDim2.new(1, -36, 0, 2)
    maximizeButton.Size = UDim2.new(0, 16, 0, 16)
    maximizeButton.BackgroundColor3 = self.Theme.WindowGray
    maximizeButton.BorderSizePixel = 0
    maximizeButton.Font = Enum.Font.SourceSansBold
    maximizeButton.Text = "□"
    maximizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    maximizeButton.TextSize = 14
    maximizeButton.ZIndex = 4
    CreateWin95Border(maximizeButton, false)
    maximizeButton.MouseButton1Click:Connect(function()
        module:Maximize()
    end)
    local closeButton = Instance.new("TextButton", titleBar)
    closeButton.Name = "CloseButton"
    closeButton.Position = UDim2.new(1, -18, 0, 2)
    closeButton.Size = UDim2.new(0, 16, 0, 16)
    closeButton.BackgroundColor3 = self.Theme.WindowGray
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.TextSize = 16
    closeButton.ZIndex = 4
    CreateWin95Border(closeButton, false)
    closeButton.MouseButton1Click:Connect(function()
        module:DestroyUI()
    end)
    local sidebarContainer = Instance.new("Frame", mainFrame)
    sidebarContainer.Name = "SidebarContainer"
    sidebarContainer.Size = UDim2.new(0, 180, 1, -34)
    sidebarContainer.Position = UDim2.new(0, 6, 0, 28)
    sidebarContainer.BackgroundColor3 = self.Theme.WindowGray
    sidebarContainer.BorderSizePixel = 0
    sidebarContainer.ZIndex = 1
    CreateWin95Border(sidebarContainer, true)
    local scroll = Instance.new("ScrollingFrame", sidebarContainer)
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.CanvasSize = UDim2.new(0, 0, 5, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 16
    scroll.ScrollBarImageColor3 = self.Theme.WindowGray
    local tableFrame = Instance.new("Frame", mainFrame)
    tableFrame.Name = "TableContainer"
    tableFrame.Position = UDim2.new(0, 192, 0, 28)
    tableFrame.Size = UDim2.new(1, -198, 1, -34)
    tableFrame.BackgroundColor3 = self.Theme.WindowGray
    tableFrame.BorderSizePixel = 0
    tableFrame.Visible = false
    tableFrame.ZIndex = 1
    CreateWin95Border(tableFrame, true)
    local backBtn = Instance.new("TextButton", tableFrame)
    backBtn.Size = UDim2.new(0, 70, 0, 22)
    backBtn.Position = UDim2.new(0, 6, 0, 6)
    backBtn.Text = "« Back"
    backBtn.BackgroundColor3 = self.Theme.WindowGray
    backBtn.BorderSizePixel = 0
    backBtn.TextColor3 = self.Theme.Text
    backBtn.Font = self.Theme.Font
    backBtn.TextSize = 12
    backBtn.Visible = false
    backBtn.ZIndex = 2
    CreateWin95Border(backBtn, false)
    backBtn.MouseButton1Click:Connect(function()
        if #module.State.TableStack > 0 then
            local prev = table.remove(module.State.TableStack)
            module:ShowTable(prev, tableScroll, backBtn)
        end
    end)
    local tableScroll = Instance.new("ScrollingFrame", tableFrame)
    tableScroll.Size = UDim2.new(1, -12, 1, -40)
    tableScroll.Position = UDim2.new(0, 6, 0, 32)
    tableScroll.ScrollBarThickness = 16
    tableScroll.ScrollBarImageColor3 = self.Theme.WindowGray
    tableScroll.BackgroundTransparency = 1
    tableScroll.BorderSizePixel = 0
    tableScroll.ZIndex = 2
    local yOffset = 0
    local containers = {
        ["Workspace"] = self.Services.Workspace,
        ["Players"] = self.Services.Players,
        ["ReplicatedStorage"] = self.Services.ReplicatedStorage
    }
    for serviceName, service in pairs(containers) do
        local serviceBtn = Instance.new("TextButton", scroll)
        serviceBtn.Size = UDim2.new(1, -4, 0, 24)
        serviceBtn.Position = UDim2.new(0, 2, 0, yOffset)
        serviceBtn.BackgroundColor3 = self.Theme.WindowGray
        serviceBtn.BorderSizePixel = 0
        serviceBtn.TextColor3 = self.Theme.Text
        serviceBtn.Text = "📁 " .. serviceName
        serviceBtn.Font = self.Theme.Font
        serviceBtn.TextSize = 12
        CreateWin95Border(serviceBtn, false)
        yOffset += 27
        serviceBtn.MouseButton1Click:Connect(function()
            for _, btn in ipairs(scroll:GetChildren()) do
                if btn:IsA("TextButton") and not btn.Text:find("📁") then
                    btn:Destroy()
                end
            end
            local modOffset = yOffset
            for _, obj in ipairs(service:GetDescendants()) do
                if obj:IsA("ModuleScript") then
                    local success, moduleTable = pcall(function() return require(obj) end)
                    local icon = (success and typeof(moduleTable) == "table") and "✔" or "✖"
                    local modBtn = Instance.new("TextButton", scroll)
                    modBtn.Size = UDim2.new(1, -4, 0, 24)
                    modBtn.Position = UDim2.new(0, 2, 0, modOffset)
                    modBtn.BackgroundColor3 = self.Theme.WindowGray
                    modBtn.BorderSizePixel = 0
                    modBtn.TextColor3 = self.Theme.Text
                    modBtn.Text = "  " .. icon .. " " .. obj.Name
                    modBtn.Font = self.Theme.Font
                    modBtn.TextSize = 11
                    modBtn.TextXAlignment = Enum.TextXAlignment.Left
                    CreateWin95Border(modBtn, false)
                    modOffset += 27
                    modBtn.MouseButton1Click:Connect(function()
                        if success and typeof(moduleTable) == "table" then
                            module.State.TableStack = {}
                            tableFrame.Visible = true
                            module:ShowTable(moduleTable, tableScroll, backBtn)
                        else
                            tableFrame.Visible = false
                            DoNotif("Failed to require: " .. obj.Name, 3)
                        end
                    end)
                end
            end
            scroll.CanvasSize = UDim2.fromOffset(0, modOffset + 50)
        end)
    end
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(16, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3 = self.Theme.WindowGray
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = mainFrame
    for i = 0, 2 do
        local line = Instance.new("Frame", resizeHandle)
        line.Size = UDim2.new(0, 2, 1, -4 * i)
        line.Position = UDim2.new(0, 4 + (4 * i), 0, 4 * i)
        line.BackgroundColor3 = self.Theme.DarkGray
        line.BorderSizePixel = 0
        line.Rotation = 45
    end
    local dragging, resizing = false, false
    local dragStart, resizeStart, startPos, startSize
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            elseif resizing then
                local delta = Vector2.new(input.Position.X - resizeStart.X, input.Position.Y - resizeStart.Y)
                local newX = math.max(400, startSize.X.Offset + delta.X)
                local newY = math.max(300, startSize.Y.Offset + delta.Y)
                mainFrame.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    DoNotif("Module Table Editor: INITIALIZED", 2)
end
function Modules.ModuleEditor:Initialize()
    local module = self
    RegisterCommand({
        Name = "modui",
        Aliases = {},
        Description = "Opens the Module Table Editor to live-patch constants."
    }, function()
        module:CreateUI()
    end)
end
Modules.ScriptExecutor2 = {
    State = {
        IsEnabled = false,
        UI = nil,
        IsMinimized = false,
        IsMaximized = false,
        PreMaximizeSize = nil,
        PreMaximizePosition = nil,
        SavedScripts = {},
        ScriptHistory = {},
        TaskbarButton = nil
    },
    Theme = {
        Background = Color3.fromRGB(0, 0, 0),
        WindowGray = Color3.fromRGB(192, 192, 192),
        DarkGray = Color3.fromRGB(128, 128, 128),
        LightGray = Color3.fromRGB(223, 223, 223),
        White = Color3.fromRGB(255, 255, 255),
        Blue = Color3.fromRGB(0, 0, 128),
        TitleGradientStart = Color3.fromRGB(0, 0, 168),
        TitleGradientEnd = Color3.fromRGB(16, 132, 208),
        Accent = Color3.fromRGB(0, 255, 0),
        Text = Color3.fromRGB(0, 0, 0),
        EditorBg = Color3.fromRGB(255, 255, 255),
        EditorText = Color3.fromRGB(0, 0, 0),
        Font = Enum.Font.Code,
        UIFont = Enum.Font.SourceSansBold
    },
    Config = {
        SCRIPTS_DIR = "workspace/executor_scripts",
        MIN_WIDTH = 450,
        MIN_HEIGHT = 350,
        DEFAULT_WIDTH = 700,
        DEFAULT_HEIGHT = 550
    },
    Services = {
        CoreGui = game:GetService("CoreGui"),
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService")
    }
}
function Modules.ScriptExecutor2:Minimize()
    if self.State.IsMinimized then return end
    self.State.IsMinimized = true
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    mainFrame.Visible = false
    local taskbarBtn = Instance.new("Frame")
    taskbarBtn.Name = "TaskbarButton"
    taskbarBtn.Size = UDim2.new(0, 120, 0, 30)
    taskbarBtn.Position = UDim2.new(0, 10, 1, -40)
    taskbarBtn.BackgroundColor3 = self.Theme.WindowGray
    taskbarBtn.BorderSizePixel = 0
    taskbarBtn.ZIndex = 200
    taskbarBtn.Parent = self.State.UI
    self:CreateWin95Border(taskbarBtn, false)
    local logo = Instance.new("Frame", taskbarBtn)
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 5, 0, 5)
    logo.BackgroundTransparency = 1
    logo.ZIndex = 201
    local colors = {
        {Color3.fromRGB(255, 0, 0), UDim2.new(0, 0, 0, 0)},
        {Color3.fromRGB(0, 255, 0), UDim2.new(0, 11, 0, 0)},
        {Color3.fromRGB(0, 0, 255), UDim2.new(0, 0, 0, 11)},
        {Color3.fromRGB(255, 255, 0), UDim2.new(0, 11, 0, 11)}
    }
    for _, colorData in ipairs(colors) do
        local square = Instance.new("Frame", logo)
        square.Size = UDim2.new(0, 8, 0, 8)
        square.Position = colorData[2]
        square.BackgroundColor3 = colorData[1]
        square.BorderSizePixel = 0
        square.ZIndex = 202
    end
    local btnText = Instance.new("TextLabel", taskbarBtn)
    btnText.Size = UDim2.new(1, -30, 1, 0)
    btnText.Position = UDim2.new(0, 28, 0, 0)
    btnText.BackgroundTransparency = 1
    btnText.Font = self.Theme.UIFont
    btnText.Text = "Script Exec..."
    btnText.TextColor3 = self.Theme.Text
    btnText.TextSize = 11
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    btnText.TextTruncate = Enum.TextTruncate.AtEnd
    btnText.ZIndex = 201
    local clickBtn = Instance.new("TextButton", taskbarBtn)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 202
    local module = self
    clickBtn.MouseButton1Click:Connect(function()
        module:Restore()
    end)
    clickBtn.MouseButton1Down:Connect(function()
        taskbarBtn.BackgroundColor3 = self.Theme.DarkGray
        for _, child in ipairs(taskbarBtn:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Theme.DarkGray
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Theme.White
            end
        end
    end)
    clickBtn.MouseButton1Up:Connect(function()
        taskbarBtn.BackgroundColor3 = self.Theme.WindowGray
        for _, child in ipairs(taskbarBtn:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Theme.White
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Theme.DarkGray
            end
        end
    end)
    self.State.TaskbarButton = taskbarBtn
end
function Modules.ScriptExecutor2:Restore()
    if not self.State.IsMinimized then return end
    self.State.IsMinimized = false
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    if self.State.TaskbarButton then
        self.State.TaskbarButton:Destroy()
        self.State.TaskbarButton = nil
    end
    mainFrame.Visible = true
end
function Modules.ScriptExecutor2:Maximize()
    local mainFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not mainFrame then return end
    if self.State.IsMaximized then
        self.State.IsMaximized = false
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
            Position = self.State.PreMaximizePosition,
            Size = self.State.PreMaximizeSize
        })
        tween:Play()
    else
        self.State.PreMaximizeSize = mainFrame.Size
        self.State.PreMaximizePosition = mainFrame.Position
        self.State.IsMaximized = true
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = self.Services.TweenService:Create(mainFrame, tweenInfo, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })
        tween:Play()
    end
end
function Modules.ScriptExecutor2:DestroyUI()
    if self.State.TaskbarButton then
        self.State.TaskbarButton:Destroy()
        self.State.TaskbarButton = nil
    end
    if self.State.UI then
        self.State.UI:Destroy()
        self.State.UI = nil
    end
    self.State.IsMinimized = false
    self.State.IsMaximized = false
    self.State.IsEnabled = false
end
function Modules.ScriptExecutor2:Execute(scriptText)
    if not scriptText or scriptText == "" then
        DoNotif("No script to execute", 2)
        return
    end
    table.insert(self.State.ScriptHistory, 1, {
        code = scriptText,
        time = os.time()
    })
    while #self.State.ScriptHistory > 10 do
        table.remove(self.State.ScriptHistory)
    end
    local success, err = pcall(function()
        local func, loadErr = loadstring(scriptText)
        if not func then
            error(loadErr)
        end
        func()
    end)
    if success then
        DoNotif("✓ Script executed successfully", 2)
    else
        DoNotif("✗ Execution failed", 3)
        warn("[ScriptExecutor] Error:", err)
    end
end
function Modules.ScriptExecutor2:SaveScript(scriptName, scriptCode)
    if not writefile or not makefolder then
        DoNotif("File system not supported", 3)
        return false
    end
    local success = pcall(function()
        if not isfolder or not isfolder(self.Config.SCRIPTS_DIR) then
            makefolder(self.Config.SCRIPTS_DIR)
        end
    end)
    if not success then
        DoNotif("Failed to create scripts folder", 3)
        return false
    end
    local filePath = self.Config.SCRIPTS_DIR .. "/" .. scriptName .. ".lua"
    success = pcall(function()
        writefile(filePath, scriptCode)
    end)
    if success then
        self.State.SavedScripts[scriptName] = {
            path = filePath,
            code = scriptCode,
            saved = os.time()
        }
        DoNotif("✓ Saved: " .. scriptName, 2)
        self:RefreshScriptList()
        return true
    else
        DoNotif("✗ Save failed", 3)
        return false
    end
end
function Modules.ScriptExecutor2:DeleteScript(scriptName)
    if not delfile then
        DoNotif("File deletion not supported", 3)
        return false
    end
    local scriptData = self.State.SavedScripts[scriptName]
    if not scriptData then
        DoNotif("Script not found", 3)
        return false
    end
    local success = pcall(function()
        delfile(scriptData.path)
    end)
    if success then
        self.State.SavedScripts[scriptName] = nil
        DoNotif("✓ Deleted: " .. scriptName, 2)
        self:RefreshScriptList()
        return true
    else
        DoNotif("✗ Delete failed", 3)
        return false
    end
end
function Modules.ScriptExecutor2:RefreshScriptList()
    if not self.State.UI then return end
    local windowFrame = self.State.UI:FindFirstChild("WindowFrame")
    if not windowFrame then return end
    local scriptPanel = windowFrame:FindFirstChild("ScriptPanel")
    if not scriptPanel then return end
    local listContainer = scriptPanel:FindFirstChild("ListContainer")
    if not listContainer then return end
    local scriptList = listContainer:FindFirstChild("ScriptList")
    if not scriptList then 
        warn("[ScriptExecutor] ScriptList not found!")
        return 
    end
    for _, child in ipairs(scriptList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    self:LoadSavedScripts()
    local scriptCount = 0
    for _ in pairs(self.State.SavedScripts) do
        scriptCount = scriptCount + 1
    end
    print("[ScriptExecutor] Found " .. scriptCount .. " scripts in SavedScripts table")
    for name, data in pairs(self.State.SavedScripts) do
        print("[ScriptExecutor] Script: " .. name)
    end
    local yOffset = 0
    local scriptBox = self.State.UI:FindFirstChild("WindowFrame"):FindFirstChild("EditorContainer"):FindFirstChild("EditorScroll"):FindFirstChild("ScriptEditor")
    for scriptName, scriptData in pairs(self.State.SavedScripts) do
        local item = Instance.new("Frame", scriptList)
        item.Name = scriptName
        item.Size = UDim2.new(1, -4, 0, 24)
        item.Position = UDim2.new(0, 2, 0, yOffset)
        item.BackgroundColor3 = self.Theme.WindowGray
        item.BorderSizePixel = 0
        item.ZIndex = 3
        self:CreateWin95Border(item, false)
        local nameLabel = Instance.new("TextLabel", item)
        nameLabel.Size = UDim2.new(1, -50, 1, 0)
        nameLabel.Position = UDim2.new(0, 4, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.Text = scriptName
        nameLabel.TextColor3 = self.Theme.Text
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex = 4
        local loadBtn = self:CreateWin95Button(item, {
            Name = "LoadBtn",
            Position = UDim2.new(1, -44, 0, 2),
            Size = UDim2.new(0, 20, 0, 20),
            Text = "📂",
            TextSize = 10,
            ZIndex = 5,
            Callback = function()
                if scriptBox then
                    scriptBox.Text = scriptData.code
                    DoNotif("✓ Loaded: " .. scriptName, 2)
                end
            end
        })
        local delBtn = self:CreateWin95Button(item, {
            Name = "DelBtn",
            Position = UDim2.new(1, -22, 0, 2),
            Size = UDim2.new(0, 20, 0, 20),
            Text = "×",
            TextSize = 14,
            ZIndex = 5,
            Callback = function()
                self:DeleteScript(scriptName)
            end
        })
        yOffset = yOffset + 26
    end
    scriptList.CanvasSize = UDim2.new(1, 0, 0, yOffset)
end
function Modules.ScriptExecutor2:ShowSaveDialog(scriptCode)
    local module = self
    local dialogBackdrop = Instance.new("Frame")
    dialogBackdrop.Name = "SaveDialog"
    dialogBackdrop.Size = UDim2.new(1, 0, 1, 0)
    dialogBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dialogBackdrop.BackgroundTransparency = 0.5
    dialogBackdrop.BorderSizePixel = 0
    dialogBackdrop.ZIndex = 100
    dialogBackdrop.Parent = self.State.UI
    local dialog = Instance.new("Frame", dialogBackdrop)
    dialog.Name = "DialogWindow"
    dialog.Size = UDim2.new(0, 350, 0, 120)
    dialog.Position = UDim2.new(0.5, -175, 0.5, -60)
    dialog.BackgroundColor3 = self.Theme.WindowGray
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 101
    self:CreateWin95Border(dialog, false)
    local dialogTitle = Instance.new("Frame", dialog)
    dialogTitle.Name = "TitleBar"
    dialogTitle.Position = UDim2.new(0, 3, 0, 3)
    dialogTitle.Size = UDim2.new(1, -6, 0, 20)
    dialogTitle.BackgroundColor3 = self.Theme.Blue
    dialogTitle.BorderSizePixel = 0
    dialogTitle.ZIndex = 102
    local titleGradient = Instance.new("UIGradient", dialogTitle)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Theme.TitleGradientStart),
        ColorSequenceKeypoint.new(1, self.Theme.TitleGradientEnd)
    }
    titleGradient.Rotation = 90
    local titleText = Instance.new("TextLabel", dialogTitle)
    titleText.Size = UDim2.new(1, -4, 1, 0)
    titleText.Position = UDim2.new(0, 4, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = self.Theme.UIFont
    titleText.Text = "Save Script"
    titleText.TextColor3 = self.Theme.White
    titleText.TextSize = 12
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 103
    local label = Instance.new("TextLabel", dialog)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 30)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.Text = "Script Name:"
    label.TextColor3 = self.Theme.Text
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 102
    local inputContainer = Instance.new("Frame", dialog)
    inputContainer.Size = UDim2.new(1, -20, 0, 22)
    inputContainer.Position = UDim2.new(0, 10, 0, 52)
    inputContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputContainer.BorderSizePixel = 0
    inputContainer.ZIndex = 102
    self:CreateWin95Border(inputContainer, true)
    local textInput = Instance.new("TextBox", inputContainer)
    textInput.Size = UDim2.new(1, -8, 1, -4)
    textInput.Position = UDim2.new(0, 4, 0, 2)
    textInput.BackgroundTransparency = 1
    textInput.Font = Enum.Font.SourceSans
    textInput.Text = "MyScript"
    textInput.TextColor3 = self.Theme.Text
    textInput.TextSize = 11
    textInput.TextXAlignment = Enum.TextXAlignment.Left
    textInput.ClearTextOnFocus = false
    textInput.ZIndex = 103
    local saveBtn = self:CreateWin95Button(dialog, {
        Name = "SaveBtn",
        Position = UDim2.new(0.5, -90, 1, -32),
        Size = UDim2.new(0, 80, 0, 24),
        Text = "Save",
        TextSize = 11,
        ZIndex = 102,
        Callback = function()
            local scriptName = textInput.Text:gsub("%.lua$", "")
            if scriptName and scriptName ~= "" then
                module:SaveScript(scriptName, scriptCode)
                dialogBackdrop:Destroy()
            else
                DoNotif("Please enter a valid name", 2)
            end
        end
    })
    local cancelBtn = self:CreateWin95Button(dialog, {
        Name = "CancelBtn",
        Position = UDim2.new(0.5, 10, 1, -32),
        Size = UDim2.new(0, 80, 0, 24),
        Text = "Cancel",
        TextSize = 11,
        ZIndex = 102,
        Callback = function()
            dialogBackdrop:Destroy()
        end
    })
    textInput:CaptureFocus()
    textInput.SelectionStart = 1
    textInput.CursorPosition = #textInput.Text + 1
    textInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            saveBtn.MouseButton1Click:Fire()
        end
    end)
end
function Modules.ScriptExecutor2:LoadSavedScripts()
    if not listfiles or not isfolder then 
        print("[ScriptExecutor] listfiles or isfolder not available")
        return 0 
    end
    local success, files = pcall(function()
        if not isfolder(self.Config.SCRIPTS_DIR) then
            print("[ScriptExecutor] Scripts directory doesn't exist: " .. self.Config.SCRIPTS_DIR)
            return {}
        end
        return listfiles(self.Config.SCRIPTS_DIR)
    end)
    if not success or not files then 
        print("[ScriptExecutor] Failed to list files or no files found")
        return 0 
    end
    print("[ScriptExecutor] Found " .. #files .. " files in directory")
    local count = 0
    for _, filePath in ipairs(files) do
        print("[ScriptExecutor] Checking file: " .. filePath)
        if filePath:lower():match("%.lua$") then
            local loadSuccess, content = pcall(function()
                return readfile(filePath)
            end)
            if loadSuccess and content then
                local scriptName = filePath:match("([^/\\]+)%.lua$") or filePath:match("([^/\\]+)$")
                print("[ScriptExecutor] Loaded script: " .. scriptName)
                self.State.SavedScripts[scriptName] = {
                    path = filePath,
                    code = content,
                    saved = os.time()
                }
                count = count + 1
            else
                print("[ScriptExecutor] Failed to read file: " .. filePath)
            end
        end
    end
    print("[ScriptExecutor] Total scripts loaded: " .. count)
    return count
end
function Modules.ScriptExecutor2:CreateWin95Border(parent, isInset)
    local topColor = isInset and self.Theme.DarkGray or self.Theme.White
    local bottomColor = isInset and self.Theme.White or self.Theme.DarkGray
    local topBorder = Instance.new("Frame", parent)
    topBorder.Name = "TopBorder"
    topBorder.Size = UDim2.new(1, 0, 0, 2)
    topBorder.Position = UDim2.new(0, 0, 0, 0)
    topBorder.BackgroundColor3 = topColor
    topBorder.BorderSizePixel = 0
    topBorder.ZIndex = parent.ZIndex + 1
    local leftBorder = Instance.new("Frame", parent)
    leftBorder.Name = "LeftBorder"
    leftBorder.Size = UDim2.new(0, 2, 1, 0)
    leftBorder.Position = UDim2.new(0, 0, 0, 0)
    leftBorder.BackgroundColor3 = topColor
    leftBorder.BorderSizePixel = 0
    leftBorder.ZIndex = parent.ZIndex + 1
    local bottomBorder = Instance.new("Frame", parent)
    bottomBorder.Name = "BottomBorder"
    bottomBorder.Size = UDim2.new(1, 0, 0, 2)
    bottomBorder.Position = UDim2.new(0, 0, 1, -2)
    bottomBorder.BackgroundColor3 = bottomColor
    bottomBorder.BorderSizePixel = 0
    bottomBorder.ZIndex = parent.ZIndex + 1
    local rightBorder = Instance.new("Frame", parent)
    rightBorder.Name = "RightBorder"
    rightBorder.Size = UDim2.new(0, 2, 1, 0)
    rightBorder.Position = UDim2.new(1, -2, 0, 0)
    rightBorder.BackgroundColor3 = bottomColor
    rightBorder.BorderSizePixel = 0
    rightBorder.ZIndex = parent.ZIndex + 1
end
function Modules.ScriptExecutor2:CreateWin95Button(parent, props)
    local button = Instance.new("TextButton", parent)
    button.Name = props.Name or "Button"
    button.Position = props.Position
    button.Size = props.Size
    button.BackgroundColor3 = self.Theme.WindowGray
    button.BorderSizePixel = 0
    button.Font = self.Theme.UIFont
    button.Text = props.Text or ""
    button.TextColor3 = self.Theme.Text
    button.TextSize = props.TextSize or 12
    button.ZIndex = props.ZIndex or 2
    self:CreateWin95Border(button, false)
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = self.Theme.DarkGray
        for _, child in ipairs(button:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Theme.DarkGray
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Theme.White
            end
        end
    end)
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = self.Theme.WindowGray
        for _, child in ipairs(button:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Theme.White
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Theme.DarkGray
            end
        end
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = self.Theme.WindowGray
        for _, child in ipairs(button:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Theme.White
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Theme.DarkGray
            end
        end
    end)
    if props.Callback then
        button.MouseButton1Click:Connect(props.Callback)
    end
    return button
end
function Modules.ScriptExecutor2:CreateMenuBar(parent, scriptBox)
    local menuBar = Instance.new("Frame", parent)
    menuBar.Name = "MenuBar"
    menuBar.Position = UDim2.new(0, 3, 0, 28)
    menuBar.Size = UDim2.new(1, -6, 0, 20)
    menuBar.BackgroundColor3 = self.Theme.WindowGray
    menuBar.BorderSizePixel = 0
    menuBar.ZIndex = 2
    self:CreateWin95Border(menuBar, false)
    local fileMenu = self:CreateWin95Button(menuBar, {
        Name = "FileMenu",
        Position = UDim2.new(0, 4, 0, 2),
        Size = UDim2.new(0, 60, 0, 16),
        Text = "File",
        TextSize = 11,
        ZIndex = 3
    })
    local scriptsMenu = self:CreateWin95Button(menuBar, {
        Name = "ScriptsMenu",
        Position = UDim2.new(0, 68, 0, 2),
        Size = UDim2.new(0, 60, 0, 16),
        Text = "Scripts",
        TextSize = 11,
        ZIndex = 3
    })
    local helpMenu = self:CreateWin95Button(menuBar, {
        Name = "HelpMenu",
        Position = UDim2.new(0, 132, 0, 2),
        Size = UDim2.new(0, 60, 0, 16),
        Text = "Help",
        TextSize = 11,
        ZIndex = 3,
        Callback = function()
            DoNotif("Script Executor v1.0 - Windows 95 Edition", 3)
        end
    })
    return menuBar
end
function Modules.ScriptExecutor2:UpdateLineNumbers(scriptBox, lineNumText)
    local lineCount = select(2, scriptBox.Text:gsub("\n", "\n")) + 1
    local numbers = {}
    for i = 1, math.min(lineCount, 1000) do
        table.insert(numbers, tostring(i))
    end
    lineNumText.Text = table.concat(numbers, "\n")
end
function Modules.ScriptExecutor2:CreateUI()
    if self.State.UI then 
        self.State.UI.Enabled = true 
        return 
    end
    local module = self
    self:LoadSavedScripts()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScriptExecutor_Win95"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = self.Services.CoreGui
    self.State.UI = screenGui
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "WindowFrame"
    mainFrame.Size = UDim2.new(0, self.Config.DEFAULT_WIDTH, 0, self.Config.DEFAULT_HEIGHT)
    mainFrame.Position = UDim2.new(0.5, -self.Config.DEFAULT_WIDTH/2, 0.5, -self.Config.DEFAULT_HEIGHT/2)
    mainFrame.BackgroundColor3 = self.Theme.WindowGray
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = false
    mainFrame.ZIndex = 1
    self:CreateWin95Border(mainFrame, false)
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Position = UDim2.new(0, 3, 0, 3)
    titleBar.Size = UDim2.new(1, -6, 0, 22)
    titleBar.BackgroundColor3 = self.Theme.Blue
    titleBar.BorderSizePixel = 0
    titleBar.Active = true
    titleBar.ZIndex = 2
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Theme.TitleGradientStart),
        ColorSequenceKeypoint.new(1, self.Theme.TitleGradientEnd)
    }
    titleGradient.Rotation = 90
    local icon = Instance.new("Frame", titleBar)
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 4, 0, 3)
    icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    icon.BorderSizePixel = 0
    icon.ZIndex = 3
    local iconText = Instance.new("TextLabel", icon)
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "⚡"
    iconText.TextColor3 = Color3.fromRGB(255, 165, 0)
    iconText.Font = Enum.Font.SourceSansBold
    iconText.TextSize = 14
    iconText.ZIndex = 4
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Name = "Title"
    titleLabel.Position = UDim2.new(0, 24, 0, 0)
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = self.Theme.UIFont
    titleLabel.Text = "Script Executor - Windows 95 Edition"
    titleLabel.TextColor3 = self.Theme.White
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 3
    local minimizeButton = self:CreateWin95Button(titleBar, {
        Name = "MinimizeButton",
        Position = UDim2.new(1, -60, 0, 2),
        Size = UDim2.new(0, 18, 0, 18),
        Text = "_",
        TextSize = 14,
        ZIndex = 4,
        Callback = function()
            if module.State.IsMinimized then
                module:Restore()
            else
                module:Minimize()
            end
        end
    })
    minimizeButton.TextYAlignment = Enum.TextYAlignment.Top
    local maximizeButton = self:CreateWin95Button(titleBar, {
        Name = "MaximizeButton",
        Position = UDim2.new(1, -40, 0, 2),
        Size = UDim2.new(0, 18, 0, 18),
        Text = "□",
        TextSize = 14,
        ZIndex = 4,
        Callback = function()
            module:Maximize()
        end
    })
    local closeButton = self:CreateWin95Button(titleBar, {
        Name = "CloseButton",
        Position = UDim2.new(1, -20, 0, 2),
        Size = UDim2.new(0, 18, 0, 18),
        Text = "×",
        TextSize = 16,
        ZIndex = 4,
        Callback = function()
            module:DestroyUI()
        end
    })
    local scriptPanel = Instance.new("Frame", mainFrame)
    scriptPanel.Name = "ScriptPanel"
    scriptPanel.Position = UDim2.new(0, 8, 0, 52)
    scriptPanel.Size = UDim2.new(0, 150, 1, -96)
    scriptPanel.BackgroundColor3 = self.Theme.WindowGray
    scriptPanel.BorderSizePixel = 0
    scriptPanel.ZIndex = 1
    self:CreateWin95Border(scriptPanel, false)
    local panelTitle = Instance.new("Frame", scriptPanel)
    panelTitle.Size = UDim2.new(1, -4, 0, 20)
    panelTitle.Position = UDim2.new(0, 2, 0, 2)
    panelTitle.BackgroundColor3 = self.Theme.Blue
    panelTitle.BorderSizePixel = 0
    panelTitle.ZIndex = 2
    local panelTitleText = Instance.new("TextLabel", panelTitle)
    panelTitleText.Size = UDim2.new(1, -4, 1, 0)
    panelTitleText.Position = UDim2.new(0, 2, 0, 0)
    panelTitleText.BackgroundTransparency = 1
    panelTitleText.Font = self.Theme.UIFont
    panelTitleText.Text = "Saved Scripts"
    panelTitleText.TextColor3 = self.Theme.White
    panelTitleText.TextSize = 11
    panelTitleText.TextXAlignment = Enum.TextXAlignment.Left
    panelTitleText.ZIndex = 3
    local scriptListContainer = Instance.new("Frame", scriptPanel)
    scriptListContainer.Name = "ListContainer"
    scriptListContainer.Size = UDim2.new(1, -8, 1, -30)
    scriptListContainer.Position = UDim2.new(0, 4, 0, 24)
    scriptListContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scriptListContainer.BorderSizePixel = 0
    scriptListContainer.ClipsDescendants = true
    scriptListContainer.ZIndex = 2
    self:CreateWin95Border(scriptListContainer, true)
    local scriptList = Instance.new("ScrollingFrame", scriptListContainer)
    scriptList.Name = "ScriptList"
    scriptList.Size = UDim2.new(1, -4, 1, -4)
    scriptList.Position = UDim2.new(0, 2, 0, 2)
    scriptList.BackgroundTransparency = 1
    scriptList.BorderSizePixel = 0
    scriptList.ScrollBarThickness = 6
    scriptList.CanvasSize = UDim2.new(1, 0, 0, 0)
    scriptList.ScrollBarImageColor3 = self.Theme.WindowGray
    scriptList.ZIndex = 3
    local editorContainer = Instance.new("Frame", mainFrame)
    editorContainer.Name = "EditorContainer"
    editorContainer.Position = UDim2.new(0, 164, 0, 52)
    editorContainer.Size = UDim2.new(1, -172, 1, -96)
    editorContainer.BackgroundColor3 = self.Theme.EditorBg
    editorContainer.BorderSizePixel = 0
    editorContainer.ClipsDescendants = true
    editorContainer.ZIndex = 1
    self:CreateWin95Border(editorContainer, true)
    local lineNumbers = Instance.new("Frame", editorContainer)
    lineNumbers.Name = "LineNumbers"
    lineNumbers.Size = UDim2.new(0, 40, 1, -4)
    lineNumbers.Position = UDim2.new(0, 2, 0, 2)
    lineNumbers.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    lineNumbers.BorderSizePixel = 0
    lineNumbers.ClipsDescendants = true
    lineNumbers.ZIndex = 2
    local lineNumScroll = Instance.new("ScrollingFrame", lineNumbers)
    lineNumScroll.Name = "LineNumScroll"
    lineNumScroll.Size = UDim2.new(1, 0, 1, 0)
    lineNumScroll.Position = UDim2.new(0, 0, 0, 0)
    lineNumScroll.BackgroundTransparency = 1
    lineNumScroll.BorderSizePixel = 0
    lineNumScroll.ScrollBarThickness = 0
    lineNumScroll.ScrollingEnabled = false
    lineNumScroll.CanvasSize = UDim2.new(1, 0, 1, 0)
    lineNumScroll.ZIndex = 3
    local lineNumText = Instance.new("TextLabel", lineNumScroll)
    lineNumText.Name = "LineNumText"
    lineNumText.Size = UDim2.new(1, -4, 1, 0)
    lineNumText.Position = UDim2.new(0, 0, 0, 4)
    lineNumText.BackgroundTransparency = 1
    lineNumText.Font = self.Theme.Font
    lineNumText.TextSize = 12
    lineNumText.TextColor3 = Color3.fromRGB(128, 128, 128)
    lineNumText.TextXAlignment = Enum.TextXAlignment.Right
    lineNumText.TextYAlignment = Enum.TextYAlignment.Top
    lineNumText.Text = "1"
    lineNumText.ZIndex = 4
    local numPadding = Instance.new("UIPadding", lineNumText)
    numPadding.PaddingRight = UDim.new(0, 4)
    local editorScroll = Instance.new("ScrollingFrame", editorContainer)
    editorScroll.Name = "EditorScroll"
    editorScroll.Size = UDim2.new(1, -48, 1, -8)
    editorScroll.Position = UDim2.new(0, 44, 0, 4)
    editorScroll.BackgroundTransparency = 1
    editorScroll.BorderSizePixel = 0
    editorScroll.ScrollBarThickness = 8
    editorScroll.CanvasSize = UDim2.new(1, 0, 1, 0)
    editorScroll.ScrollingDirection = Enum.ScrollingDirection.XY
    editorScroll.ElasticBehavior = Enum.ElasticBehavior.Never
    editorScroll.ZIndex = 2
    editorScroll.ScrollBarImageColor3 = self.Theme.WindowGray
    editorScroll.ScrollBarImageTransparency = 0
    local scriptBox = Instance.new("TextBox", editorScroll)
    scriptBox.Name = "ScriptEditor"
    scriptBox.Size = UDim2.new(1, 0, 1, 0)
    scriptBox.Position = UDim2.new(0, 0, 0, 0)
    scriptBox.BackgroundTransparency = 1
    scriptBox.Font = self.Theme.Font
    scriptBox.TextSize = 12
    scriptBox.TextColor3 = self.Theme.EditorText
    scriptBox.TextXAlignment = Enum.TextXAlignment.Left
    scriptBox.TextYAlignment = Enum.TextYAlignment.Top
    scriptBox.ClearTextOnFocus = false
    scriptBox.MultiLine = true
    scriptBox.Text = "-- Windows 95 Script Executor\n-- Enter your Lua script here\n\nprint('Hello from the 90s!')\nDoNotif('Script loaded!', 2)"
    scriptBox.TextWrapped = false
    scriptBox.ZIndex = 3
    local function updateCanvasSize()
        local textSize = game:GetService("TextService"):GetTextSize(
            scriptBox.Text,
            scriptBox.TextSize,
            scriptBox.Font,
            Vector2.new(math.huge, math.huge)
        )
        local canvasWidth = math.max(textSize.X + 20, editorScroll.AbsoluteSize.X)
        local canvasHeight = math.max(textSize.Y + 20, editorScroll.AbsoluteSize.Y)
        editorScroll.CanvasSize = UDim2.new(0, canvasWidth, 0, canvasHeight)
        scriptBox.Size = UDim2.new(0, canvasWidth, 0, canvasHeight)
        lineNumScroll.CanvasSize = UDim2.new(1, 0, 0, canvasHeight)
        lineNumText.Size = UDim2.new(1, -4, 0, canvasHeight)
        module:UpdateLineNumbers(scriptBox, lineNumText)
    end
    scriptBox:GetPropertyChangedSignal("Text"):Connect(updateCanvasSize)
    editorScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        lineNumScroll.CanvasPosition = Vector2.new(0, editorScroll.CanvasPosition.Y)
    end)
    updateCanvasSize()
    local menuBar = self:CreateMenuBar(mainFrame, scriptBox)
    local statusBar = Instance.new("Frame", mainFrame)
    statusBar.Name = "StatusBar"
    statusBar.Position = UDim2.new(0, 164, 1, -24)
    statusBar.Size = UDim2.new(1, -167, 0, 21)
    statusBar.BackgroundColor3 = self.Theme.WindowGray
    statusBar.BorderSizePixel = 0
    statusBar.ZIndex = 1
    self:CreateWin95Border(statusBar, true)
    local statusText = Instance.new("TextLabel", statusBar)
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -8, 1, -4)
    statusText.Position = UDim2.new(0, 4, 0, 2)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.SourceSans
    statusText.Text = "Ready"
    statusText.TextColor3 = self.Theme.Text
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.ZIndex = 2
    local buttonBar = Instance.new("Frame", mainFrame)
    buttonBar.Name = "ButtonBar"
    buttonBar.Position = UDim2.new(0, 164, 1, -61)
    buttonBar.Size = UDim2.new(1, -172, 0, 32)
    buttonBar.BackgroundColor3 = self.Theme.WindowGray
    buttonBar.BorderSizePixel = 0
    buttonBar.ZIndex = 1
    self:CreateWin95Border(buttonBar, true)
    local executeBtn = self:CreateWin95Button(buttonBar, {
        Name = "ExecuteButton",
        Position = UDim2.new(0, 6, 0, 6),
        Size = UDim2.new(0, 90, 0, 20),
        Text = "▶ Execute",
        TextSize = 11,
        ZIndex = 2,
        Callback = function()
            statusText.Text = "Executing script..."
            task.wait(0.1)
            module:Execute(scriptBox.Text)
            statusText.Text = "Ready"
        end
    })
    local clearBtn = self:CreateWin95Button(buttonBar, {
        Name = "ClearButton",
        Position = UDim2.new(0, 102, 0, 6),
        Size = UDim2.new(0, 80, 0, 20),
        Text = "🗑 Clear",
        TextSize = 11,
        ZIndex = 2,
        Callback = function()
            scriptBox.Text = ""
            DoNotif("Editor cleared", 2)
            statusText.Text = "Editor cleared"
        end
    })
    local copyBtn = self:CreateWin95Button(buttonBar, {
        Name = "CopyButton",
        Position = UDim2.new(0, 188, 0, 6),
        Size = UDim2.new(0, 80, 0, 20),
        Text = "📋 Copy",
        TextSize = 11,
        ZIndex = 2,
        Callback = function()
            if setclipboard then
                setclipboard(scriptBox.Text)
                DoNotif("Copied to clipboard", 2)
                statusText.Text = "Copied to clipboard"
            else
                DoNotif("Clipboard not supported", 2)
                statusText.Text = "Clipboard not available"
            end
        end
    })
    local pasteBtn = self:CreateWin95Button(buttonBar, {
        Name = "PasteButton",
        Position = UDim2.new(0, 274, 0, 6),
        Size = UDim2.new(0, 80, 0, 20),
        Text = "📄 Paste",
        TextSize = 11,
        ZIndex = 2,
        Callback = function()
            if getclipboard then
                scriptBox.Text = getclipboard()
                DoNotif("Pasted from clipboard", 2)
                statusText.Text = "Pasted from clipboard"
            else
                DoNotif("Clipboard not supported", 2)
                statusText.Text = "Clipboard not available"
            end
        end
    })
    local saveBtn = self:CreateWin95Button(buttonBar, {
        Name = "SaveButton",
        Position = UDim2.new(0, 360, 0, 6),
        Size = UDim2.new(0, 80, 0, 20),
        Text = "💾 Save",
        TextSize = 11,
        ZIndex = 2,
        Callback = function()
            module:ShowSaveDialog(scriptBox.Text)
        end
    })
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(16, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3 = self.Theme.WindowGray
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = mainFrame
    for i = 0, 2 do
        local line = Instance.new("Frame", resizeHandle)
        line.Size = UDim2.new(0, 2, 1, -4 * i)
        line.Position = UDim2.new(0, 4 + (4 * i), 0, 4 * i)
        line.BackgroundColor3 = self.Theme.DarkGray
        line.BorderSizePixel = 0
        line.Rotation = 45
        line.ZIndex = 11
    end
    local dragging, resizing = false, false
    local dragStart, resizeStart, startPos, startSize
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not module.State.IsMaximized then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    local lastClick = 0
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local now = tick()
            if now - lastClick < 0.3 then
                module:Maximize()
            end
            lastClick = now
        end
    end)
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not module.State.IsMaximized then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
            startPos = mainFrame.Position
            local conn; conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    conn:Disconnect()
                end
            end)
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            elseif resizing then
                local delta = Vector2.new(
                    input.Position.X - resizeStart.X, 
                    input.Position.Y - resizeStart.Y
                )
                local newWidth = math.max(module.Config.MIN_WIDTH, startSize.X.Offset + delta.X)
                local newHeight = math.max(module.Config.MIN_HEIGHT, startSize.Y.Offset + delta.Y)
                mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end
    end)
    self.State.IsEnabled = true
    statusText.Text = "Script Executor loaded - Ready"
    DoNotif("⚡ Script Executor opened", 2)
    self:RefreshScriptList()
end
function Modules.ScriptExecutor2:Toggle()
    if self.State.IsEnabled then
        self:DestroyUI()
        DoNotif("Script Executor closed", 2)
    else
        self:CreateUI()
    end
end
function Modules.ScriptExecutor2:Initialize()
    local module = self
    RegisterCommand({
        Name = "fastexec",
        Aliases = {"quickexec", "exec95"},
        Description = "Opens the Windows 95 style script executor"
    }, function()
        module:Toggle()
    end)
    print("[ScriptExecutor] Windows 95 Edition initialized")
end
Modules.CreepSequence = {
    State = {
        IsExecuting = false
    },
    Dependencies = {"TweenService", "RunService", "Players",},
    Services = {}
}
function Modules.CreepSequence:Execute(targetName)
    if self.State.IsExecuting then return end
    local target = Utilities.findPlayer(targetName)
    if not target then
        return DoNotif("Creep: Target not found.", 3)
    end
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not root or not tRoot then
        return DoNotif("Creep: Character parts missing.", 3)
    end
    self.State.IsExecuting = true
    DoNotif("Executing creep sequence on " .. target.Name, 1.5)
    root.CFrame = tRoot.CFrame * CFrame.new(0, -10, 4)
    task.wait()
    local noclipConn
    noclipConn = self.Services.RunService.Stepped:Connect(function()
        if not char or not self.State.IsExecuting then
            noclipConn:Disconnect()
            return
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    root.Anchored = true
    task.wait()
    local tweenInfo = TweenInfo.new(1000, Enum.EasingStyle.Linear)
    local risingTween = self.Services.TweenService:Create(root, tweenInfo, {
        CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
    })
    risingTween:Play()
    task.wait(1.5)
    risingTween:Pause()
    root.Anchored = false
    self.State.IsExecuting = false
    risingTween:Destroy()
    DoNotif("Sequence Complete.", 1)
end
function Modules.CreepSequence:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "creep",
        Aliases = {},
        Description = "Teleports you behind/under a player and rises through the floor."
    }, function(args)
        if #args == 0 then
            return DoNotif("Usage: ;creep <PlayerName>", 3)
        end
        module:Execute(args[1])
    end)
end
Modules.NextGenDesync = {
    State = {
        IsEnabled = false
    }
}
function Modules.NextGenDesync:Toggle()
    if type(setfflag) ~= "function" then
        return DoNotif("Architect Error: Executor does not support 'setfflag'.", 3)
    end
    if not self.State.IsEnabled then
        local success, err = pcall(function()
            setfflag("NextGenReplicatorEnabledWrite4", "false")
            setfflag("NextGenReplicatorEnabledWrite4", "true")
        end)
        if success then
            self.State.IsEnabled = true
            DoNotif("NextGen Desync: ENABLED. Replicator authority hijacked.", 4)
        else
            warn("--> [NextGenDesync] Enable Failed:", err)
            DoNotif("FFlag Error: Check F9 for details.", 4)
        end
    else
        local success, err = pcall(function()
            setfflag("NextGenReplicatorEnabledWrite4", "true")
            setfflag("NextGenReplicatorEnabledWrite4", "false")
        end)
        if success then
            self.State.IsEnabled = false
            DoNotif("NextGen Desync: DISABLED. Re-synced with server.", 3)
        else
            warn("--> [NextGenDesync] Disable Failed:", err)
            DoNotif("FFlag Error: Check F9 for details.", 4)
        end
    end
end
function Modules.NextGenDesync:Initialize()
    local module = self
    RegisterCommand({
        Name = "newsync",
        Aliases = {},
        Description = "New method for desync WIP"
    }, function()
        module:Toggle()
    end)
end
Modules.MirrorMimic = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        Delay = 0,
        UID = 0,
        AnimatePrevDisabled = nil,
        PrevAutoRotate = true,
        PoseQueue = {},
        PoseHead = 1,
        AnimEvents = {},
        AnimHead = 1,
        ActiveSlots = {},
        Connections = {}
    },
    Dependencies = {"RunService", "Players", "Workspace"},
    Services = {}
}
function Modules.MirrorMimic:_cleanup()
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    for key, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    for _, slot in pairs(self.State.ActiveSlots) do
        if slot.mt then pcall(function() slot.mt:Stop(0) end) end
    end
    table.clear(self.State.ActiveSlots)
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() tr:Stop(0) end)
            end
        end
        hum.AutoRotate = self.State.PrevAutoRotate
    end
    local animate = char and char:FindFirstChild("Animate")
    if animate and self.State.AnimatePrevDisabled ~= nil then
        animate.Disabled = self.State.AnimatePrevDisabled
    end
    self.State.PoseQueue = {}
    self.State.PoseHead = 1
    self.State.AnimEvents = {}
    self.State.AnimHead = 1
    self.State.IsEnabled = false
    self.State.TargetPlayer = nil
end
function Modules.MirrorMimic:_scheduleAnim(track, kind, extra)
    local now = os.clock()
    table.insert(self.State.AnimEvents, {
        t = now + self.State.Delay,
        kind = kind,
        track = track,
        animId = track.Animation.AnimationId,
        speed = (type(track.Speed) == "number" and track.Speed) or 1,
        baseTP = track.TimePosition or 0,
        looped = track.Looped,
        data = extra
    })
end
function Modules.MirrorMimic:Enable(targetName, delayVal)
    local target = Utilities.findPlayer(targetName)
    if not target or not target.Character then
        return DoNotif("Mimic: Target not found or has no character.", 3)
    end
    local lp = self.Services.Players.LocalPlayer
    local myChar = lp.Character
    local tChar = target.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    if not (myHum and tHum) or myHum.RigType ~= tHum.RigType then
        return DoNotif("Mimic Error: Character rig types do not match.", 3)
    end
    self:_cleanup()
    self.State.IsEnabled = true
    self.State.TargetPlayer = target
    self.State.Delay = tonumber(delayVal) or 0
    self.State.PrevAutoRotate = myHum.AutoRotate
    myHum.AutoRotate = false
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    local myAnimator = myHum:FindFirstChildOfClass("Animator") or Instance.new("Animator", myHum)
    local tAnimator = tHum:FindFirstChildOfClass("Animator")
    local animate = myChar:FindFirstChild("Animate")
    if animate then
        self.State.AnimatePrevDisabled = animate.Disabled
        animate.Disabled = true
    end
    self.State.Connections.AnimPlayed = tHum.AnimationPlayed:Connect(function(tt)
        self:_scheduleAnim(tt, "start")
        self.State.Connections["TrackSpd_"..tostring(tt)] = tt:GetPropertyChangedSignal("Speed"):Connect(function()
            self:_scheduleAnim(tt, "speed")
        end)
        self.State.Connections["TrackStop_"..tostring(tt)] = tt.Stopped:Connect(function()
            self:_scheduleAnim(tt, "stop")
        end)
    end)
    self.State.Connections.ToolEquip = tChar.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            local match = lp.Backpack:FindFirstChild(child.Name)
            if match then pcall(function() myHum:EquipTool(match) end) end
        end
    end)
    local lastLook = Vector3.new(0,0,-1)
    self.State.Connections.MainLoop = self.Services.RunService.Heartbeat:Connect(function()
        if not (tChar.Parent and tRoot.Parent and myChar.Parent) then
            return self:_cleanup()
        end
        local now = os.clock()
        local lv = tRoot.CFrame.LookVector
        local flat = Vector3.new(lv.X, 0, lv.Z)
        if flat.Magnitude >= 1e-4 then lastLook = flat.Unit end
        table.insert(self.State.PoseQueue, {
            t = now,
            pos = tRoot.Position,
            look = lastLook,
            vel = tRoot.AssemblyLinearVelocity,
            angY = tRoot.AssemblyAngularVelocity.Y
        })
        local snap
        while self.State.PoseHead <= #self.State.PoseQueue and self.State.PoseQueue[self.State.PoseHead].t <= (now - self.State.Delay) do
            snap = self.State.PoseQueue[self.State.PoseHead]
            self.State.PoseHead = self.State.PoseHead + 1
        end
        if snap then
            myRoot.CFrame = CFrame.lookAt(snap.pos, snap.pos + snap.look)
            myRoot.AssemblyLinearVelocity = snap.vel
            myRoot.AssemblyAngularVelocity = Vector3.new(0, snap.angY, 0)
            if self.State.PoseHead > 64 then
                local newBuf = {}
                for i = self.State.PoseHead, #self.State.PoseQueue do table.insert(newBuf, self.State.PoseQueue[i]) end
                self.State.PoseQueue, self.State.PoseHead = newBuf, 1
            end
        end
        while self.State.AnimHead <= #self.State.AnimEvents and self.State.AnimEvents[self.State.AnimHead].t <= now do
            local e = self.State.AnimEvents[self.State.AnimHead]
            self.State.AnimHead = self.State.AnimHead + 1
            if e.kind == "start" and e.animId ~= "" then
                self.State.UID = self.State.UID + 1
                local animObj = Instance.new("Animation")
                animObj.AnimationId = e.animId
                local mt = myAnimator:LoadAnimation(animObj)
                pcall(function()
                    mt:Play(0, 1, 1)
                    mt:AdjustSpeed(0)
                    mt.TimePosition = e.baseTP
                end)
                self.State.ActiveSlots[self.State.UID] = {
                    mt = mt,
                    track = e.track,
                    baseTP = e.baseTP,
                    segments = {{t = e.t, speed = e.speed}},
                    looped = e.looped,
                    alive = true
                }
            elseif e.kind == "speed" then
                for _, s in pairs(self.State.ActiveSlots) do
                    if s.alive and s.track == e.track then
                        table.insert(s.segments, {t = e.t, speed = e.speed})
                    end
                end
            elseif e.kind == "stop" then
                for id, s in pairs(self.State.ActiveSlots) do
                    if s.alive and s.track == e.track then
                        pcall(function() s.mt:Stop(0) end)
                        s.alive = false
                        self.State.ActiveSlots[id] = nil
                    end
                end
            end
        end
        for _, s in pairs(self.State.ActiveSlots) do
            if s.alive and s.mt then
                local len = s.mt.Length
                if len > 0 then
                    local tp = s.baseTP
                    for i = 1, #s.segments do
                        local st = s.segments[i].t
                        local sp = s.segments[i].speed
                        local en = (i < #s.segments) and s.segments[i+1].t or now
                        if en > st then tp = tp + (en - st) * sp end
                    end
                    tp = s.looped and (tp % len) or math.clamp(tp, 0, len - 0.03)
                    pcall(function() s.mt.TimePosition = tp end)
                end
            end
        end
    end)
    DoNotif("Mirror Active: Mimicking " .. target.Name, 2)
end
function Modules.MirrorMimic:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "mimic",
        Aliases = {"mirror", "mclone", "mcopy", "mimi"},
        Description = "Clones a player's movement and animations."
    }, function(args)
        if #args == 0 then return DoNotif("Usage: ;mimic <PlayerName> [delay]", 3) end
        module:Enable(args[1], args[2] or 0)
    end)
    RegisterCommand({
        Name = "unmimic",
        Aliases = {"mstop", "moff", "stopmimic"},
        Description = "Stops movement mirroring."
    }, function()
        module:_cleanup()
        DoNotif("Mimic Disabled.", 2)
    end)
end
Modules.ServerHopper = {
    State = {
        IsSearching = false
    },
    Dependencies = {"HttpService", "TeleportService", "Players"},
    Services = {}
}
function Modules.ServerHopper:Hop(mode)
    if self.State.IsSearching then return end
    self.State.IsSearching = true
    local http = self.Services.HttpService
    local tp = self.Services.TeleportService
    local placeId = game.PlaceId
    local jobId = game.JobId
    DoNotif("Searching for a " .. (mode == "High" and "large" or "small") .. " server...", 3)
    task.spawn(function()
        local success, result = pcall(function()
            return game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", placeId))
        end)
        if not success or not result then
            self.State.IsSearching = false
            return DoNotif("Server Hop Error: Failed to fetch server list.", 3)
        end
        local data = http:JSONDecode(result)
        if not data or not data.data then
            self.State.IsSearching = false
            return DoNotif("Server Hop Error: Empty API response.", 3)
        end
        local serverList = data.data
        local candidates = {}
        for _, server in ipairs(serverList) do
            if server.id ~= jobId and server.playing < server.maxPlayers then
                table.insert(candidates, server)
            end
        end
        if #candidates == 0 then
            self.State.IsSearching = false
            return DoNotif("No valid servers found in this batch.", 3)
        end
        if mode == "High" then
            table.sort(candidates, function(a, b) return a.playing > b.playing end)
        else
            table.sort(candidates, function(a, b) return a.playing < b.playing end)
        end
        local target = candidates[1]
        DoNotif(string.format("Joining server [%d/%d players]...", target.playing, target.maxPlayers), 3)
        task.wait(0.5)
        local tpSuccess, tpErr = pcall(function()
            tp:TeleportToPlaceInstance(placeId, target.id, self.Services.Players.LocalPlayer)
        end)
        if not tpSuccess then
            warn("--> [ServerHopper] Teleport Failed:", tpErr)
            DoNotif("Teleport failed. Check console.", 3)
        end
        self.State.IsSearching = false
    end)
end
function Modules.ServerHopper:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "serverhop",
        Aliases = {"shop", "hop"},
        Description = "Teleports you to a different, populated server."
    }, function()
        module:Hop("High")
    end)
    RegisterCommand({
        Name = "smallserverhop",
        Aliases = {"sshop", "smallhop", "minihop"},
        Description = "Teleports you to a server with the fewest players."
    }, function()
        module:Hop("Low")
    end)
end
Modules.ForceSpawn = {}
function Modules.ForceSpawn:Execute()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local localPlayer = Players.LocalPlayer
    if localPlayer.Character then
        DoNotif("Your character already exists. Use '.respawn' to reset a broken character.", 4)
        return
    end
    DoNotif("Attempting to trigger server-side spawn from nil character...", 2)
    local success, err = pcall(function()
        local tempModel = Instance.new("Model")
        tempModel.Name = "ZukaSpawnTrigger"
        tempModel.Parent = Workspace
        localPlayer.Character = tempModel
        task.wait()
        localPlayer.Character = nil
        tempModel:Destroy()
    end)
    if not success then
        warn("[ForceSpawn] Spawn trigger logic failed:", err)
        DoNotif("Spawn trigger failed. See developer console for details.", 4)
    end
end
function Modules.ForceSpawn:Initialize()
    RegisterCommand({
        Name = "spawn",
        Aliases = {"forcespawn"},
        Description = "Forces your character to spawn if you are stuck as a camera (no character)."
    }, function()
        Modules.ForceSpawn:Execute()
    end)
end
Modules.Aura = {
    State = {
        IsEnabled = false,
        Distance = 20,
        Connection = nil,
        Visualizer = nil,
        LastAttack = 0
    },
    Config = {
        ATTACK_INTERVAL = 0.1,
        VISUAL_TRANSPARENCY = 0.8,
        VISUAL_COLOR = Color3.fromRGB(255, 50, 50)
    }
}
function Modules.Aura:_createVisualizer()
    if self.State.Visualizer then self.State.Visualizer:Destroy() end
    local sphere = Instance.new("Part")
    sphere.Name = "AuraVisualizer"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.one * (self.State.Distance * 2)
    sphere.Transparency = self.Config.VISUAL_TRANSPARENCY
    sphere.Color = self.Config.VISUAL_COLOR
    sphere.Material = Enum.Material.Neon
    sphere.CanCollide = false
    sphere.CanTouch = false
    sphere.CanQuery = false
    sphere.Anchored = true
    sphere.Parent = Workspace
    self.State.Visualizer = sphere
end
function Modules.Aura:_getAttackPart(): BasePart?
    local char = Players.LocalPlayer.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    return tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
end
function Modules.Aura:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    if self.State.Visualizer then
        self.State.Visualizer:Destroy()
        self.State.Visualizer = nil
    end
    DoNotif("Kill Aura: DISABLED", 2)
end
function Modules.Aura:Enable()
    if not firetouchinterest then
        return DoNotif("Executor does not support 'firetouchinterest'.", 4)
    end
    self:Disable()
    self.State.IsEnabled = true
    self:_createVisualizer()
    self.State.Connection = RunService.Heartbeat:Connect(function()
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not self.State.Visualizer then return end
        self.State.Visualizer.CFrame = hrp.CFrame
        if os.clock() - self.State.LastAttack < self.Config.ATTACK_INTERVAL then
            return
        end
        local weapon = self:_getAttackPart()
        if not weapon then return end
        self.State.LastAttack = os.clock()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                if targetHrp and targetHum and targetHum.Health > 0 then
                    local mag = (targetHrp.Position - hrp.Position).Magnitude
                    if mag <= self.State.Distance then
                        pcall(function()
                            firetouchinterest(weapon, targetHrp, 0)
                            firetouchinterest(weapon, targetHrp, 1)
                        end)
                    end
                end
            end
        end
    end)
    DoNotif("Kill Aura: ENABLED (" .. self.State.Distance .. " studs)", 2)
end
function Modules.Aura:Initialize()
    local module = self
    RegisterCommand({
        Name = "aura",
        Aliases = {"killaura", "ka"},
        Description = "Toggles a touch-based kill aura. Optional: ;aura [distance]"
    }, function(args)
        local dist = tonumber(args[1])
        if dist then
            module.State.Distance = dist
            if module.State.IsEnabled then
                module:Enable()
            end
        else
            if module.State.IsEnabled then
                module:Disable()
            else
                module:Enable()
            end
        end
    end)
end
Modules.VoodooDoll = {
    State = { IsActive = false, Target = nil, Connection = nil },
    Config = { OFFSET = Vector3.new(0, 5, 0) },
    Dependencies = {"Players", "RunService", "Workspace"}
}
function Modules.VoodooDoll:Possess(targetName)
    local targetPlr = Utilities.findPlayer(targetName)
    if not targetPlr or not targetPlr.Character then return DoNotif("Target not found.", 2) end
    self.State.IsActive = true
    self.State.Target = targetPlr.Character
    self.State.Connection = RunService.Heartbeat:Connect(function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = self.State.Target:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
            tRoot.Velocity = Vector3.new(0, 30, 0)
            tRoot.CFrame = myRoot.CFrame * CFrame.new(self.Config.OFFSET)
        end
    end)
    DoNotif("Voodoo: Possessing " .. targetPlr.Name, 2)
end
function Modules.VoodooDoll:Initialize()
    RegisterCommand({
        Name = "netbring",
        Aliases = {},
        Description = "Locally possess an unanchored character/object."
    }, function(args)
        if self.State.IsActive then
            self.State.Connection:Disconnect()
            self.State.IsActive = false
            DoNotif("Voodoo: Released target.", 2)
        else
            self:Possess(args[1])
        end
    end)
end
Modules.HumanShield = {
    State = {
        IsEnabled = false,
        Targets = {},
        Connections = {}
    },
    Config = {
        DISTANCE = 3.5,
        VERTICAL_OFFSET = 0,
    },
    Dependencies = {"Players", "RunService"}
}
function Modules.HumanShield:Stop(): ()
    self.State.IsEnabled = false
    for _, connection in pairs(self.State.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.State.Connections = {}
    self.State.Targets = {}
end
function Modules.HumanShield:PossessAll(): ()
    if self.State.IsEnabled then self:Stop() end
    local myChar = Players.LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        return DoNotif("Your character not found.", 2)
    end
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, player.Character)
        end
    end
    if #targets == 0 then
        return DoNotif("No valid targets found.", 2)
    end
    self.State.IsEnabled = true
    self.State.Targets = targets
    for i, character in ipairs(targets) do
        local tRoot = character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            local connection = RunService.Heartbeat:Connect(function()
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not (myRoot and tRoot and tRoot.Parent) then
                    return
                end
                tRoot.Velocity = Vector3.new(0, 30.01, 0)
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, self.Config.VERTICAL_OFFSET, -self.Config.DISTANCE)
            end)
            table.insert(self.State.Connections, connection)
        end
    end
    DoNotif("Shield Active: All players (" .. #targets .. ")", 2)
end
function Modules.HumanShield:Possess(targetName: string): ()
    local targetPlr = Utilities.findPlayer(targetName)
    if not targetPlr or not targetPlr.Character then 
        return DoNotif("Target not found.", 2) 
    end
    if self.State.IsEnabled then self:Stop() end
    local character = targetPlr.Character
    local tRoot = character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    self.State.IsEnabled = true
    table.insert(self.State.Targets, character)
    local connection = RunService.Heartbeat:Connect(function()
        local myChar = Players.LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not (myRoot and tRoot and tRoot.Parent) then
            self:Stop()
            return
        end
        tRoot.Velocity = Vector3.new(0, 30.01, 0)
        tRoot.CFrame = myRoot.CFrame * CFrame.new(0, self.Config.VERTICAL_OFFSET, -self.Config.DISTANCE)
    end)
    table.insert(self.State.Connections, connection)
    DoNotif("Shield Active: " .. targetPlr.Name, 2)
end
function Modules.HumanShield:Initialize(): ()
    local module = self
    RegisterCommand({
        Name = "bring",
        Aliases = {"b"},
        Description = "Positions a player in front of you with their back turned. Use 'all' to bring all players."
    }, function(args)
        if module.State.IsEnabled then
            module:Stop()
            DoNotif("Shield Released.", 2)
        else
            if #args > 0 then
                if args[1]:lower() == "all" then
                    module:PossessAll()
                else
                    module:Possess(args[1])
                end
            else
                DoNotif("Usage: ;bring [player/all]", 3)
            end
        end
    end)
end
Modules.NetworkOwnership = {
    State = {
        IsEnabled = false,
        TargetPart = nil,
        Connection = nil,
        OriginalVelocity = nil
    },
    Config = {
        NETWORK_VELOCITY = Vector3.new(0, 30.01, 0),
        SEARCH_RADIUS = 50
    },
    Dependencies = {"RunService", "Players", "Workspace"},
    Services = {}
}
function Modules.NetworkOwnership:Claim(part: BasePart)
    if not part or not part:IsA("BasePart") then
        return DoNotif("NetworkOwner: Invalid Part Target.", 3)
    end
    if part.Anchored then
        return DoNotif("NetworkOwner: Cannot claim anchored objects.", 3)
    end
    self:Release()
    self.State.TargetPart = part
    self.State.IsEnabled = true
    self.State.Connection = self.Services.RunService.Heartbeat:Connect(function()
        if not self.State.IsEnabled or not part or not part.Parent then
            self:Release()
            return
        end
        pcall(function()
            part.AssemblyLinearVelocity = self.Config.NETWORK_VELOCITY
        end)
    end)
    DoNotif("NetworkOwner: Claimed " .. part.Name, 2)
end
function Modules.NetworkOwnership:Release()
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    self.State.TargetPart = nil
    self.State.IsEnabled = false
end
function Modules.NetworkOwnership:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "claim",
        Aliases = {"netown", "setowner", "take"},
        Description = "Forcibly claims network ownership of a part. Usage: ;claim [PartName] or ;claim tool"
    }, function(args)
        local input = args[1] and args[1]:lower() or "tool"
        local targetPart = nil
        if input == "off" or input == "stop" or input == "release" then
            module:Release()
            return DoNotif("NetworkOwner: Released control.", 2)
        end
        local char = self.Services.Players.LocalPlayer.Character
        if input == "tool" and char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                targetPart = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            end
        end
        if not targetPart and args[1] then
            local nameLookup = table.concat(args, " ")
            targetPart = self.Services.Workspace:FindFirstChild(nameLookup, true)
        end
        if targetPart and targetPart:IsA("BasePart") then
            module:Claim(targetPart)
        else
            DoNotif("NetworkOwner: Target part not found.", 3)
        end
    end)
end
Modules.MapStripper = {
    State = { IsEnabled = false, Connection = nil },
    Dependencies = {"Players", "UserInputService"}
}
function Modules.MapStripper:Initialize()
    local lp = Players.LocalPlayer
    local mouse = lp:GetMouse()
    RegisterCommand({
        Name = "deltool",
        Aliases = {},
        Description = "Toggle: Click any object to delete it locally."
    }, function()
        self.State.IsEnabled = not self.State.IsEnabled
        if self.State.IsEnabled then
            self.State.Connection = mouse.Button1Down:Connect(function()
                local target = mouse.Target
                if target and not target:IsDescendantOf(lp.Character) then
                    print("--> [STRIPPER]: Removed " .. target:GetFullName())
                    target:Destroy()
                end
            end)
            DoNotif("(Click to delete)", 2)
        else
            if self.State.Connection then self.State.Connection:Disconnect() end
            DoNotif("Map Stripper: DISABLED", 2)
        end
    end)
end
Modules.AdminWatcher = {
    State = { Detected = {} },
    Config = { SIGNATURES = {"Adonis", "HDAdmin", "Kohl", "Cmdr", "Flux"} }
}
function Modules.AdminWatcher:Scan()
    local found = {}
    for key, _ in pairs(_G) do
        for _, sig in ipairs(self.Config.SIGNATURES) do
            if tostring(key):find(sig) then table.insert(found, tostring(key)) end
        end
    end
    for key, _ in pairs(shared) do
        for _, sig in ipairs(self.Config.SIGNATURES) do
            if tostring(key):find(sig) then table.insert(found, tostring(key)) end
        end
    end
    if #found > 0 then
        DoNotif("ADMIN SYSTEMS DETECTED: " .. table.concat(found, ", "), 5)
        print("--- [ADMIN FORENSICS] ---")
        for _, name in ipairs(found) do print(" [!] Warning: " .. name .. " is active.") end
    else
        DoNotif("No common admin systems found.", 2)
    end
end
function Modules.AdminWatcher:Initialize()
    RegisterCommand({
        Name = "checkadmin",
        Aliases = {"scanenv"},
        Description = "Scans game memory for active admin systems."
    }, function()
        self:Scan()
    end)
end
Modules.HandleKill = {
    State = {
        ActiveTargets = {},
        HeartbeatConnection = nil
    }
}
function Modules.HandleKill:_getKillTool(): (Tool?, BasePart?)
    local character = Players.LocalPlayer.Character
    if not character then return nil, nil end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil, nil end
    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
    return tool, handle
end
function Modules.HandleKill:_process()
    local tool, handle = self:_getKillTool()
    if not tool or not handle then return end
    for target, _ in pairs(self.State.ActiveTargets) do
        pcall(function()
            if not target or not target.Parent or not target.Character then
                self.State.ActiveTargets[target] = nil
                return
            end
            local character = target.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                return
            end
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    firetouchinterest(handle, part, 0)
                    firetouchinterest(handle, part, 1)
                end
            end
        end)
    end
end
function Modules.HandleKill:ToggleTarget(player: Player)
    if self.State.ActiveTargets[player] then
        self.State.ActiveTargets[player] = nil
        DoNotif("HandleKill: Stopped for " .. player.Name, 2)
    else
        self.State.ActiveTargets[player] = true
        DoNotif("HandleKill: Targeting " .. player.Name, 2)
        if not self.State.HeartbeatConnection then
            self.State.HeartbeatConnection = RunService.Heartbeat:Connect(function()
                if next(self.State.ActiveTargets) == nil then
                    self.State.HeartbeatConnection:Disconnect()
                    self.State.HeartbeatConnection = nil
                    return
                end
                self:_process()
            end)
        end
    end
end
function Modules.HandleKill:Initialize()
    local module = self
    RegisterCommand({
        Name = "handlekill",
        Aliases = {"hkill", "touchkill"},
        Description = "Toggles a continuous touch-kill loop on a target using your equipped tool."
    }, function(args)
        if not firetouchinterest then
            return DoNotif("Error: Your executor does not support 'firetouchinterest'.", 4)
        end
        local targetName = table.concat(args, " ")
        if #targetName == 0 then
            return DoNotif("Usage: ;hkill <PlayerName>", 3)
        end
        local targetPlayer = Utilities.findPlayer(targetName)
        if targetPlayer then
            module:ToggleTarget(targetPlayer)
        else
            DoNotif("Player '" .. targetName .. "' not found.", 3)
        end
    end)
end
Modules.HeuristicRemoteBruteforcer = {
    State = {
        IsEnabled = false,
        Connection = nil,
        TargetQueue = {},
        FiredHistory = {},
        IsScanning = false
    },
    Config = {
        FIRE_DELAY = 0.25,
        MAX_CALLS_PER_REMOTE = 15,
        BlacklistedParents = {
            game:GetService("CoreGui"),
            game:GetService("StarterGui"),
            game:GetService("ReplicatedFirst"),
            game:GetService("Workspace")
        }
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService")
    }
}
function Modules.HeuristicRemoteBruteforcer:_getHeuristicPayloads(remote: Instance)
    local payloads = {}
    local remoteName = remote.Name:lower()
    local localPlayer = self.Services.Players.LocalPlayer
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    table.insert(payloads, {true})
    table.insert(payloads, {false})
    table.insert(payloads, {1})
    table.insert(payloads, {0})
    table.insert(payloads, {""})
    table.insert(payloads, {nil})
    table.insert(payloads, {localPlayer})
    table.insert(payloads, {remote.Name})
    if root then
        table.insert(payloads, {root.Position})
        table.insert(payloads, {root.CFrame})
    end
    if remoteName:find("buy") then
        table.insert(payloads, {"Gems", 100}); table.insert(payloads, {"Sword", 0})
    end
    if remoteName:find("sell") then
        table.insert(payloads, {"Rock", 999})
    end
    if remoteName:find("equip") then
        table.insert(payloads, {"Sword"})
    end
     if remoteName:find("teleport") or remoteName:find("tp") then
        table.insert(payloads, {Vector3.new(0, 100, 0)})
    end
    return payloads
end
function Modules.HeuristicRemoteBruteforcer:_scanAndQueue()
    if self.State.IsScanning then return end
    self.State.IsScanning = true
    DoNotif("Bruteforcer: Scanning for new, non-core remotes...", 2)
    task.spawn(function()
        local remotesFound = 0
        local descendants = game:GetDescendants()
        for i, remote in ipairs(descendants) do
            if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                local path = remote:GetFullName()
                if not self.State.FiredHistory[path] then
                    local isBlacklisted = false
                    for _, parentService in ipairs(self.Config.BlacklistedParents) do
                        if remote:IsDescendantOf(parentService) then
                            isBlacklisted = true
                            break
                        end
                    end
                    if not isBlacklisted then
                        table.insert(self.State.TargetQueue, remote)
                        self.State.FiredHistory[path] = true
                        remotesFound = remotesFound + 1
                    end
                end
            end
            if i % 500 == 0 then task.wait() end
        end
        DoNotif(string.format("Bruteforcer: Queued %d new remotes.", remotesFound), 3)
        self.State.IsScanning = false
    end)
end
function Modules.HeuristicRemoteBruteforcer:_processQueue()
    if #self.State.TargetQueue == 0 then return end
    if not self.State.IsEnabled then return end
    local remote = table.remove(self.State.TargetQueue, 1)
    if not (remote and remote.Parent) then return end
    print("--> [Bruteforcer] Fuzzing Remote:", remote:GetFullName())
    local payloads = self:_getHeuristicPayloads(remote)
    task.spawn(function()
        for i = 1, math.min(#payloads, self.Config.MAX_CALLS_PER_REMOTE) do
            if not self.State.IsEnabled then break end
            local payload = payloads[i]
            if remote:IsA("RemoteEvent") then
                pcall(remote.FireServer, remote, unpack(payload))
            elseif remote:IsA("RemoteFunction") then
                local success, result = pcall(remote.InvokeServer, remote, unpack(payload))
                if success then
                    print("    - Invoke SUCCESS. Result:", result)
                end
            end
            task.wait(self.Config.FIRE_DELAY)
        end
    end)
end
function Modules.HeuristicRemoteBruteforcer:Enable(): ()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self:_scanAndQueue()
    self.State.Connection = self.Services.RunService.Heartbeat:Connect(function()
        self:_processQueue()
    end)
    DoNotif("Heuristic Bruteforcer: ENABLED", 2)
end
function Modules.HeuristicRemoteBruteforcer:Disable(): ()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    self.State.TargetQueue = {}
    DoNotif("Heuristic Bruteforcer: DISABLED. Queue cleared.", 2)
end
function Modules.HeuristicRemoteBruteforcer:Initialize(): ()
    RegisterCommand({
        Name = "bruteforce",
        Aliases = {},
        Description = "This will more than likely kick you."
    }, function()
        if self.State.IsEnabled then self:Disable() else self:Enable() end
    end)
    RegisterCommand({
        Name = "clearfiredhistory",
        Description = "Clears the history of fired remotes, allowing a new scan."
    }, function()
        self.State.FiredHistory = {}
        DoNotif("Bruteforcer history cleared. You can now scan again.", 2)
    end)
end
Modules.Strengthen = {
State = {
Enabled = false,
Density = 1000,
OriginalProperties = {},
},
}
function Modules.Strengthen:ApplyToCharacter(character)
    table.clear(self.State.OriginalProperties)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            self.State.OriginalProperties[part] = part.CustomPhysicalProperties
            part.CustomPhysicalProperties = PhysicalProperties.new(self.State.Density, 0.3, 0.5)
        end
    end
end
function Modules.Strengthen:RevertForCharacter()
    local character = Players.LocalPlayer.Character
    if not character then return end
        for part, originalProperties in pairs(self.State.OriginalProperties) do
            if part and part.Parent and part:IsDescendantOf(character) then
                part.CustomPhysicalProperties = originalProperties
            end
        end
        table.clear(self.State.OriginalProperties)
    end
    function Modules.Strengthen:Initialize()
        local module = self
        RegisterCommand({
        Name = "stonewall",
        Aliases = {},
        Description = "Men began calling him Stonewall that very day, for he would not yield an inch."
        }, function(args)
        local character = Players.LocalPlayer.Character
        if not character then
            return DoNotif("Character not found.", 3)
        end
        local newDensity = tonumber(args[1])
        if newDensity and newDensity > 0 then
            module.State.Density = newDensity
            DoNotif("Strengthen density set to " .. module.State.Density, 2)
        end
        if module.State.Enabled then
            module:RevertForCharacter()
            module.State.Enabled = false
            DoNotif("Strengthen disabled. Character physics restored.", 2)
        else
        module:ApplyToCharacter(character)
        module.State.Enabled = true
        DoNotif("Strengthen enabled at density " .. module.State.Density, 2)
    end
end)
end
Modules.AntiAnchor = {
    State = {
        Enabled = false,
        TrackedParts = setmetatable({}, {__mode="k"}),
        OriginalProperties = setmetatable({}, {__mode="k"}),
        Signals = setmetatable({}, {__mode="k"}),
        CharacterConnections = {},
        FailsafeConnection = nil,
    },
    Dependencies = {"Players", "RunService"},
}
function Modules.AntiAnchor:Enforce(part)
    if not (part and part:IsA("BasePart")) then return end
    if self.State.OriginalProperties[part] == nil then
        self.State.OriginalProperties[part] = part.Anchored
    end
    self.State.TrackedParts[part] = true
    if part.Anchored then part.Anchored = false end
    if not self.State.Signals[part] then
        self.State.Signals[part] = part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if self.State.Enabled and part.Anchored then
                part.Anchored = false
            end
        end)
    end
end
function Modules.AntiAnchor:ProcessCharacter(character)
    for _, child in ipairs(character:GetDescendants()) do self:Enforce(child) end
    table.insert(self.State.CharacterConnections, character.DescendantAdded:Connect(function(child) self:Enforce(child) end))
    table.insert(self.State.CharacterConnections, character.DescendantRemoving:Connect(function(child)
        if self.State.Signals[child] then
            self.State.Signals[child]:Disconnect()
            self.State.Signals[child] = nil
        end
        self.State.TrackedParts[child] = nil
        self.State.OriginalProperties[child] = nil
    end))
end
function Modules.AntiAnchor:Enable()
    if self.State.Enabled then return end
    self.State.Enabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then self:ProcessCharacter(localPlayer.Character) end
    table.insert(self.State.CharacterConnections, localPlayer.CharacterAdded:Connect(function(char) self:ProcessCharacter(char) end))
    self.State.FailsafeConnection = self.Services.RunService.Stepped:Connect(function()
        for part in pairs(self.State.TrackedParts) do
            if part and part.Anchored then part.Anchored = false end
        end
    end)
    DoNotif("Anti-Anchor enabled.", 2)
end
function Modules.AntiAnchor:Disable()
    if not self.State.Enabled then return end
    self.State.Enabled = false
    for _, conn in ipairs(self.State.CharacterConnections) do conn:Disconnect() end
    for _, conn in pairs(self.State.Signals) do conn:Disconnect() end
    if self.State.FailsafeConnection then self.State.FailsafeConnection:Disconnect() end
    for part, originalValue in pairs(self.State.OriginalProperties) do
        if part and part.Parent then part.Anchored = originalValue end
    end
    table.clear(self.State.TrackedParts)
    table.clear(self.State.OriginalProperties)
    table.clear(self.State.Signals)
    table.clear(self.State.CharacterConnections)
    self.State.FailsafeConnection = nil
    DoNotif("Anti-Anchor disabled.", 2)
end
function Modules.AntiAnchor:Initialize()
    self.Services = {}
    for _, service in ipairs(self.Dependencies) do
        self.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "antianchor",
        Aliases = {"aanchor"},
        Description = "Toggles a robust defense against being anchored."
    }, function()
        if self.State.Enabled then
            self:Disable()
        else
            self:Enable()
        end
    end)
end
Modules.TeleportTool = {
    State = {},
    Dependencies = {"Players"},
    Services = {}
}
function Modules.TeleportTool:Create()
    local localPlayer = self.Services.Players.LocalPlayer
    if not localPlayer then
        return DoNotif("Teleport Tool creation failed: LocalPlayer not found.", 3)
    end
    if localPlayer.Backpack:FindFirstChild("Teleport Tool") or (localPlayer.Character and localPlayer.Character:FindFirstChild("Teleport Tool")) then
        return DoNotif("You already have the Teleport Tool.", 2)
    end
    local tpTool = Instance.new("Tool")
    tpTool.Name = "Teleport Tool"
    tpTool.RequiresHandle = false
    tpTool.Parent = localPlayer.Backpack
    local mouse = localPlayer:GetMouse()
    tpTool.Activated:Connect(function()
        local character = localPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return DoNotif("Could not find HumanoidRootPart to teleport.", 3)
        end
        local success, hitPosition = pcall(function() return mouse.Hit.Position end)
        if not success or not hitPosition then
            return DoNotif("No valid target position under cursor.", 2)
        end
        local newPosition = hitPosition + Vector3.new(0, 3, 0)
        hrp.CFrame = CFrame.new(newPosition) * (hrp.CFrame - hrp.CFrame.Position)
    end)
    DoNotif("Teleport Tool has been added to your backpack.", 2)
end
function Modules.TeleportTool:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "tptool",
        Aliases = {"teleporttool"},
        Description = "Gives you a tool that teleports you to your mouse cursor on click."
    }, function()
        module:Create()
    end)
end
Modules.ClickDetectorTools = {
    State = {},
    Dependencies = {"Workspace"},
    Services = {}
}
function Modules.ClickDetectorTools:Initialize()
    self.Services.Workspace = game:GetService("Workspace")
    RegisterCommand({
        Name = "noclickdetectorlimits",
        Aliases = {"nocdlimits", "removecdlimits"},
        Description = "Removes the distance limit for all ClickDetectors in the workspace."
    }, function()
        local count = 0
        for _, v in ipairs(self.Services.Workspace:GetDescendants()) do
            if v:IsA("ClickDetector") then
                v.MaxActivationDistance = math.huge
                count = count + 1
            end
        end
        DoNotif("Removed distance limits on " .. count .. " ClickDetectors.", 2)
    end)
    RegisterCommand({
        Name = "fireclickdetectors",
        Aliases = {"fireclick"},
        Description = "Fires all ClickDetectors in the workspace, or a specific one by name."
    }, function(args)
        if not fireclickdetector then
            return DoNotif("Environment does not support 'fireclickdetector'.", 4)
        end
        local count = 0
        if args[1] then
            local name = table.concat(args, " ")
            for _, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
                if descendant:IsA("ClickDetector") and (descendant.Name == name or descendant.Parent.Name == name) then
                    fireclickdetector(descendant)
                    count = count + 1
                end
            end
        else
            for _, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
                if descendant:IsA("ClickDetector") then
                    fireclickdetector(descendant)
                    count = count + 1
                end
            end
        end
        DoNotif("Fired " .. count .. " ClickDetector(s).", 2)
    end)
end
Modules.ProximityPromptTools = {
    State = {
        InstantPromptConnection = nil
    },
    Dependencies = {"Workspace", "ProximityPromptService"},
    Services = {}
}
function Modules.ProximityPromptTools:DisableInstantPrompts()
    if self.State.InstantPromptConnection then
        self.State.InstantPromptConnection:Disconnect()
        self.State.InstantPromptConnection = nil
        DoNotif("Instant Proximity Prompts: DISABLED", 2)
    end
end
function Modules.ProximityPromptTools:EnableInstantPrompts()
    if not fireproximityprompt then
        return DoNotif("Environment does not support 'fireproximityprompt'.", 4)
    end
    self:DisableInstantPrompts()
    self.State.InstantPromptConnection = self.Services.ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        fireproximityprompt(prompt)
    end)
    DoNotif("Instant Proximity Prompts: ENABLED", 2)
end
function Modules.ProximityPromptTools:Initialize()
    for _, serviceName in ipairs(self.Dependencies) do
        self.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "removepplimits",
        Aliases = {},
        Description = "Removes the distance limit for all ProximityPrompts."
    }, function()
        local count = 0
        for _, v in pairs(self.Services.Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.MaxActivationDistance = math.huge
                count = count + 1
            end
        end
        DoNotif("Removed distance limits on " .. count .. " ProximityPrompts.", 2)
    end)
    RegisterCommand({
        Name = "fireproximityprompts",
        Aliases = {"firepp"},
        Description = "Fires all ProximityPrompts, or a specific one by name."
    }, function(args)
        if not fireproximityprompt then
            return DoNotif("Environment does not support 'fireproximityprompt'.", 4)
        end
        local count = 0
        if args[1] then
            local name = table.concat(args, " ")
            for _, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and (descendant.Name == name or descendant.Parent.Name == name) then
                    fireproximityprompt(descendant)
                    count = count + 1
                end
            end
        else
            for _, descendant in ipairs(self.Services.Workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    fireproximityprompt(descendant)
                    count = count + 1
                end
            end
        end
        DoNotif("Fired " .. count .. " ProximityPrompt(s).", 2)
    end)
    RegisterCommand({
        Name = "instantproximityprompts",
        Aliases = {"instantpp"},
        Description = "Toggles instant triggering of proximity prompts."
    }, function()
        if self.State.InstantPromptConnection then
            self:DisableInstantPrompts()
        else
            self:EnableInstantPrompts()
        end
    end)
    RegisterCommand({
        Name = "uninstantproximityprompts",
        Aliases = {"uninstantpp"},
        Description = "Explicitly disables instant proximity prompts."
    }, function()
        self:DisableInstantPrompts()
    end)
end
Modules.RevealInvisible = {
    State = {
        Connection = nil,
        OriginalTransparency = setmetatable({}, {__mode="k"}),
    },
    Dependencies = {"RunService", "Workspace"},
}
function Modules.RevealInvisible:Disable()
    if not self.State.Connection then return end
    self.State.Connection:Disconnect()
    self.State.Connection = nil
    for part, originalValue in pairs(self.State.OriginalTransparency) do
        if part and part.Parent then
            part.Transparency = originalValue
        end
    end
    table.clear(self.State.OriginalTransparency)
    DoNotif("Invisible parts have been hidden again.", 2)
end
function Modules.RevealInvisible:Enable()
    self:Disable()
    local partsRevealed = 0
    for _, part in ipairs(self.Services.Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency > 0.95 then
            if self.State.OriginalTransparency[part] == nil then
                self.State.OriginalTransparency[part] = part.Transparency
                part.Transparency = 0.5
                partsRevealed = partsRevealed + 1
            end
        end
    end
    DoNotif("Initial scan revealed " .. partsRevealed .. " invisible parts.", 2)
    self.State.Connection = self.Services.RunService.RenderStepped:Connect(function()
        for _, part in ipairs(self.Services.Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency > 0.95 and not self.State.OriginalTransparency[part] then
                self.State.OriginalTransparency[part] = part.Transparency
                part.Transparency = 0.5
            end
        end
    end)
end
function Modules.RevealInvisible:Initialize()
    self.Services = {}
    for _, service in ipairs(self.Dependencies) do
        self.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "invisibleparts",
        Aliases = {"invisparts", "showinvisible"},
        Description = "Toggles the visibility of all invisible parts in the workspace."
    }, function()
        if self.State.Connection then
            self:Disable()
        else
            self:Enable()
        end
    end)
end
Modules.GripEditor = {
    State = {
        UI = {},
        GripConnection = nil
    },
    Dependencies = {"Players", "CoreGui", "UserInputService"},
    Services = {}
}
function Modules.GripEditor:_makeDraggable(guiObject, dragHandle)
    local isDragging = false
    local dragStart, startPosition
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPosition = guiObject.Position
            local inputEndedConn
            inputEndedConn = self.Services.UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    isDragging = false
                    inputEndedConn:Disconnect()
                end
            end)
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end
function Modules.GripEditor:_applyGrip()
    local localPlayer = self.Services.Players.LocalPlayer
    local char = localPlayer.Character
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not (tool and backpack) then
        return DoNotif("You must be holding a tool to edit its grip.", 3)
    end
    if self.State.GripConnection then
        self.State.GripConnection:Disconnect()
        self.State.GripConnection = nil
    end
    local function getVal(name)
        return tonumber(self.State.UI.TextBoxes[name].Text) or 0
    end
    local pos = Vector3.new(getVal("X"), getVal("Y"), getVal("Z"))
    local rot = Vector3.new(getVal("RX"), getVal("RY"), getVal("RZ"))
    local gripCFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
    tool.Parent = backpack
    task.wait()
    tool.Grip = gripCFrame
    tool.Parent = char
    self.State.GripConnection = tool.Changed:Connect(function(property)
        if property == "Grip" and tool.Grip ~= gripCFrame then
            tool.Grip = gripCFrame
        end
    end)
end
function Modules.GripEditor:CreateUI()
    if self.State.UI.ScreenGui then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GripEditorUI_Module"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self.Services.CoreGui
    self.State.UI.ScreenGui = screenGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 270)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    titleBar.Parent = frame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Grip Position Editor"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = titleBar
    local labels = {"X", "Y", "Z", "RX", "RY", "RZ"}
    self.State.UI.TextBoxes = {}
    for i, label in ipairs(labels) do
        local xOffset = ((i - 1) % 3) * 100
        local yOffset = 40 + math.floor((i - 1) / 3) * 50
        local labelUI = Instance.new("TextLabel", frame)
        labelUI.Size = UDim2.fromOffset(40, 25)
        labelUI.Position = UDim2.fromOffset(10 + xOffset, yOffset)
        labelUI.BackgroundTransparency = 1
        labelUI.Text = label
        labelUI.TextColor3 = Color3.fromRGB(255, 255, 255)
        labelUI.Font = Enum.Font.Gotham
        labelUI.TextSize = 14
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.fromOffset(50, 25)
        box.Position = UDim2.fromOffset(50 + xOffset, yOffset)
        box.PlaceholderText = "0"
        box.Text = ""
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.ClearTextOnFocus = false
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        self.State.UI.TextBoxes[label] = box
    end
    local previewBtn = Instance.new("TextButton", frame)
    previewBtn.Size = UDim2.fromOffset(280, 28)
    previewBtn.Position = UDim2.fromOffset(20, 150)
    previewBtn.Text = "Preview Changes"
    previewBtn.Font = Enum.Font.GothamBold
    previewBtn.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
    previewBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", previewBtn).CornerRadius = UDim.new(0, 4)
    local applyBtn = Instance.new("TextButton", frame)
    applyBtn.Size = UDim2.fromOffset(135, 32)
    applyBtn.Position = UDim2.fromOffset(20, 200)
    applyBtn.Text = "Apply & Close"
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    applyBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 4)
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.fromOffset(135, 32)
    closeBtn.Position = UDim2.fromOffset(165, 200)
    closeBtn.Text = "Close"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    previewBtn.MouseButton1Click:Connect(function() self:_applyGrip() end)
    applyBtn.MouseButton1Click:Connect(function() self:_applyGrip(); self:DestroyUI() end)
    closeBtn.MouseButton1Click:Connect(function() self:DestroyUI() end)
    self:_makeDraggable(frame, titleBar)
    DoNotif("Grip Editor opened.", 2)
end
function Modules.GripEditor:DestroyUI()
    if self.State.UI.ScreenGui then
        self.State.UI.ScreenGui:Destroy()
    end
    if self.State.GripConnection then
        self.State.GripConnection:Disconnect()
    end
    self.State = { UI = {} }
    DoNotif("Grip Editor closed.", 2)
end
function Modules.GripEditor:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "grippos",
        Aliases = {"setgrip", "gripeditor"},
        Description = "Toggles a UI to manually edit your tool's grip CFrame."
    }, function()
        if module.State.UI.ScreenGui then
            module:DestroyUI()
        else
            module:CreateUI()
        end
    end)
end
Modules.AnimationBuilder = {
    State = {
        UI = nil,
        OriginalAnimations = nil
    },
    Dependencies = {"Players", "CoreGui", "TweenService", "UserInputService"},
    Services = {}
}
function Modules.AnimationBuilder:_makeDraggable(guiObject, dragHandle)
    local isDragging = false
    local dragStart, startPosition
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPosition = guiObject.Position
            local inputEndedConn
            inputEndedConn = self.Services.UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    isDragging = false
                    inputEndedConn:Disconnect()
                end
            end)
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end
function Modules.AnimationBuilder:DestroyUI()
    if not self.State.UI then return end
    local mainFrame = self.State.UI.main
    local tween = self.Services.TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Size = UDim2.fromScale(0.01, 0.01),
        Position = UDim2.new(0.99, 0, 0.01, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Wait()
    self.State.UI.screenGui:Destroy()
    self.State.UI = nil
    DoNotif("Animation Builder closed.", 2)
end
function Modules.AnimationBuilder:CreateUI()
    if self.State.UI then return end
    local localPlayer = self.Services.Players.LocalPlayer
    local char = localPlayer.Character
    local animateScript = char and char:FindFirstChild("Animate")
    if not animateScript then
        return DoNotif("Could not find 'Animate' script in character.", 4)
    end
    if not self.State.OriginalAnimations then
        self.State.OriginalAnimations = {}
        for _, valueObject in ipairs(animateScript:GetChildren()) do
            if valueObject:IsA("StringValue") then
                local anim = valueObject:FindFirstChildOfClass("Animation")
                if anim then
                    self.State.OriginalAnimations[valueObject.Name:lower()] = anim.AnimationId
                end
            end
        end
    end
    self.State.UI = {}
    local ui = self.State.UI
    ui.screenGui = Instance.new("ScreenGui")
    ui.screenGui.Name = "AnimationBuilder_Module"
    ui.screenGui.ResetOnSpawn = false
    ui.screenGui.Parent = self.Services.CoreGui
    ui.main = Instance.new("Frame", ui.screenGui)
    ui.main.Size = UDim2.new(0, 400, 0, 450)
    ui.main.Position = UDim2.fromScale(0.5, 0.5)
    ui.main.AnchorPoint = Vector2.new(0.5, 0.5)
    ui.main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    ui.main.BorderSizePixel = 0
    Instance.new("UICorner", ui.main).CornerRadius = UDim.new(0, 8)
    local header = Instance.new("Frame", ui.main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.fromOffset(15, 0)
    title.BackgroundTransparency = 1
    title.Text = "Animation Builder"
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.fromOffset(40, 40)
    closeBtn.Position = UDim2.new(1, 0, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    local scroll = Instance.new("ScrollingFrame", ui.main)
    scroll.Size = UDim2.new(1, 0, 1, -100)
    scroll.Position = UDim2.fromOffset(0, 40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    local footer = Instance.new("Frame", ui.main)
    footer.Size = UDim2.new(1, 0, 0, 60)
    footer.Position = UDim2.new(0, 0, 1, -60)
    footer.BackgroundTransparency = 1
    local saveBtn = Instance.new("TextButton", footer)
    saveBtn.Size = UDim2.new(0.5, -15, 0.7, 0)
    saveBtn.Position = UDim2.fromOffset(10, 10)
    saveBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 80)
    saveBtn.Text = "💾 Save"
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.Font = Enum.Font.GothamSemibold
    saveBtn.TextSize = 16
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    local revertBtn = saveBtn:Clone()
    revertBtn.Position = UDim2.new(0.5, 5, 0, 10)
    revertBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
    revertBtn.Text = "↩️ Revert"
    revertBtn.Parent = footer
    ui.inputs = {}
    local states = {"Idle", "Walk", "Run", "Jump", "Fall", "Climb", "Sit"}
    for _, name in ipairs(states) do
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.25, 0, 1, 0)
        label.Position = UDim2.fromOffset(10, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextSize = 15
        local box = Instance.new("TextBox", row)
        box.Size = UDim2.new(0.75, -20, 0.8, 0)
        box.Position = UDim2.new(0.25, 0, 0.5, 0)
        box.AnchorPoint = Vector2.new(0, 0.5)
        box.PlaceholderText = "rbxassetid://"
        box.ClearTextOnFocus = false
        box.TextColor3 = Color3.new(1,1,1)
        box.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        box.Font = Enum.Font.Code
        box.TextSize = 14
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        ui.inputs[name:lower()] = box
    end
    local function applyAnims(mode)
        local currentAnimate = localPlayer.Character and localPlayer.Character:FindFirstChild("Animate")
        if not currentAnimate then return DoNotif("Animate script not found.", 3) end
        for stateName, animId in pairs(mode == "save" and ui.inputs or self.State.OriginalAnimations) do
            local valueObj = currentAnimate:FindFirstChild(stateName, true)
            if valueObj then
                local anim = valueObj:FindFirstChildOfClass("Animation")
                if anim then
                    if mode == "save" then
                        local text = animId.Text
                        if tonumber(text) then
                            anim.AnimationId = "rbxassetid://" .. text
                        end
                    else
                        anim.AnimationId = animId
                        local num = animId:match("%d+")
                        if num and ui.inputs[stateName] then
                            ui.inputs[stateName].Text = num
                        end
                    end
                end
            end
        end
        DoNotif(mode == "save" and "Animations saved." or "Animations reverted.", 2)
    end
    for stateName, textBox in pairs(ui.inputs) do
        local originalId = self.State.OriginalAnimations[stateName]
        if originalId then
            local num = originalId:match("%d+")
            if num then textBox.Text = num end
        end
    end
    closeBtn.MouseButton1Click:Connect(function() self:DestroyUI() end)
    saveBtn.MouseButton1Click:Connect(function() applyAnims("save") end)
    revertBtn.MouseButton1Click:Connect(function() applyAnims("revert") end)
    self:_makeDraggable(ui.main, header)
    DoNotif("Animation Builder opened.", 2)
end
function Modules.AnimationBuilder:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "animbuilder",
        Aliases = {"abuilder"},
        Description = "Toggles a UI to edit your character's default animations."
    }, function()
        if module.State.UI then
            module:DestroyUI()
        else
            module:CreateUI()
        end
    end)
end
Modules.CharacterMorph = {
    State = {
        IsMorphed = false,
        OriginalDescription = nil,
        CharacterAddedConnection = nil
    },
    Dependencies = {"Players"},
    Services = {}
}
function Modules.CharacterMorph:_resolveDescription(target: string)
    local targetId = tonumber(target)
    if not targetId then
        local success, idFromName = pcall(function()
            return self.Services.Players:GetUserIdFromNameAsync(target)
        end)
        if not success or not idFromName then
            DoNotif("Could not find a user with the name: " .. tostring(target), 3)
            return nil
        end
        targetId = idFromName
    end
    DoNotif("Loading avatar for UserId: " .. targetId, 1.5)
    local success, description = pcall(function()
        return self.Services.Players:GetHumanoidDescriptionFromUserId(targetId)
    end)
    if not success or not description then
        DoNotif("Unable to load avatar description for that user.", 3)
        return nil
    end
    return description
end
function Modules.CharacterMorph:_applyAndRespawn(description: HumanoidDescription)
    local localPlayer = self.Services.Players.LocalPlayer
    if not description then return end
    if self.State.CharacterAddedConnection then
        self.State.CharacterAddedConnection:Disconnect()
        self.State.CharacterAddedConnection = nil
    end
    self.State.CharacterAddedConnection = localPlayer.CharacterAdded:Once(function(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            pcall(humanoid.ApplyDescription, humanoid, description)
        end
    end)
    localPlayer:LoadCharacter()
end
function Modules.CharacterMorph:Morph(target: string)
    if not target then
        return DoNotif("Usage: ;avatar <username/userid>", 3)
    end
    if not self.State.OriginalDescription then
        local success, originalDesc = pcall(function()
            return self.Services.Players:GetHumanoidDescriptionFromUserId(self.Services.Players.LocalPlayer.UserId)
        end)
        if success then
            self.State.OriginalDescription = originalDesc
        else
            warn("[CharacterMorph] Could not cache original character description.")
        end
    end
    task.spawn(function()
        local newDescription = self:_resolveDescription(target)
        if newDescription then
            self.State.IsMorphed = true
            self:_applyAndRespawn(newDescription)
            DoNotif("Applying character morph...", 2)
        end
    end)
end
function Modules.CharacterMorph:Revert()
    if not self.State.IsMorphed then
        return DoNotif("You are not currently morphed.", 2)
    end
    if not self.State.OriginalDescription then
        return DoNotif("Failed to revert: Original avatar description is missing.", 4)
    end
    self:_applyAndRespawn(self.State.OriginalDescription)
    self.State.IsMorphed = false
    DoNotif("Reverting to original character...", 2)
end
function Modules.CharacterMorph:Initialize()
    local module = self
    for _, service in ipairs(self.Dependencies) do
        module.Services[service] = game:GetService(service)
    end
    RegisterCommand({
        Name = "swapinto",
        Aliases = {"morph"},
        Description = "Change your character's appearance to someone else's."
    }, function(args)
        module:Morph(args[1])
    end)
    RegisterCommand({
        Name = "default",
        Aliases = {},
        Description = "Reverts your character's appearance to your own."
    }, function()
        module:Revert()
    end)
end
Modules.Chams = {
    State = {
        IsEnabled = false,
        TrackedCharacters = setmetatable({}, {__mode = "k"}),
        OriginalProperties = setmetatable({}, {__mode = "k"}),
        Connections = {}
    },
    Config = {
        VisibleColor = Color3.fromRGB(0, 255, 0),
        OccludedColor = Color3.fromRGB(255, 0, 0),
        Material = Enum.Material.Neon,
        HighlightTransparency = 0
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService")
    }
}
function Modules.Chams:_apply(character)
    if not character or self.State.TrackedCharacters[character] then return end
    local highlight = Instance.new("Highlight", character)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = self.Config.OccludedColor
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = self.Config.HighlightTransparency
    local innerHighlight = Instance.new("Highlight", character)
    innerHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    innerHighlight.FillColor = self.Config.VisibleColor
    innerHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    innerHighlight.FillTransparency = self.Config.HighlightTransparency
    self.State.TrackedCharacters[character] = {highlight, innerHighlight}
end
function Modules.Chams:_revert(character)
    if not character or not self.State.TrackedCharacters[character] then return end
    for _, effect in ipairs(self.State.TrackedCharacters[character]) do
        pcall(function() effect:Destroy() end)
    end
    self.State.TrackedCharacters[character] = nil
end
function Modules.Chams:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local function setupPlayer(player)
        if player == self.Services.Players.LocalPlayer then return end
        if player.Character then
            self:_apply(player.Character)
        end
        self.State.Connections[player] = {}
        self.State.Connections[player].CharacterAdded = player.CharacterAdded:Connect(function(char) self:_apply(char) end)
        self.State.Connections[player].CharacterRemoving = player.CharacterRemoving:Connect(function(char) self:_revert(char) end)
    end
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        setupPlayer(player)
    end
    self.State.Connections.PlayerAdded = self.Services.Players.PlayerAdded:Connect(setupPlayer)
    self.State.Connections.PlayerRemoving = self.Services.Players.PlayerRemoving:Connect(function(player)
        if self.State.Connections[player] then
            for _, conn in pairs(self.State.Connections[player]) do
                conn:Disconnect()
            end
            self.State.Connections[player] = nil
        end
    end)
    DoNotif("Chams: ENABLED", 2)
end
function Modules.Chams:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for player, conns in pairs(self.State.Connections) do
        if type(conns) == "table" then
            for _, conn in pairs(conns) do
                conn:Disconnect()
            end
        else
            conns:Disconnect()
        end
    end
    table.clear(self.State.Connections)
    for character, _ in pairs(self.State.TrackedCharacters) do
        self:_revert(character)
    end
    DoNotif("Chams: DISABLED", 2)
end
RegisterCommand({
    Name = "chams",
    Aliases = {},
    Description = "Toggles a solid color ESP on all other players."
}, function()
    if Modules.Chams.State.IsEnabled then
        Modules.Chams:Disable()
    else
        Modules.Chams:Enable()
    end
end)
Modules.InfiniteJump = {
    State = {
        IsEnabled = false,
        Connection = nil
    },
    Services = {
        Players = game:GetService("Players"),
        UserInputService = game:GetService("UserInputService")
    }
}
function Modules.InfiniteJump:OnInput(input, gameProcessed)
    if gameProcessed or not self.State.IsEnabled then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        local character = self.Services.Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function Modules.InfiniteJump:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.Connection = self.Services.UserInputService.JumpRequest:Connect(function()
        self:OnInput({UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.Space}, false)
    end)
    DoNotif("Infinite Jump: ENABLED", 2)
end
function Modules.InfiniteJump:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    DoNotif("Infinite Jump: DISABLED", 2)
end
RegisterCommand({
    Name = "infjump",
    Aliases = {"infinitejump"},
    Description = "Toggles the ability to jump infinitely in the air."
}, function()
    if Modules.InfiniteJump.State.IsEnabled then
        Modules.InfiniteJump:Disable()
    else
        Modules.InfiniteJump:Enable()
    end
end)
Modules.ScriptView = {
    State = {
        IsEnabled = false,
        UI = nil,
        Syntax = true,
        CurrentSource = "",
        CurrentName = "",
        Open = false,
        OtherDone = 1
    },
    Config = {
        Operators = {
            ['bracket'] = Color3.fromRGB(204, 104, 147),
            ['math']    = Color3.fromRGB(204, 104, 147),
            ['compare'] = Color3.fromRGB(204, 104, 147),
            ['misc']    = Color3.fromRGB(204, 104, 147),
        },
        Textures = {
            ['folder']       = "2950788693",
            ['localscript']  = "99340858",
            ['modulescript'] = "413367412",
            ['function']     = "2759601950",
            ['variable']     = "2759602224",
            ['table']        = "2757039628",
            ['constant']     = "2717878542",
            ['upvalue']      = "2717876089",
        }
    }
}
function Modules.ScriptView:Initialize()
    local module = self
    local state = self.State
    local config = self.Config
    RegisterCommand({
        Name = "scriptview",
        Aliases = {"sv", "forensics", "decompile"},
        Description = "Opens ScriptView (Home/RShift). Decompile scripts and explore memory."
    }, function()
        if state.UI then
            state.Open = not state.Open
            if state.Open then module:Open() else module:Close() end
            return
        end
        local success, err = pcall(function()
            local screenGui = game:GetObjects("rbxassetid://2971927607")[1]
            local backdrop = screenGui.Backdrop
            local lexer_mod = game:GetObjects('rbxassetid://2798231692')[1]
            local lexer = loadstring(lexer_mod.Source)()
            screenGui.Parent = CoreGui
            state.UI = screenGui
            local scriptList = backdrop.Debugger.Scripts
            local sourceFrame = backdrop.ScriptFrame.Source
            local debugTemplate = scriptList.Template; debugTemplate.Parent = nil
            local lineTemplate = sourceFrame.Line; lineTemplate.Parent = nil
            local wordTemplate = lineTemplate.Word; wordTemplate.Parent = nil
            local tabsFrame = backdrop.Tabs
            local tabTemplate = tabsFrame.Deselected; tabTemplate.Parent = nil
            local ttemp = tabsFrame.Selected; ttemp.Parent = nil
            local function GVT(v, def)
                return (type(v) == "function" and "function") or (type(v) == "table" and "table") or def or "variable"
            end
            local function getEnv(scr)
                local g_env = getsenv or getmenv
                if not g_env then return {ERROR = "No env access"} end
                return (scr:IsA("LocalScript") and (getsenv and getsenv(scr))) or (getmenv and getmenv(scr))
            end
            local function Tween(Obj, Dir, Style, Duration, Goal)
                local tween = game:GetService("TweenService"):Create(Obj, TweenInfo.new(Duration, Enum.EasingStyle[Style], Enum.EasingDirection[Dir]), Goal)
                tween:Play()
                return tween
            end
            local function loadSource(source)
                state.CurrentSource = source
                for _, v in pairs(sourceFrame:GetChildren()) do
                    if v.Name == "Line" then v:Destroy() end
                end
                local lines = {}
                local tblLine = {}
                for typ, word in lexer.scan(source) do
                    if word:find("\n") then
                        word = word:gsub("\n", "")
                        if word == "" then word = " " end
                        table.insert(tblLine, {typ, word})
                        table.insert(lines, tblLine)
                        tblLine = {}
                    else
                        table.insert(tblLine, {typ, word})
                    end
                end
                table.insert(lines, tblLine)
                for num, lineTable in ipairs(lines) do
                    local line = lineTemplate:Clone()
                    line.LineNumber.Text = tostring(num).."  "
                    line.Parent = sourceFrame
                    for _, wordData in ipairs(lineTable) do
                        local word = wordTemplate:Clone()
                        word.Parent = line
                        word.String.Text = wordData[2]
                        local txtSize = game:GetService("TextService"):GetTextSize(word.String.Text, word.String.TextSize, word.String.Font, Vector2.new(10000, 25))
                        word.String.Size = UDim2.new(0, txtSize.X, 1, 0)
                        word.Size = word.String.Size
                        if state.Syntax then
                        end
                    end
                end
            end
            local function createButton(parent, info)
                local button = debugTemplate:Clone()
                local par = (parent:FindFirstChild("Contents")) or parent
                button.Label.Text = info.Name
                button.Icon.Image = "rbxassetid://" .. (config.Textures[info.Type:lower()] or config.Textures.variable)
                button.Parent = par
                button.Clicked.MouseButton1Click:Connect(function()
                    if info.Type:lower():find("script") then
                        local success, src = pcall(decompile, info.Obj)
                        loadSource(success and src or "-- Decompilation Failed")
                    end
                end)
                button.Expand.MouseButton1Click:Connect(function()
                    button.Contents.Visible = not button.Contents.Visible
                    if button.Contents.Visible then
                        for _, child in ipairs(info.Obj:GetChildren()) do
                            createButton(button, {Name = child.Name, Type = child.ClassName, Obj = child})
                        end
                    end
                end)
            end
            createButton(scriptList, {Name="Active Scripts", Type="Folder", Obj=game})
            createButton(scriptList, {Name="LocalPlayer", Type="Folder", Obj=game:GetService("Players").LocalPlayer})
            createButton(scriptList, {Name="Nil", Type="Folder", Obj=nil})
            module.Open = function()
                Tween(backdrop, "Out", "Sine", 0.2, {
                    Position = UDim2.new(0.5, -400, 0.5, -250),
                    Size = UDim2.new(0, 800, 0, 500)
                })
                state.Open = true
            end
            module.Close = function()
                Tween(backdrop, "Out", "Sine", 0.2, {
                    Position = UDim2.new(0.5, 0, 1, 2),
                    Size = UDim2.new(0.25, 0, 0.25, 0)
                })
                state.Open = false
            end
            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Home or input.KeyCode == Enum.KeyCode.RightShift then
                    state.Open = not state.Open
                    if state.Open then module.Open() else module.Close() end
                end
            end)
            DoNotif("ScriptView forensic module enabled.", 3)
        end)
        if not success then
            warn("--> [FORENSIC]: ScriptView Failed to Load Assets: " .. tostring(err))
            DoNotif("ScriptView failed: Assets unavailable.", 5)
        end
    end)
end
Modules.Gravity = {
    State = {
        IsEnabled = false,
        OriginalGravity = nil
    },
    Services = {
        Workspace = game:GetService("Workspace")
    }
}
function Modules.Gravity:Enable(newGravityValue)
    if not self.State.IsEnabled then
        self.State.OriginalGravity = self.Services.Workspace.Gravity
    end
    self.State.IsEnabled = true
    local newGravity = tonumber(newGravityValue)
    if not newGravity or newGravity <= 0 then
        newGravity = 75
        DoNotif("No gravity value provided. Defaulting to " .. newGravity, 2)
    end
    self.Services.Workspace.Gravity = newGravity
    DoNotif("Client gravity set to: " .. newGravity, 2)
end
function Modules.Gravity:Disable()
    if not self.State.IsEnabled then return end
    if self.State.OriginalGravity then
        self.Services.Workspace.Gravity = self.State.OriginalGravity
    end
    self.State.IsEnabled = false
    self.State.OriginalGravity = nil
    DoNotif("Client gravity restored to default.", 2)
end
RegisterCommand({
    Name = "gravity",
    Aliases = {"grav"},
    Description = "Sets the client-sided workspace gravity. Use 'reset' to disable."
}, function(args)
    local argument = args[1]
    if argument and (argument:lower() == "reset" or argument:lower() == "off") then
        Modules.Gravity:Disable()
    else
        Modules.Gravity:Enable(argument)
    end
end)
Modules.FixCamera = {
    State = {
        Enabled = false,
        Connection = nil,
        OriginalMaxZoom = nil,
        OriginalOcclusionMode = nil,
    }
}
RegisterCommand({
    Name = "fixcam",
    Aliases = {"unlockcam"},
    Description = "Unlocks camera, allows zooming through walls, and forces third-person."
}, function(args)
    if not LocalPlayer then return end
    local self = Modules.FixCamera
    self.State.Enabled = not self.State.Enabled
    if self.State.Enabled then
        self.State.OriginalMaxZoom = LocalPlayer.CameraMaxZoomDistance
        self.State.OriginalOcclusionMode = LocalPlayer.DevCameraOcclusionMode
        LocalPlayer.CameraMaxZoomDistance = 10000
        local success, err = pcall(function()
            LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.None
        end)
        if not success then
            warn("FixCamera: Failed to set DevCameraOcclusionMode via Enum. Falling back to 0. Error:", err)
            LocalPlayer.DevCameraOcclusionMode = 0
        end
        self.State.Connection = RunService.RenderStepped:Connect(function()
            if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
            end
        end)
        DoNotif("Camera override enabled (with wall-zoom).", 3)
    else
        if self.State.Connection and self.State.Connection.Connected then
            self.State.Connection:Disconnect()
            self.State.Connection = nil
        end
        pcall(function()
            if self.State.OriginalOcclusionMode ~= nil then
                LocalPlayer.DevCameraOcclusionMode = self.State.OriginalOcclusionMode
            end
            if self.State.OriginalMaxZoom ~= nil then
                LocalPlayer.CameraMaxZoomDistance = self.State.OriginalMaxZoom
            end
        end)
        self.State.OriginalOcclusionMode = nil
        self.State.OriginalMaxZoom = nil
        DoNotif("Camera override disabled.", 3)
    end
end)
Modules.NoFog = {
    State = {
        IsEnabled = false,
        OriginalProperties = {}
    },
    Services = {
        Lighting = game:GetService("Lighting")
    }
}
function Modules.NoFog:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.OriginalProperties.FogEnd = self.Services.Lighting.FogEnd
    self.State.OriginalProperties.FogStart = self.Services.Lighting.FogStart
    local atmosphere = self.Services.Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        self.State.OriginalProperties.AtmosphereEnabled = atmosphere.Enabled
        atmosphere.Enabled = false
    end
    self.Services.Lighting.FogEnd = 1000000
    self.Services.Lighting.FogStart = 0
    DoNotif("No Fog: ENABLED.", 2)
end
function Modules.NoFog:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.OriginalProperties.FogEnd then
        self.Services.Lighting.FogEnd = self.State.OriginalProperties.FogEnd
    end
    if self.State.OriginalProperties.FogStart then
        self.Services.Lighting.FogStart = self.State.OriginalProperties.FogStart
    end
    local atmosphere = self.Services.Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere and self.State.OriginalProperties.AtmosphereEnabled ~= nil then
        atmosphere.Enabled = self.State.OriginalProperties.AtmosphereEnabled
    end
    self.State.OriginalProperties = {}
    DoNotif("No Fog: DISABLED.", 2)
end
function Modules.NoFog:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({
    Name = "nofog",
    Aliases = {"removefog", "antifog"},
    Description = "Toggles client-sided fog."
}, function()
    Modules.NoFog:Toggle()
end)
Modules.Waypoint = {
    State = {
        Waypoints = {},
        Visuals = {}
    },
    Services = {
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        CoreGui = game:GetService("CoreGui")
    }
}
function Modules.Waypoint:_cleanupVisual(name)
    local visual = self.State.Visuals[name:lower()]
    if visual then
        pcall(function()
            visual:Destroy()
        end)
        self.State.Visuals[name:lower()] = nil
    end
end
function Modules.Waypoint:_createVisual(name, cframe)
    self:_cleanupVisual(name)
    local container = Instance.new("Part")
    container.Name = "WaypointVisual_" .. name
    container.Size = Vector3.new(0.1, 0.1, 0.1)
    container.CFrame = cframe
    container.Anchored = true
    container.CanCollide = false
    container.Transparency = 1
    container.Parent = self.Services.Workspace
    local billboard = Instance.new("BillboardGui", container)
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(200, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Text = name
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextSize = 24
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    local attachment1 = Instance.new("Attachment", container)
    local attachment2 = Instance.new("Attachment", container)
    attachment2.Position = Vector3.new(0, 1000, 0)
    local beam = Instance.new("Beam", container)
    beam.Attachment0 = attachment1
    beam.Attachment1 = attachment2
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.Width0 = 2
    beam.Width1 = 0
    beam.Transparency = NumberSequence.new(0.25)
    self.State.Visuals[name:lower()] = container
end
function Modules.Waypoint:Add(name)
    if not name or name == "" then
        return DoNotif("You must provide a name for the waypoint.", 3)
    end
    local character = self.Services.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return DoNotif("Cannot set waypoint: Character not found.", 3)
    end
    local key = name:lower()
    self.State.Waypoints[key] = hrp.CFrame
    self:_createVisual(name, hrp.CFrame)
    DoNotif("Waypoint '" .. name .. "' created at your position.", 2)
end
function Modules.Waypoint:Remove(name)
    if not name or name == "" then
        return DoNotif("You must provide a name to remove.", 3)
    end
    local key = name:lower()
    if not self.State.Waypoints[key] then
        return DoNotif("Waypoint '" .. name .. "' does not exist.", 3)
    end
    self.State.Waypoints[key] = nil
    self:_cleanupVisual(name)
    DoNotif("Waypoint '" .. name .. "' removed.", 2)
end
function Modules.Waypoint:Teleport(name)
    if not name or name == "" then
        return DoNotif("You must provide a name to teleport to.", 3)
    end
    local key = name:lower()
    local targetCFrame = self.State.Waypoints[key]
    if not targetCFrame then
        return DoNotif("Waypoint '" .. name .. "' does not exist.", 3)
    end
    local character = self.Services.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return DoNotif("Cannot teleport: Character not found.", 3)
    end
    hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    DoNotif("Teleported to '" .. name .. "'.", 2)
end
function Modules.Waypoint:List()
    local waypointNames = {}
    for name in pairs(self.State.Waypoints) do
        table.insert(waypointNames, name)
    end
    if #waypointNames == 0 then
        return DoNotif("No waypoints have been set.", 3)
    end
    local message = "Waypoints: " .. table.concat(waypointNames, ", ")
    DoNotif(message, 5)
end
function Modules.Waypoint:Clear()
    for name in pairs(self.State.Waypoints) do
        self:_cleanupVisual(name)
    end
    self.State.Waypoints = {}
    DoNotif("All waypoints cleared.", 2)
end
RegisterCommand({
    Name = "waypoint",
    Aliases = {"wp"},
    Description = "Manages waypoints."
}, function(args)
    local subCommand = args[1] and args[1]:lower()
    local name = args[2]
    if subCommand == "add" then
        Modules.Waypoint:Add(name)
    elseif subCommand == "remove" or subCommand == "del" then
        Modules.Waypoint:Remove(name)
    elseif subCommand == "tp" or subCommand == "goto" then
        Modules.Waypoint:Teleport(name)
    elseif subCommand == "list" then
        Modules.Waypoint:List()
    elseif subCommand == "clear" then
        Modules.Waypoint:Clear()
    else
        DoNotif("Usage: ;wp add,remove,tp,list", 4)
    end
end)
Modules.FpsMeter = {
    State = {
        IsEnabled = false,
        UI = {},
        Connection = nil
    },
    Services = {
        RunService = game:GetService("RunService"),
        CoreGui = game:GetService("CoreGui")
    }
}
function Modules.FpsMeter:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FpsMeter_Zuka"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = self.Services.CoreGui
    self.State.UI.ScreenGui = screenGui
    local background = Instance.new("Frame", screenGui)
    background.Size = UDim2.fromOffset(140, 30)
    background.Position = UDim2.new(1, -150, 0, 10)
    background.AnchorPoint = Vector2.new(1, 0)
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    background.BackgroundTransparency = 0.3
    local corner = Instance.new("UICorner", background)
    corner.CornerRadius = UDim.new(0, 4)
    local label = Instance.new("TextLabel", background)
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextColor3 = Color3.fromRGB(0, 255, 127)
    label.TextSize = 18
    label.Text = "FPS: ..."
    self.State.UI.Label = label
    local lastUpdate = 0
    local updateInterval = 0.25
    self.State.Connection = self.Services.RunService.Heartbeat:Connect(function(deltaTime)
        local now = os.clock()
        if now - lastUpdate > updateInterval then
            local fps = 1 / deltaTime
            label.Text = string.format("FPS: %.1f", fps)
            lastUpdate = now
        end
    end)
    DoNotif("FPS Meter: ENABLED", 2)
end
function Modules.FpsMeter:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    if self.State.UI.ScreenGui then
        self.State.UI.ScreenGui:Destroy()
    end
    self.State.UI = {}
    DoNotif("FPS Meter: DISABLED", 2)
end
function Modules.FpsMeter:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({
    Name = "fpsmeter",
    Aliases = {"showfps", "fps"},
    Description = "Toggles a client-side FPS meter."
}, function()
    Modules.FpsMeter:Toggle()
end)
Modules.HitboxESP = {
    State = {
        IsEnabled = false,
        EspEnabled = false,
        HitboxSize = 15,
        IsMinimized = false,
        CurrentTheme = "dark",
        IsDragging = false,
        EspLabels = {},
        EspBoxes = {},
        Connections = {},
        UI = nil,
        LastAnimTime = 0,
        AnimCooldown = 0.15
    },
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        CoreGui = game:GetService("CoreGui")
    }
}
function Modules.HitboxESP:AnimateButton(button)
    local currentTime = tick()
    if currentTime - self.State.LastAnimTime < self.State.AnimCooldown then
        return
    end
    self.State.LastAnimTime = currentTime
    local originalSize = button.Size
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    self.Services.TweenService:Create(button, tweenInfo, {Size = originalSize + UDim2.new(0, 4, 0, 4)}):Play()
    task.wait(0.1)
    self.Services.TweenService:Create(button, tweenInfo, {Size = originalSize}):Play()
end
function Modules.HitboxESP:ApplyTheme(theme)
    self.State.CurrentTheme = theme
    local ui = self.State.UI
    if not ui then return end
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local TS = self.Services.TweenService
    if theme == "light" then
        TS:Create(ui.MainFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.ContentFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.MainStroke, tweenInfo, {Color = Color3.fromRGB(200, 200, 210)}):Play()
        TS:Create(ui.TitleBar, tweenInfo, {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
        TS:Create(ui.TitleFix, tweenInfo, {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
        TS:Create(ui.TitleLabel, tweenInfo, {TextColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.SizeLabel, tweenInfo, {TextColor3 = Color3.fromRGB(60, 60, 70)}):Play()
        TS:Create(ui.TextBox, tweenInfo, {BackgroundColor3 = Color3.fromRGB(235, 235, 245), TextColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.TextBoxStroke, tweenInfo, {Color = Color3.fromRGB(200, 200, 210)}):Play()
        TS:Create(ui.FooterLabel, tweenInfo, {TextColor3 = Color3.fromRGB(100, 100, 110)}):Play()
        TS:Create(ui.FooterLabelMinimized, tweenInfo, {TextColor3 = Color3.fromRGB(100, 100, 110)}):Play()
        TS:Create(ui.ConfirmFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.ConfirmText, tweenInfo, {TextColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.SettingsFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.SettingsTitleBar, tweenInfo, {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
        TS:Create(ui.SettingsTitleFix, tweenInfo, {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
        TS:Create(ui.SettingsTitleLabel, tweenInfo, {TextColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.ThemeLabel, tweenInfo, {TextColor3 = Color3.fromRGB(60, 60, 70)}):Play()
        TS:Create(ui.SettingsButtonTop, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 200, 220), TextColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.DarkStroke, tweenInfo, {Color = Color3.fromRGB(200, 200, 210)}):Play()
        if not ui.LightButton:FindFirstChild("UIStroke") then
            local lightStroke = Instance.new("UIStroke")
            lightStroke.Color = Color3.fromRGB(80, 150, 255)
            lightStroke.Thickness = 3
            lightStroke.Transparency = 1
            lightStroke.ZIndex = 11
            lightStroke.Parent = ui.LightButton
            TS:Create(lightStroke, tweenInfo, {Transparency = 0}):Play()
        end
    else
        TS:Create(ui.MainFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        TS:Create(ui.ContentFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        TS:Create(ui.MainStroke, tweenInfo, {Color = Color3.fromRGB(60, 60, 70)}):Play()
        TS:Create(ui.TitleBar, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.TitleFix, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.TitleLabel, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.SizeLabel, tweenInfo, {TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
        TS:Create(ui.TextBox, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 50), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.TextBoxStroke, tweenInfo, {Color = Color3.fromRGB(80, 80, 90)}):Play()
        TS:Create(ui.FooterLabel, tweenInfo, {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
        TS:Create(ui.FooterLabelMinimized, tweenInfo, {TextColor3 = Color3.fromRGB(120, 120, 130)}):Play()
        TS:Create(ui.ConfirmFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(15, 15, 20)}):Play()
        TS:Create(ui.ConfirmText, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.SettingsFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        TS:Create(ui.SettingsTitleBar, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.SettingsTitleFix, tweenInfo, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        TS:Create(ui.SettingsTitleLabel, tweenInfo, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TS:Create(ui.ThemeLabel, tweenInfo, {TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
        TS:Create(ui.SettingsButtonTop, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 120), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        if ui.LightButton:FindFirstChild("UIStroke") then
            local lightStroke = ui.LightButton:FindFirstChild("UIStroke")
            TS:Create(lightStroke, tweenInfo, {Transparency = 1}):Play()
            task.wait(0.1)
            lightStroke:Destroy()
        end
        TS:Create(ui.DarkStroke, tweenInfo, {Color = Color3.fromRGB(80, 150, 255)}):Play()
    end
end
function Modules.HitboxESP:CreateESP(targetPlayer)
    if self.State.EspLabels[targetPlayer] or self.State.EspBoxes[targetPlayer] then
        return
    end
    local char = targetPlayer.Character
    if not char then return end
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ZukaESP_" .. targetPlayer.Name
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.Parent = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    self.State.EspLabels[targetPlayer] = {gui = billboardGui, label = textLabel}
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ZukaHighlight_" .. targetPlayer.Name
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(80, 150, 255)
        highlight.OutlineColor = Color3.fromRGB(80, 150, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char
        self.State.EspBoxes[targetPlayer] = highlight
    end
end
function Modules.HitboxESP:RemoveESP(targetPlayer)
    if self.State.EspLabels[targetPlayer] then
        if self.State.EspLabels[targetPlayer].gui then
            self.State.EspLabels[targetPlayer].gui:Destroy()
        end
        self.State.EspLabels[targetPlayer] = nil
    end
    if self.State.EspBoxes[targetPlayer] then
        self.State.EspBoxes[targetPlayer]:Destroy()
        self.State.EspBoxes[targetPlayer] = nil
    end
end
function Modules.HitboxESP:UpdateESP()
    if not self.State.EspEnabled then return end
    local lp = self.Services.Players.LocalPlayer
    for _, targetPlayer in pairs(self.Services.Players:GetPlayers()) do
        if targetPlayer ~= lp and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not self.State.EspLabels[targetPlayer] then
                self:CreateESP(targetPlayer)
            end
            if self.State.EspLabels[targetPlayer] and self.State.EspLabels[targetPlayer].gui.Parent == nil then
                local head = targetPlayer.Character:FindFirstChild("Head")
                if head then
                    self.State.EspLabels[targetPlayer].gui.Parent = head
                end
            end
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and targetHrp and self.State.EspLabels[targetPlayer] then
                local distance = (hrp.Position - targetHrp.Position).Magnitude
                local studs = math.floor(distance)
                self.State.EspLabels[targetPlayer].label.Text = targetPlayer.Name .. "\n" .. studs .. " studs"
            end
        elseif self.State.EspLabels[targetPlayer] or self.State.EspBoxes[targetPlayer] then
            self:RemoveESP(targetPlayer)
        end
    end
end
function Modules.HitboxESP:UpdateHitboxes()
    if not self.State.IsEnabled then return end
    local lp = self.Services.Players.LocalPlayer
    for _, v in pairs(self.Services.Players:GetPlayers()) do
        if v ~= lp and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(self.State.HitboxSize, self.State.HitboxSize, self.State.HitboxSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end
end
function Modules.HitboxESP:Initialize()
    local module = self
    local Players = self.Services.Players
    local TS = self.Services.TweenService
    RegisterCommand({
        Name = "hitboxchanger",
        Aliases = {},
        Description = "Opens the Hitbox Changer & ESP GUI."
    }, function()
        module:CreateUI()
    end)
    self.State.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function()
            task.wait(0.1)
            module:UpdateHitboxes()
            if module.State.EspEnabled then
                module:CreateESP(newPlayer)
            end
        end)
    end)
    self.State.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(removedPlayer)
        module:RemoveESP(removedPlayer)
    end)
    self.State.Connections.Loop = self.Services.RunService.Heartbeat:Connect(function()
        module:UpdateHitboxes()
        module:UpdateESP()
    end)
end
function Modules.HitboxESP:CreateUI()
    if self.State.UI then self.State.UI.ScreenGui.Enabled = true return end
    local module = self
    local TS = self.Services.TweenService
    local UIS = self.Services.UserInputService
    local lp = self.Services.Players.LocalPlayer
    local ui = {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HitboxChanger_Zuka"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = self.Services.CoreGui
    ui.ScreenGui = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(0, 260, 0, 180)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0; mainFrame.Active = true; mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    ui.MainFrame = mainFrame
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(60, 60, 70); mainStroke.Thickness = 2; mainStroke.Transparency = 0.5
    ui.MainStroke = mainStroke
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); titleBar.BorderSizePixel = 0
    ui.TitleBar = titleBar
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    local titleFix = Instance.new("Frame", titleBar)
    titleFix.Size = UDim2.new(1, 0, 0, 12); titleFix.Position = UDim2.new(0, 0, 1, -12)
    titleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40); titleFix.BorderSizePixel = 0
    ui.TitleFix = titleFix
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -100, 1, 0); titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "Hitbox changer & esp"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ui.TitleLabel = titleLabel
    local settingsButtonTop = Instance.new("TextButton", titleBar)
    settingsButtonTop.Name = "SettingsButtonTop"; settingsButtonTop.Size = UDim2.new(0, 26, 0, 26)
    settingsButtonTop.Position = UDim2.new(1, -90, 0, 4); settingsButtonTop.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    settingsButtonTop.Text = "⚙"; settingsButtonTop.TextColor3 = Color3.new(1, 1, 1); settingsButtonTop.Font = Enum.Font.GothamBold
    Instance.new("UICorner", settingsButtonTop).CornerRadius = UDim.new(0, 6)
    ui.SettingsButtonTop = settingsButtonTop
    local minimizeButton = Instance.new("TextButton", titleBar)
    minimizeButton.Size = UDim2.new(0, 26, 0, 26); minimizeButton.Position = UDim2.new(1, -58, 0, 4)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 200, 50); minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.new(0, 0, 0); minimizeButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 6)
    local closeButton = Instance.new("TextButton", titleBar)
    closeButton.Size = UDim2.new(0, 26, 0, 26); closeButton.Position = UDim2.new(1, -28, 0, 4)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50); closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1); closeButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Name = "ContentFrame"; contentFrame.Size = UDim2.new(1, 0, 1, -35); contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); contentFrame.BorderSizePixel = 0
    ui.ContentFrame = contentFrame
    local sizeLabel = Instance.new("TextLabel", contentFrame)
    sizeLabel.Size = UDim2.new(0, 75, 0, 22); sizeLabel.Position = UDim2.new(0, 12, 0, 8)
    sizeLabel.BackgroundTransparency = 1; sizeLabel.Text = "Hitbox Size:"
    sizeLabel.TextColor3 = Color3.fromRGB(200, 200, 210); sizeLabel.TextSize = 12; sizeLabel.Font = Enum.Font.Gotham
    sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ui.SizeLabel = sizeLabel
    local textBox = Instance.new("TextBox", contentFrame)
    textBox.Size = UDim2.new(0, 80, 0, 28); textBox.Position = UDim2.new(0, 90, 0, 6)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50); textBox.Text = tostring(self.State.HitboxSize)
    textBox.PlaceholderText = "Size"; textBox.TextColor3 = Color3.new(1, 1, 1); textBox.Font = Enum.Font.Gotham
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 7)
    local textBoxStroke = Instance.new("UIStroke", textBox)
    textBoxStroke.Color = Color3.fromRGB(80, 80, 90); ui.TextBoxStroke = textBoxStroke
    ui.TextBox = textBox
    local applyButton = Instance.new("TextButton", contentFrame)
    applyButton.Size = UDim2.new(0, 50, 0, 28); applyButton.Position = UDim2.new(0, 178, 0, 6)
    applyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255); applyButton.Text = "Apply"
    applyButton.TextColor3 = Color3.new(1, 1, 1); applyButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 7)
    local toggleButton = Instance.new("TextButton", contentFrame)
    toggleButton.Size = UDim2.new(0, 236, 0, 32); toggleButton.Position = UDim2.new(0, 12, 0, 42)
    toggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50); toggleButton.Text = "Hitbox: OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1); toggleButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 7)
    local espToggleButton = Instance.new("TextButton", contentFrame)
    espToggleButton.Size = UDim2.new(0, 236, 0, 32); espToggleButton.Position = UDim2.new(0, 12, 0, 80)
    espToggleButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50); espToggleButton.Text = "ESP: OFF"
    espToggleButton.TextColor3 = Color3.new(1, 1, 1); espToggleButton.Font = Enum.Font.GothamBold
    Instance.new("UICorner", espToggleButton).CornerRadius = UDim.new(0, 7)
    local footerLabel = Instance.new("TextButton", contentFrame)
    footerLabel.Size = UDim2.new(1, 0, 0, 25); footerLabel.Position = UDim2.new(0, 0, 1, -25)
    footerLabel.BackgroundTransparency = 1; footerLabel.Text = "by: romokaso"
    footerLabel.TextColor3 = Color3.fromRGB(120, 120, 130); footerLabel.TextSize = 10; footerLabel.Font = Enum.Font.GothamBold
    ui.FooterLabel = footerLabel
    local footerLabelMinimized = Instance.new("TextButton", mainFrame)
    footerLabelMinimized.Size = UDim2.new(1, 0, 0, 25); footerLabelMinimized.Position = UDim2.new(0, 0, 1, -25)
    footerLabelMinimized.BackgroundTransparency = 1; footerLabelMinimized.Text = "by: romokaso"
    footerLabelMinimized.TextColor3 = Color3.fromRGB(120, 120, 130); footerLabelMinimized.TextSize = 10; footerLabelMinimized.Visible = false
    ui.FooterLabelMinimized = footerLabelMinimized
    local confirmFrame = Instance.new("Frame", mainFrame)
    confirmFrame.Size = UDim2.new(1, 0, 1, 0); confirmFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    confirmFrame.BackgroundTransparency = 1; confirmFrame.Visible = false; confirmFrame.ZIndex = 10
    Instance.new("UICorner", confirmFrame)
    ui.ConfirmFrame = confirmFrame
    local confirmText = Instance.new("TextLabel", confirmFrame)
    confirmText.Size = UDim2.new(1, -24, 0, 40); confirmText.Position = UDim2.new(0, 12, 0, 45); confirmText.BackgroundTransparency = 1
    confirmText.Text = "Are you sure you want\nto close the GUI?"; confirmText.TextColor3 = Color3.new(1, 1, 1); confirmText.ZIndex = 11
    ui.ConfirmText = confirmText
    local yesButton = Instance.new("TextButton", confirmFrame)
    yesButton.Size = UDim2.new(0, 105, 0, 32); yesButton.Position = UDim2.new(0, 20, 0, 100); yesButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    yesButton.Text = "Yes"; yesButton.TextColor3 = Color3.new(1, 1, 1); yesButton.ZIndex = 11
    Instance.new("UICorner", yesButton)
    local noButton = Instance.new("TextButton", confirmFrame)
    noButton.Size = UDim2.new(0, 105, 0, 32); noButton.Position = UDim2.new(0, 135, 0, 100); noButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    noButton.Text = "No"; noButton.TextColor3 = Color3.new(1, 1, 1); noButton.ZIndex = 11
    Instance.new("UICorner", noButton)
    local settingsFrame = Instance.new("Frame", mainFrame)
    settingsFrame.Size = UDim2.new(1, 0, 1, 0); settingsFrame.Position = UDim2.new(1, 0, 0, 0); settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    settingsFrame.Visible = false; settingsFrame.ZIndex = 10
    Instance.new("UICorner", settingsFrame); ui.SettingsFrame = settingsFrame
    local settingsTitleBar = Instance.new("Frame", settingsFrame)
    settingsTitleBar.Size = UDim2.new(1, 0, 0, 35); settingsTitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); settingsTitleBar.ZIndex = 11
    Instance.new("UICorner", settingsTitleBar); ui.SettingsTitleBar = settingsTitleBar
    local settingsTitleFix = Instance.new("Frame", settingsTitleBar)
    settingsTitleFix.Size = UDim2.new(1, 0, 0, 12); settingsTitleFix.Position = UDim2.new(0, 0, 1, -12); settingsTitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40); settingsTitleFix.ZIndex = 11
    ui.SettingsTitleFix = settingsTitleFix
    local settingsTitleLabel = Instance.new("TextLabel", settingsTitleBar)
    settingsTitleLabel.Size = UDim2.new(1, -50, 1, 0); settingsTitleLabel.Position = UDim2.new(0, 10, 0, 0); settingsTitleLabel.BackgroundTransparency = 1
    settingsTitleLabel.Text = "Settings"; settingsTitleLabel.TextColor3 = Color3.new(1, 1, 1); settingsTitleLabel.ZIndex = 11; ui.SettingsTitleLabel = settingsTitleLabel
    local backButton = Instance.new("TextButton", settingsTitleBar)
    backButton.Size = UDim2.new(0, 26, 0, 26); backButton.Position = UDim2.new(1, -28, 0, 4); backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    backButton.Text = "←"; backButton.TextColor3 = Color3.new(1, 1, 1); backButton.ZIndex = 11
    Instance.new("UICorner", backButton)
    local settingsContentFrame = Instance.new("Frame", settingsFrame)
    settingsContentFrame.Size = UDim2.new(1, 0, 1, -35); settingsContentFrame.Position = UDim2.new(0, 0, 0, 35); settingsContentFrame.BackgroundTransparency = 1; settingsContentFrame.ZIndex = 11
    local themeLabel = Instance.new("TextLabel", settingsContentFrame)
    themeLabel.Size = UDim2.new(1, -24, 0, 22); themeLabel.Position = UDim2.new(0, 12, 0, 15); themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Theme:"; themeLabel.TextColor3 = Color3.fromRGB(200, 200, 210); themeLabel.ZIndex = 11; ui.ThemeLabel = themeLabel
    local darkButton = Instance.new("TextButton", settingsContentFrame)
    darkButton.Size = UDim2.new(0, 110, 0, 38); darkButton.Position = UDim2.new(0, 12, 0, 45); darkButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    darkButton.Text = "Dark"; darkButton.TextColor3 = Color3.new(1, 1, 1); darkButton.ZIndex = 11
    Instance.new("UICorner", darkButton); local darkStroke = Instance.new("UIStroke", darkButton); darkStroke.Color = Color3.fromRGB(80, 150, 255); darkStroke.Thickness = 3; ui.DarkStroke = darkStroke
    local lightButton = Instance.new("TextButton", settingsContentFrame)
    lightButton.Size = UDim2.new(0, 110, 0, 38); lightButton.Position = UDim2.new(0, 138, 0, 45); lightButton.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
    lightButton.Text = "Light"; lightButton.TextColor3 = Color3.fromRGB(30, 30, 40); lightButton.ZIndex = 11
    Instance.new("UICorner", lightButton); ui.LightButton = lightButton
    applyButton.MouseButton1Click:Connect(function()
        module:AnimateButton(applyButton)
        local val = tonumber(textBox.Text)
        if val then module.State.HitboxSize = val end
    end)
    toggleButton.MouseButton1Click:Connect(function()
        module:AnimateButton(toggleButton)
        module.State.IsEnabled = not module.State.IsEnabled
        if module.State.IsEnabled then
            TS:Create(toggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(50, 200, 100)}):Play()
            toggleButton.Text = "Hitbox: ON"
        else
            TS:Create(toggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
            toggleButton.Text = "Hitbox: OFF"
            for _, v in pairs(module.Services.Players:GetPlayers()) do
                if v ~= lp and v.Character then
                    local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
                end
            end
        end
    end)
    espToggleButton.MouseButton1Click:Connect(function()
        module:AnimateButton(espToggleButton)
        module.State.EspEnabled = not module.State.EspEnabled
        if module.State.EspEnabled then
            TS:Create(espToggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(50, 200, 100)}):Play()
            espToggleButton.Text = "ESP: ON"
        else
            TS:Create(espToggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
            espToggleButton.Text = "ESP: OFF"
            for p, _ in pairs(module.State.EspLabels) do module:RemoveESP(p) end
        end
    end)
    minimizeButton.MouseButton1Click:Connect(function()
        if confirmFrame.Visible or settingsFrame.Visible then return end
        module:AnimateButton(minimizeButton)
        module.State.IsMinimized = not module.State.IsMinimized
        if module.State.IsMinimized then
            TS:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 260, 0, 60)}):Play()
            contentFrame.Visible = false; footerLabel.Visible = false; footerLabelMinimized.Visible = true
        else
            TS:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 260, 0, 180)}):Play()
            contentFrame.Visible = true; footerLabel.Visible = true; footerLabelMinimized.Visible = false
        end
    end)
    closeButton.MouseButton1Click:Connect(function()
        if confirmFrame.Visible or settingsFrame.Visible then return end
        module:AnimateButton(closeButton)
        confirmFrame.Visible = true
        TS:Create(confirmFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
    end)
    yesButton.MouseButton1Click:Connect(function()
        module:AnimateButton(yesButton)
        TS:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        screenGui.Enabled = false
    end)
    noButton.MouseButton1Click:Connect(function()
        module:AnimateButton(noButton)
        TS:Create(confirmFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.wait(0.1); confirmFrame.Visible = false
    end)
    settingsButtonTop.MouseButton1Click:Connect(function()
        module:AnimateButton(settingsButtonTop)
        settingsFrame.Visible = true
        TS:Create(settingsFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    backButton.MouseButton1Click:Connect(function()
        module:AnimateButton(backButton)
        TS:Create(settingsFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.1); settingsFrame.Visible = false
    end)
    darkButton.MouseButton1Click:Connect(function() module:AnimateButton(darkButton); module:ApplyTheme("dark") end)
    lightButton.MouseButton1Click:Connect(function() module:AnimateButton(lightButton); module:ApplyTheme("light") end)
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            module.State.IsDragging = true
            dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then module.State.IsDragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if module.State.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self.State.UI = ui
    DoNotif("Hitbox & ESP Panel: INITIALIZED", 2)
end
RegisterCommand({
    Name = "hitboxgui",
    Aliases = {},
    Description = "Toggles the advanced Hitbox Changer and ESP interface."
}, function()
    if not Modules.HitboxESP.State.UI then
        Modules.HitboxESP:CreateUI()
    else
        Modules.HitboxESP.State.UI.ScreenGui.Enabled = not Modules.HitboxESP.State.UI.ScreenGui.Enabled
    end
end)
Modules.AntiSit = {
    State = {
        IsEnabled = false,
        CharacterConnections = {}
    },
    Services = {
        Players = game:GetService("Players")
    }
}
function Modules.AntiSit:_applyToCharacter(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 2)
    if not humanoid then return end
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local sitConnection = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if humanoid.Sit == true then
            humanoid.Sit = false
        end
    end)
    self.State.CharacterConnections[character] = sitConnection
end
function Modules.AntiSit:_revertForCharacter(character)
    if not character then return end
    if self.State.CharacterConnections[character] then
        self.State.CharacterConnections[character]:Disconnect()
        self.State.CharacterConnections[character] = nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end)
    end
end
function Modules.AntiSit:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then
        self:_applyToCharacter(localPlayer.Character)
    end
    self.State.CharacterConnections.Added = localPlayer.CharacterAdded:Connect(function(char)
        self:_applyToCharacter(char)
    end)
    self.State.CharacterConnections.Removing = localPlayer.CharacterRemoving:Connect(function(char)
        self:_revertForCharacter(char)
    end)
    DoNotif("Anti-Sit: ENABLED", 2)
end
function Modules.AntiSit:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.CharacterConnections.Added then
        self.State.CharacterConnections.Added:Disconnect()
    end
    if self.State.CharacterConnections.Removing then
        self.State.CharacterConnections.Removing:Disconnect()
    end
    local localPlayer = self.Services.Players.LocalPlayer
    if localPlayer.Character then
        self:_revertForCharacter(localPlayer.Character)
    end
    table.clear(self.State.CharacterConnections)
    DoNotif("Anti-Sit: DISABLED", 2)
end
function Modules.AntiSit:Toggle()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({
    Name = "antisit",
    Aliases = {"nosit"},
    Description = "Toggles a system to prevent your character from sitting."
}, function()
    Modules.AntiSit:Toggle()
end)
RegisterCommand({
    Name = "night",
    Aliases = {},
    Description = "Sets the time to night on your client."
}, function(args)
    local Lighting = game:GetService("Lighting")
    local targetTime = tonumber(args[1])
    if not targetTime or targetTime < 0 or targetTime >= 24 then
        targetTime = 0
    end
    Lighting.ClockTime = targetTime
    DoNotif(string.format("Client time set to %02d:00", targetTime), 2)
end)
RegisterCommand({
    Name = "day",
    Aliases = {},
    Description = "Sets the time to day on your client."
}, function(args)
    local Lighting = game:GetService("Lighting")
    local targetTime = tonumber(args[1])
    if not targetTime or targetTime < 0 or targetTime >= 24 then
        targetTime = 14
    end
    Lighting.ClockTime = targetTime
    DoNotif(string.format("Client time set to %02d:00", targetTime), 2)
end)
Modules.FullBright = {
    State = {
        IsEnabled = false,
        OriginalSettings = {}
    }
}
function Modules.FullBright:Enable(): ()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.OriginalSettings = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows
    }
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    self.State.Connection = Lighting.Changed:Connect(function()
        if self.State.IsEnabled then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        end
    end)
    DoNotif("FullBright: ENABLED", 2)
end
function Modules.FullBright:Disable(): ()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    local settings = self.State.OriginalSettings
    Lighting.Ambient = settings.Ambient
    Lighting.OutdoorAmbient = settings.OutdoorAmbient
    Lighting.Brightness = settings.Brightness
    Lighting.ClockTime = settings.ClockTime
    Lighting.GlobalShadows = settings.GlobalShadows
    DoNotif("FullBright: DISABLED", 2)
end
RegisterCommand({
    Name = "fullbright",
    Aliases = {"fb", "bright"},
    Description = "Removes all shadows and maximizes ambient light."
}, function()
    if Modules.FullBright.State.IsEnabled then
        Modules.FullBright:Disable()
    else
        Modules.FullBright:Enable()
    end
end)
Modules.ObjectESP = {
    State = {
        IsEnabled = false,
        Targets = {},
        Visuals = {}
    }
}
function Modules.ObjectESP:_apply(object: Instance): ()
    if not object:IsA("BasePart") or self.State.Visuals[object] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 170, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Parent = object
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(100, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = object.Name
    label.TextColor3 = Color3.fromRGB(255, 170, 0)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = billboard
    billboard.Parent = object
    self.State.Visuals[object] = {highlight, billboard}
end
function Modules.ObjectESP:Toggle(name: string): ()
    if not name then return DoNotif("Usage: ;itemesp <name>", 3) end
    self.State.IsEnabled = true
    local count = 0
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant.Name:lower():find(name:lower()) and descendant:IsA("BasePart") then
            self:_apply(descendant)
            count = count + 1
        end
    end
    DoNotif("Found " .. count .. " items matching: " .. name, 3)
end
function Modules.ObjectESP:Clear(): ()
    for part, effects in pairs(self.State.Visuals) do
        for _, effect in ipairs(effects) do
            pcall(function() effect:Destroy() end)
        end
    end
    table.clear(self.State.Visuals)
    DoNotif("Object ESP Cleared", 2)
end
RegisterCommand({
    Name = "itemesp",
    Aliases = {"finditem", "iesp"},
    Description = "Highlights specific objects in the workspace by name."
}, function(args)
    local name = table.concat(args, " ")
    if name == "clear" or name == "off" then
        Modules.ObjectESP:Clear()
    else
        Modules.ObjectESP:Toggle(name)
    end
end)
Modules.InternalAntiAfk = {
    State = {
        IsEnabled = false,
        Connection = nil
    }
}
function Modules.InternalAntiAfk:Toggle(): ()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        local virtualUser = game:GetService("VirtualUser")
        self.State.Connection = LocalPlayer.Idled:Connect(function()
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end)
        DoNotif("Internal Anti-AFK: ENABLED", 2)
    else
        if self.State.Connection then
            self.State.Connection:Disconnect()
            self.State.Connection = nil
        end
        DoNotif("Internal Anti-AFK: DISABLED", 2)
    end
end
RegisterCommand({
    Name = "idlesaver",
    Aliases = {"afk", "antiafk"},
    Description = "Prevents being disconnected for inactivity via internal engine signals."
}, function()
    Modules.InternalAntiAfk:Toggle()
end)
Modules.ToolSpy = {
    State = {
        IsEnabled = false
    }
}
function Modules.ToolSpy:Scan(): ()
    print("--- [Tool Spy Report] ---")
    local found = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local tools = {}
            if char then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, "[EQUIPPED] " .. item.Name)
                    end
                end
            end
            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(tools, item.Name)
                    end
                end
            end
            if #tools > 0 then
                found = found + 1
                print(string.format("Player: %s | Tools: %s", player.Name, table.concat(tools, ", ")))
            end
        end
    end
    print("--- End of Report ---")
    DoNotif("Tool Spy: Found inventory for " .. found .. " players. Check Console (F9).", 4)
end
RegisterCommand({
    Name = "toolspy",
    Aliases = {"invspy", "checktools"},
    Description = "Dumps the inventory of every player in the server to the developer console."
}, function()
    Modules.ToolSpy:Scan()
end)
Modules.LightingLock = {
    State = {
        IsEnabled = false,
        OriginalNamecall = nil,
        Properties = {
            Brightness = 2,
            ClockTime = 14,
            FogEnd = 100000,
            GlobalShadows = false
        }
    }
}
function Modules.LightingLock:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        local mt = getrawmetatable(game)
        self.State.OriginalNamecall = mt.__newindex
        local original = self.State.OriginalNamecall
        setreadonly(mt, false)
        mt.__newindex = newcclosure(function(t, k, v)
            if t == Lighting and Modules.LightingLock.State.IsEnabled then
                if Modules.LightingLock.State.Properties[k] ~= nil then
                    return
                end
            end
            return original(t, k, v)
        end)
        setreadonly(mt, true)
        for k, v in pairs(self.State.Properties) do
            pcall(function() Lighting[k] = v end)
        end
        DoNotif("Lighting Lock: ENABLED", 2)
    else
        self.State.IsEnabled = false
        DoNotif("Lighting Lock: DISABLED", 2)
    end
end
Modules.PromptAura = {
    State = {
        IsEnabled = false,
        Connection = nil,
        Distance = 15
    }
}
function Modules.PromptAura:Toggle(dist)
    self.State.IsEnabled = not self.State.IsEnabled
    self.State.Distance = tonumber(dist) or 15
    if self.State.IsEnabled then
        self.State.Connection = RunService.Heartbeat:Connect(function()
            local char = Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local part = prompt.Parent
                    if part and part:IsA("BasePart") then
                        if (hrp.Position - part.Position).Magnitude <= self.State.Distance then
                            if fireproximityprompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end
        end)
        DoNotif("Prompt Aura: ENABLED", 2)
    else
        if self.State.Connection then self.State.Connection:Disconnect() end
        self.State.IsEnabled = false
        DoNotif("Prompt Aura: DISABLED", 2)
    end
end
Modules.SafeTeleport = {
    State = {
        IsEnabled = false
    }
}
function Modules.SafeTeleport:Execute(targetName: string)
    local target = Utilities.findPlayer(targetName)
    if not target or not target.Character then return DoNotif("Target not found.", 2) end
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetHrp then
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character, target.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        local result = Workspace:Raycast(targetHrp.Position, Vector3.new(0, 5, 0), rayParams)
        local finalPos = result and result.Position or (targetHrp.Position + Vector3.new(0, 3, 0))
        hrp.CFrame = CFrame.new(finalPos)
        DoNotif("Safe Teleport to " .. target.Name, 2)
    end
end
RegisterCommand({
    Name = "locklighting",
    Aliases = {"lightlock", "ll"},
    Description = "Prevents the server from changing your local lighting settings."
}, function()
    Modules.LightingLock:Toggle()
end)
RegisterCommand({
    Name = "promptaura",
    Aliases = {"pa"},
    Description = "Automatically triggers proximity prompts in a radius."
}, function(args)
    Modules.PromptAura:Toggle(args[1])
end)
RegisterCommand({
    Name = "stp",
    Aliases = {"safeteleport"},
    Description = "Teleports to a player while checking for ceiling/wall obstructions."
}, function(args)
    Modules.SafeTeleport:Execute(args[1])
end)
Modules.HitboxExtender = {
    State = {
        IsEnabled = false,
        TrackedCharacters = setmetatable({}, {__mode = "k"}),
        OriginalSizes = setmetatable({}, {__mode = "k"}),
        Connections = {}
    },
    Config = {
        TargetPartName = "HumanoidRootPart",
        SizeMultiplier = 3
    },
    Services = {
        Players = game:GetService("Players")
    }
}
function Modules.HitboxExtender:_apply(character)
    if not character or self.State.TrackedCharacters[character] then return end
    local targetPart = character:FindFirstChild(self.Config.TargetPartName)
    if not targetPart then return end
    if not self.State.OriginalSizes[targetPart] then
        self.State.OriginalSizes[targetPart] = targetPart.Size
    end
    targetPart.Size = self.State.OriginalSizes[targetPart] * self.Config.SizeMultiplier
    targetPart.Transparency = 1
    targetPart.CanCollide = false
    self.State.TrackedCharacters[character] = true
end
function Modules.HitboxExtender:_revert(character)
    if not character or not self.State.TrackedCharacters[character] then return end
    local targetPart = character:FindFirstChild(self.Config.TargetPartName)
    if targetPart and self.State.OriginalSizes[targetPart] then
        targetPart.Size = self.State.OriginalSizes[targetPart]
        targetPart.Transparency = self.State.OriginalSizes[targetPart].Transparency or 0
        targetPart.CanCollide = self.State.OriginalSizes[targetPart].CanCollide or true
        self.State.OriginalSizes[targetPart] = nil
    end
    self.State.TrackedCharacters[character] = nil
end
function Modules.HitboxExtender:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local function setupPlayer(player)
        if player == self.Services.Players.LocalPlayer then return end
        if player.Character then
            self:_apply(player.Character)
        end
        self.State.Connections[player] = {}
        self.State.Connections[player].CharacterAdded = player.CharacterAdded:Connect(function(char) self:_apply(char) end)
        self.State.Connections[player].CharacterRemoving = player.CharacterRemoving:Connect(function(char) self:_revert(char) end)
    end
    for _, player in ipairs(self.Services.Players:GetPlayers()) do
        setupPlayer(player)
    end
    self.State.Connections.PlayerAdded = self.Services.Players.PlayerAdded:Connect(setupPlayer)
    self.State.Connections.PlayerRemoving = self.Services.Players.PlayerRemoving:Connect(function(player)
        if self.State.Connections[player] then
            for _, conn in pairs(self.State.Connections[player]) do
                conn:Disconnect()
            end
            self.State.Connections[player] = nil
        end
    end)
    DoNotif("Hitbox Extender: ENABLED", 2)
end
function Modules.HitboxExtender:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for player, conns in pairs(self.State.Connections) do
        if type(conns) == "table" then
            for _, conn in pairs(conns) do conn:Disconnect() end
        else
            conns:Disconnect()
        end
    end
    table.clear(self.State.Connections)
    for character in pairs(self.State.TrackedCharacters) do
        self:_revert(character)
    end
    table.clear(self.State.OriginalSizes)
    DoNotif("Hitbox Extender: DISABLED", 2)
end
RegisterCommand({
    Name = "hitbox",
    Aliases = {},
    Description = "Enlarges other players' hitboxes locally for easier melee hits."
}, function(args)
    local multiplier = tonumber(args[1])
    if multiplier and multiplier > 0 then
        Modules.HitboxExtender.Config.SizeMultiplier = multiplier
        DoNotif("Hitbox multiplier set to " .. multiplier, 2)
    end
    if Modules.HitboxExtender.State.IsEnabled then
        if not multiplier then
            Modules.HitboxExtender:Disable()
        end
    else
        Modules.HitboxExtender:Enable()
    end
end)
Modules.NetworkSaturator = {
    State = {
        Active = false
    }
}
function Modules.NetworkSaturator:Start(): ()
    self.State.Active = true
    task.spawn(function()
        while self.State.Active do
            for _: number, obj: Instance in ipairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    pcall(obj.FireServer, obj, math.huge, "Zuka_Saturate", string.rep("0", 100))
                end
            end
            task.wait(0.1)
        end
    end)
    DoNotif("Network Saturation: ACTIVE", 2)
end
RegisterCommand({
    Name = "rempayload",
    Aliases = {},
    Description = "Saturates discoverable remotes with high-density data payloads."
}, function()
    if Modules.NetworkSaturator.State.Active then
        Modules.NetworkSaturator.State.Active = false
        DoNotif("Network Saturation: DISABLED", 2)
    else
        Modules.NetworkSaturator:Start()
    end
end)
Modules.UltimateGod = {
    State = {
        IsEnabled = false,
        Connection = nil
    }
}
function Modules.UltimateGod:Toggle(): ()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        self.State.Connection = RunService.Heartbeat:Connect(function()
            local char: Model? = LocalPlayer.Character
            local hum: Humanoid? = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                if hum.Health <= 0 then
                    hum.Health = hum.MaxHealth
                end
            end
        end)
        DoNotif("Ultimate Godmode: ENABLED", 2)
    else
        if self.State.Connection then self.State.Connection:Disconnect() end
        local hum: Humanoid? = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        DoNotif("Ultimate Godmode: DISABLED", 2)
    end
end
RegisterCommand({
    Name = "god",
    Aliases = {},
    Description = "Aggressively locks humanoid state and health to prevent death."
}, function()
    Modules.UltimateGod:Toggle()
end)
Modules.NetworkNormalizer = {
    State = {
        IsNormalized = false,
        OriginalNames = {}
    },
    Config = {
        TARGET_CONTAINERS = {ReplicatedStorage},
        PREFIX = ""
    }
}
function Modules.NetworkNormalizer:Normalize()
    local count = 0
    table.clear(self.State.OriginalNames)
    print("--- [Network Normalization Started] ---")
    for _, container in ipairs(self.Config.TARGET_CONTAINERS) do
        local descendants = container:GetDescendants()
        for _, obj in ipairs(descendants) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                count += 1
                local oldPath = obj:GetFullName()
                local newName = self.Config.PREFIX .. tostring(count)
                self.State.OriginalNames[obj] = {
                    Name = obj.Name,
                    Path = oldPath
                }
                local success, err = pcall(function()
                    obj.Name = newName
                end)
                if success then
                    print(string.format("[ID: %d] Normalized: %s", count, oldPath))
                else
                    warn(string.format("[ID: %d] Failed to rename: %s | Error: %s", count, oldPath, err))
                end
            end
        end
    end
    self.State.IsNormalized = true
    DoNotif(string.format("Normalized %d network objects. Check F9 for the map.", count), 4)
    print("--- [Normalization Complete] ---")
end
function Modules.NetworkNormalizer:Restore()
    if not self.State.IsNormalized then
        return DoNotif("Network is not currently normalized.", 3)
    end
    local count = 0
    for obj, data in pairs(self.State.OriginalNames) do
        if obj and obj.Parent then
            pcall(function()
                obj.Name = data.Name
                count += 1
            end)
        end
    end
    self.State.IsNormalized = false
    table.clear(self.State.OriginalNames)
    DoNotif(string.format("Restored %d network objects to original states.", count), 3)
end
function Modules.NetworkNormalizer:Initialize()
    local module = self
    RegisterCommand({
        Name = "normalize",
        Aliases = {"renameremotes", "simplifynet"},
        Description = "Renames all Remotes in ReplicatedStorage to a numerical sequence (1-100+)."
    }, function()
        module:Normalize()
    end)
    RegisterCommand({
        Name = "unnormalize",
        Aliases = {"restoreremotes"},
        Description = "Restores all renamed remotes to their original obfuscated names."
    }, function()
        module:Restore()
    end)
end
Modules.UpvalueSurgeon = {
    State = {
        IsScanning = false
    },
    Config = {
        MAX_RESULTS = 50,
        BLACKLIST = {"Chat", "PlayerScripts", "CharacterSounds", "BubbleChat"}
    }
}
function Modules.UpvalueSurgeon:_convert(val: string): any
    if val:lower() == "true" then return true end
    if val:lower() == "false" then return false end
    if tonumber(val) then return tonumber(val) end
    return val
end
function Modules.UpvalueSurgeon:ScanGC(targetName: string)
    local matches = {}
    local getUpvalue = (debug and debug.getupvalue) or getupvalue
    local getInfo = (debug and debug.getinfo) or getinfo
    local isL = (islclosure or function(f) return true end)
    if not (getgc and getUpvalue and getInfo) then
        return matches
    end
    for _, obj in ipairs(getgc()) do
        if type(obj) == "function" and isL(obj) then
            local success, info = pcall(getInfo, obj)
            if success and info.source then
                local blacklisted = false
                for _, word in ipairs(self.Config.BLACKLIST) do
                    if info.source:find(word) then
                        blacklisted = true
                        break
                    end
                end
                if not blacklisted then
                    local idx = 1
                    while true do
                        local name, val = nil, nil
                        local ok, err = pcall(function()
                            name, val = getUpvalue(obj, idx)
                        end)
                        if not ok or not name then break end
                        if tostring(name) == targetName or (type(name) == "string" and name:lower() == targetName:lower()) then
                            table.insert(matches, {
                                Function = obj,
                                Index = idx,
                                Value = val,
                                Source = info.source,
                                FuncName = info.name or "Anonymous"
                            })
                        end
                        idx += 1
                        if idx > 100 then break end
                    end
                end
            end
        end
        if #matches >= self.Config.MAX_RESULTS then break end
    end
    return matches
end
function Modules.UpvalueSurgeon:Operate(targetName: string, rawValue: string)
    local newValue = self:_convert(rawValue)
    local setUpvalue = (debug and debug.setupvalue) or setupvalue
    local matches = self:ScanGC(targetName)
    local count = 0
    if not setUpvalue then return DoNotif("Executor lacks 'setupvalue'.", 3) end
    for _, m in ipairs(matches) do
        local ok = pcall(setUpvalue, m.Function, m.Index, newValue)
        if ok then
            count += 1
            print(string.format("[SURGEON] Modified upvalue '%s' in %s", targetName, m.Source))
        end
    end
    DoNotif(string.format("Surgery successful. Patched %d functions.", count), 3)
end
function Modules.UpvalueSurgeon:Initialize()
    local module = self
    RegisterCommand({
        Name = "upvalue",
        Aliases = {"surgeon", "ups"},
        Description = "Globally overwrites a local variable (upvalue) by name."
    }, function(args)
        local target, val = args[1], args[2]
        if not target or not val then return DoNotif("Usage: ;upvalue <name> <value>", 3) end
        module:Operate(target, val)
    end)
    RegisterCommand({
        Name = "scanup",
        Aliases = {"fup"},
        Description = "Scans game memory for functions containing a specific variable name."
    }, function(args)
        local target = args[1]
        if not target then return DoNotif("Variable name required.", 3) end
        DoNotif("Performing memory scan for: " .. target, 2)
        task.spawn(function()
            local matches = module:ScanGC(target)
            if #matches == 0 then
                DoNotif("No instances found in memory.", 3)
            else
                print("--- [Surgeon Scan Report] ---")
                for i, m in ipairs(matches) do
                    print(string.format("[%d] %s | Value: %s | Source: %s", i, m.FuncName, tostring(m.Value), m.Source))
                end
                DoNotif("Scan Complete. Found " .. #matches .. " matches. Check F9.", 4)
            end
        end)
    end)
end
Modules.FolderBringer = {
    State = {
        IsEnabled = true
    },
    Dependencies = {"Workspace", "Players"},
    Services = {}
}
function Modules.FolderBringer:Execute(args)
    if #args == 0 then
        return DoNotif("Usage: ;bringfolder {folderName} [partName]", 3)
    end
    local folder, partFilter
    local workspace = self.Services.Workspace
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    if not char then
        return DoNotif("Character not found.", 3)
    end
    for i = #args, 1, -1 do
        local potentialName = table.concat(args, " ", 1, i):lower()
        local potentialFilter = table.concat(args, " ", i + 1):lower()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Folder") and obj.Name:lower() == potentialName then
                folder = obj
                partFilter = potentialFilter
                break
            end
        end
        if folder then break end
    end
    if not folder then
        return DoNotif("Folder sequence not found in Workspace.", 3)
    end
    local pivot = char:GetPivot()
    local bringCount = 0
    for _, desc in ipairs(folder:GetDescendants()) do
        if desc:IsA("BasePart") then
            local shouldBring = true
            if partFilter and partFilter ~= "" then
                local n = desc.Name:lower()
                shouldBring = (n == partFilter) or (n:find(partFilter, 1, true) ~= nil)
            end
            if shouldBring then
                desc:PivotTo(pivot)
                bringCount = bringCount + 1
            end
        end
    end
    if bringCount > 0 then
        DoNotif(string.format("Brought %d parts from '%s'.", bringCount, folder.Name), 2)
    else
        DoNotif("No matching parts found in the folder.", 2)
    end
end
function Modules.FolderBringer:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "bringfolder",
        Aliases = {"bfldr", "folderbring"},
        Description = "Teleports all parts (or a specific part) from a Workspace folder to you."
    }, function(args)
        module:Execute(args)
    end)
end
Modules.QuickExecutor = {
    State = {
        IsEnabled = true
    }
}
function Modules.QuickExecutor:RunCode(args)
    local code = table.concat(args, " ")
    if not code or code == "" then
        return DoNotif("Quick Executor: No code provided.", 2)
    end
    local func, compileError = loadstring(code)
    if not func then
        warn("--> [QuickExecutor] Syntax Error:", compileError)
        return DoNotif("Syntax Error: Check F9 for details.", 3)
    end
    local success, runError = pcall(function()
        task.spawn(func)
    end)
    if not success then
        warn("--> [QuickExecutor] Runtime Error:", runError)
        DoNotif("Runtime Error occurred. Check F9 console.", 3)
    else
        DoNotif("Code executed.", 1)
    end
end
function Modules.QuickExecutor:Initialize()
    local module = self
    RegisterCommand({
        Name = "loadstring",
        Aliases = {"ls", "lstring", "loads", "execute", "run"},
        Description = "Compiles and executes Lua code directly from the command bar."
    }, function(args)
        module:RunCode(args)
    end)
end
Modules.CommandHistory = {
    State = {
        LastCommand = nil,
        PrevCommand = nil
    }
}
function Modules.CommandHistory:Record(message)
    local cmdName = message:sub(#Prefix + 1):match("%S+")
    if not cmdName then return end
    cmdName = cmdName:lower()
    local blacklist = {["lastcommand"] = true, ["lastcmd"] = true, ["re"] = true}
    if not blacklist[cmdName] then
        self.State.PrevCommand = self.State.LastCommand
        self.State.LastCommand = message
    end
end
function Modules.CommandHistory:ExecuteLast()
    local toRun = self.State.LastCommand
    if not toRun then
        return DoNotif("No previous command recorded.", 2)
    end
    if Modules.CommandBar and Modules.CommandBar.AddOutput then
        Modules.CommandBar:AddOutput("Replaying: " .. toRun, Modules.CommandBar.Theme.Accent)
    end
    processCommand(toRun)
end
function Modules.CommandHistory:Initialize()
    local module = self
    local oldProcess = processCommand
    getgenv().processCommand = function(message)
        module:Record(message)
        return oldProcess(message)
    end
    RegisterCommand({
        Name = "lastcommand",
        Aliases = {"lastcmd", "re", "redo"},
        Description = "Re-runs the last command you successfully executed."
    }, function()
        module:ExecuteLast()
    end)
end
Modules.CommandLooper = {
    State = {
        IsRunning = false,
        LoopThread = nil,
        CurrentCommand = nil
    },
    Config = {
        Interval = 1
    }
}
function Modules.CommandLooper:Start(commandName, args)
    local cmdFunc = Commands[commandName:lower()]
    if not cmdFunc then
        return DoNotif(string.format("Loop Error: Command ';%s' not found.", commandName), 3)
    end
    if commandName:lower() == "cmdloop" or commandName:lower() == "commandloop" then
        return DoNotif("Architect Error: Infinite recursion prevented.", 3)
    end
    self:Stop()
    self.State.IsRunning = true
    self.State.CurrentCommand = commandName
    DoNotif(string.format("Looping command ';%s' every %ds.", commandName, self.Config.Interval), 2)
    self.State.LoopThread = task.spawn(function()
        while self.State.IsRunning do
            local success, err = pcall(cmdFunc, args)
            if not success then
                warn("--> [CommandLooper] Error in loop:", err)
            end
            task.wait(self.Config.Interval)
        end
    end)
end
function Modules.CommandLooper:Stop()
    if not self.State.IsRunning then return end
    self.State.IsRunning = false
    if self.State.LoopThread then
        task.cancel(self.State.LoopThread)
        self.State.LoopThread = nil
    end
    DoNotif(string.format("Stopped loop for ';%s'.", self.State.CurrentCommand or "unknown"), 2)
    self.State.CurrentCommand = nil
end
function Modules.CommandLooper:Initialize()
    local module = self
    RegisterCommand({
        Name = "commandloop",
        Aliases = {"cmdloop", "cloop"},
        Description = "Runs a command repeatedly."
    }, function(args)
        if #args == 0 then
            return DoNotif("Usage: ;cmdloop <command> [args]", 3)
        end
        local cmdTarget = table.remove(args, 1)
        module:Start(cmdTarget, args)
    end)
    RegisterCommand({
        Name = "stoploop",
        Aliases = {"uncmdloop", "sloop", "stopl", "unloop"},
        Description = "Stops the currently running command loop."
    }, function()
        if not module.State.IsRunning then
            return DoNotif("No command is currently looping.", 2)
        end
        module:Stop()
    end)
end
Modules.ChatFilterReseter = {
    State = {
        IsEnabled = true
    },
    Dependencies = {"Players"},
    Services = {}
}
function Modules.ChatFilterReseter:Reset()
    local lp = self.Services.Players.LocalPlayer
    if not lp then return end
    DoNotif("Resetting chat filter...", 2)
    for i = 1, 3 do
        pcall(function()
            lp:Chat("/e hi")
        end)
        task.wait(0.1)
    end
    DoNotif("Filter Reset: Complete.", 2)
end
function Modules.ChatFilterReseter:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "resetfilter",
        Aliases = {"ref", "resetchat", "unfilter"},
        Description = "Sends emote commands to try and stop Roblox from tagging your messages."
    }, function()
        module:Reset()
    end)
end
Modules.ToolMasher = {
    State = {
        IsExecuting = false
    },
    Dependencies = {"Players"},
    Services = {}
}
function Modules.ToolMasher:Mash()
    if self.State.IsExecuting then return end
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local backpack = lp:FindFirstChildOfClass("Backpack")
    if not char or not backpack then
        return DoNotif("Tool Masher: Character or Backpack missing.", 3)
    end
    self.State.IsExecuting = true
    local toolBuffer = {}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(toolBuffer, tool)
            tool.Parent = char
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and not table.find(toolBuffer, tool) then
            table.insert(toolBuffer, tool)
        end
    end
    if #toolBuffer == 0 then
        self.State.IsExecuting = false
        return DoNotif("No tools found to mash.", 2)
    end
    task.wait(0.1)
    local successCount = 0
    for _, tool in ipairs(toolBuffer) do
        pcall(function()
            tool:Activate()
            successCount = successCount + 1
        end)
    end
    task.wait(0.1)
    for _, tool in ipairs(toolBuffer) do
        pcall(function()
            tool.Parent = backpack
        end)
    end
    DoNotif(string.format("Mashed %d tools successfully.", successCount), 2)
    self.State.IsExecuting = false
end
function Modules.ToolMasher:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "usetools",
        Aliases = {"uset", "mash", "useall"},
        Description = "Equips every tool you own, uses them once, and puts them back."
    }, function()
        module:Mash()
    end)
end
Modules.InvisDeleter = {
    State = {
        IsScanning = false
    },
    Dependencies = {"Workspace"},
    Services = {}
}
function Modules.InvisDeleter:Purge()
    if self.State.IsScanning then
        return DoNotif("Purge already in progress...", 2)
    end
    local workspace = self.Services.Workspace
    local count = 0
    self.State.IsScanning = true
    DoNotif("Scanning for invisible walls...", 2)
    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i, part in ipairs(descendants) do
            if i % 500 == 0 then task.wait() end
            if part:IsA("BasePart") then
                if part.Transparency >= 1 and part.CanCollide then
                    local char = game:GetService("Players").LocalPlayer.Character
                    if not (char and part:IsDescendantOf(char)) then
                        pcall(function()
                            part:Destroy()
                            count = count + 1
                        end)
                    end
                end
            end
        end
        self.State.IsScanning = false
        DoNotif(string.format("Purge complete. Destroyed %d parts.", count), 3)
    end)
end
function Modules.InvisDeleter:Initialize()
    local module = self
    for _, serviceName in ipairs(module.Dependencies) do
        module.Services[serviceName] = game:GetService(serviceName)
    end
    RegisterCommand({
        Name = "deleteinvisparts",
        Aliases = {"deleteinvisibleparts", "dip", "delinvis", "unblock"},
        Description = "Removes all invisible parts that have collisions enabled (Invisible Walls)."
    }, function()
        module:Purge()
    end)
end
Modules.AutoInteract = {
    State = {
        IsEnabled = false,
        Radius = 15,
        Connection = nil
    }
}
function Modules.AutoInteract:Enable(radius: number)
    if self.State.IsEnabled then self:Disable() end
    self.State.Radius = tonumber(radius) or 15
    self.State.IsEnabled = true
    self.State.Connection = RunService.Heartbeat:Connect(function()
        local character = Players.LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local part = prompt.Parent
                if part and part:IsA("BasePart") then
                    local distance = (hrp.Position - part.Position).Magnitude
                    if distance <= self.State.Radius then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end
    end)
    DoNotif("Auto-Interact: ENABLED (Radius: " .. self.State.Radius .. ")", 2)
end
function Modules.AutoInteract:Disable()
    if not self.State.IsEnabled then return end
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    self.State.IsEnabled = false
    DoNotif("Auto-Interact: DISABLED", 2)
end
RegisterCommand({
    Name = "autoprompt",
    Aliases = {"autointeract", "ap"},
    Description = "Automatically triggers proximity prompts within a radius."
}, function(args)
    if args[1] == "off" then
        Modules.AutoInteract:Disable()
    else
        Modules.AutoInteract:Enable(args[1])
    end
end)

Modules.PhysicsGun = {
    State = {
        IsEnabled = false,
        SelectedPart = nil,
        Connection = nil,
        AlignPos = nil,
        AlignOri = nil,
        Attachment0 = nil,
        Attachment1 = nil
    }
}
function Modules.PhysicsGun:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        local mouse = Players.LocalPlayer:GetMouse()
        self.State.Connection = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                if not self.State.SelectedPart then
                    local target = mouse.Target
                    if target and not target.Anchored and not target:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") then
                        self.State.SelectedPart = target
                        self.State.Attachment1 = Instance.new("Attachment", Workspace.Terrain)
                        self.State.Attachment0 = Instance.new("Attachment", target)
                        local ap = Instance.new("AlignPosition")
                        ap.Attachment0 = self.State.Attachment0
                        ap.Attachment1 = self.State.Attachment1
                        ap.MaxForce = 1e9
                        ap.Responsiveness = 200
                        ap.Parent = target
                        self.State.AlignPos = ap
                        local ao = Instance.new("AlignOrientation")
                        ao.Attachment0 = self.State.Attachment0
                        ao.Attachment1 = self.State.Attachment1
                        ao.MaxTorque = 1e9
                        ao.Responsiveness = 200
                        ao.Parent = target
                        self.State.AlignOri = ao
                    end
                end
                if self.State.SelectedPart and self.State.Attachment1 then
                    self.State.Attachment1.WorldCFrame = mouse.Hit
                end
            else
                if self.State.AlignPos then self.State.AlignPos:Destroy() end
                if self.State.AlignOri then self.State.AlignOri:Destroy() end
                if self.State.Attachment0 then self.State.Attachment0:Destroy() end
                if self.State.Attachment1 then self.State.Attachment1:Destroy() end
                self.State.SelectedPart = nil
            end
        end)
        DoNotif("Physics Gun: ENABLED (Hold LMB)", 2)
    else
        if self.State.Connection then self.State.Connection:Disconnect() end
        self.State.IsEnabled = false
        DoNotif("Physics Gun: DISABLED", 2)
    end
end
RegisterCommand({
    Name = "physicsgun",
    Aliases = {},
    Description = "Allows you to grab and move unanchored parts with your mouse."
}, function()
    Modules.PhysicsGun:Toggle()
end)
Modules.VisualClear = {
    State = {
        IsEnabled = false,
        OriginalStates = {}
    }
}
function Modules.VisualClear:Toggle()
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostProcessEffect") then
                self.State.OriginalStates[effect] = effect.Enabled
                effect.Enabled = false
            end
        end
        for _, effect in ipairs(Workspace.CurrentCamera:GetChildren()) do
            if effect:IsA("PostProcessEffect") then
                self.State.OriginalStates[effect] = effect.Enabled
                effect.Enabled = false
            end
        end
        DoNotif("Visual Clear: ENABLED (Blur/Bloom Removed)", 2)
    else
        for effect, state in pairs(self.State.OriginalStates) do
            if effect and effect.Parent then
                effect.Enabled = state
            end
        end
        table.clear(self.State.OriginalStates)
        DoNotif("Visual Clear: DISABLED", 2)
    end
end
RegisterCommand({
    Name = "clearvisuals",
    Aliases = {},
    Description = "Removes all post-processing effects like Blur, Bloom, and ColorCorrection."
}, function()
    Modules.VisualClear:Toggle()
end)
Modules.NetworkOwner = {
    State = {
        IsEnabled = false,
        Connection = nil,
        CharacterAddedConn = nil,
        CachedParts = {}
    },
    Config = {
        NETWORK_VELOCITY = Vector3.new(0, 30.01, 0)
    }
}
function Modules.NetworkOwner:CacheCharacterParts(character: Model)
    table.clear(self.State.CachedParts)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(self.State.CachedParts, part)
        end
    end
end
function Modules.NetworkOwner:Enable(): ()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    local localPlayer = Players.LocalPlayer
    local function setup(character)
        self:CacheCharacterParts(character)
    end
    if localPlayer.Character then
        setup(localPlayer.Character)
    end
    self.State.CharacterAddedConn = localPlayer.CharacterAdded:Connect(setup)
    self.State.Connection = RunService.Heartbeat:Connect(function()
        local character = localPlayer.Character
        if not character then return end
        for i = #self.State.CachedParts, 1, -1 do
            local part = self.State.CachedParts[i]
            if part and part.Parent then
                part.AssemblyLinearVelocity = self.Config.NETWORK_VELOCITY
            else
                table.remove(self.State.CachedParts, i)
            end
        end
    end)
    DoNotif("Netless: ENABLED (Persistent Physics Authority)", 2)
end
function Modules.NetworkOwner:Disable(): ()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    if self.State.CharacterAddedConn then
        self.State.CharacterAddedConn:Disconnect()
        self.State.CharacterAddedConn = nil
    end
    table.clear(self.State.CachedParts)
    DoNotif("Netless: DISABLED", 2)
end
function Modules.NetworkOwner:Toggle(): ()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
RegisterCommand({
    Name = "netless",
    Aliases = {"networkowner", "net"},
    Description = "Optimized persistence of network ownership for character parts."
}, function()
    Modules.NetworkOwner:Toggle()
end)
Modules.MeleeFreezer = {
    State = {
        IsEnabled = false,
        FrozenTracks = {},
        Connection = nil
    },
    Config = {
        ToggleKey = Enum.KeyCode.G
    }
}
function Modules.MeleeFreezer:Enable(): ()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self.State.Connection = RunService.RenderStepped:Connect(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.IsPlaying and track.Speed ~= 0 then
                    track:AdjustSpeed(0)
                end
            end
        end
    end)
    DoNotif("Melee Freeze: ENABLED (Animations Locked)", 2)
end
function Modules.MeleeFreezer:Disable(): ()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    if self.State.Connection then
        self.State.Connection:Disconnect()
        self.State.Connection = nil
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(1)
        end
    end
    DoNotif("Melee Freeze: DISABLED (Animations Restored)", 2)
end
function Modules.MeleeFreezer:Toggle(): ()
    if self.State.IsEnabled then
        self:Disable()
    else
        self:Enable()
    end
end
function Modules.MeleeFreezer:Initialize(): ()
    local module = self
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == module.Config.ToggleKey then
            module:Toggle()
        end
    end)
    RegisterCommand({
        Name = "freezemelee",
        Aliases = {},
        Description = "Toggles an animation freeze when G is pressed."
    }, function()
        module:Toggle()
    end)
end
Modules.ToolAttributeLister = {
    State = {}
}
function Modules.ToolAttributeLister:Scan(): ()
    local character = LocalPlayer.Character
    if not character then
        return DoNotif("Character not found.", 3)
    end
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        return DoNotif("You must have a tool equipped to scan it.", 3)
    end
    local attributes = tool:GetAttributes()
    local attributeCount = 0
    print("--- [Attribute Scan: " .. tool.Name .. "] ---")
    for name, value in pairs(attributes) do
        attributeCount = attributeCount + 1
        local valueType = typeof(value)
        local formattedValue = tostring(value)
        if valueType == "Color3" then
            formattedValue = string.format("RGB(%d, %d, %d)", value.R * 255, value.G * 255, value.B * 255)
        elseif valueType == "Vector3" then
            formattedValue = string.format("(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
        end
        print(string.format("  [!] %s [%s]: %s", name, valueType, formattedValue))
    end
    if attributeCount == 0 then
        print("  (No attributes found on this tool)")
        DoNotif("No attributes found on " .. tool.Name, 3)
    else
        print("--- Total Attributes: " .. attributeCount .. " ---")
        DoNotif("Listed " .. attributeCount .. " attributes for " .. tool.Name .. " in F9 console.", 4)
    end
end
RegisterCommand({
    Name = "listattributes",
    Aliases = {"toolattrs", "getattr", "scantool"},
    Description = "Dumps every attribute and value of the equipped tool to the developer console (F9)."
}, function()
    Modules.ToolAttributeLister:Scan()
end)
Modules.NeuralOverride = {
    State = {
        IsScanning = false
    }
}
function Modules.NeuralOverride:OverwriteData(targetVar: string, newValue: any): ()
    if not (getgc and debug.getupvalue and debug.setupvalue) then
        return DoNotif("NeuralOverride: Executor lacks debug library support.", 3)
    end
    local count: number = 0
    local convertedValue: any = newValue
    if newValue == "true" then convertedValue = true
    elseif newValue == "false" then convertedValue = false
    elseif tonumber(newValue) then convertedValue = tonumber(newValue) end
    for _: number, obj: any in ipairs(getgc()) do
        if type(obj) == "function" and islclosure(obj) then
            local idx: number = 1
            while true do
                local name: string?, val: any = debug.getupvalue(obj, idx)
                if not name then break end
                if name == targetVar then
                    pcall(debug.setupvalue, obj, idx, convertedValue)
                    count = count + 1
                end
                idx = idx + 1
            end
        end
    end
    DoNotif(string.format("NeuralOverride: Patched %d instances of '%s'", count, targetVar), 3)
end
RegisterCommand({
    Name = "patch",
    Aliases = {},
    Description = "Scans game memory and overwrites internal script variables. ;neural isAdmin true"
}, function(args: {string})
    if #args < 2 then return DoNotif("Usage: ;neural [varName] [value]", 3) end
    Modules.NeuralOverride:OverwriteData(args[1], args[2])
end)
Modules.InterstellarInteraction = {
    State = {
        Active = false,
        Connection = nil
    }
}
function Modules.InterstellarInteraction:Toggle(): ()
    self.State.Active = not self.State.Active
    if self.State.Active then
        self.State.Connection = RunService.Heartbeat:Connect(function()
            for _: number, obj: Instance in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.RequiresLineOfSight = false
                    obj.MaxActivationDistance = 1e7
                    if fireproximityprompt then
                        fireproximityprompt(obj)
                    end
                end
                if obj:IsA("ClickDetector") then
                    obj.MaxActivationDistance = 1e7
                    if fireclickdetector then
                        fireclickdetector(obj)
                    end
                end
            end
        end)
        DoNotif("Interstellar: Global Interaction ACTIVE", 2)
    else
        if self.State.Connection then self.State.Connection:Disconnect() end
        DoNotif("Interstellar: Global Interaction DISABLED", 2)
    end
end
RegisterCommand({
    Name = "fireallclickprompt",
    Aliases = {"massfire", "autofireall"},
    Description = "Automatically triggers every Prompt and ClickDetector in the game regardless of distance."
}, function()
    Modules.InterstellarInteraction:Toggle()
end)
Modules.IdentityPhantom = {
    State = {
        IsEnabled = false,
        OriginalIndex = nil
    }
}
function Modules.IdentityPhantom:Toggle(targetUser: string?): ()
    local success, mt = pcall(getrawmetatable, game)
    if not success or not mt then return end
    self.State.IsEnabled = not self.State.IsEnabled
    if self.State.IsEnabled then
        self.State.OriginalIndex = mt.__index
        local originalIndex = self.State.OriginalIndex
        local fakeId: number = 1
        local fakeName: string = targetUser or "Roblox"
        pcall(function()
            if targetUser then
                fakeId = Players:GetUserIdFromNameAsync(targetUser)
            end
        end)
        setreadonly(mt, false)
        mt.__index = newcclosure(function(selfArg, key)
            if Modules.IdentityPhantom.State.IsEnabled and selfArg == LocalPlayer then
                if key == "UserId" or key == "userId" then return fakeId end
                if key == "Name" or key == "name" then return fakeName end
            end
            return originalIndex(selfArg, key)
        end)
        setreadonly(mt, true)
        DoNotif("Identity Phantom: Masked as " .. fakeName, 3)
    else
        setreadonly(mt, false)
        mt.__index = self.State.OriginalIndex
        setreadonly(mt, true)
        DoNotif("Identity Phantom: Mask REMOVED", 2)
    end
end
RegisterCommand({
    Name = "nchange",
    Aliases = {"mask"},
    Description = "Locally spoofs your Name and UserId to fool group-based admin scripts."
}, function(args: {string})
    Modules.IdentityPhantom:Toggle(args[1])
end)
Modules.InventorySynth = {
    State = {
        DiscoveredTools = {}
    }
}
function Modules.InventorySynth:Scan()
    table.clear(self.State.DiscoveredTools)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            table.insert(self.State.DiscoveredTools, obj)
        end
    end
    DoNotif("Synthesis: Found " .. #self.State.DiscoveredTools .. " tool templates.", 3)
end
function Modules.InventorySynth:CloneTool(name)
    local lowerName = name:lower()
    for _, tool in ipairs(self.State.DiscoveredTools) do
        if tool.Name:lower():find(lowerName) then
            local clone = tool:Clone()
            clone.Parent = Players.LocalPlayer.Backpack
            DoNotif("Synthesized: " .. tool.Name, 2)
            return
        end
    end
    DoNotif("Tool not found in cache. Run ;scantools first.", 3)
end
RegisterCommand({
    Name = "scantools",
    Aliases = {"findgears"},
    Description = "Scans ReplicatedStorage for Tool templates."
}, function()
    Modules.InventorySynth:Scan()
end)
RegisterCommand({
    Name = "gettool",
    Aliases = {},
    Description = "Clones a discovered tool to your backpack."
}, function(args)
    if #args > 0 then
        Modules.InventorySynth:CloneTool(args[1])
    else
        DoNotif("Usage: ;gettool [ToolName]", 3)
    end
end)
Modules.PromptForensics = {
    State = {
        OriginalSettings = {}
    }
}
function Modules.PromptForensics:Expose()
    local count = 0
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = 50
            prompt.Enabled = true
            prompt.RequiresLineOfSight = false
            count = count + 1
        end
    end
    DoNotif("Forensics: Optimized " .. count .. " prompts. (0s Hold, 50 Distance)", 3)
end
RegisterCommand({
    Name = "forceprompt",
    Aliases = {},
    Description = "Forces all proximity prompts to be instant and high-range."
}, function()
    Modules.PromptForensics:Expose()
end)
Modules.AnimSynth = {
    State = {
        GeneratedID = nil
    }
}
function Modules.AnimSynth:GenerateCustomPose(poseType)
    local sequence = Instance.new("KeyframeSequence")
    local keyframe = Instance.new("Keyframe")
    keyframe.Time = 0
    keyframe.Parent = sequence
    local hash = "rbxassetid://0"
    local root = Instance.new("Pose")
    root.Name = "HumanoidRootPart"
    root.Weight = 1
    local torso = Instance.new("Pose")
    torso.Name = "Torso"
    torso.CFrame = CFrame.Angles(math.rad(45), 0, 0)
    torso.Parent = root
    if poseType == "ghost" then
        torso.CFrame = CFrame.new(0, 5, 0)
    elseif poseType == "broken" then
        torso.CFrame = CFrame.Angles(0, math.rad(180), 0)
    end
    root.Parent = keyframe
    pcall(function()
        local provider = game:GetService("KeyframeSequenceProvider")
        hash = provider:RegisterActiveKeyframeSequence(sequence)
    end)
    self.State.GeneratedID = hash
    print("  [!] Custom Animation Generated: " .. hash)
    setclipboard(hash)
    DoNotif("Custom Pose Ready! ID copied to clipboard.", 4)
end
RegisterCommand({
    Name = "localanim",
    Aliases = {},
    Description = "Generates a custom local animation ID. Options: ghost, broken, normal"
}, function(args)
    Modules.AnimSynth:GenerateCustomPose(args[1] or "normal")
end)
Modules.ToolAnimForensics = {
    State = {
        IsEnabled = false,
        ToolAnims = {},
        SwappedIds = {},
        OriginalNamecall = nil
    }
}
function Modules.ToolAnimForensics:Scan()
    local char = Players.LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then
        return DoNotif("Tool Anim: No tool equipped to scan.", 3)
    end
    table.clear(self.State.ToolAnims)
    local count = 0
    for _, obj in ipairs(tool:GetDescendants()) do
        if obj:IsA("Animation") then
            count = count + 1
            local animName = obj.Name:lower()
            self.State.ToolAnims[animName] = obj
            print(string.format("  [+] Found Animation: '%s' | ID: %s", obj.Name, obj.AnimationId))
        end
    end
    DoNotif(string.format("Scan Complete: Found %d animations in %s. Check F9.", count, tool.Name), 4)
end
function Modules.ToolAnimForensics:Hook()
    if self.State.OriginalNamecall then return end
    local mt = getrawmetatable(game)
    self.State.OriginalNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(selfArg, ...)
        local method = getnamecallmethod()
        local args = {...}
        if (method == "LoadAnimation" or method == "loadAnimation") and args[1]:IsA("Animation") then
            local animObj = args[1]
            local replacement = Modules.ToolAnimForensics.State.SwappedIds[animObj.AnimationId]
            if replacement then
                animObj.AnimationId = replacement
            end
        end
        return Modules.ToolAnimForensics.State.OriginalNamecall(selfArg, ...)
    end)
    setreadonly(mt, true)
end
function Modules.ToolAnimForensics:Set(name, newId)
    local targetName = name:lower()
    local animObj = self.State.ToolAnims[targetName]
    if not animObj then
        local tool = Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        animObj = tool and tool:FindFirstChild(name, true)
    end
    if animObj and animObj:IsA("Animation") then
        local rawId = "rbxassetid://" .. newId:match("%d+")
        self.State.SwappedIds[animObj.AnimationId] = rawId
        animObj.AnimationId = rawId
        self:Hook()
        DoNotif("Swapped '" .. name .. "' with " .. rawId, 3)
        local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation.AnimationId == animObj.AnimationId then
                    track:Stop()
                end
            end
        end
    else
        DoNotif("Animation '" .. name .. "' not found. Use ;scananim first.", 3)
    end
end
RegisterCommand({
    Name = "scananim",
    Aliases = {"listanims", "toolanims"},
    Description = "Scans the equipped tool for animations and lists them in the console."
}, function()
    Modules.ToolAnimForensics:Scan()
end)
RegisterCommand({
    Name = "setanim",
    Aliases = {"swapanim"},
    Description = "Swaps a tool animation. Usage: ;setanim [name] [id]"
}, function(args)
    if #args < 2 then
        return DoNotif("Usage: ;setanim [Idle/Attack/etc] [ID]", 3)
    end
    Modules.ToolAnimForensics:Set(args[1], args[2])
end)
Modules.Aggressor = {
    State = {
        IsEnabled = false,
        TargetPlayer = nil,
        LoopThread = nil,
        Index = 0
    },
    Config = {
        Frequency = 0.35,
        OffsetDistance = 1.5,
        VerticalAdjustment = 1
    },
    Dependencies = {"Players", "RunService"},
    Services = {}
}
function Modules.Aggressor:Stop()
    self.State.IsEnabled = false
    if self.State.LoopThread then
        task.cancel(self.State.LoopThread)
        self.State.LoopThread = nil
    end
    local char = game:GetService("Players").LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    end
    self.State.TargetPlayer = nil
    DoNotif("Aggressor sequence terminated.", 2)
end
function Modules.Aggressor:Start(targetPlayer)
    if self.State.IsEnabled then self:Stop() end
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return DoNotif("Character not found.", 3) end
    self.State.IsEnabled = true
    self.State.TargetPlayer = targetPlayer
    self.State.Index = 0
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum.Sit = false
    self.State.LoopThread = task.spawn(function()
        while self.State.IsEnabled do
            local tChar = targetPlayer.Character
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not (tChar and tHum and tRoot and char.Parent and hum.Health > 0) then
                self:Stop()
                break
            end
            self.State.Index += self.Config.Frequency
            if tHum.FloorMaterial == Enum.Material.Air and hum.FloorMaterial ~= Enum.Material.Air and not tHum.Sit then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            local sinValue = math.sin(self.State.Index) * self.Config.OffsetDistance
            local offset
            if tHum.Sit then
                offset = CFrame.new(0, 0, -self.Config.OffsetDistance + sinValue)
            else
                offset = CFrame.new(0, 0, self.Config.OffsetDistance + sinValue)
            end
            local targetGoal = tRoot.CFrame * offset
            root.CFrame = CFrame.new(targetGoal.Position, Vector3.new(tRoot.Position.X, root.Position.Y, tRoot.Position.Z))
            task.wait()
        end
    end)
    DoNotif("Aggressor sequence started on " .. targetPlayer.Name, 2)
end
RegisterCommand({
    Name = "bang",
    Aliases = {},
    Description = "Starts a baby making process."
}, function(args)
    local target = Utilities.findPlayer(args[1] or "")
    if target and target ~= game:GetService("Players").LocalPlayer then
        Modules.Aggressor:Start(target)
    else
        DoNotif("Invalid player target.", 3)
    end
end)
RegisterCommand({
    Name = "unbang",
    Aliases = {},
    Description = "Stops the baby making process."
}, function()
    Modules.Aggressor:Stop()
end)
Modules.Hugger = {
    State = {
        IsEnabled = false,
        FromFront = false,
        Target = nil,
        Tracks = {},
        Walls = {},
        UI = nil,
        Connections = {}
    },
    Config = {
        ANIM_1 = "rbxassetid://283545583",
        ANIM_2 = "rbxassetid://225975820",
        OFFSET = 1.5
    },
    Dependencies = {"Players", "RunService", "CoreGui", "UserInputService"},
    Services = {}
}
function Modules.Hugger:_clearCurrent()
    for _, track in pairs(self.State.Tracks) do
        pcall(function() track:Stop() end)
    end
    self.State.Tracks = {}
    for _, part in pairs(self.State.Walls) do
        pcall(function() part:Destroy() end)
    end
    self.State.Walls = {}
    if self.State.Connections.Loop then
        self.State.Connections.Loop:Disconnect()
        self.State.Connections.Loop = nil
    end
    self.State.Target = nil
end
function Modules.Hugger:_createCage(root)
    local thick = 0.2
    local size = 4
    local height = 6
    local wallData = {
        {off = CFrame.new(0, 0, 2), sz = Vector3.new(size, height, thick)},
        {off = CFrame.new(0, 0, -2), sz = Vector3.new(size, height, thick)},
        {off = CFrame.new(2, 0, 0), sz = Vector3.new(thick, height, size)},
        {off = CFrame.new(-2, 0, 0), sz = Vector3.new(thick, height, size)},
        {off = CFrame.new(0, 3, 0), sz = Vector3.new(size, thick, size)},
        {off = CFrame.new(0, -3, 0), sz = Vector3.new(size, thick, size)}
    }
    for _, data in ipairs(wallData) do
        local p = Instance.new("Part")
        p.Size = data.sz
        p.Transparency = 1
        p.Anchored = true
        p.CanCollide = true
        p.Parent = workspace
        table.insert(self.State.Walls, p)
    end
    self.State.Connections.Cage = self.Services.RunService.Stepped:Connect(function()
        if not self.State.IsEnabled or not root.Parent then return end
        for i, data in ipairs(wallData) do
            local part = self.State.Walls[i]
            if part then part.CFrame = root.CFrame * data.off end
        end
    end)
end
function Modules.Hugger:Apply(targetChar)
    local lp = self.Services.Players.LocalPlayer
    local myChar = lp.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not (myHum and myRoot and tRoot) then return end
    self:_clearCurrent()
    self.State.Target = targetChar
    local a1, a2 = Instance.new("Animation"), Instance.new("Animation")
    a1.AnimationId = self.Config.ANIM_1
    a2.AnimationId = self.Config.ANIM_2
    local tr1 = myHum:LoadAnimation(a1)
    local tr2 = myHum:LoadAnimation(a2)
    table.insert(self.State.Tracks, tr1)
    table.insert(self.State.Tracks, tr2)
    tr1:Play()
    tr2:Play()
    self:_createCage(myRoot)
    self.State.Connections.Loop = self.Services.RunService.Heartbeat:Connect(function()
        if not self.State.IsEnabled or not tRoot.Parent or myHum.Health <= 0 then
            self:Toggle()
            return
        end
        local look = tRoot.CFrame.LookVector
        local offset = self.State.FromFront and (look * self.Config.OFFSET) or (-look * self.Config.OFFSET)
        myRoot.CFrame = CFrame.lookAt(tRoot.Position + offset, tRoot.Position)
    end)
end
function Modules.Hugger:CreateUI()
    if self.State.UI then self.State.UI.Enabled = true return end
    local sg = Instance.new("ScreenGui", self.Services.CoreGui)
    sg.Name = "HugController_Zuka"
    self.State.UI = sg
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.fromOffset(200, 100)
    frame.Position = UDim2.new(0.5, -100, 0.1, 0)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BackgroundTransparency = 0.5
    Instance.new("UICorner", frame)
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(1, -10, 0, 40)
    toggle.Position = UDim2.fromOffset(5, 5)
    toggle.Text = "Hug Mode: OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.Code
    local side = toggle:Clone()
    side.Parent = frame
    side.Position = UDim2.fromOffset(5, 50)
    side.Text = "Hug Side: Back"
    toggle.MouseButton1Click:Connect(function()
        self.State.IsEnabled = not self.State.IsEnabled
        toggle.Text = "Hug Mode: " .. (self.State.IsEnabled and "ON" or "OFF")
        toggle.TextColor3 = self.State.IsEnabled and Color3.new(0, 1, 0.5) or Color3.new(1,1,1)
        if not self.State.IsEnabled then self:_clearCurrent() end
    end)
    side.MouseButton1Click:Connect(function()
        self.State.FromFront = not self.State.FromFront
        side.Text = "Hug Side: " .. (self.State.FromFront and "Front" or "Back")
    end)
    local mouse = self.Services.Players.LocalPlayer:GetMouse()
    self.State.Connections.Click = mouse.Button1Down:Connect(function()
        if not self.State.IsEnabled then return end
        local target = mouse.Target
        if target and target.Parent then
            local p = self.Services.Players:GetPlayerFromCharacter(target.Parent)
            if p and p ~= self.Services.Players.LocalPlayer then
                self:Apply(p.Character)
            end
        end
    end)
    DoNotif("Hugger UI Loaded. Enable and Click a player.", 3)
end
function Modules.Hugger:Initialize()
    for _, s in ipairs(self.Dependencies) do self.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "hug",
        Aliases = {"huggies", "clickhug"},
        Description = "Toggles a UI for physical character interaction (R6 Only)."
    }, function()
        local lp = game:GetService("Players").LocalPlayer
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.RigType == Enum.HumanoidRigType.R6 then
            self:CreateUI()
        else
            DoNotif("This command requires an R6 Avatar.", 3)
        end
    end)
    RegisterCommand({
        Name = "unhug",
        Description = "Force stops all hug interactions and UI."
    }, function()
        self.State.IsEnabled = false
        self:_clearCurrent()
        if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil end
        if self.State.Connections.Click then self.State.Connections.Click:Disconnect() end
    end)
end
Modules.TeamChanger = {
    State = {
        IsExecuting = false
    },
    Dependencies = {"Teams", "Players", "Workspace"},
    Services = {}
}
function Modules.TeamChanger:Execute(teamNameInput)
    if not teamNameInput or teamNameInput == "" then
        return DoNotif("Usage: ;team <TeamName>", 3)
    end
    local Teams = self.Services.Teams
    if not Teams then return end
    local targetTeam = nil
    local lookup = teamNameInput:lower()
    for _, team in ipairs(Teams:GetChildren()) do
        if team:IsA("Team") and team.Name:lower():find(lookup, 1, true) then
            targetTeam = team
            break
        end
    end
    if not targetTeam then
        return DoNotif("Invalid team: '" .. teamNameInput .. "'", 3)
    end
    local lp = self.Services.Players.LocalPlayer
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local function forceClientSide()
        pcall(function()
            lp.Neutral = false
            lp.Team = targetTeam
        end)
    end
    if typeof(firetouchinterest) == "function" and root then
        local foundSpawn = false
        for _, obj in ipairs(self.Services.Workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") and obj.BrickColor == targetTeam.TeamColor and obj.AllowTeamChangeOnTouch then
                firetouchinterest(root, obj, 0)
                task.wait()
                firetouchinterest(root, obj, 1)
                foundSpawn = true
                break
            end
        end
        if foundSpawn then
            DoNotif("Spawn sequence triggered for " .. targetTeam.Name, 2)
        end
    end
    forceClientSide()
    DoNotif("Joined Team: " .. targetTeam.Name, 2)
end
function Modules.TeamChanger:Initialize()
    local module = self
    for _, s in ipairs(self.Dependencies) do
        module.Services[s] = game:GetService(s)
    end
    RegisterCommand({
        Name = "team",
        Aliases = {"setteam", "join"},
        Description = "Forces a team change via spawn-touch emulation or property spoofing."
    }, function(args)
        module:Execute(table.concat(args, " "))
    end)
end
Modules.ScriptSearcher = {
    State = {
        IsEnabled = false,
        UI = {},
        Connections = {},
        IsSearching = false,
        LastQuery = "",
        LastResults = {},
        CurrentPage = 1,
        ResultsPerPage = 20,
        SearchHistory = {},
        SortMode = "newest",
        ActiveFilters = {},
        CurrentSource = "scriptblox",
        GameInfo = {},
        GameScripts = {}
    },
    Config = {
        ACCENT = Color3.fromRGB(0, 255, 255),
        BG = Color3.fromRGB(20, 20, 20),
        APIs = {
            scriptblox = "https://scriptblox.com/api/script/search?q=%s&mode=free&max=100",
            pastebin = "https://pastebin.com/api/v1/paste/list?api_dev_key=YOUR_KEY&results_limit=100",
        },
        MAX_HISTORY = 15
    },
    Dependencies = {"HttpService", "Players", "CoreGui", "UserInputService", "RunService"},
    Services = {}
}
function Modules.ScriptSearcher:SearchGameScripts()
    if self.State.IsSearching then return end
    self.State.IsSearching = true
    self.State.CurrentPage = 1
    self.State.LastResults = {}
    local gameId = game.GameId
    self.State.LastQuery = "game:" .. gameId
    local scroll = self.State.UI.ResultScroll
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local status = Instance.new("TextLabel", scroll)
    status.Size = UDim2.new(1, 0, 0, 30); status.BackgroundTransparency = 1
    status.Text = "Searching scripts for game " .. gameId .. "..."; status.TextColor3 = self.Config.ACCENT
    status.Font = Enum.Font.Code; status.TextSize = 14
    task.spawn(function()
        local requestFunc = (typeof(request) == "function" and request) or (typeof(syn) == "table" and syn.request) or (typeof(http) == "table" and http.request)
        if not requestFunc then
            status.Text = "ERR: NO HTTP CAPABILITY"
            self.State.IsSearching = false
            return
        end
        local apiUrl = self.Config.APIs[self.State.CurrentSource] or self.Config.APIs.scriptblox
        local url = apiUrl:format(self.Services.HttpService:UrlEncode("game:" .. gameId))
        local success, res = pcall(function() return requestFunc({Url = url, Method = "GET"}) end)
        if success and res.StatusCode == 200 then
            status:Destroy()
            local data = self.Services.HttpService:JSONDecode(res.Body)
            if data.result and data.result.scripts then
                self.State.LastResults = data.result.scripts
                self.State.GameScripts = self.State.LastResults
                self:_displayPage(1)
                DoNotif("Found " .. #self.State.LastResults .. " scripts for this game.", 2)
            else
                status.Text = "No scripts found for this game."
            end
        else
            status.Text = "API Link Failed."
        end
        self.State.IsSearching = false
    end)
end
function Modules.ScriptSearcher:FetchGameInfo()
    local gameId = game.GameId
    local players = self.Services.Players:GetPlayers()
    self.State.GameInfo = {
        GameId = gameId,
        GameName = game:GetService("MarketplaceService"):GetProductInfo(gameId).Name,
        Creator = "Unknown",
        PlayerCount = #players,
        MaxPlayers = self.Services.Players.MaxPlayers,
        Description = game:GetService("MarketplaceService"):GetProductInfo(gameId).Description
    }
    return self.State.GameInfo
end
function Modules.ScriptSearcher:PerformSearch(query)
    if self.State.IsSearching then return end
    if query == "" then return DoNotif("Enter a search query.", 2) end
    self.State.IsSearching = true
    self.State.LastQuery = query
    self.State.CurrentPage = 1
    self.State.LastResults = {}
    if not table.find(self.State.SearchHistory, query) then
        table.insert(self.State.SearchHistory, 1, query)
        if #self.State.SearchHistory > self.Config.MAX_HISTORY then
            table.remove(self.State.SearchHistory, #self.State.SearchHistory)
        end
    end
    local scroll = self.State.UI.ResultScroll
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local status = Instance.new("TextLabel", scroll)
    status.Size = UDim2.new(1, 0, 0, 30); status.BackgroundTransparency = 1
    status.Text = "Searching '" .. self.State.CurrentSource .. "'..."; status.TextColor3 = self.Config.ACCENT
    status.Font = Enum.Font.Code; status.TextSize = 14
    task.spawn(function()
        local requestFunc = (typeof(request) == "function" and request) or (typeof(syn) == "table" and syn.request) or (typeof(http) == "table" and http.request)
        if not requestFunc then
            status.Text = "ERR: NO HTTP CAPABILITY"
            self.State.IsSearching = false
            return
        end
        local apiUrl = self.Config.APIs[self.State.CurrentSource] or self.Config.APIs.scriptblox
        local url = apiUrl:format(self.Services.HttpService:UrlEncode(query))
        local success, res = pcall(function() return requestFunc({Url = url, Method = "GET"}) end)
        if success and res.StatusCode == 200 then
            status:Destroy()
            local data = self.Services.HttpService:JSONDecode(res.Body)
            if data.result and data.result.scripts then
                self.State.LastResults = data.result.scripts
                self:_displayPage(1)
                DoNotif("Found " .. #self.State.LastResults .. " results.", 2)
            else
                status.Text = "No results found."
            end
        else
            status.Text = "API Link Failed."
        end
        self.State.IsSearching = false
    end)
end
function Modules.ScriptSearcher:_displayPage(page)
    local scroll = self.State.UI.ResultScroll
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local startIdx = (page - 1) * self.State.ResultsPerPage + 1
    local endIdx = math.min(page * self.State.ResultsPerPage, #self.State.LastResults)
    if startIdx > #self.State.LastResults then
        local noMore = Instance.new("TextLabel", scroll)
        noMore.Size = UDim2.new(1, 0, 0, 30); noMore.BackgroundTransparency = 1
        noMore.Text = "No more results."; noMore.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end
    for i = startIdx, endIdx do
        self:_createResultCard(self.State.LastResults[i])
    end
    local pageInfo = Instance.new("TextLabel", scroll)
    pageInfo.Size = UDim2.new(1, 0, 0, 20); pageInfo.BackgroundTransparency = 1
    pageInfo.Text = "Page " .. page .. " of " .. math.ceil(#self.State.LastResults / self.State.ResultsPerPage)
    pageInfo.TextColor3 = self.Config.ACCENT; pageInfo.Font = Enum.Font.Code; pageInfo.TextSize = 10
    self.State.CurrentPage = page
end
function Modules.ScriptSearcher:RefreshSearch()
    if self.State.LastQuery == "" then
        return DoNotif("No previous search to refresh.", 2)
    end
    self:PerformSearch(self.State.LastQuery)
end
function Modules.ScriptSearcher:NextPage()
    local maxPage = math.ceil(#self.State.LastResults / self.State.ResultsPerPage)
    if self.State.CurrentPage < maxPage then
        self:_displayPage(self.State.CurrentPage + 1)
    else
        DoNotif("Already on last page.", 2)
    end
end
function Modules.ScriptSearcher:PrevPage()
    if self.State.CurrentPage > 1 then
        self:_displayPage(self.State.CurrentPage - 1)
    else
        DoNotif("Already on first page.", 2)
    end
end
function Modules.ScriptSearcher:SetSort(mode)
    self.State.SortMode = mode
    if #self.State.LastResults > 0 then
        if mode == "popular" then
            table.sort(self.State.LastResults, function(a, b)
                return (a.favorites or 0) > (b.favorites or 0)
            end)
        elseif mode == "newest" then
            table.sort(self.State.LastResults, function(a, b)
                return (a.updated_at or 0) > (b.updated_at or 0)
            end)
        end
        self:_displayPage(1)
    end
end
function Modules.ScriptSearcher:SetSource(source)
    if self.Config.APIs[source] then
        self.State.CurrentSource = source
        DoNotif("Source switched to: " .. source, 2)
    end
end
function Modules.ScriptSearcher:ShowHistory()
    local scroll = self.State.UI.ResultScroll
    for _, v in ipairs(scroll:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    if #self.State.SearchHistory == 0 then
        local empty = Instance.new("TextLabel", scroll)
        empty.Size = UDim2.new(1, 0, 0, 30); empty.BackgroundTransparency = 1
        empty.Text = "No search history."; empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end
    for _, query in ipairs(self.State.SearchHistory) do
        local historyBtn = Instance.new("TextButton", scroll)
        historyBtn.Size = UDim2.new(1, -10, 0, 30)
        historyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        historyBtn.BorderSizePixel = 1; historyBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
        historyBtn.Text = "🔍 " .. query; historyBtn.TextColor3 = self.Config.ACCENT
        historyBtn.Font = Enum.Font.Code; historyBtn.TextSize = 11
        historyBtn.MouseButton1Click:Connect(function()
            self:PerformSearch(query)
        end)
    end
end
function Modules.ScriptSearcher:_createResultCard(data)
    local scroll = self.State.UI.ResultScroll
    local card = Instance.new("Frame", scroll)
    card.Size = UDim2.new(1, -10, 0, 65)
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    card.BorderSizePixel = 1; card.BorderColor3 = Color3.fromRGB(60, 60, 60)
    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -100, 0, 25); title.Position = UDim2.fromOffset(5, 5)
    title.Text = data.title; title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.Code; title.TextSize = 13; title.TextXAlignment = "Left"
    title.BackgroundTransparency = 1; title.ClipsDescendants = true
    local gameLabel = Instance.new("TextLabel", card)
    gameLabel.Size = UDim2.new(1, -100, 0, 20); gameLabel.Position = UDim2.fromOffset(5, 30)
    gameLabel.Text = "Game: " .. (data.game.name or "Universal")
    gameLabel.TextColor3 = Color3.fromRGB(150, 150, 150); gameLabel.Font = Enum.Font.Code
    gameLabel.TextSize = 11; gameLabel.TextXAlignment = "Left"; gameLabel.BackgroundTransparency = 1
    local function mkBtn(text, xPos, color, callback)
        local b = Instance.new("TextButton", card)
        b.Size = UDim2.fromOffset(80, 22); b.Position = UDim2.new(1, xPos, 0, 20)
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.BorderSizePixel = 1; b.BorderColor3 = color
        b.Text = text; b.TextColor3 = color; b.Font = Enum.Font.Code; b.TextSize = 10
        b.MouseButton1Click:Connect(callback)
        return b
    end
    mkBtn("EXECUTE", -85, self.Config.ACCENT, function()
        local func, err = loadstring(data.script)
        if func then task.spawn(func); DoNotif("Executed: " .. data.title, 2)
        else warn(err); DoNotif("Syntax Error in script.", 3) end
    end)
    mkBtn("COPY", -170, Color3.fromRGB(200, 150, 100), function()
        setclipboard(data.script)
        DoNotif("Script copied to clipboard.", 2)
    end)
    mkBtn("VIEW", -255, Color3.fromRGB(200, 100, 255), function()
        print("--- [SOURCE: " .. data.title .. "] ---")
        print(data.script)
        print("--------------------------------------")
        DoNotif("Source printed to F9 Console.", 2)
    end)
end
function Modules.ScriptSearcher:CreateUI()
    if self.State.UI.Main then self.State.UI.Main.Visible = true return end
    local sg = Instance.new("ScreenGui", self.Services.CoreGui)
    sg.Name = "Zuka_ScriptHub_RC8"
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.fromOffset(600, 550)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    main.BorderSizePixel = 2; main.BorderColor3 = self.Config.ACCENT; main.Active = true
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundColor3 = Color3.fromRGB(30, 30, 30); header.BorderSizePixel = 0
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(0.7, -60, 1, 0); title.Position = UDim2.fromOffset(10, 0)
    title.Text = "DATABASE BROWSER v2"; title.TextColor3 = self.Config.ACCENT
    title.Font = Enum.Font.Code; title.TextSize = 14; title.TextXAlignment = "Left"; title.BackgroundTransparency = 1
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.fromOffset(30, 30); close.Position = UDim2.new(1, -30, 0, 0)
    close.Text = "X"; close.TextColor3 = Color3.new(1,0,0); close.BackgroundTransparency = 1
    close.MouseButton1Click:Connect(function() sg:Destroy(); self.State.UI = {} end)
    local searchBar = Instance.new("TextBox", main)
    searchBar.Size = UDim2.new(1, -230, 0, 30); searchBar.Position = UDim2.fromOffset(10, 40)
    searchBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); searchBar.BorderSizePixel = 1; searchBar.BorderColor3 = Color3.fromRGB(80, 80, 80)
    searchBar.PlaceholderText = "Enter keywords..."; searchBar.Text = ""
    searchBar.TextColor3 = Color3.new(1,1,1); searchBar.Font = Enum.Font.Code; searchBar.TextSize = 14
    local gameSearchBtn = Instance.new("TextButton", main)
    gameSearchBtn.Size = UDim2.fromOffset(80, 30); gameSearchBtn.Position = UDim2.new(1, -300, 0, 40)
    gameSearchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); gameSearchBtn.BorderSizePixel = 1; gameSearchBtn.BorderColor3 = Color3.fromRGB(100, 200, 150)
    gameSearchBtn.Text = "GAME"; gameSearchBtn.TextColor3 = Color3.fromRGB(100, 255, 150); gameSearchBtn.Font = Enum.Font.Code; gameSearchBtn.TextSize = 10
    gameSearchBtn.MouseButton1Click:Connect(function() self:SearchGameScripts() end)
    local searchBtn = Instance.new("TextButton", main)
    searchBtn.Size = UDim2.fromOffset(70, 30); searchBtn.Position = UDim2.new(1, -210, 0, 40)
    searchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); searchBtn.BorderSizePixel = 1; searchBtn.BorderColor3 = self.Config.ACCENT
    searchBtn.Text = "SEARCH"; searchBtn.TextColor3 = self.Config.ACCENT; searchBtn.Font = Enum.Font.Code; searchBtn.TextSize = 10
    searchBtn.MouseButton1Click:Connect(function() self:PerformSearch(searchBar.Text) end)
    local refreshBtn = Instance.new("TextButton", main)
    refreshBtn.Size = UDim2.fromOffset(70, 30); refreshBtn.Position = UDim2.new(1, -140, 0, 40)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); refreshBtn.BorderSizePixel = 1; refreshBtn.BorderColor3 = Color3.fromRGB(100, 150, 100)
    refreshBtn.Text = "REFRESH"; refreshBtn.TextColor3 = Color3.fromRGB(100, 200, 100); refreshBtn.Font = Enum.Font.Code; refreshBtn.TextSize = 10
    refreshBtn.MouseButton1Click:Connect(function() self:RefreshSearch() end)
    local historyBtn = Instance.new("TextButton", main)
    historyBtn.Size = UDim2.fromOffset(60, 30); historyBtn.Position = UDim2.new(1, -70, 0, 40)
    historyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); historyBtn.BorderSizePixel = 1; historyBtn.BorderColor3 = Color3.fromRGB(150, 100, 200)
    historyBtn.Text = "HISTORY"; historyBtn.TextColor3 = Color3.fromRGB(200, 150, 255); historyBtn.Font = Enum.Font.Code; historyBtn.TextSize = 9
    historyBtn.MouseButton1Click:Connect(function() self:ShowHistory() end)
    local sortLabel = Instance.new("TextLabel", main)
    sortLabel.Size = UDim2.fromOffset(40, 25); sortLabel.Position = UDim2.fromOffset(10, 75)
    sortLabel.Text = "Sort:"; sortLabel.TextColor3 = self.Config.ACCENT; sortLabel.BackgroundTransparency = 1
    sortLabel.Font = Enum.Font.Code; sortLabel.TextSize = 10
    local sortBtn = Instance.new("TextButton", main)
    sortBtn.Size = UDim2.fromOffset(80, 25); sortBtn.Position = UDim2.fromOffset(55, 75)
    sortBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); sortBtn.BorderSizePixel = 1; sortBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
    sortBtn.Text = "NEWEST"; sortBtn.TextColor3 = Color3.new(1,1,1); sortBtn.Font = Enum.Font.Code; sortBtn.TextSize = 9
    local sortModes = {"newest", "popular"}
    local sortIndex = 1
    sortBtn.MouseButton1Click:Connect(function()
        sortIndex = sortIndex % #sortModes + 1
        sortBtn.Text = sortModes[sortIndex]:upper()
        self:SetSort(sortModes[sortIndex])
    end)
    local sourceLabel = Instance.new("TextLabel", main)
    sourceLabel.Size = UDim2.fromOffset(45, 25); sourceLabel.Position = UDim2.fromOffset(145, 75)
    sourceLabel.Text = "Source:"; sourceLabel.TextColor3 = self.Config.ACCENT; sourceLabel.BackgroundTransparency = 1
    sourceLabel.Font = Enum.Font.Code; sourceLabel.TextSize = 10
    local sourceBtn = Instance.new("TextButton", main)
    sourceBtn.Size = UDim2.fromOffset(90, 25); sourceBtn.Position = UDim2.fromOffset(195, 75)
    sourceBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); sourceBtn.BorderSizePixel = 1; sourceBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
    sourceBtn.Text = "SCRIPTBLOX"; sourceBtn.TextColor3 = Color3.new(1,1,1); sourceBtn.Font = Enum.Font.Code; sourceBtn.TextSize = 9
    local sources = {"scriptblox"}
    local sourceIndex = 1
    sourceBtn.MouseButton1Click:Connect(function()
        sourceIndex = sourceIndex % #sources + 1
        sourceBtn.Text = sources[sourceIndex]:upper()
        self:SetSource(sources[sourceIndex])
    end)
    local resultsPerPageLabel = Instance.new("TextLabel", main)
    resultsPerPageLabel.Size = UDim2.fromOffset(55, 25); resultsPerPageLabel.Position = UDim2.fromOffset(295, 75)
    resultsPerPageLabel.Text = "Per Page:"; resultsPerPageLabel.TextColor3 = self.Config.ACCENT; resultsPerPageLabel.BackgroundTransparency = 1
    resultsPerPageLabel.Font = Enum.Font.Code; resultsPerPageLabel.TextSize = 10
    local resultsPerPageBtn = Instance.new("TextButton", main)
    resultsPerPageBtn.Size = UDim2.fromOffset(60, 25); resultsPerPageBtn.Position = UDim2.fromOffset(355, 75)
    resultsPerPageBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); resultsPerPageBtn.BorderSizePixel = 1; resultsPerPageBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
    resultsPerPageBtn.Text = "20"; resultsPerPageBtn.TextColor3 = Color3.new(1,1,1); resultsPerPageBtn.Font = Enum.Font.Code; resultsPerPageBtn.TextSize = 9
    local pageOptions = {10, 20, 50}
    local pageIndex = 2
    resultsPerPageBtn.MouseButton1Click:Connect(function()
        pageIndex = pageIndex % #pageOptions + 1
        self.State.ResultsPerPage = pageOptions[pageIndex]
        resultsPerPageBtn.Text = tostring(pageOptions[pageIndex])
        if #self.State.LastResults > 0 then
            self:_displayPage(1)
        end
    end)
    local prevPageBtn = Instance.new("TextButton", main)
    prevPageBtn.Size = UDim2.fromOffset(60, 25); prevPageBtn.Position = UDim2.new(1, -180, 0, 75)
    prevPageBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); prevPageBtn.BorderSizePixel = 1; prevPageBtn.BorderColor3 = self.Config.ACCENT
    prevPageBtn.Text = "◄ PREV"; prevPageBtn.TextColor3 = self.Config.ACCENT; prevPageBtn.Font = Enum.Font.Code; prevPageBtn.TextSize = 9
    prevPageBtn.MouseButton1Click:Connect(function() self:PrevPage() end)
    local nextPageBtn = Instance.new("TextButton", main)
    nextPageBtn.Size = UDim2.fromOffset(60, 25); nextPageBtn.Position = UDim2.new(1, -110, 0, 75)
    nextPageBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); nextPageBtn.BorderSizePixel = 1; nextPageBtn.BorderColor3 = self.Config.ACCENT
    nextPageBtn.Text = "NEXT ►"; nextPageBtn.TextColor3 = self.Config.ACCENT; nextPageBtn.Font = Enum.Font.Code; nextPageBtn.TextSize = 9
    nextPageBtn.MouseButton1Click:Connect(function() self:NextPage() end)
    local gameInfoPanel = Instance.new("Frame", main)
    gameInfoPanel.Size = UDim2.new(1, -20, 0, 85); gameInfoPanel.Position = UDim2.fromOffset(10, 105)
    gameInfoPanel.BackgroundColor3 = Color3.fromRGB(25, 35, 40); gameInfoPanel.BorderSizePixel = 1; gameInfoPanel.BorderColor3 = Color3.fromRGB(100, 200, 150)
    local gameNameLabel = Instance.new("TextLabel", gameInfoPanel)
    gameNameLabel.Size = UDim2.new(1, -10, 0, 20); gameNameLabel.Position = UDim2.fromOffset(5, 3)
    gameNameLabel.Text = "🎮 Game: Loading..."; gameNameLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    gameNameLabel.Font = Enum.Font.Code; gameNameLabel.TextSize = 11; gameNameLabel.TextXAlignment = "Left"; gameNameLabel.BackgroundTransparency = 1
    local gameIdLabel = Instance.new("TextLabel", gameInfoPanel)
    gameIdLabel.Size = UDim2.new(1, -10, 0, 15); gameIdLabel.Position = UDim2.fromOffset(5, 23)
    gameIdLabel.Text = "ID: " .. game.GameId; gameIdLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    gameIdLabel.Font = Enum.Font.Code; gameIdLabel.TextSize = 9; gameIdLabel.TextXAlignment = "Left"; gameIdLabel.BackgroundTransparency = 1
    local playerCountLabel = Instance.new("TextLabel", gameInfoPanel)
    playerCountLabel.Size = UDim2.new(0.5, -5, 0, 15); playerCountLabel.Position = UDim2.fromOffset(5, 38)
    playerCountLabel.Text = "👥 Players: " .. #self.Services.Players:GetPlayers() .. "/" .. self.Services.Players.MaxPlayers
    playerCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150); playerCountLabel.Font = Enum.Font.Code
    playerCountLabel.TextSize = 9; playerCountLabel.TextXAlignment = "Left"; playerCountLabel.BackgroundTransparency = 1
    local scriptCountLabel = Instance.new("TextLabel", gameInfoPanel)
    scriptCountLabel.Size = UDim2.new(0.5, -5, 0, 15); scriptCountLabel.Position = UDim2.new(0.5, 5, 0, 38)
    scriptCountLabel.Text = "📄 Scripts: Searching..."; scriptCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    scriptCountLabel.Font = Enum.Font.Code; scriptCountLabel.TextSize = 9; scriptCountLabel.TextXAlignment = "Left"; scriptCountLabel.BackgroundTransparency = 1
    local descLabel = Instance.new("TextLabel", gameInfoPanel)
    descLabel.Size = UDim2.new(1, -10, 0, 20); descLabel.Position = UDim2.fromOffset(5, 53)
    descLabel.Text = "Description: Loading..."; descLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    descLabel.Font = Enum.Font.Code; descLabel.TextSize = 8; descLabel.TextXAlignment = "Left"; descLabel.TextWrapped = true
    descLabel.BackgroundTransparency = 1
    task.spawn(function()
        local success, gameInfo = pcall(function() return self:FetchGameInfo() end)
        if success and gameInfo then
            gameNameLabel.Text = "🎮 Game: " .. (gameInfo.GameName or "Unknown")
            scriptCountLabel.Text = "📄 Scripts: " .. #self.State.GameScripts .. " available"
            descLabel.Text = "📝 " .. (gameInfo.Description or "No description available"):sub(1, 120)
        else
            gameNameLabel.Text = "🎮 Game: " .. tostring(game.GameId)
            descLabel.Text = "📝 Could not fetch game info"
        end
    end)
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -205); scroll.Position = UDim2.fromOffset(10, 195)
    scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15); scroll.BorderSizePixel = 1; scroll.BorderColor3 = Color3.fromRGB(50, 50, 50)
    scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = self.Config.ACCENT; scroll.AutomaticCanvasSize = "Y"
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5); layout.HorizontalAlignment = "Center"
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, main.Position
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    self.State.UI = {Main = main, ResultScroll = scroll}
    DoNotif("ScriptHub v2 Initialized - Full Featured Search", 2)
end
function Modules.ScriptSearcher:Initialize()
    for _, s in ipairs(self.Dependencies) do self.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "Hub",
        Aliases = {"search", "scripts"},
        Description = "Opens the ScriptBlox database searcher."
    }, function()
        self:CreateUI()
    end)
end
if not getgenv().Modules then getgenv().Modules = {} end
Modules.InternalExecutor = {
    State = {
        IsEnabled = false,
        UI = {},
        Connections = {},
        IsLifting = false,
        VFS_Cache = {},
        VFS_Loading = {},
        VFS_Base = "https://raw.githubusercontent.com/zukatech1/Lifter/main/src/"
    },
    Config = {
        ACCENT = Color3.fromRGB(0, 255, 255),
        BG = Color3.fromRGB(20, 20, 20),
        LIFT_COLOR = Color3.fromRGB(170, 0, 255),
        KEYWORDS = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "execute", "syn", "HttpGet", "HttpPost"},
        GLOBALS = {"getrawmetatable", "game", "Workspace", "script", "math", "string", "table", "print", "wait", "Instance", "Vector3", "CFrame", "Enum", "loadstring", "getgenv", "getrenv", "getreg", "getgc"},
        REMOTES = {"FireServer", "InvokeServer"},
        TOKENS = {["="]=true, ["."]=true, [","]=true, ["("]=true, [")"]=true, ["["]=true, ["]"]=true, ["{"]=true, ["}"]=true, [":"]=true, ["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true, ["%"]=true, [";"]=true, ["~"]=true}
    },
    Dependencies = {"Players", "CoreGui", "UserInputService", "RunService", "TextService", "HttpService"},
    Services = {}
}
function Modules.InternalExecutor:_vRequire(modulePath)
    local state = self.State
    if state.VFS_Cache[modulePath] then
        return state.VFS_Cache[modulePath]
    end
    if state.VFS_Loading[modulePath] then
        return state.VFS_Loading[modulePath]
    end
    local internalPath = modulePath:gsub("%.", "/") .. ".lua"
    local url = state.VFS_Base .. internalPath
    local success, content = pcall(game.HttpGet, game, url)
    if not success or content:find("404: Not Found") then
        local fallbackUrl = "https://raw.githubusercontent.com/zukatech1/Lifter/main/" .. internalPath
        success, content = pcall(game.HttpGet, game, fallbackUrl)
    end
    if not success or content:find("404: Not Found") then
        warn("--> [VFS] Resolution Failed: " .. modulePath)
        return nil
    end
    local func, err = loadstring(content, "@VFS/" .. modulePath)
    if not func then
        warn("--> [VFS] Syntax Error in " .. modulePath .. ": " .. err)
        return nil
    end
    local modulePlaceholder = {}
    state.VFS_Loading[modulePath] = modulePlaceholder
    local env = getfenv(func)
    env.require = function(path) return self:_vRequire(path) end
    env.arg = {}
    env.print = function(...) print("[LIFTER]:", ...) end
    setfenv(func, env)
    local result = func()
    local finalData = result or modulePlaceholder
    state.VFS_Cache[modulePath] = finalData
    state.VFS_Loading[modulePath] = nil
    return finalData
end
function Modules.InternalExecutor:_initializeLifter()
    self.State.VFS_Cache = {}
    self.State.VFS_Loading = {}
    local Parser = self:_vRequire("prometheus.parser")
    local Ast = self:_vRequire("prometheus.ast")
    local VisitAst = self:_vRequire("prometheus.visitast")
    local Unparser = self:_vRequire("prometheus.unparser")
    return {
        Parser = Parser,
        Ast = Ast,
        VisitAst = VisitAst,
        Unparser = Unparser
    }
end
function Modules.InternalExecutor:_process(str, keywordList)
    local K = {}
    for _, v in pairs(keywordList) do K[v] = true end
    local S = str:gsub(".", function(c) return self.Config.TOKENS[c] and " " or c end)
    S = S:gsub("%S+", function(c) return K[c] and c or (" "):rep(#c) end)
    return S
end
function Modules.InternalExecutor:_update()
    local ui = self.State.UI
    if not ui.Source then return end
    local text = ui.Source.Text:gsub("\r", ""):gsub("\t", "    ")
    local textHeight = self.Services.TextService:GetTextSize(text, 14, Enum.Font.Code, Vector2.new(ui.EditorScroll.AbsoluteSize.X - 40, math.huge)).Y
    local finalHeight = math.max(textHeight + 50, ui.EditorScroll.AbsoluteSize.Y)
    ui.EditorScroll.CanvasSize = UDim2.fromOffset(0, finalHeight)
    ui.Source.Size = UDim2.new(1, -40, 0, finalHeight)
    ui.Keywords.Text = self:_process(text, self.Config.KEYWORDS)
    ui.Globals.Text = self:_process(text, self.Config.GLOBALS)
    ui.Remotes.Text = self:_process(text, self.Config.REMOTES)
    local _, lineCount = text:gsub("\n", "")
    ui.Lines.Text = ""
    for i = 1, lineCount + 1 do
        ui.Lines.Text ..= i .. "\n"
    end
end
function Modules.InternalExecutor:CreateUI()
    if self.State.UI.Main then self.State.UI.Main.Visible = true return end
    local sg = Instance.new("ScreenGui", self.Services.CoreGui)
    sg.Name = "Zuka_RC7_Editor"
    sg.ResetOnSpawn = false
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.fromOffset(600, 420)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 1
    main.BorderColor3 = self.Config.ACCENT
    main.ClipsDescendants = true
    main.Active = true
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(255, 85, 127)
    header.BorderSizePixel = 0
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.Text = "Zukas Lifter."
    title.TextColor3 = self.Config.ACCENT
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left; title.BackgroundTransparency = 1
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.fromOffset(30, 30)
    close.Position = UDim2.new(1, -30, 0, 0)
    close.Text = "X"; close.TextColor3 = Color3.new(1,0,0); close.BackgroundTransparency = 1
    close.MouseButton1Click:Connect(function() sg:Destroy(); self.State.UI = {} end)
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -85)
    scroll.Position = UDim2.fromOffset(5, 35)
    scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    scroll.BackgroundTransparency = 0.4
    scroll.BorderSizePixel = 1
    scroll.BorderColor3 = Color3.fromRGB(50, 50, 50)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = self.Config.ACCENT
    local lines = Instance.new("TextLabel", scroll)
    lines.Size = UDim2.new(0, 30, 1, 0)
    lines.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    lines.BorderSizePixel = 0
    lines.Text = "1"; lines.TextColor3 = Color3.fromRGB(100, 100, 100)
    lines.Font = Enum.Font.Code; lines.TextSize = 14; lines.TextYAlignment = "Top"
    local source = Instance.new("TextBox", scroll)
    source.Size = UDim2.new(1, -35, 1, 0)
    source.Position = UDim2.fromOffset(35, 0)
    source.BackgroundTransparency = 1
    source.TextColor3 = Color3.fromRGB(220, 220, 220)
    source.Font = Enum.Font.Code
    source.TextSize = 14
    source.TextXAlignment = Enum.TextXAlignment.Left; source.TextYAlignment = "Top"
    source.MultiLine = true; source.ClearTextOnFocus = false
    source.Text = ""
    local function mkOverlay(name, color)
        local l = Instance.new("TextLabel", source)
        l.Name = name; l.Size = UDim2.fromScale(1, 1); l.BackgroundTransparency = 1
        l.Font = Enum.Font.Code; l.TextSize = 14; l.TextXAlignment = "Left"; l.TextYAlignment = "Top"
        l.TextColor3 = color; l.Text = ""; l.ZIndex = 3
        return l
    end
    local kw = mkOverlay("Keywords", Color3.fromRGB(255, 80, 80))
    local gb = mkOverlay("Globals", Color3.fromRGB(80, 180, 255))
    local rm = mkOverlay("Remotes", Color3.fromRGB(0, 255, 150))
    local footer = Instance.new("Frame", main)
    footer.Size = UDim2.new(1, 0, 0, 45)
    footer.Position = UDim2.new(0, 0, 1, -45)
    footer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    footer.BorderSizePixel = 0
    local function mkBtn(text, pos, color, cb)
        local b = Instance.new("TextButton", footer)
        b.Size = UDim2.fromOffset(110, 30)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.BorderSizePixel = 1; b.BorderColor3 = color
        b.Text = text; b.TextColor3 = color; b.Font = Enum.Font.Code; b.TextSize = 13
        b.MouseButton1Click:Connect(cb)
        return b
    end
    mkBtn("EXECUTE", UDim2.fromOffset(10, 7), self.Config.ACCENT, function()
        local f, e = loadstring(source.Text)
        if f then task.spawn(f); DoNotif("Executed.", 1) else warn(e); DoNotif("Syntax Error", 2) end
    end)
    mkBtn("LIFT (PROM)", UDim2.fromOffset(130, 7), self.Config.LIFT_COLOR, function()
        if self.State.IsLifting then return end
        self.State.IsLifting = true
        task.spawn(function()
            local _old_info = debug.getinfo
            getgenv().debug.getinfo = function(f, ...)
                local res = _old_info(f, ...)
                if res and res.source and res.source:find("VFS") then
                    res.source = "=[C]"
                end
                return res
            end
            local components = self:_initializeLifter()
            if not components.Parser then
                self.State.IsLifting = false
                return DoNotif("VFS Error. Check F9.", 3)
            end
            local inputCode = source.Text
            if #inputCode == 0 then
                self.State.IsLifting = false
                return DoNotif("Source empty.", 2)
            end
            DoNotif("Lifting: Analyzing AST...", 2)
            local success, ast = pcall(function()
                local p = components.Parser:new({ LuaVersion = "LuaU" })
                return p:parse(inputCode)
            end)
            if not success or not ast then
                warn("--> [Lifter] Fatal Error: " .. tostring(ast))
                self.State.IsLifting = false
                return DoNotif("Deobfuscation Failed.", 3)
            end
            local u = components.Unparser:new({ LuaVersion = "LuaU", PrettyPrint = true, IndentSpaces = 4 })
            local liftedCode = u:unparse(ast)
            liftedCode = liftedCode:gsub('"([^"]*)"%s*%.%.%s*"([^"]*)"', '"%1%2"')
            source.Text = liftedCode
            self:_update()
            self.State.IsLifting = false
            DoNotif("Code Lifted.", 2)
            getgenv().debug.getinfo = _old_info
        end)
    end)
    mkBtn("CLEAR", UDim2.fromOffset(250, 7), Color3.fromRGB(255, 150, 0), function()
        source.Text = ""
    end)
    source:GetPropertyChangedSignal("Text"):Connect(function()
        self:_update()
    end)
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, main.Position
        end
    end)
    self.Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    self.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    self.State.UI = {Main = main, Source = source, EditorScroll = scroll, Lines = lines, Keywords = kw, Globals = gb, Remotes = rm}
    DoNotif("Forensic IDE Ready.", 2)
end
function Modules.InternalExecutor:Initialize()
    for _, s in ipairs(self.Dependencies) do self.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "ide",
        Aliases = {"lift", "exe", "internal"},
        Description = "Stable Forensic IDE with circular-dependency protection."
    }, function()
        self:CreateUI()
    end)
end
Modules.Disarmer = {
    State = {
        IsEnabled = false,
        Connections = {}
    },
    Config = {
        ARM_PARTS = {
            "Left Arm", "Right Arm",
            "LeftUpperArm", "LeftLowerArm", "LeftHand",
            "RightUpperArm", "RightLowerArm", "RightHand"
        }
    },
    Dependencies = {"Players", "Workspace", "RunService"},
    Services = {}
}
function Modules.Disarmer:_strip(model)
    if not model or not self.State.IsEnabled then return end
    local player = self.Services.Players:GetPlayerFromCharacter(model)
    if player == self.Services.Players.LocalPlayer then return end
    if not model:FindFirstChild("HumanoidRootPart") then return end
    for _, limbName in ipairs(self.Config.ARM_PARTS) do
        local limb = model:FindFirstChild(limbName)
        if limb then
            pcall(function()
                limb:Destroy()
            end)
        end
    end
end
function Modules.Disarmer:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    for _, obj in ipairs(self.Services.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            self:_strip(obj)
        end
    end
    self.State.Connections.DescendantAdded = self.Services.Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.defer(function()
                if obj:FindFirstChildOfClass("Humanoid") then
                    self:_strip(obj)
                end
            end)
        end
    end)
    DoNotif("Disarmer: ENABLED (Limbs Purged)", 2)
end
function Modules.Disarmer:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for _, conn in pairs(self.State.Connections) do
        conn:Disconnect()
    end
    table.clear(self.State.Connections)
    DoNotif("Disarmer: DISABLED (Requires respawn to restore)", 2)
end
function Modules.Disarmer:Initialize()
    for _, s in ipairs(self.Dependencies) do self.Services[s] = game:GetService(s) end
    RegisterCommand({
        Name = "disarm",
        Aliases = {"noarms"},
        Description = "Removes arms from every player and NPC in the game except you."
    }, function()
        if self.State.IsEnabled then
            self:Disable()
        else
            self:Enable()
        end
    end)
end
local function loadstringCmd(url, notif)
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    DoNotif(notif, 3)
end
RegisterCommand({Name = "zsniper", Aliases = {}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/sniperZG.lua", "Loading..") end)
RegisterCommand({Name = "zshotgun", Aliases = {}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/ShotgunMinigunScriptWorking.lua", "Loading..") end)
RegisterCommand({Name = "noanim", Aliases = {}, Description = "Pauses/Removes All animations for the player."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/animationremover.lua", " Loading.. ") end)
RegisterCommand({Name = "gunlagger2", Aliases = {}, Description = "For Protect the house from Monsters."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/machinegun.lua", " Loading.. ") end)
RegisterCommand({Name = "gunlagger", Aliases = {}, Description = "For Protect the house from Monsters."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/Lagger.lua", " Loading.. ") end)
RegisterCommand({Name = "lagserv", Aliases = {"spayload"}, Description = "WIP"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/gamelagger.lua", " Loading.. ") end)
RegisterCommand({Name = "doomshammer", Aliases = {}, Description = "For Dumb bossfights"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/doomshammer.lua", " Loading.. ") end)
RegisterCommand({Name = "tptoswords", Aliases = {}, Description = "For Dumb bossfights"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/SwordGrabberBossfightGame.lua", " Loading.. ") end)
RegisterCommand({Name = "removeff", Aliases = {}, Description = "Removes Forcefields on the client, can be useful with low security"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/removeforcefield.txt", " Loading.. ") end)
RegisterCommand({Name = "AttachHub", Aliases = {}, Description = "Anthony's Script 2"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/AttachHub.lua", " Loading.. ") end)
RegisterCommand({Name = "simplespy", Aliases = {"sz"}, Description = "Better than ketamine."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/simplespy.lua", " Loading.. ") end)
RegisterCommand({Name = "mk18", Aliases = {}, Description = "For backrooms."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/mk18.lua", " Loading.. ") end)
RegisterCommand({Name = "teleporter", Aliases = {"tpui"}, Description = "Loads the Game Universe."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/GameFinder.lua", "stolen from nameless-admin") end)
RegisterCommand({Name = "autofling", Aliases = {"pwned"}, Description = "Pwned Flinger"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/Ultimatefling.lua", "Loaded!") end)
RegisterCommand({Name = "wallwalk", Aliases = {}, Description = "walk on walls."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/wallwalk.lua", "Wait a sec.") end)
RegisterCommand({Name = "npcbreaker", Aliases = {}, Description = "WIP"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/CamFixNPCBreaker.txt", "Anti Gay Shield Activated.") end)
RegisterCommand({Name = "plag", Aliases = {}, Description = "For https://www.roblox.com/games/115286378269814/Protect-The-House-From-Monsters"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/GameLaggerPlauncher.lua", "Loading Modification") end)
RegisterCommand({Name = "pumpkin", Aliases = {}, Description = "For https://www.roblox.com/games/115286378269814/Protect-The-House-From-Monsters"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/RAPIDFIREPumpkinlauncher.lua", "Loading") end)
RegisterCommand({Name = "zukahub", Aliases = {"zuka"}, Description = "Loads the Zuka Hub"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/ZukaHub.lua", "Loading Zuka's Hub...") end)
RegisterCommand({Name = "noacid", Aliases = {"unfuck"}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/AntiAcidRainLag.lua", "Loading...") end)
RegisterCommand({Name = "stats", Aliases = {}, Description = "Edit and lock your properties."}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/statlock.lua", "Loading Stats..") end)
RegisterCommand({Name = "plasmasniper", Aliases = {}, Description = "For Backrooms."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/plasmasniper.lua", "Loaded") end)
RegisterCommand({Name = "creepyanim", Aliases = {"canim"}, Description = "Uncanny Animation GUI"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/uncannyanim.lua", "Loaded GUI") end)
RegisterCommand({Name = "swordbot", Aliases = {"sf", "sfbot"}, Description = "Auto Sword Fighter, use E and R"}, function() loadstringCmd("https://raw.githubusercontent.com/bloxtech1/luaprojects2/refs/heads/main/swordnpc", "Bot loaded.") end)
RegisterCommand({Name = "touchfling", Aliases = {}, Description = "Loads the touchfling GUI"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/SimpleTouchFlingGui.lua", "Loaded") end)
RegisterCommand({Name = "umpff", Aliases = {}, Description = "For Backrooms." }, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/UMPteamkiller.lua", "Loaded") end)
RegisterCommand({Name = "hex", Aliases = {}, Description = "Work In Progress" }, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/HEXOverseer.lua", "Loaded") end)
RegisterCommand({Name = "ibtools", Aliases = {"btools"}, Description = "Upgraded Gui For Btools"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/buildtools.lua", "Loading Revamped Btools Gui") end)
RegisterCommand({Name = "Zex", Aliases = {"zx"}, Description = "Updated Dex+"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/Zex.lua", "Loading Zex..") end)
RegisterCommand({Name = "walkvoid", Aliases = {"wv"}, Description = "Stops you from falling into the void."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/WalkVoid.lua", "You are now safe from falling into the void.") end)
RegisterCommand({Name = "overseerCE", Aliases = {"CEos"}, Description = "in beta"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/CEOverseer.lua", "in beta...") end)
RegisterCommand({Name = "csgo", Aliases = {"bhop"}, Description = "Bhop movement"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/phoon.lua", "Loading") end)
RegisterCommand({Name = "lineofsight", Aliases = {}, Description = "Logger for players looking at you"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/LineOfSightLogger.lua", "Loading...") end)
RegisterCommand({Name = "zcooldowns", Aliases = {"ncd"}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/NocooldownsZombieUpd3.txt", "Loading Cooldownremover...") end)
RegisterCommand({Name = "zshovel", Aliases = {}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/ShovelAnimation.lua", "Loading Shovel.") end)
RegisterCommand({Name = "patchgun", Aliases = {}, Description = "Avoid being kicked for being idle."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/PatchedGuns.lua", "Guns Patched.") end)
RegisterCommand({Name = "zmelee", Aliases = {}, Description = "For https://www.roblox.com/games/6850833423/Zombie-Infection-Game."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/MeleeDamagex2.lua", "Loading..") end)
RegisterCommand({Name = "flinger", Aliases = {"flingui"}, Description = "Loads a Fling GUI."}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/SkidFling.lua", "Loading GUI..") end)
RegisterCommand({Name = "rem", Aliases = {}, Description = "In game exploit creation kit.."}, function() loadstringCmd("https://e-vil.com/anbu/rem.lua", "Loading Rem.") end)
RegisterCommand({Name = "Copyconsole", Aliases = {"copy"}, Description = "Allows you to copy errors from the console.."}, function() loadstringCmd("https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/consolecopy.lua", "Copy Console Activated.") end)
RegisterCommand({Name = "zhp", Aliases = {}, Description = "For https://www.roblox.com/games/14419907512/Zombie-game"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/zgamemedkit.lua", "Loading HP Teleport") end)
RegisterCommand({Name = "reachfix", Aliases = {"fix"}, Description = "Makes your equipped tool invisible when using reach"}, function() loadstringCmd("https://raw.githubusercontent.com/legalize8ga-maker/Scripts/refs/heads/main/InvisibleEquippedTool.lua", "Fixed") end)
RegisterCommand({Name = "worldofstands", Aliases = {"wos"}, Description = "For https://www.roblox.com/games/6728870912/World-of-Stands - Removes dash cooldown"}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/WOS.lua", "Loading, Wait a sec.") end)
RegisterCommand({Name = "zfucker", Aliases = {}, Description = "zfucker for the zl series."}, function() loadstringCmd("https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/main.luau", "Loading, Wait a sec.") end)
RegisterCommand({Name = "calesp", Aliases = {}, Description = "Selective ESP UI Made by the Callum-AI."}, function() loadstringCmd("https://raw.githubusercontent.com/zukatech1/ZukaTechPanel/refs/heads/main/AIESP.lua", "Loading, Wait a sec.") end)
Modules.InfiniteYieldPlugins = {
    State = {
        LoadedPlugins = {},
        PluginCache = {},
        IsEnabled = true,
        PluginFolders = {"plugins", "workspace/plugins"}
    },
    Config = {
        PLUGIN_DIR = "plugins",
        PLUGIN_EXT = ".iy",
        AUTO_LOAD = false,
        CACHE_PLUGINS = true,
        MAX_FILE_SIZE = 1000000
    },
    Dependencies = {"HttpService"}
}
function Modules.InfiniteYieldPlugins:LoadPluginFile(filePath: string): (boolean, string?)
    if not readfile then
        return false, "readfile not available in this executor"
    end
    local success, result = pcall(function()
        if not filePath:lower():find(self.Config.PLUGIN_EXT, 1, true) then
            return false, "File must have " .. self.Config.PLUGIN_EXT .. " extension"
        end
        if not isfile or not isfile(filePath) then
            return false, "File does not exist: " .. filePath
        end
        local fileContent = readfile(filePath)
        if not fileContent or fileContent == "" then
            return false, "File is empty or cannot be read"
        end
        if #fileContent > self.Config.MAX_FILE_SIZE then
            return false, "File too large (max " .. self.Config.MAX_FILE_SIZE .. " bytes)"
        end
        local testLoad, testErr = loadstring(fileContent)
        if not testLoad then
            return false, "Syntax error: " .. tostring(testErr)
        end
        return true, fileContent
    end)
    if not success then
        return false, "Error loading file: " .. tostring(result)
    end
    return result
end
function Modules.InfiniteYieldPlugins:ExecutePluginCode(pluginName: string, code: string): (boolean, string?)
    local success, result = pcall(function()
        local pluginEnv = setmetatable({
            print = print,
            warn = warn,
            error = error,
            assert = assert,
            type = type,
            typeof = typeof,
            tostring = tostring,
            tonumber = tonumber,
            next = next,
            pairs = pairs,
            ipairs = ipairs,
            pcall = pcall,
            xpcall = xpcall,
            select = select,
            task = task,
            table = table,
            string = string,
            math = math,
            utf8 = utf8,
            coroutine = coroutine,
            game = game,
            workspace = workspace,
            Instance = Instance,
            Vector3 = Vector3,
            Vector2 = Vector2,
            CFrame = CFrame,
            Color3 = Color3,
            UDim2 = UDim2,
            UDim = UDim,
            Enum = Enum,
            Players = game:GetService("Players"),
            RunService = game:GetService("RunService"),
            UserInputService = game:GetService("UserInputService"),
            TweenService = game:GetService("TweenService"),
            DoNotif = DoNotif,
            Player = game:GetService("Players").LocalPlayer,
            LocalPlayer = game:GetService("Players").LocalPlayer,
            _PLUGIN_NAME = pluginName,
            _PLUGIN_VERSION = "1.0"
        }, {__index = getgenv and getgenv() or _G})
        local pluginFunc, loadErr = loadstring(code)
        if not pluginFunc then
            return false, "Failed to compile: " .. tostring(loadErr)
        end
        setfenv(pluginFunc, pluginEnv)
        local pluginTable = pluginFunc()
        if type(pluginTable) == "table" then
            if pluginTable.Commands then
                local cmdCount = 0
                for cmdName, cmdData in pairs(pluginTable.Commands) do
                    if type(cmdData) == "table" and type(cmdData.Function) == "function" then
                        RegisterCommand({
                            Name = cmdName,
                            Aliases = cmdData.Aliases or {},
                            Description = cmdData.Description or ("IY Plugin: " .. pluginName)
                        }, function(args)
                            local success, err = pcall(function()
                                cmdData.Function(args, game:GetService("Players").LocalPlayer)
                            end)
                            if not success then
                                warn("[" .. pluginName .. "] Command error: " .. tostring(err))
                                DoNotif("Command error - see console", 3)
                            end
                        end)
                        cmdCount = cmdCount + 1
                    end
                end
                return true, "Loaded " .. cmdCount .. " command(s)"
            elseif pluginTable.Init then
                local initSuccess, initErr = pcall(pluginTable.Init)
                if not initSuccess then
                    return false, "Init failed: " .. tostring(initErr)
                end
                return true, "Plugin initialized"
            end
        end
        return true, "Plugin executed (no commands registered)"
    end)
    if not success then
        return false, "Execution error: " .. tostring(result)
    end
    return result
end
function Modules.InfiniteYieldPlugins:LoadPlugin(pluginPath: string): boolean
    if not self.State.IsEnabled then
        warn("[IY Plugin] System is disabled")
        return false
    end
    local fileName = pluginPath:match("([^/\\]+)$") or pluginPath
    local pluginName = fileName:gsub(self.Config.PLUGIN_EXT, "")
    if self.State.LoadedPlugins[pluginName] then
        DoNotif("Plugin '" .. pluginName .. "' already loaded", 2)
        return false
    end
    local success, content = self:LoadPluginFile(pluginPath)
    if not success then
        warn("[IY Plugin] Failed to load '" .. pluginName .. "': " .. tostring(content))
        DoNotif("Failed to load: " .. pluginName, 3)
        return false
    end
    if self.Config.CACHE_PLUGINS then
        self.State.PluginCache[pluginName] = content
    end
    local execSuccess, execMsg = self:ExecutePluginCode(pluginName, content)
    if execSuccess then
        self.State.LoadedPlugins[pluginName] = {
            path = pluginPath,
            loaded = os.time(),
            message = execMsg
        }
        DoNotif("✓ Loaded: " .. pluginName, 2)
        print("[IY Plugin] Integrated '" .. pluginName .. "' - " .. tostring(execMsg))
        return true
    else
        warn("[IY Plugin] Failed to execute '" .. pluginName .. "': " .. tostring(execMsg))
        DoNotif("✗ Failed: " .. pluginName, 3)
        return false
    end
end
function Modules.InfiniteYieldPlugins:UnloadPlugin(pluginName: string): boolean
    if self.State.LoadedPlugins[pluginName] then
        self.State.LoadedPlugins[pluginName] = nil
        self.State.PluginCache[pluginName] = nil
        DoNotif("Unloaded: " .. pluginName, 2)
        return true
    end
    return false
end
function Modules.InfiniteYieldPlugins:ScanDirectory(directory: string): number
    if not listfiles then
        warn("[IY Plugin] listfiles not available")
        return 0
    end
    local count = 0
    local success, files = pcall(function()
        return listfiles(directory)
    end)
    if not success then
        warn("[IY Plugin] Failed to scan directory: " .. directory)
        return 0
    end
    if not files then
        return 0
    end
    for _, filePath in ipairs(files) do
        if filePath:lower():match(self.Config.PLUGIN_EXT .. "$") then
            if self:LoadPlugin(filePath) then
                count = count + 1
            end
        end
    end
    return count
end
function Modules.InfiniteYieldPlugins:Initialize()
    RegisterCommand({
        Name = "iyscan",
        Aliases = {"refreshplugins", "iyr", "scanplugins"},
        Description = "Scans plugin folders and loads all .iy files"
    }, function(args)
        if not listfiles then
            return DoNotif("Executor doesn't support 'listfiles'", 3)
        end
        local totalCount = 0
        local foldersChecked = 0
        for _, folder in ipairs(self.State.PluginFolders) do
            local count = self:ScanDirectory(folder)
            totalCount = totalCount + count
            if count > 0 then
                foldersChecked = foldersChecked + 1
                print("[IY Plugin] Found " .. count .. " plugin(s) in: " .. folder)
            end
        end
        if totalCount > 0 then
            DoNotif("✓ Loaded " .. totalCount .. " plugin(s) from " .. foldersChecked .. " folder(s)", 3)
        else
            DoNotif("No plugins found in plugin folders", 3)
        end
    end)
    RegisterCommand({
        Name = "iyload",
        Aliases = {"loadplugin", "iyl"},
        Description = "Load a specific .iy plugin file. Usage: ;iyload <filepath>"
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;iyload <filepath>", 3)
        end
        local filePath = table.concat(args, " ")
        self:LoadPlugin(filePath)
    end)
    RegisterCommand({
        Name = "iylist",
        Aliases = {"listplugins", "plugins"},
        Description = "Lists all loaded IY plugins"
    }, function()
        local count = 0
        print("=== Loaded IY Plugins ===")
        for name, data in pairs(self.State.LoadedPlugins) do
            count = count + 1
            print(count .. ". " .. name .. " - " .. (data.message or ""))
        end
        if count == 0 then
            DoNotif("No plugins loaded", 2)
        else
            DoNotif(count .. " plugin(s) loaded", 2)
        end
    end)
    RegisterCommand({
        Name = "iyunload",
        Aliases = {"unloadplugin"},
        Description = "Unload a specific plugin. Usage: ;iyunload <name>"
    }, function(args)
        if not args[1] then
            return DoNotif("Usage: ;iyunload <plugin_name>", 3)
        end
        local pluginName = table.concat(args, " ")
        if self:UnloadPlugin(pluginName) then
            DoNotif("Unloaded: " .. pluginName, 2)
        else
            DoNotif("Plugin not found: " .. pluginName, 3)
        end
    end)
    RegisterCommand({
        Name = "iyclear",
        Aliases = {"clearplugins"},
        Description = "Unload all IY plugins"
    }, function()
        local count = 0
        for name in pairs(self.State.LoadedPlugins) do
            self:UnloadPlugin(name)
            count = count + 1
        end
        DoNotif("Cleared " .. count .. " plugin(s)", 2)
    end)
    print("[IY Plugin] System initialized")
    if self.Config.AUTO_LOAD and listfiles then
        task.defer(function()
            task.wait(1)
            local total = 0
            for _, folder in ipairs(self.State.PluginFolders) do
                total = total + self:ScanDirectory(folder)
            end
            if total > 0 then
                print("[IY Plugin] Auto-loaded " .. total .. " plugin(s)")
            end
        end)
    end
end
Modules.CommandAdapter = {
    State = {
        AdaptedCommands = {},
        LoadedScripts = {},
        UIInstance = nil
    },
    Config = {
        SupportedFrameworks = {
            "nameless",
            "infinite",
            "universal",
            "custom"
        }
    }
}
function Modules.CommandAdapter:CreateCompatibleEnvironment(frameworkName: string)
    local framework = frameworkName:lower() or "universal"
    local cmdAPI = {}
    local loadedCount = 0
    function cmdAPI:add(nameOrAliases, descOrFunc, funcOrNil)
        local name, aliases, description, func
        if type(nameOrAliases) == "string" then
            name = nameOrAliases
            aliases = {}
            description = type(descOrFunc) == "string" and descOrFunc or ""
            func = funcOrNil or descOrFunc
        elseif type(nameOrAliases) == "table" then
            aliases = {}
            name = nameOrAliases[1] or "unknown"
            for i = 2, #nameOrAliases do
                table.insert(aliases, nameOrAliases[i])
            end
            description = type(descOrFunc) == "string" and descOrFunc or ""
            func = funcOrNil or descOrFunc
        else
            warn("[CommandAdapter] Invalid command format")
            return false
        end
        if type(func) ~= "function" then
            warn("[CommandAdapter] Invalid function for command '" .. tostring(name) .. "'")
            return false
        end
        local success = pcall(function()
            RegisterCommand({
                Name = name,
                Aliases = aliases,
                Description = description or ("Imported from " .. framework)
            }, function(args)
                local cmdSuccess, cmdErr = pcall(function()
                    func(args, game:GetService("Players").LocalPlayer)
                end)
                if not cmdSuccess then
                    warn("[CommandAdapter] Error in command '" .. name .. "': " .. tostring(cmdErr))
                    DoNotif("Command error - check console", 3)
                end
            end)
        end)
        if success then
            loadedCount = loadedCount + 1
            return true
        else
            warn("[CommandAdapter] Failed to register command: " .. name)
            return false
        end
    end
    cmdAPI.register = cmdAPI.add
    cmdAPI.Add = cmdAPI.add
    return cmdAPI, function() return loadedCount end
end
function Modules.CommandAdapter:ExecuteCommandScript(scriptCode: string, frameworkName: string, scriptName: string): boolean
    frameworkName = frameworkName:lower() or "universal"
    scriptName = scriptName or "ImportedScript_" .. os.time()
    if self.State.LoadedScripts[scriptName] then
        DoNotif("Script '" .. scriptName .. "' already loaded", 3)
        return false
    end
    local success, result = pcall(function()
        local cmdAPI, getCount = self:CreateCompatibleEnvironment(frameworkName)
        local env = {
            print = print,
            warn = warn,
            error = error,
            assert = assert,
            type = type,
            typeof = typeof,
            tostring = tostring,
            tonumber = tonumber,
            next = next,
            pairs = pairs,
            ipairs = ipairs,
            pcall = pcall,
            xpcall = xpcall,
            select = select,
            unpack = unpack,
            table = table,
            string = string,
            math = math,
            task = task,
            coroutine = coroutine,
            utf8 = utf8,
            bit32 = bit32,
            game = game,
            workspace = workspace,
            script = script,
            Instance = Instance,
            Vector3 = Vector3,
            Vector2 = Vector2,
            CFrame = CFrame,
            Color3 = Color3,
            UDim2 = UDim2,
            UDim = UDim,
            Enum = Enum,
            Ray = Ray,
            Region3 = Region3,
            NumberRange = NumberRange,
            NumberSequence = NumberSequence,
            ColorSequence = ColorSequence,
            Players = game:GetService("Players"),
            Workspace = game:GetService("Workspace"),
            RunService = game:GetService("RunService"),
            UserInputService = game:GetService("UserInputService"),
            CoreGui = game:GetService("CoreGui"),
            TweenService = game:GetService("TweenService"),
            ReplicatedStorage = game:GetService("ReplicatedStorage"),
            cmd = cmdAPI,
            commands = cmdAPI,
            CMD = cmdAPI,
            Add = function(n, d, f) return cmdAPI:add(n, d, f) end,
            register = function(n, d, f) return cmdAPI:add(n, d, f) end,
            addCommand = function(n, d, f) return cmdAPI:add(n, d, f) end,
            DoNotif = DoNotif,
            LocalPlayer = game:GetService("Players").LocalPlayer,
            Player = game:GetService("Players").LocalPlayer,
            Mouse = game:GetService("Players").LocalPlayer:GetMouse(),
            Camera = workspace.CurrentCamera,
            wait = task.wait,
            spawn = task.spawn,
            delay = task.delay,
        }
        setmetatable(env, {
            __index = function(t, k)
                if _G[k] ~= nil then
                    return _G[k]
                end
                if getgenv and getgenv()[k] ~= nil then
                    return getgenv()[k]
                end
                return nil
            end
        })
        local func, compileErr = loadstring(scriptCode)
        if not func then
            return false, "Syntax error: " .. tostring(compileErr)
        end
        setfenv(func, env)
        local execSuccess, execErr = pcall(func)
        if not execSuccess then
            return false, "Execution error: " .. tostring(execErr)
        end
        local cmdCount = getCount()
        return true, "Loaded " .. cmdCount .. " command(s)"
    end)
    if success then
        self.State.LoadedScripts[scriptName] = {
            framework = frameworkName,
            loaded = os.time(),
            message = result
        }
        DoNotif("✓ " .. scriptName .. ": " .. tostring(result), 3)
        print("[CommandAdapter] " .. scriptName .. " - " .. tostring(result))
        return true
    else
        warn("[CommandAdapter] Failed to load '" .. scriptName .. "': " .. tostring(result))
        DoNotif("✗ Error: " .. tostring(result), 4)
        return false
    end
end
function Modules.CommandAdapter:Initialize()
    RegisterCommand({
        Name = "cmdadapter",
        Aliases = {"cmdui", "adaptcmds", "importcmds"},
        Description = "Opens the Command Adapter UI to import external commands"
    }, function()
        self:CreateUI()
    end)
    RegisterCommand({
        Name = "listimported",
        Aliases = {"importedcmds"},
        Description = "Lists all imported command scripts"
    }, function()
        local count = 0
        print("=== Imported Command Scripts ===")
        for name, data in pairs(self.State.LoadedScripts) do
            count = count + 1
            print(count .. ". " .. name .. " (" .. data.framework .. ") - " .. (data.message or ""))
        end
        if count == 0 then
            DoNotif("No imported scripts", 2)
        else
            DoNotif(count .. " script(s) imported", 2)
        end
    end)
    RegisterCommand({
        Name = "clearimported",
        Aliases = {"clearadapted"},
        Description = "Clears the list of imported scripts (doesn't unregister commands)"
    }, function()
        local count = 0
        for _ in pairs(self.State.LoadedScripts) do
            count = count + 1
        end
        self.State.LoadedScripts = {}
        DoNotif("Cleared " .. count .. " imported script(s)", 2)
    end)
    print("[CommandAdapter] System initialized")
end
function Modules.CommandAdapter:CreateUI()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("CommandAdapterUI") then
        CoreGui:FindFirstChild("CommandAdapterUI"):Destroy()
    end
    local sg = Instance.new("ScreenGui")
    sg.Name = "CommandAdapterUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.Parent = CoreGui
    self.State.UIInstance = sg
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(750, 650)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    local shadow = Instance.new("ImageLabel", main)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.fromOffset(-15, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local headerTitle = Instance.new("TextLabel", header)
    headerTitle.Size = UDim2.new(1, -60, 1, 0)
    headerTitle.Position = UDim2.fromOffset(20, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "⚙️ COMMAND ADAPTER"
    headerTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 18
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    local headerSubtext = Instance.new("TextLabel", header)
    headerSubtext.Size = UDim2.new(1, -60, 0, 15)
    headerSubtext.Position = UDim2.fromOffset(20, 28)
    headerSubtext.BackgroundTransparency = 1
    headerSubtext.Text = "Import commands from Nameless Admin, Infinite Yield, and more"
    headerSubtext.TextColor3 = Color3.fromRGB(150, 150, 150)
    headerSubtext.Font = Enum.Font.Gotham
    headerSubtext.TextSize = 10
    headerSubtext.TextXAlignment = Enum.TextXAlignment.Left
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.fromOffset(40, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
        self.State.UIInstance = nil
    end)
    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.fromOffset(20, 65)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
    content.CanvasSize = UDim2.fromOffset(0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local frameworkLabel = Instance.new("TextLabel", content)
    frameworkLabel.Size = UDim2.new(1, 0, 0, 20)
    frameworkLabel.BackgroundTransparency = 1
    frameworkLabel.Text = "Framework Type:"
    frameworkLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    frameworkLabel.Font = Enum.Font.GothamMedium
    frameworkLabel.TextSize = 12
    frameworkLabel.TextXAlignment = Enum.TextXAlignment.Left
    local frameworkBox = Instance.new("TextBox", content)
    frameworkBox.Size = UDim2.new(0.45, 0, 0, 35)
    frameworkBox.Position = UDim2.fromOffset(0, 25)
    frameworkBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frameworkBox.BorderSizePixel = 0
    frameworkBox.Text = "universal"
    frameworkBox.PlaceholderText = "universal/nameless/infinite"
    frameworkBox.TextColor3 = Color3.new(1, 1, 1)
    frameworkBox.Font = Enum.Font.Gotham
    frameworkBox.TextSize = 11
    Instance.new("UICorner", frameworkBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", frameworkBox).PaddingLeft = UDim.new(0, 10)
    local nameLabel = Instance.new("TextLabel", content)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.fromOffset(0, 75)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Script Name (Optional):"
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextSize = 12
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    local nameBox = Instance.new("TextBox", content)
    nameBox.Size = UDim2.new(0.45, 0, 0, 35)
    nameBox.Position = UDim2.fromOffset(0, 100)
    nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    nameBox.BorderSizePixel = 0
    nameBox.PlaceholderText = "MyCommands"
    nameBox.TextColor3 = Color3.new(1, 1, 1)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 11
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", nameBox).PaddingLeft = UDim.new(0, 10)
    local codeLabel = Instance.new("TextLabel", content)
    codeLabel.Size = UDim2.new(1, 0, 0, 20)
    codeLabel.Position = UDim2.fromOffset(0, 150)
    codeLabel.BackgroundTransparency = 1
    codeLabel.Text = "Paste Command Code:"
    codeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    codeLabel.Font = Enum.Font.GothamMedium
    codeLabel.TextSize = 12
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    local codeBox = Instance.new("TextBox", content)
    codeBox.Size = UDim2.new(1, 0, 0, 320)
    codeBox.Position = UDim2.fromOffset(0, 175)
    codeBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    codeBox.BorderSizePixel = 0
    codeBox.PlaceholderText = "-- Paste your cmd:add() commands here...\n\ncmd:add(\"example\", \"An example command\", function(args)\n    print(\"Hello!\")\nend)"
    codeBox.TextColor3 = Color3.new(1, 1, 1)
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 11
    codeBox.TextWrapped = true
    codeBox.MultiLine = true
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 6)
    local codePadding = Instance.new("UIPadding", codeBox)
    codePadding.PaddingLeft = UDim.new(0, 10)
    codePadding.PaddingTop = UDim.new(0, 10)
    codePadding.PaddingRight = UDim.new(0, 10)
    codePadding.PaddingBottom = UDim.new(0, 10)
    local buttonContainer = Instance.new("Frame", content)
    buttonContainer.Size = UDim2.new(1, 0, 0, 45)
    buttonContainer.Position = UDim2.fromOffset(0, 510)
    buttonContainer.BackgroundTransparency = 1
    local loadBtn = Instance.new("TextButton", buttonContainer)
    loadBtn.Size = UDim2.new(0.48, 0, 1, 0)
    loadBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    loadBtn.BorderSizePixel = 0
    loadBtn.Text = "✓ LOAD COMMANDS"
    loadBtn.TextColor3 = Color3.new(1, 1, 1)
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.TextSize = 13
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 8)
    loadBtn.MouseButton1Click:Connect(function()
        local code = codeBox.Text
        if code == "" or code == nil then
            DoNotif("Please paste command code first", 3)
            return
        end
        local framework = frameworkBox.Text
        if framework == "" then framework = "universal" end
        local scriptName = nameBox.Text
        if scriptName == "" then
            scriptName = "PastedCommands_" .. os.time()
        end
        self:ExecuteCommandScript(code, framework, scriptName)
    end)
    local clearBtn = Instance.new("TextButton", buttonContainer)
    clearBtn.Size = UDim2.new(0.48, 0, 1, 0)
    clearBtn.Position = UDim2.fromScale(0.52, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
    clearBtn.BorderSizePixel = 0
    clearBtn.Text = "✕ CLEAR"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 13
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
    clearBtn.MouseButton1Click:Connect(function()
        codeBox.Text = ""
        nameBox.Text = ""
        frameworkBox.Text = "universal"
        DoNotif("Cleared input fields", 2)
    end)
    DoNotif("Command Adapter UI opened", 2)
end
function processCommand(message)
    if not (message:sub(1, #Prefix) == Prefix) then
        return false
    end
    local args = {}
    for word in message:sub(#Prefix + 1):gmatch("%S+") do
        table.insert(args, word)
    end
    if #args == 0 then
        return true
    end
    local cmdName = table.remove(args, 1):lower()
    local cmdFunc = Commands[cmdName]
    if cmdFunc then
        local success, err = pcall(cmdFunc, args)
        if not success then
            warn("Command Error:", err)
            DoNotif("Error: " .. tostring(err), 5)
        end
    else
        local lowestDistance = math.huge
        local closestMatch = nil
        local SUGGESTION_THRESHOLD = 2
        for command, _ in pairs(Commands) do
            local distance = Utilities.calculateLevenshteinDistance(cmdName, command)
            if distance < lowestDistance then
                lowestDistance = distance
                closestMatch = command
            end
        end
        if closestMatch and lowestDistance <= SUGGESTION_THRESHOLD then
            DoNotif(string.format("Unknown command: %s. Did you mean ;%s?", cmdName, closestMatch), 4)
        else
            DoNotif("Unknown command: " .. cmdName, 3)
        end
    end
    return true
end
for moduleName, module in pairs(Modules) do
       if type(module) == "table" and type(module.Initialize) == "function" then
           pcall(function()
           module:Initialize()
        end)
    end
end
local function CreateMobileCommandButton()
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    if not UserInputService.TouchEnabled then
        return
    end
    if CoreGui:FindFirstChild("MobileCommandButton_Zuka") then
        return
    end
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "MobileCommandButton_Zuka"
    buttonGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    buttonGui.ResetOnSpawn = false
    buttonGui.Parent = CoreGui
    local cmdButton = Instance.new("ImageButton")
    cmdButton.Name = "DraggableCommandButton"
    cmdButton.Size = UDim2.fromOffset(60, 60)
    cmdButton.Position = UDim2.new(0, 20, 0.5, -30)
    cmdButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    cmdButton.BackgroundTransparency = 0.2
    cmdButton.Image = "rbxassetid://7243158473"
    cmdButton.ImageColor3 = Color3.fromRGB(0, 255, 255)
    cmdButton.Parent = buttonGui
    Instance.new("UICorner", cmdButton).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", cmdButton).Color = Color3.fromRGB(80, 80, 100)
    local isDragging = false
    local dragStartPos = nil
    local startGuiPosition = nil
    local DRAG_THRESHOLD = 8
    cmdButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStartPos = input.Position
            startGuiPosition = cmdButton.Position
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragStartPos then
            local delta = input.Position - dragStartPos
            if not isDragging and delta.Magnitude > DRAG_THRESHOLD then
                isDragging = true
            end
            if isDragging then
                cmdButton.Position = UDim2.new(startGuiPosition.X.Scale, startGuiPosition.X.Offset + delta.X, startGuiPosition.Y.Scale, startGuiPosition.Y.Offset + delta.Y)
            end
        end
    end)
    cmdButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragStartPos = nil
            startGuiPosition = nil
        end
    end)
    cmdButton.Activated:Connect(function()
        if not isDragging then
            if Modules.CommandBar and Modules.CommandBar.Toggle then
                Modules.CommandBar:Toggle()
            end
        end
        isDragging = false
    end)
end
CreateMobileCommandButton()
Modules.CommandList:Initialize()
if TextChatService then
    TextChatService.SendingMessage:Connect(function(messageObject)
    local wasCommand = processCommand(messageObject.Text)
    if wasCommand then
        messageObject.ShouldSend = false
    end
end)
else
LocalPlayer.Chatted:Connect(processCommand)
end
local TeleportService = game:GetService("TeleportService")
local ClientReplicator = game:GetService("NetworkClient").ClientReplicator
local CurrentServer = game["JobId"]

ClientReplicator.AncestryChanged:Connect(function()
    TeleportService:TeleportToPlaceInstance(game["PlaceId"], CurrentServer)
end)

DoNotif("We're So back. The Best Underground Panel.")
