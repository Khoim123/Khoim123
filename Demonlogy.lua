-- ============================================================
-- Ghost Info ESP - v4.00 Mobile Ultra (FIXED + Aimbot + SpeedHack)
-- Changelog v4.00:
--   + Speed Hack (toggle + textbox nhập tốc độ, re-apply khi respawn)
--   + GUI redesign rộng hơn (460x560), pill tab + sliding indicator
--   + TweenService cho hover & tab switch mượt hơn
--   + Section labels + UI gradients cho depth
--   + Hover effects trên tất cả button
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Chờ Character load trước
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local function getSafeGui()
    return (gethui and gethui()) or game:GetService("CoreGui")
end

local CONFIG = {
    MaxDistance = 1000,
    UpdateInterval = 0.2,
    AutoEscapeSpeed = 2,
    AutoEscapeCooldown = 3,
    -- AIMBOT SETTINGS
    AimbotSmooth = 1,   -- 0 = snap tức thì, 1 = không di chuyển (lerp factor = 1 - AimbotSmooth)
    AimbotHeight = 0,     -- Offset dọc (vd: 1 = aim đầu ma, -1 = aim chân)
    AimbotFOV = 360,      -- Chỉ aim nếu ma trong góc nhìn (độ), 360 = luôn aim
}

-- ===================== UTILITY =====================
local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end
local function stroke(parent, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(255,0,0)
    s.Thickness = th or 1
    s.Parent = parent
    return s
end
local function getStroke(obj)
    return obj:FindFirstChildOfClass("UIStroke")
end
-- Gradient helper (vertical by default)
local function gradient(parent, colorTop, colorBottom, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colorTop, colorBottom)
    g.Rotation = rot or 90
    g.Parent = parent
    return g
end
-- Padding helper
local function padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end
-- Smooth hover tween helper (color tween)
local function addHover(btn, normalColor, hoverColor, enterColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = enterColor or normalColor
        }):Play()
    end)
end
-- Smooth size tween on press (mobile-friendly feedback)
local function addPressScale(btn, normalSize, pressedSize)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = pressedSize
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = normalSize
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        if btn.Active then
            TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = normalSize
            }):Play()
        end
    end)
end

-- ===================== FULL BRIGHT =====================
local fullBrightActive = false
local savedLighting = {}
local function setFullBright(active)
    if active then
        savedLighting.Brightness = Lighting.Brightness
        savedLighting.Ambient = Lighting.Ambient
        savedLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        savedLighting.ClockTime = Lighting.ClockTime
        savedLighting.TimeOfDay = Lighting.TimeOfDay
        savedLighting.GlobalShadows = Lighting.GlobalShadows
        savedLighting.FogEnd = Lighting.FogEnd
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.ClockTime = 14
        Lighting.TimeOfDay = "14:00:00"
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        for k,v in pairs(savedLighting) do Lighting[k] = v end
    end
end

-- ===================== SAVE / TELEPORT =====================
local savedPositions = {nil,nil,nil}
local savedStatus = {false,false,false}
local function savePosition(slot)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    savedPositions[slot] = root.CFrame
    savedStatus[slot] = true
    return true
end
local function teleportToPosition(slot)
    local cf = savedPositions[slot]
    if not cf then return false end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = cf
    return true
end

-- ===================== ESP CORE =====================
local espFolder = Instance.new("Folder")
espFolder.Name = "GhostESP"
espFolder.Parent = getSafeGui()
local espActive, espOrbActive = true, true
local espCache, ghostList, distCache, speedCache = {}, {}, {}, {}
local pendingGhosts, attributeConnections, connections = {}, {}, {}

-- ===================== ROOM CACHE =====================
local roomCache = {}
local function rebuildRoomCache()
    for k in pairs(roomCache) do roomCache[k]=nil end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name~="" then
            local key = obj.Name:lower()
            roomCache[key] = roomCache[key] or {}
            table.insert(roomCache[key], obj)
        end
    end
end
rebuildRoomCache()
workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name~="" then
        local key = obj.Name:lower()
        roomCache[key] = roomCache[key] or {}
        table.insert(roomCache[key], obj)
    end
end)
workspace.DescendantRemoving:Connect(function(obj)
    if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
    local key = obj.Name:lower()
    local arr = roomCache[key]
    if not arr then return end
    local i=1
    while i<=#arr do
        if arr[i]==obj then table.remove(arr,i) else i=i+1 end
    end
    if #arr==0 then roomCache[key]=nil end
end)

-- ===================== GHOST FUNCTIONS =====================
local function getGhostPart(ghost)
    if not ghost or not ghost.Parent then return nil, false end
    
    local attr = ghost:GetAttribute("GhostPosition")
    if attr and typeof(attr)=="Vector3" then
        local fp = ghost:FindFirstChild("_GhostFakePart")
        if not fp or not fp:IsA("Part") then
            if fp then fp:Destroy() end
            fp = Instance.new("Part")
            fp.Name = "_GhostFakePart"; fp.Size = Vector3.one*0.5
            fp.Transparency = 1; fp.CanCollide = false; fp.Anchored = true
            fp.Parent = ghost
        end
        fp.Position = attr
        return fp, true
    end
    if ghost:IsA("BasePart") then return ghost, false end
    if ghost:IsA("Model") then
        local p = ghost:FindFirstChild("HumanoidRootPart") or ghost.PrimaryPart or ghost:FindFirstChildWhichIsA("BasePart")
        if p then return p, false end
    end
    return nil, false
end

local function isGhostObj(obj)
    if not obj or not obj.Parent then return false, nil end
    if obj:IsA("Model") and obj:GetAttribute("IsGhost")==true then return true, "ghost" end
    if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name=="GhostOrb" then return true, "orb" end
    return false, nil
end

local function createESP(ghost, objType)
    if espCache[ghost] then
        local d = espCache[ghost]
        if d.bb then pcall(function() d.bb:Destroy() end) end
        if d.hl then pcall(function() d.hl:Destroy() end) end
        espCache[ghost]=nil
    end
    local primary, isFake = getGhostPart(ghost)
    if not primary then
        if ghost:IsA("Model") then pendingGhosts[ghost]=objType end
        return nil
    end
    pendingGhosts[ghost]=nil

    local bb = Instance.new("BillboardGui")
    bb.Adornee = primary; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,120,0,75)
    bb.StudsOffset = Vector3.new(0,4,0)
    bb.Parent = espFolder

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(10,10,10)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = bb
    corner(bg,10); stroke(bg,Color3.fromRGB(255,0,0),1.5)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,0,0.33,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = objType=="orb" and "🟠 Orb" or "👻 Ghost"
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextScaled = true
    nameLbl.TextStrokeTransparency = 0.5
    nameLbl.Parent = bg

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1,0,0.33,0); distLbl.Position = UDim2.new(0,0,0.33,0)
    distLbl.BackgroundTransparency = 1; distLbl.Text = "0m"
    distLbl.TextColor3 = Color3.fromRGB(255,215,0)
    distLbl.Font = Enum.Font.GothamBold; distLbl.TextScaled = true
    distLbl.TextStrokeTransparency = 0.5
    distLbl.Parent = bg

    local spdLbl = Instance.new("TextLabel")
    spdLbl.Size = UDim2.new(1,0,0.34,0); spdLbl.Position = UDim2.new(0,0,0.66,0)
    spdLbl.BackgroundTransparency = 1; spdLbl.Text = "0.0 m/s"
    spdLbl.TextColor3 = Color3.fromRGB(0,255,255)
    spdLbl.Font = Enum.Font.GothamBold; spdLbl.TextScaled = true
    spdLbl.TextStrokeTransparency = 0.5
    spdLbl.Parent = bg

    local hl = nil
    if objType=="ghost" then
        hl = Instance.new("Highlight")
        hl.Adornee = ghost; hl.FillColor = Color3.fromRGB(255,0,0)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = espFolder
    end

    local data = {bb=bb, hl=hl, distLabel=distLbl, speedLabel=spdLbl, type=objType, isFake=isFake}
    espCache[ghost] = data
    data.bb.Enabled = (objType=="ghost" and espActive) or (objType=="orb" and espOrbActive)
    if hl then data.hl.Enabled = espActive end
    return data
end

