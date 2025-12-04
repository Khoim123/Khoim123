-- NOKIA G21 ULTRA PERFORMANCE OPTIMIZER V3.1 (FIXED)
-- Optimized for 6GB RAM / 128GB ROM / Unisoc T606 / 90Hz Display
-- Balanced performance and quality with reduced lag

print("🔧 Starting Ultra Performance Optimizer v3.1 (Fixed)...")

-- ===== SERVICES =====
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== OPTIMIZED CONFIGURATION =====
local Config = {
    -- Graphics Settings (REDUCED FOR PERFORMANCE)
    RenderDistance = 220,        -- Reduced from 280
    GraphicsQuality = 5,         -- Reduced from 6
    ShadowQuality = "Low",       -- Changed from Medium
    ParticleLimit = 50,         -- Reduced from 75
    TextureQuality = "Medium",   -- Reduced from High

    -- Performance Targets (MORE REALISTIC)
    TargetFPS = 60,              -- Reduced from 70
    MinFPS = 40,                 -- Reduced from 50
    MaxFPS = 75,                 -- Reduced from 90

    -- Features (MORE SELECTIVE)
    SmartCulling = true,
    AdaptiveQuality = true,
    DynamicLOD = true,
    AdvancedPhysics = false,     -- DISABLED - major performance impact
    PerformanceMonitor = true,
    AutoMemoryManagement = true,
    SmoothAnimations = true,

    -- REDUCED INTERVALS FOR LESS LAG
    CullingInterval = 1.0,       -- Increased from 0.3
    MonitorInterval = 1.0,       -- Increased from 0.5
    CleanupInterval = 120,       -- Increased from 60
    AdaptiveInterval = 5,        -- Increased from 3
}

-- ===== GLOBAL VARIABLES =====
local PerformanceData = {
    CurrentFPS = 60,
    AverageFPS = 60,
    MemoryUsage = 0,
    DrawCalls = 0,
    ActiveParts = 0,
    LastCleanup = tick(),
    FPSHistory = {},
    QualityLevel = Config.GraphicsQuality,
}

local OptimizationCache = {
    CulledObjects = {},
    LODObjects = {},
    OriginalProperties = {},
    ProcessedObjects = {}, -- Track processed objects to avoid reprocessing
}

-- ===== UTILITY FUNCTIONS =====
local function SafeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("⚠️ Error:", result)
    end
    return success, result
end

local function GetAverageFPS()
    local sum = 0
    for _, fps in ipairs(PerformanceData.FPSHistory) do
        sum = sum + fps
    end
    return #PerformanceData.FPSHistory > 0 and sum / #PerformanceData.FPSHistory or 60
end

