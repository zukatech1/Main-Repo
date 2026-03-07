client = nil
service = nil
Pcall = nil
Routine = nil
GetEnv = nil
origEnv = nil
logError = nil
log = nil
return function(p_u_1, p_u_2)
	local v3 = p_u_2(nil, {
		["script"] = script
	})
	setfenv(1, v3)
	local v_u_4 = _G
	local v_u_5 = game
	local v6 = script
	local v_u_7 = getfenv
	local v_u_8 = setfenv
	local _ = workspace
	local v_u_9 = getmetatable
	local v_u_10 = setmetatable
	local _ = loadstring
	local _ = coroutine
	local _ = rawequal
	local _ = typeof
	local v_u_11 = print
	local _ = math
	local v_u_12 = warn
	local v_u_13 = error
	local _ = pcall
	local _ = xpcall
	local _ = select
	local v_u_14 = rawset
	local v_u_15 = rawget
	local v_u_16 = ipairs
	local v_u_17 = pairs
	local v_u_18 = next
	local _ = Rect
	local _ = Axes
	local _ = os
	local _ = time
	local _ = Faces
	local _ = unpack
	local _ = string
	local _ = Color3
	local _ = newproxy
	local v_u_19 = tostring
	local v_u_20 = tonumber
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
	local v_u_21 = require
	local v_u_22 = table
	local v_u_23 = type
	local _ = wait
	local _ = Enum
	local _ = UDim
	local _ = UDim2
	local _ = Vector2
	local _ = Vector3
	local _ = Region3
	local _ = CFrame
	local _ = Ray
	local _ = delay
	local v_u_24 = p_u_1.Service
	local v_u_25 = p_u_1.Client
	local v_u_26 = nil
	local v_u_27 = nil
	local v_u_28 = nil
	local v_u_29 = nil
	local v_u_30 = nil
	local v_u_31 = nil
	local v_u_32 = nil
	local v_u_33 = nil
	local function v35(p34)
		-- upvalues: (ref) v_u_31, (copy) v_u_25, (ref) v_u_26, (ref) v_u_27, (ref) v_u_32, (ref) v_u_28, (ref) v_u_29, (ref) v_u_30, (ref) v_u_33
		v_u_31 = v_u_25.UI
		v_u_26 = v_u_25.Anti
		v_u_27 = v_u_25.Core
		v_u_32 = v_u_25.Variables
		v_u_28 = v_u_25.Functions
		v_u_29 = v_u_25.Process
		v_u_30 = v_u_25.Remote
		v_u_33 = v_u_25.Typechecker
		v_u_27.Name = "\0"
		v_u_27.Special = v_u_25.DepsName
		v_u_27.MakeGui = v_u_31.Make
		v_u_27.GetGui = v_u_31.Get
		v_u_27.RemoveGui = v_u_31.Remove
		if p34.DebugMode == true then
			v_u_27.DebugMode = true
		end
		v_u_27.Init = nil
	end
	local function v36(_)
		-- upvalues: (ref) v_u_27
		v_u_27.GetEvent()
		v_u_27.RunAfterPlugins = nil
	end
	local function v37()
		-- upvalues: (copy) v_u_24, (ref) v_u_27
		if v_u_24.NetworkClient then
			v_u_24.TrackTask("Thread: API Manager", v_u_27.StartAPI)
		end
		v_u_27.RunLast = nil
	end
	v_u_7().client = nil
	v_u_7().service = nil
	v_u_7().script = nil
	v_u_25.Core = {
		["Init"] = v35,
		["RunLast"] = v37,
		["RunAfterPlugins"] = v36,
		["Name"] = v6.Name,
		["Special"] = v6.Name,
		["ScriptCache"] = {},
		["GetEvent"] = function()
			-- upvalues: (ref) v_u_27, (copy) v_u_24, (copy) v_u_25, (ref) v_u_26, (ref) v_u_29, (copy) v_u_12, (ref) v_u_30
			if v_u_27.RemoteEvent then
				log("Disconnect old RemoteEvent")
				for _, v38 in v_u_27.RemoteEvent.Events do
					v38:Disconnect()
				end
				v_u_27.RemoteEvent = nil
			end
			log("Getting RemoteEvent")
			local v_u_39 = {}
			local v40 = v_u_24.ReplicatedStorage
			local v_u_41 = v40:WaitForChild(v_u_25.RemoteName, 300)
			if v_u_41 then
				log("Getting RemoteFunction")
				local v42 = v_u_41:WaitForChild("__FUNCTION", 120)
				if v42 then
					local v43 = {}
					v42.OnClientInvoke = v_u_29.Remote
					v_u_39.Object = v_u_41
					v_u_39.Function = v42
					v_u_39.FireServer = v_u_41.FireServer
					v_u_39.Events = v43
					v43.ProcessRemote = v_u_41.OnClientEvent:Connect(v_u_29.Remote)
					v43.ParentChildRemoved = v40.ChildRemoved:Connect(function(p44)
						-- upvalues: (ref) v_u_27, (copy) v_u_39, (copy) v_u_41, (ref) v_u_12
						if v_u_27.RemoteEvent == v_u_39 and (p44 == v_u_41 and task.wait()) then
							v_u_12("::ADONIS:: REMOTE EVENT REMOVED? RE-GRABBING")
							log("~! REMOTEEVENT WAS REMOVED?")
							v_u_27.GetEvent()
						end
					end)
					v_u_27.RemoteEvent = v_u_39
					if not v_u_27.Key then
						log("~! Getting key from server")
						v_u_27.Key = v_u_30.Get((("%*GET_KEY"):format(v_u_25.DepsName)))
						if v_u_27.Key then
							v_u_25.Finish_Loading()
							return
						end
						v_u_30.Fire((("%*GET_KEY"):format(v_u_25.DepsName)))
					end
				else
					v_u_26.Detected("Kick", "RemoteFunction Not Found")
				end
			else
				v_u_26.Detected("Kick", "RemoteEvent Not Found")
				return
			end
		end,
		["DebugMode"] = v_u_25.DebugMode,
		["LoadPlugin"] = function(p45)
			-- upvalues: (copy) v_u_21, (copy) v_u_8, (copy) p_u_2, (copy) v_u_7
			local v46 = v_u_21(p45)
			local v47 = v_u_8(v46, p_u_2(v_u_7(v46)))
			task.spawn(Pcall, v47)
		end,
		["LoadBytecode"] = function(p48, p49)
			-- upvalues: (copy) v_u_21, (copy) v_u_25
			return v_u_21(v_u_25.Shared.FiOne, true)(p48, p49)
		end,
		["LoadCode"] = function(p50, p51)
			-- upvalues: (ref) v_u_27
			return v_u_27.LoadBytecode(p50, p51)
		end,
		["StartAPI"] = function()
			-- upvalues: (ref) v_u_27, (copy) v_u_25, (ref) v_u_30, (copy) v_u_24, (copy) v_u_4, (copy) v_u_10, (copy) v_u_23, (copy) v_u_11, (copy) v_u_13, (copy) v_u_17, (copy) v_u_16, (copy) v_u_12, (copy) v_u_18, (copy) v_u_22, (copy) v_u_14, (copy) v_u_15, (copy) v_u_7, (copy) v_u_8, (copy) v_u_21, (copy) v_u_19, (copy) v_u_9, (ref) v_u_32, (ref) v_u_28, (copy) v_u_5, (ref) v_u_33, (copy) p_u_1, (copy) v_u_20
			local v_u_52 = v_u_27.ScriptCache
			local v_u_53 = v_u_25.Shared.FiOne
			local v_u_54 = v_u_30.Get
			local _ = v_u_30.GetFire
			local v_u_55 = v_u_25.G_API
			local v_u_56 = v_u_25.Allowed_API_Calls
			local v57 = v_u_24.NewProxy
			local v58 = v_u_24.ReplicatedStorage
			local v_u_59 = v_u_24.MetaFunc
			local _ = v_u_24.ReadOnly
			local v60 = v_u_24.StartLoop
			local v61 = v_u_24.ReadOnly
			local v_u_62 = v_u_24.UnWrap
			local v_u_63 = v_u_24
			local v_u_64 = v_u_25
			local v_u_65 = v_u_4
			local v_u_66 = v_u_10
			local v_u_67 = v_u_23
			local v_u_68 = v_u_11
			local v_u_69 = v_u_13
			local v_u_70 = v_u_16
			local v_u_71 = v_u_12
			local v_u_72 = v_u_22
			local v_u_73 = v_u_14
			local v_u_74 = v_u_15
			local v_u_75 = v_u_7
			local v_u_76 = v_u_8
			local v_u_77 = v_u_21
			local _ = Routine
			local _ = Pcall
			local v_u_78 = {}
			v_u_76(1, (v_u_66({}, {
				["__metatable"] = v_u_9(v_u_75())
			})))
			local v_u_79 = {
				["API_Specific"] = {
					["Test"] = function()
						-- upvalues: (copy) v_u_68
						v_u_68("We ran the api specific stuff")
					end
				},
				["Service"] = v_u_63
			}
			local v_u_93 = {
				["Access"] = v_u_63.MetaFunc(function(...)
					-- upvalues: (ref) v_u_32, (copy) v_u_76, (copy) v_u_75, (ref) v_u_9, (copy) v_u_66, (copy) v_u_79, (copy) v_u_64, (copy) v_u_67, (ref) v_u_28, (ref) v_u_5, (copy) v_u_63, (copy) v_u_78, (copy) v_u_69
					if v_u_32.G_Access_Key then
						local v80 = { ... }
						local v81 = v80[1]
						local v82 = v80[2]
						local v_u_83 = nil
						v_u_76(1, (v_u_66({}, {
							["__metatable"] = v_u_9(v_u_75())
						})))
						if v_u_79[v82] then
							v_u_83 = v_u_79[v82]
						elseif v_u_64[v82] and v_u_64.Allowed_API_Calls[v82] then
							v_u_83 = v_u_64[v82]
						end
						local v84 = v_u_64.G_Access and (v_u_67(v81) == "string" and v_u_28.SHA256(v81 .. v_u_5.GameId) == v_u_32.G_Access_Key and v_u_83)
						if v84 then
							v84 = v_u_64.Allowed_API_Calls[v82]
						end
						assert(v84, "Incorrect key or G_Access is disabled")
						if v_u_67(v_u_83) == "table" then
							local v86 = {
								["__index"] = function(_, p85)
									-- upvalues: (ref) v_u_83, (ref) v_u_78, (ref) v_u_67, (ref) v_u_64, (ref) v_u_63, (ref) v_u_69
									if (v_u_83[p85] == nil or v_u_78[p85] ~= nil) and v_u_78[p85] ~= true then
										if v_u_78[p85] == false then
											v_u_69((("Access Denied: %*"):format(p85)))
										else
											v_u_69((("Could not find %*"):format(p85)))
										end
									elseif v_u_83[p85] == nil or (v_u_67(v_u_83[p85]) ~= "table" or v_u_64.G_Access_Perms ~= "Read") then
										return v_u_83[p85]
									else
										return v_u_63.ReadOnly(v_u_83[p85])
									end
								end,
								["__newindex"] = function(_, _, _)
									-- upvalues: (ref) v_u_69
									v_u_69("Read-only")
								end,
								["__metatable"] = true
							}
							return v_u_63.NewProxy(v86)
						end
					end
				end, true, { v_u_33.string, v_u_33.string }),
				["Scripts"] = v61({
					["ExecutePermission"] = v_u_59(function(p87, p88)
						-- upvalues: (copy) v_u_52, (copy) v_u_62, (copy) v_u_54, (copy) v_u_77, (copy) v_u_53, (copy) v_u_72
						local v89 = nil
						for _, v90 in v_u_52 do
							if v_u_62(v90.Script) == p87 then
								v89 = v90
							end
						end
						if v89 and (v89.noCache ~= true and (not v89.runLimit or v89.runLimit and v89.Executions <= v89.runLimit)) then
							v89.Executions = v89.Executions + 1
							return v89.Source, v89.Loadstring
						end
						local v91 = v_u_54("ExecutePermission", p87, p88, true)
						if v91 and v91.Source then
							local v92
							if v89 then
								v92 = v89.Loadstring
								v89.Source = v91.Source
							else
								v92 = v_u_77(v_u_53:Clone(), true)
								v_u_72.insert(v_u_52, {
									["Script"] = p87,
									["Source"] = v91.Source,
									["Loadstring"] = v92,
									["noCache"] = v91.noCache,
									["runLimit"] = v91.runLimit,
									["Executions"] = v91.Executions
								})
							end
							return v91.Source, v92
						end
					end, true, { v_u_33.instanceOf("LocalScript"), v_u_33.string })
				}, nil, nil, true)
			}
			if v_u_27.DebugMode == true then
				local v_u_94 = {
					["Env"] = p_u_1
				}
				v_u_93.Debug = v_u_94
				local v_u_95 = {}
				local function v_u_99(p96)
					-- upvalues: (ref) v_u_20, (copy) v_u_95, (ref) p_u_1, (copy) v_u_70
					if v_u_20(p96) and v_u_95[p96] then
						return v_u_95[p96], true
					end
					local v97 = p_u_1
					for _, v98 in v_u_70((p96:split("/.\\"))) do
						v97 = v97[v98]
					end
					return v97, false
				end
				local v100 = v58:FindFirstChild("Adonis_Debug_API")
				if v100 then
					function v100.OnInvoke(p101, ...)
						-- upvalues: (copy) v_u_72, (copy) v_u_67, (copy) v_u_99, (ref) v_u_9, (copy) v_u_63, (copy) v_u_95, (copy) v_u_62, (copy) v_u_94
						local v102 = v_u_72.unpack(...)
						if p101 == "RunEnvFunc" then
							local v103 = v102[1]
							if v103 and v_u_67(v103) == "string" then
								local v104, _ = v_u_99(v103)
								return v104(v_u_72.unpack(v102, 2, v102.n))
							end
						elseif p101 == "GetEnvTableMeta" then
							local v105 = v102[1]
							if v105 and v_u_67(v105) == "string" then
								local v106, _ = v_u_99(v105)
								return v_u_9(v106)
							end
						elseif p101 == "RunEnvTableMetaFunc" then
							local v107 = v102[1]
							local v108 = v102[2]
							if v107 and v_u_67(v107) == "string" then
								local v109, _ = v_u_99(v107)
								local v110 = v_u_9(v109)[v108](v109, v_u_72.unpack(v102, 3, v102.n))
								local v111 = v_u_63.HttpService:GenerateGUID(false)
								v_u_95[v111] = v110
								return v_u_62(v110), v111
							end
						elseif p101 == "GetApi" or not p101 then
							return v_u_94
						end
					end
				end
			end
			local v_u_113 = v57({
				["__index"] = function(_, p112)
					-- upvalues: (copy) v_u_93, (copy) v_u_55, (copy) v_u_56, (copy) v_u_67, (copy) v_u_59, (copy) v_u_69
					if p112 == "Scripts" then
						return v_u_93.Scripts
					elseif v_u_55 and v_u_56.Client == true then
						if v_u_67(v_u_93[p112]) == "function" then
							return v_u_59(v_u_93[p112])
						else
							return v_u_93[p112]
						end
					else
						v_u_69("_G API is disabled")
						return
					end
				end,
				["__newindex"] = function()
					-- upvalues: (copy) v_u_69
					v_u_69("Read-only")
				end,
				["__metatable"] = "API"
			})
			if not v_u_74(v_u_65, "Adonis") then
				if not v_u_72.isfrozen(v_u_65) then
					v_u_73(v_u_65, "Adonis", v_u_113)
					v60("APICheck", 1, function()
						-- upvalues: (copy) v_u_65, (copy) v_u_74, (copy) v_u_113, (copy) v_u_72, (copy) v_u_73, (copy) v_u_71
						if v_u_74(v_u_65, "Adonis") ~= v_u_113 then
							if not v_u_72.isfrozen(v_u_65) then
								v_u_73(v_u_65, "Adonis", v_u_113)
								return
							end
							v_u_71("\226\154\160\239\184\143 ADONIS CRITICAL WARNING! MALICIOUS CODE IS TRYING TO CHANGE THE ADONIS _G API AND IT CAN\'T BE SET BACK! PLEASE SHUTDOWN THE SERVER AND REMOVE THE MALICIOUS CODE IF POSSIBLE! 0x02412")
						end
					end, true)
					return
				end
				v_u_71("The _G table was locked and the Adonis _G API could not be loaded. Error code 0x02417")
			end
		end
	}
end
