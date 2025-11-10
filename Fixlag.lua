-- Blox Fruits FPS Booster Script - Phiên bản v3.0 (Xóa Hiệu Ứng Skill)
-- Xóa particles, beams, trails, fire/smoke từ skills; giữ skin all players

local success, err = pcall(function()
    print("=== FPS Booster v3.0 đang khởi động (Xóa Hiệu Ứng Skill) ===")
    
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
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    print("Loading ReplicatedStorage... OK")
    
    -- Config
    local CONFIG = {
        TargetQuality = Enum.QualityLevel.Level01,
        GCInterval = 30,
        DebounceTime = 0.1  -- Giảm debounce để xóa effects nhanh hơn
    }
    
    -- Biến
    local isBoosted = false
    local lastDebounce = 0
    
    -- Hàm kiểm tra nếu là player character (để skip skin)
    local function isPlayerCharacter(descendant)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and descendant:IsDescendantOf(player.Character) then
                return true
            end
        end
        return false
    end
    
    -- Hàm xóa skill effects cụ thể (THÊM: Target Explosion, Sparkles, và destroy nhanh)
    local function removeSkillEffects(parent)
        for _, v in pairs(parent:GetDescendants()) do
            if isPlayerCharacter(v) then continue end  -- Skip skin
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or 
                   v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Explosion") then
                    v:Destroy()  -- Xóa hoàn toàn thay vì disable (nhanh hơn cho skills)
                elseif v:IsA("PointLight") or v:IsA("SpotLight") then
                    v.Enabled = false
                elseif v:IsA("Attachment") and (v.Parent:IsA("ParticleEmitter") or v.Parent:IsA("Trail")) then
                    v:Destroy()  -- Xóa attachments của effects
                end
            end)
        end
    end
    
    -- Hàm optimizePart (Cập tiến: Tập trung xóa effects, giữ map low-res)
    local function optimizePart(v)
        if isPlayerCharacter(v) then
            return  -- Giữ nguyên skin tất cả players
        end
        
        local ok, err = pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic  -- Low-res map
                v.Reflectance = 0
                v.CastShadow = false
                v.Anchored = true  -- Tắt di chuyển động map
                if v:IsA("MeshPart") and not v.Parent:IsA("Model") then
                    v.TextureID = ""  -- Low-res meshes
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
                v.MipMapDither = Enum.MipMapDither.None
            elseif v:IsA("SurfaceAppearance") then
                v.Enabled = false
            end
        end)
        if not ok then
            print("ERROR in optimizePart: " .. tostring(err))
        end
    end
    
    -- Hàm applyBoost (THÊM: Quét ReplicatedStorage cho skill assets, xóa effects ngay)
    local function applyBoost()
        print("applyBoost: Starting (Xóa Hiệu Ứng Skill)...")
        if isBoosted then 
            print("applyBoost: Already boosted")
            return 
        end
        isBoosted = true
        
        -- 1. Lighting (giữ xóa sương mù/dynamic)
        print("Optimizing Lighting...")
        local ok1, err1 = pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 0
            Lighting.Brightness = 0
            Lighting.ClockTime = 12
            Lighting.GeographicLatitude = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            Lighting.Technology = Enum.Technology.Compatibility
            Lighting.AmbientOcclusion = Enum.EnviromentalSpecularScale.Disabled
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect:Destroy()  -- Xóa effects thay vì disable
                end
            end
        end)
        if ok1 then print("Lighting... OK") else print("ERROR Lighting: " .. tostring(err1)) end
        
        -- 2. Terrain
        if Terrain then
            local ok2, err2 = pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end)
            if ok2 then print("Terrain... OK") else print("ERROR Terrain: " .. tostring(err2)) end
        end
        
        -- 3. Workspace (Optimize map + xóa skill effects)
        print("Optimizing Workspace...")
        local ok3, err3 = pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end
            removeSkillEffects(workspace)  -- Xóa effects skills trong workspace
        end)
        if ok3 then print("Workspace... OK (Xóa Skill Effects)") else print("ERROR Workspace: " .. tostring(err3)) end
        
        -- 4. ReplicatedStorage (THÊM: Xóa skill assets/effects từ RS)
        print("Cleaning ReplicatedStorage...")
        local ok_rs, err_rs = pcall(function()
            removeSkillEffects(ReplicatedStorage)
        end)
        if ok_rs then print("ReplicatedStorage... OK") else print("ERROR RS: " .. tostring(err_rs)) end
        
        -- 5. StarterPack (THÊM: Xóa effects từ tools/skills)
        print("Cleaning StarterPack...")
        local ok_sp, err_sp = pcall(function()
            removeSkillEffects(game.StarterPack)
        end)
        if ok_sp then print("StarterPack... OK") else print("ERROR StarterPack: " .. tostring(err_sp)) end
        
        -- 6. Rendering Settings
        print("Optimizing Rendering...")
        local ok5, err5 = pcall(function()
            settings().Rendering.QualityLevel = CONFIG.TargetQuality
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings().Rendering.EnableFRM = false
            settings().Rendering.EagerBulkExecution = false
            ContentProvider.RequestQueueSize = 0
            settings().Rendering.MeshContentProvider.MaximumConcurrentRequests = 1
            settings().StreamingTargetFPS = 30  -- Giới hạn FPS để no lag effects
        end)
        if ok5 then print("Rendering... OK") else print("ERROR Rendering: " .. tostring(err5)) end
        
        -- 7. Camera & StarterGui
        local camera = workspace.CurrentCamera
        if camera then
            pcall(function()
                camera.FieldOfView = 70
            end)
            print("Camera... OK")
        end
        pcall(function()
            StarterGui:SetCore("AutoJumpEnabled", false)
        end)
        print("AutoJump... OK")
        
        -- 8. GC Loop
        spawn(function()
            while isBoosted do
                task.wait(CONFIG.GCInterval)
                collectgarbage("collect")
            end
        end)
        print("GC... OK")
        
        print("applyBoost: Completed! (Hiệu ứng skill đã xóa)")
    end
    
    -- Connections (THÊM: Quét effects mới từ skills liên tục)
    print("Setting up Connections...")
    workspace.DescendantAdded:Connect(function(v)
        if isPlayerCharacter(v) then return end
        if tick() - lastDebounce < CONFIG.DebounceTime then return end
        lastDebounce = tick()
        task.wait()
        optimizePart(v)
        removeSkillEffects(v.Parent)  -- Xóa effects mới spawn từ skill
    end)
    print("DescendantAdded... OK (Auto Xóa Skill Effects)")
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            print("New player " .. player.Name .. " - Skin giữ nguyên, effects xóa")
        end)
    end)
    print("PlayerAdded... OK")
    
    -- Áp dụng
    applyBoost()
    
    -- Toggle
    LocalPlayer.Chatted:Connect(function(msg)
        if msg:lower() == "/togglefps" then
            isBoosted = not isBoosted
            if isBoosted then
                applyBoost()
                print("FPS Booster: BẬT (Xóa Skill Effects)")
            else
                print("FPS Booster: TẮT")
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                Lighting.Technology = Enum.Technology.Future
                Lighting.FogEnd = 100000
                Lighting.ClockTime = 14
            end
        end
    end)
    print("Toggle... OK")
    
    print("=== FPS Booster v3.0 OK - Hiệu ứng skill đã xóa! ===")
end)

if not success then
    print("CRITICAL ERROR v3.0: " .. tostring(err))
end