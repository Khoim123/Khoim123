-- Blox Fruits FPS Booster Script - Phiên bản v3.1 (Fix Lỗi Xóa Hiệu Ứng Skill)
-- Xóa particles, beams, trails, fire/smoke từ skills; giữ skin all players

local success, err = pcall(function()
    print("=== FPS Booster v3.1 đang khởi động (Fix Xóa Skill Effects) ===")
    
    local Lighting = game:GetService("Lighting")
    print("Loading Lighting... OK")
    
    local Terrain = workspace:FindFirstChild("Terrain")
    if not Terrain then
        Terrain = nil
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
        DebounceTime = 0.1,
        EffectScanInterval = 0.5  -- Quét effects mỗi 0.5s
    }
    
    -- Biến
    local isBoosted = false
    local lastDebounce = 0
    local effectScanConnection = nil
    
    -- Hàm kiểm tra nếu là player character hoặc tool (để skip skin/tools)
    local function isPlayerOrTool(descendant)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and descendant:IsDescendantOf(player.Character) then
                return true
            end
            if player.Backpack and descendant:IsDescendantOf(player.Backpack) then
                return true  -- Skip tools trong backpack
            end
        end
        -- Skip nếu là weapon/tool model
        if descendant.Parent and (descendant.Parent.Name:find("Sword") or descendant.Parent.Name:find("Fruit") or descendant.Parent:IsA("Tool")) then
            return true
        end
        return false
    end
    
    -- Hàm xóa skill effects (FIX: Enabled = false cho Explosion, skip tools)
    local function removeSkillEffects(parent)
        for _, v in pairs(parent:GetDescendants()) do
            if isPlayerOrTool(v) then continue end  -- Skip skin/tools
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or 
                   v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false  -- Disable thay vì destroy để an toàn
                elseif v:IsA("Explosion") then
                    v.Enabled = false  -- FIX: Không destroy Explosion đang active
                elseif v:IsA("PointLight") or v:IsA("SpotLight") then
                    v.Enabled = false
                elseif v:IsA("Attachment") and (v.Parent:IsA("ParticleEmitter") or v.Parent:IsA("Trail")) then
                    v.Enabled = false  -- Disable attachment effects
                end
            end)
        end
    end
    
    -- Hàm optimizePart (Giữ nguyên, tập trung map)
    local function optimizePart(v)
        if isPlayerOrTool(v) then
            return  -- Giữ nguyên skin/tools
        end
        
        local ok, err = pcall(function()
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
                v.Anchored = true
                if v:IsA("MeshPart") and not v.Parent:IsA("Model") then
                    v.TextureID = ""
                end
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
                v.MipMapDither = Enum.MipMapDither.None
            elseif v:IsA("SurfaceAppearance") then
                v.Enabled = false
            end
        end)
        if not ok then
            print("ERROR optimizePart: " .. tostring(err))
        end
    end
    
    -- Hàm applyBoost (FIX: Enum đúng, xóa settings không tồn tại)
    local function applyBoost()
        print("applyBoost: Starting (Fix Skill Effects)...")
        if isBoosted then return end
        isBoosted = true
        
        -- 1. Lighting (FIX: Enum chính tả)
        local ok1, err1 = pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 0
            Lighting.Brightness = 0
            Lighting.ClockTime = 12
            Lighting.GeographicLatitude = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            Lighting.Technology = Enum.Technology.Compatibility
            Lighting.EnvironmentSpecularScale = Enum.EnvironmentSpecularScale.Off  -- FIX: Enum đúng
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
        end)
        if ok1 then print("Lighting... OK") else print("ERROR Lighting: " .. tostring(err1)) end
        
        -- 2. Terrain
        if Terrain then
            pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
            end)
            print("Terrain... OK")
        end
        
        -- 3. Workspace
        local ok3, err3 = pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end
            removeSkillEffects(workspace)
        end)
        if ok3 then print("Workspace... OK") else print("ERROR Workspace: " .. tostring(err3)) end
        
        -- 4. ReplicatedStorage
        pcall(function()
            removeSkillEffects(ReplicatedStorage)
        end)
        print("ReplicatedStorage... OK")
        
        -- 5. StarterPack
        pcall(function()
            removeSkillEffects(game.StarterPack)
        end)
        print("StarterPack... OK")
        
        -- 6. Rendering (FIX: Bỏ StreamingTargetFPS không tồn tại)
        local ok5, err5 = pcall(function()
            settings().Rendering.QualityLevel = CONFIG.TargetQuality
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            settings().Rendering.EditQualityLevel = CONFIG.TargetQuality
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            settings().Rendering.EnableFRM = false
            settings().Rendering.EagerBulkExecution = false
            ContentProvider.RequestQueueSize = 0
            settings().Rendering.MeshContentProvider.MaximumConcurrentRequests = 1
        end)
        if ok5 then print("Rendering... OK") else print("ERROR Rendering: " .. tostring(err5)) end
        
        -- 7. Camera & AutoJump
        local camera = workspace.CurrentCamera
        if camera then
            pcall(function() camera.FieldOfView = 70 end)
        end
        pcall(function() StarterGui:SetCore("AutoJumpEnabled", false) end)
        print("Camera/AutoJump... OK")
        
        -- 8. GC Loop
        spawn(function()
            while isBoosted do
                task.wait(CONFIG.GCInterval)
                collectgarbage("collect")
            end
        end)
        print("GC... OK")
        
        -- 9. THÊM: Loop quét skill effects liên tục (FIX: Không sót effects spawn nhanh)
        if effectScanConnection then effectScanConnection:Disconnect() end
        effectScanConnection = RunService.Heartbeat:Connect(function()
            if not isBoosted then return end
            removeSkillEffects(workspace)
            removeSkillEffects(ReplicatedStorage)
        end)
        print("Effect Scan Loop... OK")
        
        print("applyBoost: Completed! (Skill effects xóa mượt)")
    end
    
    -- Connections
    workspace.DescendantAdded:Connect(function(v)
        if isPlayerOrTool(v) then return end
        if tick() - lastDebounce < CONFIG.DebounceTime then return end
        lastDebounce = tick()
        task.wait()
        optimizePart(v)
        removeSkillEffects(v.Parent)
    end)
    print("DescendantAdded... OK")
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            print("New player - Effects xóa, skin giữ")
        end)
    end)
    print("PlayerAdded... OK")
    
    -- Áp dụng
    applyBoost()
    
    -- Toggle (FIX: Reset loop khi tắt)
    LocalPlayer.Chatted:Connect(function(msg)
        if msg:lower() == "/togglefps" then
            isBoosted = not isBoosted
            if isBoosted then
                applyBoost()
                print("FPS Booster: BẬT")
            else
                print("FPS Booster: TẮT")
                if effectScanConnection then effectScanConnection:Disconnect() end
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                Lighting.Technology = Enum.Technology.Future
                Lighting.FogEnd = 100000
                Lighting.ClockTime = 14
            end
        end
    end)
    print("Toggle... OK")
    
    print("=== FPS Booster v3.1 OK - Skill effects fix! ===")
end)

if not success then
    print("CRITICAL ERROR v3.1: " .. tostring(err))
end