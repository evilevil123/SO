getgenv().PrestigeActive = true
getgenv().Autofarm = true


function GolemGorilla()
    for _, obj in pairs(game.Workspace:GetChildren()) do
        if obj.Name == "🦍" then
            obj.Name = "Gorilla"
        elseif obj.Name == "🦍😡💢 Quest" then
            obj.Name = "Gorilla Quest"
		elseif obj.Name == "HamonGolem" then
			obj.Name = "Golem"
		end      
    end
end

function AutoAssignStats()
    local skillPointsText = game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.aSkillPoints.Text
    local skillPoints = tonumber(string.match(skillPointsText, "%d+"))
    if skillPoints and skillPoints > 0 then
        game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.Stats:InvokeServer("Strength", tostring(skillPoints))
    end
end

local Quests = {
    Thug = "Thug Quest", 
    Brute = "Brute Quest", 
    Gorilla = "Gorilla Quest", 
    Werewolf = "Werewolf Quest", 
    Zombie = "Zombie Quest", 
    Vampire = "Vampire Quest", 
    Golem = "Golem Quest"
}


getgenv().CurrentMob = "Thug"
getgenv().EnemyHitCount = 0
local EnemiesHit = {}
local AutoLoop = nil
local EnemiesKilled = {}

local player = game.Players.LocalPlayer
local debounce


local function NewEnemy()
    local Enemy
    local success, error = pcall(function()
        for _, EnemyC in pairs(game.Workspace:GetChildren()) do
            if EnemyC.Name == tostring(getgenv().CurrentMob) and not EnemyC:FindFirstChild("ProximityPrompt") then
                if not EnemiesKilled[EnemyC] then
                    Enemy = EnemyC
                    break
                end
            end
        end
    end)


    return Enemy
end
function questCancelRemotes()
    pcall(function()
        local questNames = {"ThugQuest", "BruteQuest", "GorillaQuest", "WerewolfQuest", "ZombieQuest", "VampireQuest", "GolemQuest"}
        for _, questName in ipairs(questNames) do
            local quest = game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest:FindFirstChild(questName)
            if quest and quest.Remotes and quest.Remotes.Cancel then
                quest.Remotes.Cancel:FireServer()
            end
        end
    end)
end

local function NewQuest(Enemy)
    local QuestPerson = game.Workspace:FindFirstChild(Quests[Enemy])
    if QuestPerson then
        local ProximityPrompt = QuestPerson:FindFirstChild("ProximityPrompt")
        pcall(function()
            local TPTweenInfo = TweenInfo.new(1.75, Enum.EasingStyle.Linear)
            local tween = game:GetService("TweenService"):Create(
                game.Players.LocalPlayer.Character.HumanoidRootPart,
                TPTweenInfo,
                { CFrame = QuestPerson.HumanoidRootPart.CFrame })
        
            tween:Play()
        end)
        repeat
            wait()
            fireproximityprompt(ProximityPrompt, 1, true)
        until #player.PlayerGui.Quest.Quest:GetChildren() >= 2
    end
end



local function CheckQuestProgress()
    for _, child in player.PlayerGui.Quest.Quest:GetChildren() do
        if child.Name ~= "Sound" then
            print(getgenv().CurrentMob, child.Name)
            if not string.find(child.Name, getgenv().CurrentMob) then
				questCancelRemotes()
                NewQuest(getgenv().CurrentMob)
                break
            end
        end

        if child:IsA("Frame") and child:FindFirstChild("Progress") then
            local QuestProgress = child.Quest:WaitForChild("Progress")
            if QuestProgress.Value >= 5 then
                NewQuest(getgenv().CurrentMob)
            end
        elseif #player.PlayerGui.Quest.Quest:GetChildren() == 1 then
            NewQuest(getgenv().CurrentMob)
        end
    end
end



