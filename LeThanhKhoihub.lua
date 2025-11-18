local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Le Thanh Khoi hub v1.0",
    SubTitle = "by Le Thanh Khoi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Test = Window:AddTab({ Title = "Test" , Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Fluent:Notify({
    Title = "Le Thanh Khoi Hub",
    Content = "Đã được load thành công",
    SubContent = "SubContent", -- Optional
    Duration = 5
})

-- Thêm các nút vào tab Main
Tabs.Main:AddButton({
    Title = "Button",
    Description = "Very important button",
    Callback = function()
        print("Hello, world!")
    end
})

Tabs.Main:AddButton({
    Title = "Test",
    Description = "Very important button",
    Callback = function()
        print("Hello Le Thanh Khoi")
    end
})

Tabs.Main:AddButton({
    Title = "Button 3",
    Description = "Very important button",
    Callback = function()
        print("Thank you")
    end
})

-- Tạo nút ẩn hiện GUI ở ngoài màn hình
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "ToggleGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.Parent = ToggleButton
UICorner.CornerRadius = UDim.new(0, 10)

-- Lấy GUI chính của Fluent
task.wait(0.5) -- Đợi GUI load xong
local MainGUI = game:GetService("CoreGui"):FindFirstChild("ScreenGui")
local isVisible = true

ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    if MainGUI then
        MainGUI.Enabled = isVisible
    end
end)