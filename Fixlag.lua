-- Blox Fruits FPS Booster Script - Phiên bản Sửa Lỗi v2.1
-- Tối ưu hóa đồ họa để tăng FPS (Hỗ trợ mobile/low-end PC)
-- Tác giả: Cải tiến từ script gốc, sửa lỗi Camera

local Lighting = game:GetService("Lighting")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserSettings = UserSettings()
local GameSettings = UserSettings:GetService("UserGameSettings")
local StarterGui = game:GetService("StarterGui")

-- Config dễ chỉnh
local CONFIG = {
    EnableFPSCounter = true,  -- Bật/tắt FPS UI
    TargetQuality = Enum.QualityLevel.Level01,  -- Mức chất lượng (Level01 thấp nhất)
    GCInterval = 30,  -- Giây giữa các lần GC
    DebounceTime = 0.2  -- Delay cho DescendantAdded để tránh spam (tăng từ 0.1)
}

-- Biến toàn cục
local isBoosted = false
local lastDebounce = 0
local lastTime = tick()
local fpsHistory = {}  -- Để tính FPS trung bình mượt hơn

-- Thông báo bắt đầu
print("=== FPS Booster v2.1 đang khởi động (Sửa lỗi Camera) ===")

-- Hàm tối ưu Part (giữ nguyên, đã tốt)
local function optimizePart(v)
    pcall(function()
        if v:IsA("BasePart") then  -- Bao quát Part, MeshPart, UnionOperation
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("PointLight") or v:IsA("SpotLight") then
            v.Enabled = false
        elseif v:IsA("Sound") then  -- Tắt âm thanh không cần
            v.Volume = 0
        end
    end)
end

-- Hàm chính: Áp dụng booster (sửa lỗi camera)
local function applyBoost()
    if isBoosted then return end
    isBoosted = true
    
    -- 1. TẮT HIỆU ỨNG ÁNH SÁNG
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then  -- Bao quát Blur, SunRays, etc.
            effect.Enabled = false
        end
    end
    
    -- 2. TỐI ƯU TERRAIN
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    
    -- 3. TỐI ƯU WORKSPACE
    for _, v in pairs(workspace:GetDescendants()) do
        optimizePart(v)
    end
    
    -- 4. TỐI ƯU NHÂN VẬT
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                optimizePart(v)
            end
        end
    end
    
    -- 5. SETTINGS RENDERING
    settings().Rendering.QualityLevel = CONFIG.TargetQuality
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
    GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    
    pcall(function()
        settings().Rendering.EnableFRM = false
        settings().Rendering.EagerBulkExecution = false
    end)
    
    -- 6. CAMERA & PLAYER TỐI ƯU (SỬA LỖI: Loại bỏ MaxAxisRotation, thêm pcall)
    local camera = workspace.CurrentCamera
    if camera then
        pcall(function()
            camera.FieldOfView = 70  -- Hợp lệ, giảm FOV để tăng FPS nhẹ
        end)
    end
    pcall(function()
        StarterGui:SetCore("AutoJumpEnabled", false)  -- Tắt auto-jump
    end)
    
    -- 7. GC ĐỊNH KỲ
    spawn(function()
        while isBoosted do
            task.wait(CONFIG.GCInterval)
            collectgarbage("collect")
        end
    end)
    
    -- 8. FPS COUNTER (cải tiến: dùng Heartbeat ổn định hơn)
    if CONFIG.EnableFPSCounter then
        local FpsLabel = Instance.new("ScreenGui")
        FpsLabel.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        FpsLabel.Name = "FPSCounter"
        FpsLabel.ResetOnSpawn = false  -- Không reset khi respawn
        
        local Label = Instance.new("TextLabel")
        Label.Parent = FpsLabel
        Label.Size = UDim2.new(0, 200, 0, 50)
        Label.Position = UDim2.new(0, 10, 0, 10)
        Label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Label.BackgroundTransparency = 0.3
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 18
        Label.Font = Enum.Font.SourceSansBold
        Label.Text = "FPS: Calculating..."
        
        -- Tính FPS mượt (trung bình 10 frames, dùng Heartbeat)
        RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            local delta = currentTime - lastTime
            if delta > 0 then  -- Tránh chia 0
                lastTime = currentTime
                
                table.insert(fpsHistory, 1 / delta)
                if #fpsHistory > 10 then
                    table.remove(fpsHistory)
                end
                
                local avgFps = 0
                for _, f in ipairs(fpsHistory) do
                    avgFps = avgFps + f
                end
                avgFps = avgFps / math.max(1, #fpsHistory)  -- Tránh chia 0
                
                Label.Text = "FPS: " .. math.floor(avgFps)
                
                -- Màu sắc dựa trên FPS
                if avgFps > 60 then
                    Label.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Xanh
                elseif avgFps > 30 then
                    Label.TextColor3 = Color3.fromRGB(255, 255, 0)  -- Vàng
                else
                    Label.TextColor3 = Color3.fromRGB(255, 0, 0)  -- Đỏ
                end
            end
        end)
    end
    
    print("=== FPS Booster v2.1 đã kích hoạt thành công! (Không còn lỗi Camera) ===")
    print("- Đã tắt shadows, effects & particles")
    print("- Đã tối ưu terrain & materials")
    print("- Đã giảm rendering quality xuống " .. tostring(CONFIG.TargetQuality))
    print("- FPS Counter: Bật (nếu config true)")
end

-- 9. TỐI ƯU MỚI (với debounce)
workspace.DescendantAdded:Connect(function(v)
    if tick() - lastDebounce < CONFIG.DebounceTime then return end
    lastDebounce = tick()
    task.wait()  -- Delay nhỏ
    optimizePart(v)
end)

-- 10. PLAYER MỚI
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)  -- Delay để character load
        for _, v in pairs(character:GetDescendants()) do
            optimizePart(v)
        end
    end)
end)

-- Áp dụng ngay
applyBoost()

-- Toggle (gõ "/togglefps" trong chat để bật/tắt)
Players.LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/togglefps" then
        isBoosted = not isBoosted
        if isBoosted then
            applyBoost()
            print("FPS Booster: BẬT")
        else
            print("FPS Booster: TẮT (Reset settings để khôi phục)")
            -- Reset cơ bản
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            if Players.LocalPlayer.PlayerGui:FindFirstChild("FPSCounter") then
                Players.LocalPlayer.PlayerGui.FPSCounter:Destroy()
            end
        end
    end
end)