local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local GUICreator = {
    State = {
        IsEnabled       = false,
        UI              = nil,
        Connections     = {},
        CreatedGUIs     = {},
        SelectedElement = nil,
        PropertyPanel   = nil,
        HierarchyPanel  = nil,
        GridFrame       = nil,
        UndoStack       = {},
        RedoStack       = {},
        CurrentProject  = { Name = "Untitled", Elements = {} }
    },
    Config = {
        GridSize    = 20,
        SnapToGrid  = false,
        ShowGrid    = true,
        DefaultSize = UDim2.fromOffset(200, 100)
    }
}
function GUICreator:PushUndo(action)
    table.insert(self.State.UndoStack, action)
    self.State.RedoStack = {}
    if #self.State.UndoStack > 50 then
        table.remove(self.State.UndoStack, 1)
    end
end
function GUICreator:Undo()
    local action = table.remove(self.State.UndoStack)
    if not action then print("[GUICreator] Nothing to undo") return end
    table.insert(self.State.RedoStack, action)
    action.Undo()
    self:RefreshHierarchy()
end
function GUICreator:Redo()
    local action = table.remove(self.State.RedoStack)
    if not action then print("[GUICreator] Nothing to redo") return end
    table.insert(self.State.UndoStack, action)
    action.Do()
    self:RefreshHierarchy()
end
function GUICreator:SnapValue(v)
    if not self.Config.SnapToGrid then return v end
    local g = self.Config.GridSize
    return math.floor((v + g / 2) / g) * g
end
function GUICreator:GetDataForElement(element)
    for _, d in ipairs(self.State.CreatedGUIs) do
        if d.Element == element then return d end
    end
    return nil
