-- Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Aimbot + ESP",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Made by specc",
    ConfigurationSaving = { Enabled = false }
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game.Workspace.CurrentCamera

-- Variables
local AimEnabled = false
local TargetPart = "Head"
local ESPEnabled = false
local FOV = 100
local IsMobile = UserInputService.TouchEnabled -- Detects if user is on mobile

-- Create Tabs
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

-- FOV Circle (Fixed in Center)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.Filled = false

-- FOV Size Slider (Updates Circle)
AimbotTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(Value)
        FOV = Value
        FOVCircle.Radius = FOV
    end
})

-- Function to Apply ESP to a Character
local function applyESP(player)
    if player ~= LocalPlayer and ESPEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        
        -- Reapply ESP when character respawns
        player.CharacterAdded:Connect(function(char)
            highlight.Parent = char
            highlight.Adornee = char
        end)
    end
end

-- ESP Toggle Button
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        
        -- Loop through all players and apply ESP
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                applyESP(player)
            end
            
            -- Apply ESP when a new player joins
            player.CharacterAdded:Connect(function()
                applyESP(player)
            end)
        end
    end
})

-- Update FOV Circle Position
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Aimbot Function (PC & Mobile)
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
            local direction = (closestTarget.Position - Camera.CFrame.Position).Unit
            if IsMobile then
                -- Mobile: Instant Lock-On
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)
            else
                -- PC: Smooth Lock-On
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction), 0.15)
            end
        end
    end
end)
