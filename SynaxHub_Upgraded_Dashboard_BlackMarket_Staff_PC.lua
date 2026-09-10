local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local Stats = cloneref(game:GetService("Stats"))
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))

local LocalPlayer = Players.LocalPlayer
local UserInputService = cloneref(game:GetService("UserInputService"))

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)

    if ok then
        WindUI = result
    else
        if RunService:IsStudio() or not writefile then
            WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

local ThemeName = "Dark"

local Window = WindUI:CreateWindow({
    Title = "Bytee Hub",
    Author = "by Bytecode & Levis",
    Icon = "swords",
    Theme = ThemeName,
    ToggleKey = Enum.KeyCode.F,

    Size = UDim2.fromOffset(900, 600),
    Transparent = true,

    OpenButton = {
        Title = "Open Bytee Hub UI",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.9,
        Size = UDim2.fromOffset(160, 38),

        Color = ColorSequence.new(
            Color3.fromHex("#83889E"),
            Color3.fromHex("#5A5F73")
        ),
    },
})

Window:Tag({
    Title = "Premium V1",
    Color = "ElementBackground",
})

local ToolEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tool"):WaitForChild("Event")
local FOOD_TOOLS = { CerealBar = true, FoodPlate = true, Popcorn = true }
local DRINK_TOOLS = { WaterCup = true, Soda = true, BloxyCola = true }
local HubSettings = { AntiAfk = false }

local AutoHungerState = { Enabled = false, EatBelow = 50, DrinkBelow = 50 }
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
            if t:IsA("Tool") and names[t.Name] then return t end
        end
    end
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and names[t.Name] then return t end
    end
    return nil
end

local function stowLeftover(names)
    local char, humanoid = getCharacterHunger()
    if not humanoid then return end
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and names[equipped.Name] then
        pcall(function() humanoid:UnequipTools() end)
    end
end

local function collectVendingMachines()
    local list = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("RemoteEvent") and inst.Parent and inst.Parent:IsA("Configuration") then
            local text = inst.Parent:GetAttribute("Text") or ""
            if text:find("Buy Food") or text:find("Buy Drink") then
                local machine = inst:FindFirstAncestorOfClass("Model")
                if machine then
                    table.insert(list, { event = inst, kind = text:find("Food") and "Food" or "Drink", model = machine, price = tonumber(text:match("%$(%d+)")) or 3 })
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
        if m.kind == kind and m.event.Parent then
            local ok, pos = pcall(function() return m.model:GetPivot().Position end)
            if ok and pos then
                local d = root and (pos - root.Position).Magnitude or 0
                if d < bestDist then best, bestDist = m, d end
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
        if not stat or stat >= threshold then break end
        local tool = findAutoEatTool(toolNames)
        if not tool then
            local machineKind = (kind == "Eat") and "Food" or "Drink"
            local nearest = getNearestMachine(machineKind)
            if not nearest then vendingMachines = collectVendingMachines() nearest = getNearestMachine(machineKind) end
            if not nearest then AutoEatStatusLabel = "No vending machine found" break end
            if (LocalPlayer:GetAttribute("Money") or 0) < nearest.price then AutoEatStatusLabel = "Not enough money" break end
            AutoEatStatusLabel = "Buying from far away..."
            nearest.event:FireServer()
            local t0 = os.clock()
            repeat task.wait(0.15) tool = findAutoEatTool(toolNames) until tool or os.clock() - t0 > 3
            if not tool then misses += 1 task.wait(1) continue end
        end
        local _, humanoid = getCharacterHunger()
        if not humanoid then break end
        if tool.Parent == LocalPlayer.Backpack then
            humanoid:EquipTool(tool)
            local t0 = os.clock()
            while RunningAutoHunger and AutoHungerState.Enabled and tool.Parent == LocalPlayer.Backpack and os.clock() - t0 < 2 do task.wait(0.1) end
            task.wait(0.3)
        end
        if not tool.Parent then actions += 1 continue end
        local t0 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled and tool.Parent and tool:GetAttribute("OnCooldown") and os.clock() - t0 < 6 do task.wait(0.15) end
        if not RunningAutoHunger or not AutoHungerState.Enabled or not tool.Parent then actions += 1 continue end
        local before = LocalPlayer:GetAttribute(statName) or 0
        ToolEvent:FireServer(kind, tool)
        AutoEatStatusLabel = kind == "Eat" and "Eating..." or "Drinking..."
        actions += 1
        local t1 = os.clock()
        while RunningAutoHunger and AutoHungerState.Enabled and os.clock() - t1 < 4 do
            if not tool.Parent then break end
            if (LocalPlayer:GetAttribute(statName) or 0) ~= before then break end
            task.wait(0.1)
        end
        if (LocalPlayer:GetAttribute(statName) or 0) ~= before then misses = 0 else misses += 1 end
        task.wait(0.5)
    end
    stowLeftover(toolNames)
    if AutoHungerState.Enabled then AutoEatStatusLabel = "Idle" end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if not RunningAutoHunger or not AutoHungerState.Enabled then return end
            local hunger = LocalPlayer:GetAttribute("Hunger")
            local thirst = LocalPlayer:GetAttribute("Thirst")
            if hunger and hunger < AutoHungerState.EatBelow then
                consumeAutoHunger("Eat", FOOD_TOOLS, "Hunger", function() return AutoHungerState.EatBelow end)
            end
            if thirst and thirst < AutoHungerState.DrinkBelow then
                consumeAutoHunger("Drink", DRINK_TOOLS, "Thirst", function() return AutoHungerState.DrinkBelow end)
            end
        end)
    end
end)

local RocksFolder = Workspace:WaitForChild("Tasks"):WaitForChild("Prisoner"):WaitForChild("Rocks")
local TrashesFolder = Workspace:WaitForChild("Tasks"):WaitForChild("Prisoner"):WaitForChild("Trashes")
local MineRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tool"):WaitForChild("Event")
local JanitorTasks = Workspace:WaitForChild("Tasks"):WaitForChild("Janitor")

local JANITOR_AREA_CFRAME = CFrame.new(220.45, 18.3, -648.67)
local farming = false
local cleanedCount = 0
local JanitorStatusLabel = "idle | Cleaned: 0"

local function getCharacterParts()
    local char = LocalPlayer.Character
    if not char or char.Parent == nil then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil, nil end
    return char, hrp
end

local function getMop()
    local char = LocalPlayer.Character
    if char then
        local equipped = char:FindFirstChild("Mop")
        if equipped and equipped:IsA("Tool") then return equipped, true end
    end
    local bagMop = LocalPlayer.Backpack:FindFirstChild("Mop")
    if bagMop and bagMop:IsA("Tool") then return bagMop, false end
    return nil, false
end

