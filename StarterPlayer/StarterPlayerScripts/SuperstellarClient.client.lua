local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("SuperstellarEvent")
local cooldownEndsAt = 0
local cooldownDuration = 15

local gui = Instance.new("ScreenGui")
gui.Name = "SuperstellarHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.fromOffset(280, 46)
title.Position = UDim2.fromOffset(24, 22)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.Text = "SUPERSTELLAR"
title.TextColor3 = Color3.fromRGB(125, 227, 255)
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = gui

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.fromOffset(320, 24)
subtitle.Position = UDim2.fromOffset(26, 62)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Collect stardust. Ignite your power."
subtitle.TextColor3 = Color3.fromRGB(196, 211, 255)
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = gui

local counter = Instance.new("TextLabel")
counter.Name = "StardustCounter"
counter.Size = UDim2.fromOffset(190, 48)
counter.Position = UDim2.new(1, -214, 0, 28)
counter.BackgroundColor3 = Color3.fromRGB(20, 26, 62)
counter.BackgroundTransparency = 0.12
counter.Font = Enum.Font.GothamBold
counter.TextColor3 = Color3.fromRGB(255, 236, 125)
counter.TextSize = 20
counter.Text = "✦  STARDUST  0"
counter.Parent = gui

local counterCorner = Instance.new("UICorner")
counterCorner.CornerRadius = UDim.new(0, 10)
counterCorner.Parent = counter

local ability = Instance.new("TextButton")
ability.Name = "AbilityButton"
ability.Size = UDim2.fromOffset(230, 62)
ability.Position = UDim2.new(0.5, -115, 1, -92)
ability.BackgroundColor3 = Color3.fromRGB(54, 178, 220)
ability.Font = Enum.Font.GothamBold
ability.TextColor3 = Color3.fromRGB(255, 255, 255)
ability.TextSize = 17
ability.Text = "✦  SUPERNOVA [Q]"
ability.AutoButtonColor = true
ability.Parent = gui

local abilityCorner = Instance.new("UICorner")
abilityCorner.CornerRadius = UDim.new(0, 12)
abilityCorner.Parent = ability

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.Size = UDim2.fromOffset(300, 24)
hint.Position = UDim2.new(0.5, -150, 1, -122)
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.Gotham
hint.TextColor3 = Color3.fromRGB(196, 211, 255)
hint.TextSize = 13
hint.Text = "Dash through the stars"
hint.Parent = gui

local function updateCounter()
    local stats = player:FindFirstChild("leaderstats")
    local stardust = stats and stats:FindFirstChild("Stardust")
    if stardust then
        counter.Text = "✦  STARDUST  " .. stardust.Value
    end
end

local function refreshAbility()
    local remaining = math.max(0, cooldownEndsAt - os.clock())
    if remaining > 0 then
        ability.Text = string.format("✦  READY IN %ds", math.ceil(remaining))
        ability.BackgroundColor3 = Color3.fromRGB(65, 83, 122)
        ability.Active = false
    else
        ability.Text = "✦  SUPERNOVA [Q]"
        ability.BackgroundColor3 = Color3.fromRGB(54, 178, 220)
        ability.Active = true
    end
end

local function activate()
    if os.clock() >= cooldownEndsAt then
        remote:FireServer("Activate")
    end
end

ability.Activated:Connect(activate)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Q then
        activate()
    end
end)

remote.OnClientEvent:Connect(function(eventName, succeeded, value)
    if eventName ~= "AbilityResult" then
        return
    end
    if succeeded then
        cooldownDuration = value
        cooldownEndsAt = os.clock() + value
        refreshAbility()
    else
        cooldownEndsAt = os.clock() + (value or 1)
        refreshAbility()
    end
end)

local stats = player:WaitForChild("leaderstats")
local stardust = stats:WaitForChild("Stardust")
stardust:GetPropertyChangedSignal("Value"):Connect(updateCounter)
updateCounter()

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    ability.Text = "✦  SUPERNOVA"
end

while gui.Parent do
    refreshAbility()
    task.wait(0.2)
end
