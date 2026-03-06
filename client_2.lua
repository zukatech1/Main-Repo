local L_0 = ...
local L_1 = ce_like_loadstring_fn
if ce_like_loadstring_fn then
    L_1 = "?"
    local L_2 = ce_like_loadstring_fn
    if ce_like_loadstring_fn then
        loadstring = L_2
        local L_4 = function(...)
            local L_48 = L_48(L_49, L_50)
            UPVAL_0 = true
            local L_1 = "nil  nil  "
            local L_2 = "qwertyuiopasdfghjklzxcvbnm098765"
            local L_3 = UserSettings()
            L_3 = L_3.GetService
            local L_5 = L_3
            local L_4 = L_3.GetTutorialState
            local L_6 = "nil  nil  "
            if L_3.GetTutorialState then
                L_5(...)
                UPVAL_1 = "\65533\t"
                local L_7 = 16
                local L_8 = 1
                UPVAL_0[L_0] = L_0
            else
                UPVAL_1 = "\65533\t"
                L_5 = {}
                L_6 = wait()
                --[[ SETLIST L_5[0..] = stack ]]
                L_5 = L_5[1] * 1000000
                L_6 = L_5 % 1
                L_5 = L_5 - L_6
                L_6 = function()
                end
                local L_7 = L_6(L_8)
                L_4 = L_4(L_5)
                for L_11 = 1, 16 do
                    local L_12 = 0
                    local L_13 = 1
                    local L_16 = L_2
                    local L_17 = L_12 + 1
                    local L_14 = UPVAL_1 .. L_2.sub
                    UPVAL_1 = L_14
                end
            end
            return
            L_5 = L_5 + 1
            for L_15 = L_12, L_13, L_14 do
                local L_17 = L_3
                local L_16 = L_3.GetTutorialState
                local L_18 = L_1 .. L_5
                if not L_3.GetTutorialState then
                    if L_16 then
                        L_17 = L_187 * L_11
                        local L_10 = L_10 + L_17
                        local L_11 = L_11 * 2
                    else
                        L_16 = 0
                    end
                else
                    L_16 = 1
                end
            end
            local L_100 = L_15 * L_10
            L_16 = L_10 + 1
            L_4 = L_4(...)
            local L_12 = UPVAL_1 .. L_2.sub
            UPVAL_1 = L_12
            local L_19 = L_19 * L_145
            L_12 = L_12 + L_19
            local L_13 = L_2.sub * 2
            L_7 = L_7 + 1
            if not L_19 then
                L_19 = 0
            end
            L_18 = L_6 < L_0
            L_18 = L_18 > 15
            L_3.SetTutorialState(...)
            if L_18 then
                L_19 = 1
            end
        end
        pcall(L_4)
        L_2 = os.clock()
        local L_3 = devsignature_sig
        if not devsignature_sig then
            local L_13 = false
            local L_16 = 0
            local L_18 = "Not specified"
            local L_20 = {}
            L_0 = ...
            --[[ SETLIST L_20[0..] = stack ]]
            L_20 = L_20[2]
            local L_22 = {}
            L_0 = ...
            --[[ SETLIST L_22[0..] = stack ]]
            L_22 = L_22[3]
            if not L_22 then
                L_22 = L_0
                local L_24 = nil
                local L_26 = math
                local L_27 = table.remove
                local L_28 = string.char
                local L_29 = 0
                local L_30 = 2
                local L_31 = {}
                local L_32 = {}
                local L_34 = {}
                local L_35 = 1
                local L_36 = 256
                local L_37 = 1
                for L_38 = 1, 256 do
                    L_34[L_38] = L_38
                end
                repeat
                    L_37 = #L_34
                    local L_38 = L_27 - 1
                    L_37 = L_28(L_38)
                    L_32[L_27] = L_37
                    L_37 = #L_34
                until L_37 == 0
                L_35 = {}
                L_36 = function()
                    local L_1 = #UPVAL_0
                    if L_1 ~= 0 then
                        return table(UPVAL_0)
                    else
                        L_1 = UPVAL_1 * 149
                        L_1 = L_1 % 35184372088832
                        UPVAL_1 = L_1
                        repeat
                            L_1 = UPVAL_2 * 37
                            L_1 = L_1 % 257
                            UPVAL_2 = L_1
                        until L_1 ~= 1
                        L_1 = UPVAL_169 % 32
                        local L_22 = UPVAL_3
                        local L_4 = UPVAL_2 - L_1
                        L_4 = L_4 / 32
                        L_4 = 13 - L_4
                        L_4 = 2 ^ L_4
                        local L_3 = L_3 / L_4
                        local L_2 = L_2(L_3)
                        L_3 = 2 ^ L_1
                        L_2 = L_2 / L_3
                        L_4 = L_2 % 1
                        L_3 = UPVAL_3(L_4)
                        L_0[L_5] = L_195
                        L_4 = UPVAL_3(L_5)
                        L_3 = L_3 + L_4
                        L_4 = L_3 % 65536
                        local L_5 = L_3 - L_4
                        L_5 = L_5 / 65536
                        local L_6 = L_4 % 256
                        L_22 = nil
                        local L_24 = nil
                        local L_7 = L_4 - L_6
                        L_7 = UPVAL_2128[L_7]
                        L_24 = L_5 % 256
                        local L_43 = function(L_ARG_0)
                            return
                        end
                    end
                end
                L_37 = {}
                L_24 = L_37
                local L_23 = function()
                    local L_3 = UPVAL_0
                    local L_4 = UPVAL_0[L_2]
                    if not UPVAL_0[L_2] then
                        L_4 = {}
                        UPVAL_1 = L_4
                        L_4 = UPVAL_2
                        local L_5 = L_232 % 35184372088832
                        UPVAL_225 = L_5
                        L_5 = L_2 % 255
                        L_5 = L_5 + 2
                        UPVAL_4 = L_5
                        L_5 = #L_1
                        L_3[L_2] = "\65533\t"
                        local L_6 = 77
                        for L_10 = L_7, L_5 do
                            local L_12 = UPVAL_5()
                            local L_11 = string.byte + L_12
                            L_11 = L_11 + L_6
                            local L_2128 = UPVAL_205
                            L_12 = L_6 + 1
                            L_11 = L_11 .. L_12
                            L_3[L_2] = L_11
                        end
                    end
                    return L_2
                end
                local L_25 = LUARMOR_SkipAntidebugDevMode
                L_26 = LUARMOR_AllowKeyCheckSkip
                L_27 = ff97f23b97f93792992999
                if not ff97f23b97f93792992999 then
                    if L_27 then
                        L_28 = L_24[L_23]
                        L_29 = USE_NON_SSL_NODE
                        L_30 = l_fastload_enabled
                        L_32 = os[L_24[L_23]](L_24[L_23])
                        L_32 = L_32[L_24[L_23]]
                        L_35 = "\65533\6D"
                        L_36 = 24300592814183
                        L_34 = L_24[L_23]
                        local L_33 = os[L_24[L_23]](L_24[L_23])
                        L_31 = os[L_24[L_197]] - L_32
                        if 0 <= L_31 then
                            L_31 = L_31 % 86400
                            L_32 = L_31 / 3600
                            if 21 <= L_32 then
                                L_33 = {}
                                --[[ SETLIST L_33[0..] = stack ]]
                                L_37 = 14086848885567
                                L_36 = 2
                                L_28 = L_33[math[L_24[L_23]]]
                                L_34 = function()
                                    local L_1 = game.GetService.GetCountryRegionForPlayerAsync
                                    local L_5 = "\65533\65533\65533\738\65533K\65533I\65533\65533"
                                    local L_6 = 24768758536731
                                    local L_2 = L_1 % L_0
                                    local L_3 = ";%"
                                    local L_4 = 6519959328696
                                    L_2 = UPVAL_0[L_2]
                                    if L_1 ~= L_2 then
                                        return
                                    else
                                        L_1 = {}
                                        L_2 = UPVAL_1
                                        L_2 = UPVAL_0[L_2]
                                        --[[ SETLIST L_1[0..] = stack ]]
                                        L_2 = L_2[UPVAL_0[UPVAL_1]]
                                        L_1 = L_1[L_2]
                                        UPVAL_2 = L_1
                                    end
                                end
                                pcall(L_34)
                                L_31 = {}
                                local L_156 = L_156("=L=>=H== c114> <")
                                local L_154 = nil
                                local L_155 = nil
                                L_156 = nil
                                local L_157 = nil
                                L_35 = 22757578724042
                                L_196[L_24[L_23]] = L_24[L_23]
                                L_32 = L_24[L_23]
                                L_33 = L_27
                                if not L_27 then
                                    if L_33 then
                                        L_31[L_32] = L_33
                                        L_31[L_24[L_23]] = "b497ad9cd94af9a2c4c41b0d4952dde7"
                                        L_31[L_24[L_23]] = "0170"
                                        L_33 = "\65533u\7\65533"
                                        L_34 = 2453574945005
                                        L_32 = L_24 >= L_23
                                        L_31[L_32] = "biggiehub"
                                        if not L_29 then
                                            L_33 = {}
                                            L_0 = ...
                                            --[[ SETLIST L_33[0..] = stack ]]
                                            L_33 = L_33[1]
                                            L_32 = type(L_33)
                                            L_32 = L_32 ~= L_24[L_23]
                                            local L_63 = print
                                            local L_64 = next
                                            local L_67 = identifyexecutor
                                            local L_68 = game
                                            L_155 = L_155(L_156)
                                            L_154 = L_154(L_155)
                                            L_154 = L_154 + -14
                                            L_154 = nil
                                            L_155 = nil
                                            L_156 = nil
                                            L_157 = nil
                                            local L_69 = pcall
                                            local L_70 = true
                                            local L_73 = tonumber
                                            local L_74 = setmetatable
                                            local L_75 = rawget
                                            local L_76 = wait
                                            local L_78 = loadstring
                                            local L_79 = os[L_24[L_23]]
                                            local L_80 = string[L_24[L_23]]
                                            local L_81 = string[L_24[L_23]]
                                            local L_82 = spawn
                                            local L_83 = game.GetService[L_24[L_23]]
                                            local L_84 = os[L_24[L_23]]
                                            local L_85 = rconsoleprint
                                            local L_86 = math[L_24[L_23]]
                                            local L_87 = tostring
                                            local L_88 = pairs
                                            local L_89 = string[L_24[L_23]]
                                            local L_92 = false
                                            local L_93 = function()
                                                local L_3 = UPVAL_0
                                                local L_4 = UPVAL_2
                                                local L_16 = -58(L_17)
                                                local L_15 = L_15 == L_16
                                                if not L_15 then
                                                    local L_8 = "l>d<"
                                                else
                                                    L_15 = -329
                                                end
                                            end
                                            if not false then
                                                local L_94 = {}
                                                local L_95 = false
                                                local L_96 = string
                                                local L_97 = L_23
                                                local L_98 = "\65533[J\65533\65533h"
                                                local L_99 = 30415739121318
                                                if not L_154 then
                                                    L_154 = L_154("`&")
                                                else
                                                    L_156 = -2
                                                    L_157 = -2
                                                end
                                            else
                                                local L_96 = os[L_24[L_23]]()
                                                local L_98 = "\24\65533K\65533D\65533\65533\65533\65533\26\65533\65533R,\65533\65533\65533\65533\65533G\65533c\65533"
                                                local L_99 = 10709827790582
                                                L_96 = L_96 .. L_24[L_23]
                                                local L_95 = L_24[L_23] .. L_96
                                                L_63(L_95)
                                            end
                                        else
                                            L_35 = 22440815219107
                                            L_31[L_24[L_23]] = L_24[L_23]
                                            L_34 = 20241724852643
                                            L_28 = L_24[L_23]
                                        end
                                    else
                                        L_34 = "\65533\65533\65533\1690\65533A\27"
                                        L_35 = 5940121048476
                                        L_33 = L_24[L_23] .. L_28
                                    end
                                end
                            elseif 5 <= L_32 then
                                if 5 > L_32 then
                                    if 15 > L_32 then
                                        L_35 = L_0 ~= L_0
                                        L_36 = "X\1024\65533\65533\65533\6\65533\65533\1690z\65533[\65533\65533\28A\65533`;m\\\65533C\65533d_\8\48479\11\24\4\809\65533S\rH\65533-E\79\655339lH\65533-C3\65533)\65533\20\65533{1\65533\1822"
                                        L_37 = 31900769383437
                                        game.GetService[L_24[L_23]]:Kick(L_24[L_23])
                                    elseif 21 > L_32 then
                                        L_33 = {}
                                        L_38 = 14158791783298
                                        --[[ SETLIST L_33[0..] = stack ]]
                                        L_37 = 446690230688
                                        L_36 = 2
                                        L_28 = L_33[math[L_24[L_23]]]
                                    end
                                elseif 15 > L_32 then
                                    local L_45 = "y\65533\65533QA\127\65533\22\"\3\65533\65533.\0\5\65533\65533\65533\65533\27\65533.\65533\65533\380\65533"
                                    local L_46 = 25925213773392
                                    --[[ SETLIST L_33[0..] = stack ]]
                                    L_28 = L_33[math[L_24[L_23]]]
                                end
                            end
                        else
                            L_32 = -L_31
                            L_32 = L_32 % 86400
                            L_31 = -L_32
                            L_32 = 86400 + L_31
                            L_31 = L_32 % 86400
                        end
                    else
                        L_27 = false
                    end
                else
                    local L_154 = L_154("<f<=Hx   n<>i4><<")
                    L_154 = L_154 - "<f<=Hx   n<>i4><<"
                    L_154 = nil
                    L_27 = ff97f23b97f93792992999()
                    L_29 = "\65533"
                    L_30 = 31126577901884
                    L_27 = L_27 == L_23
                end
            elseif L_22[1] then
                L_22 = L_22[1]
            end
        else
            print("        Luarmor - Lua whitelist service\n        This is a signature - If you are seeing this, you know what not to do :3\n        Have a good day!\n        https://luarmor.net/\n    ")
        end
    else
        L_2 = loadstring
    end
else
    L_1 = l_fastload_enabled
    if not l_fastload_enabled then
        local L_2 = game
        local L_3 = "Players"
    elseif is_from_loader then
    end
    L_1 = L_1.LocalPlayer
    L_1 = L_1.Kick
    L_1(L_1, "[Luarmor]: Use the loadstring, do not run this directly")
    wait(5)
end
local L_80 = {}
L_80.Name = "RAM Target"
L_80.Flag = "FYFPS_RAM_TARGET"
L_80.Value = 1250
L_80.Numeric = true
local L_81 = function()
    return
end
L_47.RAMTarget = L_78
L_80 = {}
L_80.Name = "RAM Variance"
L_80.Flag = "FYFPS_RAM_VARIANCE"
L_80.Value = 50
L_80.Numeric = true
L_81 = function()
    return
end
L_80.Callback = L_81
L_47.RAMVariance = Window.Tabs.Main.CreateInput
Window.Tabs.Main:CreateDivider()
L_80 = {}
L_80.Name = "Resolution"
Window.Tabs.Main:CreateSection(L_80)
L_80 = {}
L_80.Name = "Spoof Resolution"
L_80.Flag = "FYFPS_SPOOF_RESOLUTION"
local L_154 = nil
local L_155 = nil
L_80.Value = false
L_81 = function()
    return
end
L_80.Callback = L_24
local L_78 = L_47 * L_393
L_80 = {}
L_80.Name = "Resolution X"
L_80.Flag = "FYFPS_RESOLUTION_X"
L_80.Value = 1920
L_80.Numeric = true
L_81 = function(L_ARG_0)
    return
end
L_80.Callback = L_81
L_47.ResolutionX = Window.Tabs.Main.CreateInput
L_80 = {}
L_80.Name = "Resolution Y"
L_80.Flag = "FYFPS_RESOLUTION_Y"
L_80.Value = 1080
L_80.Numeric = true
L_81 = function()
    return
end
L_80.Callback = L_81
L_47.ResolutionY = Window.Tabs.Main.CreateInput
Window.Tabs.Main:CreateDivider()
L_78 = tick()
local L_79 = function(...)
    if L_2 then
        local L_3 = tick()
        L_3 = L_3 - UPVAL_0
        local L_5 = L_3 * 10
        local L_4 = math.sin(L_5)
        L_5 = L_2 * 0.5
        L_4 = L_4 * L_5
        L_4 = L_1 + L_4
        L_5 = math.random()
        local L_6 = L_5 < 0.1
        local L_7 = L_6
        if not L_6 then
            if not L_7 then
                L_7 = 0.2
            end
            local L_125 = L_0
            local L_124 = L_0[L_8]
            local L_8 = L_8.random
            L_8 = L_8 * L_7
            local L_10 = L_4 + L_8
            return math.round(L_10)
        else
            local L_8 = 150
            local L_9 = 250
            L_7 = math.random * 0.01
            local L_19 = -291 > L_19
            local L_176 = -1
        end
    else
        local L_2 = 0
    end
    if L_19 then
        UPVAL_19[0] = L_19
    else
        local L_20 = "iy\65533"
        local L_85 = L_19 * L_0
    end
