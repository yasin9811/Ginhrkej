--// Synax Standalone Auto Fish - PC/Xeno + Mobile
--// Game-specific: PrisonRP FishingSystem
--// Separate lightweight UI. Does not modify the main Synax Hub.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

pcall(function()
    local old = CoreGui:FindFirstChild("SynaxAutoFishStandalone")
    if old then old:Destroy() end
end)

local State = {
    Enabled = false,
    Holding = false,
    LastClick = 0,
    Status = "OFF",
}

--// ------------------------------------------------------------
--// Fishing modules
--// ------------------------------------------------------------
local FishingSystem
local FishingModules
local MinigameSystem
local PowerBarSystem
local SoundManager
local GUIManager

local function loadModules()
    if MinigameSystem and PowerBarSystem and SoundManager and GUIManager then
        return true
    end

    local ok = pcall(function()
        FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 5)
        FishingModules = FishingSystem:WaitForChild("FishingModules", 5)

        MinigameSystem = require(FishingModules:WaitForChild("MinigameSystem"))
        PowerBarSystem = require(FishingModules:WaitForChild("PowerBarSystem"))
        SoundManager = require(FishingModules:WaitForChild("SoundManager"))
        GUIManager = require(FishingModules:WaitForChild("GUIManager"))
    end)

    if not ok then
        State.Status = "Fishing modules not found"
        return false
    end

    return true
end

local function getRod()
    local character = LocalPlayer.Character
    if character then
        for _, v in ipairs(character:GetChildren()) do
            if v:IsA("Tool") and string.find(string.lower(v.Name), "rod", 1, true) then
                return v
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") and string.find(string.lower(v.Name), "rod", 1, true) then
                return v
            end
        end
    end

    return nil
end

--// ------------------------------------------------------------
--// PC input compatibility
--// Try executor mouse API first, then VIM.
--// This is the part that fixes executors where VIM stopped working.
--// ------------------------------------------------------------
local function mousePress()
    if State.Holding then return true end

    local ok = false

    -- Common executor APIs
    if type(mouse1press) == "function" then
        ok = pcall(mouse1press)
    elseif type(mouse1click) == "function" then
        ok = pcall(mouse1click)
    end

    if ok then
        State.Holding = true
        return true
    end

    local vimOk = pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end)

    if vimOk then
        State.Holding = true
        return true
    end

    return false
end

local function mouseRelease()
    if not State.Holding then return true end

    local ok = false

    if type(mouse1release) == "function" then
        ok = pcall(mouse1release)
    end

    if ok then
        State.Holding = false
        return true
    end

    local vimOk = pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)

    State.Holding = false
    return vimOk
end

--// ------------------------------------------------------------
--// Cast
--// ------------------------------------------------------------
local function castRod()
    if not State.Enabled then return end
    if not loadModules() then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rod = getRod()

    if not character or not humanoid or humanoid.Health <= 0 then
        State.Status = "Character unavailable"
        return
    end

    if not rod then
        State.Status = "Rod not found"
        return
    end

    if rod.Parent ~= character then
        pcall(function()
            humanoid:EquipTool(rod)
        end)
        task.wait(0.25)
    end

    if rod.Parent ~= character then
        State.Status = "Rod could not equip"
        return
    end

    -- Reset a stuck charge from a previous cycle.
    if PowerBarSystem:IsCharging() then
        mouseRelease()
        task.wait(0.15)
    end

    State.Status = "Casting..."

    if not mousePress() then
        State.Status = "PC input unsupported"
        return
    end

    local start = os.clock()

    -- Wait until the game's power bar actually enters charging state.
    while State.Enabled and os.clock() - start < 2 do
        RunService.Heartbeat:Wait()

        local charging = false
        pcall(function()
            charging = PowerBarSystem:IsCharging()
        end)

        if charging then
            break
        end
    end

    -- Hold until nearly full power.
    while State.Enabled and os.clock() - start < 5 do
        RunService.Heartbeat:Wait()

        local power = 0
        local charging = false

        pcall(function()
            power = PowerBarSystem:GetCurrentPower() or 0
            charging = PowerBarSystem:IsCharging()
        end)

        if power >= 99.5 then
            break
        end

        if not charging and os.clock() - start > 0.6 then
            break
        end
    end

    mouseRelease()
    State.Status = "Waiting for fish..."
