-- ROBLOX SIÊU LAG FIX CHO REALME C11 (RAM 2GB)
-- Script tối ưu CỰC MẠNH - Skin người chơi màu trắng, người khác giữ nguyên

print("🔧 Đang khởi động SIÊU Lag Fix cho Realme C11...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH SIÊU TỐI ƯU =====
local Config = {
    RenderDistance = 80,
    GraphicsQuality = 1,
    RemoveShadows = true,
    RemoveParticles = true,
    RemoveDecals = true,
    RemoveTextures = true,
    OptimizeTerrain = true,
    DisableBloom = true,
    DisableBlur = true,
    ReducePhysics = true,
    MyPlayerWhite = true, -- Skin của BẠN màu trắng
    OtherPlayersNormal = true, -- Người khác giữ nguyên
    SimplifyAccessories = true,
    ReduceAnimationQuality = true,
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

-- ===== 2. XÓA TEXTURE VÀ ĐỔI MÀU TRẮNG CHO NGƯỜI CHƠI CỦA BẠN =====
local function RemoveMyPlayerTextures(character)
    if not character then return end
    
    print("👤 Đang xóa họa tiết và đổi màu TRẮNG cho nhân vật của bạn...")
    
    for _, part in pairs(character:GetDescendants()) do
        -- Xử lý body parts
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            -- Xóa texture
            if part:IsA("MeshPart") then
                part.TextureID = ""
            end
            
            -- Đơn giản hóa material
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
            part.CastShadow = false
            
            -- ĐỔI TẤT CẢ BODY PARTS THÀNH MÀU TRẮNG
            if part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or
               part.Name == "LowerTorso" or part.Name == "LeftUpperArm" or part.Name == "RightUpperArm" or
               part.Name == "LeftLowerArm" or part.Name == "RightLowerArm" or 
               part.Name == "LeftUpperLeg" or part.Name == "RightUpperLeg" or
               part.Name == "LeftLowerLeg" or part.Name == "RightLowerLeg" or
               part.Name == "LeftHand" or part.Name == "RightHand" or
               part.Name == "LeftFoot" or part.Name == "RightFoot" or
               part.Name == "HumanoidRootPart" then
                -- MÀU TRẮNG TINH
                part.Color = Color3.fromRGB(255, 255, 255)
            end
        end
        
        -- Xóa Decals (mặt)
        if part:IsA("Decal") then
            part:Destroy()
        end
        
        -- Xóa texture trong SpecialMesh
        if part:IsA("SpecialMesh") then
            part.TextureId = ""
        end
        
        -- Xóa SurfaceAppearance
        if part:IsA("SurfaceAppearance") then
            part:Destroy()
        end
        
        -- Đơn giản hóa phụ kiện
        if part:IsA("Accessory") or part.Name == "Accessory" then
            if Config.SimplifyAccessories then
                local handle = part:FindFirstChild("Handle")
                if handle and handle:IsA("MeshPart") then
                    handle.TextureID = ""
                    handle.Material = Enum.Material.SmoothPlastic
                    handle.Color = Color3.fromRGB(255, 255, 255) -- Phụ kiện cũng trắng
                end
            end
        end
    end
    
    -- Xóa BodyColors
    local bodyColors = character:FindFirstChild("Body Colors")
    if bodyColors then
        bodyColors:Destroy()
    end
    
    -- Xóa Shirt và Pants (áo quần)
    for _, clothing in pairs(character:GetChildren()) do
        if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
            clothing:Destroy()
        end
    end
    
    print("✅ Đã đổi nhân vật của bạn thành màu TRẮNG")
end

-- ===== 3. XÓA CÁC HIỆU ỨNG KHÔNG CẦN THIẾT (KHÔNG ẢNH HƯỞNG NGƯỜI CHƠI KHÁC) =====
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

    print("✅ Hiệu ứng đã được xóa (người chơi khác GIỮ NGUYÊN)")
end

-- ===== 4. TỐI ƯU RENDER DISTANCE CỰC MẠNH =====
local function OptimizeRenderDistance()
    print("👁️ Đang tối ưu tầm nhìn CỰC MẠNH...")

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

-- ===== 5. TỐI ƯU TERRAIN =====
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

-- ===== 6. GIẢM PHYSICS CALCULATIONS =====
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

-- ===== 7. MEMORY CLEANUP =====
local function CleanupMemory()
    print("🧹 Đang dọn dẹp bộ nhớ...")

    for i = 1, 3 do
        task.wait(0.1)
        collectgarbage("collect")
    end

    print("✅ Bộ nhớ đã được dọn dẹp")
end

-- ===== 8. TỐI ƯU CHO CHARACTER CỦA PLAYER =====
local function OptimizeCharacter(character)
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and Config.ReduceAnimationQuality then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(0.8)
            end
        end
    end
end

-- ===== 9. THEO DÕI NGƯỜI CHƠI MỚI (Giữ nguyên họ) =====
local function SetupPlayerTracking()
    -- Theo dõi người chơi mới tham gia
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(newCharacter)
            -- KHÔNG làm gì với người chơi khác - giữ nguyên hoàn toàn
            print("👥 Người chơi mới: " .. newPlayer.Name .. " - GIỮ NGUYÊN")
        end)
    end)
    
    -- Giữ nguyên tất cả người chơi hiện tại (trừ bạn)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player then
            print("👥 Người chơi: " .. otherPlayer.Name .. " - GIỮ NGUYÊN")
        end
    end
end

-- ===== KHỞI ĐỘNG SCRIPT =====
local function Initialize()
    print("=" .. string.rep("=", 50))
    print("🚀 ROBLOX SIÊU LAG FIX CHO REALME C11")
    print("📱 Tối ưu đặc biệt cho RAM 2GB")
    print("👤 Bạn: MÀU TRẮNG | Người khác: GIỮ NGUYÊN")
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
    
    -- Setup theo dõi người chơi
    SetupPlayerTracking()

    -- Đổi skin của BẠN thành màu trắng
    if Player.Character then
        RemoveMyPlayerTextures(Player.Character)
        OptimizeCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(character)
        task.wait(1)
        RemoveMyPlayerTextures(character) -- Chỉ đổi màu BẠN
        OptimizeCharacter(character)
    end)

    -- Cleanup định kỳ
    task.spawn(function()
        while task.wait(60) do
            CleanupMemory()
        end
    end)

    print("=" .. string.rep("=", 50))
    print("✅ TỐI ƯU HOÀN TẤT!")
    print("👤 Nhân vật của BẠN: MÀU TRẮNG TINH ✨")
    print("👥 Người chơi KHÁC: GIỮ NGUYÊN MÀU 🎨")
    print("📊 FPS sẽ cải thiện đáng kể")
    print("💡 Nếu vẫn lag, hãy tắt các app khác")
    print("=" .. string.rep("=", 50))
end

-- Chạy script
Initialize()