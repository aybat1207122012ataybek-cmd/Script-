if not game:IsLoaded() then game.Loaded:Wait() end
local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

_G.NormalSpeed = 28
_G.GuiLocked = false
local vDir = 0
local plat = nil

local function applyESP()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= lp.Character then
            if not game.Players:GetPlayerFromCharacter(v) then
                if not v:FindFirstChild("ForceHighlight") then
                    local hl = Instance.new("Highlight", v)
                    hl.Name = "ForceHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
    end
end

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
        plat.Color = Color3.fromRGB(100, 100, 100) -- Теперь серая
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
    if pg:FindFirstChild("DandyV12") then return end

    local sg = Instance.new("ScreenGui", pg)
    sg.Name = "DandyV12"
    sg.ResetOnSpawn = false

    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 80, 0, 320)
    menu.Position = UDim2.new(0.05, 0, 0.3, 0)
    menu.BackgroundTransparency = 1

    local openFrame = Instance.new("Frame", sg)
    openFrame.Size = UDim2.new(0, 70, 0, 70)
    openFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    openFrame.BackgroundTransparency = 1
    openFrame.Visible = false

    local function makeBtn(parent, txt, img, sizeY, pos)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, 75, 0, sizeY)
        frame.Position = pos or UDim2.new(0,0,0,0)
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

    local openBtn = makeBtn(openFrame, "OPEN", nil, 70)
    local closeBtn = makeBtn(menu, "CLOSE", nil, 30, UDim2.new(0,0,0,0))
    local lockBtn = makeBtn(menu, "FIXED", nil, 30, UDim2.new(0,0,0,35))
    local extraBtn = makeBtn(menu, "EXTRA", nil, 40, UDim2.new(0,0,0,70))
    local upBtn = makeBtn(menu, nil, "rbxassetid://84178930837014", 65, UDim2.new(0,0,0,115))
    local downBtn = makeBtn(menu, nil, "rbxassetid://140707758773403", 65, UDim2.new(0,0,0,185))

    extraBtn.MouseButton1Click:Connect(function()
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/FBRnb7S7"))() end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        openFrame.Position = menu.Position
        menu.Visible = false; openFrame.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        menu.Position = openFrame.Position
        menu.Visible = true; openFrame.Visible = false
    end)

    lockBtn.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        lockBtn.TextLabel.Text = _G.GuiLocked and "UNFIX" or "FIXED"
    end)

    local dragStart, startPos, dragging
    local function setDrag(target, mainObj)
        target.InputBegan:Connect(function(input)
            if not _G.GuiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = true; dragStart = input.Position; startPos = mainObj.Position
            end
        end)
    end
    setDrag(upBtn, menu); setDrag(downBtn, menu); setDrag(openBtn, openFrame); setDrag(lockBtn, menu)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local target = menu.Visible and menu or openFrame
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function() dragging = false end)

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

task.spawn(function()
    while true do
        pcall(CreateUI)
        pcall(applyESP)
        task.wait(2)
    end
end)
