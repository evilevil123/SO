local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Autofarm Script",
    LoadingTitle = "Loading Autofarm Script",
    LoadingSubtitle = "by vinnydinny",
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


local AutoFarmToggle = MainTab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = autofarmEnabled,
    Flag = "AutofarmToggle",
    Callback = function(Value)
        autofarmEnabled = Value
        if autofarmEnabled then
            autofarmStarted()
        else
            autofarmStopped()
        end
    end
})


local TogglePrestige = MainTab:CreateToggle({
    Name = "Auto Prestige",
    CurrentValue = false,
    Flag = "PrestigeActive",
    Callback = function(Value)
        getgenv().PrestigeActive = Value
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

local function purchaseItem(itemName, itemAmount)
    local item = workspace.Purchasable:FindFirstChild(itemName)
    if item then
        local clickDetector = item.ClickDetector
        if clickDetector then
            for i = 1, itemAmount do
                fireclickdetector(clickDetector)
                wait(0.01)-- Adjust the wait time as needed
            end
            print("Purchased " .. itemAmount .. " of: " .. tostring(itemName))
        else
            print("No ClickDetector found for: " .. tostring(itemName))
        end
    else
        print("Item not found in workspace.Purchasable: " .. tostring(itemName))
    end
end

local itemAmount = 1

local Input = ItemTab:CreateInput({
    Name = "Amount",
    CurrentValue = tostring(itemAmount),
    PlaceholderText = "Enter amount",
    RemoveTextAfterFocusLost = false,
    Flag = "ItemAmount",
    Callback = function(Text)
        itemAmount = tonumber(Text) or itemAmount
    end
})

for _, itemName in ipairs(items) do
    ItemTab:CreateButton({
        Name = "Purchase " .. itemName,
        Callback = function()
            purchaseItem(itemName, itemAmount)
        end
    })
end
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local itemsFolder = workspace:FindFirstChild("Items")
local localPlayer = Players.LocalPlayer
local miningEnabled = false


-- Function to enable/disable noclip
local function setNoclip(enabled)
    local character = localPlayer and localPlayer.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

-- Function to move the player to the MiningNode
local function movePlayer(targetCFrame, callback)
    local character = localPlayer and localPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            -- Enable noclip
            setNoclip(true)

            -- Tween player to the target position
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})

            tween:Play()
            tween.Completed:Connect(function()
                -- Disable noclip
                setNoclip(false)
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
                        fireproximityprompt(prompt, 1, true) -- Fire the ProximityPrompt
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

SettingsTab:CreateButton({
    Name = "Refresh Script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/evilevil123/SO/refs/heads/main/stand2.lua"))()
    end
})

SettingsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        RejoinServer()
    end
})

SettingsTab:CreateButton({
    Name = "Save into autoexec",
    Callback = function()
        local Autoexec = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/evilevil123/SO/refs/heads/main/stand2.lua")
        writefile("autoexec.lua", Autoexec)
    end
})

-- Anti-AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

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
    end
end
function autofarmStopped()
    if AutoLoop then
        AutoLoop:Disconnect()
        AutoLoop = nil
    end
    debounce = false
    workspace.Gravity = 196.2 -- Reset gravity to default
    getgenv().CurrentMob = nil -- Clear the current mob
end



function autofarmStarted()
    if autofarmEnabled then          
        GolemGorilla()
        NewLevel(string.match(getgenv().LevelText.Text, "%d+"))
        NewQuest(getgenv().CurrentMob)
        wait(2)
        TeleportToNpc()
    else
        autofarmStopped()
    end
end

local CoreGUIPath = game.Players.LocalPlayer.PlayerGui.CoreGUI
getgenv().LevelText = CoreGUIPath.Frame.EXPBAR.TextLabel
getgenv().LevelText:GetPropertyChangedSignal("Text"):Connect(function()
    local Level = string.match(getgenv().LevelText.Text, "%d+")

    if tonumber(Level) >= 100 and getgenv().PrestigeActive == true then
        AutoFarmToggle:Set(false)
        wait(5)
        game:GetService("ReplicatedStorage").Events.Prestige:InvokeServer()
        wait(2)
        AutoFarmToggle:Set(true) 
    end
    NewLevel(Level)
    AutoAssignStats()
end)
