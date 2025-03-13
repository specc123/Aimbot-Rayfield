-- Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Aimbot + ESP",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Made by specc",
    ConfigurationSaving = { Enabled = false }
})

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local AimEnabled = false
local TargetPart = "Head"
local ESPEnabled = false
local FOV = 100

-- Create Sections
local AimbotTab = Window:CreateTab("Aimbot")
local ESPTab = Window:CreateTab("ESP")

-- Aimbot Toggle
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimEnabled = Value
    end
})

-- Target Part Selection
AimbotTab:CreateDropdown({
    Name = "Aim at",
    Options = {"Head", "Torso"},
    CurrentOption = "Head",
    Callback = function(Option)
        TargetPart = Option
    end
})

-- FOV Size Slider
AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(Value)
        FOV = Value
    end
})

-- ESP Toggle
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.Adornee = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    player.CharacterAdded:Connect(function(char)
                        highlight.Parent = char
                        highlight.Adornee = char
                    end)
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, v in pairs(player.Character:GetChildren()) do
                        if v:IsA("Highlight") then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end
})

-- FOV Circle (Fixed in the Center)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOV
end)

-- Aimbot Function
RunService.RenderStepped:Connect(function()
    if AimEnabled then
        local closestTarget = nil
        local shortestDistance = FOV

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(TargetPart) then
                local part = player.Character[TargetPart]
                local screenPosition, onScreen = Camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestTarget = part
                    end
                end
            end
        end

        if closestTarget then
            mousemoverel((closestTarget.Position.X - Camera.CFrame.Position.X) * 3, (closestTarget.Position.Y - Camera.CFrame.Position.Y) * 3)
        end
    end
end)
