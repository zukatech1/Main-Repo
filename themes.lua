local ThemeCustomizer = {}
ThemeCustomizer.__index = ThemeCustomizer
local PRESET_THEMES = {
    ["Cyan Classic"] = {
        Primary = Color3.fromRGB(0, 255, 255),
        Secondary = Color3.fromRGB(0, 200, 200),
        Background = Color3.fromRGB(20, 20, 26),
        Foreground = Color3.fromRGB(30, 30, 38),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(50, 200, 100),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 80, 80),
        Transparency = 0.15,
        BlurIntensity = 12
    },
    ["Purple Dream"] = {
        Primary = Color3.fromRGB(200, 100, 255),
        Secondary = Color3.fromRGB(150, 80, 200),
        Background = Color3.fromRGB(18, 15, 25),
        Foreground = Color3.fromRGB(28, 25, 35),
        Text = Color3.fromRGB(240, 240, 250),
        TextDim = Color3.fromRGB(180, 170, 190),
        Success = Color3.fromRGB(100, 200, 150),
        Warning = Color3.fromRGB(255, 180, 100),
        Error = Color3.fromRGB(255, 100, 120),
        Transparency = 0.1,
        BlurIntensity = 15
    },
    ["Neon Pink"] = {
        Primary = Color3.fromRGB(255, 50, 150),
        Secondary = Color3.fromRGB(200, 40, 120),
        Background = Color3.fromRGB(25, 15, 20),
        Foreground = Color3.fromRGB(35, 25, 30),
        Text = Color3.fromRGB(250, 240, 245),
        TextDim = Color3.fromRGB(190, 170, 180),
        Success = Color3.fromRGB(100, 255, 180),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 60, 60),
        Transparency = 0.12,
        BlurIntensity = 14
    },
    ["Toxic Green"] = {
        Primary = Color3.fromRGB(50, 255, 50),
        Secondary = Color3.fromRGB(40, 200, 40),
        Background = Color3.fromRGB(15, 25, 15),
        Foreground = Color3.fromRGB(20, 35, 20),
        Text = Color3.fromRGB(240, 250, 240),
        TextDim = Color3.fromRGB(170, 190, 170),
        Success = Color3.fromRGB(100, 255, 100),
        Warning = Color3.fromRGB(255, 255, 100),
        Error = Color3.fromRGB(255, 80, 80),
        Transparency = 0.13,
        BlurIntensity = 11
    },
    ["Blood Red"] = {
        Primary = Color3.fromRGB(255, 40, 40),
        Secondary = Color3.fromRGB(200, 30, 30),
        Background = Color3.fromRGB(25, 15, 15),
        Foreground = Color3.fromRGB(35, 20, 20),
        Text = Color3.fromRGB(250, 240, 240),
        TextDim = Color3.fromRGB(190, 170, 170),
        Success = Color3.fromRGB(150, 200, 100),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Transparency = 0.14,
        BlurIntensity = 13
    },
    ["Ocean Blue"] = {
        Primary = Color3.fromRGB(50, 150, 255),
        Secondary = Color3.fromRGB(40, 120, 200),
        Background = Color3.fromRGB(15, 20, 28),
        Foreground = Color3.fromRGB(20, 28, 38),
        Text = Color3.fromRGB(240, 245, 250),
        TextDim = Color3.fromRGB(170, 180, 200),
        Success = Color3.fromRGB(100, 200, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Transparency = 0.11,
        BlurIntensity = 16
    },
    ["Golden Sunset"] = {
        Primary = Color3.fromRGB(255, 180, 50),
        Secondary = Color3.fromRGB(200, 140, 40),
        Background = Color3.fromRGB(28, 22, 18),
        Foreground = Color3.fromRGB(38, 32, 25),
        Text = Color3.fromRGB(250, 245, 235),
        TextDim = Color3.fromRGB(200, 185, 170),
        Success = Color3.fromRGB(150, 200, 100),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 100, 80),
        Transparency = 0.15,
        BlurIntensity = 10
    },
    ["Midnight"] = {
        Primary = Color3.fromRGB(100, 100, 150),
        Secondary = Color3.fromRGB(80, 80, 120),
        Background = Color3.fromRGB(10, 10, 15),
        Foreground = Color3.fromRGB(15, 15, 22),
        Text = Color3.fromRGB(230, 230, 240),
        TextDim = Color3.fromRGB(160, 160, 180),
        Success = Color3.fromRGB(100, 200, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Transparency = 0.08,
        BlurIntensity = 18
    },
    ["Monochrome"] = {
        Primary = Color3.fromRGB(200, 200, 200),
        Secondary = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(18, 18, 18),
        Foreground = Color3.fromRGB(28, 28, 28),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 160),
        Success = Color3.fromRGB(180, 180, 180),
        Warning = Color3.fromRGB(200, 200, 200),
        Error = Color3.fromRGB(220, 220, 220),
        Transparency = 0.1,
        BlurIntensity = 12
    }
}
function ThemeCustomizer.new()
    local self = setmetatable({}, ThemeCustomizer)
    self.CurrentTheme = self:LoadTheme() or self:CloneTheme(PRESET_THEMES["Cyan Classic"])
    self.AppliedElements = {}
    self.GUI = nil
    return self