local function TeleportToNpc()
    pcall(function()
        local stand = game.Players.LocalPlayer.Character:FindFirstChild("Stand")
        if stand and stand.Head.Transparency == 1 then
            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.SummonStand:InvokeServer()
        else
            local standSuit = game.Players.LocalPlayer.Character:FindFirstChild("StandSuit")
            if standSuit and standSuit.StandHead.Head.Color1.Transparency == 1 then
                game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.SummonStand:InvokeServer()
            end
        end
    end)
        
    AutoAssignStats()
    GolemGorilla()
    CheckQuestProgress()

    Enemy = NewEnemy()
    if not AutoLoop then
        local AutoLoop; AutoLoop = game:GetService("RunService").RenderStepped:Connect(function()
            pcall(function()
                if game.Players.LocalPlayer.Character and not debounce then
                    workspace.Gravity = 0
                    local TPTweenInfo = TweenInfo.new(0, Enum.EasingStyle.Linear)
                        
                    local tween = game:GetService("TweenService"):Create(
                        game.Players.LocalPlayer.Character.HumanoidRootPart,
                        TPTweenInfo,
                        { CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0,-5, 5) }
                    )
                        
                    tween:Play()
			        game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Barrage:InvokeServer()
                    game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Heavy:InvokeServer()
                    game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Punch:InvokeServer()
                        

                    if not Enemy or not Enemy:FindFirstChild("Humanoid") or (Enemy:FindFirstChild("Humanoid") and Enemy.Humanoid.Health == 0) then
                        if not debounce then
                            debounce = true
                            EnemiesKilled[Enemy] = true
                            AutoAssignStats()
                            GolemGorilla()
                            AutoLoop:Disconnect()
                            TeleportToNpc()
                            wait(2)
                            debounce = false
                        end
                    end
                end
            end)
        end)
    end
end


local function NewLevel(Level)
    LevelNum = tonumber(Level)
    if LevelNum >= 1 and LevelNum < 10 then
        getgenv().CurrentMob = "Thug"
    elseif LevelNum >= 10 and LevelNum < 20 then
        getgenv().CurrentMob = "Brute"
    elseif LevelNum >= 20 and LevelNum < 30 then
        getgenv().CurrentMob = "Gorilla"
    elseif LevelNum >= 30 and LevelNum < 45 then
        getgenv().CurrentMob = "Werewolf"
    elseif LevelNum >= 45 and LevelNum < 60 then
        getgenv().CurrentMob = "Zombie"
    elseif LevelNum >= 60 and LevelNum < 80 then
        getgenv().CurrentMob = "Vampire"
    elseif LevelNum >= 80 and LevelNum <= 100 then
        getgenv().CurrentMob = "Golem"
    	if LevelNum >= 100 and getgenv().PrestigeActive == true then
        	getgenv().Autofarm = false
			wait(2)
			game:GetService("ReplicatedStorage").Events.Prestige:InvokeServer()
			wait(4)
			getgenv().Autofarm = true
        end
    end
end


local CoreGUIPath = game.Players.LocalPlayer.PlayerGui.CoreGUI
local LevelText = CoreGUIPath.Frame.EXPBAR.TextLabel
if getgenv().Autofarm then
    LevelText:GetPropertyChangedSignal("Text"):Connect(function()
        local Level = string.match(LevelText.Text, "%d+")
    
        if tonumber(Level) >= 100 and getgenv().PrestigeActive == true then
            game:GetService("ReplicatedStorage").Events.Prestige:InvokeServer()
	    loadstring(game:HttpGet('https://raw.githubusercontent.com/evilevil123/SO/refs/heads/main/stand2.lua'))()	
        end
    
        NewLevel(Level)
    end)
    AutoAssignStats()
    GolemGorilla()
    NewLevel(string.match(LevelText.Text, "%d+"))
    NewQuest(getgenv().CurrentMob)
    wait(2)
    TeleportToNpc()
else
    getgenv().CurrentMob = nil
    getgenv().EnemyHitCount = 0
    EnemiesHit = {}
    EnemiesKilled = {}
    if AutoLoop then
        AutoLoop:Disconnect()
    end
    workspace.Gravity = 196.2
    
end
