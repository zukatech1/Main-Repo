local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Callum_DirectEditor"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end
local GlowFrame2 = Instance.new("Frame")
GlowFrame2.Size = UDim2.new(0, 406, 0, 506)
GlowFrame2.Position = UDim2.new(0.5, -203, 0.5, -253)
GlowFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlowFrame2.BackgroundTransparency = 0.93
GlowFrame2.BorderSizePixel = 0
GlowFrame2.ZIndex = 1
GlowFrame2.Parent = ScreenGui
Instance.new("UICorner", GlowFrame2).CornerRadius = UDim.new(0, 10)
local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(0, 390, 0, 490)
GlowFrame.Position = UDim2.new(0.5, -195, 0.5, -245)
GlowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlowFrame.BackgroundTransparency = 0.82
GlowFrame.BorderSizePixel = 0
GlowFrame.ZIndex = 2
GlowFrame.Parent = ScreenGui
Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0, 8)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 370, 0, 470)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.18
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 3
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 4)
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(18,  18,  18)),
})
Gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.88),
    NumberSequenceKeypoint.new(0.4, 0.96),
    NumberSequenceKeypoint.new(1,   1.0),
})
Gradient.Rotation = 135
Gradient.Parent = MainFrame
MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    local p = MainFrame.Position
    GlowFrame.Position  = UDim2.new(p.X.Scale, p.X.Offset - 10, p.Y.Scale, p.Y.Offset - 10)
    GlowFrame2.Position = UDim2.new(p.X.Scale, p.X.Offset - 18, p.Y.Scale, p.Y.Offset - 18)
end)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "direct weapon editor"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 4)
local SourceBadge = Instance.new("TextLabel")
SourceBadge.Size = UDim2.new(0, 120, 0, 16)
SourceBadge.Position = UDim2.new(1, -124, 0, 7)
SourceBadge.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SourceBadge.Text = ""
SourceBadge.TextColor3 = Color3.fromRGB(140, 160, 255)
SourceBadge.TextSize = 10
SourceBadge.Font = Enum.Font.Code
SourceBadge.Parent = MainFrame
Instance.new("UICorner", SourceBadge).CornerRadius = UDim.new(0, 3)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 16)
StatusLabel.Position = UDim2.new(0, 5, 0, 33)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Scanning..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame
local ToolNameBar = Instance.new("Frame")
ToolNameBar.Size = UDim2.new(1, -10, 0, 20)
ToolNameBar.Position = UDim2.new(0, 5, 0, 51)
ToolNameBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToolNameBar.BorderSizePixel = 0
ToolNameBar.Parent = MainFrame
Instance.new("UICorner", ToolNameBar).CornerRadius = UDim.new(0, 3)
local ToolIcon = Instance.new("TextLabel", ToolNameBar)
ToolIcon.Size = UDim2.new(0, 20, 1, 0)
ToolIcon.BackgroundTransparency = 1
ToolIcon.Text = "⚙"
ToolIcon.TextColor3 = Color3.fromRGB(140, 160, 255)
ToolIcon.TextSize = 12
ToolIcon.Font = Enum.Font.Code
local ToolNameLabel = Instance.new("TextLabel", ToolNameBar)
ToolNameLabel.Size = UDim2.new(1, -24, 1, 0)
ToolNameLabel.Position = UDim2.new(0, 20, 0, 0)
ToolNameLabel.BackgroundTransparency = 1
ToolNameLabel.Text = "no tool selected"
ToolNameLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
ToolNameLabel.TextSize = 11
ToolNameLabel.Font = Enum.Font.Code
ToolNameLabel.TextXAlignment = Enum.TextXAlignment.Left
ToolNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(1, -10, 0, 22)
SearchBar.Position = UDim2.new(0, 5, 0, 74)
SearchBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
SearchBar.BorderSizePixel = 0
SearchBar.Parent = MainFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 3)
local SearchIcon = Instance.new("TextLabel", SearchBar)
SearchIcon.Size = UDim2.new(0, 22, 1, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 11
SearchIcon.Font = Enum.Font.Code
local SearchBox = Instance.new("TextBox", SearchBar)
SearchBox.Size = UDim2.new(1, -26, 1, 0)
SearchBox.Position = UDim2.new(0, 22, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "search keys..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchBox.TextSize = 11
SearchBox.Font = Enum.Font.Code
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -100)
ScrollFrame.Position = UDim2.new(0, 5, 0, 99)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame
local ActiveModule = nil
local ActiveTable  = nil
local AllRows      = {}
local function ApplySearch(query)
    local q = query:lower():gsub("%s+", "")
    local visible = 0
    for _, entry in ipairs(AllRows) do
        local match = q == "" or tostring(entry.key):lower():find(q, 1, true)
        entry.row.Visible = match ~= nil and match ~= false
        if entry.row.Visible then visible = visible + 1 end
    end
    task.defer(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    end)
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    ApplySearch(SearchBox.Text)
end)
local function ApplyValue(key, valueString)
    if not ActiveTable then return end
    pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)
    local original = ActiveTable[key]
    local newValue = valueString
    if type(original) == "number" then
        newValue = tonumber(valueString) or original
    elseif type(original) == "boolean" then
        local l = valueString:lower()
        if l == "true" then newValue = true
        elseif l == "false" then newValue = false
        else newValue = original end
    elseif typeof(original) == "Vector3" then
        local c = {}
        for s in string.gmatch(valueString, "([^,]+)") do
            table.insert(c, tonumber(s))
        end
        if #c == 3 then newValue = Vector3.new(c[1], c[2], c[3]) end
    elseif typeof(original) == "Vector2" then
        local c = {}
        for s in string.gmatch(valueString, "([^,]+)") do
            table.insert(c, tonumber(s))
        end
        if #c == 2 then newValue = Vector2.new(c[1], c[2]) end
    elseif typeof(original) == "Color3" then
        local c = {}
        for s in string.gmatch(valueString, "([^,]+)") do
            table.insert(c, tonumber(s))
        end
        if #c == 3 then newValue = Color3.fromRGB(c[1], c[2], c[3]) end
    end
    ActiveTable[key] = newValue
    print("[WeaponEditor] Set " .. tostring(key) .. " = " .. tostring(newValue))
