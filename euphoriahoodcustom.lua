getgenv().CrackThis = {
    Aiming = {
        Enabled = true,
        PredictionX = 0.04,
        PredictionY = 0.08,
        AntiGroundShots = true,
        AutoAir = true,
        LookAt = true
    }
}

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = Player:GetMouse()
local Workspace = game:GetService("Workspace")
local Target = nil
local TargetPart = Target and Target.Character and Target.Character:FindFirstChild("Head")

local Enabled = false

local function AntiGround(Velocity)
    return Vector3.new(Velocity.Y * CrackThis.Aiming.PredictionY, -0.988392, math.huge)
end

local function Predictions(TargetPart)
    if not TargetPart then return Vector3.new(0, 0, 0) end
    local velocity = TargetPart.AssemblyLinearVelocity
    return Vector3.new(
        velocity.X * getgenv().CrackThis.Aiming.PredictionX,
        velocity.Y * getgenv().CrackThis.Aiming.PredictionY,
        velocity.Z * getgenv().CrackThis.Aiming.PredictionX
    )
end

local function RemoveAppearanceForAllPlayers()
    for _, player in ipairs(game.Players:GetPlayers()) do
        local Character = player.Character or player.CharacterAdded:Wait()
        for _, accessory in pairs(Character:GetChildren()) do
            if accessory:IsA("Accessory") or accessory:IsA("Hair") then
                accessory:Destroy()
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    RemoveAppearanceForAllPlayers()
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        RemoveAppearanceForAllPlayers()
    end)
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aimlocking GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 0
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Enabled = true
ScreenGui.Parent = Player.PlayerGui

local TextButton = Instance.new("TextButton")
TextButton.Name = "Target Selecter"
TextButton.Text = 'Euphoria:\n<font color="rgb(255,0,0)" size="22">OFF</font>'
TextButton.Font = Enum.Font.GothamBold
TextButton.TextSize = 20
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextTransparency = 0
TextButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextStrokeTransparency = 1
TextButton.TextScaled = false
TextButton.RichText = true
TextButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TextButton.BackgroundTransparency = 0
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Size = UDim2.new(0, 110, 0, 55)
TextButton.Position = UDim2.new(0.5, 0, 0.15, 0)
TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
TextButton.AutoButtonColor = true
TextButton.Modal = false
TextButton.Selected = false
TextButton.ClipsDescendants = false
TextButton.Draggable = true
TextButton.Active = true
TextButton.Rotation = 0
TextButton.SizeConstraint = Enum.SizeConstraint.RelativeXY
TextButton.Visible = true
TextButton.ZIndex = 1
TextButton.LayoutOrder = 0
TextButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.Name = "UICorner"
UICorner.CornerRadius = UDim.new(0.15, 0)
UICorner.Parent = TextButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "UIStroke"
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(10, 10, 10)
UIStroke.Transparency = 0
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = TextButton

local function FindNearestEnemy()
    local ClosestDistance, ClosestPlayer, ClosestPart = math.huge, nil, nil
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= Player then
            local Character = player.Character
            if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local Part = Character:FindFirstChild("Head")
                if Part then
                    local Position, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    local DistanceFromCenter = (Vector2.new(Position.X, Position.Y) - ScreenCenter).Magnitude

                    if OnScreen and DistanceFromCenter < ClosestDistance then
                        ClosestPlayer = player
                        ClosestPart = Part
                        ClosestDistance = DistanceFromCenter
                    end
                end
            end
        end
    end

    return ClosestPlayer, ClosestPart
end

local function highlight(Target)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetChildren()) do
                if obj:IsA("Highlight") then
                    obj:Destroy()
                end
            end
        end
    end

    if Target and Target.Character then
        local highlight = Instance.new("Highlight")
        highlight.Parent = Target.Character
        highlight.FillColor = Color3.fromRGB(8, 0, 255)
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
    end
end

TextButton.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    TextButton.Text = Enabled and "EuphoriaV2 On" or "EuphoriaV2 Off"

    if Enabled then
        Target, TargetPart = FindNearestEnemy()
        if Target then
            highlight(Target)
        end
    else
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, obj in ipairs(player.Character:GetChildren()) do
                    if obj:IsA("Highlight") then
                        obj:Destroy()
                    end
                end
            end
        end
        Target, TargetPart = nil, nil
    end
end)

if game.PlaceId == 9825515356 then
    local LocalFramework = Player.PlayerGui:WaitForChild("Framework")
    local FrameworkEnvironment

    if LocalFramework then
        FrameworkEnvironment = getsenv(LocalFramework)
    end

    local function TargetFuturePosition()
        if not TargetPart then return Vector3.new(0, 0, 0) end
        local velocity = TargetPart.AssemblyLinearVelocity
        return TargetPart.Position + velocity * getgenv().CrackThis.Aiming.PredictionX
    end

    RunService.PostSimulation:Connect(function(DeltaTime)
        if getgenv().CrackThis.Aiming.Enabled and FrameworkEnvironment and TargetPart then
            FrameworkEnvironment._G.MOUSE_POSITION = TargetFuturePosition()
        end
    end)
end

local UserInputService = game:GetService("UserInputService")
local BASEPLATE = game.Workspace.Map:FindFirstChild("BASEPLATE")

local baseplate = nil
local baseplateEnabled = false
local velocityConnection = nil
local rotationConnection = nil

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.X then
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

        if baseplateEnabled then
            if baseplate then
                baseplate:Destroy()
                baseplate = nil
            end
            BASEPLATE.CanCollide = true
            baseplateEnabled = false

            if velocityConnection then
                velocityConnection:Disconnect()
                velocityConnection = nil
            end
            if rotationConnection then
                rotationConnection:Disconnect()
                rotationConnection = nil
            end
        else
            baseplate = Instance.new("Part")
            baseplate.Size = Vector3.new(420, 1.95, 420)
            baseplate.Position = Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y - 10, humanoidRootPart.Position.Z)
            baseplate.Anchored = true
            baseplate.CanCollide = true
            baseplate.Parent = workspace
            baseplate.Transparency = 1
            BASEPLATE.CanCollide = false
            baseplateEnabled = true

            velocityConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local Velocity = game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(500, 500, 500)
                game:GetService("RunService").RenderStepped:Wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Velocity
            end)

            rotationConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local Rotation = game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity
                game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(500, 500, 500)
                game:GetService("RunService").RenderStepped:Wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity = Rotation
            end)
        end
    end
end)
