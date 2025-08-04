local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Makuru Hub",
    SubTitle = "Free script",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.End
})

local v16 = { 
    Home = v15:AddTab({ 
        Title = "Info" 
    }), 
    Main = v15:AddTab({ 
        Title = "Farm" 
    }), 
    Sea = v15:AddTab({ 
        Title = "Event" 
    }), 
    ITM = v15:AddTab({ 
        Title = "Item" 
    }), 
    Setting = v15:AddTab({ 
        Title = "Settings" 
    }), 
    Status = v15:AddTab({ 
        Title = "Server" 
    }), 
    Stats = v15:AddTab({ 
        Title = "Chỉ Số" 
    }), 
    Player = v15:AddTab({ 
        Title = "Người Chơi" 
    }), 
    Teleport = v15:AddTab({ 
        Title = "Dịch Chuyển" 
    }), 
    Visual = v15:AddTab({ 
        Title = "Giả" 
    }), 
    Fruit = v15:AddTab({ 
        Title = "Trái" 
    }), 
    Raid = v15:AddTab({ 
        Title = "Tập Kích" 
    }), 
    Race = v15:AddTab({ 
        Title = "Tộc" 
    }), 
    Shop = v15:AddTab({ 
        Title = "Cửa Hàng" 
    }), 
    Misc = v15:AddTab({ 
        Title = "Khác" 
    }) 
}; 
local v17 = v14.Options; 
local v18 = game.PlaceId; 
if (v18 == 2753915549) then 
    Sea1 = true; 
elseif (v18 == 4442272183) then 
    Sea2 = true; 
elseif (v18 == 7449423635) then 
    Sea3 = true; 
else 
    game:Shutdown(); 
end 
game:GetService("Players").LocalPlayer.Idled:connect(function() 
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame); 
    wait(); 
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame); 
end); 
Sea1 = false; 
Sea2 = false; 
Sea3 = false; 
local v19 = game.PlaceId; 
if (v19 == 2753915549) then 
    Sea1 = true; 
elseif (v19 == 4442272183) then 
    Sea2 = true; 
elseif (v19 == 7449423635) then 
    Sea3 = true; 
