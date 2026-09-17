local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Language state/table must be initialized before Translate() is defined.
local LanguageState = { Current = "English" }
local SupportedLanguages = {
    {Code="EN", Name="English", Flag="🇬🇧"},
    {Code="TR", Name="Turkish", Flag="🇹🇷"},
    {Code="TH", Name="Thai", Flag="🇹🇭"},
    {Code="MS", Name="Malay", Flag="🇲🇾"},
    {Code="PH", Name="Filipino", Flag="🇵🇭"},
    {Code="ZH", Name="Chinese", Flag="🇨🇳"},
    {Code="IT", Name="Italian", Flag="🇮🇹"},
    {Code="PL", Name="Polish", Flag="🇵🇱"},
    {Code="ES", Name="Spanish", Flag="🇪🇸"},
    {Code="AR", Name="Arabic", Flag="🇸🇦"},
    {Code="RU", Name="Russian", Flag="🇷🇺"},
    {Code="ID", Name="Indonesian", Flag="🇮🇩"},
    {Code="FR", Name="French", Flag="🇫🇷"},
    {Code="PT", Name="Portuguese", Flag="🇵🇹"},
    {Code="DE", Name="German", Flag="🇩🇪"},
    {Code="AZ", Name="Azerbaycan", Flag="🇦🇿"}
}

-- Global language table. Every UI string still falls back to English,
-- preserving the existing UI architecture when a translation is not defined.
local L = {
    English = {
        ["Information"]="Information", ["Farm"]="Farm", ["Farm Earning"]="Farm Earning",
        ["Auto Eat"]="Auto Eat", ["Combat"]="Combat", ["ESP"]="ESP", ["Staff"]="Staff",
        ["Extra"]="Extra", ["Settings"]="Settings", ["Beta"]="Beta",
        ["Glow ESP + Role Info"]="Glow ESP + Role Info",
        ["Clean Health Bar (2D Dynamic)"]="Clean Health Bar (2D Dynamic)",
        ["Show Status Tag (Wanted / Hostile)"]="Show Status Tag (Wanted / Hostile)",
        ["Inventory ESP (Visual Item Icons)"]="Inventory ESP (Visual Item Icons)",
        ["Distance Tracers"]="Distance Tracers", ["Zone Radius Size"]="Zone Radius Size",
        ["Select Special Player"]="Select Special Player", ["Refresh Player List"]="Refresh Player List",
        ["Special Player ESP (RGB Glow)"]="Special Player ESP (RGB Glow)",
        ["Farm Earnings"]="Farm Earnings", ["Farm Earning"]="Farm Earning", ["Current Money"]="Current Money",
        ["Session Earnings"]="Session Earnings", ["Active Farms"]="Active Farms", ["Idle"]="Idle",
        ["ON"]="ON", ["OFF"]="OFF"
    }
}
setmetatable(L.English, {__index=function(_,key) return key end})

local translationSets = {
    ["Turkish"]={["Information"]="Bilgi",["Farm"]="Farm",["Farm Earning"]="Farm Kazancı",["Auto Eat"]="Otomatik Yemek",["Combat"]="Combat",["ESP"]="ESP",["Staff"]="Yetkili",["Extra"]="Ekstra",["Settings"]="Ayarlar",["Beta"]="Beta",["Glow ESP + Role Info"]="Glow ESP + Rol Bilgisi",["Clean Health Bar (2D Dynamic)"]="Temiz Can Barı (2D Dinamik)",["Show Status Tag (Wanted / Hostile)"]="Durum Etiketi (Aranıyor / Düşman)",["Inventory ESP (Visual Item Icons)"]="Envanter ESP (Eşya İkonları)",["Distance Tracers"]="Mesafe Çizgileri",["Zone Radius Size"]="Bölge Yarıçapı",["Select Special Player"]="Özel Oyuncu Seç",["Refresh Player List"]="Oyuncu Listesini Yenile",["Special Player ESP (RGB Glow)"]="Özel Oyuncu ESP (RGB)",["Farm Earnings"]="Farm Kazançları",["Current Money"]="Mevcut Para",["Session Earnings"]="Oturum Kazancı",["Active Farms"]="Aktif Farmlar",["Idle"]="Bekliyor"},
    ["Thai"]={["Information"]="ข้อมูล",["Farm"]="ฟาร์ม",["Farm Earning"]="รายได้ฟาร์ม",["Settings"]="การตั้งค่า",["ESP"]="ESP",["Combat"]="การต่อสู้",["Staff"]="ทีมงาน",["Refresh Player List"]="รีเฟรชรายชื่อผู้เล่น",["Current Money"]="เงินปัจจุบัน",["Session Earnings"]="รายได้เซสชัน",["Active Farms"]="ฟาร์มที่ทำงาน"},
    ["Malay"]={["Information"]="Maklumat",["Farm"]="Farm",["Farm Earning"]="Pendapatan Farm",["Settings"]="Tetapan",["ESP"]="ESP",["Combat"]="Combat",["Staff"]="Kakitangan",["Refresh Player List"]="Segarkan Senarai Pemain",["Current Money"]="Wang Semasa",["Session Earnings"]="Pendapatan Sesi",["Active Farms"]="Farm Aktif"},
    ["Filipino"]={["Information"]="Impormasyon",["Farm"]="Farm",["Farm Earning"]="Kita ng Farm",["Settings"]="Mga Setting",["ESP"]="ESP",["Combat"]="Combat",["Staff"]="Staff",["Refresh Player List"]="I-refresh ang Player List",["Current Money"]="Kasalukuyang Pera",["Session Earnings"]="Kita sa Session",["Active Farms"]="Aktibong Farm"},
    ["Chinese"]={["Information"]="信息",["Farm"]="农场",["Farm Earning"]="农场收益",["Settings"]="设置",["ESP"]="ESP",["Combat"]="战斗",["Staff"]="管理组",["Refresh Player List"]="刷新玩家列表",["Current Money"]="当前资金",["Session Earnings"]="本次收益",["Active Farms"]="运行中的农场"},
    ["Italian"]={["Information"]="Informazioni",["Farm"]="Farm",["Farm Earning"]="Guadagni Farm",["Settings"]="Impostazioni",["ESP"]="ESP",["Combat"]="Combattimento",["Staff"]="Staff",["Refresh Player List"]="Aggiorna lista giocatori",["Current Money"]="Denaro attuale",["Session Earnings"]="Guadagni sessione",["Active Farms"]="Farm attivi"},
    ["Polish"]={["Information"]="Informacje",["Farm"]="Farm",["Farm Earning"]="Zarobki farmy",["Settings"]="Ustawienia",["ESP"]="ESP",["Combat"]="Walka",["Staff"]="Administracja",["Refresh Player List"]="Odśwież listę graczy",["Current Money"]="Obecne pieniądze",["Session Earnings"]="Zarobki sesji",["Active Farms"]="Aktywne farmy"},
    ["Spanish"]={["Information"]="Información",["Farm"]="Farm",["Farm Earning"]="Ganancias de Farm",["Settings"]="Ajustes",["ESP"]="ESP",["Combat"]="Combate",["Staff"]="Staff",["Refresh Player List"]="Actualizar lista de jugadores",["Current Money"]="Dinero actual",["Session Earnings"]="Ganancias de sesión",["Active Farms"]="Farms activos"},
    ["Arabic"]={["Information"]="المعلومات",["Farm"]="المزرعة",["Farm Earning"]="أرباح المزرعة",["Settings"]="الإعدادات",["ESP"]="ESP",["Combat"]="القتال",["Staff"]="الطاقم",["Refresh Player List"]="تحديث قائمة اللاعبين",["Current Money"]="المال الحالي",["Session Earnings"]="أرباح الجلسة",["Active Farms"]="المزارع النشطة"},
    ["Russian"]={["Information"]="Информация",["Farm"]="Фарм",["Farm Earning"]="Доход с фарма",["Settings"]="Настройки",["ESP"]="ESP",["Combat"]="Бой",["Staff"]="Персонал",["Refresh Player List"]="Обновить список игроков",["Current Money"]="Текущие деньги",["Session Earnings"]="Доход за сессию",["Active Farms"]="Активные фармы"},
    ["Indonesian"]={["Information"]="Informasi",["Farm"]="Farm",["Farm Earning"]="Penghasilan Farm",["Settings"]="Pengaturan",["ESP"]="ESP",["Combat"]="Pertarungan",["Staff"]="Staf",["Refresh Player List"]="Segarkan daftar pemain",["Current Money"]="Uang saat ini",["Session Earnings"]="Penghasilan sesi",["Active Farms"]="Farm aktif"},
    ["French"]={["Information"]="Informations",["Farm"]="Farm",["Farm Earning"]="Gains du Farm",["Settings"]="Paramètres",["ESP"]="ESP",["Combat"]="Combat",["Staff"]="Staff",["Refresh Player List"]="Actualiser la liste des joueurs",["Current Money"]="Argent actuel",["Session Earnings"]="Gains de session",["Active Farms"]="Farms actifs"},
    ["Portuguese"]={["Information"]="Informações",["Farm"]="Farm",["Farm Earning"]="Ganhos do Farm",["Settings"]="Configurações",["ESP"]="ESP",["Combat"]="Combate",["Staff"]="Equipe",["Refresh Player List"]="Atualizar lista de jogadores",["Current Money"]="Dinheiro atual",["Session Earnings"]="Ganhos da sessão",["Active Farms"]="Farms ativos"},
    ["German"]={["Information"]="Informationen",["Farm"]="Farm",["Farm Earning"]="Farm-Einnahmen",["Settings"]="Einstellungen",["ESP"]="ESP",["Combat"]="Kampf",["Staff"]="Team",["Refresh Player List"]="Spielerliste aktualisieren",["Current Money"]="Aktuelles Geld",["Session Earnings"]="Sitzungseinnahmen",["Active Farms"]="Aktive Farms"},
    ["Azerbaycan"]={["Information"]="Məlumat",["Farm"]="Farm",["Farm Earning"]="Farm Gəliri",["Settings"]="Ayarlar",["ESP"]="ESP",["Combat"]="Döyüş",["Staff"]="Heyət",["Refresh Player List"]="Oyunçu siyahısını yenilə",["Current Money"]="Cari pul",["Session Earnings"]="Sessiya gəliri",["Active Farms"]="Aktiv farmlar"}
}
for name, data in pairs(translationSets) do
    L[name] = setmetatable(data, {__index = L.English})
end

-- ============================================================================


local function getGameName()
    local MarketplaceService = game:GetService("MarketplaceService")
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and info and info.Name then
        return tostring(info.Name)
    end
    return "Unknown Game"
end


local function Translate(key)
    local lang = L[LanguageState.Current]
    if lang and lang[key] then return lang[key] end
    return (L.English[key] or key)
end

local Config = {
    WindowSize = UDim2.new(0, 520, 0, 340),       
    BgColor = Color3.fromRGB(15, 17, 22),         
    SidebarColor = Color3.fromRGB(11, 12, 16),    
    ContainerColor = Color3.fromRGB(22, 25, 33),  
    ContainerActive = Color3.fromRGB(38, 43, 58), 
    Accent = Color3.fromRGB(255, 255, 255),       
    HighlightText = Color3.fromRGB(95, 145, 255), 
    TextPrimary = Color3.fromRGB(245, 245, 245),  
    TextSecondary = Color3.fromRGB(130, 135, 150),
    WarningYellow = Color3.fromRGB(240, 200, 80),
    CloseRed = Color3.fromRGB(255, 70, 70),       
    Version = "1.0.0"
}

local HubSettings = {
    GlowAllWhite = false,
    GlowColor = Color3.fromRGB(255, 255, 255),
    BoxEsp = false,
    HealthBar = false,
    TargetLines = false,
    SkeletonEsp = false,
    NameDistanceEsp = false,
    Noclip = false,
    InfiniteJump = false,
    FullBright = false
}

local ActiveDrawings = {}

local UtilityState = {
    NoclipConnection = nil,
    SavedLighting = nil,
    FullBrightActive = false
}

local function MakeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    obj.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end


-- ============================================================================
-- SYNAX HUB INTEGRATED SYSTEMS
-- Farm / Auto Hunger / Fishing / Mobile HUD support
-- ============================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = workspace

local function findToolEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local toolFolder = remotes and remotes:FindFirstChild("Tool")
    local event = toolFolder and toolFolder:FindFirstChild("Event")
    if event and event:IsA("RemoteEvent") then
        return event
    end

    -- Fallback: locate the same Tool/Event remote even if the hierarchy was renamed/moved.
    for _, inst in ipairs(ReplicatedStorage:GetDescendants()) do
        if inst:IsA("RemoteEvent") then
            local n = string.lower(inst.Name)
            local parentName = inst.Parent and string.lower(inst.Parent.Name) or ""
            if n == "event" and (parentName == "tool" or parentName:find("tool")) then
                return inst
            end
            if n:find("tool") and (n:find("event") or n:find("remote")) then
                return inst
            end
        end
    end

    return nil
end

-- Proxy keeps the rest of the script working without blocking the UI if the remote is missing.
local ToolEvent = {}
function ToolEvent:FireServer(...)
    local event = findToolEvent()
    if event then
        return event:FireServer(...)
    end
end
local FOOD_TOOLS = { CerealBar = true, FoodPlate = true, Popcorn = true }
local DRINK_TOOLS = { WaterCup = true, Soda = true, BloxyCola = true }

local AutoHungerState = {
    Enabled = false,
    EatBelow = 50,
    DrinkBelow = 50
}
local RunningAutoHunger = true
local vendingMachines = {}
local AutoEatStatusLabel = "Idle"

local function getCharacterHunger()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid")
end

local function findAutoEatTool(names)
    local char = LocalPlayer.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and names[t.Name] then
                return t
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, t in ipairs(backpack:GetChildren()) do
            if t:IsA("Tool") and names[t.Name] then
                return t
            end
        end
    end

    return nil
end

local function stowLeftover(names)
    local char, humanoid = getCharacterHunger()
    if not humanoid then return end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and names[equipped.Name] then
        pcall(function()
            humanoid:UnequipTools()
        end)
    end
end

local function collectVendingMachines()
    local list = {}

    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("RemoteEvent") and inst.Parent and inst.Parent:IsA("Configuration") then
            local text = tostring(inst.Parent:GetAttribute("Text") or "")

            if text:find("Buy Food") or text:find("Buy Drink") then
                local machine = inst:FindFirstAncestorOfClass("Model")

                if machine then
                    table.insert(list, {
                        event = inst,
                        kind = text:find("Food") and "Food" or "Drink",
                        model = machine,
                        price = tonumber(text:match("%$(%d+)")) or 3
                    })
                end
            end
        end
    end

    return list
end

local function getNearestMachine(kind)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge

    for _, m in ipairs(vendingMachines) do
        if m.kind == kind and m.event and m.event.Parent and m.model and m.model.Parent then
            local ok, pos = pcall(function()
                return m.model:GetPivot().Position
            end)

            if ok and pos then
                local d = root and (pos - root.Position).Magnitude or 0
                if d < bestDist then
                    best, bestDist = m, d
                end
            end
        end
    end

    return best, bestDist
end