end
function GUICreator:CreateButton(text, color, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.fromOffset(110, 26)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel  = 0
    btn.Font             = Enum.Font.GothamBold
    btn.Text             = text
    btn.TextColor3       = Color3.new(1, 1, 1)
    btn.TextSize         = 10
    btn.AutoButtonColor  = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseEnter:Connect(function()
        local h, s, v = color:ToHSV()
        btn.BackgroundColor3 = Color3.fromHSV(h, s, math.min(v + 0.12, 1))
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color
    end)
    return btn
end
function GUICreator:_createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name            = "GUICreator_Zuka"
    screenGui.ResetOnSpawn    = false
    screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    self.State.UI             = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name             = "MainFrame"
    mainFrame.Size             = UDim2.fromOffset(1200, 700)
    mainFrame.Position         = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    mainFrame.BorderSizePixel  = 0
    mainFrame.Parent           = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color     = Color3.fromRGB(90, 140, 255)
    stroke.Thickness = 2
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name             = "TitleBar"
    titleBar.Size             = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    titleBar.BorderSizePixel  = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    local title = Instance.new("TextLabel", titleBar)
    title.Size               = UDim2.new(0.5, 0, 1, 0)
    title.Position           = UDim2.fromOffset(15, 0)
    title.BackgroundTransparency = 1
    title.Font               = Enum.Font.Code
    title.Text               = "▸ GUI CREATOR  —  Ctrl+Z Undo  |  Ctrl+Y Redo  |  Ctrl+D Dup  |  Del Delete"
    title.TextColor3         = Color3.fromRGB(90, 140, 255)
    title.TextSize           = 13
    title.TextXAlignment     = Enum.TextXAlignment.Left
    local projLabel = Instance.new("TextLabel", titleBar)
    projLabel.Size               = UDim2.fromOffset(60, 20)
    projLabel.Position           = UDim2.new(0.5, 0, 0.5, -10)
    projLabel.BackgroundTransparency = 1
    projLabel.Font               = Enum.Font.GothamBold
    projLabel.Text               = "Project:"
    projLabel.TextColor3         = Color3.fromRGB(140, 140, 160)
    projLabel.TextSize           = 10
    projLabel.TextXAlignment     = Enum.TextXAlignment.Right
    local projInput = Instance.new("TextBox", titleBar)
    projInput.Size             = UDim2.fromOffset(120, 22)
    projInput.Position         = UDim2.new(0.5, 64, 0.5, -11)
    projInput.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
    projInput.BorderSizePixel  = 0
    projInput.Font             = Enum.Font.Code
    projInput.Text             = self.State.CurrentProject.Name
    projInput.TextColor3       = Color3.fromRGB(220, 220, 255)
    projInput.TextSize         = 11
    projInput.ClearTextOnFocus = false
    Instance.new("UICorner", projInput).CornerRadius = UDim.new(0, 4)
    projInput.FocusLost:Connect(function()
        self.State.CurrentProject.Name = projInput.Text ~= "" and projInput.Text or "Untitled"
        projInput.Text = self.State.CurrentProject.Name
    end)
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size             = UDim2.fromOffset(30, 30)
    closeBtn.Position         = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "×"
    closeBtn.TextColor3       = Color3.new(1, 1, 1)
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.TextSize         = 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() self:Disable() end)
    self:MakeDraggable(titleBar, mainFrame)
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Name             = "TopBar"
    topBar.Size             = UDim2.new(1, -20, 0, 36)
    topBar.Position         = UDim2.fromOffset(10, 44)
    topBar.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    topBar.BorderSizePixel  = 0
    topBar.ZIndex           = 10
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)
    local topLayout = Instance.new("UIListLayout", topBar)
    topLayout.FillDirection    = Enum.FillDirection.Horizontal
    topLayout.Padding          = UDim.new(0, 6)
    topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    Instance.new("UIPadding", topBar).PaddingLeft = UDim.new(0, 10)
    local exportBtn = self:CreateButton("⬆ EXPORT CODE", Color3.fromRGB(0, 190, 95), topBar)
    exportBtn.MouseButton1Click:Connect(function() self:ExportCode() end)
    local undoBtn = self:CreateButton("↩ UNDO", Color3.fromRGB(90, 140, 255), topBar)
    undoBtn.Size = UDim2.fromOffset(80, 26)
    undoBtn.MouseButton1Click:Connect(function() self:Undo() end)
    local redoBtn = self:CreateButton("↪ REDO", Color3.fromRGB(90, 140, 255), topBar)
    redoBtn.Size = UDim2.fromOffset(80, 26)
    redoBtn.MouseButton1Click:Connect(function() self:Redo() end)
    local clearBtn = self:CreateButton("🗑 CLEAR", Color3.fromRGB(230, 80, 50), topBar)
    clearBtn.Size = UDim2.fromOffset(80, 26)
    clearBtn.MouseButton1Click:Connect(function() self:ClearCanvas() end)
    local gridBtn = self:CreateButton("GRID: ON", Color3.fromRGB(80, 80, 180), topBar)
    gridBtn.Size = UDim2.fromOffset(90, 26)
    gridBtn.MouseButton1Click:Connect(function()
        self.Config.ShowGrid = not self.Config.ShowGrid
        gridBtn.Text = "GRID: " .. (self.Config.ShowGrid and "ON" or "OFF")
        self:DrawGrid()
    end)
    local snapBtn = self:CreateButton("SNAP: OFF", Color3.fromRGB(120, 80, 200), topBar)
    snapBtn.Size = UDim2.fromOffset(90, 26)
    snapBtn.MouseButton1Click:Connect(function()
        self.Config.SnapToGrid = not self.Config.SnapToGrid
        snapBtn.Text = "SNAP: " .. (self.Config.SnapToGrid and "ON" or "OFF")
        snapBtn.BackgroundColor3 = self.Config.SnapToGrid
            and Color3.fromRGB(180, 80, 255)
            or  Color3.fromRGB(120, 80, 200)
    end)
    local leftPanel = Instance.new("Frame", mainFrame)
    leftPanel.Name             = "Toolbox"
    leftPanel.Size             = UDim2.new(0, 165, 1, -90)
    leftPanel.Position         = UDim2.fromOffset(10, 86)
    leftPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    leftPanel.BorderSizePixel  = 0
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 8)
    local toolboxLabel = Instance.new("TextLabel", leftPanel)
    toolboxLabel.Size               = UDim2.new(1, 0, 0, 28)
    toolboxLabel.BackgroundTransparency = 1
    toolboxLabel.Font               = Enum.Font.GothamBold
    toolboxLabel.Text               = "ELEMENTS"
    toolboxLabel.TextColor3         = Color3.fromRGB(160, 160, 180)
    toolboxLabel.TextSize           = 12
    local toolboxScroll = Instance.new("ScrollingFrame", leftPanel)
    toolboxScroll.Size                  = UDim2.new(1, -8, 1, -34)
    toolboxScroll.Position              = UDim2.fromOffset(4, 30)
    toolboxScroll.BackgroundTransparency = 1
    toolboxScroll.BorderSizePixel       = 0
    toolboxScroll.ScrollBarThickness    = 3
    toolboxScroll.ScrollBarImageColor3  = Color3.fromRGB(90, 140, 255)
    toolboxScroll.CanvasSize            = UDim2.fromOffset(0, 0)
    toolboxScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    local toolboxLayout = Instance.new("UIListLayout", toolboxScroll)
    toolboxLayout.Padding   = UDim.new(0, 4)
    toolboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local canvasPanel = Instance.new("Frame", mainFrame)
    canvasPanel.Name             = "Canvas"
    canvasPanel.Size             = UDim2.new(1, -560, 1, -90)
    canvasPanel.Position         = UDim2.fromOffset(183, 86)
    canvasPanel.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    canvasPanel.BorderSizePixel  = 0
    canvasPanel.ClipsDescendants = false
    Instance.new("UICorner", canvasPanel).CornerRadius = UDim.new(0, 8)
    local canvasLabel = Instance.new("TextLabel", canvasPanel)
    canvasLabel.Size               = UDim2.new(1, 0, 0, 24)
    canvasLabel.BackgroundTransparency = 1
    canvasLabel.Font               = Enum.Font.GothamBold
    canvasLabel.Text               = "CANVAS  (480 × 360)"
    canvasLabel.TextColor3         = Color3.fromRGB(120, 120, 140)
    canvasLabel.TextSize           = 11
    local workspace = Instance.new("Frame", canvasPanel)
    workspace.Name             = "Workspace"
    workspace.Size             = UDim2.fromOffset(480, 360)
    workspace.Position         = UDim2.new(0.5, 0, 0.5, 0)
    workspace.AnchorPoint      = Vector2.new(0.5, 0.5)
    workspace.BackgroundColor3 = Color3.fromRGB(46, 46, 58)
    workspace.BorderSizePixel  = 0
    workspace.ClipsDescendants = true
    local wsStroke = Instance.new("UIStroke", workspace)
    wsStroke.Color     = Color3.fromRGB(80, 80, 110)
    wsStroke.Thickness = 2
    local gridFrame = Instance.new("Frame", workspace)
    gridFrame.Name               = "GridOverlay"
    gridFrame.Size               = UDim2.new(1, 0, 1, 0)
    gridFrame.BackgroundTransparency = 1
    gridFrame.BorderSizePixel    = 0
    gridFrame.ZIndex             = 1
    self.State.GridFrame = gridFrame
    self:DrawGrid()
    local rightCol = Instance.new("Frame", mainFrame)
    rightCol.Name               = "RightCol"
    rightCol.Size               = UDim2.new(0, 240, 1, -90)
    rightCol.Position           = UDim2.new(1, -250, 0, 86)
    rightCol.BackgroundTransparency = 1
    rightCol.BorderSizePixel    = 0
    local rightPanel = Instance.new("Frame", rightCol)
    rightPanel.Name             = "Properties"
    rightPanel.Size             = UDim2.new(1, 0, 0.52, -4)
    rightPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    rightPanel.BorderSizePixel  = 0
    Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 8)
    local propertiesLabel = Instance.new("TextLabel", rightPanel)
    propertiesLabel.Size               = UDim2.new(1, 0, 0, 28)
    propertiesLabel.BackgroundTransparency = 1
    propertiesLabel.Font               = Enum.Font.GothamBold
    propertiesLabel.Text               = "PROPERTIES"
    propertiesLabel.TextColor3         = Color3.fromRGB(160, 160, 180)
    propertiesLabel.TextSize           = 12
    local propertiesScroll = Instance.new("ScrollingFrame", rightPanel)
    propertiesScroll.Name                  = "PropertiesScroll"
    propertiesScroll.Size                  = UDim2.new(1, -8, 1, -32)
    propertiesScroll.Position              = UDim2.fromOffset(4, 30)
    propertiesScroll.BackgroundTransparency = 1
    propertiesScroll.BorderSizePixel       = 0
    propertiesScroll.ScrollBarThickness    = 3
    propertiesScroll.ScrollBarImageColor3  = Color3.fromRGB(90, 140, 255)
    propertiesScroll.CanvasSize            = UDim2.fromOffset(0, 0)
    propertiesScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    local propLayout = Instance.new("UIListLayout", propertiesScroll)
    propLayout.Padding   = UDim.new(0, 6)
    propLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.State.PropertyPanel = propertiesScroll
    local hierPanel = Instance.new("Frame", rightCol)
    hierPanel.Name             = "Hierarchy"
    hierPanel.Size             = UDim2.new(1, 0, 0.48, -4)
    hierPanel.Position         = UDim2.new(0, 0, 0.52, 4)
    hierPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    hierPanel.BorderSizePixel  = 0
    Instance.new("UICorner", hierPanel).CornerRadius = UDim.new(0, 8)
    local hierLabel = Instance.new("TextLabel", hierPanel)
    hierLabel.Size               = UDim2.new(1, 0, 0, 28)
    hierLabel.BackgroundTransparency = 1
    hierLabel.Font               = Enum.Font.GothamBold
    hierLabel.Text               = "HIERARCHY"
    hierLabel.TextColor3         = Color3.fromRGB(160, 160, 180)
    hierLabel.TextSize           = 12
    local hierScroll = Instance.new("ScrollingFrame", hierPanel)
    hierScroll.Name                  = "HierarchyScroll"
    hierScroll.Size                  = UDim2.new(1, -8, 1, -32)
    hierScroll.Position              = UDim2.fromOffset(4, 30)
    hierScroll.BackgroundTransparency = 1
    hierScroll.BorderSizePixel       = 0
    hierScroll.ScrollBarThickness    = 3
    hierScroll.ScrollBarImageColor3  = Color3.fromRGB(90, 140, 255)
    hierScroll.CanvasSize            = UDim2.fromOffset(0, 0)
    hierScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    local hierLayout = Instance.new("UIListLayout", hierScroll)
    hierLayout.Padding   = UDim.new(0, 3)
    hierLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.State.HierarchyPanel = hierScroll
    screenGui.Parent = game:GetService("CoreGui")
    self:PopulateToolbox(toolboxScroll)
    self:_bindKeyboard()
    return workspace
