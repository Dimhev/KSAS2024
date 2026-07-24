local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")
local stats = game:GetService("Stats")
local vu = game:GetService("VirtualUser")
local lighting = game:GetService("Lighting")

local lp = players.LocalPlayer
local parent = (gethui and gethui()) or (cg:FindFirstChild("RobloxGui") and cg) or lp:WaitForChild("PlayerGui")

for _, v in ipairs(parent:GetChildren()) do
    if v.Name == "ProjectHub" then v:Destroy() end
end
if gethui then
    for _, v in ipairs(gethui():GetChildren()) do
        if v.Name == "ProjectHub" then v:Destroy() end
    end
end

local fontRegular = Enum.Font.SourceSans
local fontBold    = Enum.Font.SourceSansBold

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do inst[i] = v end
    return inst
end

local gui = create("ScreenGui", {
    Name = "ProjectHub",
    ResetOnSpawn = false,
    Parent = parent
})

local _connections = {}
local function addConn(conn)
    table.insert(_connections, conn)
    return conn
end
gui.Destroying:Connect(function()
    for _, c in pairs(_connections) do
        if c.Disconnect then c:Disconnect() end
    end
end)

local mainFrame = create("Frame", {
    Size = UDim2.new(0, 560, 0, 400),
    Position = UDim2.new(0.5, -280, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = mainFrame })

local topBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(30, 30, 35),
    BorderSizePixel = 0,
    Parent = mainFrame
})

local accentLine = create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(115, 135, 255),
    BorderSizePixel = 0,
    Parent = topBar
})

create("TextLabel", {
    Size = UDim2.new(1, -104, 1, 0),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundTransparency = 1,
    Text = "Project Hub",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 15,
    Font = fontBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    Position = UDim2.new(1, -38, 0, 0),
    BackgroundTransparency = 1,
    Text = "X",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 18,
    Font = fontBold,
    Parent = topBar
})

local minBtn = create("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    Position = UDim2.new(1, -76, 0, 0),
    BackgroundTransparency = 1,
    Text = "—",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 16,
    Font = fontBold,
    Parent = topBar
})

local tabContainer = create("Frame", {
    Size = UDim2.new(0, 150, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(28, 28, 33),
    BorderSizePixel = 0,
    Parent = mainFrame
})
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabContainer })

local pageContainer = create("Frame", {
    Size = UDim2.new(1, -150, 1, -38),
    Position = UDim2.new(0, 150, 0, 38),
    BackgroundTransparency = 1,
    Parent = mainFrame
})

local dragging, dragInput, dragStart, startPos
addConn(topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end))
addConn(topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end))
addConn(uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

local isMinimized = false
addConn(minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 560, 0, isMinimized and 38 or 400)
    }):Play()
end))
addConn(closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end))
addConn(uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end))

addConn(closeBtn.MouseEnter:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end))
addConn(closeBtn.MouseLeave:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end))
addConn(minBtn.MouseEnter:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end))
addConn(minBtn.MouseLeave:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end))

local library = {
    themeColor = Color3.fromRGB(115, 135, 255),
    tabs = {},
    tabCount = 0,
    activeToggles = {},
    themeObjects = {}
}

