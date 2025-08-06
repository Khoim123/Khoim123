local Fluent = require(game.ReplicatedStorage.Fluent)
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

local menuVisible = true

-- Hàm teleport
local function teleportTo(x, y, z, speed)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        hrp.CFrame = CFrame.new(Vector3.new(x, y, z))
        if speed then
            character.Humanoid.WalkSpeed = speed
        end
    end
end

local frame = Fluent.Container({
    Size = UDim2.fromOffset(300, 200),
    Position = UDim2.fromOffset(100, 100),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Visible = menuVisible,
    Layout = Fluent.UIListLayout({ -- Thêm layout để sắp xếp các phần tử
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Vertical
    })
})

local xInput = Fluent.TextBox({
    PlaceholderText = "X",
    Size = UDim2.new(1, 0, 0, 30)
})

local yInput = Fluent.TextBox({
    PlaceholderText = "Y",
    Size = UDim2.new(1, 0, 0, 30)
})

local zInput = Fluent.TextBox({
    PlaceholderText = "Z",
    Size = UDim2.new(1, 0, 0, 30)
})

local speedInput = Fluent.TextBox({
    PlaceholderText = "Speed (studs)",
    Size = UDim2.new(1, 0, 0, 30)
})

local teleportButton = Fluent.Button({
    Text = "Dịch chuyển",
    Size = UDim2.new(1, 0, 0, 30),
    Activated = function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        local speed = tonumber(speedInput.Text)
        
        if x and y and z then
            teleportTo(x, y, z, speed)
        else
            warn("Vui lòng nhập giá trị hợp lệ cho X, Y, Z!")
        end
    end
})

local toggleMenuButton = Fluent.Button({
    Text = "Ẩn/Hiện Menu",
    Size = UDim2.new(1, 0, 0, 30),
    Activated = function()
        menuVisible = not menuVisible
        frame.Visible = menuVisible
    end
})

frame:AddChildren({
    xInput,
    yInput,
    zInput,
    speedInput,
    teleportButton,
    toggleMenuButton
})

ScreenGui:AddChild(frame)