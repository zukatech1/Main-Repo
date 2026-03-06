local v0 = "?"
local v1 = false
do
    local l_v1_0 = v1
    pcall(function()
        l_v1_0 = true
        local v3 = "nil  nil  "
        local v4 = "qwertyuiopasdfghjklzxcvbnm098765"
        local l_UserGameSettings_0 = UserSettings():GetService("UserGameSettings")
        if not l_UserGameSettings_0:GetTutorialState(v3) then
            v0 = ""
            local v6 = ({
                wait()
            })[1] * 1000000
            local v19 = (function(v7)
                local v8 = 1103515245
                local v9 = 12345
                local v10 = 99999999
                local v12 = v7 % 2147483648
                local v13 = 1
                return function(v14, v15)
                    local l_v10_0 = v10
                    local v17 = v8 * v12 + v9
                    local v18 = v17 % l_v10_0 + v13
                    v13 = v13 + 1
                    v12 = v18
                    v9 = v17 % 4858 * (l_v10_0 % 5782)
                    return v14 + v18 % v15 - v14 + 1
                end
            end)(v6 - v6 % 1)
            l_UserGameSettings_0:SetTutorialState(v3, true)
            local v20 = 0
            for _ = 1, 16 do
                local v22 = 0
                local v23 = 1
                for _ = 1, 5 do
                    local v25 = v19(10, 20) > 15
                    l_UserGameSettings_0:SetTutorialState(v3 .. v20, v25)
                    v22 = v22 + (v25 and 1 or 0) * v23
                    v23 = v23 * 2
                    v20 = v20 + 1
                end
                v0 = v0 .. v4:sub(v22 + 1, v22 + 1)
            end
        else
            local v26 = 0
            v0 = ""
            for _ = 1, 16 do
                local v28 = 0
                local v29 = 1
                for _ = 1, 5 do
                    v28 = v28 + (l_UserGameSettings_0:GetTutorialState(v3 .. v26) and 1 or 0) * v29
                    v29 = v29 * 2
                    v26 = v26 + 1
                end
                v0 = v0 .. v4:sub(v28 + 1, v28 + 1)
            end
        end
    end)
    while not l_v1_0 do
        -- empty block
    end
end
v1 = os.clock()
if devsignature_sig then
    print("        Luarmor (aka Luauth) - Lua whitelist service developed by Federal#9999\n        This is a signature - If you are seeing this, you know what not to do :3\n        Have a good day!\n        https://luarmor.net/ - Lua wl service by Federal#9999\n    ")
end
local v31
local v32
local v33
local v34
local v35
local v36
local v37
local v38
local v39
local v40
local v41 = false
local v42 = "?"
local v43 = "?"
local v44 = 0
local l_huge_0 = math.huge
local v46 = "Not specified"
local v48
local v49
local l_floor_0 = math.floor
local l_random_0 = math.random
local l_remove_0 = table.remove
local l_char_0 = string.char
local v54 = 0
local v55 = 2
local v56 = {}
local v57 = {}
local v58 = 0
local v59 = {}
for v60 = 1, 256 do
    v59[v60] = v60
