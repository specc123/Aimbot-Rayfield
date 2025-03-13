-- Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "My Script",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By specc",
    ConfigurationSaving = { Enabled = false }
})

-- Create Tabs
local MainTab = Window:CreateTab("Main")
local ESPTab = Window:CreateTab("ESP")
local ServerTab = Window:CreateTab("Server")
local MiscTab = Window:CreateTab("Misc")

---------------------
-- Main Features --
---------------------

-- Aura Kill (Instant Kill, Only NPCs, Ignores Players)
local auraEnabled = false
local auraRadius = 10

MainTab:CreateSlider({
    Name = "Aura Kill Radius",
    Min = 5,
    Max = 50,
    Default = 10,
    Callback = function(Value) auraRadius = Value end
})

MainTab:CreateToggle({
    Name = "Aura Kill",
    Callback = function(state)
        auraEnabled = state
        while auraEnabled do
            task.wait(0.5)
            for _, enemy in ipairs(workspace:GetDescendants()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                    local isPlayer = game.Players:GetPlayerFromCharacter(enemy) -- Check if it's a player
                    if not isPlayer then -- Only kill NPCs
                        local distance = (enemy.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= auraRadius then
                            enemy.Humanoid.Health = 0 -- Instantly kills the NPC
                        end
                    end
                end
            end
        end
    end
})

-- Aimbot (Fixed, Smooth Aim)
local aimEnabled = false
local aimPart = "Head"

MainTab:CreateDropdown({
    Name = "Aimbot Target",
    Options = {"Head", "Torso"},
    Callback = function(Selected) aimPart = Selected end
})

MainTab:CreateToggle({
    Name = "Aimbot",
    Callback = function(state)
        aimEnabled = state
        local RunService = game:GetService("RunService")
        
        RunService.RenderStepped:Connect(function()
            if aimEnabled then
                local target, minDist = nil, math.huge
                for _, enemy in ipairs(workspace:GetDescendants()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild(aimPart) then
                        local screenPoint, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(enemy[aimPart].Position)
                        local cursorPos = game.Players.LocalPlayer:GetMouse().Hit.p
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(cursorPos.X, cursorPos.Y)).Magnitude
                        if onScreen and distance < 100 and distance < minDist then
                            minDist = distance
                            target = enemy
                        end
                    end
                end
                if target then
                    local playerHRP = game.Players.LocalPlayer.Character.HumanoidRootPart
                    local lookAt = CFrame.lookAt(playerHRP.Position, target[aimPart].Position)
                    playerHRP.CFrame = playerHRP.CFrame:Lerp(lookAt, 0.2) -- Smooth aim effect
                end
            end
        end)
    end
})

-- Noclip
MainTab:CreateToggle({
    Name = "Noclip",
    Callback = function(state)
        while state do
            task.wait()
            for _, part in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end
    end
})

---------------
-- ESP Features --
---------------

local function createESP(target, color)
    local esp = Instance.new("BillboardGui", target)
    esp.Size = UDim2.new(0, 100, 0, 50)
    esp.AlwaysOnTop = true
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = target.Name
    label.TextColor3 = color
    return esp
end

ESPTab:CreateToggle({
    Name = "Player ESP",
    Callback = function(state)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                createESP(player.Character.Head, Color3.fromRGB(0, 255, 0))
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Mob ESP",
    Callback = function(state)
        for _, enemy in ipairs(game.Workspace.Enemies:GetChildren()) do
            createESP(enemy.Head, Color3.fromRGB(255, 0, 0))
        end
    end
})

ESPTab:CreateToggle({
    Name = "Item ESP",
    Callback = function(state)
        for _, item in ipairs(game.Workspace.Items:GetChildren()) do
            createESP(item, Color3.fromRGB(0, 0, 255))
        end
    end
})

---------------
-- Server Features --
---------------

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

ServerTab:CreateButton({
    Name = "Rejoin Last Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

---------------
-- Misc Features --
---------------

MiscTab:CreateButton({
    Name = "Reduce Lag",
    Callback = function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Explosion") then
                v:Destroy()
            end
        end
    end
})

MiscTab:CreateButton({
    Name = "Boost FPS",
    Callback = function()
        setfpscap(1000)
    end
})

local itemRange = 10
MiscTab:CreateSlider({
    Name = "Bring Items Range",
    Min = 5,
    Max = 50,
    Default = 10,
    Callback = function(Value) itemRange = Value end
})

MiscTab:CreateButton({
    Name = "Bring Items",
    Callback = function()
        for _, item in ipairs(game.Workspace.Items:GetChildren()) do
            if item:IsA("BasePart") and not item.Anchored and (item.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= itemRange then
                item.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end
})
