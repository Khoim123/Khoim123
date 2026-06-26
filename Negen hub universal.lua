-- ==================== 1. LOAD LIBRARY ====================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ==================== 2. SERVICES (cached) ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== 3. CREATE WINDOW & TABS ====================
local Window = Fluent:CreateWindow({
    Title = "Negen hub",
    SubTitle = "by ThanhKhoi",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "" }),
    Antiban = Window:AddTab({ Title = "Antiban", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ==================== 4. SAVE MANAGER ====================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ==================== 5. STATE VARIABLES ====================
-- Gom tất cả state vào 1 bảng, tránh nhiều biến local rải rác
local State = {
    -- Speed Hack
    SpeedEnabled = false,
    SpeedValue = 50,

    -- Noclip
    NoclipEnabled = false,
    NoclipConnection = nil,
    NoclipParts = {},       -- Cache danh sách BasePart, tránh GetDescendants mỗi frame

    -- Full Bright
    FullBrightEnabled = false,
    OriginalLighting = {},

    -- Teleport
    TeleportLocations = {},
    SelectedLocation = nil,
    TeleportMode = "Teleport",
    TweenDuration = 1,

    -- Quick Teleport
    QuickTeleportVisible = false,
    QuickTeleportButton = nil,

    -- Antiban
    AntiKick = false,
    AntiVoid = false,
    AntiTeleportDetect = false,
    AntiStatChange = false,
    AntiVoidY = -500,
    SafePosition = nil,
    SafePositionName = nil,
    AntiStatConnection = nil,
    OriginalWalkSpeed = 16,
    OriginalJumpPower = 50,
    OriginalJumpHeight = 7.2,
}

-- UI references
local LocationDropdownRef = nil
local CoordDisplayRef = nil
local TeleportNameInputRef = nil  -- sẽ gán sau khi tạo input

-- ==================== 6. UTILITY FUNCTIONS (TẤT CẢ LOCAL) ====================

--- Cache Noclip parts: chỉ gọi GetDescendants 1 lần mỗi khi character spawn
local function cacheNoclipParts(character)
    State.NoclipParts = {}
    if not character then return end
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            State.NoclipParts[#State.NoclipParts + 1] = part
        end
    end
end

--- Speed Hack
local function applySpeed(speed)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

--- Noclip: dùng cached array + ipairs, không gọi GetDescendants mỗi frame
local function startNoclip()
    if State.NoclipConnection then State.NoclipConnection:Disconnect() end
    cacheNoclipParts(player.Character)

    State.NoclipConnection = RunService.Stepped:Connect(function()
        if not State.NoclipEnabled then return end
        local parts = State.NoclipParts
        for i = 1, #parts do
            parts[i].CanCollide = false
        end
    end)
end

local function stopNoclip()
    if State.NoclipConnection then
        State.NoclipConnection:Disconnect()
        State.NoclipConnection = nil
    end
    local parts = State.NoclipParts
    for i = 1, #parts do
        parts[i].CanCollide = true
    end
end

--- Full Bright
local function enableFullBright()
    local orig = State.OriginalLighting
    orig.Brightness = Lighting.Brightness
    orig.ClockTime = Lighting.ClockTime
    orig.FogEnd = Lighting.FogEnd
    orig.FogStart = Lighting.FogStart
    orig.Ambient = Lighting.Ambient
    orig.OutdoorAmbient = Lighting.OutdoorAmbient
    orig.GlobalShadows = Lighting.GlobalShadows

    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.GlobalShadows = false
end

local function disableFullBright()
    local orig = State.OriginalLighting
    if orig.Brightness ~= nil then Lighting.Brightness = orig.Brightness end
    if orig.ClockTime ~= nil then Lighting.ClockTime = orig.ClockTime end
    if orig.FogEnd ~= nil then Lighting.FogEnd = orig.FogEnd end
    if orig.FogStart ~= nil then Lighting.FogStart = orig.FogStart end
    if orig.Ambient ~= nil then Lighting.Ambient = orig.Ambient end
    if orig.OutdoorAmbient ~= nil then Lighting.OutdoorAmbient = orig.OutdoorAmbient end
    if orig.GlobalShadows ~= nil then Lighting.GlobalShadows = orig.GlobalShadows end
end

--- Teleport Helpers
local function getLocationNames()
    local names = {}
    for name in pairs(State.TeleportLocations) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

local function updateCoordDisplay()
    if not CoordDisplayRef then return end
    local sel = State.SelectedLocation
    local pos = sel and State.TeleportLocations[sel]
    local text
    if pos then
        text = string.format("X: %.2f | Y: %.2f | Z: %.2f", pos.X, pos.Y, pos.Z)
    else
        text = "Chưa chọn vị trí"
    end
    if CoordDisplayRef.SetContent then
        CoordDisplayRef:SetContent(text)
    else
        CoordDisplayRef.Content = text
    end
end

local function refreshLocationDropdown()
    local names = getLocationNames()
    if #names == 0 then
        names[1] = "Chưa có vị trí"
        State.SelectedLocation = nil
    end
    if LocationDropdownRef then
        LocationDropdownRef.Values = names
        if LocationDropdownRef.Refresh then
            LocationDropdownRef:Refresh()
        end
        LocationDropdownRef:SetValue(names[1])
    end
    updateCoordDisplay()
end

local function doTeleport(targetPos)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Fluent:Notify({ Title = "Teleport", Content = "Không tìm thấy HumanoidRootPart!", Duration = 3 })
        return
    end

    -- Nếu Anti-TP Detect bật → luôn dùng Tween bất kể mode
    local useTween = State.TeleportMode == "Tween" or State.AntiTeleportDetect

    if useTween then
        local duration = (State.AntiTeleportDetect and not (State.TeleportMode == "Tween"))
            and math.clamp((hrp.Position - targetPos).Magnitude / 100, 0.5, 3)
            or State.TweenDuration
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { CFrame = CFrame.new(targetPos) }
        )
        tween:Play()
        Fluent:Notify({ Title = "Teleport", Content = "Đang tween trong " .. string.format("%.1f", duration) .. "s...", Duration = 3 })
    else
        hrp.CFrame = CFrame.new(targetPos)
        Fluent:Notify({ Title = "Teleport", Content = "Đã dịch chuyển tức thì!", Duration = 3 })
    end
end

-- ==================== 7. ANTIBAN FUNCTIONS ====================

--- Anti-Kick: Hook phương thức Kick, chặn server kick client-side
local function enableAntiKick()
    if State.AntiKick then return end
    State.AntiKick = true
    local mt = getrawmetatable(game)
    if mt and setreadonly then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == player then
                Fluent:Notify({ Title = "Anti-Kick", Content = "Đã chặn 1 lần kick từ server!", Duration = 5 })
                return nil
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end

--- Anti-Void: Kiểm tra Y position, teleport về an toàn khi rơi vào void
--- Tối ưu: cache HRP, skip frame (chỉ check mỗi 3 frame), tránh FindFirstChild mỗi tick
local AntiVoidConnection = nil
local cachedHRP = nil
local voidFrameCount = 0

local function cacheHRP()
    local character = player.Character
    if character then
        cachedHRP = character:FindFirstChild("HumanoidRootPart")
    else
        cachedHRP = nil
    end
end

-- Cache HRP khi character spawn
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    cachedHRP = char:WaitForChild("HumanoidRootPart", 5)
end)
cacheHRP() -- Cache ngay lần đầu

local function enableAntiVoid()
    if AntiVoidConnection then AntiVoidConnection:Disconnect() end
    voidFrameCount = 0

    AntiVoidConnection = RunService.Heartbeat:Connect(function()
        if not State.AntiVoid then return end

        -- Skip frame: chỉ check mỗi 3 tick (~20 lần/giây thay vì ~60)
        -- Đủ nhanh để bắt void, giảm 66% tải CPU trên mobile
        voidFrameCount = voidFrameCount + 1
        if voidFrameCount % 3 ~= 0 then return end

        local hrp = cachedHRP
        if not hrp then cacheHRP(); hrp = cachedHRP end
        if not hrp or not hrp.Parent then cachedHRP = nil; return end

        if hrp.Position.Y < State.AntiVoidY then
            local safePos = State.SafePosition
            if safePos then
                local tween = TweenService:Create(
                    hrp,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { CFrame = CFrame.new(safePos) }
                )
                tween:Play()
                Fluent:Notify({ Title = "Anti-Void", Content = "Đã kéo bạn về vị trí an toàn!", Duration = 3 })
            else
                hrp.CFrame = CFrame.new(0, 50, 0)
                Fluent:Notify({ Title = "Anti-Void", Content = "Đã kéo về spawn! Hãy set vị trí an toàn.", Duration = 5 })
            end
        end
    end)
end

local function disableAntiVoid()
    if AntiVoidConnection then
        AntiVoidConnection:Disconnect()
        AntiVoidConnection = nil
    end
end

--- Anti-Teleport-Detect: Buộc tất cả teleport dùng Tween thay vì set CFrame
--- Giảm nguy cơ server phát hiện dịch chuyển tức thì

--- Anti-Stat-Change: Giám sát và khôi phục giá trị nhân vật bị server sửa
local function enableAntiStatChange()
    if State.AntiStatConnection then State.AntiStatConnection:Disconnect() end

    local function monitorCharacter(character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        State.OriginalWalkSpeed = humanoid.WalkSpeed
        State.OriginalJumpPower = humanoid.JumpPower
        State.OriginalJumpHeight = humanoid.JumpHeight

        State.AntiStatConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if not State.AntiStatChange then return end
            if State.SpeedEnabled then return end  -- Bỏ qua nếu đang dùng Speed Hack
            if humanoid.WalkSpeed ~= State.OriginalWalkSpeed then
                humanoid.WalkSpeed = State.OriginalWalkSpeed
                Fluent:Notify({ Title = "Anti-Stat", Content = "Phát hiện server đổi WalkSpeed! Đã khôi phục.", Duration = 5 })
            end
        end)
    end

    -- Monitor character hiện tại
    monitorCharacter(player.Character)

    -- Monitor khi character mới spawn
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        monitorCharacter(char)
    end)
