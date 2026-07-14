-- GHub - Auto Farm Chest
-- Versão: v1.0

local GHub = {
    Nome = "GHub",
    Versao = "v1.0",
    AutoFarm = false,
    TempoCriacaoServidor = nil, -- Será definido ao iniciar
    BausColetados = 0,
    Baus = {},
    BausProibidos = {},
    DistanciaMinima = 10,
    VelocidadeTween = 25,
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
    FrameConteudo = nil,
    BotaoToggle = nil,
    StatusAutoFarm = nil,
    ContadorTempo = nil,
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
    self.FramePrincipal.Size = UDim2.new(0, 380, 0, 480)
    self.FramePrincipal.Position = UDim2.new(0.5, -190, 0.5, -240)
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
    self.Titulo.Size = UDim2.new(1, 0, 0, 40)
    self.Titulo.Position = UDim2.new(0, 0, 0, 10)
    self.Titulo.BackgroundTransparency = 1
    self.Titulo.Text = "GHub"
    self.Titulo.TextColor3 = Color3.fromRGB(150, 180, 255)
    self.Titulo.TextSize = 32
    self.Titulo.Font = Enum.Font.GothamBold
    self.Titulo.TextScaled = false
    self.Titulo.Parent = self.FrameTopo

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

    -- Frame Conteúdo
    self.FrameConteudo = Instance.new("Frame")
    self.FrameConteudo.Size = UDim2.new(1, -40, 1, -140)
    self.FrameConteudo.Position = UDim2.new(0, 20, 0, 100)
    self.FrameConteudo.BackgroundTransparency = 1
    self.FrameConteudo.Parent = self.FramePrincipal

    -- Botão Toggle (Ativar/Desativar)
    self.BotaoToggle = Instance.new("TextButton")
    self.BotaoToggle.Size = UDim2.new(0, 200, 0, 50)
    self.BotaoToggle.Position = UDim2.new(0.5, -100, 0, 20)
    self.BotaoToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    self.BotaoToggle.BackgroundTransparency = 0.3
    self.BotaoToggle.Text = "ATIVAR AUTO FARM"
    self.BotaoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.BotaoToggle.TextSize = 16
    self.BotaoToggle.Font = Enum.Font.GothamBold
    self.BotaoToggle.BorderSizePixel = 0
    self.BotaoToggle.Parent = self.FrameConteudo

    local btnCorners = Instance.new("UICorner")
    btnCorners.CornerRadius = UDim.new(0, 8)
    btnCorners.Parent = self.BotaoToggle

    -- Status Auto Farm
    self.StatusAutoFarm = Instance.new("TextLabel")
    self.StatusAutoFarm.Size = UDim2.new(0, 150, 0, 30)
    self.StatusAutoFarm.Position = UDim2.new(0.5, -75, 0, 90)
    self.StatusAutoFarm.BackgroundTransparency = 1
    self.StatusAutoFarm.Text = "STATUS: OFF"
    self.StatusAutoFarm.TextColor3 = Color3.fromRGB(255, 80, 80)
    self.StatusAutoFarm.TextSize = 14
    self.StatusAutoFarm.Font = Enum.Font.GothamMedium
    self.StatusAutoFarm.Parent = self.FrameConteudo

    -- Contador de Tempo do Servidor
    self.ContadorTempo = Instance.new("TextLabel")
    self.ContadorTempo.Size = UDim2.new(0, 200, 0, 30)
    self.ContadorTempo.Position = UDim2.new(0.5, -100, 0, 140)
    self.ContadorTempo.BackgroundTransparency = 1
    self.ContadorTempo.Text = "TEMPO SERVIDOR: 00:00:00"
    self.ContadorTempo.TextColor3 = Color3.fromRGB(200, 200, 230)
    self.ContadorTempo.TextSize = 14
    self.ContadorTempo.Font = Enum.Font.GothamMedium
    self.ContadorTempo.Parent = self.FrameConteudo

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

    -- Tornar arrastável
    self:TornarArrastavel()
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
    -- Calcula o tempo desde a criação do servidor
    local tempoDecorrido = os.time() - GHub.TempoCriacaoServidor
    local horas = string.format("%02d", math.floor(tempoDecorrido / 3600))
    local minutos = string.format("%02d", math.floor((tempoDecorrido % 3600) / 60))
    local segundos = string.format("%02d", tempoDecorrido % 60)
    self.ContadorTempo.Text = "TEMPO SERVIDOR: " .. horas .. ":" .. minutos .. ":" .. segundos
end

function Interface:AtualizarStatus(ativo)
    if ativo then
        self.StatusAutoFarm.Text = "STATUS: ON"
        self.StatusAutoFarm.TextColor3 = Color3.fromRGB(80, 255, 80)
        self.BotaoToggle.Text = "DESATIVAR AUTO FARM"
        self.BotaoToggle.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
    else
        self.StatusAutoFarm.Text = "STATUS: OFF"
        self.StatusAutoFarm.TextColor3 = Color3.fromRGB(255, 80, 80)
        self.BotaoToggle.Text = "ATIVAR AUTO FARM"
        self.BotaoToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    end
end

function Interface:ConfigurarBotoes()
    self.BotaoToggle.MouseButton1Click:Connect(function()
        GHub.AutoFarm = not GHub.AutoFarm
        self:AtualizarStatus(GHub.AutoFarm)

        if GHub.AutoFarm then
            task.spawn(function()
                GHub:ExecutarAutoFarm()
            end)
        end
    end)
end

-- INICIALIZAÇÃO
function GHub:Iniciar()
    -- Obtém o tempo de criação do servidor
    -- O servidor inicia quando o jogo é carregado, usamos o tempo atual como referência
    -- pois não temos acesso direto ao tempo de criação do servidor
    self.TempoCriacaoServidor = os.time()
    
    -- Tenta obter o tempo real de criação do servidor através do Datastore ou serviço
    -- Caso não seja possível, usa o tempo atual como referência
    pcall(function()
        -- Alguns jogos tem o tempo de criação do servidor armazenado
        local serverTime = game:GetService("ReplicatedStorage"):FindFirstChild("ServerStartTime")
        if serverTime and type(serverTime.Value) == "number" then
            self.TempoCriacaoServidor = serverTime.Value
        end
    end)

    -- Cria interface
    Interface:CriarUI()
    Interface:ConfigurarBotoes()

    -- Inicia contador de tempo do servidor
    task.spawn(function()
        while true do
            Interface:AtualizarTempoServidor()
            task.wait(1)
        end
    end)

    -- Atualiza personagem periodicamente
    task.spawn(function()
        while true do
            self:AtualizarPersonagem()
            task.wait(0.5)
        end
    end)

    -- Limpa lista de baús proibidos periodicamente
    task.spawn(function()
        while true do
            task.wait(300)
            self.BausProibidos = {}
        end
    end)

    print("GHub v1.0 - Auto Farm Chest carregado com sucesso!")
    print("Tempo de criação do servidor: " .. os.date("%d/%m/%Y %H:%M:%S", self.TempoCriacaoServidor))
end

-- Executa o script
GHub:Iniciar()
