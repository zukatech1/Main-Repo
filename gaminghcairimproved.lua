local AimbotSystem = {}
AimbotSystem.__index = AimbotSystem
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local CONFIG = {
	GUI_NAME = "EnhancedAimbotSuite",
	DEFAULT_FOV = 50,
	DEFAULT_SMOOTHNESS = 0.2,
	MIN_FOV = 50,
	MAX_FOV = 500,
	MIN_SMOOTHNESS = 0.05,
	MAX_SMOOTHNESS = 1.0,
	UPDATE_RATE = 0.5,
	PREDICTION_SAMPLES = 3,
	STICKY_DISTANCE_MULTIPLIER = 1.5,
}
local HITBOX_PRIORITIES = {
	{Name = "Head", Priority = 1, DamageMultiplier = 2.0},
	{Name = "UpperTorso", Priority = 2, DamageMultiplier = 1.5},
	{Name = "HumanoidRootPart", Priority = 3, DamageMultiplier = 1.0},
	{Name = "Torso", Priority = 4, DamageMultiplier = 1.5},
	{Name = "LowerTorso", Priority = 5, DamageMultiplier = 1.0},
}
local function makeUICorner(element, cornerRadius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius or 6)
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
local function tweenProperty(instance, property, endValue, duration, easingStyle, easingDirection)
	local tween = TweenService:Create(instance, TweenInfo.new(
		duration or 0.2,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	), {[property] = endValue})
	tween:Play()
	return tween
end
function AimbotSystem.new()
	local self = setmetatable({}, AimbotSystem)
	self.enabled = false
	self.aiming = false
	self.currentTarget = nil
	self.lastTargetPosition = nil
	self.velocityHistory = {}
	self.connections = {}
	self.espObjects = {}
	self.settings = {
		toggleKey = Enum.UserInputType.MouseButton2,
		aimPart = "Head",
		fovRadius = CONFIG.DEFAULT_FOV,
		smoothingEnabled = true,
		smoothingFactor = CONFIG.DEFAULT_SMOOTHNESS,
		distanceBasedSmoothing = true,
		wallCheckEnabled = true,
		ignoreTeam = false,
		stickyTarget = true,
		predictionEnabled = true,
		predictionMultiplier = 1.0,
		targetScope = Workspace,
		specificTarget = nil,
		specificTargetEnabled = false,
		hitboxPriority = true,
		ignoredParts = {},
	}
	self.targetIndex = {}
	self.lastIndexUpdate = 0
	self.wallCheckParams = RaycastParams.new()
	self.wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
	self.fovCircle = nil
	if Drawing and typeof(Drawing.new) == "function" then
		self.fovCircle = Drawing.new("Circle")
		self.fovCircle.Visible = false
		self.fovCircle.Thickness = 2
		self.fovCircle.NumSides = 64
		self.fovCircle.Color = Color3.fromRGB(255, 255, 255)
		self.fovCircle.Transparency = 0.6
		self.fovCircle.Filled = false
	end
	return self
end
function AimbotSystem:updateTargetIndex(force)
	local now = tick()
	if not force and (now - self.lastIndexUpdate) < CONFIG.UPDATE_RATE then
		return
	end
	self.lastIndexUpdate = now
	self.targetIndex = {}
	local scope = self.settings.targetScope
	if not scope or not scope.Parent then
		scope = Workspace
		self.settings.targetScope = scope
	end
	for _, descendant in ipairs(scope:GetDescendants()) do
		if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
			local humanoid = descendant:FindFirstChildOfClass("Humanoid")
			if humanoid.Health > 0 then
				table.insert(self.targetIndex, descendant)
			end
		end
	end
end
function AimbotSystem:isTeammate(player)
	if not self.settings.ignoreTeam or not player then
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
function AimbotSystem:isPartVisible(targetPart)
	if not self.settings.wallCheckEnabled then
		return true
	end
	if not LocalPlayer.Character or not targetPart or not targetPart.Parent then
		return false
	end
	local targetCharacter = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent
	local origin = Camera.CFrame.Position
	local filterList = {LocalPlayer.Character, targetCharacter}
	for _, part in ipairs(self.settings.ignoredParts) do
		table.insert(filterList, part)
	end
	self.wallCheckParams.FilterDescendantsInstances = filterList
	local result = Workspace:Raycast(origin, targetPart.Position - origin, self.wallCheckParams)
	return not result