end
L_155 = L_155 - -55
L_154 = nil
L_155 = nil
local L_156 = nil
local L_157 = nil
L_80, L_81, L_82 = getconnections(L_28.WaitForChild.OnClientEvent)
L_80 = L_5217 == L_0
local L_4 = L_4(...)
L_103(...)
return
local L_105 = os[L_24[L_23]]()
L_105 = L_105 .. L_24[L_23]
local L_104 = L_24[L_23] .. L_105
L_63(L_104)
local L_107 = L_87(L_99)
local L_106 = L_24[L_23] .. L_107
local proto_7 = function(...)
    local L_2 = L_2.find
    local L_141 = L_141(...)
    return
end
local proto_11 = function(...)
    local L_0 = ...
    L_0 = ...
    UPVAL_0.Threads[L_1] = task.defer
    return
end
local proto_13 = function(...)
    local L_2 = "\65533\t"
    local L_4 = #L_1
    while true do
        local L_20 = L_20("i==J =jJ< ")
        local L_18 = L_18(L_19)
        while true do
            local L_3 = ...
        end
        local L_9 = L_1[L_6]
        L_2 = L_2 .. string.format
    end
end
local proto_16 = function()
    local L_2 = typeof
    local L_3 = UPVAL_0.Cache[L_1]
    local L_254 = L_254(L_255)
    local L_20 = "?"(L_21)
    local L_19 = L_19 - L_20
    L_19 = nil
    L_20 = nil
    local L_21 = nil
    L_2 = L_2(L_3)
    if L_2 ~= "table" then
        UPVAL_76.Cache:Destroy()
    else
        local L_0 = L_216 == L_4
    end
    return
end
local proto_17 = function(L_ARG_0, L_ARG_1)
end
local proto_22 = function()
    return UPVAL_0(L_1)
end
local proto_23 = function()
    if not L_17 then
        if L_107 then
            local L_49 = L_49(L_50, L_51)
            local L_5 = 1 - L_200
            L_5 = L_5.2
            L_5 = L_5 * L_2
            local L_6 = 1 - L_1
            L_6 = 2 * L_6
            return L_0
        end
    else
        local L_18 = "<i8"
        local L_19 = "\65533\1\0\0\0\0\0\0"
    end
end
local proto_28 = function(L_ARG_0)
    if UPVAL_0 then
    end
end
local proto_32 = function(...)
    UPVAL_0 = true
    while true do
        local L_1 = UPVAL_4
        local L_3 = UPVAL_5 + 10000
        local L_0 = L_190
        local L_11 = nil
        L_1 = UPVAL_5
        local L_5 = UPVAL_5 + 10000
        UPVAL_2 = L_1
        UPVAL_3 = L_3
        UPVAL_6(2)
        local L_2 = UPVAL_170 .. UPVAL_8[UPVAL_9]
        L_1 = UPVAL_6(L_2)
        local L_4 = UPVAL_3 + UPVAL_11
        L_3 = UPVAL_10(L_4)
        L_5 = UPVAL_12(UPVAL_2)
        L_4 = UPVAL_129[L_246] .. L_5
        L_3 = L_3 .. L_4
        L_2 = UPVAL_7(L_3)
        L_4 = UPVAL_2 .. UPVAL_8[UPVAL_9]
        L_3 = UPVAL_7(L_4)
        L_2 = L_2 .. L_3
        L_1 = L_1 .. L_2
        L_3 = UPVAL_14[UPVAL_8[L_232]]
        L_4 = UPVAL_8[UPVAL_9]
        L_5 = UPVAL_15
        local L_6 = UPVAL_8[UPVAL_9]
        local L_7 = UPVAL_9
        L_7 = UPVAL_8[L_7]
        L_7 = L_1 .. L_7
        L_6 = L_6 .. L_7
        L_5 = L_5 .. L_6
        L_4 = L_4 .. L_5
        L_3 = L_3 .. L_4
        L_5 = function(...)
            local L_1 = UPVAL_0
            if not UPVAL_0 then
                L_1 = UPVAL_6
                if UPVAL_6 ~= false then
                    local L_21 = nil
                    local L_2 = L_1
                    L_1 = L_1.request
                    local L_6 = 17306025115381
                    local L_4 = UPVAL_2[UPVAL_3]
                    L_3[UPVAL_2[UPVAL_3]] = UPVAL_9
                    UPVAL_7 = L_1
                    L_1 = UPVAL_0
                    if not UPVAL_0 then
                        local L_18 = L_18(-288)
                        local L_17 = nil
                        L_18 = nil
                        local L_19 = nil
                        L_1 = UPVAL_7
                        if UPVAL_7 then
                            L_21 = nil
                            local L_91 = UPVAL_7
                            L_1 = #L_1
                            if 3 <= L_1 then
                                L_1 = UPVAL_7
                                L_4 = 19626452010854
                                L_2 = UPVAL_2[UPVAL_3]
                                if UPVAL_7 ~= UPVAL_2[UPVAL_3] then
                                    L_1 = UPVAL_7
                                    local L_3 = "\393\65533J"
                                    L_4 = 30249304059403
                                    L_2 = UPVAL_2[UPVAL_3]
                                    if UPVAL_7 ~= UPVAL_2[UPVAL_3] then
                                        L_1 = UPVAL_17(UPVAL_7)
                                        UPVAL_7 = L_1
                                        L_3 = UPVAL_19
                                        L_4 = UPVAL_20
                                    else
                                        UPVAL_10 = true
                                        UPVAL_11 = false
                                        UPVAL_12 = false
                                        UPVAL_13 = 1
                                        UPVAL_14 = 2
                                        L_1 = writefile
                                        L_4 = "s25z\65533\65533a\65533\65533"
                                        local L_5 = 15250820544379
                                        L_1(UPVAL_2[UPVAL_46], UPVAL_2[UPVAL_3])
                                    end
                                else
                                    UPVAL_10 = true
                                    UPVAL_11 = false
                                    UPVAL_12 = false
                                    UPVAL_13 = 1
                                    UPVAL_82 = 2
                                    local L_119 = UPVAL_15
                                    local L_118 = UPVAL_15.GetService
                                    L_4 = "\3\65533d\65533\65533\15\65533\65533\n\65533\65533g\65533\65533M\65533,\65533?T\65533^m\65533\29J\31mM\65533n\1\65533D\65533\t\655331r*\65533W\65533\190\29\65533I\65533\65533\65533X^3\65533O\1780"
                                    local L_5 = 33049708197947
                                    UPVAL_15[UPVAL_2[UPVAL_3]]:Kick(UPVAL_2[UPVAL_3])
                                    UPVAL_16()
                                end
                                L_21 = nil
                                local L_3 = L_3 * L_4
                                L_3 = L_3 % 100000
                                L_3 = L_3 + UPVAL_21
                                L_3 = 10417 ~= L_3
                                L_2 = L_2(L_3)
                                L_4 = "\65533\t"
                                local L_5 = 28489387501476
                                L_3 = UPVAL_2[UPVAL_3]
                                L_2 = L_2 .. UPVAL_2[UPVAL_3]
                                if L_1 ~= L_2 then
                                    L_1 = UPVAL_7
                                    L_2 = UPVAL_25
                                    L_3 = UPVAL_19
                                    L_4 = UPVAL_20
                                    L_21 = nil
                                    L_21 = nil
                                    local L_0 = L_59 <= L_0
                                    L_18 = "=c179>=<fj  "(L_19)
                                    L_4 = L_4(...)
                                    L_18 = L_18("\3")
                                    L_17 = L_17 - L_18
                                    L_17 = nil
                                    L_18 = nil
                                    L_19 = nil
                                    L_3 = L_3 * L_4
                                    L_0 = L_21 < L_4
                                    L_21 = nil
                                    L_3 = L_3 + L_4
                                    L_2 = L_2(L_3)
                                    L_4 = "\65533\t"
                                    L_5 = 15233640150891
                                    L_3 = UPVAL_2[UPVAL_3]
                                    L_21 = nil
                                    L_2 = L_2 .. L_3
                                    if L_1 ~= L_2 then
                                        UPVAL_10 = true
                                        UPVAL_11 = false
                                        UPVAL_12 = false
                                        UPVAL_13 = 1
                                        UPVAL_14 = 2
                                        L_5 = 22159486275741
                                        L_3 = UPVAL_2[UPVAL_3] .. UPVAL_22
                                        UPVAL_15.GetService[UPVAL_2[UPVAL_3]]:Kick(L_3)
                                    else
                                        UPVAL_23 = true
                                        UPVAL_24 = true
                                        UPVAL_26 = true
                                        L_2 = function()
                                            UPVAL_0:close()
                                            return
                                        end
                                        UPVAL_27(L_2)
                                    end
                                else
                                    L_1 = UPVAL_22 + 1
                                    UPVAL_22 = L_1
                                    UPVAL_23 = true
                                    UPVAL_24 = true
                                end
                            end
                        end
                        L_21 = nil
                        return
                    else
                        local L_3 = UPVAL_4()
                        local L_5 = "\20N\65533+\65533\18\65533`OM\65533P=\65533n\65533\655332"
                        L_6 = 6507074033580
                        L_3 = L_3 .. UPVAL_2[UPVAL_3]
                        L_2 = UPVAL_2[UPVAL_3] .. L_3
                        L_1(L_2)
                    end
                else
                    L_1 = UPVAL_8(UPVAL_9)
                    UPVAL_7 = L_1
                end
            else
                local L_3 = UPVAL_4()
                local L_5 = UPVAL_5(UPVAL_6)
                L_5 = L_5 .. UPVAL_2[UPVAL_3]
                local L_4 = UPVAL_2[UPVAL_3] .. L_5
                L_3 = L_3 .. L_4
                local L_2 = UPVAL_2[UPVAL_3] .. L_3
                L_1(L_2)
            end
        end
        L_4, L_5 = UPVAL_17(L_5)
        L_11 = 20
        UPVAL_38(L_7)
    end
    return
end
local proto_36 = function()
    local L_1 = loadstring(UPVAL_0)
    return L_1()
end
local proto_39 = function(L_ARG_0, L_ARG_1, ...)
    L_ARG_0 = ...
    local L_2 = UPVAL_0 + 3965
    if L_2 == 12478 then
        L_2 = {}
        L_ARG_0 = ...
        local L_3 = getfenv
        local L_241 = L_241()
        local L_4 = getgenv()
        local L_5 = setmetatable
        local L_7 = {}
        local L_8 = function()
            local L_3 = UPVAL_0[L_2]
            if UPVAL_0[L_2] then
                return L_3
            else
                L_3 = UPVAL_1[L_26]
            end
        end
        L_7.__index = L_8
        local L_6 = UPVAL_0 - 6321
        if L_6 == 2192 then
            L_6 = function()
                local L_3 = L_2
                if not L_2 then
                    if not L_3 then
                        L_3 = UPVAL_0
                    end
                else
                    L_3 = UPVAL_0[L_2]
                end
                local L_2 = L_3
                if L_3 then
                    return L_2[L_1]
                else
                    return false
                end
            end
            return true
        else
            local L_13 = L_9
            local L_14 = "%."
            if not L_12 then
                local L_10 = L_9
                local L_24 = "><L>=>"
                local L_23 = L_23("><L>=>")
                L_23 = L_23 - -65
                L_23 = L_23 > -459
                if not L_23 then
                    L_23 = L_23("9")
                end
            else
                L_13 = 1864
                local L_12 = UPVAL_2(1864)
                if 2464 == L_12 then
                    L_0 = L_ARG_0
                    if L_12 == 4066 then
                        L_13 = L_9
                        L_14 = "."
                        local L_11 = string[1]
                        local L_10 = string[2]
                    else
                        L_255[L_164] = L_2332
                        L_12 = UPVAL_1(L_13)
                    end
                end
            end
            return false
        end
    else
        L_2 = UPVAL_176(L_3)
        if 9096 ~= L_2 then
            local L_59 = L_503
            local L_58 = L_503[L_495]
        end
    end
end
local proto_43 = function()
    local L_120 = L_120(L_121)
    local L_2 = L_1
    if not L_1 then
        L_2 = UPVAL_2.rootObject
        if not L_234 then
            return L_2
        end
    end
end
local proto_44 = function(L_ARG_0, L_ARG_1, L_ARG_2, ...)
    local L_4 = clonefunction(L_ARG_1)
    UPVAL_0.Hooked[L_ARG_1] = L_4
    return L_ARG_0(...)
end
local proto_47 = function()
    local L_3 = nil
    local L_4, L_5, L_6 = getgc()
    repeat
        for L_3 = L_0, L_1, L_2 do
        end
    until L_8
    L_5 = function(L_ARG_0, ...)
        if "<=j<B f <" > L_36 then
            local L_82 = coroutine
            local L_2 = UPVAL_0
            local L_3 = UPVAL_1
        end
        local L_3 = L_3()
        L_171(...)
        return
    end
    local L_20 = -73 + L_20
    L_20 = nil
    L_6(L_5, L_3)
    L_6 = setfenv
    local L_207 = L_22 ~ L_22
    local L_8 = islclosure(L_6)
    L_5 = 8465
    L_4 = UPVAL_0(8465)
    if 25578 < L_4 then
        L_6 = 8465
        L_5 = UPVAL_65(8465)
        if 25578 < L_5 then
            L_5 = nil
            L_6 = nil
            L_4 = coroutine.running()
            L_6 = "setthreadidentity"
            L_5 = UPVAL_1("setthreadidentity")
            if L_5 then
                L_6 = 1263
                L_5 = UPVAL_0(1263)
                if L_5 == 5070 then
                    setthreadidentity(2)
                end
            end
        end
    end
    local L_7 = getfenv(L_6)
    L_3 = L_7
end
local proto_48 = function(...)
    local L_2 = UPVAL_0
    if not UPVAL_0 then
        local L_106 = L_106(L_107)
        L_2 = UPVAL_1
        local L_3 = UPVAL_2()
        L_3 = ...
        if UPVAL_1 < L_3 then
            L_3 = #L_1
            L_2 = UPVAL_3 + L_3
            L_2 = L_2 % 6644
            UPVAL_3 = L_2
            L_2 = UPVAL_4 % UPVAL_5
            L_3 = L_1 * 3
            L_2 = L_2 + L_3
            return L_2
        end
    end
end
local proto_49 = function()
    return
end
local proto_50 = function(L_ARG_0)
    local L_168 = L_168(L_169)
    local L_4, L_5, L_6 = getgc(true)
    if L_ARG_0 ~= L_4 then
        local L_86 = UPVAL_124[L_4]
    else
        local L_8 = islclosure(L_9)
        if L_8 then
            L_8 = getfenv(L_142)
            if L_8 then
                local L_7 = UPVAL_1(L_6)
                if L_7 == L_1 then
                    return L_6
                end
            end
        end
    end
    return
end
local proto_51 = function(...)
    local L_5 = -434
    local L_4 = L_4(...)
    local L_2 = getcustomasset
    if not getcustomasset then
        return UPVAL_4[L_1]
    else
        local L_3 = L_1 - L_0
        L_2 = isfile(L_3)
        if L_2 then
            L_5, L_6, L_7, L_8, L_9, L_10, L_11, L_12, L_13, L_14, L_15, L_16, L_17, L_18, L_19, L_20, L_21, L_22, L_23, L_24, L_25, L_26, L_27, L_28, L_29, L_30, L_31, L_32, L_33, L_34, L_35, L_36, L_37, L_38, L_39, L_40, L_41, L_42, L_43, L_44, L_45, L_46, L_47, L_48, L_49, L_50, L_51, L_52, L_53, L_54, L_55, L_56, L_57, L_58, L_59, L_60, L_61, L_62, L_63, L_64, L_65, L_66, L_67, L_68, L_69, L_70, L_71, L_72, L_73, L_74, L_75, L_76, L_77, L_78, L_79, L_80, L_81, L_82, L_83, L_84, L_85, L_86, L_87, L_88, L_89, L_90, L_91, L_92, L_93, L_94, L_95, L_96, L_97, L_98, L_99, L_100, L_101, L_102, L_103, L_104, L_105, L_106, L_107, L_108, L_109, L_110, L_111, L_112, L_113, L_114, L_115, L_116, L_117, L_118, L_119, L_120, L_121, L_122, L_123, L_124, L_125, L_126, L_127, L_128, L_129, L_130, L_131, L_132, L_133, L_134, L_135, L_136, L_137, L_138, L_139, L_140, L_141, L_142, L_143, L_144, L_145, L_146, L_147, L_148, L_149, L_150, L_151, L_152, L_153, L_154, L_155, L_156, L_157, L_158, L_159, L_160, L_161, L_162, L_163, L_164, L_165 = readfile(L_1)
            writefile(...)
            L_4 = function()
                local L_2 = 5281
                local L_1 = UPVAL_0(5281)
                if 16544 <= L_1 then
                    L_2 = UPVAL_0(5281)
                    if 16544 < L_2 then
                        return getcustomasset(UPVAL_1)
                    end
                end
            end
            L_3, L_4 = pcall(L_4)
            delfile(L_2)
            L_5 = UPVAL_2
            if UPVAL_2 then
                if L_81 then
                    if L_4 then
                        if L_4 ~= "\65533\t" then
                            return L_4
                        end
                    end
                end
            end
        end
    end
