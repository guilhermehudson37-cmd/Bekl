--[[
    Auto Farm Chest Script for Blox Fruits - VERSÃO CORRIGIDA
    Features:
    - Sistema de voo suave com BodyVelocity
    - Detecção em tempo real de baús
    - Coleta automática
    - Detecção de itens raros
    - Velocidade ajustável (10-50)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis
local isFarming = false
local checkRareItems = false
local flySpeed = 30
local currentTarget = nil
local isFlying = false
local bodyVelocity = nil
local collectedRareItems = {}
local chestCooldown = {}

-- Criar BodyVelocity para voo
function createFly()
    if bodyVelocity then bodyVelocity:Destroy() end
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = RootPart
    return bodyVelocity
end

-- Função para voar até posição
function flyToPosition(targetPos)
    if not targetPos or not RootPart then return false end
    
    if not bodyVelocity or bodyVelocity.Parent == nil then
        createFly()
    end
    
    local direction = (targetPos - RootPart.Position).Unit
    local distance = (targetPos - RootPart.Position).Magnitude
    
    if distance < 3 then
        return true
    end
    
    bodyVelocity.Velocity = direction * flySpeed * 2
    
    -- Pequeno hover para estabilidade
    if RootPart.Position.Y < targetPos.Y - 1 then
        bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, flySpeed * 0.5, 0)
    end
    
    return false
end

-- Função para encontrar baús
function findChests()
    local chests = {}
    local ignoreList = {"Sword", "Gun", "Fruit", "Accessory"}
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:find("Chest") then
            local isValid = true
            for _, ignore in ipairs(ignoreList) do
                if v.Name:find(ignore) then
                    isValid = false
                    break
                end
            end
            if isValid and v.Parent and v.Parent:FindFirstChild("TouchInterest") then
                table.insert(chests, v)
            end
        end
    end
    
    return chests
end

-- Função para encontrar o baú mais próximo
function getClosestChest()
    local chests = findChests()
    local closest = nil
    local minDist = math.huge
    local playerPos = RootPart.Position
    
    for _, chest in ipairs(chests) do
        if chest and chest.Parent and chest:IsA("BasePart") then
            -- Verificar se o baú está no cooldown
            if chestCooldown[chest] and chestCooldown[chest] > tick() then
                continue
            end
            
            local dist = (chest.Position - playerPos).Magnitude
            if dist < minDist and dist > 2 then
                minDist = dist
                closest = chest
            end
        end
    end
    
    return closest
end

-- Função para coletar baú
function collectChest(chest)
    if not chest or not chest.Parent then return false end
    
    currentTarget = chest
    
    -- Voar para o baú com offset
    local targetPos = chest.Position + Vector3.new(0, 3, 0)
    local startTime = tick()
    local maxAttempts = 30 -- 3 segundos
    
    while (RootPart.Position - chest.Position).Magnitude > 5 do
        if not isFarming then return false end
        if tick() - startTime > maxAttempts then break end
        
        flyToPosition(targetPos)
        RunService.Heartbeat:Wait()
    end
    
    -- Verificar itens raros após coletar
    if checkRareItems then
        wait(0.5) -- Dar tempo para o item aparecer no inventário
        local backpack = Player.Backpack
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if item.Name:find("Fist") or item.Name:find("Chalice") or 
                   item.Name:find("Darkness") or item.Name:find("God") then
                    StatusLabel.Text = "⚠️ ITEM RARO ENCONTRADO!"
                    isFarming = false
                    ToggleButton.Text = "▶️ Iniciar Farm"
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                    return false
                end
            end
        end
    end
    
    -- Colocar baú em cooldown
    chestCooldown[chest] = tick() + 5
    
    return true
end

-- Função principal de farm
function farmLoop()
    while isFarming do
        if not Character or not RootPart then
            wait(0.5)
            continue
        end
        
        -- Verificar se ainda está voando
        if bodyVelocity and bodyVelocity.Parent == nil then
            createFly()
        end
        
        local chest = getClosestChest()
        
        if chest then
            StatusLabel.Text = "📦 Coletando baú..."
            local success = collectChest(chest)
            if success then
                StatusLabel.Text = "✅ Baú coletado!"
            end
        else
            StatusLabel.Text = "⏳ Aguardando baús spawnarem..."
            -- Parar movimento quando não há baús
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        wait(0.1)
    end
    
    -- Parar voo quando desativar
    if bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

-- UI Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.Name = "AutoChestUI"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.85, 0, 0.5, -180)
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

local function createRoundedCorners(frame)
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = frame
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.8
end