end
function ThemeCustomizer:CloneTheme(theme)
    local clone = {}
    for key, value in pairs(theme) do
        clone[key] = value
    end
    return clone
end
function ThemeCustomizer:SaveTheme()
    local success, err = pcall(function()
        local HttpService = game:GetService("HttpService")
        local themeData = HttpService:JSONEncode(self.CurrentTheme)
        if writefile then
            writefile("ZukaPanel_Theme.json", themeData)
        end
    end)
    if success then
        DoNotif("Theme saved successfully", 2)
    else
        DoNotif("Failed to save theme", 3)
    end
end
function ThemeCustomizer:LoadTheme()
    local success, themeData = pcall(function()
        if isfile and readfile and isfile("ZukaPanel_Theme.json") then
            local HttpService = game:GetService("HttpService")
            local json = readfile("ZukaPanel_Theme.json")
            return HttpService:JSONDecode(json)
        end
        return nil
    end)
    return success and themeData or nil
end
function ThemeCustomizer:ApplyToElement(element, colorType)
    if not element then return end
    local color = self.CurrentTheme[colorType]
    if not color then return end
    table.insert(self.AppliedElements, {
        Element = element,
        Type = colorType,
        Property = element:IsA("TextLabel") and "TextColor3" or 
                   element:IsA("TextButton") and "TextColor3" or
                   element:IsA("ImageLabel") and "ImageColor3" or
                   element:IsA("ImageButton") and "ImageColor3" or
                   "BackgroundColor3"
    })
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        element.TextColor3 = color
    elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
        element.ImageColor3 = color
    else
        element.BackgroundColor3 = color
    end
end
function ThemeCustomizer:ReapplyTheme()
    for _, data in ipairs(self.AppliedElements) do
        if data.Element and data.Element.Parent then
            local color = self.CurrentTheme[data.Type]
            if color then
                data.Element[data.Property] = color
            end
        end
    end
    DoNotif("Theme applied: " .. (self.CurrentTheme.Name or "Custom"), 2)