end
function GUICreator:DrawGrid()
    local gf = self.State.GridFrame
    if not gf then return end
    for _, c in ipairs(gf:GetChildren()) do c:Destroy() end
    if not self.Config.ShowGrid then return end
    local W, H    = 480, 360
    local g       = self.Config.GridSize
    local lineColor = Color3.fromRGB(65, 65, 85)
    local function makeLine(x, y, w, h)
        local f = Instance.new("Frame", gf)
        f.BorderSizePixel  = 0
        f.BackgroundColor3 = lineColor
        f.Size             = UDim2.fromOffset(w, h)
        f.Position         = UDim2.fromOffset(x, y)
        f.ZIndex           = 1
    end
    local x = g while x < W do makeLine(x, 0, 1, H) ; x = x + g end
    local y = g while y < H do makeLine(0, y, W, 1) ; y = y + g end
end
function GUICreator:_bindKeyboard()
    local conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if ctrl and input.KeyCode == Enum.KeyCode.Z then self:Undo() end
        if ctrl and input.KeyCode == Enum.KeyCode.Y then self:Redo() end
        if ctrl and input.KeyCode == Enum.KeyCode.D then
            if self.State.SelectedElement then
                self:DuplicateElement(self.State.SelectedElement)
            end
        end
        if input.KeyCode == Enum.KeyCode.Delete then
            if self.State.SelectedElement then
                self:DeleteElement(self.State.SelectedElement)
            end
        end
    end)
    table.insert(self.State.Connections, conn)
end
function GUICreator:MakeDraggable(handle, object)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            object.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end
function GUICreator:PopulateToolbox(parent)
    local elements = {
        {Name = "Frame",          Color = Color3.fromRGB(100, 150, 220), Icon = "▭"},
        {Name = "TextLabel",      Color = Color3.fromRGB(140, 210,  90), Icon = "T"},
        {Name = "TextButton",     Color = Color3.fromRGB(220, 150,  80), Icon = "B"},
        {Name = "TextBox",        Color = Color3.fromRGB(210,  90, 150), Icon = "I"},
        {Name = "ImageLabel",     Color = Color3.fromRGB(150,  90, 220), Icon = "🖼"},
        {Name = "ScrollingFrame", Color = Color3.fromRGB( 80, 200, 150), Icon = "⇅"},
    }
    for _, elem in ipairs(elements) do
        local btn = Instance.new("TextButton", parent)
        btn.Size             = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
        btn.BorderSizePixel  = 0
        btn.Font             = Enum.Font.GothamBold
        btn.Text             = elem.Icon .. "  " .. elem.Name
        btn.TextColor3       = elem.Color
        btn.TextSize         = 11
        btn.TextXAlignment   = Enum.TextXAlignment.Left
        btn.AutoButtonColor  = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 10)
        btn.MouseButton1Click:Connect(function() self:CreateElement(elem.Name) end)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 50, 66) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(36, 36, 48) end)
    end