end
repeat
    local v61 = l_remove_0(v59, (l_random_0(1, #v59)))
    v57[v61] = l_char_0(v61 - 1)
until #v59 == 0
local v62 = {}
do
    local l_l_floor_0_0, l_v54_0, l_v55_0, l_v57_0, l_v62_0 = l_floor_0, v54, v55, v57, v62
    local function v76()
        if #l_v62_0 == 0 then
            l_v54_0 = (l_v54_0 * 169 + 7579774851987) % 35184372088832
            repeat
                l_v55_0 = l_v55_0 * 27 % 257
            until l_v55_0 ~= 1
            local v68 = l_v55_0 % 32
            local v69 = l_l_floor_0_0(l_v54_0 / 2 ^ (13 - (l_v55_0 - v68) / 32)) % 4294967296 / 2 ^ v68
            local v70 = l_l_floor_0_0(v69 % 1 * 4294967296) + l_l_floor_0_0(v69)
            local v71 = v70 % 65536
            local v72 = (v70 - v71) / 65536
            local v73 = v71 % 256
            local v74 = (v71 - v73) / 256
            local v75 = v72 % 256
            l_v62_0 = {
                v73,
                v74,
                v75,
                (v72 - v75) / 256
            }
        end
        return table.remove(l_v62_0)
    end
    local v77 = {}
    v49 = v77
    v48 = function(v78, v79)
        local l_v77_0 = v77
        if not l_v77_0[v79] then
            l_v62_0 = {}
            local l_l_v57_0_0 = l_v57_0
            l_v54_0 = v79 % 35184372088832
            l_v55_0 = v79 % 255 + 2
            local v82 = #v78
            l_v77_0[v79] = ""
            local v83 = 180
            for v84 = 1, v82 do
                v83 = (string.byte(v78, v84) + v76() + v83) % 256
                l_v77_0[v79] = l_v77_0[v79] .. l_l_v57_0_0[v83 + 1]
            end
        end
        return v79
    end
end
l_floor_0 = LUARMOR_SkipAntidebugDevMode
l_random_0 = LUARMOR_AllowKeyCheckSkip
l_remove_0 = ff97f23b97f93792992999 and ff97f23b97f93792992999() == "j" or false
l_char_0 = "eu1-roblox-auth.luarmor.net"
v54 = l_fastload_enabled
v55 = os.time(os.date("*t")) - os.time(os.date("!*t"))
if v55 < 0 then
    v55 = (86400 + -(-v55 % 86400)) % 86400
else
    v55 = v55 % 86400
end
v56 = v55 / 3600
if v56 >= 21 or v56 < 5 then
    l_char_0 = ({
        "eu1-roblox-auth.luarmor.net",
        "eu2-roblox-auth.luarmor.net"
    })[math.random(1, 2)]
elseif v56 >= 5 and v56 < 15 then
    l_char_0 = ({
        "as1-roblox-auth.luarmor.net",
        "as2-roblox-auth.luarmor.net",
        "as3-roblox-auth.luarmor.net",
        "au1-roblox-auth.luarmor.net",
        "au2-roblox-auth.luarmor.net"
    })[math.random(1, 5)]
elseif v56 >= 15 and v56 < 21 then
    l_char_0 = ({
        "us1-roblox-auth.luarmor.net",
        "us2-roblox-auth.luarmor.net"
    })[math.random(1, 2)]
else
    game:GetService("Players").LocalPlayer:Kick("invalid timezone - send this screenshot to developer and Federal")
end
pcall(function()
    if game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(game:GetService("Players").LocalPlayer) == "AU" then
        l_char_0 = ({
            "au1-roblox-auth.luarmor.net",
            "au2-roblox-auth.luarmor.net"
        })[math.random(1, 2)]
    end
end)
v55 = {
    Version = "3.4",
    Host = l_remove_0 and LT_R_RRT_H or "https://" .. l_char_0,
    ScriptID = "2674ffd1c9054918b647386bab0ae9fc",
    ScriptVersion = "0001",
    Name = "TEST"
}
v56 = type(({
    ...
})[1]) ~= "table"
v57 = false
v58 = nil
v59 = nil
v62 = nil
local v85
local v86
local v87
local v88
local v89
local v90
local v91
local v92
local v93
local v94
local v95
local v96
local v97
local v98
local v99
local v100
local v101
local v102
local v103
local l_print_0 = print
local l_next_0 = next
local v106 = string.char
local v107 = true
local l_identifyexecutor_0 = identifyexecutor
local l_game_0 = game
local l_pcall_0 = pcall
local v111 = true
local v112 = string.gmatch
local v113 = debug.traceback
local l_tonumber_0 = tonumber
local l_setmetatable_0 = setmetatable
local l_rawget_0 = rawget
local l_wait_0 = wait
local v118 = debug.getinfo
local l_loadstring_0 = loadstring
local v120 = os.time
local v121 = string.byte
local v122 = string.sub
local l_spawn_0 = spawn
local v124 = game:GetService("RunService").Heartbeat
local v125 = os.clock
local l_rconsoleprint_0 = rconsoleprint
local v127 = math.huge
local l_tostring_0 = tostring
local l_pairs_0 = pairs
local v130 = string.find
local v131 = false
local function v134(v132, v133)
    l_loadstring_0("local t,r = ...\nspawn(function() while wait() do pcall(function() game:GetService(\"CoreGui\").RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = t\ngame:GetService(\"CoreGui\").RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = r end) end end)\ngame:GetService('Players').LocalPlayer:Kick(r)\n        ")(v132, v133)
    while l_wait_0() do
        -- empty block
    end
end
local v135 = {}
local v136 = false
local v137 = string.format
local v138 = string.sub
local v139 = table.concat
local l_type_0 = type
local l_l_pairs_0_0 = l_pairs_0
local l_l_wait_0_0 = l_wait_0
local v143 = coroutine.wrap
local v146 = syn and syn.websocket and syn.websocket.connect or WebSocket and WebSocket.connect or WebsocketClient and function(v144)
    local v145 = WebsocketClient.new(v144)
    v145:Connect()
    return v145
end
do
    local l_v137_0, l_v138_0, l_v139_0, l_l_type_0_0, l_l_l_pairs_0_0_0, l_l_l_wait_0_0_0, l_v143_0, l_v146_0 = v137, v138, v139, l_type_0, l_l_pairs_0_0, l_l_wait_0_0, v143, v146
    local function v155(v156)
        local v157 = {}
        for v158, v159 in l_l_l_pairs_0_0_0(v156) do
            v157[#v157 + 1] = l_v137_0("\"%s\":%s,", v158, l_l_type_0_0(v159) == "table" and v155(v159) or "\"" .. v159 .. "\"")
        end
        return "{" .. l_v138_0(l_v139_0(v157), 0, -2) .. "}"
    end
    local function v173(v160)
        local function v164(v161)
            if v161 == "PONG" then
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] [PONG] Server ---> Client \n")
                end
                v160.LastPong = tick()
                return
            else
                local v162 = string.match(v161, "|__(%d+)__|")
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] [RESPONSE] Server ---> Client: " .. v161 .. "\n")
                end
                if v162 then
                    local v163 = v160.Requests[v162 + 0]
                    assert(v163, "Internal Error: no event receiver")
                    v163:Fire(v161:gsub("|__(%d+)__|", ""))
                    return v163:Destroy()
                else
                    return v160.OnMessageSignal:Fire(v161)
                end
            end
        end
        local function v165()
            if v131 then
                l_rconsoleprint_0("[" .. os.clock() .. "] [CLOSED] ")
            end
            v160.__OBJECT_ACTIVE = false
            if v160.SocketClosed or v136 then
                if v131 then
                    l_rconsoleprint_0(" (ALREADY CLOSED)\n")
                end
                return
            else
                local v166 = 0
                local v167
                while true do
                    if v131 then
                        l_rconsoleprint_0("[" .. os.clock() .. "] Attempting to reconnect to wshttpemu\n")
                    end
                    local v168 = v120()
                    local v169 = false
                    local v170
                    v167 = nil
                    l_spawn_0(function()
                        local v171, v172 = l_pcall_0(l_v146_0, v160.Url)
                        v167 = v172
                        v170 = v171
                        v169 = true
                    end)
                    while not v169 and v120() < v168 + 8 do
                        l_l_l_wait_0_0_0()
                    end
                    if v131 then
                        l_rconsoleprint_0("[" .. os.clock() .. "] ######## L_PASS: d: " .. l_tostring_0(v169) .. ", ok: " .. l_tostring_0(v170) .. "\n")
                    end
                    if not v169 then
                        v57 = false
                        v166 = 10
                        warn("[2] Unable to connect (timeout)")
                    end
                    if not v170 then
                        v166 = v166 + 1
                        if v166 > 5 then
                            v57 = false
                        end
                        l_l_l_wait_0_0_0(v166 < 4 and 10 or 120)
                    else
                        break
                    end
                end
                v166 = 0
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] [CONNECT] Reconnected\n")
                end
                v160.__OBJECT_ACTIVE = true
                v160.Websocket = v167
                v57 = v160
                v167:Send(v155({
                    Opcode = "PING",
                    Data = {}
                }))
                l_pcall_0(function()
                    v167.OnClose:Connect(v165)
                    v167.OnMessage:Connect(v164)
                end)
                l_pcall_0(function()
                    v167.ConnectionClosed:Connect(v165)
                    v167.DataReceived:Connect(v164)
                end)
                return
            end
        end
        l_pcall_0(function()
            v160.Websocket.OnClose:Connect(v165)
            v160.Websocket.OnMessage:Connect(v164)
        end)
        l_pcall_0(function()
            v160.Websocket.DataReceived:Connect(v164)
            v160.Websocket.ConnectionClosed:Connect(v165)
        end)
        v160.LastPong = tick()
        while l_l_l_wait_0_0_0(10) do
            if v131 then
                l_rconsoleprint_0("[" .. os.clock() .. "] [PING] Client ---> Server\n")
            end
            if v160.__OBJECT_ACTIVE then
                v160.Websocket:Send(v155({
                    Opcode = "PING",
                    Data = {}
                }))
                if tick() - v160.LastPong > 20 then
                    if v131 then
                        l_rconsoleprint_0("[" .. os.clock() .. "] [WARN] Server timeout\n")
                    end
                    warn("Server timeout")
                    v160.Websocket:Close()
                end
            end
        end
    end
    v135.new = function(v174, v175)
        local v176 = {}
        l_setmetatable_0(v176, v174)
        v174.__index = v174
        local v177 = v120()
        local v178 = false
        local v179
        local v180
        l_spawn_0(function()
            local v181, v182 = l_pcall_0(l_v146_0, v175)
            v180 = v182
            v179 = v181
            v178 = true
        end)
        while not v178 and v120() < v177 + 8 do
            l_l_l_wait_0_0_0()
        end
        if not v178 then
            v57 = false
            error("Unable to connect to WS")
        end
        assert(v179, v180)
        v174.Websocket = v180
        v174.Url = v175
        v174.OnMessageSignal = Instance.new("BindableEvent")
        v174.OnMessage = v174.OnMessageSignal.Event
        v174.Requests = {}
        v174.__OBJECT_ACTIVE = true
        l_v143_0(v173)(v174)
        repeat
            v124:Wait()
        until v174.LastPong
        return v176
    end
    v135.request = function(v183, v184)
        if v131 then
            l_rconsoleprint_0("[" .. os.clock() .. "] [REQUEST] Client ---> Server, ObjectActive: " .. l_tostring_0(v183.__OBJECT_ACTIVE) .. "\n")
        end
        local v185 = 0
        while true do
            if true then
                v185 = v185 + 1
                l_l_l_wait_0_0_0(0.1)
                if v185 > 40 then
                    warn("[3] r_timeout")
                    v57 = false
                    return ""
                end
            else
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] [REQUEST] [!!!] OBJECT ACTIVE PASSED\n")
                end
                local v186 = math.random(1, 99999999)
                local v187 = Instance.new("BindableEvent")
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] Event assigned\n")
                end
                v183.Requests[v186] = v187
                v183.Websocket:Send(v155({
                    Opcode = "REQUEST",
                    Data = v184,
                    Id = v186
                }))
                if v131 then
                    l_rconsoleprint_0("[" .. os.clock() .. "] Packet sent!\n")
                end
                local v188 = false
                l_spawn_0(function()
                    l_l_l_wait_0_0_0(30)
                    if not v188 then
                        if v131 then
                            l_rconsoleprint_0("[" .. os.clock() .. "] !!!!!! ALERT !!!!!!!!! REQ TIMEOUT !!!!!!!!\n")
                        end
                        local v189 = v183.Requests[v186]
                        assert(v189, "Internal Error: no event receiver")
                        v189:Fire("")
                        if v131 then
                            l_rconsoleprint_0("[" .. os.clock() .. "] Responded with something empty\n")
                        end
                        return v189:Destroy()
                    else
                        return
                    end
                end)
                local v190 = v187.Event:Wait()
                v188 = true
                return v190
            end
        end
    end
    v135.close = function(v191)
        v191.SocketClosed = true
        v191.Websocket:Close()
    end