function library:UpdateTheme(color)
    self.themeColor = color
    ts:Create(accentLine, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundColor3 = color}):Play()
    for _, tab in pairs(self.tabs) do
        if tab.page.Visible then
            ts:Create(tab.indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end
    end
    for indicator, state in pairs(self.activeToggles) do
        if state then ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for _, obj in pairs(self.themeObjects) do
        if obj:IsA("Frame") then
            ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end
    end
end

function library:CreateTab(name)
    self.tabCount = self.tabCount + 1
    local order = self.tabCount

    local tabBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(28, 28, 33),
        BorderSizePixel = 0,
        LayoutOrder = order,
        Text = "   " .. name,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        Font = fontRegular,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabContainer
    })
    
    local activeIndicator = create("Frame", {
        Size = UDim2.new(0, 3, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = library.themeColor,
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Parent = tabBtn
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = activeIndicator})

    local page = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65),
        Visible = false,
        Parent = pageContainer
    })

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12), 
        Parent = page
    })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = page
    })

    addConn(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end))

    addConn(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(library.tabs) do
            t.page.Visible = false
            ts:Create(t.btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(28, 28, 33)}):Play()
            t.btn.Font = fontRegular
            ts:Create(t.indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        end
        page.Visible = true
        ts:Create(tabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(35, 35, 42)}):Play()
        tabBtn.Font = fontBold
        ts:Create(activeIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    end))

    table.insert(library.tabs, {btn = tabBtn, page = page, indicator = activeIndicator})
    if #library.tabs == 1 then
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        tabBtn.Font = fontBold
        activeIndicator.BackgroundTransparency = 0
    end

    local elements = {page = page}

    function elements:AddButton(text, callback)
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Text = text,
            TextColor3 = Color3.fromRGB(220, 220, 220), Font = fontRegular, TextSize = 14, AutoButtonColor = false, Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        addConn(btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play() end))
        addConn(btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end))
        addConn(btn.MouseButton1Click:Connect(function()
            local tw = ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.97, 0, 0, 38)})
            tw:Play(); tw.Completed:Wait()
            ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 42)}):Play()
            if callback then callback() end
        end))
    end

    function elements:AddToggle(text, description, callback)
        if type(description) == "function" then callback = description; description = nil end
        local state = false
        local height = description and 56 or 46
        local toggleFrame = create("TextButton", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Text = "", AutoButtonColor = false, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleFrame})
        local titleY = description and 14 or (height / 2)
        create("TextLabel", {Size = UDim2.new(1, -70, 0, 14), Position = UDim2.new(0, 14, 0, titleY - 7), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = fontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame})
        if description then
            create("TextLabel", {Size = UDim2.new(1, -70, 0, 12), Position = UDim2.new(0, 14, 0, 32), BackgroundTransparency = 1, Text = description, TextColor3 = Color3.fromRGB(150, 150, 150), Font = fontRegular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame})
        end
        local indicatorBg = create("Frame", {Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -56, 0.5, -11), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = toggleFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})
        local indicator = create("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(100, 100, 100), Parent = indicatorBg})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        library.activeToggles[indicator] = state

        addConn(toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            library.activeToggles[indicator] = state
            ts:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = state and library.themeColor or Color3.fromRGB(100, 100, 100)
            }):Play()
            if callback then callback(state) end
        end))
    end

    function elements:AddSlider(text, min, max, default, callback)
        local val = math.clamp(default, min, max)
        local sliderFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFrame})
        create("TextLabel", {Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 14, 0, 6), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = fontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = sliderFrame})
        local valLabel = create("TextLabel", {Size = UDim2.new(0, 55, 0, 26), Position = UDim2.new(1, -69, 0, 6), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = Color3.fromRGB(200, 200, 200), Font = fontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, Parent = sliderFrame})
        local bgBar = create("TextButton", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 1, -16), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Text = "", AutoButtonColor = false, Parent = sliderFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bgBar})
        local fill = create("Frame", {Size = UDim2.new((val - min) / (max - min), 0, 1, 0), BackgroundColor3 = library.themeColor, Parent = bgBar})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
        table.insert(library.themeObjects, fill)

        local isDragging = false
        addConn(bgBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end))
        addConn(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end))
        addConn(uis.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pct)
                valLabel.Text = tostring(val)
                ts:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
                if callback then callback(val) end
            end
        end))
    end

    function elements:AddColorPicker(text, defaultColor, callback)
        local r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255
        local expanded = false
        local cpFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(35, 35, 40), ClipsDescendants = true, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpFrame})
        local cpBtn = create("TextButton", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Text = "   " .. text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = fontBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = cpFrame})
        local colorPreview = create("Frame", {Size = UDim2.new(0, 32, 0, 20), Position = UDim2.new(1, -44, 0, 11), BackgroundColor3 = defaultColor, Parent = cpFrame})
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})
        local sliderContainer = create("Frame", {Size = UDim2.new(1, -20, 0, 90), Position = UDim2.new(0, 10, 0, 49), BackgroundTransparency = 1, Parent = cpFrame})
        create("UIListLayout", {Padding = UDim.new(0, 8), Parent = sliderContainer})
        
        local function createRgbSlider(name, colorVal, barColor)
            local sFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = sliderContainer})
            create("TextLabel", {Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(200, 200, 200), Font = fontBold, TextSize = 13, Parent = sFrame})
            local sBar = create("TextButton", {Size = UDim2.new(1, -26, 0, 6), Position = UDim2.new(0, 26, 0.5, -3), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Text = "", AutoButtonColor = false, Parent = sFrame})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sBar})
            local sFill = create("Frame", {Size = UDim2.new(colorVal / 255, 0, 1, 0), BackgroundColor3 = barColor, Parent = sBar})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sFill})
            local dragging = false
            addConn(sBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end))
            addConn(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
            addConn(uis.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                    sFill.Size = UDim2.new(pct, 0, 1, 0)
                    local v = math.floor(pct * 255)
                    if name == "R" then r = v elseif name == "G" then g = v else b = v end
                    local nc = Color3.fromRGB(r, g, b)
                    colorPreview.BackgroundColor3 = nc
                    if callback then callback(nc) end
                end
            end))
        end
        createRgbSlider("R", r, Color3.fromRGB(255, 75, 75))
        createRgbSlider("G", g, Color3.fromRGB(75, 255, 75))
        createRgbSlider("B", b, Color3.fromRGB(75, 125, 255))
        addConn(cpBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, expanded and 150 or 42)}):Play()
        end))
    end

    function elements:AddSection(text)
        create("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(235, 235, 235), Font = fontBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
    end

    return elements
end

local homeTab     = library:CreateTab("Home")
local playerTab   = library:CreateTab("Player")
local visualsTab  = library:CreateTab("Visuals")
local settingsTab = library:CreateTab("Settings")

-- [[ Home Tab ]]
local pInfoFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 100), 
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    Parent = homeTab.page
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pInfoFrame })

