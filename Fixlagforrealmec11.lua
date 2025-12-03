-- =====================================================
-- ==   REALME C11 SPECIAL EDITION v5.1             ==
-- ==   Tối ưu ĐẶC BIỆT cho Helio G35 + 2GB RAM    ==
-- ==   Mục tiêu: 25-30 FPS ổn định                ==
-- =====================================================
print("🔧 Khởi động Realme C11 Special Edition v5.1...")

-- Services
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH ĐẶC BIỆT CHO REALME C11 =====
local Config = {
    -- Graphics - Tối ưu cho PowerVR GE8320
    GraphicsQuality = "UltraLow",
    RemoveAllTextures = true,
    RemoveAllDecals = true,
    
    -- LOD - Điều chỉnh cho 2GB RAM
    EnableLOD = true,
    LODDistance1 = 50,          -- GẦN: Chi tiết cao (giảm từ 80)
    LODDistance2 = 100,         -- TRUNG: Chi tiết thấp (giảm từ 150)
    LODDistance3 = 150,         -- XA: Ẩn hoàn toàn (giảm từ 250)
    LODUpdateRate = 1,          -- Update chậm hơn để giảm tải CPU
    
    -- Performance - Tối ưu cho Helio G35
    TargetFPS = 30,             -- Mục tiêu THỰC TẾ cho Realme C11
    MinFPS = 20,                -- FPS tối thiểu chấp nhận được
    EnableFPSStabilizer = true, -- Tự động điều chỉnh để giữ FPS ổn định
    
    -- Memory - Quan trọng với 2GB RAM
    AggressiveMemory = true,
    AutoCleanupInterval = 15,   -- Dọn bộ nhớ mỗi 15 giây
    MaxMemoryUsage = 80,        -- % RAM tối đa (1.6GB)
    
    -- Character
    TransparentHead = true,
    SimplifyOtherPlayers = true,
    MaxVisiblePlayers = 5,      -- CHỈ 5 người (giảm từ 10)
    
    -- Rendering - Tối ưu cho mobile yếu
    RenderDistance = 60,        -- Rất ngắn
    DisableAllEffects = true,
    DisableAnimations = false,  -- Giữ animation nhưng giảm chất lượng
    
    -- Battery Saver - Quan trọng cho máy yếu
    EnableBatterySaver = true,
    ReduceCPUUsage = true,
}

-- ===== DANH SÁCH BẢO VỆ MAP =====
local ProtectedKeywords = {
    "terrain", "baseplate", "spawn", "map", "lobby", "building",
    "floor", "wall", "ground", "platform", "house", "tree",
    "road", "mountain", "bridge", "tower", "arena", "stage", "base"
}

-- ===== BIẾN TOÀN CỤC =====
local LODObjects = {}
local PerformanceStats = {
    PartsOptimized = 0,
    EffectsRemoved = 0,
    TexturesRemoved = 0,
    LODObjectsTracked = 0,
    MemoryCleaned = 0,
    CurrentFPS = 0,
    AverageFPS = 0,
    LowestFPS = 999,
}

local FPSCounter = 0
local FPSHistory = {}
local LastCleanup = tick()
local PerformanceMode = "Balanced" -- Auto, Balanced, Performance

-- ===== UTILITY FUNCTIONS =====
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Error:", result)
    end
    return success, result
end

local function IsMapPart(obj)
    if not obj or not obj.Parent then return false end
    
    local function checkName(instance)
        if not instance or not instance.Name then return false end
        local lowerName = string.lower(instance.Name)
        for _, keyword in ipairs(ProtectedKeywords) do
            if string.find(lowerName, keyword) then
                return true
            end
        end
        return false
    end
    
    if checkName(obj) or checkName(obj.Parent) then
        return true
    end
    
    if obj:IsA("BasePart") and obj.Anchored and obj.Size.Magnitude > 10 then
        return true
    end
    
    return false
end