end
function GUICreator:CreateElement(elementType, snapshot)
    local workspace = self.State.UI.MainFrame.Canvas.Workspace
    local element   = Instance.new(elementType)
    local idx       = #self.State.CreatedGUIs + 1
    element.Name             = elementType .. "_" .. idx
    element.Size             = snapshot and snapshot.Size     or self.Config.DefaultSize
    element.Position         = snapshot and snapshot.Position or UDim2.fromOffset(
        self:SnapValue(math.random(40, 260)),
        self:SnapValue(math.random(40, 180))
    )
    element.BackgroundColor3 = snapshot and snapshot.BackgroundColor3
        or Color3.fromRGB(math.random(90,200), math.random(90,200), math.random(90,200))
    element.BorderSizePixel  = 0
    element.ZIndex           = snapshot and snapshot.ZIndex or idx + 2
    if elementType == "TextLabel" or elementType == "TextButton" or elementType == "TextBox" then
        element.Text       = snapshot and snapshot.Text       or element.Name
        element.TextColor3 = snapshot and snapshot.TextColor3 or Color3.new(1,1,1)
        element.Font       = Enum.Font.Gotham
        element.TextSize   = snapshot and snapshot.TextSize   or 14
    end
    if elementType == "TextBox" then
        element.PlaceholderText  = "Enter text…"
        element.ClearTextOnFocus = false
    end
    if elementType == "ImageLabel" then
        element.Image = snapshot and snapshot.Image
            or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    end
    if elementType == "ScrollingFrame" then
        element.ScrollingEnabled   = false
        element.ScrollBarThickness = 6
        element.CanvasSize         = snapshot and snapshot.CanvasSize or UDim2.fromOffset(480, 720)
    end
    local cornerRadius = (snapshot and snapshot.CornerRadius) or 8
    local corner = Instance.new("UICorner", element)
    corner.CornerRadius = UDim.new(0, cornerRadius)
    element.Parent = workspace
    local data = {
        Element      = element,
        Type         = elementType,
        CornerRadius = cornerRadius,
        Connections  = {}
    }
    table.insert(self.State.CreatedGUIs, data)
    self:MakeElementInteractive(element, data)
    self:RefreshHierarchy()
    self:SelectElement(element)
    if not snapshot then
        self:PushUndo({
            Do = function()
                element.Parent = workspace
                table.insert(self.State.CreatedGUIs, data)
                self:RefreshHierarchy()
            end,
            Undo = function()
                element.Parent = nil
                for i, d in ipairs(self.State.CreatedGUIs) do
                    if d.Element == element then table.remove(self.State.CreatedGUIs, i) break end
                end
                if self.State.SelectedElement == element then
                    self.State.SelectedElement = nil
                    self:UpdatePropertiesPanel(nil)
                end
                self:RefreshHierarchy()
            end
        })
    end
    print(string.format("[GUICreator] ✓ Created %s", element.Name))
    return element
end
function GUICreator:DuplicateElement(element)
    local data = self:GetDataForElement(element)
    local snap = {
        Size             = UDim2.fromOffset(element.Size.X.Offset, element.Size.Y.Offset),
        Position         = UDim2.fromOffset(element.Position.X.Offset + 15, element.Position.Y.Offset + 15),
        BackgroundColor3 = element.BackgroundColor3,
        ZIndex           = element.ZIndex,
        CornerRadius     = data and data.CornerRadius or 8,
    }
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        snap.Text       = element.Text
        snap.TextColor3 = element.TextColor3
        snap.TextSize   = element.TextSize
    end
    if element:IsA("ImageLabel") then snap.Image = element.Image end
    if element:IsA("ScrollingFrame") then
        snap.CanvasSize = UDim2.fromOffset(element.CanvasSize.X.Offset, element.CanvasSize.Y.Offset)
    end
    self:CreateElement(data and data.Type or "Frame", snap)
    print("[GUICreator] ✓ Duplicated element (Ctrl+D)")
