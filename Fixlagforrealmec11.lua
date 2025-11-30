-- =====================================================
-- ==    ULTRA LAG FIX PRO v4.0 (REALME C11 EDITION)   ==
-- ==    Tối ưu hóa cực mạnh, giữ map, làm đầu trong suốt ==
-- =====================================================
print("🔧 Khởi động Ultra Lag Fix Pro v4.0 (Realme C11 Edition)...")

-- Lấy các service cần thiết
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI ƯU SIÊU CẤP =====
local Config = {
    RenderDistance = 120,       -- Giảm để tăng performance nhưng vẫn đủ thấy
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = true,        -- Xóa decals để tăng FPS
    RemoveTextures = true,      -- Xóa texture của objects không phải map
    OptimizeTerrain = true,
    DisableAllEffects = true,
    ReducePhysics = true,       -- Giảm physics cho objects nhỏ
    OptimizeAnimations = true,
    DisableFog = true,
    MaxFPS = 60,                -- Giới hạn FPS để tiết kiệm pin
    AggressiveMemory = true,
    DisableAudio = false,       -- Giữ âm thanh để có trải nghiệm tốt hơn
    LowPowerMode = true,
}

-- ===== DANH SÁCH PARTS QUAN TRỌNG (KHÔNG XÓA) =====
-- Script sẽ bảo vệ các objects có tên chứa các từ khóa này
local ImportantObjects = {
    "Terrain",
    "Baseplate",
    "SpawnLocation",
    "Map",
    "Lobby",
    "Building",
    "Floor",
    "Wall",
    "Ground",
    "Platform",
    "House",
    "Tree",
    "Road",
    "Mountain"
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
        warn("⚠️ Lỗi:", result)
    end
    return success, result
end

-- KIỂM TRA PART CÓ PHẢI MAP KHÔNG (CẢI TIẾN)
local function IsMapPart(obj)
    if not obj or not obj.Parent then return false end

    -- Kiểm tra tên object và parent
    local function checkName(instance)
        if not instance or not instance.Name then return false end
        local lowerName = string.lower(instance.Name)
        for _, keyword in ipairs(ImportantObjects) do
            if string.find(lowerName, string.lower(keyword)) then
                return true
            end
        end
        return false
    end

    if checkName(obj) or checkName(obj.Parent) then
        return true
    end

    -- Kiểm tra nếu là part cố định lớn (có khả năng cao là map)
    if obj:IsA("BasePart") and obj.Anchored and obj.Size.Magnitude > 15 then
        return true
    end

    return false
end

-- ===== 1. ĐỒ HỌA CỰC THẤP (POTATO GRAPHICS) =====
local function OptimizeGraphics()
    print("📊 Tối ưu đồ họa ở mức Potato...")

    SafeCall(function()
        -- Đặt chất lượng đồ họa ở mức thấp nhất
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Low
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
        
        -- Tắt các tính năng đồ họa tốn tài nguyên
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 2.5 -- Độ sáng vừa phải
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ClockTime = 14 -- Giữ thời gian ban ngày để sáng hơn

        -- Tắt sương mù hoàn toàn
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0

        -- Xóa tất cả các hiệu ứng ánh sáng
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or
               effect:IsA("Sky") then -- Xóa cả sky để tăng FPS
                SafeCall(function() effect:Destroy() end)
            end
        end

        -- Tắt clipping decals để tăng performance
        Workspace.ClipsDecals = false
        
        -- Giảm chất lượng rendering của mặt đất
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 0.5
    end)

    print("✅ Đồ họa đã được tối ưu ở mức Potato")
end

-- ===== 2. XÓA HIỆU ỨNG KHÔNG CẦN THIẾT =====
local function RemoveAllEffects()
    print("🧹 Xóa hiệu ứng không cần thiết...")

    local count = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            -- Xóa PARTICLES
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or
               obj:IsA("Beam") then
                obj:Destroy() -- Xóa hẳn thay vì chỉ tắt
                count = count + 1
            end

            -- Xóa ÁNH SÁNG
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy() -- Xóa hẳn
                count = count + 1
            end

            -- TỐI ƯU PARTS
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false

                -- CHỈ xóa texture của objects KHÔNG PHẢI MAP
                if Config.RemoveTextures and not IsMapPart(obj) then
                    if obj:IsA("MeshPart") then
                        obj.TextureID = ""
                    end
                end
                
                -- Xóa decals của objects không phải map
                if Config.RemoveDecals and not IsMapPart(obj) then
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("Decal") or child:IsA("Texture") then
                            child:Destroy()
                        end
                    end
                end

                PerformanceStats.PartsOptimized = PerformanceStats.PartsOptimized + 1
            end
        end)
    end

    PerformanceStats.EffectsRemoved = count
    print("✅ Đã xóa " .. count .. " hiệu ứng")
end

-- ===== 3. RENDER DISTANCE THÔNG MINH =====
local function SmartRenderDistance()
    print("👁️ Kích hoạt render distance thông minh...")

    local lastUpdate = 0
    local updateInterval = 1.5 -- Tăng tần suất update để mượt hơn

    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate < updateInterval then return end
        lastUpdate = currentTime

        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end

        local playerPos = Player.Character.HumanoidRootPart.Position

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent and not obj:IsDescendantOf(Player.Character) then
                SafeCall(function()
                    -- KHÔNG ẨN PARTS CỦA MAP
                    if IsMapPart(obj) then
                        return -- Bỏ qua map parts
                    end

                    local distance = (obj.Position - playerPos).Magnitude

                    -- CHỈ ẨN objects XA và KHÔNG PHẢI MAP
                    if distance > Config.RenderDistance * 2 then
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

    print("✅ Render distance đã kích hoạt (Giữ map)")
end

-- ===== 4. TỐI ƯU TERRAIN =====
local function OptimizeTerrain()
    print("🏔️ Tối ưu địa hình...")

    SafeCall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0.5
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
    end)

    print("✅ Địa hình đã tối ưu")
