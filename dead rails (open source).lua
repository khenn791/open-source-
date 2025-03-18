-- NO UPDATE :)
-- open source 
-- no fix
-- you can edit if want but credit me :'((((((
-- https://discord.gg/UgQAPcBtpy
-- https://discord.gg/UgQAPcBtpy

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/khenn791/library/refs/heads/main/obf_fx871Q5U6LWRkUHL0xyelc7AdP37t6z6N61K79BfulGV293LM73n9T8vDnQs5s5w.lua.txt"))()

local Window = WindUI:CreateWindow({
    Title = "khen.cc | Dead Rails",
    Icon = "target",
    Author = "by khen.cc",
    Folder = "DeadRails",
    Size = UDim2.fromOffset(300, 200),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 120,
})

local Tabs = {
    AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair", Desc = "Aimbot settings." }),
    BringsTab = Window:Tab({ Title = "Brings", Icon = "box", Desc = "Item teleportation." }),
    ESPTab = Window:Tab({ Title = "ESP", Icon = "eyes", Desc = "Visual enhancements." }),
    MovementTab = Window:Tab({ Title = "Movement", Icon = "user", Desc = "Player movement tweaks." }),
    ReportTab = Window:Tab({ Title = "Report Bugs", Icon = "bug", Desc = "Report issues." }),
}

Window:SelectTab(1)

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Aimbot Variables
local validNPCs = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Transparency = 1
fovCircle.Filled = false
local fovRadius = 100
local aimbotEnabled = false
local aimbotKey = Enum.UserInputType.MouseButton2

-- ESP Variables (Old)
local ESPHandles = {}
local ESPEnabled = false

-- ESP Variables (New)
local ESPPlayerEnabled = false
local ESPZombyEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)

-- Movement Variables (Old)
local speedHackEnabled = false
local speedValue = 16
local jumpHackEnabled = false
local jumpMultiplier = 1.5
local noClipEnabled = false

-- Movement Variables (New)
local infiniteJumpEnabled = false
local flyEnabled = false

-- Helper Functions
local function updateFOV()
    fovCircle.Radius = fovRadius
    fovCircle.Position = Cam.ViewportSize / 2
end

local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("Head")
        and obj:FindFirstChild("HumanoidRootPart")
        and not Players:GetPlayerFromCharacter(obj)
end

local function updateNPCs()
    local tempTable = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
            tempTable[obj] = true
        end
    end
    for i = #validNPCs, 1, -1 do
        if not tempTable[validNPCs[i]] then
            table.remove(validNPCs, i)
        end
    end
    for obj in pairs(tempTable) do
        if not table.find(validNPCs, obj) then
            table.insert(validNPCs, obj)
        end
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if isNPC(descendant) then
        table.insert(validNPCs, descendant)
        local humanoid = descendant:WaitForChild("Humanoid")
        humanoid.Destroying:Connect(function()
            for i = #validNPCs, 1, -1 do
                if validNPCs[i] == descendant then
                    table.remove(validNPCs, i)
                    break
                end
            end
        end)
    end
end)

workspace.DescendantRemoving:Connect(function(descendant)
    if isNPC(descendant) then
        for i = #validNPCs, 1, -1 do
            if validNPCs[i] == descendant then
                table.remove(validNPCs, i)
                break
            end
        end
    end
end)

local function predictPos(target)
    local rootPart = target:FindFirstChild("HumanoidRootPart")
    local head = target:FindFirstChild("Head")
    if not rootPart or not head then
        return head and head.Position or rootPart and rootPart.Position
    end
    local velocity = rootPart.Velocity
    local predictionTime = 0.02
    local basePosition = rootPart.Position + velocity * predictionTime
    local headOffset = head.Position - rootPart.Position
    return basePosition + headOffset
end

local function getTarget()
    local nearest = nil
    local minDistance = math.huge
    local viewportCenter = Cam.ViewportSize / 2
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    for _, npc in ipairs(validNPCs) do
        local predictedPos = predictPos(npc)
        local screenPos, visible = Cam:WorldToViewportPoint(predictedPos)
        if visible and screenPos.Z > 0 then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
            if distance <= fovRadius then
                local ray = workspace:Raycast(
                    Cam.CFrame.Position,
                    (predictedPos - Cam.CFrame.Position).Unit * 1000,
                    raycastParams
                )
                if ray and ray.Instance:IsDescendantOf(npc) then
                    if distance < minDistance then
                        minDistance = distance
                        nearest = npc
                    end
                end
            end
        end
    end
    return nearest
