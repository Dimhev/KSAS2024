local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Защита для экзекьюторов (используем gethui если есть, иначе CoreGui, иначе PlayerGui)
local ParentGui = (gethui and gethui()) or (CoreGui:FindFirstChild("RobloxGui") and CoreGui) or game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старый GUI, если перезапускаем скрипт
if ParentGui:FindFirstChild("MyCustomHub") then
    ParentGui.MyCustomHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyCustomHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Верхняя панель (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Executor Hub v1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопки управления окном
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar

-- Контейнер для вкладок
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

-- Контейнер для страниц
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -120, 1, -30)
PageContainer.Position = UDim2.new(0, 120, 0, 30)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

-- Система перетаскивания (Drag)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Минимизация и закрытие
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 450, 0, 30) or UDim2.new(0, 450, 0, 300)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = targetSize}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Скрытие на Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Логика библиотеки
local Library = {CurrentColor = Color3.fromRGB(85, 170, 255)}
local Tabs = {}

-- Анимация наведения
local function HoverAnim(obj, color1, color2)
    obj.MouseEnter:Connect(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = color2}):Play() end)
    obj.MouseLeave:Connect(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = color1}):Play() end)
end

-- Создание вкладки
function Library:CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 14
    TabBtn.Parent = TabContainer
    HoverAnim(TabBtn, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50))

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.Parent = PageContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 5)
    PageLayout.Parent = Page
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 5)
    PagePadding.PaddingLeft = UDim.new(0, 5)
    PagePadding.PaddingRight = UDim.new(0, 5)
    PagePadding.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Page.Visible = false
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Library.CurrentColor
    end)

    table.insert(Tabs, {Btn = TabBtn, Page = Page})
    if #Tabs == 1 then -- Первая вкладка активна по умолчанию
        Page.Visible = true
        TabBtn.TextColor3 = Library.CurrentColor
    end

    local TabLogic = {}

    -- Создание кнопки
    function TabLogic:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 14
        Btn.Parent = Page
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        
        HoverAnim(Btn, Color3.fromRGB(45, 45, 50), Color3.fromRGB(55, 55, 60))
        
        Btn.MouseButton1Click:Connect(function()
            -- Эффект клика
            local tween = TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 30)})
            tween:Play()
            tween.Completed:Wait()
            TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            callback()
        end)
    end

    -- Создание переключателя (Toggle)
    function TabLogic:AddToggle(text, callback)
        local state = false
        local ToggleFrame = Instance.new("TextButton")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        ToggleFrame.Text = "  " .. text
        ToggleFrame.TextXAlignment = Enum.TextXAlignment.Left
        ToggleFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleFrame.Font = Enum.Font.Gotham
        ToggleFrame.TextSize = 14
        ToggleFrame.Parent = Page
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 20, 0, 20)
        Indicator.Position = UDim2.new(1, -25, 0.5, -10)
        Indicator.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Красный (Off)
        Indicator.Parent = ToggleFrame
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

        ToggleFrame.MouseButton1Click:Connect(function()
            state = not state
            local targetColor = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            callback(state)
        end)
    end

    return TabLogic
end

function Library:UpdateTheme(color)
    Library.CurrentColor = color
    for _, t in pairs(Tabs) do
        if t.Page.Visible then t.Btn.TextColor3 = color end
    end
end

--------------------------------------------------
-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (ТВОЙ КОД ЗДЕСЬ)
--------------------------------------------------

-- Создаем категории (вкладки)
local MainTab = Library:CreateTab("Main")
local PlayerTab = Library:CreateTab("Player")
local SettingsTab = Library:CreateTab("Settings")

-- ===================================================
-- ИНСТРУКЦИЯ (КАК ДОБАВЛЯТЬ КНОПКИ И ПЕРЕКЛЮЧАТЕЛИ):
-- ===================================================
-- Чтобы добавить кнопку:
-- ИмяВкладки:AddButton("Название", function() 
--     -- Твой код тут
-- end)
--
-- Чтобы добавить переключатель (Toggle):
-- ИмяВкладки:AddToggle("Название", function(state)
--     if state then
--         -- Код когда ВКЛ (On)
--     else
--         -- Код когда ВЫКЛ (Off)
--     end
-- end)
-- ===================================================

-- Добавляем тестовую кнопку (Hello world) во вкладку Main
MainTab:AddButton("Test Button (Print)", function()
    print("Hello world! Экзекьютор работает.")
end)

MainTab:AddToggle("God Mode (Visual)", function(state)
    print("God mode state:", state)
end)

PlayerTab:AddButton("WalkSpeed 50", function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 50
    end
end)

PlayerTab:AddToggle("Auto-Jump", function(state)
    print("Auto-Jump:", state)
    -- Здесь логика авто-прыжка
end)

-- Настройки: Смена цвета GUI
SettingsTab:AddButton("Цвет: Синий", function()
    Library:UpdateTheme(Color3.fromRGB(85, 170, 255))
end)

SettingsTab:AddButton("Цвет: Фиолетовый", function()
    Library:UpdateTheme(Color3.fromRGB(170, 85, 255))
end)

SettingsTab:AddButton("Цвет: Красный", function()
    Library:UpdateTheme(Color3.fromRGB(255, 85, 85))
end)
