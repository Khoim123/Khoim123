-- ROBLOX FPS BOOSTER SCRIPT
-- Script giảm lag cho mọi game Roblox
-- Tương thích với mọi executor

print("========================================")
print("     ROBLOX FPS BOOSTER V1.0")
print("     Script giảm lag đơn giản")
print("========================================")

local function notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "FPS Booster";
        Text = text;
        Duration = 3;
    })
end

notify("Đang khởi động FPS Booster...")

-- 1. TẮT CHẾ ĐỘ ĐỒ HỌA CAO
local function reduceLag()
    local lighting = game:GetService("Lighting")
    local terrain = workspace.Terrain
    
    -- Giảm chất lượng ánh sáng
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    lighting.Brightness = 0
    
    -- Tắt hiệu ứng ánh sáng
    for _, effect in pairs(lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    -- Tối ưu địa hình
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    
    print("✓ Đã giảm chất lượng đồ họa")
end

-- 2. XÓA CÁC HIỆU ỨNG KHÔNG CẦN THIẾT
local function removeEffects()
    local count = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or 
           obj:IsA("Trail") or 
           obj:IsA("Smoke") or 
           obj:IsA("Fire") or 
           obj:IsA("Sparkles") then
            obj.Enabled = false
            count = count + 1
        end
        
        -- Xóa decal và texture
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
            count = count + 1
        end
    end
    
    print("✓ Đã tắt " .. count .. " hiệu ứng")
end

-- 3. TỐI ƯU PARTS VÀ MESHES
local function optimizeParts()
    local count = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Giảm chất lượng mesh
        if obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
            count = count + 1
        end
        
        -- Tắt bóng đổ
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            count = count + 1
        end
    end
    
    print("✓ Đã tối ưu " .. count .. " đối tượng")
end

-- 4. TẮT ANIMATIONS KHÔNG CẦN THIẾT
local function optimizeAnimations()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.Name ~= "WalkAnim" and track.Name ~= "RunAnim" then
                            track:Stop()
                        end
                    end
                end
            end
        end
    end
    
    print("✓ Đã tối ưu animations")
end

-- 5. TỐI ƯU GUI
local function optimizeGUI()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("ImageLabel") or gui:IsA("ImageButton") then
            gui.ImageTransparency = 0.5
        end
    end
    
    print("✓ Đã tối ưu GUI")
end

-- 6. TẮT ÂMTHANH KHÔNG CẦN THIẾT (tùy chọn)
local function muteAmbientSounds()
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") and sound.Playing then
            if not sound.Parent:IsA("Humanoid") then
                sound.Volume = 0
            end
        end
    end
    
    print("✓ Đã giảm âm thanh môi trường")
end

-- CHẠY TẤT CẢ TỐI ƯU HÓA
local success, error = pcall(function()
    reduceLag()
    wait(0.5)
    removeEffects()
    wait(0.5)
    optimizeParts()
    wait(0.5)
    optimizeAnimations()
    wait(0.5)
    optimizeGUI()
    wait(0.5)
    muteAmbientSounds()
end)

if success then
    notify("✓ FPS Booster đã kích hoạt thành công!")
    print("========================================")
    print("✓ TẤT CẢ TỐI ƯU ĐÃ HOÀN TẤT")
    print("FPS của bạn sẽ được cải thiện!")
    print("========================================")
else
    notify("⚠️ Có lỗi xảy ra: " .. tostring(error))
    warn("Lỗi: " .. tostring(error))
end

-- TỰ ĐỘNG TỐI ƯU KHI CÓ ĐỐI TƯỢNG MỚI
workspace.DescendantAdded:Connect(function(obj)
    wait(1)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
    elseif obj:IsA("MeshPart") then
        obj.RenderFidelity = Enum.RenderFidelity.Performance
    end
end)

print("🔄 Chế độ tự động tối ưu đã bật!")
notify("Script đang chạy liên tục...")