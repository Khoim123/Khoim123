-- =====================================================
-- ==   REALME C11 - TỐI ƯU AN TOÀN (v3 - FIX LỖI)   ==
-- ==   Sử dụng pcall để tránh lỗi khi Roblox cập nhật  ==
-- ==   Mục tiêu: Chạy ổn định trên mọi phiên bản       ==
-- =====================================================
print("🚀 Khởi động Tối ưu An Toàn cho Realme C11...")

-- Services
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserSettings = game:GetService("UserSettings")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI GIẢN =====
local CLEANUP_EFFECTS = true
local OPTIMIZE_CHARACTERS = true
local ENABLE_STREAMING = true
local ENABLE_MOTION_REDUCTION = true
local MOTION_REDUCTION_FACTOR = 0.85

-- ===== HÀM AN TOÀN ĐỂ GỌI CÁC LỆNH CÓ THỂ LỖI =====
local function safeExecute(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn("⚠️ Lỗi: " .. errorMessage .. " | Chi tiết: " .. tostring(result))
    else
        return true
    end
    return false
end

-- ===== 1. POTATO GRAPHICS (An toàn) =====
local function applyPotatoGraphics()
    print("🥔 Kích hoạt Potato Graphics (Chế độ an toàn)...")

    -- Chất lượng render
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    -- Sử dụng safeExecute để tránh lỗi với UserSettings
    safeExecute(function()
        local GameSettings = UserSettings().GameSettings
        GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end, "Không thể thiết lập SavedQualityLevel")

    -- Tối ưu Camera
    Camera.FieldOfView = 70
    
    -- Tối ưu Lighting
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.Brightness = 2.5
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ClockTime = 14

    -- Xóa hoàn toàn sương mù
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9

    -- Tối ưu Terrain - Sử dụng safeExecute cho các thuộc tính có thể bị lỗi
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        safeExecute(function()
            terrain.Decoration = false -- Dòng này thường gây lỗi trên các bản Roblox mới
        end, "Không thể tắt Terrain Decoration (có thể đã bị lỗi thời)")
        
        safeExecute(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end, "Không thể tối ưu Water của Terrain")
    end
    
    -- Xóa các hiệu ứng ánh sáng môi trường một cách an toàn
    for _, child in pairs(Lighting:GetChildren()) do
        safeExecute(function()
            if child:IsA("Sky") or child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("ColorCorrectionEffect") then
                child:Destroy()
            end
        end, "Không thể xóa hiệu ứng ánh sáng: " .. child.Name)
    end
    print("✅ Hoàn tất Potato Graphics.")
end

-- ===== 2. DỌN DẸP WORKSPACE (An toàn) =====
local function cleanupWorkspace()
    if not CLEANUP_EFFECTS then return end
    print("🧹 Dọn dẹp Effects và Textures...")

    local partsOptimized = 0
    local effectsRemoved = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Xóa các hiệu ứng gây lag
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
           obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") or
           obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            safeExecute(function() obj:Destroy() end, "Không thể xóa effect: " .. obj.Name)
            effectsRemoved = effectsRemoved + 1
            continue
        end

        -- Tối ưu Parts và MeshParts
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
            partsOptimized = partsOptimized + 1

            if obj:IsA("MeshPart") then
                obj.TextureID = ""
            end
        end
    end

    print("✅ Đã tối ưu " .. partsOptimized .. " parts và xóa " .. effectsRemoved .. " effects.")
end

-- ===== 3. GIẢM CHUYỂN ĐỘNG (Vẫn an toàn) =====
local function setupMotionReduction(character)
    if not ENABLE_MOTION_REDUCTION then return end
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.AnimationPlayed:Connect(function(animationTrack)
        safeExecute(function()
            animationTrack:AdjustSpeed(MOTION_REDUCTION_FACTOR)
        end, "Không thể điều chỉnh tốc độ animation")
    end)
end

-- ===== 4. TỐI ƯU NHÂN VẬT =====
local function optimizeCharacter(character)
    if not OPTIMIZE_CHARACTERS then return end
    task.wait(0.5)

    local isLocalPlayer = character.Parent == Player

    if isLocalPlayer then
        local head = character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            local face = head:FindFirstChild("face")
            if face then face.Transparency = 1 end
        end
    end

    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
            part.CastShadow = false
        end
        if part:IsA("ParticleEmitter") or part:IsA("Trail") then
            safeExecute(function() part:Destroy() end, "Không thể xóa effect trên nhân vật")
        end
    end
    
    setupMotionReduction(character)
end

-- ===== 5. KÍCH HOẠT STREAMING =====
local function setupStreaming()
    if not ENABLE_STREAMING then return end
    print("📡 Kích hoạt Roblox Streaming...")
    Workspace.StreamingEnabled = true
    Workspace.StreamingTargetRadius = 64
    Workspace.StreamingMinRadius = 32
end

-- ===== KHỞI ĐỘNG CHÍNH =====
local function Initialize()
    local startTime = tick()

    print("╔" .. string.rep("═", 58) .. "╗")
    print("║  🔥 TỐI ƯU AN TOÀN - REALME C11 EDITION            ║")
    print("║  🛡️ Chống lỗi, ổn định trên mọi phiên bản Roblox    ║")
    print("╚" .. string.rep("═", 58) .. "╝")

    -- 1. Kích hoạt Potato Graphics (An toàn)
    applyPotatoGraphics()

    -- 2. Kích hoạt Streaming
    setupStreaming()

    -- 3. Dọn dẹp Workspace (An toàn)
    cleanupWorkspace()

    -- 4. Tối ưu nhân vật
    if Player.Character then
        optimizeCharacter(Player.Character)
    end
    Player.CharacterAdded:Connect(optimizeCharacter)

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            optimizeCharacter(otherPlayer.Character)
        end
    end
    Players.PlayerAdded:Connect(function(otherPlayer)
        otherPlayer.CharacterAdded:Connect(optimizeCharacter)
    end)

    -- 5. Dọn dẹp bộ nhớ lần cuối
    print("🗑️ Dọn dẹp bộ nhớ...")
    collectgarbage("collect")

    local endTime = tick()
    local loadTime = math.floor((endTime - startTime) * 100) / 100

    print("\n╔" .. string.rep("═", 58) .. "╗")
    print("║  ✅ TỐI ƯU HOÀN TẤT!                             ║")
    print("║                                                    ║")
    print("║  ⏱️  Thời gian: " .. string.format("%.2f", loadTime) .. "s                              ║")
    print("║  🥔 Potato Graphics: BẬT                           ║")
    print("║  🌫️  Sương mù: ĐÃ XÓA                               ║")
    print("║  🏃 Giảm chuyển động: BẬT ("..(MOTION_REDUCTION_FACTOR*100).."%)               ║")
    print("║  📡 StreamingEnabled: BẬT                           ║")
    print("║  🛡️ Chế độ an toàn: ĐÃ KÍCH HOẠT                    ║")
    print("╚" .. string.rep("═", 58) .. "╝")
end

-- Chạy script
Initialize()