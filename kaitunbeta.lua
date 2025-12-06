-- Chọn phe hải tặc hoặc hải quân
task.wait(5)
local args = {
	"SetTeam",
	"Pirates"  --Pirates or Marines
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

--Tween tới npc nhận nhiệm vụ hải tặc
task.wait(5)
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local npc = workspace.NPCs["Bandit Quest Giver"]

local speed = 325 -- Tốc độ (studs/giây) - chỉnh con số này
local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
local distance = (hrp.Position - targetCFrame.Position).Magnitude
local time = distance / speed

local tween = TweenService:Create(hrp, TweenInfo.new(time), {
    CFrame = targetCFrame
})

tween:Play()

--nhận nhiệm vụ bandit