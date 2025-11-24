-- ROBLOX LAG FIX CHO NOKIA G21 (6GB RAM / 128GB ROM)
-- Script tối ưu cân bằng giữa hiệu suất và chất lượng hình ảnh
-- Tối ưu cho chip Unisoc T606 và màn hình 90Hz

print("🔧 Đang khởi động Lag Fix cho Nokia G21...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI ƯU CHO NOKIA G21 =====
local Config = {
    RenderDistance = 250, -- Tầm nhìn cao hơn nhờ RAM 6GB
    GraphicsQuality = 5, -- Chất lượng trung bình
    RemoveShadows = false, -- Giữ shadows nhẹ
    RemoveParticles = false, -- Giữ particles cơ bản
    RemoveDecals = false, -- Giữ decals
    OptimizeTextures = true, -- Tối ưu textures thay vì xóa
    OptimizeTerrain = true,
    TargetFPS = 60, -- Tối ưu cho màn hình 90Hz
    SmartCulling = true, -- Culling thông minh
    ReducePhysics = false, -- Giữ physics đầy đủ
    OptimizeAnimations = true,
}

-- ===== BIẾN THEO DÕI HIỆU SUẤT =====
local PerformanceMonitor = {
    CurrentFPS = 0,
    MemoryUsage = 0,
    LastCleanup = tick(),
}

-- ===== 1. TỐI ƯU ĐỒ HỌA CÂN BẰNG =====
local function OptimizeGraphics()
    print("📊 Đang tối ưu đồ họa cho Nokia G21...")
    
    -- Đặt chất lượng ở mức trung bình (tận dụng 6GB RAM)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
    
    -- Giữ shadows nhẹ cho đẹp hơn
    Lighting.GlobalShadows = true
    Lighting.Technology = Enum.Technology.ShadowMap -- ShadowMap nhẹ hơn Future
    Lighting.Brightness = 2
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 0.3
    
    -- Tối ưu các hiệu ứng ánh sáng
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") then
            effect.Intensity = 0.3
            effect.Threshold = 2
            effect.Size = 12
        elseif effect:IsA("BlurEffect") then
            effect.Size = math.min(effect.Size, 8)
        elseif effect:IsA("SunRaysEffect") then
            effect.Intensity = 0.05
        elseif effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false -- Tắt DoF vì ảnh hưởng hiệu suất
        end
    end
    
    print("✅ Đồ họa đã được tối ưu cân bằng")
end

-- ===== 2. TỐI ƯU HIỆU ỨNG THÔNG MINH =====
local function OptimizeEffects()
    print("🎨 Đang tối ưu hiệu ứng...")
    
    local particleCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Giảm intensity của particles thay vì xóa
        if obj:IsA("ParticleEmitter") then
            particleCount = particleCount + 1
            if particleCount > 50 then -- Giới hạn 50 particles cùng lúc
                obj.Enabled = false
            else
                obj.Rate = math.min(obj.Rate, 20)
                obj.Lifetime = NumberRange.new(
                    math.min(obj.Lifetime.Min, 3),
                    math.min(obj.Lifetime.Max, 5)
                )
            end
        end
        
        -- Tối ưu Trail effects
        if obj:IsA("Trail") then
            obj.Lifetime = math.min(obj.Lifetime, 2)
        end
        
        -- Tối ưu Material cho hiệu suất tốt hơn
        if obj:IsA("BasePart") then
            -- Không thay đổi material nhưng tối ưu properties
            obj.Reflectance = math.min(obj.Reflectance, 0.3)
            obj.CastShadow = (obj.Size.Magnitude > 10) -- Chỉ cast shadow cho objects lớn
            
            -- Giảm collision cho objects nhỏ không quan trọng
            if obj.Size.Magnitude < 2 and not obj:IsDescendantOf(Player.Character or {}) then
                obj.CanCollide = false
            end
        end
        
        -- Tối ưu textures
        if Config.OptimizeTextures and obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
        end
    end
    
    print("✅ Hiệu ứng đã được tối ưu")
end

-- ===== 3. SMART CULLING - TẦM NHÌN THÔNG MINH =====
local function SmartCulling()
    if not Config.SmartCulling then return end
    
    print("👁️ Đang kích hoạt Smart Culling...")
    
    local lastUpdate = tick()
    local cullingInterval = 0.5 -- Update mỗi 0.5 giây
    
    RunService.RenderStepped:Connect(function()
        if tick() - lastUpdate < cullingInterval then return end
        lastUpdate = tick()
        
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = Player.Character.HumanoidRootPart.Position
            local cameraPos = Camera.CFrame.Position
            local cameraLookVector = Camera.CFrame.LookVector
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj ~= Player.Character.HumanoidRootPart then
                    local distance = (obj.Position - playerPos).Magnitude
                    local toCameraVector = (obj.Position - cameraPos).Unit
                    local dotProduct = cameraLookVector:Dot(toCameraVector)
                    
                    -- Ẩn objects ngoài tầm nhìn hoặc không trong FOV
                    if distance > Config.RenderDistance or dotProduct < -0.2 then
                        if not obj:GetAttribute("OriginalTransparency") then
                            obj:SetAttribute("OriginalTransparency", obj.Transparency)
                        end
                        obj.Transparency = 1
                    else
                        local origTransparency = obj:GetAttribute("OriginalTransparency")
                        if origTransparency then
                            obj.Transparency = origTransparency
                        end
                    end
                end
            end
        end
    end)
    
    print("✅ Smart Culling đã được kích hoạt")
end

-- ===== 4. TỐI ƯU TERRAIN CHO NOKIA G21 =====
local function OptimizeTerrain()
    if Config.OptimizeTerrain then
        print("🏔️ Đang tối ưu địa hình...")
        
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true -- Giữ decoration nhờ RAM 6GB
            terrain.WaterReflectance = 0.5 -- Giữ phản chiếu nước vừa phải
            terrain.WaterTransparency = 0.3
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
        end
        
        print("✅ Địa hình đã được tối ưu")
    end
end

-- ===== 5. TỐI ƯU ANIMATIONS =====
local function OptimizeAnimations()
    if Config.OptimizeAnimations then
        print("💃 Đang tối ưu animations...")
        
        local function optimizeCharacterAnimations(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Giữ tốc độ animation bình thường
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track.Priority = Enum.AnimationPriority.Core
                end
                
                -- Giới hạn số animation tracks
                local tracks = humanoid:GetPlayingAnimationTracks()
                if #tracks > 8 then
                    for i = 9, #tracks do
                        tracks[i]:Stop()
                    end
                end
            end
        end
        
        if Player.Character then
            optimizeCharacterAnimations(Player.Character)
        end
        
        Player.CharacterAdded:Connect(function(character)
            task.wait(1)
            optimizeCharacterAnimations(character)
        end)
        
        print("✅ Animations đã được tối ưu")
    end
end

-- ===== 6. THEO DÕI HIỆU SUẤT =====
local function MonitorPerformance()
    print("📈 Đang kích hoạt Performance Monitor...")
    
    RunService.RenderStepped:Connect(function()
        -- Tính FPS
        PerformanceMonitor.CurrentFPS = math.floor(1 / RunService.RenderStepped:Wait())
        
        -- Lấy memory usage
        PerformanceMonitor.MemoryUsage = Stats:GetTotalMemoryUsageMb()
    end)
    
    -- Hiển thị FPS trên màn hình (tùy chọn)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PerformanceMonitor"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0, 150, 0, 60)
    FPSLabel.Position = UDim2.new(1, -160, 0, 10)
    FPSLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    FPSLabel.BackgroundTransparency = 0.5
    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    FPSLabel.TextSize = 16
    FPSLabel.Font = Enum.Font.SourceSansBold
    FPSLabel.Parent = ScreenGui
    
    task.spawn(function()
        while task.wait(0.5) do
            FPSLabel.Text = string.format(
                "FPS: %d\nRAM: %.0f MB\nPing: %d ms",
                PerformanceMonitor.CurrentFPS,
                PerformanceMonitor.MemoryUsage,
                Player:GetNetworkPing() * 1000
            )
            
            -- Đổi màu dựa trên FPS
            if PerformanceMonitor.CurrentFPS >= 50 then
                FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Xanh lá
            elseif PerformanceMonitor.CurrentFPS >= 30 then
                FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Vàng
            else
                FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Đỏ
            end
        end
    end)
    
    print("✅ Performance Monitor đã được kích hoạt")
end

-- ===== 7. MEMORY CLEANUP THÔNG MINH =====
local function SmartMemoryCleanup()
    print("🧹 Đang dọn dẹp bộ nhớ...")
    
    -- Cleanup cơ bản
    for i = 1, 2 do
        task.wait(0.1)
        collectgarbage("collect")
    end
    
    PerformanceMonitor.LastCleanup = tick()
    print("✅ Bộ nhớ đã được dọn dẹp")
end

-- ===== 8. ADAPTIVE QUALITY - TỰ ĐỘNG ĐIỀU CHỈNH =====
local function AdaptiveQuality()
    print("🎯 Đang kích hoạt Adaptive Quality...")
    
    task.spawn(function()
        while task.wait(5) do
            local fps = PerformanceMonitor.CurrentFPS
            
            -- Tự động giảm quality nếu FPS thấp
            if fps < 30 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
                Config.RenderDistance = 150
                print("⚠️ FPS thấp - Đã giảm quality")
            elseif fps > 50 then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
                Config.RenderDistance = 250
                print("✅ FPS tốt - Đã tăng quality")
            end
            
            -- Cleanup memory nếu quá cao
            if PerformanceMonitor.MemoryUsage > 2500 and 
               tick() - PerformanceMonitor.LastCleanup > 30 then
                SmartMemoryCleanup()
            end
        end
    end)
    
    print("✅ Adaptive Quality đã được kích hoạt")
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("=" .. string.rep("=", 60))
    print("🚀 ROBLOX LAG FIX CHO NOKIA G21")
    print("📱 Tối ưu cho 6GB RAM / 128GB ROM - Chip Unisoc T606")
    print("🖥️ Target: 60 FPS ổn định trên màn hình 90Hz")
    print("=" .. string.rep("=", 60))
    
    -- Chạy các tối ưu theo thứ tự
    OptimizeGraphics()
    task.wait(0.3)
    
    OptimizeEffects()
    task.wait(0.3)
    
    OptimizeTerrain()
    task.wait(0.3)
    
    SmartCulling()
    task.wait(0.3)
    
    OptimizeAnimations()
    task.wait(0.3)
    
    MonitorPerformance()
    task.wait(0.3)
    
    AdaptiveQuality()
    task.wait(0.3)
    
    SmartMemoryCleanup()
    
    -- Cleanup định kỳ (mỗi 90 giây)
    task.spawn(function()
        while task.wait(90) do
            SmartMemoryCleanup()
        end
    end)
    
    print("=" .. string.rep("=", 60))
    print("✅ TỐI ƯU HOÀN TẤT!")
    print("📊 Hiệu suất đã được tối ưu cho Nokia G21")
    print("🎮 FPS Monitor hiển thị ở góc phải trên")
    print("💡 Script tự động điều chỉnh quality theo FPS")
    print("🔄 Memory cleanup tự động mỗi 90 giây")
    print("=" .. string.rep("=", 60))
end

-- Chạy script
Initialize()