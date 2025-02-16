if game.PlaceId == 2281639237 then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
else
    return nil
end    

    local Quests = {
        Thug = "Thug Quest", 
        Brute = "Brute Quest", 
        ["🦍"] = "🦍😡💢 Quest", 
        Werewolf = "Werewolf Quest", 
        Zombie = "Zombie Quest", 
        Vampire = "Vampire Quest", 
        HamonGolem = "Golem Quest"
    }

    getgenv().PlayerLevel = 0
    getgenv().CurrentMob = nil
    getgenv().EnemyHitCount = 0
    local EnemiesHit = {}

    local CheckQuests = true
    local AutoLoop = nil
    local EnemiesKilled = {}
    local KillCounters = {
        Thug = 0,
        Brute = 0,
        ["🦍"] = 0,
        Werewolf = 0,
        Zombie = 0,
        Vampire = 0,
        HamonGolem = 0
    }

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

    local function NewQuest(Enemy)
        local QuestPerson = game.Workspace:FindFirstChild(Quests[Enemy])
        if QuestPerson then
            local ProximityPrompt = QuestPerson:FindFirstChild("ProximityPrompt")
            pcall(function()
                local TPTweenInfo = TweenInfo.new(1.75, Enum.EasingStyle.Linear)
                local tween = game:GetService("TweenService"):Create(
                    game.Players.LocalPlayer.Character.HumanoidRootPart,
                    TPTweenInfo,
                    { CFrame = QuestPerson.HumanoidRootPart.CFrame }
                )
                tween:Play()
            end)
            repeat
                wait()
                fireproximityprompt(ProximityPrompt, 0, true)
            until #player.PlayerGui.Quest.Quest:GetChildren() >= 2
        end
    end

    local function CheckQuestProgress()
        for _, child in player.PlayerGui.Quest.Quest:GetChildren() do
            if child.Name ~= "Sound" then
                print(getgenv().CurrentMob, child.Name)
                if not string.find(child.Name, getgenv().CurrentMob) then
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

    local function EnsureStandSummoned()
        if game.Players.LocalPlayer.Character:FindFirstChild("Stand").Head.Transparency == 1 then
            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.SummonStand:InvokeServer()
        end
    end

    local function CheckPlayerHealth()
        if game.Players.LocalPlayer.Character.Humanoid.Health == 0 then
            wait(4)
            EnsureStandSummoned()
        end
    end

    local function TeleportToNpc()
        pcall(function()
            EnsureStandSummoned()
            AutoAssignStats()
        end)
        CheckQuestProgress()

        Enemy = NewEnemy()
        if not AutoLoop then
            local AutoLoop; AutoLoop = game:GetService("RunService").RenderStepped:Connect(function()
                pcall(function()
                    CheckPlayerHealth()
                    EnsureStandSummoned()
                    if game.Players.LocalPlayer.Character and not debounce then
                        workspace.Gravity = 0
                        local TPTweenInfo = TweenInfo.new(0, Enum.EasingStyle.Linear)
                        local tween = game:GetService("TweenService"):Create(
                            game.Players.LocalPlayer.Character.HumanoidRootPart,
                            TPTweenInfo,
                            { CFrame = Enemy.HumanoidRootPart.CFrame * CFrame.new(0, -5, 5) }
                        )
                        tween:Play()
                        if getgenv().AttackMethod == "Heavy" then
                            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Heavy:InvokeServer()
                        elseif getgenv().AttackMethod == "Punch" then
                            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Punch:InvokeServer()
                        else
                            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Heavy:InvokeServer()
                            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Punch:InvokeServer()
                            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Events.Barrage:InvokeServer()
                        end

                        if not Enemy or not Enemy:FindFirstChild("Humanoid") or (Enemy:FindFirstChild("Humanoid") and Enemy.Humanoid.Health == 0) then
                            if not debounce then
                                debounce = true
                                EnemiesKilled[Enemy] = true
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
        local LevelNum = tonumber(Level)
        if LevelNum >= 1 and LevelNum < 10 then
            getgenv().CurrentMob = "Thug"
        elseif LevelNum >= 10 and LevelNum < 20 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.ThugQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "Brute"
        elseif LevelNum >= 20 and LevelNum < 30 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.BruteQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "🦍"
        elseif LevelNum >= 30 and LevelNum < 45 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.GorillaQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "Werewolf"
        elseif LevelNum >= 45 and LevelNum < 60 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.WerewolfQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "Zombie"
        elseif LevelNum >= 60 and LevelNum < 80 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.ZombieQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "Vampire"
        elseif LevelNum >= 80 and LevelNum < 100 then
            if LevelNum == 100 then
                getgenv().CurrentMob = "HamonGolem"
                NewQuest(getgenv().CurrentMob)
            else
                game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.VampireQuest.Remotes.Cancel:FireServer()
                getgenv().CurrentMob = "HamonGolem"
        end
    end

    function AutoAssignStats()
        local skillPointsText = game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.aSkillPoints.Text
        local skillPoints = tonumber(string.match(skillPointsText, "%d+"))
        if skillPoints and skillPoints > 0 then
            game:GetService("Players").LocalPlayer.PlayerGui.CoreGUI.Stats.Stats.Stats:InvokeServer("Strength", tostring(skillPoints))
        end
    end

    function StopAllActions()
        if AutoLoop then
            AutoLoop:Disconnect()
            AutoLoop = nil
        end
        debounce = false
        workspace.Gravity = 196.2 -- Reset gravity to default
        getgenv().CurrentMob = nil -- Clear the current mob
    end

    function RefreshScript()
        StopAllActions()
        Reinitialize()
        EnsureStandSummoned()
    end

    function Reinitialize()
        getgenv().PlayerLevel = 0
        getgenv().CurrentMob = "Thug"
        getgenv().EnemyHitCount = 0
        EnemiesHit = {}
        EnemiesKilled = {}
        KillCounters = {
            Thug = 0,
            Brute = 0,
            ["🦍"] = 0,
            Werewolf = 0,
            Zombie = 0,
            Vampire = 0,
            HamonGolem = 0
        }
        NewLevel(1)
        NewQuest(getgenv().CurrentMob)
        wait(2)
        TeleportToNpc()
    end

    function RejoinServer()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        local JobId = game.JobId
        local Players = game:GetService("Players")

        if #Players:GetPlayers() <= 1 then
            Players.LocalPlayer:Kick("\nRejoining...")
            wait()
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
        end
    end

    local CoreGUIPath = game.Players.LocalPlayer.PlayerGui.CoreGUI
    local LevelText = CoreGUIPath.Frame.EXPBAR.TextLabel

    LevelText:GetPropertyChangedSignal("Text"):Connect(function()
        local Level = string.match(LevelText.Text, "%d+")

        if tonumber(Level) >= 100 and getgenv().PrestigeActive then
            StopAllActions()
            wait(5)
            game:GetService("ReplicatedStorage").Events.Prestige:InvokeServer()
            wait(2)
            RejoinServer()
            
        end
        NewLevel(Level)
        AutoAssignStats()
        EnsureStandSummoned()
    end)

    NewLevel(string.match(LevelText.Text, "%d+"))
    NewQuest(getgenv().CurrentMob)
    wait(2)
    TeleportToNpc()
    EnsureStandSummoned()

