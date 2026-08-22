local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

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

local fontRegular = Enum.Font.GothamMedium
local fontBold    = Enum.Font.GothamBold

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do inst[i] = v end
    return inst
end

local function applyUniversalGradient(parentObj, rotation, intensity)
    intensity = intensity or 0.25
    local grad = create("UIGradient", {
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, intensity)
        }),
        Parent = parentObj
    })
    return grad
end

local function applyStroke(parentObj, color, transparency)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Transparency = transparency or 0.9,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parentObj
    })
end

local gui = create("ScreenGui", { Name = "ProjectHub", ResetOnSpawn = false, Parent = parent })

local library = {
    theme = {
        accent = Color3.fromRGB(115, 135, 255),
        mainBg = Color3.fromRGB(22, 22, 26),
        topBar = Color3.fromRGB(28, 28, 33),
        tabBg  = Color3.fromRGB(24, 24, 28),
        elementBg = Color3.fromRGB(32, 32, 38),
        innerBg   = Color3.fromRGB(18, 18, 22),
        text = Color3.fromRGB(240, 240, 240),
        subText = Color3.fromRGB(150, 150, 150)
    },
    tabs = {},
    tabCount = 0,
    activeToggles = {},
    themeObjects = {
        accent = {},
        mainBg = {},
        elementBg = {}
    },
    _connections = {},
    Gui = gui
}

function library:AddConnection(conn)
    table.insert(self._connections, conn)
    return conn
end

gui.Destroying:Connect(function()
    for _, c in pairs(library._connections) do
        if c.Disconnect then c:Disconnect() end
    end
end)

local notifyContainer = create("Frame", {
    Size = UDim2.new(0, 260, 1, -20),
    Position = UDim2.new(1, -270, 0, 10),
    BackgroundTransparency = 1,
    Parent = gui
})
local notifyLayout = create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 8),
    Parent = notifyContainer
})

function library:Notify(title, desc, duration)
    duration = duration or 3
    local nFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.theme.elementBg,
        ClipsDescendants = true,
        Parent = notifyContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = nFrame })
    applyStroke(nFrame, self.theme.accent, 0.6)
    applyUniversalGradient(nFrame, 45, 0.2)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.theme.text,
        Font = fontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1,
        Text = desc or "",
        TextColor3 = self.theme.subText,
        Font = fontRegular,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    ts:Create(nFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 52) }):Play()
    
    task.delay(duration, function()
        local tw = ts:Create(nFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) })
        tw:Play()
        tw.Completed:Connect(function() nFrame:Destroy() end)
    end)
end

local mainFrame = create("Frame", {
    Size = UDim2.new(0, 580, 0, 420),
    Position = UDim2.new(0.5, -290, 0.5, -210),
    BackgroundColor3 = library.theme.mainBg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })
applyStroke(mainFrame, Color3.fromRGB(255, 255, 255), 0.88)
applyUniversalGradient(mainFrame, 135, 0.15)
table.insert(library.themeObjects.mainBg, mainFrame)

local topBar = create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = library.theme.topBar, BorderSizePixel = 0, Parent = mainFrame })
applyUniversalGradient(topBar, 90, 0.1)

local accentLine = create("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = library.theme.accent, BorderSizePixel = 0, Parent = topBar })
applyUniversalGradient(accentLine, 0, 0.3)

create("TextLabel", { Size = UDim2.new(1, -104, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "Project Hub", TextColor3 = library.theme.text, TextSize = 14, Font = fontBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar })

local closeBtn = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 14, Font = fontBold, Parent = topBar })
local minBtn   = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -80, 0, 0), BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 14, Font = fontBold, Parent = topBar })

local tabContainer = create("Frame", { Size = UDim2.new(0, 155, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = library.theme.tabBg, BorderSizePixel = 0, Parent = mainFrame })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = tabContainer })
create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = tabContainer })

local pageContainer = create("Frame", { Size = UDim2.new(1, -155, 1, -40), Position = UDim2.new(0, 155, 0, 40), BackgroundTransparency = 1, Parent = mainFrame })