end

--// ------------------------------------------------------------
--// Minigame
--// ------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not State.Enabled then return end
    if not loadModules() then return end

    local active = false
    pcall(function()
        active = MinigameSystem:IsActive()
    end)

    if not active then
        return
    end

    pcall(function()
        local phase = MinigameSystem:GetPhase()

        if phase == "shake" then
            if os.clock() - State.LastClick >= 0.04 then
                MinigameSystem:HandleClick(SoundManager, GUIManager)
                State.LastClick = os.clock()
                State.Status = "Hooking..."
            end

        elseif phase == "reel" then
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            local fishingGui = playerGui and playerGui:FindFirstChild("FishingGui")
            local fishing = fishingGui and fishingGui:FindFirstChild("Fishing")
            local bar = fishing and fishing:FindFirstChild("Bar")
            local zone = bar and bar:FindFirstChild("PlayerZone")
            local marker = bar and bar:FindFirstChild("FishMarker")

            if zone and marker then
                local zonePos = zone.Position.X.Scale
                local fishPos = marker.Position.X.Scale

                if fishPos > zonePos + 0.01 then
                    MinigameSystem:SetHolding(true)
                    State.Status = "Reeling..."
                else
                    MinigameSystem:SetHolding(false)
                    State.Status = "Adjusting..."
                end
            end
        end
    end)
end)

--// ------------------------------------------------------------
--// Main loop
--// ------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(0.15)

        if not State.Enabled then
            continue
        end

        if not loadModules() then
            task.wait(1)
            continue
        end

        local active = false
        pcall(function()
            active = MinigameSystem:IsActive()
        end)

        if active then
            State.Status = "Playing..."
            while State.Enabled do
                local stillActive = false
                pcall(function()
                    stillActive = MinigameSystem:IsActive()
                end)
                if not stillActive then break end
                task.wait(0.1)
            end

            if not State.Enabled then break end
            task.wait(0.35)
        end

        if State.Enabled then
            castRod()
            task.wait(0.35)
        end
    end
end)

--// ------------------------------------------------------------
--// UI
--// ------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "SynaxAutoFishStandalone"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 310, 0, 150)
Main.Position = UDim2.new(0.5, -155, 0.72, -75)
Main.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 70, 85)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 32)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "SYNAX • AUTO FISH"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 24)
Status.Position = UDim2.new(0, 10, 0, 40)
Status.BackgroundTransparency = 1
Status.Text = "Status: OFF"
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextColor3 = Color3.fromRGB(150, 155, 170)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 48)
Toggle.Position = UDim2.new(0, 10, 0, 76)
Toggle.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
Toggle.BorderSizePixel = 0
Toggle.Text = "AUTO FISH  •  OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.TextColor3 = Color3.fromRGB(230, 230, 235)
Toggle.AutoButtonColor = true
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 9)
ToggleCorner.Parent = Toggle

local function refreshUI()
    Toggle.Text = State.Enabled and "AUTO FISH  •  ON" or "AUTO FISH  •  OFF"
    Toggle.BackgroundColor3 = State.Enabled
        and Color3.fromRGB(45, 85, 65)
        or Color3.fromRGB(35, 38, 48)

    Status.Text = "Status: " .. State.Status
end

Toggle.MouseButton1Click:Connect(function()
    State.Enabled = not State.Enabled

    if not State.Enabled then
        mouseRelease()

        pcall(function()
            if MinigameSystem then
                MinigameSystem:SetHolding(false)
            end
        end)

        State.Status = "OFF"

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            pcall(function() hum.JumpPower = 50 end)
            pcall(function() hum.JumpHeight = 7.2 end)
        end
    else
        State.Status = "Starting..."
    end

    refreshUI()
end)

--// Drag support: PC + touch
local dragging = false
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Update status text.
task.spawn(function()
    while Gui.Parent do
        task.wait(0.15)
        refreshUI()
    end
end)

refreshUI()