local function consumeAutoHunger(kind, toolNames, statName, thresholdOf)
    local actions, misses = 0, 0

    while RunningAutoHunger and AutoHungerState.Enabled and actions < 50 and misses < 3 do
        local threshold = thresholdOf()
        local stat = LocalPlayer:GetAttribute(statName)

        if not stat or stat >= threshold then
            break
        end

        local tool = findAutoEatTool(toolNames)

        if not tool then
            local machineKind = (kind == "Eat") and "Food" or "Drink"
            local nearest = getNearestMachine(machineKind)

            if not nearest then
                vendingMachines = collectVendingMachines()
                nearest = getNearestMachine(machineKind)
            end

            if not nearest then
                AutoEatStatusLabel = "No vending machine found"
                break
            end

            if (LocalPlayer:GetAttribute("Money") or 0) < nearest.price then
                AutoEatStatusLabel = "Not enough money"
                break
            end

            AutoEatStatusLabel = "Buying from far away..."
            pcall(function()
                nearest.event:FireServer()
            end)

            local t0 = os.clock()
            repeat
                task.wait(0.15)
                tool = findAutoEatTool(toolNames)
            until tool or os.clock() - t0 > 3

            if not tool then
                misses += 1
                task.wait(1)
                continue
            end
        end

        local _, humanoid = getCharacterHunger()
        if not humanoid then break end

        if tool.Parent == LocalPlayer.Backpack then
            pcall(function()
                humanoid:EquipTool(tool)
            end)

            local t0 = os.clock()
            while RunningAutoHunger and AutoHungerState.Enabled
                and tool.Parent == LocalPlayer.Backpack
                and os.clock() - t0 < 2 do
                task.wait(0.1)
            end

            task.wait(0.3)
        end

        if not tool.Parent then
            actions += 1
            continue
        end

        local t0 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled
            and tool.Parent and tool:GetAttribute("OnCooldown")
            and os.clock() - t0 < 6 do
            task.wait(0.15)
        end

        if not RunningAutoHunger or not AutoHungerState.Enabled or not tool.Parent then
            actions += 1
            continue
        end

        local before = LocalPlayer:GetAttribute(statName) or 0

        pcall(function()
            ToolEvent:FireServer(kind, tool)
        end)

        AutoEatStatusLabel = (kind == "Eat") and "Eating..." or "Drinking..."
        actions += 1

        local t1 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled and os.clock() - t1 < 4 do
            if not tool.Parent then break end
            if (LocalPlayer:GetAttribute(statName) or 0) ~= before then break end
            task.wait(0.1)
        end

        if (LocalPlayer:GetAttribute(statName) or 0) ~= before then
            misses = 0
        else
            misses += 1
        end

        task.wait(0.5)
    end

    stowLeftover(toolNames)

    if AutoHungerState.Enabled then
        AutoEatStatusLabel = "Idle"
    end
end

task.spawn(function()
    while RunningAutoHunger do
        task.wait(1)

        if AutoHungerState.Enabled then
            pcall(function()
                local hunger = LocalPlayer:GetAttribute("Hunger")
                local thirst = LocalPlayer:GetAttribute("Thirst")

                if hunger and hunger < AutoHungerState.EatBelow then
                    consumeAutoHunger(
                        "Eat",
                        FOOD_TOOLS,
                        "Hunger",
                        function()
                            return AutoHungerState.EatBelow
                        end
                    )
                end

                if thirst and thirst < AutoHungerState.DrinkBelow then
                    consumeAutoHunger(
                        "Drink",
                        DRINK_TOOLS,
                        "Thirst",
                        function()
                            return AutoHungerState.DrinkBelow
                        end
                    )
                end
            end)
        end
    end
end)

-- ---------------------------------------------------------------------------
-- FARM SYSTEMS
-- ---------------------------------------------------------------------------
local TasksFolder
local RocksFolder
local TrashesFolder
local JanitorFolder

local function refreshFarmFolders()
    TasksFolder = Workspace:FindFirstChild("Tasks")
    local prisoner = TasksFolder and TasksFolder:FindFirstChild("Prisoner")
    RocksFolder = prisoner and prisoner:FindFirstChild("Rocks")
    TrashesFolder = prisoner and prisoner:FindFirstChild("Trashes")
    JanitorFolder = TasksFolder and TasksFolder:FindFirstChild("Janitor")

    -- Fallbacks for minor hierarchy/name changes.
    if TasksFolder then
        if not RocksFolder then
            RocksFolder = TasksFolder:FindFirstChild("Rocks", true)
        end
        if not TrashesFolder then
            TrashesFolder = TasksFolder:FindFirstChild("Trashes", true)
        end
        if not JanitorFolder then
            JanitorFolder = TasksFolder:FindFirstChild("Janitor", true)
        end
    end

    return TasksFolder, RocksFolder, TrashesFolder, JanitorFolder
end

refreshFarmFolders()

local FarmState = {
    AutoCook = false,
    AutoFish = false,
    AutoSell = false,
    SellInterval = 20
}

local AutoMine = {
    IsActive = false,
    NoclipConnection = nil,
    LockConnection = nil,
    OriginalCollisions = {},
    RunningThread = nil
}

local AutoTrash = {
    IsActive = false,
    RunningThread = nil
}

local JanitorState = {
    AutoFarm = false,
    CleanDelay = 0.4,
    TpWait = 0.25,
    HitsPerPuddle = 3,
    PuddlesDone = 0,
    LastPuddle = "-"
}

    -----------------------------------------------------------------------
    -- [ FARM EARNING ENGINE ]
    -- Tracks current money and earnings per enabled farm without creating
    -- a second UI framework.
    -----------------------------------------------------------------------
    local FarmEarningState = {
        Farms = {
            ["Auto Cook"] = {Active=false, StartMoney=nil, Earned=0},
            ["Fish Farm"] = {Active=false, StartMoney=nil, Earned=0},
            ["Auto Sell Fish"] = {Active=false, StartMoney=nil, Earned=0},
            ["Auto Mine"] = {Active=false, StartMoney=nil, Earned=0},
            ["Auto Trash"] = {Active=false, StartMoney=nil, Earned=0},
            ["Janitor Farm"] = {Active=false, StartMoney=nil, Earned=0}
        },
        SessionStartMoney = nil,
        CurrentMoney = 0
    }

    local function FarmEarning_ReadMoney()
        local containers = {LocalPlayer:FindFirstChild("leaderstats"), LocalPlayer}
        local names = {"Cash", "Money", "Coins", "Balance", "Currency", "Credits"}
        for _, container in ipairs(containers) do
            if container then
                for _, name in ipairs(names) do
                    local obj = container:FindFirstChild(name)
                    if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                        return tonumber(obj.Value) or 0
                    end
                end
            end
        end
        return nil
    end

    local function FarmEarning_SetFarm(name, active)
        local data = FarmEarningState.Farms[name]
        if not data then return end
        local money = FarmEarning_ReadMoney()
        data.Active = active
        if active then
            data.StartMoney = money
            data.Earned = 0
        elseif money and data.StartMoney then
            data.Earned = math.max(0, money - data.StartMoney)
        end
    end

local function clearFarmTable(t)
    for key in pairs(t) do
        t[key] = nil
    end
end

local function getCharacterParts()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        return nil, nil
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then
        return nil, nil
    end

    return char, hrp
end

local function getRootPart()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart", 5)
end

local function getMop()
    local char = LocalPlayer.Character

    if char then
        local equipped = char:FindFirstChild("Mop")
        if equipped and equipped:IsA("Tool") then
            return equipped, true
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local bagMop = backpack and backpack:FindFirstChild("Mop")

    if bagMop and bagMop:IsA("Tool") then
        return bagMop, false
    end

    return nil, false
end

local function equipMop()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if not char or not backpack or not humanoid then
        return nil
    end

    local mop = char:FindFirstChild("Mop") or backpack:FindFirstChild("Mop")

    if mop then
        pcall(function()
            humanoid:EquipTool(mop)
        end)
        task.wait(0.25)
    end

    return char:FindFirstChild("Mop")
end

local function getPuddles()
    refreshFarmFolders()
    local list = {}
    if not JanitorFolder then return list end

    for _, child in ipairs(JanitorFolder:GetChildren()) do
        if child:IsA("BasePart") and child.Size.Y < 0.5 then
            table.insert(list, child)
        end
    end

    return list
end

local function nearestPuddle(origin)
    local best, bestDist = nil, math.huge

    for _, puddle in ipairs(getPuddles()) do
        local dist = (puddle.Position - origin).Magnitude

        if dist < bestDist then
            best, bestDist = puddle, dist
        end
    end

    return best
end

local function teleport(cframe)
    local _, hrp = getCharacterParts()
    if not hrp then return false end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = cframe
    return true
end

local function mopPuddle(puddle)
    refreshFarmFolders()
    while JanitorState.AutoFarm do
        local char = LocalPlayer.Character
        if not char then return false end

        local mop, equipped = getMop()
        if not mop then
            mop = equipMop()
            equipped = mop ~= nil
        end

        if not mop then return false end

        if puddle.Parent ~= JanitorFolder then
            return true
        end

        if not equipped then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return false end

            pcall(function()
                hum:EquipTool(mop)
            end)
            task.wait(0.4)
            continue
        end

        if mop:GetAttribute("OnCooldown") then
            task.wait(0.25)
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        if (hrp.Position - puddle.Position).Magnitude > 8 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.2, 0))
            task.wait(JanitorState.TpWait)
            continue
        end

        pcall(function()
            ToolEvent:FireServer("Mop", mop, puddle)
        end)

        task.wait(JanitorState.CleanDelay)
    end

    return false
end

local function janitorFarmLoop()
    while JanitorState.AutoFarm do
        refreshFarmFolders()
        if not JanitorFolder then task.wait(1) continue end
        local char, hrp = getCharacterParts()

        if not char or not hrp then
            task.wait(1)
            continue
        end

        local mop = getMop()
        if not mop then
            task.wait(1)
            continue
        end

        local puddles = getPuddles()

        table.sort(puddles, function(a, b)
            return (a.Position - hrp.Position).Magnitude <
                (b.Position - hrp.Position).Magnitude
        end)

        if #puddles == 0 then
            task.wait(1)
            continue
        end

        for _, puddle in ipairs(puddles) do
            if not JanitorState.AutoFarm then break end

            if puddle.Parent == JanitorFolder then
                local cleaned = mopPuddle(puddle)

                if cleaned or puddle.Parent ~= JanitorFolder then
                    JanitorState.PuddlesDone += 1
                    JanitorState.LastPuddle = puddle.Name
                end
            end
        end

        task.wait(0.2)
    end
end

local function cleanNearestPuddle()
    refreshFarmFolders()
    if not JanitorFolder then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local mop = (char and char:FindFirstChild("Mop")) or equipMop()

    if not hrp or not mop then return end

    local nearest
    local nearestDistance = math.huge

    for _, puddle in ipairs(JanitorFolder:GetChildren()) do
        if puddle:IsA("BasePart") then
            local distance = (puddle.Position - hrp.Position).Magnitude

            if distance < nearestDistance then
                nearestDistance = distance
                nearest = puddle
            end
        end
    end

    if not nearest then return end

    hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3.5, 0))
    task.wait(JanitorState.TpWait)

    for _ = 1, JanitorState.HitsPerPuddle do
        if not nearest.Parent then break end

        pcall(function()
            ToolEvent:FireServer("Mop", mop, nearest)
        end)

        task.wait(JanitorState.CleanDelay)
    end
end

local function teleportToJanitor()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp then
        hrp.CFrame = CFrame.new(91.27, 13.8, -693.9)
    end
end

local function cycleAllPuddles()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    task.spawn(function()
        for _, puddle in ipairs(getPuddles()) do
            if not JanitorState.AutoFarm then
                hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.5, 0))
                task.wait(0.5)
            end
        end
    end)
end

function AutoMine.FindClosestRock()
    refreshFarmFolders()
    if not RocksFolder then return nil end
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    if not rootPart then return nil end

    local closest, minDistance = nil, math.huge

    for _, rock in ipairs(RocksFolder:GetChildren()) do
        if rock:IsA("BasePart") then
            local health = rock:GetAttribute("Health")
            local destroyed = rock:GetAttribute("Destroyed")

            if health and health > 0 and not destroyed then
                local distance = (rock.Position - rootPart.Position).Magnitude

                if distance < minDistance then
                    minDistance = distance
                    closest = rock
                end
            end
        end
    end

    return closest
end

function AutoMine.IsRockDead(rock)
    if not rock or not rock.Parent then return true end

    local health = rock:GetAttribute("Health")
    local destroyed = rock:GetAttribute("Destroyed")

    return (health and health <= 0) or destroyed == true
end

function AutoMine.Start()
    if AutoMine.IsActive then return end

    AutoMine.IsActive = true
    clearFarmTable(AutoMine.OriginalCollisions)

    AutoMine.NoclipConnection = RunService.Stepped:Connect(function()
        if not AutoMine.IsActive then return end

        local char = LocalPlayer.Character
        if not char then return end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if AutoMine.OriginalCollisions[part] == nil then
                    AutoMine.OriginalCollisions[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    end)

    AutoMine.RunningThread = task.spawn(function()
        while AutoMine.IsActive do
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            if not humanoid or not rootPart or not backpack then
                task.wait(0.5)
                continue
            end

            local targetRock = AutoMine.FindClosestRock()

            if targetRock then
                AutoMine.LockConnection = RunService.Heartbeat:Connect(function()
                    if targetRock and targetRock.Parent and rootPart and rootPart.Parent then
                        rootPart.CFrame = targetRock.CFrame * CFrame.new(0, 3, 0)
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                    end
                end)

                while AutoMine.IsActive and not AutoMine.IsRockDead(targetRock) do
                    pcall(function()
                        local tool =
                            char:FindFirstChild("Pickaxe") or
                            backpack:FindFirstChild("Pickaxe") or
                            char:FindFirstChild("PremiumPickaxe") or
                            backpack:FindFirstChild("PremiumPickaxe")

                        if tool then
                            if tool.Parent == backpack then
                                pcall(function()
                                    humanoid:EquipTool(tool)
                                end)
                            end

                            ToolEvent:FireServer("MineOres", tool, targetRock)
                        end
                    end)

                    task.wait(0.05)
                end

                if AutoMine.LockConnection then
                    AutoMine.LockConnection:Disconnect()
                    AutoMine.LockConnection = nil
                end
            else
                task.wait(0.5)
            end

            task.wait(0.05)
        end
    end)
end

function AutoMine.Stop()
    AutoMine.IsActive = false
    AutoMine.RunningThread = nil

    if AutoMine.LockConnection then
        AutoMine.LockConnection:Disconnect()
        AutoMine.LockConnection = nil
    end

    if AutoMine.NoclipConnection then
        AutoMine.NoclipConnection:Disconnect()
        AutoMine.NoclipConnection = nil
    end

    pcall(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:UnequipTools()
        end
    end)

    pcall(function()
        local char = LocalPlayer.Character

        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and AutoMine.OriginalCollisions[part] ~= nil then
                    part.CanCollide = AutoMine.OriginalCollisions[part]
                end
            end
        end

        clearFarmTable(AutoMine.OriginalCollisions)
    end)
end

function AutoTrash.Start()
    if AutoTrash.IsActive then return end
    refreshFarmFolders()

    AutoTrash.IsActive = true

    AutoTrash.RunningThread = task.spawn(function()
        while AutoTrash.IsActive do
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

            if char and backpack then
                pcall(function()
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")

                    if not rootPart or not humanoid then
                        task.wait(0.5)
                        return
                    end

                    -- 1) Çöp henüz elde değilse: çöp noktasına TP -> çöpü al.
                    local trashTool =
                        char:FindFirstChild("SmallTrash") or
                        backpack:FindFirstChild("SmallTrash") or
                        char:FindFirstChild("BigTrash") or
                        backpack:FindFirstChild("BigTrash")

                    if not trashTool then
                        refreshFarmFolders()

                        if TrashesFolder then
                            local activeBin

                            for _, bin in ipairs(TrashesFolder:GetChildren()) do
                                local prompt = bin:FindFirstChild("Prompt")
                                if prompt and prompt:GetAttribute("Enabled") == true then
                                    activeBin = bin
                                    break
                                end
                            end

                            if activeBin then
                                local prompt = activeBin:FindFirstChild("Prompt")
                                local target = prompt and prompt.Parent

                                if target then
                                    rootPart.AssemblyLinearVelocity = Vector3.zero
                                    rootPart.CFrame = target.CFrame * CFrame.new(0, 2, 0)

                                    task.wait(0.3)
                                    if not AutoTrash.IsActive then return end

                                    local interact = prompt:FindFirstChild("Interact")
                                    local event = interact and interact:FindFirstChild("Event")

                                    if event and event:IsA("RemoteEvent") then
                                        event:FireServer()
                                    end

                                    -- Çöpün Backpack'e/Character'a geçmesini bekle.
                                    task.wait(0.25)
                                end
                            end
                        end
                    else
                        -- 2) Çöp alındı: çöplüğe TP -> tam 2 saniye bekle -> 1 kez at.
                        local map = Workspace:FindFirstChild("Map")
                        local cells = map and map:FindFirstChild("Cells")
                        local basement = cells and cells:FindFirstChild("Basement")
                        local room = basement and basement:FindFirstChild("Recyclement Room")
                        local props = room and room:FindFirstChild("Props")
                        local opened = props and props:FindFirstChild("Opened Trash")
                        local dumpster = opened and opened:FindFirstChild("Trash")

                        if dumpster then
                            rootPart.AssemblyLinearVelocity = Vector3.zero
                            rootPart.CFrame = dumpster.CFrame * CFrame.new(0, 2, 0)

                            -- İstenen sıra: TP -> 2 saniye bekle -> at.
                            task.wait(2)
                            if not AutoTrash.IsActive then return end

                            if trashTool.Parent == backpack then
                                humanoid:EquipTool(trashTool)
                                task.wait(0.15)
                            end

                            local prompt = dumpster:FindFirstChild("Prompt")
                            local interact = prompt and prompt:FindFirstChild("Interact")
                            local event = interact and interact:FindFirstChild("Event")

                            if event and event:IsA("RemoteEvent") then
                                event:FireServer()
                            end

                            -- Bir sonraki döngüde yeniden çöp almaya geç.
                            task.wait(0.15)
                        end
                    end
                end)
            else
                task.wait(0.5)
            end

            if not AutoTrash.IsActive then break end
            task.wait(0.1)
        end
    end)