end
local function CreateRow(key, val)
    local typeOf = typeof(val)
    local inputColor = Color3.fromRGB(0, 255, 150)
    if type(val) == "boolean" then
        inputColor = Color3.fromRGB(255, 200, 80)
    elseif typeOf == "Vector3" or typeOf == "Vector2" then
        inputColor = Color3.fromRGB(100, 180, 255)
    elseif typeOf == "Color3" then
        inputColor = Color3.fromRGB(255, 120, 200)
    end
    local displayVal
    if typeOf == "Vector3" then
        displayVal = string.format("%.3f,%.3f,%.3f", val.X, val.Y, val.Z)
    elseif typeOf == "Vector2" then
        displayVal = string.format("%.3f,%.3f", val.X, val.Y)
    elseif typeOf == "Color3" then
        local r,g,b = math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255)
        displayVal = string.format("%d,%d,%d", r, g, b)
    else
        displayVal = tostring(val)
    end
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -5, 0, 28)
    Row.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Row.BorderSizePixel = 0
    Row.Parent = ScrollFrame
    local TypeTag = Instance.new("TextLabel", Row)
    TypeTag.Size = UDim2.new(0, 40, 1, 0)
    TypeTag.Position = UDim2.new(0, 0, 0, 0)
    TypeTag.BackgroundTransparency = 1
    TypeTag.Text = typeOf:sub(1, 3):upper()
    TypeTag.TextColor3 = inputColor
    TypeTag.TextSize = 9
    TypeTag.Font = Enum.Font.Code
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.48, -40, 1, 0)
    Label.Position = UDim2.new(0, 40, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = tostring(key)
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 11
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    local Input = Instance.new("TextBox", Row)
    Input.Size = UDim2.new(0.52, -5, 0.8, 0)
    Input.Position = UDim2.new(0.48, 0, 0.1, 0)
    Input.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    Input.Text = displayVal
    Input.TextColor3 = inputColor
    Input.TextSize = 11
    Input.Font = Enum.Font.Code
    Input.ClearTextOnFocus = false
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 3)
    Input.FocusLost:Connect(function(enterPressed)
        ApplyValue(key, Input.Text)
    end)
    table.insert(AllRows, { key = key, row = Row })
