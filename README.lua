--[[
    Auto Farm Chest para Blox Fruits
    Desenvolvido com foco em desempenho e estabilidade
    Versão: 2.0
]]

-- Variáveis principais
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Serviços
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Configurações padrão
local settings = {
    autoFarm = false,
    paused = false,
    tweenSpeed = 150,
    chestsCollected = 0,
    moneyEarned = 0,
    startTime = 0,
    currentStatus = "Parado"
}

-- Cache de baús para performance
local chestCache = {}
local lastCheck = 0
local CHECK_INTERVAL = 3

-- Criar interface do usuário
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoChestFarmUI"
    ScreenGui.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 380, 0, 450)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Adicionar corner arredondado
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Sombra
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.BorderSizePixel = 0
    Shadow.Size = UDim2.new(1, 8, 1, 8)
    Shadow.Position = UDim2.new(0, 4, 0, 4)
    Shadow.Parent = MainFrame
    Shadow.ZIndex = -1
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 12)
    ShadowCorner.Parent = Shadow
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ AUTO CHEST FARM"
    Title.TextColor3 = Color3.fromRGB(0, 170, 255)
    Title.TextSize = 22
    Title.TextStrokeTransparency = 0.8
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 8)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Conteúdo principal
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Content.BorderSizePixel = 0
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45)
    
    -- Toggle Auto Farm
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Parent = Content
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, -30, 0, 60)
    ToggleFrame.Position = UDim2.new(0, 15, 0, 15)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.Text = "🎯 Auto Farm Chest"
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 16
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(0, 60, 0, 30)
    ToggleButton.Position = UDim2.new(1, -75, 0.5, -15)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    
    local ToggleCornerBtn = Instance.new("UICorner")
    ToggleCornerBtn.CornerRadius = UDim.new(0, 6)
    ToggleCornerBtn.Parent = ToggleButton
    
    -- Slider de velocidade
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Name = "SpeedFrame"
    SpeedFrame.Parent = Content
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SpeedFrame.BorderSizePixel = 0
    SpeedFrame.Size = UDim2.new(1, -30, 0, 60)
    SpeedFrame.Position = UDim2.new(0, 15, 0, 90)
    
    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.CornerRadius = UDim.new(0, 8)
    SpeedCorner.Parent = SpeedFrame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Parent = SpeedFrame
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
    SpeedLabel.Position = UDim2.new(0, 15, 0, 5)
    SpeedLabel.Font = Enum.Font.GothamSemibold
    SpeedLabel.Text = "⚡ Velocidade: 150"
    SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SpeedLabel.TextSize = 14
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local SpeedSlider = Instance.new("TextBox")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Parent = SpeedFrame
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Size = UDim2.new(1, -30, 0, 25)
    SpeedSlider.Position = UDim2.new(0, 15, 0, 28)
    SpeedSlider.Font = Enum.Font.Gotham
    SpeedSlider.Text = "150"
    SpeedSlider.TextColor3 = Color3.fromRGB(0, 170, 255)
    SpeedSlider.TextSize = 14
    
    local SpeedCornerSlider = Instance.new("UICorner")
    SpeedCornerSlider.CornerRadius = UDim.new(0, 4)
    SpeedCornerSlider.Parent = SpeedSlider
    
    -- Status
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Parent = Content
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Size = UDim2.new(1, -30, 0, 40)
    StatusFrame.Position = UDim2.new(0, 15, 0, 165)
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = StatusFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, -20, 1, 0)
    StatusLabel.Position = UDim2.new(0, 10, 0, 0)
    StatusLabel.Font = Enum.Font.GothamSemibold
    StatusLabel.Text = "📊 Status: Parado"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    StatusLabel.TextSize = 14
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Estatísticas
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "StatsFrame"
    StatsFrame.Parent = Content
    StatsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Size = UDim2.new(1, -30, 0, 100)
    StatsFrame.Position = UDim2.new(0, 15, 0, 220)
    
    local StatsCorner = Instance.new("UICorner")
    StatsCorner.CornerRadius = UDim.new(0, 8)
    StatsCorner.Parent = StatsFrame
    
    local statsData = {
        {icon = "📦", text = "Baús: 0", name = "ChestsCount"},
        {icon = "💰", text = "Dinheiro: $0", name = "MoneyCount"},
        {icon = "⏱️", text = "Tempo: 00:00", name = "TimeCount"},
        {icon = "📈", text = "Status: Ativo", name = "FarmStatus"}
    }
    
    for i, stat in ipairs(statsData) do
        local StatLabel = Instance.new("TextLabel")
        StatLabel.Name = stat.name
        StatLabel.Parent = StatsFrame
        StatLabel.BackgroundTransparency = 1
        StatLabel.Size = UDim2.new(1, -20, 0, 20)
        StatLabel.Position = UDim2.new(0, 10, 0, (i-1) * 22 + 8)
        StatLabel.Font = Enum.Font.Gotham
        StatLabel.Text = stat.icon .. " " .. stat.text
        StatLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        StatLabel.TextSize = 13
        StatLabel.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Botões de controle
    local ControlFrame = Instance.new("Frame")
    ControlFrame.Name = "ControlFrame"
    ControlFrame.Parent = Content
    ControlFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ControlFrame.BorderSizePixel = 0
    ControlFrame.Size = UDim2.new(1, -30, 0, 50)
    ControlFrame.Position = UDim2.new(0, 15, 0, 335)
    
    local ControlCorner = Instance.new("UICorner")
    ControlCorner.CornerRadius = UDim.new(0, 8)
    ControlCorner.Parent = ControlFrame
    
    local PauseButton = Instance.new("TextButton")
    PauseButton.Name = "PauseButton"
    PauseButton.Parent = ControlFrame
    PauseButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    PauseButton.BorderSizePixel = 0
    PauseButton.Size = UDim2.new(0.45, -5, 0, 35)
    PauseButton.Position = UDim2.new(0, 10, 0.5, -17)
    PauseButton.Font = Enum.Font.GothamBold
    PauseButton.Text = "⏸️ Pausar"
    PauseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PauseButton.TextSize = 14
    
    local PauseCorner = Instance.new("UICorner")
    PauseCorner.CornerRadius = UDim.new(0, 6)
    PauseCorner.Parent = PauseButton
    
    local ResetButton = Instance.new("TextButton")
    ResetButton.Name = "ResetButton"
    ResetButton.Parent = ControlFrame
    ResetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ResetButton.BorderSizePixel = 0
    ResetButton.Size = UDim2.new(0.45, -5, 0, 35)
    ResetButton.Position = UDim2.new(0.5, 5, 0.5, -17)
    ResetButton.Font = Enum.Font.GothamBold
    ResetButton.Text = "🔄 Resetar"
    ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetButton.TextSize = 14
    
    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetButton
    
    -- Animar abertura
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 380, 0, 450)})
    openTween:Play()
    
    -- Funções dos botões
    CloseButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)})
        closeTween:Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        settings.autoFarm = not settings.autoFarm
        if settings.autoFarm then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            ToggleButton.Text = "ON"
            settings.startTime = tick()
            settings.paused = false
            PauseButton.Text = "⏸️ Pausar"
            StatusLabel.Text = "📊 Status: Procurando baú..."
            settings.currentStatus = "Procurando baú..."
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ToggleButton.Text = "OFF"
            StatusLabel.Text = "📊 Status: Parado"
            settings.currentStatus = "Parado"
        end
    end)
    
    PauseButton.MouseButton1Click:Connect(function()
        if settings.autoFarm then
            settings.paused = not settings.paused
            if settings.paused then
                PauseButton.Text = "▶️ Continuar"
                PauseButton.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                StatusLabel.Text = "📊 Status: Pausado"
                settings.currentStatus = "Pausado"
            else
                PauseButton.Text = "⏸️ Pausar"
                PauseButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
                StatusLabel.Text = "📊 Status: Procurando baú..."
                settings.currentStatus = "Procurando baú..."
            end
        end
    end)
    
    ResetButton.MouseButton1Click:Connect(function()
        settings.chestsCollected = 0
        settings.moneyEarned = 0
        settings.startTime = tick()
        updateStats()
    end)
    
    SpeedSlider.FocusLost:Connect(function(enterPressed)
        local value = tonumber(SpeedSlider.Text)
        if value and value >= 50 and value <= 500 then
            settings.tweenSpeed = value
            SpeedLabel.Text = "⚡ Velocidade: " .. value
        else
            SpeedSlider.Text = tostring(settings.tweenSpeed)
        end
    end)
    
    return ScreenGui, StatusLabel