end

function AutoTrash.Stop()
    AutoTrash.IsActive = false
    AutoTrash.RunningThread = nil
end

local function unlockFists()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes")
            :WaitForChild("Quests")
            :WaitForChild("Pushups")
            :WaitForChild("Function")
            :InvokeServer("Submit", 300)
    end)
end

-- ---------------------------------------------------------------------------
-- COOKING
-- ---------------------------------------------------------------------------
local farmSteps = {
    {name = "Cut", cframe = CFrame.new(43.00, 7.54, -298.80), path = "Cut"},
    {name = "Cook", cframe = CFrame.new(37.12, 7.54, -297.77), path = "Cook"},
    {name = "Boil", cframe = CFrame.new(32.07, 7.54, -296.28), path = "Simmer"},
    {name = "Combine", cframe = CFrame.new(41.81, 7.54, -294.10), path = "Assemble"},
    {name = "To take", cframe = CFrame.new(48.75, 7.54, -296.25), path = "Take"},
    {name = "Deposit", cframe = CFrame.new(16.09, 7.54, -314.13), path = "Deposit"}
}

local function checkStep(step)
    local tasks = Workspace:FindFirstChild("Tasks")
    local cook = tasks and tasks:FindFirstChild("Cook")
    local taskObj = cook and cook:FindFirstChild(step.path)
    local root = taskObj and taskObj:FindFirstChild("RootPart")
    local prompt = root and root:FindFirstChild("Prompt")
    local interact = prompt and prompt:FindFirstChild("Interact")
    local event = interact and interact:FindFirstChild("Event")

    if event and event:IsA("RemoteEvent") then
        return event
    end

    return nil
end

task.spawn(function()
    while true do
        if FarmState.AutoCook then
            for index, step in ipairs(farmSteps) do
                if not FarmState.AutoCook then break end

                local rootPart = getRootPart()

                if rootPart then
                    rootPart.CFrame = step.cframe
                    task.wait(0.3)

                    local event = checkStep(step)

                    if event then
                        pcall(function()
                            event:FireServer()
                        end)
                    end
                end

                if index <= 3 then
                    task.wait(10)
                else
                    task.wait(2)
                end
            end
        end

        task.wait(0.5)
    end
end)

-- ---------------------------------------------------------------------------
-- FISHING
-- ---------------------------------------------------------------------------
local FishingSystem
local FishingModules
local MinigameSystem
local PowerBarSystem
local SoundManager
local GUIManager

local function loadFishingModules()
    if MinigameSystem then return true end

    local ok = pcall(function()
        FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
        if not FishingSystem then error("FishingSystem not found") end

        FishingModules = FishingSystem:WaitForChild("FishingModules", 5)
        if not FishingModules then error("FishingModules not found") end

        MinigameSystem = require(FishingModules:WaitForChild("MinigameSystem"))
        PowerBarSystem = require(FishingModules:WaitForChild("PowerBarSystem"))
        SoundManager = require(FishingModules:WaitForChild("SoundManager"))
        GUIManager = require(FishingModules:WaitForChild("GUIManager"))
    end)

    return ok and MinigameSystem ~= nil
end

local function getRod()
    local character = LocalPlayer.Character

    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then
                return child
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then
                return child
            end
        end
    end

    return nil
end

local function getFishingElements()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local fishingGui = playerGui and playerGui:FindFirstChild("FishingGui")
    local fishing = fishingGui and fishingGui:FindFirstChild("Fishing")
    local bar = fishing and fishing:FindFirstChild("Bar")

    return bar and bar:FindFirstChild("PlayerZone"),
        bar and bar:FindFirstChild("FishMarker")
end

local function mouseDown()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end)
end

local function mouseUp()
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function castRod()
    if not loadFishingModules() then return end

    if PowerBarSystem:IsCharging() then
        mouseUp()
        task.wait(0.15)
    end

    mouseDown()

    local start = os.clock()

    while os.clock() - start < 1 do
        RunService.Heartbeat:Wait()

        if PowerBarSystem:IsCharging() then
            break
        end
    end

    while os.clock() - start < 5 do
        RunService.Heartbeat:Wait()

        if PowerBarSystem:GetCurrentPower() >= 99.5 then
            break
        end

        if not PowerBarSystem:IsCharging() and os.clock() - start > 0.5 then
            break
        end
    end

    mouseUp()
end

local lastClick = 0

