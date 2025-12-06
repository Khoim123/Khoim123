local args = {
	"SetTeam",
	"Pirates"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Tìm NPC
local npc = workspace.NPCs:FindFirstChild("Bandit Quest Giver")

if npc and npc:FindFirstChild("HumanoidRootPart") then
    -- Teleport tới vị trí NPC
    humanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    print("Đã teleport tới Bandit Quest Giver")
else
    warn("Không tìm thấy NPC hoặc HumanoidRootPart của NPC")
end
local args = {
	"StartQuest",
	"BanditQuest1",
	1
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