end

-- Função para atualizar estatísticas
function updateStats()
    local ScreenGui = game.CoreGui:FindFirstChild("AutoChestFarmUI")
    if not ScreenGui then return end
    
    local MainFrame = ScreenGui:FindFirstChild("MainFrame")
    if not MainFrame then return end
    
    local Content = MainFrame:FindFirstChild("Content")
    if not Content then return end
    
    local StatsFrame = Content:FindFirstChild("StatsFrame")
    if not StatsFrame then return end
    
    local ChestsCount = StatsFrame:FindFirstChild("ChestsCount")
    local MoneyCount = StatsFrame:FindFirstChild("MoneyCount")
    local TimeCount = StatsFrame:FindFirstChild("TimeCount")
    local FarmStatus = StatsFrame:FindFirstChild("FarmStatus")
    
    if ChestsCount then
        ChestsCount.Text = "📦 Baús: " .. settings.chestsCollected
    end
    
    if MoneyCount then
        MoneyCount.Text = "💰 Dinheiro: $" .. settings.moneyEarned
    end
    
    if TimeCount and settings.autoFarm then
        local elapsed = tick() - settings.startTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        TimeCount.Text = string.format("⏱️ Tempo: %02d:%02d", minutes, seconds)
    end
    
    if FarmStatus then
        FarmStatus.Text = "📈 Status: " .. (settings.autoFarm and (settings.paused and "Pausado" or "Ativo") or "Inativo")
    end
