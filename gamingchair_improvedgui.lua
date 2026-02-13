local AimbotGUI = {}
AimbotGUI.__index = AimbotGUI
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local function makeUICorner(element, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = element
	return corner
end
local function createStroke(element, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(80, 80, 90)
	stroke.Thickness = thickness or 1
	stroke.Parent = element
	return stroke
end
local function tweenSize(element, endSize, duration)
	local tween = TweenService:Create(element, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = endSize})
	tween:Play()
	return tween
end
local function tweenColor(element, property, endColor, duration)
	local tween = TweenService:Create(element, TweenInfo.new(duration or 0.2), {[property] = endColor})
	tween:Play()
	return tween
end
function AimbotGUI.new(aimbotSystem, parentGui)
	local self = setmetatable({}, AimbotGUI)
	self.aimbot = aimbotSystem
	self.gui = parentGui
	self.connections = {}
	self.elements = {}
	self.currentPage = "main"
	return self
end
function AimbotGUI:createToggleButton(parent, text, initialState, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 = initialState and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(40, 40, 40)
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Text = text .. ": " .. (initialState and "ON" or "OFF")
	button.Parent = parent
	makeUICorner(button, 6)
	local state = initialState
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = text .. ": " .. (state and "ON" or "OFF")
		tweenColor(button, "BackgroundColor3", state and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(40, 40, 40), 0.2)
		if callback then
			callback(state)
		end
	end)
	button.MouseEnter:Connect(function()
		tweenColor(button, "BackgroundColor3", state and Color3.fromRGB(70, 160, 70) or Color3.fromRGB(50, 50, 50), 0.1)
	end)
	button.MouseLeave:Connect(function()
		tweenColor(button, "BackgroundColor3", state and Color3.fromRGB(60, 150, 60) or Color3.fromRGB(40, 40, 40), 0.1)
	end)
	return button
end
function AimbotGUI:createSlider(parent, labelText, min, max, defaultValue, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 50)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(180, 220, 255)
	label.TextSize = 14
	label.Text = labelText
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 60, 0, 20)
	valueLabel.Position = UDim2.new(1, -60, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.TextSize = 14
	valueLabel.Text = tostring(math.floor(defaultValue))
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = container
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 6)
	track.Position = UDim2.new(0, 0, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	track.BorderSizePixel = 0
	track.Parent = container
	makeUICorner(track, 3)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	makeUICorner(fill, 3)
	local handle = Instance.new("TextButton")
	handle.Size = UDim2.new(0, 16, 0, 16)
	handle.Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8)
	handle.BackgroundColor3 = Color3.fromRGB(180, 220, 255)
	handle.BorderSizePixel = 0
	handle.Text = ""
	handle.Parent = track
	makeUICorner(handle, 8)
	createStroke(handle, Color3.fromRGB(255, 255, 255), 2)
	local dragging = false
	local currentValue = defaultValue
	local function updateValue(input)
		local relativeX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
		local ratio = relativeX / track.AbsoluteSize.X
		currentValue = min + (max - min) * ratio
		valueLabel.Text = string.format("%.1f", currentValue)
		handle.Position = UDim2.new(ratio, -8, 0.5, -8)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		if callback then
			callback(currentValue)
		end
	end
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			tweenSize(handle, UDim2.new(0, 20, 0, 20), 0.1)
		end
	end)
	table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			tweenSize(handle, UDim2.new(0, 16, 0, 16), 0.1)
		end
	end))
	table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input)
		end
	end))
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateValue(input)
		end
	end)
	return container, function() return currentValue end
