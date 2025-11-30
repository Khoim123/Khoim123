print("🔧 Khởi động Ultra Lag Fix Pro v3.1 (Fixed)...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH ĐÃ SỬA (GIỮ MAP) =====
local Config = {
    RenderDistance = 150,       -- TĂNG LÊN để thấy map (thay vì 60)
    GraphicsQuality = 1,
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = false,       -- GIỮ decals quan trọng
    RemoveTextures = false,     -- GIỮ textures để thấy map
    OptimizeTerrain = true,
    DisableAllEffects = true,
    ReducePhysics = false,      -- KHÔNG xóa physics map
    OptimizeAnimations = true,
    ReduceGUI = false,
    DisableFog = true,
    MaxFPS = 50,
    AggressiveMemory = true,
    DisableAudio = false,
    SimplifyMeshes = false,     -- GIỮ meshes
    ReduceParticleCount = true,
    DisablePostProcessing = true,
    LowPowerMode = true,
    KeepMapVisible = true,      -- CỜ MỚI: giữ map
}

-- ===== DANH SÁCH PARTS QUAN TRỌNG (KHÔNG XÓA) =====
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
    "Platform"
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

-- KIỂM TRA PART CÓ PHẢI MAP KHÔNG
local function IsMapPart(obj)
    if not obj or not obj.Parent then return false end
    
    -- Kiểm tra tên
    for _, keyword in ipairs(ImportantObjects) do
        if string.find(string.lower(obj.Name), string.lower(keyword)) then
            return true
        end
    end
    
    -- Kiểm tra parent
    if obj.Parent and obj.Parent.Name then
        for _, keyword in ipairs(ImportantObjects) do
            if string.find(string.lower(obj.Parent.Name), string.lower(keyword)) then
                return true
            end
        end
    end
    
    -- Kiểm tra nếu là part cố định lớn (có thể là map)
    if obj:IsA("BasePart") and obj.Anchored and obj.Size.Magnitude > 10 then
        return true
    end
    
    return false
end

-- ===== 1. ĐỒ HỌA CỰC THẤP =====
local function OptimizeGraphics()
    print("📊 Tối ưu đồ họa...")

    SafeCall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 -- TĂNG để thấy map
        settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01

        -- Tắt ánh sáng động
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 5
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0

        -- Tắt sương mù
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0

        -- Xóa chỉ hiệu ứng không cần thiết
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                SafeCall(function() effect:Destroy() end)
            end
        end
    end)

    print("✅ Đồ họa đã tối ưu")
end

-- ===== 2. XÓA HIỆU ỨNG (GIỮ MAP) =====
local function RemoveAllEffects()
    print("🧹 Xóa hiệu ứng không cần thiết...")

    local count = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeCall(function()
            -- Xóa PARTICLES (không ảnh hưởng map)
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or
               obj:IsA("Beam") then
                obj.Enabled = false
                count = count + 1
            end

            -- Xóa ÁNH SÁNG (không ảnh hưởng map)
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
                count = count + 1
            end

            -- TỐI ƯU PARTS (KHÔNG LÀM MẤT MAP)
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false

                -- CHỈ xóa texture của objects KHÔNG PHẢI MAP
                if obj:IsA("MeshPart") and Config.RemoveTextures and not IsMapPart(obj) then
                    obj.TextureID = ""
                end

                PerformanceStats.PartsOptimized = PerformanceStats.PartsOptimized + 1
            end
        end)
    end

    PerformanceStats.EffectsRemoved = count
    print("✅ Đã xóa " .. count .. " hiệu ứng")
end

-- ===== 3. RENDER DISTANCE THÔNG MINH (ĐÃ SỬA) =====
local function SmartRenderDistance()
    print("👁️ Kích hoạt render distance thông minh...")

    local lastUpdate = 0
    local updateInterval = 2 -- Giảm tần suất update

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
            terrain.WaterTransparency = 0.5 -- GIỮ một chút để thấy nước
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
    end)

    print("✅ Địa hình đã tối ưu")
end

-- ===== 5. GIẢM PHYSICS (CHỈ OBJECTS NHỎ) =====
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

-- ===== 8. TỐI ƯU CHARACTER =====
local function OptimizeCharacter(character)
    task.wait(0.5)

    SafeCall(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = 0
            humanoid.NameDisplayDistance = 0
        end

        -- Tối ưu accessories
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
    print("║  🚀 ULTRA LAG FIX PRO V3.1 (FIXED MAP)                   ║")
    print("║  📱 Tối ưu cho Realme C11 - GIỮ MAP                      ║")
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
    print("║  ⏱️  Thời gian: " .. loadTime .. " giây" .. string.rep(" ", 37 - #tostring(loadTime)) .. "║")
    print("║  📊 Parts tối ưu: " .. PerformanceStats.PartsOptimized .. string.rep(" ", 37 - #tostring(PerformanceStats.PartsOptimized)) .. "║")
    print("║  🧹 Effects xóa: " .. PerformanceStats.EffectsRemoved .. string.rep(" ", 38 - #tostring(PerformanceStats.EffectsRemoved)) .. "║")
    print("║  💡 Map được giữ nguyên, chỉ xóa hiệu ứng thừa          ║")
    print("║  🔄 Auto cleanup mỗi 30 giây                             ║")
    print("╚" .. string.rep("═", 60) .. "╝")
end

SafeCall(Initialize)