local players = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = players.LocalPlayer

return function(playerTab, library)
    local function notify(title, text)
        if library.Notify then
            library:Notify(title, text, 2)
        elseif library.Notification then
            library:Notification({Title = title, Text = text, Duration = 2})
        end
    end

    playerTab:AddSection("Movement")

    local speedEnabled = false
    local speedMethod = "Stealth (LinearVelocity)"
    local targetSpeed = 16
    local originalWalkSpeed = 16

    local originalGravity = workspace.Gravity
    local savedGravity = workspace.Gravity
    local gravityEnabled = false

    local originalJumpPower = 50
    local savedJumpPower = 50
    local jumpPowerEnabled = false

    local infJumpEnabled = false
    local infJumpMethod = "PlatformJump"
    local infJumpPower = 50
    local lastJump = 0
    local jumpCooldown = 0.12

    local platformObj = nil
    local platformFallSpeed = 20
    local platformHeight = 3.3
    local platformY = nil 
    local isRecreating = false

    local function destroyPlatform()
        if platformObj then
            local p = platformObj
            platformObj = nil
            p:Destroy()
        end
        platformY = nil
    end

    local function createPlatform()
        if isRecreating then return end
        isRecreating = true

        if platformObj then
            platformObj:Destroy()
            platformObj = nil
        end

        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            isRecreating = false 
            return 
        end

        local cam = workspace.CurrentCamera or workspace
        local plat = Instance.new("Part")
        plat.Name = "Platform" 
        plat.Size = Vector3.new(18, 1, 18)
        
        local spawnY = hrp.Position.Y - platformHeight
        platformY = platformY or spawnY
        plat.CFrame = CFrame.new(hrp.Position.X, platformY, hrp.Position.Z)
        
        plat.Anchored = true
        plat.CanCollide = true
        plat.CanTouch = false 
        plat.CanQuery = false 
        plat.Archivable = false
        plat.Transparency = 0.4
        plat.Material = Enum.Material.SmoothPlastic
        plat.Color = Color3.fromRGB(0, 170, 255)
        plat.Parent = cam

        local function onDeleted()
            if infJumpEnabled and infJumpMethod == "PlatformJump" then
                task.defer(function()
                    isRecreating = false
                    createPlatform()
                end)
            end
        end

        plat.Destroying:Connect(onDeleted)
        plat.AncestryChanged:Connect(function(_, parent)
            if not parent then onDeleted() end
        end)

        platformObj = plat
        isRecreating = false
    end
    
    local function setSpeed(state)
        speedEnabled = state
        local character = lp.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state then
                originalWalkSpeed = humanoid.WalkSpeed
            else
                humanoid.WalkSpeed = originalWalkSpeed or 16
            end
        end
        notify("Speedhack", state and ("Enabled (" .. speedMethod .. ")") or "Disabled")
    end

    playerTab:AddDropdown("Speed Method", {"Stealth (LinearVelocity)", "CFrame", "WalkSpeed"}, "Stealth (LinearVelocity)", function(selected)
        speedMethod = selected
        local character = lp.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid and not speedEnabled then
            humanoid.WalkSpeed = originalWalkSpeed or 16
        end
    end)

    playerTab:AddToggle("Enable Speed", "Toggle movement speedhack", function(state)
        setSpeed(state)
    end)

    playerTab:AddSlider("Speed Value", 16, 300, 16, function(val)
        targetSpeed = val
    end)

    local function setInfJump(state)
        infJumpEnabled = state
        if state and infJumpMethod == "PlatformJump" then
            platformY = nil
            createPlatform()
        else
            destroyPlatform()
        end
        notify("Infinite Jump", state and ("Enabled (" .. infJumpMethod .. ")") or "Disabled")
    end

    playerTab:AddDropdown("InfJump Method", {"VelocityJump", "PlatformJump"}, "PlatformJump", function(selected)
        infJumpMethod = selected
        if infJumpEnabled and infJumpMethod == "PlatformJump" then
            platformY = nil
            createPlatform()
        else
            destroyPlatform()
        end
    end)

    library:AddConnection(uis.JumpRequest:Connect(function()
        if not infJumpEnabled then return end
        if uis:GetFocusedTextBox() then return end

        local character = lp.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp or humanoid.Health <= 0 then return end

        if os.clock() - lastJump < jumpCooldown then return end
        if humanoid:GetState() == Enum.HumanoidStateType.Seated then return end

        lastJump = os.clock()

        if infJumpMethod == "VelocityJump" then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                infJumpPower,
                hrp.AssemblyLinearVelocity.Z
            )
        elseif infJumpMethod == "PlatformJump" then
            platformY = hrp.Position.Y - platformHeight
            if platformObj and platformObj.Parent then
                platformObj.CFrame = CFrame.new(hrp.Position.X, platformY, hrp.Position.Z)
            else
                createPlatform()
            end

            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                math.max(hrp.AssemblyLinearVelocity.Y, infJumpPower),
                hrp.AssemblyLinearVelocity.Z
            )
        end
    end))

    playerTab:AddToggle("Infinite Jump", "Jump infinitely in air", function(state)
        setInfJump(state)
    end)

    playerTab:AddBind("Toggle InfJump Key", Enum.KeyCode.J, function()
        setInfJump(not infJumpEnabled)
    end)

    playerTab:AddSlider("Inf Jump Force", 30, 200, 50, function(val)
        infJumpPower = val
    end)

    playerTab:AddSlider("Platform Fall Speed", 1, 100, 20, function(val)
        platformFallSpeed = val
    end)

    playerTab:AddToggle("Enable JumpPower Mod", "Override humanoid JumpPower", function(state)
        jumpPowerEnabled = state
        local character = lp.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not state and humanoid then
            humanoid.JumpPower = originalJumpPower
        end
        notify("JumpPower Mod", state and "Enabled" or "Restored")
    end)

    playerTab:AddSlider("JumpPower", 10, 500, originalJumpPower, function(val)
        savedJumpPower = val
    end)

    playerTab:AddToggle("Enable Gravity Mod", "Override workspace Gravity", function(state)
        gravityEnabled = state
        if not state then
            workspace.Gravity = originalGravity
        end
        notify("Gravity Mod", state and "Enabled" or "Restored")
    end)

    playerTab:AddSlider("Gravity", 0, 400, math.floor(originalGravity), function(val)
        savedGravity = val
    end)

    library:AddConnection(rs.Heartbeat:Connect(function(dt)
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if not character or not humanoid or not hrp or humanoid.Health <= 0 then
            destroyPlatform()
            return
        end

        if speedEnabled then
            if speedMethod == "WalkSpeed" then
                humanoid.WalkSpeed = targetSpeed
            elseif speedMethod == "CFrame" then
                humanoid.WalkSpeed = 16
                if humanoid.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (targetSpeed * dt))
                end
            elseif speedMethod == "Stealth (LinearVelocity)" then
                humanoid.WalkSpeed = 16
                if humanoid.MoveDirection.Magnitude > 0 then
                    local moveVec = humanoid.MoveDirection * targetSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveVec.X, hrp.AssemblyLinearVelocity.Y, moveVec.Z)
                end
            end
        end
        if infJumpEnabled and infJumpMethod == "PlatformJump" then
            if not platformObj or not platformObj.Parent then
                createPlatform()
            end

            if platformObj then
                local hrpPos = hrp.Position
                local hrpVel = hrp.AssemblyLinearVelocity
                local idealY = hrpPos.Y - platformHeight

                if not platformY then
                    platformY = idealY
                end

                if idealY < platformY then
                    platformY = idealY
                elseif hrpVel.Y <= 0.5 then
                    platformY = platformY - (platformFallSpeed * dt)
                end
                local targetX = hrpPos.X + (hrpVel.X * dt)
                local targetZ = hrpPos.Z + (hrpVel.Z * dt)

                platformObj.CFrame = CFrame.new(targetX, platformY, targetZ)
            end
        else
            destroyPlatform()
        end
    end))
    
    playerTab:AddSection("Defense & Utils")

    local blockedLookup = {}
    local friendCache = {}
    local modifiedFlingParts = setmetatable({}, {__mode = "k"})

    local function updateFriendStatus(plr)
        task.spawn(function()
            local success, isFriend = pcall(function() return lp:IsFriendsWith(plr.UserId) end)
            if success then friendCache[plr.UserId] = isFriend end
        end)
    end

    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= lp then updateFriendStatus(plr) end
    end
    library:AddConnection(players.PlayerAdded:Connect(updateFriendStatus))
    library:AddConnection(players.PlayerRemoving:Connect(function(plr)
        friendCache[plr.UserId] = nil
        blockedLookup[plr.Name] = nil
    end))

    local flingTagObj = playerTab:AddTagList("Anti-Fling", "Name / 'All' / 'All Except Friends'", function(input)
        local lower = input:lower()
        if lower == "all" then return "All" end
        if lower == "friends" or lower == "all except friends" or lower == "nonfriends" then
            return "All Except Friends"
        end

        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():sub(1, #lower) == lower then
                return p.Name
            end
        end
        return input
    end, function(newList)
        table.clear(blockedLookup)
        for _, name in ipairs(newList) do
            blockedLookup[name] = true
        end
    end)

    library:AddConnection(players.PlayerRemoving:Connect(function(plr)
        if blockedLookup[plr.Name] then
            flingTagObj:RemoveTag(plr.Name)
        end
    end))

    library:AddConnection(rs.Stepped:Connect(function()
        local isAll = blockedLookup["All"]
        local isAllExceptFriends = blockedLookup["All Except Friends"] or blockedLookup["Friends"]
        local currentFrameParts = {}

        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local shouldDisable = isAll 
                        or (isAllExceptFriends and not friendCache[plr.UserId]) 
                        or blockedLookup[plr.Name]

                    if shouldDisable then
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                if modifiedFlingParts[part] == nil then
                                    modifiedFlingParts[part] = part.CanCollide
                                end
                                part.CanCollide = false
                                currentFrameParts[part] = true
                            end
                        end
                    end
                end
            end
        end

        for part, originalCanCollide in pairs(modifiedFlingParts) do
            if not currentFrameParts[part] then
                if part.Parent and originalCanCollide then
                    part.CanCollide = true
                end
                modifiedFlingParts[part] = nil
            end
        end
    end))

    local noclipEnabled = false
    local characterPartsCache = {}

    local function rebuildCharacterCache(char)
        table.clear(characterPartsCache)
        if not char then return end

        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(characterPartsCache, desc)
            end
        end

        library:AddConnection(char.DescendantAdded:Connect(function(desc)
            if desc:IsA("BasePart") then
                table.insert(characterPartsCache, desc)
            end
        end))

        library:AddConnection(char.DescendantRemoving:Connect(function(desc)
            local index = table.find(characterPartsCache, desc)
            if index then
                table.remove(characterPartsCache, index)
            end
        end))
    end

    local function setNoclip(state)
        noclipEnabled = state
        notify("Noclip", state and "Enabled" or "Disabled")
    end

    library:AddConnection(rs.Stepped:Connect(function()
        if not noclipEnabled then return end
        for i = 1, #characterPartsCache do
            local part = characterPartsCache[i]
            if part.CanCollide then
                part.CanCollide = false
            end
        end
    end))

    playerTab:AddToggle("Noclip", "Walk through walls", function(state)
        setNoclip(state)
    end)

    playerTab:AddBind("Toggle Noclip Key", Enum.KeyCode.N, function()
        setNoclip(not noclipEnabled)
    end)

    playerTab:AddSection("Flight Control")

    local flyEnabled = false
    local flyHzSpeed = 25
    local flyVtSpeed = 30
    local flyConnection = nil

    local function stopFly()
        if flyConnection then 
            flyConnection:Disconnect()
            flyConnection = nil 
        end
        local character = lp.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then 
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function startFly()
        stopFly()
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then return end

        humanoid.PlatformStand = true

        flyConnection = library:AddConnection(rs.Heartbeat:Connect(function()
            if not flyEnabled then 
                stopFly()
                return 
            end

            if not humanoid or humanoid.Health <= 0 or not hrp or not hrp.Parent then
                stopFly()
                return
            end

            if not humanoid.SeatPart then
                humanoid.Sit = true
            end

            if uis:GetFocusedTextBox() then
                hrp.AssemblyLinearVelocity = Vector3.new(0, math.sin(os.clock() * 5) * 0.1, 0)
                hrp.AssemblyAngularVelocity = Vector3.zero
                return
            end

            local cam = workspace.CurrentCamera
            if not cam then return end

            local camCF = cam.CFrame
            local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
            local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

            if forward.Magnitude > 0 then forward = forward.Unit end
            if right.Magnitude > 0 then right = right.Unit end

            local moveDir = Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += forward end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= forward end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= right end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += right end

            local hzVel = Vector3.zero
            if moveDir.Magnitude > 0 then
                hzVel = moveDir.Unit * flyHzSpeed
            end

            local vtVel = 0
            if uis:IsKeyDown(Enum.KeyCode.Space) then vtVel = flyVtSpeed end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then vtVel = -flyVtSpeed end

            if hzVel.Magnitude == 0 and vtVel == 0 then 
                vtVel = math.sin(os.clock() * 6) * 0.15 
            end

            hrp.AssemblyLinearVelocity = Vector3.new(hzVel.X, vtVel, hzVel.Z)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end))
    end

    local function setFly(state)
        flyEnabled = state
        if state then 
            startFly() 
        else 
            stopFly() 
        end
        notify("Flight", state and "Enabled" or "Disabled")
    end

    playerTab:AddToggle("Fly", "Use WASD + Space/Ctrl", function(state)
        setFly(state)
    end)

    playerTab:AddBind("Toggle Fly Key", Enum.KeyCode.F, function()
        setFly(not flyEnabled)
    end)

    playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 25, function(val) flyHzSpeed = val end)
    playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)

    if lp.Character then
        rebuildCharacterCache(lp.Character)
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            originalJumpPower = hum.JumpPower
            originalWalkSpeed = hum.WalkSpeed
        end
    end

    library:AddConnection(lp.CharacterAdded:Connect(function(newChar)
        stopFly()
        destroyPlatform()
        table.clear(modifiedFlingParts)
        rebuildCharacterCache(newChar)

        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then
            originalJumpPower = hum.JumpPower
            originalWalkSpeed = hum.WalkSpeed

            if jumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = savedJumpPower
            end
        end

        if flyEnabled then
            task.wait(0.5)
            if flyEnabled and lp.Character == newChar then
                startFly()
            end
        end
    end))

    library:AddConnection(lp.CharacterRemoving:Connect(function()
        destroyPlatform()
        stopFly()
    end))
end
