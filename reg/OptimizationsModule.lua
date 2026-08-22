local workspace = game:GetService("Workspace")
local rs = game:GetService("RunService")
local camera = workspace.CurrentCamera

return function(tab, library)
    tab:AddSection("Perfomance")

    local cullingActive = false
    local SHADOW_DIST = 100
    local HIDE_DIST = 500
    local BATCH_SIZE = 250

    local trackedParts = {}
    local currentIndex = 1

    local function registerPart(part)
        if not part:IsA("BasePart") then return end
        if part.Parent and part.Parent:FindFirstChild("Humanoid") then return end 

        local isDeco = (not part.CanCollide and part.Size.Magnitude < 15)
        table.insert(trackedParts, {
            part = part,
            origParent = part.Parent,
            origShadow = part.CastShadow,
            isDeco = isDeco
        })
    end

    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i, v in ipairs(descendants) do
            registerPart(v)
            if i % 1000 == 0 then task.wait() end
        end
    end)

    library:AddConnection(workspace.DescendantAdded:Connect(function(v)
        if cullingActive then registerPart(v) end
    end))

    library:AddConnection(rs.Heartbeat:Connect(function()
        if not cullingActive or #trackedParts == 0 then return end
        
        local camPos = camera.CFrame.Position
        local limit = math.min(currentIndex + BATCH_SIZE, #trackedParts)

        for i = currentIndex, limit do
            local data = trackedParts[i]
            local part = data.part

            if not part or not part.Parent and part.Parent ~= nil then
                continue 
            end

            local dist = (part.Position - camPos).Magnitude

            if dist > SHADOW_DIST then
                if part.CastShadow then part.CastShadow = false end
            else
                if not part.CastShadow and data.origShadow then part.CastShadow = true end
            end

            if data.isDeco then
                if dist > HIDE_DIST and part.Parent ~= nil then
                    data.origParent = part.Parent
                    part.Parent = nil 
                elseif dist <= HIDE_DIST and part.Parent == nil then
                    part.Parent = data.origParent 
                end
            end
        end

        currentIndex = limit + 1
        if currentIndex > #trackedParts then
            currentIndex = 1 
        end
    end))

    tab:AddToggle("Smart LOD Culling", "Dynamically hides far objects & shadows", function(state)
        cullingActive = state
        if not state then
            for _, data in ipairs(trackedParts) do
                if data.part then
                    if data.part.Parent == nil then data.part.Parent = data.origParent end
                    data.part.CastShadow = data.origShadow
                end
            end
        end
    end)
end