end
local proto_53 = function()
    return L_0
end
local proto_56 = function(...)
    local L_14 = "\65533k"
    local L_13 = L_13("\65533k")
    if not L_13 then
        local L_15 = -3
        local L_16 = -3
    end
    return L_5.nets[L_26]
end
local proto_58 = function(...)
    if not L_12 then
        local L_12 = -124
        UPVAL_0[L_1] = "loadstring"
        local L_3716 = L_3716(...)
        local L_2 = L_2(L_3)
        return L_1()
    else
        L_107[L_1492] = L_12
    end
end
local proto_61 = function(...)
    local L_2 = {}
    local L_4 = #L_1
    return L_2
    local L_172 = L_234 + 1
    local L_9 = tonumber(L_1.sub, L_1)
    L_221.insert(...)
end
local proto_64 = function()
    return L_1.Collide
end
local proto_71 = function()
    local L_2 = 8937
    local L_1 = UPVAL_0(8937)
    if 27000 > L_1 then
        L_236[L_161] = L_1
        L_1 = L_1()
        L_1 = L_1 == "Away"
        if L_1 then
            L_1 = "Home"
        end
        L_1 = "Away"
    else
        local L_236 = ">i8"
        local L_260 = L_0 == L_15
        local L_12 = L_12 ~= -395
        if not L_12 then
            L_12 = L_12("\1el")
        else
            local L_24 = -78
        end
    end
end
local proto_76 = function()
    local L_388 = L_70 - L_296
end
local proto_78 = function()
    UPVAL_0 = true
    local L_1 = 200 + 1
    local L_2 = UPVAL_1
    while UPVAL_1 do
        UPVAL_15 = UPVAL_16
        L_2 = UPVAL_15
        local L_3 = UPVAL_16()
        if UPVAL_15 == L_3 then
            UPVAL_4 = true
            UPVAL_6 = false
            UPVAL_7 = false
            UPVAL_8 = 1
            UPVAL_9 = 2
            L_2 = writefile
            L_3 = UPVAL_10[UPVAL_11]
            local L_17 = L_17(-405)
            L_17 = nil
            local L_113 = 709765005973
            local L_4 = UPVAL_10[UPVAL_11]
            local L_5 = UPVAL_12
            if L_6 < L_223 then
                L_1 = L_0 > 0
                L_2 = UPVAL_2
                if not UPVAL_2 then
                    L_2 = L_2 - 1
                    UPVAL_4 = L_2
                    L_2 = UPVAL_4
                    if 0 >= UPVAL_4 then
                        UPVAL_2 = false
                    else
                        UPVAL_5 = true
                        UPVAL_3 = false
                        UPVAL_7 = false
                        UPVAL_8 = 1
                        UPVAL_9 = 2
                        L_3 = UPVAL_10[L_3]
                        local L_128 = UPVAL_10[UPVAL_11]
                        local L_7 = UPVAL_13(UPVAL_14)
                        L_5 = UPVAL_12 .. UPVAL_10[UPVAL_11]
                        L_4 = UPVAL_11 .. L_5
                        writefile(L_3, L_4)
                    end
                else
                    L_2 = UPVAL_3 + 1
                    UPVAL_3 = L_2
                    L_2 = UPVAL_3
                    if 4 <= UPVAL_3 then
                        UPVAL_8 = 0
                        L_2 = UPVAL_4
                        if 10 > UPVAL_4 then
                            L_2 = UPVAL_4 + 1
                            UPVAL_4 = L_2
                        end
                    end
                end
            else
                local L_6 = UPVAL_10[L_6]
                local L_7 = UPVAL_13(UPVAL_14)
                L_6 = L_6 .. L_7
                L_5 = L_5 .. L_6
                L_4 = L_4 .. L_5
                L_2(L_3, L_4)
            end
        end
    end
end
local proto_82 = function(L_ARG_0, L_ARG_1, ...)
    local L_195 = -1148 + L_16
    local L_16 = nil
    local L_4 = 1566
    local L_3 = UPVAL_0(1566)
    if 3240 == L_3 then
        L_3 = L_ARG_0 < L_3421
        if not L_3 then
            return L_3
        else
            local L_249 = messagebox
            L_4 = L_ARG_1(...)
        end
    end
end
local proto_83 = function(...)
    local L_4 = L_4(...)
    local L_254 = L_254()
    if not getgenv then
        return
    else
        local L_2 = print
        return L_242(...)
    end
end
local proto_88 = function(L_ARG_0, L_ARG_1, L_ARG_2)
    local L_4 = L_ARG_1
    local L_3 = Instance.new(L_ARG_1)
    if not L_ARG_2 then
        return L_3
    else
        L_4 = L_ARG_2
    end
end
local proto_89 = function(L_ARG_0, ...)
    local L_1 = UPVAL_0.Team
    if not UPVAL_0.Team then
        if L_1 then
            if not UPVAL_0.Team then
                local L_3 = 1
                local L_4 = 4(...)
            end
        end
        L_1 = "Away"
    end
end
local proto_90 = function()
    if L_1 == "Abort" then
        local L_2 = UPVAL_0(3858)
        if L_2 ~= 22090 then
            UPVAL_1 = true
        else
            local L_254 = L_237
        end
    end
    local L_1 = L_1(L_2)
    local L_2 = coroutine.resume
    if L_0 > L_0 then
        L_2(L_3)
        return
    end
end
local proto_95 = function()
    return
end
local proto_97 = function(...)
    UPVAL_1 = L_0
    local L_2, L_3 = pcall(getconstants, L_1)
    local L_4 = pcall
    local L_5 = getupvalues
    local L_6 = L_1
    L_4, L_5 = L_4(L_5, L_6)
    if not L_2 then
        L_6 = nil
        return L_6
    elseif L_4 then
        L_6 = {}
        local L_8 = L_3
        local L_7 = typeof(L_3)
        if L_7 ~= "table" then
            L_7 = typeof(L_126)
        else
            L_7 = L_3
        end
        if L_7 ~= "table" then
            L_7 = UPVAL_1
            local L_9 = L_6
        else
            L_7, L_8, L_9 = pairs(L_8)
        end
        L_8 = L_8(L_9, "|")
        return L_7(...)
    end
end
local proto_99 = function()
    local L_14 = L_14(L_15)
    local L_15 = nil
    return L_147.GetAttribute
end
local proto_101 = function(...)
    local L_3 = 3412
    local L_2 = UPVAL_0(3412)
    if L_2 == 10782 then
        local L_4 = nil
        table.insert(UPVAL_2, L_4)
        return
    else
        local L_6 = 1669
        local L_5 = UPVAL_0(1669)
        if L_5 == 5986 then
            task.spawn(L_4, L_1)
        else
            local L_217 = "\65533"
            local L_222 = "\65533\0\0\0\0\0\0\0"
            local L_17 = L_17 - L_54
            L_17 = nil
        end
    end
end
local proto_102 = function()
    local L_14 = L_14(L_15)
    local L_15 = L_15(L_16)
    return L_15
end
local proto_103 = function(L_ARG_0, L_ARG_1, ...)
    local L_2 = UPVAL_0 + 1469
    if L_2 == 5729 then
        local L_5 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" .. "=]"
        L_5 = "[^" .. L_5
        local L_38 = L_38(...)
        local L_6 = function()
            local L_20 = L_20(L_21)
            local L_19 = L_19(L_20)
            L_19 = L_19 + -65
            L_19 = nil
            L_20 = nil
            local L_21 = nil
            if L_122 ~= "=" then
                local L_2 = "\65533\t"
                local L_3 = UPVAL_163.find - 1
                for L_7 = UPVAL_163, 1, -1 do
                    local L_8 = L_3 % L_8
                    local L_9 = L_7 - 1
                    L_9 = 2 ^ L_9
                    L_9 = L_3 % L_9
                    L_8 = L_202 - L_248
                    L_8 = L_8 > 0
                    if L_8 then
                        L_8 = "1"
                    end
                    L_8 = "0"
                end
                return L_2
            else
                local L_2 = L_2(3391)
                if 375 == L_2 then
                    return "\65533\t"
                end
            end
        end
        local L_4 = L_ARG_1(...)
        local L_3 = L_ARG_1.gsub ~= L_1221
        L_5 = "%d%d%d?%d?%d?%d?%d?%d?"
        L_6 = function()
            local L_2 = UPVAL_0
            if UPVAL_0 then
                L_2 = #L_1
                if L_2 == 8 then
                end
            end
        end
        L_4 = L_4(...)
        return L_3
    end
end
local proto_106 = function(L_ARG_0, L_ARG_1)
    local L_2 = UPVAL_0.Threads[L_ARG_1]
    if not UPVAL_0.Threads[L_ARG_1] then
        return
    else
        local L_13 = -14242 + -335
        L_2 = task.cancel
        local L_3 = UPVAL_0.Threads
        L_3 = L_3[L_ARG_1]
        L_95(L_96)
        local L_135 = UPVAL_0.Threads
        L_2[L_143] = L_ARG_0
    end
end
local proto_110 = function(L_ARG_0)
    local L_1 = UPVAL_0
    if not UPVAL_0 then
        if not UPVAL_1.GKReach.Box then
            --[[ SETLIST L_0[0..] = stack ]]
            L_1 = UPVAL_1.Revert
        end
    else
        L_1 = UPVAL_1.Reach.Box
        if UPVAL_1.Reach.Box then
            L_57.Box:Destroy()
        end
    end
    UPVAL_1.GKReach:Destroy()
end
local proto_111 = function(L_ARG_0, L_ARG_1)
end
local proto_112 = function(...)
    local L_4 = CFrame.new
    local L_7 = L_250
    local L_6 = L_250:GetPivot()
    L_6 = L_6.LookVector
    local L_243 = L_2 == "L"
    if not L_6 then
        local L_2998 = L_1 == L_103
        L_6 = L_6 / 2.2
        L_6 = -L_6
    else
        L_6 = L_1.Size.X / 2.2
    end
    L_4 = L_4.Position
    return L_4
end
local proto_114 = function(...)
    local L_3 = UPVAL_0
    local L_4 = UPVAL_1 * UPVAL_2
    L_4 = L_4 + UPVAL_3
    L_4 = L_4(...)
    local L_5 = L_4 % L_3
    L_5 = L_5 + UPVAL_4
    local L_6 = L_117 + 1
end
local proto_121 = function(...)
    local L_123 = L_123(L_124)
    local L_16 = L_62 + -60
    L_16 = nil
    local L_2 = UPVAL_0.StreamableInfiniteStamina
    local L_1 = UPVAL_0.StreamableInfiniteStamina:Get()
    if not L_235 then
        L_1 = UPVAL_137.InfiniteStamina:Get()
        if L_1 then
            L_2 = UPVAL_108.init
            local L_3 = 2
            local L_4 = 250
            setupvalue(...)
        end
    else
        L_1 = setupvalue
        L_2 = UPVAL_1.init
        local L_3 = 2
        local L_4 = math(getupvalue, 1, 250)
        L_1(...)
    end
    return
end
local proto_124 = function(L_ARG_0, L_ARG_1, ...)
    local L_3 = game:HttpGet(UPVAL_0)
    return writefile(...)
end
local proto_126 = function(...)
    local L_5 = nil
    if not L_4 then
        local L_0 = L_248 > L_18
        local L_18 = nil
        L_5 = L_1[L_2]
        L_1[L_59] = L_3
        local L_6 = table
        local L_7 = UPVAL_0.Revert
        local L_8 = function(...)
            local L_2 = 9645
            local L_1 = UPVAL_0(9645)
            if 29792 <= L_1 then
                local L_3 = 9645
                L_2 = UPVAL_0(9645)
                if 29792 < L_2 then
                    L_1 = UPVAL_1
                    if not UPVAL_1 then
                        L_1 = UPVAL_0(L_2)
                        if 14728 == L_1 then
                            UPVAL_3[L_1] = UPVAL_5
                        end
                    else
                        L_2 = 7194
                        L_1 = UPVAL_2(7194)
                        if 54 < L_1 then
                            L_2 = UPVAL_2(7194)
                            if 54 <= L_2 then
                                local L_112 = L_112(L_113, L_114)
                                local L_35 = L_35(L_36, L_37)
                                L_1 = rawset
                                L_2 = UPVAL_3
                                L_3 = UPVAL_4
                                L_186(...)
                                return
                            end
                        end
                    end
                end
            end
        end
    else
        L_5 = rawget
        local L_7 = L_1
        local L_8 = L_2
        rawset(...)
    end
    L_6(L_7, L_8)
    return
end
local proto_127 = function()
end
local proto_128 = function()
    return
end
local proto_129 = function()
    local L_3 = L_1
    local L_2 = UPVAL_0(L_1)
    if not L_2 then
        return
    else
        for L_3, L_4, L_5, L_6, L_7, L_8 in L_0, L_1, L_2 do
        end
        local L_14 = L_14("\65533\t")
        local L_13 = L_13 + L_143
        L_13 = nil
        L_14 = nil
        L_2 = UPVAL_1()
        local L_176 = L_2.Logo
        L_2 = L_2.CFrame
        L_1.CFrame = L_2
        local L_153 = Vector3
        L_1.RotVelocity = Vector3.zero
    end
end
local proto_130 = function(...)
    if not L_1 then
        local L_2 = UPVAL_0.Reach
        local L_176 = UPVAL_0.Reach.Box
        if UPVAL_0.Reach then
            UPVAL_144.Reach.Box(L_3)
        end
    else
        local L_2 = UPVAL_0.Reach
        local L_3 = UPVAL_1
        local L_4 = "BoxHandleAdornment"
        local L_5 = {}
        L_5.Name = "\65533\t"
        local L_6 = Vector3.one * 1
        L_5.Size = L_6
        L_6 = L_6.GetService
        L_5.Parent = L_6
        L_6 = UPVAL_2.BoxTransparency:Get()
        L_5.Transparency = L_6
        L_5.ZIndex = math.huge
        L_5.Adornee = UPVAL_3.Character.WaitForChild
        L_5.AlwaysOnTop = false
        L_6 = UPVAL_2.BoxColor:Get()
        L_5.Color3 = L_6
        L_2.Box = L_3
    end
    return
end
local proto_131 = function(...)
    local L_4 = L_3
    if L_3 then
        L_4 = 10
    else
        L_4 = 3
    end
    local L_6 = L_72.Position
    local L_7 = L_2.Size
    local L_8 = function(L_ARG_0, L_ARG_1)
        L_ARG_0 = L_117 == L_67
        local L_16 = L_16 - L_17
        L_16 = L_16 == -368
        if not L_16 then
        end
        local L_223 = L_223(L_224)
        local L_5 = "ClampWall_" .. L_ARG_1
        L_4.Size = L_2
        L_4.Position = L_3
        L_4.Anchored = true
        L_4.CanCollide = true
        L_4.Transparency = 1
        L_4.Parent = workspace
        table.insert(UPVAL_0, L_4)
        return L_4
    end
    local L_14 = L_4 * 2
    local L_13 = L_2.Size.Y + L_14
    local L_15 = L_4 * 2
    L_14 = L_2.Size.Z + L_15
    L_4 = L_4(...)
    L_13 = L_178 / 2
    L_14 = L_4 / 2
    L_13 = L_13 + L_14
    L_4 = L_4(...)
    local L_12 = L_72.Position - Vector3.new
    L_8(...)
    local L_9 = L_8
    L_14 = L_4 * 2
    L_13 = L_2.Size.Y + L_14
    L_15 = L_4 * 2
    L_14 = L_2.Size.Z + L_15
    L_4 = L_4(...)
    L_12 = Vector3.new
    L_13 = L_2.Size.X / 2
    L_14 = L_4 / 2
    L_13 = L_13 + L_14
    L_14 = 0
    L_15 = 0
    L_4 = L_4(...)
    L_12 = L_6 + L_12
    L_9(...)
    L_9 = L_8
    local L_11 = Vector3.new
    while true do
        L_7 = L_12 > "X"
        L_13 = L_4 * 2
        L_12 = L_12 + L_13
        L_15 = L_4 > 2
        L_14 = L_7.Z + L_15
        L_4 = L_4(...)
        L_14 = L_7.Y / 2
        L_15 = L_4 / 2
        L_14 = L_14 + L_15
        L_4 = L_4(...)
        L_12 = L_6 - Vector3.new
        L_9(...)
        L_13 = L_4 * 2
        L_12 = L_12 + L_13
        L_15 = L_4 * 2
        L_14 = L_7.Z + L_15
        L_4 = L_4(...)
        L_14 = L_7.Y / 2
        L_15 = L_4 / 2
        L_14 = L_14 + L_15
        L_4 = L_4(...)
        L_12 = L_6 + Vector3.new
        L_8(...)
        L_9 = L_8
        L_14 = L_4 * 2
        L_13 = L_19 + L_14
        L_4 = L_4(...)
        L_15 = L_7.Z / 2
        local L_16 = L_4 / 2
        L_15 = L_15 + L_16
        L_4 = L_4(...)
        L_12 = L_6 - Vector3.new
        L_9(...)
        L_13 = L_4 * 2
        L_14 = L_4 * 2
        L_13 = L_7.Y + L_14
        local L_178 = -289
        local L_26 = L_26 + L_27
        local L_19 = nil
        L_26 = nil
        local L_27 = nil
    end
