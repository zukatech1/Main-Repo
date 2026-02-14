local script = game:GetService("Players").LocalPlayer.ClientGiftsV9
local v1 = game:GetService("Players")
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = game:GetService("TweenService")
local v4 = game:GetService("RunService")
local v_u_5 = v1.LocalPlayer
repeat
	task.wait()
until v_u_5:FindFirstChild("LoadedGifts")
local v6 = v2:WaitForChild("GiftFolder")
local v7 = v6:WaitForChild("GetData")
local v8 = v6:WaitForChild("GetAssignments")
local v_u_9 = v6:WaitForChild("ClaimGift")
local v10 = require(v6:WaitForChild("SharedGiftData"))
local v11 = script.Parent:WaitForChild("Frame")
local v_u_12 = v11:WaitForChild("List")
local v_u_13 = v11:WaitForChild("RefreshIn")
local v_u_14 = script:WaitForChild("Template")
local v_u_15 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v_u_16 = v_u_5:FindFirstChild("ClaimedGifts") or v_u_5:WaitForChild("ClaimedGifts", 8)
local v_u_17, v_u_18 = v7:InvokeServer()
local v19 = v8:InvokeServer()
local v_u_20 = {}
local v_u_21 = {}
local function v_u_23(p22)
	return string.format("%02d", p22)
end
local function v_u_33(p24)
	-- upvalues: (copy) v_u_23
	local v25 = math.floor(p24)
	local v26 = math.max(0, v25)
	local v27 = v26 / 3600
	local v28 = math.floor(v27)
	local v29 = v26 - v28 * 3600
	local v30 = v29 / 60
	local v31 = math.floor(v30)
	local v32 = v29 - v31 * 60
	if v28 > 0 then
		return string.format("%s:%s:%s", string.format("%02d", v28), string.format("%02d", v31), v_u_23(v32))
	else
		return string.format("%s:%s", string.format("%02d", v31), v_u_23(v32))
	end
