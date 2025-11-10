-- Blox Fruits FPS Booster Script - Phiên bản v2.9 (Xóa Sương Mù, Giảm Đồ Họa, Xóa Effects, Không Hiệu Ứng Động)
-- Tối ưu hóa map/environment, skip tất cả player characters

local success, err = pcall(function()
    print("=== FPS Booster v2.9 đang khởi động (Xóa Sương Mù & Effects Động) ===")
    
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
    local LocalPlayer = Players.LocalPlayer
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
        TargetQuality = Enum.QualityLevel.Level01,  -- Thấp nhất cho map
        GCInterval = 30,
        DebounceTime = 0.2
    }
    
    -- Biến
    local isBoosted = false
    local lastDebounce = 0
    
    -- Hàm kiểm tra nếu là player character (để skip)
    local function isPlayerCharacter(descendant)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and descendant:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end
    
    -- Hàm optimizePart (THÊM: Xóa SurfaceAppearance, Anchored cho map, tắt dynamic attachments)
    local function optimizePart(v)
        if isPlayerCharacter(v) then
            return  -- Giữ nguyên skin tất cả players
        end
        
        local ok, err = pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic  -- Chỉ cho map parts
                v.Reflectance = 0
                v.CastShadow = false
                v.Anchored = true  -- Tắt di chuyển động cho map objects (không hiệu ứng động)
                if v:IsA("MeshPart") and not v.Parent:IsA("Model") then
                    v.TextureID = ""  -- Low-res cho map meshes
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
                v.MipMapDither = Enum.MipMapDither.None  -- Pixelated cho decals map
            elseif v:IsA("SurfaceAppearance") then  -- THÊM: Xóa surface effects
                v.Enabled = false
            elseif v:IsA("Attachment") and v.Parent:IsA("BasePart") then  -- Tắt dynamic attachments
                v.Parent:FindFirstChildOfClass("Attachment"):Destroy()  -- Xóa nếu là dynamic
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
    
    -- Hàm applyBoost (THÊM: Xóa sương mù hoàn toàn, giảm dynamic lighting, xóa effects)
    local function applyBoost()
        print("applyBoost: Starting (Xóa Sương Mù & Effects Động)...")
        if isBoosted then 
            print("applyBoost: Already boosted")
            return 
        end
        isBoosted = true
        
        -- 1. Lighting (THÊM: Xóa sương mù, luôn ban ngày, tắt dynamic)
        print("Optimizing Lighting...")
        local ok1, err1 = pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9  -- Xóa sương mù (xa vô tận)
            Lighting.FogStart = 0  -- THÊM: Bắt đầu fog từ 0, xóa hoàn toàn
            Lighting.Brightness = 0
            Lighting.ClockTime = 12  -- THÊM: Luôn ban ngày (không dynamic time)
            Lighting.GeographicLatitude = 0  -- THÊM: Tắt latitude cho no dynamic sun
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)  -- THÊM: Giảm ambient light
            Lighting.Technology = Enum.Technology.Compatibility  -- Mode cũ, ít tính toán
            Lighting.AmbientOcclusion = Enum.EnviromentalSpecularScale.Disabled  -- Tắt AO
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false  -- Xóa tất cả effects (blur, bloom, etc.)
                end
            end
        end)
        if ok1 then print("Lighting... OK (No Fog, No Dynamic Effects)") else print("ERROR Lighting: " .. tostring(err1)) end
        
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
        
        -- 3. Workspace
        print("Optimizing Workspace...")
        local ok3, err3 = pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end
        end)
        if ok3 then print("Workspace... OK (No Dynamic Motion)") else print("ERROR Workspace: " .. tostring(err3)) end
        
        -- 4. Skip Players (giữ skin all)
        print("Players: Skip optimize (Giữ skin tất cả)... OK")
        
        -- 5. Rendering Settings (THÊM: Giảm stream quality cho no dynamic load)
        print("Optimizing Rendering...")
        local ok5, err5 = pcall(function()
            settings().Rendering.QualityLevel = CONFIG.TargetQuality
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings().Rendering.EnableFRM = false
            settings().Rendering.EagerBulkExecution = false
            ContentProvider.RequestQueueSize = 0  -- Giảm preload map assets
            settings().Rendering.MeshContentProvider.MaximumConcurrentRequests = 1  -- Giảm mesh map
            settings().StreamingTargetFPS = 30  -- THÊM: Giới hạn FPS target thấp để no dynamic high-res
        end)
        if ok5 then print("Rendering... OK (No Dynamic Load)") else print("ERROR Rendering: " .. tostring(err5)) end
        
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
        
        print("applyBoost: Completed! (Không sương mù, không effects động)")
    end
    
    -- Connections
    print("Setting up Connections...")
    local ok_conn1, err_conn1 = pcall(function()
        workspace.DescendantAdded:Connect(function(v)
            if isPlayerCharacter(v) then return end  -- Skip tất cả players
            if tick() - lastDebounce < CONFIG.DebounceTime then return end
            lastDebounce = tick()
            task.wait()
            optimizePart(v)
        end)
    end)
    if ok_conn1 then print("DescendantAdded... OK (No Dynamic Effects)") else print("ERROR DescendantAdded: " .. tostring(err_conn1)) end
    
    local ok_conn2, err_conn2 = pcall(function()
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                task.wait(1)
                -- KHÔNG optimize character nào cả
                print("New player " .. player.Name .. " - Skin giữ nguyên")
            end)
        end)
    end)
    if ok_conn2 then print("PlayerAdded... OK (No Optimize)") else print("ERROR PlayerAdded: " .. tostring(err_conn2)) end
    
    -- Áp dụng
    applyBoost()
    
    -- Toggle
    local ok_toggle, err_toggle = pcall(function()
        LocalPlayer.Chatted:Connect(function(msg)
            if msg:lower() == "/togglefps" then
                isBoosted = not isBoosted
                if isBoosted then
                    applyBoost()
                    print("FPS Booster: BẬT (Không Effects Động)")
                else
                    print("FPS Booster: TẮT")
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                    Lighting.Technology = Enum.Technology.Future  -- Reset lighting
                    Lighting.FogEnd = 100000  -- Reset fog
                    Lighting.ClockTime = 14  -- Reset time
                end
            end
        end)
    end)
    if ok_toggle then print("Toggle... OK") else print("ERROR Toggle: " .. tostring(err_toggle)) end
    
    print("=== FPS Booster v2.9 OK - Không sương mù/effects động! ===")
end)

if not success then
    print("CRITICAL ERROR v2.9: " .. tostring(err))
end