local dragging, dragInput, dragStart, startPos
library:AddConnection(topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end))
library:AddConnection(topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end))
library:AddConnection(uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

local isMinimized = false
library:AddConnection(minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 580, 0, isMinimized and 40 or 420) }):Play()
end))
library:AddConnection(closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end))
library:AddConnection(uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end))

library:AddConnection(closeBtn.MouseEnter:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end))
library:AddConnection(closeBtn.MouseLeave:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end))
library:AddConnection(minBtn.MouseEnter:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end))
library:AddConnection(minBtn.MouseLeave:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end))

function library:SetAccentColor(color)
    self.theme.accent = color
    ts:Create(accentLine, TweenInfo.new(0.4), {BackgroundColor3 = color}):Play()
    for _, tab in pairs(self.tabs) do
        if tab.page.Visible then ts:Create(tab.indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for indicator, state in pairs(self.activeToggles) do
        if state then ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for _, obj in pairs(self.themeObjects.accent) do
        if obj:IsA("Frame") or obj:IsA("TextButton") then ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        elseif obj:IsA("TextLabel") then ts:Create(obj, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        elseif obj:IsA("UIStroke") then ts:Create(obj, TweenInfo.new(0.3), {Color = color}):Play() end
    end
end

function library:SetMainColor(color)
    self.theme.mainBg = color
    self.theme.tabBg = color:Lerp(Color3.new(0,0,0), 0.15)
    self.theme.topBar = color:Lerp(Color3.new(1,1,1), 0.08)
    
    ts:Create(mainFrame, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.mainBg}):Play()
    ts:Create(tabContainer, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.tabBg}):Play()
    ts:Create(topBar, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.topBar}):Play()
end

function library:SetElementColor(color)
    self.theme.elementBg = color
    for _, obj in pairs(self.themeObjects.elementBg) do
        ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
    end
end

