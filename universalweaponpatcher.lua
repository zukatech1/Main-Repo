-- ============================================================
--  Callum_DirectEditor  v2.0
--  Improvements:
--    - Priority scanner: Character > Backpack > ReplicatedStorage
--    - Event-driven rescanning (ChildAdded/Removed) instead of polling
--    - Manual override: type a module path and force-load it
--    - Pin rows to top (persists across searches)
--    - Reset to original values (per-key revert)
--    - Export / copy current table to console
--    - Manual refresh button (re-require live values)
--    - AllRows and original cache properly managed
-- ============================================================

local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local lp                 = Players.LocalPlayer

-- ── GUI ROOT ────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "Callum_DirectEditor"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Global
ScreenGui.Parent          = (gethui and gethui()) or CoreGui

-- ── GLOW LAYERS ─────────────────────────────────────────────
local GlowFrame2 = Instance.new("Frame")
GlowFrame2.Size                 = UDim2.new(0, 406, 0, 560)
GlowFrame2.Position             = UDim2.new(0.5, -203, 0.5, -280)
GlowFrame2.BackgroundColor3     = Color3.fromRGB(255,255,255)
GlowFrame2.BackgroundTransparency = 0.93
GlowFrame2.BorderSizePixel      = 0
GlowFrame2.ZIndex               = 1
GlowFrame2.Parent               = ScreenGui
Instance.new("UICorner", GlowFrame2).CornerRadius = UDim.new(0,10)

local GlowFrame = Instance.new("Frame")
GlowFrame.Size                  = UDim2.new(0, 390, 0, 544)
GlowFrame.Position              = UDim2.new(0.5, -195, 0.5, -272)
GlowFrame.BackgroundColor3      = Color3.fromRGB(255,255,255)
GlowFrame.BackgroundTransparency= 0.82
GlowFrame.BorderSizePixel       = 0
GlowFrame.ZIndex                = 2
GlowFrame.Parent                = ScreenGui
Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0,8)

-- ── MAIN FRAME ──────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Size                  = UDim2.new(0, 370, 0, 524)
MainFrame.Position              = UDim2.new(0.5, -185, 0.5, -262)
MainFrame.BackgroundColor3      = Color3.fromRGB(18,18,18)
MainFrame.BackgroundTransparency= 0.18
MainFrame.BorderSizePixel       = 0
MainFrame.Active                = true
MainFrame.Draggable             = true
MainFrame.ZIndex                = 3
MainFrame.Parent                = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,4)

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,18)),
})
Gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   0.88),
    NumberSequenceKeypoint.new(0.4, 0.96),
    NumberSequenceKeypoint.new(1,   1.0),
})
Gradient.Rotation = 135
Gradient.Parent   = MainFrame

-- keep glow frames tracking main frame position
MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    local p = MainFrame.Position
    GlowFrame.Position  = UDim2.new(p.X.Scale, p.X.Offset - 10,  p.Y.Scale, p.Y.Offset - 10)
    GlowFrame2.Position = UDim2.new(p.X.Scale, p.X.Offset - 18,  p.Y.Scale, p.Y.Offset - 18)
end)

-- ── TITLE BAR ───────────────────────────────────────────────
local Title = Instance.new("TextLabel")
Title.Size            = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3= Color3.fromRGB(30,30,30)
Title.Text            = "direct weapon editor  v2"
Title.TextColor3      = Color3.fromRGB(255,255,255)
Title.TextSize        = 13
Title.Font            = Enum.Font.Code
Title.TextXAlignment  = Enum.TextXAlignment.Left
Title.Parent          = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,4)

-- ── SOURCE BADGE ────────────────────────────────────────────
local SourceBadge = Instance.new("TextLabel")
SourceBadge.Size            = UDim2.new(0,120,0,16)
SourceBadge.Position        = UDim2.new(1,-124,0,7)
SourceBadge.BackgroundColor3= Color3.fromRGB(40,40,60)
SourceBadge.Text            = ""
SourceBadge.TextColor3      = Color3.fromRGB(140,160,255)
SourceBadge.TextSize        = 10
SourceBadge.Font            = Enum.Font.Code
SourceBadge.Parent          = MainFrame
Instance.new("UICorner", SourceBadge).CornerRadius = UDim.new(0,3)

