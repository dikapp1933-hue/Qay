-- Destroy UI Lama jika ada (Mencegah Menumpuk)
if game:GetService("CoreGui"):FindFirstChild("qayyScriptHub") then
    game:GetService("CoreGui").qayyScriptHub:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Remote Events Game
local PetDiceRemotes = ReplicatedStorage:WaitForChild("PetDice"):WaitForChild("Remotes")
local ActionRemote = PetDiceRemotes:WaitForChild("Action")
local CandyStormRemote = PetDiceRemotes:WaitForChild("CandyStorm")

-- Status Variabel (Toggle State)
local AntiAFKEnabled = true
local AutoRebirthEnabled = false
local AutoUpgradeEnabled = false
local AutoBossEnabled = false
local AutoBuyShopEnabled = false
local AutoCandyEnabled = false

---------------------------------------------------------
-- FUNGSI TELEPORT SMART SEARCH
---------------------------------------------------------
local function TeleportToName(possibleNames)
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local targetPart = nil

        -- Cari Objek di Workspace berdasarkan nama
        for _, obj in ipairs(workspace:GetDescendants()) do
            for _, name in ipairs(possibleNames) do
                if string.lower(obj.Name) == string.lower(name) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                    targetPart = obj
                    break
                end
            end
            if targetPart then break end
        end

        if targetPart then
            if targetPart:IsA("Model") then
                local primary = targetPart.PrimaryPart or targetPart:FindFirstChildOfClass("BasePart")
                if primary then
                    hrp.CFrame = primary.CFrame * CFrame.new(0, 3, 0)
                end
            elseif targetPart:IsA("BasePart") then
                hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
            end
        else
            -- Notifikasi jika lokasi tidak ditemukan di workspace
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "qayy script",
                Text = "Area tidak ditemukan di map saat ini!",
                Duration = 2
            })
        end
    end)
end

---------------------------------------------------------
-- ANTI-AFK STABIL
---------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

---------------------------------------------------------
-- CENTRAL LOOP (RINGAN)
---------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(2.5)
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
-- SCREENGUI UTAMA
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "qayyScriptHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

---------------------------------------------------------
-- 1. TOMBOL BULAT MINIMIZE (LUFFY)
---------------------------------------------------------
local LuffyBtn = Instance.new("ImageButton")
LuffyBtn.Name = "LuffyMinimizeBtn"
LuffyBtn.Parent = ScreenGui
LuffyBtn.Size = UDim2.new(0, 50, 0, 50)
LuffyBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
LuffyBtn.Image = "rbxassetid://13838423223"
LuffyBtn.BackgroundTransparency = 1
LuffyBtn.Active = true
LuffyBtn.Draggable = true
LuffyBtn.Visible = false

local CornerLuffy = Instance.new("UICorner", LuffyBtn)
CornerLuffy.CornerRadius = UDim.new(1, 0)

local StrokeLuffy = Instance.new("UIStroke", LuffyBtn)
StrokeLuffy.Color = Color3.fromRGB(255, 255, 255)
StrokeLuffy.Thickness = 2

---------------------------------------------------------
-- 2. FRAME UTAMA SCRIPT
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 350)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local CornerFrame = Instance.new("UICorner", MainFrame)
CornerFrame.CornerRadius = UDim.new(0, 10)

-- Header / Judul
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "  qayy script | Mobile Hub"
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CornerTitle = Instance.new("UICorner", TitleLabel)
CornerTitle.CornerRadius = UDim.new(0, 10)

-- Tombol Minimize (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = MainFrame
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Text = "-"
MinimizeBtn.TextSize = 22
MinimizeBtn.Font = Enum.Font.SourceSansBold

local CornerMinimize = Instance.new("UICorner", MinimizeBtn)
CornerMinimize.CornerRadius = UDim.new(0, 8)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    LuffyBtn.Visible = true
end)

LuffyBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    LuffyBtn.Visible = false
end)

---------------------------------------------------------
-- SISTEM TAB VERTIKAL
---------------------------------------------------------
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(0, 90, 1, -40)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.Size = UDim2.new(1, -105, 1, -45)
Container.Position = UDim2.new(0, 100, 0, 40)
Container.BackgroundTransparency = 1