function library:CreateTab(name)
    self.tabCount = self.tabCount + 1
    local order = self.tabCount
    local tabBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = order, Text = "    " .. name, TextColor3 = Color3.fromRGB(150, 150, 150), Font = fontRegular, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = tabContainer })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabBtn })
    
    local activeIndicator = create("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = self.theme.accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = tabBtn })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = activeIndicator})

    local page = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90), Visible = false, Parent = pageContainer })
    local layout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = page })
    create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 12), Parent = page })

    self:AddConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end))

    self:AddConnection(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.page.Visible = false
            ts:Create(t.btn, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1}):Play()
            t.btn.Font = fontRegular
            ts:Create(t.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
        page.Visible = true
        ts:Create(tabBtn, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.94}):Play()
        tabBtn.Font = fontBold
        ts:Create(activeIndicator, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    end))

    table.insert(self.tabs, {btn = tabBtn, page = page, indicator = activeIndicator})
    if #self.tabs == 1 then
        page.Visible = true; tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tabBtn.BackgroundTransparency = 0.94; tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); tabBtn.Font = fontBold; activeIndicator.BackgroundTransparency = 0
    end

    local elements = {page = page}
    local libRef = self

    function elements:AddButton(text, callback)
        local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = libRef.theme.elementBg, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, AutoButtonColor = false, Parent = page })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        applyStroke(btn, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(btn, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, btn)

        libRef:AddConnection(btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = libRef.theme.elementBg:Lerp(Color3.new(1,1,1), 0.05)}):Play() end))
        libRef:AddConnection(btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = libRef.theme.elementBg}):Play() end))
        libRef:AddConnection(btn.MouseButton1Click:Connect(function()
            local tw = ts:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(0.98, 0, 0, 36)})
            tw:Play(); tw.Completed:Wait()
            ts:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            if callback then callback() end
        end))
    end

    function elements:AddToggle(text, description, callback)
        if type(description) == "function" then callback = description; description = nil end
        local state = false
        local height = description and 52 or 42
        local toggleFrame = create("TextButton", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = libRef.theme.elementBg, Text = "", AutoButtonColor = false, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleFrame})
        applyStroke(toggleFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(toggleFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, toggleFrame)

        local titleY = description and 14 or (height / 2)
        create("TextLabel", {Size = UDim2.new(1, -70, 0, 14), Position = UDim2.new(0, 14, 0, titleY - 7), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame})
        if description then create("TextLabel", {Size = UDim2.new(1, -70, 0, 12), Position = UDim2.new(0, 14, 0, 28), BackgroundTransparency = 1, Text = description, TextColor3 = libRef.theme.subText, Font = fontRegular, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame}) end
        
        local indicatorBg = create("Frame", {Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = libRef.theme.innerBg, Parent = toggleFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})
        applyStroke(indicatorBg, Color3.fromRGB(255, 255, 255), 0.9)

        local indicator = create("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(100, 100, 100), Parent = indicatorBg})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        libRef.activeToggles[indicator] = state

        libRef:AddConnection(toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            libRef.activeToggles[indicator] = state
            ts:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = state and libRef.theme.accent or Color3.fromRGB(100, 100, 100)
            }):Play()
            if callback then callback(state) end
        end))
    end

    function elements:AddSlider(text, min, max, default, callback)
        local val = math.clamp(default, min, max)
        local sliderFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = libRef.theme.elementBg, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFrame})
        applyStroke(sliderFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(sliderFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, sliderFrame)

        create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = sliderFrame})
        local valLabel = create("TextLabel", {Size = UDim2.new(0, 55, 0, 20), Position = UDim2.new(1, -69, 0, 8), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = sliderFrame})
        
        local bgBar = create("TextButton", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 1, -14), BackgroundColor3 = libRef.theme.innerBg, Text = "", AutoButtonColor = false, Parent = sliderFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bgBar})
        
        local fill = create("Frame", {Size = UDim2.new((val - min) / (max - min), 0, 1, 0), BackgroundColor3 = libRef.theme.accent, Parent = bgBar})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
        applyUniversalGradient(fill, 0, 0.25)
        table.insert(libRef.themeObjects.accent, fill)

        local isDragging = false
        local function update(input)
            local pct = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * pct)
            valLabel.Text = tostring(val)
            ts:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            if callback then callback(val) end
        end

        libRef:AddConnection(bgBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; update(input) end end))
        libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end))
        libRef:AddConnection(uis.InputChanged:Connect(function(input) if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end))
    end

    function elements:AddColorPicker(text, defaultColor, callback)
        local r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255
        local expanded = false
        local cpFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = libRef.theme.elementBg, ClipsDescendants = true, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpFrame})
        applyStroke(cpFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(cpFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, cpFrame)

        local cpBtn = create("TextButton", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Text = "    " .. text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = cpFrame})
        local colorPreview = create("Frame", {Size = UDim2.new(0, 32, 0, 20), Position = UDim2.new(1, -44, 0, 11), BackgroundColor3 = defaultColor, Parent = cpFrame})
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})
        applyStroke(colorPreview, Color3.fromRGB(255, 255, 255), 0.8)

        local sliderContainer = create("Frame", {Size = UDim2.new(1, -24, 0, 90), Position = UDim2.new(0, 12, 0, 46), BackgroundTransparency = 1, Parent = cpFrame})
        create("UIListLayout", {Padding = UDim.new(0, 6), Parent = sliderContainer})
        
        local function createRgbSlider(name, colorVal, barColor)
            local sFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = sliderContainer})
            create("TextLabel", {Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 12, Parent = sFrame})
            local sBar = create("TextButton", {Size = UDim2.new(1, -26, 0, 6), Position = UDim2.new(0, 26, 0.5, -3), BackgroundColor3 = libRef.theme.innerBg, Text = "", AutoButtonColor = false, Parent = sFrame})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sBar})
            local sFill = create("Frame", {Size = UDim2.new(colorVal / 255, 0, 1, 0), BackgroundColor3 = barColor, Parent = sBar})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sFill})
            
            local dragging = false
            local function update(input)
                local pct = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                sFill.Size = UDim2.new(pct, 0, 1, 0)
                local v = math.floor(pct * 255)
                if name == "R" then r = v elseif name == "G" then g = v else b = v end
                local nc = Color3.fromRGB(r, g, b)
                colorPreview.BackgroundColor3 = nc
                if callback then callback(nc) end
            end
            libRef:AddConnection(sBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end))
            libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
            libRef:AddConnection(uis.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end))
        end

        createRgbSlider("R", r, Color3.fromRGB(255, 75, 75))
        createRgbSlider("G", g, Color3.fromRGB(75, 255, 75))
        createRgbSlider("B", b, Color3.fromRGB(75, 125, 255))

        libRef:AddConnection(cpBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, expanded and 145 or 42)}):Play()
        end))
    end

    function elements:AddSection(text)
        local sec = create("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = string.upper(text), TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
        create("UIPadding", {PaddingLeft = UDim.new(0, 4), Parent = sec})
    end

    function elements:AddTagList(text, placeholder, onAddRequest, onListChanged)
        local tags = {}
        local tagMethods = {}
        
        local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = libRef.theme.elementBg, ClipsDescendants = true, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = frame})
        applyStroke(frame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(frame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, frame)

        create("TextLabel", {Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
        
        local box = create("TextBox", {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0, 14, 0, 24), BackgroundTransparency = 1, Text = "", PlaceholderText = placeholder, TextColor3 = libRef.theme.subText, Font = fontRegular, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = frame})
        
        local tContainer = create("Frame", {Size = UDim2.new(1, -28, 0, 0), Position = UDim2.new(0, 14, 0, 50), BackgroundTransparency = 1, Parent = frame})
        local layout = create("UIGridLayout", {CellSize = UDim2.new(0.48, 0, 0, 24), CellPadding = UDim2.new(0.04, 0, 0, 8), Parent = tContainer})
        
        local function updateSize()
            local rows = math.ceil(#tags / 2)
            tContainer.Size = UDim2.new(1, -28, 0, rows * 32)
            frame.Size = UDim2.new(1, 0, 0, 46 + (rows > 0 and (rows * 32 + 8) or 0))
        end

        local function addVisualTag(tagName)
            table.insert(tags, tagName)
            local tFrame = create("Frame", {Name = tagName, BackgroundColor3 = libRef.theme.innerBg, Parent = tContainer})
            create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = tFrame})
            applyStroke(tFrame, Color3.fromRGB(255, 255, 255), 0.9)

            create("TextLabel", {Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = tagName, TextColor3 = libRef.theme.text, Font = fontRegular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = tFrame})
            
            local del = create("TextButton", {Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 75, 75), Font = fontBold, TextSize = 15, Parent = tFrame})
            
            libRef:AddConnection(del.MouseButton1Click:Connect(function()
                tagMethods:RemoveTag(tagName)
            end))
            
            updateSize()
            if onListChanged then onListChanged(tags) end
        end

        function tagMethods:RemoveTag(tagName)
            local idx = table.find(tags, tagName)
            if idx then table.remove(tags, idx) end
            local foundFrame = tContainer:FindFirstChild(tagName)
            if foundFrame then foundFrame:Destroy() end
            updateSize()
            if onListChanged then onListChanged(tags) end
        end

        libRef:AddConnection(box.FocusLost:Connect(function(entered)
            if entered and box.Text ~= "" then
                local finalName = onAddRequest and onAddRequest(box.Text) or box.Text
                if finalName and not table.find(tags, finalName) then addVisualTag(finalName) end
                box.Text = ""
            end
        end))

        return tagMethods 
    end

    return elements