end
function AimbotSystem:getSmartHitbox(model)
	if not self.settings.hitboxPriority then
		return model:FindFirstChild(self.settings.aimPart)
	end
	for _, hitbox in ipairs(HITBOX_PRIORITIES) do
		local part = model:FindFirstChild(hitbox.Name)
		if part and self:isPartVisible(part) then
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
function AimbotSystem:getClosestTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local minDist = math.huge
	local closestTarget = nil
	local closestPart = nil
	if self.settings.stickyTarget and self.currentTarget and self.currentTarget.Parent then
		local player = Players:GetPlayerFromCharacter(self.currentTarget)
		if not (player and player == LocalPlayer) and not (player and self:isTeammate(player)) then
			local targetPart = self:getSmartHitbox(self.currentTarget)
			if targetPart then
				local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
					if dist <= (self.settings.fovRadius * CONFIG.STICKY_DISTANCE_MULTIPLIER) then
						return self.currentTarget, targetPart
					end
				end
			end
		end
	end
	for _, model in ipairs(self.targetIndex) do
		if model and model.Parent then
			local player = Players:GetPlayerFromCharacter(model)
			if not (player and player == LocalPlayer) and not (player and self:isTeammate(player)) then
				local targetPart = self:getSmartHitbox(model)
				if targetPart then
					local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
					if onScreen then
						local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
						if dist < minDist and dist <= self.settings.fovRadius then
							minDist = dist
							closestTarget = model
							closestPart = targetPart
						end
					end
				end
			end
		end
	end
	return closestTarget, closestPart
end
function AimbotSystem:predictPosition(targetPart)
	if not self.settings.predictionEnabled then
		return targetPart.Position
	end
	local velocity = targetPart.AssemblyLinearVelocity
	table.insert(self.velocityHistory, velocity)
	if #self.velocityHistory > CONFIG.PREDICTION_SAMPLES then
		table.remove(self.velocityHistory, 1)
	end
	local avgVelocity = Vector3.new(0, 0, 0)
	for _, vel in ipairs(self.velocityHistory) do
		avgVelocity = avgVelocity + vel
	end
	avgVelocity = avgVelocity / #self.velocityHistory
	local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
	local predictionTime = (distance / 2000) * self.settings.predictionMultiplier
	return targetPart.Position + (avgVelocity * predictionTime)
end
function AimbotSystem:getDistanceBasedSmoothness(distance)
	if not self.settings.distanceBasedSmoothing then
		return self.settings.smoothingFactor
	end
	local minDistance = 10
	local maxDistance = 300
	local normalizedDist = math.clamp((distance - minDistance) / (maxDistance - minDistance), 0, 1)
	local smoothnessMult = 1 - (normalizedDist * 0.5)
	return self.settings.smoothingFactor * smoothnessMult
end
function AimbotSystem:aimAtTarget(targetPart, deltaTime)
	if not targetPart or not targetPart.Parent then
		return false
	end
	local predictedPosition = self:predictPosition(targetPart)
	local goalCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPosition)
	if self.settings.smoothingEnabled then
		local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
		local smoothness = self:getDistanceBasedSmoothness(distance)
		local adjustedSmoothFactor = math.clamp(1 - (1 - smoothness) ^ (60 * deltaTime), 0, 1)
		Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, adjustedSmoothFactor)
	else
		Camera.CFrame = goalCFrame
	end
	return true
end
function AimbotSystem:createESP(part, color, name)
	if not part or not part.Parent then
		return
	end
	if self.espObjects[part] then
		local esp = self.espObjects[part]
		esp.Color3 = color
		esp.Size = part.Size
		return
	end
	local espBox = Instance.new("BoxHandleAdornment")
	espBox.Name = name or "AimbotESP"
	espBox.Adornee = part
	espBox.AlwaysOnTop = true
	espBox.ZIndex = 10
	espBox.Size = part.Size
	espBox.Color3 = color
	espBox.Transparency = 0.4
	espBox.Parent = part
	self.espObjects[part] = espBox