end

--- Save safe position cho Anti-Void
local function saveSafePosition()
    local character = player.Character
    if not character then
        Fluent:Notify({ Title = "Anti-Void", Content = "Không tìm thấy nhân vật!", Duration = 3 })
        return false
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        Fluent:Notify({ Title = "Anti-Void", Content = "Không tìm thấy HumanoidRootPart!", Duration = 3 })
        return false
    end
    State.SafePosition = hrp.Position
    Fluent:Notify({ Title = "Anti-Void", Content = "Đã lưu vị trí an toàn hiện tại!", Duration = 3 })
    return true
end

-- ==================== 8. MOBILE BUTTON (Tối ưu, fix click-vs-drag bug) ====================
-- Dùng threshold pixel để phân biệt drag vs tap.
-- Xử lý OnClick trực tiếp trong InputEnded, không cần MouseButton1Click.

local DRAG_THRESHOLD = 10
local DRAG_SPEED = 0.5

local function createMobileButton(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = config.GuiName
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local btn = Instance.new("ImageButton")
    btn.Name = config.ButtonName
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = config.Position
    btn.Image = config.Image
    btn.BackgroundTransparency = 1
    btn.Parent = screenGui

    if config.Corner ~= false then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = btn
    end

    -- Drag state (closure variables, truy cập nhanh hơn)
    local isDragging = false
    local dragStartPos = Vector3.zero
    local buttonStartPos = UDim2.new()
    local lastInputObj = nil
    local endConn = nil

    local function updateDragPosition(input)
        local delta = input.Position - dragStartPos
        btn.Position = UDim2.new(
            buttonStartPos.X.Scale,
            buttonStartPos.X.Offset + (delta.X * DRAG_SPEED),
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + (delta.Y * DRAG_SPEED)
        )
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        isDragging = false
        dragStartPos = input.Position
        buttonStartPos = btn.Position
        lastInputObj = input

        -- Dọn connection cũ (tránh memory leak mỗi lần touch)
        if endConn then endConn:Disconnect() end

        endConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                -- Không phải drag => đây là tap => gọi OnClick
                if not isDragging and config.OnClick then
                    config.OnClick()
                end
                lastInputObj = nil
                if endConn then endConn:Disconnect() end
                endConn = nil
            end
        end)
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end
        lastInputObj = input
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input ~= lastInputObj then return end
        if not isDragging then
            -- Kiểm tra ngưỡng: vượt 10px mới coi là drag
            if (input.Position - dragStartPos).Magnitude > DRAG_THRESHOLD then
                isDragging = true
            else
                return
            end
        end
        updateDragPosition(input)
    end)

    return btn, screenGui
