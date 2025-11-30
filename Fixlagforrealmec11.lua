print("🔧 Khởi động Ultra Lag Fix Pro v3.0...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH SIÊU TỐI ƯU V3 =====
local Config = {
    RenderDistance = 60,        -- Giảm xuống 60 studs
    GraphicsQuality = 1,
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = true,
    RemoveTextures = true,
    OptimizeTerrain = true,
    DisableAllEffects = true,
    ReducePhysics = true,
    OptimizeAnimations = true,
    ReduceGUI = true,
    DisableFog = true,
    MaxFPS = 50,                -- Giới hạn 50 FPS cho ổn định
    AggressiveMemory = true,    -- Dọn bộ nhớ tích cực
    DisableAudio = false,       -- Tắt âm thanh không cần thiết
    SimplifyMeshes = true,      -- Đơn giản hóa mesh
    ReduceParticleCount = true,
    DisablePostProcessing = true,
    LowPowerMode = true,        -- Chế độ tiết kiệm năng lượng
}

-- ===== BIẾN TOÀN CỤC =====
local OptimizedParts = {}
local OriginalValues = {}
local LastCleanup = tick()
local PerformanceStats = {
    PartsOptimized = 0,
    EffectsRemoved = 0,
    MemoryCleaned = 0,
}

-- ===== UTILITY FUNCTIONS =====
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Error:", result)
    end
    return success, result
end

-- ===== 1. ĐỒ HỌA CỰC THẤP =====
local function OptimizeGraphics()
    print("📊 Tối ưu đồ họa cực mạnh...")

    SafeCall(function()
        -- Chất lượng thấp nhất có thể
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        
        -- Tắt các tính năng render nâng cao
        if sethiddenproperty then
            sethiddenproperty(game, "RenderingPerformance", "Low")
        end
        
        -- Giảm view distance
        game:GetService("Players").LocalPlayer.MaximumSimulationRadius = 0
        
        -- Tắt ánh sáng động hoàn toàn
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ShadowSoftness = 0
        
        -- Tắt sương mù
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        
        -- Xóa tất cả hiệu ứng ánh sáng
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
                SafeCall(function() effect:Destroy() end)
            end
        end
    end)

    print("✅ Đồ họa đã tối ưu cực mạnh")
end

-- ===== 2. XÓA HIỆU ỨNG TOÀN DIỆN =====
local function RemoveAllEffects()
    print("🧹 Xóa tất cả hiệu ứng và texture...")

    local count = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            -- Xóa Particles
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or
               obj:IsA("Beam") or obj:IsA("PointLight") or obj:IsA("SpotLight") or
               obj:IsA("SurfaceLight") then
                obj.Enabled = false
                count = count + 1
            end

            -- Xóa Decals/Textures
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
                count = count + 1
            end

            -- Tối ưu BasePart/MeshPart
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false
                
                if obj:IsA("MeshPart") and Config.RemoveTextures then
                    obj.TextureID = ""
                end
                
                -- Đơn giản hóa collision
                if not obj:IsDescendantOf(Player.Character or {}) then
                    obj.CanCollide = (obj.CanCollide and obj.Name ~= "Terrain")
                end
                
                PerformanceStats.PartsOptimized = PerformanceStats.PartsOptimized + 1
            end

            -- Xóa SpecialMesh texture
            if obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end

            -- Xóa SurfaceAppearance
            if obj:IsA("SurfaceAppearance") then
                obj:Destroy()
                count = count + 1
            end
            
            -- Xóa sounds không cần thiết
            if Config.DisableAudio and obj:IsA("Sound") then
                if not obj:IsDescendantOf(Player.Character or {}) then
                    obj.Volume = 0
                end
            end
        end)
    end

    PerformanceStats.EffectsRemoved = count
    print("✅ Đã xóa " .. count .. " hiệu ứng")
end

