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

    local cam = workspace.CurrentCamera

    library:AddConnection(rs.RenderStepped:Connect(function()
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
end
