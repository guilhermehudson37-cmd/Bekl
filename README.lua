--[[
    Auto Farm Chest Script for Blox Fruits
    Features:
    - Smooth Tween/Fly movement
    - Real-time chest detection and collection
    - Rare item detection (Fist of Darkness, God's Chalice)
    - Adjustable fly speed (10-50)
    - Clean and modern UI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variables
local Chests = {}
local isFarming = false
local isPaused = false
local currentTarget = nil
local flySpeed = 30
local collectedRareItems = {}

-- UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.Name = "AutoChestUI"

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.85, 0, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.ClipsDescendants = true
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
Title.BackgroundTransparency = 0.1
Title.BorderColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Auto Farm Chest"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Center
createRoundedCorners(Title)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Parent = MainFrame
ScrollContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ScrollContainer.BackgroundTransparency = 0.1
ScrollContainer.BorderColor3 = Color3.fromRGB(255, 255, 255)
ScrollContainer.BorderSizePixel = 0
ScrollContainer.Position = UDim2.new(0, 10, 0, 50)
ScrollContainer.Size = UDim2.new(1, -20, 1, -60)
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollContainer
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

local function createButton(parent, text, callback, isSpeedButton)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    button.BackgroundTransparency = 0.1
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(isSpeedButton and 0.18 or 1, 0, 0, isSpeedButton and 30 or 35)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = isSpeedButton and 12 or 14
    button.TextXAlignment = Enum.TextXAlignment.Center
    createRoundedCorners(button)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

-- Toggle Button
local ToggleButton = createButton(ScrollContainer, "Start Farming", function()
    isFarming = not isFarming
    ToggleButton.Text = isFarming and "Stop Farming" or "Start Farming"
    ToggleButton.BackgroundColor3 = isFarming and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(45, 45, 65)
    if isFarming then
        startFarming()
    else
        stopFarming()
    end
end)

-- Rare Item Toggle
local RareItemToggle = createButton(ScrollContainer, "Stop on Rare Items: OFF", function()
    checkRareItems = not checkRareItems
    RareItemToggle.Text = "Stop on Rare Items: " .. (checkRareItems and "ON" or "OFF")
    RareItemToggle.BackgroundColor3 = checkRareItems and Color3.fromRGB(70, 255, 70) or Color3.fromRGB(45, 45, 65)
end)

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Parent = ScrollContainer
SpeedContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpeedContainer.BackgroundTransparency = 0.1
SpeedContainer.BorderColor3 = Color3.fromRGB(255, 255, 255)
SpeedContainer.BorderSizePixel = 0
SpeedContainer.Size = UDim2.new(1, 0, 0, 40)
SpeedContainer.LayoutOrder = 3

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedContainer
SpeedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 5, 0, 0)
SpeedLabel.Size = UDim2.new(0.3, 0, 1, 0)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Text = "Speed: " .. flySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedButtons = {}
local speeds = {10, 20, 30, 40, 50}
for i, speed in ipairs(speeds) do
    local btn = createButton(SpeedContainer, tostring(speed), function()
        flySpeed = speed
        SpeedLabel.Text = "Speed: " .. flySpeed
        for _, b in ipairs(speedButtons) do
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    end, true)
    btn.Position = UDim2.new(0.3 + (i-1) * 0.14, 0, 0.05, 0)
    btn.Size = UDim2.new(0.12, 0, 0.9, 0)
    btn.TextSize = 10
    table.insert(speedButtons, btn)
    
    if speed == flySpeed then
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    end
end

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = ScrollContainer
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
StatusLabel.BackgroundTransparency = 0.1
StatusLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.BorderSizePixel = 0
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.LayoutOrder = 4

-- Functions
function findChests()
    local chests = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:find("Chest") then
            if v:FindFirstChild("TouchInterest") then
                table.insert(chests, v)
            end
        end
    end
    return chests
end

function getClosestChest()
    local closest = nil
    local minDist = math.huge
    local playerPos = RootPart.Position
    
    for _, chest in ipairs(findChests()) do
        if chest and chest:IsA("BasePart") and chest.Parent then
            local dist = (chest.Position - playerPos).Magnitude
            if dist < minDist then
                minDist = dist
                closest = chest
            end
        end
    end
    
    return closest
end

function flyToPosition(targetPos)
    if not targetPos then return end
    
    local tweenInfo = TweenInfo.new(
        (RootPart.Position - targetPos).Magnitude / flySpeed,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(RootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    
    -- Keep flying with slight hover
    while tween.PlaybackState ~= Enum.PlaybackState.Completed do
        if not isFarming then break end
        RunService.Heartbeat:Wait()
    end
end

function collectChest(chest)
    if not chest or not chest.Parent then return false end
    
    -- Fly to chest with slight offset
    local offset = Vector3.new(0, 2, 0)
    local targetPos = chest.Position + offset
    flyToPosition(targetPos)
    
    -- Check for rare items
    if checkRareItems then
        local backpack = Player.Backpack
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Fist") or item.Name:find("Chalice")) then
                StatusLabel.Text = "Rare item found! Pausing..."
                isFarming = false
                ToggleButton.Text = "Start Farming"
                ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                return false
            end
        end
    end
    
    return true
end

function startFarming()
    if isFarming then
        StatusLabel.Text = "Status: Farming..."
        farmLoop()
    end
end

function stopFarming()
    isFarming = false
    StatusLabel.Text = "Status: Stopped"
end

function farmLoop()
    if not isFarming then return end
    
    local chest = getClosestChest()
    if chest then
        StatusLabel.Text = "Status: Moving to chest..."
        local success = collectChest(chest)
        if success then
            StatusLabel.Text = "Status: Chest collected!"
        end
    else
        StatusLabel.Text = "Status: No chests found, waiting..."
        wait(0.5)
    end
    
    -- Small delay to avoid lag
    wait(0.1)
    
    -- Continue loop
    if isFarming then
        spawn(farmLoop)
    end
end

-- Cleanup function
local function cleanup()
    isFarming = false
    ScreenGui:Destroy()
end

-- Safe disconnect
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    if isFarming then
        startFarming()
    end
end)

-- Status update for UI
spawn(function()
    while wait(0.5) do
        if isFarming then
            local chestCount = #findChests()
            StatusLabel.Text = "Status: Farming... (" .. chestCount .. " chests found)"
        end
    end
end)

-- Load script successfully
print("Auto Farm Chest script loaded successfully!")