end
function GUICreator:MakeElementInteractive(element, data)
    local canvasPanel = self.State.UI.MainFrame.Canvas
    local selBox = Instance.new("Frame", canvasPanel)
    selBox.Name               = "SelectionBox_" .. element.Name
    selBox.BackgroundTransparency = 1
    selBox.BorderSizePixel    = 0
    selBox.Visible            = false
    selBox.ZIndex             = 200
    local selStroke = Instance.new("UIStroke", selBox)
    selStroke.Color     = Color3.fromRGB(0, 230, 255)
    selStroke.Thickness = 2
    local function syncSelBox()
        if not element or not element.Parent then return end
        local ws    = self.State.UI.MainFrame.Canvas.Workspace
        local wsAbs = ws.AbsolutePosition
        local cpAbs = canvasPanel.AbsolutePosition
        local eSize = element.AbsoluteSize
        local ox    = (wsAbs.X - cpAbs.X) + element.Position.X.Offset
        local oy    = (wsAbs.Y - cpAbs.Y) + element.Position.Y.Offset
        selBox.Size     = UDim2.fromOffset(eSize.X + 6, eSize.Y + 6)
        selBox.Position = UDim2.fromOffset(ox - 3, oy - 3)
    end
    local handles = {
        {name="NW", ax=0,   ay=0,   cx=true,  cy=true},
        {name="N",  ax=0.5, ay=0,   cx=false, cy=true},
        {name="NE", ax=1,   ay=0,   cx=true,  cy=true},
        {name="W",  ax=0,   ay=0.5, cx=true,  cy=false},
        {name="E",  ax=1,   ay=0.5, cx=true,  cy=false},
        {name="SW", ax=0,   ay=1,   cx=true,  cy=true},
        {name="S",  ax=0.5, ay=1,   cx=false, cy=true},
        {name="SE", ax=1,   ay=1,   cx=true,  cy=true},
    }
    local handleInstances = {}
    for _, hd in ipairs(handles) do
        local h = Instance.new("TextButton", selBox)
        h.Name             = "Handle_" .. hd.name
        h.Size             = UDim2.fromOffset(10, 10)
        h.AnchorPoint      = Vector2.new(0.5, 0.5)
        h.Position         = UDim2.new(hd.ax, 0, hd.ay, 0)
        h.BackgroundColor3 = Color3.fromRGB(0, 230, 255)
        h.BorderSizePixel  = 0
        h.ZIndex           = 201
        h.Text             = ""
        h.AutoButtonColor  = false
        Instance.new("UICorner", h).CornerRadius = UDim.new(0, 2)
        handleInstances[hd.name] = {frame = h, meta = hd}
    end
    local resizing     = false
    local dragging     = false
    local resizeHandle = nil
    local dragStart    = nil
    local startPos     = nil
    local startSize    = nil
    for _, hdata in pairs(handleInstances) do
        hdata.frame.MouseButton1Down:Connect(function()
            self:SelectElement(element)
            resizing     = true
            dragging     = false
            resizeHandle = hdata.meta
            dragStart    = UserInputService:GetMouseLocation()
            startPos     = {X = element.Position.X.Offset, Y = element.Position.Y.Offset}
            startSize    = {W = element.Size.X.Offset,     H = element.Size.Y.Offset}
        end)
    end
    local elemConn = element.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if resizing then return end
        self:SelectElement(element)
        dragging  = true
        dragStart = input.Position
        startPos  = {X = element.Position.X.Offset, Y = element.Position.Y.Offset}
        startSize = {W = element.Size.X.Offset,     H = element.Size.Y.Offset}
    end)
    local moveConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if resizing and resizeHandle then
            local mouseNow = UserInputService:GetMouseLocation()
            local delta    = mouseNow - dragStart
            local h        = resizeHandle
            local nx, ny   = startPos.X, startPos.Y
            local nw, nh   = startSize.W, startSize.H
            if h.cx then
                if h.ax == 0 then
                    nw = math.max(20, startSize.W - delta.X)
                    nx = startPos.X + (startSize.W - nw)
                else
                    nw = math.max(20, startSize.W + delta.X)
                end
            end
            if h.cy then
                if h.ay == 0 then
                    nh = math.max(20, startSize.H - delta.Y)
                    ny = startPos.Y + (startSize.H - nh)
                else
                    nh = math.max(20, startSize.H + delta.Y)
                end
            end
            nx = self:SnapValue(nx) ; ny = self:SnapValue(ny)
            nw = self:SnapValue(nw) ; nh = self:SnapValue(nh)
            element.Position = UDim2.fromOffset(nx, ny)
            element.Size     = UDim2.fromOffset(nw, nh)
            syncSelBox()
            self:UpdatePropertiesPanel(element)
        elseif dragging then
            local delta = input.Position - dragStart
            local nx    = self:SnapValue(startPos.X + delta.X)
            local ny    = self:SnapValue(startPos.Y + delta.Y)
            element.Position = UDim2.fromOffset(nx, ny)
            syncSelBox()
        end
    end)
    local releaseConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if (dragging or resizing) and startPos and startSize then
            local oldPos  = UDim2.fromOffset(startPos.X, startPos.Y)
            local oldSize = UDim2.fromOffset(startSize.W, startSize.H)
            local newPos  = element.Position
            local newSize = element.Size
            if oldPos ~= newPos or oldSize ~= newSize then
                self:PushUndo({
                    Do = function()
                        element.Position = newPos ; element.Size = newSize
                        syncSelBox()
                        self:UpdatePropertiesPanel(element)
                    end,
                    Undo = function()
                        element.Position = oldPos ; element.Size = oldSize
                        syncSelBox()
                        self:UpdatePropertiesPanel(element)
                    end
                })
            end
        end
        dragging     = false
        resizing     = false
        resizeHandle = nil
    end)
    data.Connections = {elemConn, moveConn, releaseConn}
    data.SelectionBox = selBox
    data.SyncSelBox   = syncSelBox
end
function GUICreator:SelectElement(element)
    if self.State.SelectedElement == element then return end
    if self.State.SelectedElement then
        local oldData = self:GetDataForElement(self.State.SelectedElement)
        if oldData and oldData.SelectionBox then
            oldData.SelectionBox.Visible = false
        end
    end
    self.State.SelectedElement = element
    local data = self:GetDataForElement(element)
    if data then
        if data.SelectionBox then
            data.SyncSelBox()
            data.SelectionBox.Visible = true
        end
    end
    self:UpdatePropertiesPanel(element)
    self:RefreshHierarchy()
end
function GUICreator:RefreshHierarchy()
    local panel = self.State.HierarchyPanel
    if not panel then return end
    for _, c in ipairs(panel:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    for _, data in ipairs(self.State.CreatedGUIs) do
        local elem = data.Element
        if not elem or not elem.Parent then continue end
        local row = Instance.new("TextButton", panel)
        row.Size             = UDim2.new(1, -6, 0, 26)
        row.BorderSizePixel  = 0
        row.Font             = Enum.Font.Code
        row.TextSize         = 11
        row.TextXAlignment   = Enum.TextXAlignment.Left
        row.AutoButtonColor  = false
        local isSel = (self.State.SelectedElement == elem)
        row.BackgroundColor3 = isSel and Color3.fromRGB(50,80,160) or Color3.fromRGB(36,36,50)
        row.TextColor3       = isSel and Color3.new(1,1,1)         or Color3.fromRGB(180,180,200)
        row.Text = "  [Z:" .. tostring(elem.ZIndex) .. "]  " .. elem.Name
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        row.MouseButton1Click:Connect(function() self:SelectElement(elem) end)
        local function makeZBtn(label, offset, delta)
            local b = Instance.new("TextButton", row)
            b.Size             = UDim2.fromOffset(18, 18)
            b.Position         = UDim2.new(1, offset, 0.5, -9)
            b.BackgroundColor3 = Color3.fromRGB(70,70,100)
            b.BorderSizePixel  = 0
            b.Font             = Enum.Font.GothamBold
            b.Text             = label
            b.TextSize         = 9
            b.TextColor3       = Color3.new(1,1,1)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,3)
            b.MouseButton1Click:Connect(function() self:ChangeZIndex(elem, delta) end)
        end
        makeZBtn("▲", -42, 1)
        makeZBtn("▼", -21, -1)
    end
end
function GUICreator:ChangeZIndex(element, delta)
    local oldZ = element.ZIndex
    local newZ = math.max(3, oldZ + delta)
    element.ZIndex = newZ
    self:PushUndo({
        Do   = function() element.ZIndex = newZ ; self:RefreshHierarchy() end,
        Undo = function() element.ZIndex = oldZ ; self:RefreshHierarchy() end
    })
    self:RefreshHierarchy()
    self:UpdatePropertiesPanel(element)
