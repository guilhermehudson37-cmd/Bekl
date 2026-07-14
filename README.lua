-- GHub - Auto Farm Chest
-- Versão: v1.0

local GHub = {
    Nome = "GHub",
    Versao = "v1.0",
    AutoFarm = false,
    PararAoEncontrarItem = false,
    TempoCriacaoServidor = nil,
    BausColetados = 0,
    Baus = {},
    BausProibidos = {},
    ItensEncontrados = {},
    DistanciaMinima = 10,
    VelocidadeTween = 25,
    VelocidadeMinima = 10,
    VelocidadeMaxima = 50,
    Player = game.Players.LocalPlayer,
    Personagem = nil,
    Raiz = nil,
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInput = game:GetService("VirtualInputManager"),
}

-- FUNÇÕES AUXILIARES
function GHub:AtualizarPersonagem()
    self.Personagem = self.Player.Character
    if self.Personagem then
        self.Raiz = self.Personagem:FindFirstChild("HumanoidRootPart")
    end
end

function GHub:EncontrarBaus()
    local bausEncontrados = {}
    for _, objeto in ipairs(workspace:GetDescendants()) do
        if objeto:IsA("BasePart") and objeto.Name:lower():find("chest") and objeto:IsDescendantOf(workspace) then
            if objeto.Parent and objeto.Parent:FindFirstChild("Humanoid") == nil then
                local raiz = objeto:FindFirstChild("RootPart") or objeto
                if raiz and raiz.Position and not table.find(self.BausProibidos, raiz) then
                    table.insert(bausEncontrados, raiz)
                end
            end
        end
    end
    return bausEncontrados
end

function GHub:ObterBauMaisProximo()
    if not self.Raiz then return nil end
    local baus = self:EncontrarBaus()
    local melhorBau = nil
    local menorDistancia = math.huge
    local posicaoJogador = self.Raiz.Position

    for _, bau in ipairs(baus) do
        local distancia = (bau.Position - posicaoJogador).Magnitude
        if distancia < menorDistancia then
            menorDistancia = distancia
            melhorBau = bau
        end
    end

    return melhorBau
end

function GHub:VerificarItemNoBau(bau)
    if not bau then return false end
    
    -- Verifica se há algum item próximo ao baú
    for _, objeto in ipairs(workspace:GetDescendants()) do
        if objeto:IsA("BasePart") and objeto:FindFirstChild("Handle") then
            local distancia = (objeto.Position - bau.Position).Magnitude
            if distancia < 5 then
                return true
            end
        end
    end
    return false
end

function GHub:MoverParaBau(bau)
    if not bau or not self.Raiz then return end

    local posicaoAlvo = bau.Position + Vector3.new(0, 2, 0)
    local distancia = (posicaoAlvo - self.Raiz.Position).Magnitude

    if distancia > self.DistanciaMinima then
        local tempoViagem = math.clamp(distancia / self.VelocidadeTween, 1.5, 4)
        local tweenInfo = TweenInfo.new(
            tempoViagem,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )
        local tween = self.TweenService:Create(self.Raiz, tweenInfo, {CFrame = CFrame.new(posicaoAlvo)})
        tween:Play()
        tween.Completed:Wait()
        return true
    end
    return false
end

function GHub:ColetarBau(bau)
    if not bau or not self.Raiz then return end

    local distancia = (bau.Position - self.Raiz.Position).Magnitude
    if distancia < 8 then
        -- Verifica se há item no baú antes de coletar
        if self.PararAoEncontrarItem and self:VerificarItemNoBau(bau) then
            self.AutoFarm = false
            Interface:AtualizarStatus(false)
            return false
        end
        
        task.wait(0.2)
        self.VirtualInput:SendKeyEvent(true, "E", false, game)
        task.wait(0.15)
        self.VirtualInput:SendKeyEvent(false, "E", false, game)
        self.BausColetados = self.BausColetados + 1
        table.insert(self.BausProibidos, bau)
        task.wait(0.3)
        return true
    end
    return false
end

