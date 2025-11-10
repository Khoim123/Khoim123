-- Blox Fruits FPS Booster Script
-- Tối ưu hóa đồ họa để tăng FPS

local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Thông báo bắt đầu
print("=== FPS Booster đang khởi động ===")

-- 1. TẮT CÁC HIỆU ỨNG ÁNH SÁNG
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.Brightness = 0

-- Xóa các hiệu ứng ánh sáng
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("BlurEffect") or 
       effect:IsA("SunRaysEffect") or 
       effect:IsA("ColorCorrectionEffect") or 
       effect:IsA("BloomEffect") or
       effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

-- 2. TỐI ƯU TERRAIN
settings().Rendering.QualityLevel = "Level01"
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0

-- 3. TỐI ƯU TẤT CẢ CÁC PARTS
local function optimizePart(v)
    if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.CastShadow = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.TextureID = ""
    end
end

-- Áp dụng tối ưu cho workspace
for _, v in pairs(workspace:GetDescendants()) do
    optimizePart(v)
end

-- 4. TỐI ƯU NHÂN VẬT NGƯỜI CHƠI
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            optimizePart(v)
        end
    end
end

-- 5. TỐI ƯU CÁC VẬT THỂ MỚI
workspace.DescendantAdded:Connect(function(v)
    wait()
    optimizePart(v)
end)

-- 6. TỐI ƯU NHÂN VẬT MỚI
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        for _, v in pairs(character:GetDescendants()) do
            optimizePart(v)
        end
    end)
end)

-- 7. GIẢM CHẤT LƯỢNG PIXEL VÀ ĐỘ PHÂN GIẢI
local camera = workspace.CurrentCamera
if camera then
    camera.FieldOfView = 70
end

-- Giảm độ phân giải render (Pixelated effect)
local UserSettings = UserSettings()
local GameSettings = UserSettings:GetService("UserGameSettings")

-- Đặt Graphics Quality xuống mức thấp nhất
GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1

-- Giảm Render Resolution
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level01

-- Tắt anti-aliasing và texture quality
pcall(function()
    settings().Rendering.EnableFRM = false
    settings().Rendering.EagerBulkExecution = false
end)

-- 8. GC (Garbage Collection) định kỳ
spawn(function()
    while true do
        wait(60) -- Mỗi 60 giây
        pcall(function()
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end)
    end
end)

print("=== FPS Booster đã kích hoạt thành công! ===")
print("- Đã tắt shadows và effects")
print("- Đã tối ưu terrain") 
print("- Đã giảm chất lượng materials")
print("- Đã tắt particles và trails")
print("- Đã giảm độ phân giải pixel xuống mức thấp nhất")

-- Hiển thị FPS counter
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
FpsLabel.Size = UDim2.new(0, 200, 0, 50)
FpsLabel.Position = UDim2.new(0, 10, 0, 10)
FpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FpsLabel.BackgroundTransparency = 0.5
FpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FpsLabel.TextSize = 20
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: Calculating..."

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    FpsLabel.Text = "FPS: " .. tostring(fps)
end)