end

-- ==================== 9. AUTO EVENTS ====================
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    cacheNoclipParts(char)
    if State.SpeedEnabled then applySpeed(State.SpeedValue) end
    if State.NoclipEnabled then startNoclip() end
end)

-- FullBright guard: dùng lookup table thay vì 4 lần so sánh string
local LIGHTING_WATCHED = {
    Brightness = true, Ambient = true, FogEnd = true,
    GlobalShadows = true, FogStart = true, OutdoorAmbient = true, ClockTime = true
}

Lighting.Changed:Connect(function(property)
    if State.FullBrightEnabled and LIGHTING_WATCHED[property] then
        enableFullBright()
    end
end)

-- ==================== 10. UI DEFINITIONS ====================

---------- TAB: MAIN ----------

-- Speed Hack
local SpeedSection = Tabs.Main:AddSection("Speed Hack")

local SpeedInput = SpeedSection:AddInput("SpeedInput", {
    Title = "Speed Value",
    Description = "Nhập tốc độ mong muốn (số)",
    Default = "50",
    Placeholder = "VD: 50, 100, 200",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            State.SpeedValue = num
            if State.SpeedEnabled then applySpeed(State.SpeedValue) end
        end
    end
})

SpeedSection:AddToggle("SpeedToggle", {
    Title = "Enable Speed Hack",
    Description = "Bật/Tắt tăng tốc độ di chuyển",
    Default = false,
    Callback = function(state)
        State.SpeedEnabled = state
        if State.SpeedEnabled then
            applySpeed(State.SpeedValue)
            Fluent:Notify({ Title = "Speed Hack", Content = "Đã bật! Tốc độ: " .. tostring(State.SpeedValue), Duration = 3 })
        else
            applySpeed(16)
            Fluent:Notify({ Title = "Speed Hack", Content = "Đã tắt! Tốc độ về mặc định", Duration = 3 })
        end
    end
})