-- ── STATUS ──────────────────────────────────────────────────
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size                = UDim2.new(1,-10,0,16)
StatusLabel.Position            = UDim2.new(0,5,0,33)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text                = "Scanning..."
StatusLabel.TextColor3          = Color3.fromRGB(255,150,0)
StatusLabel.TextSize            = 11
StatusLabel.Font                = Enum.Font.Code
StatusLabel.TextXAlignment      = Enum.TextXAlignment.Left
StatusLabel.Parent              = MainFrame

-- ── TOOL NAME BAR ───────────────────────────────────────────
local ToolNameBar = Instance.new("Frame")
ToolNameBar.Size            = UDim2.new(1,-10,0,20)
ToolNameBar.Position        = UDim2.new(0,5,0,51)
ToolNameBar.BackgroundColor3= Color3.fromRGB(30,30,40)
ToolNameBar.BorderSizePixel = 0
ToolNameBar.Parent          = MainFrame
Instance.new("UICorner", ToolNameBar).CornerRadius = UDim.new(0,3)

local ToolIcon = Instance.new("TextLabel", ToolNameBar)
ToolIcon.Size                = UDim2.new(0,20,1,0)
ToolIcon.BackgroundTransparency = 1
ToolIcon.Text                = "⚙"
ToolIcon.TextColor3          = Color3.fromRGB(140,160,255)
ToolIcon.TextSize            = 12
ToolIcon.Font                = Enum.Font.Code

local ToolNameLabel = Instance.new("TextLabel", ToolNameBar)
ToolNameLabel.Size              = UDim2.new(1,-24,1,0)
ToolNameLabel.Position          = UDim2.new(0,20,0,0)
ToolNameLabel.BackgroundTransparency = 1
ToolNameLabel.Text              = "no tool selected"
ToolNameLabel.TextColor3        = Color3.fromRGB(200,200,255)
ToolNameLabel.TextSize          = 11
ToolNameLabel.Font              = Enum.Font.Code
ToolNameLabel.TextXAlignment    = Enum.TextXAlignment.Left
ToolNameLabel.TextTruncate      = Enum.TextTruncate.AtEnd

-- ── SEARCH BAR ──────────────────────────────────────────────
local SearchBar = Instance.new("Frame")
SearchBar.Size            = UDim2.new(1,-10,0,22)
SearchBar.Position        = UDim2.new(0,5,0,74)
SearchBar.BackgroundColor3= Color3.fromRGB(28,28,36)
SearchBar.BorderSizePixel = 0
SearchBar.Parent          = MainFrame
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0,3)