-- LOOP PRINCIPAL DO AUTO FARM
function GHub:ExecutarAutoFarm()
    while self.AutoFarm do
        self:AtualizarPersonagem()
        if not self.Personagem or not self.Raiz then
            task.wait(1)
            continue
        end

        local bau = self:ObterBauMaisProximo()
        if bau then
            self:MoverParaBau(bau)
            self:ColetarBau(bau)
        else
            task.wait(1)
        end
        task.wait(0.2)
    end
end

-- INTERFACE GRÁFICA (UI)
local Interface = {
    ScreenGui = nil,
    FramePrincipal = nil,
    FrameTopo = nil,
    Titulo = nil,
    Subtitulo = nil,
    BotaoMinimizar = nil,
    FrameConteudo = nil,
    FrameConteudoInterno = nil,
    BotaoToggle = nil,
    BotaoPararItem = nil,
    StatusAutoFarm = nil,
    StatusPararItem = nil,
    ContadorTempo = nil,
    ControleVelocidade = nil,
    LabelVelocidade = nil,
    SliderVelocidade = nil,
    FrameRodape = nil,
    Versao = nil,
    EstadoMinimizado = false,
}

function Interface:CriarUI()
    -- Criação da ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "GHubInterface"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game.CoreGui

    -- Frame Principal (Glassmorphism)
    self.FramePrincipal = Instance.new("Frame")
    self.FramePrincipal.Size = UDim2.new(0, 380, 0, 520)
    self.FramePrincipal.Position = UDim2.new(0.5, -190, 0.5, -260)
    self.FramePrincipal.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    self.FramePrincipal.BackgroundTransparency = 0.15
    self.FramePrincipal.BorderSizePixel = 0
    self.FramePrincipal.ClipsDescendants = true
    self.FramePrincipal.Parent = self.ScreenGui

    -- Efeito Glassmorphism
    local glassEffect = Instance.new("Frame")
    glassEffect.Size = UDim2.new(1, 0, 1, 0)
    glassEffect.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    glassEffect.BackgroundTransparency = 0.7
    glassEffect.BorderSizePixel = 0
    glassEffect.Parent = self.FramePrincipal

    -- Cantos arredondados e sombra
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 16)
    corners.Parent = self.FramePrincipal

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.Parent = self.FramePrincipal

    -- Frame Topo
    self.FrameTopo = Instance.new("Frame")
    self.FrameTopo.Size = UDim2.new(1, 0, 0, 80)
    self.FrameTopo.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    self.FrameTopo.BackgroundTransparency = 0.3
    self.FrameTopo.BorderSizePixel = 0
    self.FrameTopo.Parent = self.FramePrincipal

    local topoCorners = Instance.new("UICorner")
    topoCorners.CornerRadius = UDim.new(0, 16)
    topoCorners.Parent = self.FrameTopo

    -- Título GHub
    self.Titulo = Instance.new("TextLabel")
    self.Titulo.Size = UDim2.new(1, -50, 0, 40)
    self.Titulo.Position = UDim2.new(0, 0, 0, 10)
    self.Titulo.BackgroundTransparency = 1
    self.Titulo.Text = "GHub"
    self.Titulo.TextColor3 = Color3.fromRGB(150, 180, 255)
    self.Titulo.TextSize = 32
    self.Titulo.Font = Enum.Font.GothamBold
    self.Titulo.TextScaled = false
    self.Titulo.Parent = self.FrameTopo

    -- Botão Minimizar
    self.BotaoMinimizar = Instance.new("TextButton")
    self.BotaoMinimizar.Size = UDim2.new(0, 30, 0, 30)
    self.BotaoMinimizar.Position = UDim2.new(1, -40, 0, 10)
    self.BotaoMinimizar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    self.BotaoMinimizar.BackgroundTransparency = 0.3
    self.BotaoMinimizar.Text = "−"
    self.BotaoMinimizar.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.BotaoMinimizar.TextSize = 20
    self.BotaoMinimizar.Font = Enum.Font.GothamBold
    self.BotaoMinimizar.BorderSizePixel = 0
    self.BotaoMinimizar.Parent = self.FrameTopo

    local minCorners = Instance.new("UICorner")
    minCorners.CornerRadius = UDim.new(0, 8)
    minCorners.Parent = self.BotaoMinimizar

    -- Subtítulo
    self.Subtitulo = Instance.new("TextLabel")
    self.Subtitulo.Size = UDim2.new(1, 0, 0, 25)
    self.Subtitulo.Position = UDim2.new(0, 0, 0, 48)
    self.Subtitulo.BackgroundTransparency = 1
    self.Subtitulo.Text = "Auto Farm Chest"
    self.Subtitulo.TextColor3 = Color3.fromRGB(200, 200, 230)
    self.Subtitulo.TextSize = 16
    self.Subtitulo.Font = Enum.Font.GothamMedium
    self.Subtitulo.TextScaled = false
    self.Subtitulo.Parent = self.FrameTopo

    -- Frame Conteúdo (container principal)
    self.FrameConteudo = Instance.new("Frame")
    self.FrameConteudo.Size = UDim2.new(1, 0, 1, -120)
    self.FrameConteudo.Position = UDim2.new(0, 0, 0, 80)
    self.FrameConteudo.BackgroundTransparency = 1
    self.FrameConteudo.Parent = self.FramePrincipal

    -- Frame Conteúdo Interno (com padding)
    self.FrameConteudoInterno = Instance.new("Frame")
    self.FrameConteudoInterno.Size = UDim2.new(1, -40, 1, -20)
    self.FrameConteudoInterno.Position = UDim2.new(0, 20, 0, 0)
    self.FrameConteudoInterno.BackgroundTransparency = 1
    self.FrameConteudoInterno.Parent = self.FrameConteudo

    -- Botão Toggle (Ativar/Desativar Auto Farm)
    self.BotaoToggle = Instance.new("TextButton")
    self.BotaoToggle.Size = UDim2.new(0, 200, 0, 45)
    self.BotaoToggle.Position = UDim2.new(0.5, -100, 0, 5)
    self.BotaoToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    self.BotaoToggle.BackgroundTransparency = 0.3
    self.BotaoToggle.Text = "ATIVAR AUTO FARM"
    self.BotaoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.BotaoToggle.TextSize = 15
    self.BotaoToggle.Font = Enum.Font.GothamBold
    self.BotaoToggle.BorderSizePixel = 0
    self.BotaoToggle.Parent = self.FrameConteudoInterno

    local btnCorners = Instance.new("UICorner")
    btnCorners.CornerRadius = UDim.new(0, 8)
    btnCorners.Parent = self.BotaoToggle

    -- Botão Parar ao Encontrar Item
    self.BotaoPararItem = Instance.new("TextButton")
    self.BotaoPararItem.Size = UDim2.new(0, 200, 0, 35)
    self.BotaoPararItem.Position = UDim2.new(0.5, -100, 0, 60)
    self.BotaoPararItem.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    self.BotaoPararItem.BackgroundTransparency = 0.3
    self.BotaoPararItem.Text = "PARAR AO ENCONTRAR ITEM: OFF"
    self.BotaoPararItem.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.BotaoPararItem.TextSize = 13
    self.BotaoPararItem.Font = Enum.Font.GothamMedium
    self.BotaoPararItem.BorderSizePixel = 0
    self.BotaoPararItem.Parent = self.FrameConteudoInterno

    local pararCorners = Instance.new("UICorner")
    pararCorners.CornerRadius = UDim.new(0, 8)
    pararCorners.Parent = self.BotaoPararItem

    -- Status Auto Farm
    self.StatusAutoFarm = Instance.new("TextLabel")
    self.StatusAutoFarm.Size = UDim2.new(0, 150, 0, 25)
    self.StatusAutoFarm.Position = UDim2.new(0.5, -75, 0, 105)
    self.StatusAutoFarm.BackgroundTransparency = 1
    self.StatusAutoFarm.Text = "STATUS: OFF"
    self.StatusAutoFarm.TextColor3 = Color3.fromRGB(255, 80, 80)
    self.StatusAutoFarm.TextSize = 13
    self.StatusAutoFarm.Font = Enum.Font.GothamMedium
    self.StatusAutoFarm.Parent = self.FrameConteudoInterno

    -- Status Parar Item
    self.StatusPararItem = Instance.new("TextLabel")
    self.StatusPararItem.Size = UDim2.new(0, 150, 0, 25)
    self.StatusPararItem.Position = UDim2.new(0.5, -75, 0, 135)
    self.StatusPararItem.BackgroundTransparency = 1
    self.StatusPararItem.Text = "PARAR ITEM: OFF"
    self.StatusPararItem.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.StatusPararItem.TextSize = 12
    self.StatusPararItem.Font = Enum.Font.GothamMedium
    self.StatusPararItem.Parent = self.FrameConteudoInterno

    -- Controle de Velocidade
    self.ControleVelocidade = Instance.new("Frame")
    self.ControleVelocidade.Size = UDim2.new(1, 0, 0, 50)
    self.ControleVelocidade.Position = UDim2.new(0, 0, 0, 165)
    self.ControleVelocidade.BackgroundTransparency = 1
    self.ControleVelocidade.Parent = self.FrameConteudoInterno

    self.LabelVelocidade = Instance.new("TextLabel")
    self.LabelVelocidade.Size = UDim2.new(0, 80, 0, 20)
    self.LabelVelocidade.Position = UDim2.new(0, 0, 0, 0)
    self.LabelVelocidade.BackgroundTransparency = 1
    self.LabelVelocidade.Text = "VEL: 25"
    self.LabelVelocidade.TextColor3 = Color3.fromRGB(200, 200, 230)
    self.LabelVelocidade.TextSize = 12
    self.LabelVelocidade.Font = Enum.Font.GothamMedium
    self.LabelVelocidade.TextXAlignment = Enum.TextXAlignment.Left
    self.LabelVelocidade.Parent = self.ControleVelocidade

    -- Slider de Velocidade
    self.SliderVelocidade = Instance.new("Frame")
    self.SliderVelocidade.Size = UDim2.new(0, 200, 0, 4)
    self.SliderVelocidade.Position = UDim2.new(0, 0, 0, 25)
    self.SliderVelocidade.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    self.SliderVelocidade.BackgroundTransparency = 0.3
    self.SliderVelocidade.BorderSizePixel = 0
    self.SliderVelocidade.Parent = self.ControleVelocidade

    local sliderCorners = Instance.new("UICorner")
    sliderCorners.CornerRadius = UDim.new(0, 2)
    sliderCorners.Parent = self.SliderVelocidade

    -- Barra de progresso do slider
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0.5, 0, 1, 0)
    sliderBar.BackgroundColor3 = Color3.fromRGB(100, 130, 255)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = self.SliderVelocidade

    local barCorners = Instance.new("UICorner")
    barCorners.CornerRadius = UDim.new(0, 2)
    barCorners.Parent = sliderBar

    -- Botão do slider (arrastável)
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(0.5, -8, 0, -6)
    sliderButton.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
    sliderButton.BackgroundTransparency = 0.1
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = self.SliderVelocidade

    local btnSliderCorners = Instance.new("UICorner")
    btnSliderCorners.CornerRadius = UDim.new(0, 8)
    btnSliderCorners.Parent = sliderButton

    -- Tornar slider arrastável
    local sliderDragging = false
    sliderButton.MouseButton1Down:Connect(function()
        sliderDragging = true
    end)

    GHub.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    GHub.UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderPos = self.SliderVelocidade.AbsolutePosition
            local sliderSize = self.SliderVelocidade.AbsoluteSize.X
            local mouseX = input.Position.X - sliderPos.X
            local percentual = math.clamp(mouseX / sliderSize, 0, 1)
            
            GHub.VelocidadeTween = GHub.VelocidadeMinima + (GHub.VelocidadeMaxima - GHub.VelocidadeMinima) * percentual
            GHub.VelocidadeTween = math.round(GHub.VelocidadeTween)
            
            sliderBar.Size = UDim2.new(percentual, 0, 1, 0)
            sliderButton.Position = UDim2.new(percentual, -8, 0, -6)
            self.LabelVelocidade.Text = "VEL: " .. tostring(GHub.VelocidadeTween)
        end
    end)

    -- Contador de Tempo do Servidor
    self.ContadorTempo = Instance.new("TextLabel")
    self.ContadorTempo.Size = UDim2.new(0, 250, 0, 30)
    self.ContadorTempo.Position = UDim2.new(0.5, -125, 0, 220)
    self.ContadorTempo.BackgroundTransparency = 1
    self.ContadorTempo.Text = "SERVIDOR ATIVO: 00:00:00"
    self.ContadorTempo.TextColor3 = Color3.fromRGB(200, 200, 230)
    self.ContadorTempo.TextSize = 13
    self.ContadorTempo.Font = Enum.Font.GothamMedium
    self.ContadorTempo.Parent = self.FrameConteudoInterno

    -- Frame Rodapé
    self.FrameRodape = Instance.new("Frame")
    self.FrameRodape.Size = UDim2.new(1, 0, 0, 40)
    self.FrameRodape.Position = UDim2.new(0, 0, 1, -40)
    self.FrameRodape.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    self.FrameRodape.BackgroundTransparency = 0.5
    self.FrameRodape.BorderSizePixel = 0
    self.FrameRodape.Parent = self.FramePrincipal

    -- Versão
    self.Versao = Instance.new("TextLabel")
    self.Versao.Size = UDim2.new(1, 0, 1, 0)
    self.Versao.BackgroundTransparency = 1
    self.Versao.Text = "GHub v1.0"
    self.Versao.TextColor3 = Color3.fromRGB(150, 150, 180)
    self.Versao.TextSize = 12
    self.Versao.Font = Enum.Font.GothamMedium
    self.Versao.Parent = self.FrameRodape

    -- Configurar eventos
    self:ConfigurarEventos()
    self:TornarArrastavel()