RunService.Heartbeat:Connect(function()
    if not FarmState.AutoFish then return end
    if not loadFishingModules() then return end
    if not MinigameSystem:IsActive() then return end

    pcall(function()
        local phase = MinigameSystem:GetPhase()

        if phase == "shake" then
            if os.clock() - lastClick > 0.04 then
                MinigameSystem:HandleClick(SoundManager, GUIManager)
                lastClick = os.clock()
            end

        elseif phase == "reel" then
            local zone, marker = getFishingElements()

            if zone and marker then
                local zonePos = zone.Position.X.Scale
                local fishPos = marker.Position.X.Scale

                if fishPos > zonePos + 0.01 then
                    MinigameSystem:SetHolding(true)
                else
                    MinigameSystem:SetHolding(false)
                end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.1)

        if not FarmState.AutoFish then
            continue
        end

        pcall(function()
            if not loadFishingModules() then
                task.wait(1)
                return
            end

            if MinigameSystem:IsActive() then
                while MinigameSystem:IsActive() and FarmState.AutoFish do
                    task.wait(0.1)
                end

                task.wait(0.5)
            end

            if not FarmState.AutoFish then return end

            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if not character or not humanoid or humanoid.Health <= 0 then
                task.wait(1)
                return
            end

            local rod = getRod()

            if not rod then
                task.wait(1)
                return
            end

            -- Equip the rod first. Some PrisonRP tool handlers reject EquipTool
            -- while movement is forcibly locked, so movement is frozen only after
            -- the rod is confirmed inside Character.
            if rod.Parent ~= character then
                pcall(function() humanoid:UnequipTools() end)
                task.wait(0.1)

                for _ = 1, 5 do
                    if rod.Parent == character then break end
                    if rod.Parent == LocalPlayer.Backpack then
                        pcall(function() humanoid:EquipTool(rod) end)
                    end
                    task.wait(0.2)
                end

                if rod.Parent ~= character and rod.Parent == LocalPlayer.Backpack then
                    pcall(function() rod.Parent = character end)
                    task.wait(0.2)
                    pcall(function() humanoid:EquipTool(rod) end)
                    task.wait(0.2)
                end
            end

            if rod.Parent ~= character then
                task.wait(1)
                return
            end

            humanoid.WalkSpeed = 0
            pcall(function() humanoid.JumpPower = 0 end)
            pcall(function() humanoid.JumpHeight = 0 end)

            castRod()
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(FarmState.SellInterval)

        if FarmState.AutoSell then
            pcall(function()
                if not FishingSystem then
                    FishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
                end

                local inventoryEvents = FishingSystem and FishingSystem:FindFirstChild("InventoryEvents")
                local sellAll = inventoryEvents and inventoryEvents:FindFirstChild("Inventory_SellAll")

                if sellAll and sellAll:IsA("RemoteFunction") then
                    sellAll:InvokeServer()
                end
            end)
        end
    end
end)


local function ExecuteScript()
    if CoreGui:FindFirstChild("SynaxHub") then
        CoreGui:FindFirstChild("SynaxHub"):Destroy()
    end

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "SynaxHub"
    MainGui.ResetOnSpawn = false
    MainGui.IgnoreGuiInset = true
    MainGui.DisplayOrder = 999999
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Enabled = true
    MainGui.Parent = CoreGui
    -- ==========================================
    -- SECURITY NOTIFICATION
    -- ==========================================
    local NotifFrame = Instance.new("Frame", MainGui)
    NotifFrame.Size = UDim2.new(0, 360, 0, 85)
    NotifFrame.Position = UDim2.new(1, 380, 1, -95)
    NotifFrame.BackgroundColor3 = Config.BgColor
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.BorderSizePixel = 0
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Config.WarningYellow
    NotifStroke.Transparency = 0.2
    NotifStroke.Thickness = 1.5

    local AccentLine = Instance.new("Frame", NotifFrame)
    AccentLine.Size = UDim2.new(0, 4, 1, -12)
    AccentLine.Position = UDim2.new(0, 6, 0, 6)
    AccentLine.BackgroundColor3 = Config.WarningYellow
    AccentLine.BorderSizePixel = 0
    Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(1, 0)

    local NotifTitle = Instance.new("TextLabel", NotifFrame)
    NotifTitle.Size = UDim2.new(1, -25, 0, 20)
    NotifTitle.Position = UDim2.new(0, 20, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = "Synax Hub Security Notice"
    NotifTitle.TextColor3 = Config.WarningYellow
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextSize = 11
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

    local NotifDesc = Instance.new("TextLabel", NotifFrame)
    NotifDesc.Size = UDim2.new(1, -25, 0, 45)
    NotifDesc.Position = UDim2.new(0, 20, 0, 28)
    NotifDesc.BackgroundTransparency = 1
    NotifDesc.Text = LocalPlayer.DisplayName .. ", hello, everything you do in this script is your responsibility. Please choose an empty server while farming. Have a good game"
    NotifDesc.TextColor3 = Config.TextSecondary
    NotifDesc.Font = Enum.Font.Gotham
    NotifDesc.TextSize = 9.5
    NotifDesc.TextWrapped = true
    NotifDesc.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -375, 1, -95)
    }):Play()

    task.delay(5, function()
        if NotifFrame and NotifFrame.Parent then
            local outTween = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 380, 1, -95)
            })
            outTween:Play()
            outTween.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end
    end)
    local TopPill = Instance.new("TextButton", MainGui)
    TopPill.Name = "TopPill"
    TopPill.Size = UDim2.new(0, 150, 0, 32)
    TopPill.Position = UDim2.new(0.5, 0, 0, 10)
    TopPill.AnchorPoint = Vector2.new(0.5, 0)
    TopPill.BackgroundColor3 = Config.BgColor
    TopPill.BackgroundTransparency = 0.15
    TopPill.Text = "[ Synax Hub ]"
    TopPill.TextColor3 = Config.TextPrimary
    TopPill.Font = Enum.Font.GothamBold
    TopPill.TextSize = 13
    TopPill.Visible = false
    Instance.new("UICorner", TopPill).CornerRadius = UDim.new(0, 8)

    local PillStroke = Instance.new("UIStroke", TopPill)
    PillStroke.Color = Color3.fromRGB(255, 255, 255)
    PillStroke.Transparency = 0.85
    PillStroke.Thickness = 1

    local MainFrame = Instance.new("Frame", MainGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Config.BgColor
    MainFrame.BackgroundTransparency = 0.12
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.ZIndex = 10
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.88
    MainStroke.Thickness = 1

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "Synax Hub"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Config.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 4)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Config.CloseRed
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 22

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -65, 0, 4)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Config.TextSecondary
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 20

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Visible = true
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 10, 0, 38)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BackgroundTransparency = 0.25
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Visible = true
    TabContainer.Size = UDim2.new(1, -6, 1, -52)
    TabContainer.Position = UDim2.new(0, 3, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Visible = true
    PagesContainer.Size = UDim2.new(1, -170, 1, -48)
    PagesContainer.Position = UDim2.new(0, 160, 0, 38)
    PagesContainer.BackgroundTransparency = 1

    local ProfileFrame = Instance.new("Frame", Sidebar)
    ProfileFrame.Size = UDim2.new(1, -10, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 5, 1, -45)
    ProfileFrame.BackgroundColor3 = Config.ContainerColor
    ProfileFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)

    local ProfileImage = Instance.new("ImageLabel", ProfileFrame)
    ProfileImage.Size = UDim2.new(0, 26, 0, 26)
    ProfileImage.Position = UDim2.new(0, 5, 0.5, -13)
    ProfileImage.BackgroundColor3 = Config.SidebarColor
    ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)

    local ProfileName = Instance.new("TextLabel", ProfileFrame)
    ProfileName.Size = UDim2.new(1, -38, 0, 14)
    ProfileName.Position = UDim2.new(0, 36, 0, 4)
    ProfileName.BackgroundTransparency = 1
    ProfileName.Text = LocalPlayer.DisplayName
    ProfileName.TextColor3 = Config.TextPrimary
    ProfileName.Font = Enum.Font.GothamBold
    ProfileName.TextSize = 10
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left

    local SessionTime = Instance.new("TextLabel", ProfileFrame)
    SessionTime.Size = UDim2.new(1, -38, 0, 12)
    SessionTime.Position = UDim2.new(0, 36, 0, 18)
    SessionTime.BackgroundTransparency = 1
    SessionTime.Text = "Session: 0s"
    SessionTime.TextColor3 = Config.TextSecondary
    SessionTime.Font = Enum.Font.Gotham
    SessionTime.TextSize = 9
    SessionTime.TextXAlignment = Enum.TextXAlignment.Left

    local startTime = os.time()
    task.spawn(function()
        while MainGui.Parent and task.wait(1) do
            local elapsed = os.time() - startTime
            SessionTime.Text = "Session: " .. elapsed .. "s"
        end
    end)

    MainFrame.Size = UDim2.new(0, 100, 0, 60)
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = Config.WindowSize
    }):Play()

    local function OpenMainUI()
        MainFrame.Visible = true
        TopPill.Visible = false
        MainFrame.Size = UDim2.new(0, 100, 0, 60)
        TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = Config.WindowSize
        }):Play()
    end

    local function CloseUI()
        local anim = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        anim:Play()
        anim.Completed:Connect(function()
            MainFrame.Visible = false
            TopPill.Visible = true
        end)
    end

    TopPill.MouseButton1Click:Connect(OpenMainUI)
    MinimizeBtn.MouseButton1Click:Connect(CloseUI)

    CloseBtn.MouseButton1Click:Connect(function()
        local anim = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        anim:Play()
        anim.Completed:Connect(function()
            for _, data in pairs(ActiveDrawings) do
                if data.Box then data.Box:Remove() end
                if data.Bones then
                    for _, line in pairs(data.Bones) do line:Remove() end
                end
            end
            if AutoMine then pcall(AutoMine.Stop) end
            if AutoTrash then pcall(AutoTrash.Stop) end
            JanitorState.AutoFarm = false
            FarmState.AutoCook = false
            FarmState.AutoFish = false
            FarmState.AutoSell = false
            AutoHungerState.Enabled = false
            if UtilityState.NoclipConnection then
                UtilityState.NoclipConnection:Disconnect()
                UtilityState.NoclipConnection = nil
            end
            if UtilityState.SavedLighting then
                local Lighting = game:GetService("Lighting")
                local saved = UtilityState.SavedLighting
                Lighting.Brightness = saved.Brightness
                Lighting.ClockTime = saved.ClockTime
                Lighting.GlobalShadows = saved.GlobalShadows
                Lighting.FogEnd = saved.FogEnd
                Lighting.ExposureCompensation = saved.ExposureCompensation
                UtilityState.SavedLighting = nil
            end
            MainGui:Destroy()
        end)
    end)
    local Tabs = {}
    local Pages = {}

    local function CreateTab(name, layoutOrder)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 28)
        TabBtn.BackgroundColor3 = (layoutOrder == 1) and Config.ContainerActive or Config.ContainerColor
        TabBtn.BackgroundTransparency = 0.2
        TabBtn:SetAttribute("SynaxOriginalText", name)
        TabBtn.Text = "  " .. Translate(name)
        TabBtn.TextColor3 = Config.TextPrimary
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 11
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.LayoutOrder = layoutOrder
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", PagesContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Config.TextSecondary
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = (layoutOrder == 1)

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 12)
        end)

        Tabs[name] = TabBtn
        Pages[name] = Page

        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(Tabs) do
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.ContainerColor}):Play()
            end
            for _, p in pairs(Pages) do
                p.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.ContainerActive}):Play()
            Page.Visible = true
            Page.CanvasPosition = Vector2.zero
        end)

        return Page
    end

    local function CreateButton(parent, text, callback)
        local Btn = Instance.new("TextButton", parent)
        Btn.Size = UDim2.new(1, -10, 0, 32)
        Btn.BackgroundColor3 = Config.ContainerColor
        Btn.BackgroundTransparency = 0.2
        Btn:SetAttribute("SynaxOriginalText", text)
        Btn.Text = Translate(text)
        Btn.TextColor3 = Config.TextPrimary
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        Btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return Btn
    end

    local function CreateToggle(parent, text, defaultState, callback)
        local ToggleFrame = Instance.new("Frame", parent)
        ToggleFrame.Size = UDim2.new(1, -10, 0, 32)
        ToggleFrame.BackgroundColor3 = Config.ContainerColor
        ToggleFrame.BackgroundTransparency = 0.2
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

        local Label = Instance.new("TextLabel", ToggleFrame)
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label:SetAttribute("SynaxOriginalText", text)
        Label.Text = Translate(text)
        Label.TextColor3 = Config.TextPrimary
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Indicator = Instance.new("TextButton", ToggleFrame)
        Indicator.Size = UDim2.new(0, 36, 0, 18)
        Indicator.Position = UDim2.new(1, -44, 0.5, -9)
        Indicator.BackgroundColor3 = defaultState and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(35, 40, 52)
        Indicator.BorderSizePixel = 0
        Indicator:SetAttribute("SynaxToggleIndicator", true)
        Indicator:SetAttribute("SynaxToggleState", defaultState)
        Indicator.Text = Translate(defaultState and "ON" or "OFF")
        Indicator.TextColor3 = defaultState and Config.Accent or Config.TextSecondary
        Indicator.Font = Enum.Font.GothamBold
        Indicator.TextSize = 9
        Indicator.AutoButtonColor = false
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 9)

        local state = defaultState
        Indicator.MouseButton1Click:Connect(function()
            state = not state
            if state then
                Indicator.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
                Indicator:SetAttribute("SynaxToggleState", true)
                Indicator.Text = Translate("ON")
                Indicator.TextColor3 = Config.Accent
            else
                Indicator.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
                Indicator:SetAttribute("SynaxToggleState", false)
                Indicator.Text = Translate("OFF")
                Indicator.TextColor3 = Config.TextSecondary
            end
            if callback then callback(state) end
        end)

        return ToggleFrame
    end

    local function CreateCard(parent, titleText, initialVal)
        local Card = Instance.new("Frame", parent)
        Card.Size = UDim2.new(1, -10, 0, 34)
        Card.BackgroundColor3 = Config.ContainerColor
        Card.BackgroundTransparency = 0.2
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

        local TitleLbl = Instance.new("TextLabel", Card)
        TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
        TitleLbl.Position = UDim2.new(0, 10, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl:SetAttribute("SynaxOriginalText", titleText)
        TitleLbl.Text = Translate(titleText)
        TitleLbl.TextColor3 = Config.TextSecondary
        TitleLbl.Font = Enum.Font.GothamMedium
        TitleLbl.TextSize = 11
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        local ValLbl = Instance.new("TextLabel", Card)
        ValLbl.Size = UDim2.new(0.4, -10, 1, 0)
        ValLbl.Position = UDim2.new(0.6, 0, 0, 0)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = initialVal
        ValLbl.TextColor3 = Config.HighlightText
        ValLbl.Font = Enum.Font.GothamBold
        ValLbl.TextSize = 11
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right

        return ValLbl
    end


    local DashboardPage = CreateTab("Dashboard", 1)
    local InfoPage      = CreateTab("Information", 2)
    local FarmEarningPage = CreateTab("Farm Earning", 3)
    local FarmPage      = CreateTab("Farm", 4)
    local AutoEatPage   = CreateTab("Auto Eat", 5)
    local CombatPage    = CreateTab("Combat", 6)
    local EspPage       = CreateTab("ESP", 7)
    local StaffPage     = CreateTab("Staff", 8)
    local ExtraPage     = CreateTab("Extra", 9)
    local SettingsPage  = CreateTab("Settings", 10)

    -----------------------------------------------------------------------
    -- [ COMBAT ]
    -- Reserved for a future update. No combat/aim-assist UI is included.
    -----------------------------------------------------------------------
    CreateCard(CombatPage, "COMBAT FEATURES WILL BE ADDED IN A FUTURE UPDATE.", "Combat systems are currently unavailable in v1.0.0.")

    -----------------------------------------------------------------------
    -- [ STAFF SYSTEM ]
    -- Single integrated Staff Monitor. Uses the supplied staff-role map,
    -- existing SynaxHub page/helpers, and creates no separate ScreenGui.
    -----------------------------------------------------------------------
    local StaffState = {
        Enabled = false,
        ESP = false,
        Alerts = false,
        FarmProtection = false,
        KickOnStaffJoin = false,
        ScanInterval = 2,
        Online = {},
        JoinTimes = {}
    }

    local STAFF_GROUP_ID = 304256484

    local STAFF_ROLES = {
        [774340190] = {name = "Tester", rank = 120},
        [616437365] = {name = "Modérateur Test", rank = 200},
        [616991309] = {name = "Modérateur Junior", rank = 201},
        [616937284] = {name = "Modérateur", rank = 202},
        [556964175] = {name = "Modérateur Sénior", rank = 203},
        [619803001] = {name = "Administrateur Junior", rank = 204},
        [617179396] = {name = "Administrateur", rank = 205},
        [616849364] = {name = "Administrateur Sénior", rank = 206},
        [673879028] = {name = "Administrateur d'État", rank = 207},
        [668615019] = {name = "Responsable Staff", rank = 208},
        [732513005] = {name = "Communication Manager", rank = 209},
        [740501056] = {name = "Leadership Team", rank = 210},
        [556052113] = {name = "Heni", rank = 253},
        [556780032] = {name = "Developper", rank = 254},
        [558880049] = {name = "Fondateur Heni", rank = 255},
    }

    local function getStaffData(player)
        if not player or player == LocalPlayer then return nil end

        local direct = STAFF_ROLES[player.UserId]
        if direct then return direct end

        local ok, role = pcall(function()
            return player:GetRoleInGroup(STAFF_GROUP_ID)
        end)

        if ok and role and role ~= "Guest" and role ~= "" then
            for _, data in pairs(STAFF_ROLES) do
                if role == data.name then
                    return data
                end
            end
            return {name = role, rank = 100}
        end

        return nil
    end

    local function getStaffDistance(player)
        local myChar = LocalPlayer.Character
        local targetChar = player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if not myRoot or not targetRoot then return nil end
        return math.floor((myRoot.Position - targetRoot.Position).Magnitude)
    end

    local function getActiveTime(player)
        local start = StaffState.JoinTimes[player.UserId]
        if not start then return "00:00" end

        local seconds = math.max(0, math.floor(os.clock() - start))
        return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
    end

    local function removeStaffESP(player)
        if not player or not player.Character then return end
        local character = player.Character

        local highlight = character:FindFirstChild("SynaxStaffHighlight")
        if highlight then highlight:Destroy() end

        local head = character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("SynaxStaffTag")
            if tag then tag:Destroy() end
        end
    end

    local function addStaffESP(player, data)
        if not StaffState.ESP or player == LocalPlayer or not player.Character then return end

        local character = player.Character
        local highlight = character:FindFirstChild("SynaxStaffHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "SynaxStaffHighlight"
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.FillColor = Color3.fromRGB(255, 65, 65)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
        end

        local head = character:FindFirstChild("Head")
        if not head then return end

        local tag = head:FindFirstChild("SynaxStaffTag")
        if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = "SynaxStaffTag"
            tag.Size = UDim2.fromOffset(175, 62)
            tag.StudsOffset = Vector3.new(0, 3.2, 0)
            tag.AlwaysOnTop = true
            tag.MaxDistance = 5000
            tag.Parent = head

            local label = Instance.new("TextLabel")
            label.Name = "StaffText"
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(255, 85, 85)
            label.TextStrokeTransparency = 0.25
            label.TextSize = 10
            label.Font = Enum.Font.GothamBold
            label.TextWrapped = true
            label.Parent = tag
        end

        local label = tag:FindFirstChild("StaffText")
        if label then
            local distance = getStaffDistance(player)
            label.Text = string.format(
                "⚠ STAFF\n%s\n%s • Rank %s\nActive %s • %s",
                player.DisplayName,
                data.name,
                tostring(data.rank),
                getActiveTime(player),
                distance and (tostring(distance) .. "m") or "?m"
            )
        end
    end

    local function stopLocalFarm()
        if not StaffState.FarmProtection then return end

        pcall(function()
            if FarmState then
                FarmState.AutoCook = false
                FarmState.AutoFish = false
                FarmState.AutoSell = false
            end
            if AutoHungerState then AutoHungerState.Enabled = false end
            if JanitorState then JanitorState.AutoFarm = false end
            if AutoMine and AutoMine.Stop then AutoMine.Stop() end
            if AutoTrash and AutoTrash.Stop then AutoTrash.Stop() end
        end)
    end

    local function notifyStaffJoin(player, data)
        if not StaffState.Alerts then return end
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "⚠ STAFF JOINED",
                Text = player.Name .. " • " .. data.name,
                Duration = 5
            })
        end)
    end

    local function scanStaff()
        if not StaffState.Enabled then return end

        local detected = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local data = getStaffData(player)

                if data then
                    local wasKnown = StaffState.JoinTimes[player.UserId] ~= nil
                    if not wasKnown then
                        StaffState.JoinTimes[player.UserId] = os.clock()
                        notifyStaffJoin(player, data)
                    end

                    table.insert(detected, {
                        Player = player,
                        Data = data
                    })

                    if StaffState.ESP then
                        addStaffESP(player, data)
                    end
                else
                    removeStaffESP(player)
                end
            end
        end

        table.sort(detected, function(a, b)
            return a.Data.rank > b.Data.rank
        end)

        StaffState.Online = detected

        if #detected > 0 then
            if StaffState.FarmProtection then
                stopLocalFarm()
            end

            if StaffState.KickOnStaffJoin then
                local first = detected[1]
                local staffName = (first and first.Player) and first.Player.Name or "Unknown"
                local staffRole = (first and first.Data) and first.Data.name or "Staff"
                pcall(function()
                    LocalPlayer:Kick("Staff Join Detected: " .. staffName .. " (" .. staffRole .. ")")
                end)
                return
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        task.delay(1, scanStaff)
        player.CharacterAdded:Connect(function()
            task.delay(1, scanStaff)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        StaffState.JoinTimes[player.UserId] = nil
        removeStaffESP(player)
        task.defer(scanStaff)
    end)

    task.spawn(function()
        while MainGui.Parent do
            task.wait(StaffState.ScanInterval)
            scanStaff()
        end
    end)

    task.spawn(function()
        while MainGui.Parent do
            task.wait(0.25)
            if StaffState.ESP then
                for _, entry in ipairs(StaffState.Online) do
                    if entry.Player and entry.Player.Parent then
                        addStaffESP(entry.Player, entry.Data)
                    end
                end
            end
        end
    end)

    -----------------------------------------------------------------------
    -- [ STAFF TAB ]
    -----------------------------------------------------------------------
    local function BuildStaffCategory(StaffPage, Config, CreateCard, CreateToggle, CreateButton)
        local StaffTitle = Instance.new("TextLabel", StaffPage)
        StaffTitle.Size = UDim2.new(1, -10, 0, 20)
        StaffTitle.BackgroundTransparency = 1
        StaffTitle.Text = "Staff Monitor"
        StaffTitle.TextColor3 = Config.HighlightText
        StaffTitle.Font = Enum.Font.GothamBold
        StaffTitle.TextSize = 12
        StaffTitle.TextXAlignment = Enum.TextXAlignment.Left

        local StaffCountCard = CreateCard(StaffPage, "Staff Online", "0")

        local StaffList = Instance.new("TextLabel", StaffPage)
        StaffList.Size = UDim2.new(1, -10, 0, 125)
        StaffList.BackgroundColor3 = Config.ContainerColor
        StaffList.BackgroundTransparency = 0.2
        StaffList.TextColor3 = Config.TextPrimary
        StaffList.Font = Enum.Font.Gotham
        StaffList.TextSize = 10
        StaffList.TextWrapped = true
        StaffList.TextXAlignment = Enum.TextXAlignment.Left
        StaffList.TextYAlignment = Enum.TextYAlignment.Top
        StaffList.Text = "No staff detected."
        StaffList.Parent = StaffPage
        Instance.new("UICorner", StaffList).CornerRadius = UDim.new(0, 6)

        local function updateStaffList()
            local online = StaffState.Online
            StaffCountCard.Text = tostring(#online)

            if #online == 0 then
                StaffList.Text = "No staff detected."
                return
            end

            local output = {}
            for _, entry in ipairs(online) do
                local player = entry.Player
                local data = entry.Data

                if player and data then
                    local distance = getStaffDistance(player)
                    table.insert(output, string.format(
                        "⚠ %s\n   %s • Rank %s\n   Active: %s • Distance: %s",
                        player.Name,
                        data.name,
                        tostring(data.rank),
                        getActiveTime(player),
                        distance and (tostring(distance) .. "m") or "?"
                    ))
                end
            end

            StaffList.Text = table.concat(output, "\n\n")
        end

        CreateToggle(StaffPage, "Staff ESP", false, function(state)
            StaffState.ESP = state
            if not state then
                for _, player in ipairs(Players:GetPlayers()) do
                    removeStaffESP(player)
                end
            else
                scanStaff()
            end
        end)

        CreateToggle(StaffPage, "Staff Alerts", false, function(state)
            StaffState.Alerts = state
        end)

        CreateToggle(StaffPage, "Farm Protection", false, function(state)
            StaffState.FarmProtection = state
            if state and #StaffState.Online > 0 then
                stopLocalFarm()
            end
        end)

        CreateToggle(StaffPage, "Leave on Staff Join", false, function(state)
            StaffState.KickOnStaffJoin = state
            if state and #StaffState.Online > 0 then
                local first = StaffState.Online[1]
                local staffName = (first and first.Player) and first.Player.Name or "Unknown"
                local staffRole = (first and first.Data) and first.Data.name or "Staff"
                pcall(function()
                    LocalPlayer:Kick("Staff Join Detected: " .. staffName .. " (" .. staffRole .. ")")
                end)
            end
        end)

        CreateButton(StaffPage, "SCAN STAFF", function()
            scanStaff()
            updateStaffList()
        end)

        task.spawn(function()
            while StaffPage and StaffPage.Parent do
                task.wait(0.5)
                updateStaffList()
            end
        end)
    end

    BuildStaffCategory(StaffPage, Config, CreateCard, CreateToggle, CreateButton)
    -----------------------------------------------------------------------
    -- [ DASHBOARD ]
    -----------------------------------------------------------------------
    local FpsLabel    = CreateCard(DashboardPage, "FPS Rate", "calculating...")
    local PingLabel   = CreateCard(DashboardPage, "MS (Ping)", "calculating...")
    local PlayerLabel = CreateCard(DashboardPage, "Server Players", "0 / 0")
    local FriendLabel = CreateCard(DashboardPage, "Active Friends", "0")
    local ServerHubLabel = CreateCard(DashboardPage, "Server Hub", "Loading...")
    local ServerRegionLabel = CreateCard(DashboardPage, "Server Region", "Unavailable")

    local ResetBtn = Instance.new("TextButton", DashboardPage)
    ResetBtn.Size = UDim2.new(1, -10, 0, 34)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    ResetBtn.BackgroundTransparency = 0.2
    ResetBtn.Text = "RESET SCRIPT"
    ResetBtn.TextColor3 = Config.Accent
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = 11
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

    ResetBtn.MouseButton1Click:Connect(function()
        ExecuteScript()
    end)

    local frameCount, lastTime = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        if not MainGui.Parent then return end
        frameCount += 1
        local currentTime = os.clock()
        if currentTime - lastTime >= 1 then
            FpsLabel.Text = tostring(frameCount) .. " FPS"
            frameCount = 0
            lastTime = currentTime
        end
    end)

    task.spawn(function()
        while MainGui.Parent and task.wait(1.5) do
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            PingLabel.Text = tostring(ping) .. " ms"

            local currentPlayers = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            PlayerLabel.Text = currentPlayers .. " / " .. maxPlayers

            local friendsInServer = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and LocalPlayer:IsFriendsWith(p.UserId) then
                    friendsInServer += 1
                end
            end
            FriendLabel.Text = tostring(friendsInServer)

            -- Roblox does not expose the physical server region to LocalScripts.
            ServerHubLabel.Text = "Job ID: " .. tostring(game.JobId ~= "" and game.JobId or "N/A")
            ServerRegionLabel.Text = "Unavailable (client-side)"
        end
    end)

    -----------------------------------------------------------------------
    -- [ FARM TAB ]
    -- Functional farm systems integrated from the supplied farm scripts.
    -----------------------------------------------------------------------
        -----------------------------------------------------------------------
    -- [ FARM EARNING TAB ]
    -----------------------------------------------------------------------
    local FarmEarningMoneyLabel = CreateCard(FarmEarningPage, "Current Money", "Detecting...")
    local FarmEarningSessionLabel = CreateCard(FarmEarningPage, "Session Earnings", "0")
    local FarmEarningActiveLabel = CreateCard(FarmEarningPage, "Active Farms", "Idle")

    task.spawn(function()
        while MainGui.Parent do
            task.wait(0.5)
            local money = FarmEarning_ReadMoney()
            if money then
                FarmEarningState.CurrentMoney = money
                if not FarmEarningState.SessionStartMoney then
                    FarmEarningState.SessionStartMoney = money
                end
                FarmEarningMoneyLabel.Text = tostring(math.floor(money))
                FarmEarningSessionLabel.Text = "+" ..
                    tostring(math.floor(math.max(0, money - FarmEarningState.SessionStartMoney)))
                local active = {}
                for farmName, data in pairs(FarmEarningState.Farms) do
                    if data.Active then
                        if data.StartMoney then
                            data.Earned = math.max(0, money - data.StartMoney)
                        end
                        table.insert(active, farmName .. ": +" .. tostring(math.floor(data.Earned)))
                    end
                end
                table.sort(active)
                FarmEarningActiveLabel.Text = #active > 0 and table.concat(active, "\n") or Translate("Idle")
            else
                FarmEarningMoneyLabel.Text = "N/A"
                FarmEarningSessionLabel.Text = "N/A"
                FarmEarningActiveLabel.Text = Translate("Idle")
            end
        end
    end)