local function removeESP(ghost)
    local d = espCache[ghost]
    if d then
        pcall(function() if d.bb then d.bb:Destroy() end end)
        pcall(function() if d.hl then d.hl:Destroy() end end)
        espCache[ghost]=nil
    end
    distCache[ghost]=nil; speedCache[ghost]=nil; pendingGhosts[ghost]=nil
    local fp = nil
    pcall(function() fp = ghost:FindFirstChild("_GhostFakePart") end)
    if fp then pcall(function() fp:Destroy() end) end
    local conn = attributeConnections[ghost]
    if conn then pcall(function() conn:Disconnect() end); attributeConnections[ghost]=nil end
end

local function onGhostAdded(obj, objType)
    if ghostList[obj] then return end
    ghostList[obj]=true; createESP(obj,objType)
end
local function onGhostRemoved(obj)
    ghostList[obj]=nil; removeESP(obj)
end

-- ===================== TELEPORT ROOMS =====================
local function getClosestGhost()
    local best, bestDist = nil, math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rp = root.Position
    for obj in pairs(ghostList) do
        local d = espCache[obj]
        if d and d.type=="ghost" then
            local p = getGhostPart(obj)
            if p and p.Parent then
                local diff = rp-p.Position
                local dist = diff:Dot(diff)
                if dist < bestDist then bestDist=dist; best=obj end
            end
        end
    end
    return best
end

local function findRoomPos(name)
    if not name or name=="" or name=="--" then return nil end
    local key = name:lower()
    local arr = roomCache[key]
    if arr then
        for _,obj in ipairs(arr) do
            if obj:IsA("BasePart") then return obj.Position end
            if obj:IsA("Model") then
                local p = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then return p.Position end
            end
        end
    end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower():find(key,1,true) then
            if obj:IsA("BasePart") then return obj.Position end
            if obj:IsA("Model") then
                local p = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then return p.Position end
            end
        end
    end
    return nil
end

local function tpToCurrentRoom()
    local g = getClosestGhost()
    if not g then warn("[GhostESP] Không tìm thấy ghost"); return false end
    local room = g:GetAttribute("CurrentRoom")
    local pos = findRoomPos(room)
    if not pos then warn("[GhostESP] Không tìm thấy phòng: "..tostring(room)); return false end
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if r then r.CFrame = CFrame.new(pos+Vector3.new(0,3,0)) end
    return true
end
local function tpToFavRoom()
    local g = getClosestGhost()
    if not g then warn("[GhostESP] Không tìm thấy ghost"); return false end
    local room = g:GetAttribute("FavoriteRoom")
    local pos = findRoomPos(room)
    if not pos then warn("[GhostESP] Không tìm thấy phòng: "..tostring(room)); return false end
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if r then r.CFrame = CFrame.new(pos+Vector3.new(0,3,0)) end
    return true
end

-- ===================== FAV ROOM ESP =====================
local favRoomActive = false
local favRoomESP = nil
local function updateFavRoomESP()
    if not favRoomActive then
        if favRoomESP then
            pcall(function() favRoomESP.bb:Destroy() end)
            pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
            favRoomESP=nil
        end
        return
    end
    local g = getClosestGhost()
    if not g then
        if favRoomESP then
            pcall(function() favRoomESP.bb:Destroy() end)
            pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
            favRoomESP=nil
        end
        return
    end
    local fav = g:GetAttribute("FavoriteRoom")
    if not fav or fav=="" or fav=="--" then return end
    local objs = roomCache[fav:lower()]
    if not objs or #objs==0 then return end
    local roomObj = objs[1]
    if not roomObj or not roomObj.Parent then
        rebuildRoomCache(); return
    end
    if favRoomESP and favRoomESP.target==roomObj and favRoomESP.bb and favRoomESP.bb.Parent then return end
    if favRoomESP then
        pcall(function() favRoomESP.bb:Destroy() end)
        pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
    end
    local adornee = roomObj:IsA("BasePart") and roomObj or (roomObj:FindFirstChild("HumanoidRootPart") or roomObj.PrimaryPart or roomObj:FindFirstChildWhichIsA("BasePart"))
    if not adornee then return end
    local bb = Instance.new("BillboardGui")
    bb.Adornee = adornee; bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,150,0,40); bb.StudsOffset = Vector3.new(0,2,0)
    bb.Parent = getSafeGui()
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(1,0,1,0); fr.BackgroundColor3 = Color3.fromRGB(0,100,200)
    fr.BackgroundTransparency = 0.3; fr.BorderSizePixel = 0
    fr.Parent = bb; corner(fr,8); stroke(fr,Color3.fromRGB(0,200,255),1.5)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = "🏠 "..fav; lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.GothamBold; lbl.TextScaled = true
    lbl.Parent = fr
    local hl = nil
    if roomObj:IsA("BasePart") or roomObj:FindFirstChildWhichIsA("BasePart") then
        hl = Instance.new("Highlight")
        hl.Adornee = roomObj; hl.FillColor = Color3.fromRGB(0,150,255)
        hl.OutlineColor = Color3.new(1,1,1); hl.FillTransparency = 0.6
        hl.Parent = getSafeGui()
    end
    favRoomESP = {bb=bb, hl=hl, target=roomObj}
end

-- ===================== ATTRIBUTE TRACKING =====================
local function setupAttrTrack(model)
    if not model:IsA("Model") or attributeConnections[model] then return end
    local function check()
        if model:GetAttribute("IsGhost")==true then
            local ig, tp = isGhostObj(model)
            if ig then onGhostAdded(model,tp) end
        elseif ghostList[model] then onGhostRemoved(model) end
    end
    check()
    local conn = model:GetAttributeChangedSignal("IsGhost"):Connect(function()
        if model and model.Parent then check() else
            pcall(function() conn:Disconnect() end)
            attributeConnections[model]=nil
        end
    end)
    attributeConnections[model]=conn
    table.insert(connections, conn)
end

-- ===================== INIT SCAN =====================
for _,obj in ipairs(workspace:GetDescendants()) do
    local ig, tp = isGhostObj(obj)
    if ig then onGhostAdded(obj,tp) elseif obj:IsA("Model") then setupAttrTrack(obj) end
end
table.insert(connections, workspace.DescendantAdded:Connect(function(obj)
    local ig, tp = isGhostObj(obj)
    if ig then onGhostAdded(obj,tp) end
    if obj:IsA("Model") then setupAttrTrack(obj) end
end))
table.insert(connections, workspace.DescendantRemoving:Connect(function(obj)
    if isGhostObj(obj) or ghostList[obj] then onGhostRemoved(obj) end
end))

-- ===================== SPEED HACK (forward declarations + core) =====================
-- These must be declared before the GUI section because the TextBox FocusLost
-- handler closes over them as upvalues.
local speedHackActive   = false
local speedHackValue    = 50
local defaultWalkSpeed  = 16

local function applySpeedHack()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if speedHackActive then
        hum.WalkSpeed = speedHackValue
    else
        -- Restore to a sensible default (Roblox default WalkSpeed is 16)
        hum.WalkSpeed = defaultWalkSpeed
    end
end

-- Re-apply speed hack whenever the character respawns (WalkSpeed resets each spawn)
LocalPlayer.CharacterAdded:Connect(function()
    -- Wait a frame so Humanoid is fully ready
    task.wait(0.2)
    applySpeedHack()
end)

-- ===================== GUI (v4.0 redesigned) =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GhostInfoGui"; screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = getSafeGui()

-- Color palette (modern dark + red accent)
local C_BG_TOP    = Color3.fromRGB(20, 20, 26)
local C_BG_BOT    = Color3.fromRGB(10, 10, 14)
local C_HEADER    = Color3.fromRGB(28, 28, 36)
local C_PANEL     = Color3.fromRGB(22, 22, 28)
local C_PANEL_HI  = Color3.fromRGB(32, 32, 40)
local C_STROKE    = Color3.fromRGB(255, 60, 60)
local C_STROKE_DIM= Color3.fromRGB(70, 70, 80)
local C_TEXT      = Color3.fromRGB(245, 245, 248)
local C_TEXT_DIM  = Color3.fromRGB(160, 160, 170)
local C_GOLD      = Color3.fromRGB(255, 215, 0)
local C_ON_GREEN  = Color3.fromRGB(0, 180, 90)
local C_OFF_RED   = Color3.fromRGB(160, 30, 30)

-- Mini frame (slightly larger, with gradient)
local miniFrame = Instance.new("Frame")
miniFrame.Size = UDim2.new(0,62,0,62)
miniFrame.Position = UDim2.new(0,10,0.3,0)
miniFrame.BackgroundColor3 = C_BG_TOP
miniFrame.BackgroundTransparency = 0.02
miniFrame.BorderSizePixel = 0; miniFrame.Active = true
miniFrame.Visible = true; miniFrame.Parent = screenGui
corner(miniFrame,14); stroke(miniFrame,C_STROKE,1.5)
gradient(miniFrame, C_BG_TOP, C_BG_BOT, 90)