end

return librarylocal ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local cg = game:GetService("CoreGui")
local players = game:GetService("Players")

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

local fontRegular = Enum.Font.GothamMedium
local fontBold    = Enum.Font.GothamBold

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do inst[i] = v end
    return inst
end

local function applyUniversalGradient(parentObj, rotation, intensity)
    intensity = intensity or 0.25
    local grad = create("UIGradient", {
        Rotation = rotation or 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, intensity)
        }),
        Parent = parentObj
    })
    return grad
end

local function applyStroke(parentObj, color, transparency)
    return create("UIStroke", {
        Color = color or Color3.fromRGB(255, 255, 255),
        Transparency = transparency or 0.9,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parentObj
    })
end

local gui = create("ScreenGui", { Name = "ProjectHub", ResetOnSpawn = false, Parent = parent })

local library = {
    theme = {
        accent = Color3.fromRGB(115, 135, 255),
        mainBg = Color3.fromRGB(22, 22, 26),
        topBar = Color3.fromRGB(28, 28, 33),
        tabBg  = Color3.fromRGB(24, 24, 28),
        elementBg = Color3.fromRGB(32, 32, 38),
        innerBg   = Color3.fromRGB(18, 18, 22),
        text = Color3.fromRGB(240, 240, 240),
        subText = Color3.fromRGB(150, 150, 150)
    },
    tabs = {},
    tabCount = 0,
    activeToggles = {},
    themeObjects = {
        accent = {},
        mainBg = {},
        elementBg = {}
    },
    _connections = {},
    Gui = gui
}