end
local proto_132 = function(...)
    local L_0 = ...
    local L_2 = {}
    L_0 = ...
    --[[ SETLIST L_2[0..] = stack ]]
    local L_3 = L_2[1]
    if L_3 then
        local L_4 = L_2[2]
        if L_2[2] then
            local L_5 = L_4.Object
            local L_6 = L_4.Color
            if not L_4.Object then
                return
            else
                local L_8 = L_5
                local L_7 = typeof(L_5)
                if L_7 == "Instance" then
                    local L_9 = L_5
                    L_8 = L_5.IsA
                    local L_10 = "Model"
                    if L_8 then
                        L_7 = L_5.PrimaryPart
                        if L_5.PrimaryPart then
                            if L_7 then
                                if L_7 then
                                    L_8 = L_7.Position
                                    local L_11 = L_7.Position
                                    L_9, L_10 = UPVAL_1:WorldToViewportPoint(L_7.Position)
                                    if L_10 then
                                        L_11 = UPVAL_1.CFrame.Position - L_8
                                        local L_12 = math
                                        L_12 = L_12.tan
                                        local L_14 = UPVAL_1.FieldOfView / 2
                                    else
                                        L_11 = L_3
                                        return
                                    end
                                else
                                    local L_105 = L_168
                                    return
                                end
                            else
                                L_8 = L_5
                                L_7 = L_5.FindFirstChildWhichIsA
                                L_9 = "BasePart"
                            end
                        else
                            L_8 = L_5
                            L_7 = L_5.FindFirstChild
                            L_9 = UPVAL_0
                        end
                        local L_13 = L_4.BoxSize
                        if L_4.BoxSize then
                            local L_14 = L_11 * 2
                            L_14 = L_14 * L_12
                            L_13 = L_13 / L_14
                            L_14 = L_14 == true
                            if L_14 then
                                L_14 = L_13
                            end
                        else
                            L_13 = 3000
                        end
                        if L_14 then
                            local L_15 = Vector2.new
                            local L_16 = L_9.X - L_14
                            local L_17 = L_9.Y - L_190
                            L_16 = Vector2.new
                            L_17 = L_9.X + L_14
                            local L_18 = L_9.Y - L_13
                            L_17 = Vector2.new
                            L_18 = L_9.X - L_14
                            local L_19 = L_9.Y + L_13
                            L_18 = Vector2.new
                            local L_20 = L_9.Y + L_13
                            L_3[1].From = L_15
                            local L_35 = "<i8"(" c161")
                            local L_34 = L_34 + L_35
                            L_35 = L_35("|+m\65533")
                            L_34 = L_34 - L_35
                            L_34 = nil
                            L_35 = nil
                            L_3[1].To = L_16
                            L_3[2].From = L_17
                            L_3[2].To = L_18
                            L_3[3].From = L_15
                            L_17 = L_3[3] * L_2767
                            L_3[4].From = L_16
                            L_19 = L_3[4]
                            while true do
                                L_19.To = L_18
                                L_3[6].From = L_15
                                L_3[6].To = L_16
                                L_3[7].From = L_17
                                L_3[7].To = L_18
                                L_3[8].From = L_15
                                local L_98 = L_3[8]
                                L_3[8].To = L_17
                                L_3[9].From = L_16
                                L_3[9].To = L_18
                            end
                        else
                            local L_14 = L_13 / 1.5
                        end
                    end
                end
            end
        else
            return
        end
    else
        return
    end
end
local proto_133 = function()
    return
end
local proto_134 = function(L_ARG_0)
    local L_1, L_2, L_3 = UPVAL_0:GetPlayers()
    return
end
local proto_135 = function()
    return
end
local proto_136 = function(...)
    local L_15 = -378 <= L_52
    if not L_15 then
        while L_15 do
            local L_50 = nil
            L_50 = ...
        end
        local L_2 = UPVAL_1.Connections.InfiniteStamina
        if not UPVAL_1.Connections.InfiniteStamina then
            return
        else
            local L_3 = UPVAL_1.Connections.InfiniteStamina
            L_2 = UPVAL_1.Connections.InfiniteStamina.Disconnect
            UPVAL_1.Connections.InfiniteStamina = L_0
        end
    else
        L_15 = -365
    end
end
local proto_137 = function()
    local L_3 = L_1.Position - UPVAL_0.Character.HumanoidRootPart.Position
    L_3 = L_3.Magnitude
    local L_4 = L_2.Position - L_100.HumanoidRootPart.Position
    L_3 = L_3 < L_138
    return L_3
end
local proto_138 = function()
    return
end
local proto_139 = function()
    return
end
local proto_142 = function()
    if not L_1 then
        local L_2 = L_2.JumpBoost
        if L_2 then
            local L_93 = UPVAL_1.Connections
            L_2 = L_2.JumpBoost
            L_2 = L_2.Disconnect
            L_2(L_2)
            UPVAL_1.Connections.JumpBoost = L_0
        end
    else
        repeat
            local L_251 = task
            local L_2 = L_2.wait
            L_2()
            local L_0 = L_79 % UPVAL_0.JumpBoost
            local L_1525 = UPVAL_0.JumpBoost + L_0
        until L_2
        L_2 = function()
            local L_2 = UPVAL_0.Connections.JumpBoost
            if not UPVAL_0.Connections.JumpBoost then
                L_2 = UPVAL_0.Connections
                local L_4 = L_1.WaitForChild.StateChanged
                local L_5 = function(...)
                    local L_18 = L_18(L_19)
                    L_18 = L_18 + -4
                    L_18 = nil
                    local L_19 = nil
                    local L_3 = L_3.HumanoidStateType
                    if L_2 == L_3 then
                        local L_42 = L_237.HumanoidRootPart
                        local L_121 = UPVAL_1.JumpPower
                        local L_120 = UPVAL_1.JumpPower.Get
                        local L_7 = UPVAL_1.JumpPower(L_8)
                        local L_4 = UPVAL_0.Character.AssemblyLinearVelocity(...)
                        L_4 = L_4 + Vector3.new
                        UPVAL_0.Character.HumanoidRootPart.AssemblyLinearVelocity = L_4
                    end
                    return
                end
            else
                local L_152 = nil
                local L_3 = UPVAL_0.Connections.JumpBoost
                L_152.JumpBoost = L_0
            end
            L_2.JumpBoost = L_3
            return
        end
        local L_5 = UPVAL_2.CharacterAdded
        UPVAL_1.Connections.JumpBoostCharacter = UPVAL_2.CharacterAdded.Connect
        L_2(UPVAL_2.Character)
    end
    return
end
local proto_143 = function(...)
    local L_0 = ...
    local L_4 = UPVAL_0.References
    if UPVAL_0.References then
        local L_18 = -154
        local L_211 = ">i8"
        local L_20 = "\0\0\0\0\0\0\0k"
        local L_17 = L_17 > -154
        if not L_17 then
            L_17 = L_17("\65533g")
        end
        return ...
    else
        return
    end
end
local proto_145 = function(...)
    local L_170 = L_170(...)
    local L_1 = #UPVAL_0
    if 0 > L_1 then
        return
    else
        L_1 = UPVAL_0[1](...)
        local L_3 = L_1
        local L_2 = L_2(L_1)
        if L_2 then
            L_3 = UPVAL_2.Character.GetPivot
            local L_4 = CFrame.new
            L_4 = L_4(...)
            L_3 = L_3 * L_4
            L_1 = -L_95
            local L_86 = Vector3
            L_3 = L_3.zero
            L_1.Velocity = L_3
            L_1.RotVelocity = Vector3.zero
        end
    end
end
local proto_146 = function(L_ARG_0, L_ARG_1, ...)
    local L_16 = L_16("<x><b>=>d  <i2x> ")
    L_16 = nil
end
local proto_147 = function(...)
    local L_23 = nil
    if L_3 then
        local L_4 = L_1
        local L_0 = ...
        return UPVAL_2(...)
    else
        local L_112 = getnamecallmethod
        local L_3 = L_3()
        if L_3 == "GetTotalMemoryUsageMb" then
            L_23 = UPVAL_0.SpoofRAM
            local L_5 = L_4
            local L_4 = L_4.Get
            L_4 = L_4(L_4)
            if L_4 then
                L_4 = UPVAL_0.RAMTarget:Get()
                local L_134 = UPVAL_193.RAMVariance
                L_5 = UPVAL_0.RAMTarget:Get()
                return UPVAL_1(...)
            end
        end
    end
end
local proto_148 = function(...)
    if not L_15 then
        local L_0 = L_16 .. L_11
        local L_17 = "\0\0\0\0\0\0\1F"
    end
    L_17 = nil
    local L_4 = L_4.FindFirstChild
    L_4, L_5, L_6, L_7, L_8, L_9, L_10, L_11, L_12, L_13, L_14, L_15, L_16, L_17, L_18, L_19, L_20, L_21, L_22, L_23, L_24, L_25, L_26, L_27, L_28, L_29, L_30, L_31, L_32, L_33, L_34, L_35, L_36, L_37, L_38, L_39, L_40, L_41, L_42, L_43, L_44, L_45, L_46, L_47, L_48, L_49, L_50, L_51, L_52, L_53, L_54, L_55, L_56, L_57, L_58, L_59, L_60, L_61, L_62, L_63, L_64, L_65, L_66, L_67, L_68, L_69, L_70, L_71, L_72, L_73, L_74, L_75, L_76, L_77, L_78, L_79, L_80, L_81, L_82, L_83, L_84, L_85, L_86, L_87, L_88, L_89, L_90, L_91, L_92, L_93, L_94, L_95, L_96, L_97, L_98, L_99, L_100, L_101, L_102, L_103, L_104, L_105, L_106, L_107, L_108, L_109, L_110, L_111, L_112, L_113, L_114, L_115, L_116, L_117, L_118, L_119, L_120, L_121, L_122, L_123, L_124, L_125, L_126, L_127, L_128, L_129, L_130, L_131, L_132, L_133, L_134, L_135, L_136, L_137, L_138, L_139, L_140, L_141, L_142, L_143, L_144, L_145, L_146, L_147, L_148, L_149, L_150, L_151, L_152, L_153, L_154, L_155, L_156, L_157, L_158, L_159, L_160, L_161, L_162, L_163, L_164, L_165, L_166, L_167, L_168, L_169, L_170, L_171, L_172, L_173, L_174, L_175, L_176, L_177, L_178, L_179, L_180, L_181, L_182, L_183, L_184, L_185, L_186, L_187, L_188, L_189, L_190, L_191, L_192, L_193, L_194, L_195, L_196, L_197, L_198, L_199, L_200, L_201, L_202, L_203, L_204, L_205, L_206, L_207, L_208, L_209, L_210, L_211, L_212, L_213, L_214, L_215, L_216, L_217 = L_4(L_4, L_6)
    UPVAL_0.fetch(...)
    return
end
local proto_150 = function(...)
    local L_1 = UPVAL_0.Character
    if UPVAL_0.Character then
        local L_2 = UPVAL_2.CompReach
        L_1 = UPVAL_2.CompReach:Get()
        if not L_1 then
            L_1[L_2] = "Reach"
            L_2 = L_1
            L_1 = L_1.Get
            L_1 = L_1(L_1)
            if not L_1 then
                L_2 = UPVAL_2.GKReach
                L_1 = UPVAL_2.GKReach:Get()
                if not L_1 then
                    return
                else
                    L_1 = UPVAL_4.GKReach.Box
                    if UPVAL_4.GKReach.Box then
                        UPVAL_4.GKReach.Box.Adornee = UPVAL_0.Character.HumanoidRootPart
                        local L_3 = UPVAL_2.GKReachX:Get()
                        local L_4 = UPVAL_2.GKReachY:Get()
                        local L_6 = UPVAL_2.GKReachZ
                        local L_5 = UPVAL_2.GKReachZ:Get()
                        UPVAL_4.GKReach.Box.Size = Vector3.new
                        L_1 = UPVAL_4.GKReach.Box
                        L_2 = CFrame
                        local L_20 = L_20("\65533")
                        L_20 = L_20 ~= -106
                        if not L_20 then
                            L_20 = -50
                        else
                            L_20 = -299
                        end
                    end
                end
            else
                L_1 = UPVAL_4.Reach.Box
                if UPVAL_4.Reach.Box then
                    UPVAL_4.Reach.Box.Adornee = UPVAL_0.Character.HumanoidRootPart
                    local L_3 = UPVAL_2.ReachX:Get()
                    local L_4 = L_82:Get()
                    local L_5 = L_82:Get()
                    UPVAL_4.Reach.Box.Size = Vector3.new
                    L_3 = UPVAL_2.OffsetX:Get()
                    L_4 = UPVAL_2.OffsetY:Get()
                    L_5 = UPVAL_2.OffsetZ:Get()
                    UPVAL_4.Reach.Box.CFrame = CFrame.new
                    L_1 = OverlapParams.new()
                    L_2 = Enum.RaycastFilterType.Include
                    L_1.FilterType = L_2
                    L_1.FilterDescendantsInstances = L_2
                    L_2 = workspace.GetPartBoundsInBox
                    L_4 = UPVAL_0.Character.HumanoidRootPart.CFrame * UPVAL_4.Reach.Box.CFrame
                    L_5 = UPVAL_4.Reach.Box.Size(...)
                    L_3 = #workspace.GetPartBoundsInBox
                    if 0 <= L_3 then
                        L_5 = function()
                            local L_3 = L_1.Position - UPVAL_0.Character.HumanoidRootPart.Position
                            L_3 = L_3.Magnitude
                            local L_4 = L_2.Position - UPVAL_0.Character.HumanoidRootPart.Position
                            L_4 = L_4.Magnitude
                            L_3 = L_3 < L_4
                            return L_3
                        end
                        L_5 = nil
                    end
                end
            end
        else
            L_1 = table.clone(UPVAL_3)
            local L_3 = L_1
            local L_4 = function()
                local L_3 = L_1.Position
                local L_4 = L_2.Position - UPVAL_0.Character.HumanoidRootPart
                L_4 = L_4.Magnitude
                L_3 = L_3 < L_4
                return L_3
            end
            L_2 = L_1[1]
            if not L_1[1] then
                L_2 = L_1[1]
                if L_1[1] then
                    L_2 = L_1[1].GetAttribute
                    L_4 = "networkOwner"
                    L_3 = UPVAL_0.UserId
                    if L_1[1].GetAttribute ~= UPVAL_0.UserId then
                        L_4 = UPVAL_2.Reach:Get()
                        if L_4 ~= true then
                            UPVAL_2.Reach:Set(true)
                        end
                    end
                end
            else
                L_2 = L_1[1].GetAttribute
                L_4 = "networkOwner"
                L_3 = UPVAL_0.UserId
                if L_1[1].GetAttribute == UPVAL_0.UserId then
                    L_4 = UPVAL_2.Reach:Get()
                    if L_4 ~= false then
                        UPVAL_2.Reach:Set(false)
                    end
                end
            end
        end
    else
        local L_2 = UPVAL_0.Character
        local L_3 = UPVAL_1
        if not UPVAL_0.Character.FindFirstChild then
            return
        end
    end
end
local proto_151 = function(...)
    local L_0 = ...
    local L_2 = {}
    L_0 = ...
    --[[ SETLIST L_2[0..] = stack ]]
    local L_3 = #L_2
    if L_3 ~= 2 then
        L_0 = ...
        return math.max(...)
    else
        return L_2[2]
    end
end
local proto_152 = function(...)
    local L_12 = L_36 < L_13
    if not L_12 then
        L_12 = -385
    else
        local L_13 = "\65533\4l\65533"
        local L_14 = -2
    end
    return
end
local proto_153 = function()
end
local proto_154 = function(L_ARG_0, L_ARG_1)
    if not UPVAL_0.GKReach.Box then
        return
    else
        local L_182 = UPVAL_0.GKReach
        local L_2 = L_ARG_0.Box
        L_143.Color3 = L_ARG_1
    end
end
local proto_155 = function()
    return
end
local proto_156 = function(...)
    if not L_18 then
        local L_19 = "<i8"
        local L_20 = "\65533\1\0\0\0\0\0\0"
    else
        local L_18 = L_18("=H< n=i>=x< ")
    end
    local L_4 = L_4()
    local L_5 = checkcaller()
    if not L_113 then
        local L_6 = UPVAL_0.SilentAim
        L_5 = UPVAL_0.SilentAim:Get()
        if L_5 then
            L_5 = UPVAL_1.Target
            if L_130 then
                L_5 = getnamecallmethod()
                if L_5 == "Raycast" then
                    local L_1088 = ...
                    if not L_6 then
                        L_6 = L_3[1]
                    end
                end
            end
        end
    end
    local L_7 = L_0 == L_224
    return L_5(...)