local avatar = create("ImageLabel", {
    Size = UDim2.new(0, 80, 0, 80), 
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    Image = "", 
    Parent = pInfoFrame
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })

create("TextLabel", {
    Size = UDim2.new(1, -110, 0, 22),
    Position = UDim2.new(0, 100, 0, 20),
    BackgroundTransparency = 1,
    Text = "Hello, " .. lp.Name .. "!",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = fontBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})

local placeLabel = create("TextLabel", {
    Size = UDim2.new(1, -110, 0, 16),
    Position = UDim2.new(0, 100, 0, 48),
    BackgroundTransparency = 1,
    Text = "Loading...",
    TextColor3 = Color3.fromRGB(170, 170, 170),
    Font = fontRegular,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})

task.spawn(function()
    pcall(function()
        avatar.Image = players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    pcall(function()
        placeLabel.Text = mps:GetProductInfo(game.PlaceId).Name
    end)
end)

local statsContainer = create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    Parent = homeTab.page
})

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, 
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8), 
    Parent = statsContainer 
})

local function createStatBlock(text, isThemeColor)
    local block = create("Frame", {
        Size = UDim2.new(0.33, -5, 1, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        Parent = statsContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = block })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = isThemeColor and library.themeColor or Color3.fromRGB(220, 220, 220),
        Font = fontBold, 
        TextSize = 14,
        Parent = block
    })
    if isThemeColor then table.insert(library.themeObjects, label) end
    return label
end

local fpsLabel = createStatBlock("FPS: 0", true)
local pingLabel = createStatBlock("Ping: 0ms", false)
local timeLabel = createStatBlock("00:00", false)

local startTime = os.time()
local frames = 0

addConn(rs.RenderStepped:Connect(function() 
    frames += 1 
end))

task.spawn(function()
    while task.wait(1) do
        if not gui.Parent then break end 
        
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        
        local diff = os.time() - startTime
        timeLabel.Text = string.format("%02d:%02d", math.floor(diff / 60), diff % 60)
        
        pcall(function()
            local p = string.match(stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), "%d+")
            pingLabel.Text = "Ping: " .. (p or 0) .. "ms"
        end)
    end
end)

homeTab:AddSection("Modules")

homeTab:AddToggle("Anti-AFK", "Automatically prevents AFK disconnects", function(state)
    getgenv().AntiAfkEnabled = state
end)

addConn(lp.Idled:Connect(function()
    if getgenv().AntiAfkEnabled then
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end))

-- [[ Player Tab ]]
playerTab:AddSection("Movement")

local speedBoost = 0
local savedJumpPower = 50
local savedGravity  = 196
local smoothRate     = 8
local flyEnabled = false

