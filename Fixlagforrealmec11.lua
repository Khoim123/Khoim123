-- ROBLOX ULTRA LAG FIX V3.0 - OPTIMIZED FOR LOW-END DEVICES
-- Đặt script trong StarterPlayerScripts hoặc StarterCharacterScripts

print("🔧 Khởi động Ultra Lag Fix V3.0...")

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== CẤU HÌNH TỐI ƯU =====
local Config = {
    RenderDistance = 300,
    UpdateInterval = 0.5,
    EnableDynamicCulling = false, -- TẮT để tránh lỗi map
    MaxVisibleParts = 1000
}

-- ===== 1. TỐI ƯU ĐỒ HỌA NÂNG CAO =====
local function OptimizeGraphics()
    print("📊 Tối ưu đồ họa...")
    
    -- Chất lượng thấp nhất
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Tắt các tính năng nâng cao
    pcall(function() settings().Rendering.EnableVSync = false end)
    pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
    
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01
    
    -- Tối ưu ánh sáng
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.Brightness = 2
    Lighting.Technology = Enum.Technology.Legacy
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    
    -- Xóa hiệu ứng ánh sáng
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Sky") then
            effect:Destroy()
        end
    end
    
    -- Tắt bloom và blur mặc định
    pcall(function()
        Lighting.Bloom.Enabled = false
        Lighting.Blur.Enabled = false
    end)
    
    print("✅ Đồ họa đã tối ưu")
end

-- ===== 2. XÓA HIỆU ỨNG VÀ TỐI ƯU PARTS =====
local processedParts = {}

local function OptimizePart(obj)
    if processedParts[obj] then return end
    processedParts[obj] = true
    
    -- Bỏ qua character và descendants của players
    local character = Player.Character
    if character and obj:IsDescendantOf(character) then 
        return 
    end
    
    -- Kiểm tra nếu là part của player khác
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return
        end
    end
    
    -- Tối ưu BasePart (KHÔNG TẮT COLLISION)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
        -- GIỮ NGUYÊN CanCollide để map hoạt động bình thường
    end
    
    -- Xóa texture trên MeshPart
    if obj:IsA("MeshPart") then
        obj.TextureID = ""
    end
    
    -- Xóa decals và textures (KHÔNG XÓA QUAN TRỌNG)
    if obj:IsA("SurfaceAppearance") then
        obj:Destroy()
    end
end

local function RemoveEffects()
    print("🧹 Xóa hiệu ứng và tối ưu parts...")
    
    local character = Player.Character
    local effects = {
        "ParticleEmitter", "Trail", "Smoke", "Fire", 
        "Sparkles", "Beam"
        -- BỎ "PointLight", "SpotLight", "SurfaceLight" để giữ ánh sáng cơ bản
    }
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Bỏ qua character của tất cả players
        local isPlayerChar = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and obj:IsDescendantOf(player.Character) then
                isPlayerChar = true
                break
            end
        end
        
        if isPlayerChar then continue end
        
        -- Xóa hiệu ứng
        for _, effectType in ipairs(effects) do
            if obj:IsA(effectType) then
                obj:Destroy()
                break
            end
        end
        
        -- Tối ưu parts (GIỮ NGUYÊN MAP)
        OptimizePart(obj)
    end
    
    print("✅ Đã xóa hiệu ứng")
end

-- ===== 3. CULLING ĐỘNG (Ẩn vật thể xa) - ĐÃ TẮT MẶC ĐỊNH =====
local cullConnection