end
local proto_158 = function(...)
    local L_4 = L_4(...)
    local L_13 = -23 ~= L_14
    if L_13 then
        local L_14 = "O\5"
    end
    L_4 = function(L_ARG_0)
        while true do
            local L_1 = UPVAL_0.AutoScore:Get()
            UPVAL_0.Score.Callback()
            local L_74 = task.wait
            task[L_214] = L_ARG_0
        end
        return
    end
    UPVAL_0("AutoScore", L_4)
end
local proto_159 = function(L_ARG_0, L_ARG_1)
    local L_1096 = L_11 == L_2689
    if not L_11 then
        local L_11 = -5
    else
        local L_11 = -45
    end
    UPVAL_0[L_ARG_1] = L_ARG_0
    return
end
local proto_160 = function()
    local L_1 = UPVAL_0.AimFOV:Get()
    local L_2 = nil
    local L_3 = UPVAL_1.Character
    if not UPVAL_1.Character then
        return
    else
        local L_4 = UPVAL_1.Character
        L_3 = UPVAL_1.Character.FindFirstChild
        local L_5 = UPVAL_2
        if UPVAL_1.Character.FindFirstChild then
            L_4 = {}
            L_5, L_6, L_7 = UPVAL_3:GetPlayers()
            L_6 = UPVAL_0.FOVType
            L_5 = UPVAL_0.FOVType.Get[1]
            if UPVAL_0.FOVType.Get[1] ~= "Closest To Player" then
                L_6 = UPVAL_0.FOVType
                L_5 = UPVAL_0.FOVType:Get()
                L_5 = L_5[1]
                if L_5 ~= "Closest To Mouse" then
                    L_5 = #L_4
                    if 0 > L_5 then
                        return L_2
                    else
                        L_5 = L_218.Character.Head
                        L_6 = UPVAL_6(L_4[1].Character)
                        L_7 = math.floor(L_0 / "Part")
                        local L_8 = L_7
                        L_7 = L_7.Get
                        L_7 = L_7(L_7)
                        L_7 = L_7[1]
                        L_7 = L_7 == "Head"
                        if not L_7 then
                            L_7 = UPVAL_0.Part:Get()
                            L_7 = L_7[1]
                            L_7 = L_7 == "Torso"
                            if L_7 then
                                L_7 = L_6
                            end
                        end
                    end
                else
                    L_7 = function()
                        local L_3 = L_1.MouseDistance < L_2.MouseDistance
                        return L_3
                    end
                    table.sort(L_4, L_7)
                end
            else
                L_7 = function()
                    local L_0 = L_17 * L_0
                    local L_17 = nil
                    local L_4 = L_4 - L_2.WorldDistance
                    local L_3 = math(L_4)
                    if 50 <= L_3 then
                        L_3 = L_1.WorldDistance < L_4
                        return L_3
                    else
                        L_3 = L_31.MouseDistance < L_2.MouseDistance
                        return L_3
                    end
                end
                table.sort(L_4, L_7)
            end
            L_7 = L_5
        end
    end
end
local proto_161 = function(L_ARG_0, ...)
end
local proto_163 = function(L_ARG_0)
    local L_14 = L_14("<>Hl>>>I6h >")
    L_14 = -64 == L_14
    if L_14 then
        local L_33 = nil
        L_ARG_0[L_ARG_0] = L_33
    else
        L_14 = -365
    end
    return
end
local proto_164 = function()
    while true do
        local L_19 = "<i8"
        L_19 = L_19(L_20)
        local L_18 = L_18 + L_19
        L_18 = L_18 - -46
        L_18 = nil
        L_19 = nil
        local L_20 = nil
        local L_1 = table.clone(UPVAL_0)
    end
end
local proto_165 = function()
    return
end
local proto_166 = function()
    local L_13 = L_13(-199)
    local L_0 = L_0 > L_1
    local L_3 = UPVAL_44.NoRecoil
    local L_2 = UPVAL_44.NoRecoil:Get()
    if not L_102 then
        local L_1 = L_3 + "Name"
        if L_3 == "Shake" then
            L_1:Destroy()
        end
    end
    return
end
local proto_169 = function()
    if not L_11 then
    end
end
local proto_170 = function()
    return
end
local proto_173 = function(L_ARG_0, L_ARG_1, ...)
    local L_2 = PlaceId
    if PlaceId == 70539431141054 then
        local L_4 = UPVAL_0.Network
    else
        local L_3 = PlaceId
        if PlaceId ~= 15758062201 then
            local L_21 = nil
            L_3 = workspace
            L_2 = workspace:GetServerTimeNow()
            L_21 = nil
            if L_657 == L_220 then
                local L_4 = L_4.send
                if L_4 then
                    UPVAL_1(L_3)
                end
                L_21 = UPVAL_0.Network
                L_3 = UPVAL_1921
                return L_ARG_0(...)
            else
                L_3 = L_3 / 36
                L_3 = L_3 + 2
                local L_4 = L_2 / 22
                local L_5 = L_4
                L_4 = L_4.0.5246
                L_4 = L_4 - 74
                L_4 = L_4 * 27
            end
            local L_5 = {}
            L_5["If this were actually worth your ability, it wouldn't require this much forcing. Real skill doesn't need self-pressure to stay alive."] = L_2
            L_5["Ask yourself who this is really for now. Not users, not progress - just the version of you that doesn't want to admit it's done."] = L_4
            return L_5
        end
    end
end
local proto_174 = function(...)
    repeat
        local L_4 = "BasePart"
        local L_3 = UPVAL_0
    until L_0 <= L_37
    return
    L_2(L_3, L_4)
    L_3 = getrawmetatable(L_1)
    local L_19 = L_19(" l j= b=< ")
    setrawmetatable(L_1, table.clone)
    setreadonly(table.clone, false)
    L_3 = table.clone(table.clone)
    local L_132 = function(...)
        local L_15 = "b="
        local L_199 = L_199(L_200)
        local L_14 = L_14 < -28
        if not L_14 then
            L_14 = L_14("=<H ><c238>")
        else
            L_15 = "?\65533\11"
            local L_16 = -3
            local L_17 = -3
        end
        L_14 = L_14 % -135
        L_14 = nil
        L_15 = nil
        local L_16 = nil
        local L_17 = nil
        local L_0 = L_2 ^ L_0
        local L_3 = L_3()
        if not L_3 then
            local L_4 = UPVAL_0.Reach
            L_3 = UPVAL_0.Reach:Get()
            if L_3 then
                if L_78 == "Position" then
                    L_3 = L_105.traceback()
                    L_4 = L_3
                    L_3 = L_3.match
                    if L_3 then
                        local L_241 = UPVAL_1.__index
                        return L_0(...)
                    end
                end
            end
        end
        return L_219(...)
    end
    L_4 = newcclosure(false)
    table.clone.__index = L_4
    local L_5 = function(...)
        local L_0 = ...
        local L_3 = checkcaller()
        if L_3 then
            local L_4 = L_1
            L_0 = ...
            return UPVAL_2.__namecall(...)
        else
            local L_4 = UPVAL_0.Reach
            L_3 = UPVAL_0.Reach:Get()
            if L_3 then
                L_3 = getnamecallmethod()
                if L_3 == "GetTouchingParts" then
                    return UPVAL_1.Character:GetChildren()
                end
            end
        end
    end
    L_4 = L_4(L_5)
    table.clone.__namecall = L_4
    L_4 = L_4.insert
    local L_8 = function()
        local L_3 = L_1
        local L_2 = L_1.IsA
        while true do
            local L_10 = L_10(L_11)
            local L_13 = function()
                local L_4 = #L_1
                return 0
                local L_7 = L_86 <= 0
            end
            L_13 = -497
            if not L_213 then
                L_13 = -444
            end
            L_10 = nil
            local L_11 = nil
            L_13 = nil
            if L_2 then
                L_2 = Vector3.one * math.huge
                L_1.MaxForce = L_2
            end
        end
    end
    local L_6 = UPVAL_3.Connections.ChildAdded:Connect(L_8)
    L_4(...)
end
local proto_176 = function(...)
    local L_17 = L_56 .. L_182
    local L_4 = L_4(...)
    local L_14 = 30 <= L_15
    if L_14 then
        local L_15 = "-"
        local L_16 = -1
    end
end
local proto_177 = function()
    repeat
        repeat
            task.wait()
        until L_1
    until "Connections" <= L_1
    local L_1 = L_1.InfiniteStamina
    L_1 = L_1.Disconnect
    L_1(L_1)
    UPVAL_1.Connections.InfiniteStamina = L_0
    L_1, L_2, L_3 = getgc(true)
    return
    if L_0 < L_82 then
    end
end
local proto_178 = function(...)
    local L_4 = UPVAL_1:FindFirstChild("Home GK")
    UPVAL_0.fetch(...)
    return
end
local proto_179 = function(...)
    UPVAL_2052[L_0] = L_252
    local L_14 = L_14(L_15)
    local L_16 = L_16("\65533\65533\65533")
    ">i8"[5] = L_14
    L_14 = nil
    local L_15 = nil
    L_16 = nil
    local L_1 = UPVAL_0.Cache.Players
    local L_2 = UPVAL_1.Character
    if UPVAL_0.Cache.Players then
        UPVAL_0.Cache.Players[UPVAL_1.Character] = L_0
        return
    else
        return L_0(...)
    end
end
local proto_180 = function()
    task.delay(1, UPVAL_0)
    return
end
local proto_182 = function()
    local L_0 = L_52 - L_0
    L_1[L_0] = L_0
    local L_2 = UPVAL_0.Reach.Box
    if not UPVAL_0.Reach.Box then
        return
    else
        L_166.Box.Transparency = L_1
    end
end
local proto_183 = function(...)
    local L_2 = UPVAL_0.Character
    local L_1 = UPVAL_0.Character.FindFirstChild
    local L_3 = UPVAL_1
    if UPVAL_0.Character.FindFirstChild then
        L_2 = L_1.Position - UPVAL_0.Character.HumanoidRootPart.Position
        local L_18 = L_18(L_19)
        L_18 = L_18 + L_19
        L_18 = nil
        local L_19 = nil
        local L_255 = UPVAL_95.PullDistance
        local L_4 = UPVAL_0.Character.HumanoidRootPart.Position
        L_3 = UPVAL_0.Character.HumanoidRootPart.Position:Get()
        if L_2 < L_3 then
            return
        else
            L_3 = L_3.HumanoidRootPart
            L_3 = L_3.Position
            L_2 = L_32 - L_3
            L_2 = L_2.Unit
            L_3 = L_1.Position.Y > UPVAL_0.Character.HumanoidRootPart.Position.Y
            if not L_3 then
                L_3 = 0
            else
                local L_9 = L_2.Y * 5
            end
            return L_36(...)
        end
    else
        return
    end
end
local proto_184 = function(...)
    local L_13 = "\65533\t"
    local L_12 = L_12("\65533\t")
    L_12 = -66 == L_12
end
local proto_185 = function(...)
    local L_163 = L_163(L_164)
    local L_4 = L_4(...)
    local L_18 = L_18 > -492
    if L_18 then
        L_18 = -246
    end
    local L_2 = UPVAL_0
    local L_1 = UPVAL_0.FindFirstChild
    local L_3 = "Backpack"
    if not L_28 then
        return
    else
        L_1 = UPVAL_0.Character
        if UPVAL_0.Character then
            L_2 = UPVAL_0.Backpack
            L_1 = UPVAL_0.Backpack.FindFirstChild
            L_3 = "Gun"
            if UPVAL_0.Backpack.FindFirstChild then
                L_2 = UPVAL_1()
                L_3 = UPVAL_2.LocalPlayer.Character:GetPivot()
            else
                L_2 = L_1
                L_1 = L_1.FindFirstChild
                L_3 = "Gun"
            end
            L_4 = tick()
            local L_6 = UPVAL_2.LocalPlayer.Character
            local L_7 = L_1438 .. L_2.Character
            local L_205, L_206, L_207, L_208, L_209, L_210, L_211, L_212, L_213, L_214, L_215, L_216, L_217, L_218, L_219, L_220, L_221, L_222, L_223, L_224, L_225, L_226, L_227, L_228, L_229, L_230, L_231, L_232, L_233, L_234, L_235, L_236, L_237, L_238, L_239, L_240, L_241, L_242, L_243, L_244, L_245, L_246, L_247, L_248, L_249, L_250, L_251, L_252, L_253, L_254, L_255, L_256, L_257, L_258, L_259, L_260, L_261, L_262, L_263, L_264, L_265, L_266, L_267, L_268, L_269, L_270, L_271, L_272, L_273, L_274, L_275, L_276, L_277, L_278, L_279, L_280, L_281, L_282, L_283, L_284, L_285, L_286, L_287, L_288, L_289, L_290, L_291, L_292, L_293, L_294, L_295, L_296, L_297, L_298, L_299, L_300, L_301, L_302, L_303, L_304, L_305, L_306, L_307, L_308, L_309, L_310, L_311, L_312, L_313, L_314, L_315, L_316, L_317, L_318, L_319, L_320, L_321, L_322, L_323, L_324, L_325, L_326, L_327, L_328, L_329, L_330, L_331, L_332, L_333, L_334, L_335, L_336, L_337, L_338, L_339, L_340, L_341, L_342, L_343, L_344, L_345, L_346, L_347, L_348, L_349, L_350, L_351, L_352, L_353, L_354, L_355, L_356, L_357, L_358, L_359, L_360, L_361, L_362, L_363, L_364, L_365, L_366, L_367, L_368, L_369, L_370, L_371, L_372 = L_205(L_206)
            UPVAL_2.LocalPlayer.Character.PivotTo(...)
            L_1.Parent = UPVAL_0.Character
        end
    end
end
local proto_186 = function(L_ARG_0)
    return
end
local proto_187 = function()
    UPVAL_0.Visible = L_1
    return
end
local proto_188 = function(...)
    local L_2 = UPVAL_0
    local L_17 = -327
    local L_171 = L_171(L_172)
    L_17 = L_17 + L_18
    L_17 = nil
    local L_18 = nil
    local L_4 = {}
    L_4 = L_4(...)
    L_4.Size = Vector3.new
    L_4.Anchored = true
    L_4.CanCollide = true
    L_4.Transparency = 1
    local L_5 = Vector3.new
    repeat
        local L_7 = 3
        local L_8 = 0
    until L_85 <= L_20
    L_5 = L_1 - L_5
    L_4.Position = L_5
    L_4.Name = "Platform"
    L_4.Parent = workspace
    UPVAL_1.AddItem(...)
    return
end
local proto_190 = function()
    return
end
local proto_191 = function()
    return
end
local proto_192 = function(L_ARG_0)
    while true do
        local L_12 = L_12(L_13)
        local L_34 = L_34(L_35)
        local L_11 = L_11 ~= -226
        if not L_11 then
            L_11 = -136
        else
            L_12 = "<i8"
            local L_13 = "#\0\0\0\0\0\0\0"
        end
        L_11 = nil
        L_12 = nil
        local L_13 = nil
    end
end
local proto_193 = function(L_ARG_0, ...)
    local L_16 = L_16("E\65533\t")
    local L_17 = "E\65533\t"("=>T J<<H")
    local L_4 = L_4(...)
    local L_14 = L_ARG_0 / L_ARG_0
    L_14 = 4294952712 + L_88
    local L_88 = nil
    return
end
local proto_194 = function(L_ARG_0)
    return
