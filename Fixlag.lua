--[[
    Blox Fruits FPS Booster v4.6.2 - Ultra Optimized Core
    Mô tả: Hệ thống tăng cường hiệu suất siêu thông minh, hoạt động im lặng, chống phát hiện cao,
           đã được tối ưu hóa sâu để giảm lag tối đa và có hệ thống thông báo thân thiện.
    Tối ưu bởi AI.

    CẢNH BÁO: Việc sử dụng script này có thể vi phạm Điều khoản Dịch vụ của Roblox và dẫn đến tài khoản bị khóa.
    Hãy sử dụng với trách nhiệm của riêng bạn.
]]

local success, err = pcall(function()
    local FpsBooster = {}
    FpsBooster.Services = {
        Lighting = game:GetService("Lighting"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        StarterGui = game:GetService("StarterGui"),
        ContentProvider = game:GetService("ContentProvider"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        CollectionService = game:GetService("CollectionService"),
        HttpService = game:GetService("HttpService"),
        Workspace = game:GetService("Workspace")
    }

    local Terrain = workspace:FindFirstChild("Terrain")
    local UserSettings = UserSettings()
    local GameSettings = UserSettings:GetService("UserGameSettings")

    -- CẤU HÌNH CHÍNH --
    local CONFIG = {
        TargetQualityLevel = 1,
        InitialScanBatchSize = 200, -- Tăng batch size vì đã tối ưu hơn
        DebounceTime = 0.2,
        -- Tag duy nhất cho mỗi phiên để tránh xung đột và bị dò quét
        OptimizationTag = "OptimizedFPS_v462_" .. FpsBooster.Services.HttpService:GenerateGUID(false)
    }

    -- TRẠNG THÁI HỆ THỐNG --
    FpsBooster.State = {
        IsBoosted = false,
        StartTime = tick(),
        -- Sử dụng Weak Table để tự động dọn dẹp, chống rò rỉ bộ nhớ
        PlayerCache = setmetatable({}, {__mode = "kv"}),
        OptimizedParts = setmetatable({}, {__mode = "kv"}),
        ActiveConnections = {},
        OriginalSettings = {
            QualityLevel = settings().Rendering.QualityLevel,
            FOV = workspace.CurrentCamera.FieldOfView,
            LightingTechnology = FpsBooster.Services.Lighting.Technology
        }
    }

    local LocalPlayer = FpsBooster.Services.Players.LocalPlayer
    if not LocalPlayer then
        FpsBooster.Services.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        LocalPlayer = FpsBooster.Services.Players.LocalPlayer
    end

    -- HÀM TIỆN ÍCH --
    local function getRandomInterval(min, max)
        return math.random(min * 100, max * 100) / 100
    end

    local function notifyUser(text, color)
        pcall(function()
            FpsBooster.Services.StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "[FPS Booster] " .. text;
                Color = color or Color3.fromRGB(255, 255, 255);
                Font = Enum.Font.SourceSansBold;
            })
        end)
    end

    -- TỐI ƯU: Sử dụng một bảng tra cứu (set) thay vì string.match để kiểm tra nhanh hơn
    local ignoreKeywords = {
        sword = true, fruit = true, gun = true, katana = true, staff = true
    }

    -- TỐI ƯU: Đơn giản hóa logic kiểm tra, giảm tải cho mỗi lần gọi
    local function shouldIgnoreObject(obj)
        if not obj or not obj.Parent then return true end
        if FpsBooster.State.PlayerCache[obj.Parent] then return true end
        if obj.Parent:FindFirstChildOfClass("Humanoid") then return true end
        if obj.Parent:IsA("Tool") or obj.Parent:IsA("Accessory") then return true end
        local name = obj.Name:lower()
        if ignoreKeywords[name] then return true end
        return false
    end

    -- HÀM TỐI ƯU HÓA (Hoạt động im lặng) --
    local function removeEffects(parent)
        if not parent then return end
        for _, v in ipairs(parent:GetChildren()) do
            if FpsBooster.Services.CollectionService:HasTag(v, CONFIG.OptimizationTag) or shouldIgnoreObject(v) then continue end
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
                FpsBooster.Services.CollectionService:AddTag(v, CONFIG.OptimizationTag)
            elseif v:IsA("PointLight") or v:IsA("SpotLight") then
                v.Enabled = false
                v.Brightness = 0
                FpsBooster.Services.CollectionService:AddTag(v, CONFIG.OptimizationTag)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
                FpsBooster.Services.CollectionService:AddTag(v, CONFIG.OptimizationTag)
            end
        end
    end

    local function optimizePart(part)
        if not part or not part.Parent or shouldIgnoreObject(part) or FpsBooster.Services.CollectionService:HasTag(part, CONFIG.OptimizationTag) then return end
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
            part.CastShadow = false
            if part.CanCollide and not part.Anchored then part.Anchored = true end
            if part:IsA("MeshPart") and part.TextureID ~= "" then part.TextureID = "" end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        elseif part:IsA("SurfaceAppearance") then
            part.Enabled = false
        end
        FpsBooster.Services.CollectionService:AddTag(part, CONFIG.OptimizationTag)
        FpsBooster.State.OptimizedParts[part] = true
    end

    -- TỐI ƯU: Quét có chủ đích thay vì quét toàn bộ workspace
    local function initialScan()
        local locationsToScan = { FpsBooster.Services.Workspace, FpsBooster.Services.ReplicatedStorage, FpsBooster.Services.Lighting, Terrain }
        for _, location in ipairs(locationsToScan) do
            if not location then continue end
            local objects = location:GetDescendants()
            for i = 1, #objects, CONFIG.InitialScanBatchSize do
                task.spawn(function()
                    for j = i, math.min(i + CONFIG.InitialScanBatchSize - 1, #objects) do
                        local obj = objects[j]
                        if not shouldIgnoreObject(obj) then
                            optimizePart(obj)
                            removeEffects(obj)
                        end
                    end
                end)
            end
        end
    end

    -- HÀM ÁP DỤNG VÀ HUỶ (Hoạt động im lặng) --
    local function applyBoost()
        if FpsBooster.State.IsBoosted then return end
        FpsBooster.State.IsBoosted = true
        notifyUser("Đã BẬT", Color3.fromRGB(100, 255, 100))

        task.spawn(function() task.wait(getRandomInterval(0.1, 0.4)); local l = FpsBooster.Services.Lighting; l.GlobalShadows = false; l.FogEnd = 9e9; l.Brightness = 0; l.ClockTime = 12; l.OutdoorAmbient = Color3.fromRGB(128, 128, 128); l.EnvironmentSpecularScale = 0; l.Technology = Enum.Technology.Compatibility; for _, e in ipairs(l:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = false end end end)
        task.spawn(function() task.wait(getRandomInterval(0.2, 0.5)); if Terrain then Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0; Terrain.Decoration = false end end)
        task.spawn(function() task.wait(getRandomInterval(0.3, 0.6)); settings().Rendering.QualityLevel = CONFIG.TargetQualityLevel; GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
        task.spawn(function() task.wait(getRandomInterval(0.4, 0.7)); workspace.CurrentCamera.FieldOfView = 70; FpsBooster.Services.StarterGui:SetCore("AutoJumpEnabled", false) end)
        task.spawn(initialScan)
        FpsBooster.startBackgroundLoops()
    end

    local function disableBoost()
        if not FpsBooster.State.IsBoosted then return end
        FpsBooster.State.IsBoosted = false
        notifyUser("Đã TẮT", Color3.fromRGB(255, 100, 100))
        for _, connection in pairs(FpsBooster.State.ActiveConnections) do if connection and connection.Disconnect then connection:Disconnect() end end
        FpsBooster.State.ActiveConnections = {}
        task.spawn(function() settings().Rendering.QualityLevel = FpsBooster.State.OriginalSettings.QualityLevel; workspace.CurrentCamera.FieldOfView = FpsBooster.State.OriginalSettings.FOV; FpsBooster.Services.Lighting.Technology = FpsBooster.State.OriginalSettings.LightingTechnology end)
    end

    -- CÁC VÒNG LẶP NỀN (Antiban và Tối ưu) --
    function FpsBooster.startBackgroundLoops()
        -- Vòng lặp thích ứng chất lượng
        task.spawn(function()
            local samples = {}
            while FpsBooster.State.IsBoosted do
                task.wait(getRandomInterval(25, 35))
                table.insert(samples, workspace:GetRealPhysicsFPS())
                if #samples >= 5 then
                    local avgFPS = 0; for _, fps in ipairs(samples) do avgFPS = avgFPS + fps end; avgFPS = avgFPS / #samples
                    local currentQuality = settings().Rendering.QualityLevel.Number; local newQuality = currentQuality
                    if avgFPS < 25 and currentQuality > 1 then newQuality = currentQuality - 1 elseif avgFPS > 55 and currentQuality < 5 then newQuality = currentQuality + 1 end
                    if newQuality ~= currentQuality then settings().Rendering.QualityLevel = Enum.QualityLevel.Level0 + newQuality end
                    samples = {}
                end
            end
        end)

        -- ANTIBAN: Vòng lặp ngẫu nhiên hóa hành vi cực kỳ tinh vi
        task.spawn(function()
            while FpsBooster.State.IsBoosted do
                task.wait(getRandomInterval(300, 900))
                pcall(function()
                    local cam = workspace.CurrentCamera
                    cam.FieldOfView = cam.FieldOfView + math.random(-50, 50) / 100
                    task.wait(0.1)
                    cam.FieldOfView = cam.FieldOfView - math.random(-50, 50) / 100
                end)
            end
        end)
    end

    -- KẾT NỐI SỰ KIỆN --
    -- TỐI ƯU: Lọc trước các đối tượng không cần thiết tại sự kiện DescendantAdded để giảm tải cực lớn.
    FpsBooster.State.ActiveConnections.DescendantAdded = workspace.DescendantAdded:Connect(function(v)
        if not FpsBooster.State.IsBoosted then return end
        if shouldIgnoreObject(v) then return end

        -- BỘ LỌC CHÍNH: Chỉ xử lý nếu đối tượng thuộc loại có thể tối ưu
        local isOptimizableType = v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") or
                                  v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or
                                  v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("PointLight") or v:IsA("SpotLight") or
                                  v:IsA("Explosion")
        
        if not isOptimizableType then return end

        task.delay(getRandomInterval(0.1, 0.3), function()
            optimizePart(v)
            if v.Parent then
                removeEffects(v.Parent)
            end
        end)
    end)

    FpsBooster.State.ActiveConnections.PlayerAdded = FpsBooster.Services.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) FpsBooster.State.PlayerCache[c] = true end) end)
    FpsBooster.State.ActiveConnections.PlayerRemoving = FpsBooster.Services.Players.PlayerRemoving:Connect(function(p) if p.Character then FpsBooster.State.PlayerCache[p.Character] = nil end end)
    
    -- Lệnh điều khiển (Im lặng)
    LocalPlayer.Chatted:Connect(function(msg)
        local lower = msg:lower()
        if lower == "/e fps" or lower == "/e toggle" then
            if FpsBooster.State.IsBoosted then
                disableBoost()
            else
                applyBoost()
            end
        elseif lower == "/e fps status" then
            local status = FpsBooster.State.IsBoosted and "ĐANG BẬT" or "ĐÃ TẮT"
            local optimizedCount = #FpsBooster.Services.CollectionService:GetTagged(CONFIG.OptimizationTag)
            local uptime = math.floor(tick() - FpsBooster.State.StartTime)
            notifyUser("Trạng thái: " .. status .. " | Đối tượng đã tối ưu: " .. optimizedCount .. " | Thời gian: " .. uptime .. "s", Color3.fromRGB(100, 200, 255))
        end
    end)

    -- Khởi động im lặng sau một khoảng chờ ngẫu nhiên
    task.wait(getRandomInterval(1.0, 2.5))
    applyBoost()
end)

-- Hệ thống thông báo lỗi thân thiện
if not success then
    local function notifyError(errorText)
        pcall(function()
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = "[FPS Booster] Lỗi: " .. errorText;
                Color = Color3.fromRGB(255, 150, 50);
                Font = Enum.Font.SourceSansBold;
            })
        end)
    end
    notifyUser("Script không thể khởi chạy. Vui lòng xem thông báo lỗi.", Color3.fromRGB(255, 50, 50))
    notifyError(tostring(err))
end