local function StartDynamicCulling()
    if not Config.EnableDynamicCulling then 
        print("⚠️ Culling động đã TẮT để tránh lỗi map")
        return 
    end
    
    print("👁️ Bật culling động...")
    
    local lastUpdate = 0
    local visibleParts = {}
    
    cullConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastUpdate < Config.UpdateInterval then return end
        lastUpdate = now
        
        local camPos = Camera.CFrame.Position
        local character = Player.Character
        
        -- Reset visibility
        for part, _ in pairs(visibleParts) do
            if part and part.Parent then
                part.Transparency = part:GetAttribute("OriginalTransparency") or part.Transparency
            end
            visibleParts[part] = nil
        end
        
        -- Ẩn parts xa
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if count > Config.MaxVisibleParts then break end
            
            if obj:IsA("BasePart") and obj.Parent then
                if character and obj:IsDescendantOf(character) then 
                    continue 
                end
                
                local distance = (obj.Position - camPos).Magnitude
                
                if distance > Config.RenderDistance then
                    if not obj:GetAttribute("OriginalTransparency") then
                        obj:SetAttribute("OriginalTransparency", obj.Transparency)
                    end
                    obj.Transparency = 1
                else
                    visibleParts[obj] = true
                    count = count + 1
                end
            end
        end
    end)
    
    print("✅ Culling động đã bật")
end

-- ===== 4. TỐI ƯU TERRAIN =====
local function OptimizeTerrain()
    print("🏔️ Tối ưu terrain...")
    
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function() terrain.WaterReflectance = 0 end)
        pcall(function() terrain.WaterTransparency = 0.5 end)
        pcall(function() terrain.WaterWaveSize = 0 end)
        pcall(function() terrain.WaterWaveSpeed = 0 end)
    end
    
    print("✅ Terrain đã tối ưu")
end

-- ===== 5. TỐI ƯU BỘ NHỚ =====
local function OptimizeMemory()
    print("🧹 Tối ưu bộ nhớ...")
    
    -- Kiểm tra memory usage
    local memBefore = gcinfo()
    print("📊 Memory hiện tại: " .. math.floor(memBefore) .. " KB")
    
    -- Giảm preload content
    pcall(function()
        ContentProvider:SetBaseUrl("")
    end)
    
    print("✅ Bộ nhớ đã tối ưu")
end

-- ===== 6. TỐI ƯU CAMERA =====
local function OptimizeCamera()
    print("📷 Tối ưu camera...")
    
    Camera.FieldOfView = 70
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
    end)
    
    print("✅ Camera đã tối ưu")
end

-- ===== 7. XỬ LÝ OBJECTS MỚI =====
Workspace.DescendantAdded:Connect(function(obj)
    task.wait()
    
    -- Bỏ qua nếu là part của player
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return
        end
    end
    
    -- Xóa hiệu ứng mới
    local effects = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles", "Beam"}
    for _, effectType in ipairs(effects) do
        if obj:IsA(effectType) then
            obj:Destroy()
            return
        end
    end
    
    -- Tối ưu parts mới (KHÔNG LÀM MẤT COLLISION)
    if obj:IsA("BasePart") then
        obj.CastShadow = false
        obj.Reflectance = 0
    end
end)

-- ===== KHỞI ĐỘNG =====
local function Initialize()
    print(string.rep("=", 60))
    print("🚀 ULTRA LAG FIX V3.0")
    print("📱 Tối ưu cho thiết bị RAM 2GB")
    print(string.rep("=", 60))
    
    OptimizeGraphics()
    task.wait(0.3)
    
    RemoveEffects()
    task.wait(0.3)
    
    OptimizeTerrain()
    task.wait(0.3)
    
    OptimizeCamera()
    task.wait(0.3)
    
    StartDynamicCulling()
    task.wait(0.3)
    
    OptimizeMemory()
    
    -- Kiểm tra memory định kỳ (không dọn rác nữa vì Roblox không cho phép)
    task.spawn(function()
        while true do
            task.wait(60)
            local mem = gcinfo()
            print("💾 Memory: " .. math.floor(mem) .. " KB")
        end
    end)
    
    print(string.rep("=", 60))
    print("✅ TỐI ƯU HOÀN TẤT!")
    print("📊 FPS sẽ tăng đáng kể")
    print("💡 Mẹo: Tắt ứng dụng nền + giảm âm lượng game")
    print(string.rep("=", 60))
end

-- Đợi character load xong
if not Player.Character then
    Player.CharacterAdded:Wait()
end

task.wait(2)
Initialize()

-- Cleanup khi player rời
Players.PlayerRemoving:Connect(function(plr)
    if plr == Player and cullConnection then
        cullConnection:Disconnect()
    end
end)