createRoundedCorners(MainFrame)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.BackgroundTransparency = 0.2
Title.BorderColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "🚀 Auto Farm Chest"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Center
createRoundedCorners(Title)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Parent = MainFrame
ScrollContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ScrollContainer.BackgroundTransparency = 0.1
ScrollContainer.BorderColor3 = Color3.fromRGB(255, 255, 255)
ScrollContainer.BorderSizePixel = 0
ScrollContainer.Position = UDim2.new(0, 10, 0, 55)
ScrollContainer.Size = UDim2.new(1, -20, 1, -65)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollContainer
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Função para criar botão
local function createButton(parent, text, callback, isSpeedButton)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    button.BackgroundTransparency = 0.1
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(isSpeedButton and 0.18 or 1, 0, 0, isSpeedButton and 32 or 38)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = isSpeedButton and 12 or 15
    button.TextXAlignment = Enum.TextXAlignment.Center
    createRoundedCorners(button)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

-- Botão Toggle Farm
local ToggleButton = createButton(ScrollContainer, "▶️ Iniciar Farm", function()
    isFarming = not isFarming
    ToggleButton.Text = isFarming and "⏹️ Parar Farm" or "▶️ Iniciar Farm"
    ToggleButton.BackgroundColor3 = isFarming and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(45, 45, 65)
    
    if isFarming then
        StatusLabel.Text = "🔄 Iniciando Farm..."
        spawn(function()
            farmLoop()
        end)
    else
        StatusLabel.Text = "⏸️ Farm pausado"
        if bodyVelocity then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Botão Itens Raros
local RareItemToggle = createButton(ScrollContainer, "🔴 Parar em Itens Raros: OFF", function()
    checkRareItems = not checkRareItems
    RareItemToggle.Text = checkRareItems and "🟢 Parar em Itens Raros: ON" or "🔴 Parar em Itens Raros: OFF"
    RareItemToggle.BackgroundColor3 = checkRareItems and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(45, 45, 65)
end)

-- Container de Velocidade
local SpeedContainer = Instance.new("Frame")
SpeedContainer.Parent = ScrollContainer
SpeedContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedContainer.BackgroundTransparency = 0.1
SpeedContainer.BorderColor3 = Color3.fromRGB(255, 255, 255)
SpeedContainer.BorderSizePixel = 0
SpeedContainer.Size = UDim2.new(1, 0, 0, 45)
SpeedContainer.LayoutOrder = 3

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedContainer
SpeedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 5, 0, 2)
SpeedLabel.Size = UDim2.new(0.35, 0, 0.4, 0)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Text = "⚡ Velocidade: " .. flySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 13
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedButtons = {}
local speeds = {10, 20, 30, 40, 50}
for i, speed in ipairs(speeds) do
    local btn = createButton(SpeedContainer, tostring(speed), function()
        flySpeed = speed
        SpeedLabel.Text = "⚡ Velocidade: " .. flySpeed
        for _, b in ipairs(speedButtons) do
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
        
        -- Atualizar velocidade imediatamente
        if isFarming and bodyVelocity then
            bodyVelocity.MaxForce = Vector3.new(4000 + speed * 100, 4000 + speed * 100, 4000 + speed * 100)
        end
    end, true)
    btn.Position = UDim2.new(0.35 + (i-1) * 0.13, 0, 0.45, 0)
    btn.Size = UDim2.new(0.12, 0, 0.4, 0)
    btn.TextSize = 11
    table.insert(speedButtons, btn)
    
    if speed == flySpeed then
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    end
end

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ScrollContainer
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
StatusLabel.BackgroundTransparency = 0.1
StatusLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BorderSizePixel = 0
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "⏸️ Aguardando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.LayoutOrder = 4

-- Contador de Baús
local ChestCounter = Instance.new("TextLabel")
ChestCounter.Parent = ScrollContainer
ChestCounter.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ChestCounter.BackgroundTransparency = 0.1
ChestCounter.BorderColor3 = Color3.fromRGB(255, 255, 255)
ChestCounter.BorderSizePixel = 0
ChestCounter.Size = UDim2.new(1, 0, 0, 25)
ChestCounter.Font = Enum.Font.Gotham
ChestCounter.Text = "📦 Baús encontrados: 0"
ChestCounter.TextColor3 = Color3.fromRGB(200, 200, 200)
ChestCounter.TextSize = 12
ChestCounter.TextXAlignment = Enum.TextXAlignment.Center
ChestCounter.LayoutOrder = 5

-- Atualizar contador de baús
spawn(function()
    while wait(0.5) do
        if isFarming then
            local count = #findChests()
            ChestCounter.Text = "📦 Baús encontrados: " .. count
        end
    end
end)

-- Função de limpeza
local function cleanup()
    isFarming = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    ScreenGui:Destroy()
end

-- Lidar com recriação do personagem
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if isFarming then
        createFly()
    end
end)

-- Atalho de teclado (F para iniciar/parar)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        ToggleButton.MouseButton1Click:Fire()
    end
end)

print("✅ Auto Farm Chest carregado! Pressione F para iniciar/parar.")
