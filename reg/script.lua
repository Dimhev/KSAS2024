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
    Text = "×",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 24,
    Font = fontRegular,
    Parent = topBar
})

local minBtn = create("TextButton", {
    Size = UDim2.new(0, 38, 0, 38),
    Position = UDim2.new(1, -76, 0, 0),
    BackgroundTransparency = 1,
    Text = "-",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = 24,
    Font = fontRegular,
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
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
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
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 560, 0, isMinimized and 38 or 400)
    }):Play()
end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
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
    tabCount = 0,
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
        if state then ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
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
    self.tabCount = self.tabCount + 1
    local order = self.tabCount

    local tabBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(28, 28, 33),
        BorderSizePixel = 0,
        LayoutOrder = order,
        Text = name,
        TextColor3 = Color3.fromRGB(170, 170, 170),
        Font = fontRegular,
        TextSize = 14,
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
        Padding = UDim.new(0, 10),
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
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = fontRegular,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play() end)
        btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end)
        btn.MouseButton1Click:Connect(function()
            local tw = ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.97, 0, 0, 38)})
            tw:Play(); tw.Completed:Wait()
            ts:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 42)}):Play()
            if callback then callback() end
        end)
    end

    function elements:AddToggle(text, callback)
        local state = false
        local toggleFrame = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Text = "   " .. text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = fontRegular,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleFrame})

        local indicatorBg = create("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Parent = toggleFrame
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})

        local indicator = create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = indicatorBg
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        library.activeToggles[indicator] = state

        toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            library.activeToggles[indicator] = state
            ts:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = state and library.themeColor or Color3.fromRGB(100, 100, 100)
            }):Play()
            if callback then callback(state) end
        end)
    end

    function elements:AddSlider(text, min, max, default, callback)
        local val = math.clamp(default, min, max)
        local sliderFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFrame})

        create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 26),
            Position = UDim2.new(0, 10, 0, 6),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = fontRegular,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sliderFrame
        })

        local valLabel = create("TextLabel", {
            Size = UDim2.new(0, 55, 0, 26),
            Position = UDim2.new(1, -65, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(val),
            TextColor3 = library.themeColor,
            Font = fontBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = sliderFrame
        })
        table.insert(library.themeObjects, valLabel)

        local bgBar = create("TextButton", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 1, -16),
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
        end)
        uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
        end)
        uis.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pct)
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
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Color3.fromRGB(35, 35, 40),
            ClipsDescendants = true,
            Parent = page
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpFrame})
        local cpBtn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            Text = "   " .. text,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = fontRegular,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = cpFrame
        })
        local colorPreview = create("Frame", {
            Size = UDim2.new(0, 32, 0, 20),
            Position = UDim2.new(1, -44, 0, 11),
            BackgroundColor3 = defaultColor,
            Parent = cpFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})
        local sliderContainer = create("Frame", {
            Size = UDim2.new(1, -20, 0, 90),
            Position = UDim2.new(0, 10, 0, 49),
            BackgroundTransparency = 1,
            Parent = cpFrame
        })
        create("UIListLayout", {Padding = UDim.new(0, 8), Parent = sliderContainer})
        local function createRgbSlider(name, colorVal, barColor)
            local sFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Parent = sliderContainer})
            create("TextLabel", {Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(200, 200, 200), Font = fontBold, TextSize = 13, Parent = sFrame})
            local sBar = create("TextButton", {Size = UDim2.new(1, -26, 0, 6), Position = UDim2.new(0, 26, 0.5, -3), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Text = "", AutoButtonColor = false, Parent = sFrame})
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
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, expanded and 150 or 42)}):Play()
        end)
    end

    function elements:AddSection(text)
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Font = fontBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = page
        })
    end

    return elements
end

local mainTab     = library:CreateTab("Main")
local homeTab     = library:CreateTab("Home")
local playerTab   = library:CreateTab("Player")
local settingsTab = library:CreateTab("Settings")

-- [[ Main Tab ]]
-- вкладка пока пустая, здесь будет основная логика проекта
-- место под модули: teleport, esp-список, статус читов и т.п.

-- [[ Home Tab ]]
local pInfoFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 92),
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    Parent = homeTab.page
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = pInfoFrame})

local avatar = create("ImageLabel", {
    Size = UDim2.new(0, 72, 0, 72),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    Image = players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420),
    Parent = pInfoFrame
})
create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = avatar})

create("TextLabel", {
    Size = UDim2.new(1, -100, 0, 22),
    Position = UDim2.new(0, 92, 0, 16),
    BackgroundTransparency = 1,
    Text = "Hello, " .. lp.Name .. "!",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = fontBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})

local placeLabel = create("TextLabel", {
    Size = UDim2.new(1, -100, 0, 16),
    Position = UDim2.new(0, 92, 0, 44),
    BackgroundTransparency = 1,
    Text = "Loading...",
    TextColor3 = Color3.fromRGB(170, 170, 170),
    Font = fontRegular,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pInfoFrame
})
task.spawn(function()
    pcall(function() placeLabel.Text = mps:GetProductInfo(game.PlaceId).Name end)
end)

