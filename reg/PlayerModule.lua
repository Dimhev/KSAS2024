local players = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = players.LocalPlayer

return function(playerTab, library)
    playerTab:AddSection("Movement")

    local savedWalkSpeed = 16
    local speedBoost = 0
    local savedJumpPower = 50
    local savedGravity = 196
    local smoothRate = 8
    local flyEnabled = false

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

    playerTab:AddSection("Defense & Utils")

    local blockedPlayers = {}
    playerTab:AddTagList("Anti-Fling", "Enter username (auto-completes)...", function(input)
        input = input:lower()
        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():sub(1, #input) == input then
                return p.Name
            end
        end
        return input 
    end, function(newList)
        blockedPlayers = newList
    end)

    library:AddConnection(rs.Stepped:Connect(function()
        for _, pName in ipairs(blockedPlayers) do
            local plr = players:FindFirstChild(pName)
            if plr and plr.Character then
                for _, part in ipairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
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

    playerTab:AddToggle("Noclip", "Walk through walls and obstacles", function(state)
        noclipEnabled = state
        if not state then
            for part, canCollide in pairs(originalCanCollide) do
                if part and part.Parent then part.CanCollide = canCollide end
            end
            table.clear(originalCanCollide)
        end
    end)
    library:AddConnection(lp.CharacterAdded:Connect(function() table.clear(originalCanCollide) end))
    playerTab:AddBind("Toggle Noclip Key", Enum.KeyCode.N, function()
        noclipEnabled = not noclipEnabled
    end)


    playerTab:AddSection("Flight Control")

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

    playerTab:AddToggle("Fly", "Use WASD + Space/Ctrl", function(state)
        flyEnabled = state
        if state then startFly() else stopFly() end
    end)
    playerTab:AddBind("Toggle Fly Key", Enum.KeyCode.F, function()
        flyEnabled = not flyEnabled
        if flyEnabled then startFly() else stopFly() end
    end)

    playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 18, function(val) flyHzSpeed = val end)
    playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)
end