local function getPuddles()
    local list = {}
    for _, child in ipairs(JanitorTasks:GetChildren()) do
        if child:IsA("BasePart") and child.Size.Y < 0.5 then table.insert(list, child) end
    end
    return list
end

local function nearestPuddle(origin)
    local best, bestDist = nil, math.huge
    for _, puddle in ipairs(getPuddles()) do
        local dist = (puddle.Position - origin).Magnitude
        if dist < bestDist then best, bestDist = puddle, dist end
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
    while farming do
        local char = LocalPlayer.Character
        if not char then return false end
        local mop, equipped = getMop()
        if not mop then return false end
        if not equipped then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return false end
            hum:EquipTool(mop) task.wait(0.4) continue
        end
        if puddle.Parent ~= JanitorTasks then return true end
        if mop:GetAttribute("OnCooldown") then task.wait(0.25) continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        if (hrp.Position - puddle.Position).Magnitude > 8 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(puddle.Position + Vector3.new(0, 3.2, 0))
            task.wait(0.2) continue
        end
        ToolEvent:FireServer("Mop", mop, puddle)
        task.wait(0.5)
    end
    return false
end

local function farmLoop()
    while farming do
        local char, hrp = getCharacterParts()
        if not char or not hrp then task.wait(1) continue end
        local mop = getMop()
        if not mop then task.wait(1) continue end
        local puddle = nearestPuddle(hrp.Position)
        if not puddle then task.wait(1) continue end
        local wasCleaned = mopPuddle(puddle)
        if wasCleaned then cleanedCount += 1 end
        task.wait(0.15)
    end
end

local AutoMine = { IsActive = false, NoclipConnection = nil, LockConnection = nil, OriginalCollisions = {}, RunningThread = nil }
local function clearFarmTable(t) for key in pairs(t) do t[key] = nil end end

function AutoMine.FindClosestRock()
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
                if distance < minDistance then minDistance = distance closest = rock end
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
                if AutoMine.OriginalCollisions[part] == nil then AutoMine.OriginalCollisions[part] = part.CanCollide end
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
            if not humanoid or not rootPart or not backpack then task.wait(0.5) continue end
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
                        local tool = char:FindFirstChild("Pickaxe") or backpack:FindFirstChild("Pickaxe") or char:FindFirstChild("PremiumPickaxe") or backpack:FindFirstChild("PremiumPickaxe")
                        if tool then
                            if tool.Parent == backpack then tool.Parent = char end
                            MineRemote:FireServer("MineOres", tool, targetRock)
                        end
                    end)
                    task.wait(0.05)
                end
                if AutoMine.LockConnection then AutoMine.LockConnection:Disconnect() AutoMine.LockConnection = nil end
            else task.wait(0.5) end
            task.wait(0.05)
        end
    end)
end

function AutoMine.Stop()
    AutoMine.IsActive = false
    AutoMine.RunningThread = nil
    if AutoMine.LockConnection then AutoMine.LockConnection:Disconnect() AutoMine.LockConnection = nil end
    if AutoMine.NoclipConnection then AutoMine.NoclipConnection:Disconnect() AutoMine.NoclipConnection = nil end
    pcall(function()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:UnequipTools() end
    end)
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and AutoMine.OriginalCollisions[part] ~= nil then part.CanCollide = AutoMine.OriginalCollisions[part] end
            end
        end
        clearFarmTable(AutoMine.OriginalCollisions)
    end)
end

local AutoTrash = { IsActive = false, RunningThread = nil }

function AutoTrash.Start()
    if AutoTrash.IsActive then return end
    AutoTrash.IsActive = true
    AutoTrash.RunningThread = task.spawn(function()
        while AutoTrash.IsActive do
            local char = LocalPlayer.Character
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if char and backpack then
                pcall(function()
                    local trashTool = char:FindFirstChild("SmallTrash") or backpack:FindFirstChild("SmallTrash") or char:FindFirstChild("BigTrash") or backpack:FindFirstChild("BigTrash")
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if trashTool and rootPart and humanoid then
                        local dumpster = Workspace.Map.Cells.Basement["Recyclement Room"].Props["Opened Trash"].Trash
                        rootPart.CFrame = dumpster.CFrame * CFrame.new(0, 2, 0)
                        if not AutoTrash.IsActive then return end
                        task.wait(0.3)
                        if not AutoTrash.IsActive then return end
                        if trashTool.Parent == backpack then humanoid:EquipTool(trashTool) end
                        dumpster.Prompt.Interact.Event:FireServer()
                        if not AutoTrash.IsActive then return end
                        task.wait(0.3)
                    else
                        local activeBin
                        for _, bin in ipairs(TrashesFolder:GetChildren()) do
                            local prompt = bin:FindFirstChild("Prompt")
                            if prompt and prompt:GetAttribute("Enabled") == true then activeBin = bin break end
                        end
                        if activeBin and activeBin.Prompt and rootPart then
                            rootPart.CFrame = activeBin.Prompt.Parent.CFrame * CFrame.new(0, 2, 0)
                            if not AutoTrash.IsActive then return end
                            task.wait(0.3)
                            if not AutoTrash.IsActive then return end
                            activeBin.Prompt.Interact.Event:FireServer()
                            if not AutoTrash.IsActive then return end
                            task.wait(0.5)
                        else task.wait(1) end
                    end
                end)
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
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Quests"):WaitForChild("Pushups"):WaitForChild("Function"):InvokeServer("Submit", 300)
    end)
end

local FarmState = { AutoCook = false, AutoFish = false, AutoSell = false, SellInterval = 20 }
local function getRootPart()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart", 5)
end

local farmSteps = {
    {name = "Cut", cframe = CFrame.new(43.00, 7.54, -298.80), path = "Cut"},
    {name = "Cook", cframe = CFrame.new(37.12, 7.54, -297.77), path = "Cook"},
    {name = "Boil", cframe = CFrame.new(32.07, 7.54, -296.28), path = "Simmer"},
    {name = "Combine", cframe = CFrame.new(41.81, 7.54, -294.10), path = "Assemble"},
    {name = "To take", cframe = CFrame.new(48.75, 7.54, -296.25), path = "Take"},
    {name = "Deposit", cframe = CFrame.new(16.09, 7.54, -314.13), path = "Deposit"}
}

local function checkStep(step)
    local tasks = workspace:FindFirstChild("Tasks")
    if not tasks then return nil end
    local cook = tasks:FindFirstChild("Cook")
    if not cook then return nil end
    local taskObj = cook:FindFirstChild(step.path)
    if not taskObj then return nil end
    local root = taskObj:FindFirstChild("RootPart")
    if not root then return nil end
    local prompt = root:FindFirstChild("Prompt")
    if not prompt then return nil end
    local interact = prompt:FindFirstChild("Interact")
    if not interact then return nil end
    local event = interact:FindFirstChild("Event")
    if not event or not event:IsA("RemoteEvent") then return nil end
    return event
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
                    if event then pcall(function() event:FireServer() end) end
                end
                if index <= 3 then task.wait(10.0) else task.wait(2.0) end
            end
        end
        task.wait(0.5)
    end
