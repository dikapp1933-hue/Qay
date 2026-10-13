-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "qayy script | Pet Dice Hub",
   LoadingTitle = "Memuat qayy script...",
   LoadingSubtitle = "Vertical UI Layout",
   ConfigurationSaving = { Enabled = false }
})

-- Referensi Remote Events Utama Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetDiceRemotes = ReplicatedStorage:WaitForChild("PetDice"):WaitForChild("Remotes")
local ActionRemote = PetDiceRemotes:WaitForChild("Action")
local CandyStormRemote = PetDiceRemotes:WaitForChild("CandyStorm")

---------------------------------------------------------
-- TAB UTAMA: ALL FEATURES (VERTUKAL / ATAS KE BAWAH)
---------------------------------------------------------
local MainTab = Window:CreateTab("Main Menu", 4483345998)

---------------------------------------------------------
-- SECTION 1: UTILITY & PROTECTION
---------------------------------------------------------
MainTab:CreateSection("--- UTILITY & UTAMA ---")

local AntiAFKEnabled = true
local VirtualUser = game:GetService("VirtualUser")

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

MainTab:CreateToggle({
   Name = "Anti-AFK (Anti Disconnect)",
   CurrentValue = true,
   Flag = "AntiAFKToggle",
   Callback = function(Value)
      AntiAFKEnabled = Value
      if AntiAFKEnabled then
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Anti-AFK Aktif!",
             Duration = 2,
             Image = 4483345998,
          })
      end
   end,
})

MainTab:CreateButton({
   Name = "Equip Best (Pakai Best Pet/Dice)",
   Callback = function()
      pcall(function()
          ActionRemote:FireServer("EquipBest")
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Berhasil memakai equipment terbaik!",
             Duration = 2,
             Image = 4483345998,
          })
      end)
   end,
})

---------------------------------------------------------
-- SECTION 2: CANDY STORM EVENT
---------------------------------------------------------
MainTab:CreateSection("--- CANDY STORM EVENT ---")

local AutoCandyEnabled = false

CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                hrp.CFrame = CFrame.new(position)
                
                Rayfield:Notify({
                   Title = "qayy script",
                   Content = "Mengambil " .. tostring(itemName) .. "!",
                   Duration = 1.5,
                   Image = 4483345998,
                })

                ActionRemote:FireServer("CollectCandy", candyId)
                ActionRemote:FireServer("CollectItem", candyId)
            end
        end)
    end
end)

MainTab:CreateToggle({
   Name = "Auto Collect Candy Storm",
   CurrentValue = false,
   Flag = "AutoCandyToggle",
   Callback = function(Value)
      AutoCandyEnabled = Value
   end,
})

---------------------------------------------------------
-- SECTION 3: WORLD BOSS
---------------------------------------------------------
MainTab:CreateSection("--- WORLD BOSS ---")

local AutoBossEnabled = false

local function startAutoBoss()
    while AutoBossEnabled do
        pcall(function()
            ActionRemote:FireServer("WorldBossJoin")
        end)
        task.wait(2)
    end
end

MainTab:CreateToggle({
   Name = "Auto Join World Boss",
   CurrentValue = false,
   Flag = "AutoBossToggle",
   Callback = function(Value)
      AutoBossEnabled = Value
      if AutoBossEnabled then
          task.spawn(startAutoBoss)
      end
   end,
})

---------------------------------------------------------
-- SECTION 4: AUTO CLAIM & UPGRADES
---------------------------------------------------------
MainTab:CreateSection("--- AUTO CLAIM & UPGRADE ---")

local AutoClaimEnabled = false
local AutoUpgradeEnabled = false

local function startAutoClaim()
    while AutoClaimEnabled do
        pcall(function()
            -- Daily & Weekly Quest Claim
            ActionRemote:FireServer("QuestClaim", "Daily", 1)
            ActionRemote:FireServer("QuestClaim", "Weekly", 1)
            
            -- Goals Claim (Halloween & Infinity25)
            ActionRemote:FireServer("HalloweenGoalClaim", "Minutes")
            ActionRemote:FireServer("GoalClaim", "infinity25")
            
            -- Playtime Rewards Claim (Slot 1-12)
            for i = 1, 12 do
                ActionRemote:FireServer("ClaimPlaytime", i)
            end
        end)
        task.wait(5)
    end
end

local function startAutoUpgrade()
    while AutoUpgradeEnabled do
        pcall(function()
            ActionRemote:FireServer("Funnel", "UpgradeTree", 1, nil)
            ActionRemote:FireServer("Funnel", "Dice", 1, nil)
        end)
        task.wait(3)
    end
end

MainTab:CreateToggle({
   Name = "Auto Claim All (Daily, Weekly, Goals, Playtime)",
   CurrentValue = false,
   Flag = "AutoClaimToggle",
   Callback = function(Value)
      AutoClaimEnabled = Value
      if AutoClaimEnabled then
          task.spawn(startAutoClaim)
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Upgrade (Tree & Dice)",
   CurrentValue = false,
   Flag = "AutoUpgradeToggle",
   Callback = function(Value)
      AutoUpgradeEnabled = Value
      if AutoUpgradeEnabled then
          task.spawn(startAutoUpgrade)
      end
   end,
})

MainTab:CreateButton({
   Name = "Rebirth Instant (1x)",
   Callback = function()
      pcall(function()
          ActionRemote:FireServer("Funnel", "Rebirth", 2, nil)
      end)
   end,
})

---------------------------------------------------------
-- SECTION 5: MARKET & SHOP
---------------------------------------------------------
MainTab:CreateSection("--- MARKET & SHOP ---")

local AutoBuyAllEnabled = false

local function startAutoBuyAll()
    while AutoBuyAllEnabled do
        pcall(function()
            ActionRemote:FireServer("MarketBuyAll")
        end)
        task.wait(2)
    end
end

MainTab:CreateButton({
   Name = "Beli Semua Item Market (1x)",
   Callback = function()
      pcall(function()
          ActionRemote:FireServer("MarketBuyAll")
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Market Buy All terisi!",
             Duration = 2,
             Image = 4483345998,
          })
      end)
   end,
})

MainTab:CreateToggle({
   Name = "Auto Buy All Market (Loop)",
   CurrentValue = false,
   Flag = "AutoBuyAllToggle",
   Callback = function(Value)
      AutoBuyAllEnabled = Value
      if AutoBuyAllEnabled then
          task.spawn(startAutoBuyAll)
      end
   end,
})

---------------------------------------------------------
-- NOTIFIKASI
---------------------------------------------------------
Rayfield:Notify({
   Title = "qayy script Dimuat!",
   Content = "Weekly Quest & Infinity25 Goal sudah ditambahkan.",
   Duration = 4,
   Image = 4483345998,
})
