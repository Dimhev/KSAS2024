local players = game:GetService("Players")
local rs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")
local stats = game:GetService("Stats")
local vu = game:GetService("VirtualUser")
local tps = game:GetService("TeleportService")
local http = game:GetService("HttpService")
local lp = players.LocalPlayer

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do inst[i] = v end
    return inst
end

local repo = "https://raw.githubusercontent.com/Dimhev/KSAS2024/refs/heads/main/reg/"

local UiLibrary = loadstring(game:HttpGet(repo .. "UiLibrary.lua"))()
local PlayerModule = loadstring(game:HttpGet(repo .. "PlayerModule.lua"))()
local VisualsModule = loadstring(game:HttpGet(repo .. "VisualsModule.lua"))()

local homeTab     = UiLibrary:CreateTab("Home")
local playerTab   = UiLibrary:CreateTab("Player")
local visualsTab  = UiLibrary:CreateTab("Visuals")
local settingsTab = UiLibrary:CreateTab("Settings")

local pInfoFrame = create("Frame", { Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Parent = homeTab.page })
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pInfoFrame })

local avatar = create("ImageLabel", { Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Image = "", Parent = pInfoFrame })
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })
create("TextLabel", { Size = UDim2.new(1, -110, 0, 22), Position = UDim2.new(0, 100, 0, 20), BackgroundTransparency = 1, Text = "Hello, " .. lp.Name .. "!", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.SourceSansBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = pInfoFrame })
local placeLabel = create("TextLabel", { Size = UDim2.new(1, -110, 0, 16), Position = UDim2.new(0, 100, 0, 48), BackgroundTransparency = 1, Text = "Loading...", TextColor3 = Color3.fromRGB(170, 170, 170), Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = pInfoFrame })

task.spawn(function()
    pcall(function() avatar.Image = players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
    pcall(function() placeLabel.Text = mps:GetProductInfo(game.PlaceId).Name end)
end)

local statsContainer = create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Parent = homeTab.page })
create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = statsContainer })

local function createStatBlock(text, isThemeColor)
    local block = create("Frame", { Size = UDim2.new(0.33, -5, 1, 0), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Parent = statsContainer })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = block })
    local label = create("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = isThemeColor and UiLibrary.theme.accent or Color3.fromRGB(220, 220, 220), Font = Enum.Font.SourceSansBold, TextSize = 14, Parent = block })
    if isThemeColor and UiLibrary.themeObjects and UiLibrary.themeObjects.accent then 
        table.insert(UiLibrary.themeObjects.accent, label) 
    end
    return label
end

local fpsLabel = createStatBlock("FPS: 0", true)
local pingLabel = createStatBlock("Ping: 0ms", false)
local timeLabel = createStatBlock("00:00", false)

local startTime = os.time()
local lastUpdate = os.clock()
local frames = 0

UiLibrary:AddConnection(rs.RenderStepped:Connect(function()
    frames += 1
    local now = os.clock()
    
    if now - lastUpdate >= 1 then
        if not (UiLibrary.Gui and UiLibrary.Gui.Parent) then return end 
        
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        lastUpdate = now
        
        local diff = os.time() - startTime
        timeLabel.Text = string.format("%02d:%02d", math.floor(diff / 60), diff % 60)
        
        pcall(function()
            local ping = math.round(lp:GetNetworkPing() * 1000)
            if ping == 0 then
                ping = math.round(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end
            pingLabel.Text = "Ping: " .. ping .. "ms"
        end)
    end
end))

getgenv().AntiAfkEnabled = false
homeTab:AddSection("Modules")
homeTab:AddToggle("Anti-AFK", "Automatically prevents AFK disconnects", function(state) getgenv().AntiAfkEnabled = state end)

UiLibrary:AddConnection(lp.Idled:Connect(function()
    if getgenv().AntiAfkEnabled then
        local cam = workspace.CurrentCamera
        if cam then
            vu:Button2Down(Vector2.new(0, 0), cam.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), cam.CFrame)
        end
    end
end))

homeTab:AddSection("Server Options")

homeTab:AddButton("Rejoin Server", function()
    UiLibrary:Notify("Rejoin", "Rejoining current server...", 3)
    tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end)

homeTab:AddButton("Server Hop", function()
    local fileName = "ProjectHub_HopLog.json"
    local visited = {}
    
    if isfile and isfile(fileName) then
        pcall(function()
            visited = http:JSONDecode(readfile(fileName))
        end)
    end
    
    visited[game.JobId] = true
    if writefile then
        pcall(function() writefile(fileName, http:JSONEncode(visited)) end)
    end

    UiLibrary:Notify("Server Hop", "Searching for a new server...", 5)

    local cursor = ""
    local found = false
    
    while not found do
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        
        local req = request or http_request or (syn and syn.request)
        local res = req and req({Url = url, Method = "GET"}) or {Body = game:HttpGet(url)}
        
        if res and res.Body then
            local success, body = pcall(function() return http:JSONDecode(res.Body) end)
            if success and body and body.data then
                for _, server in pairs(body.data) do
                    if type(server) == "table" and server.id and server.playing and server.maxPlayers then
                        if server.playing < server.maxPlayers and not visited[server.id] and server.id ~= game.JobId then
                            found = true
                            UiLibrary:Notify("Server Hop", "Teleporting...", 3)
                            tps:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
                            return
                        end
                    end
                end
                cursor = body.nextPageCursor
                if not cursor then break end 
            else
                break
            end
        else
            break
        end
    end
    
    if not found then
        UiLibrary:Notify("Error", "No new servers found. Resetting history.", 3)
        if writefile then pcall(function() writefile(fileName, "{}") end) end
    end
end)

PlayerModule(playerTab, UiLibrary)
VisualsModule(visualsTab, UiLibrary)

settingsTab:AddSection("UI Customization")

settingsTab:AddColorPicker("Accent Color", UiLibrary.theme.accent, function(color)
    UiLibrary:SetAccentColor(color)
end)

settingsTab:AddColorPicker("Background Color", UiLibrary.theme.mainBg, function(color)
    UiLibrary:SetMainColor(color)
end)

settingsTab:AddColorPicker("Element Color", UiLibrary.theme.elementBg, function(color)
    UiLibrary:SetElementColor(color)
end)

settingsTab:AddToggle("Sync Mode", "Color synchronization with the clock time", function(state)
    UiLibrary:SetSyncMode(state)
end)

settingsTab:AddButton("Send Test Notification", function()
    UiLibrary:Notify("Project Hub", "Settings applied successfully!", 3)
end)