local ava = Instance.new("ImageLabel")
ava.Size = UDim2.new(1,-8,1,-8); ava.Position = UDim2.new(0,4,0,4)
ava.BackgroundTransparency = 1
ava.Image = "rbxassetid://108674032232259"
ava.Parent = miniFrame; corner(ava,11)

local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(1,0,1,0); expandBtn.BackgroundTransparency = 1
expandBtn.Text = ""; expandBtn.AutoButtonColor = false
expandBtn.Parent = miniFrame

-- Main frame (wider 460, taller 560, gradient bg)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,460,0,560)
mainFrame.Position = UDim2.new(0,10,0.3,0)
mainFrame.BackgroundColor3 = C_BG_TOP
mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderSizePixel = 0; mainFrame.Active = true
mainFrame.Parent = screenGui
corner(mainFrame,14); stroke(mainFrame,C_STROKE,1.5)
gradient(mainFrame, C_BG_TOP, C_BG_BOT, 90)

-- Header (taller, with gradient + bottom border accent)
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,48)
header.BackgroundColor3 = C_HEADER
header.BorderSizePixel = 0; header.Active = true
header.Parent = mainFrame; corner(header,14)
gradient(header, Color3.fromRGB(36, 36, 44), Color3.fromRGB(22, 22, 28), 90)
local hf = Instance.new("Frame")
hf.Size = UDim2.new(1,-24,0,1); hf.Position = UDim2.new(0,12,1,-1)
hf.BackgroundColor3 = C_STROKE; hf.BorderSizePixel = 0
hf.BackgroundTransparency = 0.4
hf.Parent = header

local tit = Instance.new("TextLabel")
tit.Size = UDim2.new(0,200,0,28); tit.Position = UDim2.new(0,16,0,4)
tit.BackgroundTransparency = 1; tit.Text = "👻 GHOST INFO"
tit.TextColor3 = C_TEXT; tit.Font = Enum.Font.GothamBlack
tit.TextSize = 17; tit.TextXAlignment = Enum.TextXAlignment.Left
tit.Parent = header

local subtit = Instance.new("TextLabel")
subtit.Size = UDim2.new(0,200,0,14); subtit.Position = UDim2.new(0,16,0,32)
subtit.BackgroundTransparency = 1; subtit.Text = "v4.0 • ESP + Aimbot + SpeedHack"
subtit.TextColor3 = C_TEXT_DIM; subtit.Font = Enum.Font.Gotham
subtit.TextSize = 9; subtit.TextXAlignment = Enum.TextXAlignment.Left
subtit.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,36,0,32); minBtn.Position = UDim2.new(1,-88,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48); minBtn.Text = "—"
minBtn.TextColor3 = C_TEXT; minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16; minBtn.BorderSizePixel = 0; minBtn.Parent = header
corner(minBtn,7); stroke(minBtn,Color3.fromRGB(80,80,90),1)
addHover(minBtn, Color3.fromRGB(40,40,48), Color3.fromRGB(60,60,72))

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,36,0,32); closeBtn.Position = UDim2.new(1,-44,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48); closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,100,100); closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13; closeBtn.BorderSizePixel = 0; closeBtn.Parent = header
corner(closeBtn,7); stroke(closeBtn,Color3.fromRGB(80,80,90),1)
addHover(closeBtn, Color3.fromRGB(40,40,48), Color3.fromRGB(120,30,30))

-- Info Panel (taller, better padding, gradient bg)
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(1,-24,0,112); infoPanel.Position = UDim2.new(0,12,0,56)
infoPanel.BackgroundColor3 = C_PANEL
infoPanel.BorderSizePixel = 0; infoPanel.Parent = mainFrame
corner(infoPanel,10); stroke(infoPanel,C_STROKE_DIM,1)
gradient(infoPanel, C_PANEL_HI, C_PANEL, 90)
padding(infoPanel, 4, 4, 6, 6)

local function mkRow(y,icon,label)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,-12,0,24); r.Position = UDim2.new(0,6,0,y)
    r.BackgroundTransparency = 1; r.Parent = infoPanel
    local ib = Instance.new("Frame")
    ib.Size = UDim2.new(0,24,0,24); ib.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    ib.BorderSizePixel = 0; ib.Parent = r; corner(ib,6); stroke(ib,Color3.fromRGB(60,60,72),1)
    local il = Instance.new("TextLabel")
    il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
    il.Text = icon; il.TextColor3 = C_TEXT
    il.Font = Enum.Font.GothamBold; il.TextSize = 12; il.Parent = ib
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0,120,1,0); lb.Position = UDim2.new(0,30,0,0)
    lb.BackgroundTransparency = 1; lb.Text = label
    lb.TextColor3 = C_TEXT_DIM; lb.Font = Enum.Font.Gotham
    lb.TextSize = 11; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Parent = r
    local cl = Instance.new("TextLabel")
    cl.Size = UDim2.new(0,8,1,0); cl.Position = UDim2.new(0,150,0,0)
    cl.BackgroundTransparency = 1; cl.Text = ":"
    cl.TextColor3 = Color3.fromRGB(120,120,130); cl.Font = Enum.Font.Gotham
    cl.TextSize = 11; cl.Parent = r
    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(1,-165,1,0); vl.Position = UDim2.new(0,162,0,0)
    vl.BackgroundTransparency = 1; vl.Text = "--"
    vl.TextColor3 = C_GOLD; vl.Font = Enum.Font.GothamBold
    vl.TextSize = 11; vl.TextXAlignment = Enum.TextXAlignment.Left; vl.Parent = r
    return vl
end

local tuoiVal = mkRow(4,"📅","Tuổi")
local gioiTinhVal = mkRow(30,"⚧","Giới tính")
local phongYTVal = mkRow(56,"🏠","Phòng thích")
local phongDOVal = mkRow(82,"📁","Phòng hiện tại")

-- Tab bar (pill style with sliding indicator)
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,-24,0,36); tabBar.Position = UDim2.new(0,12,0,176)
tabBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
tabBar.BorderSizePixel = 0; tabBar.Parent = mainFrame
corner(tabBar,10); stroke(tabBar,C_STROKE_DIM,1)

-- Sliding indicator (animated pill behind active tab)
local tabIndicator = Instance.new("Frame")
tabIndicator.Size = UDim2.new(0.33,-6,0,28); tabIndicator.Position = UDim2.new(0,3,0,4)
tabIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
tabIndicator.BorderSizePixel = 0; tabIndicator.Parent = tabBar
corner(tabIndicator,8)
gradient(tabIndicator, Color3.fromRGB(80, 80, 95), Color3.fromRGB(50, 50, 62), 90)

local function mkTabBtn(text, x, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(w,-2,0,28); b.Position = UDim2.new(x,2,0,4)
    b.BackgroundTransparency = 1
    b.Text = text; b.TextColor3 = C_TEXT
    b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.BorderSizePixel = 0
    b.Parent = tabBar; corner(b,8)
    b.AutoButtonColor = false
    return b
end

local tab1Btn = mkTabBtn("⚙️ FUNCTIONS", 0, 0.33)
local tab2Btn = mkTabBtn("💾 SLOTS", 0.33, 0.33)
local tab3Btn = mkTabBtn("🚪 ROOMS", 0.66, 0.34)

-- ScrollingFrame (wider, taller for new layout)
local function mkScrollParent()
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1,-24,0,318); sc.Position = UDim2.new(0,12,0,220)
    sc.BackgroundColor3 = C_PANEL
    sc.BorderSizePixel = 0; sc.ScrollBarThickness = 6
    sc.ScrollBarImageColor3 = C_STROKE
    sc.ScrollBarImageTransparency = 0.3
    sc.ScrollingDirection = Enum.ScrollingDirection.Y
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.CanvasSize = UDim2.new(0,0,0,0)
    sc.Parent = mainFrame
    corner(sc,10); stroke(sc,C_STROKE_DIM,1)
    gradient(sc, C_PANEL_HI, C_PANEL, 90)
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,6); list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = sc
    padding(sc, 6, 6, 6, 6)
    return sc
end

local tab1Content = mkScrollParent()
local tab2Content = mkScrollParent(); tab2Content.Visible = false
local tab3Content = mkScrollParent(); tab3Content.Visible = false