end)

local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem")
local FishingModules = FishingSystem:WaitForChild("FishingModules")
local MinigameSystem = require(FishingModules:WaitForChild("MinigameSystem"))
local PowerBarSystem = require(FishingModules:WaitForChild("PowerBarSystem"))
local SoundManager = require(FishingModules:WaitForChild("SoundManager"))
local GUIManager = require(FishingModules:WaitForChild("GUIManager"))

local function getRod()
   local character = LocalPlayer.Character
   if character then
       for _, child in ipairs(character:GetChildren()) do
           if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then return child end
       end
   end
   local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
   if backpack then
       for _, child in ipairs(backpack:GetChildren()) do
           if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then return child end
       end
   end
   return nil
end

local function getElements()
   local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
   local fishingGui = playerGui and playerGui:FindFirstChild("FishingGui")
   local fishing = fishingGui and fishingGui:FindFirstChild("Fishing")
   local bar = fishing and fishing:FindFirstChild("Bar")
   return bar and bar:FindFirstChild("PlayerZone"), bar and bar:FindFirstChild("FishMarker")
end

local function mouseDown() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0) end
local function mouseUp() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end

local function castRod()
   if PowerBarSystem:IsCharging() then mouseUp() task.wait(0.15) end
   mouseDown()
   local start = os.clock()
   while os.clock() - start < 1.0 do
       RunService.Heartbeat:Wait()
       if PowerBarSystem:IsCharging() then break end
   end
   while os.clock() - start < 5 do
       RunService.Heartbeat:Wait()
       if PowerBarSystem:GetCurrentPower() >= 99.5 then break end
       if not PowerBarSystem:IsCharging() and os.clock() - start > 0.5 then break end
   end
   mouseUp()
end

local lastClick = 0
RunService.Heartbeat:Connect(function()
   if not FarmState.AutoFish then return end
   if not MinigameSystem:IsActive() then return end
   pcall(function()
       local phase = MinigameSystem:GetPhase()
       if phase == "shake" then
           if os.clock() - lastClick > 0.04 then
               MinigameSystem:HandleClick(SoundManager, GUIManager)
               lastClick = os.clock()
           end
       elseif phase == "reel" then
           local zone, marker = getElements()
           if zone and marker then
               local zonePos = zone.Position.X.Scale
               local fishPos = marker.Position.X.Scale
               if fishPos > zonePos + 0.01 then MinigameSystem:SetHolding(true)
               elseif fishPos < zonePos - 0.01 then MinigameSystem:SetHolding(false)
               else MinigameSystem:SetHolding(false) end
           end
       end
   end)
end)

task.spawn(function()
   while true do
       task.wait(0.1)
       if not FarmState.AutoFish then continue end
       local success, err = pcall(function()
           if MinigameSystem:IsActive() then
               while MinigameSystem:IsActive() and FarmState.AutoFish do task.wait(0.1) end
               task.wait(0.5)
           end
           if not FarmState.AutoFish then return end
           local character = LocalPlayer.Character
           local humanoid = character and character:FindFirstChildOfClass("Humanoid")
           if not character or not humanoid or humanoid.Health <= 0 then task.wait(1) return end

           humanoid.WalkSpeed = 0
           pcall(function() humanoid.JumpPower = 0 end)
           pcall(function() humanoid.JumpHeight = 0 end)

           local rod = getRod()
           if not rod then task.wait(1) return end
           if rod.Parent ~= character then humanoid:EquipTool(rod) task.wait(0.8) end
           castRod()
       end)
       if not success then task.wait(1) end
   end
end)

task.spawn(function()
   while true do
       task.wait(FarmState.SellInterval)
       if FarmState.AutoSell then pcall(function() FishingSystem.InventoryEvents.Inventory_SellAll:InvokeServer() end) end
   end
end)

local hiddenInstances = {}
local nametagConnection = nil
local ToggleState = false
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function getTargets()
    local targets = {}
    local mainGui = PlayerGui:FindFirstChild("MainGui")
    if mainGui then
        local bottomLeft = mainGui:FindFirstChild("Bottom") and mainGui.Bottom:FindFirstChild("Left")
        if bottomLeft then
            if bottomLeft:FindFirstChild("Money") then table.insert(targets, bottomLeft.Money) end
            if bottomLeft:FindFirstChild("Experience") then table.insert(targets, bottomLeft.Experience) end
        end
        local bottomRight = mainGui:FindFirstChild("Bottom") and mainGui.Bottom:FindFirstChild("Right")
        if bottomRight then
            for _, child in ipairs(bottomRight:GetDescendants()) do
                if child:IsA("TextLabel") then
                    local txt = child.Text or ""
                    if string.find(txt, LocalPlayer.Name, 1, true) or string.find(txt, tostring(LocalPlayer.UserId), 1, true) then
                        table.insert(targets, child)
                    end
                end
            end
        end
    end
    return targets
end

local function hideNametags()
    local function scanModel(model)
        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("BillboardGui") and not table.find(hiddenInstances, v) then
                v.Enabled = false
                table.insert(hiddenInstances, v)
            end
        end
    end
    local char = LocalPlayer.Character
    if char then scanModel(char) end
    local playersFolder = game.Workspace:FindFirstChild("Players")
    if playersFolder then
        local myModel = playersFolder:FindFirstChild(LocalPlayer.Name)
        if myModel then scanModel(myModel) end
    end
end

local function hideAll()
    for _, target in pairs(getTargets()) do
        if target.Visible ~= false then
            target.Visible = false
            table.insert(hiddenInstances, target)
        end
    end
    hideNametags()
end

local function showAll()
    for _, inst in pairs(hiddenInstances) do
        if inst and inst.Parent then
            if inst:IsA("BillboardGui") then inst.Enabled = true
            else inst.Visible = true end
        end
    end
    hiddenInstances = {}
end

local function startNametagWatch()
    if nametagConnection then return end
    nametagConnection = RunService.RenderStepped:Connect(function()
        if not ToggleState then return end
        hideAll()
    end)
end

local function stopNametagWatch()
    if nametagConnection then nametagConnection:Disconnect() nametagConnection = nil end
end

local function safeSetDesc(element, text)
    pcall(function()
        if element and element.SetDesc then
            element:SetDesc(text)
        elseif element and element.SetDescription then
            element:SetDescription(text)
        end
    end)
end

