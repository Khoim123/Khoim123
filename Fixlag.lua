-- Blox Fruits FPS Booster v4.0 - Optimized Version
-- Giữ 100% skin player, tối ưu hiệu suất và memory

local success, err = pcall(function()
    print("=== FPS Booster v4.0 Starting (Optimized) ===")
    
    -- Services (Cache một lần)
    local services = {
        Lighting = game:GetService("Lighting"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        StarterGui = game:GetService("StarterGui"),
        ContentProvider = game:GetService("ContentProvider"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        CollectionService = game:GetService("CollectionService")
    }
    
    local Terrain = workspace:FindFirstChild("Terrain")
    local LocalPlayer = services.Players.LocalPlayer
    local UserSettings = UserSettings()
    local GameSettings = UserSettings:GetService("UserGameSettings")
    
    -- Config tối ưu
    local CONFIG = {
        TargetQuality = Enum.QualityLevel.Level01,
        GCInterval = 90, -- Tăng từ 60 -> 90 để giảm lag spike
        DebounceTime = 0.3, -- Giảm từ 0.5 -> 0.3 cho responsive hơn
        EffectScanInterval = 3, -- Tăng từ 2 -> 3 để giảm CPU usage
        BatchSize = 50 -- Xử lý theo batch để tránh freeze
    }
    
    -- State management
    local state = {
        boosted = false,
        lastDebounce = 0,
        effectScanConnection = nil,
        gcConnection = nil,
        playerCache = {},
        optimizedParts = {}
    }
    
    local TAG = "OptimizedFPS_v4"
    
    -- Cache player characters để tăng tốc độ check
    local function updatePlayerCache()
        table.clear(state.playerCache)
        for _, player in ipairs(services.Players:GetPlayers()) do
            if player.Character then
                state.playerCache[player.Character] = true
            end
        end
    end
    
    -- Kiểm tra player/tool (Tối ưu với cache)
    local function isPlayerRelated(obj)
        if not obj or not obj.Parent then return false end
        
        -- Check cache trước (nhanh nhất)
        local ancestor = obj
        for i = 1, 5 do -- Giới hạn 5 level để tránh lag
            if state.playerCache[ancestor] then return true end
            ancestor = ancestor.Parent
            if not ancestor then break end
        end
        
        -- Kiểm tra tool/weapon patterns
        local name = obj.Name
        if name:match("Sword") or name:match("Fruit") or name:match("Gun") or 
           name:match("Katana") or name:match("Staff") then
            return true
        end
        
        -- Kiểm tra nếu parent là Tool
        if obj.Parent:IsA("Tool") or obj.Parent:IsA("Accessory") then
            return true
        end
        
        return false
    end
    
    -- Xóa effects (Tối ưu với early return)
    local function removeEffects(parent)
        if not parent then return end
        
        pcall(function()
            local children = parent:GetChildren()
            for i = 1, #children do
                local v = children[i]
                
                -- Skip nếu đã optimize hoặc là player
                if services.CollectionService:HasTag(v, TAG) or isPlayerRelated(v) then
                    continue
                end
                
                local vType = v.ClassName
                
                -- Sử dụng lookup table thay vì if-else chain
                if vType == "ParticleEmitter" or vType == "Trail" or vType == "Beam" or 
                   vType == "Fire" or vType == "Smoke" or vType == "Sparkles" then
                    v.Enabled = false
                    services.CollectionService:AddTag(v, TAG)
                elseif vType == "PointLight" or vType == "SpotLight" then
                    v.Enabled = false
                    v.Brightness = 0
                    services.CollectionService:AddTag(v, TAG)
                elseif vType == "Explosion" then
                    v.BlastPressure = 0
                    v.BlastRadius = 0
                    services.CollectionService:AddTag(v, TAG)
                end
            end
        end)
    end
    
    -- Optimize part (Batch processing)
    local function optimizePart(v)
        if not v or not v.Parent then return end
        if services.CollectionService:HasTag(v, TAG) or isPlayerRelated(v) then
            return
        end
        
        pcall(function()
            -- Skip nếu thuộc Model có Humanoid
            local parent = v.Parent
            if parent and parent:FindFirstChildOfClass("Humanoid") then
                return
            end
            
            local vType = v.ClassName
            
            if vType == "Part" or vType == "MeshPart" or vType == "UnionOperation" then
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
                
                -- Chỉ anchor nếu chưa được anchor
                if not v.Anchored and v.CanCollide then
                    v.Anchored = true
                end
                
                if vType == "MeshPart" and v.TextureID ~= "" then
                    v.TextureID = ""
                end
                
                state.optimizedParts[v] = true
                
            elseif vType == "Decal" or vType == "Texture" then
                v.Transparency = 1
                
            elseif vType == "SurfaceAppearance" then
                v.Enabled = false
            end
            
            services.CollectionService:AddTag(v, TAG)
        end)
    end
    
    -- Optimize batch để tránh freeze
    local function optimizeBatch(objects)
        local count = #objects
        local batchSize = CONFIG.BatchSize
        
        for i = 1, count, batchSize do
            for j = i, math.min(i + batchSize - 1, count) do
                optimizePart(objects[j])
            end
            
            -- Yield sau mỗi batch
            if i + batchSize < count then
                task.wait()
            end
        end
    end
    
    -- Apply boost chính
    local function applyBoost()
        if state.boosted then return end
        state.boosted = true
        
        print("Applying boost...")
        
        -- Update player cache
        updatePlayerCache()
        
        -- 1. Lighting (Single pcall)
        pcall(function()
            local lighting = services.Lighting
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            lighting.FogStart = 0
            lighting.Brightness = 0
            lighting.ClockTime = 12
            lighting.GeographicLatitude = 0
            lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
            lighting.Technology = Enum.Technology.Compatibility
            lighting.EnvironmentSpecularScale = 0
            
            for _, effect in ipairs(lighting:GetChildren()) do
                if effect:IsA("PostEffect") then
                    effect.Enabled = false
                end
            end
        end)
        
        -- 2. Terrain
        if Terrain then
            pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
                Terrain.Decoration = false
            end)
        end
        
        -- 3. Workspace (Batch processing)
        task.spawn(function()
            pcall(function()
                local objects = {}
                
                for _, child in ipairs(workspace:GetDescendants()) do
                    if not isPlayerRelated(child) and not child:FindFirstChildOfClass("Humanoid") then
                        table.insert(objects, child)
                        removeEffects(child)
                    end
                end
                
                print("Optimizing " .. #objects .. " objects...")
                optimizeBatch(objects)
                print("Workspace optimized!")
            end)
        end)
        
        -- 4. ReplicatedStorage
        task.spawn(function()
            pcall(function()
                removeEffects(services.ReplicatedStorage)
            end)
        end)
        
        -- 5. Rendering settings
        pcall(function()
            local rendering = settings().Rendering
            rendering.QualityLevel = CONFIG.TargetQuality
            rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
            rendering.EditQualityLevel = CONFIG.TargetQuality
            rendering.EnableFRM = false
            rendering.EagerBulkExecution = false
            
            GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            services.ContentProvider.RequestQueueSize = 0
        end)
        
        -- 6. Camera
        pcall(function()
            workspace.CurrentCamera.FieldOfView = 70
            services.StarterGui:SetCore("AutoJumpEnabled", false)
        end)
        
        -- 7. GC Loop (Optimized)
        if state.gcConnection then state.gcConnection:Disconnect() end
        state.gcConnection = task.spawn(function()
            while state.boosted do
                task.wait(CONFIG.GCInterval)
                collectgarbage("collect")
                
                -- Clean up destroyed parts cache
                for part in pairs(state.optimizedParts) do
                    if not part.Parent then
                        state.optimizedParts[part] = nil
                    end
                end
            end
        end)
        
        -- 8. Effect scan loop
        if state.effectScanConnection then 
            state.effectScanConnection:Disconnect() 
        end
        
        state.effectScanConnection = services.RunService.Heartbeat:Connect(function()
            if not state.boosted then return end
            
            -- Throttle scanning
            if tick() - state.lastDebounce < CONFIG.EffectScanInterval then
                return
            end
            state.lastDebounce = tick()
            
            removeEffects(workspace)
            removeEffects(services.ReplicatedStorage)
        end)
        
        print("=== FPS Boost Applied Successfully! ===")
    end
    
    -- Disable boost
    local function disableBoost()
        state.boosted = false
        
        if state.effectScanConnection then
            state.effectScanConnection:Disconnect()
            state.effectScanConnection = nil
        end
        
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            services.Lighting.Technology = Enum.Technology.Future
            services.Lighting.FogEnd = 100000
            services.Lighting.ClockTime = 14
        end)
        
        print("=== FPS Boost Disabled ===")
    end
    
    -- DescendantAdded với debounce
    workspace.DescendantAdded:Connect(function(v)
        if not state.boosted then return end
        if isPlayerRelated(v) or services.CollectionService:HasTag(v, TAG) then
            return
        end
        
        -- Debounce check
        local now = tick()
        if now - state.lastDebounce < CONFIG.DebounceTime then
            return
        end
        state.lastDebounce = now
        
        task.delay(0.1, function()
            optimizePart(v)
            removeEffects(v.Parent)
        end)
    end)
    
    -- Player added handler
    services.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            updatePlayerCache()
            print("Player joined - Cache updated")
        end)
    end)
    
    -- Player removing handler
    services.Players.PlayerRemoving:Connect(function(player)
        task.delay(0.5, updatePlayerCache)
    end)
    
    -- Toggle command
    LocalPlayer.Chatted:Connect(function(msg)
        local lower = msg:lower()
        if lower == "/togglefps" or lower == "/fps" then
            if state.boosted then
                disableBoost()
            else
                applyBoost()
            end
        elseif lower == "/fpsstats" then
            print("=== FPS Booster Stats ===")
            print("Status: " .. (state.boosted and "ENABLED" or "DISABLED"))
            print("Optimized Parts: " .. tostring(table.getn(state.optimizedParts)))
            print("Cached Players: " .. tostring(table.getn(state.playerCache)))
        end
    end)
    
    -- Auto-apply on load
    task.wait(2)
    applyBoost()
    
    print("=== FPS Booster v4.0 Ready! ===")
    print("Commands: /togglefps, /fps, /fpsstats")
end)

if not success then
    warn("FPS Booster Error: " .. tostring(err))
end