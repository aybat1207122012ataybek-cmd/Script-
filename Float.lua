if not game:IsLoaded() then game.Loaded:Wait() end
local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SP = game:GetService("SoundService")

_G.GuiLocked = false
_G.PlatColor = Color3.fromRGB(163, 162, 165)
local vDir, plat = 0, nil
local starbornFont = Font.fromEnum(Enum.Font.SourceSansBold)

local function PlayClick() 
    local s = Instance.new("Sound", SP) s.SoundId = "rbxassetid://552900451" s.Volume = 1 s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

-- ФИЗИКА ПЛАТФОРМЫ V62
local function ManagePlatform()
    local char = lp.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    
    if vDir ~= 0 or (plat and plat.Parent) then
        if not plat or not plat.Parent then
            plat = Instance.new("Part")
            plat.Name = "BasePart" 
            plat.Parent = workspace
            plat.Size = Vector3.new(14, 1, 14)
            plat.Anchored = true 
            plat.CanCollide = true 
            plat.Transparency = 0.5
        end
        plat.Color = _G.PlatColor
        
        local targetY = plat.Position.Y + (vDir * 0.8) 
        if (root.Position.Y - targetY) > 5 then targetY = root.Position.Y - 3.5 end
        
        plat.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    end
end

local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 20)
    if pg:FindFirstChild("Dandy_V62_Colors") then return end
    local sg = Instance.new("ScreenGui", pg) sg.Name = "Dandy_V62_Colors" sg.ResetOnSpawn = false

    local function applyBg(obj)
        local bg = Instance.new("ImageLabel", obj)
        bg.Size = UDim2.new(1,0,1,0) bg.Image = "rbxassetid://114452497059751"
        bg.BackgroundTransparency = 1 bg.ZIndex = 0
        local s = Instance.new("UIStroke", obj) s.Thickness = 2.5 s.Color = Color3.new(0,0,0) s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 8)
    end

    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 75, 0, 320) menu.Position = UDim2.new(0.05, 0, 0.2, 0) menu.BackgroundTransparency = 1 

    local openCont = Instance.new("Frame", sg)
    openCont.Size = UDim2.new(0, 70, 0, 45) openCont.Visible = false openCont.BackgroundTransparency = 1

    local function makeBtn(parent, txt, img, sizeY, pos)
        local f = Instance.new("Frame", parent) f.Size = UDim2.new(0, (parent == menu or parent == openCont) and 70 or 100, 0, sizeY)
        f.Position = pos or UDim2.new(0,0,0,0) f.BackgroundTransparency = 1 applyBg(f)
        local b = Instance.new("ImageButton", f) b.Size = UDim2.new(1,0,1,0) b.BackgroundTransparency = 0.4 b.BackgroundColor3 = Color3.fromRGB(30,30,30) b.ZIndex = 2
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        if img then b.Image = "rbxassetid://" .. img end
        if txt then
            local t = Instance.new("TextLabel", b) t.Size = UDim2.new(1,0,1,0) t.BackgroundTransparency = 1 
            t.Text = txt t.TextColor3 = Color3.new(1,1,1) t.TextScaled = true t.ZIndex = 3 t.FontFace = starbornFont
        end
        b.MouseButton1Click:Connect(PlayClick) return b
    end

    local scriptPanel = Instance.new("Frame", menu) scriptPanel.Size = UDim2.new(0, 120, 0, 195) scriptPanel.Position = UDim2.new(1, 10, 0, 70) 
    scriptPanel.Visible = false scriptPanel.BackgroundTransparency = 1 applyBg(scriptPanel)

    local colorPanel = Instance.new("Frame", scriptPanel) colorPanel.Size = UDim2.new(0, 320, 0, 160) colorPanel.Position = UDim2.new(1, 10, 0, 0) 
    colorPanel.Visible = false colorPanel.BackgroundTransparency = 1 applyBg(colorPanel)

    local close = makeBtn(menu, "CLOSE", nil, 30, UDim2.new(0,0,0,0))
    local lock = makeBtn(menu, "FIXED", nil, 30, UDim2.new(0,0,0,35))
    local scrB = makeBtn(menu, "SCRIPT", nil, 40, UDim2.new(0,0,0,70))
    local upB = makeBtn(menu, nil, "100779215956277", 55, UDim2.new(0,0,0,115))
    local dwB = makeBtn(menu, nil, "88901857737780", 55, UDim2.new(0,0,0,175))
    local open = makeBtn(openCont, "OPEN", nil, 45)

    -- ВОССТАНОВЛЕННЫЙ ЦВЕТОВОЙ КОРРЕКТОР (Hue, Sat, Val + HEX)
    local picker = Instance.new("ImageButton", colorPanel) picker.Size = UDim2.new(0, 140, 0, 100) picker.Position = UDim2.new(0, 130, 0, 15) picker.ZIndex = 5
    local g1 = Instance.new("UIGradient", picker) g1.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,0,0))
    local pickDot = Instance.new("Frame", picker) pickDot.Size = UDim2.new(0, 10, 0, 10) pickDot.AnchorPoint = Vector2.new(0.5, 0.5)
    pickDot.BackgroundColor3 = Color3.new(1,1,1) pickDot.ZIndex = 6 Instance.new("UICorner", pickDot).CornerRadius = UDim.new(1,0) Instance.new("UIStroke", pickDot)

    -- ЧЕРНАЯ ТЕМНАЯ ЛИНИЯ (Value Slider)
    local valS = Instance.new("ImageButton", colorPanel) valS.Size = UDim2.new(0, 20, 0, 100) valS.Position = UDim2.new(0, 285, 0, 15) valS.ZIndex = 5
    local gV = Instance.new("UIGradient", valS) gV.Rotation = 90 gV.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0))
    local valLine = Instance.new("Frame", valS) valLine.Size = UDim2.new(1, 4, 0, 2) valLine.BackgroundColor3 = Color3.new(1,1,1) valLine.ZIndex = 6

    -- HEX Поле ввода
    local hexInput = Instance.new("TextBox", colorPanel) hexInput.Size = UDim2.new(0, 110, 0, 35) hexInput.Position = UDim2.new(0, 10, 0, 15)
    hexInput.BackgroundColor3 = Color3.fromRGB(45,45,45) hexInput.TextColor3 = Color3.new(1,1,1) hexInput.Text = "#A3A2A5" hexInput.TextScaled = true applyBg(hexInput)

    local cH, cS, cV = 0, 0, 0.64
    local function update()
        _G.PlatColor = Color3.fromHSV(cH, cS, cV)
        g1.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(cH, 1, 1))
        gV.Color = ColorSequence.new(Color3.fromHSV(cH, cS, 1), Color3.new(0,0,0))
        pickDot.Position = UDim2.new(cS, 0, 1 - cV, 0)
        valLine.Position = UDim2.new(0.5, 0, 1 - cV, 0)
        hexInput.Text = "#".._G.PlatColor:ToHex():upper()
    end

    local function setupPicker(obj, func)
        local active = false
        local function proc()
            local mPos = UIS:GetMouseLocation() - obj.AbsolutePosition - Vector2.new(0, 36)
            func(math.clamp(mPos.X/obj.AbsoluteSize.X, 0, 1), math.clamp(mPos.Y/obj.AbsoluteSize.Y, 0, 1))
        end
        obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true proc() end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)
        RS.RenderStepped:Connect(function() if active and colorPanel.Visible then proc() update() end end)
    end
    setupPicker(picker, function(x, y) cS = x cV = 1 - y end)
    setupPicker(valS, function(x, y) cV = 1 - y end) -- Тот самый ползунок яркости

    makeBtn(colorPanel, "RESET", nil, 35, UDim2.new(0,10,0,60)).MouseButton1Click:Connect(function() _G.PlatColor = Color3.fromRGB(163, 162, 165) cH, cS, cV = Color3.toHSV(_G.PlatColor) update() end)
    makeBtn(scriptPanel, "COLORS", nil, 35, UDim2.new(0,10,0,145)).MouseButton1Click:Connect(function() colorPanel.Visible = not colorPanel.Visible end)
    makeBtn(colorPanel, "REMOVE", nil, 35, UDim2.new(0,10,0,100)).MouseButton1Click:Connect(function() if plat then plat:Destroy() end end)

    close.MouseButton1Click:Connect(function() menu.Visible = false openCont.Visible = true openCont.Position = menu.Position end)
    open.MouseButton1Click:Connect(function() menu.Visible = true openCont.Visible = false menu.Position = openCont.Position end)
    
    lock.MouseButton1Click:Connect(function() 
        _G.GuiLocked = not _G.GuiLocked 
        lock.TextLabel.Text = _G.GuiLocked and "UNFIX" or "FIXED" 
        lock.BackgroundColor3 = _G.GuiLocked and Color3.fromRGB(120, 0, 0) or Color3.fromRGB(30, 30, 30) 
    end)
    
    scrB.MouseButton1Click:Connect(function() scriptPanel.Visible = not scriptPanel.Visible if not scriptPanel.Visible then colorPanel.Visible = false end end)
    
    local credit = Instance.new("TextLabel", colorPanel) credit.Size = UDim2.new(1, 0, 0, 20) credit.Position = UDim2.new(0, 0, 1, -25) credit.BackgroundTransparency = 1 credit.Text = "@AYBAT_ATAYBEK" credit.TextColor3 = Color3.fromRGB(150,150,150) credit.TextScaled = true credit.FontFace = starbornFont credit.ZIndex = 5

    -- Кнопки полета
    local function setupFlight(btn, dir)
        btn.InputBegan:Connect(function(i) if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name:find("Touch") then vDir = dir end end)
        btn.InputEnded:Connect(function() vDir = 0 end)
    end
    setupFlight(upB, 1) setupFlight(dwB, -1)

    local function MakeDraggable(uiObj, dragTarget)
        local dragging, dragStart, startPos
        uiObj.InputBegan:Connect(function(input)
            if not _G.GuiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = true dragStart = input.Position startPos = dragTarget.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        uiObj.InputEnded:Connect(function() dragging = false end)
    end
    MakeDraggable(close, menu) MakeDraggable(lock, menu) MakeDraggable(open, openCont)
    update()
end

RS.Heartbeat:Connect(ManagePlatform)
task.spawn(function() while true do pcall(CreateUI) task.wait(5) end end)

