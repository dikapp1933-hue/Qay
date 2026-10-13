-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "qayy script | Pet Dice Hub",
   LoadingTitle = "Memuat qayy script...",
   LoadingSubtitle = "Optimized Mobile Edition",
   ConfigurationSaving = { Enabled = false }
})

-- Referensi Remote Events Utama Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetDiceRemotes = ReplicatedStorage:WaitForChild("PetDice"):WaitForChild("Remotes")
local ActionRemote = PetDiceRemotes:WaitForChild("Action")
local CandyStormRemote = PetDiceRemotes:WaitForChild("CandyStorm")

---------------------------------------------------------
-- TAB 1: MAIN & UTILITY (ANTI-AFK & AUTO REBIRTH)
---------------------------------------------------------
local MainTab = Window:CreateTab("Main / Utility", 4483345998)

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
   end,
})

local AutoRebirthEnabled = false

local function startAutoRebirth()
    while AutoRebirthEnabled do
        pcall(function()
            ActionRemote:FireServer("Rebirth")
        end)
        task.wait(2)
    end
end

MainTab:CreateToggle({
   Name = "Auto Rebirth (On/Off)",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
      AutoRebirthEnabled = Value
      if AutoRebirthEnabled then
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Auto Rebirth Aktif!",
             Duration = 2,
             Image = 4483345998,
          })
          task.spawn(startAutoRebirth)
      else
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Auto Rebirth Dimatikan.",
             Duration = 2,
             Image = 4483345998,
          })
      end
   end,
})

---------------------------------------------------------
-- TAB 2: AUTO UPGRADES
---------------------------------------------------------
local UpgradeTab = Window:CreateTab("Auto Upgrades", 4483345998)

local AutoUpgradeEnabled = false

local function startAutoUpgrade()
    while AutoUpgradeEnabled do
        pcall(function()
            ActionRemote:FireServer("BuyAllUpgrades")
            ActionRemote:FireServer("Funnel", "UpgradeTree", 1, nil)
            ActionRemote:FireServer("Funnel", "Dice", 1, nil)
        end)
        task.wait(1.5)
    end
end

UpgradeTab:CreateToggle({
   Name = "Auto Upgrade All (Buy All & Tree)",
   CurrentValue = false,
   Flag = "AutoUpgradeToggle",
   Callback = function(Value)
      AutoUpgradeEnabled = Value
      if AutoUpgradeEnabled then
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Auto Upgrade Aktif!",
             Duration = 2,
             Image = 4483345998,
          })
          task.spawn(startAutoUpgrade)
      end
   end,
})

---------------------------------------------------------
-- TAB 3: CANDY STORM EVENT
---------------------------------------------------------
local EventTab = Window:CreateTab("Candy Storm", 4483345998)

local AutoCandyEnabled = false

CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                hrp.CFrame = CFrame.new(position)
                ActionRemote:FireServer("CollectCandy", candyId)
                ActionRemote:FireServer("CollectItem", candyId)
            end
        end)
    end
end)

EventTab:CreateToggle({
   Name = "Auto Collect Candy Storm",
   CurrentValue = false,
   Flag = "AutoCandyToggle",
   Callback = function(Value)
      AutoCandyEnabled = Value
   end,
})

---------------------------------------------------------
-- TAB 4: WORLD BOSS
---------------------------------------------------------
local BossTab = Window:CreateTab("World Boss", 4483345998)

local AutoBossEnabled = false

local function startAutoBoss()
    while AutoBossEnabled do
        pcall(function()
            ActionRemote:FireServer("WorldBossJoin")
        end)
        task.wait(2)
    end
end

BossTab:CreateToggle({
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
-- TAB 5: MARKET & SHOP (LOOP AUTO BUY)
---------------------------------------------------------
local ShopTab = Window:CreateTab("Market & Shop", 4483345998)

local AutoBuyShopEnabled = false
local BuyInterval = 2 -- Jeda waktu per loop dalam detik

local function startAutoBuyShop()
    while AutoBuyShopEnabled do
        pcall(function()
            ActionRemote:FireServer("MarketBuyAll")
        end)
        task.wait(BuyInterval)
    end
end

ShopTab:CreateToggle({
   Name = "Loop Auto Buy Shop (On/Off)",
   CurrentValue = false,
   Flag = "LoopAutoBuyToggle",
   Callback = function(Value)
      AutoBuyShopEnabled = Value
      if AutoBuyShopEnabled then
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Loop Auto Buy Shop Aktif!",
             Duration = 2,
             Image = 4483345998,
          })
          task.spawn(startAutoBuyShop)
      else
          Rayfield:Notify({
             Title = "qayy script",
             Content = "Loop Auto Buy Shop Dimatikan.",
             Duration = 2,
             Image = 4483345998,
          })
      end
   end,
})

ShopTab:CreateSlider({
   Name = "Kecepatan Loop (Detik)",
   Range = {1, 30},
   Increment = 1,
   Suffix = "Detik",
   CurrentValue = 2,
   Flag = "ShopLoopIntervalSlider",
   Callback = function(Value)
      BuyInterval = Value
   end,
})

ShopTab:CreateButton({
   Name = "Beli Semua Item Market (1x Instant)",
   Callback = function()
      pcall(function()
          ActionRemote:FireServer("MarketBuyAll")
      end)
   end,
})

---------------------------------------------------------
-- NOTIFIKASI SCRIPT SIAP
---------------------------------------------------------
Rayfield:Notify({
   Title = "qayy script Siap!",
   Content = "Loop Auto Buy Shop berhasil dipasang.",
   Duration = 4,
   Image = 4483345998,
})