end
local function v47(p_u_34, p35)
	-- upvalues: (copy) v_u_14, (copy) v_u_20, (copy) v_u_17, (copy) v_u_5, (ref) v_u_16, (copy) v_u_9, (copy) v_u_33, (copy) v_u_21, (copy) v_u_3, (copy) v_u_15, (copy) v_u_12
	local v_u_36 = v_u_14:Clone()
	v_u_36.Name = tostring(p_u_34)
	v_u_36.LayoutOrder = p_u_34
	v_u_36.Button.Image = p35.Image or v_u_36.Button.Image
	v_u_36.Info.Text = p35.Info or "Gift " .. p_u_34
	v_u_20[p_u_34] = v_u_36
	local v37 = v_u_17 + (v_u_5.CurrentSession and v_u_5.CurrentSession.Value or 0)
	local v38 = (p35.Time or 0) - v37
	local v39 = math.max(0, v38)
	if v39 <= 0 then
		local v40
		if v_u_16 then
			v40 = v_u_16:FindFirstChild((tostring(p_u_34))) ~= nil
		else
			v40 = false
		end
		if v40 then
			v_u_36.TextLabel.Text = "Claimed"
			v_u_36.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			v_u_36.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
		else
			v_u_36.TextLabel.Text = "READY"
			v_u_36.TextLabel.TextColor3 = Color3.fromRGB(47, 255, 61)
			v_u_36.Button.ImageColor3 = Color3.fromRGB(47, 255, 61)
			local v41
			if v_u_16 then
				v41 = v_u_16:FindFirstChild((tostring(p_u_34))) ~= nil
			else
				v41 = false
			end
			if not v41 then
				local v42 = v_u_36.Button
				local v_u_43 = false
				v42.Activated:Connect(function()
					-- upvalues: (ref) v_u_43, (ref) v_u_9, (copy) p_u_34, (copy) v_u_36
					if not v_u_43 then
						v_u_43 = true
						if v_u_9:InvokeServer(p_u_34) then
							local v44 = v_u_36
							v44.TextLabel.Text = "Claimed"
							v44.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
							v44.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
						end
						task.delay(0.1, function()
							-- upvalues: (ref) v_u_43
							v_u_43 = false
						end)
					end
				end)
			end
		end
	else
		v_u_36.TextLabel.Text = v_u_33(v39)
		local v45 = v_u_21
		local v46 = {
			["obj"] = v_u_36,
			["req"] = p35.Time or 0,
			["giftNumber"] = p_u_34
		}
		table.insert(v45, v46)
	end
	v_u_36.Button.MouseEnter:Connect(function()
		-- upvalues: (ref) v_u_3, (copy) v_u_36, (ref) v_u_15
		v_u_3:Create(v_u_36.Button, v_u_15, {
			["Position"] = UDim2.new(0.5, 0, 0.3, 0),
			["ImageColor3"] = Color3.fromRGB(220, 220, 220)
		}):Play()
	end)
	v_u_36.Button.MouseLeave:Connect(function()
		-- upvalues: (ref) v_u_3, (copy) v_u_36, (ref) v_u_15
		v_u_3:Create(v_u_36.Button, v_u_15, {
			["Position"] = UDim2.new(0.5, 0, 0.4, 0),
			["ImageColor3"] = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)
	v_u_36.Parent = v_u_12
end
for v48 = 1, v10.MaxGiftNumber do
	local v49 = v19[v48]
	if v49 then
		local v50 = v10.getVariant(v48, v49)
		if v50 then
			v47(v48, v50)
		end
	end
end
if v_u_16 then
	for _, v51 in ipairs(v_u_16:GetChildren()) do
		local v52 = v51.Name
		local v53 = tonumber(v52)
		if v53 then
			v53 = v_u_20[v53]
		end
		if v53 then
			v53.TextLabel.Text = "Claimed"
			v53.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			v53.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
		end
	end
	v_u_16.ChildAdded:Connect(function(p54)
		-- upvalues: (copy) v_u_20
		local v55 = p54.Name
		local v56 = tonumber(v55)
		if v56 then
			local v57 = v_u_20[v56]
			if v57 then
				v57.TextLabel.Text = "Claimed"
				v57.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				v57.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
			end
		end
	end)
end
v4.Heartbeat:Connect(function()
	-- upvalues: (copy) v_u_17, (copy) v_u_5, (copy) v_u_21, (ref) v_u_16, (copy) v_u_9, (copy) v_u_33, (copy) v_u_18, (copy) v_u_13
	local v58 = v_u_17 + (v_u_5.CurrentSession and v_u_5.CurrentSession.Value or 0)
	local v59 = 1
	while v59 <= #v_u_21 do
		local v60 = v_u_21[v59]
		local v_u_61 = v60.obj
		local v62 = v60.req
		local v_u_63 = v60.giftNumber
		local v64 = v62 - v58
		local v65 = math.max(0, v64)
		if v65 <= 0 then
			local v66
			if v_u_16 then
				v66 = v_u_16:FindFirstChild((tostring(v_u_63))) ~= nil
			else
				v66 = false
			end
			if v66 then
				v_u_61.TextLabel.Text = "Claimed"
				v_u_61.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				v_u_61.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
			else
				v_u_61.TextLabel.Text = "READY"
				v_u_61.TextLabel.TextColor3 = Color3.fromRGB(47, 255, 61)
				v_u_61.Button.ImageColor3 = Color3.fromRGB(47, 255, 61)
				local v67
				if v_u_16 then
					v67 = v_u_16:FindFirstChild((tostring(v_u_63))) ~= nil
				else
					v67 = false
				end
				if not v67 then
					local v68 = v_u_61.Button
					local v_u_69 = false
					v68.Activated:Connect(function()
						-- upvalues: (ref) v_u_69, (ref) v_u_9, (copy) v_u_63, (copy) v_u_61
						if not v_u_69 then
							v_u_69 = true
							if v_u_9:InvokeServer(v_u_63) then
								local v70 = v_u_61
								v70.TextLabel.Text = "Claimed"
								v70.TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
								v70.Button.ImageColor3 = Color3.fromRGB(61, 164, 255)
							end
							task.delay(0.1, function()
								-- upvalues: (ref) v_u_69
								v_u_69 = false
							end)
						end
					end)
				end
			end
			table.remove(v_u_21, v59)
		else
			v_u_61.TextLabel.Text = v_u_33(v65)
			v59 = v59 + 1
		end
	end
	local v71 = v_u_18 - os.time()
	v_u_13.Text = "Refresh in: " .. v_u_33((math.max(0, v71)))
end)
-- Calling function info
-- Generated by the SimpleSpy V3 serializer

local functionInfo = {
    ["script"] = {
        ["SourceScript"] = "nil",
        ["CallingScript"] = game:GetService("Players").LocalPlayer.ClientGiftsV9
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

