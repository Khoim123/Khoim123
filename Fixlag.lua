-- ROBLOX FPS BOOSTER SCRIPT
-- Xóa 90% đồ họa và hiệu ứng động để tăng FPS

local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")

print("Bắt đầu tối ưu hóa FPS...")

-- 1. TẮT TẤT CẢ HIỆU ỨNG ÁNH SÁNG
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

-- Xóa tất cả hiệu ứng ánh sáng
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or 
       effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or 
       effect:IsA("DepthOfFieldEffect") or effect:IsA("SunRaysEffect") then
        effect.Enabled = false
    end
end

-- 2. TỐI ƯU HÓA TERRAIN
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0
Terrain.Decoration = false

-- 3. XÓA HIỆU ỨNG PARTICLE VÀ TRAIL
local function removeEffects(object)
    for _, descendant in pairs(object:GetDescendants()) do
        -- Xóa hiệu ứng particle
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or 
           descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
            descendant.Enabled = false
            descendant:Destroy()
        end
        
        -- Xóa hiệu ứng ánh sáng
        if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or 
           descendant:IsA("SurfaceLight") then
            descendant.Enabled = false
            descendant:Destroy()
        end
        
        -- Giảm chất lượng texture
        if descendant:IsA("Decal") or descendant:IsA("Texture") then
            descendant.Transparency = 0.98
        end
        
        -- Tắt bóng của từng part
        if descendant:IsA("BasePart") then
            descendant.CastShadow = false
            descendant.Material = Enum.Material.SmoothPlastic
            
            -- Xóa reflect/specular
            if descendant:IsA("MeshPart") then
                descendant.Reflectance = 0
                descendant.TextureID = ""
            end
        end
        
        -- Xóa hiệu ứng mesh
        if descendant:IsA("SpecialMesh") then
            descendant.TextureId = ""
        end
    end
end

-- Áp dụng cho toàn bộ workspace
removeEffects(workspace)

-- 4. TỐI ƯU HÓA CHARACTER CỦA PLAYER
local function optimizeCharacter(character)
    if character then
        removeEffects(character)
        
        -- Giảm chi tiết nhân vật
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
            end
            
            -- Xóa accessories không cần thiết để tăng FPS
            if part:IsA("Accessory") then
                local handle = part:FindFirstChild("Handle")
                if handle and handle:IsA("MeshPart") then
                    handle.TextureID = ""
                end
            end
        end
    end
end

-- Tối ưu cho player hiện tại
local player = Players.LocalPlayer
if player.Character then
    optimizeCharacter(player.Character)
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    optimizeCharacter(character)
end)

-- Tối ưu cho tất cả player khác
for _, otherPlayer in pairs(Players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
        optimizeCharacter(otherPlayer.Character)
    end
    
    otherPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        optimizeCharacter(character)
    end)
end

-- 5. TỰ ĐỘNG XÓA HIỆU ỨNG MỚI
workspace.DescendantAdded:Connect(function(descendant)
    wait(0.1)
    if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or 
       descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles") then
        descendant.Enabled = false
        descendant:Destroy()
    elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") or 
           descendant:IsA("SurfaceLight") then
        descendant.Enabled = false
        descendant:Destroy()
    elseif descendant:IsA("BasePart") then
        descendant.CastShadow = false
    end
end)

-- 6. CÀI ĐẶT ĐỒ HỌA THẤP NHẤT
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

print("✓ Hoàn tất tối ưu hóa FPS!")
print("- Đã tắt tất cả hiệu ứng ánh sáng")
print("- Đã xóa particle, trail, smoke, fire")
print("- Đã tắt bóng đổ (shadows)")
print("- Đã giảm 90% chất lượng đồ họa")
print("FPS sẽ được cải thiện đáng kể!")