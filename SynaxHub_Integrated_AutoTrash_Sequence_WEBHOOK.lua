local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================================
-- SYNAX HUB WEBHOOK LOGGER
-- Keep your webhook URL private. Paste it locally in WEBHOOK_URL.
-- Sends only basic Roblox/game session information; never cookies, tokens or IPs.
-- ============================================================================
local WEBHOOK_URL = "PASTE_YOUR_DISCORD_WEBHOOK_URL_HERE"
local WEBHOOK_ENABLED = true

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
end

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

local function sendExecutionLog()
    if not WEBHOOK_ENABLED then return end
    if WEBHOOK_URL == "" or WEBHOOK_URL == "PASTE_YOUR_DISCORD_WEBHOOK_URL_HERE" then return end

    local HttpService = game:GetService("HttpService")
    local req = getRequestFunction()
    if not req then return end

    local gameName = getGameName()
    local now = os.time()
    local avatarUrl = string.format(
        "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=180&height=180&format=png",
        LocalPlayer.UserId
    )

    local payload = {
        username = "Synax Hub Logger",
        avatar_url = avatarUrl,
        embeds = {{
            title = "🚀 Synax Hub • Script Executed",
            description = "A Synax Hub session has been started.",
            color = 5793266,
            thumbnail = {
                url = avatarUrl
            },
            author = {
                name = tostring(LocalPlayer.DisplayName) .. " (" .. tostring(LocalPlayer.Name) .. ")",
                icon_url = avatarUrl,
                url = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"
            },
            fields = {
                {name = "👤 Username", value = "`" .. tostring(LocalPlayer.Name) .. "`", inline = true},
                {name = "🪪 User ID", value = "`" .. tostring(LocalPlayer.UserId) .. "`", inline = true},
                {name = "🎮 Game", value = "`" .. gameName:gsub("`", "'") .. "`", inline = false},
                {name = "🆔 Place ID", value = "`" .. tostring(game.PlaceId) .. "`", inline = true},
                {name = "🖥️ Server Job ID", value = "`" .. tostring(game.JobId ~= "" and game.JobId or "Studio/Private") .. "`", inline = false},
                {name = "🕐 Time", value = "<t:" .. tostring(now) .. ":F>\n<t:" .. tostring(now) .. ":R>", inline = true},
            },
            footer = {
                text = "Synax Hub • Execution Logger"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local body = HttpService:JSONEncode(payload)

    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)
end

task.spawn(function()
    task.wait(1)
    sendExecutionLog()
end)


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
    Discord = "https://discord.gg/synaxhub",
    YouTube = "https://www.youtube.com/@llevis-o2u",
    YouTubeName = "Synax Hub YouTube"
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

            humanoid.WalkSpeed = 0
            pcall(function() humanoid.JumpPower = 0 end)
            pcall(function() humanoid.JumpHeight = 0 end)

            local rod = getRod()

            if not rod then
                task.wait(1)
                return
            end

            if rod.Parent ~= character then
                humanoid:EquipTool(rod)
                task.wait(0.8)
            end

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
    Sidebar.Size = UDim2.new(0, 140, 1, -48)
    Sidebar.Position = UDim2.new(0, 10, 0, 38)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BackgroundTransparency = 0.25
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
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
        TabBtn.Text = "  " .. name
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
        end)

        return Page
    end

    local function CreateButton(parent, text, callback)
        local Btn = Instance.new("TextButton", parent)
        Btn.Size = UDim2.new(1, -10, 0, 32)
        Btn.BackgroundColor3 = Config.ContainerColor
        Btn.BackgroundTransparency = 0.2
        Btn.Text = text
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
        Label.Text = text
        Label.TextColor3 = Config.TextPrimary
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Indicator = Instance.new("TextButton", ToggleFrame)
        Indicator.Size = UDim2.new(0, 36, 0, 18)
        Indicator.Position = UDim2.new(1, -44, 0.5, -9)
        Indicator.BackgroundColor3 = defaultState and Color3.fromRGB(60, 180, 100) or Color3.fromRGB(35, 40, 52)
        Indicator.BorderSizePixel = 0
        Indicator.Text = defaultState and "ON" or "OFF"
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
                Indicator.Text = "ON"
                Indicator.TextColor3 = Config.Accent
            else
                Indicator.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
                Indicator.Text = "OFF"
                Indicator.TextColor3 = Config.TextSecondary
            end
            if callback then callback(state) end
        end)

        return ToggleFrame
    end

    local DashboardPage = CreateTab("Dashboard", 1)
    local InfoPage      = CreateTab("Information", 2)
    local FarmPage      = CreateTab("Farm", 3)
    local AutoEatPage   = CreateTab("Auto Eat", 4)
    local CombatPage    = CreateTab("Combat", 5)
    local EspPage       = CreateTab("ESP", 6)
    local ExtraPage     = CreateTab("Extra", 7)
    local SettingsPage  = CreateTab("Settings", 8)

    -----------------------------------------------------------------------
    -- [ DASHBOARD ]
    -----------------------------------------------------------------------
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
        TitleLbl.Text = titleText
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

    local FpsLabel    = CreateCard(DashboardPage, "FPS Rate", "calculating...")
    local PingLabel   = CreateCard(DashboardPage, "MS (Ping)", "calculating...")
    local PlayerLabel = CreateCard(DashboardPage, "Server Players", "0 / 0")
    local FriendLabel = CreateCard(DashboardPage, "Active Friends", "0")

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
        end
    end)

    -----------------------------------------------------------------------
    -- [ FARM TAB ]
    -- Functional farm systems integrated from the supplied farm scripts.
    -----------------------------------------------------------------------
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
    end)

    CreateToggle(FarmPage, "Fish Farm", false, function(state)
        FarmState.AutoFish = state

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
        if state then
            AutoMine.Start()
        else
            AutoMine.Stop()
        end
    end)

    CreateToggle(FarmPage, "Auto Trash (EXP)", false, function(state)
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
            label.Text = title .. ": " .. tostring(value) .. suffix
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
    -----------------------------------------------------------------------
    CreateToggle(EspPage, "Glow ESP (All White)", false, function(state)
        HubSettings.GlowAllWhite = state
    end)

    local ColorContainer = Instance.new("Frame", EspPage)
    ColorContainer.Size = UDim2.new(1, -10, 0, 36)
    ColorContainer.BackgroundColor3 = Config.ContainerColor
    ColorContainer.BackgroundTransparency = 0.2
    Instance.new("UICorner", ColorContainer).CornerRadius = UDim.new(0, 6)

    local ColorLbl = Instance.new("TextLabel", ColorContainer)
    ColorLbl.Size = UDim2.new(0.5, 0, 1, 0)
    ColorLbl.Position = UDim2.new(0, 10, 0, 0)
    ColorLbl.BackgroundTransparency = 1
    ColorLbl.Text = "Glow Custom Color"
    ColorLbl.TextColor3 = Config.TextPrimary
    ColorLbl.Font = Enum.Font.GothamMedium
    ColorLbl.TextSize = 11
    ColorLbl.TextXAlignment = Enum.TextXAlignment.Left

    local colors = {
        {Name = "Red", Color = Color3.fromRGB(255, 50, 50)},
        {Name = "Blue", Color = Color3.fromRGB(50, 150, 255)},
        {Name = "Green", Color = Color3.fromRGB(50, 255, 100)},
        {Name = "White", Color = Color3.fromRGB(255, 255, 255)}
    }

    local xOffset = -135
    for _, col in ipairs(colors) do
        local btn = Instance.new("TextButton", ColorContainer)
        btn.Size = UDim2.new(0, 28, 0, 20)
        btn.Position = UDim2.new(1, xOffset, 0.5, -10)
        btn.BackgroundColor3 = col.Color
        btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            HubSettings.GlowColor = col.Color
        end)
        xOffset += 33
    end

    CreateToggle(EspPage, "2D Box ESP", false, function(state)
        HubSettings.BoxEsp = state
    end)

    CreateToggle(EspPage, "Health Bar ESP", false, function(state)
        HubSettings.HealthBar = state
    end)

    CreateToggle(EspPage, "Target ESP (Top Lines)", false, function(state)
        HubSettings.TargetLines = state
    end)

    CreateToggle(EspPage, "Skeleton ESP", false, function(state)
        HubSettings.SkeletonEsp = state
    end)

    CreateToggle(EspPage, "Name & Distance ESP", false, function(state)
        HubSettings.NameDistanceEsp = state
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
        HUDEditorActive = value
        EditScreenGui.Enabled = value

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
    -----------------------------------------------------------------------
    CreateButton(CombatPage, "AIMBOT SCRIPT [MOBILE]", function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Mobile-34677"))()
    end)

    local CombatNotice = Instance.new("TextLabel", CombatPage)
    CombatNotice.Size = UDim2.new(1, -10, 0, 45)
    CombatNotice.BackgroundTransparency = 1
    CombatNotice.Text = "New features will be added in a minor update, thank you for your patience."
    CombatNotice.TextColor3 = Config.WarningYellow
    CombatNotice.Font = Enum.Font.GothamMedium
    CombatNotice.TextSize = 10
    CombatNotice.TextWrapped = true
    CombatNotice.TextXAlignment = Enum.TextXAlignment.Left

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
    UpdateInfoTitle.Text = "Synax Hub New Update (Beta V1)"
    UpdateInfoTitle.TextColor3 = Config.HighlightText
    UpdateInfoTitle.Font = Enum.Font.GothamBold
    UpdateInfoTitle.TextSize = 12
    UpdateInfoTitle.TextXAlignment = Enum.TextXAlignment.Left

    local UpdateInfoDesc = Instance.new("TextLabel", InfoPage)
    UpdateInfoDesc.Size = UDim2.new(1, -10, 0, 50)
    UpdateInfoDesc.BackgroundTransparency = 1
    UpdateInfoDesc.Text = "First of all, the script is still in beta; please keep this in mind. The main reason for this is to provide you with a better experience. This script brings many innovations to you, so stay patient through the challenge."
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
    InfoDesc.Text = "This script was made for PrisonRP on Roblox. Running it in another game may cause issues."
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
    DevOwner.Text = "• Owner: C11"
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
    end)

    CreateToggle(SettingsPage, "Infinite Jump", false, function(state)
        HubSettings.InfiniteJump = state
    end)

    CreateToggle(SettingsPage, "FullBright (Remove Darkness)", false, function(state)
        HubSettings.FullBright = state
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
    -----------------------------------------------------------------------
    -- [ GLOBAL ESP & UTILITY RENDER LOOP ]
    -----------------------------------------------------------------------
    RunService.RenderStepped:Connect(function()
        if not MainGui.Parent then return end

        if HubSettings.Noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        if HubSettings.FullBright then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local char = p.Character
                local root = char.HumanoidRootPart
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                -- Glow ESP
                local glow = char:FindFirstChild("SynaxHubGlow")
                if HubSettings.GlowAllWhite then
                    if not glow then
                        glow = Instance.new("Highlight")
                        glow.Name = "SynaxHubGlow"
                        glow.Parent = char
                    end
                    glow.FillColor = HubSettings.GlowColor
                    glow.FillTransparency = 0.4
                    glow.OutlineColor = Color3.fromRGB(255, 255, 255)
                    glow.OutlineTransparency = 0
                else
                    if glow then glow:Destroy() end
                end

                -- Drawing Tablosu
                if not ActiveDrawings[p] then
                    ActiveDrawings[p] = {
                        Box = Drawing.new("Square"),
                        Bones = {
                            Drawing.new("Line"),
                            Drawing.new("Line"),
                            Drawing.new("Line"),
                            Drawing.new("Line"),
                            Drawing.new("Line"),
                            Drawing.new("Line")
                        }
                    }
                    ActiveDrawings[p].Box.Visible = false
                    ActiveDrawings[p].Box.Thickness = 1.5
                    ActiveDrawings[p].Box.Color = Color3.fromRGB(255, 255, 255)
                    ActiveDrawings[p].Box.Filled = false

                    for _, bone in ipairs(ActiveDrawings[p].Bones) do
                        bone.Visible = false
                        bone.Thickness = 1.5
                        bone.Color = Color3.fromRGB(255, 255, 255)
                    end
                end

                local drawData = ActiveDrawings[p]
                
                -- Box ESP
                if HubSettings.BoxEsp then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        if onScreen or rootOnScreen then
                            local height = math.abs(headPos.Y - rootPos.Y)
                            local width = height / 2
                            drawData.Box.Size = Vector2.new(width, height)
                            drawData.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                            drawData.Box.Visible = true
                        else
                            drawData.Box.Visible = false
                        end
                    else
                        drawData.Box.Visible = false
                    end
                else
                    drawData.Box.Visible = false
                end

                -- Skeleton ESP
                if HubSettings.SkeletonEsp and humanoid and humanoid.Health > 0 then
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    local head = char:FindFirstChild("Head")
                    if head and torso then
                        local hPos, hVis = Camera:WorldToViewportPoint(head.Position)
                        local tPos, tVis = Camera:WorldToViewportPoint(torso.Position)

                        if hVis or tVis then
                            drawData.Bones[1].From = Vector2.new(hPos.X, hPos.Y)
                            drawData.Bones[1].To = Vector2.new(tPos.X, tPos.Y)
                            drawData.Bones[1].Visible = true
                        else
                            drawData.Bones[1].Visible = false
                        end
                    else
                        drawData.Bones[1].Visible = false
                    end
                else
                    for _, bone in ipairs(drawData.Bones) do bone.Visible = false end
                end

                -- Health Bar
                local uiHolder = char:FindFirstChild("SynaxHubHealthUI")
                if HubSettings.HealthBar and humanoid then
                    if not uiHolder then
                        uiHolder = Instance.new("BillboardGui")
                        uiHolder.Name = "SynaxHubHealthUI"
                        uiHolder.Size = UDim2.new(0, 100, 0, 40)
                        uiHolder.StudsOffset = Vector3.new(0, 3.2, 0)
                        uiHolder.AlwaysOnTop = true
                        uiHolder.Parent = char

                        local bgBar = Instance.new("Frame", uiHolder)
                        bgBar.Name = "HealthBg"
                        bgBar.Size = UDim2.new(0, 60, 0, 6)
                        bgBar.Position = UDim2.new(0.5, -30, 0, 0)
                        bgBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        bgBar.BorderSizePixel = 0
                        Instance.new("UICorner", bgBar).CornerRadius = UDim.new(1, 0)

                        local fgBar = Instance.new("Frame", bgBar)
                        fgBar.Name = "HealthFg"
                        fgBar.Size = UDim2.new(1, 0, 1, 0)
                        fgBar.BackgroundColor3 = Color3.fromRGB(60, 220, 80)
                        fgBar.BorderSizePixel = 0
                        Instance.new("UICorner", fgBar).CornerRadius = UDim.new(1, 0)
                    end

                    local hb = uiHolder:FindFirstChild("HealthBg")
                    if hb then
                        hb.Visible = true
                        local fg = hb:FindFirstChild("HealthFg")
                        if fg and humanoid.MaxHealth > 0 then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            fg.Size = UDim2.new(healthPercent, 0, 1, 0)
                            fg.BackgroundColor3 = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0)
                        end
                    end
                else
                    if uiHolder then uiHolder:Destroy() end
                end

                -- Target Lines
                local linePart = char:FindFirstChild("SynaxHubTargetLine")
                if HubSettings.TargetLines then
                    if not linePart then
                        linePart = Instance.new("Part")
                        linePart.Name = "SynaxHubTargetLine"
                        linePart.Size = Vector3.new(0.1, 50, 0.1)
                        linePart.Anchored = true
                        linePart.CanCollide = false
                        linePart.Transparency = 0.4
                        linePart.BrickColor = BrickColor.new("Cyan")
                        linePart.Parent = char
                    end
                    linePart.CFrame = CFrame.new(root.Position + Vector3.new(0, 25, 0))
                else
                    if linePart then linePart:Destroy() end
                end
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if HubSettings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    MakeDraggable(MainFrame)
    MakeDraggable(TopPill)
end

ExecuteScript()