SpeedInput:OnChanged(function()
    local num = tonumber(SpeedInput.Value)
    if num then
        State.SpeedValue = num
        if State.SpeedEnabled then applySpeed(State.SpeedValue) end
    end
end)

-- Noclip
local NoclipSection = Tabs.Main:AddSection("Noclip")

NoclipSection:AddToggle("NoclipToggle", {
    Title = "Enable Noclip",
    Description = "Đi xuyên tường (vật cản)",
    Default = false,
    Callback = function(state)
        State.NoclipEnabled = state
        if State.NoclipEnabled then
            startNoclip()
            Fluent:Notify({ Title = "Noclip", Content = "Đã bật! Bạn có thể đi xuyên tường", Duration = 3 })
        else
            stopNoclip()
            Fluent:Notify({ Title = "Noclip", Content = "Đã tắt! Vật cản hoạt động bình thường", Duration = 3 })
        end
    end
})

-- Teleport
local TeleportSection = Tabs.Main:AddSection("Teleport")

TeleportNameInputRef = TeleportSection:AddInput("TeleportName", {
    Title = "Tên vị trí",
    Description = "Nhập tên rồi nhấn Lưu",
    Default = "",
    Placeholder = "VD: Cửa hàng, Boss...",
    Numeric = false,
    Finished = false,
    Callback = function() end
})

TeleportSection:AddButton({
    Title = "Lưu vị trí hiện tại",
    Description = "Lưu/Ghi đè vị trí theo tên đã nhập",
    Callback = function()
        local name = TeleportNameInputRef.Value
        if name == "" or name == nil then
            Fluent:Notify({ Title = "Teleport", Content = "Vui lòng nhập tên vị trí trước!", Duration = 3 })
            return
        end
        local character = player.Character
        if not character then
            Fluent:Notify({ Title = "Teleport", Content = "Không tìm thấy nhân vật!", Duration = 3 })
            return
        end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            Fluent:Notify({ Title = "Teleport", Content = "Không tìm thấy HumanoidRootPart!", Duration = 3 })
            return
        end
        State.TeleportLocations[name] = hrp.Position
        Fluent:Notify({ Title = "Teleport", Content = "Đã lưu vị trí: " .. name, Duration = 3 })
        refreshLocationDropdown()
    end
})

LocationDropdownRef = TeleportSection:AddDropdown("LocationDropdown", {
    Title = "Chọn vị trí đã lưu",
    Description = "Chọn vị trí để dịch chuyển",
    Values = {"Chưa có vị trí"},
    Multi = false,
    Default = 1,
})

