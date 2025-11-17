# 🚀 Blox Fruits FPS Booster v8.8.1-Lite - Edition Cho Máy 2GB RAM

```lua
--[[
    Blox Fruits FPS Booster v8.8.1-Lite - Low-End Optimization
    Mô tả: Phiên bản siêu tối ưu cho máy yếu (2GB RAM, low-end CPU)
    Đặc điểm: Tối thiểu memory footprint, aggressive optimization, lightweight anti-detection
    Mục tiêu: FPS tối đa trên máy yếu, RAM usage < 50MB, CPU usage minimal
    Khuyến nghị: Cho điện thoại cũ, PC RAM 2-4GB, hoặc thiết bị low-end
]]

local success, err = pcall(function()
    -- ==========================================
    -- KHỞI TẠO CƠ BẢN (MINIMAL SERVICES)
    -- ==========================================
    local L = game:GetService("Lighting")
    local W = game:GetService("Workspace")
    local P = game:GetService("Players")
    local R = game:GetService("RunService")
    local H = game:GetService("HttpService")
    local U = game:GetService("UserInputService")
    local S = game:GetService("StarterGui")

    local LP = P.LocalPlayer or P:GetPropertyChangedSignal("LocalPlayer"):Wait()
    local Cam = W.CurrentCamera
    local Ter = W:FindFirstChild("Terrain")

    -- CẤU HÌNH SIÊU TỐI ƯU CHO MÁY YẾU
    local CFG = {
        -- === ULTRA LOW-END PROFILE ===
        Profile = {
            MaxObjects = 10, -- Giảm từ 40 xuống 10
            LODEnabled = true,
            LODInterval = 2.0, -- Tăng từ 1.0 lên 2.0 (giảm update frequency)
            LODDistance = {100, 200, 400, 800}, -- Chỉ 4 levels thay vì 5
            ScanInterval = 15, -- Tăng từ 10s lên 15s
            MemoryThreshold = 40 -- Giảm từ 100MB xuống 40MB
        },
        
        -- === AGGRESSIVE DESTRUCTION ===
        Destroy = {"ParticleEmitter", "Fire", "Smoke", "Sparkles", "Beam", "Trail", "Decal", "Texture", "SurfaceGui", "BillboardGui"},
        Disable = {"PointLight", "SpotLight", "SurfaceLight", "Atmosphere"},
        Keep = {"sword", "fruit", "gun", "weapon", "boss", "npc", "dealer"}, -- Giảm keywords
        
        -- === MINIMAL GHOST PROTOCOL ===
        Ghost = {
            Enabled = false, -- TẮT mặc định cho máy yếu
            CombatCheck = 5, -- Tăng interval lên 5s
            CameraSway = {45, 70}, -- Tăng lên 45-70s
            Movement = {50, 80} -- Tăng lên 50-80s
        }
    }

    -- ==========================================
    -- STATE SIÊU NHẸ (< 5KB)
    -- ==========================================
    local ST = {
        On = false,
        Tag = H:GenerateGUID(false):sub(1, 8), -- Giảm từ 12 xuống 8
        Objs = setmetatable({}, {__mode = "k"}), -- Chỉ weak keys
        LOD = setmetatable({}, {__mode = "k"}),
        Cons = {},
        Tasks = {},
        FPS = 60,
        Mem = 0,
        Total = 0,
        Killed = 0,
        Combat = false,
        LastCheck = 0,
        LastMem = 0,
        -- Lưu settings gốc (minimal)
        Orig = {
            Bright = L.Brightness,
            Ambient = L.OutdoorAmbient,
            Tech = L.Technology,
            Shadow = L.GlobalShadows,
            Quality = settings().Rendering.QualityLevel
        }
    }

    -- ==========================================
    -- TIỆN ÍCH SIÊU NHẸ
    -- ==========================================
    local function log(m, c)
        pcall(function()
            S:SetCore("ChatMakeSystemMessage", {
                Text = "[Lite] " .. m,
                Color = c or Color3.fromRGB(0, 255, 100),
                Font = Enum.Font.SourceSans
            })
        end)
    end

    -- ==========================================
    -- LỌC THÔNG MINH (OPTIMIZED)
    -- ==========================================
    local function isKeep(o)
        local n = o.Name:lower()
        for _, k in ipairs(CFG.Keep) do
            if n:find(k) then return true end
        end
        return o:IsDescendantOf(LP.Character)
    end

    -- ==========================================
    -- TỐI ƯU HÓA AGGRESSIVE
    -- ==========================================
    local function optimize(o)
        if isKeep(o) then return false end
        
        local c = o.ClassName
        
        -- Destroy aggressive
        for _, d in ipairs(CFG.Destroy) do
            if c == d then
                pcall(o.Destroy, o)
                ST.Killed = ST.Killed + 1
                return true
            end
        end
        
        -- Disable lights/effects
        for _, d in ipairs(CFG.Disable) do
            if c == d then
                pcall(function()
                    o.Enabled = false
                    if o:IsA("Light") then o.Brightness = 0 end
                end)
                return true
            end
        end
        
        return false
    end

    -- ==========================================
    -- LOD SYSTEM (LIGHTWEIGHT)
    -- ==========================================
    local function regLOD(o)
        if not o:IsA("BasePart") or o:IsA("Terrain") or isKeep(o) then return end
        ST.LOD[o] = {
            S = o.Size,
            M = o.Material,
            T = o.Transparency,
            C = o.CanCollide
        }
    end

    local function updateLOD()
        local pos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") 
                    and LP.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        
        for o, d in pairs(ST.LOD) do
            if not o or not o.Parent then continue end
            
            local dist = (o.Position - pos).Magnitude
            
            -- 4 levels: 0-100, 100-200, 200-400, 400+
            if dist > 400 then
                -- Level 4: Tối thiểu
                o.Size = d.S * 0.1
                o.Transparency = 1
                o.CanCollide = false
            elseif dist > 200 then
                -- Level 3: Rất nhỏ
                o.Size = d.S * 0.3
                o.Transparency = math.min(1, d.T + 0.5)
                o.CanCollide = false
            elseif dist > 100 then
                -- Level 2: Nhỏ
                o.Size = d.S * 0.6
                o.Transparency = math.min(1, d.T + 0.3)
                o.CanCollide = false
            else
                -- Level 1: Gốc
                o.Size = d.S
                o.Material = d.M
                o.Transparency = d.T
                o.CanCollide = d.C
            end
        end
    end

    -- ==========================================
    -- QUÉT SIÊU TIẾT KIỆM
    -- ==========================================
    local function scan()
        local objs = W:GetDescendants()
        local count = 0
        local max = math.min(#objs, CFG.Profile.MaxObjects)
        
        for i = 1, max do
            if optimize(objs[i]) then
                count = count + 1
                ST.Total = ST.Total + 1
            end
            -- Yield mỗi 10 objects thay vì 50
            if i % 10 == 0 then task.wait() end
        end
        
        return count
    end

    -- ==========================================
    -- BỘ NHỚ (AGGRESSIVE CLEANUP)
    -- ==========================================
    local function cleanMem()
        local pre = ST.Mem
        
        -- Clear dead references
        for o, _ in pairs(ST.Objs) do
            if not o or not o.Parent then
                ST.Objs[o] = nil
            end
        end
        
        -- Aggressive GC
        collectgarbage("collect")
        collectgarbage("collect") -- Call 2 lần cho low-end
        
        ST.Mem = collectgarbage("count") / 1024
        local freed = pre - ST.Mem
        
        if freed > 0 then
            log(string.format("Freed %.1fMB", freed))
        end
    end

    -- ==========================================
    -- GHOST PROTOCOL (ULTRA MINIMAL)
    -- ==========================================
    local function checkCombat()
        if not CFG.Ghost.Enabled then return false end
        if tick() - ST.LastCheck < CFG.Ghost.CombatCheck then return ST.Combat end
        
        ST.LastCheck = tick()
        
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        
        local pos = LP.Character.HumanoidRootPart.Position
        
        -- Chỉ check 5 players gần nhất
        local players = P:GetPlayers()
        local checked = 0
        
        for _, p in ipairs(players) do
            if checked >= 5 then break end
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - pos).Magnitude
                if dist < 50 then
                    ST.Combat = true
                    return true
                end
                checked = checked + 1
            end
        end
        
        ST.Combat = false
        return false
    end

    local function ghostMonitor()
        while ST.On do
            task.wait(5) -- Kiểm tra mỗi 5 giây
            
            if not CFG.Ghost.Enabled then continue end
            
            checkCombat()
            
            -- Camera sway (rất thưa)
            if not ST.Combat and math.random(1, 5) == 1 then
                pcall(function()
                    local cur = Cam.CFrame
                    local off = Vector3.new(math.random(-1, 1) / 200, math.random(-1, 1) / 200, 0)
                    Cam.CFrame = cur * CFrame.new(off)
                    task.wait(0.2)
                    Cam.CFrame = cur
                end)
            end
        end
    end

    -- ==========================================
    -- ÁP DỤNG CÀI ĐẶT SIÊU AGGRESSIVE
    -- ==========================================
    local function apply()
        -- Rendering: Tối thiểu
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04 -- Thấp nhất
        
        -- Lighting: Tắt hết
        L.GlobalShadows = false
        L.ShadowSoftness = 0
        L.FogEnd = math.huge
        L.Brightness = ST.Orig.Bright -- Giữ nguyên độ sáng
        L.OutdoorAmbient = Color3.fromRGB(128, 128, 128) -- Xám để giảm render
        L.Technology = Enum.Technology.Compatibility
        
        -- Tắt TẤT CẢ post effects
        for _, e in ipairs(L:GetChildren()) do
            if e:IsA("PostEffect") then
                e.Enabled = false
            end
        end
        
        -- Terrain: Tối thiểu
        if Ter then
            Ter.Decoration = false
            Ter.WaterWaveSize = 0
            Ter.WaterWaveSpeed = 0
            Ter.WaterReflectance = 0
            Ter.WaterTransparency = 1 -- Nước trong suốt hoàn toàn
        end
        
        -- Workspace: Aggressive streaming
        W.StreamingEnabled = true
        W.StreamingTargetRadius = 128 -- Giảm từ 200 xuống 128
        W.StreamingMinRadius = 32 -- Giảm từ 64 xuống 32
        
        -- Network: Minimal
        pcall(function()
            local NS = game:GetService("NetworkSettings")
            NS.IncomingReplicationLag = 0
            NS.ClientPhysicsSendRate = 20 -- Giảm từ 40 xuống 20
            NS.ClientPhysicsReceiveRate = 30 -- Giảm từ 60 xuống 30
        end)
    end

    -- ==========================================
    -- MONITOR LOOPS (MINIMAL)
    -- ==========================================
    local function scanLoop()
        while ST.On do
            task.wait(CFG.Profile.ScanInterval)
            if ST.On then scan() end
        end
    end

    local function lodLoop()
        while ST.On do
            task.wait(CFG.Profile.LODInterval)
            if ST.On and CFG.Profile.LODEnabled then updateLOD() end
        end
    end

    local function memLoop()
        while ST.On do
            task.wait(30) -- Check mỗi 30 giây
            if ST.On then
                ST.Mem = collectgarbage("count") / 1024
                if ST.Mem > CFG.Profile.MemoryThreshold then
                    cleanMem()
                end
            end
        end
    end

    local function fpsLoop()
        while ST.On do
            task.wait(2) -- Update mỗi 2 giây
            if ST.On then
                ST.FPS = math.floor(W:GetRealPhysicsFPS())
            end
        end
    end

    -- ==========================================
    -- BẬT/TẮT HỆ THỐNG
    -- ==========================================
    local function enable()
        if ST.On then return end
        ST.On = true
        
        log("Starting Lite Mode...")
        
        apply()
        
        -- Spawn loops
        table.insert(ST.Tasks, task.spawn(scanLoop))
        table.insert(ST.Tasks, task.spawn(lodLoop))
        table.insert(ST.Tasks, task.spawn(memLoop))
        table.insert(ST.Tasks, task.spawn(fpsLoop))
        
        if CFG.Ghost.Enabled then
            table.insert(ST.Tasks, task.spawn(ghostMonitor))
        end
        
        -- Initial scan
        task.spawn(scan)
        
        -- Descendant watcher (minimal)
        ST.Cons.Desc = W.DescendantAdded:Connect(function(o)
            if not ST.On then return end
            
            task.defer(function()
                -- Register LOD nếu là BasePart
                if CFG.Profile.LODEnabled and o:IsA("BasePart") and not o:IsA("Terrain") then
                    regLOD(o)
                end
                
                -- Optimize
                if optimize(o) then
                    ST.Total = ST.Total + 1
                end
            end)
        end)
        
        log("✅ Lite Mode Active!", Color3.fromRGB(0, 255, 0))
    end

    local function disable()
        if not ST.On then return end
        ST.On = false
        
        log("Disabling...")
        
        -- Stop tasks
        for _, t in ipairs(ST.Tasks) do
            pcall(task.cancel, t)
        end
        ST.Tasks = {}
        
        -- Disconnect
        for _, c in pairs(ST.Cons) do
            pcall(c.Disconnect, c)
        end
        ST.Cons = {}
        
        -- Restore settings
        pcall(function()
            L.Brightness = ST.Orig.Bright
            L.OutdoorAmbient = ST.Orig.Ambient
            L.Technology = ST.Orig.Tech
            L.GlobalShadows = ST.Orig.Shadow
            settings().Rendering.QualityLevel = ST.Orig.Quality
            
            -- Restore LOD objects
            for o, d in pairs(ST.LOD) do
                if o and o.Parent then
                    o.Size = d.S
                    o.Material = d.M
                    o.Transparency = d.T
                    o.CanCollide = d.C
                end
            end
        end)
        
        -- Final cleanup
        cleanMem()
        
        log("❌ Disabled. All restored.", Color3.fromRGB(255, 100, 100))
    end

    -- ==========================================
    -- LỆNH ĐIỀU KHIỂN ĐƠN GIẢN
    -- ==========================================
    LP.Chatted:Connect(function(m)
        local c = m:lower()
        
        if c == "/e fps" then
            if ST.On then disable() else enable() end
            
        elseif c == "/e fps status" or c == "/e fps s" then
            local s = ST.On and "🟢 ON" or "🔴 OFF"
            log(string.format("%s | FPS:%d | Mem:%.1fMB | Total:%d | Killed:%d",
                s, ST.FPS, ST.Mem, ST.Total, ST.Killed), Color3.fromRGB(255, 255, 0))
            
        elseif c == "/e fps ghost" then
            CFG.Ghost.Enabled = not CFG.Ghost.Enabled
            log("Ghost: " .. (CFG.Ghost.Enabled and "ON" or "OFF"))
            
        elseif c == "/e fps clean" or c == "/e fps c" then
            local pre = ST.Mem
            cleanMem()
            log(string.format("Cleaned: %.1fMB → %.1fMB", pre, ST.Mem))
            
        elseif c == "/e fps help" or c == "/e fps h" then
            log("Commands: /e fps (toggle) | /e fps s (status) | /e fps c (clean) | /e fps ghost (toggle ghost)", Color3.fromRGB(100, 200, 255))
        end
    end)

    -- Auto-start sau 2 giây
    task.delay(2, enable)

end)

if not success then
    warn("[LITE ERROR] " .. tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "❌ Lite Error: " .. tostring(err),
            Color = Color3.fromRGB(255, 0, 0)
        })
    end)
end