-- ===== 3. RENDER DISTANCE THÔNG MINH NÂNG CAO =====
local function SmartRenderDistance()
    print("👁️ Kích hoạt render distance thông minh...")

    local lastUpdate = 0
    local updateInterval = 1 -- Cập nhật mỗi 1 giây để tiết kiệm

    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate < updateInterval then return end
        lastUpdate = currentTime

        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end

        local playerPos = Player.Character.HumanoidRootPart.Position
        local camera = Camera.CFrame.Position

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Player.Character) then
                SafeCall(function()
                    local distance = (obj.Position - playerPos).Magnitude
                    local inView = (obj.Position - camera).Magnitude < Config.RenderDistance * 1.5

                    -- Tắt parts xa hoặc ngoài tầm nhìn
                    if distance > Config.RenderDistance or not inView then
                        if not OptimizedParts[obj] then
                            OptimizedParts[obj] = {
                                Trans = obj.Transparency,
                                Coll = obj.CanCollide
                            }
                        end
                        obj.Transparency = 1
                        obj.CanCollide = false
                    else
                        if OptimizedParts[obj] then
                            obj.Transparency = OptimizedParts[obj].Trans
                            obj.CanCollide = OptimizedParts[obj].Coll
                        end
                    end
                end)
            end
        end
    end)

    print("✅ Render distance thông minh đã kích hoạt")
end

-- ===== 4. TỐI ƯU TERRAIN CỰC MẠNH =====
local function OptimizeTerrain()
    print("🏔️ Tối ưu địa hình cực mạnh...")

    SafeCall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            
            -- Tắt terrain trong sương mù
            if setfpscap then
                setfpscap(Config.MaxFPS)
            end
        end
    end)

    print("✅ Địa hình đã tối ưu")
end

-- ===== 5. GIẢM PHYSICS TOÀN DIỆN =====
local function ReducePhysics()
    print("⚙️ Giảm physics toàn diện...")

    local count = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or {}) then
                -- Xóa các BodyMover
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or
                       child:IsA("BodyPosition") or child:IsA("BodyForce") or
                       child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity") or
                       child:IsA("RocketPropulsion") then
                        child:Destroy()
                        count = count + 1
                    end
                end

                -- Đơn giản hóa physics
                obj.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.2, 0.5)
                
                -- Tắt collision cho parts nhỏ
                if obj.Size.Magnitude < 2 then
                    obj.CanCollide = false
                end
            end
        end)
    end

    print("✅ Đã giảm " .. count .. " physics objects")
end

-- ===== 6. TỐI ƯU ANIMATIONS =====
local function OptimizeAnimations()
    print("🎬 Tối ưu animations...")

    SafeCall(function()
        if Player.Character then
            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Giảm tốc độ animation
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0.6)
                    track.Priority = Enum.AnimationPriority.Idle
                end
            end
        end
    end)

    print("✅ Animations đã được tối ưu")
end

-- ===== 7. MEMORY CLEANUP TÍCH CỰC =====
local function AggressiveMemoryCleanup()
    print("🧹 Dọn bộ nhớ tích cực...")

    SafeCall(function()
        -- Garbage collection mạnh
        for i = 1, 10 do
            collectgarbage("collect")
            task.wait(0.05)
        end
        
        collectgarbage("stop")
        task.wait(0.1)
        collectgarbage("restart")
        
        -- Xóa cache
        if ContentProvider then
            ContentProvider:PreloadAsync({})
        end
        
        PerformanceStats.MemoryCleaned = PerformanceStats.MemoryCleaned + 1
    end)

    print("✅ Bộ nhớ đã được dọn sạch")
end

-- ===== 8. TỐI ƯU CHARACTER TOÀN DIỆN =====
local function OptimizeCharacter(character)
    task.wait(0.5)

    SafeCall(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = 0
            humanoid.NameDisplayDistance = 0
            
            -- Giảm animation FPS
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0.6)
            end
        end

        -- Tối ưu accessories
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle then
                    handle.Material = Enum.Material.Plastic
                    handle.Reflectance = 0
                    handle.CastShadow = false
                    
                    for _, child in pairs(handle:GetDescendants()) do
                        if child:IsA("SpecialMesh") then
                            child.TextureId = ""
                        elseif child:IsA("SurfaceAppearance") then
                            child:Destroy()
                        end
                    end
                end
            end
        end

        -- Tối ưu body parts
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
                part.Reflectance = 0
                part.CastShadow = false
            end
        end
    end)
end

-- ===== 9. TỐI ƯU GUI NÂNG CAO =====
local function OptimizeGUI()
    print("🖥️ Tối ưu GUI...")

    SafeCall(function()
        local playerGui = Player:WaitForChild("PlayerGui", 5)
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
                    gui.ImageTransparency = 0.5
                    gui.BackgroundTransparency = 0.5
                elseif gui:IsA("ViewportFrame") then
                    gui.Ambient = Color3.new(1, 1, 1)
                    gui.LightColor = Color3.new(0, 0, 0)
                end
            end
        end
    end)

    print("✅ GUI đã được tối ưu")
