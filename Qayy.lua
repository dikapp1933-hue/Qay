-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "qayy script | Pet Dice Hub",
   LoadingTitle = "Memuat qayy script...",
   LoadingSubtitle = "by Delta Executor",
   ConfigurationSaving = { Enabled = false }
})

-- Referensi Remote Events Utama Game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetDiceRemotes = ReplicatedStorage:WaitForChild("PetDice"):WaitForChild("Remotes")
local ActionRemote = PetDiceRemotes:WaitForChild("Action")
local CandyStormRemote = PetDiceRemotes:WaitForChild("CandyStorm")

---------------------------------------------------------
-- TAB 1: MAIN & ANTI-AFK
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
      if AntiAFKEnabled then
          Rayfield:Notify({
             Title = "qayy script | Anti-AFK",
             Content = "Kamu tidak akan terkeluar (kick) saat AFK lama.",
             Duration = 3,
             Image = 4483345998,
          })
      else
          Rayfield:Notify({
             Title = "qayy script | Anti-AFK",
             Content = "Sistem perlindungan AFK dinonaktifkan.",
             Duration = 3,
             Image = 4483345998,
          })
      end
   end,
})

---------------------------------------------------------
-- TAB 2: CANDY STORM / EVENT COLLECTOR
---------------------------------------------------------
local EventTab = Window:CreateTab("Candy Storm", 4483345998)
local AutoCandyEnabled = false

-- Listener untuk Auto Collect Candy Storm (CandyBag, CandyCorn, dll)
CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                -- Teleport langsung ke lokasi item yang jatuh
                hrp.CFrame = CFrame.new(position)
                
                -- Notifikasi singkat tentang item yang diambil
                Rayfield:Notify({
                   Title = "qayy script | Candy Collected",
                   Content = "Mengambil " .. tostring(itemName) .. "!",
                   Duration = 1.5,
                   Image = 4483345998,
                })

                -- Memanggil remote action pengumpulan item jika server membutuhkannya
                ActionRemote:FireServer("CollectCandy", candyId)
                ActionRemote:FireServer("CollectItem", candyId)
            end
        end)
    end
end)

EventTab:CreateToggle({
   Name = "Auto Collect Candy Storm (Bag & Corn)",
   CurrentValue = false,
   Flag = "AutoCandyToggle",
   Callback = function(Value)
      AutoCandyEnabled = Value
      if AutoCandyEnabled then
          Rayfield:Notify({
             Title = "qayy script | Candy Storm",
             Content = "Auto Collect Aktif! Akan mengambil CandyBag & CandyCorn.",
             Duration = 3,
             Image = 4483345998,
          })
      else
          Rayfield:Notify({
             Title = "qayy script | Candy Storm",
             Content = "Auto Collect Candy Storm Dimatikan.",
             Duration = 3,
             Image = 4483345998,
          })
      end
   end,
})

---------------------------------------------------------
-- TAB 3: WORLD BOSS
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
          Rayfield:Notify({
             Title = "qayy script | World Boss",
             Content = "Mencoba masuk ke World Boss...",
             Duration = 3,
             Image = 4483345998,
          })
          task.spawn(startAutoBoss)
      else
          Rayfield:Notify({
             Title = "qayy script | World Boss",
             Content = "Fitur dimatikan.",
             Duration = 3,
             Image = 4483345998,
          })
      end
   end,
})

---------------------------------------------------------
-- TAB 4: MARKET / SHOP
---------------------------------------------------------
local ShopTab = Window:CreateTab("Market & Shop", 4483345998)
local AutoBuyAllEnabled = false

local function startAutoBuyAll()
    while AutoBuyAllEnabled do
        pcall(function()
            ActionRemote:FireServer("MarketBuyAll")
        end)
        task.wait(2)
    end
end

ShopTab:CreateButton({
   Name = "Beli Semua Item Market Sekarang (1x)",
   Callback = function()
      pcall(function()
          ActionRemote:FireServer("MarketBuyAll")
          Rayfield:Notify({
             Title = "qayy script | Market",
             Content = "Berhasil mengirim perintah MarketBuyAll!",
             Duration = 3,
             Image = 4483345998,
          })
      end)
   end,
})

ShopTab:CreateToggle({
   Name = "Auto Buy All Market (Loop)",
   CurrentValue = false,
   Flag = "AutoBuyAllToggle",
   Callback = function(Value)
      AutoBuyAllEnabled = Value
      if AutoBuyAllEnabled then
          Rayfield:Notify({
             Title = "qayy script | Market",
             Content = "Membeli semua item di market secara otomatis...",
             Duration = 3,
             Image = 4483345998,
          })
          task.spawn(startAutoBuyAll)
      else
          Rayfield:Notify({
             Title = "qayy script | Market",
             Content = "Fitur dimatikan.",
             Duration = 3,
             Image = 4483345998,
          })
      end
   end,
})

---------------------------------------------------------
-- NOTIFIKASI SCRIPT SIAP
---------------------------------------------------------
Rayfield:Notify({
   Title = "qayy script Berhasil Dimuat!",
   Content = "Anti-AFK, Candy Storm, World Boss, dan Market Siap Digunakan.",
   Duration = 5,
   Image = 4483345998,
})
