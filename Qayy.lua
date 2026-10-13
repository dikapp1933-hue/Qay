-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "qayy script | Pet Dice Hub (Lite)",
   LoadingTitle = "Memuat qayy script...",
   LoadingSubtitle = "Fixed Anti-AFK Edition",
   ConfigurationSaving = { Enabled = false }
})

-- Referensi Remote Events Utama Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetDiceRemotes = ReplicatedStorage:WaitForChild("PetDice"):WaitForChild("Remotes")
local ActionRemote = PetDiceRemotes:WaitForChild("Action")
local CandyStormRemote = PetDiceRemotes:WaitForChild("CandyStorm")

-- Status Variabel Fitur
local AntiAFKEnabled = true
local AutoRebirthEnabled = false
local AutoUpgradeEnabled = false
local AutoBossEnabled = false
local AutoBuyShopEnabled = false
local AutoCandyEnabled = false

---------------------------------------------------------
-- SISTEM ANTI-AFK TERPERBARUI (WORK UNTUK EXECUTOR MOBILE)
---------------------------------------------------------
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

-- 1. Anti-Idle Disconnect Handler
Players.LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Unknown, false, game)
    end
end)

-- 2. Anti-AFK Loop Tambahan (Simulasi Gerak/Lompat Ringan)
task.spawn(function()
    while true do
        task.wait(120) -- Berjalan tiap 2 menit sekali
        if AntiAFKEnabled then
            pcall(function()
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    -- Simulasi lompat kecil agar terdeteksi aktif oleh server
                    char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
end)

---------------------------------------------------------
-- CENTRALIZED LIGHTWEIGHT LOOP (1 LOOP SEMUA FITUR)
---------------------------------------------------------
task.spawn(function()
    while task.wait(2.5) do
        pcall(function()
            if AutoUpgradeEnabled then
                ActionRemote:FireServer("BuyAllUpgrades")
                ActionRemote:FireServer("Funnel", "UpgradeTree", 1, nil)
            end

            if AutoRebirthEnabled then
                ActionRemote:FireServer("Rebirth")
            end

            if AutoBossEnabled then
                ActionRemote:FireServer("WorldBossJoin")
            end

            if AutoBuyShopEnabled then
                ActionRemote:FireServer("MarketBuyAll")
            end
        end)
    end
end)

---------------------------------------------------------
-- TAB 1: MAIN & UTILITY
---------------------------------------------------------
local MainTab = Window:CreateTab("Main / Utility", 4483345998)

MainTab:CreateToggle({
   Name = "Anti-AFK (Fix Anti Disconnect)",
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

MainTab:CreateToggle({
   Name = "Auto Rebirth (On/Off)",
   CurrentValue = false,
   Flag = "AutoRebirthToggle",
   Callback = function(Value)
      AutoRebirthEnabled = Value
   end,
})

---------------------------------------------------------
-- TAB 2: AUTO UPGRADES
---------------------------------------------------------
local UpgradeTab = Window:CreateTab("Auto Upgrades", 4483345998)

UpgradeTab:CreateToggle({
   Name = "Auto Upgrade All (Buy All & Tree)",
   CurrentValue = false,
   Flag = "AutoUpgradeToggle",
   Callback = function(Value)
      AutoUpgradeEnabled = Value
   end,
})

---------------------------------------------------------
-- TAB 3: CANDY STORM EVENT
---------------------------------------------------------
local EventTab = Window:CreateTab("Candy Storm", 4483345998)

CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                hrp.CFrame = CFrame.new(position)
                ActionRemote:FireServer("CollectCandy", candyId)
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

BossTab:CreateToggle({
   Name = "Auto Join World Boss",
   CurrentValue = false,
   Flag = "AutoBossToggle",
   Callback = function(Value)
      AutoBossEnabled = Value
   end,
})

---------------------------------------------------------
-- TAB 5: MARKET & SHOP
---------------------------------------------------------
local ShopTab = Window:CreateTab("Market & Shop", 4483345998)

ShopTab:CreateToggle({
   Name = "Auto Buy Shop (On/Off)",
   CurrentValue = false,
   Flag = "LoopAutoBuyToggle",
   Callback = function(Value)
      AutoBuyShopEnabled = Value
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
-- NOTIFIKASI
---------------------------------------------------------
Rayfield:Notify({
   Title = "qayy script Loaded!",
   Content = "Anti-AFK berhasil diperbaiki.",
   Duration = 3,
   Image = 4483345998,
})