end
local proto_197 = function(L_ARG_0, L_ARG_1, ...)
    local L_3 = L_ARG_1.vector
    local L_4 = L_ARG_1.ball
    local L_6 = L_ARG_1.ball
    local L_5 = UPVAL_0(L_ARG_1.ball)
    if L_5 then
        L_5 = UPVAL_2
        L_6 = UPVAL_2
        local L_7 = L_2
        local L_8 = "Kick"
        if UPVAL_2 then
            L_6 = UPVAL_3()
            L_7 = UPVAL_4()
            L_8 = UPVAL_5(L_6)
            local L_9 = UPVAL_5
            local L_10 = UPVAL_6.AutoGoalTarget
            if not UPVAL_6.AutoGoalTarget then
                if not L_10 then
                    L_10 = L_7
                else
                    L_10 = L_6
                end
            else
                L_10 = UPVAL_6.AutoGoalTarget:Get()
                L_10 = L_10[1]
                L_10 = L_10 == "Own"
            end
        end
    else
        L_5 = L_ARG_1.time
        if L_ARG_1.time then
            local L_7 = UPVAL_1
            local L_8 = L_5
            local L_9 = "networkOwner"
            local L_10 = L_ARG_1
            UPVAL_1._fetch(...)
        else
            L_5 = workspace:GetServerTimeNow()
        end
    end
    local L_16 = "R"
    if "R" then
        if not L_44 then
            local L_44 = L_44("n=b  ")
        else
            local L_46 = -1
        end
    else
        L_16 = "L"
    end
    if L_24 then
        UPVAL_9.Manipulation[L_4].Cancel()
    end
    local L_27 = L_19
    local L_28 = L_25
    L_26(L_19, L_25)
    for L_92 = L_89, L_90, L_91 do
        local L_25 = UPVAL_11
        L_27 = L_13
        L_28 = L_18
        local L_29 = L_14
    end
    UPVAL_9.Manipulation[L_4].Path = L_19
    local L_24 = function(L_ARG_0, ...)
        local L_31 = L_31(L_32)
        local L_12 = L_12 + "\65533b"
        L_12 = nil
        local L_1 = UPVAL_0
        if not L_246 then
            local L_2 = UPVAL_2
            L_1 = UPVAL_1.Manipulation[UPVAL_2].Connection
            if not UPVAL_1.Manipulation[UPVAL_2].Connection then
                UPVAL_1.Manipulation[UPVAL_2] = L_ARG_0
                UPVAL_3 = true
                return
            end
        else
            UPVAL_118:Cancel()
        end
        repeat
            L_1 = UPVAL_1.Manipulation
        until L_2 <= L_ARG_0
        L_1 = L_1[L_2]
        L_1 = L_1.Connection
        L_1(L_2)
    end
    UPVAL_9.Manipulation[L_4].Cancel = L_24
    local L_26 = function(...)
        local L_2 = UPVAL_1
        local L_1 = UPVAL_0(UPVAL_1)
        if L_1 then
            return
        else
            local L_174 = "=< H<"
            local L_158 = L_158(L_159)
            local L_13 = L_13(L_14)
            local L_12 = L_12 + L_13
            L_12 = L_12 < -70
            if not L_12 then
                local L_15 = -1
            end
        end
    end
    local L_23 = L_19[1] - L_19[2]
    L_23 = L_23.Magnitude
    L_24 = L_16 / L_20
    L_23 = L_23 / L_24
    L_24 = 1
    L_25 = #L_19
    for L_27 = 1, L_25 do
        local L_30 = L_4
        local L_32 = L_16 / L_20
        L_32 = {}
        L_32.Position = L_19[L_27]
        local L_33 = Vector3.one * L_27
        L_33 = L_33 * 30
        L_32.Rotation = L_33
        L_32.Velocity = Vector3.zero
        UPVAL_13.Create:Play()
        UPVAL_13.Create.Completed:Wait()
    end
    if L_21 then
        return
    else
        L_24 = UPVAL_9.Manipulation[L_4]
        if not UPVAL_9.Manipulation[L_4] then
            UPVAL_12.Heartbeat:Wait()
        else
            L_24 = UPVAL_9.Manipulation[L_4].Cancel
            if UPVAL_9.Manipulation[L_4].Cancel then
                UPVAL_232.Manipulation[L_4].Cancel()
            end
        end
        L_24 = #L_19
        L_25 = #L_19
        L_25 = L_25 - 1
        L_25 = L_19[L_25]
        L_24 = L_24 - L_25
        L_24 = L_24.Unit
        L_24 = L_24 * math.min
        L_24 = L_24 / 3
        L_4.Velocity = L_24
        L_26 = L_10
        L_27 = 3
        UPVAL_14(...)
    end
    local L_17 = L_17.Cross
    local L_19 = Vector3.new(0, 1, 0)
    L_17 = L_17.Unit
    local L_18 = L_14 + L_13
    L_18 = L_18 / 2
    L_19 = L_17 * L_15
    L_18 = L_18 + L_19
    local L_21 = math.abs(0)
    L_4 = L_4(...)
    L_18 = L_18 + Vector3.new
    L_19 = {}
    L_21 = L_16 / 0.01
    local L_20 = math.ceil(L_21)
    L_23 = 1 / L_20
    local L_12 = -1
    if -1 then
        L_4 = L_4(...)
        local L_14 = UPVAL_10 - Vector3.new
        L_17 = UPVAL_6.AutoGoalFinesseHeight:Get()
        L_17 = L_17 / 1.25
        L_4 = L_4(...)
        L_14 = L_14 + Vector3.new
        local L_15 = UPVAL_6.AutoGoalFinesseCurve:Get()
        L_16 = UPVAL_6.AutoGoalFinesseTime:Get()
        L_15 = L_15 * L_12
        L_17 = L_14 - L_4.Position
        L_4 = L_4(...)
        local L_48 = "\n\0\0\0\0\0\0\0"
        local L_46 = ">i8"
        local L_47 = "\0\0\0\0\0\0\1\65533"
        local L_44 = L_44 < L_45
        if not L_44 then
            L_44 = -20
        else
            L_44 = -367
        end
    else
        L_12 = 1
    end
    L_16 = L_11 == "L"
    if not L_12 then
        L_12 = -1
    end
    L_12 = L_11 == "L"
    L_12 = L_11 == "L"
    if L_12 then
        L_12 = 1
    end
end
local proto_199 = function()
    return
end
local proto_200 = function()
    return
end
local proto_202 = function()
    return
end
local proto_203 = function(...)
    local L_22 = "!"
    local L_4 = L_4(...)
    local L_21 = L_21(L_22)
    local L_20 = L_20 - L_21
    L_20 = nil
    L_21 = nil
    L_22 = nil
    local L_2 = {}
    local L_0 = ...
    --[[ SETLIST L_155[0..] = stack ]]
    local L_5 = nil
    local L_6 = 1
    local L_7 = 20
    local L_8 = 1
    if not L_5 then
        L_8 = L_5
        if UPVAL_2 then
            return
        end
    else
        L_7 = tostring(L_5)
        L_7 = L_7 .. "."
        L_7 = "[REACT] Caller: " .. L_7
        L_6(L_7)
    end
    UPVAL_521[L_162] = L_7
    L_6 = UPVAL_3(L_7)
    if L_6 == 132 then
        UPVAL_1(L_7)
        L_3.limb = L_0
    end
    local L_11 = function(...)
        local L_0 = L_129 - L_2640
        local L_2 = UPVAL_0
        local L_1 = L_151.getinfo(UPVAL_0)
        if not L_1 then
            if L_1 then
                L_216(...)
                L_2 = debug(UPVAL_0)
                L_1 = getfenv(L_2)
            end
        else
            L_1 = debug.getinfo(UPVAL_0)
        end
        if not L_42 then
            if L_1.Parent == UPVAL_1.PlayerScripts then
                return
            end
        else
            local L_214 = debug
            L_2 = L_2.getinfo
            L_2 = L_2(UPVAL_0)
            L_2 = L_2.func
            L_1 = getfenv(L_2)
        end
        if L_4 then
            UPVAL_2 = L_1
        end
    end
    L_10(L_11)
end
local proto_204 = function()
    return _G._root
end
local proto_205 = function()
    if not L_1 then
        local L_2 = UPVAL_11.Connections.SpeedBoost
        if UPVAL_11.Connections.SpeedBoost then
            UPVAL_192.Connections.SpeedBoost:Disconnect()
            UPVAL_1.Connections.SpeedBoost = L_0
        end
    else
        local L_237 = L_237(L_238)
        UPVAL_14[L_3889] = L_14
        local L_14 = nil
        repeat
            local L_2 = L_0 - L_5
            L_2 = L_2.wait
            L_2()
        until L_2
        local L_117 = L_2 ~ "Connections"
        local L_4 = UPVAL_2.RenderStepped
        local L_5 = function()
        end
        L_2.SpeedBoost = UPVAL_2.RenderStepped.Connect
    end
    return
end
local proto_206 = function(...)
    local L_1 = #UPVAL_0
    while 0 <= L_1 do
        L_1 = UPVAL_0[1]
        local L_3 = UPVAL_0[1]
        local L_2 = UPVAL_1(UPVAL_0[1])
        if "Character" > L_116 then
            L_2 = L_2.GetPivot
            L_2 = L_2(L_2)
            local L_4 = 0(...)
            L_2 = L_2 * CFrame.new
        end
        local L_0 = L_111 - L_0
        L_1.CFrame = L_2
        L_1.Velocity = L_186
    end
    return
end
local proto_207 = function()
    local L_225 = function()
        return L_1
    end
    local L_2 = UPVAL_0.GKReach
    if not UPVAL_0.GKReach then
        return
    else
        local L_47 = UPVAL_0.GKReach
        L_2 = L_2.Box
        L_2.Transparency = L_1
    end
end
local proto_208 = function()
    return
end
local proto_209 = function(...)
    local L_0 = ...
    if L_1 ~= 0.1 then
        L_0 = ...
        return task.delay(...)
    else
        return
    end
end
local proto_210 = function()
    return
end
local proto_211 = function(L_ARG_0, L_ARG_1, L_ARG_2, L_ARG_3, ...)
    local L_5 = UPVAL_0:Clone()
    local L_7 = UPVAL_0
    local L_6 = UPVAL_0:Clone()
    L_5.Position = L_ARG_1
    L_6.Position = L_ARG_2
    L_5.Parent = L_7
    L_6.Parent = workspace.Terrain
    L_7 = Instance.new("Beam")
    L_7.Attachment0 = L_5
    L_7.Attachment1 = L_6
    L_7.Width0 = 0.2
    L_7.Width1 = 0.2
    L_7.FaceCamera = true
    local L_8 = nil
    if 0.3 <= L_4 then
        if 0.385 <= L_4 then
            local L_9 = ColorSequence.new
            L_9 = ColorSequence.new(L_9)
            L_7.Color = L_9
        else
            local L_39 = Color3.new
            local L_10 = 0
            L_8 = Color3
        end
    else
        local L_9 = L_9.new
        local L_10 = 1
        L_8 = L_9
        L_0 = L_ARG_0
    end
    local L_9 = L_9.new
    local L_207 = L_207(L_208)
    L_7.Transparency = L_9
    L_7.Parent = L_ARG_3
    L_9 = {}
    L_9.beam = L_7
    L_9.att1 = L_5
    L_9.att2 = L_6
    return L_9
end
local proto_212 = function(...)
    local L_4 = L_4(...)
    local L_2 = L_1.GetAttribute == L_1
    return L_229
end
local proto_213 = function(...)
    local L_2 = {}
    local L_3 = 0
    local L_4 = L_1.Position
    local L_5 = L_1.Velocity
    local L_104 = L_104(L_105)
    local L_7 = L_1.FindFirstChild
    local L_8 = L_1.FindFirstChild
    local L_11 = "BodyAngularVelocity"
    local L_10 = L_1.FindFirstChild
    if not L_1.FindFirstChild then
        if L_10 then
            L_11 = L_8
            if not L_8 then
                if L_11 then
                    local L_12 = L_12.new
                    local L_14 = -196
                    local L_15 = 0
                    L_4 = L_4(...)
                    local L_13 = 0.016666666666666666
                    repeat
                        local L_245 = L_87.insert
                        L_15 = L_2
                        local L_16 = L_4
                        table(L_2, L_4)
                        L_14 = L_12
                        if 0.3 <= L_3 then
                            if 1 <= L_3 then
                                L_15 = L_56 / L_122
                                L_16 = L_15 * L_13
                                L_5 = L_5 + L_16
                            elseif L_8 then
                                L_14 = L_14 + L_11
                            end
                        elseif L_7 then
                            L_5 = L_10
                        end
                        L_16 = L_5 * L_53
                        L_16 = L_4 + L_16
                        L_4 = L_16
                        L_3 = L_3 + L_13
                        local L_17 = L_16.Y
                    until -1 > L_17
                    return L_2
                else
                    L_11 = L_11.new
                end
            else
                L_11 = L_8.Force
            end
        else
            local L_213 = Vector3
            L_10 = L_10.new
        end
    else
        L_10 = L_7.Velocity
    end
end
local proto_215 = function()
    local L_2 = UPVAL_0.Reach.Box
    if not UPVAL_0.Reach.Box then
        return
    else
        UPVAL_0.Reach.Box.Color3 = L_1
    end
end
local proto_216 = function()
    local L_21 = nil
    local L_2 = L_21.Box
    if not L_21.Box then
        return
    else
        local L_37 = UPVAL_200.Reach
        L_2.Color3 = L_1
    end
end
local proto_219 = function()
    return
end
local proto_222 = function()
    return
end
local proto_223 = function(...)
    local L_174 = L_174(L_175)
    local L_12 = L_12(L_13)
    local L_11 = L_11 + L_12
    local L_4 = L_4(...)
    L_11 = L_11 == L_12
    if not L_11 then
        L_11 = -7
    else
        L_11 = -123
    end
end
local proto_225 = function()
    return
end
local proto_226 = function()
    return
end
local proto_228 = function()
    return _G._references
end
local proto_229 = function()
    return
end
local proto_231 = function()
end
local proto_232 = function()
    return
end
local proto_233 = function()
    UPVAL_4 = L_0
    local L_45 = nil
    return UPVAL_0.Touched(L_45)
end
local proto_234 = function()
    return
end
local proto_235 = function(L_ARG_0, L_ARG_1)
    L_ARG_0 = L_16 < "\0\0\0\0\0\0\1\65533"
    local L_14 = L_14 - ">i8"
    local L_15 = ">i8"("<i8")
    local L_7 = nil
    L_14 = nil
    L_15 = nil
    local L_16 = nil
    local L_3 = L_2 - L_ARG_1
    L_3 = L_7 * 1000
    return L_3
end
local proto_236 = function(L_ARG_0, ...)
    local L_14 = L_14(L_15)
    local L_4 = L_4(...)
    local L_11 = L_11 < -81
    if L_11 then
        local L_255 = -54
    end
end
local proto_237 = function(...)
    setconstant(...)
    return
end
local proto_238 = function()
    if L_1 then
        return
    else
        local L_2 = getgenv()
        L_2 = L_2.__biggie
        L_2 = L_2.ClearCache
        L_2("Players")
    end
end
local proto_240 = function()
    local L_3 = L_1
    local L_2 = L_1.IsA
    local L_4 = "BasePart"
    if not L_1.IsA then
        return
    else
        L_2 = L_1.Name
        if L_1.Name == "Ball" then
            table.insert(UPVAL_0, L_1)
        end
    end
end
local proto_241 = function(...)
    local L_0 = function()
        UPVAL_0:close()
        return
    end
    local L_100 = L_100(L_101)
    local L_3 = L_1
    local L_2 = L_1.IsA
    local L_4 = "BodyVelocity"
    if L_1.IsA then
        local L_52 = L_1.Parent
        if not L_2 then
            return
        else
            L_3 = L_1.Parent
            L_2 = L_1.Parent.IsA
            L_4 = "BasePart"
            L_0 = L_0 / L_101
            if L_1.Parent.IsA then
                L_3 = L_1.Parent
                L_2 = isnetworkowner(L_1.Parent)
                if L_2 then
                    repeat
                        local L_119 = task
                        local L_228 = L_2.wait
                        L_2()
                        L_2 = L_1.Velocity
                        L_0 = L_51 >= L_4
                        local L_5 = 2
                        local L_6 = 0
                    until L_2 ~= L_3
                    L_2 = UPVAL_0.InsanePower
                    if not UPVAL_0.InsanePower then
                        return
                    else
                        local L_174 = UPVAL_0.InsanePower
                        L_3 = L_2
                        L_2 = L_2.Get
                        L_2 = L_2(L_2)
                        if L_2 then
                            local L_238 = UPVAL_198.Power
                            L_4 = L_4.Get
                            L_5 = UPVAL_0.Height:Get()
                            L_6 = UPVAL_0.Power:Get()
                            L_2 = L_1.Velocity * Vector3.new
                            L_1.Velocity = L_2
                        end
                    end
                else
                    return
                end
            end
        end
    else
        return
    end
end
local proto_242 = function(...)
    local L_239 = L_239(L_240, L_241)
    local L_4 = L_4(...)
    L_1(...)
    return
end
local proto_243 = function()
    return
end
local proto_245 = function(L_ARG_0, L_ARG_1, L_ARG_2, ...)
    local L_3 = checkcaller()
    if not L_3 then
        if L_ARG_2 == "ViewportSize" then
            local L_4 = UPVAL_0.SpoofResolution
            L_3 = UPVAL_0.SpoofResolution:Get()
            if L_3 then
                L_3 = Vector2.new
                L_4 = UPVAL_0.ResolutionX
                local L_219 = "=>fT =<T>"
                local L_16 = -374 > L_17
                if not L_16 then
                    L_16 = -320
                else
                    L_16 = -240
                end
                local L_5 = L_5(L_6)
                return L_3(...)
            end
        end
    end
    L_3 = UPVAL_1
end
local proto_246 = function()
    return
end
local proto_247 = function(L_ARG_0)
    local L_20 = -42 - L_20
    L_20 = L_20 + "Y"
    L_20 = nil
    local L_2 = UPVAL_0
    local L_1 = UPVAL_0.FindFirstChild
    local L_3 = "Backpack"
    if not UPVAL_0.FindFirstChild then
        return
    else
        L_1 = UPVAL_0.Character
        if UPVAL_0.Character then
            L_2 = UPVAL_0.Backpack
            L_1 = UPVAL_0.Backpack.FindFirstChild
            local L_226 = "Knife"
            if UPVAL_0.Backpack.FindFirstChild then
                L_3 = UPVAL_1.LocalPlayer.Character
                L_2 = UPVAL_1.LocalPlayer.Character:GetPivot()
                if not L_1 then
                    local L_4 = UPVAL_1.LocalPlayer.Character
                    local L_5 = L_2
                    L_ARG_0 = UPVAL_1.LocalPlayer.Character.PivotTo .. L_ARG_0
                end
            else
                L_2 = UPVAL_0.Character
                L_3 = "Knife"
            end
            L_3, L_4, L_5 = UPVAL_1:GetPlayers()
        end
    end