end
function ThemeCustomizer:CreateGUI()
    if self.GUI and self.GUI.Parent then
        self.GUI:Destroy()
    end
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local gui = Instance.new("ScreenGui")
    gui.Name = "ThemeCustomizer_Zuka"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    self.GUI = gui
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Parent = gui
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(700, 550)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = self.CurrentTheme.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = self.CurrentTheme.Primary
    containerStroke.Thickness = 2
    containerStroke.Parent = container
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = self.CurrentTheme.Foreground
    titleBar.BorderSizePixel = 0
    titleBar.Parent = container
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.fromOffset(20, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎨 THEME CUSTOMIZER"
    title.TextColor3 = self.CurrentTheme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(40, 40)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
    closeBtn.BackgroundColor3 = self.CurrentTheme.Error
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -40, 1, -70)
    content.Position = UDim2.fromOffset(20, 60)
    content.BackgroundTransparency = 1
    content.Parent = container
    local presetPanel = Instance.new("Frame")
    presetPanel.Size = UDim2.new(0.35, -10, 1, 0)
    presetPanel.BackgroundColor3 = self.CurrentTheme.Foreground
    presetPanel.BorderSizePixel = 0
    presetPanel.Parent = content
    Instance.new("UICorner", presetPanel).CornerRadius = UDim.new(0, 10)
    local presetTitle = Instance.new("TextLabel")
    presetTitle.Size = UDim2.new(1, -20, 0, 30)
    presetTitle.Position = UDim2.fromOffset(10, 10)
    presetTitle.BackgroundTransparency = 1
    presetTitle.Text = "PRESET THEMES"
    presetTitle.TextColor3 = self.CurrentTheme.Primary
    presetTitle.Font = Enum.Font.GothamBold
    presetTitle.TextSize = 14
    presetTitle.TextXAlignment = Enum.TextXAlignment.Left
    presetTitle.Parent = presetPanel
    local presetList = Instance.new("ScrollingFrame")
    presetList.Size = UDim2.new(1, -20, 1, -50)
    presetList.Position = UDim2.fromOffset(10, 45)
    presetList.BackgroundTransparency = 1
    presetList.BorderSizePixel = 0
    presetList.ScrollBarThickness = 4
    presetList.ScrollBarImageColor3 = self.CurrentTheme.Primary
    presetList.CanvasSize = UDim2.fromOffset(0, 0)
    presetList.Parent = presetPanel
    local presetLayout = Instance.new("UIListLayout")
    presetLayout.Padding = UDim.new(0, 8)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Parent = presetList
    presetLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        presetList.CanvasSize = UDim2.fromOffset(0, presetLayout.AbsoluteContentSize.Y + 10)
    end)
    for themeName, themeData in pairs(PRESET_THEMES) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = self.CurrentTheme.Background
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = presetList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local colorPreview = Instance.new("Frame")
        colorPreview.Size = UDim2.fromOffset(35, 35)
        colorPreview.Position = UDim2.fromOffset(8, 5)
        colorPreview.BackgroundColor3 = themeData.Primary
        colorPreview.BorderSizePixel = 0
        colorPreview.Parent = btn
        Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(1, 0)
        Instance.new("UIStroke", colorPreview).Color = themeData.Secondary
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -55, 1, 0)
        nameLabel.Position = UDim2.fromOffset(50, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = themeName
        nameLabel.TextColor3 = self.CurrentTheme.Text
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = btn
        btn.MouseButton1Click:Connect(function()
            self.CurrentTheme = self:CloneTheme(themeData)
            self.CurrentTheme.Name = themeName
            self:ReapplyTheme()
            self:UpdateCustomColorPickers()
            self:SaveTheme()
        end)
    end
    local customPanel = Instance.new("Frame")
    customPanel.Size = UDim2.new(0.65, -10, 1, 0)
    customPanel.Position = UDim2.new(0.35, 10, 0, 0)
    customPanel.BackgroundColor3 = self.CurrentTheme.Foreground
    customPanel.BorderSizePixel = 0
    customPanel.Parent = content
    Instance.new("UICorner", customPanel).CornerRadius = UDim.new(0, 10)
    local customTitle = Instance.new("TextLabel")
    customTitle.Size = UDim2.new(1, -20, 0, 30)
    customTitle.Position = UDim2.fromOffset(10, 10)
    customTitle.BackgroundTransparency = 1
    customTitle.Text = "CUSTOM COLORS"
    customTitle.TextColor3 = self.CurrentTheme.Primary
    customTitle.Font = Enum.Font.GothamBold
    customTitle.TextSize = 14
    customTitle.TextXAlignment = Enum.TextXAlignment.Left
    customTitle.Parent = customPanel
    local colorScroll = Instance.new("ScrollingFrame")
    colorScroll.Size = UDim2.new(1, -20, 1, -90)
    colorScroll.Position = UDim2.fromOffset(10, 45)
    colorScroll.BackgroundTransparency = 1
    colorScroll.BorderSizePixel = 0
    colorScroll.ScrollBarThickness = 4
    colorScroll.ScrollBarImageColor3 = self.CurrentTheme.Primary
    colorScroll.CanvasSize = UDim2.fromOffset(0, 0)
    colorScroll.Parent = customPanel
    local colorLayout = Instance.new("UIListLayout")
    colorLayout.Padding = UDim.new(0, 10)
    colorLayout.SortOrder = Enum.SortOrder.LayoutOrder
    colorLayout.Parent = colorScroll
    colorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        colorScroll.CanvasSize = UDim2.fromOffset(0, colorLayout.AbsoluteContentSize.Y + 10)
    end)
    local colorProperties = {
        {Name = "Primary", Label = "Primary Color"},
        {Name = "Secondary", Label = "Secondary Color"},
        {Name = "Background", Label = "Background"},
        {Name = "Foreground", Label = "Foreground"},
        {Name = "Text", Label = "Text Color"},
        {Name = "TextDim", Label = "Dim Text"},
        {Name = "Success", Label = "Success Color"},
        {Name = "Warning", Label = "Warning Color"},
        {Name = "Error", Label = "Error Color"}
    }
    for _, prop in ipairs(colorProperties) do
        self:CreateColorPicker(colorScroll, prop.Name, prop.Label)
    end
    self:CreateSlider(customPanel, "Transparency", 0, 0.5, self.CurrentTheme.Transparency)
    self:CreateSlider(customPanel, "BlurIntensity", 0, 24, self.CurrentTheme.BlurIntensity)
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -40, 0, 40)
    buttonContainer.Position = UDim2.new(0, 20, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = container
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.32, -5, 1, 0)
    saveBtn.BackgroundColor3 = self.CurrentTheme.Success
    saveBtn.Text = "💾 SAVE"
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 14
    saveBtn.Parent = buttonContainer
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    saveBtn.MouseButton1Click:Connect(function()
        self:SaveTheme()
    end)
    local applyBtn = Instance.new("TextButton")
    applyBtn.Size = UDim2.new(0.32, -5, 1, 0)
    applyBtn.Position = UDim2.new(0.34, 0, 0, 0)
    applyBtn.BackgroundColor3 = self.CurrentTheme.Primary
    applyBtn.Text = "✓ APPLY"
    applyBtn.TextColor3 = Color3.new(1, 1, 1)
    applyBtn.Font = Enum.Font.GothamBold
    applyBtn.TextSize = 14
    applyBtn.Parent = buttonContainer
    Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 8)
    applyBtn.MouseButton1Click:Connect(function()
        self:ReapplyTheme()
    end)
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0.32, -5, 1, 0)
    resetBtn.Position = UDim2.new(0.68, 0, 0, 0)
    resetBtn.BackgroundColor3 = self.CurrentTheme.Error
    resetBtn.Text = "↺ RESET"
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.Parent = buttonContainer
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
    resetBtn.MouseButton1Click:Connect(function()
        self.CurrentTheme = self:CloneTheme(PRESET_THEMES["Cyan Classic"])
        self:ReapplyTheme()
        self:UpdateCustomColorPickers()
        DoNotif("Theme reset to default", 2)
    end)
    container.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(700, 550)
    }):Play()
