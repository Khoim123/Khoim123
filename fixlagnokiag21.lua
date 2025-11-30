-- NOKIA G21 ULTRA PERFORMANCE OPTIMIZER V3.0
-- Tối ưu cho 6GB RAM / 128GB ROM / Unisoc T606 / Màn hình 90Hz
-- Cân bằng hoàn hảo giữa hiệu suất và chất lượng hình ảnh

print("🔧 Khởi động Ultra Performance Optimizer v3.0...")

-- ===== SERVICES =====
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI ƯU CHO NOKIA G21 =====
local Config = {
    -- Graphics Settings
    RenderDistance = 280,
    GraphicsQuality = 6,
    ShadowQuality = "Medium",
    ParticleLimit = 75,
    TextureQuality = "High",
    
    -- Performance Targets
    TargetFPS = 70,          -- Target 70 FPS cho màn hình 90Hz
    MinFPS = 50,             -- FPS tối thiểu trước khi giảm quality
    MaxFPS = 90,             -- Giới hạn tối đa
    
    -- Features
    SmartCulling = true,
    AdaptiveQuality = true,
    DynamicLOD = true,       -- Level of Detail động
    AdvancedPhysics = true,   -- Physics nâng cao
    PerformanceMonitor = true,
    AutoMemoryManagement = true,
    SmoothAnimations = true,
    
    -- Intervals
    CullingInterval = 0.3,
    MonitorInterval = 0.5,
    CleanupInterval = 60,
    AdaptiveInterval = 3,
}

-- ===== BIẾN TOÀN CỤC =====
local PerformanceData = {
    CurrentFPS = 60,
    AverageFPS = 60,
    MemoryUsage = 0,
    DrawCalls = 0,
    ActiveParts = 0,
    LastCleanup = tick(),
    FPSHistory = {},
    QualityLevel = Config.GraphicsQuality,
}

local OptimizationCache = {
    CulledObjects = {},
    LODObjects = {},
    OriginalProperties = {},
}

-- ===== UTILITY FUNCTIONS =====
local function SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Error:", result)
    end
    return success, result
end

local function GetAverageFPS()
    local sum = 0
    for _, fps in ipairs(PerformanceData.FPSHistory) do
        sum = sum + fps
    end
    return #PerformanceData.FPSHistory > 0 and sum / #PerformanceData.FPSHistory or 60
end

-- ===== 1. ĐỒ HỌA TỐI ƯU THÔNG MINH =====
local function OptimizeGraphics()
    print("📊 Tối ưu đồ họa thông minh cho Nokia G21...")
    
    SafeExecute(function()
        -- Đặt quality level phù hợp với 6GB RAM
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level06
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level02
        
        -- Shadows chất lượng trung bình
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.ShadowMap
        Lighting.Brightness = 2.5
        Lighting.EnvironmentDiffuseScale = 0.6
        Lighting.EnvironmentSpecularScale = 0.4
        Lighting.ShadowSoftness = 0.2
        
        -- Tối ưu lighting cho hiệu suất
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        
        -- Tối ưu fog
        if Lighting.FogEnd < 1000 then
            Lighting.FogEnd = math.max(Lighting.FogEnd, 500)
        end
        
        -- Tối ưu hiệu ứng post-processing
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") then
                effect.Enabled = true
                effect.Intensity = math.min(effect.Intensity, 0.4)
                effect.Threshold = math.max(effect.Threshold, 1.5)
                effect.Size = math.min(effect.Size, 16)
            elseif effect:IsA("BlurEffect") then
                effect.Size = math.min(effect.Size, 6)
            elseif effect:IsA("SunRaysEffect") then
                effect.Intensity = math.min(effect.Intensity, 0.08)
                effect.Spread = math.min(effect.Spread, 0.5)
            elseif effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = true
            elseif effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
    end)
    
    print("✅ Đồ họa đã được tối ưu thông minh")
end

-- ===== 2. DYNAMIC LOD SYSTEM =====
local function InitializeDynamicLOD()
    if not Config.DynamicLOD then return end
    
    print("🎯 Khởi động Dynamic LOD System...")
    
    local LODDistances = {
        High = Config.RenderDistance * 0.3,
        Medium = Config.RenderDistance * 0.6,
        Low = Config.RenderDistance,
    }
    
    local lastLODUpdate = tick()
    
    RunService.Heartbeat:Connect(function()
        if tick() - lastLODUpdate < 0.5 then return end
        lastLODUpdate = tick()
        
        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end
        
        local playerPos = Player.Character.HumanoidRootPart.Position
        local partsOptimized = 0
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                SafeExecute(function()
                    local distance = (obj.Position - playerPos).Magnitude
                    
                    -- Lưu properties gốc
                    if not OptimizationCache.OriginalProperties[obj] then
                        OptimizationCache.OriginalProperties[obj] = {
                            RenderFidelity = obj.RenderFidelity,
                            CastShadow = obj.CastShadow,
                        }
                    end
                    
                    -- Áp dụng LOD
                    if distance < LODDistances.High then
                        obj.RenderFidelity = Enum.RenderFidelity.Precise
                        obj.CastShadow = true
                    elseif distance < LODDistances.Medium then
                        obj.RenderFidelity = Enum.RenderFidelity.Automatic
                        obj.CastShadow = true
                    elseif distance < LODDistances.Low then
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                        obj.CastShadow = false
                    else
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                        obj.CastShadow = false
                    end
                    
                    partsOptimized = partsOptimized + 1
                end)
            end
        end
        
        PerformanceData.ActiveParts = partsOptimized
    end)
    
    print("✅ Dynamic LOD System đã khởi động")