local DashboardTab = Window:Tab({ Title = "Dashboard", Icon = "layout-dashboard" })
local AutoFarmTab = Window:Tab({ Title = "Auto Farm", Icon = "warehouse" })
local AutoEatTab = Window:Tab({ Title = "Auto Eat", Icon = "utensils" })
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
local ExtraTab = Window:Tab({ Title = "Extra", Icon = "package-plus" })
local StaffTab = Window:Tab({ Title = "Staff", Icon = "shield" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

local DashSection = DashboardTab:Section({ Title = "Performance & Server", Icon = "activity", Box = true })

local FpsLabel = DashSection:Button({ Title = "FPS Rate", Desc = "calculating...", Icon = "gauge" })
local PingLabel = DashSection:Button({ Title = "MS (Ping)", Desc = "calculating...", Icon = "wifi" })
local PlayerLabel = DashSection:Button({ Title = "Server Players", Desc = "0 / 0", Icon = "users" })
local FriendLabel = DashSection:Button({ Title = "Active Friends", Desc = "0", Icon = "heart" })
local MoneyLabel = DashSection:Button({ Title = "Money", Desc = "$0", Icon = "wallet" })
local TeamLabel = DashSection:Button({ Title = "Team", Desc = "Unknown", Icon = "shield" })
local HealthLabel = DashSection:Button({ Title = "Health", Desc = "100 / 100", Icon = "heart-pulse" })
local SessionLabel = DashSection:Button({ Title = "Session", Desc = "00:00:00", Icon = "clock-3" })
local FarmStatusLabel = DashSection:Button({ Title = "Farm Status", Desc = "Idle", Icon = "activity" })

local DashboardStartTime = os.clock()

local function getDashboardFarmStatus()
    if FarmState.AutoCook then return "Auto Cook" end
    if FarmState.AutoFish then return FarmState.AutoSell and "Auto Fish + Sell" or "Auto Fish" end
    if AutoMine.IsActive then return "Auto Mine" end
    if AutoTrash.IsActive then return "Auto Trash" end
    if farming then return "Janitor" end
    if AutoHungerState.Enabled then return "Auto Eat / Drink" end
    return "Idle"
end

local function formatSession(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end


local frameCount, lastTime = 0, os.clock()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local currentTime = os.clock()
    if currentTime - lastTime >= 1 then
        safeSetDesc(FpsLabel, tostring(frameCount) .. " FPS")
        frameCount = 0
        lastTime = currentTime
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        safeSetDesc(PingLabel, tostring(ping) .. " ms")

        local currentPlayers = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        safeSetDesc(PlayerLabel, currentPlayers .. " / " .. maxPlayers)

        local friendsInServer = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and LocalPlayer:IsFriendsWith(p.UserId) then friendsInServer += 1 end
        end
        safeSetDesc(FriendLabel, tostring(friendsInServer))

        local money = LocalPlayer:GetAttribute("Money")
        if money ~= nil then
            safeSetDesc(MoneyLabel, "$" .. tostring(math.floor(tonumber(money) or 0)))
        else
            safeSetDesc(MoneyLabel, "Unavailable")
        end

        safeSetDesc(TeamLabel, LocalPlayer.Team and LocalPlayer.Team.Name or "No Team")

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            safeSetDesc(HealthLabel, string.format("%d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth)))
        else
            safeSetDesc(HealthLabel, "Unavailable")
        end

        safeSetDesc(SessionLabel, formatSession(os.clock() - DashboardStartTime))
        safeSetDesc(FarmStatusLabel, getDashboardFarmStatus())
    end
end)

DashboardTab:Button({
    Title = "RESET SCRIPT",
    Desc = "Restarts Bytee Hub safely",
    Icon = "refresh-ccw",
    Color = Color3.fromHex("#F44732"),
    Callback = function() print("Reloading UI...") end,
})

DashboardTab:Paragraph({
    Title = "Bytee Hub",
    Desc = "First of all, the script is still in beta; please keep this in mind. The main reason for this is to provide you with a better experience. This script brings many innovations to you, so stay patient through the challenge.",
    Buttons = {
        { Title = "YouTube", Callback = function() if setclipboard then setclipboard("https://youtube.com/@thesyntezys?si=MxwEA0EzAhKy_mQh") end end },
        { Title = "Discord", Variant = "Secondary", Callback = function() if setclipboard then setclipboard("https://discord.gg/rVFTeNfyxC") end end },
    },
})

DashboardTab:Paragraph({
    Title = "Important Notice",
    Desc = "Please choose empty servers when farming. Doing it in crowded servers may put your account at risk.\n\nThis script was made for PrisonRP on Roblox. Running it in another game may cause issues.",
})

local DevSection = DashboardTab:Section({ Title = "Development Team", Icon = "users", Box = true })
DevSection:Button({ Title = "Owner", Desc = "Bytecode" })
DevSection:Button({ Title = "Scripters", Desc = "Bytecode, Levis" })
DevSection:Button({ Title = "UI Designer", Desc = "Levis" })

local EatSection = AutoEatTab:Section({ Title = "Auto Hunger System", Icon = "utensils-crossed", Box = true })

local StatusBtn = EatSection:Button({ Title = "Status", Desc = "Idle", Icon = "info" })
local function setAutoEatStatus(msg)
    AutoEatStatusLabel = msg
    safeSetDesc(StatusBtn, msg)
end
setAutoEatStatus("Idle")

EatSection:Toggle({
    Title = "Enable Auto Eat / Drink",
    Desc = "Watches your Hunger/Thirst. When it drops below the threshold, it auto consumes items. If you have none, it buys from vending machines from ANY distance.",
    Icon = "utensils-crossed",
    Default = false,
    Callback = function(state)
        AutoHungerState.Enabled = state
        if not state then setAutoEatStatus("Idle") end
    end,
})

EatSection:Slider({
    Title = "Eat When Hunger Below",
    Desc = "Threshold percentage for food",
    Icon = "sandwich",
    Min = 5, Max = 95, Default = 50, Step = 1,
    Callback = function(val) AutoHungerState.EatBelow = val end,
})

EatSection:Slider({
    Title = "Drink When Thirst Below",
    Desc = "Threshold percentage for drinks",
    Icon = "cup-soda",
    Min = 5, Max = 95, Default = 50, Step = 1,
    Callback = function(val) AutoHungerState.DrinkBelow = val end,
})

local FarmSection = AutoFarmTab:Section({ Title = "Auto Farm & Cooking", Icon = "chef-hat", Box = true })

FarmSection:Toggle({
    Title = "Auto Cook",
    Desc = "Automatically cooks and deposits food",
    Default = false,
    Callback = function(state) FarmState.AutoCook = state end,
})

local FishSection = AutoFarmTab:Section({ Title = "Fishing System", Icon = "fish", Box = true })

FishSection:Toggle({
    Title = "Auto Fish",
    Desc = "Automatically catches fish & freezes your character",
    Default = false,
    Callback = function(state)
        FarmState.AutoFish = state
        if not state then
            pcall(function() MinigameSystem:SetHolding(false) end)
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                pcall(function() humanoid.JumpPower = 50 end)
                pcall(function() humanoid.JumpHeight = 7.2 end)
            end
        end
    end,
})

FishSection:Toggle({
    Title = "Auto Sell Fish",
    Desc = "Sells inventory every 20s",
    Default = false,
    Callback = function(state) FarmState.AutoSell = state end,
})

FishSection:Button({
    Title = "Sell All Fish Now",
    Desc = "Instantly sell caught fish",
    Callback = function() pcall(function() FishingSystem.InventoryEvents.Inventory_SellAll:InvokeServer() end) end,
})

FishSection:Button({
    Title = "Teleport to Fishing Area",
    Desc = "Go to FishingZone",
    Callback = function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local fz = workspace:FindFirstChild("FishingZone")
        if hrp and fz then hrp.CFrame = fz.CFrame + Vector3.new(0, 5, 0) end
    end,
})

local MineSection = AutoFarmTab:Section({ Title = "Mining & Trash", Icon = "pickaxe", Box = true })

MineSection:Toggle({
    Title = "Auto Mine",
    Desc = "Mines nearest rock with noclip",
    Default = false,
    Callback = function(state) if state then AutoMine.Start() else AutoMine.Stop() end end,
})

MineSection:Toggle({
    Title = "Auto Trash (EXP)",
    Desc = "Collects and empties trash",
    Default = false,
    Callback = function(state) if state then AutoTrash.Start() else AutoTrash.Stop() end end,
})

MineSection:Button({
    Title = "Unlock Fists",
    Desc = "Unlocks fists via Pushups quest",
    Callback = function() unlockFists() end,
})

local JanitorSection = AutoFarmTab:Section({ Title = "Janitor Farm", Icon = "droplets", Box = true })
local JanitorStatusBtn = JanitorSection:Button({ Title = "Janitor Status", Desc = "idle | Cleaned: 0", Icon = "info" })

local function setJanitorStatus(text)
    safeSetDesc(JanitorStatusBtn, text)
end

task.spawn(function()
    while task.wait(2) do
        if farming then setJanitorStatus("farming | Cleaned: " .. cleanedCount) end
    end
end)

JanitorSection:Toggle({
    Title = "Auto Clean Puddles",
    Desc = "Farms Janitor Puddles",
    Default = false,
    Callback = function(state)
        farming = state
        if state then
            setJanitorStatus("farming | Cleaned: " .. cleanedCount)
            task.spawn(farmLoop)
        else
            setJanitorStatus("idle | Cleaned: " .. cleanedCount)
        end
    end,
})

JanitorSection:Button({
    Title = "Teleport to Janitor Area",
    Callback = function()
        if teleport(JANITOR_AREA_CFRAME) then setJanitorStatus("Teleported to Janitor's Room")
        else setJanitorStatus("Teleport failed (no character)") end
    end,
})

JanitorSection:Button({
    Title = "Teleport to Nearest Puddle",
    Callback = function()
        local _, hrp = getCharacterParts()
        if not hrp then setJanitorStatus("Teleport failed (no character)") return end
        local puddle = nearestPuddle(hrp.Position)
        if not puddle then setJanitorStatus("No puddles active right now") return end
        teleport(CFrame.new(puddle.Position + Vector3.new(0, 3.2, 0)))
        setJanitorStatus("Teleported to puddle")
    end,
})

local CombatSection = CombatTab:Section({ Title = "Aimbot", Icon = "crosshair", Box = true })

CombatSection:Button({
    Title = "AIMBOT SCRIPT [MOBILE]",
    Desc = "Loads external mobile aimbot",
    Color = Color3.fromHex("#F44732"),
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Mobile-34677"))()
    end,
})

local PCAimbot = {
    Enabled = false,
    HoldOnly = true,
    TeamCheck = true,
    FOV = 220,
    Smoothness = 0.18,
    Holding = false,
}

local function getAimbotTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local bestPlayer, bestDistance = nil, PCAimbot.FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if not (PCAimbot.TeamCheck and plr.Team == LocalPlayer.Team) then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                if hum and head and hum.Health > 0 then
                    local screenPos, visible = camera:WorldToViewportPoint(head.Position)
                    if visible and screenPos.Z > 0 then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distance < bestDistance then
                            bestDistance = distance
                            bestPlayer = plr
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

RunService.RenderStepped:Connect(function()
    if not PCAimbot.Enabled then return end
    if PCAimbot.HoldOnly and not PCAimbot.Holding then return end

    local camera = Workspace.CurrentCamera
    local target = getAimbotTarget()
    local head = target and target.Character and target.Character:FindFirstChild("Head")

    if camera and head then
        local desired = CFrame.lookAt(camera.CFrame.Position, head.Position)
        camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(PCAimbot.Smoothness, 0.02, 1))
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        PCAimbot.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        PCAimbot.Holding = false
    end
end)

CombatSection:Toggle({
    Title = "PC Aimbot",
    Desc = "Hold right mouse button to aim at the nearest visible player inside FOV.",
    Icon = "crosshair",
    Default = false,
    Callback = function(Value)
        PCAimbot.Enabled = Value
    end,
})

CombatSection:Toggle({
    Title = "Aimbot Team Check",
    Desc = "Ignores players on your current team.",
    Icon = "users",
    Default = true,
    Callback = function(Value)
        PCAimbot.TeamCheck = Value
    end,
})

CombatSection:Slider({
    Title = "Aimbot FOV",
    Desc = "Maximum screen distance for target selection.",
    Icon = "scan",
    Min = 50, Max = 500, Step = 10, Default = 220,
    Callback = function(Value)
        PCAimbot.FOV = Value
    end,
})

CombatSection:Slider({
    Title = "Aimbot Smoothness",
    Desc = "Higher values lock faster; lower values are smoother.",
    Icon = "move",
    Min = 2, Max = 100, Step = 1, Default = 18,
    Callback = function(Value)
        PCAimbot.Smoothness = Value / 100
    end,
})


CombatTab:Paragraph({
    Title = "Notice",
    Desc = "New features will be added in a minor update, thank you for your patience.",
})

local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))
local VirtualUser = game:GetService("VirtualUser")

local function MakeElementDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local connections = {}

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local c1 = gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        end
    end)

    local c2 = gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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
        for _, conn in pairs(connections) do
            if conn then conn:Disconnect() end
        end
    end