end

local function aim(targetPosition)
    local currentCF = Cam.CFrame
    local targetDirection = (targetPosition - currentCF.Position).Unit
    local smoothFactor = 0.581
    local newLookVector = currentCF.LookVector:Lerp(targetDirection, smoothFactor)
    Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
end

local function CreateESP(object, color)
    if not object or not object.PrimaryPart then return end
    if ESPHandles[object] then return end 

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = object.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = object.Name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = color
    textLabel.BackgroundTransparency = 1
    textLabel.TextSize = 7
    textLabel.Parent = billboard

    ESPHandles[object] = {Highlight = highlight, Billboard = billboard, Color = color}
end

local function ClearESP()
    for obj, handles in pairs(ESPHandles) do
        if handles.Highlight then handles.Highlight:Destroy() end
        if handles.Billboard then handles.Billboard:Destroy() end
        ESPHandles[obj] = nil
    end
end

local function UpdateESP()
    ClearESP()
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                CreateESP(item, Color3.new(1, 0, 0))
            end
        end
    end
    local nightEnemies = workspace:FindFirstChild("NightEnemies")
    if nightEnemies then
        for _, enemy in ipairs(nightEnemies:GetDescendants()) do
            if enemy:IsA("Model") then
                CreateESP(enemy, Color3.new(0, 0, 1))
            end
        end
    end
end

local function AutoUpdateESP()
    while ESPEnabled do
        UpdateESP()
        wait()
    end
end

local function AddESPForPlayer(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or player == LocalPlayer then return end
    local character = player.Character
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local espFrame = Instance.new("BillboardGui")
    espFrame.Parent = character
    espFrame.Adornee = humanoidRootPart
    espFrame.Size = UDim2.new(0, 100, 0, 40)
    espFrame.StudsOffset = Vector3.new(0, 3, 0)
    espFrame.AlwaysOnTop = true
    espFrame.Name = "ESPFrame"
    local frame = Instance.new("Frame")
    frame.Parent = espFrame
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    local healthText = Instance.new("TextLabel")
    healthText.Parent = frame
    healthText.Size = UDim2.new(1, 0, 0.3, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextSize = 10
    healthText.Text = "Health: " .. math.floor(humanoid.Health)
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        healthText.Text = "Health: " .. math.floor(humanoid.Health)
    end)
end

local function AddESPForEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end
    local character = enemy
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local espFrame = Instance.new("BillboardGui")
    espFrame.Parent = character
    espFrame.Adornee = humanoidRootPart
    espFrame.Size = UDim2.new(0, 100, 0, 40)
    espFrame.StudsOffset = Vector3.new(0, 3, 0)
    espFrame.AlwaysOnTop = true
    espFrame.Name = "ESPFrame"
    local frame = Instance.new("Frame")
    frame.Parent = espFrame
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    local healthText = Instance.new("TextLabel")
    healthText.Parent = frame
    healthText.Size = UDim2.new(1, 0, 0.3, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = ESPColor
    healthText.TextSize = 10
    healthText.Text = "Health: " .. math.floor(humanoid.Health)
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        healthText.Text = "Health: " .. math.floor(humanoid.Health)
    end)
end

local function GetItemNames()
    local items = {}
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                table.insert(items, item.Name)
            end
        end
    end
    return items
end

local function applySpeedHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedHackEnabled and speedValue or 16
    end
end

local function applyJumpHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if humanoid:FindFirstChild("JumpHeight") then
            humanoid.JumpHeight = jumpHackEnabled and (7.2 * jumpMultiplier) or 7.2
        end
    end
end

local function applyNoClip()
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noClipEnabled
            end
        end
    end
end

-- Main Loop
local lastUpdate = 0
local UPDATE_INTERVAL = 0.4

RunService.Heartbeat:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    if lastUpdate >= UPDATE_INTERVAL then
        updateNPCs()
        lastUpdate = 0
    end
    if aimbotEnabled then
        local target = getTarget()
        if target then
            local predictedPosition = predictPos(target)
            aim(predictedPosition)
        end
    end
    if ESPPlayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("ESPFrame") then
                AddESPForPlayer(player)
            end
        end
    end
    if ESPZombyEnabled then
        for _, enemy in pairs(workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(enemy) and not enemy:FindFirstChild("ESPFrame") then
                AddESPForEnemy(enemy)
            end
        end
    end
    if infiniteJumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if noClipEnabled then
        applyNoClip()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == aimbotKey then
        aimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimbotKey then
        aimbotEnabled = false
    end
end)

-- Aimbot Tab
Tabs.AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        aimbotEnabled = Value
        fovCircle.Visible = Value
    end
})