end
v101 = script_key or "none"
v93 = 0
v137 = false
do
    local l_v137_1 = v137
    l_spawn_0(function()
        l_v137_1 = true
        while not v95 do
            v93 = v93 + 1
            v124:Wait()
        end
    end)
    while not l_v137_1 do
        v124:Wait()
    end
    v94 = function()
        local l_v93_0 = v93
        while v93 == l_v93_0 do
            v124:Wait()
        end
    end
end
v91 = function(v194)
    if v194 then
        for _ = 1, 99999999 do
            for _ = 1, 99999999 do
                LPH_CRASH()
            end
        end
    end
    while l_wait_0() do
        -- empty block
    end
end
v90 = 1
v107 = syn and syn.request or request or http_request
if l_identifyexecutor_0 and ({
    l_identifyexecutor_0()
})[1] == "Synapse X" and not gethui and syn then
    v90 = 1
elseif l_identifyexecutor_0 and ({
    l_identifyexecutor_0()
})[1] == "ScriptWare" then
    v90 = ({
        l_identifyexecutor_0()
    })[2] == "Mac" and 5 or 2
elseif FLUXUS_LOADED or EVON_LOADED or WRD_LOADED or COMET_LOADED or OZONE_LOADED or TRIGON_LOADED then
    v90 = 4
