client = nil
service = nil
Pcall = nil
Routine = nil
GetEnv = nil
origEnv = nil
logError = nil
log = nil
return function(p1, p_u_2)
	local v3 = p_u_2(nil, {
		["script"] = script
	})
	setfenv(1, v3)
	local _ = _G
	local _ = game
	local _ = script
	local v4 = getfenv
	local _ = setfenv
	local _ = workspace
	local _ = getmetatable
	local _ = setmetatable
	local _ = loadstring
	local _ = coroutine
	local _ = rawequal
	local _ = typeof
	local v_u_5 = print
	local v_u_6 = math
	local v_u_7 = warn
	local v_u_8 = error
	local v_u_9 = pcall
	local _ = xpcall
	local v_u_10 = select
	local _ = rawset
	local _ = rawget
	local _ = ipairs
	local _ = pairs
	local _ = next
	local _ = Rect
	local _ = Axes
	local v_u_11 = os
	local v_u_12 = time
	local _ = Faces
	local v_u_13 = unpack
	local v_u_14 = string
	local v_u_15 = Color3
	local _ = newproxy
	local v_u_16 = tostring
	local _ = tonumber
	local _ = Instance
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
	local v_u_17 = table
	local v_u_18 = type
	local _ = wait
	local v_u_19 = Enum
	local _ = UDim
	local _ = UDim2
	local _ = Vector2
	local _ = Vector3
	local _ = Region3
	local _ = CFrame
	local _ = Ray
	local _ = delay
	local v_u_20 = p1.Service
	local v_u_21 = p1.Client
	local v_u_22 = nil
	local v_u_23 = nil
	local v_u_24 = nil
	local v_u_25 = nil
	local v_u_26 = nil
	local v_u_27 = nil
	local v_u_28 = nil
	local function v32()
		-- upvalues: (ref) v_u_27, (copy) v_u_21, (ref) v_u_22, (ref) v_u_23, (ref) v_u_28, (ref) v_u_24, (ref) v_u_25, (ref) v_u_26
		v_u_27 = v_u_21.UI
		v_u_22 = v_u_21.Anti
		v_u_23 = v_u_21.Core
		v_u_28 = v_u_21.Variables
		v_u_24 = v_u_21.Functions
		v_u_25 = v_u_21.Process
		v_u_26 = v_u_21.Remote
		function v_u_26.NewDecrypt(p29, p30, p31)
			-- upvalues: (ref) v_u_26
			return v_u_26.NewEncrypt(p29, p30, p31 or v_u_26.NewDecodeCache)
		end
		v_u_26.Init = nil
	end
	local function v34()
		-- upvalues: (copy) v_u_21, (copy) v_u_20, (ref) v_u_26, (copy) v_u_7
		log("~! Fire client loaded")
		v_u_21.Remote.Send("ClientLoaded")
		log("~! Start ClientCheck loop")
		task.delay(5, function()
			-- upvalues: (ref) v_u_20, (ref) v_u_26
			v_u_20.StartLoop("ClientCheck", 30, v_u_26.CheckClient, true)
		end)
		log("Get settings")
		local v33 = v_u_21.Remote.Get("Setting", {
			"G_API",
			"G_Access",
			"G_Access_Perms",
			"Allowed_API_Calls",
			"HelpButtonImage"
		})
		if v33 then
			v_u_21.G_API = v33.G_API
			v_u_21.G_Access = v33.G_Access
			v_u_21.G_Access_Perms = v33.G_Access_Perms
			v_u_21.Allowed_API_Calls = v33.Allowed_API_Calls
			v_u_21.HelpButtonImage = v33.HelpButtonImage
		else
			log("~! GET SETTINGS FAILED?")
			v_u_7("FAILED TO GET SETTINGS FROM SERVER")
		end
		v_u_26.RunAfterLoaded = nil
	end
	local function v35()
		-- upvalues: (ref) v_u_26
		v_u_26.RunLast = nil
	end
	v4().client = nil
	v4().service = nil
	v4().script = nil
	local v170 = {
		["Init"] = v32,
		["RunLast"] = v35,
		["RunAfterLoaded"] = v34,
		["Returns"] = {},
		["PendingReturns"] = {},
		["EncodeCache"] = {},
		["DecodeCache"] = {},
		["NewEncodeCache"] = {},
		["NewDecodeCache"] = {},
		["Received"] = 0,
		["Sent"] = 0,
		["CheckClient"] = function()
			-- upvalues: (copy) v_u_11, (ref) v_u_23, (ref) v_u_26, (copy) v_u_21
			if v_u_11.time() - v_u_23.LastUpdate >= 10 then
				v_u_26.Send("ClientCheck", {
					["Sent"] = v_u_26.Sent or 0,
					["Received"] = v_u_26.Received
				}, v_u_21.DepsName)
			end
		end,
		["Returnables"] = {
			["Test"] = function(p36)
				-- upvalues: (copy) v_u_13
				return "HELLO FROM THE CLIENT SIDE :)! ", v_u_13(p36)
			end,
			["Ping"] = function(_)
				-- upvalues: (ref) v_u_26
				return v_u_26.Ping()
			end,
			["ClientHooked"] = function(_)
				-- upvalues: (ref) v_u_23
				return v_u_23.Special
			end,
			["TaskManager"] = function(p37)
				-- upvalues: (copy) v_u_20, (copy) v_u_11, (copy) v_u_16, (copy) v_u_17
				if p37[1] == "GetTasks" then
					local v38 = {}
					for _, v39 in v_u_20.GetTasks() do
						local v40 = {
							["Status"] = v39.Status,
							["Name"] = v39.Name,
							["Index"] = v39.Index,
							["Created"] = v39.Created,
							["CurrentTime"] = v_u_11.time(),
							["Function"] = v_u_16(v39.Function)
						}
						v_u_17.insert(v38, v40)
					end
					return v38
				end
			end,
			["LoadCode"] = function(p41)
				-- upvalues: (ref) v_u_23, (copy) p_u_2
				local v42 = p41[1]
				local v43 = v_u_23.LoadCode(v42, p_u_2())
				if v43 then
					return v43()
				end
			end,
			["Function"] = function(p44)
				-- upvalues: (copy) v_u_21, (copy) v_u_18, (copy) v_u_13
				local v45 = v_u_21.Functions[p44[1]]
				if v45 and v_u_18(v45) == "function" then
					return v45(v_u_13(p44, 2))
				end
			end,
			["Handler"] = function(p46)
				-- upvalues: (copy) v_u_21, (copy) v_u_18, (copy) v_u_13
				local v47 = v_u_21.Handlers[p46[1]]
				if v47 and v_u_18(v47) == "function" then
					return v47(v_u_13(p46, 2))
				end
			end,
			["UIKeepAlive"] = function(_)
				-- upvalues: (ref) v_u_28, (copy) v_u_21, (copy) v_u_20, (ref) v_u_27
				if v_u_28.UIKeepAlive then
					for _, v48 in v_u_21.GUIs do
						if v48.KeepAlive then
							if v48.Class == "ScreenGui" or v48.Class == "GuiMain" then
								v48.Object.Parent = v_u_20.Player.PlayerGui
							elseif v48.Class == "TextLabel" then
								v48.Object.Parent = v_u_27.GetHolder()
							end
							v48.KeepAlive = false
						end
					end
				end
				return true
			end,
			["UI"] = function(p49)
				-- upvalues: (ref) v_u_28, (ref) v_u_27
				local v50 = p49[1]
				local v51 = p49[2]
				local v52 = p49[3]
				v_u_28.LastServerTheme = v51 or v_u_28.LastServerTheme
				return v_u_27.Make(v50, v52, v51)
			end,
			["InstanceList"] = function(_)
				-- upvalues: (copy) v_u_20, (copy) v_u_17
				local v53 = {}
				for _, v54 in v_u_20.GetAdonisObjects() do
					local v55 = {
						["Text"] = v54:GetFullName(),
						["Desc"] = v54.ClassName
					}
					v_u_17.insert(v53, v55)
				end
				return v53
			end,
			["ClientLog"] = function(_)
				-- upvalues: (copy) v_u_19, (copy) v_u_15, (copy) v_u_20, (copy) v_u_17
				local v56 = {
					[v_u_19.MessageType.MessageWarning] = v_u_15.fromRGB(222, 146, 55),
					[v_u_19.MessageType.MessageError] = v_u_15.fromRGB(219, 75, 75),
					[v_u_19.MessageType.MessageInfo] = v_u_15.fromRGB(137, 221, 255)
				}
				local v57 = v_u_20.LogService:GetLogHistory()
				local v58 = {}
				for v59 = #v57, 1, -1 do
					local v60 = v57[v59]
					for v61, v62 in v_u_20.ExtractLines(v60.message) do
						local v63 = {
							["Text"] = v62
						}
						local v64
						if v61 == 1 then
							v64 = v60.timestamp
						else
							v64 = nil
						end
						v63.Time = v64
						v63.Desc = v60.messageType.Name:match("^Message(.+)$")
						v63.Color = v56[v60.messageType]
						v_u_17.insert(v58, v63)
					end
				end
				return v58
			end,
			["LocallyFormattedTime"] = function(p65)
				-- upvalues: (copy) v_u_18, (copy) v_u_20, (copy) v_u_10, (copy) v_u_13
				if v_u_18(p65[1]) ~= "table" then
					return v_u_20.FormatTime(v_u_13(p65))
				end
				local v66 = {}
				for v67, v68 in p65[1] do
					v66[v67] = v_u_20.FormatTime(v68, v_u_10(2, v_u_13(p65)))
				end
				return v66
			end
		},
		["Commands"] = {
			["GetReturn"] = function(p69)
				-- upvalues: (copy) v_u_5, (copy) v_u_17, (ref) v_u_26, (copy) v_u_9
				v_u_5("THE SERVER IS ASKING US FOR A RETURN")
				local v70 = p69[1]
				local v71 = p69[2]
				local v72 = v_u_17.pack(v_u_17.unpack(p69, 3))
				local v73 = v_u_26.Returnables[v70]
				local v74 = v73 and v_u_17.pack(v_u_9(v73, v72)) or {}
				if v74[1] == true then
					v_u_5("SENT RETURN")
					v_u_26.Send("GiveReturn", v71, v_u_17.unpack(v74, 2))
				else
					logError(v74[2])
					v_u_26.Send("GiveReturn", v71, "__ADONIS_RETURN_ERROR", v74[2])
				end
			end,
			["GiveReturn"] = function(p75)
				-- upvalues: (copy) v_u_5, (ref) v_u_26, (copy) v_u_20, (copy) v_u_17
				v_u_5("SERVER GAVE US A RETURN")
				if v_u_26.PendingReturns[p75[1]] then
					v_u_5("VALID PENDING RETURN")
					v_u_26.PendingReturns[p75[1]] = nil
					v_u_20.Events[p75[1]]:Fire(v_u_17.unpack(p75, 2))
				end
			end,
			["SessionData"] = function(p76)
				-- upvalues: (copy) v_u_20, (copy) v_u_17
				local v77 = p76[1]
				if v77 then
					v_u_20.Events.SessionData:Fire(v77, v_u_17.unpack(p76, 2))
				end
			end,
			["SetVariables"] = function(p78)
				-- upvalues: (ref) v_u_28
				for v79, v80 in p78[1] do
					v_u_28[v79] = v80
				end
			end,
			["Print"] = function(p81)
				-- upvalues: (copy) v_u_5, (copy) v_u_13
				v_u_5(v_u_13(p81))
			end,
			["FireEvent"] = function(p82)
				-- upvalues: (copy) v_u_20, (copy) v_u_13
				v_u_20.FireEvent(v_u_13(p82))
			end,
			["Test"] = function(p83)
				-- upvalues: (copy) v_u_5
				v_u_5((("OK WE GOT COMMUNICATION!  ORGL: %*"):format(p83[1])))
			end,
			["TestError"] = function(_)
				-- upvalues: (copy) v_u_8
				v_u_8("THIS IS A TEST ERROR")
			end,
			["TestEvent"] = function(p84)
				-- upvalues: (ref) v_u_26, (copy) v_u_13
				v_u_26.PlayerEvent(p84[1], v_u_13(p84, 2))
			end,
			["LoadCode"] = function(p85)
				-- upvalues: (ref) v_u_23, (copy) p_u_2
				local v86 = p85[1]
				local v87 = v_u_23.LoadCode(v86, p_u_2())
				if v87 then
					return v87()
				end
			end,
			["LaunchAnti"] = function(p88)
				-- upvalues: (ref) v_u_22
				v_u_22.Launch(p88[1], p88[2])
			end,
			["UI"] = function(p89)
				-- upvalues: (ref) v_u_28, (ref) v_u_27
				local v90 = p89[1]
				local v91 = p89[2]
				local v92 = p89[3]
				v_u_28.LastServerTheme = v91 or v_u_28.LastServerTheme
				v_u_27.Make(v90, v92, v91)
			end,
			["RemoveUI"] = function(p93)
				-- upvalues: (ref) v_u_27
				v_u_27.Remove(p93[1], p93[2])
			end,
			["RefreshUI"] = function(p94)
				-- upvalues: (ref) v_u_27, (ref) v_u_28
				local v95 = p94[1]
				local v96 = p94[2]
				v_u_27.Remove(v95, v96)
				local v97 = p94[3]
				local v98 = p94[4]
				v_u_28.LastServerTheme = v97 or v_u_28.LastServerTheme
				v_u_27.Make(v95, v98, v97)
			end,
			["StartLoop"] = function(p99)
				-- upvalues: (ref) v_u_23, (copy) p_u_2, (copy) v_u_20
				local v100 = p99[1]
				local v101 = p99[2]
				local v102 = p99[3]
				local v103 = v_u_23.LoadCode(v102, p_u_2())
				if v100 and (v101 and (v102 and v103)) then
					v_u_20.StartLoop(v100, v101, v103)
				end
			end,
			["StopLoop"] = function(p104)
				-- upvalues: (copy) v_u_20
				v_u_20.StopLoop(p104[1])
			end,
			["Function"] = function(p105)
				-- upvalues: (copy) v_u_21, (copy) v_u_18, (copy) v_u_13
				local v106 = v_u_21.Functions[p105[1]]
				if v106 and v_u_18(v106) == "function" then
					Pcall(v106, v_u_13(p105, 2))
				end
			end,
			["Handler"] = function(p107)
				-- upvalues: (copy) v_u_21, (copy) v_u_18, (copy) v_u_13
				local v108 = v_u_21.Handlers[p107[1]]
				if v108 and v_u_18(v108) == "function" then
					Pcall(v108, v_u_13(p107, 2))
				end
			end
		},
		["Fire"] = function(...)
			-- upvalues: (ref) v_u_25, (ref) v_u_23, (copy) v_u_17, (copy) v_u_20, (ref) v_u_26, (copy) v_u_21
			local v109 = v_u_25.RateLimits
			local v_u_110 = v109 and v109.Remote or 0.01
			local v_u_111 = v_u_23.RemoteEvent
			local v_u_112 = v_u_17.pack(...)
			if v_u_111 and v_u_111.Object then
				v_u_20.Queue("REMOTE_SEND", function()
					-- upvalues: (ref) v_u_26, (copy) v_u_111, (ref) v_u_21, (copy) v_u_112, (ref) v_u_17, (copy) v_u_110
					v_u_26.Sent = v_u_26.Sent + 1
					local v113 = v_u_112
					v_u_111.Object:FireServer({
						["Mode"] = "Fire",
						["Module"] = v_u_21.Module,
						["Loader"] = v_u_21.Loader,
						["Sent"] = v_u_26.Sent,
						["Received"] = v_u_26.Received
					}, v_u_17.unpack(v113))
					task.wait(v_u_110)
				end)
			end
		end,
		["Send"] = function(p114, ...)
			-- upvalues: (ref) v_u_23, (copy) v_u_11, (ref) v_u_26
			v_u_23.LastUpdate = v_u_11.time()
			v_u_26.Fire(v_u_26.NewEncrypt(p114, v_u_23.Key), ...)
		end,
		["GetFire"] = function(...)
			-- upvalues: (ref) v_u_23, (ref) v_u_25, (copy) v_u_17, (copy) v_u_20, (ref) v_u_26, (copy) v_u_21, (copy) v_u_13
			local v_u_115 = v_u_23.RemoteEvent
			local v116 = v_u_25.RateLimits
			local v_u_117 = v116 and v116.Remote or 0.02
			local v_u_118 = v_u_17.pack(...)
			local v_u_119 = nil
			if v_u_115 and v_u_115.Function then
				local v_u_120 = v_u_20.Signal.new()
				v_u_20.Queue("REMOTE_SEND", function()
					-- upvalues: (ref) v_u_26, (ref) v_u_119, (copy) v_u_115, (ref) v_u_21, (copy) v_u_118, (ref) v_u_17, (copy) v_u_120, (copy) v_u_117
					v_u_26.Sent = v_u_26.Sent + 1
					task.delay(0, function()
						-- upvalues: (ref) v_u_119, (ref) v_u_115, (ref) v_u_21, (ref) v_u_26, (ref) v_u_118, (ref) v_u_17, (ref) v_u_120
						local v121 = {}
						local v122 = v_u_118
						__set_list(v121, 1, {v_u_115.Function:InvokeServer({
	["Mode"] = "Get",
	["Module"] = v_u_21.Module,
	["Loader"] = v_u_21.Loader,
	["Sent"] = v_u_26.Sent,
	["Received"] = v_u_26.Received
}, v_u_17.unpack(v122))})
						v_u_119 = v121
						v_u_120:Fire(v_u_119)
					end)
					task.wait(v_u_117)
				end)
				if not v_u_119 then
					v_u_120:Wait()
				end
				v_u_120:Destroy()
				if v_u_119 then
					return v_u_13(v_u_119)
				end
			end
		end,
		["RawGet"] = function(...)
			-- upvalues: (copy) v_u_17, (ref) v_u_23, (ref) v_u_26, (copy) v_u_21
			local v123 = v_u_17.pack(...)
			local v124 = v_u_23.RemoteEvent
			if v124 and v124.Function then
				v_u_26.Sent = v_u_26.Sent + 1
				return v124.Function:InvokeServer({
					["Mode"] = "Get",
					["Module"] = v_u_21.Module,
					["Loader"] = v_u_21.Loader,
					["Sent"] = v_u_26.Sent,
					["Received"] = v_u_26.Received
				}, v_u_17.unpack(v123))
			end
		end,
		["Get"] = function(p125, ...)
			-- upvalues: (ref) v_u_23, (copy) v_u_11, (ref) v_u_26, (copy) v_u_18, (copy) v_u_17
			v_u_23.LastUpdate = v_u_11.time()
			local v126 = v_u_26.GetFire(v_u_26.NewEncrypt(p125, v_u_23.Key), ...)
			if v_u_18(v126) == "table" then
				return v_u_17.unpack(v126)
			else
				return v126
			end
		end,
		["OldGet"] = function(p127, ...)
			-- upvalues: (copy) v_u_20, (copy) v_u_5, (copy) v_u_17, (ref) v_u_26, (copy) v_u_14, (copy) v_u_16, (copy) v_u_8
			local v_u_128 = nil
			local v129 = v_u_20.HttpService:GenerateGUID(false)
			local v_u_130 = v_u_20.New("BindableEvent")
			local v131 = v_u_20.Events[v129]:Connect(function(...)
				-- upvalues: (ref) v_u_5, (ref) v_u_128, (ref) v_u_17, (copy) v_u_130
				v_u_5("WE ARE GETTING A RETURN!")
				v_u_128 = v_u_17.pack(...)
				v_u_130:Fire()
				task.wait()
				v_u_130:Fire()
				v_u_130:Destroy()
			end)
			v_u_26.PendingReturns[v129] = true
			v_u_26.Send("GetReturn", p127, v129, ...)
			v_u_5(v_u_14.format("GETTING RETURNS? %s", (v_u_16(v_u_128))))
			v_u_130.Event:Wait()
			v_u_5(v_u_14.format("WE GOT IT! %s", (v_u_16(v_u_128))))
			v131:Disconnect()
			if not v_u_128 then
				return nil
			end
			if v_u_128[1] ~= "__ADONIS_RETURN_ERROR" then
				local v132 = v_u_128
				return v_u_17.unpack(v132)
			end
			v_u_8(v_u_128[2])
		end,
		["Ping"] = function()
			-- upvalues: (copy) v_u_12, (ref) v_u_26, (copy) v_u_6
			local v133 = v_u_12()
			if not v_u_26.Get("Ping") then
				return false
			end
			local v134 = (v_u_12() - v133) * 1000 + 0.5
			return v_u_6.floor(v134) / 1000 * 1000
		end,
		["PlayerEvent"] = function(p135, ...)
			-- upvalues: (ref) v_u_26
			v_u_26.Send("PlayerEvent", p135, ...)
		end,
		["Encrypt"] = function(p136, p137, p138)
			-- upvalues: (ref) v_u_26
			local v139 = p138 or (v_u_26.EncodeCache or {})
			local v140 = v139[p137] or {}
			if not (p137 and p136) then
				return p136
			end
			if v140[p136] then
				return v140[p136]
			end
			local v141 = buffer.writeu8
			local v142 = buffer.readu8
			local v143 = buffer.fromstring(p136)
			local v144 = v140[1] or buffer.fromstring(p137)
			local v145 = #p137
			for v146 = 0, #p136 - 1 do
				v141(v143, v146, (v142(v143, v146) + v142(v144, (v146 + 1) % v145)) % 126 + 1)
			end
			v139[p137] = v140
			v140[p136] = buffer.tostring(v143)
			v140[1] = v144
			return v140[p136]
		end,
		["Decrypt"] = function(p147, p148, p149)
			-- upvalues: (ref) v_u_26
			local v150 = p149 or (v_u_26.DecodeCache or {})
			local v151 = v150[p148] or {}
			if not (p148 and p147) then
				return p147
			end
			if v151[p147] then
				return v151[p147]
			end
			local v152 = buffer.writeu8
			local v153 = buffer.readu8
			local v154 = buffer.fromstring(p147)
			local v155 = v151[1] or buffer.fromstring(p148)
			local v156 = #p148
			for v157 = 0, #p147 - 1 do
				v152(v154, v157, (v153(v154, v157) - v153(v155, (v157 + 1) % v156)) % 126 - 1)
			end
			v150[p148] = v151
			v151[p147] = buffer.tostring(v154)
			v151[1] = v155
			return v151[p147]
		end,
		["NewEncrypt"] = function(p158, p159, p160)
			-- upvalues: (ref) v_u_26
			local v161 = p160 or (v_u_26.NewEncodeCache or {})
			local v162 = v161[p159] or {}
			if not (p159 and p158) then
				return p158
			end
			if v162[p158] then
				return v162[p158]
			end
			local v163 = buffer.writeu8
			local v164 = buffer.readu8
			local v165 = bit32.bxor
			local v166 = buffer.fromstring(p158)
			local v167 = v162[1] or buffer.fromstring(p159)
			local v168 = #p159
			for v169 = 0, #p158 - 1 do
				v163(v166, v169, (v165(v164(v166, v169), (v164(v167, v169 % v168)))))
			end
			v161[p159] = v162
			v162[p158] = buffer.tostring(v166)
			v162[1] = v167
			return v162[p158]
		end
	}
	v_u_21.Remote = v170
end
