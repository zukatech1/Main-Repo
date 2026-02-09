local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
if not _G.Modules then
    _G.Modules = {}
end
local Modules = _G.Modules
Modules.Overseer95 = {
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
        DisabledModules = {},
        TracerActive = false,
        CallTrace = {},
        MaxTraceSize = 500,
        EventSpyActive = false,
        EventLog = {},
        MaxEventLogSize = 500,
        EditingValue = nil,
        EditingTable = nil,
        EditingKey = nil,
        PatchProfiles = {},
        SavedProfiles = {},
        CodeInjectCache = {},
        FunctionReplaceMap = {},
        InstanceHooks = {},
        LuaEnvironmentAccess = {},
        RuntimeInjections = {},
        PatchHistory = {},
        VisitedTables = {}
    },
    Config = {
        WINDOW_GRAY = Color3.fromRGB(192, 192, 192),
        DARK_GRAY = Color3.fromRGB(128, 128, 128),
        LIGHT_GRAY = Color3.fromRGB(223, 223, 223),
        WHITE = Color3.fromRGB(255, 255, 255),
        BLACK = Color3.fromRGB(0, 0, 0),
        TITLE_BLUE = Color3.fromRGB(0, 0, 128),
        TITLE_GRADIENT_END = Color3.fromRGB(16, 132, 208),
        BUTTON_FACE = Color3.fromRGB(192, 192, 192),
        ACCENT_TEAL = Color3.fromRGB(0, 128, 128),
        BUTTON_HEIGHT = 24,
        ROW_HEIGHT = 35,
        FILTER_HEIGHT = 40,
        PADDING = 4,
        CORNER_RADIUS = 0
    },
    RemoteSpy = {
        MaxLogSize = 500,
        RecordingTypes = { "FireServer", "FireClient", "InvokeServer" },
        ForensicLogging = true,
        DecodingEnabled = true
    }
}
function Modules.Overseer95:_createWin95Border(parent, isInset)
    local topColor = isInset and self.Config.DARK_GRAY or self.Config.WHITE
    local bottomColor = isInset and self.Config.WHITE or self.Config.DARK_GRAY
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
function Modules.Overseer95:_applyStyle(obj, radius)
    obj.BorderSizePixel = 0
end
function Modules.Overseer95:_setClipboard(txt)
    if setclipboard then
        setclipboard(txt)
    elseif toclipboard then
        toclipboard(txt)
    end
end
function Modules.Overseer95:_decodeBase64(data)
    local success, result = pcall(function()
        local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        data = string.gsub(data, "[^" .. BASE64_ALPHABET .. "=]", "")
        local decoded = ""
        local buffer = 0
        local bitCount = 0
        for i = 1, #data do
            local char = string.sub(data, i, i)
            if char == "=" then break end
            local value = string.find(BASE64_ALPHABET, char, 1, true) - 1
            if bit32 then
                buffer = bit32.lshift(buffer, 6) + value
                bitCount = bitCount + 6
                if bitCount >= 8 then
                    bitCount = bitCount - 8
                    local byte = bit32.extract(buffer, bitCount, 8)
                    decoded = decoded .. string.char(byte)
                end
            end
        end
        return decoded
    end)
    return success and result or nil
end
function Modules.Overseer95:_decodeHex(data)
    local success, result = pcall(function()
        local decoded = ""
        for i = 1, #data, 2 do
            local hexPair = string.sub(data, i, i + 1)
            local byte = tonumber(hexPair, 16)
            if not byte then return nil end
            decoded = decoded .. string.char(byte)
        end
        return decoded
    end)
    return success and result or nil
end
function Modules.Overseer95:_isLikelyHex(data)
    return #data % 2 == 0 and string.match(data, "^[0-9a-fA-F]+$") ~= nil
end
function Modules.Overseer95:_isLikelyBase64(data)
    return #data % 4 == 0 and string.match(data, "^[A-Za-z0-9+/]+=?=?$") ~= nil
end
function Modules.Overseer95:_forensicDecodeArg(arg)
    if type(arg) ~= "string" or #arg < 4 then
        return {Type = "string", Decoded = arg}
    end
    if self:_isLikelyHex(arg) then
        local decoded = self:_decodeHex(arg)
        if decoded and string.match(decoded, "[%w%s%p]+") then
            return {Type = "Hexadecimal", Raw = arg, Decoded = decoded}
        end
    end
    if self:_isLikelyBase64(arg) then
        local decoded = self:_decodeBase64(arg)
        if decoded and string.match(decoded, "[%w%s%p]+") then
            return {Type = "Base64", Raw = arg, Decoded = decoded}
        end
    end
    return {Type = "string", Decoded = arg}
end
function Modules.Overseer95:_showErrorInGrid(errorText)
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local errorLabel = Instance.new("TextLabel", ui.Grid)
    errorLabel.Size = UDim2.new(1, -10, 0, 40)
    errorLabel.Text = errorText
    errorLabel.TextColor3 = self.Config.BLACK
    errorLabel.BackgroundColor3 = self.Config.WINDOW_GRAY
    errorLabel.Font = Enum.Font.SourceSans
    errorLabel.TextSize = 11
    errorLabel.TextWrapped = true
    self:_createWin95Border(errorLabel, true)
end
function Modules.Overseer95:_cleanupModuleHooks(mod)
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
function Modules.Overseer95:_validatePatches()
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
function Modules.Overseer95:_validateHooks()
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
function Modules.Overseer95:_generateObfuscatedName()
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local length = math.random(10, 20)
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    return result
end
function Modules.Overseer95:_applyEnvironment(func, scriptInstance)
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
    if setfenv then
        setfenv(func, fenv)
    end
    return func
