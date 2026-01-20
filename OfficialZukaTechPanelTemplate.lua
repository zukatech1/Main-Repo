--[[
made by zuka @OverZuka on roblox

this is the commandless template.
give me credit if you skid this.

--]]
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

dismantle_readonly(getgenv())
dismantle_readonly(getrenv())
dismantle_readonly(getreg())

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
                if info.name == target_name or (info.source and info.source:find(target_name)) then
                    found = found + 1
                end
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

print(string.format("--> [INTERNAL]: Memory Baseline: %.2f KB", _GC_START))
print(string.format("--> [INTERNAL]: Environment Unlock: SUCCESS"))
print(string.format("--> [INTERNAL]: C-Closure Wrapper: ACTIVE"))

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
        game:GetService("ContentProvider"):PreloadAsync({ icon })
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
function Utilities.calculateLevenshteinDistance(s1, s2)
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
    local textService = game:GetService("TextService")
    local notifGui = Instance.new("ScreenGui", CoreGui)
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
        local textBounds = textService:GetTextSize(notif.Text, notif.TextSize, notif.Font, Vector2.new(300, 1000))
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

        local inTween = TweenService:Create(notif, tweenInfoIn, goalIn)
        inTween:Play()
        inTween.Completed:Wait()
        task.wait(duration)
        local outTween = TweenService:Create(notif, tweenInfoOut, goalOut)
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

--[[Commands will go right below this.]]






Modules.CallumAI = {
    State = { IsEnabled = true },
    Config = { API_KEY = "", MODEL = "deepseek/deepseek-chat" }
}
function Modules.CallumAI:Initialize()
    RegisterCommand({
        Name = "callum",
        Aliases = {"c"},
        Description = "AI interface."
    }, function(args)
        DoNotif("Callum AI: Shoutout to Zuka!", 2)
    end)
end





--[[Commands will go right above this.]]

for moduleName, module in pairs(Modules) do
    if type(module) == "table" and type(module.Initialize) == "function" then
        pcall(function()
            module:Initialize()
            print("Initialized module:", moduleName)
        end)
    end
end
function processCommand(message)
    if not (message:sub(1, #Prefix) == Prefix) then return false end
    local args = {}
    for word in message:sub(#Prefix + 1):gmatch("%S+") do table.insert(args, word) end
    if #args == 0 then return true end
    local cmdName = table.remove(args, 1):lower()
    local cmdFunc = Commands[cmdName]
    if cmdFunc then
        pcall(cmdFunc, args)
    else
        DoNotif("Unknown command: " .. cmdName, 3)
    end
    return true
end
local TextChatService = game:GetService("TextChatService")
if TextChatService and TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.SendingMessage:Connect(function(messageObject)
        if processCommand(messageObject.Text) then
            messageObject.ShouldSend = false
        end
    end)
else
    LocalPlayer.Chatted:Connect(processCommand)
end
DoNotif("We're So back. ZukaTech v10 Loaded.")