end

-- ===== 3. SMART CULLING NÂNG CAO =====
local function AdvancedSmartCulling()
    if not Config.SmartCulling then return end
    
    print("👁️ Khởi động Advanced Smart Culling...")
    
    local lastUpdate = tick()
    
    RunService.RenderStepped:Connect(function()
        if tick() - lastUpdate < Config.CullingInterval then return end
        lastUpdate = tick()
        
        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end
        
        local playerPos = Player.Character.HumanoidRootPart.Position
        local cameraPos = Camera.CFrame.Position
        local cameraLook = Camera.CFrame.LookVector
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj ~= Player.Character.HumanoidRootPart then
                SafeExecute(function()
                    local objPos = obj.Position
                    local distance = (objPos - playerPos).Magnitude
                    
                    -- Frustum culling
                    local toCamera = (objPos - cameraPos).Unit
                    local dotProduct = cameraLook:Dot(toCamera)
                    local inFrustum = dotProduct > -0.3
                    
                    -- Distance culling
                    local inRange = distance <= Config.RenderDistance
                    
                    -- Lưu transparency gốc
                    if not obj:GetAttribute("OrigTrans") then
                        obj:SetAttribute("OrigTrans", obj.Transparency)
                    end
                    
                    -- Áp dụng culling
                    if not inRange or not inFrustum then
                        OptimizationCache.CulledObjects[obj] = true
                        obj.Transparency = 1
                    else
                        if OptimizationCache.CulledObjects[obj] then
                            obj.Transparency = obj:GetAttribute("OrigTrans") or 0
                            OptimizationCache.CulledObjects[obj] = nil
                        end
                    end
                end)
            end
        end
    end)
    
    print("✅ Advanced Smart Culling đã khởi động")
end

-- ===== 4. TỐI ƯU HIỆU ỨNG THÔNG MINH =====
local function OptimizeEffectsIntelligent()
    print("🎨 Tối ưu hiệu ứng thông minh...")
    
    local particleCount = 0
    local effectsOptimized = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeExecute(function()
            -- Particle Effects
            if obj:IsA("ParticleEmitter") then
                particleCount = particleCount + 1
                
                if particleCount > Config.ParticleLimit then
                    obj.Enabled = false
                else
                    obj.Enabled = true
                    obj.Rate = math.min(obj.Rate, 30)
                    obj.Lifetime = NumberRange.new(
                        math.min(obj.Lifetime.Min, 4),
                        math.min(obj.Lifetime.Max, 6)
                    )
                end
                effectsOptimized = effectsOptimized + 1
            end
            
            -- Trail Effects
            if obj:IsA("Trail") then
                obj.Lifetime = math.min(obj.Lifetime, 3)
                effectsOptimized = effectsOptimized + 1
            end
            
            -- Light Sources
            if obj:IsA("PointLight") or obj:IsA("SpotLight") then
                obj.Brightness = math.min(obj.Brightness, 3)
                obj.Range = math.min(obj.Range, 40)
                obj.Shadows = (obj.Brightness > 1.5)
                effectsOptimized = effectsOptimized + 1
            end
            
            -- BasePart optimization
            if obj:IsA("BasePart") then
                obj.Reflectance = math.min(obj.Reflectance, 0.4)
                
                -- Shadow optimization
                if obj.Size.Magnitude < 5 then
                    obj.CastShadow = false
                end
                
                -- Collision optimization
                if obj.Size.Magnitude < 1.5 and not obj:IsDescendantOf(Player.Character or {}) then
                    obj.CanCollide = false
                end
            end
        end)
    end
    
    print("✅ Đã tối ưu " .. effectsOptimized .. " hiệu ứng")
end

-- ===== 5. TỐI ƯU TERRAIN =====
local function OptimizeTerrain()
    print("🏔️ Tối ưu địa hình...")
    
    SafeExecute(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true
            terrain.WaterReflectance = 0.6
            terrain.WaterTransparency = 0.25
            terrain.WaterWaveSize = 0.2
            terrain.WaterWaveSpeed = 12
        end
    end)
    
    print("✅ Địa hình đã được tối ưu")
