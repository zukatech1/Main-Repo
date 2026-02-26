local plr = game:GetService("Players").LocalPlayer
local success, err = pcall(function()
function RunCustomAnimation(Char)
    if not Char or not Char.Parent then return end
    pcall(function()
        if Char:FindFirstChild("Animate") then
            Char.Animate.Disabled = true
        end
    end)
    local Character = Char
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    if not Humanoid then return end
    pcall(function()
        for i, v in next, Humanoid:GetPlayingAnimationTracks() do
            v:Stop(0)
            v:Destroy()
        end
    end)
    local pose = "Standing"
    local humanoidSpeed = 0
    local cachedRunningSpeed = 0
    local cachedLocalDirection = {x=0.0, y=0.0}
    local smallButNotZero = 0.0001
    local runBlendtime = 0.2
    local lastBlendTime = 0
    local WALK_SPEED = 6.4
    local RUN_SPEED = 12.8
    local EMOTE_TRANSITION_TIME = 0.1
    local currentAnim = ""
    local currentAnimInstance = nil
    local currentAnimTrack = nil
    local currentAnimKeyframeHandler = nil
    local currentAnimSpeed = 1.0
    local currentlyPlayingEmote = false
    local PreloadedAnims = {}
    local animTable = {}
    local animNames = { 
        idle = {
            { id = "http://www.roblox.com/asset/?id=12521158637", weight = 9 },
            { id = "http://www.roblox.com/asset/?id=12521162526", weight = 1 },
        },
        walk = {
            { id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 }
        },
        run = {
            { id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 } 
        },
        jump = {
            { id = "http://www.roblox.com/asset/?id=12520880485", weight = 10 }
        },
        fall = {
            { id = "http://www.roblox.com/asset/?id=12520972571", weight = 10 }
        },
        climb = {
            { id = "http://www.roblox.com/asset/?id=12520982150", weight = 10 }
        },
        sit = {
            { id = "http://www.roblox.com/asset/?id=12520993168", weight = 10 }
        },
        toolnone = {
            { id = "http://www.roblox.com/asset/?id=12520996634", weight = 10 }
        },
        toolslash = {
            { id = "http://www.roblox.com/asset/?id=12520999032", weight = 10 }
        },
        toollunge = {
            { id = "http://www.roblox.com/asset/?id=12521002003", weight = 10 }
        },
        wave = {
            { id = "http://www.roblox.com/asset/?id=12521004586", weight = 10 }
        },
        point = {
            { id = "http://www.roblox.com/asset/?id=12521007694", weight = 10 }
        },
        dance = {
            { id = "http://www.roblox.com/asset/?id=12521009666", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521151637", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521015053", weight = 10 }
        },
        dance2 = {
            { id = "http://www.roblox.com/asset/?id=12521169800", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521173533", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521027874", weight = 10 }
        },
        dance3 = {
            { id = "http://www.roblox.com/asset/?id=12521178362", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521181508", weight = 10 },
            { id = "http://www.roblox.com/asset/?id=12521184133", weight = 10 }
        },
        laugh = {
            { id = "http://www.roblox.com/asset/?id=12521018724", weight = 10 }
        },
        cheer = {
            { id = "http://www.roblox.com/asset/?id=12521021991", weight = 10 }
        },
    }
    local strafingLocomotionMap = {}
    local fallbackLocomotionMap = {}
    local locomotionMap = strafingLocomotionMap
    local emoteNames = { wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false}
    math.randomseed(tick())
    local function configureAnimationSet(name, fileList)
        if animTable[name] ~= nil then
            for _, connection in pairs(animTable[name].connections or {}) do
                pcall(function() connection:Disconnect() end)
            end
        end
        animTable[name] = {}
        animTable[name].count = 0
        animTable[name].totalWeight = 0
        animTable[name].connections = {}
        if name == "run" or name == "walk" then
            local speed = name == "run" and RUN_SPEED or WALK_SPEED
            fallbackLocomotionMap[name] = {lv=Vector2.new(0.0, speed), speed = speed}
            locomotionMap = fallbackLocomotionMap
        end
        if animTable[name].count <= 0 then
            for idx, anim in pairs(fileList) do
                animTable[name][idx] = {}
                animTable[name][idx].anim = Instance.new("Animation")
                animTable[name][idx].anim.Name = name
                animTable[name][idx].anim.AnimationId = anim.id
                animTable[name][idx].weight = anim.weight
                animTable[name].count = animTable[name].count + 1
                animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
            end
        end
        for i, animType in pairs(animTable) do
            for idx = 1, animType.count, 1 do
                if animType[idx] and animType[idx].anim then
                    if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
                        pcall(function()
                            Humanoid:LoadAnimation(animType[idx].anim)
                            PreloadedAnims[animType[idx].anim.AnimationId] = true
                        end)
                    end
                end
            end
        end
    end
    pcall(function()
        local animator = Humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animTracks = animator:GetPlayingAnimationTracks()
            for i, track in ipairs(animTracks) do
                pcall(function()
                    track:Stop(0)
                    track:Destroy()
                end)
            end
        end
    end)
    for name, fileList in pairs(animNames) do
        configureAnimationSet(name, fileList)
    end
    local function stopAllAnimations()
        local oldAnim = currentAnim
        if emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false then
            oldAnim = "idle"
        end
        if currentlyPlayingEmote then
            oldAnim = "idle"
            currentlyPlayingEmote = false
        end
        currentAnim = ""
        currentAnimInstance = nil
        pcall(function() if currentAnimKeyframeHandler then currentAnimKeyframeHandler:Disconnect() end end)
        pcall(function()
            if currentAnimTrack then
                currentAnimTrack:Stop()
                currentAnimTrack:Destroy()
            end
            currentAnimTrack = nil
        end)
        for _, v in pairs(locomotionMap) do
            if v.track then
                pcall(function()
                    v.track:Stop()
                    v.track:Destroy()
                    v.track = nil
                end)
            end
        end
        return oldAnim
    end
    local function signedAngle(a, b)
        return -math.atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
    end
    local angleWeight = 2.0
    local function get2DWeight(px, p1, p2, sx, s1, s2)
        local avgLength = 0.5 * (s1 + s2)
        local p_1 = {x = (sx - s1)/avgLength, y = (angleWeight * signedAngle(p1, px))}
        local p12 = {x = (s2 - s1)/avgLength, y = (angleWeight * signedAngle(p1, p2))}	
        local denom = smallButNotZero + (p12.x*p12.x + p12.y*p12.y)
        local numer = p_1.x * p12.x + p_1.y * p12.y
        local r = math.max(0, math.min(1, 1.0 - numer/denom))
        return r
    end
    local function blend2D(targetVelo, targetSpeed)
        local h = {}
        local sum = 0.0
        for n, v1 in pairs(locomotionMap) do
            if targetVelo.x * v1.lv.x < 0.0 or targetVelo.y * v1.lv.y < 0 then
                h[n] = 0.0
                continue
            end
            h[n] = math.huge
            for j, v2 in pairs(locomotionMap) do
                if targetVelo.x * v2.lv.x < 0.0 or targetVelo.y * v2.lv.y < 0 then
                    continue
                end
                h[n] = math.min(h[n], get2DWeight(targetVelo, v1.lv, v2.lv, targetSpeed, v1.speed, v2.speed))
            end
            sum += h[n]
        end
        local sum2 = 0.0
        local weightedVeloX = 0
        local weightedVeloY = 0
        for n, v in pairs(locomotionMap) do
            if h[n] / math.max(sum, smallButNotZero) > 0.1 then
                sum2 += h[n]
                weightedVeloX += h[n] * v.lv.x
                weightedVeloY += h[n] * v.lv.y
            else
                h[n] = 0.0
            end
        end
        local animSpeed = 0
        local weightedSpeedSquared = weightedVeloX * weightedVeloX + weightedVeloY * weightedVeloY
        if weightedSpeedSquared > smallButNotZero then
            animSpeed = math.sqrt(targetSpeed * targetSpeed / weightedSpeedSquared)
        end
        local groupTimePosition = 0
        for n, v in pairs(locomotionMap) do
            if v.track and v.track.IsPlaying then
                groupTimePosition = v.track.TimePosition
                break
            end
        end
        for n, v in pairs(locomotionMap) do
            if h[n] > 0.0 then
                if not v.track.IsPlaying then 
                    pcall(function()
                        v.track:Play(runBlendtime)
                        v.track.TimePosition = groupTimePosition
                    end)
                end
                local weight = math.max(smallButNotZero, h[n] / math.max(sum2, smallButNotZero))
                pcall(function()
                    v.track:AdjustWeight(weight, runBlendtime)
                    v.track:AdjustSpeed(animSpeed)
                end)
            else
                pcall(function()
                    v.track:Stop(runBlendtime)
                end)
            end
        end
    end
    local function getWalkDirection()
        if Humanoid.MoveDirection ~= Vector3.zero then
            return Humanoid.MoveDirection
        else
            return Humanoid.MoveDirection
        end
    end
    local function updateVelocity(currentTime)
        if not locomotionMap then return end
        if math.abs(humanoidSpeed - cachedRunningSpeed) > 0.01 or currentTime - lastBlendTime > 1 then
            cachedRunningSpeed = humanoidSpeed
            lastBlendTime = currentTime
            blend2D(Vector2.new(0, 1), cachedRunningSpeed)
        end
    end
    local function setAnimationSpeed(speed)
        if currentAnim ~= "walk" and currentAnimTrack then
            if speed ~= currentAnimSpeed then
                currentAnimSpeed = speed
                pcall(function()
                    currentAnimTrack:AdjustSpeed(currentAnimSpeed)
                end)
            end
        end
    end
    local function keyFrameReachedFunc(frameName)
        if (frameName == "End") then
            local repeatAnim = currentAnim
            if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
                repeatAnim = "idle"
            end
            if currentlyPlayingEmote then
                if currentAnimTrack and currentAnimTrack.Looped then
                    return
                end
                repeatAnim = "idle"
                currentlyPlayingEmote = false
            end
            local animSpeed = currentAnimSpeed
            playAnimation(repeatAnim, 0.15, Humanoid)
            setAnimationSpeed(animSpeed)
        end
    end
    local function rollAnimation(animName)
        if not animTable[animName] or animTable[animName].totalWeight == 0 then
            return 1
        end
        local roll = math.random(1, animTable[animName].totalWeight)
        local idx = 1
        while roll > animTable[animName][idx].weight do
            roll = roll - animTable[animName][idx].weight
            idx = idx + 1
        end
        return idx
    end
    local function setupWalkAnimation(anim, animName, transitionTime, humanoid)
        for n, v in pairs(locomotionMap) do
            if animTable[n] and animTable[n][1] then
                pcall(function()
                    v.track = humanoid:LoadAnimation(animTable[n][1].anim)
                    v.track.Priority = Enum.AnimationPriority.Core
                end)
            end
        end
    end
    local function switchToAnim(anim, animName, transitionTime, humanoid)
        if anim == currentAnimInstance then return end
        pcall(function()
            if currentAnimTrack then
                currentAnimTrack:Stop(transitionTime)
                currentAnimTrack:Destroy()
            end
            if currentAnimKeyframeHandler then
                currentAnimKeyframeHandler:Disconnect()
            end
            currentAnimSpeed = 1.0
            currentAnim = animName
            currentAnimInstance = anim
            if animName == "walk" then
                setupWalkAnimation(anim, animName, transitionTime, humanoid)
            else
                currentAnimTrack = humanoid:LoadAnimation(anim)
                currentAnimTrack.Priority = Enum.AnimationPriority.Core
                currentAnimTrack:Play(transitionTime)	
                currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:Connect(keyFrameReachedFunc)
            end
        end)
    end
    function playAnimation(animName, transitionTime, humanoid)
        if not animTable[animName] then return end
        local idx = rollAnimation(animName)
        local anim = animTable[animName][idx].anim
        switchToAnim(anim, animName, transitionTime, humanoid)
        currentlyPlayingEmote = false
    end
    local function playEmote(emoteAnim, transitionTime, humanoid)
        switchToAnim(emoteAnim, emoteAnim.Name, transitionTime, humanoid)
        currentlyPlayingEmote = true
    end
    local toolAnimName = ""
    local toolAnimTrack = nil
    local toolAnimInstance = nil
    local currentToolAnimKeyframeHandler = nil
    local function toolKeyFrameReachedFunc(frameName)
        if (frameName == "End") then
            playToolAnimation(toolAnimName, 0.0, Humanoid)
        end
    end
    function playToolAnimation(animName, transitionTime, humanoid, priority)
        if not animTable[animName] then return end
        local idx = rollAnimation(animName)
        local anim = animTable[animName][idx].anim
        if toolAnimInstance ~= anim then
            pcall(function()
                if toolAnimTrack then
                    toolAnimTrack:Stop()
                    toolAnimTrack:Destroy()
                    transitionTime = 0
                end
                toolAnimTrack = humanoid:LoadAnimation(anim)
                if priority then
                    toolAnimTrack.Priority = priority
                end
                toolAnimTrack:Play(transitionTime)
                toolAnimName = animName
                toolAnimInstance = anim
                currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:Connect(toolKeyFrameReachedFunc)
            end)
        end
    end
    local function stopToolAnimations()
        pcall(function()
            if currentToolAnimKeyframeHandler then
                currentToolAnimKeyframeHandler:Disconnect()
            end
            if toolAnimTrack then
                toolAnimTrack:Stop()
                toolAnimTrack:Destroy()
            end
        end)
        toolAnimName = ""
        toolAnimInstance = nil
        toolAnimTrack = nil
    end
    local function onRunning(speed)
        humanoidSpeed = speed
        if speed > 0.75 then
            playAnimation("walk", 0.2, Humanoid)
            if pose ~= "Running" then
                pose = "Running"
                updateVelocity(0)
            end
        else
            if emoteNames[currentAnim] == nil and not currentlyPlayingEmote then
                playAnimation("idle", 0.2, Humanoid)
                pose = "Standing"
            end
        end
    end
    local function onDied()
        pose = "Dead"
    end
    local function onJumping()
        playAnimation("jump", 0.1, Humanoid)
        pose = "Jumping"
    end
    local function onClimbing(speed)
        playAnimation("climb", 0.1, Humanoid)
        setAnimationSpeed(speed / 5.0)
        pose = "Climbing"
    end
    local function onGettingUp()
        pose = "GettingUp"
    end
    local function onFreeFall()
        playAnimation("fall", 0.2, Humanoid)
        pose = "FreeFall"
    end
    local function onFallingDown()
        pose = "FallingDown"
    end
    local function onSeated()
        pose = "Seated"
    end
    local function onPlatformStanding()
        pose = "PlatformStanding"
    end
    local function onSwimming(speed)
        if speed > 0 then
            pose = "Running"
        else
            pose = "Standing"
        end
    end
    local toolAnim = "None"
    local toolAnimTime = 0
    local toolTransitionTime = 0.1
    local lastTick = 0
    local jumpAnimTime = 0
    local jumpAnimDuration = 0.31
    local function animateTool()
        if toolAnim == "None" then
            playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
        elseif toolAnim == "Slash" then
            playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
        elseif toolAnim == "Lunge" then
            playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
        end
    end
    local function getToolAnim(tool)
        for _, c in ipairs(tool:GetChildren()) do
            if c.Name == "toolanim" and c:IsA("StringValue") then
                return c
            end
        end
        return nil
    end
    local function stepAnimate(currentTime)
        local deltaTime = currentTime - lastTick
        lastTick = currentTime
        if jumpAnimTime > 0 then
            jumpAnimTime = jumpAnimTime - deltaTime
        end
        if pose == "FreeFall" and jumpAnimTime <= 0 then
            playAnimation("fall", 0.2, Humanoid)
        elseif pose == "Seated" then
            playAnimation("sit", 0.5, Humanoid)
        elseif pose == "Running" then
            playAnimation("walk", 0.2, Humanoid)
            updateVelocity(currentTime)
        elseif pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "PlatformStanding" then
            stopAllAnimations()
        end
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            local animStringValueObject = getToolAnim(tool)
            if animStringValueObject then
                toolAnim = animStringValueObject.Value
                animStringValueObject.Parent = nil
                toolAnimTime = currentTime + 0.3
            end
            if currentTime > toolAnimTime then
                toolAnimTime = 0
                toolAnim = "None"
            end
            animateTool()
        else
            stopToolAnimations()
            toolAnim = "None"
            toolAnimInstance = nil
            toolAnimTime = 0
        end
    end
    pcall(function() Humanoid.Died:Connect(onDied) end)
    pcall(function() Humanoid.Running:Connect(onRunning) end)
    pcall(function() Humanoid.Jumping:Connect(onJumping) end)
    pcall(function() Humanoid.Climbing:Connect(onClimbing) end)
    pcall(function() Humanoid.GettingUp:Connect(onGettingUp) end)
    pcall(function() Humanoid.FreeFalling:Connect(onFreeFall) end)
    pcall(function() Humanoid.FallingDown:Connect(onFallingDown) end)
    pcall(function() Humanoid.Seated:Connect(onSeated) end)
    pcall(function() Humanoid.PlatformStanding:Connect(onPlatformStanding) end)
    pcall(function() Humanoid.Swimming:Connect(onSwimming) end)
    local function onChatted(msg)
        local emote = ""
        if string.sub(msg, 1, 3) == "/e " then
            emote = string.sub(msg, 4)
        elseif string.sub(msg, 1, 7) == "/emote " then
            emote = string.sub(msg, 8)
        end
        if pose == "Standing" and emoteNames[emote] ~= nil then
            playAnimation(emote, EMOTE_TRANSITION_TIME, Humanoid)
        end
    end
    pcall(function()
        if plr then
            plr.Chatted:Connect(onChatted)
        end
    end)
    if Character.Parent ~= nil then
        playAnimation("idle", 0.1, Humanoid)
        pose = "Standing"
    end
    task.spawn(function()
        while Character.Parent ~= nil do
            local _, currentGameTime = wait(0.1)
            pcall(function()
                stepAnimate(currentGameTime)
            end)
        end
    end)
end
if plr and plr.Character then
    RunCustomAnimation(plr.Character)
end
pcall(function()
    plr.CharacterAdded:Connect(function(Char)
        task.wait(0.1)
        RunCustomAnimation(Char)
    end)
end)
end)
if not success then
    warn("[CustomAnimation] Error: " .. tostring(err))
end