elseif KRNL_LOADED then
    v90 = 3
elseif Electron_Loaded then
    v90 = 6
elseif l_identifyexecutor_0 and ({
    l_identifyexecutor_0()
})[1] == "Sirhurt" then
    v90 = 7
end
;(function(v197, v198)
    v89 = {}
    v88 = {}
    for v199 = 0, 255 do
        local v200 = v106(v199)
        v88[v199] = v200
        v88[v200] = v199
    end
    local l_v198_0 = v198
    for v202 = 1, #l_v198_0 do
        local v203 = l_v198_0[v202]
        v89[v202 - 1] = v203
        v89[v203] = v202 - 1
    end
end)(255, {
    "a",
    "b",
    "Q",
    "k",
    "O",
    "I",
    "1",
    "l",
    "0",
    "9",
    "E",
    "3",
    "J",
    "7",
    "G",
    "T"
})
v58 = function(v204)
    return v204 - v204 % 1
end
v62 = function(v205)
    local v206 = 1103515245
    local v207 = 12345
    local v208 = 99999999
    local v210 = v205 % 2147483648
    local v211 = 1
    return function(v212, v213)
        local l_v208_0 = v208
        local v215 = v206 * v210 + v207
        local v216 = v215 % l_v208_0 + v211
        v211 = v211 + 1
        v210 = v216
        v207 = v215 % 4859 * (l_v208_0 % 5781)
        return v212 + v216 % v213 - v212 + 1
    end
end
v59 = function(v217)
    for _ = 1, 2 do
        local v219 = v217 % 9915 + 4
        local v220
        local v221
        for v222 = 1, 3 do
            v220 = v217 % 4155 + 3
            if v222 % 2 == 1 then
                v220 = v220 + 522
            end
            v221 = v217 % 9996 + 1
            if v221 % 2 ~= 1 then
                v221 = v221 * 3
            end
        end
        local v223 = v217 % 9999995 + 1 + 13729
        local v224 = v217 % 1000
        local v225 = v58((v217 - v224) / 1000) % 1000
        local v226 = v224 * v225 + v223 + v217 % (419824125 - v223 + v224)
        local v227 = v217 % (v219 * v220 + 9999) + 13729
        v217 = (v226 + (v227 + (v224 * v220 + v225)) % 999999 * (v223 + v227 % v221)) % 99999999999
    end
    return v217
end
v87 = function(v228)
    l_print_0("[" .. v55.Name .. "]: " .. v228)
end
v85 = function(v229)
    local v230 = {}
    local v231 = {}
    local v232 = {}
    for v233 = 1, 13 do
        local v234 = {}
        local v235 = {}
        v230[v234] = v235
        v231[v235] = v233
        v232[v234] = v235
    end
    local v236 = 0
    local v237 = 0
    local v238 = 0
    if v229 then
        v230 = v229[1]
        v231 = v229[2]
        v232 = v229[3]
    end
    for v239, v240 in l_next_0, v230 do
        local v241 = v231[v240]
        if v232[v239] == v240 then
            v236 = v236 + 1
        end
        v238 = v238 + 1
        v237 = v238 % 2 == 0 and v237 * v241 or v237 + v241 + v238
    end
    if v236 ~= 13 then
        v86 = -1
    end
    v102 = {
        v230,
        v231,
        v232
    }
    v86 = v237
    return false
end
v137 = 68
v87("[1/3] Loading Luarmor client...")
v138 = nil
v86 = -1
v85()
while v86 == -1 do
    -- empty block
end
v138 = v62(v93 + v86)
if v90 == 1 or v90 == 2 then
    v139 = 0
    do
        local l_v139_1, l_l_type_0_1 = v139, l_type_0
        l_pcall_0(function()
            (function(v244)
                l_tostring_0(v244[1])
            end)(l_setmetatable_0({}, {
                __index = function(_, _)
                    local v247
                    v247 = function()
                        l_v139_1 = l_v139_1 + 1
                        return v247()
                    end
                    v247()
                end
            }))
        end)
        l_l_type_0_1 = 0
        l_pcall_0(function()
            v107(l_setmetatable_0({}, {
                __index = function(_, _)
                    local v250
                    v250 = function()
                        l_l_type_0_1 = l_l_type_0_1 + 1
                        return v250()
                    end
                    v250()
                end
            }))
        end)
        if l_l_type_0_1 + l_v139_1 < 20000 then
            if true then
                v137 = 19
            end
        elseif l_l_type_0_1 - l_v139_1 ~= 0 and true then
            v137 = 18
        end
    end