-- Section label helper for tab content
local function mkSectionLabel(parent, text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-8,0,18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C_GOLD
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = parent
    return lbl
end

-- Toggle row builder (wider, with hover on toggle button)
local function mkToggle(parent, icon, title, desc, on, layoutOrder)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-8,0,56); row.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    row.BackgroundTransparency = 0.4
    row.LayoutOrder = layoutOrder; row.Parent = parent
    corner(row,8); stroke(row, C_STROKE_DIM, 1)
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0,32,0,32); ic.Position = UDim2.new(0,8,0,12)
    ic.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    ic.BorderSizePixel = 0; ic.Parent = row; corner(ic,7)
    stroke(ic, Color3.fromRGB(60,60,72), 1)
    ic.Text = icon; ic.TextColor3 = C_TEXT
    ic.Font = Enum.Font.GothamBold; ic.TextSize = 18
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0,200,0,18); tl.Position = UDim2.new(0,48,0,10)
    tl.BackgroundTransparency = 1; tl.Text = title
    tl.TextColor3 = C_TEXT; tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = row
    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(0,220,0,14); dl.Position = UDim2.new(0,48,0,28)
    dl.BackgroundTransparency = 1; dl.Text = desc
    dl.TextColor3 = C_TEXT_DIM; dl.Font = Enum.Font.Gotham
    dl.TextSize = 9; dl.TextXAlignment = Enum.TextXAlignment.Left; dl.Parent = row
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,72,0,32); btn.Position = UDim2.new(1,-82,0,12)
    btn.BackgroundColor3 = on and C_ON_GREEN or C_OFF_RED
    btn.Text = on and "ON" or "OFF"; btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.BorderSizePixel = 0
    btn.Parent = row; corner(btn,7)
    local st = stroke(btn, on and Color3.fromRGB(0,230,120) or Color3.fromRGB(220,60,60),1)
    btn.AutoButtonColor = false
    return btn, st, row
end

-- ============ TAB 1: Functions ============
mkSectionLabel(tab1Content, "🔹 ESP & VISUAL", 0)
local ghostToggleBtn, ghostStrokeObj = mkToggle(tab1Content, "👻", "Ghost ESP", "Highlight + Billboard cho ma", true, 1)
local orbToggleBtn, orbStrokeObj = mkToggle(tab1Content, "🟠", "Orb ESP", "Đánh dấu orb trên map", true, 2)
local brightToggleBtn, brightStrokeObj = mkToggle(tab1Content, "☀️", "Full Bright", "Tăng độ sáng tối đa", false, 3)
local favToggleBtn, favStrokeObj = mkToggle(tab1Content, "🏠", "FavRoom ESP", "Hiển thị phòng yêu thích", false, 4)

mkSectionLabel(tab1Content, "⚡ MOVEMENT & AIM", 10)
-- SPEED HACK (toggle + textbox)
local speedToggleBtn, speedStrokeObj, speedRow = mkToggle(tab1Content, "💨", "Speed Hack", "Tăng tốc độ di chuyển", false, 11)
-- Replace the desc position to make room for input
-- Speed textbox
local speedInputLbl = Instance.new("TextLabel")
speedInputLbl.Size = UDim2.new(0,40,0,16); speedInputLbl.Position = UDim2.new(1,-180,0,20)
speedInputLbl.BackgroundTransparency = 1; speedInputLbl.Text = "Speed:"
speedInputLbl.TextColor3 = C_TEXT_DIM; speedInputLbl.Font = Enum.Font.GothamBold
speedInputLbl.TextSize = 10; speedInputLbl.TextXAlignment = Enum.TextXAlignment.Right
speedInputLbl.Parent = speedRow

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0,46,0,22); speedInput.Position = UDim2.new(1,-136,0,17)
speedInput.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
speedInput.Text = "50"; speedInput.TextColor3 = C_TEXT
speedInput.Font = Enum.Font.GothamBold; speedInput.TextSize = 12
speedInput.BorderSizePixel = 0; speedInput.PlaceholderText = "16-500"
speedInput.PlaceholderColor3 = Color3.fromRGB(120,120,130)
speedInput.TextXAlignment = Enum.TextXAlignment.Center
speedInput.Parent = speedRow; corner(speedInput,5)
local speedInputStroke = stroke(speedInput, Color3.fromRGB(80,80,100), 1)

-- Speed input focus/blur feedback
speedInput.Focused:Connect(function()
    TweenService:Create(speedInputStroke, TweenInfo.new(0.15), {
        Color = C_STROKE, Thickness = 1.5
    }):Play()
end)
speedInput.FocusLost:Connect(function(enterPressed)
    TweenService:Create(speedInputStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(80,80,100), Thickness = 1
    }):Play()
    local n = tonumber(speedInput.Text)
    if n then
        speedHackValue = math.clamp(math.floor(n), 1, 500)
        speedInput.Text = tostring(speedHackValue)
        if speedHackActive then applySpeedHack() end
    else
        speedInput.Text = tostring(speedHackValue)
    end
end)

local aimbotToggleBtn, aimbotStrokeObj = mkToggle(tab1Content, "🎯", "Ghost Aimbot", "Camera tự ngắm ma gần nhất", false, 12)
local miniToggleBtn, miniStrokeObj = mkToggle(tab1Content, "🎛️", "Always Show Mini", "Luôn hiện nút mini", true, 13)

-- Auto Escape row
mkSectionLabel(tab1Content, "🛡️ AUTO ESCAPE", 20)
local aeRow = Instance.new("Frame")
aeRow.Size = UDim2.new(1,-8,0,72); aeRow.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
aeRow.BackgroundTransparency = 0.4
aeRow.LayoutOrder = 21; aeRow.Parent = tab1Content
corner(aeRow,8); stroke(aeRow, C_STROKE_DIM, 1)

local aeIcon = Instance.new("TextLabel")
aeIcon.Size = UDim2.new(0,32,0,32); aeIcon.Position = UDim2.new(0,8,0,8)
aeIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
aeIcon.BorderSizePixel = 0; aeIcon.Parent = aeRow; corner(aeIcon,7)
stroke(aeIcon, Color3.fromRGB(60,60,72), 1)
aeIcon.Text = "⚡"; aeIcon.TextColor3 = C_TEXT
aeIcon.Font = Enum.Font.GothamBold; aeIcon.TextSize = 18

local aeTitle = Instance.new("TextLabel")
aeTitle.Size = UDim2.new(0,180,0,18); aeTitle.Position = UDim2.new(0,48,0,8)
aeTitle.BackgroundTransparency = 1; aeTitle.Text = "Auto Escape"
aeTitle.TextColor3 = C_TEXT; aeTitle.Font = Enum.Font.GothamBold
aeTitle.TextSize = 12; aeTitle.TextXAlignment = Enum.TextXAlignment.Left; aeTitle.Parent = aeRow

local aeDesc = Instance.new("TextLabel")
aeDesc.Size = UDim2.new(0,220,0,14); aeDesc.Position = UDim2.new(0,48,0,28)
aeDesc.BackgroundTransparency = 1; aeDesc.Text = "TP về slot khi ma > 2 m/s"
aeDesc.TextColor3 = C_TEXT_DIM; aeDesc.Font = Enum.Font.Gotham
aeDesc.TextSize = 9; aeDesc.TextXAlignment = Enum.TextXAlignment.Left; aeDesc.Parent = aeRow

local escapeToggleBtn = Instance.new("TextButton")
escapeToggleBtn.Size = UDim2.new(0,72,0,32); escapeToggleBtn.Position = UDim2.new(1,-82,0,8)
escapeToggleBtn.BackgroundColor3 = C_OFF_RED
escapeToggleBtn.Text = "OFF"; escapeToggleBtn.TextColor3 = C_TEXT
escapeToggleBtn.Font = Enum.Font.GothamBold; escapeToggleBtn.TextSize = 12
escapeToggleBtn.BorderSizePixel = 0; escapeToggleBtn.Parent = aeRow
escapeToggleBtn.AutoButtonColor = false
corner(escapeToggleBtn,7)
local escapeToggleStroke = stroke(escapeToggleBtn, Color3.fromRGB(220,60,60),1)

local slLabel = Instance.new("TextLabel")
slLabel.Size = UDim2.new(0,40,0,14); slLabel.Position = UDim2.new(0,48,0,46)
slLabel.BackgroundTransparency = 1; slLabel.Text = "Escape Slot:"
slLabel.TextColor3 = C_TEXT_DIM; slLabel.Font = Enum.Font.GothamBold
slLabel.TextSize = 10; slLabel.TextXAlignment = Enum.TextXAlignment.Left; slLabel.Parent = aeRow