end

-- ===== 6. ANIMATION OPTIMIZER =====
local function OptimizeAnimations()
    if not Config.SmoothAnimations then return end
    
    print("💃 Tối ưu animations...")
    
    local function optimizeCharacter(character)
        SafeExecute(function()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Giữ animation smooth
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track.Priority = Enum.AnimationPriority.Core
            end
            
            -- Giới hạn số lượng tracks
            local tracks = humanoid:GetPlayingAnimationTracks()
            if #tracks > 10 then
                for i = 11, #tracks do
                    tracks[i]:Stop()
                end
            end
            
            -- Tối ưu humanoid properties
            humanoid.HealthDisplayDistance = 100
            humanoid.NameDisplayDistance = 100
        end)
    end
    
    if Player.Character then
        optimizeCharacter(Player.Character)
    end
    
    Player.CharacterAdded:Connect(function(character)
        task.wait(1)
        optimizeCharacter(character)
    end)
    
    -- Optimize other players
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            optimizeCharacter(otherPlayer.Character)
        end
    end
    
    print("✅ Animations đã được tối ưu")
end

-- ===== 7. PERFORMANCE MONITOR NÂNG CAO =====
local function AdvancedPerformanceMonitor()
    if not Config.PerformanceMonitor then return end
    
    print("📈 Khởi động Performance Monitor...")
    
    -- Update FPS
    local lastFrame = tick()
    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastFrame
        lastFrame = currentTime
        
        PerformanceData.CurrentFPS = math.floor(1 / math.max(deltaTime, 0.001))
        
        -- Update FPS history
        table.insert(PerformanceData.FPSHistory, PerformanceData.CurrentFPS)
        if #PerformanceData.FPSHistory > 30 then
            table.remove(PerformanceData.FPSHistory, 1)
        end
        
        PerformanceData.AverageFPS = GetAverageFPS()
    end)
    
    -- Create GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PerformanceMonitor"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 200, 0, 140)
    MainFrame.Position = UDim2.new(1, -210, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BackgroundTransparency = 0.2
    Title.Text = "⚡ NOKIA G21"
    Title.TextColor3 = Color3.fromRGB(0, 255, 150)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(1, -10, 1, -30)
    StatsLabel.Position = UDim2.new(0, 5, 0, 28)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsLabel.TextSize = 13
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatsLabel.Parent = MainFrame
    
    -- Update stats
    task.spawn(function()
        while task.wait(Config.MonitorInterval) do
            SafeExecute(function()
                PerformanceData.MemoryUsage = Stats:GetTotalMemoryUsageMb()
                
                local fpsColor
                if PerformanceData.CurrentFPS >= Config.MinFPS then
                    fpsColor = "🟢"
                elseif PerformanceData.CurrentFPS >= 30 then
                    fpsColor = "🟡"
                else
                    fpsColor = "🔴"
                end
                
                StatsLabel.Text = string.format(
                    "%s FPS: %d (Avg: %d)\n" ..
                    "📊 Quality: Level %d\n" ..
                    "💾 RAM: %.0f MB\n" ..
                    "📦 Parts: %d\n" ..
                    "🌐 Ping: %d ms\n" ..
                    "🎯 Target: %d FPS",
                    fpsColor,
                    PerformanceData.CurrentFPS,
                    math.floor(PerformanceData.AverageFPS),
                    PerformanceData.QualityLevel,
                    PerformanceData.MemoryUsage,
                    PerformanceData.ActiveParts,
                    math.floor(Player:GetNetworkPing() * 1000),
                    Config.TargetFPS
                )
            end)
        end
    end)
    
    print("✅ Performance Monitor đã khởi động")
end

-- ===== 8. ADAPTIVE QUALITY SYSTEM =====
local function AdaptiveQualitySystem()
    if not Config.AdaptiveQuality then return end
    
    print("🎯 Khởi động Adaptive Quality System...")
    
    task.spawn(function()
        while task.wait(Config.AdaptiveInterval) do
            SafeExecute(function()
                local avgFPS = PerformanceData.AverageFPS
                local currentQuality = PerformanceData.QualityLevel
                
                -- Điều chỉnh quality dựa trên FPS
                if avgFPS < Config.MinFPS and currentQuality > 3 then
                    -- Giảm quality
                    PerformanceData.QualityLevel = math.max(currentQuality - 1, 3)
                    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. PerformanceData.QualityLevel]
                    Config.RenderDistance = math.max(Config.RenderDistance - 30, 150)
                    print("⬇️ Giảm quality xuống Level " .. PerformanceData.QualityLevel)
                    
                elseif avgFPS > Config.TargetFPS and currentQuality < 7 then
                    -- Tăng quality
                    PerformanceData.QualityLevel = math.min(currentQuality + 1, 7)
                    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. PerformanceData.QualityLevel]
                    Config.RenderDistance = math.min(Config.RenderDistance + 30, 300)
                    print("⬆️ Tăng quality lên Level " .. PerformanceData.QualityLevel)
                end
                
                -- Memory management
                if PerformanceData.MemoryUsage > 3500 then
                    SmartMemoryCleanup()
                end
            end)
        end
    end)
    
    print("✅ Adaptive Quality System đã khởi động")