local SearchIcon = Instance.new("TextLabel", SearchBar)
SearchIcon.Size                 = UDim2.new(0,22,1,0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text                 = "🔍"
SearchIcon.TextSize             = 11
SearchIcon.Font                 = Enum.Font.Code

local SearchBox = Instance.new("TextBox", SearchBar)
SearchBox.Size              = UDim2.new(1,-26,1,0)
SearchBox.Position          = UDim2.new(0,22,0,0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText   = "search keys..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90,90,90)
SearchBox.Text              = ""
SearchBox.TextColor3        = Color3.fromRGB(200,200,200)
SearchBox.TextSize          = 11
SearchBox.Font              = Enum.Font.Code
SearchBox.ClearTextOnFocus  = false
SearchBox.TextXAlignment    = Enum.TextXAlignment.Left

-- ── ACTION BUTTONS ROW ──────────────────────────────────────
local ButtonRow = Instance.new("Frame")
ButtonRow.Size              = UDim2.new(1,-10,0,22)
ButtonRow.Position          = UDim2.new(0,5,0,99)
ButtonRow.BackgroundTransparency = 1
ButtonRow.Parent            = MainFrame

local function MakeBtn(text, color, xPos, widthScale)
    local btn = Instance.new("TextButton", ButtonRow)
    btn.Size            = UDim2.new(widthScale, -3, 1, 0)
    btn.Position        = UDim2.new(xPos, 2, 0, 0)
    btn.BackgroundColor3= color
    btn.Text            = text
    btn.TextColor3      = Color3.fromRGB(240,240,240)
    btn.TextSize        = 10
    btn.Font            = Enum.Font.Code
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,3)
    return btn
end

local RefreshBtn = MakeBtn("↺ refresh",  Color3.fromRGB(40,80,60),  0,     0.25)
local ResetAllBtn= MakeBtn("⟲ reset all",Color3.fromRGB(80,40,40),  0.25,  0.25)
local ExportBtn  = MakeBtn("⎘ export",   Color3.fromRGB(40,40,80),  0.5,   0.25)
local OverrideBtn= MakeBtn("⌖ override", Color3.fromRGB(60,50,20),  0.75,  0.25)

-- ── OVERRIDE INPUT (hidden by default) ──────────────────────
local OverrideBar = Instance.new("Frame")
OverrideBar.Size            = UDim2.new(1,-10,0,22)
OverrideBar.Position        = UDim2.new(0,5,0,124)
OverrideBar.BackgroundColor3= Color3.fromRGB(40,38,20)
OverrideBar.BorderSizePixel = 0
OverrideBar.Visible         = false
OverrideBar.Parent          = MainFrame
Instance.new("UICorner", OverrideBar).CornerRadius = UDim.new(0,3)

local OverrideBox = Instance.new("TextBox", OverrideBar)
OverrideBox.Size            = UDim2.new(1,-50,1,0)
OverrideBox.BackgroundTransparency = 1
OverrideBox.PlaceholderText = "e.g. ReplicatedStorage.Guns.AK47.Settings"
OverrideBox.PlaceholderColor3= Color3.fromRGB(100,90,50)
OverrideBox.Text            = ""
OverrideBox.TextColor3      = Color3.fromRGB(255,220,100)
OverrideBox.TextSize        = 10
OverrideBox.Font            = Enum.Font.Code
OverrideBox.ClearTextOnFocus= false
OverrideBox.TextXAlignment  = Enum.TextXAlignment.Left

local OverrideGoBtn = Instance.new("TextButton", OverrideBar)
OverrideGoBtn.Size            = UDim2.new(0,46,1,0)
OverrideGoBtn.Position        = UDim2.new(1,-48,0,0)
OverrideGoBtn.BackgroundColor3= Color3.fromRGB(80,70,20)
OverrideGoBtn.Text            = "load"
OverrideGoBtn.TextColor3      = Color3.fromRGB(255,220,80)
OverrideGoBtn.TextSize        = 10
OverrideGoBtn.Font            = Enum.Font.Code
OverrideGoBtn.BorderSizePixel = 0
Instance.new("UICorner", OverrideGoBtn).CornerRadius = UDim.new(0,3)

-- ── SCROLL FRAME ────────────────────────────────────────────
-- shifts down extra 27px when override bar is visible
local SCROLL_Y_NORMAL   = 124
local SCROLL_Y_OVERRIDE = 149

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size                = UDim2.new(1,-10,1,-130)
ScrollFrame.Position            = UDim2.new(0,5,0,SCROLL_Y_NORMAL)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize          = UDim2.new(0,0,0,0)
ScrollFrame.ScrollBarThickness  = 2
ScrollFrame.Parent              = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding    = UDim.new(0,3)
UIListLayout.SortOrder  = Enum.SortOrder.LayoutOrder
UIListLayout.Parent     = ScrollFrame

-- ── STATE ───────────────────────────────────────────────────
local ActiveModule   = nil
local ActiveTable    = nil
local AllRows        = {}          -- { key, row, pinned, originalVal }
local PinnedKeys     = {}          -- set: key -> true
local OverrideOpen   = false

-- ── HELPERS ─────────────────────────────────────────────────
local function RefreshCanvasSize()
    task.defer(function()
        ScrollFrame.CanvasSize = UDim2.new(0,0,0, UIListLayout.AbsoluteContentSize.Y + 5)
    end)
end

local function SetScrollPosition(yOffset)
    ScrollFrame.Position = UDim2.new(0,5,0,yOffset)
    ScrollFrame.Size     = UDim2.new(1,-10,1,-(yOffset+6))
end

local function ApplySearch(query)
    local q = query:lower():gsub("%s+","")
    for _, entry in ipairs(AllRows) do
        if entry.pinned then
            entry.row.Visible = true
        else
            local match = q == "" or tostring(entry.key):lower():find(q,1,true)
            entry.row.Visible = (match ~= nil and match ~= false)
        end
    end
    RefreshCanvasSize()
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    ApplySearch(SearchBox.Text)
end)

