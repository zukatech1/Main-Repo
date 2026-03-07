server = nil
client = nil
Pcall = nil
Routine = nil
logError = nil
Folder = nil
local v_u_1 = nil
local v_u_2 = nil
local v_u_3 = {}
local v9 = {
	["__index"] = function(_, p_u_4)
		-- upvalues: (copy) v_u_3, (ref) v_u_2
		return function(p_u_5, ...)
			-- upvalues: (copy) p_u_4, (ref) v_u_3, (ref) v_u_2
			local v6, v7 = pcall(function()
				-- upvalues: (copy) p_u_5
				return p_u_5.ClassName
			end)
			if v6 and (v7 and p_u_5[p_u_4]) then
				local v8 = p_u_5[p_u_4]
				if type(v8) == "function" then
					if not v_u_3[v7] then
						v_u_3[v7] = {}
					end
					if not v_u_3[v7][p_u_4] then
						v_u_3[v7][p_u_4] = p_u_5[p_u_4]
					end
					if v_u_3[v7][p_u_4] ~= p_u_5[p_u_4] and v_u_2 then
						v_u_2("MethodError", ("%* || Cached method does not match found method: %*"):format(debug.traceback(), p_u_4), ("Method: %*"):format(p_u_4), p_u_4)
					end
					return v_u_3[v7][p_u_4](p_u_5, ...)
				end
			end
			return p_u_5[p_u_4](p_u_5, ...)
		end
	end,
	["__metatable"] = "Methods"
}
local v_u_10 = setmetatable({}, v9)
return function(p11, _, p_u_12, p13)
	-- upvalues: (ref) v_u_1, (ref) v_u_2, (copy) v_u_10
	if p13 then
		setfenv(1, p13)
	end
	local _ = _G
	local v_u_14 = game
	local _ = script
	local v_u_15 = getfenv
	local _ = setfenv
	local _ = workspace
	local v_u_16 = getmetatable
	local v_u_17 = setmetatable
	local _ = loadstring
	local v_u_18 = coroutine
	local v_u_19 = rawequal
	local v_u_20 = typeof
	local _ = print
	local v_u_21 = math
	local v_u_22 = warn
	local v_u_23 = error
	local v_u_24 = pcall
	local v_u_25 = xpcall
	local v_u_26 = select
	local v_u_27 = rawset
	local v_u_28 = rawget
	local v_u_29 = ipairs
	local _ = pairs
	local _ = next
	local _ = Rect
	local _ = Axes
	local v_u_30 = os
	local v_u_31 = time
	local _ = Faces
	local v_u_32 = unpack
	local v_u_33 = string
	local _ = Color3
	local v_u_34 = newproxy
	local v_u_35 = tostring
	local v_u_36 = tonumber
	local v37 = Instance
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
	local v38 = require
	local v_u_39 = table
	local v_u_40 = type
	local v_u_41 = task.wait
	local v_u_42 = Enum
	local _ = UDim
	local _ = UDim2
	local _ = Vector2
	local _ = Vector3
	local _ = Region3
	local _ = CFrame
	local _ = Ray
	local _ = task.delay
	local _ = task.defer
	local v_u_43 = task
	local _ = tick
	v_u_1 = server or client
	v_u_2 = p11
	server = nil
	client = nil
	local v44 = p13.Routine
	local v_u_45 = nil
	local v_u_46 = {}
	local v_u_47 = {}
	local v_u_48 = {}
	local v_u_49 = {}
	local v_u_50 = {}
	local v_u_51 = nil
	local function v_u_53(p52)
		return p52 and true or false
	end
	local v_u_54 = {}
	local v_u_55 = {}
	local v_u_56 = {}
	local v_u_57 = {}
	local v_u_58 = {}
	local v_u_59 = {}
	local v_u_60 = {}
	local v_u_61 = {}
	local v_u_62 = {}
	local v_u_63 = v_u_17({}, {
		["__mode"] = "v"
	})
	local v_u_64 = v_u_17({}, {
		["__mode"] = "kv"
	})
	local v_u_65 = v37.new
	local v66 = v37.new("Folder")
	local v67 = v37.new("Folder")
	local v68 = v37.new("Folder")
	local v69 = v37.new("Folder")
	local v_u_73 = {
		["new"] = function(p70, p71)
			-- upvalues: (copy) v_u_65, (ref) v_u_45
			local v72 = v_u_65(p70)
			if p71 then
				v72.Parent = v_u_45.UnWrap(p71)
			end
			if v_u_45 and client then
				v72 = v_u_45.Wrap(v72, true) or v72
			end
			return v72
		end
	}
	local v_u_114 = {
		["TrackTask"] = function(p74, p_u_75, p76, ...)
			-- upvalues: (copy) v_u_40, (copy) v_u_26, (copy) v_u_14, (copy) v_u_33, (copy) v_u_30, (copy) v_u_59, (copy) v_u_39, (copy) v_u_25, (copy) v_u_18
			local v_u_78 = (v_u_40(p76) ~= "function" or v_u_26("#", ...) == 0 and p76 == nil) and function(p77)
				logError(p77 .. "\n" .. debug.traceback())
			end or p76
			local v_u_79 = v_u_14:GetService("HttpService"):GenerateGUID(false)
			local v80 = v_u_33.sub(p74, 1, 7) == "Thread:"
			local v_u_81 = {
				["Name"] = p74,
				["Status"] = "Waiting",
				["Function"] = p_u_75,
				["isThread"] = v80,
				["Created"] = v_u_30.time(),
				["Index"] = v_u_79
			}
			local function v83(...)
				-- upvalues: (ref) v_u_59, (copy) v_u_79, (copy) v_u_81, (ref) v_u_39, (ref) v_u_25, (copy) p_u_75, (ref) v_u_78
				v_u_59[v_u_79] = v_u_81
				v_u_81.Status = "Running"
				v_u_81.Returns = v_u_39.pack(v_u_25(p_u_75, v_u_78, ...))
				if v_u_81.Returns[1] then
					v_u_81.Status = "Finished"
				else
					v_u_81.Status = "Errored"
				end
				v_u_59[v_u_79] = nil
				local v82 = v_u_81.Returns
				return v_u_39.unpack(v82)
			end
			if not v80 then
				return v83(...)
			end
			v_u_81.Thread = v_u_18.create(v83)
			return v_u_18.resume(v_u_81.Thread, ...)
		end,
		["EventTask"] = function(p_u_84, p_u_85)
			-- upvalues: (ref) v_u_45
			local v_u_86 = v_u_45.TrackTask
			return function(...)
				-- upvalues: (copy) v_u_86, (copy) p_u_84, (copy) p_u_85
				return v_u_86(p_u_84, p_u_85, false, ...)
			end
		end,
		["GetTasks"] = function()
			-- upvalues: (copy) v_u_59
			return v_u_59
		end,
		["TaskScheduler"] = function(p_u_87, p88)
			-- upvalues: (copy) v_u_61, (ref) v_u_45, (copy) v_u_24, (copy) v_u_39, (copy) v_u_41, (copy) v_u_30
			local v_u_89 = p88 or {}
			if not v_u_89.Temporary and v_u_61[p_u_87] then
				return v_u_61[p_u_87]
			end
			local v_u_92 = {
				["Name"] = p_u_87,
				["Running"] = true,
				["Properties"] = v_u_89,
				["LinkedTasks"] = {},
				["RunnerEvent"] = v_u_45.New("BindableEvent"),
				["Trigger"] = function(p90, ...)
					p90.Event:Fire(...)
				end,
				["Delete"] = function(p91)
					-- upvalues: (copy) v_u_89, (ref) v_u_61, (copy) p_u_87
					if not v_u_89.Temporary then
						v_u_61[p_u_87] = nil
					end
					p91.Running = false
					p91.Event:Disconnect()
				end
			}
			v_u_92.Event = v_u_92.RunnerEvent.Event:Connect(function(...)
				-- upvalues: (copy) v_u_92, (ref) v_u_24, (ref) v_u_39
				for v93, v94 in v_u_92.LinkedTasks do
					local _, v95 = v_u_24(v94)
					if v95 then
						v_u_39.remove(v_u_92.LinkedTasks, v93)
					end
				end
			end)
			if v_u_89.Interval then
				while v_u_41(v_u_89.Interval) and v_u_92.Running do
					v_u_92:Trigger(v_u_30.time())
				end
			end
			if not v_u_89.Temporary then
				v_u_61[p_u_87] = v_u_92
			end
			return v_u_92
		end,
		["Events"] = v_u_17({}, {
			["__index"] = function(_, p96)
				-- upvalues: (ref) v_u_45
				return v_u_45.GetEvent(p96)
			end
		}),
		["CheckEvents"] = function(_)
			return "Disabled"
		end,
		["WrapEventArgs"] = function(p97)
			-- upvalues: (ref) v_u_45, (copy) v_u_40
			local v98 = v_u_45.Wrap
			for v99, v100 in p97 do
				if v_u_40(v100) == "table" and (v100.__ISWRAPPED and v100.__OBJECT) then
					p97[v99] = v98(v100.__OBJECT)
				end
			end
			return p97
		end,
		["UnWrapEventArgs"] = function(p101)
			-- upvalues: (ref) v_u_45
			local v102 = v_u_45.UnWrap
			local v103 = v_u_45.Wrapped
			for v104, v105 in p101 do
				if v103(v105) then
					p101[v104] = {
						["__ISWRAPPED"] = true,
						["__OBJECT"] = v102(v105)
					}
				end
			end
			return p101
		end,
		["GetEvent"] = function(p106)
			-- upvalues: (copy) v_u_54, (ref) v_u_45
			if v_u_54[p106] then
				return v_u_54[p106]
			end
			local v107 = v_u_45.Signal.new()
			v_u_54[p106] = v107
			return v107
		end,
		["HookEvent"] = function(p108, p109, _)
			-- upvalues: (copy) v_u_40, (copy) v_u_22, (ref) v_u_45
			if v_u_40(p108) == "string" and v_u_40(p109) == "function" then
				return v_u_45.GetEvent(p108):Connect(p109)
			end
			v_u_22("Invalid argument supplied; HookEvent(string, function)")
		end,
		["FireEvent"] = function(p110, ...)
			-- upvalues: (copy) v_u_54
			local v111 = v_u_54[p110]
			if v111 then
				v111 = v111:Fire(...)
			end
			return v111
		end,
		["RemoveEvents"] = function(p112)
			-- upvalues: (copy) v_u_54
			local v113 = v_u_54[p112]
			if v113 then
				v_u_54[p112] = nil
				v113:Destroy()
			end
		end
	}
	local v165 = {
		["Tasks"] = {},
		["Threads"] = {},
		["CheckTasks"] = function()
			-- upvalues: (ref) v_u_45
			for _, v115 in v_u_45.Threads.Tasks do
				if not v115.Thread or v115:Status() == "dead" then
					v115:Remove()
				end
			end
		end,
		["NewTask"] = function(p116, p_u_117, p118)
			-- upvalues: (copy) v_u_21, (copy) v_u_30, (copy) v_u_32, (ref) v_u_45, (copy) v_u_39, (ref) v_u_2
			local v119 = v_u_21.random() * v_u_30.time() / 1000
			local v_u_120 = ("%*:%*"):format(v119, p_u_117)
			local v_u_121 = nil
			v_u_121 = {
				["PID"] = v119,
				["Name"] = p116,
				["Index"] = v_u_120,
				["Created"] = v_u_30.time(),
				["Changed"] = {},
				["Timeout"] = p118 or 0,
				["Running"] = false,
				["R_Status"] = "Idle",
				["Finished"] = {},
				["Function"] = function(...)
					-- upvalues: (ref) v_u_121, (copy) p_u_117, (ref) v_u_32
					v_u_121.R_Status = "Running"
					v_u_121.Running = true
					local v122 = { p_u_117(...) }
					v_u_121.R_Status = "Finished"
					v_u_121.Running = false
					v_u_121.Remove()
					return v_u_32(v122)
				end,
				["Remove"] = function()
					-- upvalues: (ref) v_u_121, (ref) v_u_45, (ref) v_u_39, (copy) v_u_120
					v_u_121.R_Status = "Removed"
					v_u_121.Running = false
					for v123, v124 in v_u_45.Threads.Tasks do
						if v124 == v_u_121 then
							v_u_39.remove(v_u_45.Threads.Tasks, v123)
						end
					end
					v_u_121.Changed:Fire("Removed")
					v_u_121.Finished:Fire()
					v_u_45.RemoveEvents((("%*_TASKCHANGED"):format(v_u_120)))
					v_u_45.RemoveEvents((("%*_TASKFINISHED"):format(v_u_120)))
					v_u_121.Thread = nil
				end,
				["Thread"] = v_u_45.Threads.Create(function(...)
					-- upvalues: (ref) v_u_121
					return v_u_121.Function(...)
				end),
				["Resume"] = function(...)
					-- upvalues: (ref) v_u_121, (ref) v_u_45, (ref) v_u_2, (ref) v_u_32
					v_u_121.R_Status = "Resumed"
					v_u_121.Running = true
					v_u_121.Changed:Fire("Resumed")
					local v125 = { v_u_45.Threads.Resume(v_u_121.Thread, ...) }
					if not v125[1] then
						v_u_2("TaskError", v125[2])
						v_u_121.Changed:Fire("Errored", v125[2])
						v_u_121.Remove()
					end
					return v_u_32(v125)
				end,
				["Status"] = function()
					-- upvalues: (ref) v_u_121, (ref) v_u_30, (ref) v_u_45
					if v_u_121.Timeout == 0 or v_u_30.time() - v_u_121.Created <= v_u_121.Timeout then
						return v_u_45.Threads.Status(v_u_121.Thread)
					end
					v_u_121:Stop()
					return "timeout"
				end,
				["Pause"] = function()
					-- upvalues: (ref) v_u_121, (ref) v_u_45
					v_u_121.R_Status = "Paused"
					v_u_121.Running = false
					v_u_45.Threads.Pause(v_u_121.Thread)
					v_u_121.Changed:Fire("Paused")
				end,
				["Stop"] = function()
					-- upvalues: (ref) v_u_121, (ref) v_u_45
					v_u_121.R_Status = "Stopping"
					v_u_45.Threads.Stop(v_u_121.Thread)
					v_u_121.Changed:Fire("Stopped")
					v_u_121.Remove()
				end,
				["Kill"] = function()
					-- upvalues: (ref) v_u_121, (ref) v_u_45
					v_u_121.R_Status = "Killing"
					v_u_45.Threads.End(v_u_121.Thread)
					v_u_121.Changed:Fire("Killed")
					v_u_121.Remove()
				end
			}
			local function v127(_, p126)
				-- upvalues: (ref) v_u_45, (copy) v_u_120
				return v_u_45.Events[("%*_TASKCHANGED"):format(v_u_120)]:Connect(p126)
			end
			v_u_121.Changed.Connect = v127
			local function v128(_, ...)
				-- upvalues: (ref) v_u_45, (copy) v_u_120
				v_u_45.Events[("%*_TASKCHANGED"):format(v_u_120)]:Fire(...)
			end
			v_u_121.Changed.Fire = v128
			local function v130(_, p129)
				-- upvalues: (ref) v_u_45, (copy) v_u_120
				return v_u_45.Events[("%*_TASKFINISHED"):format(v_u_120)]:Connect(p129)
			end
			v_u_121.Finished.Connect = v130
			local function v131(_)
				-- upvalues: (ref) v_u_45, (copy) v_u_120
				v_u_45.Events[("%*_TASKFINISHED"):format(v_u_120)]:wait(0)
			end
			v_u_121.Finished.wait = v131
			local function v132(_, ...)
				-- upvalues: (ref) v_u_45, (copy) v_u_120
				v_u_45.Events[("%*_TASKFINISHED"):format(v_u_120)]:Fire(...)
			end
			v_u_121.Finished.Fire = v132
			v_u_121.End = v_u_121.Stop
			v_u_121.Kill = v_u_121.Stop
			local v133 = v_u_45.Threads.Tasks
			local v134 = v_u_121
			v_u_39.insert(v133, v134)
			v_u_45.Threads.CheckTasks()
			return v_u_121.Resume, v_u_121
		end,
		["RunTask"] = function(p135, p136, ...)
			-- upvalues: (ref) v_u_45
			local v137, v138 = v_u_45.Threads.NewTask(p135, p136)
			return v138, v137(...)
		end,
		["TimeoutRunTask"] = function(p139, p140, p141, ...)
			-- upvalues: (ref) v_u_45
			local v142, v143 = v_u_45.Threads.NewTask(p139, p140, p141)
			return v143, v142(...)
		end,
		["WaitTask"] = function(p144, p145, ...)
			-- upvalues: (ref) v_u_45, (copy) v_u_32
			local v146, v147 = v_u_45.Threads.NewTask(p144, p145)
			local v148 = { v146(...) }
			v147.Finished:wait()
			return v147, v_u_32(v148)
		end,
		["NewEventTask"] = function(p_u_149, p_u_150, p_u_151)
			-- upvalues: (ref) v_u_45
			return function(...)
				-- upvalues: (ref) v_u_45, (copy) p_u_149, (copy) p_u_150, (copy) p_u_151
				return not v_u_45.Running and function() end or v_u_45.Threads.NewTask(p_u_149, p_u_150, p_u_151)(...)
			end
		end,
		["Stop"] = v_u_18.yield,
		["Wait"] = v_u_18.yield,
		["Pause"] = v_u_18.yield,
		["Yield"] = v_u_18.yield,
		["Status"] = v_u_18.status,
		["Running"] = v_u_18.running,
		["Create"] = v_u_18.create,
		["Start"] = v_u_18.resume,
		["Get"] = v_u_18.running,
		["New"] = function(p152)
			-- upvalues: (copy) v_u_18, (ref) v_u_45, (copy) v_u_39
			local v153 = v_u_18.create(p152)
			local v154 = v_u_45.Threads.Threads
			v_u_39.insert(v154, v153)
			return v153
		end,
		["End"] = function(p155)
			-- upvalues: (ref) v_u_45
			while p155 and v_u_45.Threads.Status(p155) ~= "dead" do
				v_u_45.Threads.Stop(p155)
				v_u_45.Threads.Resume(p155)
				if not p155 or v_u_45.Threads.Status(p155) == "dead" then
					return
				end
			end
		end,
		["Wrap"] = function(p156, ...)
			-- upvalues: (ref) v_u_45
			local v157 = v_u_45.Threads.New(p156)
			v_u_45.Threads.Resume(p156, ...)
			return v157
		end,
		["Resume"] = function(p158, ...)
			-- upvalues: (copy) v_u_18
			if p158 and v_u_18.status(p158) == "suspended" then
				return v_u_18.resume(p158, ...)
			end
		end,
		["Remove"] = function(p159)
			-- upvalues: (ref) v_u_45, (copy) v_u_39
			v_u_45.Threads.Stop(p159)
			for v160, v161 in v_u_45.Threads.Threads do
				if v161 == p159 then
					v_u_39.remove(v_u_45.Threads.Threads, v160)
				end
			end
		end,
		["StopAll"] = function()
			-- upvalues: (ref) v_u_45, (copy) v_u_39
			for v162, v163 in v_u_45.Threads.Threads do
				v_u_45.Threads.Stop(v163)
				v_u_39.remove(v_u_45.Threads.Threads, v162)
			end
		end,
		["ResumeAll"] = function()
			-- upvalues: (ref) v_u_45
			for _, v164 in v_u_45.Threads.Threads do
				v_u_45.Threads.Resume(v164)
			end
		end,
		["GetAll"] = function()
			-- upvalues: (ref) v_u_45
			return v_u_45.Threads.Threads
		end
	}
	local v_u_201 = {
		["WrapIgnore"] = function(p166)
			-- upvalues: (ref) v_u_1, (copy) v_u_17
			return v_u_17(p166, {
				["__metatable"] = v_u_1.Core and v_u_1.Core.DebugMode and "Ignore" or nil
			})
		end,
		["CheckWrappers"] = function()
			-- upvalues: (copy) v_u_64, (ref) v_u_45
			for v167, _ in v_u_64 do
				if v_u_45.IsDestroyed(v167) then
					v_u_64[v167] = nil
				end
			end
		end,
		["Wrapped"] = function(p168)
			-- upvalues: (copy) v_u_16, (copy) v_u_40, (copy) v_u_28, (copy) v_u_20
			return (v_u_40((v_u_16(p168))) == "table" and v_u_28(v_u_16(p168), "__ADONIS_WRAPPED") or v_u_16(p168) == "Adonis_Proxy") and true or ((v_u_40(p168) == "table" or v_u_20(p168) == "userdata") and (p168.IsProxy and p168:IsProxy()) and true or false)
		end,
		["UnWrap"] = function(p169)
			-- upvalues: (copy) v_u_20, (ref) v_u_45
			local v170 = v_u_20(p169)
			if v170 == "Instance" then
				return p169
			elseif v170 == "table" then
				local v171 = v_u_45.UnWrap
				local v172 = {}
				for v173, v174 in p169 do
					v172[v173] = v171(v174)
				end
				return v172
			elseif v_u_45.Wrapped(p169) then
				return p169:GetObject()
			else
				return p169
			end
		end,
		["Wrap"] = function(p_u_175, p176)
			-- upvalues: (copy) v_u_16, (copy) v_u_64, (copy) v_u_40, (ref) v_u_45, (copy) v_u_17, (copy) v_u_20, (copy) v_u_34, (copy) v_u_63, (copy) v_u_39, (copy) v_u_32, (ref) v_u_10, (copy) v_u_35, (ref) v_u_1
			local v_u_177 = p176
			if not v_u_177 then
				if p176 == nil then
					v_u_177 = client ~= nil
				else
					v_u_177 = false
				end
			end
			if v_u_16(p_u_175) == "Ignore" or v_u_16(p_u_175) == "ReadOnly_Table" then
				return p_u_175
			end
			if v_u_64[p_u_175] then
				return v_u_64[p_u_175]
			end
			if v_u_40(p_u_175) == "table" then
				local v178 = v_u_45.Wrap
				local v179 = v_u_17({}, {
					["__eq"] = function(_, _)
						-- upvalues: (copy) p_u_175
						return p_u_175
					end
				})
				for v180, v181 in p_u_175 do
					v179[v180] = v178(v181, v_u_177)
				end
				return v179
			end
			if v_u_20(p_u_175) ~= "Instance" and (v_u_20(p_u_175) ~= "RBXScriptSignal" and v_u_20(p_u_175) ~= "RBXScriptConnection") or v_u_45.Wrapped(p_u_175) then
				return p_u_175
			end
			local v_u_182 = v_u_45.UnWrap
			local v_u_183 = v_u_45.Wrap
			local v_u_185 = not v_u_177 and function(...)
				return ...
			end or function(p184)
				-- upvalues: (copy) v_u_183, (ref) v_u_177
				return v_u_183(p184, v_u_177)
			end
			local v_u_186 = v_u_34(true)
			local v_u_187 = v_u_16(v_u_186)
			local v_u_188 = nil
			v_u_188 = {
				["GetMetatable"] = function()
					-- upvalues: (copy) v_u_187
					return v_u_187
				end,
				["AddToCache"] = function()
					-- upvalues: (ref) v_u_64, (copy) p_u_175, (copy) v_u_186
					v_u_64[p_u_175] = v_u_186
				end,
				["RemoveFromCache"] = function()
					-- upvalues: (ref) v_u_64, (copy) p_u_175
					v_u_64[p_u_175] = nil
				end,
				["GetObject"] = function()
					-- upvalues: (copy) p_u_175
					return p_u_175
				end,
				["SetSpecial"] = function(_, p189, p190)
					-- upvalues: (ref) v_u_188
					v_u_188[p189] = p190
					return v_u_188
				end,
				["Clone"] = function(_, p191)
					-- upvalues: (copy) p_u_175, (ref) v_u_63, (ref) v_u_39, (copy) v_u_183
					local v192 = p_u_175:Clone()
					if not p191 then
						local v193 = v_u_63
						v_u_39.insert(v193, v192)
					end
					return v_u_183(v192)
				end,
				["IsWrapped"] = function()
					return true
				end,
				["Connect"] = function(_, p_u_194)
					-- upvalues: (copy) v_u_185, (copy) p_u_175, (ref) v_u_39, (copy) v_u_183, (ref) v_u_32
					return v_u_185(p_u_175:Connect(function(...)
						-- upvalues: (ref) v_u_39, (copy) p_u_194, (ref) v_u_183, (ref) v_u_32
						local v195 = v_u_39.pack(...)
						return p_u_194(v_u_32(v_u_183(v195), 1, v195.n))
					end))
				end,
				["Wait"] = function(_, ...)
					-- upvalues: (copy) v_u_185, (copy) p_u_175
					return v_u_185(p_u_175.Wait)(p_u_175, ...)
				end
			}
			v_u_188.connect = v_u_188.Connect
			v_u_188.wait = v_u_188.Wait
			function v_u_187.__index(_, p_u_196)
				-- upvalues: (ref) v_u_188, (copy) p_u_175, (ref) v_u_40, (ref) v_u_39, (copy) v_u_185, (ref) v_u_10, (copy) v_u_182, (ref) v_u_32
				local v197 = v_u_188[p_u_196] or p_u_175[p_u_196]
				if v_u_188[p_u_196] then
					return v_u_188[p_u_196]
				else
					return v_u_40(v197) == "function" and function(_, ...)
						-- upvalues: (ref) v_u_39, (ref) v_u_185, (ref) v_u_10, (copy) p_u_196, (ref) p_u_175, (ref) v_u_182, (ref) v_u_32
						local v198 = v_u_39.pack(...)
						return v_u_32(v_u_185({ v_u_10[p_u_196](p_u_175, v_u_32(v_u_182(v198), 1, v198.n)) }))
					end or v_u_185(v197)
				end
			end
			function v_u_187.__newindex(_, p199, p200)
				-- upvalues: (copy) p_u_175, (copy) v_u_182
				p_u_175[p199] = v_u_182(p200)
			end
			v_u_187.__eq = v_u_45.RawEqual
			function v_u_187.__tostring()
				-- upvalues: (ref) v_u_188, (copy) p_u_175, (ref) v_u_35
				return v_u_188.ToString or v_u_35(p_u_175)
			end
			v_u_187.__metatable = not (v_u_1.Core and v_u_1.Core.DebugMode) and "Adonis_Proxy" or nil
			v_u_187.__ADONIS_WRAPPED = true
			v_u_188:AddToCache()
			return v_u_186
		end
	}
	local v_u_453 = {
		["DeepCopy"] = function(p_u_202)
			-- upvalues: (copy) v_u_16, (copy) v_u_17, (copy) v_u_40, (ref) v_u_45
			local v204 = v_u_16(p_u_202) == nil and {} or (v_u_17({}, {
				["__index"] = function(_, p203)
					-- upvalues: (copy) p_u_202
					return p_u_202[p203]
				end
			}) or {})
			for v205, v206 in p_u_202 do
				if v_u_40(v206) == "table" then
					v204[v205] = v_u_45.DeepCopy(v206)
				else
					v204[v205] = v206
				end
			end
			return v204
		end,
		["Timer"] = function(p_u_207, p_u_208, p_u_209)
			-- upvalues: (copy) v_u_31, (ref) v_u_45
			local v_u_210 = v_u_31()
			local v_u_211 = nil
			v_u_211 = v_u_45.RunService.RenderStepped:Connect(function()
				-- upvalues: (ref) v_u_31, (copy) v_u_210, (copy) p_u_207, (copy) p_u_209, (copy) p_u_208, (ref) v_u_211
				if p_u_207 < v_u_31() - v_u_210 or p_u_209 and p_u_209() then
					p_u_208()
					v_u_211:Disconnect()
				end
			end)
		end,
		["ExtractLines"] = function(p212)
			-- upvalues: (copy) v_u_33
			return v_u_33.split(v_u_33.gsub(p212, "[%z\1-\t\11-\31]", ""), "\n")
		end,
		["Filter"] = function(p213, p_u_214, p_u_215)
			-- upvalues: (ref) v_u_45, (copy) v_u_39, (copy) v_u_24
			if not utf8.len(p213) then
				return "Filter Error"
			end
			local v_u_216 = v_u_45.ExtractLines(p213)
			local v217 = v_u_39.create(#v_u_216)
			for v_u_218 = 1, #v_u_216 do
				local v219, v220 = v_u_24(function()
					-- upvalues: (ref) v_u_45, (copy) v_u_216, (copy) v_u_218, (copy) p_u_214, (copy) p_u_215
					return v_u_45.TextService:FilterStringAsync(v_u_216[v_u_218], p_u_214.UserId):GetNonChatStringForUserAsync(p_u_215.UserId)
				end)
				v217[v_u_218] = v219 and v220 and v220 or (v_u_216[v_u_218] or "")
			end
			return v217 and v_u_39.concat(v217, "\n") or "Filter Error"
		end,
		["LaxFilter"] = function(p221, p222, p223)
			-- upvalues: (copy) v_u_36, (copy) v_u_40, (ref) v_u_45
			if v_u_36(p221) then
				return p221
			elseif v_u_40(p221) == "string" then
				if utf8.len(p221) then
					if p223 and #v_u_45.GetPlayers(p222, p221, {
						["DontError"] = true
					}) > 0 then
						return p221
					else
						return v_u_45.Filter(p221, p222, p222)
					end
				else
					return "Filter Error"
				end
			else
				return p221
			end
		end,
		["BroadcastFilter"] = function(p224, p_u_225)
			-- upvalues: (ref) v_u_45, (copy) v_u_39, (copy) v_u_24
			if not utf8.len(p224) then
				return "Filter Error"
			end
			local v_u_226 = v_u_45.ExtractLines(p224)
			local v227 = v_u_39.create(#v_u_226)
			for v_u_228 = 1, #v_u_226 do
				local v229, v230 = v_u_24(function()
					-- upvalues: (ref) v_u_45, (copy) v_u_226, (copy) v_u_228, (copy) p_u_225
					return v_u_45.TextService:FilterStringAsync(v_u_226[v_u_228], p_u_225.UserId):GetNonChatStringForBroadcastAsync()
				end)
				v227[v_u_228] = v229 and v230 and v230 or (v_u_226[v_u_228] or "")
			end
			return v227 and v_u_39.concat(v227, "\n") or "Filter Error"
		end,
		["RecursiveMtSearch"] = function(p231)
			-- upvalues: (copy) v_u_40, (copy) v_u_20, (copy) v_u_16, (ref) v_u_45
			for _, v232 in p231 do
				if (v_u_40(v232) == "table" or v_u_20(v232) == "userdata") and (v_u_16(v232) ~= nil or v_u_45.RecursiveMtSearch(v232)) then
					return true
				end
			end
			return false
		end,
		["MetaFunc"] = function(p_u_233, p_u_234, p_u_235)
			-- upvalues: (ref) v_u_45, (copy) v_u_24, (copy) v_u_39, (copy) v_u_22
			local v241 = {
				["__call"] = function(_, ...)
					-- upvalues: (copy) p_u_234, (ref) v_u_24, (ref) v_u_45, (copy) p_u_235, (ref) v_u_39, (copy) p_u_233, (ref) v_u_22
					if p_u_234 then
						local v238, v239 = v_u_24(function(...)
							-- upvalues: (ref) v_u_45, (ref) p_u_235
							if v_u_45.RecursiveMtSearch({ ... }) then
								return false
							end
							if p_u_235 then
								for v236, v237 in { ... } do
									if p_u_235[v236] and not p_u_235[v236](v237) then
										return false
									end
								end
							end
							return true
						end, ...)
						if not v238 or v239 == false then
							return nil
						end
					end
					local v240 = v_u_39.pack(v_u_24(p_u_233, ...))
					if v240[1] then
						return v_u_39.unpack(v240, 2)
					end
					v_u_22(v240[2])
				end
			}
			return v_u_45.NewProxy(v241)
		end,
		["NewProxy"] = function(p242)
			-- upvalues: (copy) v_u_34, (copy) v_u_16, (ref) v_u_1
			local v243 = v_u_34(true)
			local v244 = v_u_16(v243)
			v244.__metatable = not (v_u_1.Core and v_u_1.Core.DebugMode) and "Adonis_Proxy" or nil
			v244.__ADONIS_WRAPPED = true
			for v245, v246 in p242 do
				v244[v245] = v246
			end
			return v243
		end,
		["CountTable"] = function(p247)
			local v248 = 0
			for _ in p247 do
				v248 = v248 + 1
			end
			return v248
		end,
		["CompareTables"] = function(p249, p250)
			-- upvalues: (ref) v_u_45, (copy) v_u_19
			if v_u_45.CountTable(p249) ~= v_u_45.CountTable(p250) then
				return false
			end
			for v251, _ in p249 do
				if not v_u_19(p249[v251], p250[v251]) then
					return false
				end
			end
			return true
		end,
		["Debounce"] = function(p252, p253)
			-- upvalues: (copy) v_u_15, (copy) v_u_55, (copy) v_u_24, (copy) v_u_23
			local v254 = v_u_15(2)
			local v255 = v254 and v254._ADONIS_DEBOUNCES or (v_u_55 or {})
			if v254 then
				v254._ADONIS_DEBOUNCES = v254 and (v254._ADONIS_DEBOUNCES or {}) or {}
			end
			if v255[p252] then
				return false
			end
			v255[p252] = true
			local v256, v257 = v_u_24(p253)
			v255[p252] = false
			if not v256 then
				v_u_23(v257)
			end
		end,
		["Queue"] = function(p258, p259, p260, p261)
			-- upvalues: (copy) v_u_56, (ref) v_u_1, (copy) v_u_30, (ref) v_u_45, (copy) v_u_39
			if not v_u_56[p258] then
				v_u_56[p258] = {
					["Processing"] = false,
					["Functions"] = v_u_1.DLL and v_u_1.DLL.new() or {}
				}
			end
			local v262 = v_u_56[p258]
			local v263 = {
				["Time"] = v_u_30.time(),
				["Running"] = false,
				["Function"] = p259,
				["Timeout"] = p260,
				["Finished"] = false
			}
			local v264
			if p261 then
				v264 = v_u_45.Signal.new()
			else
				v264 = p261
			end
			v263.Yield = v264
			if v262.Functions.__meta == "DLL" then
				v262.Functions:AddEnd(v263)
			else
				local v265 = v262.Functions
				v_u_39.insert(v265, v263)
			end
			if not v262.Processing then
				v_u_45.TrackTask(("Thread: QueueProcessor_%*"):format(p258), v_u_45.ProcessQueue, false, v262, p258)
			end
			if p261 and not v263.Finished then
				return v263.Yield:Wait()
			end
		end,
		["ProcessQueue"] = function(p266, p_u_267)
			-- upvalues: (ref) v_u_45, (copy) v_u_39, (copy) v_u_43, (copy) v_u_22, (copy) v_u_25, (copy) v_u_56
			if p266 then
				if p266.Processing then
					return "Processing"
				end
				local v_u_268 = p266.Functions
				local v269 = v_u_268.__meta == "DLL"
				local v_u_270 = v_u_45.Signal.new()
				local function v272()
					-- upvalues: (copy) v_u_268, (ref) v_u_39
					local v271 = v_u_268[1]
					v_u_39.remove(v_u_268, 1)
					return v271
				end
				p266.Processing = true
				while v269 and v_u_268.count > 0 or not v269 and v_u_268[1] ~= nil do
					local v_u_273
					if v269 then
						v_u_273 = v_u_268:RemoveNode(v_u_268.snode)
					else
						v_u_273 = v272()
					end
					v_u_273.Running = true
					if v_u_273.Timeout then
						v_u_43.delay(v_u_273.Timeout, function()
							-- upvalues: (copy) v_u_273, (copy) v_u_270, (ref) v_u_22, (copy) p_u_267
							if not v_u_273.Finished then
								v_u_270:Fire()
								v_u_22((("Queue Timeout Reached for %*"):format(p_u_267 or "Unknown")))
								if v_u_273.Yield then
									v_u_273.Yield:Fire(false, "Timeout Reached")
								end
							end
						end)
					end
					v_u_45.TrackTask(("Thread: %*_QueuedFunction"):format(p_u_267 or "Unknown"), function()
						-- upvalues: (ref) v_u_25, (copy) v_u_273, (ref) v_u_22, (copy) p_u_267, (copy) v_u_270
						local v275, v276 = v_u_25(v_u_273.Function, function(p274)
							-- upvalues: (ref) v_u_273, (ref) v_u_22, (ref) p_u_267
							v_u_273.Error = p274
							v_u_22((("Queue Error: %*: %* \n %*"):format(p_u_267, p274, (debug.traceback()))))
						end)
						v_u_273.Running = false
						v_u_273.Finished = true
						if v_u_273.Yield then
							v_u_273.Yield:Fire(v275, v276)
						end
						v_u_270:Fire()
					end, false)
					if v_u_273.Running then
						v_u_270:Wait()
					end
				end
				v_u_270:Destroy()
				p266.Processing = false
				if p_u_267 then
					v_u_56[p_u_267] = nil
				end
			end
		end,
		["ProcessLoopQueue"] = function()
			-- upvalues: (copy) v_u_58, (copy) v_u_31
			for v277, v278 in v_u_58 do
				if not v278.LastRun or v278.LastRun and v_u_31() - v278.LastRun > v278.Delay then
					if v278.MaxRuns and (v278.NumRuns and v278.MaxRuns <= v278.NumRuns) then
						v_u_58[v277] = nil
					else
						if v278.MaxRuns and v278.NumRuns then
							v278.NumRuns = v278.NumRuns + 1
						end
						Pcall(v278.Function)
						v278.LastRun = v_u_31()
					end
				end
			end
		end,
		["QueueItem"] = function(p279, p280)
			-- upvalues: (copy) v_u_58
			if p280.MaxRuns then
				p280.NumRuns = 0
			end
			v_u_58[p279] = p280
		end,
		["RemoveQueue"] = function(p281)
			-- upvalues: (copy) v_u_58
			v_u_58[p281] = nil
		end,
		["New"] = function(p282, p283, p284, p285)
			-- upvalues: (copy) v_u_65, (copy) v_u_73, (copy) v_u_40, (ref) v_u_45, (copy) v_u_63, (copy) v_u_39
			local v286 = p284 and v_u_65(p282) or v_u_73.new(p282)
			if p283 then
				if v_u_40(p283) == "table" then
					local v287 = p283.Parent
					if v_u_45.Wrapped(v287) then
						v287 = v287:GetObject()
					end
					p283.Parent = nil
					for v288, v289 in p283 do
						v286[v288] = v289
					end
					if v287 then
						v286.Parent = v287
					end
				elseif v_u_40(p283) == "userdata" then
					if v_u_45.Wrapped(p283) then
						v286.Parent = p283:GetObject()
					else
						v286.Parent = p283
					end
				end
			end
			if v286 and not p285 then
				local v290 = v_u_63
				v_u_39.insert(v290, v286)
			end
			return v286
		end,
		["Iterate"] = function(p291, p292)
			-- upvalues: (copy) v_u_40, (copy) v_u_29, (copy) v_u_23
			if p291 and v_u_40(p291) == "table" then
				for v293, v294 in p291 do
					local v295 = p292(v293, v294)
					if v295 ~= nil then
						return v295
					end
				end
				return
			elseif p291 and v_u_40(p291) == "userdata" then
				for v296, v297 in v_u_29(p291:GetChildren()) do
					local v298 = p292(v297, v296)
					if v298 ~= nil then
						return v298
					end
				end
			else
				v_u_23("Invalid table")
			end
		end,
		["EscapeControlCharacters"] = function(p299)
			-- upvalues: (copy) v_u_33
			return v_u_33.gsub(p299, "%c", {
				["\7"] = "\\a",
				["\8"] = "\\b",
				["\f"] = "\\f",
				["\n"] = "\\n",
				["\r"] = "\\r",
				["\t"] = "\\t",
				["\11"] = "\\v"
			})
		end,
		["UnsanitizeXML"] = function(p300)
			-- upvalues: (copy) v_u_33
			return v_u_33.gsub(p300, "&%w+;", {
				["&apos;"] = "\'",
				["&quot;"] = "\"",
				["&lt;"] = "<",
				["&gt;"] = ">",
				["&amp;"] = "&"
			})
		end,
		["SanitizeXML"] = function(p301)
			-- upvalues: (copy) v_u_33
			return v_u_33.gsub(p301, "[\'\"<>&]", {
				["\'"] = "&apos;",
				["\""] = "&quot;",
				["<"] = "&lt;",
				[">"] = "&gt;",
				["&"] = "&amp;"
			})
		end,
		["SanitizePattern"] = function(p302)
			-- upvalues: (copy) v_u_33
			return v_u_33.gsub(p302, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
		end,
		["GetCurrentLocale"] = function()
			-- upvalues: (ref) v_u_45, (ref) v_u_51
			if not v_u_45.RunService:IsClient() then
				return "en-us"
			end
			local v303 = v_u_45.LocalizationService.RobloxLocaleId
			local v304 = v_u_45.LocalizationService.SystemLocaleId
			local v305 = v_u_51
			if v305 then
				v303 = v305
			elseif v303 == "en-us" or (v303 == "en" or not v303) then
				v303 = (v304 == "" or not v304) and "en-us" or v304
			end
			return v303
		end,
		["GetTime"] = v_u_30.time,
		["FormatTime"] = function(p306, p307)
			-- upvalues: (ref) v_u_45, (copy) v_u_24
			local v308 = p307 == true and {
				["WithDate"] = true
			} or (p307 or {})
			local v309 = v308.FormatString or (v308.WithWrittenDate and "LL HH:mm:ss" or (v308.WithDate and "L HH:mm:ss" or "HH:mm:ss"))
			local v310 = DateTime.fromUnixTimestamp(p306 or v_u_45.GetTime())
			local v311, v312 = v_u_24(v310.FormatLocalTime, v310, v309, v_u_45.RunService:IsClient() and v_u_45.GetCurrentLocale() or "en-gb")
			if v311 then
				return v312
			else
				return v310:ToIsoDate()
			end
		end,
		["FormatPlayer"] = function(p313, p314)
			if not p313 then
				return "%UNKNOWN%"
			end
			if p313.Name == "[Unknown User]" then
				return ("[Unknown User%*]"):format((not p313.UserId or p313.UserId == -1) and "" or (" %*"):format(p313.UserId))
			end
			local v315
			if p313.DisplayName == p313.Name then
				v315 = ("@%*"):format(p313.Name)
			else
				v315 = ("%* (%*)"):format(p313.DisplayName or "???", p313.Name or "???")
			end
			if p314 then
				v315 = v315 .. ("[%*]"):format((not p313.UserId or p313.UserId == -1) and "?" or p313.UserId)
			end
			return v315
		end,
		["FormatNumber"] = function(p316, p317, p318)
			-- upvalues: (copy) v_u_36, (copy) v_u_21, (copy) v_u_35, (copy) v_u_32, (copy) v_u_33, (ref) v_u_45, (copy) v_u_39
			local v319 = v_u_36(p316)
			local v320 = p318 or ","
			if v319 then
				if v_u_21.abs(v319) >= 1e150 then
					return "Inf"
				else
					local v321, v322 = v_u_32(v_u_35((v_u_21.abs(v319))):split("."))
					if p317 and v_u_21.abs(v319) >= 1000 then
						local v323 = {
							"K",
							"M",
							"B",
							"T",
							"Qd",
							"Qi"
						}
						local v324 = (#v321 - 1) / 3
						local v325 = v_u_21.floor(v324)
						local v326 = v323[v325]
						if v326 then
							return v_u_36(v_u_33.format("%.2f", v319 / 10 ^ (v325 * 3))) .. v326
						else
							return v_u_45.FormatNumber(v319 / 10 ^ (#v323 * 3), false, v320) .. v323[#v323]
						end
					else
						local v327 = v321:reverse()
						local v328 = v_u_39.create
						local v329 = #v327
						local v330 = (#v327 - 1) / 3
						local v331 = v328(v329 + v_u_21.floor(v330))
						for v332 = 1, #v327 do
							if v332 % 3 == 1 and v332 ~= 1 then
								v_u_39.insert(v331, v320)
							end
							v_u_39.insert(v331, v327:sub(v332, v332))
						end
						return ("%*%*%*"):format(v319 < 0 and "-" or "", v_u_39.concat(v331):reverse(), v322 and (".%*"):format(v322) or "")
					end
				end
			else
				return "NaN"
			end
		end,
		["GetProductInfo"] = function(p333, p334)
			-- upvalues: (copy) v_u_36, (copy) v_u_42, (copy) v_u_49, (copy) v_u_21, (copy) v_u_30, (copy) v_u_24, (ref) v_u_45, (copy) v_u_40, (copy) v_u_39
			local v335 = v_u_36(p333) or 0
			local v336 = p334 or v_u_42.InfoType.Asset
			if v335 > 0 then
				local v337 = v_u_49[("%*-%*"):format(v335, v336)]
				if not v337 then
					v337 = {
						["results"] = {
							["Created"] = false
						},
						["lastUpdated"] = -v_u_21.huge
					}
					v_u_49[("%*-%*"):format(v335, v336)] = v337
				end
				if not v337.lastUpdated or v_u_30.clock() - v337.lastUpdated > 120 then
					local v338, v339 = v_u_24(v_u_45.MarketplaceService.GetProductInfo, v_u_45.MarketplaceService, v335, v336)
					if v338 and v_u_40(v339) == "table" then
						v339.Created = true
						v337.results = v339
					else
						v337.results.Created = false
					end
				end
				return v_u_39.clone(v337.results)
			end
		end,
		["CheckPassOwnership"] = function(p340, p341)
			-- upvalues: (copy) v_u_40, (copy) v_u_36, (copy) v_u_46, (copy) v_u_30, (copy) v_u_24, (ref) v_u_45, (copy) v_u_53
			local v_u_342
			if v_u_40(p340) == "userdata" then
				v_u_342 = p340.UserId
			else
				v_u_342 = v_u_36(p340)
			end
			local v_u_343 = v_u_36(p341)
			local v344 = ("%*-%*"):format(v_u_342, v_u_343)
			local v345 = v_u_46[v344]
			if v345 and v345.owned then
				return true
			end
			if v345 and v_u_30.time() - v345.lastUpdated > 60 or not v345 then
				local v346 = {
					["owned"] = v345 and v345.owned or false,
					["lastUpdated"] = v_u_30.time()
				}
				v_u_46[v344] = v346
				local v347, v348 = v_u_24(function()
					-- upvalues: (ref) v_u_45, (ref) v_u_342, (ref) v_u_343
					return v_u_45.MarketplaceService:UserOwnsGamePassAsync(v_u_342, v_u_343)
				end)
				if not v347 then
					return v346.owned
				end
				v346.owned = v_u_53(v348)
				return v_u_53(v348)
			end
			if v345 then
				return v345.owned
			end
		end,
		["CheckAssetOwnership"] = function(p_u_349, p_u_350)
			-- upvalues: (copy) v_u_40, (ref) v_u_45, (copy) v_u_47, (copy) v_u_30, (copy) v_u_46, (copy) v_u_24, (copy) v_u_53
			if v_u_40(p_u_349) == "number" then
				p_u_349 = v_u_45.Players:GetPlayerByUserId(p_u_349)
			end
			local v351 = ("%*-%*"):format(p_u_349.UserId, p_u_350)
			local v352 = v_u_47[v351]
			if v352 and v352.owned then
				return true
			end
			if v352 and v_u_30.time() - v352.lastUpdated > 60 or not v352 then
				local v353 = {
					["owned"] = v352 and v352.owned or false,
					["lastUpdated"] = v_u_30.time()
				}
				v_u_46[v351] = v353
				local v354, v355 = v_u_24(function()
					-- upvalues: (ref) v_u_45, (ref) p_u_349, (copy) p_u_350
					return v_u_45.MarketplaceService:PlayerOwnsAsset(p_u_349, p_u_350)
				end)
				if v354 then
					v353.owned = v_u_53(v355)
				end
				return v353.owned
			end
			if v352 then
				return v352.owned
			end
		end,
		["CheckSubscriptionStatus"] = function(p_u_356, p_u_357)
			-- upvalues: (copy) v_u_40, (ref) v_u_45, (copy) v_u_48, (copy) v_u_30, (copy) v_u_24, (copy) v_u_53
			if v_u_40(p_u_356) == "number" then
				p_u_356 = v_u_45.Players:GetPlayerByUserId(p_u_356)
			end
			local v358 = ("%*-%*"):format(p_u_356.UserId, p_u_357)
			local v359 = v_u_48[v358]
			if v359 and v359.owned then
				return true
			end
			if v359 and v_u_30.time() - v359.lastUpdated > 60 or not v359 then
				local v360 = {
					["owned"] = v359 and v359.owned or false,
					["lastUpdated"] = v_u_30.time()
				}
				v_u_48[v358] = v360
				local v361, v362 = v_u_24(function()
					-- upvalues: (ref) v_u_45, (ref) p_u_356, (copy) p_u_357
					return v_u_45.MarketplaceService:GetUserSubscriptionStatusAsync(p_u_356, p_u_357)
				end)
				if v361 then
					v360.owned = v_u_53(v362.IsSubscribed)
				end
				return v360.owned
			end
			if v359 then
				return v359.owned
			end
		end,
		["GetGroupInfo"] = function(p363)
			-- upvalues: (copy) v_u_36, (copy) v_u_50, (copy) v_u_30, (copy) v_u_24, (ref) v_u_45, (copy) v_u_40, (copy) v_u_39
			local v364 = v_u_36(p363) or 0
			if v364 > 0 then
				local v365 = v_u_50[v364]
				if not v365 or v_u_30.time() - v365.lastUpdated > 120 then
					v365 = {
						["results"] = v365 and v365.results or {},
						["lastUpdated"] = v_u_30.time()
					}
					v_u_50[v364] = v365
					local v366, v367 = v_u_24(v_u_45.GroupService.GetGroupInfoAsync, v_u_45.GroupService, v364)
					if v366 and v_u_40(v367) == "table" then
						v365.results = v367
					else
						v365.results.Failed = true
					end
				end
				return v_u_39.clone(v365.results)
			end
		end,
		["GetGroupCreatorId"] = function(p368)
			-- upvalues: (copy) v_u_36, (ref) v_u_45
			local v369 = v_u_36(p368) or 0
			if v369 > 0 then
				local v370 = v_u_45.GetGroupInfo(v369)
				if v370 and v370.Owner then
					return v370.Owner.Id
				end
			end
			return 0
		end,
		["MaxLen"] = function(p371, p372)
			-- upvalues: (copy) v_u_33, (copy) v_u_26
			local v373 = v_u_33.len(p371)
			local v374
			if v373 <= p372 * 6 then
				v374 = utf8.len(p371)
			else
				v374 = false
			end
			if p372 >= v373 or v374 and v374 <= p372 then
				return p371
			end
			local v375 = 1
			if v374 then
				p372 = utf8.offset(p371, p372 + 1) - 1 or p372
			end
			local v376 = v_u_33.sub(p371, v375, p372)
			local v377 = "%*..."
			if not utf8.len(v376) then
				local v378 = v_u_26(2, utf8.len(v376)) - 1
				v376 = v_u_33.sub(v376, 1, v378) or v376
			end
			return v377:format(v376)
		end,
		["StartLoop"] = function(p379, p_u_380, p_u_381, p382)
			-- upvalues: (copy) v_u_14, (copy) v_u_60, (copy) v_u_36, (copy) v_u_43, (ref) v_u_45
			local v_u_383 = ("%* - %*"):format(p379, (v_u_14:GetService("HttpService"):GenerateGUID(false)))
			local v_u_384 = {
				["Name"] = p379,
				["Delay"] = p_u_380,
				["Function"] = p_u_381,
				["Running"] = true
			}
			local function v_u_385()
				-- upvalues: (copy) v_u_384, (ref) v_u_60, (copy) v_u_383
				v_u_384.Running = true
				if v_u_60[v_u_383] == v_u_384 then
					v_u_60[v_u_383] = nil
				end
			end
			local function v386()
				-- upvalues: (copy) p_u_380, (ref) v_u_36, (copy) p_u_381, (ref) v_u_43, (ref) v_u_60, (copy) v_u_383, (copy) v_u_384, (copy) v_u_385, (ref) v_u_45
				if v_u_36(p_u_380) then
					repeat
						p_u_381()
						v_u_43.wait((v_u_36(p_u_380)))
					until v_u_60[v_u_383] ~= v_u_384 or not v_u_384.Running
					v_u_385()
					return
				elseif p_u_380 == "Heartbeat" then
					repeat
						p_u_381()
						v_u_45.RunService.Heartbeat:wait()
					until v_u_60[v_u_383] ~= v_u_384 or not v_u_384.Running
					v_u_385()
					return
				elseif p_u_380 == "RenderStepped" then
					repeat
						p_u_381()
						v_u_45.RunService.RenderStepped:wait()
					until v_u_60[v_u_383] ~= v_u_384 or not v_u_384.Running
					v_u_385()
					return
				elseif p_u_380 == "Stepped" then
					repeat
						p_u_381()
						v_u_45.RunService.Stepped:wait()
					until v_u_60[v_u_383] ~= v_u_384 or not v_u_384.Running
					v_u_385()
				else
					v_u_384.Running = false
				end
			end
			v_u_384.Kill = v_u_385
			v_u_60[v_u_383] = v_u_384
			if p382 then
				v_u_45.TrackTask(("Thread: Loop: %*"):format(p379), v386, false)
				return v_u_384
			else
				v_u_45.TrackTask(("Loop: %*"):format(p379), v386, false)
				return v_u_384
			end
		end,
		["StopLoop"] = function(p387)
			-- upvalues: (copy) v_u_60
			for _, v388 in v_u_60 do
				if p387 == v388.Function or p387 == v388.Name then
					v388.Running = false
				end
			end
		end,
		["IsLooped"] = function(p389)
			-- upvalues: (copy) v_u_60
			for _, v390 in v_u_60 do
				if p389 == v390.Function or p389 == v390.Name then
					return v390.Running
				end
			end
			return false
		end,
		["Immutable"] = function(...)
			-- upvalues: (copy) v_u_18
			local v391 = v_u_18.wrap(function(...)
				-- upvalues: (ref) v_u_18
				while true do
					v_u_18.yield(...)
				end
			end)
			v391(...)
			return v391
		end,
		["ReadOnly"] = function(p_u_392, p_u_393, p_u_394, p_u_395)
			-- upvalues: (ref) v_u_45, (ref) v_u_1, (copy) v_u_15, (copy) v_u_16, (copy) v_u_24, (copy) v_u_18, (copy) v_u_40, (copy) v_u_20, (ref) v_u_2, (copy) v_u_22, (copy) v_u_27
			local v_u_396 = not p_u_395
			if v_u_396 then
				v_u_396 = v_u_45.RunService:IsClient()
			end
			if v_u_1.Core and v_u_1.Core.DebugMode then
				v_u_396 = false
			end
			if v_u_396 then
				local v397 = v_u_45.Players.LocalPlayer
			end
			if v397 then
				local _ = v397.Kick
			end
			local v_u_398 = v_u_15().settings
			local v_u_399 = v_u_16
			local v_u_400 = v_u_15
			local v_u_401 = v_u_24
			local _ = v_u_18.resume
			local _ = v_u_18.create
			if v_u_396 then
				local v_u_402 = v_u_399(v_u_400())
			end
			return v_u_45.NewProxy({
				["__index"] = function(_, p403)
					-- upvalues: (ref) v_u_40, (ref) v_u_20, (ref) v_u_396, (copy) v_u_400, (ref) v_u_24, (copy) v_u_398, (ref) v_u_15, (copy) v_u_399, (ref) v_u_16, (copy) v_u_401, (copy) v_u_402, (ref) v_u_2, (copy) p_u_392, (copy) p_u_393, (ref) v_u_45, (copy) p_u_394, (copy) p_u_395
					local v404 = (v_u_40(p403) == "table" or (v_u_20(p403) == "userdata" or not p403)) and "Potentially dangerous index" or p403
					local v405 = v_u_396 and v_u_400
					if v405 then
						v405 = v_u_400(2)
					end
					local v406 = v_u_396
					if v406 then
						v406 = v_u_24(v_u_398)
					end
					if v_u_396 and (v406 or (v_u_400 ~= v_u_15 or (v_u_399 ~= v_u_16 or (v_u_401 ~= v_u_24 or (not v405 or (v_u_40(v405) ~= "table" or v_u_399(v405) ~= v_u_402)))))) then
						local v407 = v_u_2
						local v408 = "ReadError"
						local v409 = "Tampering with Client [read rt0001]"
						local v410 = "[%* %* %*]\n%*"
						local v411
						if v405 then
							v411 = v_u_399(v405)
						else
							v411 = v405
						end
						v407(v408, v409, (v410:format(v404, v405, v411, (debug.traceback()))))
						return
					elseif p_u_392[v404] == nil or (v_u_40(p_u_392[v404]) ~= "table" or p_u_393 and (p_u_393[v404] or p_u_393[p_u_392[v404]])) then
						return p_u_392[v404]
					else
						return v_u_45.ReadOnly(p_u_392[v404], p_u_393, p_u_394, p_u_395)
					end
				end,
				["__newindex"] = function(_, p412, p413)
					-- upvalues: (ref) v_u_40, (ref) v_u_20, (ref) v_u_396, (copy) v_u_400, (ref) v_u_24, (copy) v_u_398, (ref) v_u_15, (copy) v_u_399, (ref) v_u_16, (copy) v_u_401, (copy) v_u_402, (ref) v_u_2, (copy) p_u_393, (copy) p_u_392, (copy) p_u_394, (ref) v_u_22, (ref) v_u_27
					local v414 = (v_u_40(p412) == "table" or (v_u_20(p412) == "userdata" or not p412)) and "Potentially dangerous index" or p412
					local v415 = v_u_396 and v_u_400
					if v415 then
						v415 = v_u_400(2)
					end
					local v416 = v_u_396
					if v416 then
						v416 = v_u_24(v_u_398)
					end
					if v_u_396 and (v416 or (v_u_400 ~= v_u_15 or (v_u_399 ~= v_u_16 or (v_u_401 ~= v_u_24 or (not v415 or (v_u_40(v415) ~= "table" or v_u_399(v415) ~= v_u_402)))))) then
						local v417 = v_u_2
						local v418 = "ReadError"
						local v419 = "Tampering with Client [write wt0003]"
						local v420 = "[%* %* %*]\n%*"
						local v421
						if v415 then
							v421 = v_u_399(v415)
						else
							v421 = v415
						end
						v417(v418, v419, (v420:format(v414, v415, v421, (debug.traceback()))))
						return
					elseif p_u_393 and (p_u_393[v414] or p_u_393[p_u_392[v414]]) then
						v_u_27(p_u_392, v414, p413)
					else
						if p_u_394 then
							local v422 = v_u_2
							local v423 = "ReadError"
							local v424 = "Tampering with Client [write wt0005]"
							local v425 = "[%* %* %*]\n%*"
							local v426
							if v415 then
								v426 = v_u_399(v415)
							else
								v426 = v415
							end
							v422(v423, v424, (v425:format(v414, v415, v426, (debug.traceback()))))
						end
						v_u_22((("Something attempted to set index %* in a read-only table."):format(v414)))
					end
				end,
				["__metatable"] = not (v_u_1.Core and v_u_1.Core.DebugMode) and "ReadOnly_Table" or v_u_402
			})
		end,
		["Wait"] = function(p427)
			-- upvalues: (ref) v_u_45, (copy) v_u_36, (copy) v_u_41
			if p427 and p427 ~= "Stepped" then
				if p427 == "Heartbeat" then
					v_u_45.RunService.Heartbeat:wait()
				elseif p427 and v_u_36(p427) then
					v_u_41((v_u_36(p427)))
				end
			else
				v_u_45.RunService.Stepped:wait()
				return
			end
		end,
		["OrigRawEqual"] = v_u_19,
		["HasItem"] = function(p_u_428, p_u_429)
			-- upvalues: (copy) v_u_24
			return v_u_24(function()
				-- upvalues: (copy) p_u_428, (copy) p_u_429
				return p_u_428[p_u_429]
			end)
		end,
		["IsDestroyed"] = function(p_u_430)
			-- upvalues: (copy) v_u_40, (ref) v_u_45, (copy) v_u_24, (copy) v_u_14, (copy) v_u_33
			if v_u_40(p_u_430) == "userdata" and (v_u_45.HasItem(p_u_430, "Parent") and p_u_430.Parent == nil) then
				local v431, v432 = v_u_24(function()
					-- upvalues: (copy) p_u_430, (ref) v_u_14
					p_u_430.Parent = v_u_14
					p_u_430.Parent = nil
				end)
				if not v431 then
					return v432 and v_u_33.match(v432, "^The Parent property of (.*) is locked, current parent: NULL,") and true or false
				end
			end
			return false
		end,
		["OutfitCache"] = {},
		["UnallowedCache"] = {},
		["Insert"] = function(p433, p434)
			-- upvalues: (ref) v_u_45
			if not (v_u_45.UnallowedCache and v_u_45.UnallowedCache[p433]) then
				local v435 = v_u_45.InsertService:LoadAsset(p433)
				if p434 or (not v435:IsA("Model") or v435.Name ~= "Model") then
					return v435
				end
				local v436 = v435:GetChildren()[1]
				v436.Parent = v435.Parent
				v435:Destroy()
				return v436
			end
		end,
		["SecureAccessory"] = function(p437, p_u_438)
			-- upvalues: (ref) v_u_45, (copy) v_u_36, (copy) v_u_23, (copy) v_u_24
			if not p437.Character then
				return
			end
			local function v439()
				-- upvalues: (ref) v_u_45, (copy) p_u_438, (ref) v_u_36, (ref) v_u_23
				v_u_45.UnallowedCache[v_u_36(p_u_438)] = true
				v_u_23("Item not supported")
			end
			local v440, v441 = v_u_24(function()
				-- upvalues: (ref) v_u_45, (copy) p_u_438, (ref) v_u_36
				return v_u_45.Insert((v_u_36(p_u_438)))
			end)
			if not v440 then
				return v439()
			end
			if not v441 then
				return v439()
			end
			if not v441:IsA("Accoutrement") then
				return v439()
			end
			if not v441:FindFirstChild("Handle") then
				return v439()
			end
			if #v441:GetDescendants() > 250 then
				return v439()
			end
			v441.Name = "CustomAdonisAccessory"
			v441:SetAttribute("AssetId", p_u_438)
			local v442 = {
				"LuaSourceContainer",
				"Model",
				"Tool",
				"Hopperbin"
			}
			local v443 = {
				"Accoutrement",
				"BasePart",
				"SpecialMesh",
				"Attachment",
				"Weld",
				"WeldConstraint",
				"Motor6D",
				"Folder",
				"ValueBase",
				"ParticleEmitter",
				"Sparkles",
				"Fire"
			}
			for _, v444 in v441:GetDescendants() do
				if v444:IsA("BasePart") then
					v444.CanCollide = false
				end
			end
			for _, v445 in v441:GetDescendants() do
				local v446 = false
				for _, v447 in v442 do
					if v445:IsA(v447) then
						v446 = true
						break
					end
				end
				if v446 then
					return v439()
				end
			end
			for _, v448 in v441:GetDescendants() do
				local v449 = false
				for _, v450 in v443 do
					if v448:IsA(v450) then
						v449 = true
						break
					end
				end
				if not v449 then
					v448:Destroy()
				end
			end
			p437.Character.Humanoid:AddAccessory(v441)
		end,
		["GetPlayers"] = function()
			-- upvalues: (ref) v_u_45
			return v_u_45.Players:GetPlayers()
		end,
		["IsAdonisObject"] = function(p451)
			-- upvalues: (copy) v_u_63
			for _, v452 in v_u_63 do
				if v452 == p451 then
					return true
				end
			end
		end,
		["GetAdonisObjects"] = function()
			-- upvalues: (copy) v_u_63
			return v_u_63
		end
	}
	v_u_45 = v_u_17({
		["Variables"] = function()
			-- upvalues: (copy) v_u_62
			return v_u_62
		end,
		["Routine"] = v44,
		["Running"] = true,
		["Pcall"] = Pcall,
		["Threads"] = v165,
		["DataModel"] = v_u_14,
		["Font"] = Font,
		["WrapService"] = v66,
		["EventService"] = v69,
		["ThreadService"] = v67,
		["HelperService"] = v68,
		["MarketPlace"] = v_u_14:GetService("MarketplaceService"),
		["GamepassService"] = v_u_14:GetService("GamePassService"),
		["ChatService"] = v_u_14:GetService("Chat"),
		["Gamepasses"] = v_u_14:GetService("GamePassService"),
		["Delete"] = function(p454, p455)
			-- upvalues: (copy) v_u_14, (copy) v_u_24
			v_u_14:GetService("Debris"):AddItem(p454, p455 or 0)
			v_u_24(p454.Destroy, p454)
		end,
		["RbxEvent"] = function(p456, p457)
			-- upvalues: (copy) v_u_57, (copy) v_u_39
			local v458 = p456:Connect(p457)
			local v459 = v_u_57
			v_u_39.insert(v459, v458)
			return v458
		end,
		["SelfEvent"] = function(p460, p_u_461)
			-- upvalues: (ref) v_u_45
			v_u_45.RbxEvent(p460, function(...)
				-- upvalues: (copy) p_u_461
				p_u_461(...)
			end)
		end,
		["DelRbxEvent"] = function(p462)
			-- upvalues: (copy) v_u_57, (copy) v_u_39
			for v463, v464 in v_u_57 do
				if v464 == p462 then
					v464:Disconnect()
					v_u_39.remove(v_u_57, v463)
				end
			end
		end,
		["SanitizeString"] = function(p465)
			-- upvalues: (copy) v_u_33, (ref) v_u_45
			return v_u_33.gsub(v_u_45.Trim(p465), "[%c%z\n]", "")
		end,
		["Trim"] = function(p466)
			-- upvalues: (copy) v_u_33
			return v_u_33.match(p466, "^%s*(.-)%s*$")
		end,
		["Localize"] = function(p467, p468)
			-- upvalues: (ref) v_u_45, (copy) v_u_40
			local v469 = v_u_45.Localize
			local v470 = v_u_45.ReadOnly
			if v_u_40(p467) ~= "table" then
				return p467
			end
			local v471 = {}
			for v472 in p467 do
				v471[v472] = v469(p467[v472], p468)
			end
			if p468 then
				v471 = v470(v471) or v471
			end
			return v471
		end,
		["RawEqual"] = function(p473, p474)
			-- upvalues: (ref) v_u_45
			return v_u_45.UnWrap(p473) == v_u_45.UnWrap(p474)
		end,
		["CheckProperty"] = function(p_u_475, p_u_476)
			-- upvalues: (copy) v_u_24
			return v_u_24(function()
				-- upvalues: (copy) p_u_475, (copy) p_u_476
				return p_u_475[p_u_476]
			end)
		end,
		["NewWaiter"] = function()
			-- upvalues: (ref) v_u_45
			local v477 = v_u_45.New("BindableEvent")
			return {
				["Wait"] = v477.wait,
				["Finish"] = v477.Fire
			}
		end
	}, {
		["__index"] = function(_, p_u_478)
			-- upvalues: (copy) p_u_12, (copy) v_u_201, (copy) v_u_114, (copy) v_u_453, (copy) v_u_24, (copy) v_u_14, (ref) v_u_45
			local v479 = p_u_12 and p_u_12[p_u_478] or v_u_201[p_u_478] or (v_u_114[p_u_478] or v_u_453[p_u_478])
			if v479 then
				return v479
			end
			local v481, v482 = v_u_24(function()
				-- upvalues: (ref) v_u_14, (copy) p_u_478, (ref) v_u_45
				local v480 = v_u_14:GetService(p_u_478)
				if client ~= nil then
					v480 = v_u_45.Wrap(v480, true) or v480
				end
				return v480
			end)
			if v481 and v482 then
				v_u_45[p_u_478] = v482
				return v482
			end
		end,
		["__tostring"] = function()
			return "Service"
		end,
		["__metatable"] = not (v_u_1.Core and v_u_1.Core.DebugMode) and "Service" or nil
	})
	local v483 = v_u_201.Wrap(v66)
	local v484 = v_u_201.Wrap(v68)
	local v485 = v_u_201.Wrap(v67)
	local v486 = v_u_201.Wrap(v69)
	v_u_45.WrapService = v483
	v_u_45.HelperService = v484
	v_u_45.ThreadService = v485
	v_u_45.EventService = v486
	v_u_45.Signal = v38((v_u_1.Shared or (v_u_1.Folder or Folder).Parent.Shared).GoodSignal)
	local v_u_487, v_u_488
	if client == nil then
		v_u_487 = v_u_51
		v_u_488 = v_u_45
	else
		v_u_487 = v_u_51
		v_u_488 = v_u_45
		for v489, v490 in v_u_45 do
			if v_u_40(v490) == "userdata" then
				v_u_488[v489] = v_u_488.Wrap(v490, true)
			end
		end
	end
	for v491, v_u_492 in v_u_201 do
		if v_u_40(v_u_492) == "function" then
			v483:SetSpecial(v491, function(_, ...)
				-- upvalues: (copy) v_u_492
				return v_u_492(...)
			end)
		else
			v483:SetSpecial(v491, v_u_492)
		end
	end
	for v493, v_u_494 in v_u_453 do
		if v_u_40(v_u_494) == "function" then
			v484:SetSpecial(v493, function(_, ...)
				-- upvalues: (copy) v_u_494
				return v_u_494(...)
			end)
		else
			v484:SetSpecial(v493, v_u_494)
		end
	end
	for v495, v_u_496 in v165 do
		if v_u_40(v_u_496) == "function" then
			v485:SetSpecial(v495, function(_, ...)
				-- upvalues: (copy) v_u_496
				return v_u_496(...)
			end)
		else
			v485:SetSpecial(v495, v_u_496)
		end
	end
	for v497, v_u_498 in v_u_114 do
		if v_u_40(v_u_498) == "function" then
			v486:SetSpecial(v497, function(_, ...)
				-- upvalues: (copy) v_u_498
				return v_u_498(...)
			end)
		else
			v486:SetSpecial(v497, v_u_498)
		end
	end
	for v_u_499, v500 in {
		["WrapService"] = v483,
		["EventService"] = v486,
		["ThreadService"] = v485,
		["HelperService"] = v484
	} do
		v500:SetSpecial("ClassName", v_u_499)
		v500:SetSpecial("ToString", v_u_499)
		v500:SetSpecial("IsA", function(_, p501)
			-- upvalues: (copy) v_u_499
			return p501 == v_u_499
		end)
	end
	if v_u_488.RunService:IsClient() then
		v_u_43.spawn(v_u_25, function()
			-- upvalues: (ref) v_u_488, (ref) v_u_487
			local v_u_502 = v_u_488.LocalizationService:GetTranslatorForPlayerAsync(v_u_488.Players.LocalPlayer)
			v_u_502:GetPropertyChangedSignal("LocaleId"):Connect(function()
				-- upvalues: (ref) v_u_487, (copy) v_u_502
				v_u_487 = v_u_502.LocaleId
			end)
		end, v_u_22)
	end
	if server ~= nil then
		v_u_488.StartLoop("AssetCacheCheck", 360, function()
			-- upvalues: (copy) v_u_46, (copy) v_u_47, (copy) v_u_48, (copy) v_u_49, (copy) v_u_50, (copy) v_u_40, (copy) v_u_30
			for _, v503 in {
				v_u_46,
				v_u_47,
				v_u_48,
				v_u_49,
				v_u_50
			} do
				for v504, v505 in v503 do
					if v_u_40(v505) == "table" and (v_u_40(v505.lastUpdated) == "number" and v_u_30.time() - v505.lastUpdated > 300) then
						v503[v504] = nil
					end
				end
			end
		end, true)
	end
	return v_u_488
end