end
function AimbotGUI:createDropdown(parent, labelText, options, defaultOption, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 32)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(180, 220, 255)
	label.TextSize = 14
	label.Text = labelText .. ":"
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.6, 0, 1, 0)
	button.Position = UDim2.new(0.4, 0, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Text = defaultOption or options[1]
	button.Parent = container
	makeUICorner(button, 6)
	local dropdownFrame = nil
	local isOpen = false
	local function closeDropdown()
		if dropdownFrame then
			dropdownFrame:Destroy()
			dropdownFrame = nil
		end
		isOpen = false
	end
	button.MouseButton1Click:Connect(function()
		if isOpen then
			closeDropdown()
			return
		end
		isOpen = true
		dropdownFrame = Instance.new("Frame")
		dropdownFrame.Size = UDim2.new(0.6, 0, 0, #options * 28)
		dropdownFrame.Position = UDim2.new(0.4, 0, 1, 4)
		dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		dropdownFrame.BorderSizePixel = 0
		dropdownFrame.ZIndex = 10
		dropdownFrame.Parent = container
		makeUICorner(dropdownFrame, 6)
		createStroke(dropdownFrame, Color3.fromRGB(80, 80, 90), 1)
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 2)
		listLayout.Parent = dropdownFrame
		for i, option in ipairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, 0, 0, 26)
			optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			optionButton.Font = Enum.Font.Gotham
			optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			optionButton.TextSize = 13
			optionButton.Text = option
			optionButton.Parent = dropdownFrame
			makeUICorner(optionButton, 4)
			optionButton.MouseButton1Click:Connect(function()
				button.Text = option
				closeDropdown()
				if callback then
					callback(option)
				end
			end)
			optionButton.MouseEnter:Connect(function()
				tweenColor(optionButton, "BackgroundColor3", Color3.fromRGB(55, 55, 65), 0.1)
			end)
			optionButton.MouseLeave:Connect(function()
				tweenColor(optionButton, "BackgroundColor3", Color3.fromRGB(45, 45, 55), 0.1)
			end)
		end
	end)
	table.insert(self.connections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
			if not button:IsAncestorOf(input.Position) and dropdownFrame and not dropdownFrame:IsAncestorOf(input.Position) then
				closeDropdown()
			end
		end
	end))
	return container
end
function AimbotGUI:createKeybindButton(parent, labelText, defaultKey, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 32)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextColor3 = Color3.fromRGB(180, 220, 255)
	label.TextSize = 14
	label.Text = labelText .. ":"
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.6, 0, 1, 0)
	button.Position = UDim2.new(0.4, 0, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 14
	button.Text = defaultKey
	button.Parent = container
	makeUICorner(button, 6)
	local listening = false
	local currentKey = defaultKey
	button.MouseButton1Click:Connect(function()
		if listening then
			return
		end
		listening = true
		button.Text = "Press a key..."
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
		local connection
		connection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			local keyName = ""
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				keyName = "MouseButton2"
			elseif input.UserInputType == Enum.UserInputType.Keyboard then
				keyName = input.KeyCode.Name
			else
				return
			end
			currentKey = keyName
			button.Text = keyName
			button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			listening = false
			connection:Disconnect()
			if callback then
				callback(keyName, input.UserInputType, input.KeyCode)
			end
		end)
	end)
	return container
end
function AimbotGUI:createSectionHeader(parent, text)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.Text = text
	header.TextColor3 = Color3.fromRGB(200, 220, 255)
	header.TextSize = 16
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = parent
	return header
end
function AimbotGUI:createStatusBar(parent)
	local statusBar = Instance.new("Frame")
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(1, -20, 0, 50)
	statusBar.Position = UDim2.new(0, 10, 1, -55)
	statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	statusBar.BorderSizePixel = 0
	statusBar.Parent = parent
	makeUICorner(statusBar, 6)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = statusBar
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 18)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
	statusLabel.TextSize = 13
	statusLabel.Text = "Aimbot ready"
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = statusBar
	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Name = "FPSLabel"
	fpsLabel.Size = UDim2.new(1, 0, 0, 16)
	fpsLabel.Position = UDim2.new(0, 0, 0, 20)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.Font = Enum.Font.GothamMedium
	fpsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	fpsLabel.TextSize = 11
	fpsLabel.Text = "FPS: 60 | Targets: 0"
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.Parent = statusBar
	self.elements.statusLabel = statusLabel
	self.elements.fpsLabel = fpsLabel
	local lastUpdate = tick()
	local frameCount = 0
	table.insert(self.connections, RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = tick()
		if now - lastUpdate >= 1 then
			local fps = frameCount / (now - lastUpdate)
			local targetCount = #self.aimbot.targetIndex
			fpsLabel.Text = string.format("FPS: %d | Targets: %d", math.floor(fps), targetCount)
			frameCount = 0
			lastUpdate = now
		end
	end))
	return statusBar