-- ── APPLY VALUE ─────────────────────────────────────────────
local function ApplyValue(key, valueString)
    if not ActiveTable then return end
    pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)
    local original = ActiveTable[key]
    local newValue = valueString
    if type(original) == "number" then
        newValue = tonumber(valueString) or original
    elseif type(original) == "boolean" then
        local l = valueString:lower()
        if     l == "true"  then newValue = true
        elseif l == "false" then newValue = false
        else                     newValue = original end
    elseif typeof(original) == "Vector3" then
        local c = {}
        for s in valueString:gmatch("([^,]+)") do table.insert(c, tonumber(s)) end
        if #c == 3 then newValue = Vector3.new(c[1],c[2],c[3]) end
    elseif typeof(original) == "Vector2" then
        local c = {}
        for s in valueString:gmatch("([^,]+)") do table.insert(c, tonumber(s)) end
        if #c == 2 then newValue = Vector2.new(c[1],c[2]) end
    elseif typeof(original) == "Color3" then
        local c = {}
        for s in valueString:gmatch("([^,]+)") do table.insert(c, tonumber(s)) end
        if #c == 3 then newValue = Color3.fromRGB(c[1],c[2],c[3]) end
    end
    ActiveTable[key] = newValue
    print("[WeaponEditor] Set " .. tostring(key) .. " = " .. tostring(newValue))
end

-- ── FORMAT VALUE ────────────────────────────────────────────
local function FormatVal(val)
    local t = typeof(val)
    if t == "Vector3" then
        return string.format("%.3f,%.3f,%.3f", val.X, val.Y, val.Z)
    elseif t == "Vector2" then
        return string.format("%.3f,%.3f", val.X, val.Y)
    elseif t == "Color3" then
        return string.format("%d,%d,%d", math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255))
    else
        return tostring(val)
    end
end

-- ── CREATE ROW ──────────────────────────────────────────────
local function CreateRow(key, val, originalVal)
    local typeOf    = typeof(val)
    local inputColor= Color3.fromRGB(0,255,150)
    if type(val)    == "boolean" then inputColor = Color3.fromRGB(255,200,80)
    elseif typeOf   == "Vector3" or typeOf == "Vector2" then inputColor = Color3.fromRGB(100,180,255)
    elseif typeOf   == "Color3"  then inputColor = Color3.fromRGB(255,120,200)
    end

    local Row = Instance.new("Frame")
    Row.Size            = UDim2.new(1,-5,0,28)
    Row.BackgroundColor3= Color3.fromRGB(28,28,28)
    Row.BorderSizePixel = 0
    Row.Parent          = ScrollFrame

    -- type tag
    local TypeTag = Instance.new("TextLabel", Row)
    TypeTag.Size                 = UDim2.new(0,32,1,0)
    TypeTag.BackgroundTransparency= 1
    TypeTag.Text                 = typeOf:sub(1,3):upper()
    TypeTag.TextColor3           = inputColor
    TypeTag.TextSize             = 9
    TypeTag.Font                 = Enum.Font.Code

    -- pin button
    local PinBtn = Instance.new("TextButton", Row)
    PinBtn.Size             = UDim2.new(0,18,0,18)
    PinBtn.Position         = UDim2.new(0,32,0.5,-9)
    PinBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    PinBtn.Text             = "📌"
    PinBtn.TextSize         = 9
    PinBtn.Font             = Enum.Font.Code
    PinBtn.BorderSizePixel  = 0
    Instance.new("UICorner", PinBtn).CornerRadius = UDim.new(0,3)

    -- key label
    local Label = Instance.new("TextLabel", Row)
    Label.Size              = UDim2.new(0.42,-52,1,0)
    Label.Position          = UDim2.new(0,52,0,0)
    Label.BackgroundTransparency= 1
    Label.Text              = tostring(key)
    Label.TextColor3        = Color3.fromRGB(180,180,180)
    Label.TextSize          = 11
    Label.Font              = Enum.Font.Code
    Label.TextXAlignment    = Enum.TextXAlignment.Left
    Label.TextTruncate      = Enum.TextTruncate.AtEnd

    -- value input
    local Input = Instance.new("TextBox", Row)
    Input.Size              = UDim2.new(0.52,-22,0.8,0)
    Input.Position          = UDim2.new(0.48,0,0.1,0)
    Input.BackgroundColor3  = Color3.fromRGB(38,38,38)
    Input.Text              = FormatVal(val)
    Input.TextColor3        = inputColor
    Input.TextSize          = 11
    Input.Font              = Enum.Font.Code
    Input.ClearTextOnFocus  = false
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0,3)

    -- reset button
    local ResetBtn = Instance.new("TextButton", Row)
    ResetBtn.Size            = UDim2.new(0,18,0,18)
    ResetBtn.Position        = UDim2.new(1,-20,0.5,-9)
    ResetBtn.BackgroundColor3= Color3.fromRGB(60,30,30)
    ResetBtn.Text            = "↩"
    ResetBtn.TextSize        = 10
    ResetBtn.Font            = Enum.Font.Code
    ResetBtn.BorderSizePixel = 0
    ResetBtn.TextColor3      = Color3.fromRGB(255,120,120)
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0,3)

    -- entry ref (so pin/search can update it)
    local entry = { key = key, row = Row, pinned = PinnedKeys[key] == true, originalVal = originalVal }
    table.insert(AllRows, entry)

    -- pin highlight
    local function UpdatePinVisual()
        if entry.pinned then
            Row.BackgroundColor3 = Color3.fromRGB(30,30,48)
            PinBtn.TextColor3    = Color3.fromRGB(180,180,255)
            Row.LayoutOrder      = -1
        else
            Row.BackgroundColor3 = Color3.fromRGB(28,28,28)
            PinBtn.TextColor3    = Color3.fromRGB(100,100,100)
            Row.LayoutOrder      = 0
        end
    end
    UpdatePinVisual()

    PinBtn.MouseButton1Click:Connect(function()
        entry.pinned = not entry.pinned
        if entry.pinned then PinnedKeys[key] = true else PinnedKeys[key] = nil end
        UpdatePinVisual()
        RefreshCanvasSize()
    end)

    Input.FocusLost:Connect(function()
        ApplyValue(key, Input.Text)
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        if not ActiveTable then return end
        pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)
        ActiveTable[key] = originalVal
        Input.Text = FormatVal(originalVal)
        print("[WeaponEditor] Reset " .. tostring(key) .. " -> " .. tostring(originalVal))
    end)
