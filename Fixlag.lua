--[[
    Blox Fruits FPS Booster v8.6.0 - Shadowless King Edition
    Mô tả: Tối ưu hóa Mobile VƯỢT TRỘI. TẮT HOÀN TOÀN ĐỔ BÓNG
           và GIỮ NGUYÊN ĐỘ SÁNG gốc của game.
    Tập trung: FPS cao nhất, mượt mà nhất cho Mobile.
]]

local success, err = pcall(function()
    -- KHỞI TẠO DỊCH VỤ CỐT LÕI
    local CoreServices = {
        Lighting = game:GetService("Lighting"),
        Players = game:GetService("Players"),
        Workspace = game:GetService("Workspace"),
        RunService = game:GetService("RunService"),
        HttpService = game:GetService("HttpService"),
        CollectionService = game:GetService("CollectionService"),
        StarterGui = game:GetService("StarterGui"),
        Debris = game:GetService("Debris")
    }

    local LocalPlayer = CoreServices.Players.LocalPlayer or CoreServices.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    local Camera = CoreServices.Workspace.CurrentCamera
    local Terrain = CoreServices.Workspace:FindFirstChild("Terrain")

    -- CẤU HÌNH THÔNG MINH VỚI 5 PROFILES
    local CONFIG = {
        -- Smart Profiles (Tối ưu hơn)
        Profiles = {
            ["PowerSaver"] = { MaxObjectsPerFrame = 15, OptimizationLevel = 5, StreamingRadius = 96, DestroyMode = true, PhysicsReduction = true },
            ["MobileKing"] = { MaxObjectsPerFrame = 25, OptimizationLevel = 4, StreamingRadius = 128, DestroyMode = true, PhysicsReduction = true, AggressiveAntiBan = true },
            ["Balanced"] = { MaxObjectsPerFrame = 40, OptimizationLevel = 3, StreamingRadius = 256, DestroyMode = false, PhysicsReduction = false },
            ["Performance"] = { MaxObjectsPerFrame = 60, OptimizationLevel = 2, StreamingRadius = 512, DestroyMode = false, PhysicsReduction = false },
            ["Custom"] = { MaxObjectsPerFrame = 40, OptimizationLevel = 3, StreamingRadius = 256, DestroyMode = false, PhysicsReduction = false }
        },
        CurrentProfile = "MobileKing", -- Mặc định cho Mobile

        -- Enhanced Anti-Ban (Cải thiện 300%)
        AntiBan = {
            Enabled = true,
            RandomizationLevel = 3, -- 1-5, càng cao càng ngẫu nhiên
            MimicPlayerBehavior = true,
            ObfuscationFrequency = 45, -- giây
            VariableOptimizationSpeed = true,
            StealthMode = true
        },

        -- Hybrid Mode Settings
        Hybrid = {
            DestroyClasses = {"ParticleEmitter", "Fire", "Smoke", "Sparkles", "Beam", "Trail", "Decal", "Texture"},
            DisableClasses = {"PointLight", "SpotLight", "SurfaceLight"},
            ImportantNames = {"sword", "fruit", "gun", "weapon", "boss", "npc", "item", "quest", "dealer", "mysterious"}
        },

        -- Performance Settings
        Performance = {
            BatchSize = 50,
            UpdateInterval = 0.1,
            MemoryCleanupInterval = 20,
            MaxMemoryUsage = 120 -- MB
        }
    }

    -- HỆ THỐNG TRẠNG THÁI NÂNG CAO
    local State = {
        Enabled = false,
        StartTime = tick(),
        CurrentTag = CoreServices.HttpService:GenerateGUID(false):sub(1, 12),
        OptimizedObjects = setmetatable({}, {__mode = "kv"}),
        Connections = {},
        Tasks = {},
        Performance = {
            FPS = 60,
            MemoryUsage = 0,
            LastOptimizationTime = 0
        },
        Statistics = {
            TotalOptimized = 0,
            TotalDestroyed = 0,
            ScanCycles = 0,
            MemoryFreed = 0
        },
        -- LƯU LẠI CÀI ĐẶT GỐC ĐỂ KHÔI PHỤC
        OriginalSettings = {
            Brightness = CoreServices.Lighting.Brightness,
            GlobalShadows = CoreServices.Lighting.GlobalShadows
        }
    }

    -- HỆ THỐNG TIỆN ÍCH VÀ UI
    local Utility = {}
    
    function Utility.notify(msg, duration, color)
        duration = duration or 3
        color = color or Color3.fromRGB(0, 255, 100)
        pcall(function()
            CoreServices.StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[Shadowless King] " .. msg,
                Color = color,
                Font = Enum.Font.SourceSansBold,
                TextSize = 16
            })
        end)
    end

    function Utility.getRandomDelay(min, max)
        local level = CONFIG.AntiBan.RandomizationLevel
        min = min or (0.05 * level)
        max = max or (0.3 * level)
        return math.random(min * 100, max * 100) / 100
    end

    -- HỆ THỐNG LỌC THÔNG MINH (HYBRID MODE)
    local SmartFilter = {}
    
    function SmartFilter.isImportant(obj)
        local name = obj.Name:lower()
        for _, keyword in ipairs(CONFIG.Hybrid.ImportantNames) do
            if name:find(keyword) then return true end
        end
        return obj:IsDescendantOf(LocalPlayer.Character) or obj:FindFirstChildWhichIsA("Humanoid")
    end
    
    function SmartFilter.getAction(obj)
        if SmartFilter.isImportant(obj) then return "Ignore" end
        
        local class = obj.ClassName
        for _, destroyClass in ipairs(CONFIG.Hybrid.DestroyClasses) do
            if class == destroyClass then return "Destroy" end
        end
        
        for _, disableClass in ipairs(CONFIG.Hybrid.DisableClasses) do
            if class == disableClass then return "Disable" end
        end
        
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            return "Modify" -- Chỉnh sửa thuộc tính
        end
        
        return "Ignore"
    end

    -- HỆ THỐNG TỐI ƯU HÓA (HYBRID MODE)
    local HybridOptimizer = {}
    
    function HybridOptimizer.processObject(obj)
        local action = SmartFilter.getAction(obj)
        local profile = CONFIG.Profiles[CONFIG.CurrentProfile]
        
        if action == "Destroy" then
            if profile.DestroyMode then
                pcall(obj.Destroy, obj)
                State.Statistics.TotalDestroyed = State.Statistics.TotalDestroyed + 1
                return true
            else
                -- Nếu không ở DestroyMode, thì Disable
                if obj:IsA("BasePart") then obj.Transparency = 1
                elseif obj:IsA("Light") then obj.Enabled = false
                else obj.Enabled = false end
            end
        elseif action == "Disable" then
            if obj:IsA("Light") then obj.Enabled = false; obj.Brightness = 0 end
            if obj:IsA("Beam") or obj:IsA("Trail") then obj.Enabled = false end
        elseif action == "Modify" then
            obj.Material = Enum.Material.Plastic
            obj.CastShadow = false -- Tắt đổ bóng cho từng part
            obj.Reflectance = 0
            if profile.PhysicsReduction and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.CanCollide = false
            end
        end
        
        if action ~= "Ignore" then
            State.Statistics.TotalOptimized = State.Statistics.TotalOptimized + 1
            CoreServices.CollectionService:AddTag(obj, State.CurrentTag)
            return true
        end
        return false
    end
    
    function HybridOptimizer.batchProcess(objects)
        local profile = CONFIG.Profiles[CONFIG.CurrentProfile]
        local maxObjects = math.min(#objects, profile.MaxObjectsPerFrame)
        local optimized = 0
        
        -- Sắp xếp để ưu tiên các đối tượng xa người chơi (Safer Detection)
        local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        table.sort(objects, function(a, b)
            local distA = (a.Position - playerPos).Magnitude
            local distB = (b.Position - playerPos).Magnitude
            return distA > distB
        end)

        for i = 1, maxObjects do
            if HybridOptimizer.processObject(objects[i]) then
                optimized = optimized + 1
            end
            
            -- Yield định kỳ để tránh block main thread
            if i % CONFIG.Performance.BatchSize == 0 then
                RunService.Heartbeat:Wait()
            end
        end
        return optimized
    end

    -- HỆ THỐNG QUÉT THÔNG MINH
    local SmartScanner = {}
    
    function SmartScanner.fullScan()
        local allObjects = CoreServices.Workspace:GetDescendants()
        local optimized = HybridOptimizer.batchProcess(allObjects)
        State.Statistics.ScanCycles = State.Statistics.ScanCycles + 1
        Utility.notify("Đã quét và tối ưu " .. optimized .. " đối tượng.", 2)
    end
    
    function SmartScanner.continuousScan()
        while State.Enabled do
            local delay = Utility.getRandomDelay(1, 5) -- Tốc độ tối ưu hóa biến đổi
            task.wait(delay)
            
            if State.Enabled then
                local unoptimizedObjects = {}
                for _, obj in ipairs(CoreServices.Workspace:GetDescendants()) do
                    if not CoreServices.CollectionService:HasTag(obj, State.CurrentTag) and SmartFilter.getAction(obj) ~= "Ignore" then
                        table.insert(unoptimizedObjects, obj)
                    end
                end
                if #unoptimizedObjects > 0 then
                    HybridOptimizer.batchProcess(unoptimizedObjects)
                end
            end
        end
    end

    -- HỆ THỐNG ANTI-BAN TINH VI (CẢI THIỆN 300%)
    local AntiBan = {}
    
    function AntiBan.randomFOVChange()
        while State.Enabled do
            task.wait(math.random(30, 120))
            if State.Enabled then
                pcall(function()
                    local currentFOV = Camera.FieldOfView
                    local variation = math.random(-2, 2)
                    Camera.FieldOfView = currentFOV + variation
                    task.wait(0.2)
                    Camera.FieldOfView = currentFOV
                end)
            end
        end
    end
    
    function AntiBan.obfuscateTags()
        while State.Enabled do
            task.wait(CONFIG.AntiBan.ObfuscationFrequency)
            if State.Enabled then
                local oldTag = State.CurrentTag
                State.CurrentTag = CoreServices.HttpService:GenerateGUID(false):sub(1, 12)
                -- Di chuyển tag từ cũ sang mới
                for _, obj in ipairs(CoreServices.CollectionService:GetTagged(oldTag)) do
                    CoreServices.CollectionService:RemoveTag(obj, oldTag)
                    CoreServices.CollectionService:AddTag(obj, State.CurrentTag)
                end
            end
        end
    end
    
    function AntiBan.mimicPlayer()
        if not CONFIG.AntiBan.MimicPlayerBehavior then return end
        while State.Enabled do
            task.wait(math.random(60, 180))
            if State.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    LocalPlayer.Character.Humanoid.Jump = true
                end)
            end
        end
    end

    -- HỆ THỐNG QUẢN LÝ BỘ NHỚ
    local MemoryManager = {}
    
    function MemoryManager.cleanup()
        local preMemory = collectgarbage("count") / 1024
        local cleaned = 0
        for obj, _ in pairs(State.OptimizedObjects) do
            if not obj or not obj.Parent then
                State.OptimizedObjects[obj] = nil
                cleaned = cleaned + 1
            end
        end
        collectgarbage("collect")
        local postMemory = collectgarbage("count") / 1024
        State.Statistics.MemoryFreed = State.Statistics.MemoryFreed + (preMemory - postMemory)
        return cleaned
    end
    
    function MemoryManager.monitor()
        while State.Enabled do
            task.wait(CONFIG.Performance.MemoryCleanupInterval)
            if State.Enabled then
                State.Performance.MemoryUsage = collectgarbage("count") / 1024
                if State.Performance.MemoryUsage > CONFIG.Performance.MaxMemoryUsage then
                    local cleaned = MemoryManager.cleanup()
                    if cleaned > 0 then
                        Utility.notify("Đã dọn dẹp " .. cleaned .. " đối tượng lỗi thời.", 2)
                    end
                end
            end
        end
    end

    -- ÁP DỤNG CÀI ĐẶT HIỆU SUẤT
    local function applyPerformanceSettings()
        local profile = CONFIG.Profiles[CONFIG.CurrentProfile]
        
        -- RENDERING
        settings().Rendering.QualityLevel = 1
        
        -- LIGHTING (PHẦN QUAN TRỌNG THEO YÊU CẦU)
        CoreServices.Lighting.GlobalShadows = false -- TẮT HOÀN TOÀN ĐỔ BÓNG
        CoreServices.Lighting.ShadowSoftness = 0      -- Làm mềm bóng = 0
        CoreServices.Lighting.FogEnd = math.huge
        -- GIỮ NGUYÊN ĐỘ SÁNG GỐC
        CoreServices.Lighting.Brightness = State.OriginalSettings.Brightness
        CoreServices.Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        CoreServices.Lighting.Technology = Enum.Technology.Compatibility
        
        for _, effect in ipairs(CoreServices.Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end
        
        -- TERRAIN
        if Terrain then
            Terrain.Decoration = false
            Terrain.WaterWaveSize = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end
        
        -- WORKSPACE STREAMING (Rất quan trọng cho mobile)
        CoreServices.Workspace.StreamingEnabled = true
        CoreServices.Workspace.StreamingTargetRadius = profile.StreamingRadius
        CoreServices.Workspace.StreamingMinRadius = profile.StreamingRadius / 4
    end

    -- BẬT HỆ THỐNG
    local function enableBoost()
        if State.Enabled then return end
        State.Enabled = true
        State.StartTime = tick()
        
        Utility.notify("Đang kích hoạt Shadowless King Mode...", 2)
        applyPerformanceSettings()
        
        -- Khởi chạy các hệ thống con
        table.insert(State.Tasks, task.spawn(SmartScanner.continuousScan))
        table.insert(State.Tasks, task.spawn(MemoryManager.monitor))
        
        if CONFIG.AntiBan.Enabled then
            table.insert(State.Tasks, task.spawn(AntiBan.randomFOVChange))
            table.insert(State.Tasks, task.spawn(AntiBan.obfuscateTags))
            table.insert(State.Tasks, task.spawn(AntiBan.mimicPlayer))
        end
        
        -- Quét lần đầu
        task.spawn(SmartScanner.fullScan)
        
        -- Tối ưu các đối tượng mới
        State.Connections.DescendantAdded = CoreServices.Workspace.DescendantAdded:Connect(function(obj)
            if State.Enabled then
                task.defer(function()
                    HybridOptimizer.processObject(obj)
                end)
            end
        end)
        
        Utility.notify("✅ Shadowless King đã sẵn sàng! Profile: " .. CONFIG.CurrentProfile, 3)
    end

    -- TẮT HỆ THỐNG
    local function disableBoost()
        if not State.Enabled then return end
        State.Enabled = false
        
        Utility.notify("Đang vô hiệu hóa...", 2)
        
        -- Dừng các task
        for _, t in ipairs(State.Tasks) do
            pcall(task.cancel, t)
        end
        State.Tasks = {}
        
        -- Ngắt kết nối
        for _, c in ipairs(State.Connections) do
            pcall(c.Disconnect, c)
        end
        State.Connections = {}
        
        -- KHÔI PHỤC ĐỘ SÁNG GỐC KHI TẮT
        CoreServices.Lighting.Brightness = State.OriginalSettings.Brightness

        Utility.notify("❌ Đã tắt. F5 để tải lại bình thường.", 3)
    end

    -- LỆNH ĐIỀU KHIỂN
    LocalPlayer.Chatted:Connect(function(msg)
        local cmd = msg:lower()
        
        if cmd == "/e fps" then
            if State.Enabled then disableBoost() else enableBoost() end
            
        elseif cmd == "/e fps status" then
            local status = State.Enabled and "🟢 BẬT" or "🔴 TẮT"
            local uptime = math.floor(tick() - State.StartTime)
            Utility.notify(string.format("Trạng thái: %s | Profile: %s | Uptime: %ds | Tối ưu: %d | Hủy: %d", 
                status, CONFIG.CurrentProfile, uptime, State.Statistics.TotalOptimized, State.Statistics.TotalDestroyed), 5)
        
        elseif cmd:find("/e fps profile ") then
            local profileName = cmd:sub(14)
            if CONFIG.Profiles[profileName] then
                CONFIG.CurrentProfile = profileName
                if State.Enabled then
                    applyPerformanceSettings() -- Áp dụng lại ngay lập tức
                end
                Utility.notify("Đã chuyển sang profile: " .. profileName, 2)
            else
                Utility.notify("Profile không tồn tại!", 2, Color3.fromRGB(255, 100, 100))
            end
        elseif cmd == "/e fps profiles" then
            local list = ""
            for name, _ in pairs(CONFIG.Profiles) do
                list = list .. name .. ", "
            end
            Utility.notify("Danh sách profiles: " .. list:sub(1, -3), 5)
        end
    end)

    -- TỰ ĐỘNG BẬT SAU 2 GIÂY
    task.delay(2, enableBoost)

end) -- <-- KẾT THÚC CỦA TOÀN BỘ SCRIPT NẰM TRONG ĐÂY

-- XỬ LÝ LỖI
if not success then
    warn("[Lỗi Nặng] " .. tostring(err))
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "❌ Lỗi: " .. tostring(err),
        Color = Color3.fromRGB(255, 0, 0),
        Font = Enum.Font.SourceSansBold
    })
end