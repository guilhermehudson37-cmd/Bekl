--[[
    GHUB - Blox Fruits Script
    Auto Farm Chest com interface premium
]]

-- Variáveis principais
local GHUB = {
    Player = game.Players.LocalPlayer,
    Character = nil,
    Humanoid = nil,
    RootPart = nil,
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TeleportService = game:GetService("TeleportService"),
    CollectionService = game:GetService("CollectionService"),
    
    -- Configurações
    Settings = {
        AutoFarm = false,
        TweenSpeed = 50,
        CollectRadius = 50,
    },
    
    -- Stats
    Stats = {
        ChestsCollected = 0,
        ServerTime = 0,
        IsFarming = false,
        FoundRare = false,
    },
    
    -- Core
    Chests = {},
    CurrentTarget = nil,
    Tween = nil,
    Connections = {},
    UI = nil,
}

-- Função para criar a interface
function GHUB:CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GHUB"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 450, 0, 550)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    MainFrame.ClipsDescendants = true
    
    -- Efeito Glass
    local GlassEffect = Instance.new("Frame")
    GlassEffect.Name = "GlassEffect"
    GlassEffect.Parent = MainFrame
    GlassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassEffect.BackgroundTransparency = 0.95
    GlassEffect.Size = UDim2.new(1, 0, 1, 0)
    GlassEffect.BorderSizePixel = 0
    
    -- Bordas com brilho
    local BorderGlow = Instance.new("Frame")
    BorderGlow.Name = "BorderGlow"
    BorderGlow.Parent = MainFrame
    BorderGlow.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    BorderGlow.BackgroundTransparency = 0.8
    BorderGlow.Size = UDim2.new(1, 0, 0, 2)
    BorderGlow.Position = UDim2.new(0, 0, 0, 0)
    BorderGlow.BorderSizePixel = 0
    
    -- Cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.Parent = MainFrame
    Corner.CornerRadius = UDim.new(0, 12)
    
    -- Barra Superior
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TopBar.BackgroundTransparency = 0.3
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BorderSizePixel = 0
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.Parent = TopBar
    TopCorner.CornerRadius = UDim.new(0, 12)
    
    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Name = "Logo"
    Logo.Parent = TopBar
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0, 10, 0, 5)
    Logo.Size = UDim2.new(0, 30, 0, 30)
    Logo.Text = "⚡"
    Logo.TextColor3 = Color3.fromRGB(100, 50, 255)
    Logo.TextSize = 24
    Logo.Font = Enum.Font.SourceSansBold
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 45, 0, 5)
    Title.Size = UDim2.new(0, 100, 0, 30)
    Title.Text = "GHUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botões da barra superior
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TopBar
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    MinimizeBtn.BackgroundTransparency = 0.3
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 8)
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 18
    MinimizeBtn.Font = Enum.Font.SourceSansBold
    MinimizeBtn.BorderSizePixel = 0
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.Parent = MinimizeBtn
    MinCorner.CornerRadius = UDim.new(0, 6)
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Position = UDim2.new(1, -35, 0, 8)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.BorderSizePixel = 0
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.Parent = CloseBtn
    CloseCorner.CornerRadius = UDim.new(0, 6)
    
    -- Área de Conteúdo
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 0, 0, 50)
    ContentArea.Size = UDim2.new(1, 0, 1, -55)
    ContentArea.ScrollBarThickness = 4
    ContentArea.ScrollBarImageColor3 = Color3.fromRGB(100, 50, 255)
    ContentArea.BorderSizePixel = 0
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = ContentArea
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 10)
    
    -- Seção Auto Farm
    local FarmSection = self:CreateSection(ContentArea, "⚙️ AUTO FARM")
    
    -- Toggle Auto Farm
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Parent = FarmSection
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ToggleFrame.BackgroundTransparency = 0.5
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 10)
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.Parent = ToggleFrame
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0, 150, 0, 40)
    ToggleLabel.Text = "Auto Farm Chest"
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 15
    ToggleLabel.Font = Enum.Font.SourceSansSemiBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ToggleBtn.Position = UDim2.new(1, -55, 0, 8)
    ToggleBtn.Size = UDim2.new(0, 45, 0, 24)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.BorderSizePixel = 0
    
    local ToggleBtnCorner = Instance.new("UICorner")
    ToggleBtnCorner.Parent = ToggleBtn
    ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
    
    -- Slider Velocidade
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Name = "SpeedFrame"
    SpeedFrame.Parent = FarmSection
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SpeedFrame.BackgroundTransparency = 0.5
    SpeedFrame.Size = UDim2.new(1, -20, 0, 50)
    SpeedFrame.Position = UDim2.new(0, 10, 0, 55)
    SpeedFrame.BorderSizePixel = 0
    
    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.Parent = SpeedFrame
    SpeedCorner.CornerRadius = UDim.new(0, 8)
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Parent = SpeedFrame
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Position = UDim2.new(0, 10, 0, 0)
    SpeedLabel.Size = UDim2.new(0, 150, 0, 20)
    SpeedLabel.Text = "Velocidade Tween"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextSize = 13
    SpeedLabel.Font = Enum.Font.SourceSansSemiBold
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SpeedValue = Instance.new("TextLabel")
    SpeedValue.Name = "SpeedValue"
    SpeedValue.Parent = SpeedFrame
    SpeedValue.BackgroundTransparency = 1
    SpeedValue.Position = UDim2.new(1, -60, 0, 0)
    SpeedValue.Size = UDim2.new(0, 50, 0, 20)
    SpeedValue.Text = "50%"
    SpeedValue.TextColor3 = Color3.fromRGB(100, 50, 255)
    SpeedValue.TextSize = 13
    SpeedValue.Font = Enum.Font.SourceSansBold
    SpeedValue.TextXAlignment = Enum.TextXAlignment.Right
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Parent = SpeedFrame
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 28)
    SpeedSlider.Size = UDim2.new(1, -20, 0, 8)
    SpeedSlider.BorderSizePixel = 0
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.Parent = SpeedSlider
    SliderCorner.CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Parent = SpeedSlider
    SliderFill.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    SliderFill.BorderSizePixel = 0
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.Parent = SliderFill
    FillCorner.CornerRadius = UDim.new(1, 0)
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Parent = SpeedSlider
    SliderButton.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    SliderButton.Position = UDim2.new(0.5, -8, 0, -4)
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Text = ""
    SliderButton.BorderSizePixel = 0
    
    local SliderBtnCorner = Instance.new("UICorner")
    SliderBtnCorner.Parent = SliderButton
    SliderBtnCorner.CornerRadius = UDim.new(1, 0)
    
    -- Seção Status
    local StatusSection = self:CreateSection(ContentArea, "📊 STATUS")
    
    -- Status Auto Farm
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Parent = StatusSection
    StatusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    StatusFrame.BackgroundTransparency = 0.5
    StatusFrame.Size = UDim2.new(1, -20, 0, 30)
    StatusFrame.Position = UDim2.new(0, 10, 0, 10)
    StatusFrame.BorderSizePixel = 0
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.Parent = StatusFrame
    StatusCorner.CornerRadius = UDim.new(0, 8)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 10, 0, 0)
    StatusLabel.Size = UDim2.new(0, 100, 0, 30)
    StatusLabel.Text = "Status:"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.SourceSansSemiBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusValue = Instance.new("TextLabel")
    StatusValue.Name = "StatusValue"
    StatusValue.Parent = StatusFrame
    StatusValue.BackgroundTransparency = 1
    StatusValue.Position = UDim2.new(0, 80, 0, 0)
    StatusValue.Size = UDim2.new(0, 150, 0, 30)
    StatusValue.Text = "Desativado"
    StatusValue.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusValue.TextSize = 13
    StatusValue.Font = Enum.Font.SourceSansBold
    StatusValue.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Tempo Servidor
    local ServerTimeFrame = Instance.new("Frame")
    ServerTimeFrame.Name = "ServerTimeFrame"
    ServerTimeFrame.Parent = StatusSection
    ServerTimeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ServerTimeFrame.BackgroundTransparency = 0.5
    ServerTimeFrame.Size = UDim2.new(1, -20, 0, 30)
    ServerTimeFrame.Position = UDim2.new(0, 10, 0, 45)
    ServerTimeFrame.BorderSizePixel = 0
    
    local STCorner = Instance.new("UICorner")
    STCorner.Parent = ServerTimeFrame
    STCorner.CornerRadius = UDim.new(0, 8)
    
    local STLabel = Instance.new("TextLabel")
    STLabel.Name = "STLabel"
    STLabel.Parent = ServerTimeFrame
    STLabel.BackgroundTransparency = 1
    STLabel.Position = UDim2.new(0, 10, 0, 0)
    STLabel.Size = UDim2.new(0, 150, 0, 30)
    STLabel.Text = "Servidor criado há:"
    STLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    STLabel.TextSize = 13
    STLabel.Font = Enum.Font.SourceSansSemiBold
    STLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local STValue = Instance.new("TextLabel")
    STValue.Name = "STValue"
    STValue.Parent = ServerTimeFrame
    STValue.BackgroundTransparency = 1
    STValue.Position = UDim2.new(0, 150, 0, 0)
    STValue.Size = UDim2.new(0, 200, 0, 30)
    STValue.Text = "00h 00m 00s"
    STValue.TextColor3 = Color3.fromRGB(100, 200, 255)
    STValue.TextSize = 13
    STValue.Font = Enum.Font.SourceSansBold
    STValue.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Baús Coletados
    local ChestsFrame = Instance.new("Frame")
    ChestsFrame.Name = "ChestsFrame"
    ChestsFrame.Parent = StatusSection
    ChestsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ChestsFrame.BackgroundTransparency = 0.5
    ChestsFrame.Size = UDim2.new(1, -20, 0, 30)
    ChestsFrame.Position = UDim2.new(0, 10, 0, 80)
    ChestsFrame.BorderSizePixel = 0
    
    local ChestCorner = Instance.new("UICorner")
    ChestCorner.Parent = ChestsFrame
    ChestCorner.CornerRadius = UDim.new(0, 8)
    
    local ChestLabel = Instance.new("TextLabel")
    ChestLabel.Name = "ChestLabel"
    ChestLabel.Parent = ChestsFrame
    ChestLabel.BackgroundTransparency = 1
    ChestLabel.Position = UDim2.new(0, 10, 0, 0)
    ChestLabel.Size = UDim2.new(0, 150, 0, 30)
    ChestLabel.Text = "Baús coletados:"
    ChestLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ChestLabel.TextSize = 13
    ChestLabel.Font = Enum.Font.SourceSansSemiBold
    ChestLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ChestValue = Instance.new("TextLabel")
    ChestValue.Name = "ChestValue"
    ChestValue.Parent = ChestsFrame
    ChestValue.BackgroundTransparency = 1
    ChestValue.Position = UDim2.new(0, 150, 0, 0)
    ChestValue.Size = UDim2.new(0, 100, 0, 30)
    ChestValue.Text = "0"
    ChestValue.TextColor3 = Color3.fromRGB(255, 200, 100)
    ChestValue.TextSize = 13
    ChestValue.Font = Enum.Font.SourceSansBold
    ChestValue.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Armazenar referências
    self.UI = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ToggleBtn = ToggleBtn,
        SpeedSlider = SpeedSlider,
        SliderFill = SliderFill,
        SliderButton = SliderButton,
        SpeedValue = SpeedValue,
        StatusValue = StatusValue,
        STValue = STValue,
        ChestValue = ChestValue,
        MinimizeBtn = MinimizeBtn,
        CloseBtn = CloseBtn,
        BorderGlow = BorderGlow,
    }
    
    -- Configurar eventos
    self:SetupUIEvents()
    self:StartServerTimeUpdater()
    
    return true