end
function GUICreator:UpdatePropertiesPanel(element)
    local panel = self.State.PropertyPanel
    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
    if not element then return end
    local data = self:GetDataForElement(element)
    self:CreateProperty(panel, "Name", element.Name, function(v)
        local old = element.Name
        element.Name = v
        if data and data.SelectionBox then
            data.SelectionBox.Name = "SelectionBox_" .. v
        end
        self:PushUndo({
            Do   = function() element.Name = v   ; self:RefreshHierarchy() end,
            Undo = function() element.Name = old ; self:RefreshHierarchy() end
        })
        self:RefreshHierarchy()
    end)
    self:CreateProperty(panel, "Size X", tostring(element.Size.X.Offset), function(v)
        element.Size = UDim2.fromOffset(tonumber(v) or 200, element.Size.Y.Offset)
        if data then data.SyncSelBox() end
    end)
    self:CreateProperty(panel, "Size Y", tostring(element.Size.Y.Offset), function(v)
        element.Size = UDim2.fromOffset(element.Size.X.Offset, tonumber(v) or 100)
        if data then data.SyncSelBox() end
    end)
    self:CreateProperty(panel, "Pos X", tostring(element.Position.X.Offset), function(v)
        element.Position = UDim2.fromOffset(tonumber(v) or 0, element.Position.Y.Offset)
        if data then data.SyncSelBox() end
    end)
    self:CreateProperty(panel, "Pos Y", tostring(element.Position.Y.Offset), function(v)
        element.Position = UDim2.fromOffset(element.Position.X.Offset, tonumber(v) or 0)
        if data then data.SyncSelBox() end
    end)
    self:CreateProperty(panel, "ZIndex", tostring(element.ZIndex), function(v)
        local old = element.ZIndex
        local nz  = math.max(3, tonumber(v) or 3)
        element.ZIndex = nz
        self:PushUndo({
            Do   = function() element.ZIndex = nz  ; self:RefreshHierarchy() end,
            Undo = function() element.ZIndex = old ; self:RefreshHierarchy() end
        })
        self:RefreshHierarchy()
    end)
    self:CreateProperty(panel, "CornerRadius", tostring(data and data.CornerRadius or 8), function(v)
        local r = math.max(0, tonumber(v) or 8)
        if data then data.CornerRadius = r end
        local corner = element:FindFirstChildOfClass("UICorner")
        if corner then corner.CornerRadius = UDim.new(0, r) end
    end)
    self:CreateProperty(panel, "AnchorPoint X", tostring(element.AnchorPoint.X), function(v)
        element.AnchorPoint = Vector2.new(math.clamp(tonumber(v) or 0, 0, 1), element.AnchorPoint.Y)
        if data then data.SyncSelBox() end
    end)
    self:CreateProperty(panel, "AnchorPoint Y", tostring(element.AnchorPoint.Y), function(v)
        element.AnchorPoint = Vector2.new(element.AnchorPoint.X, math.clamp(tonumber(v) or 0, 0, 1))
        if data then data.SyncSelBox() end
    end)
    self:CreateColorProperty(panel, "BG Color", element.BackgroundColor3, function(c)
        element.BackgroundColor3 = c
    end)
    self:CreateProperty(panel, "Transparency", tostring(element.BackgroundTransparency), function(v)
        element.BackgroundTransparency = math.clamp(tonumber(v) or 0, 0, 1)
    end)
    self:CreateToggleProperty(panel, "Visible", element.Visible, function(v)
        element.Visible = v
    end)
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        self:CreateProperty(panel, "Text", element.Text, function(v) element.Text = v end)
        self:CreateProperty(panel, "TextSize", tostring(element.TextSize), function(v)
            element.TextSize = tonumber(v) or 14
        end)
        self:CreateColorProperty(panel, "Text Color", element.TextColor3, function(c)
            element.TextColor3 = c
        end)
    end
    if element:IsA("ImageLabel") or element:IsA("ImageButton") then
        self:CreateProperty(panel, "Image ID", element.Image, function(v)
            element.Image = v
        end)
    end
    if element:IsA("ScrollingFrame") then
        self:CreateProperty(panel, "Canvas W", tostring(element.CanvasSize.X.Offset), function(v)
            element.CanvasSize = UDim2.fromOffset(tonumber(v) or 480, element.CanvasSize.Y.Offset)
        end)
        self:CreateProperty(panel, "Canvas H", tostring(element.CanvasSize.Y.Offset), function(v)
            element.CanvasSize = UDim2.fromOffset(element.CanvasSize.X.Offset, tonumber(v) or 720)
        end)
        self:CreateProperty(panel, "ScrollBar Thickness", tostring(element.ScrollBarThickness), function(v)
            element.ScrollBarThickness = tonumber(v) or 6
        end)
    end
    local deleteBtn = Instance.new("TextButton", panel)
    deleteBtn.Size             = UDim2.new(1,-6,0,32)
    deleteBtn.BackgroundColor3 = Color3.fromRGB(220,45,90)
    deleteBtn.BorderSizePixel  = 0
    deleteBtn.Font             = Enum.Font.GothamBold
    deleteBtn.Text             = "🗑  DELETE ELEMENT"
    deleteBtn.TextColor3       = Color3.new(1,1,1)
    deleteBtn.TextSize         = 11
    Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0,6)
    deleteBtn.MouseButton1Click:Connect(function() self:DeleteElement(element) end)
    local dupBtn = Instance.new("TextButton", panel)
    dupBtn.Size             = UDim2.new(1,-6,0,32)
    dupBtn.BackgroundColor3 = Color3.fromRGB(70,130,220)
    dupBtn.BorderSizePixel  = 0
    dupBtn.Font             = Enum.Font.GothamBold
    dupBtn.Text             = "⧉  DUPLICATE (Ctrl+D)"
    dupBtn.TextColor3       = Color3.new(1,1,1)
    dupBtn.TextSize         = 11
    Instance.new("UICorner", dupBtn).CornerRadius = UDim.new(0,6)
    dupBtn.MouseButton1Click:Connect(function() self:DuplicateElement(element) end)