local tabs = {}

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Parent = TabBar
    TabButton.Size = UDim2.new(1, 0, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Text = name
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.SourceSans
    
    local CornerTab = Instance.new("UICorner", TabButton)
    CornerTab.CornerRadius = UDim.new(0, 6)

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Parent = Container
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = false
    TabPage.ScrollBarThickness = 4
    
    local PageList = Instance.new("UIListLayout", TabPage)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Padding = UDim.new(0, 8)

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    table.insert(tabs, {Btn = TabButton, Page = TabPage})
    return TabPage
end

local function CreateToggle(parent, text, default, callback)
    local state = default
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = parent
    ToggleBtn.Size = UDim2.new(1, -5, 0, 35)
    ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = text .. " : " .. (state and "ON" or "OFF")
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.SourceSansBold

    local Corner = Instance.new("UICorner", ToggleBtn)
    Corner.CornerRadius = UDim.new(0, 6)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        ToggleBtn.Text = text .. " : " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -5, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = text
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSansBold

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(callback)
end

---------------------------------------------------------
-- HALAMAN TAB & FITUR
---------------------------------------------------------
local MainTabPage = CreateTab("Main")
local TeleportTabPage = CreateTab("Teleport")
local UpgradeTabPage = CreateTab("Upgrades")
local EventTabPage = CreateTab("Events")
local BossTabPage = CreateTab("World Boss")
local ShopTabPage = CreateTab("Shop")

-- Tab Default
tabs[1].Page.Visible = true
tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- TAB 1: Main
CreateToggle(MainTabPage, "Anti-AFK", AntiAFKEnabled, function(v) AntiAFKEnabled = v end)
CreateToggle(MainTabPage, "Auto Rebirth", AutoRebirthEnabled, function(v) AutoRebirthEnabled = v end)

-- TAB 2: Teleport (Mencari berdasarkan nama objek asli di game)
CreateButton(TeleportTabPage, "Teleport to Grades", function()
    TeleportToName({"Grade", "Grades", "GradeMachine", "GradeBoard"})
end)

CreateButton(TeleportTabPage, "Teleport to Tower", function()
    TeleportToName({"Tower", "Towers", "TowerEntrance", "TowerPortal"})
end)

CreateButton(TeleportTabPage, "Teleport to World Boss", function()
    TeleportToName({"WorldBoss", "Boss", "BossPortal", "BossArea"})
end)

CreateButton(TeleportTabPage, "Teleport to Traits", function()
    TeleportToName({"Trait", "Traits", "TraitMachine", "TraitReroll"})
end)

-- TAB 3: Upgrades
CreateToggle(UpgradeTabPage, "Auto Upgrade All", AutoUpgradeEnabled, function(v) AutoUpgradeEnabled = v end)

-- TAB 4: Events
CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                ActionRemote:FireServer("CollectCandy", candyId)
            end
        end)
    end
end)
CreateToggle(EventTabPage, "Auto Candy Storm", AutoCandyEnabled, function(v) AutoCandyEnabled = v end)

-- TAB 5: World Boss
CreateToggle(BossTabPage, "Auto World Boss", AutoBossEnabled, function(v) AutoBossEnabled = v end)

-- TAB 6: Shop
CreateToggle(ShopTabPage, "Loop Auto Buy Shop", AutoBuyShopEnabled, function(v) AutoBuyShopEnabled = v end)
CreateButton(ShopTabPage, "Beli Market (1x Instant)", function()
    pcall(function()
        ActionRemote:FireServer("MarketBuyAll")
    end)
end)"TextButton")
    ToggleBtn.Parent = parent
    ToggleBtn.Size = UDim2.new(1, -5, 0, 35)
    ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = text .. " : " .. (state and "ON" or "OFF")
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.SourceSansBold

    local Corner = Instance.new("UICorner", ToggleBtn)
    Corner.CornerRadius = UDim.new(0, 6)

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
        ToggleBtn.Text = text .. " : " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, -5, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = text
    Btn.TextSize = 13
    Btn.Font = Enum.Font.SourceSansBold

    local Corner = Instance.new("UICorner", Btn)
    Corner.CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(callback)
end

-- Hal Tab & Fitur
local MainTabPage = CreateTab("Main")
local TeleportTabPage = CreateTab("Teleport")
local UpgradeTabPage = CreateTab("Upgrades")
local EventTabPage = CreateTab("Events")
local BossTabPage = CreateTab("World Boss")
local ShopTabPage = CreateTab("Shop")

tabs[1].Page.Visible = true
tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

CreateToggle(MainTabPage, "Anti-AFK", AntiAFKEnabled, function(v) AntiAFKEnabled = v end)
CreateToggle(MainTabPage, "Auto Rebirth", AutoRebirthEnabled, function(v) AutoRebirthEnabled = v end)

CreateButton(TeleportTabPage, "Teleport to Grades", function() TeleportToName({"Grade", "Grades", "GradeMachine"}) end)
CreateButton(TeleportTabPage, "Teleport to Tower", function() TeleportToName({"Tower", "Towers", "TowerEntrance"}) end)
CreateButton(TeleportTabPage, "Teleport to World Boss", function() TeleportToName({"WorldBoss", "Boss", "BossPortal"}) end)
CreateButton(TeleportTabPage, "Teleport to Traits", function() TeleportToName({"Trait", "Traits", "TraitMachine"}) end)

CreateToggle(UpgradeTabPage, "Auto Upgrade All", AutoUpgradeEnabled, function(v) AutoUpgradeEnabled = v end)

CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
    if AutoCandyEnabled and actionType == "Drop" and position then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(position)
                ActionRemote:FireServer("CollectCandy", candyId)
            end
        end)
    end
end)
CreateToggle(EventTabPage, "Auto Candy Storm", AutoCandyEnabled, function(v) AutoCandyEnabled = v end)
CreateToggle(BossTabPage, "Auto World Boss", AutoBossEnabled, function(v) AutoBossEnabled = v end)
CreateToggle(ShopTabPage, "Loop Auto Buy Shop", AutoBuyShopEnabled, function(v) AutoBuyShopEnabled = v end)
CreateButton(ShopTabPage, "Beli Market (1x Instant)", function()
    pcall(function()
        ActionRemote:FireServer("MarketBuyAll")
    end)
end) function(v) AutoBuyShopEnabled = v end)
CreateButton(ShopTabPage, "Beli Market (1x Instant)", function()
    pcall(function()
        ActionRemote:FireServer("MarketBuyAll")
    end)
end)
