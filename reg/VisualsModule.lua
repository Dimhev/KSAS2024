local players = game:GetService("Players")
local rs = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local lp = players.LocalPlayer

return function(visualsTab, library)
    visualsTab:AddSection("Lighting Modifications")

    local fbEnabled = false
    local fbConnection = nil
    local origLighting = {}

    local function applyFullbright()
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
    end

    visualsTab:AddToggle("Fullbright", "Removes shadows and makes everything bright", function(state)
        fbEnabled = state
        if state then
            origLighting.Ambient = lighting.Ambient
            origLighting.OutdoorAmbient = lighting.OutdoorAmbient
            origLighting.Brightness = lighting.Brightness
            origLighting.ClockTime = lighting.ClockTime
            origLighting.FogEnd = lighting.FogEnd
            origLighting.GlobalShadows = lighting.GlobalShadows
            
            applyFullbright()
            fbConnection = library:AddConnection(lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
                if fbEnabled then applyFullbright() end
            end))
        else
            if fbConnection then fbConnection:Disconnect(); fbConnection = nil end
            for k, v in pairs(origLighting) do pcall(function() lighting[k] = v end) end
        end
    end)

    visualsTab:AddSection("Player ESP")

    local espSettings = {
        enabled = false, boxes = false, names = false, health = false, distance = false, teamColor = false,
        maxDist = 1500, baseColor = Color3.fromRGB(255, 255, 255)
    }
    local espCache = {}

    local function createEspDrawing(plr)
        if espCache[plr] then return end
        espCache[plr] = {
            boxOutline = Drawing.new("Square"), box = Drawing.new("Square"),
            name = Drawing.new("Text"), dist = Drawing.new("Text"),
            hpOutline = Drawing.new("Square"), hp = Drawing.new("Square")
        }
        local c = espCache[plr]
        c.boxOutline.Thickness = 3; c.boxOutline.Color = Color3.new(0, 0, 0); c.boxOutline.Filled = false
        c.box.Thickness = 1; c.box.Filled = false
        c.name.Size = 14; c.name.Center = true; c.name.Outline = true
        c.dist.Size = 13; c.dist.Center = true; c.dist.Outline = true
        c.hpOutline.Thickness = 1; c.hpOutline.Color = Color3.new(0, 0, 0); c.hpOutline.Filled = true
        c.hp.Thickness = 1; c.hp.Filled = true
    end

    local function removeEspDrawing(plr)
        if espCache[plr] then
            for _, drawing in pairs(espCache[plr]) do drawing:Remove() end
            espCache[plr] = nil
        end
    end

    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= lp then createEspDrawing(plr) end
    end
    library:AddConnection(players.PlayerAdded:Connect(createEspDrawing))
    library:AddConnection(players.PlayerRemoving:Connect(removeEspDrawing))

    library:AddConnection(library.Gui.Destroying:Connect(function()
        for plr, _ in pairs(espCache) do removeEspDrawing(plr) end
    end))

    library:AddConnection(rs.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera 
        if not cam then return end

        for plr, cache in pairs(espCache) do
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            local isAlive = char and hrp and head and hum and hum.Health > 0
            local onScreen = false
            local dist = 0
            
            if espSettings.enabled and isAlive then
                local _, screenCheck = cam:WorldToViewportPoint(hrp.Position)
                onScreen = screenCheck
                dist = (cam.CFrame.Position - hrp.Position).Magnitude
            end
            
            if onScreen and dist <= espSettings.maxDist then
                local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local h = math.abs(headPos.Y - legPos.Y)
                local w = h * 0.6
                
                local renderColor = espSettings.baseColor
                if espSettings.teamColor and plr.Team then renderColor = plr.TeamColor.Color end
                
                if espSettings.boxes then
                    cache.boxOutline.Size = Vector2.new(w, h); cache.boxOutline.Position = Vector2.new(headPos.X - w/2, headPos.Y); cache.boxOutline.Visible = true
                    cache.box.Size = Vector2.new(w, h); cache.box.Position = Vector2.new(headPos.X - w/2, headPos.Y); cache.box.Color = renderColor; cache.box.Visible = true
                else cache.boxOutline.Visible = false; cache.box.Visible = false end
                
                if espSettings.names then
                    cache.name.Text = plr.Name; cache.name.Position = Vector2.new(headPos.X, headPos.Y - 16); cache.name.Color = renderColor; cache.name.Visible = true
                else cache.name.Visible = false end
                
                if espSettings.distance then
                    cache.dist.Text = math.floor(dist) .. "s"; cache.dist.Position = Vector2.new(headPos.X, headPos.Y + h + 2); cache.dist.Color = renderColor; cache.dist.Visible = true
                else cache.dist.Visible = false end
                
                if espSettings.health then
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    cache.hpOutline.Size = Vector2.new(4, h + 2); cache.hpOutline.Position = Vector2.new(headPos.X - w/2 - 6, headPos.Y - 1); cache.hpOutline.Visible = true
                    cache.hp.Size = Vector2.new(2, h * hpPercent); cache.hp.Position = Vector2.new(headPos.X - w/2 - 5, headPos.Y + (h - (h * hpPercent))); cache.hp.Color = Color3.fromHSV(hpPercent * 0.3, 1, 1); cache.hp.Visible = true
                else cache.hpOutline.Visible = false; cache.hp.Visible = false end
            else
                cache.boxOutline.Visible = false; cache.box.Visible = false
                cache.name.Visible = false; cache.dist.Visible = false
                cache.hpOutline.Visible = false; cache.hp.Visible = false
            end
        end
    end))

    visualsTab:AddToggle("Enable ESP", "Master switch for Player ESP", function(state) espSettings.enabled = state end)
    visualsTab:AddToggle("Boxes", "Draw 2D bounding boxes", function(state) espSettings.boxes = state end)
    visualsTab:AddToggle("Names", "Display player DisplayName", function(state) espSettings.names = state end)
    visualsTab:AddToggle("Health Bar", "Show dynamic health bar", function(state) espSettings.health = state end)
    visualsTab:AddToggle("Distance", "Show distance in studs", function(state) espSettings.distance = state end)
    visualsTab:AddToggle("Use Team Colors", "Matches ESP color to player's team", function(state) espSettings.teamColor = state end)
    visualsTab:AddSlider("Max Distance", 100, 5000, 1500, function(val) espSettings.maxDist = val end)

