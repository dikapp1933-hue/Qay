-- Destroy UI Lama jika ada (Mencegah Menumpuk)
if game:GetService("CoreGui"):FindFirstChild("qayyScriptHub") then
    game:GetService("CoreGui").qayyScriptHub:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Safely Find Remotes
local ActionRemote, CandyStormRemote
pcall(function()
    local PetDiceFolder = ReplicatedStorage:FindFirstChild("PetDice")
    if PetDiceFolder then
        local Remotes = PetDiceFolder:FindFirstChild("Remotes")
        if Remotes then
            ActionRemote = Remotes:FindFirstChild("Action")
            CandyStormRemote = Remotes:FindFirstChild("CandyStorm")
        end
    end
end)

-- Status Variabel
local AntiAFKEnabled = true
local AutoRebirthEnabled = false
local AutoUpgradeEnabled = false
local AutoBossEnabled = false
local AutoBuyShopEnabled = false
local AutoCandyEnabled = false

-- Antrean & Map Permen
local ActiveCandies = {}
local IsProcessingCandy = false

---------------------------------------------------------
-- ANTI-AFK SAFE
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
-- CENTRAL LOOP UTAMA (2.5 DETIK)
---------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(2.5)
        pcall(function()
            if ActionRemote then
                if AutoUpgradeEnabled then
                    ActionRemote:FireServer("BuyAllUpgrades")
                    ActionRemote:FireServer("Funnel", "UpgradeTree", 1, nil)
                end
                if AutoRebirthEnabled then
                    ActionRemote:FireServer("Rebirth")
                end
                if AutoBuyShopEnabled then
                    ActionRemote:FireServer("MarketBuyAll")
                end
            end
        end)
    end
end)

---------------------------------------------------------
-- FUNGSI MENCARI POSISI OBJEK DI WORKSPACE
---------------------------------------------------------
local function GetTargetPosition(possibleNames)
    local targetPos = nil
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            for _, name in ipairs(possibleNames) do
                if string.lower(obj.Name) == string.lower(name) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                    if obj:IsA("Model") then
                        local primary = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                        if primary then targetPos = primary.Position end
                    elseif obj:IsA("BasePart") then
                        targetPos = obj.Position
                    end
                    break
                end
            end
            if targetPos then break end
        end
    end)
    return targetPos
end

---------------------------------------------------------
-- LOOP SAFE AUTO BOSS
---------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(3)
        if AutoBossEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local bossPos = GetTargetPosition({"WorldBoss", "Boss", "BossPortal", "BossArea"})

                    if hrp and humanoid and bossPos then
                        local distance = (hrp.Position - bossPos).Magnitude
                        if distance > 25 then
                            humanoid:MoveTo(bossPos)
                        else
                            if ActionRemote then
                                ActionRemote:FireServer("WorldBossJoin")
                            end
                        end
                    end
                end
            end)
        end
    end
end)

---------------------------------------------------------
-- LOGIKA SMART CANDY (CARI PERMEN TERDEKAT & BIFOKUS SAMPAI KENA)
---------------------------------------------------------
local function ProcessCandyQueue()
    if IsProcessingCandy then return end
    IsProcessingCandy = true

    task.spawn(function()
        while AutoCandyEnabled do
            local char = LocalPlayer.Character
            if not char then break end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if not hrp or not humanoid then break end

            -- 1. Cari permen yang lokasinya paling dekat dengan karakter saat ini
            local closestIndex = nil
            local closestDist = math.huge

            for i, data in ipairs(ActiveCandies) do
                local dist = (hrp.Position - data.position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestIndex = i
                end
            end

            -- Jika tidak ada permen tersisa, keluar dari loop
            if not closestIndex then break end

            -- Ambil permen terdekat dari daftar
            local currentTarget = table.remove(ActiveCandies, closestIndex)
            local candyId = currentTarget.candyId
            local targetPos = currentTarget.position

            -- 2. Perintahkan karakter berjalan ke posisi permen
            humanoid:MoveTo(targetPos)

            -- 3. Tunggu sampai benar-benar mendekat (Jarak <= 3.5 stud)
            local startTime = tick()
            while tick() - startTime < 6 do -- Toleransi waktu jalan max 6 detik
                if not AutoCandyEnabled then break end
                
                local currentDist = (hrp.Position - targetPos).Magnitude
                if currentDist <= 3.5 then
                    -- Sudah sangat dekat dengan permen!
                    break
                end
                
                -- Jika karakter berhenti mendadak sebelum sampai, perintahkan jalan lagi
                if humanoid.MoveDirection.Magnitude == 0 then
                    humanoid:MoveTo(targetPos)
                end
                
                task.wait(0.1)
            end

            -- 4. Kirim remote eksekusi ambil permen
            if ActionRemote then
                pcall(function()
                    ActionRemote:FireServer("CollectCandy", candyId)
                end)
            end

            task.wait(0.15) -- Jeda kecil sebelum lanjut mencari permen terdekat berikutnya
        end

        IsProcessingCandy = false
    end)
end

---------------------------------------------------------
-- FUNGSI TELEPORT SAFE
---------------------------------------------------------
local function TeleportToName(possibleNames)
    local pos = GetTargetPosition(possibleNames)
    if pos then
        pcall(function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos) * CFrame.new(0, 4, 0)
            end
        end)
    end
end

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
MainFrame.Visible = true

local CornerFrame = Instance.new("UICorner", MainFrame)
CornerFrame.CornerRadius = UDim.new(0, 10)

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
-- SISTEM TAB & KONTEN MENU UTAMA
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

-- DETEKSI EVENT PERMEN JATUH
if CandyStormRemote then
    CandyStormRemote.OnClientEvent:Connect(function(actionType, candyId, itemName, position)
        if AutoCandyEnabled and actionType == "Drop" and position then
            table.insert(ActiveCandies, {candyId = candyId, position = position})
            ProcessCandyQueue()
        end
    end)
end

CreateToggle(EventTabPage, "Smart Auto Candy", AutoCandyEnabled, function(v) 
    AutoCandyEnabled = v 
    if not v then
        ActiveCandies = {}
    end
end)

CreateToggle(BossTabPage, "Auto World Boss", AutoBossEnabled, function(v) AutoBossEnabled = v end)
CreateToggle(ShopTabPage, "Loop Auto Buy Shop", AutoBuyShopEnabled, function(v) AutoBuyShopEnabled = v end)
CreateButton(ShopTabPage, "Beli Market (1x Instant)", function()
    pcall(function()
        if ActionRemote then ActionRemote:FireServer("MarketBuyAll") end
    end)
end)