local slot1Btn = Instance.new("TextButton")
slot1Btn.Size = UDim2.new(0,38,0,22); slot1Btn.Position = UDim2.new(0,128,0,42)
slot1Btn.BackgroundColor3 = Color3.fromRGB(0,120,200); slot1Btn.Text = "1"
slot1Btn.TextColor3 = C_TEXT; slot1Btn.Font = Enum.Font.GothamBold
slot1Btn.TextSize = 12; slot1Btn.BorderSizePixel = 0; slot1Btn.Parent = aeRow
slot1Btn.AutoButtonColor = false
corner(slot1Btn,5)
local slot1Stroke = stroke(slot1Btn,Color3.fromRGB(0,200,255),1)

local slot2Btn = Instance.new("TextButton")
slot2Btn.Size = UDim2.new(0,38,0,22); slot2Btn.Position = UDim2.new(0,170,0,42)
slot2Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); slot2Btn.Text = "2"
slot2Btn.TextColor3 = C_TEXT; slot2Btn.Font = Enum.Font.GothamBold
slot2Btn.TextSize = 12; slot2Btn.BorderSizePixel = 0; slot2Btn.Parent = aeRow
slot2Btn.AutoButtonColor = false
corner(slot2Btn,5)
local slot2Stroke = stroke(slot2Btn,Color3.fromRGB(100,100,100),1)

local slot3Btn = Instance.new("TextButton")
slot3Btn.Size = UDim2.new(0,38,0,22); slot3Btn.Position = UDim2.new(0,212,0,42)
slot3Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); slot3Btn.Text = "3"
slot3Btn.TextColor3 = C_TEXT; slot3Btn.Font = Enum.Font.GothamBold
slot3Btn.TextSize = 12; slot3Btn.BorderSizePixel = 0; slot3Btn.Parent = aeRow
slot3Btn.AutoButtonColor = false
corner(slot3Btn,5)
local slot3Stroke = stroke(slot3Btn,Color3.fromRGB(100,100,100),1)

-- ============ TAB 2: Save Slots + Hotkey Settings ============
mkSectionLabel(tab2Content, "💾 SAVE SLOTS", 0)
local function mkSlotRow(parent, slotNum)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-8,0,64); row.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    row.BackgroundTransparency = 0.4
    row.LayoutOrder = slotNum; row.Parent = parent
    corner(row,8); stroke(row, C_STROKE_DIM, 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0,80,0,32); lbl.Position = UDim2.new(0,10,0,16)
    lbl.BackgroundTransparency = 1; lbl.Text = "SLOT "..slotNum
    lbl.TextColor3 = C_GOLD; lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl.Parent = row
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0,150,0,18); st.Position = UDim2.new(0,90,0,23)
    st.BackgroundTransparency = 1; st.Text = ""
    st.TextColor3 = Color3.fromRGB(100,255,100); st.Font = Enum.Font.Gotham
    st.TextSize = 10; st.TextXAlignment = Enum.TextXAlignment.Left; st.Parent = row
    local sv = Instance.new("TextButton")
    sv.Size = UDim2.new(0,100,0,38); sv.Position = UDim2.new(1,-208,0,13)
    sv.BackgroundColor3 = Color3.fromRGB(0,120,200); sv.Text = "💾 Save"
    sv.TextColor3 = C_TEXT; sv.Font = Enum.Font.GothamBold
    sv.TextSize = 13; sv.BorderSizePixel = 0; sv.Parent = row
    sv.AutoButtonColor = false
    corner(sv,7); stroke(sv, Color3.fromRGB(0,200,255), 1)
    addHover(sv, Color3.fromRGB(0,120,200), Color3.fromRGB(0,150,240))
    local tp = Instance.new("TextButton")
    tp.Size = UDim2.new(0,100,0,38); tp.Position = UDim2.new(1,-104,0,13)
    tp.BackgroundColor3 = Color3.fromRGB(200,100,0); tp.Text = "📍 Tele"
    tp.TextColor3 = C_TEXT; tp.Font = Enum.Font.GothamBold
    tp.TextSize = 13; tp.BorderSizePixel = 0; tp.Parent = row
    tp.AutoButtonColor = false
    corner(tp,7); stroke(tp, Color3.fromRGB(255,150,50), 1)
    addHover(tp, Color3.fromRGB(200,100,0), Color3.fromRGB(240,140,30))
    return {save=sv, tele=tp, status=st}
end

local slotRows = {}
for i=1,3 do slotRows[i] = mkSlotRow(tab2Content, i) end

-- Hotkey Settings
mkSectionLabel(tab2Content, "⚡ HOTKEY SETTINGS", 10)
local hkSettingsFrame = Instance.new("Frame")
hkSettingsFrame.Size = UDim2.new(1,-8,0,140)
hkSettingsFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
hkSettingsFrame.BackgroundTransparency = 0.4
hkSettingsFrame.LayoutOrder = 11; hkSettingsFrame.Parent = tab2Content
corner(hkSettingsFrame,8); stroke(hkSettingsFrame, C_STROKE_DIM, 1)
padding(hkSettingsFrame, 8, 8, 8, 8)

local function mkHkToggle(parent, y, icon, label, on, onclickRef)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-16,0,32); row.Position = UDim2.new(0,8,0,y)
    row.BackgroundTransparency = 1; row.Parent = parent
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0,28,0,28); ic.Position = UDim2.new(0,0,0,2)
    ic.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    ic.BorderSizePixel = 0; ic.Parent = row; corner(ic,6)
    stroke(ic, Color3.fromRGB(60,60,72), 1)
    ic.Text = icon; ic.TextColor3 = C_TEXT
    ic.Font = Enum.Font.GothamBold; ic.TextSize = 16
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0,160,0,28); lb.Position = UDim2.new(0,34,0,2)
    lb.BackgroundTransparency = 1; lb.Text = label
    lb.TextColor3 = C_TEXT; lb.Font = Enum.Font.GothamBold
    lb.TextSize = 11; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.Parent = row
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,68,0,28); btn.Position = UDim2.new(1,-76,0,2)
    btn.BackgroundColor3 = on and C_ON_GREEN or C_OFF_RED
    btn.Text = on and "ON" or "OFF"; btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.BorderSizePixel = 0; btn.Parent = row
    btn.AutoButtonColor = false
    corner(btn,6)
    local st = stroke(btn, on and Color3.fromRGB(0,230,120) or Color3.fromRGB(220,60,60),1)
    return btn, st, row
end

local showHkBtn, showHkStroke = mkHkToggle(hkSettingsFrame, 8, "👁️", "Show Hotkey", true)
local lockHkBtn, lockHkStroke = mkHkToggle(hkSettingsFrame, 44, "🔒", "Lock Position", false)

-- Hotkey Slot Selector row
local hkSlotRow = Instance.new("Frame")
hkSlotRow.Size = UDim2.new(1,-16,0,32); hkSlotRow.Position = UDim2.new(0,8,0,84)
hkSlotRow.BackgroundTransparency = 1; hkSlotRow.Parent = hkSettingsFrame

local hkSlotIcon = Instance.new("TextLabel")
hkSlotIcon.Size = UDim2.new(0,28,0,28); hkSlotIcon.Position = UDim2.new(0,0,0,2)
hkSlotIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
hkSlotIcon.BorderSizePixel = 0; hkSlotIcon.Parent = hkSlotRow; corner(hkSlotIcon,6)
stroke(hkSlotIcon, Color3.fromRGB(60,60,72), 1)
hkSlotIcon.Text = "🎯"; hkSlotIcon.TextColor3 = C_TEXT
hkSlotIcon.Font = Enum.Font.GothamBold; hkSlotIcon.TextSize = 16

local hkSlotLbl = Instance.new("TextLabel")
hkSlotLbl.Size = UDim2.new(0,120,0,28); hkSlotLbl.Position = UDim2.new(0,34,0,2)
hkSlotLbl.BackgroundTransparency = 1; hkSlotLbl.Text = "Hotkey Slot:"
hkSlotLbl.TextColor3 = C_TEXT; hkSlotLbl.Font = Enum.Font.GothamBold
hkSlotLbl.TextSize = 11; hkSlotLbl.TextXAlignment = Enum.TextXAlignment.Left
hkSlotLbl.Parent = hkSlotRow