end
function ThemeCustomizer:CreateColorPicker(parent, propertyName, label)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Name = propertyName .. "_Picker"
    container.Parent = parent
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.CurrentTheme.Text
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = container
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.fromOffset(100, 30)
    colorDisplay.Position = UDim2.new(1, -100, 0, 2.5)
    colorDisplay.BackgroundColor3 = self.CurrentTheme[propertyName]
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = container
    Instance.new("UICorner", colorDisplay).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", colorDisplay).Color = self.CurrentTheme.TextDim
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.fromScale(1, 1)
    colorBtn.BackgroundTransparency = 1
    colorBtn.Text = ""
    colorBtn.Parent = colorDisplay
    colorBtn.MouseButton1Click:Connect(function()
        self:OpenColorWheel(propertyName, colorDisplay)
    end)
end
function ThemeCustomizer:OpenColorWheel(propertyName, displayFrame)
    local pickerGui = Instance.new("ScreenGui")
    pickerGui.Name = "ColorPicker_" .. propertyName
    pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pickerGui.Parent = game:GetService("CoreGui")
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.fromOffset(300, 200)
    pickerFrame.Position = UDim2.fromScale(0.5, 0.5)
    pickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    pickerFrame.BackgroundColor3 = self.CurrentTheme.Background
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Parent = pickerGui
    Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", pickerFrame).Color = self.CurrentTheme.Primary
    local currentColor = self.CurrentTheme[propertyName]
    local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
    local function createSlider(yPos, colorName, initialValue)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.fromOffset(10, yPos)
        label.BackgroundTransparency = 1
        label.Text = colorName .. ": " .. initialValue
        label.TextColor3 = self.CurrentTheme.Text
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = pickerFrame
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, -20, 0, 6)
        slider.Position = UDim2.fromOffset(10, yPos + 25)
        slider.BackgroundColor3 = self.CurrentTheme.Foreground
        slider.BorderSizePixel = 0
        slider.Parent = pickerFrame
        Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(initialValue / 255, 1)
        fill.BackgroundColor3 = self.CurrentTheme.Primary
        fill.BorderSizePixel = 0
        fill.Parent = slider
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromScale(1, 1)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = slider
        local dragging = false
        button.MouseButton1Down:Connect(function()
            dragging = true
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.fromScale(pos, 1)
                local value = math.floor(pos * 255)
                label.Text = colorName .. ": " .. value
                if colorName == "R" then r = value
                elseif colorName == "G" then g = value
                else b = value end
                local newColor = Color3.fromRGB(r, g, b)
                self.CurrentTheme[propertyName] = newColor
                displayFrame.BackgroundColor3 = newColor
            end
        end)
        return label
    end
    createSlider(20, "R", r)
    createSlider(70, "G", g)
    createSlider(120, "B", b)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(280, 35)
    closeBtn.Position = UDim2.fromOffset(10, 155)
    closeBtn.BackgroundColor3 = self.CurrentTheme.Primary
    closeBtn.Text = "✓ DONE"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = pickerFrame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        pickerGui:Destroy()
    end)
