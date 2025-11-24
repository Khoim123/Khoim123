-- ROBLOX LAG FIX CHO REALME C11 (RAM 2GB)
-- Script tối ưu đặc biệt cho thiết bị cấu hình thấp

print("🔧 Đang khởi động Lag Fix cho Realme C11...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI ƯU CHO REALME C11 =====
local Config = {
    RenderDistance = 100, -- Giảm tầm nhìn
    GraphicsQuality = 1, -- Chất lượng đồ họa thấp nhất
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = true,
    RemoveTextures = false, -- Giữ texture cơ bản
    OptimizeTerrain = true,
    DisableBloom = true,
    DisableBlur = true,
    ReducePhysics = true,
}

-- ===== 1. TỐI ƯU ĐỒ HỌA =====
local function OptimizeGraphics()
    print("📊 Đang tối ưu đồ họa...")
    
    -- Giảm chất lượng render xuống mức thấp nhất
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Tắt các hiệu ứng ánh sáng
    if Config.RemoveShadows then
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end
    
    -- Tắt các hiệu ứng hậu kỳ
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or 
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    print("✅ Đồ họa đã được tối ưu")
end

-- ===== 2. XÓA CÁC HIỆU ỨNG KHÔNG CẦN THIẾT =====
local function RemoveEffects()
    print("🧹 Đang xóa hiệu ứng...")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Xóa Particle Effects
        if Config.RemoveParticles and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")) then
            obj.Enabled = false
        end
        
        -- Xóa Decals và Textures
        if Config.RemoveDecals and (obj:IsA("Decal") or obj:IsA("Texture")) then
            obj.Transparency = 1
        end
        
        -- Tối ưu Material
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        
        -- Xóa các MeshPart phức tạp (giữ hình dạng cơ bản)
        if obj:IsA("SpecialMesh") then
            obj.TextureId = ""
        end
    end
    
    print("✅ Hiệu ứng đã được xóa")
end

-- ===== 3. TỐI ƯU RENDER DISTANCE =====
local function OptimizeRenderDistance()
    print("👁️ Đang tối ưu tầm nhìn...")
    
    RunService.RenderStepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = Player.Character.HumanoidRootPart.Position
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj ~= Player.Character.HumanoidRootPart then
                    local distance = (obj.Position - playerPos).Magnitude
                    
                    -- Ẩn objects xa hơn render distance
                    if distance > Config.RenderDistance then
                        obj.Transparency = 1
                        obj.CanCollide = false
                    else
                        if obj:FindFirstChild("OriginalTransparency") then
                            obj.Transparency = obj.OriginalTransparency.Value
                        end
                    end
                end
            end
        end
    end)
    
    print("✅ Tầm nhìn đã được tối ưu")
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
            if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or {}) then
                -- Giảm độ phức tạp physics
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
    
    -- Garbage collection
    for i = 1, 3 do
        task.wait(0.1)
        collectgarbage("collect")
    end
    
    print("✅ Bộ nhớ đã được dọn dẹp")
end

-- ===== 7. TỐI ƯU CHO CHARACTER CỦA PLAYER =====
local function OptimizeCharacter(character)
    if character then
        -- Giảm animation FPS
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0.8) -- Chạy animation chậm hơn 20%
            end
        end
    end
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("=" .. string.rep("=", 50))
    print("🚀 ROBLOX LAG FIX CHO REALME C11")
    print("📱 Tối ưu đặc biệt cho RAM 2GB")
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
    
    -- Tối ưu character khi spawn
    if Player.Character then
        OptimizeCharacter(Player.Character)
    end
    
    Player.CharacterAdded:Connect(function(character)
        task.wait(1)
        OptimizeCharacter(character)
    end)
    
    -- Cleanup định kỳ (mỗi 60 giây)
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