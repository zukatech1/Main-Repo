local script = game:GetService("Folder").ClientMover
local v_u_1 = script.Parent:FindFirstChild("ADONIS_DEBUGMODE_ENABLED", true) ~= nil
local v_u_2 = task.wait
local v_u_3 = time
local v_u_4 = pcall
local v_u_5 = xpcall
local v_u_6 = setfenv
local v_u_7 = tostring
local v_u_8 = game
local v_u_9 = task.spawn
local v_u_10 = require
local v_u_11 = task.wait
local v_u_12 = v_u_8:FindFirstChildWhichIsA("Players") or v_u_8:FindService("Players")
local v_u_13 = v_u_12.LocalPlayer
local v_u_14 = false
local function v_u_16(p15)
	-- upvalues: (copy) v_u_13, (copy) v_u_12
	(v_u_13 or v_u_12.LocalPlayer):Kick((("[ACLI-0x6E2FA164] Loading Error [Environment integrity violation error: %*]"):format(p15)))
	while true do

	end
end
local v_u_17 = newproxy(true)
local v18 = getmetatable(v_u_17)
function v18.__index()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0xEC7E1")
	return task.wait(200)
end
function v18.__newindex()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x28AEC")
	return task.wait(200)
end
function v18.__tostring()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x36F14")
	return task.wait(200)
end
function v18.__unm()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x50B7F")
	return task.wait(200)
end
function v18.__add()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0xCD67D")
	return task.wait(200)
end
function v18.__sub()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x8110D")
	return task.wait(200)
end
function v18.__mul()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x6A01B")
	return task.wait(200)
end
function v18.__div()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x5A975")
	return task.wait(200)
end
function v18.__mod()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x6CFEB")
	return task.wait(200)
end
function v18.__pow()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x20A50")
	return task.wait(200)
end
function v18.__len()
	-- upvalues: (copy) v_u_16
	v_u_16("Proxy methamethod 0x3B96C")
	return task.wait(200)
end
v18.__metatable = "The metatable is locked"
v_u_9(v_u_5, function()
	-- upvalues: (copy) v_u_8, (copy) v_u_4, (copy) v_u_10, (copy) v_u_9, (copy) v_u_5, (copy) v_u_16, (copy) v_u_17, (ref) v_u_14
	local v19 = v_u_8:GetService("Workspace") or v_u_8:GetService("ReplicatedStorage")
	local v20, v_u_21 = v_u_4(v_u_10, v_u_8)
	if v19 then
		if v20 or not string.match(v_u_21, "^Attempted to call require with invalid argument%(s%)%.$") then
			v_u_9(v_u_5, function()
				-- upvalues: (ref) v_u_16, (copy) v_u_21
				v_u_16((("Require load fail. %*"):format(v_u_21)))
			end, function(p22)
				-- upvalues: (ref) v_u_16
				v_u_16(p22)
			end)
			while true do

			end
		else
			task.spawn(v_u_4, v_u_10, v_u_17)
			v_u_14 = true
			return
		end
	else
		v_u_9(v_u_5, function()
			-- upvalues: (ref) v_u_16
			v_u_16("Service not returning")
		end, function(p23)
			-- upvalues: (ref) v_u_16
			v_u_16(p23)
		end)
		while true do

		end
	end
end, function(p24)
	-- upvalues: (copy) v_u_9, (copy) v_u_16
	v_u_9(v_u_16, p24)
	while true do

	end
end)
v_u_9(v_u_5, function()
	-- upvalues: (copy) v_u_11, (ref) v_u_14, (copy) v_u_9, (copy) v_u_5, (copy) v_u_16
	v_u_11()
	v_u_11()
	if v_u_14 then
		return
	else
		v_u_9(v_u_5, function()
			-- upvalues: (ref) v_u_16, (ref) v_u_14
			v_u_16((("Loading detectors failed to load%*"):format(v_u_14)))
		end, function(p25)
			-- upvalues: (ref) v_u_16
			v_u_16(p25)
		end)
		while true do

		end
	end
end, function(p26)
	-- upvalues: (copy) v_u_9, (copy) v_u_16
	v_u_9(v_u_16, p26)
	while true do

	end
end)
local v_u_27 = game:GetService("Players").LocalPlayer
local v28 = script.Parent
local v29 = v28:WaitForChild("Client")
local v30 = v28.Parent
local v_u_31 = v_u_27.Kick
local v32 = v29:WaitForChild("Client")
local v_u_33 = print
local v_u_34 = warn
local v_u_35 = v_u_3()
local v_u_36 = {}
local function v_u_41(...)
	-- upvalues: (copy) v_u_1, (copy) v_u_27, (copy) v_u_33, (copy) v_u_36, (copy) v_u_4
	if v_u_1 or v_u_27.UserId == 1237666 then
		v_u_33("ACLI:", ...)
	end
	local v37 = v_u_36
	local v38 = select
	local v39 = v_u_4
	local v40 = table.concat
	table.insert(v37, v38(2, v39(v40, { "ACLI:", ... }, " ")))