end

-- Função para criar seções
function GHUB:CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = "Section"
    section.Parent = parent
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = section
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 0, 30)
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(100, 50, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Parent = section
    line.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
    line.BackgroundTransparency = 0.5
    line.Position = UDim2.new(0, 10, 0, 32)
    line.Size = UDim2.new(1, -20, 0, 1)
    line.BorderSizePixel = 0
    
    return section
end

-- Configurar eventos da UI
function GHUB:SetupUIEvents()
    -- Toggle Auto Farm
    self.UI.ToggleBtn.MouseButton1Click:Connect(function()
        self.Settings.AutoFarm = not self.Settings.AutoFarm
        if self.Settings.AutoFarm then
            self.UI.ToggleBtn.Text = "ON"
            self.UI.ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 255)
            self.UI.StatusValue.Text = "Ativado"
            self.UI.StatusValue.TextColor3 = Color3.fromRGB(100, 255, 100)
            self:StartAutoFarm()
        else
            self.UI.ToggleBtn.Text = "OFF"
            self.UI.ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            self.UI.StatusValue.Text = "Desativado"
            self.UI.StatusValue.TextColor3 = Color3.fromRGB(255, 100, 100)
            self:StopAutoFarm()
        end
    end)
    
    -- Slider de Velocidade
    local dragging = false
    self.UI.SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    self.UI.SliderButton.MouseButton1Up:Connect(function()
        dragging = false
    end)
    
    self.UI.SliderButton.MouseLeave:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local slider = self.UI.SpeedSlider
            local frame = slider.Parent
            local x = input.Position.X - slider.AbsolutePosition.X
            local width = slider.AbsoluteSize.X
            local percent = math.clamp(x / width, 0, 1)
            
            self.UI.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            self.UI.SliderButton.Position = UDim2.new(percent, -8, 0, -4)
            
            self.Settings.TweenSpeed = math.floor(percent * 100)
            self.UI.SpeedValue.Text = tostring(self.Settings.TweenSpeed).."%"
        end
    end)
    
    -- Minimizar
    self.UI.MinimizeBtn.MouseButton1Click:Connect(function()
        self.UI.MainFrame.Visible = not self.UI.MainFrame.Visible
    end)
    
    -- Fechar
    self.UI.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Animação de hover nos botões
    for _, btn in pairs({self.UI.ToggleBtn, self.UI.MinimizeBtn, self.UI.CloseBtn}) do
        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.1
            btn:TweenSize(UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 2, btn.Size.Y.Scale, btn.Size.Y.Offset + 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.3
            btn:TweenSize(UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 2, btn.Size.Y.Scale, btn.Size.Y.Offset - 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        end)
    end
end

-- Atualizar tempo do servidor
function GHUB:StartServerTimeUpdater()
    local startTime = os.time()
    self:AddConnection(self.RunService.Heartbeat:Connect(function()
        local elapsed = os.time() - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        
        self.UI.STValue.Text = string.format("%02dh %02dm %02ds", hours, minutes, seconds)
    end))
end

-- Sistema Auto Farm
function GHUB:StartAutoFarm()
    if self.Stats.IsFarming