end

-- Sistema Anti-Stuck
local antiStuck = {
    lastPosition = nil,
    stuckTimer = 0,
    STUCK_THRESHOLD = 3
}

function antiStuck.check()
    if not character or not humanoidRootPart then return false end
    
    local currentPosition = humanoidRootPart.Position
    if antiStuck.lastPosition then
        local distance = (currentPosition - antiStuck.lastPosition).Magnitude
        if distance < 1 then
            antiStuck.stuckTimer = antiStuck.stuckTimer + 0.1
            if antiStuck.stuckTimer >= antiStuck.STUCK_THRESHOLD then
                -- Tentar pular para destravar
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                antiStuck.stuckTimer = 0
                return true
            end
        else
            antiStuck.stuckTimer = 0
        end
    end
    antiStuck.lastPosition = currentPosition
    return false
end

-- Sistema de busca de baús
local function findNearestChest()
    if tick() - lastCheck > CHECK_INTERVAL then
        chestCache = {}
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                if v:FindFirstChild("TouchInterest") or v:FindFirstChild("ClickDetector") then
                    table.insert(chestCache, v)
                end
            end
        end
        lastCheck = tick()
    end
    
    if #chestCache == 0 then return nil end
    
    local nearestChest = nil
    local shortestDistance = math.huge
    
    for _, chest in ipairs(chestCache) do
        if chest and chest.Parent and chest.Parent:FindFirstChild("Humanoid") == nil then
            local distance = (humanoidRootPart.Position - chest.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestChest = chest
            end
        end
    end
    
    return nearestChest
end

-- Sistema de movimento com Tween
local function moveToChest(chest)
    local targetPosition = chest.Position + Vector3.new(0, 2, 0)
    local distance = (humanoidRootPart.Position - targetPosition).Magnitude
    local tweenTime = distance / settings.tweenSpeed
    
    local tweenInfo = TweenInfo.new(
        math.clamp(tweenTime, 0.5, 5),
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    
    local success, error = pcall(function()
        tween:Play()
        tween.Completed:Wait()
    end)
    
    if not success then
        warn("Erro no Tween: " .. tostring(error))
        -- Fallback: teleportar
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
    end
    
    return success
end

-- Função para coletar baú
local function collectChest(chest)
    local success, error = pcall(function()
        -- Tentar através de TouchInterest
        local touchInterest = chest:FindFirstChild("TouchInterest")
        if touchInterest then
            firetouchinterest(humanoidRootPart, chest, 0)
            firetouchinterest(humanoidRootPart, chest, 1)
        end
        
        -- Tentar através de ClickDetector
        local clickDetector = chest:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
        end
        
        -- Tentar através de ProximityPrompt
        local proximity = chest:FindFirstChild("ProximityPrompt")
        if proximity then
            proximity:InputHoldBegin()
            wait(0.1)
            proximity:InputHoldEnd()
        end
    end)
    
    return success
end

-- Loop principal
local function autoFarmLoop()
    while settings.autoFarm do
        if not settings.paused and character and humanoidRootPart then
            local nearestChest = findNearestChest()
            
            if nearestChest then
                settings.currentStatus = "Movendo para o baú..."
                
                -- Mover até o baú
                local moveSuccess = moveToChest(nearestChest)
                
                if moveSuccess then
                    settings.currentStatus = "Coletando baú..."
                    wait(0.2)
                    
                    -- Coletar o baú
                    local collectSuccess = collectChest(nearestChest)
                    
                    if collectSuccess then
                        settings.chestsCollected = settings.chestsCollected + 1
                        -- Estimar dinheiro (valores típicos em Blox Fruits)
                        local moneyGain = math.random(500, 5000)
                        settings.moneyEarned = settings.moneyEarned + moneyGain
                        settings.currentStatus = "Baú coletado!"
                        
                        -- Aguardar o baú desaparecer
                        wait(1)
                    else
                        settings.currentStatus = "Erro na coleta - Retrying..."
                        wait(2)
                    end
                end
            else
                settings.currentStatus = "Procurando baús..."
                wait(2)
            end
            
   
