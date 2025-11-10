-- Blox Fruits FPS Booster Script - Phiên bản v2.4 (Fix Âm Thanh - Không Tắt Sound)
-- Tối ưu hóa đồ họa để tăng FPS (với DEBUG prints để check lỗi)
-- Đã xóa phần tắt âm thanh để fix lỗi mute

local success, err = pcall(function()
    -- Load Services với debug
    print("=== FPS Booster v2.4 đang khởi động (Fix Âm Thanh) ===")
    
    local Lighting = game:GetService("Lighting")
    print("Loading Lighting... OK")
    
    local Terrain = workspace:FindFirstChild("Terrain")
    if not Terrain then
        print("WARNING: No Terrain in workspace, skipping terrain optim")
        Terrain = nil
    else
        print("Loading Terrain... OK")
    end
    
    local Players = game:GetService("Players")
    print("Loading Players... OK")
    
    local RunService = game:GetService("RunService")
    print("Loading RunService... OK")
    
    local UserSettings = UserSettings()
    print("Loading UserSettings... OK")
    
    local GameSettings = UserSettings:GetService("UserGameSettings")
    print("Loading GameSettings... OK")
    
    local StarterGui = game:GetService("StarterGui")
    print("Loading StarterGui... OK")
    
    -- Config
    local CONFIG = {
        TargetQuality = Enum.QualityLevel.Level01,
        GCInterval = 30,
        DebounceTime = 0.2
    }
    
    -- Biến
    local isBoosted = false
    local lastDebounce = 0
    
    -- Hàm optimizePart (XÓA PHẦN SOUND để fix âm thanh)
    local function optimizePart(v)
        local ok, err = pcall(function()
            if v:IsA("BasePart") then
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
            -- ĐÃ XÓA: elseif v:IsA("Sound") then v.Volume = 0 end  (Fix âm thanh)
            end
        end)
        if not ok then
            print("ERROR in optimizePart: " .. tostring(err))
        end
    end
    
    -- Hàm applyBoost (giữ nguyên)
    local function applyBoost()
        print("applyBoost: Starting...")
        if isBoosted then 
            print("applyBoost: Already boosted, skipping")
            return 
        end
        isBoosted = true
        
        -- 1. Lighting
        print("Optimizing Lighting...")
        local ok1, err1 = pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
        end)
        if ok1 then print("Lighting... OK") else print("ERROR Lighting: " .. tostring(err1)) end
        
        -- 2. Terrain (nếu có)
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
        if ok3 then print("Workspace... OK") else print("ERROR Workspace: " .. tostring(err3)) end
        
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
        
        -- 5. Rendering Settings
        print("Optimizing Rendering...")
        local ok5, err5 = pcall(function()
            settings().Rendering.QualityLevel = CONFIG.TargetQuality
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings().Rendering.EnableFRM = false
            settings().Rendering.EagerBulkExecution = false
        end)
        if ok5 then print("Rendering... OK") else print("ERROR Rendering: " .. tostring(err5)) end
        
        -- 6. Camera & StarterGui
        print("Optimizing Camera...")
        local camera = workspace.CurrentCamera
        if camera then
            local ok6, err6 = pcall(function()
                camera.FieldOfView = 70
            end)
            if ok6 then print("Camera FOV... OK") else print("ERROR Camera: " .. tostring(err6)) end
        else
            print("WARNING: No CurrentCamera, skipping")
        end
        
        local ok7, err7 = pcall(function()
            StarterGui:SetCore("AutoJumpEnabled", false)
        end)
        if ok7 then print("AutoJump... OK") else print("ERROR AutoJump: " .. tostring(err7)) end
        
        -- 7. GC Loop
        print("Starting GC Loop...")
        local ok8, err8 = pcall(function()
            spawn(function()
                while isBoosted do
                    task.wait(CONFIG.GCInterval)
                    collectgarbage("collect")
                end
            end)
        end)
        if ok8 then print("GC Loop... OK") else print("ERROR GC: " .. tostring(err8)) end
        
        print("applyBoost: Completed successfully! (Âm thanh đã được giữ nguyên)")
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
                    print("FPS Booster: BẬT")
                else
                    print("FPS Booster: TẮT")
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                end
            end
        end)
    end)
    if ok_toggle then print("Toggle Chat... OK") else print("ERROR Toggle: " .. tostring(err_toggle)) end
    
    print("=== FPS Booster v2.4 OK - All setups done! (Âm thanh OK) ===")
end)

-- Global error catcher
if not success then
    print("CRITICAL ERROR in FPS Booster v2.4: " .. tostring(err))
    print("Stack trace: " .. debug.traceback())
end