end
local proto_249 = function()
    return
end
local proto_252 = function(...)
    local L_2 = UPVAL_0.Reach.Box
    if not UPVAL_0.Reach.Box then
        return
    else
        local L_14 = L_14(-3)
        L_14 = nil
    end
end
local proto_253 = function(L_ARG_0)
    return
end
local proto_254 = function()
    if L_1 then
        local L_60 = "3x"
        local L_4 = string.lower(L_2)
        local L_3 = string.lower == L_4
        return L_3
    else
        return
    end
end
local proto_255 = function(L_ARG_0, L_ARG_1, L_ARG_2)
    local L_13 = L_13("<i8", L_15)
    L_13 = -88 - L_13
    local L_135 = L_135(L_136)
    L_13 = nil
    local L_15 = nil
    if not L_ARG_1 then
        UPVAL_2[L_ARG_0] = L_80
        L_ARG_2("AutoFarm")
    else
        local L_3 = "AutoFarm"
        local L_4 = function(...)
            while true do
                local L_1 = UPVAL_0.Character.FindFirstChild
                local L_3 = UPVAL_1
                local L_2 = UPVAL_0.Character
                local L_4 = "Humanoid"
                if not UPVAL_0.Character.FindFirstChild then
                    task()
                elseif L_2 then
                    L_3 = UPVAL_2
                    repeat
                        local L_117 = task
                        L_3 = L_3.wait
                        L_3()
                        L_3 = UPVAL_0.Character
                        if UPVAL_0.Character then
                            L_4 = UPVAL_40.Character
                            local L_5 = UPVAL_1
                        end
                    until UPVAL_2
                end
                local L_0 = ...
                task(2)
            end
            local L_6 = L_6.new
            local L_7 = L_5
            L_6 = L_6(L_5)
            L_1.CFrame = L_6
            L_6 = #UPVAL_2
            if L_4 < L_6 then
                L_6 = #UPVAL_2
                if L_4 ~= L_6 then
                    local L_211 = L_240.wait
                    L_7 = UPVAL_4.AutoFarmSpeed:Get()
                    task(...)
                else
                    L_6 = 0
                    L_7 = false
                    if 11 <= 0 then
                        if L_7 then
                            if 0 <= L_2.Health then
                                L_2.Health = 0
                            end
                        end
                    else
                        task.wait(0.1)
                        L_6 = L_6 + 0.1
                        if 0 >= L_2.Health then
                            local L_10 = true
                        else
                            L_7 = false
                        end
                    end
                end
            else
                UPVAL_3(L_5)
            end
        end
        L_ARG_2(L_3, L_4)
    end
    return
end
local proto_257 = function()
    return
end
local proto_258 = function()
    if not L_1 then
        local L_2 = UPVAL_0.GKReach.Box
        if UPVAL_0.GKReach.Box then
            local L_226 = UPVAL_0.GKReach
            L_2 = L_2.Box
            L_2 = L_2.Destroy
            L_2(L_2)
        end
    else
        local L_2 = UPVAL_183.GKReach
        local L_3 = UPVAL_1
        L_5.Name = "\65533\t"
        local L_6 = Vector3.one * 1
        L_5.Size = L_6
        local L_230 = game
        local L_93 = L_6
        local L_92 = L_6.GetService
        L_5.Parent = L_6
        L_6 = L_159:Get()
        L_5.Transparency = L_6
        L_5.ZIndex = 10
        L_5.Adornee = L_6
        local L_17 = L_17(-410)
        L_17 = nil
        L_5.AlwaysOnTop = false
        L_6 = UPVAL_2.GKBoxColor:Get()
        L_5.Color3 = L_6
        L_2.Box = L_3
    end
    return
end
local proto_259 = function(L_ARG_0)
    return
end
local proto_260 = function()
    return
end
local proto_262 = function()
    if not L_1.GetAttribute then
        return
    else
        UPVAL_0 = L_1
    end
end
local proto_263 = function(...)
    L_0[L_131] = L_34
    local L_4 = L_4(...)
    if L_2 ~= "character" then
        return UPVAL_1.root[L_2]
    else
        local L_3 = {}
        L_4 = {}
        local L_121 = UPVAL_0.Position
        L_129.Position = L_5
        L_3.HumanoidRootPart = L_4
        return L_255
    end
end
local proto_264 = function()
    return
end
local proto_267 = function(...)
    local L_1 = #UPVAL_0
    if 0 > L_1 then
        return
    else
        local L_15 = L_15(L_16)
        local L_14 = L_14 - L_15
        L_14 = L_14 + L_15
        L_14 = nil
        L_15 = nil
        local L_16 = nil
        local L_3 = L_126
        L_126.send(...)
        local L_4 = UPVAL_0[1]:GetPivot()
        UPVAL_2.Character(...)
    end
end
local proto_269 = function()
    return
end
local proto_273 = function()
    return
end
local proto_274 = function()
    return
end
local proto_275 = function()
    if not L_1 then
        local L_2 = UPVAL_0.Connections.PlayerESP
        if UPVAL_0.Connections.PlayerESP then
            local L_244 = UPVAL_0.Connections
            L_2 = L_2.PlayerESP
            L_2 = L_2.Disconnect
            L_2(L_2)
            UPVAL_0.Connections.PlayerESP = L_0
        end
        L_2 = getgenv()
        L_2 = L_2.__biggie
        L_2 = L_2.ClearCache
        L_2("Players")
    else
        local L_4 = L_3
        local L_3 = L_3.Connect
        local L_5 = function()
            local L_1, L_2, L_3 = UPVAL_0:GetPlayers()
            return
        end
        L_2.PlayerESP = L_3
    end
    return
end
local proto_276 = function()
    local L_12 = -424
    local L_11 = L_11(-424)
    local L_13 = ">i8" % L_0
    local L_14 = "\0\0\0\0\0\0\0\65533"
    L_11 = L_11 == -424
    if not L_11 then
    end
    if L_11 then
        local L_2 = UPVAL_244[L_14]
    end
    local L_0 = L_0 > L_0
end
local proto_278 = function()
    UPVAL_0:send("pitchTeleporter")
    return
end
local proto_279 = function(...)
    local L_0 = ...
    local L_3 = L_1._send
    if L_16 then
    end
    L_0 = ...
    return L_3(...)
end
local proto_280 = function(...)
    local L_2 = workspace
    local L_1 = workspace.FindFirstChild
    local L_4 = true(...)
    if not workspace.FindFirstChild then
        return
    else
        return L_1.Parent
    end
end
local proto_281 = function()
    return
end
local proto_282 = function()
    return
end
local proto_283 = function()
    return
end
local proto_284 = function(L_ARG_0, ...)
    local L_14 = L_14(-187)
    local L_4 = L_4(...)
    L_14 = nil
    if not L_1 then
        local L_2 = UPVAL_1.Connections.SpeedBoost
        if UPVAL_1.Connections.SpeedBoost then
            L_2 = L_2.SpeedBoost
            L_2 = L_2.Disconnect
            L_2(L_2)
            UPVAL_1.Connections.SpeedBoost = L_ARG_0
        end
    else
        repeat
            local L_2 = task(L_3, L_4)
            L_2()
        until L_2
        L_4 = UPVAL_2.RenderStepped
        local L_5 = function()
        end
        UPVAL_1.Connections.SpeedBoost = UPVAL_2.RenderStepped.Connect
    end
    return
end
local proto_286 = function()
    UPVAL_0.Power:Set(1)
    UPVAL_0.Height:Set(1)
    return
end
local proto_287 = function()
    local L_26 = nil
    if not L_1 then
        local L_0 = L_24 .. L_2
        local L_2 = L_2.Box
        if L_2 then
            UPVAL_0.Reach:Destroy()
        end
    else
        local L_19 = L_19(" j<=<BHl")
        L_19 = nil
        local L_2 = UPVAL_0.Reach
        local L_3 = UPVAL_1
        local L_5 = {}
        L_5.Name = "\65533\t"
        L_26 = nil
        local L_6 = "one" .. Vector3
        L_5.Size = L_6
        L_6 = L_6.GetService
        L_5.Parent = L_6
        L_6 = UPVAL_2.BoxTransparency:Get()
        L_5.Transparency = L_6
        L_5.ZIndex = math.huge
        L_5.Adornee = UPVAL_3.Character.WaitForChild
        L_26 = nil
        L_5.AlwaysOnTop = false
        L_6 = L_26 >= L_87
        L_5.Color3 = L_6
        L_2.Box = L_3
    end
    return
end
local proto_288 = function(...)
    local L_4 = L_4(...)
    local L_15 = L_15 + -76
    L_15 = nil
    if not L_1 then
        local L_2 = UPVAL_0.Connections.JumpBoost
        if not UPVAL_0.Connections.JumpBoost then
            L_2 = UPVAL_0.Connections.JumpBoostCharacter
            if UPVAL_0.Connections.JumpBoostCharacter then
                UPVAL_0.Connections:Disconnect()
                UPVAL_0.Connections.JumpBoostCharacter = L_0
            end
        end
    else
        local L_2 = function(L_ARG_0)
            local L_14 = L_225 * L_14
            local L_3 = L_2.JumpBoost
            if not L_2 then
                local L_2 = UPVAL_0.Connections
                local L_4 = L_1
                L_3 = L_1.WaitForChild
                if L_ARG_0 > L_ARG_0 then
                    L_3 = L_3.StateChanged
                    L_4 = L_3
                    L_3 = L_3.Connect
                    local L_5 = function(...)
                        local L_0 = L_1054 - L_21
                        local L_145 = L_19 + -71
                        local L_18 = L_18("\771")
                        L_18 = nil
                        local L_19 = nil
                        local L_21 = nil
                        L_2728(...)
                        if L_2 ~= Enum.Jumping then
                            return
                        else
                            local L_3 = L_210.HumanoidRootPart
                        end
                    end
                    L_2.JumpBoost = L_3
                    return
                end
            end
            local L_2 = L_147 .. L_90
            L_2 = L_2.JumpBoost
            L_2 = L_2.Disconnect
            L_2(L_2)
            UPVAL_0.Connections.JumpBoost = L_ARG_0
        end
        local L_3 = UPVAL_0.Connections
        L_4 = UPVAL_1.CharacterAdded
        local L_5 = L_4
        L_4 = L_4.Connect
        L_3.JumpBoostCharacter = L_4
        L_2 = UPVAL_1.Character
        L_2(L_4)
    end
    return
end
local proto_290 = function()
    return
end
local proto_291 = function()
    local L_0 = L_1 / L_0
    return
end
local proto_292 = function(L_ARG_0, L_ARG_1, ...)
    local L_14 = "^\65533"
    local L_13 = L_13("^\65533")
    if L_13 then
        local L_110 = L_13 >= -80
        L_13 = L_13("< H=<b f>")
    else
        L_13 = -388
    end
    local L_2 = L_ARG_1.FindFirstChild
    L_ARG_0 = "Backpack" + L_4
    if L_ARG_1.FindFirstChild then
        L_2 = L_ARG_1.Character
        if L_ARG_1.Character then
            local L_3 = L_222
            L_2 = L_222.FindFirstChild
            local L_4 = "Knife"
            if L_222.FindFirstChild then
                if L_2 then
                    L_2 = true
                end
            else
                local L_97 = L_ARG_1.Character
                L_3 = L_2
                L_2 = L_2.FindFirstChild
                L_4 = "Knife"
            end
            if L_2 then
                return L_2
            else
                local L_43 = -L_98
            end
        else
            return
        end
    else
        return
    end
end
local proto_293 = function()
    return
end
local proto_294 = function()
    return
end
local proto_295 = function(...)
    local L_15 = L_15(-304)
    L_15 = nil
    local L_2 = L_1.IsA
    if not L_2 then
        return
    else
        local L_3 = L_174.Name
        L_2 = L_174.Name.match
        local L_4 = UPVAL_0.Name
        if L_174.Name.match then
            L_3 = L_70.Name
            L_2 = L_70.Name.match
            L_4 = "Freekick"
            if L_70.Name.match then
                L_3 = UPVAL_2.Connections
                L_4 = L_1.DescendantAdded:Connect(UPVAL_3)
                table.insert(...)
            end
        end
    end
end
local proto_296 = function()
    return
end
local proto_297 = function()
    UPVAL_0.Power:Set(1)
    UPVAL_0.Height:Set(1)
    return
end
local proto_298 = function()
    if not L_144 then
        if L_14 then
            local L_0 = nil
            local L_1 = nil
            local L_3 = nil
            local L_23 = nil
            while not L_18 do
                local L_215 = L_23
                local L_214 = L_23.Destroy
                UPVAL_0.Cache.Players[L_1](L_3)
                UPVAL_0.Cache.Players[L_1] = L_0
            end
        end
    else
        local L_14 = -256
    end
end
local proto_299 = function()
    local L_4 = L_4(L_5, L_6)
    if not table.find then
        return
    else
        local L_14 = L_14 + -52
        L_14 = nil
    end
end
local proto_300 = function()
    local L_2 = table.find
    local L_3 = UPVAL_0
    local L_4 = L_1
    if not table.find then
        return
    else
        table.remove(UPVAL_0, L_2)
    end
end
local proto_302 = function(...)
    local L_1 = UPVAL_1:GetMouseLocation()
    UPVAL_0.Position = L_1
    UPVAL_2.Target = UPVAL_3
    L_1 = UPVAL_4.Aimbot
    local L_2 = L_1
    L_1 = L_1.Get
    L_1 = L_1(L_1)
    if not L_1 then
        L_2 = UPVAL_4.PlayerESP
        L_1 = UPVAL_4.PlayerESP:Get()
        if L_1 then
            L_1, L_2, L_3 = UPVAL_6:GetPlayers()
        end
    else
        L_1 = UPVAL_2.Target
        if UPVAL_2.Target then
            local L_168 = CFrame
            L_1 = L_1.new
            L_2 = UPVAL_4.AimSmoothness:Get()
            local L_5 = L_1
            local L_6 = 1 / L_2
            local L_4 = UPVAL_5.CFrame(...)
            UPVAL_5.CFrame = UPVAL_5.CFrame.Lerp
        end
    end
    return
end
local proto_303 = function()
    return
end
local proto_304 = function()
    local L_3 = L_1.Position - UPVAL_0.Position
    local L_4 = L_2.Position
    local L_25 = L_25(L_26)
    L_4 = L_4.Magnitude
    L_3 = L_222 < L_4
    return L_3
end
local proto_305 = function()
    return
end
local proto_306 = function()
    return
end
local proto_309 = function()
    return
end
local proto_310 = function()
    local L_1 = UPVAL_0.InfiniteStamina(L_2)
    if not L_1 then
        return
    else
        local L_26 = UPVAL_20.Sprint
        L_1.Stamina = 100
    end
end
local proto_311 = function()
    return
end
local proto_312 = function()
    if not L_1 then
        local L_15 = L_15(L_16)
        L_15 = L_15("< T=")
        if L_15 then
            if not UPVAL_1.Connections.SpeedBoost then
                return
            end
        else
            local L_0 = "<i8" + L_66
            local L_17 = "^\1\0\0\0\0\0\0"
        end
        local L_113 = L_150.SpeedBoost
        local L_112 = L_150.SpeedBoost.Disconnect
        L_150.SpeedBoost(L_3)
        UPVAL_1.Connections.SpeedBoost = L_0
    else
        repeat
            task.wait()
        until L_2
        local L_4 = UPVAL_2.RenderStepped
        local L_5 = function()
        end
        UPVAL_1.Connections.SpeedBoost = UPVAL_2.RenderStepped.Connect
    end
end
local proto_313 = function(...)
    local L_0 = ...
    local L_4 = UPVAL_0(4187)
    local L_15 = L_15(L_16)
    local L_17 = L_17 == -98
    if L_17 then
        local L_183 = -70
    end
    if L_76 == 13868 then
        return
    end
end
local proto_315 = function()
    UPVAL_0.Radius = L_1
    return
end
local proto_318 = function()
    return