end

-- ===== 5. GIẢM PHYSICS =====
local function ReducePhysics()
    print("⚙️ Giảm physics objects nhỏ...")

    local count = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or {}) then
                -- CHỈ xử lý objects NHỎ, KHÔNG PHẢI MAP
                if obj.Size.Magnitude < 5 and not IsMapPart(obj) then
                    -- Xóa BodyMovers
                    for _, child in pairs(obj:GetChildren()) do
                        if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or
                           child:IsA("BodyPosition") or child:IsA("BodyForce") then
                            child:Destroy()
                            count = count + 1
                        end
                    end
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
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(0.7)
                end
            end
        end
    end)

    print("✅ Animations đã được tối ưu")
end

-- ===== 7. MEMORY CLEANUP =====
local function AggressiveMemoryCleanup()
    print("🧹 Dọn bộ nhớ...")

    SafeCall(function()
        for i = 1, 5 do
            collectgarbage("collect")
            task.wait(0.05)
        end

        PerformanceStats.MemoryCleaned = PerformanceStats.MemoryCleaned + 1
    end)

    print("✅ Bộ nhớ đã được dọn")
end

-- ===== 8. TỐI ƯU CHARACTER (LÀM ĐẦU TRONG SUỐT) =====
local function OptimizeCharacter(character)
    task.wait(0.5)

    SafeCall(function()
        -- ===== MỚI: LÀM ĐẦU NGƯỜI CHƠI LOCAL TRONG SUỐT =====
        if character.Parent == Player then
            local head = character:FindFirstChild("Head")
            if head then
                -- Làm trong suốt hoàn toàn và vô hiệu hóa va chạm
                head.Transparency = 1
                head.CanCollide = false
                print("✅ Đã làm trong suốt đầu người chơi local")
            end
        end

        -- Tối ưu accessories cho tất cả người chơi
        for _, accessory in pairs(character:GetChildren()) do
            if accessory:IsA("Accessory") then
                local handle = accessory:FindFirstChild("Handle")
                if handle then
                    handle.Material = Enum.Material.Plastic
                    handle.Reflectance = 0
                    handle.CastShadow = false
                end
            end
        end

        -- Tối ưu body parts cho tất cả người chơi
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.Plastic
                part.Reflectance = 0
                part.CastShadow = false
            end
        end
    end)
end

-- ===== 9. FPS LIMITER =====
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

    print("✅ FPS đã được giới hạn")
end

-- ===== 10. AUTO CLEANUP =====
local function AutoCleanup()
    task.spawn(function()
        while task.wait(30) do
            print("🔄 Auto cleanup...")
            AggressiveMemoryCleanup()
            LastCleanup = tick()
        end
    end)
end

-- ===== 11. TỐI ƯU PLAYERS KHÁC =====
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

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  🚀 ULTRA LAG FIX PRO V4.0 (REALME C11 EDITION)       ║")
    print("║  📱 Tối ưu siêu cấp - Làm đầu trong suốt - Giữ map      ║")
    print("╚" .. string.rep("═", 60) .. "╝")

    local startTime = tick()

    OptimizeGraphics()
    task.wait(0.2)

    RemoveAllEffects()
    task.wait(0.2)

    OptimizeTerrain()
    task.wait(0.2)

    ReducePhysics()
    task.wait(0.2)

    SmartRenderDistance()
    task.wait(0.2)

    OptimizeAnimations()
    task.wait(0.2)

    AggressiveMemoryCleanup()
    task.wait(0.2)

    LimitFPS()
    task.wait(0.2)

    OptimizeOtherPlayers()

    if Player.Character then
        OptimizeCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(character)
        task.wait(1)
        OptimizeCharacter(character)
    end)

    AutoCleanup()

    local endTime = tick()
    local loadTime = math.floor((endTime - startTime) * 100) / 100

    print("╔" .. string.rep("═", 60) .. "╗")
    print("║  ✅ TỐI ƯU HOÀN TẤT - MAP VẪN HIỂN THỊ!                 ║")
    print("║  🤖 Đầu người chơi local đã được làm trong suốt           ║")
    print("║  ⏱️  Thời gian: " .. loadTime .. " giây" .. string.rep(" ", 37 - #tostring(loadTime)) .. "║")
    print("║  📊 Parts tối ưu: " .. PerformanceStats.PartsOptimized .. string.rep(" ", 37 - #tostring(PerformanceStats.PartsOptimized)) .. "║")
    print("║  🧹 Effects xóa: " .. PerformanceStats.EffectsRemoved .. string.rep(" ", 38 - #tostring(PerformanceStats.EffectsRemoved)) .. "║")
    print("║  💡 Map được giữ nguyên, chỉ xóa hiệu ứng thừa          ║")
    print("║  🔄 Auto cleanup mỗi 30 giây                             ║")
    print("╚" .. string.rep("═", 60) .. "╝")
end

-- Chạy script với xử lý lỗi
SafeCall(Initialize)