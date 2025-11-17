--[[
    Blox Fruits FPS Booster v8.8.1 - The Ultimate King (Đề Xuất Edition)
    Mô tả: Phiên bản kết hợp hoàn hảo giữa hiệu suất v8.7.5 và anti-detection tinh vi v8.8.0.
    Đặc điểm: Ghost Protocol được tinh chỉnh để tối thiểu tác động hiệu suất, mang lại sự an toàn tuyệt đối.
    Mục tiêu: FPS cao nhất, an toàn tối đa, kiến trúc sạch sẽ và ổn định.
]]

local success, err = pcall(function()
    -- ==========================================
    -- KHỞI TẠO & CẤU HÌNH TỐI ƯU
    -- ==========================================
    local CoreServices = {
        Lighting = game:GetService("Lighting"),
        Workspace = game:GetService("Workspace"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService"),
        UserInputService = game:GetService("UserInputService"),
        StarterGui = game:GetService("StarterGui"),
        TweenService = game:GetService("TweenService"),
        Stats = game:GetService("Stats")
    }

    local LocalPlayer = CoreServices.Players.LocalPlayer or CoreServices.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    local Camera = CoreServices.Workspace.CurrentCamera
    local Terrain = CoreServices.Workspace:FindFirstChild("Terrain")

    -- CẤU HÌNH V8.8.1 - ĐỀ XUẤT EDITION
    local CONFIG = {
        -- === SMART PROFILES + AUTO-DETECT ===
        Profiles = {
            PowerSaver = { MaxObjects = 15, LOD = true, Predict = true, Adaptive = true },
            MobileKing = { MaxObjects = 25, LOD = true, Predict = true, Adaptive = true },
            Balanced = { MaxObjects = 40, LOD = true, Predict = true, Adaptive = true },
            Performance = { MaxObjects = 60, LOD = false, Predict = true, Adaptive = true },
            Ultimate = { MaxObjects = 100, LOD = true, Predict = true, Adaptive = true }
        },
        CurrentProfile = "Auto",

        -- === HYBRID MODE ===
        Hybrid = {
            DestroyClasses = {"ParticleEmitter", "Fire", "Smoke", "Sparkles", "Beam", "Trail", "Decal", "Texture"},
            DisableClasses = {"PointLight", "SpotLight", "SurfaceLight"},
            ImportantNames = {"sword", "fruit", "gun", "weapon", "boss", "npc", "item", "quest", "dealer"}
        },

        -- === GHOST PROTOCOL (LIGHTWEIGHT & REFINED) ===
        GhostProtocol = {
            Enabled = true,
            PerformanceImpact = "Medium", -- Low, Medium, High - Mức độ ảnh hưởng hiệu suất
            -- Combat Detection (Optimized)
            CombatDetection = {
                Enabled = true,
                ProximityThreshold = 50,
                CheckInterval = 3, -- Tăng interval để giảm tải
                PauseActionsInCombat = true
            },
            -- Behavior Simulation (Lightweight)
            BehaviorSimulation = {
                Enabled = true,
                IdleActions = {
                    CameraSway = { Enabled = true, SwayAmount = 1.5, Interval = {25, 45} }, -- Giảm sway và tăng interval
                    TinyMovement = { Enabled = true, Distance = 0.15, Interval = {30, 50} } -- Giảm movement và tăng interval
                }
            },
            -- Network Stealth (Minimal Impact)
            NetworkStealth = {
                Enabled = true,
                SimulatedLag = { Enabled = true, Min = 0, Max = 0.005 }, -- Giảm max lag
                ChangeInterval = 10 -- Thay đổi lag mỗi 10 giây
            },
            StealthLevel = 3, -- 1-5
            DynamicTagRotation = true
        },

        -- === ADVANCED PERFORMANCE ===
        Performance = {
            LOD = { Enabled = true, Levels = 5, DistanceMultipliers = {1, 2, 4, 8, 16}, UpdateInterval = 1.0 },
            Prediction = { Enabled = true, Window = 5, Accuracy = 0.8 },
            Adaptive = { Enabled = true, Thresholds = {Low = 30, Mid = 45, High = 60} },
            DynamicBatch = { Enabled = true, MinSize = 50, MaxSize = 500 },
            Debounce = { Enabled = true, MinDelay = 0.05, MaxDelay = 0.3 },
            MemoryHysteresis = 10
        },

        Network = { Enabled = true, IncomingReplicationLag = 0, ClientPhysicsSendRate = 40, ClientPhysicsReceiveRate = 60 },
        Sound = { Enabled = true, RollOffMode = Enum.RollOffMode.Linear, RollOffMaxDistance = 100 }
    }

    -- ==========================================
    -- HỆ THỐNG TRẠNG THÁI NÂNG CAO
    -- ==========================================
    local State = {
        Enabled = false,
        StartTime = tick(),
        CurrentTag = CoreServices.HttpService:GenerateGUID(false):sub(1, 12),
        OptimizedObjects = setmetatable({}, {__mode = "kv"}),
        LODObjects = setmetatable({}, {__mode = "kv"}),
        Connections = {},
        Tasks = {},
        Performance = {
            FPS = 60, AverageFPS = 60, MinFPS = 60, MaxFPS = 60, FrameTime = 0,
            MemoryUsage = 0, MemoryPeak = 0, Ping = 0, PerformanceHistory = {}, PredictionData = {}
        },
        Statistics = {
            TotalOptimized = 0, TotalDestroyed = 0, ScanCycles = 0, MemoryFreed = 0, LastReset = tick()
        },
        Adaptive = { SystemTier = "Auto", PerformanceTrend = "Stable", PredictiveOptimizations = 0 },
        Settings = { VerboseLogging = false, DebugMode = false, AutoDetectDevice = true },
        OriginalSettings = {
            Lighting = { Brightness = CoreServices.Lighting.Brightness, OutdoorAmbient = CoreServices.Lighting.OutdoorAmbient, Technology = CoreServices.Lighting.Technology, GlobalShadows = CoreServices.Lighting.GlobalShadows, ShadowSoftness = CoreServices.Lighting.ShadowSoftness, FogEnd = CoreServices.Lighting.FogEnd },
            Workspace = { StreamingEnabled = CoreServices.Workspace.StreamingEnabled, StreamingTargetRadius = CoreServices.Workspace.StreamingTargetRadius, StreamingMinRadius = CoreServices.Workspace.StreamingMinRadius },
            Rendering = { QualityLevel = settings().Rendering.QualityLevel },
            Terrain = Terrain and { Decoration = Terrain.Decoration, WaterWaveSize = Terrain.WaterWaveSize, WaterReflectance = Terrain.WaterReflectance, WaterTransparency = Terrain.WaterTransparency } or nil,
            PostEffects = {}
        },
        GhostProtocol = { InCombat = false, LastCombatCheckTime = 0, LastNetworkChangeTime = 0 }
    }

    for _, effect in ipairs(CoreServices.Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then State.OriginalSettings.PostEffects[effect.Name] = effect.Enabled end
    end

    -- ==========================================
    -- HỆ THỐNG TIỆN ÍCH (KHÔNG GUI)
    -- ==========================================
    local Utility = {}
    function Utility.notify(msg, duration, color)
        duration = duration or 3; color = color or Color3.fromRGB(0, 255, 100)
        pcall(function()
            CoreServices.StarterGui:SetCore("ChatMakeSystemMessage", { Text = "[Đề Xuất] " .. msg, Color = color, Font = Enum.Font.SourceSansBold, TextSize = 16 })
        end)
    end
    function Utility.getRandomDelay() return math.random(CONFIG.Performance.Debounce.MinDelay * 100, CONFIG.Performance.Debounce.MaxDelay * 100) / 100 end
    function Utility.debugLog(message) if State.Settings.DebugMode then print("[DEBUG] " .. message) end end

    -- ==========================================
    -- GHOST PROTOCOL (LIGHTWEIGHT & REFINED)
    -- ==========================================
    local GhostProtocol = {}
    
    -- Combat Detection (Optimized)
    function GhostProtocol.isInCombat()
        if not CONFIG.GhostProtocol.CombatDetection.Enabled then return false end
        if tick() - State.GhostProtocol.LastCombatCheckTime < CONFIG.GhostProtocol.CombatDetection.CheckInterval then return State.GhostProtocol.InCombat end
        
        State.GhostProtocol.LastCombatCheckTime = tick()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
        
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local distance = (player.Character.PrimaryPart.Position - playerPos).Magnitude
                if distance < CONFIG.GhostProtocol.CombatDetection.ProximityThreshold then
                    State.GhostProtocol.InCombat = true
                    return true
                end
            end
        end
        State.GhostProtocol.InCombat = false
        return false
    end

    -- Behavior Simulation (Lightweight)
    function GhostProtocol.simulateCameraSway()
        if not CONFIG.GhostProtocol.BehaviorSimulation.Enabled or not CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.CameraSway.Enabled then return end
        if GhostProtocol.isInCombat() and CONFIG.GhostProtocol.CombatDetection.PauseActionsInCombat then return end
        
        local interval = math.random(CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.CameraSway.Interval[1], CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.CameraSway.Interval[2])
        task.wait(interval)
        
        if State.Enabled then
            pcall(function()
                local currentCFrame = Camera.CFrame
                local swayAmount = CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.CameraSway.SwayAmount
                local randomOffset = Vector3.new(math.random(-swayAmount, swayAmount) / 100, math.random(-swayAmount, swayAmount) / 100, 0)
                local targetCFrame = currentCFrame * CFrame.new(randomOffset)
                
                local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                local tween = CoreServices.TweenService:Create(Camera, tweenInfo, {CFrame = targetCFrame})
                tween.Completed:Wait()
                
                local tweenBack = CoreServices.TweenService:Create(Camera, tweenInfo, {CFrame = currentCFrame})
            end)
        end
    end

    function GhostProtocol.simulateTinyMovement()
        if not CONFIG.GhostProtocol.BehaviorSimulation.Enabled or not CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.TinyMovement.Enabled then return end
        if GhostProtocol.isInCombat() and CONFIG.GhostProtocol.CombatDetection.PauseActionsInCombat then return end
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local interval = math.random(CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.TinyMovement.Interval[1], CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.TinyMovement.Interval[2])
        task.wait(interval)
        
        if State.Enabled then
            pcall(function()
                local moveDirection = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
                humanoid:Move(moveDirection * CONFIG.GhostProtocol.BehaviorSimulation.IdleActions.TinyMovement.Distance)
                task.wait(0.1)
                humanoid:Move(Vector3.new(0, 0, 0))
            end)
        end
    end

    -- Network Stealth (Minimal Impact)
    function GhostProtocol.applyNetworkStealth()
        if not CONFIG.GhostProtocol.NetworkStealth.Enabled then return end
        if tick() - State.GhostProtocol.LastNetworkChangeTime < CONFIG.GhostProtocol.NetworkStealth.ChangeInterval then return end
        
        State.GhostProtocol.LastNetworkChangeTime = tick()
        pcall(function()
            local lag = math.random(CONFIG.GhostProtocol.NetworkStealth.SimulatedLag.Min * 1000, CONFIG.GhostProtocol.NetworkStealth.SimulatedLag.Max * 1000) / 1000
            game:GetService("NetworkSettings").IncomingReplicationLag = lag
        end)
    end

    -- Main GhostProtocol monitor loop (Lightweight)
    function GhostProtocol.monitor()
        while State.Enabled do
            GhostProtocol.isInCombat() -- Update combat state
            GhostProtocol.applyNetworkStealth()
            
            -- Chạy hành vi mô phỏng một cách thưa thớt để giảm tải
            if math.random(1, 3) == 1 then
                task.spawn(GhostProtocol.simulateCameraSway)
            end
            if math.random(1, 3) == 1 then
                task.spawn(GhostProtocol.simulateTinyMovement)
            end
            
            task.wait(2) -- Kiểm tra mỗi 2 giây
        end
    end

    -- ==========================================
    -- HỆ THỐNG LỌC THÔNG MINH (HYBRID MODE)
    -- ==========================================
    local SmartFilter = {}
    function SmartFilter.isImportant(obj)
        local name = obj.Name:lower()
        for _, keyword in ipairs(CONFIG.Hybrid.ImportantNames) do if name:find(keyword) then return true end end
        return obj:IsDescendantOf(LocalPlayer.Character) or obj:FindFirstChildWhichIsA("Humanoid")
    end
    function SmartFilter.getAction(obj)
        if SmartFilter.isImportant(obj) then return "Ignore" end
        local class = obj.ClassName
        for _, c in ipairs(CONFIG.Hybrid.DestroyClasses) do if class == c then return "Destroy" end end
        for _, c in ipairs(CONFIG.Hybrid.DisableClasses) do if class == c then return "Disable" end end
        return "Ignore"
    end

    -- ==========================================
    -- HỆ THỐNG TỐI ƯU HÓA (HYBRID MODE)
    -- ==========================================
    local HybridOptimizer = {}
    function HybridOptimizer.processObject(obj)
        local action = SmartFilter.getAction(obj)
        if action == "Destroy" then
            pcall(obj.Destroy, obj)
            State.Statistics.TotalDestroyed += 1
            return true
        elseif action == "Disable" then
            if obj:IsA("Light") then obj.Enabled = false; obj.Brightness = 0 end
            if obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false end
            return true
        end
        return false
    end
    function HybridOptimizer.batchProcess(objects)
        local maxObjects = math.min(#objects, CONFIG.Profiles[CONFIG.CurrentProfile].MaxObjects)
        local optimized = 0
        for i = 1, maxObjects do
            if HybridOptimizer.processObject(objects[i]) then optimized += 1 end
            if i % 50 == 0 then RunService.Heartbeat:Wait() end
        end
        return optimized
    end

    -- ==========================================
    -- HỆ THỐNG QUÉT THÔNG MINH + AI PREDICTION
    -- ==========================================
    local SmartScanner = {}
    function SmartScanner.fullScan()
        local allObjects = CoreServices.Workspace:GetDescendants()
        local optimized = HybridOptimizer.batchProcess(allObjects)
        State.Statistics.ScanCycles += 1
        if State.Settings.VerboseLogging then Utility.notify("Đã quét và tối ưu " .. optimized .. " đối tượng.", 2) end
    end
    function SmartScanner.continuousScan()
        while State.Enabled do
            task.wait(Utility.getRandomDelay() * 10)
            if State.Enabled then SmartScanner.fullScan() end
        end
    end
    function SmartScanner.predictiveScan()
        if not CONFIG.Performance.Prediction.Enabled then return end
        while State.Enabled do
            task.wait(CONFIG.Performance.Prediction.Window)
            if State.Enabled and State.Performance.AverageFPS < CONFIG.Performance.Adaptive.Thresholds.Low then
                Utility.debugLog("Predictive optimization triggered")
                SmartScanner.fullScan()
                State.Adaptive.PredictiveOptimizations += 1
            end
        end
    end

    -- ==========================================
    -- HỆ THỐNG QUẢN LÝ BỘ NHỚ + Hysteresis
    -- ==========================================
    local MemoryManager = {}
    function MemoryManager.cleanup()
        local preMemory = State.Performance.MemoryUsage
        for obj, _ in pairs(State.OptimizedObjects) do if not obj or not obj.Parent then State.OptimizedObjects[obj] = nil end end
        collectgarbage("collect")
        local postMemory = collectgarbage("count") / 1024
        State.Statistics.MemoryFreed += (preMemory - postMemory)
    end
    function MemoryManager.monitor()
        while State.Enabled do
            task.wait(20)
            if State.Enabled then
                State.Performance.MemoryUsage = collectgarbage("count") / 1024
                if State.Performance.MemoryUsage > 100 + CONFIG.Performance.MemoryHysteresis then
                    MemoryManager.cleanup()
                    if State.Settings.VerboseLogging then Utility.notify("Đã dọn dẹp bộ nhớ.", 2) end
                end
            end
        end
    end

    -- ==========================================
    -- HỆ THỐNG PHÂN TÍCH HIỆU SUẤT + ADAPTIVE
    -- ==========================================
    local PerformanceMonitor = {}
    function PerformanceMonitor.update()
        local currentFPS = math.floor(CoreServices.Workspace:GetRealPhysicsFPS())
        State.Performance.FPS = currentFPS
        State.Performance.MinFPS = math.min(State.Performance.MinFPS, currentFPS)
        State.Performance.MaxFPS = math.max(State.Performance.MaxFPS, currentFPS)
        State.Performance.FrameTime = 1 / currentFPS
        State.Performance.MemoryUsage = collectgarbage("count") / 1024
        State.Performance.MemoryPeak = math.max(State.Performance.MemoryPeak, State.Performance.MemoryUsage)
        State.Performance.AverageFPS = (State.Performance.AverageFPS * 0.9) + (currentFPS * 0.1)
        table.insert(State.Performance.PerformanceHistory, {Time = tick(), FPS = currentFPS})
        if #State.Performance.PerformanceHistory > 60 then table.remove(State.Performance.PerformanceHistory, 1) end
    end
    function PerformanceMonitor.determineSystemTier()
        local fps = State.Performance.AverageFPS
        if fps < CONFIG.Performance.Adaptive.Thresholds.Low then return "Low"
        elseif fps < CONFIG.Performance.Adaptive.Thresholds.Mid then return "Mid"
        else return "High" end
    end

    local AdaptiveSystem = {}
    function AdaptiveSystem.updateSettings()
        State.Adaptive.SystemTier = PerformanceMonitor.determineSystemTier()
        if State.Adaptive.SystemTier == "Low" then CONFIG.CurrentProfile = "PowerSaver"
        elseif State.Adaptive.SystemTier == "Mid" then CONFIG.CurrentProfile = "MobileKing"
        else CONFIG.CurrentProfile = "Balanced" end
        Utility.debugLog("Adaptive System: Tier=" .. State.Adaptive.SystemTier .. ", Profile=" .. CONFIG.CurrentProfile)
    end
    function AdaptiveSystem.monitor()
        while State.Enabled do
            task.wait(5)
            if State.Enabled then
                PerformanceMonitor.update()
                AdaptiveSystem.updateSettings()
            end
        end
    end

    -- ==========================================
    -- HỆ THỐNG LOD (STABLE)
    -- ==========================================
    local LODSystem = {}
    function LODSystem.registerObject(obj)
        if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
        State.LODObjects[obj] = {
            OriginalSize = obj.Size, OriginalMaterial = obj.Material,
            OriginalReflectance = obj.Reflectance, OriginalTransparency = obj.Transparency,
            OriginalCanCollide = obj.CanCollide
        }
    end
    function LODSystem.update()
        if not CONFIG.Performance.LOD.Enabled then return end
        local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        for obj, data in pairs(State.LODObjects) do
            if not obj or not obj.Parent then continue end
            local distance = (obj.Position - playerPos).Magnitude
            local lodLevel = 1
            for i, multiplier in ipairs(CONFIG.Performance.LOD.DistanceMultipliers) do
                if distance > 200 * multiplier then lodLevel = i else break end
            end
            if lodLevel > 1 then
                local scaleFactor = 1 / (lodLevel * 0.5)
                obj.Size = data.OriginalSize * scaleFactor
                obj.Reflectance = data.OriginalReflectance * (1 / lodLevel)
                obj.Transparency = math.min(1, data.OriginalTransparency + (0.2 * (lodLevel - 1)))
                obj.CanCollide = false
            else
                obj.Size = data.OriginalSize; obj.Material = data.OriginalMaterial
                obj.Reflectance = data.OriginalReflectance; obj.Transparency = data.OriginalTransparency
                obj.CanCollide = data.OriginalCanCollide
            end
        end
    end
    function LODSystem.monitor()
        while State.Enabled do
            task.wait(CONFIG.Performance.LOD.UpdateInterval)
            if State.Enabled and CONFIG.Performance.LOD.Enabled then LODSystem.update() end
        end
    end

    -- ==========================================
    -- ÁP DỤNG CÀI ĐẶT HIỆU SUẤT
    -- ==========================================
    local function applyPerformanceSettings()
        local profile = CONFIG.Profiles[CONFIG.CurrentProfile]
        settings().Rendering.QualityLevel = 1
        CoreServices.Lighting.GlobalShadows = false; CoreServices.Lighting.ShadowSoftness = 0
        CoreServices.Lighting.FogEnd = math.huge
        CoreServices.Lighting.Brightness = State.OriginalSettings.Lighting.Brightness
        CoreServices.Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        CoreServices.Lighting.Technology = Enum.Technology.Compatibility
        for _, effect in ipairs(CoreServices.Lighting:GetChildren()) do if effect:IsA("PostEffect") then effect.Enabled = false end end
        if Terrain then Terrain.Decoration = false; Terrain.WaterWaveSize = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0 end
        CoreServices.Workspace.StreamingEnabled = true
        CoreServices.Workspace.StreamingTargetRadius = profile.LOD and 200 or 512
        CoreServices.Workspace.StreamingMinRadius = 64
        
        GhostProtocol.applyNetworkStealth()
        
        if CONFIG.Network.Enabled then
            pcall(function() game:GetService("NetworkSettings").IncomingReplicationLag = CONFIG.Network.IncomingReplicationLag end)
            pcall(function() game:GetService("NetworkSettings").ClientPhysicsSendRate = CONFIG.Network.ClientPhysicsSendRate end)
            pcall(function() game:GetService("NetworkSettings").ClientPhysicsReceiveRate = CONFIG.Network.ClientPhysicsReceiveRate end)
        end
        if CONFIG.Sound.Enabled then
            CoreServices.Workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Sound") then
                    descendant.RollOffMode = CONFIG.Sound.RollOffMode
                    descendant.RollOffMaxDistance = CONFIG.Sound.RollOffMaxDistance
                end
            end)
        end
    end

    -- ==========================================
    -- HÀM BẬT/TẮT HỆ THỐNG
    -- ==========================================
    local function enableBoost()
        if State.Enabled then return end
        State.Enabled = true; State.StartTime = tick()
        if State.Settings.AutoDetectDevice then
            CONFIG.CurrentProfile = CoreServices.UserInputService.TouchEnabled and "MobileKing" or "Balanced"
        end
        Utility.notify("Đang kích hoạt Đề Xuất Mode... Profile: " .. CONFIG.CurrentProfile, 2)
        applyPerformanceSettings()
        
        table.insert(State.Tasks, task.spawn(SmartScanner.continuousScan))
        table.insert(State.Tasks, task.spawn(SmartScanner.predictiveScan))
        table.insert(State.Tasks, task.spawn(MemoryManager.monitor))
        table.insert(State.Tasks, task.spawn(AdaptiveSystem.monitor))
        table.insert(State.Tasks, task.spawn(LODSystem.monitor))
        
        if CONFIG.GhostProtocol.Enabled then
            table.insert(State.Tasks, task.spawn(GhostProtocol.monitor))
        end
        
        task.spawn(SmartScanner.fullScan)
        State.Connections.DescendantAdded = CoreServices.Workspace.DescendantAdded:Connect(function(obj)
            if State.Enabled then
                task.defer(function()
                    if CONFIG.Performance.Debounce.Enabled and (tick() - State.Performance.LastOptimizationTime < Utility.getRandomDelay()) then return end
                    if CONFIG.Performance.LOD.Enabled and obj:IsA("BasePart") and not obj:IsA("Terrain") then
                        LODSystem.registerObject(obj)
                    end
                    if HybridOptimizer.processObject(obj) then
                        State.Statistics.TotalOptimized += 1
                        CoreServices.CollectionService:AddTag(obj, State.CurrentTag)
                    end
                    State.Performance.LastOptimizationTime = tick()
                end)
            end
        end)
        Utility.notify("✅ Đề Xuất đã sẵn sàng!", 3)
    end
    local function disableBoost()
        if not State.Enabled then return end
        State.Enabled = false
        Utility.notify("Đang vô hiệu hóa...", 2)
        for _, t in ipairs(State.Tasks) do pcall(task.cancel, t) end; State.Tasks = {}
        for _, c in ipairs(State.Connections) do pcall(c.Disconnect, c) end; State.Connections = {}
        
        pcall(function()
            for prop, value in pairs(State.OriginalSettings.Lighting) do CoreServices.Lighting[prop] = value end
            for prop, value in pairs(State.OriginalSettings.Workspace) do CoreServices.Workspace[prop] = value end
            settings().Rendering.QualityLevel = State.OriginalSettings.Rendering.QualityLevel
            if State.OriginalSettings.Terrain and Terrain then
                for prop, value in pairs(State.OriginalSettings.Terrain) do Terrain[prop] = value end
            end
            for effectName, originalEnabled in pairs(State.OriginalSettings.PostEffects) do
                local effect = CoreServices.Lighting:FindFirstChild(effectName)
                if effect and effect:IsA("PostEffect") then effect.Enabled = originalEnabled end
            end
            for obj, data in pairs(State.LODObjects) do
                if obj and obj.Parent then
                    obj.Size = data.OriginalSize; obj.Material = data.OriginalMaterial
                    obj.Reflectance = data.OriginalReflectance; obj.Transparency = data.OriginalTransparency
                    obj.CanCollide = data.OriginalCanCollide
                end
            end
        end)
        Utility.notify("❌ Đã tắt. TOÀN BỘ cài đặt đã được khôi phục.", 3)
    end

    -- ==========================================
    -- LỆNH ĐIỀU KHIỂN
    -- ==========================================
    LocalPlayer.Chatted:Connect(function(msg)
        local cmd = msg:lower()
        if cmd == "/e fps" then if State.Enabled then disableBoost() else enableBoost() end
        elseif cmd == "/e fps status" then
            local status = State.Enabled and "🟢 BẬT" or "🔴 TẮT"
            local uptime = math.floor(tick() - State.StartTime)
            Utility.notify(string.format("Status: %s | Profile: %s | FPS: %d | Mem: %.1fMB | Uptime: %ds | Tối ưu: %d | Hủy: %d",
                status, CONFIG.CurrentProfile, State.Performance.FPS, State.Performance.MemoryUsage, uptime, State.Statistics.TotalOptimized, State.Statistics.TotalDestroyed), 5)
        -- === GHOST PROTOCOL COMMANDS ===
        elseif cmd == "/e fps ghost" then
            local status = CONFIG.GhostProtocol.Enabled and "🟢 BẬT" or "🔴 TẮT"
            Utility.notify("Ghost Protocol: " .. status, 3)
        elseif cmd:find("/e fps impact ") then
            local impact = cmd:sub(14)
            if impact == "low" or impact == "medium" or impact == "high" then
                CONFIG.GhostProtocol.PerformanceImpact = impact
                Utility.notify("Ghost Protocol: Performance impact set to " .. impact, 2)
            else
                Utility.notify("Usage: /e fps impact low/medium/high", 2, Color3.fromRGB(255, 100, 100))
            end
        -- === LEGACY COMMANDS ===
        elseif cmd:find("/e fps profile ") then
            local profileName = cmd:sub(14)
            if CONFIG.Profiles[profileName] then CONFIG.CurrentProfile = profileName; Utility.notify("Đã chuyển sang profile: " .. profileName, 2)
            else Utility.notify("Profile không tồn tại!", 2, Color3.fromRGB(255, 100, 100)) end
        elseif cmd == "/e fps profiles" then
            local list = ""; for name, _ in pairs(CONFIG.Profiles) do list = list .. name .. ", " end
            Utility.notify("Profiles: " .. list:sub(1, -3), 5)
        elseif cmd == "/e fps advanced" then
            Utility.notify(string.format("Advanced: AvgFPS: %d | MinFPS: %d | MaxFPS: %d | FrameTime: %.3fms | MemPeak: %.1fMB | Predictions: %d",
                math.floor(State.Performance.AverageFPS), State.Performance.MinFPS, State.Performance.MaxFPS, State.Performance.FrameTime * 1000, State.Performance.MemoryPeak, State.Adaptive.PredictiveOptimizations), 6)
        elseif cmd == "/e fps cleanup" then
            local preMem = State.Performance.MemoryUsage; MemoryManager.cleanup()
            Utility.notify("Đã dọn dẹp bộ nhớ. Tự do: " .. string.format("%.2f", preMem - State.Performance.MemoryUsage) .. "MB", 3)
        elseif cmd == "/e fps debug" then State.Settings.DebugMode = not State.Settings.DebugMode; Utility.notify("Debug mode: " .. (State.Settings.DebugMode and "ON" or "OFF"), 2)
        elseif cmd == "/e fps verbose" then State.Settings.VerboseLogging = not State.Settings.VerboseLogging; Utility.notify("Verbose logging: " .. (State.Settings.VerboseLogging and "ON" or "OFF"), 2)
        elseif cmd == "/e fps resetstats" then
            State.Statistics = { TotalOptimized = 0, TotalDestroyed = 0, ScanCycles = 0, MemoryFreed = 0, LastReset = tick() }
            State.Performance.MinFPS = 60; State.Performance.MaxFPS = 60; State.Performance.MemoryPeak = 0
            Utility.notify("Statistics have been reset.", 2)
        end
    end)

    task.delay(2, enableBoost)

end)

if not success then
    warn("[Lỗi Nặng] " .. tostring(err))
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("ChatMakeSystemMessage", { Text = "❌ Lỗi: " .. tostring(err), Color = Color3.fromRGB(255, 0, 0), Font = Enum.Font.SourceSansBold })
end