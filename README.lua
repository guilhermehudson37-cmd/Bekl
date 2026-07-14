--[[
    GHub - Auto Farm Chest
    Versão: 1.0
    Plataforma: Roblox - Blox Fruits
    
    Script desenvolvido exclusivamente para sistema de Auto Farm Chest
    Interface premium com design Glassmorphism e Dark Mode
--]]

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Configurações
local GHub = {
    Player = Players.LocalPlayer,
    Character = nil,
    Humanoid = nil,
    HumanoidRootPart = nil,
    
    -- Estado do Auto Farm
    AutoFarmActive = false,
    StopOnItem = false,
    Speed = 25,
    ChestsCollected = 0,
    BlacklistedChests = {},
    TargetChest = nil,
    IsMoving = false,
    
    -- Tempo do servidor
    ServerStartTime = tick(),
    
    -- Interface
    UI = {
        MainFrame = nil,
        Minimized = false,
        Dragging = false,
        DragStart = nil,
        StartPosition = nil
    },
    
    -- Configurações do Tween
    TweenConfig = {
        MinTime = 1.5,
        MaxTime = 4,
        MinDistance = 10,
        CollectDistance = 8,
        EasingStyle = Enum.EasingStyle.Sine,
        EasingDirection = Enum.EasingDirection.InOut
    }
}

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

function GHub:GetCharacter()
    self.Character = self.Player.Character
    if self.Character then
        self.Humanoid = self.Character:FindFirstChild("Humanoid")
        self.HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    end
    return self.Character ~= nil
end

function GHub:GetAllChests()
    local chests = {}
    -- Busca por baús no workspace
    -- Adaptar conforme a nomenclatura dos baús no Blox Fruits
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("chest") or obj.Name:lower():find("baú") then
            -- Verificar se não está na lista de proibidos
            if not table.find(self.BlacklistedChests, obj) then
                table.insert(chests, obj)
            end
        end
    end
    return chests
end