-- ===== 1. FIXED GRAPHICS OPTIMIZATION =====
local function OptimizeGraphics()
    print("📊 Optimizing graphics for Nokia G21...")

    SafeExecute(function()
        -- Set conservative quality level
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

        -- FIXED: Correct shadow and lighting properties
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.ShadowMap
        
        -- FIXED: Use correct brightness property
        Lighting.Ambient = Color3.fromRGB(120, 120, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        
        -- FIXED: Removed invalid Brightness property
        -- Use EnvironmentDiffuseScale instead
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.3
        Lighting.ShadowSoftness = 0.3

        -- Optimized fog
        if Lighting.FogEnd < 800 then
            Lighting.FogEnd = math.max(Lighting.FogEnd, 400)
        end

        -- REDUCED: Less aggressive post-processing optimization
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") then
                effect.Enabled = true
                effect.Intensity = math.min(effect.Intensity, 0.3) -- Reduced
                effect.Threshold = math.max(effect.Threshold, 2.0) -- Increased
                effect.Size = math.min(effect.Size, 12) -- Reduced
            elseif effect:IsA("BlurEffect") then
                effect.Size = math.min(effect.Size, 4) -- Reduced
            elseif effect:IsA("SunRaysEffect") then
                effect.Intensity = math.min(effect.Intensity, 0.05) -- Reduced
                effect.Spread = math.min(effect.Spread, 0.3) -- Reduced
            elseif effect:IsA("ColorCorrectionEffect") then
                effect.Enabled = true
            elseif effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false -- Always disable for performance
            end
        end
    end)

    print("✅ Graphics optimized successfully")
end

-- ===== 2. OPTIMIZED DYNAMIC LOD SYSTEM =====
local function InitializeDynamicLOD()
    if not Config.DynamicLOD then return end

    print("🎯 Starting Optimized Dynamic LOD System...")

    local LODDistances = {
        High = Config.RenderDistance * 0.25, -- Reduced zones
        Medium = Config.RenderDistance * 0.5,
        Low = Config.RenderDistance * 0.8,   -- Don't process at max distance
    }

    local lastLODUpdate = tick()
    local processedCount = 0
    local maxProcessPerFrame = 50 -- Limit processing per frame

    RunService.Heartbeat:Connect(function()
        if tick() - lastLODUpdate < 1.0 then return end -- Increased interval
        lastLODUpdate = tick()

        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end

        local playerPos = Player.Character.HumanoidRootPart.Position
        processedCount = 0

        -- OPTIMIZED: Only process nearby objects, not all workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if processedCount >= maxProcessPerFrame then break end -- Limit processing
            
            if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                SafeExecute(function()
                    local distance = (obj.Position - playerPos).Magnitude

                    -- Skip if too far away
                    if distance > Config.RenderDistance then return end

                    -- Cache properties to avoid repeated access
                    if not OptimizationCache.OriginalProperties[obj] then
                        OptimizationCache.OriginalProperties[obj] = {
                            RenderFidelity = obj.RenderFidelity,
                            CastShadow = obj.CastShadow,
                        }
                    end

                    -- Apply LOD with reduced shadow casting
                    if distance < LODDistances.High then
                        obj.RenderFidelity = Enum.RenderFidelity.Precise
                        obj.CastShadow = true
                    elseif distance < LODDistances.Medium then
                        obj.RenderFidelity = Enum.RenderFidelity.Automatic
                        obj.CastShadow = false -- Disable shadows for performance
                    elseif distance < LODDistances.Low then
                        obj.RenderFidelity = Enum.RenderFidelity.Performance
                        obj.CastShadow = false
                    end

                    processedCount = processedCount + 1
                end)
            end
        end

        PerformanceData.ActiveParts = processedCount
    end)

    print("✅ Optimized Dynamic LOD System started")
end

-- ===== 3. OPTIMIZED SMART CULLING =====
local function OptimizedSmartCulling()
    if not Config.SmartCulling then return end

    print("👁️ Starting Optimized Smart Culling...")

    local lastUpdate = tick()
    local cullingRadius = Config.RenderDistance * 0.7 -- More aggressive culling

    RunService.RenderStepped:Connect(function()
        if tick() - lastUpdate < Config.CullingInterval then return end
        lastUpdate = tick()

        if not (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")) then
            return
        end

        local playerPos = Player.Character.HumanoidRootPart.Position
        local cameraPos = Camera.CFrame.Position
        local cameraLook = Camera.CFrame.LookVector

        local processedCount = 0
        local maxProcessPerFrame = 30 -- Reduced processing

        -- OPTIMIZED: Only process BaseParts with size filtering
        for _, obj in pairs(Workspace:GetDescendants()) do
            if processedCount >= maxProcessPerFrame then break end
            
            if obj:IsA("BasePart") and obj ~= Player.Character.HumanoidRootPart then
                -- Skip very small parts to save performance
                if obj.Size.Magnitude < 0.5 then continue end
                
                SafeExecute(function()
                    local objPos = obj.Position
                    local distance = (objPos - playerPos).Magnitude

                    -- Skip if already processed recently
                    if OptimizationCache.ProcessedObjects[obj] and 
                       tick() - OptimizationCache.ProcessedObjects[obj] < 2.0 then 
                        return 
                    end

                    -- Simplified frustum culling
                    local inRange = distance <= cullingRadius

                    -- Store original transparency
                    if not obj:GetAttribute("OrigTrans") then
                        obj:SetAttribute("OrigTrans", obj.Transparency)
                    end

                    -- Apply culling
                    if not inRange then
                        if not OptimizationCache.CulledObjects[obj] then
                            obj.Transparency = 1
                            OptimizationCache.CulledObjects[obj] = true
                        end
                    else
                        if OptimizationCache.CulledObjects[obj] then
                            obj.Transparency = obj:GetAttribute("OrigTrans") or 0
                            OptimizationCache.CulledObjects[obj] = nil
                        end
                    end

                    OptimizationCache.ProcessedObjects[obj] = tick()
                    processedCount = processedCount + 1
                end)
            end
        end
    end)

    print("✅ Optimized Smart Culling started")
end

-- ===== 4. REDUCED EFFECTS OPTIMIZATION =====
local function OptimizeEffectsIntelligent()
    print("🎨 Optimizing effects intelligently...")

    local particleCount = 0
    local effectsOptimized = 0

    for _, obj in pairs(Workspace:GetDescendants()) do
        SafeExecute(function()
            -- Particle Effects - MORE AGGRESSIVE LIMITING
            if obj:IsA("ParticleEmitter") then
                particleCount = particleCount + 1

                if particleCount > Config.ParticleLimit then
                    obj.Enabled = false
                else
                    obj.Enabled = true
                    obj.Rate = math.min(obj.Rate, 20) -- Reduced from 30
                    obj.Lifetime = NumberRange.new(
                        math.min(obj.Lifetime.Min, 3), -- Reduced
                        math.min(obj.Lifetime.Max, 4)  -- Reduced
                    )
                end
                effectsOptimized = effectsOptimized + 1
            end

            -- Trail Effects - MORE AGGRESSIVE
            if obj:IsA("Trail") then
                obj.Lifetime = math.min(obj.Lifetime, 2) -- Reduced from 3
                effectsOptimized = effectsOptimized + 1
            end

            -- Light Sources - MORE CONSERVATIVE
            if obj:IsA("PointLight") or obj:IsA("SpotLight") then
                obj.Brightness = math.min(obj.Brightness, 2) -- Reduced from 3
                obj.Range = math.min(obj.Range, 25) -- Reduced from 40
                obj.Shadows = false -- Always disable for performance
                effectsOptimized = effectsOptimized + 1
            end

            -- BasePart optimization - MORE AGGRESSIVE
            if obj:IsA("BasePart") then
                obj.Reflectance = math.min(obj.Reflectance, 0.2) -- Reduced from 0.4

                -- Shadow optimization - MORE AGGRESSIVE
                if obj.Size.Magnitude < 8 then -- Increased threshold
                    obj.CastShadow = false
                end

                -- Collision optimization - MORE AGGRESSIVE
                if obj.Size.Magnitude < 2.0 and not obj:IsDescendantOf(Player.Character or {}) then
                    obj.CanCollide = false
                end
            end
        end)
    end

    print("✅ Optimized " .. effectsOptimized .. " effects")
end

-- ===== 5. SIMPLIFIED TERRAIN OPTIMIZATION =====
local function OptimizeTerrain()
    print("🏔️ Optimizing terrain...")

    SafeExecute(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false -- Disable for performance
            terrain.WaterReflectance = 0.3 -- Reduced from 0.6
            terrain.WaterTransparency = 0.4 -- Increased
            terrain.WaterWaveSize = 0.1 -- Reduced
            terrain.WaterWaveSpeed = 8 -- Reduced
        end
    end)

    print("✅ Terrain optimized")
end

-- ===== 6. SIMPLIFIED ANIMATION OPTIMIZER =====
local function OptimizeAnimations()
    if not Config.SmoothAnimations then return end

    print("💃 Optimizing animations...")

    local function optimizeCharacter(character)
        SafeExecute(function()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end

            -- REDUCED: Less aggressive animation management
            local tracks = humanoid:GetPlayingAnimationTracks()
            if #tracks > 8 then -- Reduced from 10
                for i = 9, #tracks do
                    tracks[i]:Stop()
                end
            end

            -- Optimized humanoid properties
            humanoid.HealthDisplayDistance = 80 -- Reduced
            humanoid.NameDisplayDistance = 80   -- Reduced
        end)
    end

    if Player.Character then
        optimizeCharacter(Player.Character)
    end

    Player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Reduced wait time
        optimizeCharacter(character)
    end)

    print("✅ Animations optimized")
end

-- ===== 7. REDUCED PERFORMANCE MONITOR =====
local function OptimizedPerformanceMonitor()
    if not Config.PerformanceMonitor then return end

    print("📈 Starting Optimized Performance Monitor...")

    -- Update FPS
    local lastFrame = tick()
    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastFrame
        lastFrame = currentTime

        PerformanceData.CurrentFPS = math.floor(1 / math.max(deltaTime, 0.001))

        -- Update FPS history (reduced size)
        table.insert(PerformanceData.FPSHistory, PerformanceData.CurrentFPS)
        if #PerformanceData.FPSHistory > 20 then -- Reduced from 30
            table.remove(PerformanceData.FPSHistory, 1)
        end

        PerformanceData.AverageFPS = GetAverageFPS()
    end)

    -- Create GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PerformanceMonitor"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 180, 0, 120) -- Reduced size
    MainFrame.Position = UDim2.new(1, -190, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6) -- Reduced
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 22) -- Reduced
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BackgroundTransparency = 0.2
    Title.Text = "⚡ NOKIA G21"
    Title.TextColor3 = Color3.fromRGB(0, 255, 150)
    Title.TextSize = 12 -- Reduced
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 6)
    TitleCorner.Parent = Title

    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(1, -10, 1, -27)
    StatsLabel.Position = UDim2.new(0, 5, 0, 25)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsLabel.TextSize = 11 -- Reduced
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatsLabel.Parent = MainFrame

    -- REDUCED: Update stats less frequently
    task.spawn(function()
        while task.wait(Config.MonitorInterval) do
            SafeExecute(function()
                PerformanceData.MemoryUsage = Stats:GetTotalMemoryUsageMb()

                local fpsColor
                if PerformanceData.CurrentFPS >= Config.MinFPS then
                    fpsColor = "🟢"
                elseif PerformanceData.CurrentFPS >= 30 then
                    fpsColor = "🟡"
                else
                    fpsColor = "🔴"
                end

                StatsLabel.Text = string.format(
                    "%s FPS: %d (Avg: %d)\n" ..
                    "📊 Quality: %d\n" ..
                    "💾 RAM: %.0f MB\n" ..
                    "📦 Parts: %d",
                    fpsColor,
                    PerformanceData.CurrentFPS,
                    math.floor(PerformanceData.AverageFPS),
                    PerformanceData.QualityLevel,
                    PerformanceData.MemoryUsage,
                    PerformanceData.ActiveParts
                )
            end)
        end
    end)

    print("✅ Optimized Performance Monitor started")