end
function AimbotGUI:updateStatus(text, color)
	if self.elements.statusLabel then
		self.elements.statusLabel.Text = text
		if color then
			self.elements.statusLabel.TextColor3 = color
		end
	end
end
function AimbotGUI:build()
	local mainWindow = self.gui
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, 0, 1, -30)
	contentContainer.Position = UDim2.new(0, 0, 0, 30)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = mainWindow
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -60)
	scrollFrame.Position = UDim2.new(0, 10, 0, 10)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = contentContainer
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = scrollFrame
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end)
	self:createSectionHeader(scrollFrame, "⚙️ General Settings")
	self:createKeybindButton(scrollFrame, "Toggle Key", "MouseButton2", function(keyName, inputType, keyCode)
		self.aimbot.settings.toggleKey = inputType == Enum.UserInputType.MouseButton2 and inputType or keyCode
		self:updateStatus("Toggle key set to: " .. keyName, Color3.fromRGB(180, 220, 180))
	end)
	self:createDropdown(scrollFrame, "Aim Part", {"Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso"}, "Head", function(option)
		self.aimbot.settings.aimPart = option
	end)
	self:createToggleButton(scrollFrame, "Smart Hitbox", true, function(state)
		self.aimbot.settings.hitboxPriority = state
	end)
	self:createSectionHeader(scrollFrame, "🎯 Field of View")
	self:createSlider(scrollFrame, "FOV Radius", 50, 500, self.aimbot.settings.fovRadius, function(value)
		self.aimbot.settings.fovRadius = value
	end)
	self:createSectionHeader(scrollFrame, "🎮 Smoothing")
	self:createToggleButton(scrollFrame, "Smoothing", self.aimbot.settings.smoothingEnabled, function(state)
		self.aimbot.settings.smoothingEnabled = state
	end)
	self:createSlider(scrollFrame, "Smoothness", 0.05, 1.0, self.aimbot.settings.smoothingFactor, function(value)
		self.aimbot.settings.smoothingFactor = value
	end)
	self:createToggleButton(scrollFrame, "Distance-Based Smoothing", true, function(state)
		self.aimbot.settings.distanceBasedSmoothing = state
	end)
	self:createSectionHeader(scrollFrame, "🔮 Prediction")
	self:createToggleButton(scrollFrame, "Prediction", self.aimbot.settings.predictionEnabled, function(state)
		self.aimbot.settings.predictionEnabled = state
	end)
	self:createSlider(scrollFrame, "Prediction Strength", 0.5, 2.0, 1.0, function(value)
		self.aimbot.settings.predictionMultiplier = value
	end)
	self:createSectionHeader(scrollFrame, "🛡️ Modifiers")
	self:createToggleButton(scrollFrame, "Ignore Team", false, function(state)
		self.aimbot.settings.ignoreTeam = state
	end)
	self:createToggleButton(scrollFrame, "Wall Check", true, function(state)
		self.aimbot.settings.wallCheckEnabled = state
	end)
	self:createToggleButton(scrollFrame, "Sticky Target", true, function(state)
		self.aimbot.settings.stickyTarget = state
	end)
	self:createStatusBar(contentContainer)
	return mainWindow
end
function AimbotGUI:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}
end
return AimbotGUI