end

function Interface:ConfigurarEventos()
    -- Botão Minimizar
    self.BotaoMinimizar.MouseButton1Click:Connect(function()
        self.EstadoMinimizado = not self.EstadoMinimizado
        if self.EstadoMinimizado then
            self.FrameConteudo.Visible = false
            self.FrameRodape.Visible = false
            self.FramePrincipal.Size = UDim2.new(0, 380, 0, 80)
            self.BotaoMinimizar.Text = "+"
        else
            self.FrameConteudo.Visible = true
            self.FrameRodape.Visible = true
            self.FramePrincipal.Size = UDim2.new(0, 380, 0, 520)
            self.BotaoMinimizar.Text = "−"
        end
    end)

    -- Botão Auto Farm
    self.BotaoToggle.MouseButton1Click:Connect(function()
        GHub.AutoFarm = not GHub.AutoFarm
        self:AtualizarStatus(GHub.AutoFarm)

        if GHub.AutoFarm then
            task.spawn(function()
                GHub:ExecutarAutoFarm()
            end)
        end
    end)

    -- Botão Parar ao Encontrar Item
    self.BotaoPararItem.MouseButton1Click:Connect(function()
        GHub.PararAoEncontrarItem = not GHub.PararAoEncontrarItem
        self:AtualizarStatusPararItem(GHub.PararAoEncontrarItem)
    end)
