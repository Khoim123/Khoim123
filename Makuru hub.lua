local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Tải thư viện Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Khởi tạo biến toàn cục
_G.AutoFarm = false
_G.SelectMonster = nil
_G.AttackDistance = 15 -- Khoảng cách tấn công tối đa

-- Tạo cửa sổ Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Auto Farm Pro " .. os.date("%d/%m/%Y"),
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Tạo các tab
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Section chính
local AutoFarmSection = Tabs.Main:AddSection("Auto Farm Settings", {
    Title = "Auto Farm Configuration",
    Side = "Left"
})

-- Toggle Auto Farm
local AutoFarmToggle = AutoFarmSection:AddToggle("AutoFarmToggle", {
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
        if value then
            StartAutoFarm()
        else
            Fluent:Notify({
                Title = "Auto Farm",
                Content = "Đã tắt Auto Farm",
                Duration = 3
            })
        end
    end
})

local MonsterDropdown = AutoFarmSection:AddDropdown("MonsterDropdown", {
    Title = "Chọn quái",
    Description = "Để trống sẽ tự động chọn theo level",
    Values = {"Tự động", "Bandit", "Monkey", "Gorilla", "Pirate", "Brute", "Desert Bandit", "Desert Officer", "Snow Bandit", "Snowman"},
    Multi = false,
    Default = "Tự động",
    Callback = function(value)
        _G.SelectMonster = (value ~= "Tự động") and value or nil
        print("Đã chọn:", _G.SelectMonster or "Tự động")
    end
})

local AttackDistanceSlider = AutoFarmSection:AddSlider("AttackDistanceSlider", {
    Title = "Khoảng cách tấn công",
    Description = "Khoảng cách tối đa để tấn công quái (studs)",
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Callback = function(value)
        _G.AttackDistance = value
    end
})

local StatusDisplay = AutoFarmSection:AddParagraph("StatusDisplay", {
    Title = "Trạng thái:",
    Content = "Đang chờ..."
})

-- Section cài đặt
local SettingsSection = Tabs.Settings:AddSection("Cài đặt hệ thống", {
    Title = "Cấu hình nâng cao",
    Side = "Right"
})

SettingsSection:AddButton({
    Title = "Lưu cài đặt",
    Description = "Lưu cấu hình hiện tại",
    Callback = function()
        SaveManager:Save()
        Fluent:Notify({
            Title = "Thành công",
            Content = "Đã lưu cài đặt!",
            Duration = 3
        })
    end
})

SettingsSection:AddButton({
    Title = "Tải cài đặt",
    Description = "Tải cấu hình đã lưu",
    Callback = function()
        SaveManager:Load()
        Fluent:Notify({
            Title = "Thành công",
            Content = "Đã tải cài đặt!",
            Duration = 3
        })
    end
})

function CheckLevel()
    local level = player.Data.Level.Value
    
    if _G.SelectMonster then
        -- Code chọn quái cụ thể
        if _G.SelectMonster == "Bandit" then
            return {
                NameQuest = "BanditQuest1",
                QuestLv = 1,
                NameMon = "Bandit",
                CFrameQ = CFrame.new(1060.93, 16.45, 1547.78),
                CFrameMon = CFrame.new(1038.55, 41.29, 1576.50)
            }
        -- Thêm các quái khác...
        end
    else
        -- Code tự động chọn theo level
        if level <= 9 then
            return {
                NameQuest = "BanditQuest1",
                QuestLv = 1,
                NameMon = "Bandit",
                CFrameQ = CFrame.new(1060.93, 16.45, 1547.78),
                CFrameMon = CFrame.new(1038.55, 41.29, 1576.50)
            }
        -- Thêm các level khác...
        end
    end
    return nil
end

-- Hàm di chuyển đến vị trí
function TweenToPosition(cframe)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local distance = (character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tweenInfo = TweenInfo.new(
            distance / 100,
            Enum.EasingStyle.Linear
        )
        local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {CFrame = cframe})
        tween:Play()
        tween.Completed:Wait()
        return true
    end
    return false
end

-- Hàm trang bị vũ khí
function EquipWeapon()
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    if not backpack or not character then return false end
    
    -- Tìm kiếm vũ khí trong túi đồ
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = character
            return true
        end
    end
    
    -- Kiểm tra xem đã trang bị vũ khí chưa
    if character:FindFirstChildOfClass("Tool") then
        return true
    end
    
    return false
end

-- Hàm tự động tấn công
function AutoAttack(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Trang bị vũ khí
    EquipWeapon()
    
    -- Di chuyển đến gần quái
    local targetPos = target.HumanoidRootPart.Position
    local distance = (humanoidRootPart.Position - targetPos).Magnitude
    
    if distance > _G.AttackDistance then
        TweenToPosition(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.AttackDistance - 2))
    end
    
    -- Tấn công
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

function StartAutoFarm()
    while _G.AutoFarm do
        local questData = CheckLevel()
        if not questData then
            StatusDisplay:Set("Không tìm thấy nhiệm vụ phù hợp")
            task.wait(3)
            break
        end
        
        -- Cập nhật UI
        local monsterName = _G.SelectMonster or "Tự động ("..questData.NameMon..")"
        StatusDisplay:Set("Đang farm: "..monsterName)
        
        -- ... phần còn lại của hàm auto farm
    end
end
        
        -- Nhận nhiệm vụ
        StatusLabel:Set("Trạng thái hiện tại: Đang nhận nhiệm vụ...")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", questData.NameQuest, questData.QuestLv)
        
        -- Di chuyển đến NPC
        StatusLabel:Set("Trạng thái hiện tại: Đang di chuyển đến NPC...")
        if not TweenToPosition(questData.CFrameQ) then
            StatusLabel:Set("Trạng thái hiện tại: Không thể đến NPC")
            task.wait(3)
            break
        end
        
        -- Tìm và diệt quái
        StatusLabel:Set("Trạng thái hiện tại: Đang tìm quái "..questData.NameMon.."...")
        local foundTarget = false
        
        for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
            if enemy.Name == questData.NameMon and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                foundTarget = true
                StatusLabel:Set("Trạng thái hiện tại: Đang tiêu diệt "..questData.NameMon.."...")
                
                repeat
                    if not _G.AutoFarm then break end
                    AutoAttack(enemy)
                    task.wait(0.1)
                until not enemy or enemy.Humanoid.Health <= 0 or not _G.AutoFarm
            end
        end
        
        if not foundTarget then
            StatusLabel:Set("Trạng thái hiện tại: Di chuyển đến khu vực quái...")
            TweenToPosition(questData.CFrameMon)
            task.wait(3)
        end
    end
    
    if not _G.AutoFarm then
        StatusLabel:Set("Trạng thái hiện tại: Đã dừng Auto Farm")
    end
end

-- Kích hoạt SaveManager và InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Auto Farm Pro",
    Content = "Hệ thống Auto Farm đã sẵn sàng!",
    Duration = 5
})