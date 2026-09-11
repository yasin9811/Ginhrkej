-- Part 1/11
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============================================================================
-- AUTHORIZATION & CONFIGURATION
-- ============================================================================
local API_URL = "https://genres-intelligence-author-geographic.trycloudflare.com
"
local GUILD_ID = "1547303886078087250"
local USER_ID = tostring(LocalPlayer.UserId)
local API_KEY = "fa4c2b088c07832db41dfe7afb5b63d37dfd5c7075c5bea928c683281d1c9a4c"

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
end

local function checkAuthorization()
    local req = getRequestFunction()
    if not req then
        return false, {
            username = LocalPlayer.Name,
            type = "PERMANENT BAN",
            reason = "Executor does not support HTTP requests.",
            issuedBy = "System",
            expiresAt = "Never"
        }
    end

    local endpoint = API_URL .. "/api/access/" .. GUILD_ID .. "/" .. USER_ID
    local success, response = pcall(function()
        return req({
            Url = endpoint,
            Method = "GET",
            Headers = {
                ["x-api-key"] = API_KEY,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if not success or not response then
        return false, {
            username = LocalPlayer.Name,
            type = "PERMANENT BAN",
            reason = "Failed to communicate with authorization server.",
            issuedBy = "System",
            expiresAt = "Never"
        }
    end

    if response.StatusCode ~= 200 then
        return false, {
            username = LocalPlayer.Name,
            type = "PERMANENT BAN",
            reason = "HTTP Error " .. tostring(response.StatusCode),
            issuedBy = "Server",
            expiresAt = "Never"
        }
    end

    local decodeSuccess, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not decodeSuccess or type(data) ~= "table" then
        return false, {
            username = LocalPlayer.Name,
            type = "PERMANENT BAN",
            reason = "Invalid JSON response from server.",
            issuedBy = "Server",
            expiresAt = "Never"
        }
    end

    if data.allowed == true then
        return true, nil
    else
        local banType = data.type or "PERMANENT BAN"
        local expires = data.expiresAt or "Never"

        if banType == "TEMPORARY BAN" and expires == "Never" then
            expires = "Temporary"
        elseif banType == "PERMANENT BAN" then
            expires = "Never"
        end

        return false, {
            username = data.username or LocalPlayer.Name,
            type = banType,
            reason = data.reason or "No reason specified.",
            issuedBy = data.issuedBy or "Administrator",
            expiresAt = expires
        }
    end
end

local isAllowed, banDetails = checkAuthorization()

if not isAllowed then
    if CoreGui:FindFirstChild("SynaxHubAccessDenied") then
        CoreGui:FindFirstChild("SynaxHubAccessDenied"):Destroy()
    end

    local DeniedGui = Instance.new("ScreenGui")
    DeniedGui.Name = "SynaxHubAccessDenied"
    DeniedGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame", DeniedGui)
    MainFrame.Size = UDim2.new(0, 420, 0, 260)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local FrameStroke = Instance.new("UIStroke", MainFrame)
    FrameStroke.Color = Color3.fromRGB(255, 70, 70)
    FrameStroke.Thickness = 1.5

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "ACCESS DENIED"
    Title.TextColor3 = Color3.fromRGB(255, 70, 70)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -40, 0, 180)
    Container.Position = UDim2.new(0, 20, 0, 55)
    Container.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
    Container.BorderSizePixel = 0
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local function addField(yPos, labelText, valueText)
        local lbl = Instance.new("TextLabel", Container)
        lbl.Size = UDim2.new(0, 100, 0, 20)
        lbl.Position = UDim2.new(0, 15, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(130, 135, 150)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local val = Instance.new("TextLabel", Container)
        val.Size = UDim2.new(1, -125, 0, 20)
        val.Position = UDim2.new(0, 115, 0, yPos)
        val.BackgroundTransparency = 1
        val.Text = valueText
        val.TextColor3 = Color3.fromRGB(245, 245, 245)
        val.Font = Enum.Font.GothamBold
        val.TextSize = 11
        val.TextXAlignment = Enum.TextXAlignment.Left
    end

    addField(15, "Username:", tostring(banDetails.username))
    addField(45, "Ban Type:", tostring(banDetails.type))
    addField(75, "Reason:", tostring(banDetails.reason))
    addField(105, "Issued By:", tostring(banDetails.issuedBy))
    addField(135, "Expires At:", tostring(banDetails.expiresAt))

    return
end

-- ============================================================================
-- SYNAX HUB WEBHOOK LOGGER
-- ============================================================================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1547664741034496211/j2j3VLFuXbVuAEII5jhJXdJtG3VjrnRdrwVeMZJU2gAKX4XphXOWCfckDGf1c8ciywFy"
local WEBHOOK_ENABLED = true

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
    if WEBHOOK_URL == "" then return end

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
            thumbnail = { url = avatarUrl },
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
            footer = { text = "Synax Hub • Execution Logger" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
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

local AimbotState = {
    Enabled = false,
    MobileEnabled = false,
    HoldMouse2 = true,
    WallCheck = false,
    TeamCheck = false,
    Sticky = true,
    TargetPart = "Head",
    Smoothness = 0.18,
    FOV = 180,
    FOVEnabled = true,
    Prediction = 0.08,
    MaxDistance = 2000,
    Target = nil,
    Connection = nil
}

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
-- Part 2/11
local FOVCircle = Drawing and Drawing.new("Circle") or nil
if FOVCircle then
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 60
    FOVCircle.Radius = AimbotState.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Transparency = 0.8
end

local TargetTracer = Drawing and Drawing.new("Line") or nil
if TargetTracer then
    TargetTracer.Thickness = 1.5
    TargetTracer.Color = Color3.fromRGB(255, 60, 60)
    TargetTracer.Transparency = 0.9
    TargetTracer.Visible = false
end

local function IsVisible(targetPart, character)
    if not AimbotState.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    
    local filterList = {Camera}
    if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
    if character then table.insert(filterList, character) end
    
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, destination - origin, raycastParams)
    return result == nil
end

local function GetTargetPart(character)
    if not character then return nil end
    if AimbotState.TargetPart == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

local function GetClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDistance = AimbotState.FOVEnabled and AimbotState.FOV or math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (AimbotState.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team) then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local targetPart = GetTargetPart(character)
                    
                    if humanoid and humanoid.Health > 0 and targetPart then
                        local worldPos = targetPart.Position
                        local camPos = Camera.CFrame.Position
                        local distToCam = (worldPos - camPos).Magnitude

                        if distToCam <= AimbotState.MaxDistance then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
                            if onScreen then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local distanceToMouse = (screenVec - mousePos).Magnitude

                                if distanceToMouse < shortestDistance then
                                    if IsVisible(targetPart, character) then
                                        shortestDistance = distanceToMouse
                                        closestTarget = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function IsTargetValid(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local character = targetPart.Parent
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    local player = Players:GetPlayerFromCharacter(character)
    if player and AimbotState.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return false
    end

    local camPos = Camera.CFrame.Position
    if (targetPart.Position - camPos).Magnitude > AimbotState.MaxDistance then
        return false
    end

    if AimbotState.FOVEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then return false end
        local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distToMouse > AimbotState.FOV then return false end
    end

    if not IsVisible(targetPart, character) then return false end
    return true
end

local function AimAt(targetPart)
    if not targetPart then return end
    local targetPos = targetPart.Position
    if targetPart.Velocity then
        targetPos = targetPos + (targetPart.Velocity * AimbotState.Prediction)
    end
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, AimbotState.Smoothness)
end
-- Part 3/11
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    if FOVCircle then
        FOVCircle.Position = mousePos
        FOVCircle.Radius = AimbotState.FOV
        FOVCircle.Visible = AimbotState.FOVEnabled and (AimbotState.Enabled or AimbotState.MobileEnabled)
    end

    local isActive = false
    if AimbotState.Enabled then
        if AimbotState.HoldMouse2 then
            isActive = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        else
            isActive = true
        end
    elseif AimbotState.MobileEnabled then
        isActive = true
    end

    if isActive then
        if AimbotState.Sticky and AimbotState.Target then
            if not IsTargetValid(AimbotState.Target) then
                AimbotState.Target = GetClosestTarget()
            end
        else
            AimbotState.Target = GetClosestTarget()
        end

        if AimbotState.Target then
            AimAt(AimbotState.Target)

            if TargetTracer then
                local screenPos, onScreen = Camera:WorldToViewportPoint(AimbotState.Target.Position)
                if onScreen then
                    TargetTracer.From = mousePos
                    TargetTracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    TargetTracer.Visible = true
                else
                    TargetTracer.Visible = false
                end
            end
        else
            if TargetTracer then TargetTracer.Visible = false end
        end
    else
        AimbotState.Target = nil
        if TargetTracer then TargetTracer.Visible = false end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SynaxHubUI"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = Config.WindowSize
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Config.BgColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MakeDraggable(MainFrame)

local FrameCorner = Instance.new("UICorner", MainFrame)
FrameCorner.CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Config.SidebarColor
Sidebar.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner", Sidebar)
SidebarCorner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Synax Hub"
Title.TextColor3 = Config.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local Subtitle = Instance.new("TextLabel", Sidebar)
Subtitle.Size = UDim2.new(1, -20, 0, 15)
Subtitle.Position = UDim2.new(0, 10, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Universal Edition"
Subtitle.TextColor3 = Config.TextSecondary
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Size = UDim2.new(1, -10, 1, -100)
TabContainer.Position = UDim2.new(0, 5, 0, 55)
TabContainer.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout", TabContainer)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 3)

local UserCard = Instance.new("Frame", Sidebar)
UserCard.Size = UDim2.new(1, -10, 0, 36)
UserCard.Position = UDim2.new(0, 5, 1, -41)
UserCard.BackgroundColor3 = Config.ContainerColor
UserCard.BorderSizePixel = 0

local UserCardCorner = Instance.new("UICorner", UserCard)
UserCardCorner.CornerRadius = UDim.new(0, 6)

local UserAvatar = Instance.new("ImageLabel", UserCard)
UserAvatar.Size = UDim2.new(0, 26, 0, 26)
UserAvatar.Position = UDim2.new(0, 5, 0.5, -13)
UserAvatar.BackgroundTransparency = 1
UserAvatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", LocalPlayer.UserId)

local AvatarCorner = Instance.new("UICorner", UserAvatar)
AvatarCorner.CornerRadius = UDim.new(1, 0)

local UsernameLabel = Instance.new("TextLabel", UserCard)
UsernameLabel.Size = UDim2.new(1, -38, 0, 14)
UsernameLabel.Position = UDim2.new(0, 35, 0, 4)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.DisplayName
UsernameLabel.TextColor3 = Config.TextPrimary
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.TextSize = 10
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.ClipsDescendants = true

local UserTagLabel = Instance.new("TextLabel", UserCard)
UserTagLabel.Size = UDim2.new(1, -38, 0, 12)
UserTagLabel.Position = UDim2.new(0, 35, 0, 18)
UserTagLabel.BackgroundTransparency = 1
UserTagLabel.Text = "@" .. LocalPlayer.Name
UserTagLabel.TextColor3 = Config.TextSecondary
UserTagLabel.Font = Enum.Font.GothamMedium
UserTagLabel.TextSize = 9
UserTagLabel.TextXAlignment = Enum.TextXAlignment.Left
UserTagLabel.ClipsDescendants = true

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -160, 1, -10)
ContentArea.Position = UDim2.new(0, 155, 0, 5)
ContentArea.BackgroundTransparency = 1

local TopRightControls = Instance.new("Frame", ContentArea)
TopRightControls.Size = UDim2.new(0, 50, 0, 20)
TopRightControls.Position = UDim2.new(1, -55, 0, 5)
TopRightControls.BackgroundTransparency = 1
TopRightControls.ZIndex = 10

local TopControlsLayout = Instance.new("UIListLayout", TopRightControls)
TopControlsLayout.FillDirection = Enum.FillDirection.Horizontal
TopControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
TopControlsLayout.Padding = UDim.new(0, 6)

local MinimizeBtn = Instance.new("TextButton", TopRightControls)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.BackgroundColor3 = Config.ContainerColor
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Config.TextSecondary
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton", TopRightControls)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.BackgroundColor3 = Config.ContainerColor
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Config.CloseRed
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
-- Part 4/11
local Pages = {}

local function CreateTab(name, id)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Config.SidebarColor
    TabBtn.Text = "  " .. name
    TabBtn.TextColor3 = Config.TextSecondary
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, -10)
    Page.Position = UDim2.new(0, 0, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Config.TextSecondary
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    local PagePadding = Instance.new("UIPadding", Page)
    PagePadding.PaddingTop = UDim.new(0, 25)
    PagePadding.PaddingRight = UDim.new(0, 10)

    Pages[id] = {Button = TabBtn, Page = Page}

    TabBtn.MouseButton1Click:Connect(function()
        for _, tabData in pairs(Pages) do
            tabData.Button.BackgroundColor3 = Config.SidebarColor
            tabData.Button.TextColor3 = Config.TextSecondary
            tabData.Page.Visible = false
        end
        TabBtn.BackgroundColor3 = Config.ContainerColor
        TabBtn.TextColor3 = Config.Accent
        Page.Visible = true
    end)

    return Page
end

local MainTab = CreateTab("Main", "Main")
local VisualsTab = CreateTab("Visuals", "Visuals")
local CombatTab = CreateTab("Combat", "Combat")
local UtilityTab = CreateTab("Utility", "Utility")
local SettingsTab = CreateTab("Settings", "Settings")

Pages["Main"].Button.BackgroundColor3 = Config.ContainerColor
Pages["Main"].Button.TextColor3 = Config.Accent
Pages["Main"].Page.Visible = true

local function AddToggle(parent, text, default, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Config.ContainerColor
    Container.BorderSizePixel = 0
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBtn = Instance.new("TextButton", Container)
    ToggleBtn.Size = UDim2.new(0, 36, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -46, 0.5, -9)
    ToggleBtn.BackgroundColor3 = default and Config.HighlightText or Config.SidebarColor
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", ToggleBtn)
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Config.Accent
    Circle.BorderSizePixel = 0
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local state = default

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Config.HighlightText or Config.SidebarColor
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        callback(state)
    end)
end
-- Part 5/11
local function AddSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundColor3 = Config.ContainerColor
    Container.BorderSizePixel = 0
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(0.7, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", Container)
    ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Config.TextSecondary
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBar = Instance.new("Frame", Container)
    SliderBar.Size = UDim2.new(1, -20, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Config.SidebarColor
    SliderBar.BorderSizePixel = 0
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", SliderBar)
    local initRatio = (default - min) / (max - min)
    Fill.Size = UDim2.new(math.clamp(initRatio, 0, 1), 0, 1, 0)
    Fill.BackgroundColor3 = Config.HighlightText
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        callback(value)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function AddDropdown(parent, text, options, default, callback)
    local Container = Instance.new("Frame", parent)
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Config.ContainerColor
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local MainBtn = Instance.new("TextButton", Container)
    MainBtn.Size = UDim2.new(1, 0, 0, 35)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = ""

    local Label = Instance.new("TextLabel", MainBtn)
    Label.Size = UDim2.new(0.5, -10, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.TextPrimary
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SelectedLabel = Instance.new("TextLabel", MainBtn)
    SelectedLabel.Size = UDim2.new(0.5, -10, 1, 0)
    SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = default .. " ▼"
    SelectedLabel.TextColor3 = Config.HighlightText
    SelectedLabel.Font = Enum.Font.GothamBold
    SelectedLabel.TextSize = 11
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right

    local expanded = false
    local optionButtons = {}

    MainBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetSize = expanded and UDim2.new(1, 0, 0, 35 + (#options * 25)) or UDim2.new(1, 0, 0, 35)
        SelectedLabel.Text = default .. (expanded and " ▲" or " ▼")
        TweenService:Create(Container, TweenInfo.new(0.2), {Size = targetSize}):Play()
    end)

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton", Container)
        OptBtn.Size = UDim2.new(1, -20, 0, 22)
        OptBtn.Position = UDim2.new(0, 10, 0, 35 + ((i - 1) * 25))
        OptBtn.BackgroundColor3 = Config.SidebarColor
        OptBtn.Text = opt
        OptBtn.TextColor3 = Config.TextSecondary
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.TextSize = 11
        OptBtn.BorderSizePixel = 0
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

        OptBtn.MouseButton1Click:Connect(function()
            default = opt
            SelectedLabel.Text = default .. " ▼"
            expanded = false
            TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
            callback(opt)
        end)
    end
end
-- Part 6/11
local function AddInfoCard(parent, titleText, bodyText)
    local Card = Instance.new("Frame", parent)
    Card.Size = UDim2.new(1, 0, 0, 60)
    Card.BackgroundColor3 = Config.ContainerColor
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

    local CardTitle = Instance.new("TextLabel", Card)
    CardTitle.Size = UDim2.new(1, -20, 0, 20)
    CardTitle.Position = UDim2.new(0, 10, 0, 6)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = titleText
    CardTitle.TextColor3 = Config.HighlightText
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextSize = 12
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left

    local CardBody = Instance.new("TextLabel", Card)
    CardBody.Size = UDim2.new(1, -20, 0, 30)
    CardBody.Position = UDim2.new(0, 10, 0, 24)
    CardBody.BackgroundTransparency = 1
    CardBody.Text = bodyText
    CardBody.TextColor3 = Config.TextSecondary
    CardBody.Font = Enum.Font.GothamMedium
    CardBody.TextSize = 10
    CardBody.TextWrapped = true
    CardBody.TextXAlignment = Enum.TextXAlignment.Left
    CardBody.TextYAlignment = Enum.TextYAlignment.Top
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Config.ContainerColor
    Btn.Text = text
    Btn.TextColor3 = Config.TextPrimary
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.BorderSizePixel = 0
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Config.ContainerActive}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Config.ContainerColor}):Play()
        callback()
    end)
end

-- MAIN TAB CONTENT
AddInfoCard(MainTab, "Synax Hub Dashboard", "Welcome to Synax Hub Universal Script. Key bind: RightControl to toggle UI.")

local PingLabel, FPSLabel

local StatFrame = Instance.new("Frame", MainTab)
StatFrame.Size = UDim2.new(1, 0, 0, 45)
StatFrame.BackgroundColor3 = Config.ContainerColor
StatFrame.BorderSizePixel = 0
Instance.new("UICorner", StatFrame).CornerRadius = UDim.new(0, 6)

FPSLabel = Instance.new("TextLabel", StatFrame)
FPSLabel.Size = UDim2.new(0.5, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Config.Accent
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 13

PingLabel = Instance.new("TextLabel", StatFrame)
PingLabel.Size = UDim2.new(0.5, 0, 1, 0)
PingLabel.Position = UDim2.new(0.5, 0, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "Ping: -- ms"
PingLabel.TextColor3 = Config.Accent
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 13

local frameCount = 0
local lastCheck = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastCheck >= 1 then
        local fps = math.floor(frameCount / (now - lastCheck))
        FPSLabel.Text = "FPS: " .. tostring(fps)
        frameCount = 0
        lastCheck = now

        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        PingLabel.Text = "Ping: " .. tostring(ping) .. " ms"
    end
end)
-- Part 7/11
-- VISUALS TAB CONTENT
local function ClearDrawings(player)
    if ActiveDrawings[player] then
        for _, obj in pairs(ActiveDrawings[player]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
        ActiveDrawings[player] = nil
    end
end

local function ApplyGlow(character)
    if not character then return end
    local highlight = character:FindFirstChild("SynaxGlow")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "SynaxGlow"
        highlight.Parent = character
    end
    highlight.FillColor = HubSettings.GlowColor
    highlight.OutlineColor = HubSettings.GlowColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Enabled = HubSettings.GlowAllWhite
end

local function RemoveGlow(character)
    if not character then return end
    local highlight = character:FindFirstChild("SynaxGlow")
    if highlight then highlight:Destroy() end
end

AddToggle(VisualsTab, "White Glow (All Players)", HubSettings.GlowAllWhite, function(state)
    HubSettings.GlowAllWhite = state
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if state then
                ApplyGlow(player.Character)
            else
                RemoveGlow(player.Character)
            end
        end
    end
end)

AddToggle(VisualsTab, "Box ESP", HubSettings.BoxEsp, function(state)
    HubSettings.BoxEsp = state
end)

AddToggle(VisualsTab, "Health Bar ESP", HubSettings.HealthBar, function(state)
    HubSettings.HealthBar = state
end)

AddToggle(VisualsTab, "Target Lines (Tracers)", HubSettings.TargetLines, function(state)
    HubSettings.TargetLines = state
end)

AddToggle(VisualsTab, "Skeleton ESP", HubSettings.SkeletonEsp, function(state)
    HubSettings.SkeletonEsp = state
end)

AddToggle(VisualsTab, "Name & Distance ESP", HubSettings.NameDistanceEsp, function(state)
    HubSettings.NameDistanceEsp = state
end)

-- ESP Render Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if char and hrp and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    if HubSettings.GlowAllWhite then ApplyGlow(char) end

                    if not ActiveDrawings[player] then
                        ActiveDrawings[player] = {}
                    end

                    local drawings = ActiveDrawings[player]

                    -- Box ESP
                    if HubSettings.BoxEsp then
                        if not drawings.Box then
                            local box = Drawing.new("Square")
                            box.Thickness = 1.5
                            box.Color = Color3.fromRGB(255, 255, 255)
                            box.Filled = false
                            box.Visible = false
                            drawings.Box = box
                        end
                        local sizeY = (Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0)).Y)
                        local sizeX = sizeY / 1.8
                        drawings.Box.Size = Vector2.new(math.abs(sizeX), math.abs(sizeY))
                        drawings.Box.Position = Vector2.new(pos.X - math.abs(sizeX)/2, pos.Y - math.abs(sizeY)/2)
                        drawings.Box.Visible = true
                    elseif drawings.Box then
                        drawings.Box.Visible = false
                    end

                    -- Target Lines
                    if HubSettings.TargetLines then
                        if not drawings.Tracer then
                            local line = Drawing.new("Line")
                            line.Thickness = 1
                            line.Color = Color3.fromRGB(255, 255, 255)
                            drawings.Tracer = line
                        end
                        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
                        drawings.Tracer.Visible = true
                    elseif drawings.Tracer then
                        drawings.Tracer.Visible = false
                    end

                    -- Name & Distance
                    if HubSettings.NameDistanceEsp then
                        if not drawings.Text then
                            local txt = Drawing.new("Text")
                            txt.Size = 13
                            txt.Center = true
                            txt.Outline = true
                            txt.Color = Color3.fromRGB(255, 255, 255)
                            drawings.Text = txt
                        end
                        local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                        drawings.Text.Text = player.Name .. " [" .. tostring(dist) .. "m]"
                        drawings.Text.Position = Vector2.new(pos.X, pos.Y - 35)
                        drawings.Text.Visible = true
                    elseif drawings.Text then
                        drawings.Text.Visible = false
                    end

                else
                    ClearDrawings(player)
                end
            else
                ClearDrawings(player)
            end
        end
    end
end)
-- Part 8/11
-- COMBAT TAB CONTENT
AddToggle(CombatTab, "PC Aimbot (Hold RMB)", AimbotState.Enabled, function(state)
    AimbotState.Enabled = state
end)

AddToggle(CombatTab, "Mobile Aimbot (Always On)", AimbotState.MobileEnabled, function(state)
    AimbotState.MobileEnabled = state
end)

AddToggle(CombatTab, "Draw FOV Circle", AimbotState.FOVEnabled, function(state)
    AimbotState.FOVEnabled = state
end)

AddToggle(CombatTab, "Wall Check", AimbotState.WallCheck, function(state)
    AimbotState.WallCheck = state
end)

AddToggle(CombatTab, "Team Check", AimbotState.TeamCheck, function(state)
    AimbotState.TeamCheck = state
end)

AddToggle(CombatTab, "Sticky Target", AimbotState.Sticky, function(state)
    AimbotState.Sticky = state
end)

AddDropdown(CombatTab, "Target Part", {"Head", "HumanoidRootPart"}, AimbotState.TargetPart, function(selected)
    AimbotState.TargetPart = selected
end)

AddSlider(CombatTab, "Aimbot FOV", 30, 500, AimbotState.FOV, function(val)
    AimbotState.FOV = val
end)

AddSlider(CombatTab, "Smoothness (Low = Fast)", 1, 100, math.floor(AimbotState.Smoothness * 100), function(val)
    AimbotState.Smoothness = val / 100
end)

AddSlider(CombatTab, "Prediction", 0, 30, math.floor(AimbotState.Prediction * 100), function(val)
    AimbotState.Prediction = val / 100
end)

AddSlider(CombatTab, "Max Distance", 100, 5000, AimbotState.MaxDistance, function(val)
    AimbotState.MaxDistance = val
end)
-- Part 9/11
-- UTILITY TAB CONTENT
AddToggle(UtilityTab, "Noclip", HubSettings.Noclip, function(state)
    HubSettings.Noclip = state
    if state then
        UtilityState.NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if UtilityState.NoclipConnection then
            UtilityState.NoclipConnection:Disconnect()
            UtilityState.NoclipConnection = nil
        end
    end
end)

AddToggle(UtilityTab, "Infinite Jump", HubSettings.InfiniteJump, function(state)
    HubSettings.InfiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if HubSettings.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

AddToggle(UtilityTab, "Full Bright", HubSettings.FullBright, function(state)
    HubSettings.FullBright = state
    local Lighting = game:GetService("Lighting")
    if state then
        UtilityState.SavedLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        if UtilityState.SavedLighting then
            Lighting.Brightness = UtilityState.SavedLighting.Brightness
            Lighting.ClockTime = UtilityState.SavedLighting.ClockTime
            Lighting.FogEnd = UtilityState.SavedLighting.FogEnd
            Lighting.GlobalShadows = UtilityState.SavedLighting.GlobalShadows
            Lighting.Ambient = UtilityState.SavedLighting.Ambient
        end
    end
end)

AddSlider(UtilityTab, "WalkSpeed", 16, 250, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end)

AddSlider(UtilityTab, "JumpPower", 50, 300, 50, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = val
    end
end)
-- Part 10/11
-- SETTINGS TAB CONTENT
AddInfoCard(SettingsTab, "Community & Links", "Click below to copy our Discord or YouTube channel link directly to your clipboard.")

AddButton(SettingsTab, "Copy Discord Server Link", function()
    if setclipboard then
        setclipboard(Config.Discord)
    end
end)

AddButton(SettingsTab, "Copy YouTube Channel Link", function()
    if setclipboard then
        setclipboard(Config.YouTube)
    end
end)

AddButton(SettingsTab, "Unload UI & Reset", function()
    if FOVCircle then FOVCircle:Remove() end
    if TargetTracer then TargetTracer:Remove() end
    for p, _ in pairs(ActiveDrawings) do
        ClearDrawings(p)
    end
    if UtilityState.NoclipConnection then
        UtilityState.NoclipConnection:Disconnect()
    end
    ScreenGui:Destroy()
end)

-- MINIMIZE / CLOSE / KEYBIND
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 520, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        MainFrame:TweenSize(Config.WindowSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
-- Part 11/11
-- MOBILE TOGGLE BUTTON
local MobileToggle = Instance.new("ImageButton", ScreenGui)
MobileToggle.Name = "SynaxMobileToggle"
MobileToggle.Size = UDim2.new(0, 45, 0, 45)
MobileToggle.Position = UDim2.new(0, 15, 0.5, -22)
MobileToggle.BackgroundColor3 = Config.ContainerColor
MobileToggle.Image = "rbxassetid://6031097225"
MobileToggle.ImageColor3 = Config.Accent
MobileToggle.BorderSizePixel = 0
MobileToggle.ZIndex = 100
MakeDraggable(MobileToggle)

local MobileCorner = Instance.new("UICorner", MobileToggle)
MobileCorner.CornerRadius = UDim.new(1, 0)

local MobileStroke = Instance.new("UIStroke", MobileToggle)
MobileStroke.Color = Config.HighlightText
MobileStroke.Thickness = 1.5

MobileToggle.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- PLAYER REMOVAL CLEANUP
Players.PlayerRemoving:Connect(function(player)
    ClearDrawings(player)
end)