function library:AddConnection(conn)
    table.insert(self._connections, conn)
    return conn
end

gui.Destroying:Connect(function()
    for _, c in pairs(library._connections) do
        if c.Disconnect then c:Disconnect() end
    end
end)

local notifyContainer = create("Frame", {
    Size = UDim2.new(0, 260, 1, -20),
    Position = UDim2.new(1, -270, 0, 10),
    BackgroundTransparency = 1,
    Parent = gui
})
local notifyLayout = create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 8),
    Parent = notifyContainer
})

function library:Notify(title, desc, duration)
    duration = duration or 3
    local nFrame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.theme.elementBg,
        ClipsDescendants = true,
        Parent = notifyContainer
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = nFrame })
    applyStroke(nFrame, self.theme.accent, 0.6)
    applyUniversalGradient(nFrame, 45, 0.2)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.theme.text,
        Font = fontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1,
        Text = desc or "",
        TextColor3 = self.theme.subText,
        Font = fontRegular,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    ts:Create(nFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, 52) }):Play()
    
    task.delay(duration, function()
        local tw = ts:Create(nFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) })
        tw:Play()
        tw.Completed:Connect(function() nFrame:Destroy() end)
    end)
end

local mainFrame = create("Frame", {
    Size = UDim2.new(0, 580, 0, 420),
    Position = UDim2.new(0.5, -290, 0.5, -210),
    BackgroundColor3 = library.theme.mainBg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainFrame })
applyStroke(mainFrame, Color3.fromRGB(255, 255, 255), 0.88)
applyUniversalGradient(mainFrame, 135, 0.15)
table.insert(library.themeObjects.mainBg, mainFrame)

local topBar = create("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = library.theme.topBar, BorderSizePixel = 0, Parent = mainFrame })
applyUniversalGradient(topBar, 90, 0.1)

local accentLine = create("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = library.theme.accent, BorderSizePixel = 0, Parent = topBar })
applyUniversalGradient(accentLine, 0, 0.3)

create("TextLabel", { Size = UDim2.new(1, -104, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "Project Hub", TextColor3 = library.theme.text, TextSize = 14, Font = fontBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar })

local closeBtn = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Text = "✕", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 14, Font = fontBold, Parent = topBar })
local minBtn   = create("TextButton", { Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -80, 0, 0), BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(180, 180, 180), TextSize = 14, Font = fontBold, Parent = topBar })

local tabContainer = create("Frame", { Size = UDim2.new(0, 155, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = library.theme.tabBg, BorderSizePixel = 0, Parent = mainFrame })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = tabContainer })
create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = tabContainer })

local pageContainer = create("Frame", { Size = UDim2.new(1, -155, 1, -40), Position = UDim2.new(0, 155, 0, 40), BackgroundTransparency = 1, Parent = mainFrame })

local dragging, dragInput, dragStart, startPos
library:AddConnection(topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end))
library:AddConnection(topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end))
library:AddConnection(uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

local isMinimized = false
library:AddConnection(minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 580, 0, isMinimized and 40 or 420) }):Play()
end))
library:AddConnection(closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end))
library:AddConnection(uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end))