end 
function CheckLevel() 
    local v197 = game:GetService("Players").LocalPlayer.Data.Level.Value; 
    if Sea1 then 
        if ((v197 == 1) or (v197 <= 9) or (SelectMonster == "Bandit")) then 
            Ms = "Bandit"; 
            NameQuest = "BanditQuest1"; 
            QuestLv = 1; 
            NameMon = "Bandit"; 
            CFrameQ = CFrame.new(1060.9383544922, 16.455066680908, 1547.7841796875); 
            CFrameMon = CFrame.new(1038.5533447266, 41.296249389648, 1576.5098876953); 
        elseif ((v197 == 10) or (v197 <= 14) or (SelectMonster == "Monkey")) then 
            Ms = "Monkey"; 
            NameQuest = "JungleQuest"; 
            QuestLv = 1; 
            NameMon = "Monkey"; 
            CFrameQ = CFrame.new(- 1601.6553955078, 36.85213470459, 153.38809204102); 
            CFrameMon = CFrame.new(- 1448.1446533203, 50.851993560791, 63.60718536377); 
        elseif ((v197 == 15) or (v197 <= 29) or (SelectMonster == "Gorilla")) then 
            Ms = "Gorilla"; 
            NameQuest = "JungleQuest"; 
            QuestLv = 2; 
            NameMon = "Gorilla"; 
            CFrameQ = CFrame.new(- 1601.6553955078, 36.85213470459, 153.38809204102); 
            CFrameMon = CFrame.new(- 1142.6488037109, 40.462348937988, - 515.39227294922); 
        elseif ((v197 == 30) or (v197 <= 39) or (SelectMonster == "Pirate")) then 
            Ms = "Pirate"; 
            NameQuest = "BuggyQuest1"; 
            QuestLv = 1; 
            NameMon = "Pirate"; 
            CFrameQ = CFrame.new(- 1140.1761474609, 4.752049446106, 3827.4057617188); 
            CFrameMon = CFrame.new(- 1201.0881347656, 40.628940582275, 3857.5966796875); 
        elseif ((v197 == 40) or (v197 <= 59) or (SelectMonster == "Brute")) then 
            Ms = "Brute"; 
            NameQuest = "BuggyQuest1"; 
            QuestLv = 2; 
            NameMon = "Brute"; 
            CFrameQ = CFrame.new(- 1140.1761474609, 4.752049446106, 3827.4057617188); 
            CFrameMon = CFrame.new(- 1387.5324707031, 24.592035293579, 4100.9575195313); 
        elseif ((v197 == 60) or (v197 <= 74) or (SelectMonster == "Desert Bandit")) then 
            Ms = "Desert Bandit"; 
            NameQuest = "DesertQuest"; 
            QuestLv = 1; 
            NameMon = "Desert Bandit"; 
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625); 
            CFrameMon = CFrame.new(984.99896240234, 16.109552383423, 4417.91015625); 
        elseif ((v197 == 75) or (v197 <= 89) or (SelectMonster == "Desert Officer")) then 
            Ms = "Desert Officer"; 
            NameQuest = "DesertQuest"; 
            QuestLv = 2; 
            NameMon = "Desert Officer"; 
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625); 
            CFrameMon = CFrame.new(1547.1510009766, 14.452038764954, 4381.8002929688); 
        elseif ((v197 == 90) or (v197 <= 99) or (SelectMonster == "Snow Bandit")) then 
            Ms = "Snow Bandit"; 
            NameQuest = "SnowQuest"; 
            QuestLv = 1; 
            NameMon = "Snow Bandit"; 
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, - 1298.3576660156); 
            CFrameMon = CFrame.new(1356.3028564453, 105.76865386963, - 1328.2418212891); 
        elseif ((v197 == 100) or (v197 <= 119) or (SelectMonster == "Snowman")) then 
            Ms = "Snowman"; 
            NameQuest = "SnowQuest"; 
            QuestLv = 2; 
            NameMon = "Snowman"; 
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, - 1298.3576660156); 
            CFrameMon = CFrame.new(1218.7956542969, 138.01184082031, - 1488.0262451172); 
        elseif ((v197 == 120) or (v197 <= 149) or (SelectMonster == "Chief Petty Officer")) then 
            Ms = "Chief Petty Officer"; 
            NameQuest = "MarineQuest2"; 
            QuestLv = 1; 
            NameMon = "Chief Petty Officer"; 
            CFrameQ = CFrame.new(- 5035.49609375, 28.677835464478, 4324.1840820313); 
            CFrameMon = CFrame.new(- 4931.1552734375, 65.793113708496, 4121.8393554688); 
        elseif ((v197 == 150) or (v197 <= 174) or (SelectMonster == "Sky Bandit")) then 
            Ms = "Sky Bandit"; 
            NameQuest = "SkyQuest"; 
            QuestLv = 1; 
            NameMon = "Sky Bandit"; 
            CFrameQ = CFrame.new(- 4842.1372070313, 717.69543457031, - 2623.0483398438); 
            CFrameMon = CFrame.new(- 4955.6411132813, 365.46365356445, - 2908.1865234375); 
        elseif ((v197 == 175) or (v197 <= 189) or (SelectMonster == "Dark Master")) then 
            Ms = "Dark Master"; 
            NameQuest = "SkyQuest"; 
            QuestLv = 2; 
            NameMon = "Dark Master"; 
            CFrameQ = CFrame.new(- 4842.1372070313, 717.69543457031, - 2623.0483398438); 
            CFrameMon = CFrame.new(- 5148.1650390625, 439.04571533203, - 2332.9611816406); 
        elseif ((v197 == 190) or (v197 <= 209) or (SelectMonster == "Prisoner")) then 
            Ms = "Prisoner"; 
            NameQuest = "PrisonerQuest"; 
            QuestLv = 1; 
            NameMon = "Prisoner"; 
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, - 0.999846935, 0, 0.0175017118); 
            CFrameMon = CFrame.new(4937.31885, 0.332031399, 649.574524, 0.694649816, 0, - 0.719348073, 0, 1, 0, 0.719348073, 0, 0.694649816); 
        elseif ((v197 == 210) or (v197 <= 249) or (SelectMonster == "Dangerous Prisoner")) then 
            Ms = "Dangerous Prisoner"; 
            NameQuest = "PrisonerQuest"; 
            QuestLv = 2; 
            NameMon = "Dangerous Prisoner"; 
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, - 0.999846935, 0, 0.0175017118); 
            CFrameMon = CFrame.new(5099.6626, 0.351562679, 1055.7583, 0.898906827, 0, - 0.438139856, 0, 1, 0, 0.438139856, 0, 0.898906827); 
        elseif ((v197 == 250) or (v197 <= 274) or (SelectMonster == "Toga Warrior")) then 
            Ms = "Toga Warrior"; 
            NameQuest = "ColosseumQuest"; 
            QuestLv = 1; 
            NameMon = "Toga Warrior"; 
            CFrameQ = CFrame.new(- 1577.7890625, 7.4151420593262, - 2984.4838867188); 
            CFrameMon = CFrame.new(- 1872.5166015625, 49.080215454102, - 2913.810546875); 
        elseif ((v197 == 275) or (v197 <= 299) or (SelectMonster == "Gladiator")) then 
            Ms = "Gladiator"; 
            NameQuest = "ColosseumQuest"; 
            QuestLv = 2; 
            NameMon = "Gladiator"; 
            CFrameQ = CFrame.new(- 1577.7890625, 7.4151420593262, - 2984.4838867188); 
            CFrameMon = CFrame.new(- 1521.3740234375, 81.203170776367, - 3066.3139648438); 
        elseif ((v197 == 300) or (v197 <= 324) or (SelectMonster == "Military Soldier")) then 
            Ms = "Military Soldier"; 
            NameQuest = "MagmaQuest"; 
            QuestLv = 1; 
            NameMon = "Military Soldier"; 
            CFrameQ = CFrame.new(- 5316.1157226563, 12.262831687927, 8517.00390625); 
            CFrameMon = CFrame.new(- 5369.0004882813, 61.24352645874, 8556.4921875); 
        elseif ((v197 == 325) or (v197 <= 374) or (SelectMonster == "Military Spy")) then 
            Ms = "Military Spy"; 
            NameQuest = "MagmaQuest"; 
            QuestLv = 2; 
            NameMon = "Military Spy"; 
            CFrameQ = CFrame.new(- 5316.1157226563, 12.262831687927, 8517.00390625); 
            CFrameMon = CFrame.new(- 5787.00293, 75.8262634, 8651.69922, 0.838590562, 0, - 0.544762194, 0, 1, 0, 0.544762194, 0, 0.838590562); 
        elseif ((v197 == 375) or (v197 <= 399) or (SelectMonster == "Fishman Warrior")) then 
            Ms = "Fishman Warrior"; 
            NameQuest = "FishmanQuest"; 
            QuestLv = 1; 
            NameMon = "Fishman Warrior"; 
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734); 
            CFrameMon = CFrame.new(60844.10546875, 98.462875366211, 1298.3985595703); 
            if (_G.AutoLevel and ((CFrameMon.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000)) then 
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)); 
            end 
        elseif ((v197 == 400) or (v197 <= 449) or (SelectMonster == "Fishman Commando")) then 
            Ms = "Fishman Commando"; 
            NameQuest = "FishmanQuest"; 
            QuestLv = 2; 
            NameMon = "Fishman Commando"; 
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734); 
            CFrameMon = CFrame.new(61738.3984375, 64.207321166992, 1433.8375244141); 
            if (_G.AutoLevel and ((CFrameMon.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000)) then 
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)); 
            end 
        elseif ((v197 == 10) or (v197 <= 474) or (SelectMonster == "God's Guard")) then 
            Ms = "God's Guard"; 
            NameQuest = "SkyExp1Quest"; 
            QuestLv = 1; 
            NameMon = "God's Guard"; 
            CFrameQ = CFrame.new(- 4721.8603515625, 845.30297851563, - 1953.8489990234); 
            CFrameMon = CFrame.new(- 4628.0498046875, 866.92877197266, - 1931.2352294922); 
            if (_G.AutoLevel and ((CFrameMon.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000)) then 
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 4607.82275, 872.54248, - 1667.55688)); 
            end 
        elseif ((v197 == 475) or (v197 <= 524) or (SelectMonster == "Shanda")) then 
            Ms = "Shanda"; 
            NameQuest = "SkyExp1Quest"; 
            QuestLv = 2; 
            NameMon = "Shanda"; 
            CFrameQ = CFrame.new(- 7863.1596679688, 5545.5190429688, - 378.42266845703); 
            CFrameMon = CFrame.new(- 7685.1474609375, 5601.0751953125, - 441.38876342773); 
            if (_G.AutoLevel and ((CFrameMon.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 3000)) then 
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 7894.6176757813, 5547.1416015625, - 380.29119873047)); 
            end 
        elseif ((v197 == 525) or (v197 <= 549) or (SelectMonster == "Royal Squad")) then 
            Ms = "Royal Squad"; 
            NameQuest = "SkyExp2Quest"; 
            QuestLv = 1; 
            NameMon = "Royal Squad"; 
            CFrameQ = CFrame.new(- 7903.3828125, 5635.9897460938, - 1410.923828125); 
            CFrameMon = CFrame.new(- 7654.2514648438, 5637.1079101563, - 1407.7550048828); 
        elseif ((v197 == 550) or (v197 <= 624) or (SelectMonster == "Royal Soldier")) then 
            Ms = "Royal Soldier"; 
            NameQuest = "SkyExp2Quest"; 
            QuestLv = 2; 
            NameMon = "Royal Soldier"; 
            CFrameQ = CFrame.new(- 7903.3828125, 5635.9897460938, - 1410.923828125); 
            CFrameMon = CFrame.new(- 7760.4106445313, 5679.9077148438, - 1884.8112792969); 
        elseif ((v197 == 625) or (v197 <= 649) or (SelectMonster == "Galley Pirate")) then 
            Ms = "Galley Pirate"; 
            NameQuest = "FountainQuest"; 
            QuestLv = 1; 
            NameMon = "Galley Pirate"; 
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875); 
            CFrameMon = CFrame.new(5557.1684570313, 152.32717895508, 3998.7758789063); 
        elseif ((v197 >= 650) or (SelectMonster == "Galley Captain")) then 
            Ms = "Galley Captain"; 
            NameQuest = "FountainQuest"; 
            QuestLv = 2; 
            NameMon = "Galley Captain"; 
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875); 
            CFrameMon = CFrame.new(5677.6772460938, 92.786109924316, 4966.6323242188); 
        end 
    end 
    if Sea2 then 
        if ((v197 == 700) or (v197 <= 724) or (SelectMonster == "Raider")) then 
            Ms = "Raider"; 
            NameQuest = "Area1Quest"; 
            QuestLv = 1; 
            NameMon = "Raider"; 
            CFrameQ = CFrame.new(- 427.72567749023, 72.99634552002, 1835.9426269531); 
            CFrameMon = CFrame.new(68.874565124512, 93.635643005371, 2429.6752929688); 
        elseif ((v197 == 725) or (v197 <= 774) or (SelectMonster == "Mercenary")) then 
            Ms = "Mercenary"; 
            NameQuest = "Area1Quest"; 
            QuestLv = 2; 
            NameMon = "Mercenary"; 
            CFrameQ = CFrame.new(- 427.72567749023, 72.99634552002, 1835.9426269531); 
            CFrameMon = CFrame.new(- 864.85009765625, 122.47104644775, 1453.1505126953); 
        elseif ((v197 == 775) or (v197 <= 799) or (SelectMonster == "Swan Pirate")) then 
            Ms = "Swan Pirate"; 
            NameQuest = "Area2Quest"; 
            QuestLv = 1; 
            NameMon = "Swan Pirate"; 
            CFrameQ = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125); 
            CFrameMon = CFrame.new(1065.3669433594, 137.64012145996, 1324.3798828125); 
        elseif ((v197 == 800) or (v197 <= 874) or (SelectMonster == "Factory Staff")) then 
            Ms = "Factory Staff"; 
            NameQuest = "Area2Quest"; 
            QuestLv = 2; 
            NameMon = "Factory Staff"; 
            CFrameQ = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125); 
            CFrameMon = CFrame.new(533.22045898438, 128.46876525879, 355.62615966797); 
        elseif ((v197 == 875) or (v197 <= 899) or (SelectMonster == "Marine Lieutenan")) then 
            Ms = "Marine Lieutenant"; 
            NameQuest = "MarineQuest3"; 
            QuestLv = 1; 
            NameMon = "Marine Lieutenant"; 
            CFrameQ = CFrame.new(- 2440.9934082031, 73.04190826416, - 3217.7082519531); 
            CFrameMon = CFrame.new(- 2489.2622070313, 84.613594055176, - 3151.8830566406); 
        elseif ((v197 == 900) or (v197 <= 949) or (SelectMonster == "Marine Captain")) then 
            Ms = "Marine Captain"; 
            NameQuest = "MarineQuest3"; 
            QuestLv = 2; 
            NameMon = "Marine Captain"; 
            CFrameQ = CFrame.new(- 2440.9934082031, 73.04190826416, - 3217.7082519531); 
            CFrameMon = CFrame.new(- 2335.2026367188, 79.786659240723, - 3245.8674316406); 
        elseif ((v197 == 950) or (v197 <= 974) or (SelectMonster == "Zombie")) then 
            Ms = "Zombie"; 
            NameQuest = "ZombieQuest"; 
            QuestLv = 1; 
            NameMon = "Zombie"; 
            CFrameQ = CFrame.new(- 5494.3413085938, 48.505931854248, - 794.59094238281); 
            CFrameMon = CFrame.new(- 5536.4970703125, 101.08577728271, - 835.59075927734); 
        elseif ((v197 == 975) or (v197 <= 999) or (SelectMonster == "Vampire")) then 
            Ms = "Vampire"; 
            NameQuest = "ZombieQuest"; 
            QuestLv = 2; 
            NameMon = "Vampire"; 
            CFrameQ = CFrame.new(- 5494.3413085938, 48.505931854248, - 794.59094238281); 
            CFrameMon = CFrame.new(- 5806.1098632813, 16.722528457642, - 1164.4384765625); 
        elseif ((v197 == 1000) or (v197 <= 1049) or (SelectMonster == "Snow Trooper")) then 
            Ms = "Snow Trooper"; 
            NameQuest = "SnowMountainQuest"; 
            QuestLv = 1; 
            NameMon = "Snow Trooper"; 
            CFrameQ = CFrame.new(607.05963134766, 401.44781494141, - 5370.5546875); 
            CFrameMon = CFrame.new(535.21051025391, 432.74209594727, - 5484.9165039063); 
        elseif ((v197 == 1050) or (v197 <= 1099) or (SelectMonster == "Winter Warrior")) then 
            Ms = "Winter Warrior"; 
            NameQuest = "SnowMountainQuest"; 
            QuestLv = 2; 
            NameMon = "Winter Warrior"; 
            CFrameQ = CFrame.new(607.05963134766, 401.44781494141, - 5370.5546875); 
            CFrameMon = CFrame.new(1234.4449462891, 456.95419311523, - 5174.130859375); 
        elseif ((v197 == 1100) or (v197 <= 1124) or (SelectMonster == "Lab Subordinate")) then 
            Ms = "Lab Subordinate"; 
            NameQuest = "IceSideQuest"; 
            QuestLv = 1; 
            NameMon = "Lab Subordinate"; 
            CFrameQ = CFrame.new(- 6061.841796875, 15.926671981812, - 4902.0385742188); 
            CFrameMon = CFrame.new(- 5720.5576171875, 63.309471130371, - 4784.6103515625); 
        elseif ((v197 == 1125) or (v197 <= 1174) or (SelectMonster == "Horned Warrior")) then 
            Ms = "Horned Warrior"; 
            NameQuest = "IceSideQuest"; 
            QuestLv = 2; 
            NameMon = "Horned Warrior"; 
            CFrameQ = CFrame.new(- 6061.841796875, 15.926671981812, - 4902.0385742188); 
            CFrameMon = CFrame.new(- 6292.751953125, 91.181983947754, - 5502.6499023438); 
        elseif ((v197 == 1175) or (v197 <= 1199) or (SelectMonster == "Magma Ninja")) then 
            Ms = "Magma Ninja"; 
            NameQuest = "FireSideQuest"; 
            QuestLv = 1; 
            NameMon = "Magma Ninja"; 
            CFrameQ = CFrame.new(- 5429.0473632813, 15.977565765381, - 5297.9614257813); 
            CFrameMon = CFrame.new(- 5461.8388671875, 130.36347961426, - 5836.4702148438); 
        elseif ((v197 == 1200) or (v197 <= 1249) or (SelectMonster == "Lava Pirate")) then 
            Ms = "Lava Pirate"; 
            NameQuest = "FireSideQuest"; 
            QuestLv = 2; 
            NameMon = "Lava Pirate"; 
            CFrameQ = CFrame.new(- 5429.0473632813, 15.977565765381, - 5297.9614257813); 
            CFrameMon = CFrame.new(- 5251.1889648438, 55.164535522461, - 4774.4096679688); 
        elseif ((v197 == 1250) or (v197 <= 1274) or (SelectMonster == "Ship Deckhand")) then 
            Ms = "Ship Deckhand"; 
            NameQuest = "ShipQuest1"; 
            QuestLv = 1; 
            NameMon = "Ship Deckhand"; 
            CFrameQ = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625); 
            CFrameMon = CFrame.new(921.12365722656, 125.9839553833, 33088.328125);