end
function ThemeCustomizer:CreateSlider(parent, propertyName, minValue, maxValue, currentValue)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 1, -85)
    container.BackgroundTransparency = 1
    container.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = propertyName .. ": " .. string.format("%.2f", currentValue)
    label.TextColor3 = self.CurrentTheme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.5, -10, 0, 8)
    sliderBg.Position = UDim2.new(0.5, 5, 0.5, -4)
    sliderBg.BackgroundColor3 = self.CurrentTheme.Foreground
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale((currentValue - minValue) / (maxValue - minValue), 1)
    fill.BackgroundColor3 = self.CurrentTheme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(1, 1)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = sliderBg
    local dragging = false
    button.MouseButton1Down:Connect(function()
        dragging = true
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.fromScale(pos, 1)
            local value = minValue + (pos * (maxValue - minValue))
            self.CurrentTheme[propertyName] = value
            label.Text = propertyName .. ": " .. string.format("%.2f", value)
        end
    end)
end
function ThemeCustomizer:UpdateCustomColorPickers()
    if not self.GUI then return end
    local colorScroll = self.GUI:FindFirstChild("ThemeCustomizer_Zuka"):FindFirstChild("Frame"):FindFirstChild("Frame", true)
    if not colorScroll then return end
    for _, child in ipairs(colorScroll:GetChildren()) do
        if child.Name:match("_Picker$") then
            local propertyName = child.Name:gsub("_Picker", "")
            local colorDisplay = child:FindFirstChild("Frame")
            if colorDisplay then
                colorDisplay.BackgroundColor3 = self.CurrentTheme[propertyName]
            end
        end
    end
end
function ThemeCustomizer:GetTheme()
    return self.CurrentTheme
end
return ThemeCustomizer