LocationDropdownRef:OnChanged(function(Value)
    if Value and Value ~= "Chưa có vị trí" then
        State.SelectedLocation = Value
    else
        State.SelectedLocation = nil
    end
    updateCoordDisplay()
end)

CoordDisplayRef = TeleportSection:AddParagraph({
    Title = "Tọa độ",
    Content = "Chưa chọn vị trí"
})

TeleportSection:AddDropdown("ModeDropdown", {
    Title = "Phương thức di chuyển",
    Description = "Chọn Teleport hoặc Tween",
    Values = {"Teleport", "Tween"},
    Multi = false,
    Default = 1,
}):OnChanged(function(Value)
    State.TeleportMode = Value
end)

local TweenDurationInput = TeleportSection:AddInput("TweenDuration", {
    Title = "Tween Duration (giây)",
    Description = "Thời gian tween (chỉ áp dụng khi chọn Tween)",
    Default = "1",
    Placeholder = "VD: 0.5, 1, 2",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            State.TweenDuration = num
        end
    end
})

TweenDurationInput:OnChanged(function()
    local num = tonumber(TweenDurationInput.Value)
    if num and num > 0 then
        State.TweenDuration = num
    end
end)

TeleportSection:AddButton({
    Title = "Di chuyển (Go)",
    Description = "Thực hiện dịch chuyển đến vị trí đã chọn",
    Callback = function()
        local sel = State.SelectedLocation
        if not sel then
            Fluent:Notify({ Title = "Teleport", Content = "Vui lòng chọn vị trí trước!", Duration = 3 })
            return
        end
        local pos = State.TeleportLocations[sel]
        if not pos then
            Fluent:Notify({ Title = "Teleport", Content = "Vị trí không tồn tại!", Duration = 3 })
            return
        end
        doTeleport(pos)
    end
})

TeleportSection:AddButton({
    Title = "Xóa vị trí",
    Description = "Xóa vị trí đang chọn trong dropdown",
    Callback = function()
        local sel = State.SelectedLocation
        if not sel then
            Fluent:Notify({ Title = "Teleport", Content = "Chưa chọn vị trí để xóa!", Duration = 3 })
            return
        end
        if State.TeleportLocations[sel] then
            State.TeleportLocations[sel] = nil
            Fluent:Notify({ Title = "Teleport", Content = "Đã xóa: " .. sel, Duration = 3 })
            State.SelectedLocation = nil
            refreshLocationDropdown()
        end
    end
})

TeleportSection:AddToggle("QuickTeleportToggle", {
    Title = "Hiện nút Tele nhanh",
    Description = "Bật để hiện nút teleport nhanh trên màn hình",
    Default = false,
    Callback = function(state)
        State.QuickTeleportVisible = state
        if State.QuickTeleportButton then
            State.QuickTeleportButton.Visible = state
        end
    end
})

---------- TAB: ANTIBAN ----------
local AntibanSection = Tabs.Antiban:AddSection("Anti-Kick")

AntibanSection:AddToggle("AntiKickToggle", {
    Title = "Anti-Kick",
    Description = "Chặn server kick (client-side). Cần hỗ trợ securecall.",
    Default = false,
    Callback = function(state)
        if state then
            local ok, err = pcall(enableAntiKick)
            if ok then
                Fluent:Notify({ Title = "Anti-Kick", Content = "Đã bật Anti-Kick!", Duration = 3 })
            else
                State.AntiKick = false
                Fluent:Notify({ Title = "Anti-Kick", Content = "Lỗi: " .. tostring(err), Duration = 5 })
            end
        else
            State.AntiKick = false
            Fluent:Notify({ Title = "Anti-Kick", Content = "Đã tắt Anti-Kick!", Duration = 3 })
        end
    end
})

local AntiVoidSection = Tabs.Antiban:AddSection("Anti-Void")

AntiVoidSection:AddToggle("AntiVoidToggle", {
    Title = "Anti-Void",
    Description = "Tự động kéo về vị trí an toàn khi rơi xuống void",
    Default = false,
    Callback = function(state)
        State.AntiVoid = state
        if State.AntiVoid then
            enableAntiVoid()
            Fluent:Notify({ Title = "Anti-Void", Content = "Đã bật! Hãy lưu vị trí an toàn.", Duration = 3 })
        else
            disableAntiVoid()
            Fluent:Notify({ Title = "Anti-Void", Content = "Đã tắt!", Duration = 3 })
        end
    end
})

