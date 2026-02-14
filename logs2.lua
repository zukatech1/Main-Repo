local script = game:GetService("Players").LocalPlayer.CratesClient
local v1 = game:GetService("Players")
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = game:GetService("MarketplaceService")
local v_u_4 = game:GetService("RunService")
local v_u_5 = game:GetService("TweenService")
local v_u_6 = game:GetService("StarterGui")
local v_u_7 = game:GetService("TextChatService")
local v_u_8 = v1.LocalPlayer
local v9 = v2:WaitForChild("ModuleSettings")
local v_u_10 = require(v9:WaitForChild("CratesConfig"))
local v11 = v2:WaitForChild("RemoteEvents")
local v_u_12 = v11:WaitForChild("UnboxCrate")
local v13 = v11:WaitForChild("CrateOpened")
local v14 = v11:WaitForChild("SyncRolls")
local v_u_15 = v11:WaitForChild("RequestRolls")
v11:WaitForChild("NotificationEvent")
local v_u_16 = v11:WaitForChild("RevealAck")
local v17 = v11:WaitForChild("GlobalUnlock")
local v_u_18 = v11:WaitForChild("NotifyRequest")
local v_u_19 = v11:WaitForChild("GetOwned")
local v20 = script.Parent
local v_u_21 = v20:WaitForChild("Main"):WaitForChild("Frames"):WaitForChild("CrateShopFrame")
local v_u_22 = v_u_21:WaitForChild("CratesList")
local v_u_23 = v_u_21:WaitForChild("SelectedCrate")
v_u_23.Visible = false
local v_u_24 = v20:WaitForChild("OpenedCrateGui")
v_u_24.Enabled = false
local v_u_25 = v_u_24:WaitForChild("CrateFrame")
v_u_25.Visible = false
local v_u_26 = v_u_25:WaitForChild("ContinueButton")
local v_u_27 = v_u_25:WaitForChild("ReRoll")
local v_u_28 = v_u_25:WaitForChild("ItemsFrame"):WaitForChild("ItemsContainer")
local v_u_29 = v_u_23:WaitForChild("Rolls")
local v30 = v_u_23:WaitForChild("BuyRoll1")
local v31 = v_u_23:WaitForChild("BuyRoll2")
local v32 = v_u_23:WaitForChild("UnboxButton")
local v_u_33 = script:WaitForChild("CrateShopButton")
local v_u_34 = script:WaitForChild("SelectedCrateItemFrame")
local v_u_35 = script:WaitForChild("OpeningCrateItemFrame")
local v_u_36 = script:FindFirstChild("TickSound")
local v_u_37 = script:FindFirstChild("CelebrateSound")
local v_u_38 = Random.new()
local v_u_39 = {}
local v_u_40 = {}
local v_u_41 = nil
local v_u_42 = "IDLE"
local v_u_43 = nil
local v_u_44 = 0
local v_u_45 = 0
local v_u_46 = nil
local v_u_47 = false
for _, v48 in pairs(v_u_10.CRATES) do
	for _, v49 in ipairs(v48.Items) do
		v_u_39[v49.name] = v49
	end
end
local v_u_50 = Color3.fromRGB(50, 205, 50)
local v_u_51 = Color3.fromRGB(255, 80, 80)
local function v_u_53()
	-- upvalues: (copy) v_u_28
	for _, v52 in ipairs(v_u_28:GetChildren()) do
		if v52:IsA("Frame") then
			v52:Destroy()
		end
	end
end
local function v_u_69(p_u_54, p_u_55, p_u_56)
	-- upvalues: (copy) v_u_10, (copy) v_u_7, (copy) v_u_6
	local v57 = v_u_10.RARITIES[p_u_56]
	local v_u_58 = v57 and v57.color or Color3.new(1, 1, 1)
	local v59 = v_u_58.R * 255 + 0.5
	local v60 = math.floor(v59)
	local v61 = v_u_58.G * 255 + 0.5
	local v62 = math.floor(v61)
	local v63 = v_u_58.B * 255 + 0.5
	local v64 = math.floor(v63)
	local v65 = string.format("#%02X%02X%02X", v60, v62, v64)
	local v_u_66 = nil
	pcall(function()
		-- upvalues: (ref) v_u_7, (ref) v_u_66
		local v67 = v_u_7:FindFirstChild("TextChannels")
		if v67 then
			v_u_66 = v67:FindFirstChild("RBXGeneral")
		end
	end)
	local v68 = string.format("<b><font color=\"%s\">\226\152\133 %s unlocked %s [%s]!</font></b>", v65, p_u_54, p_u_55, p_u_56)
	if v_u_66 and v_u_66.DisplaySystemMessage then
		v_u_66:DisplaySystemMessage(v68)
	end
	pcall(function()
		-- upvalues: (ref) v_u_6, (copy) p_u_54, (copy) p_u_55, (copy) p_u_56, (copy) v_u_58
		v_u_6:SetCore("ChatMakeSystemMessage", {
			["Text"] = string.format("%s unlocked %s [%s]!", p_u_54, p_u_55, p_u_56),
			["Color"] = v_u_58,
			["Font"] = Enum.Font.SourceSansBold,
			["FontSize"] = Enum.FontSize.Size24
		})
	end)