end

-- ===== 9. SMART MEMORY MANAGEMENT =====
function SmartMemoryCleanup()
    print("🧹 Đang dọn dẹp bộ nhớ thông minh...")
    
    SafeExecute(function()
        -- Aggressive cleanup
        for i = 1, 3 do
            collectgarbage("collect")
            task.wait(0.05)
        end
        
        -- Clear optimization cache occasionally
        if tick() - PerformanceData.LastCleanup > 300 then
            OptimizationCache.CulledObjects = {}
            OptimizationCache.LODObjects = {}
        end
        
        collectgarbage("stop")
        task.wait(0.05)
        collectgarbage("restart")
        
        PerformanceData.LastCleanup = tick()
    end)
    
    print("✅ Bộ nhớ đã được dọn sạch")
end

-- ===== 10. FPS LIMITER =====
local function SmartFPSLimiter()
    print("🎯 Khởi động Smart FPS Limiter...")
    
    local targetFrameTime = 1 / Config.MaxFPS
    local lastFrame = tick()
    
    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local elapsed = currentTime - lastFrame
        
        if elapsed < targetFrameTime then
            local sleepTime = targetFrameTime - elapsed
            task.wait(sleepTime)
        end
        
        lastFrame = tick()
    end)
    
    print("✅ FPS đã được giới hạn tại " .. Config.MaxFPS)
end

-- ===== 11. AUTO MEMORY CLEANUP =====
local function AutoMemoryCleanup()
    if not Config.AutoMemoryManagement then return end
    
    print("🔄 Khởi động Auto Memory Cleanup...")
    
    task.spawn(function()
        while task.wait(Config.CleanupInterval) do
            SmartMemoryCleanup()
        end
    end)
    
    print("✅ Auto Memory Cleanup đã khởi động")
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("╔" .. string.rep("═", 62) .. "╗")
    print("║  🚀 NOKIA G21 ULTRA PERFORMANCE OPTIMIZER V3.0              ║")
    print("║  📱 6GB RAM / 128GB ROM / Unisoc T606 / 90Hz Display       ║")
    print("║  ⚡ Target: 70 FPS ổn định với chất lượng cao              ║")
    print("║  🎯 Smart Adaptive Quality + Dynamic LOD                   ║")
    print("╚" .. string.rep("═", 62) .. "╝")
    
    local startTime = tick()
    
    -- Chạy các tối ưu
    OptimizeGraphics()
    task.wait(0.2)
    
    OptimizeEffectsIntelligent()
    task.wait(0.2)
    
    OptimizeTerrain()
    task.wait(0.2)
    
    InitializeDynamicLOD()
    task.wait(0.2)
    
    AdvancedSmartCulling()
    task.wait(0.2)
    
    OptimizeAnimations()
    task.wait(0.2)
    
    AdvancedPerformanceMonitor()
    task.wait(0.2)
    
    AdaptiveQualitySystem()
    task.wait(0.2)
    
    SmartFPSLimiter()
    task.wait(0.2)
    
    AutoMemoryCleanup()
    task.wait(0.2)
    
    SmartMemoryCleanup()
    
    local loadTime = math.floor((tick() - startTime) * 100) / 100
    
    print("╔" .. string.rep("═", 62) .. "╗")
    print("║  ✅ TỐI ƯU HOÀN TẤT SIÊU MƯỢT!                             ║")
    print("║  ⏱️  Load time: " .. loadTime .. " giây" .. string.rep(" ", 40 - #tostring(loadTime)) .. "║")
    print("║  📊 Performance Monitor: Góc phải trên màn hình            ║")
    print("║  🎯 Adaptive Quality: Tự động điều chỉnh theo FPS          ║")
    print("║  🔄 Memory Cleanup: Mỗi " .. Config.CleanupInterval .. " giây" .. string.rep(" ", 29) .. "║")
    print("║  💡 Dynamic LOD: Tối ưu theo khoảng cách                   ║")
    print("║  👁️  Smart Culling: Ẩn objects ngoài tầm nhìn              ║")
    print("╚" .. string.rep("═", 62) .. "╝")
end

-- Chạy script
SafeExecute(Initialize)