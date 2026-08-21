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

local fontRegular = Enum.Font.SourceSans
local fontBold    = Enum.Font.SourceSansBold

local function create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do inst[i] = v end
    return inst
end

local gui = create("ScreenGui", { Name = "ProjectHub", ResetOnSpawn = false, Parent = parent })

local library = {
    themeColor = Color3.fromRGB(115, 135, 255),
    tabs = {},
    tabCount = 0,
    activeToggles = {},
    themeObjects = {},
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

local mainFrame = create("Frame", {
    Size = UDim2.new(0, 560, 0, 400),
    Position = UDim2.new(0.5, -280, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = mainFrame })

local topBar = create("Frame", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(30, 30, 35), BorderSizePixel = 0, Parent = mainFrame })
local accentLine = create("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = library.themeColor, BorderSizePixel = 0, Parent = topBar })

create("TextLabel", { Size = UDim2.new(1, -104, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "Project Hub", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 15, Font = fontBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar })

local closeBtn = create("TextButton", { Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -38, 0, 0), BackgroundTransparency = 1, Text = "X", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 18, Font = fontBold, Parent = topBar })
local minBtn = create("TextButton", { Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(1, -76, 0, 0), BackgroundTransparency = 1, Text = "—", TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 16, Font = fontBold, Parent = topBar })

local tabContainer = create("Frame", { Size = UDim2.new(0, 150, 1, -38), Position = UDim2.new(0, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(28, 28, 33), BorderSizePixel = 0, Parent = mainFrame })
create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabContainer })

local pageContainer = create("Frame", { Size = UDim2.new(1, -150, 1, -38), Position = UDim2.new(0, 150, 0, 38), BackgroundTransparency = 1, Parent = mainFrame })

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
    ts:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(0, 560, 0, isMinimized and 38 or 400) }):Play()
end))
library:AddConnection(closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end))
library:AddConnection(uis.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end))

library:AddConnection(closeBtn.MouseEnter:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end))
library:AddConnection(closeBtn.MouseLeave:Connect(function() ts:Create(closeBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end))
library:AddConnection(minBtn.MouseEnter:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end))
library:AddConnection(minBtn.MouseLeave:Connect(function() ts:Create(minBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end))

function library:UpdateTheme(color)
    self.themeColor = color
    ts:Create(accentLine, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundColor3 = color}):Play()
    for _, tab in pairs(self.tabs) do
        if tab.page.Visible then ts:Create(tab.indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for indicator, state in pairs(self.activeToggles) do
        if state then ts:Create(indicator, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() end
    end
    for _, obj in pairs(self.themeObjects) do
        if obj:IsA("Frame") then ts:Create(obj, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play() elseif obj:IsA("TextLabel") then ts:Create(obj, TweenInfo.new(0.3), {TextColor3 = color}):Play() end
    end
end

function library:CreateTab(name)
    self.tabCount = self.tabCount + 1
    local order = self.tabCount
    local tabBtn = create("TextButton", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Color3.fromRGB(28, 28, 33), BorderSizePixel = 0, LayoutOrder = order, Text = "   " .. name, TextColor3 = Color3.fromRGB(150, 150, 150), Font = fontRegular, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = tabContainer })
    local activeIndicator = create("Frame", { Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundColor3 = self.themeColor, BorderSizePixel = 0, BackgroundTransparency = 1, Parent = tabBtn })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = activeIndicator})

    local page = create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65), Visible = false, Parent = pageContainer })
    local layout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = page })
    create("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = page })

    self:AddConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end))

    self:AddConnection(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
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

    table.insert(self.tabs, {btn = tabBtn, page = page, indicator = activeIndicator})
    if #self.tabs == 1 then
        page.Visible = true; tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42); tabBtn.Font = fontBold; activeIndicator.BackgroundTransparency = 0
    end

    local elements = {page = page}
    local libRef = self

    function elements:AddButton(text, callback)
        local btn = create("TextButton", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(35, 35, 40), Text = text, TextColor3 = Color3.fromRGB(220, 220, 220), Font = fontRegular, TextSize = 14, AutoButtonColor = false, Parent = page })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        libRef:AddConnection(btn.MouseEnter:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play() end))
        libRef:AddConnection(btn.MouseLeave:Connect(function() ts:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play() end))
        libRef:AddConnection(btn.MouseButton1Click:Connect(function()
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
        if description then create("TextLabel", {Size = UDim2.new(1, -70, 0, 12), Position = UDim2.new(0, 14, 0, 32), BackgroundTransparency = 1, Text = description, TextColor3 = Color3.fromRGB(150, 150, 150), Font = fontRegular, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = toggleFrame}) end
        local indicatorBg = create("Frame", {Size = UDim2.new(0, 44, 0, 22), Position = UDim2.new(1, -56, 0.5, -11), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Parent = toggleFrame})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicatorBg})
        local indicator = create("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Color3.fromRGB(100, 100, 100), Parent = indicatorBg})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = indicator})
        libRef.activeToggles[indicator] = state

        libRef:AddConnection(toggleFrame.MouseButton1Click:Connect(function()
            state = not state
            libRef.activeToggles[indicator] = state
            ts:Create(indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = state and libRef.themeColor or Color3.fromRGB(100, 100, 100)
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
        local fill = create("Frame", {Size = UDim2.new((val - min) / (max - min), 0, 1, 0), BackgroundColor3 = libRef.themeColor, Parent = bgBar})
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})
        table.insert(libRef.themeObjects, fill)

        local isDragging = false
        libRef:AddConnection(bgBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end))
        libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end))
        libRef:AddConnection(uis.InputChanged:Connect(function(input)
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
            libRef:AddConnection(sBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end))
            libRef:AddConnection(uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
            libRef:AddConnection(uis.InputChanged:Connect(function(input)
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
        libRef:AddConnection(cpBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            ts:Create(cpFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, expanded and 150 or 42)}):Play()
        end))
    end

    function elements:AddSection(text)
        create("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(235, 235, 235), Font = fontBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
    end

    return elements
end

return library