Tabs.AimbotTab:Slider({
    Title = "FOV Radius",
    Default = 100,
    Min = 50,
    Max = 500,
    Callback = function(Value)
        fovRadius = Value
        updateFOV()
    end
})

updateFOV()

-- Brings Tab
local selectedItem = "Select an item"
Tabs.BringsTab:Dropdown({
    Title = "Choose Item",
    Options = GetItemNames(),
    Default = "Select an item",
    Callback = function(Value)
        selectedItem = Value
    end
})

Tabs.BringsTab:Button({
    Title = "Refresh Items",
    Callback = function()
        Tabs.BringsTab:Dropdown({
            Title = "Choose Item",
            Options = GetItemNames(),
            Default = selectedItem,
            Callback = function(Value)
                selectedItem = Value
            end
        })
    end
})

Tabs.BringsTab:Button({
    Title = "Collect Selected Item",
    Callback = function()
        if selectedItem == "Select an item" then return end
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return end
        local itemToCollect
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.Name == selectedItem then
                itemToCollect = item
                break
            end
        end
        if itemToCollect and itemToCollect.PrimaryPart then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            itemToCollect:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0))
        end
    end
})

Tabs.BringsTab:Button({
    Title = "Collect All Items",
    Callback = function()
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.PrimaryPart then
                local offset = hrp.CFrame.LookVector * 5
                item:SetPrimaryPartCFrame(hrp.CFrame + offset)
            end
        end
    end
})

-- ESP Tab
Tabs.ESPTab:Toggle({
    Title = "ESP Items and Mobs",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            UpdateESP()
            coroutine.wrap(AutoUpdateESP)()
        else
            ClearESP()
        end
    end
})

Tabs.ESPTab:Toggle({
    Title = "ESP Players",
    Default = false,
    Callback = function(Value)
        ESPPlayerEnabled = Value
    end
})

Tabs.ESPTab:Toggle({
    Title = "ESP Zombies",
    Default = false,
    Callback = function(Value)
        ESPZombyEnabled = Value
    end
})

-- Movement Tab
Tabs.MovementTab:Slider({
    Title = "WalkSpeed",
    Default = 50,
    Min = 1,
    Max = 500,
    Callback = function(Value)
        speedValue = Value
        applySpeedHack()
    end
})

Tabs.MovementTab:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(Value)
        speedHackEnabled = Value
        applySpeedHack()
    end
})

Tabs.MovementTab:Slider({
    Title = "Jump Height",
    Default = 50,
    Min = 10,
    Max = 500,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpHeight = Value
        end
    end
})

Tabs.MovementTab:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end
})

Tabs.MovementTab:Toggle({
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if Value then
            local speed = 50
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
            bodyVelocity.Velocity = Vector3.new(0, speed, 0)
            bodyVelocity.Parent = hrp
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
            spawn(function()
                while flyEnabled and hrp do
                    bodyVelocity.Velocity = Vector3.new(0, speed, 0)
                    wait(0.1)
                end
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
            end)
        else
            local bodyVelocity = hrp:FindFirstChildOfClass("BodyVelocity")
            local bodyGyro = hrp:FindFirstChildOfClass("BodyGyro")
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end
})

Tabs.MovementTab:Toggle({
    Title = "Jump Hack",
    Default = false,
    Callback = function(Value)
        jumpHackEnabled = Value
        applyJumpHack()
    end
})

Tabs.MovementTab:Slider({
    Title = "Jump Power Multiplier",
    Default = 1.5,
    Min = 1,
    Max = 5,
    Callback = function(Value)
        jumpMultiplier = Value
        applyJumpHack()
    end
})

Tabs.MovementTab:Toggle({
    Title = "NoClip",
    Default = false,
    Callback = function(Value)
        noClipEnabled = Value
    end
})