end
v17.OnClientEvent:Connect(function(p70, p71, p72, _)
	-- upvalues: (copy) v_u_69
	v_u_69(p70, p71, p72)
end)
local function v_u_103(p73)
	-- upvalues: (copy) v_u_10
	local v74 = {}
	local v75 = 0
	for _, v76 in ipairs(p73.Items) do
		v74[v76.rarity] = true
	end
	for v77, v78 in pairs(v_u_10.RARITIES) do
		local v79 = v78.weight
		local v80 = tonumber(v79) or 0
		if v74[v77] and v80 > 0 then
			v75 = v75 + v80
		end
	end
	local v81 = {}
	for v82, v83 in pairs(v_u_10.RARITIES) do
		local v84 = v83.weight
		local v85 = tonumber(v84) or 0
		if v74[v82] and v85 > 0 then
			local v86 = {
				["name"] = v82,
				["w"] = v85,
				["color"] = v83.color,
				["order"] = v83.order or 999
			}
			table.insert(v81, v86)
		end
	end
	table.sort(v81, function(p87, p88)
		if p87.order == p88.order then
			return p87.name < p88.name
		else
			return p87.order < p88.order
		end
	end)
	local v89 = {}
	for _, v90 in ipairs(v81) do
		local v91
		if v75 > 0 then
			local v92 = v90.w / v75 * 1000 + 0.5
			v91 = math.floor(v92) / 10 or 0
		else
			v91 = 0
		end
		local v93 = v90.color
		local v94 = string.format
		local v95 = v93.R * 255 + 0.5
		local v96 = math.floor(v95)
		local v97 = v93.G * 255 + 0.5
		local v98 = math.floor(v97)
		local v99 = v93.B * 255 + 0.5
		local v100 = math.floor(v99)
		local v101 = v90.name
		local v102 = tostring(v91)
		table.insert(v89, v94("<font color=\"rgb(%d,%d,%d)\">%s: <b>%s%%</b></font>", v96, v98, v100, v101, v102))
	end
	return table.concat(v89, "<br/>")
end
local function v_u_106()
	-- upvalues: (copy) v_u_19, (ref) v_u_40
	local v104, v105 = pcall(function()
		-- upvalues: (ref) v_u_19
		return v_u_19:InvokeServer()
	end)
	if v104 and typeof(v105) == "table" then
		v_u_40 = v105
	else
		v_u_40 = {}
	end
end
local function v_u_111(p107, p108)
	-- upvalues: (copy) v_u_39, (ref) v_u_40, (copy) v_u_50, (copy) v_u_51
	local v109 = p107:FindFirstChild("STATUS")
	if v109 and v109:IsA("TextLabel") then
		local v110 = v_u_39[p108]
		if v110 and v110.type == "XP" then
			v109.Text = ""
			v109.Visible = true
		else
			if v_u_40[p108] then
				v109.Text = "Owned"
				v109.TextColor3 = v_u_50
			else
				v109.Text = "Not Owned"
				v109.TextColor3 = v_u_51
			end
			v109.Visible = true
			v109.TextTransparency = 0
		end
	else
		return
	end
end
local function v_u_123(p112)
	-- upvalues: (copy) v_u_10
	local v113 = {}
	for _, v114 in ipairs(p112.Items) do
		v113[v114.rarity] = true
	end
	local v115 = 0
	local v116 = {}
	for v117, v118 in pairs(v_u_10.RARITIES) do
		local v119 = v118.weight
		local v120 = tonumber(v119) or 0
		if v113[v117] and v120 > 0 then
			v115 = v115 + v120
			table.insert(v116, {
				["rarity"] = v117,
				["cum"] = v115
			})
		end
	end
	table.sort(v116, function(p121, p122)
		return p121.cum < p122.cum
	end)
	return v116, v115