local function applyMovementSettings(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.UseJumpPower = true
    humanoid.JumpPower = savedJumpPower
end

addConn(lp.CharacterAdded:Connect(applyMovementSettings))
if lp.Character then applyMovementSettings(lp.Character) end

addConn(rs.Heartbeat:Connect(function(dt)
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
    
    if speedBoost > 0 and humanoid.MoveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (humanoid.MoveDirection * (speedBoost * dt))
    end
end))

playerTab:AddSlider("Speed Boost", 0, 100, 0, function(val) speedBoost = val end)
playerTab:AddSlider("JumpPower", 50, 500, 50, function(val) savedJumpPower = val end)
playerTab:AddSlider("Gravity", 0, 400, 196, function(val) savedGravity = val end)

playerTab:AddSection("Camera")
playerTab:AddSlider("Field of View", 70, 120, 70, function(val)
    workspace.CurrentCamera.FieldOfView = val
end)

playerTab:AddSection("Abilities")

local infiniteJumpEnabled = false
addConn(uis.JumpRequest:Connect(function()
    if not infiniteJumpEnabled then return end
    local character = lp.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local currentState = humanoid:GetState()
    if currentState ~= Enum.HumanoidStateType.Seated and currentState ~= Enum.HumanoidStateType.Dead then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

playerTab:AddToggle("Infinite Jump", "Allows you to jump mid-air endlessly", function(state)
    infiniteJumpEnabled = state
end)

local noclipEnabled = false
local originalCanCollide = {}

addConn(rs.Stepped:Connect(function()
    if not noclipEnabled then return end
    local character = lp.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalCanCollide[part] == nil then
                originalCanCollide[part] = part.CanCollide
            end
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
addConn(lp.CharacterAdded:Connect(function() table.clear(originalCanCollide) end))


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

    toiletFlyConn = addConn(rs.Heartbeat:Connect(function()
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
    if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
end

addConn(lp.CharacterAdded:Connect(function(newChar)
    if flyEnabled then
        task.wait(0.5)
        startFly()
    end
end))

playerTab:AddToggle("Fly", "Use WASD + Space/Ctrl to move freely", function(state)
    flyEnabled = state
    if state then startFly() else stopFly() end
end)

playerTab:AddSlider("Fly Horizontal Speed", 10, 300, 18, function(val) flyHzSpeed = val end)
playerTab:AddSlider("Fly Vertical Speed", 10, 200, 30, function(val) flyVtSpeed = val end)

-- [[ Visuals Tab & ESP System ]]
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
        
        fbConnection = addConn(lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
            if fbEnabled then applyFullbright() end
        end))
    else
        if fbConnection then 
            fbConnection:Disconnect() 
            fbConnection = nil
        end
        for k, v in pairs(origLighting) do
            pcall(function() lighting[k] = v end)
        end
    end
end)

visualsTab:AddSection("Player ESP")

local espSettings = {
    enabled = false,
    boxes = false,
    names = false,
    health = false,
    distance = false,
    teamColor = false,
    maxDist = 1500,
    baseColor = Color3.fromRGB(255, 255, 255)
}

local espCache = {}

local function createEspDrawing(plr)
    if espCache[plr] then return end
    espCache[plr] = {
        boxOutline = Drawing.new("Square"),
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
        hpOutline = Drawing.new("Square"),
        hp = Drawing.new("Square")
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
addConn(players.PlayerAdded:Connect(createEspDrawing))
addConn(players.PlayerRemoving:Connect(removeEspDrawing))

addConn(gui.Destroying:Connect(function()
    for plr, _ in pairs(espCache) do removeEspDrawing(plr) end
end))

local cam = workspace.CurrentCamera

addConn(rs.RenderStepped:Connect(function()
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
            if espSettings.teamColor and plr.Team then
                renderColor = plr.TeamColor.Color
            end
            
            if espSettings.boxes then
                cache.boxOutline.Size = Vector2.new(w, h)
                cache.boxOutline.Position = Vector2.new(headPos.X - w/2, headPos.Y)
                cache.boxOutline.Visible = true
                
                cache.box.Size = Vector2.new(w, h)
                cache.box.Position = Vector2.new(headPos.X - w/2, headPos.Y)
                cache.box.Color = renderColor
                cache.box.Visible = true
            else
                cache.boxOutline.Visible = false
                cache.box.Visible = false
            end
            
            if espSettings.names then
                cache.name.Text = plr.DisplayName
                cache.name.Position = Vector2.new(headPos.X, headPos.Y - 16)
                cache.name.Color = renderColor
                cache.name.Visible = true
            else
                cache.name.Visible = false
            end
            
            if espSettings.distance then
                cache.dist.Text = math.floor(dist) .. "s"
                cache.dist.Position = Vector2.new(headPos.X, headPos.Y + h + 2)
                cache.dist.Color = renderColor
                cache.dist.Visible = true
            else
                cache.dist.Visible = false
            end
            
            if espSettings.health then
                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                cache.hpOutline.Size = Vector2.new(4, h + 2)
                cache.hpOutline.Position = Vector2.new(headPos.X - w/2 - 6, headPos.Y - 1)
                cache.hpOutline.Visible = true
                
                cache.hp.Size = Vector2.new(2, h * hpPercent)
                cache.hp.Position = Vector2.new(headPos.X - w/2 - 5, headPos.Y + (h - (h * hpPercent)))
                cache.hp.Color = Color3.fromHSV(hpPercent * 0.3, 1, 1)
                cache.hp.Visible = true
            else
                cache.hpOutline.Visible = false
                cache.hp.Visible = false
            end
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


-- [[ Settings Tab ]]
settingsTab:AddSection("UI Customization")
settingsTab:AddColorPicker("Theme Color", library.themeColor, function(color)
    library:UpdateTheme(color)
end)

return library
