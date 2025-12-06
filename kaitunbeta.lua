-- Chọn phe hải tặc hoặc hải quân
local args = {
	"SetTeam",
	"Pirates"  --Pirates or Marines
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
--Tween tới npc nhận nhiệm vụ hải tặc

task.wait(5)
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local npc = workspace.NPCs["Bandit Quest Giver"]

local speed = 325
local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
local distance = (hrp.Position - targetCFrame.Position).Magnitude
local time = distance / speed

-- TweenInfo đều đặn
local tweenInfo = TweenInfo.new(
    time,
    Enum.EasingStyle.Linear,  -- Đều đặn
    Enum.EasingDirection.Out
)

local tween = TweenService:Create(hrp, tweenInfo, {
    CFrame = targetCFrame
})

tween:Play()
tween.Completed:Wait()

--nhận nhiệm vụ bandit
local args = {
	"StartQuest",
	"BanditQuest1",
	1
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))