end

function Interface:TornarArrastavel()
    local dragging = false
    local dragInput, dragStart, startPos

    self.FrameTopo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.FramePrincipal.Position
        end
    end)

    self.FrameTopo.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    self.FrameTopo.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    GHub.UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            self.FramePrincipal.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Interface:AtualizarTempoServidor()
    if not GHub.TempoCriacaoServidor then return end
    
    local tempoDecorrido = os.time() - GHub.TempoCriacaoServidor
    local horas = string.format("%02d", math.floor(tempoDecorrido / 3600))
    local minutos = string.format("%02d", math.floor((tempoDecorrido % 3600) / 60))
    local segundos = string.format("%02d", tempoDecorrido % 60)
    self.ContadorTempo.Text = "SERVIDOR ATIVO: " .. horas .. ":" .. minutos .. ":" .. segundos
end

function Interface:AtualizarStatus(ativo)
    if ativo then
        self.StatusAutoFarm.Text = "STATUS: ON"
        self.StatusAutoFarm.TextColor3 = Color3.fromRGB(80, 255, 80)
        self.BotaoToggle.Text = "DESATIVAR AUTO FARM"
        self.BotaoToggle.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    else
        self.StatusAutoFarm.Text = "STATUS: OFF"
        self.StatusAutoFarm.TextCo