end
local function LoadModule(moduleScript, sourceLabel)
    if moduleScript == ActiveModule then return end
    local ok, result = pcall(require, moduleScript)
    if not ok or type(result) ~= "table" then
        StatusLabel.Text = "Failed to require module: " .. moduleScript.Name
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    ActiveModule = moduleScript
    ActiveTable  = result
    pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)
    AllRows = {}
    SearchBox.Text = ""
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local keys = {}
    for k, v in pairs(ActiveTable) do
        local t = type(v)
        if t ~= "table" and t ~= "function" and t ~= "thread" and t ~= "userdata" or
           typeof(v) == "Vector3" or typeof(v) == "Vector2" or typeof(v) == "Color3" then
            table.insert(keys, k)
        end
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do
        CreateRow(k, ActiveTable[k])
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    local toolName = moduleScript.Name
    if moduleScript.Parent and moduleScript.Parent.Parent and moduleScript.Parent.Parent:IsA("Tool") then
        toolName = moduleScript.Parent.Parent.Name
    elseif moduleScript.Parent and moduleScript.Parent:IsA("Tool") then
        toolName = moduleScript.Parent.Name
    elseif moduleScript.Parent then
        toolName = moduleScript.Parent.Name
    end
    StatusLabel.Text = #keys .. " keys loaded"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ToolNameLabel.Text = toolName
    SourceBadge.Text = " src: " .. (sourceLabel or "?") .. " "
end
local SETTING_MODULE_NAMES = {
    ["setting"]      = true,
    ["settings"]     = true,
    ["config"]       = true,
    ["configuration"]= true,
    ["weaponconfig"] = true,
    ["gunconfig"]    = true,
    ["weaponsettings"]= true,
    ["stats"]        = true,
    ["weaponstats"]  = true,
}
local function tryFindInTool(tool)
    local settingFolder = tool:FindFirstChild("Setting")
    if settingFolder then
        local one = settingFolder:FindFirstChild("1")
        if one and one:IsA("ModuleScript") then
            return one, "Tool>Setting>1"
        end
        if settingFolder:IsA("ModuleScript") then
            return settingFolder, "Tool>Setting"
        end
        for _, child in ipairs(settingFolder:GetChildren()) do
            if child:IsA("ModuleScript") then
                return child, "Tool>Setting>" .. child.Name
            end
        end
    end
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("ModuleScript") and SETTING_MODULE_NAMES[child.Name:lower()] then
            return child, "Tool>" .. child.Name
        end
    end
    return nil, nil
end
local function scanReplicatedStorage()
    local gunKeywords = {"gun", "weapon", "rifle", "pistol", "smg", "shotgun", "sniper", "firearm", "ar", "lmg"}
    local function looksLikeWeapon(name)
        local l = name:lower()
        for _, kw in ipairs(gunKeywords) do
            if l:find(kw) then return true end
        end
        return false
    end
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("ModuleScript") and SETTING_MODULE_NAMES[descendant.Name:lower()] then
            local ancestor = descendant.Parent
            while ancestor and ancestor ~= ReplicatedStorage do
                if looksLikeWeapon(ancestor.Name) then
                    return descendant, "RepStorage>" .. ancestor.Name
                end
                ancestor = ancestor.Parent
            end
        end
    end
    local candidates = {}
    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("ModuleScript") and SETTING_MODULE_NAMES[descendant.Name:lower()] then
            table.insert(candidates, descendant)
        end
    end
    if #candidates == 1 then
        return candidates[1], "RepStorage"
    end
    return nil, nil
end
task.spawn(function()
    while task.wait(1) do
        local found, source = nil, nil
        local searchAreas = {lp.Backpack, lp.Character}
        for _, area in ipairs(searchAreas) do
            if area then
                for _, tool in ipairs(area:GetChildren()) do
                    if tool:IsA("Tool") then
                        found, source = tryFindInTool(tool)
                        if found then break end
                    end
                end
            end
            if found then break end
        end
        if not found then
            found, source = scanReplicatedStorage()
        end
        if found then
            if found ~= ActiveModule then
                LoadModule(found, source)
            end
        else
            if ActiveModule then
                ActiveModule = nil
                ActiveTable  = nil
                for _, v in pairs(ScrollFrame:GetChildren()) do
                    if v:IsA("Frame") then v:Destroy() end
                end
                ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                SourceBadge.Text = ""
                ToolNameLabel.Text = "no tool selected"
                AllRows = {}
                SearchBox.Text = ""
            end
            StatusLabel.Text = "Scanning for weapon module..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
print("[WeaponEditor] Loaded. RightCtrl to toggle.")
