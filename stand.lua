if game.PlaceId == 2281639237 then
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
else
    return nil
end    

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Autofarm Script",
    LoadingTitle = "Loading Autofarm Script",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil, -- Create a custom folder for your hub/game
        FileName = "AutofarmScript"
    },
    Discord = {
        Enabled = false,
        Invite = "", -- The Discord invite code, do not include discord.gg/
        RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
        Title = "Autofarm Script",
        Subtitle = "Key System",
        Note = "Join the discord (discord.gg/...)",
        FileName = "AutofarmScriptKey",
        SaveKey = true,
        GrabKeyFromSite = false, -- If this is true, set Key to the site you want to grab the key from
        Key = "ABCDEF"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458) -- Title, Image
local ItemTab = Window:CreateTab("Items", 4483362458) -- Title, Image
local MiningTab = Window:CreateTab("Mining", 4483362458) -- Title, Image
local SettingsTab = Window:CreateTab("Settings", 4483362458) -- Title, Image

local tweenSpeed = 1.75
local autofarmEnabled = false

local Slider = MainTab:CreateSlider({
    Name = "Tween Speed",
    Range = {0.5, 5},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = tweenSpeed,
    Flag = "TweenSpeedSlider",
    Callback = function(Value)
        tweenSpeed = Value
    end
})

local Toggle = MainTab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = autofarmEnabled,
    Flag = "AutofarmToggle",
    Callback = function(Value)
        autofarmEnabled = Value
        if autofarmEnabled then
            InitializeScript()
        else

            DeinitializeScript()
        end
    end
})

local ButtonPrestige = MainTab:CreateButton({
    Name = "Prestige",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.Prestige:InvokeServer()
        wait(2)
        RejoinServer()
    end
})

local ButtonLowerQuest = MainTab:CreateButton({
    Name = "Grab Lower Level Quest",
    Callback = function()
        GrabLowerLevelQuest()
    end
})

local items = {}
local itemSet = {}

for _, item in pairs(workspace.Purchasable:GetChildren()) do
    if not itemSet[item.Name] then
        table.insert(items, item.Name)
        itemSet[item.Name] = true
    end
end

local function purchaseItem(itemName)
    local item = workspace.Purchasable:FindFirstChild(itemName)
    if item then
        local clickDetector = item.ClickDetector
        if clickDetector then
            local initialCount = #game.Players.LocalPlayer.Backpack:GetChildren()
            local newCount
            repeat
                fireclickdetector(clickDetector)
                wait(0.1) -- Adjust the wait time as needed
                newCount = #game.Players.LocalPlayer.Backpack:GetChildren()
            until newCount == initialCount
            print("Purchased max of: " .. tostring(itemName))
        else
            print("No ClickDetector found for: " .. tostring(itemName))
        end
    else
        print("Item not found in workspace.Purchasable: " .. tostring(itemName))
    end
end



for _, itemName in ipairs(items) do
    ItemTab:CreateButton({
        Name = "Purchase " .. itemName,
        Callback = function()
            purchaseItem(itemName)
        end
    })
end
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local itemsFolder = workspace:FindFirstChild("Items")
local localPlayer = Players.LocalPlayer
local miningEnabled = false

-- Function to fire a ProximityPrompt
local function fireproximityprompt2(Obj, Amount, Skip)
    if Obj.ClassName == "ProximityPrompt" then 
        Amount = Amount or 1
        local PromptTime = Obj.HoldDuration
        if Skip then 
            Obj.HoldDuration = 0
        end
        for i = 1, Amount do 
            Obj:InputHoldBegin()
            if not Skip then 
                wait(Obj.HoldDuration)
            end
            Obj:InputHoldEnd()
        end
        Obj.HoldDuration = PromptTime
    else 
        error("userdata<ProximityPrompt> expected")
    end
end

-- Function to move the player to the MiningNode
local function movePlayer(targetCFrame, callback)
    local character = localPlayer and localPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Tween player to the target position
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})

            tween:Play()
            tween.Completed:Connect(function()
                if callback then callback() end -- Fire ProximityPrompt after reaching
            end)
        end
    end
end

-- Function to recursively search for "MiningNode" and interact with its ProximityPrompt
local function findMiningNodes(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("Model") and child.Name == "MiningNode" then
            local primaryPart = child.PrimaryPart -- Ensure it has a PrimaryPart
            if primaryPart then
                -- Find the ProximityPrompt inside the MiningNode
                local prompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    -- Move the player to the MiningNode’s position
                    movePlayer(primaryPart.CFrame, function()
                        fireproximityprompt2(prompt, 1, true) -- Fire the ProximityPrompt
                    end)
                else
                    warn("No ProximityPrompt found in: " .. child:GetFullName())
                end
            else
                warn("MiningNode missing PrimaryPart: " .. child:GetFullName())
            end
        elseif child:IsA("Model") or child:IsA("Folder") then
            -- Recursively check children
            findMiningNodes(child)
        end
    end
end

-- Function to repeatedly check for MiningNodes every 2 seconds
local function startChecking()
    while miningEnabled do
        if itemsFolder then
            findMiningNodes(itemsFolder)
        else
            warn("workspace.Items folder not found!")
        end
        wait(2) -- Check every 2 seconds
    end
end

-- Toggle to start/stop mining
MiningTab:CreateToggle({
    Name = "Enable Mining",
    CurrentValue = miningEnabled,
    Flag = "MiningToggle",
    Callback = function(Value)
        miningEnabled = Value
        if miningEnabled then
            task.spawn(startChecking)
        end
    end
})

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
            local TPTweenInfo = TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear)
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
    local success, error = pcall(function()
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
        elseif LevelNum >= 80 and LevelNum <= 100 then
            game:GetService("Players").LocalPlayer.PlayerGui.Quest.Quest.VampireQuest.Remotes.Cancel:FireServer()
            getgenv().CurrentMob = "HamonGolem"
            if NewQuest ~= "Golem Quest" then
                NewQuest("HamonGolem")
            end
        end
    end)
    if not success then
        return nil
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

function GrabLowerLevelQuest()
    local Level = tonumber(string.match(getgenv().LevelText.Text, "%d+"))
    if Level >= 1 and Level < 10 then
        NewQuest("Thug")
    elseif Level >= 10 and Level < 20 then
        NewQuest("Thug")
    elseif Level >= 20 and Level < 30 then
        NewQuest("Brute")
    elseif Level >= 30 and Level < 45 then
        NewQuest("🦍")
    elseif Level >= 45 and Level < 60 then
        NewQuest("Werewolf")
    elseif Level >= 60 and Level < 80 then
        NewQuest("Zombie")
    elseif Level >= 80 and Level <= 100 then
        NewQuest("Vampire")
    end
end

function InitializeScript()
    GrabLowerLevelQuest()
	wait(tweenSpeed + 0.5)
    NewLevel(string.match(getgenv().LevelText.Text, "%d+"))
    NewQuest(getgenv().CurrentMob)
    wait(2)
    TeleportToNpc()
    EnsureStandSummoned()
end

function DeinitializeScript()
    StopAllActions()
end

local CoreGUIPath = game.Players.LocalPlayer.PlayerGui.CoreGUI
getgenv().LevelText = CoreGUIPath.Frame.EXPBAR.TextLabel

getgenv().LevelText:GetPropertyChangedSignal("Text"):Connect(function()
    local Level = string.match(getgenv().LevelText.Text, "%d+")

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