end
local function v_u_46(...)
	-- upvalues: (copy) v_u_34, (copy) v_u_36, (copy) v_u_4
	v_u_34("ACLI:", ...)
	local v42 = v_u_36
	local v43 = select
	local v44 = v_u_4
	local v45 = table.concat
	table.insert(v42, v43(2, v44(v45, { "ACLI WARNING:", ... }, " ")))
end
local function v_u_48(p_u_47)
	-- upvalues: (copy) v_u_1, (copy) v_u_46, (copy) v_u_4, (copy) v_u_31, (copy) v_u_27, (copy) v_u_2
	if v_u_1 then
		v_u_46(p_u_47)
	else
		v_u_4(function()
			-- upvalues: (ref) v_u_31, (ref) v_u_27, (copy) p_u_47
			v_u_31(v_u_27, p_u_47)
		end)
		v_u_2(1)
		v_u_4(function()
			-- upvalues: (ref) v_u_1, (ref) v_u_2, (ref) v_u_4
			while not v_u_1 and v_u_2() do
				v_u_4(function()
					while true do

					end
				end)
			end
		end)
	end
end
local function v_u_50(p_u_49)
	-- upvalues: (copy) v_u_4
	return not p_u_49 and true or not v_u_4(function()
		-- upvalues: (copy) p_u_49
		return p_u_49.GetFullName(p_u_49)
	end)
end
local function v51()
	-- upvalues: (copy) v_u_6, (copy) v_u_41, (copy) v_u_3, (copy) v_u_35, (copy) v_u_7
	v_u_6(1, {})
	v_u_41("LoadingTime Called:", (v_u_7(v_u_3() - v_u_35)))
end
local function v53(p_u_52)
	-- upvalues: (copy) v_u_41, (copy) v_u_50, (copy) v_u_46, (copy) v_u_48, (copy) v_u_5
	v_u_41((("CallCheck: %*"):format(p_u_52)))
	if v_u_50(p_u_52) then
		v_u_46("Child locked?")
		v_u_48("[ACLI-0x213A7768D]: Locked")
	else
		v_u_41("Child not locked")
		v_u_5(function()
			-- upvalues: (copy) p_u_52
			return p_u_52[{}]
		end, function()
			-- upvalues: (ref) v_u_48
			if getfenv(1) ~= getfenv(2) then
				v_u_48("[ACLI-0xBC34ADD8]: Check caller error")
			end
		end)
	end
end
if v32 and v32:IsA("ModuleScript") then
	v_u_41("Loading Folder...")
	v_u_41("Waiting for Client & Special")
	local v54 = v29:WaitForChild("Special", 30)
	v_u_41("Checking Client & Special")
	v_u_41("Getting origName")
	local v55 = v54 and v54.Value or v29.Name
	v_u_41((("Got name: %*"):format(v55)))
	v_u_41("Removing old client folder...")
	local v56 = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterPlayerScripts"):FindFirstChild(v29.Name)
	v_u_41((("FOUND?! %*"):format(v56)))
	v_u_41((("LOOKED FOR : %*"):format(v29.Name)))
	if v56 then
		v_u_46("REMOVED!")
		v56.Parent = nil
	end
	v_u_41("Changing child parent...")
	v28.Name = ""
	v_u_2(0.01)
	v28.Parent = nil
	v_u_41("Debug: Loading the client?")
	local v57, v58 = v_u_4(require, v32)
	v_u_41((("Got metatable: %*"):format(v58)))
	if not v57 then
		v_u_48((("[ACLI-0x20D21CEE7]: Loading Error [Module failed to load due to %*]"):format(v58)))
		return
	end
	if v58 and (type(v58) == "userdata" and v_u_7(v58) == "Adonis") then
		local _, v59 = v_u_4(v58, {
			["Module"] = v32,
			["Start"] = v_u_35,
			["Loader"] = script,
			["Name"] = v55,
			["Folder"] = v29,
			["LoadingTime"] = v51,
			["CallCheck"] = v53,
			["Kill"] = v_u_48,
			["acliLogs"] = v_u_36
		})
		v_u_41((("Got return: %*"):format(v59)))
		if v59 ~= "SUCCESS" then
			v_u_46("Loading failed! Reason", v59)
			v_u_48("[ACLI-0x102134B1E]: Loading Error [Bad Module Return]")
			return
		end
		v_u_41("Debug: The client was found and loaded?")
		if v30 and v30:IsA("ScreenGui") then
			v30.Parent = nil
			return
		end
	else
		v_u_46((("Invalid metatable: %*!"):format(v58)))
		v_u_48("[ACLI-0xCE8CEF67]: Loading Error [Bad Module Return]")
	end
end


-- Calling function info
-- Generated by the SimpleSpy V3 serializer

local functionInfo = {
    ["script"] = {
        ["SourceScript"] = "nil",
        ["CallingScript"] = game:GetService("Folder").ClientMover
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