end

local HUDSection = ExtraTab:Section({ Title = "Mobile HUD Editor", Icon = "layout-template", Box = true })

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

MakeElementDraggable(EditFrame)

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

CreateCompactBtn("Size +", UDim2.new(0.06, 0, 0, 40), UDim2.new(0.42, 0, 0, 22), Color3.fromRGB(30, 30, 30), function()
   if SelectedButton then
      SelectedButton.Size = UDim2.new(SelectedButton.Size.X.Scale * 1.1, SelectedButton.Size.X.Offset * 1.1, SelectedButton.Size.Y.Scale * 1.1, SelectedButton.Size.Y.Offset * 1.1)
   end
end)

CreateCompactBtn("Size -", UDim2.new(0.52, 0, 0, 40), UDim2.new(0.42, 0, 0, 22), Color3.fromRGB(30, 30, 30), function()
   if SelectedButton then
      SelectedButton.Size = UDim2.new(SelectedButton.Size.X.Scale * 0.9, SelectedButton.Size.X.Offset * 0.9, SelectedButton.Size.Y.Scale * 0.9, SelectedButton.Size.Y.Offset * 0.9)
   end
end)

CreateCompactBtn("Alpha +", UDim2.new(0.06, 0, 0, 68), UDim2.new(0.42, 0, 0, 22), Color3.fromRGB(30, 30, 30), function()
   if SelectedButton then
      if SelectedButton:IsA("ImageButton") then
         SelectedButton.ImageTransparency = math.clamp(SelectedButton.ImageTransparency + 0.1, 0, 1)
      elseif SelectedButton:IsA("TextButton") then
         SelectedButton.BackgroundTransparency = math.clamp(SelectedButton.BackgroundTransparency + 0.1, 0, 1)
      end
   end
end)