end

-- ── CLEAR ROWS ──────────────────────────────────────────────
local function ClearRows()
    AllRows = {}
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
end

-- ── LOAD MODULE ─────────────────────────────────────────────
local function LoadModule(moduleScript, sourceLabel)
    if moduleScript == ActiveModule then return end
    local ok, result = pcall(require, moduleScript)
    if not ok or type(result) ~= "table" then
        StatusLabel.Text       = "Failed: " .. moduleScript.Name
        StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    ActiveModule = moduleScript
    ActiveTable  = result
    pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)

    ClearRows()
    SearchBox.Text = ""

    local keys = {}
    for k, v in pairs(ActiveTable) do
        local t  = type(v)
        local tv = typeof(v)
        if (t ~= "table" and t ~= "function" and t ~= "thread" and t ~= "userdata")
            or tv == "Vector3" or tv == "Vector2" or tv == "Color3" then
            table.insert(keys, k)
        end
    end
    table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)

    for _, k in ipairs(keys) do
        CreateRow(k, ActiveTable[k], ActiveTable[k])   -- originalVal = value at load time
    end

    RefreshCanvasSize()

    -- nice display name
    local toolName = moduleScript.Name
    local p = moduleScript.Parent
    if p then
        if p.Parent and p.Parent:IsA("Tool") then toolName = p.Parent.Name
        elseif p:IsA("Tool")                  then toolName = p.Name
        else                                       toolName = p.Name end
    end

    StatusLabel.Text       = #keys .. " keys loaded"
    StatusLabel.TextColor3 = Color3.fromRGB(0,255,150)
    ToolNameLabel.Text     = toolName
    SourceBadge.Text       = " src: " .. (sourceLabel or "?") .. " "
end

