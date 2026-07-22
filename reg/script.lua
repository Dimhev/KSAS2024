local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")
local stats = game:GetService("Stats")
local vu = game:GetService("VirtualUser")

local lp = players.LocalPlayer
local parent = (gethui and gethui()) or (cg:FindFirstChild("RobloxGui") and cg) or lp:WaitForChild("PlayerGui")

if parent:FindFirstChild("ProjectHub") then
    parent.ProjectHub:Destroy()
end

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do
        inst[i] = v
    end
    return inst
end

local gui = create("ScreenGui", {
    Name = "ProjectHub",
    ResetOnSpawn = false,
    Parent = parent
})

local mainFrame = create("Frame", {
    Size = UDim2.new(0, 520, 0, 360),
    Position = UDim2.new(0.5, -260, 0.5, -180),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})

create("UICorner", {
    CornerRadius = UDim.new(0, 6),
    Parent = mainFrame
})

local topBar = create("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
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

local title = create("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "Project Hub",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = topBar
})

local closeBtn = create("TextButton", {
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(1, -35, 0, 0),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 22,
    Font = Enum.Font.Gotham,
    Parent = topBar
})

local minBtn = create("TextButton", {
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(1, -70, 0, 0),
    BackgroundTransparency = 1,
    Text = "-",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 22,
    Font = Enum.Font.Gotham,
    Parent = topBar
})

local tabContainer = create("Frame", {
    Size = UDim2.new(0, 140, 1, -37),
    Position = UDim2.new(0, 0, 0, 37),
    BackgroundColor3 = Color3.fromRGB(28, 28, 33),
    BorderSizePixel = 0,
    Parent = mainFrame
})

create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = tabContainer
})

local pageContainer = create("Frame", {
    Size = UDim2.new(1, -140, 1, -37),
    Position = UDim2.new(0, 140, 0, 37),
    BackgroundTransparency = 1,
    Parent = mainFrame
})

local dragging, dragInput, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetY = isMinimized and 35 or 360
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, targetY)}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

closeBtn.MouseEnter:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end)
closeBtn.MouseLeave:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end)
minBtn.MouseEnter:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
minBtn.MouseLeave:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end)

local library = {
    themeColor = Color3.fromRGB(115, 135, 255),
    tabs = {},
    activeToggles = {},
    themeObjects = {}
}

function library:UpdateTheme(color)
    self.themeColor = color
    ts:Create(accentLine, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundColor3 = color}):Play()
    
    for _, tab in pairs(self.tabs) do
        if tab.page.Visible then
            ts:Create(tab.btn, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        end
    end
    
    for indicator, state in pairs(self.activeToggles) do
        if state then
            ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        end
    end
    
    for _, obj in pairs(self.themeObjects) do
        if obj:IsA("Frame") then
            ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        elseif obj:IsA("TextLabel") or obj:IsA("TextBox") then
            ts:Create(obj, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        end
    end
end

function library:CreateTab(name)
    local tabBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(28, 28, 33),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(170, 170, 170),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = tabContainer
    })

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
        Padding = UDim.new(0, 8),
        Parent = page
    })
    
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = page
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(library.tabs) do
            t.page.Visible = false
            ts:Create(t.btn, TweenInfo.new(0.3), {
                TextColor3 = Color3.fromRGB(170, 170, 170),
                BackgroundColor3 = Color3.fromRGB(28, 28, 33)
            }):Play()
        end
        page.Visible = true
        ts:Create(tabBtn, TweenInfo.new(0.3), {
            TextColor3 = library.themeColor,
            BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        }):Play()
    end)

    table.insert(library.tabs, {btn = tabBtn, page = page})
    
    if #library.tabs == 1 then
        page.Visible = true
        tabBtn.TextColor3 = library.themeColor
        tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    end

    local elements = {page = page}

    function elements:AddButton(text, callback)
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            AutoButtonColor = false,
            Parent = page
        })
        
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        
        btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play() end)
        btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end)
        
        btn.MouseButton1Click:Connect(function()
            local tw = ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.97, 0, 0, 34)})
            tw:Play()
            tw.Completed:Wait()
            ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            if callback then callback() end
        end)
    end

    function elements:AddToggle(text, callback)
        local state = false
        local toggleFrame = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = "   " .. text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            AutoButtonColor = false,
            Parent = page
        })
        
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleFrame})

        local indicatorBg = create("Frame", {
            Size = UDim2.new(0, 36, 0, 18),
            Position = UDim2.new(1, -46, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Parent = toggleFrame
        })
        
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})

        local indicator = create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = indicatorBg
        })
        
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        library.activeToggles[indicator] = state

        toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            library.activeToggles[indicator] = state
            local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            local targetColor = state and library.themeColor or Color3.fromRGB(100, 100, 100)
            
            ts:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = targetPos,
                BackgroundColor3 = targetColor
            }):Play()
            if callback then callback(state) end
        end)
    end

    function elements:AddSlider(text, min, max, default, callback)
        local val = math.clamp(default, min, max)
        
        local sliderFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 55),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFrame})

        local title = create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sliderFrame
        })

        local valLabel = create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 25),
            Position = UDim2.new(1, -60, 0, 5),
            BackgroundTransparency = 1,
            Text = tostring(val),
            TextColor3 = library.themeColor,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = sliderFrame
        })
        table.insert(library.themeObjects, valLabel)

        local bgBar = create("TextButton", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 1, -15),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Text = "",
            AutoButtonColor = false,
            Parent = sliderFrame
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bgBar})

        local fill = create("Frame", {
            Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = library.themeColor,
            Parent = bgBar
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
        table.insert(library.themeObjects, fill)

        local isDragging = false
        bgBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
            end
        end)
        
        uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)

        uis.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                val = math.floor(min + ((max - min) * pct))
                valLabel.Text = tostring(val)
                ts:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
                if callback then callback(val) end
            end
        end)
    end

    function elements:AddColorPicker(text, defaultColor, callback)
        local r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255
        local expanded = false

        local cpFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            ClipsDescendants = true,
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpFrame})

        local cpBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1,
            Text = "   " .. text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = cpFrame
        })

        local colorPreview = create("Frame", {
            Size = UDim2.new(0, 30, 0, 18),
            Position = UDim2.new(1, -40, 0, 10),
            BackgroundColor3 = defaultColor,
            Parent = cpFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})

        local sliderContainer = create("Frame", {
            Size = UDim2.new(1, -20, 0, 90),
            Position = UDim2.new(0, 10, 0, 45),
            BackgroundTransparency = 1,
            Parent = cpFrame
        })
        create("UIListLayout", {Padding = UDim.new(0, 8), Parent = sliderContainer})

        local function createRgbSlider(name, colorVal, barColor)
            local sFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = sliderContainer})
            local lName = create("TextLabel", {Size = UDim2.new(0, 15, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, TextSize = 12, Parent = sFrame})
            local sBar = create("TextButton", {Size = UDim2.new(1, -25, 0, 6), Position = UDim2.new(0, 25, 0.5, -3), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Text = "", AutoButtonColor = false, Parent = sFrame})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sBar})
            local sFill = create("Frame", {Size = UDim2.new(colorVal / 255, 0, 1, 0), BackgroundColor3 = barColor, Parent = sBar})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sFill})

            local dragging = false
            sBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            
            uis.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                    sFill.Size = UDim2.new(pct, 0, 1, 0)
                    local v = math.floor(pct * 255)
                    if name == "R" then r = v elseif name == "G" then g = v else b = v end
                    local nc = Color3.fromRGB(r, g, b)
                    colorPreview.BackgroundColor3 = nc
                    if callback then callback(nc) end
                end
            end)
        end

        createRgbSlider("R", r, Color3.fromRGB(255, 75, 75))
        createRgbSlider("G", g, Color3.fromRGB(75, 255, 75))
        createRgbSlider("B", b, Color3.fromRGB(75, 125, 255))

        cpBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, expanded and 145 or 38)}):Play()
        end)
    end

    function elements:AddSection(text)
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = page
        })
    end

    return elements
