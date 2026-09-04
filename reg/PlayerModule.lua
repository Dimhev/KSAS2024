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
    local originalWalkSpeed = nil

    local originalGravity = workspace.Gravity
    local savedGravity = workspace.Gravity
    local gravityEnabled = false

    local originalJumpPower = 50
    local savedJumpPower = 50
    local jumpPowerEnabled = false

    local smoothRate = 8

    local infJumpEnabled = false
    local infJumpMethod = "VelocityJump"
    local infJumpPower = 50
    local lastJump = 0
    local jumpCooldown = 0.12

    local platformObj = nil
    local platformFollowSpeed = 60
    local platformFallSpeed = 20
    local platformHeight = 3.2

    local function destroyPlatform()
        if platformObj then
            platformObj:Destroy()
            platformObj = nil
        end
    end

    local function createPlatform()
        destroyPlatform()
        local character = lp.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local plat = Instance.new("Part")
        plat.Name = "Platform"
        plat.Size = Vector3.new(15, 1, 15)
        plat.CFrame = hrp.CFrame * CFrame.new(0, -platformHeight, 0)
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Material = Enum.Material.SmoothPlastic
        plat.Color = Color3.fromRGB(0, 170, 255)
        plat.Parent = workspace
        
        platformObj = plat
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
                originalWalkSpeed = nil
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
            createPlatform()
        else
            destroyPlatform()
        end
        notify("Infinite Jump", state and ("Enabled (" .. infJumpMethod .. ")") or "Disabled")
    end

    playerTab:AddDropdown("InfJump Method", {"VelocityJump", "PlatformJump"}, "VelocityJump", function(selected)
        infJumpMethod = selected
        if infJumpEnabled and infJumpMethod == "PlatformJump" then
            createPlatform()
        else
            destroyPlatform()
        end
    end)

    library:AddConnection(uis.JumpRequest:Connect(function()
        if not infJumpEnabled then return end
        local character = lp.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not hrp or humanoid.Health <= 0 then return end

        if os.clock() - lastJump >= jumpCooldown and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            lastJump = os.clock()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                infJumpPower,
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
        local alpha = math.clamp(dt * smoothRate, 0, 1)

        if gravityEnabled and math.abs(workspace.Gravity - savedGravity) > 0.05 then
            workspace.Gravity = workspace.Gravity + (savedGravity - workspace.Gravity) * alpha
        end

        local character = lp.Character
        if not character then 
            destroyPlatform()
            return 
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not hrp or humanoid.Health <= 0 then 
            destroyPlatform()
            return 
        end

        if jumpPowerEnabled then
            if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end
            if math.abs(humanoid.JumpPower - savedJumpPower) > 0.05 then
                humanoid.JumpPower = humanoid.JumpPower + (savedJumpPower - humanoid.JumpPower) * alpha
            end
        end

        if speedEnabled then
            if speedMethod == "WalkSpeed" then
                humanoid.WalkSpeed = targetSpeed
            elseif speedMethod == "CFrame" then
                humanoid.WalkSpeed = 16
                if humanoid.MoveDirection.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * ((targetSpeed - 16) * dt))
                end
            elseif speedMethod == "Stealth (LinearVelocity)" then
                humanoid.WalkSpeed = 16
                if humanoid.MoveDirection.Magnitude > 0 then
                    local currentY = hrp.AssemblyLinearVelocity.Y
                    local moveVec = humanoid.MoveDirection * targetSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(moveVec.X, currentY, moveVec.Z)
                end
            end
        end

        if infJumpEnabled and infJumpMethod == "PlatformJump" then
            if not platformObj or not platformObj.Parent then
                createPlatform()
            end

            if platformObj then
                local currentPos = platformObj.Position
                local hrpPos = hrp.Position
                
                local targetX = hrpPos.X
                local targetZ = hrpPos.Z
                local targetY = currentPos.Y

                local playerVelY = hrp.AssemblyLinearVelocity.Y
                local idealY = hrpPos.Y - platformHeight

                if playerVelY > 0.5 then
                    targetY = currentPos.Y
                elseif playerVelY < -0.5 then
                    if idealY < currentPos.Y then
                        targetY = math.max(idealY, currentPos.Y - (platformFallSpeed * dt))
                    else
                        targetY = currentPos.Y
                    end
                else
                    targetY = currentPos.Y + (idealY - currentPos.Y) * math.clamp(dt * 8, 0, 1)
                end

                local newX = currentPos.X + (targetX - currentPos.X) * math.clamp(dt * platformFollowSpeed, 0, 1)
                local newZ = currentPos.Z + (targetZ - currentPos.Z) * math.clamp(dt * platformFollowSpeed, 0, 1)

                platformObj.CFrame = CFrame.new(Vector3.new(newX, targetY, newZ))
            end
        else
            destroyPlatform()
        end
    end))

    playerTab:AddSection("Defense & Utils")

    local blockedPlayers = {}
    local friendCache = {}
    local disabledFlingParts = {} 

    task.spawn(function()
        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= lp then pcall(function() friendCache[plr.UserId] = lp:IsFriendsWith(plr.UserId) end) end
        end
    end)
    library:AddConnection(players.PlayerAdded:Connect(function(plr)
        pcall(function() friendCache[plr.UserId] = lp:IsFriendsWith(plr.UserId) end)
    end))
    library:AddConnection(players.PlayerRemoving:Connect(function(plr)
        friendCache[plr.UserId] = nil
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
        blockedPlayers = newList
    end)

    library:AddConnection(players.PlayerRemoving:Connect(function(plr)
        if table.find(blockedPlayers, plr.Name) then
            flingTagObj:RemoveTag(plr.Name)
        end
    end))

    library:AddConnection(rs.Stepped:Connect(function()
        local isAll = table.find(blockedPlayers, "All")
        local isAllExceptFriends = table.find(blockedPlayers, "All Except Friends") or table.find(blockedPlayers, "Friends")

        local currentBlockedParts = {}

        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local shouldDisable = false
                    if isAll then
                        shouldDisable = true
                    elseif isAllExceptFriends and not friendCache[plr.UserId] then
                        shouldDisable = true
                    elseif table.find(blockedPlayers, plr.Name) then
                        shouldDisable = true
                    end

                    if shouldDisable then
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                currentBlockedParts[part] = true
                            end
                        end
                    end
                end
            end
        end

        for part in pairs(disabledFlingParts) do
            if not currentBlockedParts[part] then
                if part.Parent then
                    pcall(function() part.CanCollide = true end)
                end
                disabledFlingParts[part] = nil
            end
        end

        for part in pairs(currentBlockedParts) do
            disabledFlingParts[part] = true
        end
    end))

    local noclipEnabled = false

    local function setNoclip(state)
        noclipEnabled = state
        notify("Noclip", state and "Enabled" or "Disabled")
    end

    library:AddConnection(rs.Stepped:Connect(function()
        if not noclipEnabled then return end
        local character = lp.Character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
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
    local flyHzSpeed = 18.5
    local flyVtSpeed = 30
    local toiletFlyConn = nil

    local function stopFly()
        if toiletFlyConn then 
            toiletFlyConn:Disconnect()
            toiletFlyConn = nil 
        end
        local character = lp.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then 
            hrp.AssemblyLinearVelocity = Vector3.zero 
        end
    end

    local function startFly()
        local character = lp.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyMover") or v:IsA("LinearVelocity") or v:IsA("VectorForce") then 
                v:Destroy() 
            end
        end

        humanoid.PlatformStand = true
        if toiletFlyConn then toiletFlyConn:Disconnect() end

        toiletFlyConn = library:AddConnection(rs.Heartbeat:Connect(function()
            if not flyEnabled then return end
            humanoid.Sit = true
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.zero

            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end

            local hzMove = Vector3.new(moveDir.X, 0, moveDir.Z)
            if hzMove.Magnitude > 0 then hzMove = hzMove.Unit * flyHzSpeed end

            local vtVel = 0
            if uis:IsKeyDown(Enum.KeyCode.Space) then vtVel = flyVtSpeed end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then vtVel = -flyVtSpeed end
            
            if hzMove.Magnitude == 0 and vtVel == 0 then 
                vtVel = math.sin(os.clock() * 10) * 0.1 
            end

            hrp.AssemblyLinearVelocity = Vector3.new(hzMove.X, vtVel, hzMove.Z)
            hrp.RotVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0.0001, 0)
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

    playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 18, function(val) flyHzSpeed = val end)
    playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)

    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            originalJumpPower = hum.JumpPower
            originalWalkSpeed = hum.WalkSpeed
        end
    end

    library:AddConnection(lp.CharacterAdded:Connect(function(newChar)
        stopFly()
        destroyPlatform()
        disabledFlingParts = {}

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
            startFly()
        end
    end))
end
