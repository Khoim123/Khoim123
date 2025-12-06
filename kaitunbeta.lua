-- Chọn phe hải tặc hoặc hải quân
local args = {
	"SetTeam",
	"Pirates"  --Pirates or Marines
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
--Tween tới npc nhận nhiệm vụ hải tặc

local function tweenToNPC()
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Vị trí NPC
    local npcPosition = Vector3.new(1058.96802, 12.6660004, 1551.81396)
    
    local speed = 325
    local targetCFrame = CFrame.new(npcPosition)
    local distance = (hrp.Position - npcPosition).Magnitude
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    task.wait(0.5)
end
-cầm melee
local player = game.Players.LocalPlayer
local character = player.Character

for _, tool in pairs(player.Backpack:GetChildren()) do
    if tool:IsA("Tool") and tool.ToolTip == "Melee" then
        character.Humanoid:EquipTool(tool)
        break
    end
end

--nhận nhiệm vụ bandit
local args = {
	"StartQuest",
	"BanditQuest1",
	1
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))