local function mkSlotBtn(x, num, active)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,38,0,28); b.Position = UDim2.new(1,-128 + (x-1)*40,0,2)
    b.BackgroundColor3 = active and Color3.fromRGB(0,120,200) or Color3.fromRGB(50, 50, 60)
    b.Text = num; b.TextColor3 = C_TEXT
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.BorderSizePixel = 0
    b.Parent = hkSlotRow; corner(b,5); b.AutoButtonColor = false
    local s = stroke(b, active and Color3.fromRGB(0,200,255) or Color3.fromRGB(100,100,100), 1)
    return b, s
end

local hkSlot1, hkSlot1Stroke = mkSlotBtn(1, "1", true)
local hkSlot2, hkSlot2Stroke = mkSlotBtn(2, "2", false)
local hkSlot3, hkSlot3Stroke = mkSlotBtn(3, "3", false)

-- ============ TAB 3: Teleport Rooms ============
mkSectionLabel(tab3Content, "🚪 TELEPORT TO ROOM", 0)
local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1,-8,0,120); tpFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
tpFrame.BackgroundTransparency = 0.4
tpFrame.LayoutOrder = 1; tpFrame.Parent = tab3Content
corner(tpFrame,8); stroke(tpFrame, C_STROKE_DIM, 1)
padding(tpFrame, 10, 10, 10, 10)

local curRoomBtn = Instance.new("TextButton")
curRoomBtn.Size = UDim2.new(1,0,0,42); curRoomBtn.Position = UDim2.new(0,0,0,8)
curRoomBtn.BackgroundColor3 = Color3.fromRGB(0,150,150)
curRoomBtn.Text = "🏠  Teleport to Current Room"
curRoomBtn.TextColor3 = C_TEXT; curRoomBtn.Font = Enum.Font.GothamBold
curRoomBtn.TextSize = 13; curRoomBtn.BorderSizePixel = 0; curRoomBtn.Parent = tpFrame
curRoomBtn.AutoButtonColor = false
corner(curRoomBtn,8); stroke(curRoomBtn,Color3.fromRGB(0,220,220),1)
addHover(curRoomBtn, Color3.fromRGB(0,150,150), Color3.fromRGB(0,190,190))

local favRoomBtn = Instance.new("TextButton")
favRoomBtn.Size = UDim2.new(1,0,0,42); favRoomBtn.Position = UDim2.new(0,0,0,58)
favRoomBtn.BackgroundColor3 = Color3.fromRGB(200,80,120)
favRoomBtn.Text = "❤️  Teleport to Favorite Room"
favRoomBtn.TextColor3 = C_TEXT; favRoomBtn.Font = Enum.Font.GothamBold
favRoomBtn.TextSize = 13; favRoomBtn.BorderSizePixel = 0; favRoomBtn.Parent = tpFrame
favRoomBtn.AutoButtonColor = false
corner(favRoomBtn,8); stroke(favRoomBtn,Color3.fromRGB(255,130,170),1)
addHover(favRoomBtn, Color3.fromRGB(200,80,120), Color3.fromRGB(230,110,150))

-- Drag hint (bottom of main frame)
local dragText = Instance.new("TextLabel")
dragText.Size = UDim2.new(1,0,0,18); dragText.Position = UDim2.new(0,0,1,-22)
dragText.BackgroundTransparency = 1; dragText.Text = "⬌  Kéo thả để di chuyển GUI  ⬌"
dragText.TextColor3 = Color3.fromRGB(110,110,120); dragText.Font = Enum.Font.Gotham
dragText.TextSize = 10; dragText.Parent = mainFrame


-- ===================== MOBILE HOTKEY FRAME =====================
local hotkeyFrame = Instance.new("Frame")
hotkeyFrame.Name = "MobileHotkey"
hotkeyFrame.Size = UDim2.new(0, 80, 0, 80)
hotkeyFrame.Position = UDim2.new(1, -90, 1, -100)
hotkeyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
hotkeyFrame.BackgroundTransparency = 0.05
hotkeyFrame.BorderSizePixel = 0
hotkeyFrame.Active = true
hotkeyFrame.ZIndex = 10
hotkeyFrame.Parent = screenGui
corner(hotkeyFrame, 14)
local hotkeyFrameStroke = stroke(hotkeyFrame, Color3.fromRGB(255, 60, 60), 1.5)

local hotkeyTeleBtn = Instance.new("TextButton")
hotkeyTeleBtn.Size = UDim2.new(1, -8, 1, -8)
hotkeyTeleBtn.Position = UDim2.new(0, 4, 0, 4)
hotkeyTeleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
hotkeyTeleBtn.Text = "🚀\nTELE"
hotkeyTeleBtn.TextColor3 = Color3.new(1, 1, 1)
hotkeyTeleBtn.Font = Enum.Font.GothamBold
hotkeyTeleBtn.TextSize = 14
hotkeyTeleBtn.BorderSizePixel = 0
hotkeyTeleBtn.ZIndex = 11
hotkeyTeleBtn.Parent = hotkeyFrame
corner(hotkeyTeleBtn, 12)
stroke(hotkeyTeleBtn, Color3.fromRGB(255, 150, 50), 1)

-- ===================== LOGIC =====================
local autoEscapeActive, autoEscapeSlot, lastEscapeTime = false, 1, 0
local hotkeySlot = 1
local hotkeyVisible = true
local hotkeyLocked = false
-- FIX: Đổi mặc định Always Show Mini thành true
local alwaysShowMini = true
local isExpanded = true
local aimbotActive = false
local currentClosestGhost = nil 

local function updateSlotStatus()
    for i=1,3 do
        if savedStatus[i] then
            local cf = savedPositions[i]
            if cf then
                local p = cf.Position
                slotRows[i].status.Text = string.format("✓ (%.0f,%.0f,%.0f)", p.X, p.Y, p.Z)
            else
                slotRows[i].status.Text = "✓ Saved"
            end
        else
            slotRows[i].status.Text = ""
        end
    end
end

local function setGhostESP(active)
    espActive = active
    for _,d in pairs(espCache) do
        if d.type=="ghost" then
            d.bb.Enabled = active
            if d.hl then d.hl.Enabled = active end
        end
    end
    ghostToggleBtn.Text = active and "ON" or "OFF"
    ghostToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    ghostStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
end
local function setOrbESP(active)
    espOrbActive = active
    for _,d in pairs(espCache) do
        if d.type=="orb" then d.bb.Enabled = active end
    end
    orbToggleBtn.Text = active and "ON" or "OFF"
    orbToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    orbStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
end
local function setBright(active)
    setFullBright(active); fullBrightActive = active
    brightToggleBtn.Text = active and "ON" or "OFF"
    brightToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    brightStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
end
local function setFav(active)
    favRoomActive = active
    favToggleBtn.Text = active and "ON" or "OFF"
    favToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    favStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
    if not active and favRoomESP then
        pcall(function() favRoomESP.bb:Destroy() end)
        pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
        favRoomESP = nil
    end
end

local function updateEscapeSlot()
    local btnList = {slot1Btn, slot2Btn, slot3Btn}
    local strokeList = {slot1Stroke, slot2Stroke, slot3Stroke}
    for i=1,3 do
        if i==autoEscapeSlot then
            btnList[i].BackgroundColor3 = Color3.fromRGB(0,120,200)
            strokeList[i].Color = Color3.fromRGB(0,200,255)
        else
            btnList[i].BackgroundColor3 = Color3.fromRGB(60,60,70)
            strokeList[i].Color = Color3.fromRGB(100,100,100)
        end
    end
end

local function setAutoEscape(active)
    autoEscapeActive = active
    escapeToggleBtn.Text = active and "ON" or "OFF"
    escapeToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    escapeToggleStroke.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
end

local function updateHotkeySlotUI()
    local btnList = {hkSlot1, hkSlot2, hkSlot3}
    local strokeList = {hkSlot1Stroke, hkSlot2Stroke, hkSlot3Stroke}
    for i=1,3 do
        if i==hotkeySlot then
            btnList[i].BackgroundColor3 = Color3.fromRGB(0,120,200)
            strokeList[i].Color = Color3.fromRGB(0,200,255)
        else
            btnList[i].BackgroundColor3 = Color3.fromRGB(60,60,70)
            strokeList[i].Color = Color3.fromRGB(100,100,100)
        end
    end
end

local function setHotkeyVisible(active)
    hotkeyVisible = active
    hotkeyFrame.Visible = active
    showHkBtn.Text = active and "ON" or "OFF"
    showHkBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    showHkStroke.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
end