end

local homeTab = library:CreateTab("Home")
local playerTab = library:CreateTab("Player")
local settingsTab = library:CreateTab("Settings")

local pInfoFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    Parent = homeTab.page
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = pInfoFrame})

local avatar = create("ImageLabel", {
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    Image = players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
    Parent = pInfoFrame
})
create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = avatar})

local greetLabel = create("TextLabel", {
    Size = UDim2.new(1, -90, 0, 20),
    Position = UDim2.new(0, 80, 0, 15),
    BackgroundTransparency = 1,
    Text = "Hello, " .. lp.Name .. "!",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})

local placeLabel = create("TextLabel", {
    Size = UDim2.new(1, -90, 0, 15),
    Position = UDim2.new(0, 80, 0, 40),
    BackgroundTransparency = 1,
    Text = "Loading...",
    TextColor3 = Color3.fromRGB(170, 170, 170),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})

task.spawn(function()
    pcall(function()
        placeLabel.Text = mps:GetProductInfo(game.PlaceId).Name
    end)
end)

local statsFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    Parent = homeTab.page
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = statsFrame})

local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0.33, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "FPS: 0",
    TextColor3 = library.themeColor,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = statsFrame
})
table.insert(library.themeObjects, fpsLabel)

local pingLabel = create("TextLabel", {
    Size = UDim2.new(0.33, 0, 1, 0),
    Position = UDim2.new(0.33, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "Ping: 0ms",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = statsFrame
})

local timeLabel = create("TextLabel", {
    Size = UDim2.new(0.34, 0, 1, 0),
    Position = UDim2.new(0.66, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "00:00",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = statsFrame
})

local startTime = os.time()
local frames = 0
rs.RenderStepped:Connect(function()
    frames = frames + 1
end)

task.spawn(function()
    while task.wait(1) do
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
homeTab:AddToggle("Anti-AFK", function(state)
    getgenv().AntiAfkEnabled = state
end)

lp.Idled:Connect(function()
    if getgenv().AntiAfkEnabled then
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

playerTab:AddSection("Movement")
playerTab:AddSlider("WalkSpeed", 16, 250, 16, function(val)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = val
    end
end)

playerTab:AddSlider("JumpPower", 50, 500, 50, function(val)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.UseJumpPower = true
        lp.Character.Humanoid.JumpPower = val
    end
end)

playerTab:AddSection("Camera")
playerTab:AddSlider("Field of View", 70, 120, 70, function(val)
    workspace.CurrentCamera.FieldOfView = val
end)

settingsTab:AddSection("UI Customization")
settingsTab:AddColorPicker("Theme Color", library.themeColor, function(color)
    library:UpdateTheme(color)
end)

return Library