local function GetDistanceToPlayer(obj)
    if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
        return math.huge
    end
    
    local playerPos = Player.Character.HumanoidRootPart.Position
    local objPos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
    
    return (objPos - playerPos).Magnitude
end

-- ===== 1. ULTRA LOW GRAPHICS (PowerVR GE8320 Optimized) =====
local function UltraLowGraphics()
    print("📊 Kích hoạt Ultra Low Graphics cho PowerVR GE8320...")
    
    SafeCall(function()
        -- Chất lượng thấp nhất
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Low
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        
        -- Mobile-specific optimizations
        if UserSettings():IsUserFeatureEnabled("UserReduceMotionEnabled") then
            UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        end
        
        -- Lighting - Tối ưu cho mobile
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.Brightness = 2.5
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        
        -- Xóa effects
        for _, effect in pairs(Lighting:GetChildren()) do
            if not effect:IsA("Lighting") then
                SafeCall(function() effect:Destroy() end)
            end
        end
        
        -- Terrain optimization
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end
        
        -- Camera - Giảm FOV để tăng FPS
        Camera.FieldOfView = 65
    end)
    
    print("✅ Ultra Low Graphics đã kích hoạt")
end

-- ===== 2. XÓA EFFECTS VÀ TEXTURES (Helio G35 Optimized) =====
local function RemoveVisualEffects()
    print("🧹 Xóa effects và textures...")
    
    local effectsCount = 0
    local texturesCount = 0
    local processedCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        processedCount = processedCount + 1
        
        -- Giới hạn xử lý mỗi frame để không lag
        if processedCount % 100 == 0 then
            task.wait()
        end
        
        SafeCall(function()
            -- Xóa particles/effects
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
               obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") or
               obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
                effectsCount = effectsCount + 1
            end
            
            -- Tối ưu parts
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false
                
                -- Xóa textures (trừ map)
                if obj:IsA("MeshPart") and not IsMapPart(obj) then
                    obj.TextureID = ""
                    texturesCount = texturesCount + 1
                end
                
                -- Xóa decals (trừ map)
                if not IsMapPart(obj) then
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceGui") then
                            child:Destroy()
                        end
                    end
                end
                
                PerformanceStats.PartsOptimized = PerformanceStats.PartsOptimized + 1
            end
        end)
    end
    
    PerformanceStats.EffectsRemoved = effectsCount
    PerformanceStats.TexturesRemoved = texturesCount
    
    print("✅ Đã xóa " .. effectsCount .. " effects, " .. texturesCount .. " textures")
end