visualsTab:AddSection("Performance & Optimization")

local cullingActive = false
local vfxActive = false

local DECO_HIDE_DIST_SQ = 400 * 400
local DEBRIS_HIDE_DIST_SQ = 180 * 180 
local BATCH_SIZE = 300

local trackedParts = {}
local trackedSet = setmetatable({}, { __mode = "k" })
local vfxCache = setmetatable({}, { __mode = "k" }) 
local currentIndex = 1

local function getBasePosition(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Trail") or inst:IsA("Beam") then
        local a0, a1 = inst.Attachment0, inst.Attachment1
        if a0 and a1 then
            return (a0.WorldPosition + a1.WorldPosition) / 2
        elseif a0 then return a0.WorldPosition
        elseif a1 then return a1.WorldPosition
        end
    end
    if inst.Parent and inst.Parent:IsA("BasePart") then return inst.Parent.Position end
    if inst.Parent and inst.Parent:IsA("Attachment") then return inst.Parent.WorldPosition end
    return nil
end

local function registerObject(inst)
    if trackedSet[inst] then return end 

    if inst:IsA("BasePart") then
        local model = inst:FindFirstAncestorOfClass("Model")
        if model then
            if model:FindFirstChildOfClass("Humanoid") then return end
            if model:FindFirstChildOfClass("VehicleSeat") or model:FindFirstChildOfClass("Seat") then return end
        end
        if inst:FindFirstAncestorOfClass("Tool") then return end

        local size = inst.Size.Magnitude
        
        local isDeco = (not inst.CanCollide and size < 15)
        
        local isDebris = (not inst.Anchored and size < 25)
        
        local shadowDist = size > 25 and 200 or (size > 10 and 120 or 70)
        
        trackedSet[inst] = true
        table.insert(trackedParts, {
            part = inst,
            origParent = inst.Parent,
            origShadow = inst.CastShadow,
            shadowDistSq = shadowDist * shadowDist,
            isDeco = isDeco,
            isDebris = isDebris,
            hidden = false,
            lastPos = inst.Position
        })
    end

    if inst:IsA("ParticleEmitter") then 
        trackedSet[inst] = true
        vfxCache[inst] = { Rate = inst.Rate, Type = "Particle" }
    elseif inst:IsA("Smoke") then 
        trackedSet[inst] = true
        vfxCache[inst] = { Opacity = inst.Opacity, Type = "Smoke" }
    elseif inst:IsA("Trail") then 
        trackedSet[inst] = true
        vfxCache[inst] = { Lifetime = inst.Lifetime, Type = "Trail" }
    elseif inst:IsA("Beam") then 
        trackedSet[inst] = true
        vfxCache[inst] = { Segments = inst.Segments, Type = "Beam" }
    elseif inst:IsA("Light") then 
        trackedSet[inst] = true
        vfxCache[inst] = { Shadows = inst.Shadows, Range = inst.Range, Type = "Light" }
    end
end

task.spawn(function()
    for i, v in ipairs(workspace:GetDescendants()) do
        registerObject(v)
        if i % 1000 == 0 then task.wait() end
    end
end)

library:AddConnection(workspace.DescendantAdded:Connect(registerObject))

library:AddConnection(rs.Heartbeat:Connect(function(deltaTime)
    if not cullingActive or #trackedParts == 0 then return end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local camPos = cam.CFrame.Position
    local lookVec = cam.CFrame.LookVector
    
    local limit = math.min(currentIndex + BATCH_SIZE - 1, #trackedParts)
    local i = currentIndex

    while i <= limit do
        local data = trackedParts[i]
        local part = data.part

        if not part or (part.Parent == nil and not data.hidden) then
            trackedSet[part] = nil
            trackedParts[i] = trackedParts[#trackedParts]
            trackedParts[#trackedParts] = nil
            limit = math.min(limit, #trackedParts)
            continue 
        end

        if not data.hidden then
            data.lastPos = part.Position
        end

        local dx = data.lastPos.X - camPos.X
        local dy = data.lastPos.Y - camPos.Y
        local dz = data.lastPos.Z - camPos.Z
        local distSq = dx*dx + dy*dy + dz*dz

        local shouldShadow = data.origShadow and (distSq <= data.shadowDistSq)
        if part.CastShadow ~= shouldShadow then
            part.CastShadow = shouldShadow
        end

        local shouldHide = false
        
        if data.isDebris then
            local isBehind = (lookVec.X*dx + lookVec.Y*dy + lookVec.Z*dz) < 0
            shouldHide = (distSq > DEBRIS_HIDE_DIST_SQ) or (isBehind and distSq > 3600)
            
        elseif data.isDeco then
            local isBehind = false
            if distSq > 900 then 
                isBehind = (lookVec.X*dx + lookVec.Y*dy + lookVec.Z*dz) < 0
            end
            shouldHide = (distSq > DECO_HIDE_DIST_SQ) or (isBehind and distSq > 10000)
        end

        if shouldHide and not data.hidden then
            data.hidden = true
            part.Parent = nil 
        elseif not shouldHide and data.hidden then
            if data.origParent and data.origParent.Parent ~= nil then
                data.hidden = false
                part.Parent = data.origParent 
            else
                trackedSet[part] = nil
                trackedParts[i] = trackedParts[#trackedParts]
                trackedParts[#trackedParts] = nil
                limit = math.min(limit, #trackedParts)
                continue
            end
        end
        
        i = i + 1
    end

    currentIndex = limit + 1
    if currentIndex > #trackedParts then currentIndex = 1 end
end))

task.spawn(function()
    while task.wait(0.5) do
        if not vfxActive then continue end
        local cam = workspace.CurrentCamera
        if not cam then continue end
        local camPos = cam.Position

        for inst, data in pairs(vfxCache) do
            if not inst.Parent then continue end
            
            local pos = getBasePosition(inst) or camPos
            local dx, dy, dz = pos.X - camPos.X, pos.Y - camPos.Y, pos.Z - camPos.Z
            local distSq = dx*dx + dy*dy + dz*dz

            if data.Type == "Particle" then
                if distSq > 122500 then
                    inst.Rate = data.Rate * 0.05
                elseif distSq > 40000 then
                    inst.Rate = data.Rate * 0.2
                elseif distSq > 10000 then
                    inst.Rate = data.Rate * 0.6
                else
                    inst.Rate = data.Rate
                end
            elseif data.Type == "Smoke" then
                inst.Opacity = (distSq > 90000) and 0 or ((distSq > 22500) and (data.Opacity * 0.5) or data.Opacity)
            elseif data.Type == "Trail" then
                inst.Lifetime = (distSq > 40000) and 0 or data.Lifetime
            elseif data.Type == "Beam" then
                inst.Segments = (distSq > 40000) and math.max(1, math.floor(data.Segments * 0.2)) or data.Segments 
            elseif data.Type == "Light" then
                if distSq > 40000 then
                    inst.Shadows = false
                    inst.Range = 0
                elseif distSq > 10000 then
                    inst.Shadows = false
                    inst.Range = data.Range * 0.5
                elseif distSq > 2500 then
                    inst.Shadows = false
                    inst.Range = data.Range
                else
                    inst.Shadows = data.Shadows
                    inst.Range = data.Range
                end
            end
        end
    end
end)

local postFXCache = {}
local originalShadowSoftness = nil

local function togglePostProcessing(state)
    if state then
        originalShadowSoftness = originalShadowSoftness or lighting.ShadowSoftness
        lighting.ShadowSoftness = 0.2
        for _, v in ipairs(lighting:GetDescendants()) do
            if v:IsA("DepthOfFieldEffect") then
                if postFXCache[v] == nil then postFXCache[v] = v.Enabled end
                v.Enabled = false
            elseif v:IsA("SunRaysEffect") then
                if postFXCache[v] == nil then postFXCache[v] = v.Intensity end
                v.Intensity = postFXCache[v] * 0.4
            end
        end
    else
        if originalShadowSoftness then 
            lighting.ShadowSoftness = originalShadowSoftness 
            originalShadowSoftness = nil
        end
        for v, val in pairs(postFXCache) do
            if typeof(v) == "Instance" and v.Parent then
                if v:IsA("DepthOfFieldEffect") then v.Enabled = val
                elseif v:IsA("SunRaysEffect") then v.Intensity = val end
            end
        end
        postFXCache = {}
    end
end

visualsTab:AddToggle("Smart Spatial Culling", function(state)
    cullingActive = state
    if not state then
        for _, data in ipairs(trackedParts) do
            if data.part then
                if data.hidden and data.origParent and data.origParent.Parent ~= nil then 
                    data.part.Parent = data.origParent 
                    data.hidden = false
                end
                data.part.CastShadow = data.origShadow
            end
        end
    end
end)

visualsTab:AddToggle("Distance-Based VFX", function(state)
    vfxActive = state
    togglePostProcessing(state)
    
    if not state then
        for inst, data in pairs(vfxCache) do
            if inst and inst.Parent then
                if data.Type == "Particle" then inst.Rate = data.Rate
                elseif data.Type == "Smoke" then inst.Opacity = data.Opacity
                elseif data.Type == "Trail" then inst.Lifetime = data.Lifetime
                elseif data.Type == "Beam" then inst.Segments = data.Segments
                elseif data.Type == "Light" then inst.Shadows = data.Shadows; inst.Range = data.Range
                end
            end
        end
    end
end)
end
