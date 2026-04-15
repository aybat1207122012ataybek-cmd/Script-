local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
_G.Speed = 28
_G.Locked = false 
local moveDir = 0
local plat = nil

local function play()
    local s = Instance.new("Sound", lp:WaitForChild("PlayerGui"))
    s.SoundId = "rbxassetid://552900451"
    s.Volume = 0.5
    s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

local function esp(obj)
    if obj:IsA("Model") and obj ~= lp.Character and obj:FindFirstChild("Humanoid") then
        if not Players:GetPlayerFromCharacter(obj) then
            if not obj:FindFirstChild("Glow") then
                local h = Instance.new("Highlight")
                h.Name = "Glow"
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.Parent = obj
            end
        end
    end
end

local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 10)
    if not pg or pg:FindFirstChild("DandyMain") then return end

    local sg = Instance.new("ScreenGui", pg)
    sg.Name = "DandyMain"
    sg.ResetOnSpawn = false

    local pos = UDim2.new(0.05, 0, 0.4, 0)

    local function btn(parent, txt, img, sz)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(0, 65, 0, sz or 65)
        f.BackgroundTransparency = 1
        
        local b = Instance.new("ImageButton", f)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Position = UDim2.new(0.5, 0, 0.5, 0)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        if img then b.Image = img end
        
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", b)
        st.Thickness = 3

        if txt then
            local tl = Instance.new("TextLabel", b)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = txt
            tl.TextColor3 = Color3.new(1, 1, 1)
            tl.TextScaled = true
        end

        b.MouseButton1Down:Connect(function()
            play()
            TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.8, 0, 0.8, 0)}):Play()
        end)
        b.MouseButton1Up:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        end)
        
        return f, b
    end

    local f_open, b_open = btn(sg, "OPEN")
    f_open.Visible = false
    f_open.Position = pos

    local m = Instance.new("Frame", sg)
    m.Size = UDim2.new(0, 70, 0, 260)
    m.Position = pos
    m.BackgroundTransparency = 1

    local _, b_close = btn(m, "CLOSE", nil, 35)
    b_close.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

    local f_lock, b_lock = btn(m, "FIXED", nil, 35)
    f_lock.Position = UDim2.new(0,0,0,40)

    local f_up, b_up = btn(m, nil, "rbxassetid://84178930837014")
    f_up.Position = UDim2.new(0,0,0,85)

    local f_down, b_down = btn(m, nil, "rbxassetid://140707758773403")
    f_down.Position = UDim2.new(0,0,0,155)

    b_lock.MouseButton1Click:Connect(function()
        _G.Locked = not _G.Locked
        b_lock.TextLabel.Text = _G.Locked and "UNFIX" or "FIXED"
    end)

    b_close.MouseButton1Click:Connect(function()
        pos = m.Position
        f_open.Position = pos
        m.Visible = false
        f_open.Visible = true
    end)

    b_open.MouseButton1Click:Connect(function()
        pos = f_open.Position
        m.Position = pos
        m.Visible = true
        f_open.Visible = false
    end)

    local function drag(o, c)
        local drag_on, s_pos, input_pos
        o.InputBegan:Connect(function(i)
            if not _G.Locked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                drag_on = true
                input_pos = i.Position
                s_pos = c.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag_on and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - input_pos
                c.Position = UDim2.new(s_pos.X.Scale, s_pos.X.Offset + d.X, s_pos.Y.Scale, s_pos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() drag_on = false end)
    end

    drag(b_up, m)
    drag(b_down, m)
    drag(b_open, f_open)
    drag(b_lock, m)

    b_up.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then moveDir = 1 end end)
    b_up.InputEnded:Connect(function() moveDir = 0 end)
    b_down.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then moveDir = -1 end end)
    b_down.InputEnded:Connect(function() moveDir = 0 end)
end

RunService.Stepped:Connect(function()
    pcall(function()
        local char = lp.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum then
                hum.WalkSpeed = _G.Speed
                if hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Landed) end
                if not plat or not plat.Parent then
                    plat = Instance.new("Part")
                    plat.Name = "Surface"
                    plat.Size = Vector3.new(7, 0.4, 7)
                    plat.Anchored = true
                    plat.Transparency = 0.5
                    plat.Parent = workspace
                end
                local n_y = plat.Position.Y + (moveDir * 0.65)
                plat.CFrame = CFrame.new(hrp.Position.X, n_y, hrp.Position.Z)
                if math.abs(hrp.Position.Y - plat.Position.Y) > 3.2 then
                    plat.Position = hrp.Position - Vector3.new(0, 3.01, 0)
                end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        pcall(CreateUI)
        pcall(function() for _, o in pairs(workspace:GetDescendants()) do esp(o) end end)
        task.wait(1.5)
    end
end)
