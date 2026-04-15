--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// НАСТРОЙКИ (БЕЗОПАСНЫЕ ДЛЯ МИРА ДЕНДИ)
_G.NormalSpeed = 28
_G.GuiLocked = false 
local verticalDir = 0
local platform = nil

--// ЗВУКОВАЯ СИСТЕМА
local function playClick()
    local s = Instance.new("Sound", player:WaitForChild("PlayerGui"))
    s.SoundId = "rbxassetid://552900451"
    s.Volume = 0.5
    s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

--// 1. HIGHLIGHT ESP
local function applyESP(v)
    if v:IsA("Model") and v ~= player.Character and v:FindFirstChild("Humanoid") then
        if not Players:GetPlayerFromCharacter(v) then
            if not v:FindFirstChild("ForceHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "ForceHighlight"
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = v
            end
        end
    end
end

--// 2. GUI С ЦЕНТРАЛЬНОЙ АНИМАЦИЕЙ
local function CreateUI()
    local pg = player:WaitForChild("PlayerGui", 10)
    if not pg or pg:FindFirstChild("DandyAntiKickUI") then return end

    local sg = Instance.new("ScreenGui", pg)
    sg.Name = "DandyAntiKickUI"
    sg.ResetOnSpawn = false

    local currentPos = UDim2.new(0.05, 0, 0.4, 0)

    local function makeBtn(parent, text, img, sizeY)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, 65, 0, sizeY or 65)
        frame.BackgroundTransparency = 1
        
        local b = Instance.new("ImageButton", frame)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Position = UDim2.new(0.5, 0, 0.5, 0)
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        b.AutoButtonColor = false
        if img then b.Image = img end
        
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", b)
        stroke.Thickness = 3
        stroke.Color = Color3.new(0, 0, 0)

        if text then
            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = text
            t.TextColor3 = Color3.new(1, 1, 1); t.Font = Enum.Font.Code; t.TextScaled = true
        end

        b.MouseButton1Down:Connect(function()
            playClick()
            TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.85, 0, 0.85, 0),
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
        
        b.MouseButton1Up:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
        
        return frame, b
    end

    local openCont, openBtn = makeBtn(sg, "ОТКРЫТЬ", nil)
    openCont.Visible = false; openCont.Position = currentPos

    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 70, 0, 260); menu.Position = currentPos; menu.BackgroundTransparency = 1

    local closeCont, closeBtn = makeBtn(menu, "ЗАКР.", nil, 35)
    closeBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)

    local lockCont, lockBtn = makeBtn(menu, "ЗАКРЕП.", nil, 35)
    lockCont.Position = UDim2.new(0,0,0,40)

    local upCont, upBtn = makeBtn(menu, nil, "rbxassetid://84178930837014")
    upCont.Position = UDim2.new(0,0,0,85)

    local downCont, downBtn = makeBtn(menu, nil, "rbxassetid://140707758773403")
    downCont.Position = UDim2.new(0,0,0,155)

    lockBtn.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        lockBtn.TextLabel.Text = _G.GuiLocked and "ОТКРЕП." or "ЗАКРЕП."
        lockBtn.UIStroke.Color = _G.GuiLocked and Color3.fromRGB(255, 50, 50) or Color3.new(0, 0, 0)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        currentPos = menu.Position; openCont.Position = currentPos
        menu.Visible = false; openCont.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        currentPos = openCont.Position; menu.Position = currentPos
        menu.Visible = true; openCont.Visible = false
    end)

    local function drag(obj, target)
        local dragging, startPos, dragStart
        obj.InputBegan:Connect(function(i)
            if not _G.GuiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                dragging = true; dragStart = i.Position; startPos = target.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() dragging = false end)
    end

    drag(upBtn, menu); drag(downBtn, menu); drag(openBtn, openCont); drag(lockBtn, menu)

    upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then verticalDir = 1 end end)
    upBtn.InputEnded:Connect(function() verticalDir = 0 end)
    downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then verticalDir = -1 end end)
    downBtn.InputEnded:Connect(function() verticalDir = 0 end)
end

--// 3. БЕЗОПАСНАЯ ПЛАТФОРМА (ОБХОД ANTI-FLY)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if root and hum then
            hum.WalkSpeed = _G.NormalSpeed
            
            -- Сбрасываем состояние падения, чтобы античит думал, что мы на земле
            if hum:GetState() == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end

            if not platform or not platform.Parent then
                platform = Instance.new("Part")
                platform.Name = "Floor_Surface"
                platform.Size = Vector3.new(8, 0.5, 8)
                platform.Anchored = true
                platform.Transparency = 0.5
                platform.Material = Enum.Material.Plastic
                platform.Parent = workspace
            end
            
            -- Платформа теперь ДЕРЖИТ ноги персонажа (3.05 вместо 3.5)
            -- Это создает эффект плотного контакта с поверхностью
            local currentY = platform.Position.Y
            local targetY = currentY + (verticalDir * 0.6)
            platform.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
            
            -- Если мы слишком далеко от платформы, подтягиваем её
            if (root.Position.Y - platform.Position.Y) > 4 then
                platform.Position = root.Position - Vector3.new(0, 3.05, 0)
            end
        end
    end)
end)

--// 4. ЗАПУСК
task.spawn(function()
    while true do
        pcall(CreateUI)
        pcall(function() for _, v in pairs(workspace:GetDescendants()) do applyESP(v) end end)
        task.wait(1.5)
    end
end)