local function setHotkeyLocked(active)
    hotkeyLocked = active
    lockHkBtn.Text = active and "ON" or "OFF"
    lockHkBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    lockHkStroke.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
    if active then
        hotkeyFrameStroke.Color = Color3.fromRGB(255, 150, 50)
    else
        hotkeyFrameStroke.Color = Color3.fromRGB(255, 60, 60)
    end
end

local function setAlwaysShowMini(active)
    alwaysShowMini = active
    miniToggleBtn.Text = active and "ON" or "OFF"
    miniToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    miniStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
    if active then
        miniFrame.Visible = true
    else
        if isExpanded then
            miniFrame.Visible = false
        end
    end
end

local function setAimbot(active)
    aimbotActive = active
    aimbotToggleBtn.Text = active and "ON" or "OFF"
    aimbotToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    aimbotStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
    if active then
        print("[GhostESP] 🎯 Aimbot ON - camera sẽ auto-aim vào ma gần nhất")
    else
        print("[GhostESP] 🎯 Aimbot OFF")
    end
end

local function setSpeedHack(active)
    speedHackActive = active
    speedToggleBtn.Text = active and "ON" or "OFF"
    speedToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0,140,60) or Color3.fromRGB(160,30,30)
    speedStrokeObj.Color = active and Color3.fromRGB(0,200,100) or Color3.fromRGB(220,60,60)
    applySpeedHack()
    if active then
        print("[GhostESP] 💨 Speed Hack ON - WalkSpeed = "..tostring(speedHackValue))
    else
        print("[GhostESP] 💨 Speed Hack OFF - WalkSpeed = "..tostring(defaultWalkSpeed))
    end
end

-- Khởi tạo trạng thái UI mặc định
setAlwaysShowMini(alwaysShowMini)

-- Connections Tab 1
table.insert(connections, ghostToggleBtn.MouseButton1Click:Connect(function() setGhostESP(not espActive) end))
table.insert(connections, orbToggleBtn.MouseButton1Click:Connect(function() setOrbESP(not espOrbActive) end))
table.insert(connections, brightToggleBtn.MouseButton1Click:Connect(function() setBright(not fullBrightActive) end))
table.insert(connections, favToggleBtn.MouseButton1Click:Connect(function() setFav(not favRoomActive) end))
table.insert(connections, escapeToggleBtn.MouseButton1Click:Connect(function() setAutoEscape(not autoEscapeActive) end))
table.insert(connections, miniToggleBtn.MouseButton1Click:Connect(function() setAlwaysShowMini(not alwaysShowMini) end))
table.insert(connections, aimbotToggleBtn.MouseButton1Click:Connect(function() setAimbot(not aimbotActive) end))
table.insert(connections, speedToggleBtn.MouseButton1Click:Connect(function() setSpeedHack(not speedHackActive) end))
table.insert(connections, slot1Btn.MouseButton1Click:Connect(function() autoEscapeSlot=1; updateEscapeSlot() end))
table.insert(connections, slot2Btn.MouseButton1Click:Connect(function() autoEscapeSlot=2; updateEscapeSlot() end))
table.insert(connections, slot3Btn.MouseButton1Click:Connect(function() autoEscapeSlot=3; updateEscapeSlot() end))

-- Tab 2
table.insert(connections, hkSlot1.MouseButton1Click:Connect(function() hotkeySlot=1; updateHotkeySlotUI() end))
table.insert(connections, hkSlot2.MouseButton1Click:Connect(function() hotkeySlot=2; updateHotkeySlotUI() end))
table.insert(connections, hkSlot3.MouseButton1Click:Connect(function() hotkeySlot=3; updateHotkeySlotUI() end))
table.insert(connections, showHkBtn.MouseButton1Click:Connect(function() setHotkeyVisible(not hotkeyVisible) end))
table.insert(connections, lockHkBtn.MouseButton1Click:Connect(function() setHotkeyLocked(not hotkeyLocked) end))

for i=1,3 do
    table.insert(connections, slotRows[i].save.MouseButton1Click:Connect(function()
        if savePosition(i) then savedStatus[i]=true; updateSlotStatus() end
    end))
    table.insert(connections, slotRows[i].tele.MouseButton1Click:Connect(function() teleportToPosition(i) end))
end

-- Tab 3
table.insert(connections, curRoomBtn.MouseButton1Click:Connect(tpToCurrentRoom))
table.insert(connections, favRoomBtn.MouseButton1Click:Connect(tpToFavRoom))

-- Hotkey Teleport
table.insert(connections, hotkeyTeleBtn.MouseButton1Click:Connect(function()
    if teleportToPosition(hotkeySlot) then
        hotkeyTeleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.delay(0.25, function()
            if hotkeyTeleBtn and hotkeyTeleBtn.Parent then
                hotkeyTeleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            end
        end)
    else
        hotkeyTeleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        hotkeyTeleBtn.Text = "❌\nEMPTY"
        task.delay(0.6, function()
            if hotkeyTeleBtn and hotkeyTeleBtn.Parent then
                hotkeyTeleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                hotkeyTeleBtn.Text = "🚀\nTELE"
            end
        end)
    end
end))

-- Tab switch (with sliding indicator tween for smoothness)
local function switchTab(n)
    tab1Content.Visible = n==1; tab2Content.Visible = n==2; tab3Content.Visible = n==3
    local btns = {tab1Btn, tab2Btn, tab3Btn}
    for i,b in ipairs(btns) do
        b.TextColor3 = (i==n) and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,190)
    end
    -- Slide the indicator pill
    local targetX = (n==1) and 0 or (n==2) and 0.33 or 0.66
    TweenService:Create(tabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(targetX, 3, 0, 4)
    }):Play()
    if n==2 then updateSlotStatus() end
end
table.insert(connections, tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end))
table.insert(connections, tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end))
table.insert(connections, tab3Btn.MouseButton1Click:Connect(function() switchTab(3) end))

-- Minimize / Expand (with smooth pop-in tweens)
local function minimize()
    isExpanded = false
    miniFrame.Position = mainFrame.Position
    mainFrame.Visible = false
    miniFrame.Visible = true
    -- Smooth pop-in for mini (start small, bounce to full size)
    miniFrame.Size = UDim2.new(0, 40, 0, 40)
    TweenService:Create(miniFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 62, 0, 62)
    }):Play()
end
local function expand()
    isExpanded = true
    mainFrame.Position = miniFrame.Position
    mainFrame.Visible = true
    if not alwaysShowMini then
        miniFrame.Visible = false
    end
    -- Smooth pop-in for main (start slightly smaller, grow to full size)
    mainFrame.Size = UDim2.new(0, 440, 0, 540)
    TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 460, 0, 560)
    }):Play()
end
local function toggleFromMini()
    if alwaysShowMini then
        isExpanded = not isExpanded
        mainFrame.Visible = isExpanded
    else
        if isExpanded then
            minimize()
        else
            expand()
        end
    end
end
table.insert(connections, minBtn.MouseButton1Click:Connect(minimize))
table.insert(connections, expandBtn.MouseButton1Click:Connect(toggleFromMini))

-- ===================== DRAG LOGIC =====================
local dragFrame2, dragStart2, startPos2
table.insert(connections, header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragFrame2 = mainFrame; dragStart2 = input.Position; startPos2 = mainFrame.Position
    end
end))
table.insert(connections, miniFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragFrame2 = miniFrame; dragStart2 = input.Position; startPos2 = miniFrame.Position
    end
end))
table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragFrame2 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart2
        dragFrame2.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset+delta.X, startPos2.Y.Scale, startPos2.Y.Offset+delta.Y)
    end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragFrame2 = nil
    end
end))

-- ===================== DRAG HOTKEY (PIXEL PERFECT) =====================
local hkDragging, hkDragStart, hkStartPixelX, hkStartPixelY
local DRAG_DEADZONE = 6
local HK_ORIGINAL_SIZE = hotkeyFrame.Size

local function isPointInHotkey(pos)
    local absPos = hotkeyFrame.AbsolutePosition
    local absSize = hotkeyFrame.AbsoluteSize
    return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X
       and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
end

local function clampToScreen(px, py, size)
    local sw = size.X.Offset
    local sh = size.Y.Offset
    local vw = workspace.CurrentCamera.ViewportSize.X
    local vh = workspace.CurrentCamera.ViewportSize.Y
    px = math.clamp(px, 0, math.max(0, vw - sw))
    py = math.clamp(py, 0, math.max(0, vh - sh))
    return px, py
end