local statsFrame = create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Color3.fromRGB(35, 35, 40),
    Parent = homeTab.page
})
create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = statsFrame})

local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0.33, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "FPS: 0",
    TextColor3 = library.themeColor,
    Font = fontBold, TextSize = 14,
    Parent = statsFrame
})
table.insert(library.themeObjects, fpsLabel)

local pingLabel = create("TextLabel", {
    Size = UDim2.new(0.33, 0, 1, 0),
    Position = UDim2.new(0.33, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "Ping: 0ms",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = fontBold, TextSize = 14,
    Parent = statsFrame
})

local timeLabel = create("TextLabel", {
    Size = UDim2.new(0.34, 0, 1, 0),
    Position = UDim2.new(0.66, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "00:00",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = fontBold, TextSize = 14,
    Parent = statsFrame
})

local startTime = os.time()
local frames = 0
rs.RenderStepped:Connect(function() frames += 1 end)
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

-- [[ Player Tab ]]
playerTab:AddSection("Movement")

local savedWalkSpeed = 16
local savedJumpPower = 50
local savedGravity   = 196
local smoothRate     = 8

local function applyMovementSettings(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.WalkSpeed = savedWalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = savedJumpPower
end

lp.CharacterAdded:Connect(applyMovementSettings)
if lp.Character then applyMovementSettings(lp.Character) end

rs.Heartbeat:Connect(function(dt)
    local alpha = math.clamp(dt * smoothRate, 0, 1)

    if math.abs(workspace.Gravity - savedGravity) > 0.05 then
        workspace.Gravity = workspace.Gravity + (savedGravity - workspace.Gravity) * alpha
    end

    local character = lp.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end

    if math.abs(humanoid.WalkSpeed - savedWalkSpeed) > 0.05 then
        humanoid.WalkSpeed = humanoid.WalkSpeed + (savedWalkSpeed - humanoid.WalkSpeed) * alpha
    end
    if math.abs(humanoid.JumpPower - savedJumpPower) > 0.05 then
        humanoid.JumpPower = humanoid.JumpPower + (savedJumpPower - humanoid.JumpPower) * alpha
    end
end)

playerTab:AddSlider("WalkSpeed", 16, 250, 16, function(val) savedWalkSpeed = val end)
playerTab:AddSlider("JumpPower", 50, 500, 50, function(val) savedJumpPower = val end)
playerTab:AddSlider("Gravity", 0, 400, 196, function(val) savedGravity = val end)

playerTab:AddSection("Camera")
playerTab:AddSlider("Field of View", 70, 120, 70, function(val)
    workspace.CurrentCamera.FieldOfView = val
end)

playerTab:AddSection("Abilities")

local infiniteJumpEnabled = false
uis.JumpRequest:Connect(function()
    if not infiniteJumpEnabled then return end
    local character = lp.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

playerTab:AddToggle("Infinite Jump", function(state)
    infiniteJumpEnabled = state
end)

local noclipEnabled = false
rs.Stepped:Connect(function()
    if not noclipEnabled then return end
    local character = lp.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

playerTab:AddToggle("Noclip", function(state)
    noclipEnabled = state
    if not state then
        local character = lp.Character
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

local flyEnabled  = false
local flyVelocity = nil
local flyGyro     = nil
local flySpeed    = 60

local function startFly()
    local character = lp.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(9e8, 9e8, 9e8)
    flyGyro.P = 9e4
    flyGyro.CFrame = workspace.CurrentCamera.CFrame
    flyGyro.Parent = hrp

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.MaxForce = Vector3.new(9e8, 9e8, 9e8)
    flyVelocity.Parent = hrp

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Physics) end
end

local function stopFly()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyGyro     then flyGyro:Destroy();     flyGyro     = nil end
    local character = lp.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

rs.RenderStepped:Connect(function()
    if not flyEnabled or not flyVelocity or not flyGyro then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if uis:IsKeyDown(Enum.KeyCode.W)            then dir += cam.CFrame.LookVector  end
    if uis:IsKeyDown(Enum.KeyCode.S)            then dir -= cam.CFrame.LookVector  end
    if uis:IsKeyDown(Enum.KeyCode.A)            then dir -= cam.CFrame.RightVector end
    if uis:IsKeyDown(Enum.KeyCode.D)            then dir += cam.CFrame.RightVector end
    if uis:IsKeyDown(Enum.KeyCode.Space)        then dir += Vector3.yAxis          end
    if uis:IsKeyDown(Enum.KeyCode.LeftControl)  then dir -= Vector3.yAxis          end
    flyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
    flyGyro.CFrame = cam.CFrame
end)

lp.CharacterAdded:Connect(function()
    if flyEnabled then
        task.wait(0.5)
        startFly()
    end
end)

playerTab:AddToggle("Fly  (WASD + Space / Ctrl)", function(state)
    flyEnabled = state
    if state then startFly() else stopFly() end
end)

settingsTab:AddSection("UI Customization")
settingsTab:AddColorPicker("Theme Color", library.themeColor, function(color)
    library:UpdateTheme(color)
end)

return library