library:AddConnection(closeBtn.MouseEnter:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end))
library:AddConnection(closeBtn.MouseLeave:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end))
library:AddConnection(minBtn.MouseEnter:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end))
library:AddConnection(minBtn.MouseLeave:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end))

function library:SetAccentColor(color)
    self.theme.accent = color
    ts:Create(accentLine, TweenInfo.new(0.4), {BackgroundColor3 = color}):Play()
    for _, tab in pairs(self.tabs) do
        if tab.page.Visible then ts:Create(tab.indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for indicator, state in pairs(self.activeToggles) do
        if state then ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for _, obj in pairs(self.themeObjects.accent) do
        if obj:IsA("Frame") or obj:IsA("TextButton") then ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        elseif obj:IsA("TextLabel") then ts:Create(obj, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        elseif obj:IsA("UIStroke") then ts:Create(obj, TweenInfo.new(0.3), {Color = color}):Play() end
    end
end

function library:SetMainColor(color)
    self.theme.mainBg = color
    self.theme.tabBg = color:Lerp(Color3.new(0,0,0), 0.15)
    self.theme.topBar = color:Lerp(Color3.new(1,1,1), 0.08)
    
    ts:Create(mainFrame, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.mainBg}):Play()
    ts:Create(tabContainer, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.tabBg}):Play()
    ts:Create(topBar, TweenInfo.new(0.4), {BackgroundColor3 = self.theme.topBar}):Play()
end

function library:SetElementColor(color)
    self.theme.elementBg = color
    for _, obj in pairs(self.themeObjects.elementBg) do
        ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
    end
end

