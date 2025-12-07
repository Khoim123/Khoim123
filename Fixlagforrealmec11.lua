--[[ 
    SIÊU TỐI ƯU CHO REALME C11
    Chức năng: Potato Graphics, No Fog, FPS Boost
]]

local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local RunService = game:GetService("RunService")

-- 1. Xóa Sương mù & Chỉnh sáng (No Fog & Full Bright)
function OptiLighting()
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2
    Lighting.ClockTime = 14 -- Giữ trời sáng ban ngày
    
    -- Xóa các hiệu ứng môi trường nặng
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end

-- 2. Chế độ Potato (Làm mượt vật thể)
function PotatoMode()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
            v.TopSurface = Enum.SurfaceType.Smooth
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy() -- Xóa họa tiết
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false -- Tắt hiệu ứng hạt
        end
    end
    
    -- Tối ưu địa hình (Terrain)
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

-- Chạy Script
local success, err = pcall(function()
    OptiLighting()
    PotatoMode()
    -- Giữ cho Lighting không bị game reset
    Lighting.Changed:Connect(function()
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
    end)
end)

if success then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Realme C11 Optimized";
        Text = "Đã bật chế độ siêu mượt!";
        Duration = 5;
    })
else
    warn("Lỗi script: " .. err)
end