end
local function v_u_128(p124, p125)
	-- upvalues: (copy) v_u_38
	if p125 <= 0 then
		return "Common"
	end
	local v126 = v_u_38:NextNumber(0, p125)
	for v127 = 1, #p124 do
		if v126 <= p124[v127].cum then
			return p124[v127].rarity
		end
	end
	return p124[#p124].rarity
end
local function v_u_134(p129, p130)
	-- upvalues: (copy) v_u_38
	local v131 = {}
	for _, v132 in ipairs(p129.Items) do
		if v132.rarity == p130 then
			table.insert(v131, v132)
		end
	end
	if #v131 == 0 then
		for _, v133 in ipairs(p129.Items) do
			table.insert(v131, v133)
		end
	end
	if #v131 == 0 then
		return nil
	else
		return v131[v_u_38:NextInteger(1, #v131)]
	end
end
local function v_u_148(p135)
	-- upvalues: (copy) v_u_10, (ref) v_u_41, (copy) v_u_23, (copy) v_u_103, (copy) v_u_106, (copy) v_u_34, (copy) v_u_111
	local v136 = v_u_10.CRATES[p135]
	if v136 then
		if v_u_41 ~= p135 then
			v_u_41 = p135
			v_u_23.CrateName.Text = p135
			v_u_23.CrateImage.Image = v136.Image or ""
			v_u_23.RaritiesText.RichText = true
			v_u_23.RaritiesText.Text = v_u_103(v136)
			v_u_106()
			for _, v137 in ipairs(v_u_23.ItemsList:GetChildren()) do
				if v137:IsA("Frame") then
					v137:Destroy()
				end
			end
			local v138 = table.clone(v136.Items)
			table.sort(v138, function(p139, p140)
				-- upvalues: (ref) v_u_10
				local v141 = v_u_10.RARITIES[p139.rarity] or {}
				local v142 = v_u_10.RARITIES[p140.rarity] or {}
				local v143 = v141.order or 999
				local v144 = v142.order or 999
				if v143 == v144 then
					return p139.name < p140.name
				else
					return v143 < v144
				end
			end)
			for _, v145 in ipairs(v138) do
				local v146 = v_u_34:Clone()
				v146.ItemName.Text = v145.name
				local v147 = v_u_10.RARITIES[v145.rarity] and v_u_10.RARITIES[v145.rarity].color or Color3.new(1, 1, 1)
				v146.ItemName.TextColor3 = v147
				v146.ItemImage.Image = v145.image or ""
				v146.Parent = v_u_23.ItemsList
				v_u_111(v146, v145.name)
			end
			v_u_23.Visible = true
		end
	else
		return
	end
end
local v149 = v_u_10.DEV_PRODUCTS.BuyRoll1
local v_u_150 = tonumber(v149) or 0
local v151 = v_u_10.DEV_PRODUCTS.BuyRoll2
local v_u_152 = tonumber(v151) or 0
local function v_u_155(p153)
	-- upvalues: (copy) v_u_25, (ref) v_u_43, (copy) v_u_21, (copy) v_u_24, (copy) v_u_53, (copy) v_u_27, (copy) v_u_26, (copy) v_u_5
	v_u_25.CrateName.Text = p153 or (v_u_43 or "")
	v_u_21.Visible = false
	v_u_25.Visible = true
	v_u_24.Enabled = true
	v_u_53()
	v_u_27.Visible = false
	v_u_26.Visible = true
	v_u_26.Text = "Skip Animation"
	local v154 = v_u_26
	v_u_26.BackgroundTransparency = 1
	v154.TextTransparency = 1
	v_u_5:Create(v_u_26, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		["BackgroundTransparency"] = 0,
		["TextTransparency"] = 0
	}):Play()
end
v32.MouseButton1Click:Connect(function()
	-- upvalues: (copy) v_u_23, (ref) v_u_41, (ref) v_u_43, (ref) v_u_44, (copy) v_u_18, (copy) v_u_150, (copy) v_u_3, (copy) v_u_8, (ref) v_u_42, (ref) v_u_47, (copy) v_u_12, (copy) v_u_155
	if v_u_23.Visible and v_u_41 then
		v_u_43 = v_u_41
		local v156 = v_u_43
		local v157
		if v_u_44 <= 0 then
			v_u_18:FireServer(tostring("You need more rolls."), (tostring("Red")))
			if v_u_150 > 0 then
				v_u_3:PromptProductPurchase(v_u_8, v_u_150)
				v157 = false
			else
				v157 = false
			end
		else
			v_u_42 = "ROLLING"
			v_u_47 = false
			v_u_12:FireServer(v156)
			v157 = true
		end
		if v157 then
			v_u_155(v_u_43)
		end
	end
end)
v_u_26.MouseButton1Click:Connect(function()
	-- upvalues: (ref) v_u_42, (ref) v_u_47
	if v_u_42 == "ROLLING" then
		v_u_47 = true
	end
end)
v_u_27.MouseButton1Click:Connect(function()
	-- upvalues: (ref) v_u_42, (ref) v_u_43, (ref) v_u_45, (copy) v_u_18, (ref) v_u_44, (copy) v_u_150, (copy) v_u_3, (copy) v_u_8, (ref) v_u_47, (copy) v_u_12, (copy) v_u_155
	if v_u_42 == "REVEALED" and v_u_43 then
		local v158 = os.clock()
		if v158 - v_u_45 < 0.9 then
			local v159 = 0.9 - (v158 - v_u_45)
			local v160 = v_u_18
			local v161 = string.format("Cooldown: %.2fs", (math.max(0, v159))) or ""
			v160:FireServer(tostring(v161), (tostring("Yellow")))
		else
			local v162 = v_u_43
			local v163
			if v_u_44 <= 0 then
				v_u_18:FireServer(tostring("You need more rolls."), (tostring("Red")))
				if v_u_150 > 0 then
					v_u_3:PromptProductPurchase(v_u_8, v_u_150)
					v163 = false
				else
					v163 = false
				end
			else
				v_u_42 = "ROLLING"
				v_u_47 = false
				v_u_12:FireServer(v162)
				v163 = true
			end
			if v163 then
				v_u_155(v_u_43)
			end
		end
	else
		return
	end
end)
v13.OnClientEvent:Connect(function(p164, p165, p166, p167, p168, p169, _)
	-- upvalues: (copy) v_u_10, (copy) v_u_25, (copy) v_u_155, (copy) v_u_53, (copy) v_u_38, (copy) v_u_123, (copy) v_u_128, (copy) v_u_134, (copy) v_u_35, (copy) v_u_28, (ref) v_u_42, (ref) v_u_47, (copy) v_u_36, (copy) v_u_4, (ref) v_u_45, (ref) v_u_40, (copy) v_u_23, (copy) v_u_111, (copy) v_u_37, (copy) v_u_16, (copy) v_u_5, (copy) v_u_26, (copy) v_u_27, (ref) v_u_46, (copy) v_u_24, (copy) v_u_21
	local v170 = v_u_10.CRATES[p164]
	if not v170 then
		return
	end
	if not v_u_25.Visible then
		v_u_155(p164)
	end
	v_u_53()
	local v171 = v_u_38:NextInteger(20, 100)
	local v172 = v_u_38
	local v173 = v171 - 5
	local v174 = v172:NextInteger(15, (math.max(16, v173)))
	local v175, v176 = v_u_123(v170)
	for v177 = 1, v171 do
		local v178, v179, v180
		if v177 == v174 then
			v178 = p166
			v179 = p165
			v180 = p167
		else
			local v181 = v_u_134(v170, (v_u_128(v175, v176)))
			if v181 then
				v179 = v181.name
				v178 = v181.rarity
				v180 = v181.image or ""
			else
				v180 = ""
				v179 = "???"
				v178 = "Common"
			end
		end
		local v182 = v_u_35:Clone()
		v182.ItemName.Text = v179
		local v183 = v_u_10.RARITIES[v178] and v_u_10.RARITIES[v178].color or Color3.new(1, 1, 1)
		v182.ItemName.TextColor3 = v183
		v182.ItemImage.Image = v180
		v182.Parent = v_u_28
	end
	v_u_28.Position = UDim2.new(0, 0, 0.5, 0)
	local v184 = v_u_35.Size.X.Scale
	local v185 = v_u_28.UIListLayout.Padding.Scale
	local v186 = 0.5 - v184 / 2
	local v187 = -v184 - v185
	local v188 = v186 + (v174 - 1) * v187
	local v189 = v_u_38:NextNumber(-v184 / 2, v184 / 2)
	local v190 = v188 + v189
	local v191 = os.clock()
	local v192 = v_u_38:NextNumber(2, 10)
	local v193 = 0
	while true do
		if true then
			local v194 = v_u_42 == "ROLLING" and not v_u_47 and ((os.clock() - v191) / p168 or 1) or 1
			local v195 = 1 - (1 - math.clamp(v194, 0, 1)) ^ v192
			local v196 = 0 + (v190 - 0) * v195
			local v197 = (v196 + v189) / v184
			local v198 = math.floor(v197)
			local v199 = math.abs(v198) + 1
			if v199 == v193 then
				v199 = v193
			elseif v_u_36 and v_u_36:IsA("Sound") then
				v_u_36:Play()
			end
		end
		v_u_28.Position = UDim2.new(v196, 0, 0.5, 0)
		if v194 >= 1 then
			v_u_42 = "REVEALED"
			v_u_45 = os.clock()
			if p169 == "unlocked" and p165 then
				v_u_40[p165] = true
				if v_u_23.Visible then
					for _, v200 in ipairs(v_u_23.ItemsList:GetChildren()) do
						if v200:IsA("Frame") then
							local v201 = v200:FindFirstChild("ItemName")
							if v201 and (v201:IsA("TextLabel") and v201.Text == p165) then
								v_u_111(v200, p165)
								break
							end
						end
					end
				end
			end
			if v_u_37 and v_u_37:IsA("Sound") then
				v_u_37:Play()
			end
			v_u_16:FireServer()
			v_u_5:Create(v_u_26, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				["TextTransparency"] = 1,
				["BackgroundTransparency"] = 1
			}):Play()
			v_u_26.Visible = false
			v_u_27.Visible = true
			local v202 = v_u_27
			v_u_27.BackgroundTransparency = 1
			v202.TextTransparency = 1
			v_u_5:Create(v_u_27, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				["TextTransparency"] = 0,
				["BackgroundTransparency"] = 0
			}):Play()
			local v_u_203 = os.clock()
			if v_u_46 then
				v_u_46:Disconnect()
			end
			v_u_46 = v_u_4.Heartbeat:Connect(function()
				-- upvalues: (ref) v_u_42, (copy) v_u_203, (ref) v_u_46, (ref) v_u_25, (ref) v_u_24, (ref) v_u_53, (ref) v_u_21
				if v_u_42 == "REVEALED" then
					if os.clock() - v_u_203 >= 3 then
						if v_u_46 then
							v_u_46:Disconnect()
							v_u_46 = nil
						end
						v_u_25.Visible = false
						v_u_24.Enabled = false
						v_u_53()
						v_u_21.Visible = true
						v_u_42 = "IDLE"
					end
				end
			end)
			return
		end
		v_u_4.Heartbeat:Wait()
		v193 = v199
	end
end)
v_u_106();
(function()
	-- upvalues: (copy) v_u_22, (copy) v_u_10, (copy) v_u_33, (copy) v_u_148
	for _, v204 in ipairs(v_u_22:GetChildren()) do
		if v204:IsA("Frame") or v204:IsA("TextButton") then
			v204:Destroy()
		end
	end
	local v205 = {}
	for v206 in pairs(v_u_10.CRATES) do
		table.insert(v205, v206)
	end
	table.sort(v205)
	for _, v_u_207 in ipairs(v205) do
		local v208 = v_u_10.CRATES[v_u_207]
		local v209 = v_u_33:Clone()
		v209.Name = v_u_207
		v209.CrateName.Text = v_u_207
		v209.CrateImage.Image = v208.Image or ""
		v209.MouseButton1Click:Connect(function()
			-- upvalues: (ref) v_u_148, (copy) v_u_207
			v_u_148(v_u_207)
		end)
		v209.Parent = v_u_22
	end
	if #v205 > 0 then
		v_u_148(v205[1])
	end
end)()
local v210, v211 = pcall(function()
	-- upvalues: (copy) v_u_15
	return v_u_15:InvokeServer()
end)
local v_u_212 = tonumber(v210 and v211 and v211 or 0) or 0
v_u_29.Text = string.format("%d Remaining Roll(s)", v_u_212)
v14.OnClientEvent:Connect(function(p213)
	-- upvalues: (ref) v_u_212, (copy) v_u_29
	v_u_212 = tonumber(p213) or 0
	v_u_29.Text = string.format("%d Remaining Roll(s)", v_u_212)
end)
v30.MouseButton1Click:Connect(function()
	-- upvalues: (copy) v_u_150, (copy) v_u_3, (copy) v_u_8, (copy) v_u_18
	if v_u_150 > 0 then
		v_u_3:PromptProductPurchase(v_u_8, v_u_150)
	else
		v_u_18:FireServer(tostring("BuyRoll1 is not set yet."), (tostring("Yellow")))
	end
end)
v31.MouseButton1Click:Connect(function()
	-- upvalues: (copy) v_u_152, (copy) v_u_3, (copy) v_u_8, (copy) v_u_18
	if v_u_152 > 0 then
		v_u_3:PromptProductPurchase(v_u_8, v_u_152)
	else
		v_u_18:FireServer(tostring("BuyRoll2 is not set yet."), (tostring("Yellow")))
	end
end)
local function v219(p214)
	local v215 = p214:FindFirstChild("ShineOverlay")
	if not v215 then
		v215 = Instance.new("Frame")
		v215.Name = "ShineOverlay"
		v215.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		v215.BackgroundTransparency = 0
		v215.Size = UDim2.fromScale(1, 1)
		v215.Position = UDim2.fromScale(0, 0)
		v215.BorderSizePixel = 0
		v215.ZIndex = (p214.ZIndex or 1) + 1
		v215.Parent = p214
		local v216 = Instance.new("UICorner")
		v216.CornerRadius = UDim.new(0, 5)
		v216.Parent = v215
	end
	local v217 = v215:FindFirstChildOfClass("UIGradient")
	if not v217 then
		v217 = Instance.new("UIGradient")
		v217.Name = "Shine"
		v217.Rotation = 20
		v217.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 180)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(180, 220, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 255, 210)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 200))
		})
		v217.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(0.45, 0.94),
			NumberSequenceKeypoint.new(0.5, 0.18),
			NumberSequenceKeypoint.new(0.55, 0.94),
			NumberSequenceKeypoint.new(1, 0.94)
		})
		v217.Offset = Vector2.new(-1, 0)
		local v218 = v215:FindFirstChild("ShineCorner") or Instance.new("UICorner")
		v218.Name = "ShineCorner"
		v218.CornerRadius = UDim.new(0, 5)
		v218.Parent = v215
		v217.Parent = v215
	end
	return v215, v217