end
function GUICreator:CreateProperty(panel, name, value, onChange)
    local container = Instance.new("Frame", panel)
    container.Size             = UDim2.new(1,-6,0,48)
    container.BackgroundColor3 = Color3.fromRGB(36,36,50)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,5)
    local label = Instance.new("TextLabel", container)
    label.Size               = UDim2.new(1,-10,0,18)
    label.Position           = UDim2.fromOffset(6,4)
    label.BackgroundTransparency = 1
    label.Font               = Enum.Font.GothamBold
    label.Text               = name
    label.TextColor3         = Color3.fromRGB(180,180,200)
    label.TextSize           = 10
    label.TextXAlignment     = Enum.TextXAlignment.Left
    local input = Instance.new("TextBox", container)
    input.Size             = UDim2.new(1,-12,0,20)
    input.Position         = UDim2.fromOffset(6,24)
    input.BackgroundColor3 = Color3.fromRGB(26,26,38)
    input.BorderSizePixel  = 0
    input.Font             = Enum.Font.Code
    input.Text             = tostring(value)
    input.TextColor3       = Color3.new(1,1,1)
    input.TextSize         = 10
    input.ClearTextOnFocus = false
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,4)
    input.FocusLost:Connect(function() onChange(input.Text) end)
end
function GUICreator:CreateColorProperty(panel, name, color, onChange)
    local container = Instance.new("Frame", panel)
    container.Size             = UDim2.new(1,-6,0,48)
    container.BackgroundColor3 = Color3.fromRGB(36,36,50)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,5)
    local label = Instance.new("TextLabel", container)
    label.Size               = UDim2.new(1,-46,0,18)
    label.Position           = UDim2.fromOffset(6,4)
    label.BackgroundTransparency = 1
    label.Font               = Enum.Font.GothamBold
    label.Text               = name
    label.TextColor3         = Color3.fromRGB(180,180,200)
    label.TextSize           = 10
    label.TextXAlignment     = Enum.TextXAlignment.Left
    local preview = Instance.new("Frame", container)
    preview.Size             = UDim2.fromOffset(22,22)
    preview.Position         = UDim2.new(1,-28,0,4)
    preview.BackgroundColor3 = color
    preview.BorderSizePixel  = 0
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0,4)
    local input = Instance.new("TextBox", container)
    input.Size             = UDim2.new(1,-12,0,20)
    input.Position         = UDim2.fromOffset(6,24)
    input.BackgroundColor3 = Color3.fromRGB(26,26,38)
    input.BorderSizePixel  = 0
    input.Font             = Enum.Font.Code
    input.Text             = string.format("%d,%d,%d", color.R*255, color.G*255, color.B*255)
    input.TextColor3       = Color3.new(1,1,1)
    input.TextSize         = 10
    input.PlaceholderText  = "R,G,B"
    input.ClearTextOnFocus = false
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,4)
    input.FocusLost:Connect(function()
        local p = string.split(input.Text, ",")
        if #p == 3 then
            local r,g,b = tonumber(p[1]),tonumber(p[2]),tonumber(p[3])
            if r and g and b then
                local nc = Color3.fromRGB(r,g,b)
                preview.BackgroundColor3 = nc
                onChange(nc)
            end
        end
    end)
end
function GUICreator:CreateToggleProperty(panel, name, currentValue, onChange)
    local container = Instance.new("Frame", panel)
    container.Size             = UDim2.new(1,-6,0,34)
    container.BackgroundColor3 = Color3.fromRGB(36,36,50)
    container.BorderSizePixel  = 0
    Instance.new("UICorner", container).CornerRadius = UDim.new(0,5)
    local label = Instance.new("TextLabel", container)
    label.Size               = UDim2.new(1,-50,1,0)
    label.Position           = UDim2.fromOffset(6,0)
    label.BackgroundTransparency = 1
    label.Font               = Enum.Font.GothamBold
    label.Text               = name
    label.TextColor3         = Color3.fromRGB(180,180,200)
    label.TextSize           = 10
    label.TextXAlignment     = Enum.TextXAlignment.Left
    local val = currentValue
    local toggleBtn = Instance.new("TextButton", container)
    toggleBtn.Size             = UDim2.fromOffset(44, 22)
    toggleBtn.Position         = UDim2.new(1,-50,0.5,-11)
    toggleBtn.BorderSizePixel  = 0
    toggleBtn.Font             = Enum.Font.GothamBold
    toggleBtn.TextSize         = 10
    toggleBtn.TextColor3       = Color3.new(1,1,1)
    toggleBtn.AutoButtonColor  = false
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,4)
    local function refresh()
        toggleBtn.Text             = val and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = val and Color3.fromRGB(0,180,90) or Color3.fromRGB(140,40,60)
    end
    refresh()
    toggleBtn.MouseButton1Click:Connect(function()
        val = not val
        refresh()
        onChange(val)
    end)