end
v111 = function(v251, v252, v253)
    local v254 = {
        Method = "GET"
    }
    if v252 then
        v254 = l_setmetatable_0(v254, {
            __index = function(_, v256)
                if v256 == "Url" then
                    local v257 = v112(v113(), "[^:]*:(%d+)")
                    local v258 = v257()
                    local v259 = v257()
                    local v260 = 1
                    l_pcall_0(function()
                        v260 = l_tonumber_0(v259) - l_tonumber_0(v258)
                    end)
                    if v90 == 1 and syn and (v260 ~= 0 or v258 ~= v259) then
                        v137 = 37
                        while v253 do
                            -- empty block
                        end
                    end
                    return v251
                else
                    return l_rawget_0(v254, v256)
                end
            end
        })
    else
        v254.Url = v251
    end
    local v261 = v107(v254)
    return v261.Body
end
v94()
v103 = function(_)
    -- empty block
end
v92 = function(v263)
    local v264 = false
    local v265 = {
        v118,
        l_setmetatable_0,
        l_tostring_0,
        [-1] = v90 == 3 and function()
            -- empty block
        end or v107,
        v106,
        v122,
        v121,
        v120,
        l_loadstring_0,
        l_pcall_0
    }
    local function v266()
        v264 = true
        return (" "):rep(16777215)
    end
    local v267 = l_setmetatable_0({}, {
        __tostring = function()
            v264 = true
            return (" "):rep(16777215)
        end
    })
    for v268, v269 in l_next_0, v265 do
        if v268 ~= -1 and false then
            v264 = true
        end
        if v269 ~= l_print_0 and v269 ~= l_tostring_0 then
            local l_l_print_0_0 = l_print_0
            local l_l_tostring_0_0 = l_tostring_0
            local l_error_0 = error
            local v273 = getfenv()
            v273.tostring = v266
            v273.error = v266
            v273.print = v266
            if v268 == -1 then
                if v90 ~= 5 then
                    l_pcall_0(v269, "")
                end
            else
                l_pcall_0(v269, v267)
            end
            v273.tostring = l_l_tostring_0_0
            v273.print = l_l_print_0_0
            v273.error = l_error_0
        end
    end
    if v264 then
        v137 = 85
        if v263 then
            v91(true)
        end
    end
end
v139 = v93
l_type_0 = nil
l_l_pairs_0_0, l_l_wait_0_0 = l_pcall_0(function()
    l_type_0 = v111(v55.Host .. "/status", false)
    local v274 = l_game_0:GetService("HttpService"):JSONDecode(l_type_0)
    if true then
        warn(v274.message)
        v91()
    end
    if not v274.versions[v55.Version] then
        warn("This script is outdated! Try using the latest version.")
        v91()
    end
    v55.Host = l_remove_0 and LT_R_RRT_H or "https://" .. l_char_0
    v99 = v274.versions[v55.Version]
end)
v94()
if not l_l_pairs_0_0 then
    v87("Failed to load Luarmor client. (Server responds with something unparsable)")
    error("Failed to load Luarmor client. (Server responds with something unparsable) --> " .. l_tostring_0(l_type_0))
    return