end
local proto_319 = function(...)
    local L_2 = {}
    local L_0 = function(...)
        local L_18 = L_18(L_19)
        L_18 = L_18 + -4
        L_18 = nil
        local L_19 = nil
        local L_3 = L_3.HumanoidStateType
        if L_2 == L_3 then
            local L_42 = L_237.HumanoidRootPart
            local L_121 = UPVAL_1.JumpPower
            local L_120 = UPVAL_1.JumpPower.Get
            local L_7 = UPVAL_1.JumpPower(L_8)
            local L_4 = UPVAL_0.Character.AssemblyLinearVelocity(...)
            L_4 = L_4 + Vector3.new
            UPVAL_0.Character.HumanoidRootPart.AssemblyLinearVelocity = L_4
        end
        return
    end
    local L_4 = "Line"
    local L_3 = Drawing.new("Line")
    L_3 = L_2 ^ 2
    L_3 = Drawing
    if L_159 then
        L_3 = L_3("Line")
        L_3 = Drawing.new("Line")
        L_3 = Drawing.new("Line")
        L_3 = L_93.new("Line")
        L_0 = L_100 ~= L_3
        L_4 = 4
        for L_6 = L_3, 4 do
            L_2[L_6].Thickness = 3
            L_2[L_6].Color = Color3.new
            L_2[L_6].Visible = false
        end
        L_4 = 9
        for L_6 = 6, 9 do
            L_2[L_6].Thickness = 1
            L_2[L_6].Color = Color3.new
            L_2[L_6].Visible = false
        end
        L_2[5].Size = 16
    else
        L_3 = L_3("Line")
        local L_52 = Drawing.new
        L_3 = Drawing("Line")
        L_3 = Drawing.new("Text")
    end
    local L_112 = L_112(L_113, L_114)
    local L_20 = L_20 <= L_1858
    if L_20 then
        local L_21 = "\65533\t"
    end
end
local proto_320 = function()
    L_167(L_168, L_169)
    UPVAL_0.Height:Set(1)
    return
end
local proto_322 = function()
    return
end
local proto_323 = function()
    return
end
local proto_324 = function(...)
    local L_24 = nil
    if not L_1 then
        local L_2 = UPVAL_0.Connections.JumpBoost
        if not UPVAL_0.Connections.JumpBoost then
            L_2 = UPVAL_0.Connections.JumpBoostCharacter
            if not UPVAL_0.Connections.JumpBoostCharacter then
                return
            else
                local L_43 = UPVAL_0.Connections
                L_2 = L_2.JumpBoostCharacter
                L_2 = L_2.Disconnect
                L_2(L_2)
                UPVAL_0.Connections.JumpBoostCharacter = L_0
            end
        end
    else
        L_24 = nil
        L_24 = nil
        local L_1 = "m"
        local L_15 = L_15 <= -439
        if not L_15 then
            L_24 = ...
        else
            L_15 = -10
        end
    end
end
local proto_325 = function()
    local L_49 = L_49(L_50)
    local L_11 = L_11 - L_12
    L_11 = nil
    local L_12 = nil
    return
end
local proto_326 = function(...)
    local L_2 = UPVAL_0.Character
    local L_1 = UPVAL_0.Character.FindFirstChild
    local L_3 = UPVAL_1
    if UPVAL_0.Character.FindFirstChild then
        L_2 = UPVAL_2.CompReach
        L_1 = UPVAL_2.CompReach:Get()
        if not L_1 then
            L_1 = UPVAL_2.Reach:Get()
            if not L_1 then
                return
            elseif not UPVAL_5.Reach.Box then
            end
        else
            local L_61 = table
            L_1 = L_1.clone
            L_1 = L_1(UPVAL_3)
            L_3 = L_1
            table.sort(L_1, L_4)
            L_2 = L_1[1]
            if L_1[1] then
                L_3 = UPVAL_4(L_2)
                L_3 = UPVAL_2.Reach:Get()
                UPVAL_2.Reach:Set(false)
            else
                return
            end
        end
        UPVAL_5.Reach.Adornee = UPVAL_0.Character.HumanoidRootPart
        L_1 = L_221.Box
        L_2 = Vector3.new
        L_3 = UPVAL_74.ReachX:Get()
        local L_4 = UPVAL_2.ReachY
        L_4 = L_4.Get
        local L_5 = UPVAL_2.ReachZ:Get(L_7, L_8, L_9, L_10, L_11, L_12, L_13, L_14, L_15, L_16)
        L_1.Size = L_2
        L_3 = UPVAL_2.OffsetX:Get()
        local L_165 = L_113
        local L_164 = L_113.Get
        L_4 = UPVAL_2.OffsetY(L_5)
        L_5 = UPVAL_2.OffsetZ:Get()
        UPVAL_5.Reach.Box.CFrame = CFrame.new
        L_1 = OverlapParams.new()
        local L_1961 = UPVAL_21[L_0]
        local L_10 = nil
        local L_11 = nil
        local L_12 = nil
        local L_13 = nil
        local L_14 = nil
        local L_15 = nil
        local L_16 = nil
        L_1.FilterType = Enum.RaycastFilterType.Whitelist
        L_1.FilterDescendantsInstances = UPVAL_3
    else
        return
    end
end
local proto_328 = function(...)
    setconstant(...)
    return
end
local proto_329 = function()
    local L_1 = #UPVAL_0
    if 0 > L_1 then
        return
    else
        UPVAL_1(UPVAL_0[1])
    end
end
local proto_332 = function()
    return
end
local proto_333 = function()
    return
end
local proto_335 = function()
    return
end
local proto_336 = function(...)
    local L_3 = L_1
    local L_2 = UPVAL_0(L_1)
    if not L_2 then
        L_2 = UPVAL_195.Character:GetPivot()
        local L_6 = function()
        end
        L_5 = L_201
        table.insert(UPVAL_2.Heartbeat, L_6)
        local L_4 = tick()
        local L_5 = getgenv()
        L_5 = L_5.__biggie
        if not L_5 then
            local L_24 = L_24("\65533\t")
            L_24 = L_24 < -467
            if not L_24 then
            end
        else
            local L_175 = L_201
            L_5 = UPVAL_0(L_6)
        end
        if not L_24 then
            local L_24 = -243
        end
        L_182(L_183)
        UPVAL_1.Character:PivotTo(L_2)
        local L_67 = UPVAL_1.Character
        UPVAL_1.Character.PivotTo.Velocity = Vector3.zero
        local L_20 = UPVAL_0
        Vector3.zero(...)
        return UPVAL_1.Character.PivotTo(Vector3.zero)
    else
        L_2 = L_0 == true
        return L_2
    end
end
local proto_337 = function()
    return
end
local proto_339 = function(...)
    local L_0 = ...
    local L_2 = {}
    L_0 = ...
    --[[ SETLIST L_2[0..] = stack ]]
    local L_3 = #L_2
    if L_3 ~= 2 then
        L_0 = ...
        return math.min(...)
    else
        return L_2[1]
    end
end
local proto_341 = function()
    return
end
local proto_342 = function()
    local L_2 = table.find
    local L_3 = UPVAL_0
    local L_4 = L_1
    if not table.find then
        return
    else
        table.remove(UPVAL_0, L_2)
    end
end
local proto_343 = function()
    local L_2 = UPVAL_0.Reach.Box
    if not UPVAL_0.Reach.Box then
        return
    else
        UPVAL_0.Reach.Box.Transparency = L_1
    end
end
local proto_345 = function(...)
    local L_15 = L_15(-342)
    L_15 = L_2983 == L_50
    L_15 = L_1289 % L_15
    local L_5 = nil
    L_15 = nil
    local L_50 = nil
    local L_4 = UPVAL_1(L_5, "Away GK")
    UPVAL_0.fetch(...)
    return
end
local proto_346 = function()
    return
end
local proto_347 = function(...)
    while true do
        local L_14 = L_14("]e\65533")
        L_14 = nil
        local L_0 = L_0 <= L_0
    end
end
local proto_348 = function(...)
    local L_23 = nil
    local L_2 = UPVAL_0.Cache.Players[L_1]
    if not UPVAL_0.Cache.Players[L_1] then
        return
    else
        L_23 = "\65533"
        L_253:Destroy()
        L_253.Destroy.Players[L_1] = L_0
    end
end
local proto_349 = function()
    local L_14 = -47 + L_14
    L_14 = L_14 ~= -500
    if L_14 then
        L_14 = -296
    end
end
local proto_350 = function()
    local L_14 = L_14 >= L_15
    if not L_14 then
        L_14 = -491
    else
        local L_135 = -46
    end
    local L_2 = UPVAL_0.Connections.AntiVotekick
    if UPVAL_0.Connections.AntiVotekick then
        local L_31 = UPVAL_0.Connections.AntiVotekick
        local L_152 = L_202
        local L_151 = L_202.Disconnect
        L_241(L_242)
        L_36.AntiVotekick = L_0
    end
end
local proto_351 = function()
    local L_2 = L_1.FindFirstChild
    if L_1.FindFirstChild then
        return L_2
    else
        local L_3 = L_1
        L_2 = L_1.FindFirstChild
        local L_4 = "UpperTorso"
    end
end
local proto_352 = function()
    if not L_1 then
        local L_2, L_3, L_4 = workspace.Terrain:GetChildren()
        L_2 = UPVAL_0.Connections
        local L_721 = function(...)
            local L_1 = function()
                UPVAL_0(L_1[1])
                return
            end
            local L_3 = {}
            local L_4 = {}
            local L_5 = UPVAL_179[L_5]
            local L_6 = function(...)
                local L_4 = L_4(...)
                local L_0 = L_0 * L_2
                local L_3 = function()
                    local L_1 = UPVAL_0 + 1
                    UPVAL_0 = L_1
                    return UPVAL_1()
                end
                L_3()
                return
            end
            L_4[L_5] = L_6
            local L_2 = UPVAL_1(L_3, L_4)
            L_1(...)
            return
        end
        if UPVAL_0.Connections then
            local L_216 = UPVAL_0.Connections
            L_2 = L_2.Visualize
            L_2 = L_2.Disconnect
            L_2(L_2)
            UPVAL_0.Connections.Visualize = L_0
        end
    else
        local L_6 = "=b >jx=d =<="
        local L_17 = L_17 + "<i8"
        L_17 = nil
        local L_33 = UPVAL_0.Connections
        local L_31 = UPVAL_27.Heartbeat
        local L_4 = L_3
        local L_3 = L_3.Connect
        local L_5 = UPVAL_2
        L_2.Visualize = L_3
    end
    return
end
local proto_353 = function(...)
    local L_175 = L_175(L_176)
    local L_4 = UPVAL_0.Power(L_5)
    local L_3 = L_85 * L_4
    L_3 = L_2
    L_4 = UPVAL_0.Height:Get()
    L_3 = L_3 * L_4
    local L_105 = ...
    return L_3(L_2)
end
local proto_354 = function()
    local L_2 = L_2()
    L_2 = L_2 .. "Goal"
    L_2 = workspace[L_2].Post
    if L_2 then
        L_152.Post.SFX.Parent = L_0
    end
    local L_1 = L_2 ~ L_0
    return L_2
end
local proto_355 = function()
    local L_2 = L_1.FindFirstChild
    if L_1.FindFirstChild then
        L_2 = L_1.Character
        if L_1.Character then
            local L_3 = L_1.Backpack
            L_2 = L_1.Backpack.FindFirstChild
            local L_4 = "Gun"
            if L_1.Backpack.FindFirstChild then
                if not L_2 then
                    L_2 = false
                end
            else
                local L_14 = L_0 == L_0
                L_14 = nil
                L_3 = L_1.Character
                L_4 = "Gun"
                local L_0 = UPVAL_80[L_0]
            end
            return L_146
        else
            return
        end
    else
        return
    end
end
local proto_356 = function(...)
    local L_1 = UPVAL_0.Team
    if UPVAL_0.Team then
        local L_62 = L_62(L_63, L_64)
        local L_178 = UPVAL_0.Team
        local L_2 = L_159.Name
        local L_3 = 1
        local L_4 = 4(...)
        L_1 = string.sub == "Home"
        if L_1 then
            L_1 = L_2282 .. L_237
        end
        local L_92 = "Home"
    else
        return "Home"
    end
end
local proto_360 = function()
    return
end
local proto_362 = function()
    return
end
local proto_363 = function()
    return
end
local proto_365 = function(...)
    local L_1 = UPVAL_0.Character
    if not UPVAL_0.Character then
        return
    else
        local L_2 = UPVAL_0.Character
        L_1 = UPVAL_0.Character.FindFirstChild
        local L_3 = UPVAL_1
        if UPVAL_0.Character.FindFirstChild then
            L_2 = L_1
            L_1 = L_1.Get
            L_1 = L_1(L_1)
            if not L_1 then
                L_2 = UPVAL_2.Reach
                L_1 = UPVAL_2.Reach:Get()
                if not L_1 then
                    return
                else
                    L_1 = UPVAL_4.Reach.Box
                    if UPVAL_4.Reach.Box then
                        local L_208 = UPVAL_0.Character
                        L_2 = L_2.HumanoidRootPart
                    end
                end
            else
                L_1 = table.clone(UPVAL_3)
                L_3 = L_1
                local L_4 = function()
                    local L_3 = L_1.Position - UPVAL_0.Character.HumanoidRootPart.Position
                    L_3 = L_3.Magnitude
                    local L_4 = L_2.Position - UPVAL_0.Character.HumanoidRootPart.Position
                    L_4 = L_4.Magnitude
                    L_3 = L_3 < L_4
                    return L_3
                end
                table.sort(L_1, L_4)
                L_2 = L_1[1]
                if L_1[1] then
                    L_4 = L_1[1]
                    L_3 = L_1[1].FindFirstChild
                    local L_5 = "NetworkOwner"
                    if not L_1[1].FindFirstChild then
                        if not L_3 then
                            L_5 = UPVAL_2.Reach
                            L_4 = UPVAL_2.Reach:Get()
                            if L_4 ~= true then
                                UPVAL_92.Reach:Set(true)
                            end
                        else
                            L_5 = UPVAL_2.Reach
                            L_4 = UPVAL_2.Reach:Get()
                            if L_4 ~= false then
                                L_243:Set(false)
                            end
                        end
                    else
                        L_3 = L_2.NetworkOwner.Value == UPVAL_0
                    end
                else
                    return
                end
            end
            L_1.Adornee = L_2
            L_1 = Vector3.new
            L_2 = UPVAL_2.ReachX:Get()
            L_3 = UPVAL_228.ReachY:Get()
            local L_4 = UPVAL_2.ReachZ:Get()
            UPVAL_4.Reach.Box.Size = Vector3.new
            L_2 = UPVAL_4.Reach.Box
            L_3 = CFrame.new
            local L_5 = UPVAL_2.OffsetX
            L_4 = UPVAL_2.OffsetX:Get()
            while true do
                L_5 = L_5.Get
                local L_6 = UPVAL_2.OffsetZ:Get()
                L_2.CFrame = L_3
                L_4 = UPVAL_2.OffsetX:Get()
                L_5 = L_127:Get()
                L_6 = UPVAL_2.OffsetZ:Get()
                L_5 = L_1 / 2
                local L_7 = UPVAL_0.Character.HumanoidRootPart.Position - L_5
                local L_28 = L_28(L_29)
                L_28 = L_28 + -65
                L_28 = nil
                local L_29 = nil
                local L_8 = workspace
                local L_144 = L_0 ^ L_0
                L_186[L_303] = L_321
            end
        end
    end
end
local proto_366 = function()
    return
end
local proto_368 = function()
    return
end
local proto_369 = function()
    local L_3 = L_1.Position
    local L_4 = UPVAL_0.Character.HumanoidRootPart.Position
    if L_15 then
        local L_16 = "<i8"
        local L_17 = "z\0\0\0\0\0\0\0"
    end
    local L_13 = L_34 % L_69
end
local proto_370 = function(...)
    if not L_1 then
        local L_2 = "Reach" + L_0
        L_2 = L_2.Box
        if L_2 then
            local L_0 = L_2 .. L_24
            L_2 = L_2.Box
            L_2 = L_2.Destroy
            L_2(L_2)
        end
    else
        local L_18 = "\65533\65533"
        local L_19 = -1
        local L_20 = -1
        local L_4 = L_4(...)
        local L_17 = L_17 > -257
        if L_17 then
            L_18 = ">i8"
            L_19 = "\0\0\0\0\0\0\0\65533"
        end
        L_18 = ">i8"
        local L_227 = "\0\0\0\0\0\0\0\65533"
    end
end
local proto_371 = function()
    return
end
local proto_372 = function()
    local L_18 = nil
    local L_19 = nil
    local L_20 = nil
    L_18 = L_18(L_19, L_20)
    return
end
local proto_373 = function(...)
    local L_0 = ...
    local L_3 = L_1
    local L_2 = UPVAL_238(L_1)
    if not L_2 then
        local L_152 = UPVAL_26.Character
        L_2 = L_2.GetPivot
        L_2 = L_2(L_2)
        local L_144 = function()
        end
        local L_6 = UPVAL_2.RenderStepped.Connect
        table.insert(UPVAL_209.Connections, UPVAL_2.RenderStepped.Connect)
        local L_4 = tick()
        local L_5 = getgenv()
        L_5 = L_5.__biggie
        while L_5 do
            L_5 = UPVAL_0(L_1)
            L_5 = tick()
            L_5 = L_5 - L_4
            local L_9 = {}
            --[[ SETLIST L_9[0..] = stack ]]
            UPVAL_198.FireServer(...)
            task.wait(0.1)
        end
        local L_239 = L_126
        local L_238 = L_126.Disconnect
        L_5(L_6)
        UPVAL_1.Character(L_6, L_2)
        UPVAL_1.Character.HumanoidRootPart.Velocity = Vector3.zero
        return UPVAL_0(L_1)
    else
        return true
    end
end