CreateCompactBtn("Alpha -", UDim2.new(0.52, 0, 0, 68), UDim2.new(0.42, 0, 0, 22), Color3.fromRGB(30, 30, 30), function()
   if SelectedButton then
      if SelectedButton:IsA("ImageButton") then
         SelectedButton.ImageTransparency = math.clamp(SelectedButton.ImageTransparency - 0.1, 0, 1)
      elseif SelectedButton:IsA("TextButton") then
         SelectedButton.BackgroundTransparency = math.clamp(SelectedButton.BackgroundTransparency - 0.1, 0, 1)
      end
   end
end)

CreateCompactBtn("SAVE LAYOUT", UDim2.new(0.06, 0, 0, 98), UDim2.new(0.88, 0, 0, 24), Color3.fromRGB(40, 80, 40), function()
   SavedHUDLayout = {}
   for _, gui in pairs(PlayerGui:GetChildren()) do
      if gui:IsA("ScreenGui") and gui.Name ~= "CompactHUDEditor" and gui.Name ~= "WindUI" then
         for _, element in pairs(gui:GetDescendants()) do
            if element:IsA("ImageButton") or element:IsA("TextButton") then
               SavedHUDLayout[element] = {
                  Position = element.Position,
                  Size = element.Size,
                  Transparency = element:IsA("ImageButton") and element.ImageTransparency or element.BackgroundTransparency
               }
            end
         end
      end
   end
   WindUI:Notify({Title = "HUD Editor", Content = "Layout Saved!", Duration = 2})
end)

CreateCompactBtn("LOAD LAYOUT", UDim2.new(0.06, 0, 0, 128), UDim2.new(0.88, 0, 0, 24), Color3.fromRGB(40, 40, 80), function()
   for element, data in pairs(SavedHUDLayout) do
      if element and element.Parent then
         element.Position = data.Position
         element.Size = data.Size
         if element:IsA("ImageButton") then element.ImageTransparency = data.Transparency end
         if element:IsA("TextButton") then element.BackgroundTransparency = data.Transparency end
      end
   end
   WindUI:Notify({Title = "HUD Editor", Content = "Layout Loaded!", Duration = 2})
end)

HUDSection:Toggle({
   Title = "Enable Mobile HUD Editor Overlay",
   Desc = "Allows you to move, resize, and change transparency of game UI buttons.",
   Icon = "layout-dashboard",
   Default = false,
   Callback = function(Value)
      HUDEditorActive = Value
      EditScreenGui.Enabled = Value
      
      for _, conn in pairs(HUDConnections) do conn:Disconnect() end
      HUDConnections = {}

      for _, cleanupFunc in pairs(HUDDragCleanup) do
         if cleanupFunc then cleanupFunc() end
      end
      HUDDragCleanup = {}
      
      SelectedButton = nil
      SelectedLabel.Text = "Selected: None"

      if HUDEditorActive then
         for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "CompactHUDEditor" and gui.Name ~= "WindUI" then
               for _, element in pairs(gui:GetDescendants()) do
                  if element:IsA("ImageButton") or element:IsA("TextButton") then
                     local dragCleanup = MakeElementDraggable(element)
                     table.insert(HUDDragCleanup, dragCleanup)

                     local conn = element.MouseButton1Click:Connect(function()
                        SelectedButton = element
                        SelectedLabel.Text = "Selected: " .. string.sub(element.Name, 1, 14)
                     end)
                     table.insert(HUDConnections, conn)
                  end
               end
            end
         end
      end
   end,
})

local ESPSection = ExtraTab:Section({ Title = "ESP System", Icon = "eye", Box = true })

local ESPEnabled = false
local ESPConnections = {}

local RoleColors = {
   Murderer = Color3.fromRGB(255, 30, 30),
   Sheriff = Color3.fromRGB(0, 162, 255),
   Hero = Color3.fromRGB(255, 215, 0),
   Civilian = Color3.fromRGB(0, 255, 136),
   Default = Color3.fromRGB(200, 200, 200)
}

local function GetPlayerRoleAndColor(plr)
   if not plr then return "Civilian", RoleColors.Civilian end
   local char = plr.Character
   if char then
      if char:FindFirstChild("Role") then 
         local rVal = tostring(char.Role.Value)
         return rVal, RoleColors[rVal] or RoleColors.Default
      end
      local bp = plr:FindFirstChild("Backpack")
      if bp then
         if bp:FindFirstChild("Knife") or char:FindFirstChild("Knife") then return "Murderer", RoleColors.Murderer end
         if bp:FindFirstChild("Gun") or char:FindFirstChild("Gun") or bp:FindFirstChild("Revolver") then return "Sheriff", RoleColors.Sheriff end
      end
   end
   if plr.Team then 
      local tName = plr.Team.Name
      return tName, RoleColors[tName] or RoleColors.Default 
   end
   return "Civilian", RoleColors.Civilian
end

local function RemoveESPForPlayer(plr)
   if ESPConnections[plr] then
      ESPConnections[plr]:Disconnect()
      ESPConnections[plr] = nil
   end
   if plr.Character then
      if plr.Character:FindFirstChild("ESPGlow") then plr.Character.ESPGlow:Destroy() end
      if plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.HumanoidRootPart:FindFirstChild("ESPBillboard") then
         plr.Character.HumanoidRootPart.ESPBillboard:Destroy()
      end
   end
end

