local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REMOTE_NAME = "SuperstellarEvent"
local ORB_COUNT = 18
local ABILITY_COOLDOWN = 15
local DASH_SPEED = 90
local DASH_LIFT = 28

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = REMOTE_NAME
    remote.Parent = ReplicatedStorage
end

local arena = workspace:FindFirstChild("SuperstellarArena")
if arena then
    arena:Destroy()
end
arena = Instance.new("Folder")
arena.Name = "SuperstellarArena"
arena.Parent = workspace

local function makePart(name, size, position, color, material, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local platform = makePart(
    "StarlightPlatform",
    Vector3.new(180, 4, 180),
    Vector3.new(0, -2, 0),
    Color3.fromRGB(20, 26, 62),
    Enum.Material.Slate,
    arena
)
platform.Shape = Enum.PartType.Cylinder
platform.Orientation = Vector3.new(0, 0, 90)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "StellarSpawn"
spawn.Size = Vector3.new(10, 1, 10)
spawn.Position = Vector3.new(0, 1, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(105, 220, 255)
spawn.Parent = arena

for index = 1, 12 do
    local angle = (math.pi * 2 / 12) * index
    local x = math.cos(angle) * 73
    local z = math.sin(angle) * 73
    local pillar = makePart(
        "StarPillar",
        Vector3.new(4, math.random(8, 22), 4),
        Vector3.new(x, 0, z),
        Color3.fromRGB(52, 93, 164),
        Enum.Material.Neon,
        arena
    )
    pillar.Transparency = 0.25
end

local random = Random.new()
local function spawnOrb()
    local x = random:NextNumber(-70, 70)
    local z = random:NextNumber(-70, 70)
    local orb = Instance.new("Part")
    orb.Name = "Stardust"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(2.5, 2.5, 2.5)
    orb.Position = Vector3.new(x, 3.5, z)
    orb.Anchored = true
    orb.CanCollide = false
    orb.Material = Enum.Material.Neon
    orb.Color = Color3.fromRGB(255, 229, 91)
    orb.Parent = arena

    local light = Instance.new("PointLight")
    light.Color = orb.Color
    light.Brightness = 1.5
    light.Range = 12
    light.Parent = orb

    local sparkles = Instance.new("Sparkles")
    sparkles.SparkleColor = Color3.fromRGB(255, 255, 190)
    sparkles.Parent = orb

    local claimed = false
    orb.Touched:Connect(function(hit)
        if claimed then
            return
        end
        local character = hit:FindFirstAncestorOfClass("Model")
        local player = character and Players:GetPlayerFromCharacter(character)
        local stats = player and player:FindFirstChild("leaderstats")
        local stardust = stats and stats:FindFirstChild("Stardust")
        if not stardust then
            return
        end

        claimed = true
        stardust.Value += 1
        orb:Destroy()
        task.delay(3, function()
            if arena.Parent then
                spawnOrb()
            end
        end)
    end)
end

for _ = 1, ORB_COUNT do
    spawnOrb()
end

local cooldowns = {}
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local stardust = Instance.new("IntValue")
    stardust.Name = "Stardust"
    stardust.Value = 0
    stardust.Parent = leaderstats
end)

Players.PlayerRemoving:Connect(function(player)
    cooldowns[player] = nil
end)

remote.OnServerEvent:Connect(function(player, action)
    if action ~= "Activate" then
        return
    end

    local now = os.clock()
    local readyAt = cooldowns[player] or 0
    if now < readyAt then
        remote:FireClient(player, "AbilityResult", false, math.ceil(readyAt - now))
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then
        remote:FireClient(player, "AbilityResult", false, 1)
        return
    end

    cooldowns[player] = now + ABILITY_COOLDOWN
    root.AssemblyLinearVelocity = root.CFrame.LookVector * DASH_SPEED + Vector3.new(0, DASH_LIFT, 0)

    local burst = Instance.new("Part")
    burst.Name = "SupernovaBurst"
    burst.Shape = Enum.PartType.Ball
    burst.Size = Vector3.new(2, 2, 2)
    burst.CFrame = root.CFrame
    burst.Anchored = true
    burst.CanCollide = false
    burst.Material = Enum.Material.Neon
    burst.Color = Color3.fromRGB(111, 226, 255)
    burst.Transparency = 0.25
    burst.Parent = workspace
    TweenService:Create(
        burst,
        TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = Vector3.new(24, 24, 24), Transparency = 1 }
    ):Play()
    Debris:AddItem(burst, 0.5)

    remote:FireClient(player, "AbilityResult", true, ABILITY_COOLDOWN)
end)