else
    v143 = false
    l_spawn_0(function()
        if not l_pcall_0(function()
            v57 = v135:new(l_remove_0 and LT_R_RRT_W or "wss://" .. l_char_0 .. ":443/wshttpemu")
        end) then
            v87("[INFO] Failed to connect to websocket, falling back to HTTP.")
            v57 = false
        end
        v143 = true
    end)
    v139 = v93 % 8585 * (v139 % 9910)
    v92()
    if v56 then
        v137 = 146
    end
    v87("[2/3] Connecting to server..")
    v146 = v62(v139 + v138(2, 4096))
    local v275 = {
        [1] = v146(100000, 1000000),
        [2] = v138(1111, 32768),
        [3] = v138(3333, 15625) + v93,
        [4] = v146(10000, 1000000)
    }
    local v276 = false
    v86 = -1
    v85()
    if v86 == -1 then
        v276 = true
        v86 = 100
    end
    local v277 = 0
    local v278 = 0
    local v279 = 0
    local v280 = 1
    local v281 = {
        [0] = 0
    }
    do
        local l_v277_0, l_v278_0, l_v279_0, l_v280_0, l_v281_0 = v277, v278, v279, v280, v281
        local function v292(v287, v288, v289)
            local v290 = v288 and v287 or v88[v287]
            if not v289 then
                v290 = (v290 + 4096 - l_v281_0[l_v277_0]) % 256
                l_v279_0 = l_v279_0 + v290
                l_v277_0 = (l_v277_0 + 1) % l_v280_0
            end
            local v291 = v290 % 16
            return v89[(v290 - v291) / 16] .. v89[v291]
        end
        v100 = function(v293)
            local v294 = 0
            for v295 = 1, #v293 do
                v294 = v294 + v121(v293, v295)
            end
            return v294
        end
        local function v299(v296, v297)
            local v298 = (v89[v122(v296, 1, 1)] * 16 + v89[v122(v296, 2, 2)] + l_v281_0[l_v278_0]) % 256
            l_v278_0 = (l_v278_0 + 1) % l_v280_0
            if v297 then
                return v298
            else
                return v88[v298]
            end
        end
        v97 = function(v300)
            local v301 = {}
            l_v278_0 = 0
            local v302 = 1
            repeat
                local v303 = v299(v122(v300, v302, v302 + 1), true)
                v302 = v302 + 2
                local v304 = ""
                for _ = 1, v303 do
                    v304 = v304 .. v299(v122(v300, v302, v302 + 1))
                    v302 = v302 + 2
                end
                v301[#v301 + 1] = v304
            until #v300 < v302
            return v301
        end
        v96 = function(v306, v307)
            local v308 = v292(#v306, true, v307)
            for v309 = 1, #v306 do
                v308 = v308 .. v292(v122(v306, v309, v309), false, v307)
            end
            return v308
        end
        v98 = function(v310, v311, v312)
            if v310 == 1 then
                l_v281_0 = v311
                l_v280_0 = v312
            elseif v310 == 2 then
                l_v277_0 = 0
                l_v279_0 = 0
            elseif v310 == 3 then
                return l_v279_0
            end
        end
    end
    v138 = v62(v138(2, 32768 + v120() % 2000) + v86 % 4096)
    v146 = v62(v146(1, 32768) + v93 + v120() % 1000)
    v277 = v138(111111, 999999)
    v278 = {}
    for v313 = 1, v277 % 30 + 1 do
        local v314
        if v313 == 2 then
            v314 = l_tostring_0
        elseif v313 == 8 then
            v314 = l_print_0
        elseif v313 == 17 then
            v314 = v122
        else
            v314 = function()
                -- empty block
            end
        end
        v278[v313] = v314
    end
    v279 = v146(111111, 999999) + 181
    v280 = v138(1, 1234) * v146(2, 1235) + v86 % 80000
    v281 = {
        [1] = v138(100000, 1000000),
        [2] = v146(100000, 1000000),
        [3] = v138(100000, 1000000)
    }
    if l_floor_0 or l_random_0 then
        v137 = 218
    end
    if v276 then
        v137 = 250
    end
    local v315 = ((((((v96("" .. v279) .. v96("" .. v59(8410 + v277) .. v59(v137 + v280) .. v59(v279 - 181))) .. v96(v280 .. "") .. v96("" .. v277)) .. v96(v275[3] + 19053 .. "")) .. v96("" .. v281[1]) .. v96("" .. 15411 + v275[4])) .. v96(v281[3] .. "") .. v96("" .. v275[2] + 181)) .. v96(v281[2] .. "") .. v96("" .. 8410 + v275[1])) .. v96(v0 and v0 or "?")
    v315 = v96(v59(v98(3) + 12268) .. "", true) .. v315
    local v316 = {}
    local v317 = v146(111111, 999999)
    local l_v86_0 = v86
    getfenv()[v316] = v317
    local v319 = v111(v55.Host .. "/" .. v99 .. "/auth/" .. v55.ScriptID .. "/init?t=" .. v315 .. "&v=" .. v55.ScriptVersion .. "&k=" .. v101, false)
    v86 = -1
    v85(v102)
    while v86 == -1 do
        -- empty block
    end
    local v320 = false
    local v321 = 0
    for v322, v323 in l_pairs_0(v278) do
        v321 = v322
        if v322 == 2 and v323 ~= l_tostring_0 then
            v137 = 147
        end
        if v322 == 8 and v323 ~= l_print_0 then
            v137 = 147
        end
        if v322 == 17 and v323 ~= v122 then
            v137 = 147
        end
    end
    if v321 ~= v277 % 30 + 1 then
        v137 = 147
    end
    if v137 == 147 then
        v320 = true
    end
    if v86 ~= l_v86_0 then
        v320 = true
        v137 = 100
    end
    if v319 == "err" then
        while true do
            -- empty block
        end
    end
    if v130(v319, "Old script, please use the latest version") and v54 then
        v54("flush")
        return
    else
        if v122(v319, 1, 1) == "!" then
            v321 = v319
            local v324 = "Whitelist Error"
            if string.find(v321, ";;lrm_is_diff_msg") then
                v324 = "You are blacklisted"
                v321 = v122(v319, 2, #v319 - 17)
            else
                v321 = v122(v319, 2, #v319)
            end
            v134(v324, v321)
            v91()
        end
        v275 = {
            [0] = v275[1] % 256,
            [1] = v275[2] % 256,
            [2] = v275[3] % 256,
            [3] = v275[4] % 256
        }
        v94()
        if getfenv()[v316] ~= v317 then
            v320 = true
            v137 = 100
        end
        v321 = 0
        local v325 = 1
        for _ = 1, 30 do
            if l_tostring_0({}) > l_tostring_0({}) then
                v325 = v325 + 1
            else
                v325 = v325 * 2
            end
            v325 = v325 % 10000
        end
        v321 = v325
        v98(1, v275, 4)
        v319 = v97(v319)
        v40 = v319[1] - v279
        v39 = v319[4] - v277
        v92()
        v98(1, {
            [0] = v275[0],
            [2] = v275[1],
            [4] = v275[2],
            [6] = v275[3],
            [1] = v319[9],
            [3] = v319[7],
            [5] = v319[2],
            [7] = v319[6]
        }, 8)
        v325 = v319[8] - v281[1]
        local v327 = v319[3] - v281[2]
        v33 = v319[5] - v281[3]
        v32 = v327
        v31 = v325
        v325 = "" .. v59(v281[3] + 8474) .. v59(v281[1] + 31) .. v59(v281[2] + 4491)
        if v319[11] == v325 and ({
            [v325] = true
        })[v319[11]] then
            v37 = true
            v41 = true
        else
            v325 = "" .. v59(v281[3] + 8474) .. v59(v281[1] + 69) .. v59(v281[2] + 4491)
            if v319[11] == v325 and ({
                [v325] = true
            })[v319[11]] then
                v37 = true
            end
        end
        if v37 then
            if l_tonumber_0(v319[14] and v319[14] or "-1") == -1 then
                l_huge_0 = v127
            end
            v44 = l_tonumber_0(v319[15] and v319[15] or "0")
            v46 = v319[16]
        end
        v86 = -1
        v85()
        if v86 == -1 then
            v137 = 250
            v86 = 100
        end
        v325 = v138(111111, 999999) + v93 + v146(1234, 5678) + v86 % 99915 + v321
        v281[4] = v138(100000, 1000000 + v86 % 1000) + v93 + v86 % 9951
        v281[5] = v146(100000, 1000000 + v86 % 5000) + v86 % 8005 + v321
        v281[6] = v138(100000, 1000000)
        v98(2)
        v327 = v319[10]
        v315 = v96("" .. v59(v319[13] + 2848) .. v59(v325 + v137) .. v59(v319[10] + v277)) .. v96(v281[5] .. "") .. v96("" .. v325) .. v96("" .. v281[6]) .. v96(v281[4] .. "")
        v315 = v96(v59(v98(3) + 12268) .. "", true) .. v315
        local v328 = l_game_0:HttpGet(v55.Host .. "/" .. v99 .. "/auth/start/" .. v319[12] .. "?t=" .. v315)
        if v328 == "err" then
            while true do
                -- empty block
            end
        end
        if v122(v328, 1, 1) == "!" then
            l_game_0:GetService("Players").LocalPlayer:Kick(v328)
            v91()
        end
        v328 = v97(v328)
        local v329 = 1
        local v330 = v62(1 + v138(100, 1000 + v321) + v146(500, 5000 + v321) + v93 % 10000)
        local v331 = false
        local v332 = false
        local v333 = false
        local v334 = 0
        do
            do
                local l_v55_1, l_v57_1, l_v59_0, l_v91_0, l_v96_0, l_v97_0, l_v98_0, l_v99_0, l_l_game_0_0, l_l_pcall_0_0, l_v111_0, l_l_wait_0_1, l_v125_0, l_l_rconsoleprint_0_0, l_l_tostring_0_1, l_v131_0, l_v136_0, l_v279_1, l_v325_0, l_v327_0, l_v329_0, l_v330_0, l_v333_0, l_v334_0 = v55, v57, v59, v91, v96, v97, v98, v99, l_game_0, l_pcall_0, v111, l_wait_0, v125, l_rconsoleprint_0, l_tostring_0, v131, v136, v279, v325, v327, v329, v330, v333, v334
                for v361 = 1, 3 do
                    local v362 = v328[3]
                    expected = l_v59_0(v281[5] + 181) .. l_v59_0(v281[4] + v100(v332 and "?" or l_l_game_0_0.JobId)) .. l_v59_0(v281[6] + v281[2])
                    if v362 == expected and ({
                        [expected] = true
                    })[v362] then
                        v331 = true
                        v38 = true
                        v42 = v328[8] and v328[8] ~= "?" and v328[8] or "Unknown"
                        v43 = v328[9] and v328[9] or "Unknown"
                        local v363 = v328[6]
                        local v364 = v328[2]
                        v36 = v328[4]
                        v35 = v364
                        v34 = v363
                        v363 = v328[1] - v281[4]
                        v364 = v328[7] - v281[5]
                        local v365 = v328[5] - v281[6]
                        local l_v31_0 = v31
                        local l_v32_0 = v32
                        local l_v33_0 = v33
                        do
                            local l_v363_0, l_v364_0, l_v365_0, l_l_v31_0_0, l_l_v32_0_0, l_l_v33_0_0 = v363, v364, v365, l_v31_0, l_v32_0, l_v33_0
                            v31 = function(v375)
                                if l_v333_0 or l_v334_0 < l_v125_0() - 8 then
                                    while true do
                                        -- empty block
                                    end
                                end
                                l_v329_0 = (l_v329_0 + v375 % 66) % 6644
                                return l_l_v31_0_0 * v375 % l_v363_0 + v375 * 3
                            end
                            v32 = function(v376)
                                if l_v333_0 or l_v334_0 < l_v125_0() - 8 then
                                    while true do
                                        -- empty block
                                    end
                                end
                                l_v329_0 = (l_v329_0 + v376 % 50) % 5891
                                return l_l_v32_0_0 * v376 % 10000 + v376 * (l_v364_0 % 4)
                            end
                            v33 = function(v377)
                                if l_v333_0 or l_v334_0 < l_v125_0() - 8 then
                                    while true do
                                        -- empty block
                                    end
                                end
                                l_v329_0 = (l_v329_0 + v377 % 35) % 6711
                                return (v377 + l_v365_0) % 100 * (v377 % (l_l_v33_0_0 % 100 + 1))
                            end
                        end
                        break
                    elseif v361 ~= 3 then
                        v332 = true
                    end
                end
                if not v331 then
                    while true do
                        -- empty block
                    end
                end
                if v320 then
                    while true do
                        -- empty block
                    end
                end
                while not v143 do
                    v124:Wait()
                end
                v95 = true
                local v378 = false
                local v379 = false
                local v380 = 0
                local v381 = 0
                local v382 = 0
                local v383 = false
                local v384 = 0
                local v385 = 0
                local v386 = v319[12]
                do
                    local l_v380_0, l_v381_0, l_v382_0, l_v383_0, l_v384_0, l_v385_0, l_v386_0 = v380, v381, v382, v383, v384, v385, v386
                    l_spawn_0(function()
                        v379 = true
                        while not l_v136_0 do
                            local v394 = l_v330_0(1000, l_v329_0 + 10000) + l_v329_0
                            l_v385_0 = l_v330_0(1000, l_v329_0 + 10000) + l_v329_0
                            l_v384_0 = v394
                            l_v98_0(2)
                            v394 = l_v96_0(l_v385_0 .. "") .. l_v96_0(l_v59_0(l_v385_0 + l_v327_0) .. "" .. l_v59_0(l_v384_0 + l_v279_1)) .. l_v96_0(l_v384_0 .. "")
                            local v395 = ""
                            local v396 = l_v55_1.Host .. "/" .. l_v99_0 .. "/auth/heartbeat?t=" .. v394 .. "&s=" .. l_v386_0
                            do
                                local l_v395_0, l_v396_0 = v395, v396
                                l_l_pcall_0_0(function()
                                    if l_v131_0 then
                                        l_l_rconsoleprint_0_0("[" .. l_v125_0() .. "] Sending ticket...(" .. l_l_tostring_0_1(l_v57_1) .. ")\n")
                                    end
                                    if l_v57_1 == false then
                                        l_v395_0 = l_v111_0(l_v396_0)
                                    else
                                        l_v395_0 = l_v57_1:request({
                                            Url = l_v396_0
                                        })
                                    end
                                    if l_v131_0 then
                                        l_l_rconsoleprint_0_0("[" .. l_v125_0() .. "] Ticket responded\n")
                                    end
                                    if l_v395_0 and #l_v395_0 > 3 then
                                        if l_v395_0 == "NOT_FOUND" then
                                            l_v333_0 = true
                                            v37 = false
                                            v38 = false
                                            v39 = 1
                                            v40 = 2
                                            l_l_game_0_0:GetService("Players").LocalPlayer:Kick("A fatal Luarmor error occurred, please restart your script.")
                                            l_v91_0()
                                        end
                                        if l_v395_0 == "FAIL" then
                                            l_v333_0 = true
                                            v37 = false
                                            v38 = false
                                            v39 = 1
                                            v40 = 2
                                            writefile("luarmor-dbgfail.txt", "resp:fail")
                                            while true do
                                                -- empty block
                                            end
                                        end
                                        l_v395_0 = l_v97_0(l_v395_0)[1]
                                        if l_v395_0 == l_v59_0(l_v384_0 * l_v385_0 % 100000 + l_v325_0 + 8410) .. "" then
                                            l_v381_0 = l_v381_0 + 1
                                            l_v383_0 = true
                                            v378 = true
                                        elseif l_v395_0 == l_v59_0(l_v384_0 * l_v385_0 % 100000 + l_v325_0 + 8410 + 4919) .. "" then
                                            l_v383_0 = true
                                            v378 = true
                                            l_v136_0 = true
                                            l_l_pcall_0_0(function()
                                                l_v57_1:close()
                                            end)
                                        else
                                            l_v333_0 = true
                                            v37 = false
                                            v38 = false
                                            v39 = 1
                                            v40 = 2
                                            l_l_game_0_0:GetService("Players").LocalPlayer:Kick("Heartbeat failure [0x01]. ttl: " .. l_v381_0)
                                        end
                                    end
                                end)
                                l_l_wait_0_1(20)
                            end
                        end
                    end)
                    while not v379 do
                        v124:Wait()
                    end
                    v379 = false
                    l_spawn_0(function()
                        v379 = true
                        local v401 = 200
                        while true do
                            v401 = v401 + 1
                            if not l_v136_0 and v401 >= 250 then
                                v401 = 0
                                if l_v383_0 then
                                    l_v380_0 = l_v380_0 + 1
                                    if l_v380_0 > 4 then
                                        l_v380_0 = 0
                                        if l_v382_0 < 10 then
                                            l_v382_0 = l_v382_0 + 1
                                        end
                                    end
                                else
                                    l_v382_0 = l_v382_0 - 1
                                    if l_v382_0 <= 0 then
                                        l_v333_0 = true
                                        v37 = false
                                        v38 = false
                                        v39 = 1
                                        v40 = 2
                                        writefile("luarmor-error-log.txt", "[0x2001] " .. l_v381_0 .. " v: " .. l_l_tostring_0_1(l_v57_1))
                                    end
                                end
                                l_v383_0 = false
                            end
                            l_v334_0 = l_v125_0()
                            l_l_wait_0_1(0.18)
                            if l_v334_0 == l_v125_0() then
                                l_v333_0 = true
                                v37 = false
                                v38 = false
                                v39 = 1
                                v40 = 2
                                writefile("luarmor-error-log.txt", "[0x2022] " .. l_v381_0 .. " v: " .. l_l_tostring_0_1(l_v57_1))
                            end
                        end
                    end)
                end
                v87("[3/3] Successfully authenticated!")
                v87("Authenticated in " .. l_v125_0() - v1 .. "s")
                while not v379 or not v378 do
                    l_l_wait_0_1()
                end
            end
        end
        print(v34)
        return
    end
end