-- ===== 3. LOD SYSTEM (2GB RAM Optimized) =====
local function InitializeLODSystem()
    if not Config.EnableLOD then return end
    
    print("🎯 Khởi động LOD System cho 2GB RAM...")
    
    -- Đăng ký objects cho LOD (giới hạn số lượng)
    local objectCount = 0
    local maxObjects = 500 -- Giới hạn cho 2GB RAM
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if objectCount >= maxObjects then break end
        
        if (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:IsDescendantOf(Player.Character or {}) then
            if not IsMapPart(obj) then
                LODObjects[obj] = {
                    OriginalTrans = obj:IsA("BasePart") and obj.Transparency or 0,
                    OriginalColl = obj:IsA("BasePart") and obj.CanCollide or false,
                    CurrentLOD = 0,
                }
                objectCount = objectCount + 1
            end
        end
    end
    
    PerformanceStats.LODObjectsTracked = objectCount
    
    -- LOD Update Loop - TỐI ƯU CHO CPU YẾU
    task.spawn(function()
        while task.wait(Config.LODUpdateRate) do
            if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
                continue
            end
            
            local playerPos = Player.Character.HumanoidRootPart.Position
            local processedThisFrame = 0
            
            for obj, data in pairs(LODObjects) do
                -- Giới hạn xử lý mỗi frame
                processedThisFrame = processedThisFrame + 1
                if processedThisFrame > 50 then
                    task.wait()
                    processedThisFrame = 0
                end
                
                if not obj or not obj.Parent then
                    LODObjects[obj] = nil
                    continue
                end
                
                SafeCall(function()
                    local distance = GetDistanceToPlayer(obj)
                    local newLOD = 0
                    
                    -- LOD levels - ĐIỀU CHỈNH CHO REALME C11
                    if distance < Config.LODDistance1 then
                        newLOD = 1  -- Gần: Hiển thị
                    elseif distance < Config.LODDistance2 then
                        newLOD = 2  -- Trung: Giảm chất lượng
                    else
                        newLOD = 3  -- Xa: Ẩn
                    end
                    
                    if newLOD ~= data.CurrentLOD then
                        data.CurrentLOD = newLOD
                        
                        if obj:IsA("BasePart") then
                            if newLOD == 1 then
                                obj.Transparency = data.OriginalTrans
                                obj.CanCollide = data.OriginalColl
                            elseif newLOD == 2 then
                                obj.Transparency = math.min(data.OriginalTrans + 0.5, 0.95)
                                obj.CanCollide = false
                            else -- LOD 3
                                obj.Transparency = 1
                                obj.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    print("✅ LOD System khởi động (" .. objectCount .. " objects)")
end

-- ===== 4. FPS STABILIZER (Tự động điều chỉnh) =====
local function InitializeFPSStabilizer()
    if not Config.EnableFPSStabilizer then return end
    
    print("📊 Khởi động FPS Stabilizer...")
    
    local lastFPSCheck = tick()
    
    -- FPS Counter
    RunService.RenderStepped:Connect(function()
        FPSCounter = FPSCounter + 1
    end)
    
    -- FPS Monitor & Auto Adjust
    task.spawn(function()
        while task.wait(1) do
            -- Tính FPS
            PerformanceStats.CurrentFPS = FPSCounter
            table.insert(FPSHistory, FPSCounter)
            if #FPSHistory > 10 then
                table.remove(FPSHistory, 1)
            end
            
            local total = 0
            for _, fps in ipairs(FPSHistory) do
                total = total + fps
            end
            PerformanceStats.AverageFPS = math.floor(total / #FPSHistory)
            
            if PerformanceStats.CurrentFPS < PerformanceStats.LowestFPS then
                PerformanceStats.LowestFPS = PerformanceStats.CurrentFPS
            end
            
            FPSCounter = 0
            
            -- TỰ ĐỘNG ĐIỀU CHỈNH NẾU FPS THẤP
            if tick() - lastFPSCheck > 5 then
                lastFPSCheck = tick()
                
                if PerformanceStats.AverageFPS < Config.MinFPS then
                    -- FPS quá thấp - Tăng cường tối ưu
                    print("⚠️ FPS thấp (" .. PerformanceStats.AverageFPS .. ") - Tăng tối ưu...")
                    
                    if Config.MaxVisiblePlayers > 3 then
                        Config.MaxVisiblePlayers = 3
                        print("   → Giảm players hiển thị xuống 3")
                    end
                    
                    if Config.LODDistance1 > 30 then
                        Config.LODDistance1 = 30
                        Config.LODDistance2 = 60
                        print("   → Giảm LOD distance")
                    end
                    
                    -- Cleanup ngay
                    AggressiveMemoryCleanup()
                    
                elseif PerformanceStats.AverageFPS > Config.TargetFPS + 5 then
                    -- FPS tốt - Có thể nới lỏng
                    if Config.MaxVisiblePlayers < 5 then
                        Config.MaxVisiblePlayers = math.min(5, Config.MaxVisiblePlayers + 1)
                        print("✅ FPS tốt - Tăng players lên " .. Config.MaxVisiblePlayers)
                    end
                end
            end
        end
    end)
    
    print("✅ FPS Stabilizer đã khởi động")
end

-- ===== 5. PHYSICS REDUCTION =====
local function ReducePhysics()
    print("⚙️ Giảm physics...")
    
    local count = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or {}) then
                if not IsMapPart(obj) then
                    -- Xóa constraints
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("Constraint") or child:IsA("BodyMover") then
                            child:Destroy()
                            count = count + 1
                        end
                    end
                    
                    -- Đơn giản hóa physics
                    if obj.Size.Magnitude < 5 then
                        obj.CanCollide = false
                        obj.Massless = true
                    end
                end
            end
        end)
    end
    
    print("✅ Đã giảm " .. count .. " physics objects")
end

-- ===== 6. CHARACTER OPTIMIZATION =====
local function OptimizeCharacter(character)
    task.wait(0.3)
    
    SafeCall(function()
        local isLocalPlayer = character.Parent == Player
        
        -- Head transparent cho local player
        if isLocalPlayer and Config.TransparentHead then
            local head = character:FindFirstChild("Head")
            if head then
                head.Transparency = 1
                head.CanCollide = false
                local face = head:FindFirstChild("face")
                if face then face.Transparency = 1 end
            end
        end
        
        -- Đơn giản hóa character
        for _, part in pairs(character:GetDescendants()) do
            SafeCall(function()
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Plastic
                    part.Reflectance = 0
                    part.CastShadow = false
                    
                    if part.Parent:IsA("Accessory") then
                        part.CanCollide = false
                        part.Massless = true
                        -- Giảm chi tiết accessories
                        if part:IsA("MeshPart") then
                            part.TextureID = ""
                        end
                    end
                end
                
                if part:IsA("ParticleEmitter") or part:IsA("Trail") then
                    part:Destroy()
                end
            end)
        end
    end)
end

-- ===== 7. PLAYER VISIBILITY MANAGER =====
local function ManagePlayerVisibility()
    if not Config.SimplifyOtherPlayers then return end
    
    print("👥 Quản lý hiển thị players...")
    
    task.spawn(function()
        while task.wait(2) do
            if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
                continue
            end
            
            local playerPos = Player.Character.HumanoidRootPart.Position
            local nearbyPlayers = {}
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= Player and otherPlayer.Character and 
                   otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (otherPlayer.Character.HumanoidRootPart.Position - playerPos).Magnitude
                    table.insert(nearbyPlayers, {player = otherPlayer, distance = distance})
                end
            end
            
            table.sort(nearbyPlayers, function(a, b) return a.distance < b.distance end)
            
            for i, data in ipairs(nearbyPlayers) do
                SafeCall(function()
                    local char = data.player.Character
                    local visible = i <= Config.MaxVisiblePlayers
                    
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not visible then
                                part.Transparency = 1
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    print("✅ Quản lý players: Max " .. Config.MaxVisiblePlayers)
end

-- ===== 8. MEMORY CLEANUP (2GB RAM Optimized) =====
function AggressiveMemoryCleanup()
    SafeCall(function()
        -- Garbage collection
        for i = 1, 8 do
            collectgarbage("collect")
            if i % 2 == 0 then
                task.wait(0.01)
            end
        end
        
        -- Xóa dead objects
        for obj, _ in pairs(LODObjects) do
            if not obj or not obj.Parent then
                LODObjects[obj] = nil
            end
        end
        
        PerformanceStats.MemoryCleaned = PerformanceStats.MemoryCleaned + 1
    end)
end

-- ===== 9. AUTO CLEANUP LOOP =====
local function AutoCleanupLoop()
    task.spawn(function()
        while task.wait(Config.AutoCleanupInterval) do
            AggressiveMemoryCleanup()
        end
    end)
end

-- ===== 10. BATTERY SAVER MODE =====
local function EnableBatterySaver()
    if not Config.EnableBatterySaver then return end
    
    print("🔋 Kích hoạt Battery Saver...")
    
    SafeCall(function()
        -- Giảm animation quality
        if Player.Character then
            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0.9)
                end
            end
        end
    end)
    
    print("✅ Battery Saver đã kích hoạt")
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("╔" .. string.rep("═", 62) .. "╗")
    print("║  🔥 REALME C11 SPECIAL EDITION V5.1                       ║")
    print("║  📱 Helio G35 + 2GB RAM Optimized                         ║")
    print("║  🎯 Target: 25-30 FPS Stable                              ║")
    print("╚" .. string.rep("═", 62) .. "╝")
    
    local startTime = tick()
    
    print("\n⏳ Đang tối ưu...")
    
    -- Phase 1: Graphics
    UltraLowGraphics()
    task.wait(0.15)
    
    -- Phase 2: Visual Effects
    RemoveVisualEffects()
    task.wait(0.15)
    
    -- Phase 3: Physics
    ReducePhysics()
    task.wait(0.15)
    
    -- Phase 4: LOD System
    InitializeLODSystem()
    task.wait(0.15)
    
    -- Phase 5: FPS Stabilizer
    InitializeFPSStabilizer()
    
    -- Phase 6: Characters
    if Player.Character then
        OptimizeCharacter(Player.Character)
    end
    
    Player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        OptimizeCharacter(character)
    end)
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            OptimizeCharacter(otherPlayer.Character)
        end
    end
    
    Players.PlayerAdded:Connect(function(otherPlayer)
        otherPlayer.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            OptimizeCharacter(character)
        end)
    end)
    
    -- Phase 7: Advanced Features
    ManagePlayerVisibility()
    EnableBatterySaver()
    
    -- Phase 8: Memory
    AggressiveMemoryCleanup()
    AutoCleanupLoop()
    
    local endTime = tick()
    local loadTime = math.floor((endTime - startTime) * 100) / 100
    
    task.wait(2)
    
    print("\n╔" .. string.rep("═", 62) .. "╗")
    print("║  ✅ TỐI ƯU HOÀN TẤT - REALME C11 READY!                   ║")
    print("║                                                            ║")
    print("║  📊 THỐNG KÊ:                                              ║")
    print("║  ⏱️  Thời gian: " .. loadTime .. "s                                      ║")
    print("║  🎯 Parts: " .. PerformanceStats.PartsOptimized .. "                                            ║")
    print("║  🧹 Effects: " .. PerformanceStats.EffectsRemoved .. "                                          ║")
    print("║  🖼️  Textures: " .. PerformanceStats.TexturesRemoved .. "                                        ║")
    print("║  🎮 LOD Objects: " .. PerformanceStats.LODObjectsTracked .. "                                    ║")
    print("║  📈 FPS hiện tại: " .. PerformanceStats.CurrentFPS .. "                                 ║")
    print("║                                                            ║")
    print("║  💡 ĐẶC BIỆT CHO REALME C11:                              ║")
    print("║  ✓ PowerVR GE8320 Optimized                               ║")
    print("║  ✓ 2GB RAM Management                                     ║")
    print("║  ✓ LOD Distance: 50/100/150                               ║")
    print("║  ✓ Max " .. Config.MaxVisiblePlayers .. " Players Visible                                ║")
    print("║  ✓ FPS Auto Stabilizer (Target: " .. Config.TargetFPS .. " FPS)                   ║")
    print("║  ✓ Battery Saver Mode                                     ║")
    print("║  ✓ Auto Cleanup mỗi " .. Config.AutoCleanupInterval .. "s                               ║")
    print("║                                                            ║")
    print("║  ⚠️  LƯU Ý:                                                ║")
    print("║  • FPS thực tế phụ thuộc vào game bạn chơi                ║")
    print("║  • Script sẽ TỰ ĐỘNG điều chỉnh nếu FPS quá thấp          ║")
    print("║  • Tắt app khác để FPS tốt hơn                            ║")
    print("╚" .. string.rep("═", 62) .. "╝")
end

-- Chạy script
SafeCall(Initialize)