local function ApplyESP(plr)
   if plr == LocalPlayer then return end
   RemoveESPForPlayer(plr)

   local function CreateGlowAndTag()
      local char = plr.Character
      local hum = char and char:FindFirstChildOfClass("Humanoid")
      local hrp = char and char:FindFirstChild("HumanoidRootPart")

      if char and hum and hrp then
         local roleName, roleColor = GetPlayerRoleAndColor(plr)

         local highlight = Instance.new("Highlight")
         highlight.Name = "ESPGlow"
         highlight.FillTransparency = 0.8
         highlight.FillColor = roleColor
         highlight.OutlineColor = roleColor
         highlight.OutlineTransparency = 0
         highlight.Adornee = char
         highlight.Parent = char

         local bb = Instance.new("BillboardGui")
         bb.Name = "ESPBillboard"
         bb.Size = UDim2.new(0, 160, 0, 50)
         bb.StudsOffset = Vector3.new(0, 3.5, 0)
         bb.AlwaysOnTop = true
         bb.Adornee = hrp

         local txt = Instance.new("TextLabel")
         txt.Size = UDim2.new(1, 0, 0, 25)
         txt.BackgroundTransparency = 1
         txt.TextColor3 = roleColor
         txt.TextStrokeTransparency = 0.2
         txt.TextSize = 11
         txt.Font = Enum.Font.SourceSansBold
         txt.Parent = bb

         local hpBg = Instance.new("Frame")
         hpBg.Size = UDim2.new(0.8, 0, 0, 4)
         hpBg.Position = UDim2.new(0.1, 0, 0, 28)
         hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
         hpBg.BorderSizePixel = 0
         hpBg.Parent = bb

         local hpFill = Instance.new("Frame")
         hpFill.Size = UDim2.new(1, 0, 1, 0)
         hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
         hpFill.BorderSizePixel = 0
         hpFill.Parent = hpBg

         bb.Parent = hrp

         local renderConn = RunService.RenderStepped:Connect(function()
            if ESPEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp and hrp.Parent and hum and hum.Health > 0 then
               local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
               local currentRole, currentColor = GetPlayerRoleAndColor(plr)

               txt.Text = plr.Name .. " (" .. dist .. "m)\n[" .. currentRole .. "]"
               txt.TextColor3 = currentColor
               highlight.OutlineColor = currentColor
               highlight.FillColor = currentColor

               local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
               hpFill.Size = UDim2.new(hpPercent, 0, 1, 0)
               hpFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
            else
               RemoveESPForPlayer(plr)
            end
         end)
         ESPConnections[plr] = renderConn
      end
   end

   if plr.Character then CreateGlowAndTag() end
   plr.CharacterAdded:Connect(function()
      task.wait(0.5)
      if ESPEnabled then CreateGlowAndTag() end
   end)
end

ESPSection:Toggle({
   Title = "Role + Glow ESP",
   Desc = "Shows player roles, health, and distance through walls.",
   Icon = "eye",
   Default = false,
   Callback = function(Value)
      ESPEnabled = Value
      if ESPEnabled then
         for _, plr in pairs(Players:GetPlayers()) do ApplyESP(plr) end
      else
         for plr, conn in pairs(ESPConnections) do
            if conn then conn:Disconnect() end
         end
         ESPConnections = {}
         for _, plr in pairs(Players:GetPlayers()) do
            RemoveESPForPlayer(plr)
         end
      end
   end,
})

local ExtraCombatSection = ExtraTab:Section({ Title = "Combat & Modifiers", Icon = "swords", Box = true })

local NoCooldownEnabled = false
task.spawn(function()
   while true do
      if NoCooldownEnabled then
         local char = LocalPlayer.Character
         if char then
            for _, tool in pairs(char:GetChildren()) do
               if tool:IsA("Tool") then
                  if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end
                  if tool:FindFirstChild("Debounce") then tool.Debounce.Value = false end
               end
            end
         end
         local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
         if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
               if tool:IsA("Tool") then
                  if tool:FindFirstChild("Cooldown") then tool.Cooldown.Value = 0 end
                  if tool:FindFirstChild("Debounce") then tool.Debounce.Value = false end
               end
            end
         end
      end
      task.wait(0.1)
   end
end)

ExtraCombatSection:Toggle({
   Title = "No Cooldown (Zero Delay)",
   Desc = "Removes cooldown and debounce from tools.",
   Icon = "timer-off",
   Default = false,
   Callback = function(Value) NoCooldownEnabled = Value end,
})

local FastAcquisitionEnabled = false
local PromptConnection = nil

ExtraCombatSection:Toggle({
   Title = "Fast Item Acquisition (Instant E)",
   Desc = "Sets ProximityPrompt hold duration to 0.",
   Icon = "hand",
   Default = false,
   Callback = function(Value)
      FastAcquisitionEnabled = Value
      if FastAcquisitionEnabled then
         for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
         end
         PromptConnection = ProximityPromptService.PromptAdded:Connect(function(prompt)
            if FastAcquisitionEnabled then prompt.HoldDuration = 0 end
         end)
      else
         if PromptConnection then PromptConnection:Disconnect() PromptConnection = nil end
      end
   end,
})

local AutoClickerEnabled = false
local AutoClickerCPS = 20

task.spawn(function()
   while true do
      if AutoClickerEnabled then
         if mouse1press and mouse1click then
            mouse1press()
            task.wait(0.01)
            mouse1click()
         else
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0,0))
         end
         task.wait(1 / math.clamp(AutoClickerCPS, 1, 100))
      else
         task.wait(0.1)
      end
   end
end)

ExtraCombatSection:Toggle({
   Title = "Enable Auto Clicker",
   Desc = "Automatically clicks for you.",
   Icon = "mouse-pointer-click",
   Default = false,
   Callback = function(Value) AutoClickerEnabled = Value end,
})

ExtraCombatSection:Slider({
   Title = "Clicker Speed (CPS)",
   Desc = "Clicks per second.",
   Icon = "gauge",
   Min = 1, Max = 60, Step = 1, Default = 20,
   Callback = function(Value) AutoClickerCPS = Value end,
})

local TPSection = ExtraTab:Section({ Title = "Black Market TP", Icon = "map-pin", Box = true })

local BlackMarketNPC = nil

local function FindBlackMarketNPC()
   for _, obj in pairs(workspace:GetDescendants()) do
      if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
         local nameLower = string.lower(obj.Name)
         if string.find(nameLower, "black") and string.find(nameLower, "market") then
            return obj
         end
      end
   end
   return nil
end