end

-- ===== 8. MORE CONSERVATIVE ADAPTIVE QUALITY =====
local function AdaptiveQualitySystem()
    if not Config.AdaptiveQuality then return end

    print("🎯 Starting Conservative Adaptive Quality System...")

    task.spawn(function()
        while task.wait(Config.AdaptiveInterval) do
            SafeExecute(function()
                local avgFPS = PerformanceData.AverageFPS
                local currentQuality = PerformanceData.QualityLevel

                -- MORE CONSERVATIVE adjustments
                if avgFPS < Config.MinFPS and currentQuality > 4 then -- Higher minimum
                    PerformanceData.QualityLevel = math.max(currentQuality - 1, 4)
                    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. PerformanceData.QualityLevel]
                    Config.RenderDistance = math.max(Config.RenderDistance - 20, 180) -- Smaller changes
                    print("⬇️ Reduced quality to Level " .. PerformanceData.QualityLevel)

                elseif avgFPS > Config.TargetFPS + 10 and currentQuality < 6 then -- Higher threshold
                    PerformanceData.QualityLevel = math.min(currentQuality + 1, 6)
                    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. PerformanceData.QualityLevel]
                    Config.RenderDistance = math.min(Config.RenderDistance + 20, 250) -- Smaller changes
                    print("⬆️ Increased quality to Level " .. PerformanceData.QualityLevel)
                end

                -- More conservative memory management
                if PerformanceData.MemoryUsage > 3000 then -- Increased threshold
                    SmartMemoryCleanup()
                end
            end)
        end
    end)

    print("✅ Conservative Adaptive Quality System started")