function GHub:FindNearestChest(chests)
    if not self.HumanoidRootPart then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    local currentPos = self.HumanoidRootPart.Position
    
    for _, chest in pairs(chests) do
        if chest and chest:IsA("BasePart") and chest.Parent then
            local dist = (chest.Position - currentPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = chest
            end
        end
    end
    
    return nearest, nearestDist
end

function GHub:CalculateTweenTime(distance)
    local time = distance / self.Speed
    return math.clamp(time, self.TweenConfig.MinTime, self.TweenConfig.MaxTime)
end

function GHub:SimulateKeyPress(key)
    VirtualInputManager:SendKeyEvent(true, key, false, nil)
    task.wait(0.15)
    VirtualInputManager:SendKeyEvent(false, key, false, nil)
end

function GHub:GetServerTime()
    return tick() - self.ServerStartTime
end

function GHub:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- ============================================
-- LÓGICA DO AUTO FARM
-- ============================================

function GHub:ClearBlacklist()
    self.BlacklistedChests = {}
end

function GHub:CheckForItems(chest)
    -- Verifica se há itens próximos ao baú
    if not self.StopOnItem then return false end
    
    local items = {}
    -- Adaptar para procurar itens dropados no Blox Fruits
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("item") then
            if (obj.Position - chest.Position).Magnitude < 15 then
                table.insert(items, obj)
            end
        end
    end
    
    return #items > 0
end

function GHub:CollectChest(chest)
    if not chest or not chest.Parent then return false end
    
    -- Verificar distância
    if not self.HumanoidRootPart then return false end
    local dist = (chest.Position - self.HumanoidRootPart.Position).Magnitude
    
    if dist > self.TweenConfig.CollectDistance then
        return false
    end
    
    -- Delay humano
    task.wait(0.2)
    
    -- Coletar
    self:SimulateKeyPress(Enum.KeyCode.E)
    
    -- Delay após coleta
    task.wait(0.3)
    
    -- Adicionar à lista de proibidos
    table.insert(self.BlacklistedChests, chest)
    self.ChestsCollected = self.ChestsCollected + 1
    
    return true
end

function GHub:MoveToChest(chest)
    if not chest or not chest.Parent then return false end
    if not self.HumanoidRootPart then return false end
    
    local dist = (chest.Position - self.HumanoidRootPart.Position).Magnitude
    
    -- Verificar distância mínima
    if dist < self.TweenConfig.MinDistance then
        return true -- Já está perto
    end
    
    -- Calcular tempo de viagem
    local tweenTime = self:CalculateTweenTime(dist)
    
    -- Configurar Tween
    local tweenInfo = TweenInfo.new(
        tweenTime,
        self.TweenConfig.EasingStyle,
        self.TweenConfig.EasingDirection
    )
    
    local targetPosition = chest.Position + Vector3.new(0, 2, 0) -- Ajuste de altura
    local tween = TweenService:Create(
        self.HumanoidRootPart,
        tweenInfo,
        {CFrame = CFrame.new(targetPosition)}
    )
    
    self.IsMoving = true
    
    -- Executar Tween
    tween:Play()
    tween.Completed:Wait()
    
    self.IsMoving = false
    return true
end

function GHub:AutoFarmLoop()
    while self.AutoFarmActive do
        -- Verificar personagem
        if not self:GetCharacter() then
            task.wait(1)
            continue
        end
        
        -- Encontrar baús
        local chests = self:GetAllChests()
        
        if #chests == 0 then
            task.wait(1)
            continue
        end
        
        -- Selecionar baú mais próximo
        local target, distance = self:FindNearestChest(chests)
        
        if not target then
            task.wait(0.5)
            continue
        end
        
        self.TargetChest = target
        
        -- Mover para o baú
        local moved = self:MoveToChest(target)
        
        if not moved then
            task.wait(0.5)
            continue
        end
        
        -- Verificar itens (se ativado)
        if self:CheckForItems(target) then
            self.AutoFarmActive = false
            self:UpdateUIStatus()
            break
        end
        
        -- Coletar
        local collected = self:CollectChest(target)
        
        if not collected then
            -- Se não coletou, adicionar à lista de proibidos
            table.insert(self.BlacklistedChests, target)
        end
        
        -- Pequena pausa entre ações
        task.wait(0.2)
        
        -- Limpar lista de proibidos a cada 5 minutos
        if self.ChestsCollected % 20 == 0 then
            self:ClearBlacklist()
        end
    end
    
    self:UpdateUIStatus()
end

-- ============================================
-- INTERFACE GRÁFICA
-- ============================================

function GHub:CreateUI()
    -- Frame principal com Glassmorphism
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    mainFrame.BackgroundTransparency = 0.85
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = CoreGui
    
    -- Cantos arredondados e sombra
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Glassmorphism overlay
    local glassOverlay = Instance.new("Frame")
    glassOverlay.Size = UDim2.new(1, 0, 1, 0)
    glassOverlay.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
    glassOverlay.BackgroundTransparency = 0.7
    glassOverlay.BorderSizePixel = 0
    glassOverlay.Parent = mainFrame
    
    self.UI.MainFrame = mainFrame
    
    -- TOPO
    self:CreateTopSection(mainFrame)
    
    -- CONTEÚDO PRINCIPAL
    self:CreateContentSection(mainFrame)
    
    -- RODAPÉ
    self:CreateFooter(mainFrame)
    
    -- Tornar arrastável
    self:MakeDraggable(mainFrame)
    
    return mainFrame
end

function GHub:CreateTopSection(parent)
    local topFrame = Instance.new("Frame")
    topFrame.Size = UDim2.new(1, 0, 0, 80)
    topFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    topFrame.BackgroundTransparency = 0.3
    topFrame.BorderSizePixel = 0
    topFrame.Parent = parent
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "GHub"
    title.TextColor3 = Color3.fromRGB(150, 180, 255)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = topFrame
    
    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0, 0, 0, 42)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Auto Farm Chest"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 230)
    subtitle.TextSize = 16
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = topFrame
    
    -- Botão Minimizar
    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.new(0, 30, 0, 30)
    minButton.Position = UDim2.new(1, -40, 0, 5)
    minButton.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    minButton.BackgroundTransparency = 0.3
    minButton.Text = "−"
    minButton.TextColor3 = Color3.fromRGB(200, 200, 230)
    minButton.TextSize = 20
    minButton.Font = Enum.Font.GothamBold
    minButton.BorderSizePixel = 0
    minButton.Parent = topFrame
    
    -- Corner do botão
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = minButton
    
    minButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
end

