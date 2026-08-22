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

    local savedWalkSpeed = 16
    local speedBoost = 0
    local savedJumpPower = 50
    local savedGravity = 196
    local smoothRate = 8
    
    local infJumpEnabled = false
    local infJumpPower = 50
    local lastJump = 0
    local jumpCooldown = 0.12 

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

    local function applyMovementSettings(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        humanoid.UseJumpPower = true
        humanoid.JumpPower = savedJumpPower
        humanoid.WalkSpeed = savedWalkSpeed
    end

    library:AddConnection(lp.CharacterAdded:Connect(applyMovementSettings))
    if lp.Character then applyMovementSettings(lp.Character) end

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
        if humanoid.WalkSpeed ~= savedWalkSpeed then
            humanoid.WalkSpeed = savedWalkSpeed
        end
        
        if speedBoost > 0 and humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (speedBoost * dt))
        end
    end))

    playerTab:AddSlider("WalkSpeed", 16, 200, 16, function(val) savedWalkSpeed = val end)
    playerTab:AddSlider("Speed Boost (CFrame)", 0, 100, 0, function(val) speedBoost = val end)
    playerTab:AddSlider("JumpPower", 50, 500, 50, function(val) savedJumpPower = val end)
    playerTab:AddSlider("Gravity", 0, 400, 196, function(val) savedGravity = val end)

    local infJumpToggle = playerTab:AddToggle("Infinite Jump", "Jump infinitely in air", function(state)
        infJumpEnabled = state
        notify("Infinite Jump", state and "Enabled" or "Disabled")
    end)
    playerTab:AddSlider("Inf Jump Force", 30, 200, 50, function(val) infJumpPower = val end)
    
    playerTab:AddBind("Toggle InfJump Key", Enum.KeyCode.J, function()
        if infJumpToggle and infJumpToggle.Set then
            infJumpToggle:Set(not infJumpEnabled)
        else
            infJumpEnabled = not infJumpEnabled
            notify("Infinite Jump", infJumpEnabled and "Enabled" or "Disabled")
        end
    end)


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

        if isAll then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        elseif isFriends then
            for _, plr in ipairs(players:GetPlayers()) do
                if plr ~= lp and not friendCache[plr.UserId] and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        else
            for _, pName in ipairs(blockedPlayers) do
                local plr = players:FindFirstChild(pName)
                if plr and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end))

    local noclipEnabled = false
    local originalCanCollide = {}

    library:AddConnection(rs.Stepped:Connect(function()
        if not noclipEnabled then return end
        local character = lp.Character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCanCollide[part] == nil then originalCanCollide[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end))

    local noclipToggle = playerTab:AddToggle("Noclip", "Walk through walls and obstacles", function(state)
        noclipEnabled = state
        if not state then
            for part, canCollide in pairs(originalCanCollide) do
                if part and part.Parent then part.CanCollide = canCollide end
            end
            table.clear(originalCanCollide)
        end
        notify("Noclip", state and "Enabled" or "Disabled")
    end)

    library:AddConnection(lp.CharacterAdded:Connect(function() table.clear(originalCanCollide) end))
    
    playerTab:AddBind("Toggle Noclip Key", Enum.KeyCode.N, function()
        if noclipToggle and noclipToggle.Set then
            noclipToggle:Set(not noclipEnabled)
        else
            noclipEnabled = not noclipEnabled
            notify("Noclip", noclipEnabled and "Enabled" or "Disabled")
        end
    end)


    playerTab:AddSection("Flight Control")

    local flyEnabled = false
    local flyHzSpeed = 18.5
    local flyVtSpeed = 30
    local toiletFlyConn = nil

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

    local function stopFly()
        if toiletFlyConn then toiletFlyConn:Disconnect(); toiletFlyConn = nil end
        local character = lp.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            humanoid.Sit = false; humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end

    library:AddConnection(lp.CharacterAdded:Connect(function(newChar)
        if flyEnabled then task.wait(0.5); startFly() end
    end))

    local flyToggle = playerTab:AddToggle("Fly", "Use WASD + Space/Ctrl", function(state)
        flyEnabled = state
        if state then startFly() else stopFly() end
        notify("Flight", state and "Enabled" or "Disabled")
    end)

    playerTab:AddBind("Toggle Fly Key", Enum.KeyCode.F, function()
        if flyToggle and flyToggle.Set then
            flyToggle:Set(not flyEnabled)
        else
            flyEnabled = not flyEnabled
            if flyEnabled then startFly() else stopFly() end
            notify("Flight", flyEnabled and "Enabled" or "Disabled")
        end
    end)

    playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 18, function(val) flyHzSpeed = val end)
    playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)
end
