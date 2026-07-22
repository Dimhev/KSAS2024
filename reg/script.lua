local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

local parent = (gethui and gethui()) or (cg:FindFirstChild("RobloxGui") and cg) or players.LocalPlayer:WaitForChild("PlayerGui")

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
    Size = UDim2.new(0, 480, 0, 320),
    Position = UDim2.new(0.5, -240, 0.5, -160),
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

local gradient = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
    }),
    Parent = accentLine
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
    Size = UDim2.new(0, 130, 1, -37),
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
    Size = UDim2.new(1, -130, 1, -37),
    Position = UDim2.new(0, 130, 0, 37),
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
    local targetY = isMinimized and 35 or 320
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 480, 0, targetY)}):Play()
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
    activeToggles = {}
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

    local elements = {}

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
        
        create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = btn
        })
        
        btn.MouseEnter:Connect(function()
            ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
        end)
        
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
        
        create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = toggleFrame
        })

        local indicatorBg = create("Frame", {
            Size = UDim2.new(0, 36, 0, 18),
            Position = UDim2.new(1, -46, 0.5, -9),
            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
            Parent = toggleFrame
        })
        
        create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = indicatorBg
        })

        local indicator = create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = indicatorBg
        })
        
        create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = indicator
        })
        
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

    function elements:AddSection(text)
        local section = create("TextLabel", {
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

return library
