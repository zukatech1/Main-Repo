client = nil
service = nil
Pcall = nil
Routine = nil
GetEnv = nil
origEnv = nil
logError = nil
return function(_, p1)
	local v2 = p1(nil, {
		["script"] = script
	})
	setfenv(1, v2)
	local _ = _G
	local v3 = game
	local _ = script
	local v4 = getfenv
	local _ = setfenv
	local v_u_5 = workspace
	local v6 = getmetatable
	local v7 = setmetatable
	local _ = loadstring
	local v_u_8 = coroutine
	local v_u_9 = rawequal
	local _ = typeof
	local _ = print
	local _ = math
	local v_u_10 = warn
	local _ = error
	local v_u_11 = pcall
	local v_u_12 = xpcall
	local v13 = select
	local _ = rawset
	local _ = rawget
	local _ = ipairs
	local _ = pairs
	local _ = next
	local _ = Rect
	local _ = Axes
	local _ = os
	local v14 = time
	local _ = Faces
	local _ = unpack
	local v_u_15 = string
	local _ = Color3
	local v16 = newproxy
	local v_u_17 = tostring
	local _ = tonumber
	local v18 = Instance
	local _ = TweenInfo
	local _ = BrickColor
	local _ = NumberRange
	local _ = ColorSequence
	local _ = NumberSequence
	local _ = ColorSequenceKeypoint
	local _ = NumberSequenceKeypoint
	local _ = PhysicalProperties
	local _ = Region3int16
	local _ = Vector3int16
	local _ = require
	local v19 = table
	local v_u_20 = type
	local _ = wait
	local v_u_21 = Enum
	local _ = UDim
	local _ = UDim2
	local _ = Vector2
	local _ = Vector3
	local _ = Region3
	local _ = CFrame
	local _ = Ray
	local _ = delay
	local v_u_22 = nil
	local v_u_23 = nil
	local v_u_24 = nil
	local v_u_25 = nil
	local v_u_26 = v2.service
	local v_u_27 = v2.client
	local v_u_28 = v_u_27.Core
	local v_u_29 = v_u_27.Remote
	local v_u_30 = v_u_27.Functions
	local v_u_31 = v_u_27.Disconnect
	local v_u_32 = v_u_27.Remote.Send
	local v_u_33 = v_u_27.Remote.Get
	local v_u_34 = v_u_26.NetworkClient
	local v_u_35 = v_u_27.Kill
	local v_u_36 = v_u_26.Players.LocalPlayer
	local v_u_37 = v13(2, v_u_11(v_u_26.RunService.IsStudio, v_u_26.RunService))
	local v_u_38 = v_u_36.Kick
	local v_u_39 = v_u_26.GuiService:IsTenFootInterface()
	local v_u_40 = v_u_26.UserInputService.TouchEnabled and not v_u_26.UserInputService.KeyboardEnabled
	if v_u_40 then
		v_u_40 = not v_u_26.UserInputService.MouseEnabled
	end
	v4().client = nil
	v4().service = nil
	v4().script = nil
	local function v_u_44(p41, p42, p43)
		-- upvalues: (copy) v_u_34, (copy) v_u_11, (copy) v_u_32, (copy) v_u_17, (copy) v_u_39, (copy) v_u_40, (copy) v_u_37, (copy) v_u_36, (copy) v_u_31, (copy) v_u_35
		if v_u_34 and p41 ~= "_" then
			v_u_11(v_u_32, "Detected", p41, v_u_17(p42) .. (v_u_39 and " - On Xbox" or (v_u_40 and " - On mobile" or "")))
			task.wait(0.5)
			if p41 == "kick" and not v_u_37 then
				if p43 then
					v_u_36:Kick(":" .. ":" .. " " .. "A" .. "d" .. "o" .. "n" .. "i" .. "s" .. " " .. "A" .. "n" .. "t" .. "i" .. " " .. "C" .. "h" .. "e" .. "a" .. "t" .. ":" .. ":" .. "\n" .. v_u_17(p42))
				else
					v_u_31(p42)
				end
			elseif p41 == "crash" and not v_u_37 then
				v_u_35(p42)
			end
		end
		return true
	end
	local v_u_45 = nil
	local v_u_46 = nil
	local v_u_47 = nil
	task.spawn(v_u_12, function()
		-- upvalues: (ref) v_u_45, (ref) v_u_46, (ref) v_u_47, (copy) v_u_44
		local v48, v49, v50 = debug.info(v_u_44, "nsl")
		v_u_45 = v48
		v_u_46 = v49
		v_u_47 = v50
	end, function()
		-- upvalues: (copy) v_u_44, (copy) v_u_11, (copy) v_u_31, (copy) v_u_35, (copy) v_u_38, (copy) v_u_36
		v_u_44("crash", "Tamper Protection 0xCCD44")
		task.wait(1)
		v_u_11(v_u_31, "Adonis_0xCCD44")
		v_u_11(v_u_35, "Adonis_0xCCD44")
		v_u_11(v_u_38, v_u_36, "Adonis_0xCCD44")
	end)
	local function v_u_54(p51, p52)
		-- upvalues: (copy) v_u_26, (copy) v_u_9
		if v_u_26.CountTable(p51) ~= v_u_26.CountTable(p52) then
			return false
		end
		for v53, _ in p51 do
			if not v_u_9(p51[v53], p52[v53]) then
				return false
			end
		end
		return true
	end
	local v_u_55 = v16(true)
	local v56 = v6(v_u_55)
	function v56.__index()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x215F")
		return task.wait(200)
	end
	function v56.__newindex()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x86F1")
		return task.wait(200)
	end
	function v56.__tostring()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0xC0BD0")
		return task.wait(200)
	end
	function v56.__unm()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x10F00")
		return task.wait(200)
	end
	function v56.__add()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x60DC3")
		return task.wait(200)
	end
	function v56.__sub()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x90F5D")
		return task.wait(200)
	end
	function v56.__mul()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x19999")
		return task.wait(200)
	end
	function v56.__div()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x1D14AC")
		return task.wait(200)
	end
	function v56.__mod()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x786C64")
		return task.wait(200)
	end
	function v56.__pow()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0x1D948C")
		return task.wait(200)
	end
	function v56.__len()
		-- upvalues: (copy) v_u_44
		v_u_44("kick", "Proxy metaMethod 0xBE931")
		return task.wait(200)
	end
	v56.__metatable = "The metatable is locked"
	local v_u_57 = v19.freeze({
		["indexInstance"] = {},
		["newindexInstance"] = {},
		["namecallInstance"] = {},
		["indexEnum"] = {},
		["namecallEnum"] = {},
		["eqEnum"] = {}
	})
	local v_u_58 = {}
	local v_u_59 = v_u_26.UnWrap(v3)
	local function v_u_64(p60)
		-- upvalues: (copy) v_u_57
		local v61 = #v_u_57[p60] <= 0
		for v62 = 3, 4 do
			local v63 = debug.info(v62, "f")
			if v61 then
				v_u_57[p60][v62] = v63
			elseif v_u_57[p60][v62] ~= v63 then
				return true
			end
		end
		return false
	end
	local function v_u_66(p65)
		-- upvalues: (copy) v_u_20
		return p65 and (v_u_20(p65) == "function" and (debug.info(p65, "s") == "[C]" and (debug.info(p65, "l") == -1 and (debug.info(p65, "n") == "" and debug.info(p65, "a") == 0)))) and true or false
	end
	local v_u_108 = v19.freeze({
		["indexInstance"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_12, (copy) v_u_59, (copy) v_u_64, (copy) v_u_66, (copy) v_u_11, (copy) v_u_55, (copy) v_u_58, (copy) v_u_54
				local v_u_67 = false
				local v_u_68 = nil
				local v69, v70 = v_u_12(function()
					-- upvalues: (ref) v_u_59
					local _ = v_u_59.____________
				end, function()
					-- upvalues: (ref) v_u_68, (ref) v_u_67, (ref) v_u_64
					v_u_68 = debug.info(2, "f")
					if v_u_67 or v_u_64("indexInstance") then
						v_u_67 = true
					end
				end)
				if not v_u_66(v_u_68) then
					return true
				end
				local v71, v72 = v_u_11(v_u_68, v_u_59)
				local v73, v74 = v_u_11(v_u_68)
				v_u_11(v_u_68, v_u_55, "GetChildren")
				v_u_11(v_u_68, v_u_55)
				v_u_11(v_u_68, v_u_59, v_u_55)
				if v_u_67 or (v69 or (v73 or v71)) then
					return true
				end
				if not v_u_58.indexInstance then
					v_u_58.indexInstance = { v70, v74, v72 }
				end
				return not v_u_54(v_u_58.indexInstance, { v70, v74, v72 })
			end }),
		["newindexInstance"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_12, (copy) v_u_59, (copy) v_u_64, (copy) v_u_66, (copy) v_u_11, (copy) v_u_55, (copy) v_u_58, (copy) v_u_54
				local v_u_75 = false
				local v_u_76 = nil
				local v77, v78 = v_u_12(function()
					-- upvalues: (ref) v_u_59
					v_u_59.____________ = 5
				end, function()
					-- upvalues: (ref) v_u_76, (ref) v_u_75, (ref) v_u_64
					v_u_76 = debug.info(2, "f")
					if v_u_75 or v_u_64("newindexInstance") then
						v_u_75 = true
					end
				end)
				if not v_u_66(v_u_76) then
					return true
				end
				local v79, v80 = v_u_11(v_u_76, v_u_59)
				local v81, v82 = v_u_11(v_u_76)
				v_u_11(v_u_76, v_u_55, "GetChildren")
				v_u_11(v_u_76, v_u_55)
				v_u_11(v_u_76, v_u_59, v_u_55)
				v_u_11(v_u_76, v_u_59, "AllowThirdPartySales", v_u_55)
				if v_u_75 or (v77 or (v81 or v79)) then
					return true
				end
				if not v_u_58.newindexInstance then
					v_u_58.newindexInstance = { v78, v82, v80 }
				end
				return not v_u_54(v_u_58.newindexInstance, { v78, v82, v80 })
			end }),
		["namecallInstance"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_12, (copy) v_u_59, (copy) v_u_64, (copy) v_u_66, (copy) v_u_11, (copy) v_u_55, (copy) v_u_37, (copy) v_u_58, (copy) v_u_54
				local v_u_83 = false
				local v_u_84 = nil
				local v85, v86 = v_u_12(function()
					-- upvalues: (ref) v_u_59
					v_u_59:____________()
				end, function()
					-- upvalues: (ref) v_u_84, (ref) v_u_83, (ref) v_u_64
					v_u_84 = debug.info(2, "f")
					if v_u_83 or v_u_64("namecallInstance") then
						v_u_83 = true
					end
				end)
				if not v_u_66(v_u_84) then
					return true
				end
				local v87, v88 = v_u_11(v_u_84, v_u_59)
				local v89, v90 = v_u_11(v_u_84)
				v_u_11(v_u_84, v_u_55)
				v_u_11(v_u_84, v_u_59, v_u_55)
				if v_u_83 or (v85 or (v89 or v87)) then
					return not v_u_37
				end
				if not v_u_58.namecallInstance then
					v_u_58.namecallInstance = { v86, v90, v88 }
				end
				local v91 = not v_u_54(v_u_58.namecallInstance, { v86, v90, v88 })
				if v91 then
					v91 = not v_u_37
				end
				return v91
			end }),
		["indexEnum"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_12, (copy) v_u_21, (copy) v_u_64, (copy) v_u_66, (copy) v_u_11, (copy) v_u_55, (copy) v_u_58, (copy) v_u_54
				local v_u_92 = false
				local v_u_93 = nil
				local v94, v95 = v_u_12(function()
					-- upvalues: (ref) v_u_21
					local _ = v_u_21.HumanoidStateType.____________
				end, function()
					-- upvalues: (ref) v_u_93, (ref) v_u_92, (ref) v_u_64
					v_u_93 = debug.info(2, "f")
					if v_u_92 or v_u_64("indexEnum") then
						v_u_92 = true
					end
				end)
				if not v_u_66(v_u_93) then
					return true
				end
				local v96, v97 = v_u_11(v_u_93, v_u_21.HumanoidStateType)
				local v98, v99 = v_u_11(v_u_93)
				v_u_11(v_u_93, v_u_55, "Name")
				v_u_11(v_u_93, v_u_55)
				v_u_11(v_u_93, v_u_21.HumanoidStateType, v_u_55)
				if v_u_92 or (v94 or (v98 or v96)) then
					return true
				end
				if not v_u_58.indexEnum then
					v_u_58.indexEnum = { v95, v99, v97 }
				end
				return not v_u_54(v_u_58.indexEnum, { v95, v99, v97 })
			end }),
		["namecallEnum"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_12, (copy) v_u_21, (copy) v_u_64, (copy) v_u_66, (copy) v_u_11, (copy) v_u_55, (copy) v_u_58, (copy) v_u_54
				local v_u_100 = false
				local v_u_101 = nil
				local v102, v103 = v_u_12(function()
					-- upvalues: (ref) v_u_21
					v_u_21.HumanoidStateType:____________()
				end, function()
					-- upvalues: (ref) v_u_101, (ref) v_u_100, (ref) v_u_64
					v_u_101 = debug.info(2, "f")
					if v_u_100 or v_u_64("namecallEnum") then
						v_u_100 = true
					end
				end)
				if not v_u_66(v_u_101) then
					return true
				end
				local v104, v105 = v_u_11(v_u_101, v_u_21.HumanoidStateType)
				local v106, v107 = v_u_11(v_u_101)
				v_u_11(v_u_101, v_u_55)
				v_u_11(v_u_101, v_u_21.HumanoidStateType, v_u_55)
				if v_u_100 or (v102 or (v106 or v104)) then
					return true
				end
				if not v_u_58.namecallEnum then
					v_u_58.namecallEnum = { v103, v107, v105 }
				end
				return not v_u_54(v_u_58.namecallEnum, { v103, v107, v105 })
			end }),
		["eqEnum"] = v19.freeze({ "kick", function()
				-- upvalues: (copy) v_u_21
				return v_u_21.HumanoidStateType.Running ~= v_u_21.HumanoidStateType.Running
			end })
	})
	local v_u_109 = v_u_26.UnWrap(v18.new("RemoteEvent"))
	local v_u_110 = v_u_26.UnWrap(v18.new("RemoteFunction"))
	local v_u_111 = v_u_26.UnWrap(v_u_26.LogService)
	local v_u_112 = v7({}, {
		["__mode"] = "k"
	})
	v_u_26.UnWrap(v_u_26.Players).ChildRemoved:Connect(function(p113)
		-- upvalues: (copy) v_u_112
		if p113:IsA("Player") then
			v_u_112[p113] = true
		end
	end)
	Routine(function()
		-- upvalues: (copy) v_u_44, (ref) v_u_46, (ref) v_u_47, (ref) v_u_45, (copy) v_u_108, (copy) v_u_11, (copy) v_u_31, (copy) v_u_35, (copy) v_u_38, (copy) v_u_36, (copy) v_u_12, (copy) v_u_26, (copy) v_u_5, (copy) v_u_15, (copy) v_u_10, (copy) v_u_112, (copy) v_u_59, (copy) v_u_111, (copy) v_u_109, (copy) v_u_55, (copy) v_u_110
		while true do
			local v114, v115, v116, v117, v118, v119 = debug.info(v_u_44, "slanf")
			if v114 ~= v_u_46 or (v115 ~= v_u_47 or (v118 ~= v_u_45 or (v116 ~= 3 or (v117 or (v119 ~= v_u_44 or not v_u_44("_", "_", true)))))) then
				break
			end
			for v120, v121 in v_u_108 do
				local v122 = v121[1]
				local v123, v124 = v_u_11(v121[2])
				if v123 and (v124 == false or v124 == true) then
					if v124 then
						v_u_44(v122, (("%* detector detected"):format(v120)))
					end
				else
					v_u_44("crash", "Tamper Protection 0xDD42F")
					task.wait(1)
					v_u_11(v_u_31, "Adonis_0xDD42F")
					v_u_11(v_u_35, "Adonis_0xDD42F")
					v_u_11(v_u_38, v_u_36, "Adonis_0xDD42F")
				end
			end
			local v_u_125 = false
			task.spawn(v_u_12, function()
				-- upvalues: (ref) v_u_26, (ref) v_u_36, (ref) v_u_5, (ref) v_u_11, (ref) v_u_15, (ref) v_u_44, (ref) v_u_10, (ref) v_u_112, (ref) v_u_59, (ref) v_u_125
				local v_u_126 = v_u_26.UnWrap(v_u_36)
				local v_u_127 = v_u_26.UnWrap(v_u_5)
				local v128, v129 = v_u_11(function()
					-- upvalues: (copy) v_u_126, (copy) v_u_127
					v_u_126.Kick(v_u_127, "If this message appears, report it to Adonis maintainers. 0x1")
				end)
				local v130, v131 = v_u_11(function()
					-- upvalues: (copy) v_u_127
					v_u_127:Kick("If this message appears, report it to Adonis maintainers. 0x2")
				end)
				if v128 or (v129 ~= "Expected \':\' not \'.\' calling member function Kick" or (v130 or (v_u_15.match(v131, "^Kick is not a valid member of Workspace \"(.+)\"$") or "") ~= v_u_127:GetFullName())) then
					v_u_44("kick", "Anti kick found! Method 0x3")
					v_u_10(v128, v129, "|", v130, v131)
				end
				if #v_u_26.Players:GetPlayers() > 1 then
					local v132 = v_u_26.Players
					for _, v133 in v_u_26.Players:GetPlayers() do
						local v_u_134 = v_u_26.UnWrap(v133)
						if v_u_134 and (not v_u_112[v_u_134] and (v_u_134.Parent == v132 and v_u_134 ~= v_u_126)) then
							local v135, v136 = v_u_11(v_u_126.Kick, v_u_134, "If this message appears, report it to Adonis maintainers. 0x2")
							local v137, v138 = v_u_11(function()
								-- upvalues: (copy) v_u_134
								v_u_134:Kick("If this message appears, report it to Adonis maintainers. 0x4")
							end)
							if v135 or (v136 ~= "Cannot kick a non-local Player from a LocalScript" or (v137 or v138 ~= "Cannot kick a non-local Player from a LocalScript")) then
								v_u_44("kick", "Anti kick found! Method 0x6")
								v_u_10(v135, v136, "|", v137, v138)
							end
						end
					end
				end
				local v139, v140 = v_u_11(function()
					-- upvalues: (copy) v_u_126
					v_u_126:KicK("If this message appears, report it to Adonis maintainers. 0x5")
				end)
				if v139 or (v_u_15.match(v140, "^%a+ is not a valid member of Player \"(.+)\"$") or "") ~= v_u_126:GetFullName() then
					v_u_44("kick", "Anti kick found! Method 0x4")
				end
				local v141, v142 = v_u_11(v_u_26.UnWrap(v_u_127).GetRealPhysicsFPS, v_u_59)
				if v141 or not v_u_15.match(v142, "Expected \':\' not \'.\' calling member function GetRealPhysicsFPS") then
					v_u_44("kick", "Anti FPS detection found!")
				end
				v_u_125 = true
			end, function()
				-- upvalues: (ref) v_u_44, (ref) v_u_11, (ref) v_u_31, (ref) v_u_35, (ref) v_u_38, (ref) v_u_36
				v_u_44("crash", "Tamper Protection 0x16E68")
				task.wait(1)
				v_u_11(v_u_31, "Adonis_0x16E68")
				v_u_11(v_u_35, "Adonis_0x16E68")
				v_u_11(v_u_38, v_u_36, "Adonis_0x16E68")
			end)
			task.spawn(v_u_12, function()
				-- upvalues: (ref) v_u_125, (ref) v_u_44
				task.wait(4)
				if not v_u_125 then
					v_u_44("kick", "Anti kick found! Method 0x3")
				end
			end, function()
				-- upvalues: (ref) v_u_44, (ref) v_u_11, (ref) v_u_31, (ref) v_u_35, (ref) v_u_38, (ref) v_u_36
				v_u_44("crash", "Tamper Protection 0x7D2B")
				task.wait(1)
				v_u_11(v_u_31, "Adonis_0x7D2B")
				v_u_11(v_u_35, "Adonis_0x7D2B")
				v_u_11(v_u_38, v_u_36, "Adonis_0x7D2B")
			end)
			local v_u_143 = false
			task.spawn(v_u_12, function()
				-- upvalues: (ref) v_u_26, (ref) v_u_5, (ref) v_u_11, (ref) v_u_111, (ref) v_u_15, (ref) v_u_44, (ref) v_u_109, (ref) v_u_55, (ref) v_u_110, (ref) v_u_143
				local v_u_144 = v_u_26.UnWrap(v_u_5)
				local v145, v146 = v_u_11(function()
					-- upvalues: (ref) v_u_111
					v_u_111:getlogHistory()
				end)
				local v147, v148 = v_u_11(function()
					-- upvalues: (ref) v_u_111, (copy) v_u_144
					v_u_111.GetLogHistory(v_u_144)
				end)
				local v149, v150 = v_u_11(function()
					-- upvalues: (copy) v_u_144
					v_u_144:GetLogHistory()
				end)
				if v145 or ((v_u_15.match(v146, "^%a+ is not a valid member of LogService \"(.+)\"$") or "") ~= v_u_111:GetFullName() or (v147 or (v148 ~= "Expected \':\' not \'.\' calling member function GetLogHistory" or (v149 or (v_u_15.match(v150, "^GetLogHistory is not a valid member of Workspace \"(.+)\"$") or "") ~= v_u_144:GetFullName())))) then
					v_u_44("kick", "0x7D3C GetLogHistory function hooks detected")
				end
				local v151, v152 = v_u_11(function()
					-- upvalues: (ref) v_u_109
					v_u_109:fireserver()
				end)
				local v153, v154 = v_u_11(function()
					-- upvalues: (ref) v_u_109, (copy) v_u_144
					v_u_109.FireServer(v_u_144)
				end)
				local v155, v156 = v_u_11(function()
					-- upvalues: (copy) v_u_144
					v_u_144:FireServer()
				end)
				if v151 or ((v_u_15.match(v152, "^%a+ is not a valid member of RemoteEvent \"(.+)\"$") or "") ~= v_u_109:GetFullName() or (v153 or (v154 ~= "Expected \':\' not \'.\' calling member function FireServer" or (v155 or (v_u_15.match(v156, "^FireServer is not a valid member of Workspace \"(.+)\"$") or "") ~= v_u_144:GetFullName())))) then
					v_u_44("kick", "FireServer function hooks detected")
				end
				v_u_11(v_u_109.FireServer, v_u_55, v_u_55)
				local v157, v158 = v_u_11(function()
					-- upvalues: (ref) v_u_110
					v_u_110:invokeserver()
				end)
				local v159, v160 = v_u_11(function()
					-- upvalues: (ref) v_u_110, (copy) v_u_144
					v_u_110.InvokeServer(v_u_144)
				end)
				local v161, v162 = v_u_11(function()
					-- upvalues: (copy) v_u_144
					v_u_144:InvokeServer()
				end)
				if v157 or ((v_u_15.match(v158, "^%a+ is not a valid member of RemoteFunction \"(.+)\"$") or "") ~= v_u_110:GetFullName() or (v159 or (v160 ~= "Expected \':\' not \'.\' calling member function InvokeServer" or (v161 or (v_u_15.match(v162, "^InvokeServer is not a valid member of Workspace \"(.+)\"$") or "") ~= v_u_144:GetFullName())))) then
					v_u_44("kick", "InvokeServer function hooks detected")
				end
				v_u_11(v_u_110.InvokeServer, v_u_55, v_u_109)
				v_u_143 = true
			end, function()
				-- upvalues: (ref) v_u_44, (ref) v_u_11, (ref) v_u_31, (ref) v_u_35, (ref) v_u_38, (ref) v_u_36
				v_u_44("crash", "Tamper Protection 0xB3EB")
				task.wait(1)
				v_u_11(v_u_31, "Adonis_0xB3EB")
				v_u_11(v_u_35, "Adonis_0xB3EB")
				v_u_11(v_u_38, v_u_36, "Adonis_0xB3EB")
			end)
			task.spawn(v_u_12, function()
				-- upvalues: (ref) v_u_143, (ref) v_u_44
				task.wait(4)
				if not v_u_143 then
					v_u_44("kick", "Remote and/or logservice spoofcheck failed")
				end
			end, function()
				-- upvalues: (ref) v_u_44, (ref) v_u_11, (ref) v_u_31, (ref) v_u_35, (ref) v_u_38, (ref) v_u_36
				v_u_44("crash", "Tamper Protection 0x33E0")
				task.wait(1)
				v_u_11(v_u_31, "Adonis_0x33E0")
				v_u_11(v_u_35, "Adonis_0x33E0")
				v_u_11(v_u_38, v_u_36, "Adonis_0x33E0")
			end)
			task.wait(5)
		end
		while true do

		end
	end)
	local v_u_163 = {}
	local v_u_169 = v_u_26.ReadOnly({
		["Init"] = function()
			-- upvalues: (ref) v_u_24, (copy) v_u_27, (ref) v_u_22, (ref) v_u_25, (ref) v_u_23
			v_u_24 = v_u_27.UI
			v_u_22 = v_u_27.Anti
			v_u_25 = v_u_27.Variables
			v_u_23 = v_u_27.Process
			v_u_22.Init = nil
		end,
		["RunLast"] = function()
			-- upvalues: (ref) v_u_22
			v_u_22.RunLast = nil
		end,
		["RunAfterLoaded"] = function()
			-- upvalues: (copy) v_u_26, (ref) v_u_22
			v_u_26.Player.Changed:Connect(function()
				-- upvalues: (ref) v_u_22, (ref) v_u_26
				if v_u_22.RLocked(v_u_26.Player) then
					v_u_22.Detected("kick", "Player is Roblox Locked")
				end
			end)
			v_u_22.RunAfterLoaded = nil
		end,
		["Launch"] = function(p164, p165)
			-- upvalues: (ref) v_u_22, (copy) v_u_26
			if v_u_22.Detectors[p164] and v_u_26.NetworkClient then
				v_u_22.Detectors[p164](p165)
			end
		end,
		["Detected"] = v_u_44,
		["Detectors"] = v_u_26.ReadOnly(v7({}, {
			["__index"] = v_u_163
		}), false, true),
		["AddDetector"] = function(p166, p167)
			-- upvalues: (copy) v_u_163
			if not v_u_163[p166] then
				v_u_163[p166] = p167
			end
		end,
		["RLocked"] = function(p_u_168)
			-- upvalues: (copy) v_u_11
			return not v_u_11(function()
				-- upvalues: (copy) p_u_168
				return p_u_168.GetFullName(p_u_168)
			end)
		end
	}, {
		["Init"] = true,
		["RunLast"] = true,
		["RunAfterLoaded"] = true
	}, true)
	v_u_27.Anti = v_u_169
	local v170 = v_u_26.MetaFunc
	local v171 = v170(v_u_26.TrackTask)
	local v_u_172 = v170(v_u_11)
	local v_u_173 = v170(task.wait)
	v170(v14)
	v171("Thread: TableCheck", v170(function()
		-- upvalues: (copy) v_u_173, (copy) v_u_8, (copy) v_u_27, (copy) v_u_28, (copy) v_u_29, (copy) v_u_30, (ref) v_u_169, (copy) v_u_32, (copy) v_u_33, (copy) v_u_44, (copy) v_u_31, (copy) v_u_35, (copy) v_u_172, (copy) v_u_38, (copy) v_u_36
		while v_u_173(1) do
			local v174, v175, v176, v177, v178, v179, v180, v181, v182, v183 = v_u_8.resume(v_u_8.create(function()
				-- upvalues: (ref) v_u_27
				return v_u_27.Core, v_u_27.Remote, v_u_27.Functions, v_u_27.Anti, v_u_27.Remote.Send, v_u_27.Remote.Get, v_u_27.Anti.Detected, v_u_27.Disconnect, v_u_27.Kill
			end))
			if not v174 or (v175 ~= v_u_28 or (v176 ~= v_u_29 or (v177 ~= v_u_30 or (v178 ~= v_u_169 or (v179 ~= v_u_32 or (v180 ~= v_u_33 or (v181 ~= v_u_44 or (v182 ~= v_u_31 or v183 ~= v_u_35)))))))) then
				v_u_172(v_u_44, "crash", "Tamper Protection 0x273A")
				v_u_173(1)
				v_u_172(v_u_31, "Adonis_0x273A")
				v_u_172(v_u_35, "Adonis_0x273A")
				v_u_172(v_u_38, v_u_36, "Adonis_0x273A")
			end
		end
	end))
end