TPSection:Button({
   Title = "TP To Black Market (Front Position)",
   Desc = "Teleports directly in front of Black Market NPC.",
   Icon = "map-pin",
   Callback = function()
      BlackMarketNPC = FindBlackMarketNPC()
      
      if BlackMarketNPC and BlackMarketNPC:FindFirstChild("HumanoidRootPart") then
         local char = LocalPlayer.Character
         if char and char:FindFirstChild("HumanoidRootPart") then
            local npcHRP = BlackMarketNPC.HumanoidRootPart
            local frontPosition = npcHRP.CFrame * CFrame.new(0, 0, -3)
            char.HumanoidRootPart.CFrame = CFrame.lookAt(frontPosition.Position, npcHRP.Position)
            WindUI:Notify({Title = "Teleport Success", Content = "Teleported directly in front of Black Market!", Duration = 3})
         end
      else
         WindUI:Notify({Title = "Teleport Error", Content = "Black Market NPC not found on map!", Duration = 3})
      end
   end,
})


local STAFF_GROUP_ID = 304256484
local StaffESPEnabled = false
local StaffESPConnections = {}
local StaffRoleCache = {}

local STAFF_ROLE_KEYWORDS = {
    "tester",
    "modérateur",
    "moderateur",
    "administrateur",
    "administrator",
    "staff",
    "manager",
    "developer",
    "dev",
    "fondateur",
    "founder",
    "heni",
    "leadership",
    "responsable",
}

local function normalizeRoleName(role)
    role = tostring(role or ""):lower()
    role = role:gsub("’", "'"):gsub("`", "'")
    return role
end

local function isStaffRole(role)
    local normalized = normalizeRoleName(role)
    if normalized == "" or normalized == "guest" or normalized == "member" then
        return false
    end

    for _, keyword in ipairs(STAFF_ROLE_KEYWORDS) do
        if string.find(normalized, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function getStaffRole(plr)
    if not plr then return "" end

    local cached = StaffRoleCache[plr]
    if cached and os.clock() - cached.time < 5 then
        return cached.role
    end

    local role = ""
    pcall(function()
        role = plr:GetRoleInGroup(STAFF_GROUP_ID)
    end)

    StaffRoleCache[plr] = { role = tostring(role or ""), time = os.clock() }
    return StaffRoleCache[plr].role
end

local function removeStaffESP(plr)
    local conn = StaffESPConnections[plr]
    if conn then conn:Disconnect() StaffESPConnections[plr] = nil end

    local char = plr and plr.Character
    if char then
        local glow = char:FindFirstChild("SynaxStaffESP")
        if glow then glow:Destroy() end

        local root = char:FindFirstChild("HumanoidRootPart")
        local tag = root and root:FindFirstChild("SynaxStaffTag")
        if tag then tag:Destroy() end
    end
end

local function applyStaffESP(plr)
    if plr == LocalPlayer then return end
    removeStaffESP(plr)

    local function refresh()
        if not StaffESPEnabled then return end

        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not root or not hum or hum.Health <= 0 then return end

        local role = getStaffRole(plr)
        if not isStaffRole(role) then return end

        local glow = Instance.new("Highlight")
        glow.Name = "SynaxStaffESP"
        glow.FillColor = Color3.fromRGB(255, 55, 55)
        glow.OutlineColor = Color3.fromRGB(255, 255, 255)
        glow.FillTransparency = 0.55
        glow.OutlineTransparency = 0
        glow.Adornee = char
        glow.Parent = char

        local tag = Instance.new("BillboardGui")
        tag.Name = "SynaxStaffTag"
        tag.Size = UDim2.new(0, 220, 0, 42)
        tag.StudsOffset = Vector3.new(0, 3.5, 0)
        tag.AlwaysOnTop = true
        tag.Adornee = root
        tag.Parent = root

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 70, 70)
        label.TextStrokeTransparency = 0.15
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 13
        label.Parent = tag

        StaffESPConnections[plr] = RunService.RenderStepped:Connect(function()
            if not StaffESPEnabled or not plr.Parent or not char.Parent or hum.Health <= 0 then
                removeStaffESP(plr)
                return
            end

            local currentRole = getStaffRole(plr)
            if not isStaffRole(currentRole) then
                removeStaffESP(plr)
                return
            end

            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
            label.Text = "STAFF • " .. plr.DisplayName .. "\n" .. currentRole .. " • " .. distance .. "m"
        end)
    end

    refresh()
end

StaffTab:Toggle({
    Title = "Staff ESP",
    Desc = "Detects staff through the Nyxkay Studio group (304256484).",
    Icon = "shield-alert",
    Default = false,
    Callback = function(Value)
        StaffESPEnabled = Value

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if Value then applyStaffESP(plr) else removeStaffESP(plr) end
            end
        end
    end,
})

StaffTab:Button({
    Title = "Refresh Staff ESP",
    Desc = "Rechecks group roles for every player.",
    Icon = "refresh-cw",
    Callback = function()
        table.clear(StaffRoleCache)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and StaffESPEnabled then
                applyStaffESP(plr)
            end
        end
        WindUI:Notify({Title = "Staff ESP", Content = "Group roles refreshed.", Duration = 2})
    end,
})

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.75)
        if StaffESPEnabled then applyStaffESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    removeStaffESP(plr)
    StaffRoleCache[plr] = nil
end)

local SetSection = SettingsTab:Section({ Title = "Exploit & Utility Settings", Icon = "settings", Box = true })

local AntiAfkConn = nil
SetSection:Toggle({
    Title = "Anti AFK (Prevent Kick)",
    Desc = "Simulates key presses to avoid disconnecting",
    Default = false,
    Callback = function(state)
        HubSettings.AntiAfk = state
        if state then
            if not AntiAfkConn then
                AntiAfkConn = LocalPlayer.Idled:Connect(function()
                    if HubSettings.AntiAfk then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end
                end)
            end
        else
            if AntiAfkConn then AntiAfkConn:Disconnect() AntiAfkConn = nil end
        end
    end,
})

local HiderSection = SettingsTab:Section({ Title = "Info Hider", Icon = "eye-off", Box = true })
HiderSection:Toggle({
    Title = "Hide Info (Money, Exp, Name, ID)",
    Desc = "Hides your UI info and Nametags from others",
    Default = false,
    Callback = function(state)
        ToggleState = state
        if state then hideAll() startNametagWatch()
        else showAll() stopNametagWatch() end
    end,
})

local ScaleSection = SettingsTab:Section({ Title = "UI Scale Size", Icon = "maximize", Box = true })
ScaleSection:Dropdown({
    Title = "Select UI Scale",
    Desc = "Adjusts the overall size of the Bytee Hub UI",
    Values = {"Small", "Normal", "Large"},
    Default = "Large",
    Callback = function(Value)
        if Value == "Small" then Window:Size(UDim2.fromOffset(700, 500), true)
        elseif Value == "Large" then Window:Size(UDim2.fromOffset(1000, 700), true)
        else Window:Size(UDim2.fromOffset(900, 600), true) end
    end,
})