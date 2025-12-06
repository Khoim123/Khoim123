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

local speed = 325 -- Tốc độ (studs/giây) - chỉnh con số này
local targetCFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
local distance = (hrp.Position - targetCFrame.Position).Magnitude
local time = distance / speed

local tween = TweenService:Create(hrp, TweenInfo.new(time), {
    CFrame = targetCFrame
})

tween:Play()

-- khoá di chuyển
local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
hrp.Anchored = true

--nhận nhiệm vụ bandit
local args = {
	"StartQuest",
	"BanditQuest1",
	1
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))

-- FARM BẰNG CHUỘT TRÁI + BRING
local VirtualInputManager = game:GetService("VirtualInputManager")

while task.wait(0.1) do
    -- Bring mob
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == "Bandit" and mob:FindFirstChild("HumanoidRootPart") then
            if mob.Humanoid.Health > 0 then
                mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, -10, 0)
                mob.HumanoidRootPart.CanCollide = false
                mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
            end
        end
    end
    
    -- Click chuột trái liên tục
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end