function library:CreateTab(name)
    self.tabCount = self.tabCount + 1
    local order = self.tabCount
    local tabBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = order, Text = "    " .. name, TextColor3 = Color3.fromRGB(150, 150, 150), Font = fontRegular, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = tabContainer })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabBtn })
    
    local activeIndicator = create("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = self.theme.accent, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = tabBtn })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = activeIndicator})

    local page = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90), Visible = false, Parent = pageContainer })
    local layout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = page })
    create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingBottom = UDim.new(0, 12), Parent = page })

    self:AddConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end))

    self:AddConnection(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.page.Visible = false
            ts:Create(t.btn, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1}):Play()
            t.btn.Font = fontRegular
            ts:Create(t.indicator, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
        page.Visible = true
        ts:Create(tabBtn, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.94}):Play()
        tabBtn.Font = fontBold
        ts:Create(activeIndicator, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    end))

    table.insert(self.tabs, {btn = tabBtn, page = page, indicator = activeIndicator})
    if #self.tabs == 1 then
        page.Visible = true; tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tabBtn.BackgroundTransparency = 0.94; tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); tabBtn.Font = fontBold; activeIndicator.BackgroundTransparency = 0
    end

    local elements = {page = page}
    local libRef = self

    function elements:AddButton(text, callback)
        local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = libRef.theme.elementBg, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, AutoButtonColor = false, Parent = page })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        applyStroke(btn, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(btn, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, btn)

        libRef:AddConnection(btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = libRef.theme.elementBg:Lerp(Color3.new(1,1,1), 0.05)}):Play() end))
        libRef:AddConnection(btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = libRef.theme.elementBg}):Play() end))
        libRef:AddConnection(btn.MouseButton1Click:Connect(function()
            local tw = ts:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(0.98, 0, 0, 36)})
            tw:Play(); tw.Completed:Wait()
            ts:Create(btn, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            if callback then callback() end
        end))
    end

    function elements:AddToggle(text, description, callback)
        if type(description) == "function" then callback = description; description = nil end
        local state = false
        local height = description and 52 or 42
        local toggleFrame = create("TextButton", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = libRef.theme.elementBg, Text = "", AutoButtonColor = false, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = toggleFrame})
        applyStroke(toggleFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(toggleFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, toggleFrame)

        local titleY = description and 14 or (height / 2)
        create("TextLabel", {Size = UDim2.new(1, -70, 0, 14), Position = UDim2.new(0, 14, 0, titleY - 7), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame})
        if description then create("TextLabel", {Size = UDim2.new(1, -70, 0, 12), Position = UDim2.new(0, 14, 0, 28), BackgroundTransparency = 1, Text = description, TextColor3 = libRef.theme.subText, Font = fontRegular, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame}) end
        
        local indicatorBg = create("Frame", {Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = libRef.theme.innerBg, Parent = toggleFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})
        applyStroke(indicatorBg, Color3.fromRGB(255, 255, 255), 0.9)

        local indicator = create("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(100, 100, 100), Parent = indicatorBg})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        libRef.activeToggles[indicator] = state

        libRef:AddConnection(toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            libRef.activeToggles[indicator] = state
            ts:Create(indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = state and libRef.theme.accent or Color3.fromRGB(100, 100, 100)
            }):Play()
            if callback then callback(state) end
        end))
    end

    function elements:AddSlider(text, min, max, default, callback)
        local val = math.clamp(default, min, max)
        local sliderFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = libRef.theme.elementBg, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = sliderFrame})
        applyStroke(sliderFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(sliderFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, sliderFrame)

        create("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = sliderFrame})
        local valLabel = create("TextLabel", {Size = UDim2.new(0, 55, 0, 20), Position = UDim2.new(1, -69, 0, 8), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = sliderFrame})
        
        local bgBar = create("TextButton", {Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 1, -14), BackgroundColor3 = libRef.theme.innerBg, Text = "", AutoButtonColor = false, Parent = sliderFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bgBar})
        
        local fill = create("Frame", {Size = UDim2.new((val - min) / (max - min), 0, 1, 0), BackgroundColor3 = libRef.theme.accent, Parent = bgBar})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
        applyUniversalGradient(fill, 0, 0.25)
        table.insert(libRef.themeObjects.accent, fill)

        local isDragging = false
        local function update(input)
            local pct = math.clamp((input.Position.X - bgBar.AbsolutePosition.X) / bgBar.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * pct)
            valLabel.Text = tostring(val)
            ts:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            if callback then callback(val) end
        end

        libRef:AddConnection(bgBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; update(input) end end))
        libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end))
        libRef:AddConnection(uis.InputChanged:Connect(function(input) if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end))
    end

    function elements:AddColorPicker(text, defaultColor, callback)
        local r, g, b = defaultColor.R * 255, defaultColor.G * 255, defaultColor.B * 255
        local expanded = false
        local cpFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = libRef.theme.elementBg, ClipsDescendants = true, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = cpFrame})
        applyStroke(cpFrame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(cpFrame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, cpFrame)

        local cpBtn = create("TextButton", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Text = "    " .. text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = cpFrame})
        local colorPreview = create("Frame", {Size = UDim2.new(0, 32, 0, 20), Position = UDim2.new(1, -44, 0, 11), BackgroundColor3 = defaultColor, Parent = cpFrame})
        create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorPreview})
        applyStroke(colorPreview, Color3.fromRGB(255, 255, 255), 0.8)

        local sliderContainer = create("Frame", {Size = UDim2.new(1, -24, 0, 90), Position = UDim2.new(0, 12, 0, 46), BackgroundTransparency = 1, Parent = cpFrame})
        create("UIListLayout", {Padding = UDim.new(0, 6), Parent = sliderContainer})
        
        local function createRgbSlider(name, colorVal, barColor)
            local sFrame = create("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = sliderContainer})
            create("TextLabel", {Size = UDim2.new(0, 16, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 12, Parent = sFrame})
            local sBar = create("TextButton", {Size = UDim2.new(1, -26, 0, 6), Position = UDim2.new(0, 26, 0.5, -3), BackgroundColor3 = libRef.theme.innerBg, Text = "", AutoButtonColor = false, Parent = sFrame})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sBar})
            local sFill = create("Frame", {Size = UDim2.new(colorVal / 255, 0, 1, 0), BackgroundColor3 = barColor, Parent = sBar})
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sFill})
            
            local dragging = false
            local function update(input)
                local pct = math.clamp((input.Position.X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
                sFill.Size = UDim2.new(pct, 0, 1, 0)
                local v = math.floor(pct * 255)
                if name == "R" then r = v elseif name == "G" then g = v else b = v end
                local nc = Color3.fromRGB(r, g, b)
                colorPreview.BackgroundColor3 = nc
                if callback then callback(nc) end
            end
            libRef:AddConnection(sBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end end))
            libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
            libRef:AddConnection(uis.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end))
        end

        createRgbSlider("R", r, Color3.fromRGB(255, 75, 75))
        createRgbSlider("G", g, Color3.fromRGB(75, 255, 75))
        createRgbSlider("B", b, Color3.fromRGB(75, 125, 255))

        libRef:AddConnection(cpBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, expanded and 145 or 42)}):Play()
        end))
    end

    function elements:AddSection(text)
        local sec = create("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = string.upper(text), TextColor3 = libRef.theme.subText, Font = fontBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
        create("UIPadding", {PaddingLeft = UDim.new(0, 4), Parent = sec})
    end

    function elements:AddTagList(text, placeholder, onAddRequest, onListChanged)
        local tags = {}
        local tagMethods = {}
        
        local frame = create("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = libRef.theme.elementBg, ClipsDescendants = true, Parent = page})
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = frame})
        applyStroke(frame, Color3.fromRGB(255, 255, 255), 0.92)
        applyUniversalGradient(frame, 90, 0.15)
        table.insert(libRef.themeObjects.elementBg, frame)

        create("TextLabel", {Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 14, 0, 8), BackgroundTransparency = 1, Text = text, TextColor3 = libRef.theme.text, Font = fontBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
        
        local box = create("TextBox", {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.new(0, 14, 0, 24), BackgroundTransparency = 1, Text = "", PlaceholderText = placeholder, TextColor3 = libRef.theme.subText, Font = fontRegular, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = frame})
        
        local tContainer = create("Frame", {Size = UDim2.new(1, -28, 0, 0), Position = UDim2.new(0, 14, 0, 50), BackgroundTransparency = 1, Parent = frame})
        local layout = create("UIGridLayout", {CellSize = UDim2.new(0.48, 0, 0, 24), CellPadding = UDim2.new(0.04, 0, 0, 8), Parent = tContainer})
        
        local function updateSize()
            local rows = math.ceil(#tags / 2)
            tContainer.Size = UDim2.new(1, -28, 0, rows * 32)
            frame.Size = UDim2.new(1, 0, 0, 46 + (rows > 0 and (rows * 32 + 8) or 0))
        end

        local function addVisualTag(tagName)
            table.insert(tags, tagName)
            local tFrame = create("Frame", {Name = tagName, BackgroundColor3 = libRef.theme.innerBg, Parent = tContainer})
            create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = tFrame})
            applyStroke(tFrame, Color3.fromRGB(255, 255, 255), 0.9)

            create("TextLabel", {Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = tagName, TextColor3 = libRef.theme.text, Font = fontRegular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = tFrame})
            
            local del = create("TextButton", {Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -24, 0, 0), BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(255, 75, 75), Font = fontBold, TextSize = 15, Parent = tFrame})
            
            libRef:AddConnection(del.MouseButton1Click:Connect(function()
                tagMethods:RemoveTag(tagName)
            end))
            
            updateSize()
            if onListChanged then onListChanged(tags) end
        end

        function tagMethods:RemoveTag(tagName)
            local idx = table.find(tags, tagName)
            if idx then table.remove(tags, idx) end
            local foundFrame = tContainer:FindFirstChild(tagName)
            if foundFrame then foundFrame:Destroy() end
            updateSize()
            if onListChanged then onListChanged(tags) end
        end

        libRef:AddConnection(box.FocusLost:Connect(function(entered)
            if entered and box.Text ~= "" then
                local finalName = onAddRequest and onAddRequest(box.Text) or box.Text
                if finalName and not table.find(tags, finalName) then addVisualTag(finalName) end
                box.Text = ""
            end
        end))

        return tagMethods 
    end

    return elements
end

return library