AntiVoidSection:AddButton({
    Title = "Lưu vị trí an toàn",
    Description = "Lưu vị trí hiện tại làm điểm quay về khi rơi void",
    Callback = function()
        saveSafePosition()
    end
})

AntiVoidSection:AddInput("AntiVoidY", {
    Title = "Ngưỡng Void (Y)",
    Description = "Y thấp hơn giá trị này = rơi void (mặc định -500)",
    Default = "-500",
    Placeholder = "VD: -500, -1000",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then State.AntiVoidY = num end
    end
})

local AntiStatSection = Tabs.Antiban:AddSection("Anti-Stat Change")

AntiStatSection:AddToggle("AntiStatToggle", {
    Title = "Anti-Stat Change",
    Description = "Giám sát và khôi phục WalkSpeed/JumpPower khi server cố đổi",
    Default = false,
    Callback = function(state)
        State.AntiStatChange = state
        if State.AntiStatChange then
            enableAntiStatChange()
            Fluent:Notify({ Title = "Anti-Stat", Content = "Đã bật! Đang giám sát stats...", Duration = 3 })
        else
            if State.AntiStatConnection then
                State.AntiStatConnection:Disconnect()
                State.AntiStatConnection = nil
            end
            Fluent:Notify({ Title = "Anti-Stat", Content = "Đã tắt!", Duration = 3 })
        end
    end
})

local AntiTPSection = Tabs.Antiban:AddSection("Anti-Teleport Detect")

AntiTPSection:AddToggle("AntiTPDetectToggle", {
    Title = "Anti-Teleport Detection",
    Description = "Luôn dùng Tween khi teleport để tránh server phát hiện",
    Default = false,
    Callback = function(state)
        State.AntiTeleportDetect = state
        if State.AntiTeleportDetect then
            Fluent:Notify({ Title = "Anti-TP", Content = "Đã bật! Tất cả teleport sẽ dùng Tween.", Duration = 3 })
        else
            Fluent:Notify({ Title = "Anti-TP", Content = "Đã tắt!", Duration = 3 })
        end
    end
})

---------- TAB: VISUAL ----------
local VisualSection = Tabs.Visual:AddSection("Visual Effects")

VisualSection:AddToggle("FullBrightToggle", {
    Title = "Full Bright",
    Description = "Sáng toàn bộ map, bỏ sương mù/tối",
    Default = false,
    Callback = function(state)
        State.FullBrightEnabled = state
        if State.FullBrightEnabled then
            enableFullBright()
            Fluent:Notify({ Title = "Full Bright", Content = "Đã bật! Map sáng rõ", Duration = 3 })
        else
            disableFullBright()
            Fluent:Notify({ Title = "Full Bright", Content = "Đã tắt! Ánh sáng về mặc định", Duration = 3 })
        end
    end
})

-- ==================== 11. MOBILE BUTTONS ====================

-- Nút 1: Toggle Ẩn/Hiện GUI — tái sử dụng createMobileButton
local isGuiVisible = true

createMobileButton({
    GuiName = "FluentMobileToggle",
    ButtonName = "FluentToggleBtn",
    Position = UDim2.new(0, 20, 0, 60),
    Image = "rbxassetid://108674032232259",
    Corner = true,
    OnClick = function()
        isGuiVisible = not isGuiVisible
        if Window and Window.Root then
            Window.Root.Visible = isGuiVisible
        end
    end
})

-- Nút 2: Quick Teleport (mặc định ẨN)
State.QuickTeleportButton = createMobileButton({
    GuiName = "QuickTeleportGui",
    ButtonName = "QuickTeleportBtn",
    Position = UDim2.new(1, -70, 0, 60),
    Image = "rbxassetid://77216267068730",
    Corner = false,
    OnClick = function()
        local sel = State.SelectedLocation
        if not sel then
            Fluent:Notify({ Title = "Quick Teleport", Content = "Chưa chọn vị trí trong GUI!", Duration = 3 })
            return
        end
        local pos = State.TeleportLocations[sel]
        if not pos then
            Fluent:Notify({ Title = "Quick Teleport", Content = "Vị trí không tồn tại!", Duration = 3 })
            return
        end
        doTeleport(pos)
    end
})

State.QuickTeleportButton.Visible = false