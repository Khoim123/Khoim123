local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fluent
if not ReplicatedStorage:FindFirstChild("Fluent") then
    warn("Fluent UI not found! Please install it in ReplicatedStorage")
    return
else
    Fluent = require(ReplicatedStorage.Fluent)
end

local Window = Fluent:CreateWindow({
    Title = "Teleport Tool " .. Fluent.Version,
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 350), -- Kích thước nhỏ gọn hơn
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local TeleportTab = Window:AddTab({
    Title = "Teleport",
    Icon = "rbxassetid://10734927979"
})

local PositionSection = TeleportTab:AddSection({
    Title = "Position (X, Y, Z)",
    Side = "Left"
})

local PositionInput = PositionSection:AddInput({
    Title = "Coordinates",
    Default = "0, 0, 0",
    Placeholder = "Enter X,Y,Z (e.g. 100, 5, 50)",
    Numeric = false,
    Callback = function(Value) end
})

local SpeedSection = TeleportTab:AddSection({
    Title = "Movement Settings",
    Side = "Left"
})

local SpeedInput = SpeedSection:AddInput({
    Title = "Tween Speed",
    Default = "350",
    Placeholder = "Enter speed (studs/s)",
    Numeric = true,
    Callback = function(Value) end
})

SpeedSection:AddButton({
    Title = "Tween",
    Description = "Teleport to specified position",
    Callback = function()
        local coordParts = {}
        for part in string.gmatch(PositionInput.Value, "[^,%s]+") do
            table.insert(coordParts, tonumber(part))
        end
        
        if #coordParts == 3 then
            local position = Vector3.new(coordParts[1], coordParts[2], coordParts[3])
            local speed = tonumber(SpeedInput.Value) or 16
            
            local character = Players.LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(position)
                character.Humanoid.WalkSpeed = speed
                
                Fluent:Notify({
                    Title = "SUCCESS",
                    Content = string.format("Teleported to %s", tostring(position)),
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "ERROR",
                Content = "Invalid position format! Use X,Y,Z",
                Duration = 3
            })
        end
    end
})

TeleportTab:AddButton({
    Title = "TOGGLE UI",
    Callback = function()
        Window:Toggle()
    end
})

Window:SelectTab(1)