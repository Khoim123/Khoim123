-- Auto Shoot Brainrot Script
-- Tự động bắn tất cả brainrot trong game "Shoot a Brainrot"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Cấu hình
local Config = {
    Enabled = false,
    ShootDelay = 0.1, -- Độ trễ giữa các lần bắn (giây)
    MaxDistance = 1000, -- Khoảng cách tối đa để bắn (studs)
    AutoEquip = true, -- Tự động trang bị Sentinel
    TargetPart = "HumanoidRootPart" -- Phần cơ thể để nhắm
}

-- Biến toàn cục
local shootConnection = nil
local lastShootTime = 0

-- Hàm tìm tất cả brainrot trong workspace
local function getAllBrainrots()
    local brainrots = {}
    local workspace = game:GetService("Workspace")
    
    -- Tìm trong Workspace.Enemies hoặc Workspace.NPCs
    local enemiesFolder = workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("NPCs") or workspace
    
    for _, obj in pairs(enemiesFolder:GetDescendants()) do
        -- Kiểm tra xem có phải là brainrot không (có thể là Model hoặc NPC)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local humanoid = obj:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Kiểm tra tên có chứa "brainrot" hoặc các từ khóa liên quan
                local name = obj.Name:lower()
                if name:find("brainrot") or name:find("enemy") or name:find("npc") then
                    table.insert(brainrots, obj)
                end
            end
        end
    end
    
    return brainrots
end

-- Hàm tìm brainrot gần nhất
local function getNearestBrainrot()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local playerPos = character.HumanoidRootPart.Position
    local nearestBrainrot = nil
    local shortestDistance = Config.MaxDistance
    
    local brainrots = getAllBrainrots()
    
    for _, brainrot in pairs(brainrots) do
        local targetPart = brainrot:FindFirstChild(Config.TargetPart) or brainrot:FindFirstChild("Head")
        if targetPart then
            local distance = (playerPos - targetPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestBrainrot = brainrot
            end
        end
    end
    
    return nearestBrainrot, shortestDistance
end

-- Hàm tự động trang bị Sentinel
local function equipSentinel()
    if not Config.AutoEquip then return false end
    
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    if not character or not backpack then return false end
    
    -- Kiểm tra xem đã trang bị chưa
    if character:FindFirstChild("Sentinel") then
        return true
    end
    
    -- Tìm và trang bị Sentinel từ Backpack
    local sentinel = backpack:FindFirstChild("Sentinel")
    if sentinel then
        character.Humanoid:EquipTool(sentinel)
        task.wait(0.1)
        return true
    end
    
    return false
end

-- Hàm bắn brainrot (sử dụng ByteNet)
local function shootBrainrot(brainrot)
    if not brainrot or not brainrot:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    -- Kiểm tra cooldown
    local currentTime = tick()
    if currentTime - lastShootTime < Config.ShootDelay then
        return false
    end
    
    -- Trang bị vũ khí
    if not equipSentinel() then
        warn("Không thể trang bị Sentinel!")
        return false
    end
    
    -- Lấy vị trí mục tiêu
    local targetPos = brainrot.HumanoidRootPart.Position
    
    -- Tạo buffer data (có thể cần điều chỉnh dựa trên game)
    local bufferData = buffer.fromstring(
        "\\017X\\170M\\196\\004\\154y\\195\\173g\\255\\195\\249\\142\\ai\\161\\141tC\\004\\n\\216A\\aM)Cl\\180\\022\\179\\136\\173C>f\\248\\1382\\001\\000\\001\\0001\\001\\002"
    )
    
    -- Tạo args để bắn
    local args = {
        bufferData,
        {
            Instance.new("Part", nil), -- Có thể cần thay đổi
            player.Backpack:WaitForChild("Sentinel", 1) or player.Character:FindFirstChild("Sentinel")
        }
    }
    
    -- Bắn qua ByteNet
    local success, err = pcall(function()
        ReplicatedStorage:WaitForChild("ByteNetReliable"):FireServer(unpack(args))
    end)
    
    if success then
        lastShootTime = currentTime
        return true
    else
        warn("Lỗi khi bắn:", err)
        return false
    end
end

-- Hàm auto shoot loop
local function startAutoShoot()
    if shootConnection then
        shootConnection:Disconnect()
    end
    
    shootConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled then return end
        
        local nearestBrainrot, distance = getNearestBrainrot()
        
        if nearestBrainrot then
            local success = shootBrainrot(nearestBrainrot)
            if success then
                print(string.format("Đã bắn %s (Khoảng cách: %.1f studs)", nearestBrainrot.Name, distance))
            end
        end
    end)
end

-- Hàm dừng auto shoot
local function stopAutoShoot()
    if shootConnection then
        shootConnection:Disconnect()
        shootConnection = nil
    end
end

-- Tạo GUI đơn giản
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoShootBrainrotGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "🎯 Auto Shoot Brainrot"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    
    -- Toggle Button
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = MainFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "BẬT AUTO SHOOT"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.55, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Text = "🔴 Trạng thái: TẮT"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14
    
    -- Distance Slider
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Parent = MainFrame
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    DistanceLabel.Size = UDim2.new(1, 0, 0, 20)
    DistanceLabel.Font = Enum.Font.SourceSans
    DistanceLabel.Text = "Khoảng cách: " .. Config.MaxDistance .. " studs"
    DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DistanceLabel.TextSize = 12
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Toggle Button Click
    ToggleButton.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        
        if Config.Enabled then
            ToggleButton.Text = "TẮT AUTO SHOOT"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
            StatusLabel.Text = "🟢 Trạng thái: BẬT"
            startAutoShoot()
        else
            ToggleButton.Text = "BẬT AUTO SHOOT"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            StatusLabel.Text = "🔴 Trạng thái: TẮT"
            stopAutoShoot()
        end
    end)
    
    -- Close Button Click
    CloseButton.MouseButton1Click:Connect(function()
        Config.Enabled = false
        stopAutoShoot()
        ScreenGui:Destroy()
    end)
    
    -- Draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Khởi tạo
createGUI()
print("✅ Auto Shoot Brainrot đã được tải!")
print("📌 Nhấn nút 'BẬT AUTO SHOOT' để bắt đầu")
print("⚙️ Cấu hình:")
print("   - Khoảng cách tối đa:", Config.MaxDistance, "studs")
print("   - Độ trễ bắn:", Config.ShootDelay, "giây")
