local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local DRESS_MESH = "rbxassetid://121152412023150"
local DRESS_TEXTURE = "rbxassetid://87295821417072"

local function findTorso(character)
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("Body")
    if torso then return torso end

    local candidates = {}
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local name = part.Name
            if name:find("Body") or name:find("Torso") then
                table.insert(candidates, part)
            end
        end
    end

    if #candidates > 0 then
        table.sort(candidates, function(a, b)
            local sizeA = a.Size.X * a.Size.Y * a.Size.Z
            local sizeB = b.Size.X * b.Size.Y * b.Size.Z
            return sizeA > sizeB
        end)
        return candidates[1]
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "RootPart" then
            return part
        end
    end

    return nil
end

local function applyDress(character)
    if not character or not character:IsA("Model") then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local torso = findTorso(character)
    if not torso then return end

    local oldDress = character:FindFirstChild("MaidDress")
    if oldDress then oldDress:Destroy() end

    local torsoSize = torso.Size
    local dressSize = Vector3.new(
        math.max(torsoSize.X * 0.7, 0.7),
        math.max(torsoSize.Y * 0.9, 0.8),
        math.max(torsoSize.Z * 1.0, 1.0)
    )

    local dress = Instance.new("MeshPart")
    dress.Name = "MaidDress"
    dress.Size = dressSize
    dress.MeshId = DRESS_MESH
    dress.TextureID = DRESS_TEXTURE
    dress.CanCollide = false
    dress.Transparency = 0
    dress.Material = Enum.Material.SmoothPlastic
    dress.Parent = character

    local attach0 = Instance.new("Attachment")
    attach0.Name = "DressAttach0"
    attach0.Parent = torso

    local dressAtt = Instance.new("Attachment")
    dressAtt.Name = "DressAttachment"
    dressAtt.Position = Vector3.new(0, torsoSize.Y * -0.3, 0)
    dressAtt.Parent = dress

    local constraint = Instance.new("RigidConstraint")
    constraint.Attachment0 = attach0
    constraint.Attachment1 = dressAtt
    constraint.Parent = dress
end

local function applyToAllCharacters()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            applyDress(player.Character)
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isPlayer = false
            for _, player in ipairs(Players:GetPlayers()) do
                if obj == player.Character then
                    isPlayer = true
                    break
                end
            end
            if not isPlayer then
                local hum = obj:FindFirstChild("Humanoid")
                if hum then
                    applyDress(obj)
                end
            end
        end
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("Humanoid", 5)
        task.wait(0.5)
        applyDress(character)
    end)
    if player.Character then
        applyDress(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

Workspace.ChildAdded:Connect(function(child)
    task.wait(1)
    if child:IsA("Model") then
        local isPlayer = false
        for _, player in ipairs(Players:GetPlayers()) do
            if child == player.Character then
                isPlayer = true
                break
            end
        end
        if not isPlayer then
            local hum = child:FindFirstChild("Humanoid")
            if hum then
                applyDress(child)
            end
        end
    end
end)

task.wait(1)
applyToAllCharacters()

print("Горничная одежда успешно одето! сделал AYBAT_ATAYBEK")
