if not game:IsLoaded() then game.Loaded:Wait() end
local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")

_G.NormalSpeed = 28
_G.GuiLocked = false
local vDir = 0
local plat = nil

-- === ШРИФТ STARBORN ===
local function GetStarborn()
    local fontName = "starborn.ttf"
    local jsonName = "starborn.json"
    local success, font = pcall(function()
        if not isfile(fontName) then
            writefile(fontName, game:HttpGet("https://granny.anondrop.net/uploads/6c2505542959f371/Starborn.ttf"))
        end
        writefile(jsonName, HS:JSONEncode({
            name = "Starborn",
            faces = {{name="Regular", weight=400, style="normal", assetId=getcustomasset(fontName)}}
        }))
        return Font.new(getcustomasset(jsonName))
    end)
    return success and font or Font.fromEnum(Enum.Font.SourceSansBold)
end
local starbornFont = GetStarborn()

-- Функция звука
local function PlayClick()
    local s = Instance.new("Sound", game.Workspace)
    s.SoundId = "rbxassetid://552900451"; s.Volume = 0.5
    s:Play(); s.Ended:Connect(function() s:Destroy() end)
end

-- Функция анимации нажатия
local function AnimatePress(obj, shrink)
    local targetSize = shrink and UDim2.new(0.9, 0, 0.9, 0) or UDim2.new(1, 0, 1, 0)
    TS:Create(obj, TweenInfo.new(0.1), {Size = targetSize}):Play()
end

-- Функция перетаскивания
local function MakeDraggable(uiObj, dragTarget)
    local dragging, dragStart, startPos
    uiObj.InputBegan:Connect(function(input)
        if not _G.GuiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = input.Position; startPos = dragTarget.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === УПРАВЛЕНИЕ ПЛАТФОРМОЙ ===
local function ManagePlatform()
    local char = lp.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if not plat or not plat.Parent then
        plat = Instance.new("Part", workspace.CurrentCamera)
        plat.Size = Vector3.new(12, 1, 12); plat.Anchored = true; plat.CanCollide = true; plat.Transparency = 0.5
    end
    local antiSleep = math.sin(tick() * 10) * 0.0001
    local newPos = plat.Position.Y + (vDir * 1.0) + antiSleep
    if (hrp.Position - plat.Position).Magnitude > 15 then
        plat.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
    else
        plat.CFrame = CFrame.new(hrp.Position.X, newPos, hrp.Position.Z)
    end
    if vDir == 0 and (hrp.Position.Y - plat.Position.Y) < 3.6 then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
    end
end

-- === ОСНОВНОЙ GUI ===
local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 20)
    if pg:FindFirstChild("DandyV12") then return end

    local sg = Instance.new("ScreenGui", pg); sg.Name = "DandyV12"; sg.ResetOnSpawn = false
    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 80, 0, 320); menu.Position = UDim2.new(0.05, 0, 0.3, 0); menu.BackgroundTransparency = 1

    local openFrame = Instance.new("Frame", sg)
    openFrame.Size = UDim2.new(0, 70, 0, 70); openFrame.Position = UDim2.new(0.05, 0, 0.3, 0); openFrame.BackgroundTransparency = 1; openFrame.Visible = false

    local function makeBtn(parent, txt, img, sizeY, pos)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(0, 75, 0, sizeY); frame.Position = pos or UDim2.new(0,0,0,0); frame.BackgroundTransparency = 1
        
        local bgImg = Instance.new("ImageLabel", frame)
        bgImg.Size = UDim2.new(1, 0, 1, 0); bgImg.Image = "rbxassetid://114452497059751"; bgImg.BackgroundTransparency = 1; bgImg.ZIndex = 1
        Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 10)
        
        local b = Instance.new("ImageButton", frame)
        b.AnchorPoint = Vector2.new(0.5, 0.5); b.Position = UDim2.new(0.5, 0, 0.5, 0); b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundTransparency = 0.3; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.ZIndex = 2
        if img then b.Image = "rbxassetid://" .. img end
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        
        -- СПОКОЙНАЯ ТЕМНАЯ ОБВОДКА
        local s = Instance.new("UIStroke", b); s.Thickness = 2; s.Color = Color3.fromRGB(20, 20, 20)

        if txt then
            local t = Instance.new("TextLabel", b)
            t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = txt
            t.TextColor3 = Color3.new(1, 1, 1); t.TextScaled = true; t.ZIndex = 3; t.FontFace = starbornFont
        end

        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                PlayClick(); AnimatePress(b, true)
            end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                AnimatePress(b, false)
            end
        end)
        return b
    end

    local openBtn = makeBtn(openFrame, "OPEN", nil, 70)
    local closeBtn = makeBtn(menu, "CLOSE", nil, 30, UDim2.new(0,0,0,0))
    local lockBtn = makeBtn(menu, "FIXED", nil, 30, UDim2.new(0,0,0,35))
    local scriptBtn = makeBtn(menu, "SCRIPT", nil, 40, UDim2.new(0,0,0,70))
    local upBtn = makeBtn(menu, nil, "100779215956277", 65, UDim2.new(0,0,0,115))
    local downBtn = makeBtn(menu, nil, "88901857737780", 65, UDim2.new(0,0,0,185))

    MakeDraggable(upBtn, menu); MakeDraggable(downBtn, menu); MakeDraggable(lockBtn, menu); MakeDraggable(openBtn, openFrame)

    -- НОВАЯ ССЫЛКА НА ТВОЙ СКРИПТ
    scriptBtn.MouseButton1Click:Connect(function()
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/bookworming/bookshelf/refs/heads/main/shelf%203/boxten%20sex%20gui.lua"))() end)
    end)

    closeBtn.MouseButton1Click:Connect(function() menu.Visible = false; openFrame.Visible = true; openFrame.Position = menu.Position end)
    openBtn.MouseButton1Click:Connect(function() menu.Visible = true; openFrame.Visible = false; menu.Position = openFrame.Position end)
    
    lockBtn.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        lockBtn.TextLabel.Text = _G.GuiLocked and "UNFIX" or "FIXED"
        -- ТЕМНО-КРАСНЫЙ ЦВЕТ ПРИ ЗАКРЕПЕ
        lockBtn.BackgroundColor3 = _G.GuiLocked and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(35, 35, 35)
    end)

    upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then vDir = 1 end end)
    upBtn.InputEnded:Connect(function() vDir = 0 end)
    downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then vDir = -1 end end)
    downBtn.InputEnded:Connect(function() vDir = 0 end)
end

-- === ЦИКЛ ОБНОВЛЕНИЯ ===
RS.Heartbeat:Connect(function()
    pcall(ManagePlatform)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then 
        lp.Character.Humanoid.WalkSpeed = _G.NormalSpeed 
    end
end)

task.spawn(function()
    while true do
        pcall(CreateUI)
        task.wait(2)
    end
end)

