local Fluent = require(game.ReplicatedStorage.Fluent) -- đường dẫn tùy theo bạn
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

local menuVisible = true

local frame = Fluent.Container({
    Size = UDim2.fromOffset(300, 200),
    Position = UDim2.fromOffset(100, 100),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Visible = menuVisible
})

local xInput = Fluent.TextBox({ PlaceholderText = "X" })
local yInput = Fluent.TextBox({ PlaceholderText = "Y" })
local zInput = Fluent.TextBox({ PlaceholderText = "Z" })
local speedInput = Fluent.TextBox({ PlaceholderText = "Speed (studs)" })

local teleportButton = Fluent.Button({
    Text = "Dịch chuyển",
    Activated = function()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)
        local speed = tonumber(speedInput.Text)
        if x and y and z and speed then
            teleportTo(x, y, z, speed)
        end
    end
})

local toggleMenuButton = Fluent.Button({
    Text = "Ẩn/Hiện Menu",
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