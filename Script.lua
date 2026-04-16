if not game:IsLoaded() then game.Loaded:Wait() end
local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

_G.NormalSpeed = 28
_G.GuiLocked = false
local vDir = 0
local plat = nil

local function ManagePlatform()
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if not plat or not plat.Parent then
        plat = Instance.new("Part")
        plat.Name = "DandyBase_Safe"
        plat.Size = Vector3.new(12, 1, 12)
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.5
        plat.Color = Color3.new(0, 1, 0)
        plat.Parent = workspace.CurrentCamera 
    end

    local currentPos = plat.Position
    local newY = currentPos.Y + (vDir * 1.0)
    
    if (hrp.Position - currentPos).Magnitude > 15 then
        plat.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
    else
        plat.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
    end
end

local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 20)
    if pg:FindFirstChild("DandyFloatV12") then return end

    local sg = Instance.new("ScreenGui", pg)
    sg.Name = "DandyFloatV12"
    sg.ResetOnSpawn = false

    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 80, 0, 320)
    menu.Position = UDim2.new(0.05, 0, 0.3, 0)
    menu.BackgroundTransparency = 1

    local function makeBtn(txt, img, sizeY, pos)
        local frame = Instance.new("Frame", menu)
        frame.Size = UDim2.new(0, 75, 0, sizeY)
        frame.Position = pos
        frame.BackgroundTransparency = 1
        
        local b = Instance.new("ImageButton", frame)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        if img then b.Image = img end
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", b).Thickness = 2

        if txt then
            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = txt
            t.TextColor3 = Color3.new(1, 1, 1); t.TextScaled = true; t.Font = Enum.Font.Code
        end
        return b
    end

    local closeBtn = makeBtn("CLOSE", nil, 30, UDim2.new(0,0,0,0))
    local lockBtn = makeBtn("FIXED", nil, 30, UDim2.new(0,0,0,35))
    local upBtn = makeBtn(nil, "rbxassetid://84178930837014", 65, UDim2.new(0,0,0,70))
    local downBtn = makeBtn(nil, "rbxassetid://140707758773403", 65, UDim2.new(0,0,0,140))

    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    
    lockBtn.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        lockBtn.TextLabel.Text = _G.GuiLocked and "UNFIX" or "FIXED"
    end)

    upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then vDir = 1 end end)
    upBtn.InputEnded:Connect(function() vDir = 0 end)
    downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then vDir = -1 end end)
    downBtn.InputEnded:Connect(function() vDir = 0 end)
end

RS.Heartbeat:Connect(function()
    pcall(function()
        ManagePlatform()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = _G.NormalSpeed
        end
    end)
end)

CreateUI()