end
function GUICreator:DeleteElement(element)
    local savedType, savedData
    for i, data in ipairs(self.State.CreatedGUIs) do
        if data.Element == element then
            savedType = data.Type
            savedData = data
            table.remove(self.State.CreatedGUIs, i)
            break
        end
    end
    if savedData and savedData.Connections then
        for _, c in ipairs(savedData.Connections) do if c then c:Disconnect() end end
    end
    if savedData and savedData.SelectionBox then
        savedData.SelectionBox:Destroy()
    end
    local snap = {
        Size             = element.Size,
        Position         = element.Position,
        BackgroundColor3 = element.BackgroundColor3,
        ZIndex           = element.ZIndex,
        CornerRadius     = savedData and savedData.CornerRadius or 8,
    }
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        snap.Text       = element.Text
        snap.TextColor3 = element.TextColor3
        snap.TextSize   = element.TextSize
    end
    if element:IsA("ImageLabel") then snap.Image = element.Image end
    if element:IsA("ScrollingFrame") then
        snap.CanvasSize = UDim2.fromOffset(element.CanvasSize.X.Offset, element.CanvasSize.Y.Offset)
    end
    element:Destroy()
    self.State.SelectedElement = nil
    self:UpdatePropertiesPanel(nil)
    self:RefreshHierarchy()
    self:PushUndo({
        Undo = function() self:CreateElement(savedType, snap) end,
        Do   = function()
            local latest = self.State.CreatedGUIs[#self.State.CreatedGUIs]
            if latest then self:DeleteElement(latest.Element) end
        end
    })
    print("[GUICreator] ✓ Deleted element")
end
function GUICreator:ClearCanvas()
    for _, data in ipairs(self.State.CreatedGUIs) do
        if data.Connections then
            for _, c in ipairs(data.Connections) do if c then c:Disconnect() end end
        end
        if data.SelectionBox then data.SelectionBox:Destroy() end
        if data.Element      then data.Element:Destroy() end
    end
    self.State.CreatedGUIs     = {}
    self.State.UndoStack       = {}
    self.State.RedoStack       = {}
    self.State.SelectedElement = nil
    self:UpdatePropertiesPanel(nil)
    self:RefreshHierarchy()
    print("[GUICreator] ✓ Cleared canvas")
end
function GUICreator:ExportCode()
    local lines = {}
    local function w(s) table.insert(lines, s) end
    w("-- ════════════════════════════════════════")
    w("-- Generated by GUI Creator (Zuka)")
    w("-- Project: " .. self.State.CurrentProject.Name)
    w("-- ════════════════════════════════════════")
    w("local Players     = game:GetService('Players')")
    w("local LocalPlayer = Players.LocalPlayer")
    w("")
    w("local ScreenGui = Instance.new('ScreenGui')")
    w("ScreenGui.Name           = '" .. self.State.CurrentProject.Name .. "'")
    w("ScreenGui.ResetOnSpawn   = false")
    w("ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling")
    w("ScreenGui.Parent         = LocalPlayer:WaitForChild('PlayerGui')")
    w("")
    for _, data in ipairs(self.State.CreatedGUIs) do
        local e = data.Element
        if not e or not e.Parent then continue end
        local n = e.Name
        w(string.format("-- %s", n))
        w(string.format("local %s = Instance.new('%s')", n, data.Type))
        w(string.format("%s.Name                   = '%s'", n, n))
        w(string.format("%s.Size                   = UDim2.fromOffset(%d, %d)", n, e.Size.X.Offset, e.Size.Y.Offset))
        w(string.format("%s.Position               = UDim2.fromOffset(%d, %d)", n, e.Position.X.Offset, e.Position.Y.Offset))
        w(string.format("%s.AnchorPoint            = Vector2.new(%g, %g)", n, e.AnchorPoint.X, e.AnchorPoint.Y))
        w(string.format("%s.BackgroundColor3       = Color3.fromRGB(%d, %d, %d)",
            n, math.round(e.BackgroundColor3.R*255), math.round(e.BackgroundColor3.G*255), math.round(e.BackgroundColor3.B*255)))
        w(string.format("%s.BackgroundTransparency = %g", n, e.BackgroundTransparency))
        w(string.format("%s.BorderSizePixel        = 0", n))
        w(string.format("%s.ZIndex                 = %d", n, e.ZIndex))
        w(string.format("%s.Visible                = %s", n, tostring(e.Visible)))
        if e:IsA("TextLabel") or e:IsA("TextButton") or e:IsA("TextBox") then
            local safe = e.Text:gsub("'", "\\'")
            w(string.format("%s.Text                   = '%s'", n, safe))
            w(string.format("%s.TextColor3             = Color3.fromRGB(%d, %d, %d)",
                n, math.round(e.TextColor3.R*255), math.round(e.TextColor3.G*255), math.round(e.TextColor3.B*255)))
            w(string.format("%s.TextSize               = %d", n, e.TextSize))
            w(string.format("%s.Font                   = Enum.Font.%s",
                n, tostring(e.Font):gsub("Enum%.Font%.", "")))
            w(string.format("%s.TextXAlignment         = Enum.TextXAlignment.Left", n))
        end
        if e:IsA("ImageLabel") or e:IsA("ImageButton") then
            w(string.format("%s.Image     = '%s'", n, e.Image))
            w(string.format("%s.ScaleType = Enum.ScaleType.Fit", n))
        end
        if e:IsA("ScrollingFrame") then
            w(string.format("%s.ScrollBarThickness = %d", n, e.ScrollBarThickness))
            w(string.format("%s.CanvasSize         = UDim2.fromOffset(%d, %d)",
                n, e.CanvasSize.X.Offset, e.CanvasSize.Y.Offset))
            w(string.format("%s.ScrollingEnabled   = true", n))
        end
        local cr = data.CornerRadius or 8
        w(string.format("do local c = Instance.new('UICorner', %s) ; c.CornerRadius = UDim.new(0, %d) end", n, cr))
        w(string.format("%s.Parent = ScreenGui", n))
        w("")
    end
    local code = table.concat(lines, "\n")
    if setclipboard then
        setclipboard(code)
        print("[GUICreator] ✓ Code copied to clipboard!")
    else
        print(code)
        print("[GUICreator] ✓ Code printed to console (F9)")
    end
end
function GUICreator:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self:_createUI()
    print("[GUICreator] ✓ Enabled")
    print("  Drag | Resize via handles | Ctrl+Z/Y | Ctrl+D dup | Del delete")
end
function GUICreator:Disable()
    if not self.State.IsEnabled then return end
    self.State.IsEnabled = false
    for _, conn in pairs(self.State.Connections) do
        if conn then conn:Disconnect() end
    end
    table.clear(self.State.Connections)
    for _, data in ipairs(self.State.CreatedGUIs) do
        if data.Connections then
            for _, c in ipairs(data.Connections) do if c then c:Disconnect() end end
        end
    end
    if self.State.UI then
        self.State.UI:Destroy()
        self.State.UI = nil
    end
    self.State.CreatedGUIs     = {}
    self.State.UndoStack       = {}
    self.State.RedoStack       = {}
    self.State.SelectedElement = nil
    self.State.GridFrame       = nil
    print("[GUICreator] ✓ Disabled")
end
function GUICreator:Toggle()
    if self.State.IsEnabled then self:Disable() else self:Enable() end
end
GUICreator:Enable()