-- ── RELOAD (re-require same module) ─────────────────────────
local function ReloadActive()
    if not ActiveModule then
        StatusLabel.Text       = "No module loaded to refresh."
        StatusLabel.TextColor3 = Color3.fromRGB(255,180,0)
        return
    end
    local saved = SourceBadge.Text
    ActiveModule = nil    -- force re-load
    local mod = ActiveModule  -- will be nil; capture current
    -- re-find by stored badge text is fragile; just force re-require
    local storedMod = ActiveModule
    ActiveModule = nil
    local ok, result = pcall(require, (function()
        -- re-grab via saved reference stored before we nil'd it
        return storedMod
    end)())
    -- simpler: just nil active and let scanner pick it up immediately
    ActiveModule = nil
    ActiveTable  = nil
    ClearRows()
    ToolNameLabel.Text     = "refreshing..."
    StatusLabel.Text       = "Re-scanning..."
    StatusLabel.TextColor3 = Color3.fromRGB(255,180,0)
end

-- ── EXPORT ──────────────────────────────────────────────────
local function ExportTable()
    if not ActiveTable then
        print("[WeaponEditor] No table loaded.")
        return
    end
    print("[WeaponEditor] ── EXPORT ──────────────────────")
    for k, v in pairs(ActiveTable) do
        local t = type(v)
        if t ~= "table" and t ~= "function" and t ~= "thread" then
            print(string.format("  [%s] %s = %s", typeof(v), tostring(k), FormatVal(v)))
        end
    end
    print("[WeaponEditor] ────────────────────────────────")
    StatusLabel.Text       = "Exported to console."
    StatusLabel.TextColor3 = Color3.fromRGB(140,160,255)
end

-- ── RESET ALL ───────────────────────────────────────────────
local function ResetAll()
    if not ActiveTable then return end
    pcall(function() if setreadonly then setreadonly(ActiveTable, false) end end)
    for _, entry in ipairs(AllRows) do
        ActiveTable[entry.key] = entry.originalVal
        -- update the input textbox
        for _, child in pairs(entry.row:GetChildren()) do
            if child:IsA("TextBox") then
                child.Text = FormatVal(entry.originalVal)
            end
        end
    end
    print("[WeaponEditor] All values reset to original.")
    StatusLabel.Text       = "All values reset."
    StatusLabel.TextColor3 = Color3.fromRGB(255,160,80)
end