end
function Modules.Overseer95:_createButton(parent, text, size, position, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = self.Config.BUTTON_FACE
    btn.Text = text
    btn.TextColor3 = self.Config.BLACK
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    self:_createWin95Border(btn, false)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = self.Config.DARK_GRAY
        for _, child in ipairs(btn:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Config.DARK_GRAY
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Config.WHITE
            end
        end
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = self.Config.BUTTON_FACE
        for _, child in ipairs(btn:GetChildren()) do
            if child.Name == "TopBorder" or child.Name == "LeftBorder" then
                child.BackgroundColor3 = self.Config.WHITE
            elseif child.Name == "BottomBorder" or child.Name == "RightBorder" then
                child.BackgroundColor3 = self.Config.DARK_GRAY
            end
        end
    end)
    return btn
end
function Modules.Overseer95:_createLabel(parent, text, size, position, textColor)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = size
    lbl.Position = position
    lbl.Text = text
    lbl.TextColor3 = textColor or self.Config.BLACK
    lbl.BackgroundColor3 = self.Config.WINDOW_GRAY
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    return lbl
end
function Modules.Overseer95:_createRow(parent, labelText, labelSize, labelColor)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
    row.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", row)
    label.Size = labelSize or UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = labelColor or self.Config.BLACK
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ClipsDescendants = true
    return row, label
end
function Modules.Overseer95:CreateUI()
    if self.State.UI and self.State.UI.Main then
        self.State.UI.Main.Visible = true
        return
    end
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "Overseer_Win95_Edition"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.fromOffset(850, 570)
    main.Position = UDim2.new(0.5, -425, 0.5, -285)
    main.BackgroundColor3 = self.Config.WINDOW_GRAY
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    self:_createWin95Border(main, false)
    local titleBar = Instance.new("Frame", main)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -4, 0, 24)
    titleBar.Position = UDim2.fromOffset(2, 2)
    titleBar.BackgroundColor3 = self.Config.TITLE_BLUE
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
    }
    titleGradient.Rotation = 90
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.fromOffset(4, 0)
    title.Text = "Overseer - Module Inspector"
    title.TextColor3 = self.Config.WHITE
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 3
    local closeBtn = self:_createButton(titleBar, "×", UDim2.fromOffset(18, 18), UDim2.new(1, -20, 0, 3), function()
        main.Visible = false
    end)
    closeBtn.ZIndex = 4
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    local minBtn = self:_createButton(titleBar, "_", UDim2.fromOffset(18, 18), UDim2.new(1, -40, 0, 3), function()
        main.Visible = false
    end)
    minBtn.ZIndex = 4
    minBtn.TextYAlignment = Enum.TextYAlignment.Top
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -8, 1, -32)
    content.Position = UDim2.fromOffset(4, 28)
    content.BackgroundColor3 = self.Config.WINDOW_GRAY
    content.BorderSizePixel = 0
    local toolbar = Instance.new("Frame", content)
    toolbar.Size = UDim2.new(1, 0, 0, 30)
    toolbar.Position = UDim2.fromOffset(0, 0)
    toolbar.BackgroundColor3 = self.Config.WINDOW_GRAY
    toolbar.BorderSizePixel = 0
    self:_createWin95Border(toolbar, false)
    local rescanBtn = self:_createButton(toolbar, "Rescan", UDim2.fromOffset(70, 22), UDim2.fromOffset(4, 4), function()
        self:_rescanModules()
    end)
    local modeBtn = self:_createButton(toolbar, "Explorer", UDim2.fromOffset(70, 22), UDim2.fromOffset(78, 4), function()
    end)
    local patchBtn = self:_createButton(toolbar, "Patches", UDim2.fromOffset(70, 22), UDim2.fromOffset(152, 4), function()
        self:_showPatchManager()
    end)
    local spyBtn = self:_createButton(toolbar, "Spy", UDim2.fromOffset(70, 22), UDim2.fromOffset(226, 4), function()
        self:_showRemoteSpy()
    end)
    local searchBox = Instance.new("TextBox", content)
    searchBox.Size = UDim2.fromOffset(230, 22)
    searchBox.Position = UDim2.fromOffset(10, 40)
    searchBox.BackgroundColor3 = self.Config.WHITE
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search modules..."
    searchBox.TextColor3 = self.Config.BLACK
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.BorderSizePixel = 0
    self:_createWin95Border(searchBox, true)
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:_filterGridBySearch(searchBox.Text)
        end
    end)
    local backBtn = self:_createButton(content, "< Back", UDim2.fromOffset(60, 22), UDim2.fromOffset(250, 40), function()
        self:_goBack()
    end)
    local sidebar = Instance.new("ScrollingFrame", content)
    sidebar.Size = UDim2.new(0, 230, 1, -72)
    sidebar.Position = UDim2.fromOffset(10, 70)
    sidebar.BackgroundColor3 = self.Config.WHITE
    sidebar.BorderSizePixel = 0
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollBarThickness = 16
    sidebar.ScrollBarImageColor3 = self.Config.WINDOW_GRAY
    self:_createWin95Border(sidebar, true)
    local sidebarList = Instance.new("UIListLayout", sidebar)
    sidebarList.Padding = UDim.new(0, 2)
    local grid = Instance.new("ScrollingFrame", content)
    grid.Size = UDim2.new(1, -255, 1, -42)
    grid.Position = UDim2.fromOffset(245, 40)
    grid.BackgroundColor3 = self.Config.WHITE
    grid.BorderSizePixel = 0
    grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
    grid.ScrollBarThickness = 16
    grid.ScrollBarImageColor3 = self.Config.WINDOW_GRAY
    self:_createWin95Border(grid, true)
    local gridList = Instance.new("UIListLayout", grid)
    gridList.SortOrder = Enum.SortOrder.LayoutOrder
    gridList.Padding = UDim.new(0, 2)
    local codeFrame = Instance.new("Frame", content)
    codeFrame.Size = grid.Size
    codeFrame.Position = grid.Position
    codeFrame.BackgroundColor3 = self.Config.WHITE
    codeFrame.Visible = false
    codeFrame.BorderSizePixel = 0
    self:_createWin95Border(codeFrame, true)
    local codeScroller = Instance.new("ScrollingFrame", codeFrame)
    codeScroller.Size = UDim2.new(1, -20, 1, -50)
    codeScroller.Position = UDim2.fromOffset(10, 10)
    codeScroller.BackgroundColor3 = self.Config.WHITE
    codeScroller.BorderSizePixel = 0
    codeScroller.ScrollBarThickness = 16
    codeScroller.AutomaticCanvasSize = Enum.AutomaticSize.XY
    local codeBox = Instance.new("TextBox", codeScroller)
    codeBox.Size = UDim2.new(1, 0, 1, 0)
    codeBox.BackgroundColor3 = self.Config.WHITE
    codeBox.TextColor3 = self.Config.BLACK
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 11
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.ClearTextOnFocus = false
    codeBox.TextEditable = false
    codeBox.MultiLine = true
    codeBox.AutomaticSize = Enum.AutomaticSize.XY
    local copyBtn = self:_createButton(codeFrame, "Copy", UDim2.fromOffset(70, 24), UDim2.new(1, -300, 1, -34), function()
        self:_setClipboard(codeBox.Text)
        copyBtn.Text = "Copied!"
        task.wait(1)
        copyBtn.Text = "Copy"
    end)
    local applyBtn = self:_createButton(codeFrame, "Apply", UDim2.fromOffset(70, 24), UDim2.new(1, -220, 1, -34), function()
        if self:_applyLiveEdit() then
            applyBtn.Text = "Applied!"
            task.wait(1)
            applyBtn.Text = "Apply"
        end
    end)
    local executeBtn = self:_createButton(codeFrame, "Execute", UDim2.fromOffset(70, 24), UDim2.new(1, -140, 1, -34), function()
        local result = self:ExecuteCode(codeBox.Text)
        if result.Success then
            codeBox.Text = "
        else
            codeBox.Text = "
        end
    end)
    local closeCodeBtn = self:_createButton(codeFrame, "Close", UDim2.fromOffset(70, 24), UDim2.new(1, -60, 1, -34), function()
        codeFrame.Visible = false
        grid.Visible = true
        self.State.ViewingCode = false
        self.State.EditMode = nil
        codeBox.TextEditable = false
    end)
    self.State.UI = {
        ScreenGui = screenGui,
        Main = main,
        Title = title,
        Grid = grid,
        Sidebar = sidebar,
        CodeFrame = codeFrame,
        CodeBox = codeBox,
        Search = searchBox,
        EditMode = false,
        EditTarget = nil,
        OriginalCode = ""
    }
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    self:_rescanModules()
end
function Modules.Overseer95:_rescanModules()
    if not self.State.UI or not self.State.UI.Sidebar then return end
    for _, child in ipairs(self.State.UI.Sidebar:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    self.State.SidebarButtons = {}
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
function Modules.Overseer95:AddModuleToList(scriptInstance)
    if not scriptInstance or not scriptInstance.Parent then return end
    if not self.State.UI or not self.State.UI.Sidebar then return end
    local name = scriptInstance.Name
    local moduleType = scriptInstance.ClassName
    local btn = Instance.new("TextButton", self.State.UI.Sidebar)
    btn.Size = UDim2.new(1, -6, 0, self.Config.ROW_HEIGHT)
    btn.BackgroundColor3 = self.Config.BUTTON_FACE
    btn.Text = name
    btn.TextColor3 = self.Config.BLACK
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.LayoutOrder = #self.State.UI.Sidebar:GetChildren()
    self:_createWin95Border(btn, false)
    local function loadModule()
        self.State.SelectedModule = scriptInstance
        self.State.CurrentTable = nil
        self.State.PathStack = {}
        self.State.VisitedTables = {}
        self:_updateGrid()
    end
    btn.MouseButton1Click:Connect(loadModule)
    table.insert(self.State.SidebarButtons, {Button = btn, Script = scriptInstance})
end
function Modules.Overseer95:_updateGrid()
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    if not self.State.SelectedModule then
        self:_showErrorInGrid("No module selected")
        return
    end
    local script = self.State.SelectedModule
    if script:IsA("ModuleScript") then
        local success, result = pcall(function()
            return require(script)
        end)
        if not success then
            self:_showErrorInGrid("Failed to load module: " .. tostring(result))
            return
        end
        if type(result) ~= "table" then
            self:_showErrorInGrid("Module did not return a table")
            return
        end
        self.State.CurrentTable = result
        self.State.VisitedTables = {}
        self:_populateGridFromTable(result)
    elseif script:IsA("LocalScript") or script:IsA("Script") then
        local source = script.Source
        if source and #source > 0 then
            self:_showScriptSource(script.Name, source)
        else
            self:_showErrorInGrid("Script has no source code")
        end
    else
        self:_showErrorInGrid("Script type: " .. script.ClassName .. " (not supported)")
    end
end
function Modules.Overseer95:_populateGridFromTable(tbl, prefix)
    prefix = prefix or ""
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    if self.State.VisitedTables[tbl] then
        local cycleRow = Instance.new("TextLabel", ui.Grid)
        cycleRow.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
        cycleRow.BackgroundColor3 = self.Config.LIGHT_GRAY
        cycleRow.Text = "[CYCLIC REFERENCE DETECTED]"
        cycleRow.TextColor3 = self.Config.ACCENT_TEAL
        cycleRow.Font = Enum.Font.Code
        cycleRow.TextSize = 10
        cycleRow.BorderSizePixel = 0
        self:_createWin95Border(cycleRow, true)
        return
    end
    self.State.VisitedTables[tbl] = true
    for key, value in pairs(tbl) do
        self:_createGridRow(key, value, prefix)
    end
    local mt = getmetatable(tbl)
    if mt then
        local mtPrefix = prefix .. "[METATABLE]."
        local mtRow = Instance.new("TextButton", ui.Grid)
        mtRow.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
        mtRow.BackgroundColor3 = self.Config.LIGHT_GRAY
        mtRow.Text = ""
        mtRow.BorderSizePixel = 0
        self:_createWin95Border(mtRow, false)
        local mtLabel = Instance.new("TextLabel", mtRow)
        mtLabel.Size = UDim2.new(0, 150, 1, 0)
        mtLabel.Position = UDim2.fromOffset(5, 0)
        mtLabel.BackgroundTransparency = 1
        mtLabel.Text = "[METATABLE]"
        mtLabel.TextColor3 = self.Config.TITLE_BLUE
        mtLabel.Font = Enum.Font.Code
        mtLabel.TextSize = 10
        mtLabel.TextXAlignment = Enum.TextXAlignment.Left
        local mtTypeLabel = Instance.new("TextLabel", mtRow)
        mtTypeLabel.Size = UDim2.new(0, 100, 1, 0)
        mtTypeLabel.Position = UDim2.fromOffset(160, 0)
        mtTypeLabel.BackgroundTransparency = 1
        mtTypeLabel.Text = "table"
        mtTypeLabel.TextColor3 = self.Config.TITLE_BLUE
        mtTypeLabel.Font = Enum.Font.SourceSans
        mtTypeLabel.TextSize = 10
        mtTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
        local mtBtn = self:_createButton(mtRow, "Dive", UDim2.fromOffset(40, 20), UDim2.new(1, -50, 0, 5), function()
            self:_drillDownTable(mt, "[METATABLE]")
        end)
        local count = 0
        for mtKey, mtValue in pairs(mt) do
            if count < 20 then
                self:_createGridRow(mtKey, mtValue, mtPrefix, true)
                count = count + 1
            else
                local moreLabel = Instance.new("TextLabel", ui.Grid)
                moreLabel.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
                moreLabel.BackgroundColor3 = self.Config.LIGHT_GRAY
                moreLabel.Text = "... (more items hidden)"
                moreLabel.TextColor3 = self.Config.BLACK
                moreLabel.Font = Enum.Font.SourceSans
                moreLabel.TextSize = 10
                moreLabel.BorderSizePixel = 0
                break
            end
        end
        local ghostPrefix = prefix .. "[GHOST_INDEX]."
        local indexChain = {}
        local currentMeta = mt
        local depth = 0
        while currentMeta and depth < 10 do
            local indexValue = rawget(currentMeta, "__index")
            if indexValue then
                if type(indexValue) == "table" then
                    table.insert(indexChain, {Type = "table", Value = indexValue, Meta = currentMeta, Depth = depth})
                    currentMeta = getmetatable(indexValue)
                    depth = depth + 1
                elseif type(indexValue) == "function" then
                    table.insert(indexChain, {Type = "function", Value = indexValue, Meta = currentMeta, Depth = depth})
                    break
                else
                    break
                end
            else
                break
            end
        end
        if #indexChain > 0 then
            local ghostHeaderRow = Instance.new("TextButton", ui.Grid)
            ghostHeaderRow.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
            ghostHeaderRow.BackgroundColor3 = self.Config.DARK_GRAY
            ghostHeaderRow.Text = ""
            ghostHeaderRow.BorderSizePixel = 0
            self:_createWin95Border(ghostHeaderRow, false)
            local ghostHeaderLabel = Instance.new("TextLabel", ghostHeaderRow)
            ghostHeaderLabel.Size = UDim2.new(0, 200, 1, 0)
            ghostHeaderLabel.Position = UDim2.fromOffset(5, 0)
            ghostHeaderLabel.BackgroundTransparency = 1
            ghostHeaderLabel.Text = "=== GHOST INDEX CHAIN ==="
            ghostHeaderLabel.TextColor3 = self.Config.WHITE
            ghostHeaderLabel.Font = Enum.Font.Code
            ghostHeaderLabel.TextSize = 9
            ghostHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            for i, chainItem in ipairs(indexChain) do
                local chainPrefix = ghostPrefix .. "Level_" .. i .. "."
                local chainTypeStr = chainItem.Type == "table" and "table" or "function"
                local chainRow = Instance.new("TextButton", ui.Grid)
                chainRow.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
                chainRow.BackgroundColor3 = self.Config.DARK_GRAY
                chainRow.Text = ""
                chainRow.BorderSizePixel = 0
                self:_createWin95Border(chainRow, false)
                local chainLabel = Instance.new("TextLabel", chainRow)
                chainLabel.Size = UDim2.new(0, 150, 1, 0)
                chainLabel.Position = UDim2.fromOffset(5, 0)
                chainLabel.BackgroundTransparency = 1
                chainLabel.Text = "[__INDEX #" .. i .. "]"
                chainLabel.TextColor3 = self.Config.WHITE
                chainLabel.Font = Enum.Font.Code
                chainLabel.TextSize = 10
                chainLabel.TextXAlignment = Enum.TextXAlignment.Left
                local chainTypeLabel = Instance.new("TextLabel", chainRow)
                chainTypeLabel.Size = UDim2.new(0, 100, 1, 0)
                chainTypeLabel.Position = UDim2.fromOffset(160, 0)
                chainTypeLabel.BackgroundTransparency = 1
                chainTypeLabel.Text = chainTypeStr
                chainTypeLabel.TextColor3 = self.Config.WHITE
                chainTypeLabel.Font = Enum.Font.SourceSans
                chainTypeLabel.TextSize = 10
                chainTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
                if chainItem.Type == "table" then
                    local chainBtn = self:_createButton(chainRow, "Dive", UDim2.fromOffset(40, 20), UDim2.new(1, -50, 0, 5), function()
                        self:_drillDownTable(chainItem.Value, "[__INDEX #" .. i .. "]")
                    end)
                else
                    local funcBtn = self:_createButton(chainRow, "View", UDim2.fromOffset(40, 20), UDim2.new(1, -50, 0, 5), function()
                        self:_showFunctionCode("__index #" .. i, chainItem.Value)
                    end)
                end
                if chainItem.Type == "table" then
                    local chainCount = 0
                    for chainKey, chainValue in pairs(chainItem.Value) do
                        if chainCount < 10 then
                            self:_createGridRow(chainKey, chainValue, chainPrefix, true)
                            chainCount = chainCount + 1
                        else
                            break
                        end
                    end
                end
            end
        end
    end
end
function Modules.Overseer95:_createGridRow(key, value, prefix, isMetatable)
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    local displayName = prefix .. tostring(key)
    local valueType = type(value)
    if value == nil then return end
    local row = Instance.new("TextButton", ui.Grid)
    row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
    if isMetatable then
        row.BackgroundColor3 = self.Config.LIGHT_GRAY
    else
        row.BackgroundColor3 = self.Config.WHITE
    end
    row.Text = ""
    row.BorderSizePixel = 0
    self:_createWin95Border(row, true)
    local keyLabel = Instance.new("TextLabel", row)
    keyLabel.Size = UDim2.new(0, 120, 1, 0)
    keyLabel.Position = UDim2.fromOffset(5, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = displayName
    keyLabel.TextColor3 = self.Config.BLACK
    keyLabel.Font = isMetatable and Enum.Font.Code or Enum.Font.SourceSans
    keyLabel.TextSize = 10
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
    local valueLabel = Instance.new("TextLabel", row)
    valueLabel.Size = UDim2.new(0, 80, 1, 0)
    valueLabel.Position = UDim2.fromOffset(130, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = valueType
    valueLabel.TextColor3 = self.Config.TITLE_BLUE
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    local viewBtn = self:_createButton(row, "View", UDim2.fromOffset(40, 20), UDim2.new(1, -145, 0, 5), function()
        if valueType == "function" then
            self:_showFunctionCode(key, value)
        elseif valueType == "table" then
            self:_drillDownTable(value, displayName)
        else
            self:_showValueEditor(displayName, value)
        end
    end)
    if valueType ~= "function" then
        local editBtn = self:_createButton(row, "Edit", UDim2.fromOffset(40, 20), UDim2.new(1, -100, 0, 5), function()
            self:_openValueEditor(key, value)
        end)
    else
        local replaceBtn = self:_createButton(row, "Hook", UDim2.fromOffset(40, 20), UDim2.new(1, -100, 0, 5), function()
            self:_openFunctionHooker(key, value)
        end)
    end
    local patchBtn = self:_createButton(row, "Patch", UDim2.fromOffset(45, 20), UDim2.new(1, -50, 0, 5), function()
        self.State.EditingValue = value
        self.State.EditingTable = self.State.CurrentTable
        self.State.EditingKey = key
        self:_showPatchEditor(key, value)
    end)
    row.MouseButton1Click:Connect(function()
        row.BackgroundColor3 = self.Config.LIGHT_GRAY
    end)
end
function Modules.Overseer95:_showScriptSource(scriptName, source)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    ui.CodeBox.Text = source
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
    self.State.ViewingScriptSource = true
    self.State.CurrentScriptName = scriptName
end
function Modules.Overseer95:_drillDownTable(tbl, name)
    if not self.State.PathStack then
        self.State.PathStack = {}
    end
    table.insert(self.State.PathStack, {
        Table = self.State.CurrentTable,
        Name = self.State.SelectedModule and self.State.SelectedModule.Name or "Root"
    })
    self.State.CurrentTable = tbl
    self.State.VisitedTables = {}
    local ui = self.State.UI
    if ui and ui.Search then ui.Search.Text = name end
    self:_updateGrid()
end
function Modules.Overseer95:_goBack()
    if not self.State.PathStack or #self.State.PathStack == 0 then return end
    local previous = table.remove(self.State.PathStack)
    self.State.CurrentTable = previous.Table
    self.State.VisitedTables = {}
    local ui = self.State.UI
    if ui and ui.Search then ui.Search.Text = previous.Name end
    self:_updateGrid()
end
function Modules.Overseer95:_filterGridBySearch(query)
    if not query or query == "" then
        self:_updateGrid()
        return
    end
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    local tbl = self.State.CurrentTable
    if not tbl then
        self:_showErrorInGrid("No table selected")
        return
    end
    local results = {}
    local queryLower = query:lower()
    for key, value in pairs(tbl) do
        local keyStr = tostring(key):lower()
        local valueStr = tostring(value):lower()
        if string.find(keyStr, queryLower, 1, true) or string.find(valueStr, queryLower, 1, true) then
            table.insert(results, {key = key, value = value})
        end
    end
    if #results == 0 then
        local noResultsLabel = Instance.new("TextLabel", ui.Grid)
        noResultsLabel.Size = UDim2.new(1, -10, 0, 30)
        noResultsLabel.BackgroundColor3 = self.Config.WHITE
        noResultsLabel.Text = "No results for: " .. query
        noResultsLabel.TextColor3 = self.Config.BLACK
        noResultsLabel.Font = Enum.Font.SourceSans
        noResultsLabel.TextSize = 11
        noResultsLabel.BorderSizePixel = 0
        return
    end
    for _, result in ipairs(results) do
        self:_createGridRow(result.key, result.value, "")
    end
end
function Modules.Overseer95:_showFunctionCode(name, func)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    local success, decompiled = pcall(function()
        if getinfo then
            local info = getinfo(func)
            return "Function: " .. tostring(name) .. "\n\nInfo:\n" .. tostring(info)
        end
        return "Function source not available"
    end)
    if not success then
        ui.CodeBox.Text = "Error: " .. tostring(decompiled)
    else
        ui.CodeBox.Text = decompiled
    end
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
end
function Modules.Overseer95:_showValueEditor(key, value)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    ui.CodeBox.Text = "Value: " .. tostring(key) .. "\nType: " .. type(value) .. "\nValue: " .. tostring(value)
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
end
function Modules.Overseer95:_openValueEditor(key, value)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    self.State.EditingKey = key
    self.State.EditingValue = value
    self.State.EditingTable = self.State.CurrentTable
    ui.CodeBox.Text = tostring(value)
    ui.CodeBox.TextEditable = true
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
    self.State.EditMode = "value"
end
function Modules.Overseer95:_openFunctionHooker(key, func)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    self.State.EditingKey = key
    self.State.EditingValue = func
    self.State.EditingTable = self.State.CurrentTable
    ui.CodeBox.Text = "
    ui.CodeBox.TextEditable = true
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
    self.State.EditMode = "function_hook"
end
function Modules.Overseer95:_showPatchEditor(key, currentValue)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    local valueType = type(currentValue)
    local templateCode = ""
    if valueType == "string" then
        templateCode = 'return "' .. tostring(currentValue):gsub('"', '\\"') .. '"'
    elseif valueType == "number" then
        templateCode = "return " .. tostring(currentValue)
    elseif valueType == "boolean" then
        templateCode = "return " .. tostring(currentValue)
    else
        templateCode = "
    end
    ui.CodeBox.Text = templateCode
    ui.CodeBox.TextEditable = true
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
    self.State.EditMode = "patch_value"
end
function Modules.Overseer95:_applyLiveEdit()
    local ui = self.State.UI
    if not ui or not ui.CodeBox or not self.State.EditMode then return false end
    local code = ui.CodeBox.Text
    local key = self.State.EditingKey
    local table_ = self.State.EditingTable
    if not table_ or not key then return false end
    if self.State.EditMode == "patch_value" then
        local success, newValue = pcall(function()
            local func = loadstring(code)
            if func then
                return func()
            end
        end)
        if success then
            self:LivePatchValue(table_, key, newValue)
            self:_updateGrid()
            return true
        else
            self:_showErrorInGrid("Error: " .. tostring(newValue))
        end
    elseif self.State.EditMode == "function_hook" then
        local success, hookFunc = pcall(function()
            local func = loadstring(code)
            if func then
                return func()
            end
        end)
        if success and type(hookFunc) == "function" then
            local result = self:HookFunction(table_, key, "", "")
            if result.Success then
                self:_updateGrid()
                return true
            end
        else
            self:_showErrorInGrid("Error: Hook must return a function")
        end
    elseif self.State.EditMode == "value" then
        local success, newValue = pcall(function()
            local func = loadstring("return " .. code)
            if func then
                return func()
            end
        end)
        if success then
            self:LivePatchValue(table_, key, newValue)
            self:_updateGrid()
            return true
        else
            self:_showErrorInGrid("Error: " .. tostring(newValue))
        end
    end
    return false
end
function Modules.Overseer95:_showPatchManager()
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    if not next(self.State.ActivePatches) then
        local emptyLabel = Instance.new("TextLabel", ui.Grid)
        emptyLabel.Size = UDim2.new(1, -10, 0, 30)
        emptyLabel.BackgroundColor3 = self.Config.WHITE
        emptyLabel.Text = "No active patches"
        emptyLabel.TextColor3 = self.Config.BLACK
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 11
        emptyLabel.BorderSizePixel = 0
        return
    end
    for tbl, patches in pairs(self.State.ActivePatches) do
        for key, data in pairs(patches) do
            local row = Instance.new("Frame", ui.Grid)
            row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
            row.BackgroundColor3 = self.Config.WHITE
            row.BorderSizePixel = 0
            self:_createWin95Border(row, true)
            local keyLabel = Instance.new("TextLabel", row)
            keyLabel.Size = UDim2.new(0, 150, 1, 0)
            keyLabel.Position = UDim2.fromOffset(5, 0)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Text = tostring(key)
            keyLabel.TextColor3 = self.Config.BLACK
            keyLabel.Font = Enum.Font.SourceSans
            keyLabel.TextSize = 10
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            local valueLabel = Instance.new("TextLabel", row)
            valueLabel.Size = UDim2.new(0, 150, 1, 0)
            valueLabel.Position = UDim2.fromOffset(160, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(data.Value)
            valueLabel.TextColor3 = self.Config.TITLE_BLUE
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 10
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            local toggleBtn = self:_createButton(row, data.Locked and "Unlock" or "Lock", UDim2.fromOffset(60, 20), UDim2.new(1, -70, 0, 5), function()
                data.Locked = not data.Locked
                self:_showPatchManager()
            end)
        end
    end
end
function Modules.Overseer95:_showRemoteSpy()
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    if not next(self.State.RemoteSpyData) then
        local emptyLabel = Instance.new("TextLabel", ui.Grid)
        emptyLabel.Size = UDim2.new(1, -10, 0, 30)
        emptyLabel.BackgroundColor3 = self.Config.WHITE
        emptyLabel.Text = "No remote calls detected"
        emptyLabel.TextColor3 = self.Config.BLACK
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 11
        emptyLabel.BorderSizePixel = 0
        return
    end
    for remoteName, callData in pairs(self.State.RemoteSpyData) do
        local row = Instance.new("TextButton", ui.Grid)
        row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
        row.BackgroundColor3 = self.Config.BUTTON_FACE
        row.Text = ""
        row.BorderSizePixel = 0
        self:_createWin95Border(row, false)
        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(0, 200, 1, 0)
        nameLabel.Position = UDim2.fromOffset(5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = remoteName
        nameLabel.TextColor3 = self.Config.BLACK
        nameLabel.Font = Enum.Font.SourceSans
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        local countLabel = Instance.new("TextLabel", row)
        countLabel.Size = UDim2.new(0, 80, 1, 0)
        countLabel.Position = UDim2.fromOffset(210, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = "Calls: " .. tostring(callData.Count or 0)
        countLabel.TextColor3 = self.Config.TITLE_BLUE
        countLabel.Font = Enum.Font.SourceSans
        countLabel.TextSize = 10
        local logsBtn = self:_createButton(row, "Logs", UDim2.fromOffset(50, 20), UDim2.new(1, -60, 0, 5), function()
            self:_showRemoteCallLogs(remoteName, callData.Calls)
        end)
    end
end
function Modules.Overseer95:_showRemoteCallLogs(remoteName, calls)
    local ui = self.State.UI
    if not ui or not ui.Grid then return end
    for _, v in ipairs(ui.Grid:GetChildren()) do
        if not v:IsA("UIListLayout") then v:Destroy() end
    end
    if not calls or #calls == 0 then
        local emptyLabel = Instance.new("TextLabel", ui.Grid)
        emptyLabel.Size = UDim2.new(1, -10, 0, 30)
        emptyLabel.BackgroundColor3 = self.Config.WHITE
        emptyLabel.Text = "No calls logged for " .. remoteName
        emptyLabel.TextColor3 = self.Config.BLACK
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 11
        emptyLabel.BorderSizePixel = 0
        return
    end
    local startIdx = math.max(1, #calls - 49)
    for i = startIdx, #calls do
        local callData = calls[i]
        local callHeaderRow = Instance.new("TextButton", ui.Grid)
        callHeaderRow.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
        callHeaderRow.BackgroundColor3 = self.Config.DARK_GRAY
        callHeaderRow.Text = ""
        callHeaderRow.BorderSizePixel = 0
        self:_createWin95Border(callHeaderRow, false)
        local callNumberLabel = Instance.new("TextLabel", callHeaderRow)
        callNumberLabel.Size = UDim2.new(0, 80, 1, 0)
        callNumberLabel.Position = UDim2.fromOffset(5, 0)
        callNumberLabel.BackgroundTransparency = 1
        callNumberLabel.Text = "Call #" .. i
        callNumberLabel.TextColor3 = self.Config.WHITE
        callNumberLabel.Font = Enum.Font.Code
        callNumberLabel.TextSize = 10
        callNumberLabel.TextXAlignment = Enum.TextXAlignment.Left
        local timeLabel = Instance.new("TextLabel", callHeaderRow)
        timeLabel.Size = UDim2.new(0, 150, 1, 0)
        timeLabel.Position = UDim2.fromOffset(90, 0)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Text = os.date("%H:%M:%S", callData.Timestamp)
        timeLabel.TextColor3 = self.Config.WHITE
        timeLabel.Font = Enum.Font.SourceSans
        timeLabel.TextSize = 9
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left
        local traceBtn = self:_createButton(callHeaderRow, "Trace", UDim2.fromOffset(50, 20), UDim2.new(1, -60, 0, 5), function()
            self:_showCallStackTrace(remoteName, i, callData)
        end)
        for argIdx, decodedArg in ipairs(callData.DecodedArgs or callData.Args) do
            local row = Instance.new("Frame", ui.Grid)
            row.Size = UDim2.new(1, -10, 0, self.Config.ROW_HEIGHT)
            row.BackgroundColor3 = self.Config.WHITE
            row.BorderSizePixel = 0
            self:_createWin95Border(row, true)
            local indexLabel = Instance.new("TextLabel", row)
            indexLabel.Size = UDim2.new(0, 50, 1, 0)
            indexLabel.Position = UDim2.fromOffset(5, 0)
            indexLabel.BackgroundTransparency = 1
            indexLabel.Text = "[" .. argIdx .. "]"
            indexLabel.TextColor3 = self.Config.BLACK
            indexLabel.Font = Enum.Font.Code
            indexLabel.TextSize = 9
            indexLabel.TextXAlignment = Enum.TextXAlignment.Left
            local typeLabel = Instance.new("TextLabel", row)
            typeLabel.Size = UDim2.new(0, 100, 1, 0)
            typeLabel.Position = UDim2.fromOffset(60, 0)
            typeLabel.BackgroundTransparency = 1
            if type(decodedArg) == "table" and decodedArg.Type then
                typeLabel.Text = decodedArg.Type
                typeLabel.TextColor3 = self.Config.TITLE_BLUE
            else
                typeLabel.Text = type(decodedArg)
                typeLabel.TextColor3 = self.Config.BLACK
            end
            typeLabel.Font = Enum.Font.SourceSans
            typeLabel.TextSize = 10
            typeLabel.TextXAlignment = Enum.TextXAlignment.Left
            local valueLabel = Instance.new("TextLabel", row)
            valueLabel.Size = UDim2.new(0, 200, 1, 0)
            valueLabel.Position = UDim2.fromOffset(165, 0)
            valueLabel.BackgroundTransparency = 1
            if type(decodedArg) == "table" and decodedArg.Decoded then
                valueLabel.Text = string.sub(tostring(decodedArg.Decoded), 1, 50)
            else
                valueLabel.Text = string.sub(tostring(decodedArg), 1, 50)
            end
            valueLabel.TextColor3 = self.Config.BLACK
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 9
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            local viewBtn = self:_createButton(row, "View", UDim2.fromOffset(50, 20), UDim2.new(1, -60, 0, 5), function()
                self:_showDecodedPacket(remoteName, argIdx, decodedArg)
            end)
        end
    end
end
function Modules.Overseer95:_showDecodedPacket(remoteName, argIdx, decodedArg)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    local displayText = ""
    if type(decodedArg) == "table" then
        if decodedArg.Type then
            displayText = "=== " .. remoteName .. " [Arg " .. argIdx .. "] ===\n"
            displayText = displayText .. "Type: " .. decodedArg.Type .. "\n"
            if decodedArg.Raw then
                displayText = displayText .. "\nRaw:\n" .. tostring(decodedArg.Raw) .. "\n"
            end
            if decodedArg.Decoded then
                displayText = displayText .. "\nDecoded:\n" .. tostring(decodedArg.Decoded)
            end
        else
            displayText = tostring(decodedArg)
        end
    else
        displayText = tostring(decodedArg)
    end
    ui.CodeBox.Text = displayText
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
end
function Modules.Overseer95:_showCallStackTrace(remoteName, callIndex, callData)
    local ui = self.State.UI
    if not ui or not ui.CodeBox then return end
    local displayText = "=== " .. remoteName .. " - Call #" .. callIndex .. " ===\n"
    displayText = displayText .. "Time: " .. os.date("%H:%M:%S", callData.Timestamp) .. "\n"
    displayText = displayText .. "\n
    displayText = displayText .. (callData.StackTrace or "No traceback available")
    ui.CodeBox.Text = displayText
    ui.CodeFrame.Visible = true
    ui.Grid.Visible = false
    self.State.ViewingCode = true
end
function Modules.Overseer95:PatchValue(tbl, key, value, isFunction, lock)
    if not tbl or not key then return false end
    if not self.State.ActivePatches[tbl] then
        self.State.ActivePatches[tbl] = {}
    end
    self.State.ActivePatches[tbl][key] = {
        Value = value,
        IsFunction = isFunction or false,
        Locked = lock or false,
        Original = rawget(tbl, key),
        Patches = {},
        History = {}
    }
    if lock then
        pcall(function()
            if setreadonly then
                setreadonly(tbl, false)
            elseif make_writeable then
                make_writeable(tbl)
            end
            rawset(tbl, key, value)
            if setreadonly then
                setreadonly(tbl, true)
            end
        end)
    end
    return true
end
function Modules.Overseer95:UnpatchValue(tbl, key)
    if not tbl or not key then return false end
    if self.State.ActivePatches[tbl] and self.State.ActivePatches[tbl][key] then
        local original = self.State.ActivePatches[tbl][key].Original
        pcall(function()
            if setreadonly then
                setreadonly(tbl, false)
            elseif make_writeable then
                make_writeable(tbl)
            end
            rawset(tbl, key, original)
            if setreadonly then
                setreadonly(tbl, true)
            end
        end)
        self.State.ActivePatches[tbl][key] = nil
    end
    return true
end
function Modules.Overseer95:HookValue(tbl, key, callback)
    if not tbl or not key or not callback then return nil end
    local hookKey = self:_generateObfuscatedName()
    self.State.ValueHooks[hookKey] = {
        table = tbl,
        key = key,
        callback = callback,
        enabled = true,
        value = rawget(tbl, key)
    }
    return hookKey
end
function Modules.Overseer95:UnhookValue(hookKey)
    if self.State.ValueHooks[hookKey] then
        self.State.ValueHooks[hookKey] = nil
        return true
    end
    return false
end
function Modules.Overseer95:SpyRemote(remote)
    if not remote then return false end
    local remoteName = remote.Name or "Unknown"
    if not self.State.RemoteSpyData[remoteName] then
        self.State.RemoteSpyData[remoteName] = {Count = 0, Calls = {}, DecodedCalls = {}}
    end
    local oldFireServer = remote.FireServer
    local module = self
    remote.FireServer = function(self, ...)
        module.State.RemoteSpyData[remoteName].Count = (module.State.RemoteSpyData[remoteName].Count or 0) + 1
        local args = {...}
        local decodedArgs = {}
        local stackTrace = ""
        pcall(function()
            stackTrace = debug.traceback("", 2) or "No traceback available"
        end)
        if module.Config and module.RemoteSpy.DecodingEnabled then
            for _, arg in ipairs(args) do
                table.insert(decodedArgs, module:_forensicDecodeArg(arg))
            end
        else
            decodedArgs = args
        end
        table.insert(module.State.RemoteSpyData[remoteName].Calls, {
            Args = args,
            DecodedArgs = decodedArgs,
            Timestamp = tick(),
            StackTrace = stackTrace
        })
        return oldFireServer(self, ...)
    end
    return true
end
function Modules.Overseer95:SetupGlobalRemoteSpy()
    local module = self
    local function hookRemotes(parent)
        if not parent then return end
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                module:SpyRemote(obj)
            end
        end
        parent.DescendantAdded:Connect(function(obj)
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                module:SpyRemote(obj)
            end
        end)
    end
    hookRemotes(ReplicatedStorage)
end
function Modules.Overseer95:LivePatchValue(tbl, key, newValue)
    if not tbl or not key then return false end
    local success = pcall(function()
        if setreadonly then
            setreadonly(tbl, false)
        elseif make_writeable then
            make_writeable(tbl)
        end
        local oldValue = rawget(tbl, key)
        if not self.State.ActivePatches[tbl] then
            self.State.ActivePatches[tbl] = {}
        end
        if not self.State.ActivePatches[tbl][key] then
            self.State.ActivePatches[tbl][key] = {
                Original = oldValue,
                Patches = {},
                History = {}
            }
        end
        rawset(tbl, key, newValue)
        table.insert(self.State.ActivePatches[tbl][key].Patches, newValue)
        table.insert(self.State.ActivePatches[tbl][key].History, {
            Action = "PATCHED",
            OldValue = oldValue,
            NewValue = newValue,
            Timestamp = tick()
        })
        if setreadonly then
            setreadonly(tbl, true)
        end
    end)
    return success
end
function Modules.Overseer95:ExecuteCode(code, env)
    local sandbox = env or _G
    local success, result = pcall(function()
        local func = loadstring(code)
        if func then
            if setfenv then
                setfenv(func, sandbox)
            end
            return func()
        end
    end)
    if not success then
        return {Success = false, Error = tostring(result)}
    end
    return {Success = true, Result = result}
end
function Modules.Overseer95:InjectFunction(tbl, key, codeString)
    if not tbl or not key then return {Success = false, Error = "Invalid table or key"} end
    local success, newFunc = pcall(function()
        local func = loadstring("return " .. codeString)
        if func then
            return func()
        end
    end)
    if not success then
        return {Success = false, Error = tostring(newFunc)}
    end
    if type(newFunc) ~= "function" then
        return {Success = false, Error = "Code did not return a function"}
    end
    return self:LivePatchValue(tbl, key, newFunc) and {Success = true} or {Success = false, Error = "Failed to patch"}
end
function Modules.Overseer95:HookFunction(tbl, key, beforeCode, afterCode)
    if not tbl or not key then return {Success = false, Error = "Invalid table or key"} end
    local originalFunc = rawget(tbl, key)
    if type(originalFunc) ~= "function" then
        return {Success = false, Error = "Not a function"}
    end
    local hookId = self:_generateObfuscatedName()
    local hookedFunc = function(...)
        local args = {...}
        if beforeCode and beforeCode ~= "" then
            pcall(function()
                local beforeFunc = loadstring("return function(args) " .. beforeCode .. " end")()
                if beforeFunc then
                    beforeFunc(args)
                end
            end)
        end
        local results = {originalFunc(...)}
        if afterCode and afterCode ~= "" then
            pcall(function()
                local afterFunc = loadstring("return function(results) " .. afterCode .. " end")()
                if afterFunc then
                    afterFunc(results)
                end
            end)
        end
        return unpack(results)
    end
    if self:LivePatchValue(tbl, key, hookedFunc) then
        self.State.FunctionReplaceMap[hookId] = {
            Table = tbl,
            Key = key,
            Original = originalFunc,
            Hook = hookedFunc
        }
        return {Success = true, HookId = hookId}
    end
    return {Success = false, Error = "Failed to apply hook"}
end
function Modules.Overseer95:ReplaceFunction(tbl, key, newCode)
    if not tbl or not key then return {Success = false, Error = "Invalid table or key"} end
    local originalFunc = rawget(tbl, key)
    if type(originalFunc) ~= "function" then
        return {Success = false, Error = "Not a function"}
    end
    local success, newFunc = pcall(function()
        local func = loadstring(newCode)
        if func then
            return func()
        end
    end)
    if not success then
        return {Success = false, Error = tostring(newFunc)}
    end
    if type(newFunc) ~= "function" then
        return {Success = false, Error = "Code did not return a function"}
    end
    if self:LivePatchValue(tbl, key, newFunc) then
        return {Success = true, Original = originalFunc, Replaced = newFunc}
    end
    return {Success = false, Error = "Failed to replace"}
end
function Modules.Overseer95:UndoPatch(tbl, key)
    if not self.State.ActivePatches[tbl] or not self.State.ActivePatches[tbl][key] then
        return {Success = false, Error = "No patch found"}
    end
    local patchData = self.State.ActivePatches[tbl][key]
    local original = patchData.Original
    if self:LivePatchValue(tbl, key, original) then
        return {Success = true, Restored = original}
    end
    return {Success = false, Error = "Failed to undo"}
end
function Modules.Overseer95:GetPatchStatus(tbl, key)
    if not self.State.ActivePatches[tbl] or not self.State.ActivePatches[tbl][key] then
        return nil
    end
    local patch = self.State.ActivePatches[tbl][key]
    return {
        Original = patch.Original,
        Current = rawget(tbl, key),
        PatchCount = #patch.Patches,
        History = patch.History,
        IsPatched = rawget(tbl, key) ~= patch.Original
    }
end
function Modules.Overseer95:BulkPatchTable(tbl, patches)
    if not tbl or not patches then return {} end
    local results = {}
    for key, value in pairs(patches) do
        local result = self:LivePatchValue(tbl, key, value)
        table.insert(results, {Key = key, Success = result})
    end
    return results
end
function Modules.Overseer95:InterceptRemote(remote, callback)
    if not remote or (not remote:IsA("RemoteFunction") and not remote:IsA("RemoteEvent")) then
        return {Success = false, Error = "Not a remote"}
    end
    local interceptId = self:_generateObfuscatedName()
    local oldFireServer = remote.FireServer
    remote.FireServer = function(self, ...)
        local args = {...}
        local shouldContinue = true
        local modifiedArgs = args
        if callback then
            local callbackResult = callback(args)
            if callbackResult then
                shouldContinue = callbackResult.Continue ~= false
                modifiedArgs = callbackResult.ModifiedArgs or args
            end
        end
        if shouldContinue then
            return oldFireServer(self, unpack(modifiedArgs))
        end
    end
    self.State.InstanceHooks[interceptId] = {
        Instance = remote,
        Type = "RemoteInterceptor",
        Original = oldFireServer
    }
    return {Success = true, InterceptId = interceptId}
end
function Modules.Overseer95:SavePatchProfile(profileName)
    if not profileName then return false end
    local profile = {}
    for tbl, patches in pairs(self.State.ActivePatches) do
        for key, data in pairs(patches) do
            table.insert(profile, {
                TableIdentifier = tostring(tbl),
                Key = key,
                Original = data.Original,
                Current = rawget(tbl, key)
            })
        end
    end
    self.State.SavedProfiles[profileName] = {
        Profile = profile,
        SaveTime = os.date("%Y-%m-%d %H:%M:%S"),
        Timestamp = tick()
    }
    return true
end
function Modules.Overseer95:ApplyPatchProfile(profileName)
    if not self.State.SavedProfiles[profileName] then
        return {Success = false, Error = "Profile not found"}
    end
    local profile = self.State.SavedProfiles[profileName].Profile
    local appliedCount = 0
    for _, patchData in ipairs(profile) do
        appliedCount = appliedCount + 1
    end
    return {Success = true, Applied = appliedCount}
end
function Modules.Overseer95:ListActivePatches()
    local patches = {}
    for tbl, data in pairs(self.State.ActivePatches) do
        for key, patchData in pairs(data) do
            table.insert(patches, {
                Key = key,
                Original = patchData.Original,
                Current = rawget(tbl, key),
                IsActive = rawget(tbl, key) ~= patchData.Original,
                PatchCount = #patchData.Patches
            })
        end
    end
    return patches
end
function Modules.Overseer95:Initialize()
    local module = self
    RunService.Heartbeat:Connect(function()
        for tbl, keys in pairs(module.State.ActivePatches) do
            for key, data in pairs(keys) do
                if data.Locked then
                    pcall(function()
                        if setreadonly then
                            setreadonly(tbl, false)
                        elseif make_writeable then
                            make_writeable(tbl)
                        end
                        if data.IsFunction then
                            if data.Value == "TRUE" then
                                rawset(tbl, key, function() return true end)
                            elseif data.Value == "FALSE" then
                                rawset(tbl, key, function() return false end)
                            end
                        else
                            rawset(tbl, key, data.Value)
                        end
                        if setreadonly then
                            setreadonly(tbl, true)
                        end
                    end)
                end
            end
        end
    end)
    print("[Overseer95] Initializing Windows 95 Edition...")
    self:CreateUI()
    print("[Overseer95] UI Created! Ready to fuck up some modules.")
end
Modules.Overseer95:Initialize()
return Modules.Overseer95