end
function AimbotSystem:clearESP(part)
	if part then
		if self.espObjects[part] then
			self.espObjects[part]:Destroy()
			self.espObjects[part] = nil
		end
	else
		for _, espBox in pairs(self.espObjects) do
			pcall(function()
				espBox:Destroy()
			end)
		end
		self.espObjects = {}
	end
end
function AimbotSystem:update(deltaTime)
	if self.fovCircle and self.fovCircle.Visible then
		self.fovCircle.Position = UserInputService:GetMouseLocation()
		self.fovCircle.Radius = self.settings.fovRadius
	end
	self:updateTargetIndex()
	if not self.aiming then
		self.currentTarget = nil
		self.velocityHistory = {}
		self:clearESP()
		return
	end
	local targetModel, targetPart
	if self.settings.specificTargetEnabled and self.settings.specificTarget then
		local player = self.settings.specificTarget
		if player and player.Character and player ~= LocalPlayer and not self:isTeammate(player) then
			targetModel = player.Character
			targetPart = self:getSmartHitbox(targetModel)
		end
	else
		targetModel, targetPart = self:getClosestTarget()
	end
	self.currentTarget = targetModel
	if targetModel and targetPart then
		if self:aimAtTarget(targetPart, deltaTime) then
			self:createESP(targetPart, Color3.fromRGB(255, 80, 80), "AimbotESP")
		else
			self:clearESP()
		end
	else
		self:clearESP()
	end
	for part, _ in pairs(self.espObjects) do
		if not part.Parent or part ~= targetPart then
			self:clearESP(part)
		end
	end
end
function AimbotSystem:handleInput(input, processed)
	if processed then
		return
	end
	if input.UserInputType == self.settings.toggleKey or
	   (input.UserInputType == Enum.UserInputType.Keyboard and 
	    input.KeyCode == self.settings.toggleKey) then
		self.aiming = true
		if self.fovCircle then
			self.fovCircle.Visible = true
		end
	end
end
function AimbotSystem:handleInputEnd(input)
	if input.UserInputType == self.settings.toggleKey or
	   (input.UserInputType == Enum.UserInputType.Keyboard and 
	    input.KeyCode == self.settings.toggleKey) then
		self.aiming = false
		if self.fovCircle then
			self.fovCircle.Visible = false
		end
		self:clearESP()
	end
end
function AimbotSystem:start()
	if self.enabled then
		return
	end
	self.enabled = true
	table.insert(self.connections, RunService.RenderStepped:Connect(function(dt)
		self:update(dt)
	end))
	table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, processed)
		self:handleInput(input, processed)
	end))
	table.insert(self.connections, UserInputService.InputEnded:Connect(function(input)
		self:handleInputEnd(input)
	end))
	self:updateTargetIndex(true)
end
function AimbotSystem:stop()
	if not self.enabled then
		return
	end
	self.enabled = false
	self.aiming = false
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}
	self:clearESP()
	if self.fovCircle then
		self.fovCircle.Visible = false
	end
end
function AimbotSystem:destroy()
	self:stop()
	if self.fovCircle then
		self.fovCircle:Remove()
		self.fovCircle = nil
	end
end
function AimbotSystem:saveProfile(name)
	name = name or "default"
	local profile = HttpService:JSONEncode(self.settings)
	if writefile then
		local success, err = pcall(function()
			writefile("aimbot_profile_" .. name .. ".json", profile)
		end)
		return success, err
	end
	return false, "File system not available"
end
function AimbotSystem:loadProfile(name)
	name = name or "default"
	if readfile then
		local success, result = pcall(function()
			return readfile("aimbot_profile_" .. name .. ".json")
		end)
		if success then
			local settings = HttpService:JSONDecode(result)
			for key, value in pairs(settings) do
				if self.settings[key] ~= nil then
					self.settings[key] = value
				end
			end
			return true
		end
	end
	return false
end
return AimbotSystem
