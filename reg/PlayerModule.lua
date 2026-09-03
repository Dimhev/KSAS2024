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

    local savedJumpPower = 50
    local savedGravity = 196
    local smoothRate = 8

    local infJumpEnabled = false
    local infJumpPower = 50
    local lastJump = 0
    local jumpCooldown = 0.12

    playerTab:AddDropdown("Speed Method", {"Stealth (LinearVelocity)", "CFrame", "WalkSpeed"}, "Stealth (LinearVelocity)", function(selected)
        speedMethod = selected
        if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end)

    playerTab:AddToggle("Enable Speed", "Toggle movement speedhack", function(state)
        speedEnabled = state
        if not state and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
            lp.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
        notify("Speedhack", state and ("Enabled (" .. speedMethod .. ")") or "Disabled")
    end)

    playerTab:AddSlider("Speed Value", 16, 300, 16, function(val)
        targetSpeed = val
    end)

    library:AddConnection(uis.JumpRequest:Connect(function()
        if not infJumpEnabled then return end
        local character = lp.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not hrp or humanoid.Health <= 0 then return end

        if tick() - lastJump >= jumpCooldown and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
            lastJump = tick()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                infJumpPower,
                hrp.AssemblyLinearVelocity.Z
            )
        end
    end))

    local infJumpToggle = playerTab:AddToggle("Infinite Jump", "Jump infinitely in air", function(state)
        infJumpEnabled = state
        notify("Infinite Jump", state and "Enabled" or "Disabled")
    end)

    playerTab:AddSlider("Inf Jump Force", 30, 200, 50, function(val) infJumpPower = val end)

    playerTab:AddBind("Toggle InfJump Key", Enum.KeyCode.J, function()
        infJumpEnabled = not infJumpEnabled
        notify("Infinite Jump", infJumpEnabled and "Enabled" or "Disabled")
    end)

    playerTab:AddSlider("JumpPower", 50, 500, 50, function(val) savedJumpPower = val end)
    playerTab:AddSlider("Gravity", 0, 400, 196, function(val) savedGravity = val end)

    library:AddConnection(rs.Heartbeat:Connect(function(dt)
        local alpha = math.clamp(dt * smoothRate, 0, 1)

        if math.abs(workspace.Gravity - savedGravity) > 0.05 then
            workspace.Gravity = workspace.Gravity + (savedGravity - workspace.Gravity) * alpha
        end

        local character = lp.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not hrp or humanoid.Health <= 0 then return end

        if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end
        if math.abs(humanoid.JumpPower - savedJumpPower) > 0.05 then
            humanoid.JumpPower = humanoid.JumpPower + (savedJumpPower - humanoid.JumpPower) * alpha
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
        else
            if humanoid.WalkSpeed ~= 16 and speedMethod ~= "WalkSpeed" then
                humanoid.WalkSpeed = 16
            end
        end
    end))

    playerTab:AddSection("Defense & Utils")

    local blockedPlayers = {}
    local friendCache = {}

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

    local flingTagObj = playerTab:AddTagList("Anti-Fling", "Name / 'All' / 'Friends'", function(input)
        input = input:lower()
        if input == "all" then return "All" end
        if input == "friends" then return "Friends" end

        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():sub(1, #input) == input then
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
        local isFriends = table.find(blockedPlayers, "Friends")

        for _, plr in ipairs(players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local shouldDisable = false
                if isAll then
                    shouldDisable = true
                elseif isFriends and not friendCache[plr.UserId] then
                    shouldDisable = true
                elseif table.find(blockedPlayers, plr.Name) then
                    shouldDisable = true
                end

                if shouldDisable then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end))

    local noclipEnabled = false

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

    local noclipToggle = playerTab:AddToggle("Noclip", "Walk through walls", function(state)
        noclipEnabled = state
        notify("Noclip", state and "Enabled" or "Disabled")
    end)

    playerTab:AddBind("Toggle Noclip Key", Enum.KeyCode.N, function()
        noclipEnabled = not noclipEnabled
        notify("Noclip", noclipEnabled and "Enabled" or "Disabled")
    end)

    playerTab:AddSection("Flight Control")

    local flyEnabled = false
    local flyHzSpeed = 18.5
    local flyVtSpeed = 30
    local toiletFlyConn = nil

    local function stopFly()
        if toiletFlyConn then toiletFlyConn:Disconnect(); toiletFlyConn = nil end
        local character = lp.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end

    local function startFly()
        local character = lp.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyMover") or v:IsA("Constraint") then v:Destroy() end
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
            if hzMove.Magnitude == 0 and vtVel == 0 then vtVel = math.sin(tick() * 10) * 0.1 end

            hrp.AssemblyLinearVelocity = Vector3.new(hzMove.X, vtVel, hzMove.Z)
            hrp.RotVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0.0001, 0)
        end))
    end

    local flyToggle = playerTab:AddToggle("Fly", "Use WASD + Space/Ctrl", function(state)
        flyEnabled = state
        if state then startFly() else stopFly() end
        notify("Flight", state and "Enabled" or "Disabled")
    end)

    playerTab:AddBind("Toggle Fly Key", Enum.KeyCode.F, function()
        flyEnabled = not flyEnabled
        if flyEnabled then startFly() else stopFly() end
        notify("Flight", flyEnabled and "Enabled" or "Disabled")
    end)

    playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 18, function(val) flyHzSpeed = val end)
    playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)

    library:AddConnection(lp.CharacterAdded:Connect(function(newChar)
        stopFly()
        
        local hum = newChar:WaitForChild("Humanoid", 5)
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = savedJumpPower
        end

        if flyEnabled then
            task.wait(0.5)
            startFly()
        end
    end))
end
