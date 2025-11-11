-- Blox Fruits FPS Booster v4.4 - The Ghost Protocol
-- An intelligent, adaptive, and undetectable performance enhancement system.

local success, err = pcall(function()
    -- OBFUSCATED LOGGING
    print("System core loading...")

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
    local UserSettings = UserSettings()
    local GameSettings = UserSettings:GetService("UserGameSettings")

    -- ADVANCED: Fingerprint Randomization - Mỗi session là duy nhất
    local SESSION_FINGERPRINT = {
        gcBase = math.random(75, 95),
        scanBase = math.random(2.0, 3.5),
        skipChance = math.random(0.05, 0.20),
        fastScanChance = math.random(0.08, 0.15) -- Xác suất fast scan
    }

    -- ADVANCED: Deeper Adaptive Logic - Đa giai đoạn
    local ADAPTIVE_STAGES = {
        {time = 0,    gc = {SESSION_FINGERPRINT.gcBase, SESSION_FINGERPRINT.gcBase + 10}, skip = 0.05}, -- Rất cẩn thận
        {time = 600,  gc = {SESSION_FINGERPRINT.gcBase - 5, SESSION_FINGERPRINT.gcBase + 15}, skip = 0.08}, -- Cẩn thận
        {time = 1800, gc = {SESSION_FINGERPRINT.gcBase - 10, SESSION_FINGERPRINT.gcBase + 20}, skip = 0.12}, -- Bình thường
        {time = 3600, gc = {SESSION_FINGERPRINT.gcBase - 20, SESSION_FINGERPRINT.gcBase + 30}, skip = 0.15}  -- Thoải mái
    }

    -- ANTIBAN: Cấu hình chống phát hiện nâng cao
    local ANTIBAN_CONFIG = {
        Enabled = true,
        DebugMode = false,
        RandomizeIntervals = true,
        RandomizeProperties = true,
        SensitiveKeywords = {"Admin", "System", "AntiCheat", "V4", "V5", "Mod", "Secure", "Detector"},
        InitialStaggerDelay = {0.1, 0.5},
        FOVRange = {68, 72},
        -- Các giá trị này sẽ được khởi tạo bởi Fingerprint
        GCInterval = {SESSION_FINGERPRINT.gcBase, SESSION_FINGERPRINT.gcBase + 20},
        EffectScanInterval = {SESSION_FINGERPRINT.scanBase, SESSION_FINGERPRINT.scanBase + 1.5},
        ScanSkipChance = SESSION_FINGERPRINT.skipChance,
        FastScanInterval = {1.0, 1.5},
        FastScanChance = SESSION_FINGERPRINT.fastScanChance
    }

    -- ADVANCED: Machine Learning-like Adaptation
    local LEARNING_CONFIG = {
        samples = {},
        adaptiveQuality = true,
        sampleInterval = 30, -- Giây giữa mỗi lần lấy mẫu FPS
        maxSamples = 10
    }

    -- ADVANCED: Entropy Injection
    local ENTROPY_CONFIG = {
        enabled = true,
        interval = {1800, 3600}, -- 30-60 phút
        actions = {
            function() workspace.CurrentCamera.FieldOfView = math.random(65, 75) end,
            function() task.wait(math.random(1, 3)) end,
            function() -- Giả AFK
                task.wait(math.random(5, 15))
            end
        }
    }

    -- ADVANCED: Decoy Operations
    local DECOY_CONFIG = {
        enabled = true,
        interval = 60 -- Giây
    }

    -- Config tối ưu
    local CONFIG = {
        TargetQuality = Enum.QualityLevel.Level01,
        DebounceTime = 0.3,
        BatchSize = 50
    }

    -- State management
    local state = {
        boosted = false,
        lastDebounce = 0,
        effectScanConnection = nil,
        gcConnection = nil,
        playerCache = {},
        optimizedParts = {},
        startTime = tick()
    }

    local function countDictionary(t)
        local count = 0
        for _ in pairs(t) do
            count = count + 1
        end
        return count
    end

    local LocalPlayer
    local function waitForLocalPlayer()
        LocalPlayer = services.Players.LocalPlayer
        while not LocalPlayer do
            services.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
            LocalPlayer = services.Players.LocalPlayer
        end
    end
    waitForLocalPlayer()

    local TAG = "OptimizedFPS_v4_" .. tick()

    local function getRandomInterval(range)
        if not ANTIBAN_CONFIG.Enabled or not ANTIBAN_CONFIG.RandomizeIntervals then
            return (range[1] + range[2]) / 2
        end
        return math.random(range[1] * 100, range[2] * 100) / 100
    end

    -- ADVANCED: Hàm lấy giai đoạn thích ứng hiện tại
    local function getAdaptiveStage(runTime)
        local currentStage = ADAPTIVE_STAGES[1]
        for _, stage in ipairs(ADAPTIVE_STAGES) do
            if runTime >= stage.time then
                currentStage = stage
            end
        end
        return currentStage
    end

    local function updatePlayerCache()
        for character in pairs(state.playerCache) do
            if not character or not character.Parent then
                state.playerCache[character] = nil
            end
        end

        for _, player in ipairs(services.Players:GetPlayers()) do
            if player.Character then
                state.playerCache[player.Character] = true
            end
        end
    end

    local function shouldIgnoreObject(obj)
        if not obj or not obj.Parent then return true end

        local ancestor = obj
        for i = 1, 5 do
            if state.playerCache[ancestor] then return true end
            ancestor = ancestor.Parent
            if not ancestor then break end
        end

        if ANTIBAN_CONFIG.Enabled then
            local checkName = obj.Name:lower()
            for _, keyword in ipairs(ANTIBAN_CONFIG.SensitiveKeywords) do
                if checkName:find(keyword:lower()) then
                    return true
                end
            end
        end

        local name = obj.Name
        if name:match("Sword") or name:match("Fruit") or name:match("Gun") or 
           name:match("Katana") or name:match("Staff") then
            return true
        end

        if obj.Parent:IsA("Tool") or obj.Parent:IsA("Accessory") then
            return true
        end

        return false
    end

    local function removeEffects(parent)
        if not parent then return end

        pcall(function()
            local children = parent:GetChildren()
            for i = 1, #children do
                local v = children[i]

                if services.CollectionService:HasTag(v, TAG) or shouldIgnoreObject(v) then
                    continue
                end

                local vType = v.ClassName
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

    local function optimizePart(v)
        if not v or not v.Parent then return end
        if services.CollectionService:HasTag(v, TAG) or shouldIgnoreObject(v) then
            return
        end

        pcall(function()
            local parent = v.Parent
            if parent and parent:FindFirstChildOfClass("Humanoid") then
                return
            end

            local vType = v.ClassName

            if vType == "Part" or vType == "MeshPart" or vType == "UnionOperation" then
                if ANTIBAN_CONFIG.Enabled and ANTIBAN_CONFIG.RandomizeProperties then
                    v.Material = math.random(1, 2) == 1 and Enum.Material.Plastic or Enum.Material.SmoothPlastic
                else
                    v.Material = Enum.Material.Plastic
                end
                
                v.Reflectance = 0
                v.CastShadow = false

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

    local function optimizeBatch(objects)
        local count = #objects
        local batchSize = CONFIG.BatchSize

        for i = 1, count, batchSize do
            for j = i, math.min(i + batchSize - 1, count) do
                optimizePart(objects[j])
            end

            if i + batchSize < count then
                task.wait()
            end
        end
    end

    local function applyBoost()
        if state.boosted then return end
        state.boosted = true

        if ANTIBAN_CONFIG.DebugMode then print("Applying performance profile...") end

        updatePlayerCache()

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
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
        end)

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
            if Terrain then
                pcall(function()
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 0
                    Terrain.Decoration = false
                end)
            end
        end)

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
            pcall(function()
                local objects = {}
                for _, child in ipairs(workspace:GetDescendants()) do
                    if not shouldIgnoreObject(child) and not child:FindFirstChildOfClass("Humanoid") then
                        table.insert(objects, child)
                        removeEffects(child)
                    end
                end
                if ANTIBAN_CONFIG.DebugMode then print("Optimizing " .. #objects .. " objects...") end
                optimizeBatch(objects)
                if ANTIBAN_CONFIG.DebugMode then print("Workspace profile applied.") end
            end)
        end)

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
            pcall(function()
                removeEffects(services.ReplicatedStorage)
            end)
        end)

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
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
        end)

        task.spawn(function()
            task.wait(getRandomInterval(ANTIBAN_CONFIG.InitialStaggerDelay))
            pcall(function()
                if ANTIBAN_CONFIG.Enabled and ANTIBAN_CONFIG.RandomizeProperties then
                    workspace.CurrentCamera.FieldOfView = math.random(ANTIBAN_CONFIG.FOVRange[1], ANTIBAN_CONFIG.FOVRange[2])
                else
                    workspace.CurrentCamera.FieldOfView = 70
                end
                services.StarterGui:SetCore("AutoJumpEnabled", false)
            end)
        end)

        -- ADVANCED: GC Loop với Adaptive Logic
        if state.gcConnection then state.gcConnection:Disconnect() end
        state.gcConnection = task.spawn(function()
            while state.boosted do
                local runTime = tick() - state.startTime
                local stage = getAdaptiveStage(runTime)
                task.wait(getRandomInterval(stage.gc))
                
                collectgarbage("collect")

                for part in pairs(state.optimizedParts) do
                    if not part.Parent then
                        state.optimizedParts[part] = nil
                    end
                end

                updatePlayerCache()
            end
        end)

        -- ADVANCED: Effect scan loop với Unpredictable Pattern Mixing
        if state.effectScanConnection then 
            state.effectScanConnection:Disconnect() 
        end

        state.effectScanConnection = services.RunService.Heartbeat:Connect(function()
            if not state.boosted then return end

            local runTime = tick() - state.startTime
            local stage = getAdaptiveStage(runTime)
            if ANTIBAN_CONFIG.Enabled and math.random() < stage.skip then
                return
            end

            local currentScanInterval = ANTIBAN_CONFIG.EffectScanInterval
            -- ADVANCED: Random Burst thay vì fixed cycle
            if ANTIBAN_CONFIG.Enabled and math.random() < ANTIBAN_CONFIG.FastScanChance then
                currentScanInterval = ANTIBAN_CONFIG.FastScanInterval
            end

            if tick() - state.lastDebounce < getRandomInterval(currentScanInterval) then
                return
            end
            state.lastDebounce = tick()

            removeEffects(workspace)
            removeEffects(services.ReplicatedStorage)
        end)

        -- ADVANCED: Machine Learning-like Adaptation Loop
        if LEARNING_CONFIG.adaptiveQuality then
            task.spawn(function()
                while state.boosted do
                    task.wait(LEARNING_CONFIG.sampleInterval)
                    local currentFPS = workspace:GetRealPhysicsFPS()
                    table.insert(LEARNING_CONFIG.samples, currentFPS)
                    
                    if #LEARNING_CONFIG.samples > LEARNING_CONFIG.maxSamples then
                        local avgFPS = 0
                        for _, fps in ipairs(LEARNING_CONFIG.samples) do
                            avgFPS = avgFPS + fps
                        end
                        avgFPS = avgFPS / #LEARNING_CONFIG.samples
                        
                        local oldQuality = CONFIG.TargetQuality
                        if avgFPS < 30 then
                            CONFIG.TargetQuality = Enum.QualityLevel.Level01
                        elseif avgFPS > 60 then
                            CONFIG.TargetQuality = Enum.QualityLevel.Level03
                        else
                            CONFIG.TargetQuality = Enum.QualityLevel.Level02
                        end
                        
                        if oldQuality ~= CONFIG.TargetQuality then
                            pcall(function() settings().Rendering.QualityLevel = CONFIG.TargetQuality end)
                            if ANTIBAN_CONFIG.DebugMode then print("Performance profile adjusted based on performance data.") end
                        end
                        
                        LEARNING_CONFIG.samples = {}
                    end
                end
            end)
        end

        -- ADVANCED: Entropy Injection Loop
        if ENTROPY_CONFIG.enabled then
            task.spawn(function()
                while state.boosted do
                    task.wait(getRandomInterval(ENTROPY_CONFIG.interval))
                    local action = ENTROPY_CONFIG.actions[math.random(1, #ENTROPY_CONFIG.actions)]
                    pcall(action)
                end
            end)
        end

        -- ADVANCED: Decoy Operations Loop
        if DECOY_CONFIG.enabled then
            task.spawn(function()
                while state.boosted do
                    task.wait(DECOY_CONFIG.interval)
                    pcall(function()
                        local _ = workspace:GetDescendants()
                        local __ = services.Lighting:GetChildren()
                    end)
                end
            end)
        end

        -- ADVANCED: Fake Normal Activity Loop
        task.spawn(function()
            while state.boosted do
                task.wait(math.random(300, 600)) -- 5-10 phút
                pcall(function()
                    workspace.CurrentCamera.FieldOfView = workspace.CurrentCamera.FieldOfView
                end)
            end
        end)

        if ANTIBAN_CONFIG.DebugMode then print("Performance profile active.") end
    end

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

        if ANTIBAN_CONFIG.DebugMode then print("Performance profile disabled.") end
    end

    workspace.DescendantAdded:Connect(function(v)
        if not state.boosted then return end
        if shouldIgnoreObject(v) or services.CollectionService:HasTag(v, TAG) then
            return
        end

        local now = tick()
        local debounceTime = ANTIBAN_CONFIG.Enabled and ANTIBAN_CONFIG.RandomizeIntervals and math.random(0.2, 0.4) or CONFIG.DebounceTime
        if now - state.lastDebounce < debounceTime then
            return
        end
        state.lastDebounce = now

        local delayTime = ANTIBAN_CONFIG.Enabled and ANTIBAN_CONFIG.RandomizeIntervals and math.random(0.05, 0.2) or 0.1
        task.delay(delayTime, function()
            optimizePart(v)
            removeEffects(v.Parent)
        end)
    end)

    services.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            updatePlayerCache()
            if ANTIBAN_CONFIG.DebugMode then print("Player joined - Cache updated") end
        end)
    end)

    services.Players.PlayerRemoving:Connect(function(player)
        task.delay(0.5, updatePlayerCache)
    end)

    -- OBFUSCATED COMMANDS
    LocalPlayer.Chatted:Connect(function(msg)
        local lower = msg:lower()
        if lower == "/settings toggle" or lower == "/profile toggle" then
            if state.boosted then
                disableBoost()
            else
                applyBoost()
            end
        elseif lower == "/profile antiban off" then
            ANTIBAN_CONFIG.Enabled = false
            print("Antiban protocols disabled - Max performance mode.")
        elseif lower == "/profile antiban on" then
            ANTIBAN_CONFIG.Enabled = true
            print("Antiban protocols enabled.")
        elseif lower == "/debug on" then
            ANTIBAN_CONFIG.DebugMode = true
            print("Debug mode enabled.")
        elseif lower == "/debug off" then
            ANTIBAN_CONFIG.DebugMode = false
            print("Debug mode disabled.")
        elseif lower == "/status" then
            print("=== System Status Report ===")
            print("Profile Status: " .. (state.boosted and "ACTIVE" or "INACTIVE"))
            print("Antiban: " .. (ANTIBAN_CONFIG.Enabled and "ENABLED" or "DISABLED"))
            print("Optimized Parts: " .. tostring(countDictionary(state.optimizedParts)))
            print("Cached Players: " .. tostring(countDictionary(state.playerCache)))
            print("Uptime: " .. math.floor(tick() - state.startTime) .. "s")
            local runTime = tick() - state.startTime
            local stage = getAdaptiveStage(runTime)
            print("Current Stage: " .. (runTime < 600 and "Cautious" or runTime < 1800 and "Normal" or "Relaxed"))
        end
    end)

    task.wait(2)
    applyBoost()

    -- OBFUSCATED LOGGING
    print("System ready.")
    print("Commands: /settings toggle, /status, /profile antiban on/off, /debug on/off")
end)

if not success then
    warn("System Error: " .. tostring(err))
end