local function setHotkeyDragging(active)
    if active then
        hotkeyFrame:TweenSize(
            UDim2.new(0, HK_ORIGINAL_SIZE.X.Offset * 0.92, 0, HK_ORIGINAL_SIZE.Y.Offset * 0.92),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.08, true
        )
        hotkeyFrameStroke.Color = Color3.fromRGB(255, 220, 80)
        hotkeyFrameStroke.Thickness = 3
        hotkeyTeleBtn.Active = false
    else
        hotkeyFrame:TweenSize(HK_ORIGINAL_SIZE, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        if hotkeyLocked then
            hotkeyFrameStroke.Color = Color3.fromRGB(255, 150, 50)
        else
            hotkeyFrameStroke.Color = Color3.fromRGB(255, 60, 60)
        end
        hotkeyFrameStroke.Thickness = 1.5
        hotkeyTeleBtn.Active = true
    end
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input)
    if hotkeyLocked then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not isPointInHotkey(input.Position) then return end

    hkDragging = false
    hkDragStart = input.Position
    hkStartPixelX = hotkeyFrame.AbsolutePosition.X
    hkStartPixelY = hotkeyFrame.AbsolutePosition.Y
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if not hkDragStart then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local delta = (input.Position - hkDragStart).Magnitude
    if not hkDragging then
        if delta > DRAG_DEADZONE then
            hkDragging = true
            setHotkeyDragging(true)
        else
            return
        end
    end

    local dx = input.Position.X - hkDragStart.X
    local dy = input.Position.Y - hkDragStart.Y
    local newX = hkStartPixelX + dx
    local newY = hkStartPixelY + dy
    local cx, cy = clampToScreen(newX, newY, hotkeyFrame.Size)
    hotkeyFrame.Position = UDim2.new(0, cx, 0, cy)
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not hkDragStart then return end

    if hkDragging then
        setHotkeyDragging(false)
    end
    hkDragging = false
    hkDragStart = nil
end))
-- ===================== MAIN LOOP =====================
local function update()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local rp = root.Position
    local now = tick()

    for g,t in pairs(pendingGhosts) do
        if g and g.Parent then createESP(g,t) else pendingGhosts[g]=nil end
    end

    for k in pairs(distCache) do distCache[k]=nil end

    local closestGhost, closestDist = nil, math.huge
    for obj in pairs(ghostList) do
        local primary, isFake = getGhostPart(obj)
        if primary and primary.Parent then
            if isFake then primary.Position = obj:GetAttribute("GhostPosition") or primary.Position end
            local cp = primary.Position
            local diff = rp - cp
            local dist = math.sqrt(diff.X*diff.X + diff.Y*diff.Y + diff.Z*diff.Z)
            distCache[obj] = dist

            local sc = speedCache[obj]
            local spd = 0
            if sc then
                local dt = now - sc.time
                if dt > 0 then
                    spd = (cp - sc.pos).Magnitude / dt
                    local d = espCache[obj]
                    if d and d.speedLabel then d.speedLabel.Text = string.format("%.1f m/s", spd) end
                end
            end
            speedCache[obj] = {pos=cp, time=now, speed=spd}

            if espCache[obj] and espCache[obj].type=="ghost" and dist < closestDist then
                closestDist = dist; closestGhost = obj
            end
        else
            distCache[obj] = nil
        end
    end

    if closestGhost then
        currentClosestGhost = closestGhost
        local age = closestGhost:GetAttribute("Age")
        local gender = closestGhost:GetAttribute("Gender")
        local fav = closestGhost:GetAttribute("FavoriteRoom")
        local cur = closestGhost:GetAttribute("CurrentRoom")
        if gender then
            gender = tostring(gender):lower()
            gender = gender=="male" and "Nam" or (gender=="female" and "Nữ" or gender)
        end
        tuoiVal.Text = tostring(age or "--")
        gioiTinhVal.Text = gender or "--"
        phongYTVal.Text = tostring(fav or "--")
        phongDOVal.Text = tostring(cur or "--")
    else
        currentClosestGhost = nil
        tuoiVal.Text = "--"; gioiTinhVal.Text = "--"; phongYTVal.Text = "--"; phongDOVal.Text = "--"
    end

    for obj,d in pairs(espCache) do
        local dist = distCache[obj]
        if dist and d.distLabel then
            d.distLabel.Text = string.format("%.0fm", dist)
            local en = false
            if d.type=="ghost" then en = espActive and dist <= CONFIG.MaxDistance
            elseif d.type=="orb" then en = espOrbActive and dist <= CONFIG.MaxDistance end
            if d.bb.Enabled ~= en then d.bb.Enabled = en; if d.hl then d.hl.Enabled = en end end
        elseif not dist then
            if d.bb.Enabled then d.bb.Enabled = false; if d.hl then d.hl.Enabled = false end end
        end
    end

    if autoEscapeActive and closestGhost and closestDist <= CONFIG.MaxDistance then
        local sc = speedCache[closestGhost]
        if sc and sc.speed > CONFIG.AutoEscapeSpeed then
            if now - lastEscapeTime >= CONFIG.AutoEscapeCooldown then
                lastEscapeTime = now
                if savedStatus[autoEscapeSlot] then
                    teleportToPosition(autoEscapeSlot)
                    print(string.format("[GhostESP] ⚠️ AUTO ESCAPE! Speed: %.1f m/s -> Slot %d", sc.speed, autoEscapeSlot))
                else
                    warn("[GhostESP] Auto Escape: Slot "..autoEscapeSlot.." chưa save!")
                end
            end
        end
    end

    if favRoomActive then updateFavRoomESP() else
        if favRoomESP then
            pcall(function() favRoomESP.bb:Destroy() end)
            pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
            favRoomESP = nil
        end
    end

    -- Speed Hack persistence: re-apply if game reset WalkSpeed
    if speedHackActive then
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= speedHackValue then
            hum.WalkSpeed = speedHackValue
        end
    end
end

task.spawn(function()
    while screenGui and screenGui.Parent do
        local ok, err = pcall(update)
        if not ok then warn("[GhostESP] "..tostring(err)) end
        task.wait(CONFIG.UpdateInterval)
    end
end)

-- ===================== AIMBOT (RenderStepped 60fps) =====================
local function updateAimbot()
    if not aimbotActive then return end

    if not currentClosestGhost or not currentClosestGhost.Parent then return end
    local ghost = currentClosestGhost

    local part = getGhostPart(ghost)
    if not part or not part.Parent then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    local camPos = cam.CFrame.Position
    local targetPos = part.Position + Vector3.new(0, CONFIG.AimbotHeight, 0)

    local diff = targetPos - camPos
    if diff.Magnitude < 0.1 then return end

    if CONFIG.AimbotFOV < 360 then
        local lookDir = cam.CFrame.LookVector
        local toGhost = diff.Unit
        local dot = lookDir:Dot(toGhost)
        local angleDeg = math.deg(math.acos(math.clamp(dot, -1, 1)))
        if angleDeg > CONFIG.AimbotFOV / 2 then return end
    end

    local targetCFrame = CFrame.lookAt(camPos, targetPos)

    local lerpFactor = 1 - CONFIG.AimbotSmooth
    if lerpFactor >= 1 then
        cam.CFrame = targetCFrame
    elseif lerpFactor > 0 then
        cam.CFrame = cam.CFrame:Lerp(targetCFrame, lerpFactor)
    end
end

RunService:BindToRenderStep("GhostAimbot", Enum.RenderPriority.Camera.Value + 1, updateAimbot)

-- ===================== CLEANUP =====================
closeBtn.MouseButton1Click:Connect(function()
    pcall(function() RunService:UnbindFromRenderStep("GhostAimbot") end)
    -- Reset speed hack before tearing down
    pcall(function()
        speedHackActive = false
        applySpeedHack()
    end)
    for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    for _,c in pairs(attributeConnections) do pcall(function() c:Disconnect() end) end
    for _,d in pairs(espCache) do
        pcall(function() if d.bb then d.bb:Destroy() end end)
        pcall(function() if d.hl then d.hl:Destroy() end end)
    end
    if favRoomESP then
        pcall(function() favRoomESP.bb:Destroy() end)
        pcall(function() if favRoomESP.hl then favRoomESP.hl:Destroy() end end)
    end
    ghostList={}; espCache={}; distCache={}; speedCache={}; pendingGhosts={}; attributeConnections={}
    if fullBrightActive then setFullBright(false) end
    pcall(function() screenGui:Destroy() end)
    pcall(function() espFolder:Destroy() end)
end)

print("[GhostESP] v4.00 Fixed + Aimbot + SpeedHack - GUI loaded OK!")