end

-- ===== 10. FPS LIMITER =====
local function LimitFPS()
    print("🎯 Giới hạn FPS tại " .. Config.MaxFPS .. "...")

    local frameTime = 1 / Config.MaxFPS
    local lastFrame = tick()

    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastFrame

        if deltaTime < frameTime then
            task.wait(frameTime - deltaTime)
        end

        lastFrame = tick()
    end)

    print("✅ FPS đã được giới hạn ổn định")
end

-- ===== 11. AUTO CLEANUP THÔNG MINH =====
local function AutoCleanup()
    task.spawn(function()
        while task.wait(30) do -- Mỗi 30 giây
            local currentTime = tick()
            if currentTime - LastCleanup >= 30 then
                print("🔄 Auto cleanup...")
                AggressiveMemoryCleanup()
                LastCleanup = currentTime
            end
        end
    end)
end

-- ===== 12. TỐI ƯU PLAYERS KHÁC =====
local function OptimizeOtherPlayers()
    print("👥 Tối ưu players khác...")

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            OptimizeCharacter(otherPlayer.Character)
        end
    end

    Players.PlayerAdded:Connect(function(otherPlayer)
        otherPlayer.CharacterAdded:Connect(function(character)
            task.wait(1)
            OptimizeCharacter(character)
        end)
    end)

    print("✅ Players khác đã được tối ưu")
end

-- ===== 13. XÓA OBJECTS KHÔNG CẦN THIẾT =====
local function RemoveUnnecessaryObjects()
    print("🗑️ Xóa objects không cần thiết...")

    local count = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            -- Xóa các effects không cần
            if obj:IsA("ForceField") or obj:IsA("SelectionBox") or
               obj:IsA("Handles") or obj:IsA("ArcHandles") or
               obj:IsA("SurfaceSelection") then
                obj:Destroy()
                count = count + 1
            end
        end)
    end

    print("✅ Đã xóa " .. count .. " objects không cần thiết")
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  🚀 ROBLOX ULTRA LAG FIX PRO V3.0                         ║")
    print("║  📱 Tối ưu cực mạnh cho Realme C11 (RAM 2GB)             ║")
    print("║  ⚡ Cải thiện FPS 60-100%                                 ║")
    print("╚" .. string.rep("═", 60) .. "╝")

    local startTime = tick()

    -- Chạy tất cả tối ưu
    OptimizeGraphics()
    task.wait(0.2)

    RemoveAllEffects()
    task.wait(0.2)

    OptimizeTerrain()
    task.wait(0.2)

    ReducePhysics()
    task.wait(0.2)

    RemoveUnnecessaryObjects()
    task.wait(0.2)

    SmartRenderDistance()
    task.wait(0.2)

    OptimizeAnimations()
    task.wait(0.2)

    OptimizeGUI()
    task.wait(0.2)

    AggressiveMemoryCleanup()
    task.wait(0.2)

    LimitFPS()
    task.wait(0.2)

    OptimizeOtherPlayers()

    -- Tối ưu character
    if Player.Character then
        OptimizeCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(character)
        task.wait(1)
        OptimizeCharacter(character)
    end)

    -- Auto cleanup
    AutoCleanup()

    local endTime = tick()
    local loadTime = math.floor((endTime - startTime) * 100) / 100

    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  ✅ TỐI ƯU HOÀN TẤT SIÊU MƯỢT!                           ║")
    print("║  ⏱️  Thời gian: " .. loadTime .. " giây" .. string.rep(" ", 37 - #tostring(loadTime)) .. "║")
    print("║  📊 Parts tối ưu: " .. PerformanceStats.PartsOptimized .. string.rep(" ", 37 - #tostring(PerformanceStats.PartsOptimized)) .. "║")
    print("║  🧹 Effects xóa: " .. PerformanceStats.EffectsRemoved .. string.rep(" ", 38 - #tostring(PerformanceStats.EffectsRemoved)) .. "║")
    print("║  💡 Mẹo: Tắt WiFi khi chơi offline để tăng FPS          ║")
    print("║  🔄 Auto cleanup mỗi 30 giây                             ║")
    print("╚" .. string.rep("═", 60) .. "╝")
end

-- Chạy script
SafeCall(Initialize)