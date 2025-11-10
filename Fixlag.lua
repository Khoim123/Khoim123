-- Blox Fruits FPS Booster Script - Phiên bản v2.5 (Giảm Pixel & Chất Lượng Tối Giản)
-- Tối ưu hóa đồ họa đến mức thấp nhất (pixelated, low-res textures)

local success, err = pcall(function()
    print("=== FPS Booster v2.5 đang khởi động (Tối Giản Graphics) ===")
    
    local Lighting = game:GetService("Lighting")
    print("Loading Lighting... OK")
    
    local Terrain = workspace:FindFirstChild("Terrain")
    if not Terrain then
        print("WARNING: No Terrain, skipping")
        Terrain = nil
    else
        print("Loading Terrain... OK")
    end
    
    local Players = game:GetService("Players")
    print("Loading Players... OK")
    
    local RunService = game:GetService("RunService")
    print("Loading RunService... OK")
    
    local UserSettings = UserSettings()
    local GameSettings = UserSettings:GetService("UserGameSettings")
    print("Loading Settings... OK")
    
    local StarterGui = game:GetService("StarterGui")
    print("Loading StarterGui... OK")
    
    local ContentProvider = game:GetService("ContentProvider")
    print("Loading ContentProvider... OK")
    
    -- Config
    local CONFIG = {
        TargetQuality = Enum.QualityLevel.Level01,  -- Thấp nhất
        GCInterval = 30,
        DebounceTime = 0.2
    }
    
    -- Biến
    local isBoosted = false
    local lastDebounce = 0
    
    -- Hàm optimizePart (THÊM: Tắt CanCollide, MipMapDither, TextureID rỗng)
    local function optimizePart(v)
        local ok, err = pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
                v.CanCollide = false  -- Tắt collision để giảm physics CPU
                if v:IsA("MeshPart") then
                    v.TextureID = ""  -- Xóa texture để low-res
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
                v.MipMapDither = Enum.MipMapDither.None  -- Tắt mipmaps (pixelated effect)
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("PointLight") or v:IsA("SpotLight") then
                v.Enabled = false
            end
        end)
        if not ok then
            print("ERROR in optimizePart: " .. tostring(err))
        end
    end
    
    -- Hàm applyBoost (THÊM: Compatibility Lighting, RenderStepped thấp, Preload giảm)
    local function applyBoost()
        print("applyBoost: Starting (Ultra Low Graphics)...")
        if isBoosted then 
            print("applyBoost: Already boosted")
            return 
        end
        isBoosted = true
        
        -- 1. Lighting (THÊM: Compatibility mode cho low-tech)
        print("Optimizing Lighting...")
        local ok1, err1 = pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            Lighting.Technology = Enum.Technology.Compatibility  -- Mode cũ, ít tính toán (tối giản hơn)
            Lighting.AmbientOcclusion = Enum.EnviromentalSpecularScale.Disabled  -- Tắt AO nếu có
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
        end)
        if ok1 then print("Lighting... OK (Compatibility Mode)") else print("ERROR Lighting: " .. tostring(err1)) end
        
        -- 2. Terrain
        if Terrain then
            print("Optimizing Terrain...")
            local ok2, err2 = pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end)
            if ok2 then print("Terrain... OK") else print("ERROR Terrain: " .. tostring(err2)) end
        end
        
        -- 3. Workspace (THÊM: Áp dụng optimize cho tất cả)
        print("Optimizing Workspace...")
        local ok3, err3 = pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end
        end)
        if ok3 then print("Workspace... OK (Pixelated Textures)") else print("ERROR Workspace: " .. tostring(err3)) end
        
        -- 4. Players
        print("Optimizing Players...")
        local ok4, err4 = pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        optimizePart(v)
                    end
                end
            end
        end)
        if ok4 then print("Players... OK") else print("ERROR Players: " .. tostring(err4)) end
        
        -- 5. Rendering Settings (THÊM: Giảm preload & concurrent requests)
        print("Optimizing Rendering (Ultra Low)...")
        local ok5, err5 = pcall(function()
            settings().Rendering.QualityLevel = CONFIG.TargetQuality
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings().Rendering.EnableFRM = false
            settings().Rendering.EagerBulkExecution = false
            ContentProvider.RequestQueueSize = 0  -- Giảm preload assets (low-res load)
            settings().Rendering.MeshContentProvider.MaximumConcurrentRequests = 1  -- Giảm mesh detail
        end)
        if ok5 then print("Rendering... OK (Max Low-Res)") else print("ERROR Rendering: " .. tostring(err5)) end
        
        -- 6. Camera & StarterGui
        print("Optimizing Camera...")
        local camera = workspace.CurrentCamera
        if camera then
            local ok6, err6 = pcall(function()
                camera.FieldOfView = 70
            end)
            if ok6 then print("Camera... OK") else print("ERROR Camera: " .. tostring(err6)) end
        end
        
        local ok7, err7 = pcall(function()
            StarterGui:SetCore("AutoJumpEnabled", false)
        end)
        if ok7 then print("AutoJump... OK") else print("ERROR AutoJump: " .. tostring(err7)) end
        
        -- 7. GC Loop
        print("Starting GC...")
        local ok8, err8 = pcall(function()
            spawn(function()
                while isBoosted do
                    task.wait(CONFIG.GCInterval)
                    collectgarbage("collect")
                end
            end)
        end)
        if ok8 then print("GC... OK") else print("ERROR GC: " .. tostring(err8)) end
        
        print("applyBoost: Completed! (Graphics giờ siêu thấp - pixelated)")
    end
    
    -- Connections
    print("Setting up Connections...")
    local ok_conn1, err_conn1 = pcall(function()
        workspace.DescendantAdded:Connect(function(v)
            if tick() - lastDebounce < CONFIG.DebounceTime then return end
            lastDebounce = tick()
            task.wait()
            optimizePart(v)
        end)
    end)
    if ok_conn1 then print("DescendantAdded... OK") else print("ERROR DescendantAdded: " .. tostring(err_conn1)) end
    
    local ok_conn2, err_conn2 = pcall(function()
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                task.wait(1)
                for _, v in pairs(character:GetDescendants()) do
                    optimizePart(v)
                end
            end)
        end)
    end)
    if ok_conn2 then print("PlayerAdded... OK") else print("ERROR PlayerAdded: " .. tostring(err_conn2)) end
    
    -- Áp dụng
    applyBoost()
    
    -- Toggle
    local ok_toggle, err_toggle = pcall(function()
        Players.LocalPlayer.Chatted:Connect(function(msg)
            if msg:lower() == "/togglefps" then
                isBoosted = not isBoosted
                if isBoosted then
                    applyBoost()
                    print("FPS Booster: BẬT (Ultra Low)")
                else
                    print("FPS Booster: TẮT")
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                    Lighting.Technology = Enum.Technology.Future  -- Reset lighting
                end
            end
        end)
    end)
    if ok_toggle then print("Toggle... OK") else print("ERROR Toggle: " .. tostring(err_toggle)) end
    
    print("=== FPS Booster v2.5 OK - Graphics siêu tối giản! ===")
end)

if not success then
    print("CRITICAL ERROR v2.5: " .. tostring(err))
end