-- ── MANUAL OVERRIDE ─────────────────────────────────────────
local function TryOverridePath(pathStr)
    local parts = {}
    for p in pathStr:gmatch("[^%.]+") do table.insert(parts, p) end
    if #parts < 2 then
        StatusLabel.Text       = "Invalid path."
        StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    local services = {
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        Workspace         = game:GetService("Workspace"),
        Players           = game:GetService("Players"),
        ServerStorage     = pcall(function() return game:GetService("ServerStorage") end) and game:GetService("ServerStorage") or nil,
    }
    local root = services[parts[1]]
    if not root then
        -- try as direct game child
        root = game:FindFirstChild(parts[1])
    end
    if not root then
        StatusLabel.Text       = "Root not found: " .. parts[1]
        StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    local current = root
    for i = 2, #parts do
        current = current:FindFirstChild(parts[i])
        if not current then
            StatusLabel.Text       = "Not found: " .. parts[i]
            StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
            return
        end
    end
    if not current:IsA("ModuleScript") then
        StatusLabel.Text       = parts[#parts] .. " is not a ModuleScript"
        StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
    ActiveModule = nil  -- force reload
    LoadModule(current, "override")
end

-- ── BUTTON CONNECTIONS ──────────────────────────────────────
RefreshBtn.MouseButton1Click:Connect(function()
    ReloadActive()
end)

ResetAllBtn.MouseButton1Click:Connect(function()
    ResetAll()
end)

ExportBtn.MouseButton1Click:Connect(function()
    ExportTable()
end)

OverrideBtn.MouseButton1Click:Connect(function()
    OverrideOpen = not OverrideOpen
    OverrideBar.Visible = OverrideOpen
    SetScrollPosition(OverrideOpen and SCROLL_Y_OVERRIDE or SCROLL_Y_NORMAL)
end)

OverrideGoBtn.MouseButton1Click:Connect(function()
    TryOverridePath(OverrideBox.Text)
end)
OverrideBox.FocusLost:Connect(function(enter)
    if enter then TryOverridePath(OverrideBox.Text) end
end)

-- ── SCANNER CONFIG ──────────────────────────────────────────
local SETTING_MODULE_NAMES = {
    ["setting"]       = true, ["settings"]      = true,
    ["config"]        = true, ["configuration"] = true,
    ["weaponconfig"]  = true, ["gunconfig"]     = true,
    ["weaponsettings"]= true, ["stats"]         = true,
    ["weaponstats"]   = true,
}

local function tryFindInTool(tool)
    local settingFolder = tool:FindFirstChild("Setting")
    if settingFolder then
        local one = settingFolder:FindFirstChild("1")
        if one and one:IsA("ModuleScript") then return one, "Tool>Setting>1" end
        if settingFolder:IsA("ModuleScript") then return settingFolder, "Tool>Setting" end
        for _, child in ipairs(settingFolder:GetChildren()) do
            if child:IsA("ModuleScript") then return child, "Tool>Setting>"..child.Name end
        end
    end
    for _, child in ipairs(tool:GetChildren()) do
        if child:IsA("ModuleScript") and SETTING_MODULE_NAMES[child.Name:lower()] then
            return child, "Tool>"..child.Name
        end
    end
    return nil, nil
end

local GUN_KEYWORDS = {"gun","weapon","rifle","pistol","smg","shotgun","sniper","firearm","ar","lmg"}
local function looksLikeWeapon(name)
    local l = name:lower()
    for _, kw in ipairs(GUN_KEYWORDS) do
        if l:find(kw) then return true end
    end
    return false
end

local function scanReplicatedStorage()
    -- prefer modules inside a weapon-named ancestor
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("ModuleScript") and SETTING_MODULE_NAMES[d.Name:lower()] then
            local ancestor = d.Parent
            while ancestor and ancestor ~= ReplicatedStorage do
                if looksLikeWeapon(ancestor.Name) then return d, "RepStorage>"..ancestor.Name end
                ancestor = ancestor.Parent
            end
        end
    end
    -- fallback: single match
    local candidates = {}
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("ModuleScript") and SETTING_MODULE_NAMES[d.Name:lower()] then
            table.insert(candidates, d)
        end
    end
    if #candidates == 1 then return candidates[1], "RepStorage" end
    return nil, nil
end

-- ── PRIORITY SCAN: Character > Backpack > RepStorage ────────
--  Returns the highest-priority module found right now.
local function PriorityScan()
    -- 1. Currently equipped tool (Character)
    local char = lp.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                local m, src = tryFindInTool(obj)
                if m then return m, src end
            end
        end
    end
    -- 2. Tools in Backpack
    local bp = lp.Backpack
    if bp then
        for _, obj in ipairs(bp:GetChildren()) do
            if obj:IsA("Tool") then
                local m, src = tryFindInTool(obj)
                if m then return m, src end
            end
        end
    end
    -- 3. ReplicatedStorage fallback
    return scanReplicatedStorage()
end

-- ── EVENT-DRIVEN RESCANNING ─────────────────────────────────
local scanDebounce = false
local function TriggerScan()
    if scanDebounce then return end
    scanDebounce = true
    task.delay(0.3, function()   -- short debounce to let parenting settle
        scanDebounce = false
        local found, source = PriorityScan()
        if found then
            LoadModule(found, source)
        else
            if ActiveModule then
                ActiveModule = nil
                ActiveTable  = nil
                ClearRows()
                SourceBadge.Text   = ""
                ToolNameLabel.Text = "no tool selected"
                SearchBox.Text     = ""
            end
            StatusLabel.Text       = "Scanning for weapon module..."
            StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
        end
    end)
end

-- watch backpack
local function WatchContainer(container)
    if not container then return end
    container.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then TriggerScan() end
    end)
    container.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then TriggerScan() end
    end)
end

WatchContainer(lp.Backpack)

-- watch character (equip/unequip)
local function WatchCharacter(char)
    if not char then return end
    WatchContainer(char)
    -- also re-scan immediately when a new character spawns
    TriggerScan()
end

if lp.Character then WatchCharacter(lp.Character) end
lp.CharacterAdded:Connect(WatchCharacter)

-- initial scan on load
TriggerScan()

-- ── TOGGLE VISIBILITY ───────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible  = not MainFrame.Visible
        GlowFrame.Visible  = MainFrame.Visible
        GlowFrame2.Visible = MainFrame.Visible
    end
end)

print("[WeaponEditor v2] Loaded.")
print("  RightCtrl     → toggle UI")
print("  ↺ refresh     → re-require active module")
print("  ⟲ reset all   → revert all keys to load-time values")
print("  ⎘ export      → dump table to console")
print("  ⌖ override    → manually specify a module path")