function GHub:CreateContentSection(parent)
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -120)
    contentFrame.Position = UDim2.new(0, 0, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = parent
    
    -- ScrollingFrame para conteúdo rolável
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(108, 140, 255)
    scrollFrame.Parent = contentFrame
    
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 0, 400)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = scrollFrame
    
    -- Botão Auto Farm
    local autoFarmButton = Instance.new("TextButton")
    autoFarmButton.Size = UDim2.new(0, 200, 0, 45)
    autoFarmButton.Position = UDim2.new(0.5, -100, 0, 10)
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    autoFarmButton.BackgroundTransparency = 0.3
    autoFarmButton.Text = "ATIVAR AUTO FARM"
    autoFarmButton.TextColor3 = Color3.fromRGB(200, 200, 230)
    autoFarmButton.TextSize = 14
    autoFarmButton.Font = Enum.Font.GothamBold
    autoFarmButton.BorderSizePixel = 0
    autoFarmButton.Parent = contentContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = autoFarmButton
    
    -- Botão Parar ao Encontrar Item
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0, 200, 0, 35)
    stopButton.Position = UDim2.new(0.5, -100, 0, 65)
    stopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    stopButton.BackgroundTransparency = 0.3
    stopButton.Text = "PARAR AO ENCONTRAR ITEM: OFF"
    stopButton.TextColor3 = Color3.fromRGB(200, 200, 230)
    stopButton.TextSize = 13
    stopButton.Font = Enum.Font.GothamMedium
    stopButton.BorderSizePixel = 0
    stopButton.Parent = contentContainer
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 12)
    stopCorner.Parent = stopButton
    
    -- Status Auto Farm
    local statusAuto = Instance.new("TextLabel")
    statusAuto.Size = UDim2.new(0, 150, 0, 25)
    statusAuto.Position = UDim2.new(0.5, -75, 0, 110)
    statusAuto.BackgroundTransparency = 1
    statusAuto.Text = "STATUS: OFF"
    statusAuto.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusAuto.TextSize = 13
    statusAuto.Font = Enum.Font.GothamMedium
    statusAuto.TextXAlignment = Enum.TextXAlignment.Center
    statusAuto.Parent = contentContainer
    
    -- Status Parar Item
    local statusStop = Instance.new("TextLabel")
    statusStop.Size = UDim2.new(0, 150, 0, 25)
    statusStop.Position = UDim2.new(0.5, -75, 0, 140)
    statusStop.BackgroundTransparency = 1
    statusStop.Text = "PARAR ITEM: OFF"
    statusStop.TextColor3 = Color3.fromRGB(200, 200, 230)
    statusStop.TextSize = 12
    statusStop.Font = Enum.Font.GothamMedium
    statusStop.TextXAlignment = Enum.TextXAlignment.Center
    statusStop.Parent = contentContainer
    
    -- Controle de Velocidade
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 200, 0, 20)
    speedLabel.Position = UDim2.new(0.5, -100, 0, 175)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "VEL: 25"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
    speedLabel.TextSize = 13
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextXAlignment = Enum.TextXAlignment.Center
    speedLabel.Parent = contentContainer
    
    -- Slider
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 200, 0, 20)
    sliderFrame.Position = UDim2.new(0.5, -100, 0, 200)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    sliderFrame.BackgroundTransparency = 0.3
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = contentContainer
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderFrame
    
    -- Progresso do slider
    local sliderProgress = Instance.new("Frame")
    sliderProgress.Size = UDim2.new(0.5, 0, 1, 0)
    sliderProgress.BackgroundColor3 = Color3.fromRGB(100, 130, 255)
    sliderProgress.BorderSizePixel = 0
    sliderProgress.Parent = sliderFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = sliderProgress
    
    -- Botão do slider
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(0.5, -8, 0, 2)
    sliderButton.BackgroundColor3 = Color3.fromRGB(108, 140, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = sliderButton
    
    -- Contador de Tempo do Servidor
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 250, 0, 30)
    timeLabel.Position = UDim2.new(0.5, -125, 0, 235)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "SERVIDOR ATIVO: 00:00:00"
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
    timeLabel.TextSize = 13
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextXAlignment = Enum.TextXAlignment.Center
    timeLabel.Parent = contentContainer
    
    -- ============================================
    -- EVENTOS DA INTERFACE
    -- ============================================
    
    -- Auto Farm Button
    autoFarmButton.MouseButton1Click:Connect(function()
        self.AutoFarmActive = not self.AutoFarmActive
        
        if self.AutoFarmActive then
            autoFarmButton.Text = "DESATIVAR AUTO FARM"
            autoFarmButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusAuto.Text = "STATUS: ON"
            statusAuto.TextColor3 = Color3.fromRGB(80, 255, 80)
            
            -- Iniciar loop em uma thread separada
            task.spawn(function()
                self:AutoFarmLoop()
            end)
        else
            autoFarmButton.Text = "ATIVAR AUTO FARM"
            autoFarmButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            autoFarmButton.TextColor3 = Color3.fromRGB(200, 200, 230)
            statusAuto.Text = "STATUS: OFF"
            statusAuto.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
    
    -- Stop on Item Button
    stopButton.MouseButton1Click:Connect(function()
        self.StopOnItem = not self.StopOnItem
        
        if self.StopOnItem then
            stopButton.Text = "PARAR AO ENCONTRAR ITEM: ON"
            stopButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            statusStop.Text = "PARAR ITEM: ON"
            statusStop.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            stopButton.Text = "PARAR AO ENCONTRAR ITEM: OFF"
            stopButton.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            statusStop.Text = "PARAR ITEM: OFF"
            statusStop.TextColor3 = Color3.fromRGB(200, 200, 230)
        end
    end)
    
    -- Slider Interativo
    local isDragging = false
    local sliderValue = 25
    
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local sliderPos = sliderFrame.AbsolutePosition
            local sliderSize = sliderFrame.AbsoluteSize
            
            local relativeX = (mousePos.X - sliderPos.X) / sliderSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            sliderValue = math.floor(relativeX * 40 + 10)
            sliderValue = math.clamp(sliderValue, 10, 50)
            
            -- Atualizar slider
            sliderProgress.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(relativeX, -8, 0, 2)
            
            -- Atualizar label
            speedLabel.Text = "VEL: " .. tostring(sliderValue)
            
            -- Atualizar velocidade
            self.Speed = sliderValue
        end
    end)
    
    -- Armazenar referências para atualização
    self.UI.AutoFarmButton = autoFarmButton
    self.UI.StopButton = stopButton
    self.UI.StatusAuto = statusAuto
    self.UI.S
