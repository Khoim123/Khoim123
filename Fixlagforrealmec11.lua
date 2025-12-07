-- ROBLOX SIÊU LAG FIX CHO REALME C11 (RAM 2GB)
-- Script tối ưu CỰC MẠNH - Đơn giản hóa, không thay đổi nhân vật

print("🔧 Đang khởi động SIÊU Lag Fix cho Realme C11...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH SIÊU TỐI ƯU =====
local Config = {
    RenderDistance = 250, -- TĂNG tầm nhìn tối đa
    GraphicsQuality = 1,
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = true,
    RemoveTextures = true,
    OptimizeTerrain = true,
    DisableBloom = true,
    DisableBlur = true,
    ReducePhysics = true,
}

-- ===== 1. TỐI ƯU ĐỒ HỌA SIÊU MẠNH =====
local function OptimizeGraphics()
    print("📊 Đang tối ưu đồ họa SIÊU MẠNH...")

    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.EnableVSync = false
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

    if Config.RemoveShadows then
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.Technology = Enum.Technology.Legacy
    end

    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or 
           effect:IsA("DepthOfFieldEffect") or effect:IsA("SkyEffect") then
            effect.Enabled = false
        end
    end

    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    print("✅ Đồ họa đã được tối ưu SIÊU MẠNH")
end

-- ===== 2. XÓA CÁC HIỆU ỨNG KHÔNG CẦN THIẾT (KHÔNG ẢNH HƯỞNG NGƯỜI CHƠI) =====
local function RemoveEffects()
    print("🧹 Đang xóa hiệu ứng...")

    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Bỏ qua tất cả người chơi (giữ nguyên)
        local isPlayerCharacter = false
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and obj:IsDescendantOf(player.Character) then
                isPlayerCharacter = true
                break
            end
        end

        if not isPlayerCharacter then
            -- Xóa Particle Effects
            if Config.RemoveParticles and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam")) then
                obj:Destroy()
            end

            -- Xóa Decals và Textures
            if Config.RemoveDecals and (obj:IsA("Decal") or obj:IsA("Texture")) then
                obj:Destroy()
            end

            -- Xóa SurfaceAppearance
            if obj:IsA("SurfaceAppearance") then
                obj:Destroy()
            end

            -- Tối ưu Material
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end

            -- Xóa texture MeshPart
            if obj:IsA("MeshPart") then
                obj.TextureID = ""
            end

            -- Xóa các SpecialMesh texture
            if obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end
        end
    end

    print("✅ Hiệu ứng đã được xóa (người chơi GIỮ NGUYÊN)")
end

-- ===== 3. TỐI ƯU RENDER DISTANCE =====
local function OptimizeRenderDistance()
    print("👁️ Đang tối ưu tầm nhìn...")

    local lastUpdate = 0
    local updateInterval = 0.5

    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        if currentTime - lastUpdate < updateInterval then return end
        lastUpdate = currentTime

        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = Player.Character.HumanoidRootPart.Position

            for _, obj in pairs(Workspace:GetChildren()) do
                -- BỎ QUA TẤT CẢ NGƯỜI CHƠI (giữ nguyên hiển thị)
                local isPlayerModel = false
                for _, player in pairs(Players:GetPlayers()) do
                    if obj == player.Character then
                        isPlayerModel = true
                        break
                    end
                end

                if not isPlayerModel and obj:IsA("Model") then
                    local primaryPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primaryPart then
                        local distance = (primaryPart.Position - playerPos).Magnitude

                        if distance > Config.RenderDistance then
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                    part.CanCollide = false
                                end
                            end
                        else
                            for _, part in pairs(obj:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    if not part:GetAttribute("OriginalTransparency") then
                                        part:SetAttribute("OriginalTransparency", part.Transparency)
                                    end
                                    part.Transparency = part:GetAttribute("OriginalTransparency")
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    print("✅ Tầm nhìn đã được tối ưu (người chơi LUÔN HIỂN THỊ)")
end

-- ===== 4. TỐI ƯU TERRAIN =====
local function OptimizeTerrain()
    if Config.OptimizeTerrain then
        print("🏔️ Đang tối ưu địa hình...")

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0.5
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end

        print("✅ Địa hình đã được tối ưu")
    end
end

-- ===== 5. GIẢM PHYSICS CALCULATIONS =====
local function ReducePhysics()
    if Config.ReducePhysics then
        print("⚙️ Đang giảm physics...")

        for _, obj in pairs(Workspace:GetDescendants()) do
            -- Bỏ qua người chơi
            local isPlayerPart = false
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and obj:IsDescendantOf(player.Character) then
                    isPlayerPart = true
                    break
                end
            end

            if not isPlayerPart and obj:IsA("BasePart") then
                if obj:FindFirstChild("BodyVelocity") or obj:FindFirstChild("BodyGyro") or
                   obj:FindFirstChild("BodyPosition") then
                    obj.Anchored = true
                end
            end
        end

        print("✅ Physics đã được giảm")
    end
end

-- ===== 6. MEMORY CLEANUP =====
local function CleanupMemory()
    print("🧹 Đang dọn dẹp bộ nhớ...")

    for i = 1, 3 do
        task.wait(0.1)
        collectgarbage("collect")
    end

    print("✅ Bộ nhớ đã được dọn dẹp")
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("=" .. string.rep("=", 50))
    print("🚀 ROBLOX SIÊU LAG FIX CHO REALME C11")
    print("📱 Tối ưu đặc biệt cho RAM 2GB")
    print("🎯 Tập trung vào hiệu suất, không thay đổi nhân vật")
    print("=" .. string.rep("=", 50))

    -- Chạy các tối ưu
    OptimizeGraphics()
    task.wait(0.5)

    RemoveEffects()
    task.wait(0.5)

    OptimizeTerrain()
    task.wait(0.5)

    ReducePhysics()
    task.wait(0.5)

    OptimizeRenderDistance()
    task.wait(0.5)

    CleanupMemory()

    -- Cleanup định kỳ
    task.spawn(function()
        while task.wait(60) do
            CleanupMemory()
        end
    end)

    print("=" .. string.rep("=", 50))
    print("✅ TỐI ƯU HOÀN TẤT!")
    print("📊 FPS sẽ cải thiện đáng kể")
    print("💡 Nếu vẫn lag, hãy tắt các app khác")
    print("=" .. string.rep("=", 50))
end

-- Chạy script
Initialize()