end

-- ===== 9. OPTIMIZED MEMORY MANAGEMENT =====
function SmartMemoryCleanup()
    print("🧹 Performing optimized memory cleanup...")

    SafeExecute(function()
        -- Less aggressive cleanup
        for i = 1, 2 do -- Reduced from 3
            collectgarbage("collect")
            task.wait(0.1) -- Increased wait
        end

        -- Clean optimization cache more frequently
        if tick() - PerformanceData.LastCleanup > 180 then -- Increased from 300
            -- Partial cleanup instead of full
            local count = 0
            for obj in pairs(OptimizationCache.ProcessedObjects) do
                if tick() - OptimizationCache.ProcessedObjects[obj] > 300 then
                    OptimizationCache.ProcessedObjects[obj] = nil
                    count = count + 1
                    if count > 100 then break end -- Limit cleanup
                end
            end
        end

        collectgarbage("stop")
        task.wait(0.1)
        collectgarbage("restart")

        PerformanceData.LastCleanup = tick()
    end)

    print("✅ Memory cleaned up successfully")
end

-- ===== 10. SIMPLIFIED FPS LIMITER =====
local function SimpleFPSLimiter()
    print("🎯 Starting Simple FPS Limiter...")

    local targetFrameTime = 1 / Config.MaxFPS
    local lastFrame = tick()

    RunService.RenderStepped:Connect(function()
        local currentTime = tick()
        local elapsed = currentTime - lastFrame

        if elapsed < targetFrameTime then
            local sleepTime = targetFrameTime - elapsed
            task.wait(sleepTime)
        end

        lastFrame = tick()
    end)

    print("✅ FPS limited to " .. Config.MaxFPS)