end
local v_u_220, v_u_221 = v219(v32)
task.spawn(function()
	-- upvalues: (copy) v_u_220, (copy) v_u_221, (copy) v_u_5
	while v_u_220.Parent do
		v_u_221.Offset = Vector2.new(-1, 0)
		local v222 = v_u_5
		local v223 = v_u_221
		local v224 = TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local v225 = {
			["Offset"] = Vector2.new(1, 0)
		}
		v222:Create(v223, v224, v225):Play()
		task.wait(1.4)
		task.wait(0.3)
	end
end)
local v_u_226, v_u_227 = v219(v30)
task.spawn(function()
	-- upvalues: (copy) v_u_226, (copy) v_u_227, (copy) v_u_5
	while v_u_226.Parent do
		v_u_227.Offset = Vector2.new(-1, 0)
		local v228 = v_u_5
		local v229 = v_u_227
		local v230 = TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local v231 = {
			["Offset"] = Vector2.new(1, 0)
		}
		v228:Create(v229, v230, v231):Play()
		task.wait(1.4)
		task.wait(0.3)
	end
end)
local v_u_232, v_u_233 = v219(v31)
task.spawn(function()
	-- upvalues: (copy) v_u_232, (copy) v_u_233, (copy) v_u_5
	while v_u_232.Parent do
		v_u_233.Offset = Vector2.new(-1, 0)
		local v234 = v_u_5
		local v235 = v_u_233
		local v236 = TweenInfo.new(1.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		local v237 = {
			["Offset"] = Vector2.new(1, 0)
		}
		v234:Create(v235, v236, v237):Play()
		task.wait(1.4)
		task.wait(0.3)
	end
end)

-- Calling function info
-- Generated by the SimpleSpy V3 serializer

local functionInfo = {
    ["script"] = {
        ["SourceScript"] = "nil",
        ["CallingScript"] = game:GetService("Players").LocalPlayer.CratesClient
    },
    ["upvalues"] = {
        [1] = debug.info
    },
    ["info"] = {
        ["source"] = "",
        ["what"] = "Lua",
        ["numparams"] = 2,
        ["func"] = function safeDebugInfo() end -- Function Called: safeDebugInfo,
        ["short_src"] = "[string \"\"]",
        ["name"] = "safeDebugInfo",
        ["currentline"] = 52,
        ["nups"] = 1,
        ["linedefined"] = 52,
        ["is_vararg"] = 0
    },
    ["constants"] = {
        [1] = "pcall"
    }
}