local FarmTitle = Instance.new("TextLabel", FarmPage)
    FarmTitle.Size = UDim2.new(1, -10, 0, 20)
    FarmTitle.BackgroundTransparency = 1
    FarmTitle.Text = "Farming"
    FarmTitle.TextColor3 = Config.HighlightText
    FarmTitle.Font = Enum.Font.GothamBold
    FarmTitle.TextSize = 12
    FarmTitle.TextXAlignment = Enum.TextXAlignment.Left

    CreateToggle(FarmPage, "Auto Cook", false, function(state)
        FarmState.AutoCook = state
        FarmEarning_SetFarm("Auto Cook", state)
    end)

    CreateToggle(FarmPage, "Fish Farm", false, function(state)
        FarmState.AutoFish = state
        FarmEarning_SetFarm("Fish Farm", state)

        if not state then
            pcall(function()
                if MinigameSystem then
                    MinigameSystem:SetHolding(false)
                end
            end)

            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid.WalkSpeed = 16
                pcall(function() humanoid.JumpPower = 50 end)
                pcall(function() humanoid.JumpHeight = 7.2 end)
            end
        end
    end)

    CreateToggle(FarmPage, "Auto Sell Fish", false, function(state)
        FarmState.AutoSell = state
        FarmEarning_SetFarm("Auto Sell Fish", state)
    end)

    CreateButton(FarmPage, "Sell All Fish Now", function()
        pcall(function()
            if not FishingSystem then
                FishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            end

            local inventoryEvents = FishingSystem and FishingSystem:FindFirstChild("InventoryEvents")
            local sellAll = inventoryEvents and inventoryEvents:FindFirstChild("Inventory_SellAll")

            if sellAll and sellAll:IsA("RemoteFunction") then
                sellAll:InvokeServer()
            end
        end)
    end)

    CreateButton(FarmPage, "Teleport to Fishing Area", function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local fz = Workspace:FindFirstChild("FishingZone")

        if hrp and fz then
            pcall(function()
                hrp.CFrame = fz:GetPivot() + Vector3.new(0, 5, 0)
            end)
        end
    end)

    CreateToggle(FarmPage, "Auto Mine", false, function(state)
        FarmEarning_SetFarm("Auto Mine", state)
        if state then
            AutoMine.Start()
        else
            AutoMine.Stop()
        end
    end)

    CreateToggle(FarmPage, "Auto Trash (EXP)", false, function(state)
        FarmEarning_SetFarm("Auto Trash", state)
        if state then
            AutoTrash.Start()
        else
            AutoTrash.Stop()
        end
    end)

    CreateButton(FarmPage, "Unlock Fists", unlockFists)

    local JanitorTitle = Instance.new("TextLabel", FarmPage)
    JanitorTitle.Size = UDim2.new(1, -10, 0, 20)
    JanitorTitle.BackgroundTransparency = 1
    JanitorTitle.Text = "Janitor Farm"
    JanitorTitle.TextColor3 = Config.HighlightText
    JanitorTitle.Font = Enum.Font.GothamBold
    JanitorTitle.TextSize = 12
    JanitorTitle.TextXAlignment = Enum.TextXAlignment.Left

    local JanitorStatus = CreateCard(FarmPage, "Janitor Status", "Idle")
    local janitorStatusLast = ""

    task.spawn(function()
        while MainGui.Parent do
            task.wait(0.5)

            local text
            if JanitorState.AutoFarm then
                text = "Running | " .. JanitorState.PuddlesDone .. " | " .. JanitorState.LastPuddle
            else
                text = "Idle | " .. JanitorState.PuddlesDone
            end

            if text ~= janitorStatusLast then
                JanitorStatus.Text = text
                janitorStatusLast = text
            end
        end
    end)

    CreateToggle(FarmPage, "Janitor Farm", false, function(state)
        JanitorState.AutoFarm = state
        FarmEarning_SetFarm("Janitor Farm", state)

        if state then
            task.spawn(janitorFarmLoop)
        end
    end)

    CreateButton(FarmPage, "Equip Mop", function()
        equipMop()
    end)

    CreateButton(FarmPage, "Clean Nearest Puddle", function()
        task.spawn(cleanNearestPuddle)
    end)

    CreateButton(FarmPage, "Teleport to Janitor Area", teleportToJanitor)
    CreateButton(FarmPage, "Cycle Through All Puddles", cycleAllPuddles)

    local function CreateFarmSlider(parent, title, minValue, maxValue, defaultValue, step, suffix, callback)
        local holder = Instance.new("Frame", parent)
        holder.Size = UDim2.new(1, -10, 0, 42)
        holder.BackgroundColor3 = Config.ContainerColor
        holder.BackgroundTransparency = 0.2
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", holder)
        label.Size = UDim2.new(1, -20, 0, 18)
        label.Position = UDim2.new(0, 10, 0, 2)
        label.BackgroundTransparency = 1
        label:SetAttribute("SynaxSliderTitle", title)
        label:SetAttribute("SynaxSliderSuffix", suffix)
        label:SetAttribute("SynaxSliderValue", defaultValue)
        label.TextColor3 = Config.TextPrimary
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("TextButton", holder)
        bar.Size = UDim2.new(1, -20, 0, 8)
        bar.Position = UDim2.new(0, 10, 0, 27)
        bar.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
        bar.BorderSizePixel = 0
        bar.Text = ""
        bar.AutoButtonColor = false
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.BackgroundColor3 = Config.HighlightText
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local dragging = false

        local function setValue(value)
            value = math.clamp(value, minValue, maxValue)
            value = math.floor((value - minValue) / step + 0.5) * step + minValue
            value = math.clamp(value, minValue, maxValue)

            local alpha = (value - minValue) / (maxValue - minValue)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            label:SetAttribute("SynaxSliderValue", value)
            label.Text = Translate(title) .. ": " .. tostring(value) .. suffix
            callback(value)
        end

        local function updateFromInput(input)
            local alpha = math.clamp(
                (input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1),
                0,
                1
            )

            setValue(minValue + (maxValue - minValue) * alpha)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromInput(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            ) then
                updateFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        setValue(defaultValue)
        return holder
    end

    CreateFarmSlider(
        FarmPage,
        "Hits per puddle",
        1, 8,
        JanitorState.HitsPerPuddle,
        1,
        " fires",
        function(value)
            JanitorState.HitsPerPuddle = value
        end
    )

    CreateFarmSlider(
        FarmPage,
        "Delay between fires",
        0, 2,
        JanitorState.CleanDelay,
        0.05,
        "s",
        function(value)
            JanitorState.CleanDelay = value
        end
    )

    CreateFarmSlider(
        FarmPage,
        "Teleport settle time",
        0, 1,
        JanitorState.TpWait,
        0.05,
        "s",
        function(value)
            JanitorState.TpWait = value
        end
    )

    CreateFarmSlider(
        FarmPage,
        "Fish sell interval",
        5, 120,
        FarmState.SellInterval,
        1,
        "s",
        function(value)
            FarmState.SellInterval = value
        end
    )

    -----------------------------------------------------------------------
    -- [ ESP TAB ]
    -- Integrated C11 SYNAX Ultimate ESP Engine.
    -- No external ESP UI is created; every control uses the existing hub UI.
    -----------------------------------------------------------------------
    local ESPState = {
        GlowEspActive = false,
        HealthBarActive = false,
        StatusEspActive = false,
        TracerActive = false,
        DetectionRadius = 150,
        ShowCircleTemp = false,
        SpecialEspTarget = nil,
        SpecialEspActive = false,
        InventoryEspActive = false
    }

    local ESP_Lines = {}
    local ESP_RoleTexts = {}
    local ESP_HealthBarBg = {}
    local ESP_HealthBarFill = {}
    local ESP_InventoryHolders = {}
    local ESP_ZoneCircle = nil

    pcall(function()
        ESP_ZoneCircle = Drawing.new("Circle")
        ESP_ZoneCircle.Visible = false
        ESP_ZoneCircle.Thickness = 2
        ESP_ZoneCircle.NumSides = 40
    end)

    local function ESP_RemovePlayerDrawings(playerName)
        if ESP_Lines[playerName] then
            pcall(function() ESP_Lines[playerName]:Remove() end)
            ESP_Lines[playerName] = nil
        end
        if ESP_RoleTexts[playerName] then
            pcall(function() ESP_RoleTexts[playerName]:Remove() end)
            ESP_RoleTexts[playerName] = nil
        end
        if ESP_HealthBarBg[playerName] then
            pcall(function() ESP_HealthBarBg[playerName]:Remove() end)
            ESP_HealthBarBg[playerName] = nil
        end
        if ESP_HealthBarFill[playerName] then
            pcall(function() ESP_HealthBarFill[playerName]:Remove() end)
            ESP_HealthBarFill[playerName] = nil
        end
        if ESP_InventoryHolders[playerName] then
            pcall(function() ESP_InventoryHolders[playerName]:Destroy() end)
            ESP_InventoryHolders[playerName] = nil
        end
    end

    local function ESP_ClearAllDrawings()
        local names = {}
        for name in pairs(ESP_Lines) do names[name] = true end
        for name in pairs(ESP_RoleTexts) do names[name] = true end
        for name in pairs(ESP_HealthBarBg) do names[name] = true end
        for name in pairs(ESP_HealthBarFill) do names[name] = true end
        for name in pairs(ESP_InventoryHolders) do names[name] = true end
        for name in pairs(names) do ESP_RemovePlayerDrawings(name) end
    end

    local function ESP_GetPlayerList()
        local result = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then table.insert(result, player.Name) end
        end
        table.sort(result)
        return result
    end

    local function ESP_GetPlayerRole(player)
        if player.Team then
            return player.Team.Name, player.Team.TeamColor.Color
        end
        return "Citizen", Color3.fromRGB(255, 170, 0)
    end

    local function ESP_GetPlayerStatus(player)
        local statusList = {}
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local wanted = leaderstats:FindFirstChild("Wanted")
                or leaderstats:FindFirstChild("Wanted Level")
                or player:FindFirstChild("Wanted")
            if wanted and (wanted.Value == true or (type(wanted.Value) == "number" and wanted.Value > 0)) then
                table.insert(statusList, "[WANTED]")
            end
        end
        if player.Team then
            local teamName = player.Team.Name:lower()
            if teamName:find("wanted") or teamName:find("aranıyor") then
                if not table.find(statusList, "[WANTED]") then
                    table.insert(statusList, "[WANTED]")
                end
            end
            if teamName:find("hostile") or teamName:find("criminal")
                or teamName:find("düşman") or teamName:find("raider") then
                table.insert(statusList, "[HOSTILE]")
            end
        end
        return #statusList > 0 and table.concat(statusList, " ") or ""
    end

    local function ESP_GetPlayerTools(player)
        local tools = {}
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then table.insert(tools, item) end
            end
        end
        if character then
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Tool") then table.insert(tools, item) end
            end
        end
        return tools
    end

    CreateToggle(EspPage, "Glow ESP + Role Info", false, function(value)
        ESPState.GlowEspActive = value
        if not value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local glow = player.Character:FindFirstChild("C11_Glow_Outline")
                    if glow then glow:Destroy() end
                end
            end
        end
    end)

    CreateToggle(EspPage, "Clean Health Bar (2D Dynamic)", false, function(value)
        ESPState.HealthBarActive = value
        if not value then
            for _, drawing in pairs(ESP_HealthBarBg) do pcall(function() drawing.Visible = false end) end
            for _, drawing in pairs(ESP_HealthBarFill) do pcall(function() drawing.Visible = false end) end
        end
    end)

    CreateToggle(EspPage, "Show Status Tag (Wanted / Hostile)", false, function(value)
        ESPState.StatusEspActive = value
    end)

    CreateToggle(EspPage, "Inventory ESP (Visual Item Icons)", false, function(value)
        ESPState.InventoryEspActive = value
        if not value then
            for _, holder in pairs(ESP_InventoryHolders) do
                if holder then holder.Visible = false end
            end
        end
    end)

    local ESPRadiusSlider = CreateFarmSlider(
        EspPage, "Zone Radius Size", 20, 500, 150, 10, " Studs",
        function(value)
            ESPState.DetectionRadius = value
            ESPState.ShowCircleTemp = true
            task.delay(2, function()
                ESPState.ShowCircleTemp = false
                if ESP_ZoneCircle then ESP_ZoneCircle.Visible = false end
            end)
        end
    )

    CreateToggle(EspPage, "Distance Tracers", false, function(value)
        ESPState.TracerActive = value
        if not value then
            for _, line in pairs(ESP_Lines) do pcall(function() line.Visible = false end) end
        end
    end)

    local SpecialPlayerLabel = Instance.new("TextLabel", EspPage)
    SpecialPlayerLabel.Size = UDim2.new(1, -10, 0, 22)
    SpecialPlayerLabel.BackgroundTransparency = 1
    SpecialPlayerLabel.Text = "Select Special Player: None"
    SpecialPlayerLabel.TextColor3 = Config.TextPrimary
    SpecialPlayerLabel.Font = Enum.Font.GothamMedium
    SpecialPlayerLabel.TextSize = 10
    SpecialPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpecialPlayerLabel:SetAttribute("SynaxOriginalText", "Select Special Player: None")

    local SpecialPlayerButton = CreateButton(EspPage, "Refresh Player List", function()
        local list = ESP_GetPlayerList()
        if #list == 0 then
            ESPState.SpecialEspTarget = nil
            SpecialPlayerLabel.Text = Translate("Select Special Player") .. ": None"
        else
            local currentIndex = table.find(list, ESPState.SpecialEspTarget) or 0
            local nextIndex = currentIndex + 1
            if nextIndex > #list then nextIndex = 1 end
            ESPState.SpecialEspTarget = list[nextIndex]
            SpecialPlayerLabel.Text = Translate("Select Special Player") .. ": " .. list[nextIndex]
        end
    end)

    CreateToggle(EspPage, "Special Player ESP (RGB Glow)", false, function(value)
        ESPState.SpecialEspActive = value
        if not value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("C11_RGB_Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)

    -- Keep the custom hub UI as the only control surface; the engine itself
    -- runs without Rayfield or another secondary UI.
    local ESP_LastSweep = 0
    local ESP_Connection
    ESP_Connection = RunService.RenderStepped:Connect(function()
        if not MainGui.Parent then
            if ESP_Connection then ESP_Connection:Disconnect() end
            return
        end

        local active = ESPState.GlowEspActive or ESPState.HealthBarActive
            or ESPState.StatusEspActive or ESPState.TracerActive
            or ESPState.InventoryEspActive or ESPState.SpecialEspActive

        local camera = workspace.CurrentCamera
        local localChar = LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")

        if ESP_ZoneCircle and ESPState.ShowCircleTemp and localHRP and camera then
            ESP_ZoneCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            ESP_ZoneCircle.Radius = ESPState.DetectionRadius * 2
            ESP_ZoneCircle.Color = Color3.fromHSV((tick() * 0.6) % 1, 0.9, 1)
            ESP_ZoneCircle.Visible = true
        elseif ESP_ZoneCircle then
            ESP_ZoneCircle.Visible = false
        end

        if not active or not localHRP or not camera then
            if os.clock() - ESP_LastSweep > 1 then
                ESP_ClearAllDrawings()
                ESP_LastSweep = os.clock()
            end
            return
        end

        local myScreenPos, myOnScreen = camera:WorldToViewportPoint(localHRP.Position)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                local targetHead = char:FindFirstChild("Head")
                local targetHum = char:FindFirstChildOfClass("Humanoid")

                if targetHRP then
                    local distance = (localHRP.Position - targetHRP.Position).Magnitude
                    local targetScreenPos, targetOnScreen = camera:WorldToViewportPoint(targetHRP.Position)
                    local headScreenPos, headOnScreen = camera:WorldToViewportPoint(
                        targetHead and targetHead.Position or targetHRP.Position
                    )

                    if ESPState.GlowEspActive then
                        local highlight = char:FindFirstChild("C11_Glow_Outline")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = "C11_Glow_Outline"
                            highlight.FillTransparency = 1
                            highlight.OutlineTransparency = 0
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.Parent = char
                        end

                        local roleName, roleColor = ESP_GetPlayerRole(player)
                        highlight.OutlineColor = roleColor

                        if headOnScreen then
                            local txt = ESP_RoleTexts[player.Name]
                            if not txt then
                                txt = Drawing.new("Text")
                                txt.Size = 13
                                txt.Center = true
                                txt.Outline = true
                                txt.OutlineColor = Color3.fromRGB(0, 0, 0)
                                ESP_RoleTexts[player.Name] = txt
                            end
                            local statusTag = ESPState.StatusEspActive and ESP_GetPlayerStatus(player) or ""
                            local displayTag = statusTag ~= "" and ("\n" .. statusTag) or ""
                            txt.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 30)
                            txt.Text = "@" .. player.Name .. " [" .. math.floor(distance) .. "m]\n["
                                .. roleName .. "]" .. displayTag
                            txt.Color = roleColor
                            txt.Visible = true
                        elseif ESP_RoleTexts[player.Name] then
                            ESP_RoleTexts[player.Name].Visible = false
                        end
                    elseif ESP_RoleTexts[player.Name] then
                        ESP_RoleTexts[player.Name].Visible = false
                    end

                    if ESPState.InventoryEspActive and headOnScreen then
                        local holder = ESP_InventoryHolders[player.Name]
                        if not holder then
                            holder = Instance.new("Frame")
                            holder.Name = player.Name .. "_SynaxInv"
                            holder.BackgroundTransparency = 1
                            holder.Size = UDim2.new(0, 150, 0, 25)
                            holder.Parent = MainGui
                            ESP_InventoryHolders[player.Name] = holder
                        end
                        holder.Visible = true
                        holder.Position = UDim2.fromOffset(headScreenPos.X - 75, headScreenPos.Y + 15)

                        for _, child in ipairs(holder:GetChildren()) do child:Destroy() end
                        for i, tool in ipairs(ESP_GetPlayerTools(player)) do
                            if i <= 5 then
                                local img = Instance.new("ImageLabel")
                                img.Size = UDim2.fromOffset(22, 22)
                                img.Position = UDim2.fromOffset((i - 1) * 24, 0)
                                img.BackgroundTransparency = 1
                                img.Image = "rbxassetid://6071575925"
                                pcall(function()
                                    if tool.TextureId ~= "" then
                                        img.Image = tool.TextureId
                                    elseif tool:FindFirstChild("Handle")
                                        and tool.Handle:FindFirstChildOfClass("SpecialMesh")
                                        and tool.Handle.SpecialMesh.TextureId ~= "" then
                                        img.Image = tool.Handle.SpecialMesh.TextureId
                                    end
                                end)
                                img.Parent = holder
                            end
                        end
                    elseif ESP_InventoryHolders[player.Name] then
                        ESP_InventoryHolders[player.Name].Visible = false
                    end

                    if ESPState.HealthBarActive and headOnScreen and targetHum then
                        if not ESP_HealthBarBg[player.Name] then
                            local bg = Drawing.new("Square")
                            bg.Thickness = 1
                            bg.Filled = true
                            bg.Color = Color3.fromRGB(0, 0, 0)
                            ESP_HealthBarBg[player.Name] = bg

                            local fill = Drawing.new("Square")
                            fill.Thickness = 1
                            fill.Filled = true
                            ESP_HealthBarFill[player.Name] = fill
                        end

                        local barHeight = math.clamp(1000 / math.max(distance, 1), 20, 50)
                        local posX = headScreenPos.X - 20
                        local posY = headScreenPos.Y - (barHeight / 2)
                        local healthPercent = math.clamp(
                            targetHum.MaxHealth > 0 and targetHum.Health / targetHum.MaxHealth or 0,
                            0, 1
                        )

                        local bg = ESP_HealthBarBg[player.Name]
                        bg.Size = Vector2.new(3, barHeight)
                        bg.Position = Vector2.new(posX, posY)
                        bg.Visible = true

                        local fill = ESP_HealthBarFill[player.Name]
                        fill.Size = Vector2.new(3, barHeight * healthPercent)
                        fill.Position = Vector2.new(posX, posY + barHeight * (1 - healthPercent))
                        fill.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        fill.Visible = true
                    else
                        if ESP_HealthBarBg[player.Name] then ESP_HealthBarBg[player.Name].Visible = false end
                        if ESP_HealthBarFill[player.Name] then ESP_HealthBarFill[player.Name].Visible = false end
                    end

                    if ESPState.TracerActive and targetOnScreen and myOnScreen
                        and distance <= ESPState.DetectionRadius then
                        if not ESP_Lines[player.Name] then
                            local line = Drawing.new("Line")
                            line.Thickness = 1.5
                            ESP_Lines[player.Name] = line
                        end
                        local line = ESP_Lines[player.Name]
                        line.From = Vector2.new(myScreenPos.X, myScreenPos.Y)
                        line.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                        if distance <= 30 then
                            line.Color = Color3.fromRGB(0, 255, 100)
                        elseif distance <= 80 then
                            line.Color = Color3.fromRGB(255, 170, 0)
                        else
                            line.Color = Color3.fromRGB(255, 50, 50)
                        end
                        line.Visible = true
                    elseif ESP_Lines[player.Name] then
                        ESP_Lines[player.Name].Visible = false
                    end
                else
                    ESP_RemovePlayerDrawings(player.Name)
                end
            else
                ESP_RemovePlayerDrawings(player.Name)
            end
        end

        if ESPState.SpecialEspActive and ESPState.SpecialEspTarget then
            local target = Players:FindFirstChild(ESPState.SpecialEspTarget)
            if target and target.Character then
                local glow = target.Character:FindFirstChild("C11_RGB_Highlight")
                if not glow then
                    glow = Instance.new("Highlight")
                    glow.Name = "C11_RGB_Highlight"
                    glow.FillTransparency = 1
                    glow.OutlineTransparency = 0
                    glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    glow.Parent = target.Character
                end
                glow.OutlineColor = Color3.fromHSV((tick() * 0.6) % 1, 0.9, 1)
            end
        end
    end)

    -----------------------------------------------------------------------
    -- [ AUTO EAT / DRINK ]
    -----------------------------------------------------------------------
    local HungerTitle = Instance.new("TextLabel", AutoEatPage)
    HungerTitle.Size = UDim2.new(1, -10, 0, 20)
    HungerTitle.BackgroundTransparency = 1
    HungerTitle.Text = "Auto Hunger System"
    HungerTitle.TextColor3 = Config.HighlightText
    HungerTitle.Font = Enum.Font.GothamBold
    HungerTitle.TextSize = 12
    HungerTitle.TextXAlignment = Enum.TextXAlignment.Left

    local HungerStatus = CreateCard(AutoEatPage, "Status", "Idle")

    task.spawn(function()
        while MainGui.Parent do
            task.wait(0.5)

            local status = AutoEatStatusLabel
            local hunger = LocalPlayer:GetAttribute("Hunger")
            local thirst = LocalPlayer:GetAttribute("Thirst")

            if hunger ~= nil or thirst ~= nil then
                status = status .. " | H:" .. tostring(hunger or "?") ..
                    " T:" .. tostring(thirst or "?")
            end

            HungerStatus.Text = status
        end
    end)

    CreateToggle(AutoEatPage, "Enable Auto Eat / Drink", false, function(state)
        AutoHungerState.Enabled = state

        if not state then
            AutoEatStatusLabel = "Idle"
        end
    end)

    CreateFarmSlider(
        AutoEatPage,
        "Eat when Hunger below",
        5, 95,
        AutoHungerState.EatBelow,
        1,
        "%",
        function(value)
            AutoHungerState.EatBelow = value
        end
    )

    CreateFarmSlider(
        AutoEatPage,
        "Drink when Thirst below",
        5, 95,
        AutoHungerState.DrinkBelow,
        1,
        "%",
        function(value)
            AutoHungerState.DrinkBelow = value
        end
    )

    local HungerInfo = Instance.new("TextLabel", AutoEatPage)
    HungerInfo.Size = UDim2.new(1, -10, 0, 55)
    HungerInfo.BackgroundTransparency = 1
    HungerInfo.Text = "Automatically consumes food/drinks from your inventory. " ..
        "If none are available, it searches vending machines and attempts to purchase " ..
        "the required item."
    HungerInfo.TextColor3 = Config.TextSecondary
    HungerInfo.Font = Enum.Font.Gotham
    HungerInfo.TextSize = 10
    HungerInfo.TextWrapped = true
    HungerInfo.TextXAlignment = Enum.TextXAlignment.Left

    -----------------------------------------------------------------------
    -- [ EXTRA / BLACK MARKET ]
    -----------------------------------------------------------------------
    local BlackMarketTitle = Instance.new("TextLabel", ExtraPage)
    BlackMarketTitle.Size = UDim2.new(1, -10, 0, 20)
    BlackMarketTitle.BackgroundTransparency = 1
    BlackMarketTitle.Text = "Black Market"
    BlackMarketTitle.TextColor3 = Config.HighlightText
    BlackMarketTitle.Font = Enum.Font.GothamBold
    BlackMarketTitle.TextSize = 12
    BlackMarketTitle.TextXAlignment = Enum.TextXAlignment.Left

    local function FindBlackMarketNPC()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "black") and string.find(nameLower, "market") then
                    return obj
                end
            end
        end
        return nil
    end

    local function teleportToBlackMarket()
        local npc = FindBlackMarketNPC()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if npc and hrp then
            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                local frontPosition = npcHRP.CFrame * CFrame.new(0, 0, -3)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.lookAt(frontPosition.Position, npcHRP.Position)
            end
        end
    end

    CreateButton(ExtraPage, "Teleport to Black Market", teleportToBlackMarket)

    -----------------------------------------------------------------------
    -- [ EXTRA / MOBILE HUD EDITOR ]
    -----------------------------------------------------------------------
    local ExtraTitle = Instance.new("TextLabel", ExtraPage)
    ExtraTitle.Size = UDim2.new(1, -10, 0, 20)
    ExtraTitle.BackgroundTransparency = 1
    ExtraTitle.Text = "Mobile HUD Editor"
    ExtraTitle.TextColor3 = Config.HighlightText
    ExtraTitle.Font = Enum.Font.GothamBold
    ExtraTitle.TextSize = 12
    ExtraTitle.TextXAlignment = Enum.TextXAlignment.Left

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local SelectedButton = nil
    local HUDEditorActive = false
    local SavedHUDLayout = {}
    local HUDConnections = {}
    local HUDDragCleanup = {}

    if PlayerGui:FindFirstChild("CompactHUDEditor") then
        PlayerGui.CompactHUDEditor:Destroy()
    end

    local EditScreenGui = Instance.new("ScreenGui")
    EditScreenGui.Name = "CompactHUDEditor"
    EditScreenGui.ResetOnSpawn = false
    EditScreenGui.Enabled = false
    EditScreenGui.Parent = PlayerGui

    -- Never reopen the editor automatically after respawn/role changes.
    local HUDStateGuard = PlayerGui.ChildAdded:Connect(function(child)
        if child ~= EditScreenGui and child.Name == "CompactHUDEditor" and not HUDEditorActive then
            pcall(function() child:Destroy() end)
        end
        if not HUDEditorActive then
            EditScreenGui.Enabled = false
        end
    end)

    EditScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if not HUDEditorActive and EditScreenGui.Enabled then
            EditScreenGui.Enabled = false
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        HUDEditorActive = false
        EditScreenGui.Enabled = false
        SelectedButton = nil
        for _, conn in ipairs(HUDConnections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        HUDConnections = {}
        for _, cleanupFunc in ipairs(HUDDragCleanup) do
            if cleanupFunc then pcall(cleanupFunc) end
        end
        HUDDragCleanup = {}
    end)

    local EditFrame = Instance.new("Frame")
    EditFrame.Size = UDim2.new(0, 160, 0, 170)
    EditFrame.Position = UDim2.new(0.02, 0, 0.35, 0)
    EditFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    EditFrame.BorderSizePixel = 0
    EditFrame.Active = true
    EditFrame.Parent = EditScreenGui

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 8)
    FrameCorner.Parent = EditFrame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(0, 255, 200)
    FrameStroke.Thickness = 1.5
    FrameStroke.Parent = EditFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 22)
    TitleLabel.Text = "HUD EDITOR"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    TitleLabel.TextSize = 11
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = EditFrame

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, 0, 0, 15)
    SelectedLabel.Position = UDim2.new(0, 0, 0, 20)
    SelectedLabel.Text = "Selected: None"
    SelectedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    SelectedLabel.TextSize = 9
    SelectedLabel.Font = Enum.Font.SourceSans
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Parent = EditFrame

    local function MakeHUDElementDraggable(gui)
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        local connections = {}

        local function update(input)
            if not dragStart or not startPos then return end

            local delta = input.Position - dragStart
            gui.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        local c1 = gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position

                local endConn
                endConn = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if endConn then endConn:Disconnect() end
                    end
                end)

                table.insert(connections, endConn)
            end
        end)

        local c2 = gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        local c3 = UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)

        table.insert(connections, c1)
        table.insert(connections, c2)
        table.insert(connections, c3)

        return function()
            dragging = false

            for _, conn in ipairs(connections) do
                if conn then
                    conn:Disconnect()
                end
            end
        end
    end

    local function CreateCompactBtn(text, pos, size, bgCol, callback)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = bgCol
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 9

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn

        btn.Parent = EditFrame
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    CreateCompactBtn(
        "Size +",
        UDim2.new(0.06, 0, 0, 40),
        UDim2.new(0.42, 0, 0, 22),
        Color3.fromRGB(30, 30, 30),
        function()
            if SelectedButton then
                SelectedButton.Size = UDim2.new(
                    SelectedButton.Size.X.Scale * 1.1,
                    SelectedButton.Size.X.Offset * 1.1,
                    SelectedButton.Size.Y.Scale * 1.1,
                    SelectedButton.Size.Y.Offset * 1.1
                )
            end
        end
    )

    CreateCompactBtn(
        "Size -",
        UDim2.new(0.52, 0, 0, 40),
        UDim2.new(0.42, 0, 0, 22),
        Color3.fromRGB(30, 30, 30),
        function()
            if SelectedButton then
                SelectedButton.Size = UDim2.new(
                    SelectedButton.Size.X.Scale * 0.9,
                    SelectedButton.Size.X.Offset * 0.9,
                    SelectedButton.Size.Y.Scale * 0.9,
                    SelectedButton.Size.Y.Offset * 0.9
                )
            end
        end
    )

    CreateCompactBtn(
        "Alpha +",
        UDim2.new(0.06, 0, 0, 68),
        UDim2.new(0.42, 0, 0, 22),
        Color3.fromRGB(30, 30, 30),
        function()
            if SelectedButton then
                if SelectedButton:IsA("ImageButton") then
                    SelectedButton.ImageTransparency =
                        math.clamp(SelectedButton.ImageTransparency + 0.1, 0, 1)
                elseif SelectedButton:IsA("TextButton") then
                    SelectedButton.BackgroundTransparency =
                        math.clamp(SelectedButton.BackgroundTransparency + 0.1, 0, 1)
                end
            end
        end
    )

    CreateCompactBtn(
        "Alpha -",
        UDim2.new(0.52, 0, 0, 68),
        UDim2.new(0.42, 0, 0, 22),
        Color3.fromRGB(30, 30, 30),
        function()
            if SelectedButton then
                if SelectedButton:IsA("ImageButton") then
                    SelectedButton.ImageTransparency =
                        math.clamp(SelectedButton.ImageTransparency - 0.1, 0, 1)
                elseif SelectedButton:IsA("TextButton") then
                    SelectedButton.BackgroundTransparency =
                        math.clamp(SelectedButton.BackgroundTransparency - 0.1, 0, 1)
                end
            end
        end
    )

    CreateCompactBtn(
        "SAVE LAYOUT",
        UDim2.new(0.06, 0, 0, 98),
        UDim2.new(0.88, 0, 0, 24),
        Color3.fromRGB(40, 80, 40),
        function()
            SavedHUDLayout = {}

            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui")
                    and gui.Name ~= "CompactHUDEditor"
                    and gui.Name ~= "SynaxHub" then

                    for _, element in ipairs(gui:GetDescendants()) do
                        if element:IsA("ImageButton") or element:IsA("TextButton") then
                            SavedHUDLayout[element] = {
                                Position = element.Position,
                                Size = element.Size,
                                Transparency =
                                    element:IsA("ImageButton")
                                    and element.ImageTransparency
                                    or element.BackgroundTransparency
                            }
                        end
                    end
                end
            end

            TitleLabel.Text = "HUD SAVED"
            task.delay(1.2, function()
                if TitleLabel and TitleLabel.Parent then
                    TitleLabel.Text = "HUD EDITOR"
                end
            end)
        end
    )

    CreateCompactBtn(
        "LOAD LAYOUT",
        UDim2.new(0.06, 0, 0, 128),
        UDim2.new(0.88, 0, 0, 24),
        Color3.fromRGB(40, 40, 80),
        function()
            for element, data in pairs(SavedHUDLayout) do
                if element and element.Parent then
                    element.Position = data.Position
                    element.Size = data.Size

                    if element:IsA("ImageButton") then
                        element.ImageTransparency = data.Transparency
                    elseif element:IsA("TextButton") then
                        element.BackgroundTransparency = data.Transparency
                    end
                end
            end

            TitleLabel.Text = "HUD LOADED"
            task.delay(1.2, function()
                if TitleLabel and TitleLabel.Parent then
                    TitleLabel.Text = "HUD EDITOR"
                end
            end)
        end
    )

    CreateToggle(ExtraPage, "Enable Mobile HUD Editor Overlay", false, function(value)
        HUDEditorActive = value == true
        EditScreenGui.Enabled = HUDEditorActive

        for _, conn in ipairs(HUDConnections) do
            if conn then conn:Disconnect() end
        end
        HUDConnections = {}

        for _, cleanupFunc in ipairs(HUDDragCleanup) do
            if cleanupFunc then cleanupFunc() end
        end
        HUDDragCleanup = {}

        SelectedButton = nil
        SelectedLabel.Text = "Selected: None"

        if HUDEditorActive then
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui")
                    and gui.Name ~= "CompactHUDEditor"
                    and gui.Name ~= "SynaxHub" then

                    for _, element in ipairs(gui:GetDescendants()) do
                        if element:IsA("ImageButton") or element:IsA("TextButton") then
                            local dragCleanup = MakeHUDElementDraggable(element)
                            table.insert(HUDDragCleanup, dragCleanup)

                            local conn = element.MouseButton1Click:Connect(function()
                                SelectedButton = element
                                SelectedLabel.Text =
                                    "Selected: " .. string.sub(element.Name, 1, 14)
                            end)

                            table.insert(HUDConnections, conn)
                        end
                    end
                end
            end
        end
    end)

    local HUDInfo = Instance.new("TextLabel", ExtraPage)
    HUDInfo.Size = UDim2.new(1, -10, 0, 50)
    HUDInfo.BackgroundTransparency = 1
    HUDInfo.Text = "Mobile HUD Editor: tap a game button to select it, then drag " ..
        "it, resize it, change transparency, and save/load the current layout."
    HUDInfo.TextColor3 = Config.TextSecondary
    HUDInfo.Font = Enum.Font.Gotham
    HUDInfo.TextSize = 10
    HUDInfo.TextWrapped = true
    HUDInfo.TextXAlignment = Enum.TextXAlignment.Left

    -----------------------------------------------------------------------
    -- [ COMBAT TAB ]
    -- Intentionally empty in v1.0.0.
    -----------------------------------------------------------------------

    -----------------------------------------------------------------------
    -- [ INFORMATION TAB ]
    -----------------------------------------------------------------------
    local YTBtn = Instance.new("TextButton", InfoPage)
    YTBtn.Size = UDim2.new(1, -10, 0, 32)
    YTBtn.BackgroundColor3 = Config.ContainerColor
    YTBtn.BackgroundTransparency = 0.2
    YTBtn.Text = Config.YouTubeName
    YTBtn.TextColor3 = Config.TextPrimary
    YTBtn.Font = Enum.Font.GothamBold
    YTBtn.TextSize = 11
    Instance.new("UICorner", YTBtn).CornerRadius = UDim.new(0, 6)

    YTBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(Config.YouTube) end
        YTBtn.Text = "COPIED!"
        task.wait(1.5)
        YTBtn.Text = Config.YouTubeName
    end)

    local DCBtn = Instance.new("TextButton", InfoPage)
    DCBtn.Size = UDim2.new(1, -10, 0, 32)
    DCBtn.BackgroundColor3 = Config.ContainerColor
    DCBtn.BackgroundTransparency = 0.2
    DCBtn.Text = "Discord Server"
    DCBtn.TextColor3 = Config.TextPrimary
    DCBtn.Font = Enum.Font.GothamBold
    DCBtn.TextSize = 11
    Instance.new("UICorner", DCBtn).CornerRadius = UDim.new(0, 6)

    DCBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(Config.Discord) end
        DCBtn.Text = "LINK COPIED!"
        task.wait(1.5)
        DCBtn.Text = "Discord Server"
    end)

    local UpdateInfoTitle = Instance.new("TextLabel", InfoPage)
    UpdateInfoTitle.Size = UDim2.new(1, -10, 0, 18)
    UpdateInfoTitle.BackgroundTransparency = 1
    UpdateInfoTitle.Text = "Synax Hub Update • v1.0.0"
    UpdateInfoTitle.TextColor3 = Config.HighlightText
    UpdateInfoTitle.Font = Enum.Font.GothamBold
    UpdateInfoTitle.TextSize = 12
    UpdateInfoTitle.TextXAlignment = Enum.TextXAlignment.Left

    local UpdateInfoDesc = Instance.new("TextLabel", InfoPage)
    UpdateInfoDesc.Size = UDim2.new(1, -10, 0, 50)
    UpdateInfoDesc.BackgroundTransparency = 1
    UpdateInfoDesc.Text = "Version 1.0.0 includes global language support, the integrated Ultimate ESP engine, Farm Earning tracking, and a Combat page reserved for a future update."
    UpdateInfoDesc.TextColor3 = Config.TextSecondary
    UpdateInfoDesc.Font = Enum.Font.Gotham
    UpdateInfoDesc.TextSize = 10
    UpdateInfoDesc.TextWrapped = true
    UpdateInfoDesc.TextXAlignment = Enum.TextXAlignment.Left

    local WarningTitle = Instance.new("TextLabel", InfoPage)
    WarningTitle.Size = UDim2.new(1, -10, 0, 18)
    WarningTitle.BackgroundTransparency = 1
    WarningTitle.Text = "Important Notice"
    WarningTitle.TextColor3 = Config.WarningYellow
    WarningTitle.Font = Enum.Font.GothamBold
    WarningTitle.TextSize = 12
    WarningTitle.TextXAlignment = Enum.TextXAlignment.Left

    local WarningDesc = Instance.new("TextLabel", InfoPage)
    WarningDesc.Size = UDim2.new(1, -10, 0, 40)
    WarningDesc.BackgroundTransparency = 1
    WarningDesc.Text = "Please choose empty servers when farming. Doing it in crowded servers may put your account at risk."
    WarningDesc.TextColor3 = Config.TextSecondary
    WarningDesc.Font = Enum.Font.Gotham
    WarningDesc.TextSize = 10
    WarningDesc.TextWrapped = true
    WarningDesc.TextXAlignment = Enum.TextXAlignment.Left

    local InfoTitle = Instance.new("TextLabel", InfoPage)
    InfoTitle.Size = UDim2.new(1, -10, 0, 18)
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Text = "Project Information"
    InfoTitle.TextColor3 = Config.HighlightText
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.TextSize = 12
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left

    local InfoDesc = Instance.new("TextLabel", InfoPage)
    InfoDesc.Size = UDim2.new(1, -10, 0, 30)
    InfoDesc.BackgroundTransparency = 1
    InfoDesc.Text = "C11 Synax v1.0.0 for PrisonRP. Global language support, Ultimate ESP, and Farm Earning tracking are included."
    InfoDesc.TextColor3 = Config.TextSecondary
    InfoDesc.Font = Enum.Font.Gotham
    InfoDesc.TextSize = 10
    InfoDesc.TextWrapped = true
    InfoDesc.TextXAlignment = Enum.TextXAlignment.Left

    local DevTitle = Instance.new("TextLabel", InfoPage)
    DevTitle.Size = UDim2.new(1, -10, 0, 18)
    DevTitle.BackgroundTransparency = 1
    DevTitle.Text = "Development team"
    DevTitle.TextColor3 = Config.CloseRed
    DevTitle.Font = Enum.Font.GothamBold
    DevTitle.TextSize = 12
    DevTitle.TextXAlignment = Enum.TextXAlignment.Left

    local DevOwner = Instance.new("TextLabel", InfoPage)
    DevOwner.Size = UDim2.new(1, -10, 0, 15)
    DevOwner.BackgroundTransparency = 1
    DevOwner.Text = "• Owner/Developer: C11\n• PrisonRP Responsible: Hawk\n• PrisonRP Senior Official: Eagle\n• Version: 1.0.0"
    DevOwner.TextColor3 = Config.TextPrimary
    DevOwner.Font = Enum.Font.Gotham
    DevOwner.TextSize = 10
    DevOwner.TextXAlignment = Enum.TextXAlignment.Left

    -----------------------------------------------------------------------
    -- [ SETTINGS TAB ]
    -----------------------------------------------------------------------
    local SettingsTitle = Instance.new("TextLabel", SettingsPage)
    SettingsTitle.Size = UDim2.new(1, -10, 0, 20)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "Exploit & Utility Settings"
    SettingsTitle.TextColor3 = Config.HighlightText
    SettingsTitle.Font = Enum.Font.GothamBold
    SettingsTitle.TextSize = 12
    SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left

    local LanguageTitle = Instance.new("TextLabel", SettingsPage)
    LanguageTitle.Size = UDim2.new(1, -10, 0, 20)
    LanguageTitle.BackgroundTransparency = 1
    LanguageTitle.Text = "GLOBAL LANGUAGE • " .. Translate("Beta")
    LanguageTitle.TextColor3 = Config.HighlightText
    LanguageTitle.Font = Enum.Font.GothamBold
    LanguageTitle.TextSize = 12
    LanguageTitle.TextXAlignment = Enum.TextXAlignment.Left

    local LanguageCard = CreateCard(SettingsPage, "Current Language", LanguageState.Current)

    local LanguageInfo = Instance.new("TextLabel", SettingsPage)
    LanguageInfo.Size = UDim2.new(1, -10, 0, 32)
    LanguageInfo.BackgroundTransparency = 1
    LanguageInfo.Text = "16 languages available. Select one from the dropdown below."
    LanguageInfo.TextColor3 = Config.TextSecondary
    LanguageInfo.Font = Enum.Font.Gotham
    LanguageInfo.TextSize = 9
    LanguageInfo.TextWrapped = true
    LanguageInfo.TextXAlignment = Enum.TextXAlignment.Left

    local LanguageSelector = Instance.new("TextButton", SettingsPage)
    LanguageSelector.Size = UDim2.new(1, -10, 0, 36)
    LanguageSelector.BackgroundColor3 = Config.ContainerColor
    LanguageSelector.BackgroundTransparency = 0.2
    LanguageSelector.TextColor3 = Config.TextPrimary
    LanguageSelector.Font = Enum.Font.GothamBold
    LanguageSelector.TextSize = 11
    LanguageSelector.TextXAlignment = Enum.TextXAlignment.Left
    LanguageSelector.AutoButtonColor = false
    Instance.new("UICorner", LanguageSelector).CornerRadius = UDim.new(0, 6)

    local Arrow = Instance.new("TextLabel", LanguageSelector)
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -35, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Config.TextSecondary
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12

    local LanguageDropdown = Instance.new("Frame", SettingsPage)
    LanguageDropdown.Size = UDim2.new(1, -10, 0, 0)
    LanguageDropdown.BackgroundColor3 = Config.ContainerColor
    LanguageDropdown.BackgroundTransparency = 0.08
    LanguageDropdown.Visible = false
    LanguageDropdown.ClipsDescendants = true
    LanguageDropdown.LayoutOrder = 999
    Instance.new("UICorner", LanguageDropdown).CornerRadius = UDim.new(0, 6)

    local LanguageScroll = Instance.new("ScrollingFrame", LanguageDropdown)
    LanguageScroll.Size = UDim2.new(1, 0, 1, 0)
    LanguageScroll.BackgroundTransparency = 1
    LanguageScroll.BorderSizePixel = 0
    LanguageScroll.ScrollBarThickness = 3
    LanguageScroll.ScrollBarImageColor3 = Config.TextSecondary
    LanguageScroll.CanvasSize = UDim2.new(0, 0, 0, #SupportedLanguages * 34)
    LanguageScroll.AutomaticCanvasSize = Enum.AutomaticSize.None

    local LanguageList = Instance.new("UIListLayout", LanguageScroll)
    LanguageList.SortOrder = Enum.SortOrder.LayoutOrder
    LanguageList.Padding = UDim.new(0, 3)
    LanguageList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local LanguageButtons = {}
    local DropdownOpen = false
    local function UpdateLanguageSelector()
        local current = SupportedLanguages[1]
        for _, item in ipairs(SupportedLanguages) do
            if item.Name == LanguageState.Current then current = item break end
        end
        LanguageSelector.Text = "  " .. current.Flag .. "  " .. current.Name
        Arrow.Text = DropdownOpen and "▲" or "▼"
        LanguageCard.Text = current.Name
    end

    local function ApplyLanguage()
        -- First, remember every static text element so feature names and manually-created UI labels are included.
        for _, obj in ipairs(MainGui:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and not obj:GetAttribute("SynaxOriginalText") then
                local text = obj.Text
                if text and text ~= "" and not string.find(text, "^Session: ") and not string.find(text, "^Job ID:") then
                    obj:SetAttribute("SynaxOriginalText", text)
                end
            end
        end

        for _, obj in ipairs(MainGui:GetDescendants()) do
            if obj:GetAttribute("SynaxToggleIndicator") then
                obj.Text = Translate(obj:GetAttribute("SynaxToggleState") and "ON" or "OFF")
            elseif obj:GetAttribute("SynaxSliderTitle") then
                local sliderTitle = obj:GetAttribute("SynaxSliderTitle")
                local sliderValue = obj:GetAttribute("SynaxSliderValue")
                local sliderSuffix = obj:GetAttribute("SynaxSliderSuffix") or ""
                obj.Text = Translate(sliderTitle) .. ": " .. tostring(sliderValue) .. sliderSuffix
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local original = obj:GetAttribute("SynaxOriginalText")
                if original then
                    if obj == LanguageSelector then
                        -- handled separately
                    elseif obj:IsA("TextButton") and string.sub(original, 1, 2) == "  " then
                        obj.Text = "  " .. Translate(string.sub(original, 3))
                    else
                        obj.Text = Translate(original)
                    end
                end
            end
        end

        SettingsTitle.Text = Translate("Settings") .. " • " .. Translate("Beta")
        LanguageTitle.Text = "GLOBAL LANGUAGE • " .. Translate("Beta")
        UpdateLanguageSelector()
    end

    local function SetLanguage(index)
        LanguageState.Current = SupportedLanguages[index].Name
        ApplyLanguage()
        DropdownOpen = false
        LanguageDropdown.Visible = false
        LanguageDropdown.Size = UDim2.new(1, -10, 0, 0)
        UpdateLanguageSelector()
    end

    for i, item in ipairs(SupportedLanguages) do
        local btn = Instance.new("TextButton", LanguageScroll)
        btn.Size = UDim2.new(1, -8, 0, 31)
        btn.BackgroundColor3 = Config.ContainerColor
        btn.BackgroundTransparency = 0.15
        btn.Text = "  " .. item.Flag .. "  " .. item.Name
        btn.TextColor3 = Config.TextPrimary
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = i
        btn.AutoButtonColor = false
        btn:SetAttribute("SynaxLanguageButton", true)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        LanguageButtons[i] = btn
        btn.MouseButton1Click:Connect(function() SetLanguage(i) end)
    end

    LanguageSelector.MouseButton1Click:Connect(function()
        DropdownOpen = not DropdownOpen
        LanguageDropdown.Visible = DropdownOpen
        LanguageDropdown.Size = UDim2.new(1, -10, 0, DropdownOpen and 174 or 0)
        Arrow.Text = DropdownOpen and "▲" or "▼"
    end)

    ApplyLanguage()


    local AntiAfkConn = nil

    CreateToggle(SettingsPage, "Anti AFK (Prevent Kick)", false, function(state)
        if state then
            if not AntiAfkConn then
                AntiAfkConn = LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end)
                end)
            end
        else
            if AntiAfkConn then
                AntiAfkConn:Disconnect()
                AntiAfkConn = nil
            end
        end
    end)

    CreateToggle(SettingsPage, "Noclip (Walk Through Walls)", false, function(state)
        HubSettings.Noclip = state
        if UtilityState.NoclipConnection then
            UtilityState.NoclipConnection:Disconnect()
            UtilityState.NoclipConnection = nil
        end
        if state then
            UtilityState.NoclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)

    CreateToggle(SettingsPage, "Infinite Jump", false, function(state)
        HubSettings.InfiniteJump = state
    end)

    CreateToggle(SettingsPage, "FullBright (Remove Darkness)", false, function(state)
        HubSettings.FullBright = state
        local Lighting = game:GetService("Lighting")
        if state then
            if not UtilityState.SavedLighting then
                UtilityState.SavedLighting = {
                    Brightness = Lighting.Brightness,
                    ClockTime = Lighting.ClockTime,
                    GlobalShadows = Lighting.GlobalShadows,
                    FogEnd = Lighting.FogEnd,
                    ExposureCompensation = Lighting.ExposureCompensation
                }
            end
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.ExposureCompensation = 0.5
            UtilityState.FullBrightActive = true
        elseif UtilityState.SavedLighting then
            local saved = UtilityState.SavedLighting
            Lighting.Brightness = saved.Brightness
            Lighting.ClockTime = saved.ClockTime
            Lighting.GlobalShadows = saved.GlobalShadows
            Lighting.FogEnd = saved.FogEnd
            Lighting.ExposureCompensation = saved.ExposureCompensation
            UtilityState.SavedLighting = nil
            UtilityState.FullBrightActive = false
        end
    end)

    local ScaleContainer = Instance.new("Frame", SettingsPage)
    ScaleContainer.Size = UDim2.new(1, -10, 0, 36)
    ScaleContainer.BackgroundColor3 = Config.ContainerColor
    ScaleContainer.BackgroundTransparency = 0.2
    Instance.new("UICorner", ScaleContainer).CornerRadius = UDim.new(0, 6)

    local ScaleLbl = Instance.new("TextLabel", ScaleContainer)
    ScaleLbl.Size = UDim2.new(0.5, 0, 1, 0)
    ScaleLbl.Position = UDim2.new(0, 10, 0, 0)
    ScaleLbl.BackgroundTransparency = 1
    ScaleLbl.Text = "UI Scale Size"
    ScaleLbl.TextColor3 = Config.TextPrimary
    ScaleLbl.Font = Enum.Font.GothamMedium
    ScaleLbl.TextSize = 11
    ScaleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local scales = {
        {Name = "Small", Size = UDim2.new(0, 420, 0, 280)},
        {Name = "Normal", Size = UDim2.new(0, 520, 0, 340)},
        {Name = "Large", Size = UDim2.new(0, 620, 0, 400)}
    }

    local sxOffset = -105
    for _, sc in ipairs(scales) do
        local sBtn = Instance.new("TextButton", ScaleContainer)
        sBtn.Size = UDim2.new(0, 32, 0, 20)
        sBtn.Position = UDim2.new(1, sxOffset, 0.5, -10)
        sBtn.BackgroundColor3 = Config.SidebarColor
        sBtn.Text = sc.Name:sub(1,1)
        sBtn.TextColor3 = Config.Accent
        sBtn.Font = Enum.Font.GothamBold
        sBtn.TextSize = 9
        Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 4)
        sBtn.MouseButton1Click:Connect(function()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = sc.Size}):Play()
        end)
        sxOffset += 36
    end
    task.defer(function()
        task.wait(0.5)
        scanStaff()
        updateStaffList()
    end)

    UserInputService.JumpRequest:Connect(function()
        if HubSettings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    -----------------------------------------------------------------------
    -- [ UI LAYOUT FIX ]
    -- Keep every page deterministic on mobile/PC. The old layout relied on
    -- several siblings sharing LayoutOrder = 0, which can reorder controls
    -- unexpectedly and create the large blank/incorrect gaps seen on mobile.
    -- This section only normalizes the visual page layout; feature logic,
    -- access checks, staff system and API configuration are untouched.
    -----------------------------------------------------------------------
    local AllPages = {
        DashboardPage,
        InfoPage,
        FarmPage,
        AutoEatPage,
        CombatPage,
        EspPage,
        StaffPage,
        ExtraPage,
        SettingsPage,
    }

    PagesContainer.ClipsDescendants = true

    local function NormalizePageLayout(Page)
        if not Page or not Page.Parent then return end

        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Position = UDim2.new(0, 0, 0, 0)
        Page.ClipsDescendants = true
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local Layout = Page:FindFirstChildOfClass("UIListLayout")
        if not Layout then
            Layout = Instance.new("UIListLayout")
            Layout.Parent = Page
        end

        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.FillDirection = Enum.FillDirection.Vertical
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Top
        Layout.Padding = UDim.new(0, 6)

        -- Assign a unique order using the existing creation order.
        -- This preserves the intended UI sequence without changing any
        -- individual feature control.
        local order = 0
        for _, child in ipairs(Page:GetChildren()) do
            if not child:IsA("UIListLayout")
                and not child:IsA("UIPadding")
                and not child:IsA("UIGridLayout")
                and not child:IsA("UITableLayout")
                and not child:IsA("UIPageLayout") then
                order += 1
                child.LayoutOrder = order
            end
        end

        local function updateCanvas()
            if Page.Parent and Layout.Parent == Page then
                Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 12)
            end
        end

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)
    end

    for _, Page in ipairs(AllPages) do
        NormalizePageLayout(Page)
    end

    MakeDraggable(MainFrame)
    MakeDraggable(TopPill)

    MainGui.Enabled = true
    MainFrame.Visible = true
    MainFrame.ZIndex = 10
    Sidebar.Visible = true
    TabContainer.Visible = true
    PagesContainer.Visible = true
end

local __synaxOk, __synaxErr = xpcall(ExecuteScript, function(err)
    return debug.traceback(tostring(err), 2)
end)
if not __synaxOk then
    warn("[SynaxHub] ExecuteScript failed:\n" .. tostring(__synaxErr))
end