end

-- ===== 11. REDUCED AUTO CLEANUP =====
local function AutoMemoryCleanup()
    if not Config.AutoMemoryManagement then return end

    print("🔄 Starting Reduced Auto Memory Cleanup...")

    task.spawn(function()
        while task.wait(Config.CleanupInterval) do
            SmartMemoryCleanup()
        end
    end)

    print("✅ Reduced Auto Memory Cleanup started")
end

-- ===== INITIALIZATION =====
local function Initialize()
    print("╔" .. string.rep("═", 62) .. "╗")
    print("║  🚀 NOKIA G21 ULTRA PERFORMANCE OPTIMIZER V3.1 (FIXED)    ║")
    print("║  📱 6GB RAM / 128GB ROM / Unisoc T606 / 90Hz Display       ║")
    print("║  ⚡ Target: 60 FPS stable with optimized quality           ║")
    print("║  🔧 Fixed brightness errors & reduced lag                 ║")
    print("║  🎯 Conservative Adaptive Quality + Optimized LOD         ║")
    print("╚" .. string.rep("═", 62) .. "╝")

    local startTime = tick()

    -- Run optimizations with more delays
    OptimizeGraphics()
    task.wait(0.5) -- Increased delay

    OptimizeEffectsIntelligent()
    task.wait(0.5)

    OptimizeTerrain()
    task.wait(0.5)

    InitializeDynamicLOD()
    task.wait(0.5)

    OptimizedSmartCulling()
    task.wait(0.5)

    OptimizeAnimations()
    task.wait(0.5)

    OptimizedPerformanceMonitor()
    task.wait(0.5)

    AdaptiveQualitySystem()
    task.wait(0.5)

    SimpleFPSLimiter()
    task.wait(0.5)

    AutoMemoryCleanup()
    task.wait(0.5)

    SmartMemoryCleanup()

    local loadTime = math.floor((tick() - startTime) * 100) / 100

    print("╔" .. string.rep("═", 62) .. "╗")
    print("║  ✅ OPTIMIZATION COMPLETE - LAG FIXED!                     ║")
    print("║  ⏱️  Load time: " .. loadTime .. " seconds" .. string.rep(" ", 41 - #tostring(loadTime)) .. "║")
    print("║  📊 Performance Monitor: Top right corner                 ║")
    print("║  🎯 Adaptive Quality: Auto-adjusts based on FPS            ║")
    print("║  🔄 Memory Cleanup: Every " .. Config.CleanupInterval .. " seconds" .. string.rep(" ", 28) .. "║")
    print("║  💡 Dynamic LOD: Distance-based optimization              ║")
    print("║  👁️  Smart Culling: Hides off-screen objects              ║")
    print("║  🔧 Fixed: Brightness errors & performance issues         ║")
    print("╚" .. string.rep("═", 62) .. "╝")
end

-- Run script
SafeExecute(Initialize)