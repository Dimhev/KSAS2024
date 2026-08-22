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

local DECO_HIDE_DIST_SQ = 450 * 450
local BATCH_SIZE = 300
local VFX_BATCH_SIZE = 150

local trackedParts = {}
local trackedPartsSet = setmetatable({}, { __mode = "k" })

local trackedVFX = {}
local trackedVFXSet = setmetatable({}, { __mode = "k" })

local currentPartIndex = 1
local currentVFXIndex = 1

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
    if inst:IsA("BasePart") then
        if trackedPartsSet[inst] then return end

        local model = inst:FindFirstAncestorOfClass("Model")
        if model then
            if model:FindFirstChildOfClass("Humanoid") then return end
            if model:FindFirstChildOfClass("VehicleSeat") or model:FindFirstChildOfClass("Seat") then return end
        end
        if inst:FindFirstAncestorOfClass("Tool") then return end 

        if inst.Material == Enum.Material.Water or inst.Material == Enum.Material.ForceField then return end
        local nameLower = inst.Name:lower()
        if nameLower:find("water") or nameLower:find("ocean") or nameLower:find("sea") or nameLower:find("lake") or nameLower:find("river") then
            return 
        end

        if inst.Transparency >= 1 and #inst:GetChildren() == 0 then return end

        local realSize = inst.Size
        local mesh = inst:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            realSize = Vector3.new(
                inst.Size.X * math.abs(mesh.Scale.X),
                inst.Size.Y * math.abs(mesh.Scale.Y),
                inst.Size.Z * math.abs(mesh.Scale.Z)
            )
        end

        local maxDimension = math.max(realSize.X, realSize.Y, realSize.Z)
        local sizeMag = realSize.Magnitude

        local isDeco = (inst.Anchored and not inst.CanCollide and maxDimension < 15)

        local shadowDist
        if sizeMag > 50 then
            shadowDist = 280
        elseif sizeMag > 20 then
            shadowDist = 180
        elseif sizeMag > 10 then
            shadowDist = 120
        else
            shadowDist = 75
        end

        trackedPartsSet[inst] = true
        table.insert(trackedParts, {
            part = inst,
            origParent = inst.Parent,
            origShadow = inst.CastShadow,
            shadowDistSq = shadowDist * shadowDist,
            isDeco = isDeco,
            hidden = false,
            lastPos = inst.Position
        })
    end

    if inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Light") then
        if trackedVFXSet[inst] then return end
        
        local vfxData = { inst = inst }
        if inst:IsA("ParticleEmitter") then 
            vfxData.Type = "Particle"; vfxData.Rate = inst.Rate 
        elseif inst:IsA("Smoke") then 
            vfxData.Type = "Smoke"; vfxData.Opacity = inst.Opacity 
        elseif inst:IsA("Trail") then 
            vfxData.Type = "Trail"; vfxData.Lifetime = inst.Lifetime 
        elseif inst:IsA("Beam") then 
            vfxData.Type = "Beam"; vfxData.Segments = inst.Segments 
        elseif inst:IsA("Light") then 
            vfxData.Type = "Light"; vfxData.Shadows = inst.Shadows; vfxData.Range = inst.Range 
        end

        trackedVFXSet[inst] = vfxData
        table.insert(trackedVFX, vfxData)
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
    
    local total = #trackedParts
    local limit = math.min(currentPartIndex + BATCH_SIZE - 1, total)
    local i = currentPartIndex

    while i <= limit do
        local data = trackedParts[i]
        local part = data.part

        if not part or not part:IsDescendantOf(game) then
            trackedPartsSet[part] = nil
            trackedParts[i] = trackedParts[#trackedParts]
            trackedParts[#trackedParts] = nil
            total = #trackedParts
            limit = math.min(limit, total)
            continue 
        end

        if not data.hidden then
            data.lastPos = part.Position
        end

        local dx = data.lastPos.X - camPos.X
        local dy = data.lastPos.Y - camPos.Y
        local dz = data.lastPos.Z - camPos.Z
        local distSq = dx*dx + dy*dy + dz*dz

        local shouldHide = false
        if data.isDeco then
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
            if data.origParent and data.origParent:IsDescendantOf(game) then
                data.hidden = false
                part.Parent = data.origParent 
            else
                trackedPartsSet[part] = nil
                trackedParts[i] = trackedParts[#trackedParts]
                trackedParts[#trackedParts] = nil
                total = #trackedParts
                limit = math.min(limit, total)
                continue
            end
        end

        if not data.hidden then
            local shouldShadow = data.origShadow and (distSq <= data.shadowDistSq)
            if part.CastShadow ~= shouldShadow then
                part.CastShadow = shouldShadow
            end
        end
        
        i = i + 1
    end

    currentPartIndex = limit + 1
    if currentPartIndex > #trackedParts then currentPartIndex = 1 end
end))

library:AddConnection(rs.Heartbeat:Connect(function()
    if not vfxActive or #trackedVFX == 0 then return end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position

    local total = #trackedVFX
    local limit = math.min(currentVFXIndex + VFX_BATCH_SIZE - 1, total)
    local i = currentVFXIndex

    while i <= limit do
        local data = trackedVFX[i]
        local inst = data.inst

        if not inst or not inst:IsDescendantOf(workspace) then
            if not inst or not inst:IsDescendantOf(game) then
                trackedVFXSet[inst] = nil
                trackedVFX[i] = trackedVFX[#trackedVFX]
                trackedVFX[#trackedVFX] = nil
                total = #trackedVFX
                limit = math.min(limit, total)
                continue
            end
            i = i + 1
            continue
        end

        local pos = getBasePosition(inst) or camPos
        local dx = pos.X - camPos.X
        local dy = pos.Y - camPos.Y
        local dz = pos.Z - camPos.Z
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
            if distSq > 40000 then
                inst.Lifetime = 0
            elseif distSq > 22500 then 
                inst.Lifetime = data.Lifetime * 0.25
            elseif distSq > 10000 then
                inst.Lifetime = data.Lifetime * 0.6
            else
                inst.Lifetime = data.Lifetime
            end
        elseif data.Type == "Beam" then
            inst.Segments = (distSq > 40000) and math.max(2, math.floor(data.Segments * 0.4)) or data.Segments 
        elseif data.Type == "Light" then
            if distSq > 62500 then
                inst.Shadows = false
                inst.Range = (data.Range > 30) and (data.Range * 0.25) or 0
            elseif distSq > 14400 then
                inst.Shadows = false
                inst.Range = data.Range * 0.5
            elseif distSq > 3600 then
                inst.Shadows = false
                inst.Range = data.Range
            else
                inst.Shadows = data.Shadows
                inst.Range = data.Range
            end
        end

        i = i + 1
    end

    currentVFXIndex = limit + 1
    if currentVFXIndex > #trackedVFX then currentVFXIndex = 1 end
end))

local postFXCache = {}
local function togglePostProcessing(state)
    if state then
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
                if data.hidden and data.origParent and data.origParent:IsDescendantOf(game) then 
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
        for _, data in ipairs(trackedVFX) do
            local inst = data.inst
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
end
