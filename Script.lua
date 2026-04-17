if not game:IsLoaded() then game.Loaded:Wait() end
local lp = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local SP = game:GetService("SoundService")

_G.GuiLocked = false
_G.PlatColor = Color3.fromRGB(163, 162, 165)
local vDir = 0
local plat = nil
local starbornFont = Font.fromEnum(Enum.Font.SourceSansBold)

-- Создание звука
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://552900451"
clickSound.Volume = 1
clickSound.Parent = SP

local function PlayClick()
    clickSound:Play()
end

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
    uiObj.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local function ManagePlatform()
    local char = lp.Character if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if vDir ~= 0 and (not plat or not plat.Parent) then
        plat = Instance.new("Part", workspace.CurrentCamera)
        plat.Size = Vector3.new(12, 1, 12) plat.Anchored = true plat.CanCollide = true plat.Transparency = 0.5
        plat.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
    end
    if plat and plat.Parent then
        plat.Color = _G.PlatColor
        plat.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, plat.Position.Y + (vDir * 1.2), char.HumanoidRootPart.Position.Z)
    end
end

local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 20)
    if pg:FindFirstChild("DandyV33_Sound") then return end
    local sg = Instance.new("ScreenGui", pg) sg.Name = "DandyV33_Sound" sg.ResetOnSpawn = false

    local menu = Instance.new("Frame", sg)
    menu.Size = UDim2.new(0, 75, 0, 320) menu.Position = UDim2.new(0.05, 0, 0.2, 0) menu.BackgroundTransparency = 1
    local openCont = Instance.new("Frame", sg)
    openCont.Size = UDim2.new(0, 70, 0, 45) openCont.Visible = false openCont.BackgroundTransparency = 1

    local function applyStroke(obj)
        local s = Instance.new("UIStroke", obj)
        s.Thickness = 2.5 s.Color = Color3.new(0,0,0) s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end

    local function makeBtn(parent, txt, img, sizeY, pos)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(0, (parent == menu or parent == openCont) and 70 or 100, 0, sizeY)
        f.Position = pos or UDim2.new(0,0,0,0) f.BackgroundTransparency = 1
        local bg = Instance.new("ImageLabel", f)
        bg.Size = UDim2.new(1,0,1,0) bg.Image = "rbxassetid://114452497059751" bg.BackgroundTransparency = 1 bg.ZIndex = 1
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
        applyStroke(bg)
        local b = Instance.new("ImageButton", f)
        b.Size = UDim2.new(1,0,1,0) b.BackgroundTransparency = 0.4 b.BackgroundColor3 = Color3.fromRGB(30,30,30) b.ZIndex = 2
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        if img then b.Image = "rbxassetid://" .. img end
        if txt then
            local t = Instance.new("TextLabel", b) t.Size = UDim2.new(1,0,1,0) t.BackgroundTransparency = 1 t.Text = txt t.TextColor3 = Color3.new(1,1,1) t.TextScaled = true t.ZIndex = 3 t.FontFace = starbornFont
        end
        b.MouseButton1Click:Connect(PlayClick)
        return b
    end

    local scriptPanel = Instance.new("Frame", menu)
    scriptPanel.Size = UDim2.new(0, 120, 0, 190) scriptPanel.Position = UDim2.new(1, 10, 0, 70) scriptPanel.Visible = false scriptPanel.BackgroundTransparency = 1
    local sbg = Instance.new("ImageLabel", scriptPanel) sbg.Size = UDim2.new(1,0,1,0) sbg.Image = "rbxassetid://114452497059751" sbg.BackgroundTransparency = 1
    Instance.new("UICorner", sbg) applyStroke(sbg)

    local colorPanel = Instance.new("Frame", scriptPanel)
    colorPanel.Size = UDim2.new(0, 300, 0, 200) colorPanel.Position = UDim2.new(1, 10, 0, 0) colorPanel.Visible = false colorPanel.BackgroundTransparency = 1
    local cbg = Instance.new("ImageLabel", colorPanel) cbg.Size = UDim2.new(1,0,1,0) cbg.Image = "rbxassetid://114452497059751" cbg.BackgroundTransparency = 1
    Instance.new("UICorner", cbg) applyStroke(cbg)

    local close = makeBtn(menu, "CLOSE", nil, 30, UDim2.new(0,0,0,0))
    local lock = makeBtn(menu, "FIXED", nil, 30, UDim2.new(0,0,0,35))
    local scrB = makeBtn(menu, "SCRIPT", nil, 40, UDim2.new(0,0,0,70))
    local upB = makeBtn(menu, nil, "100779215956277", 55, UDim2.new(0,0,0,115))
    local dwB = makeBtn(menu, nil, "88901857737780", 55, UDim2.new(0,0,0,175))
    local open = makeBtn(openCont, "OPEN", nil, 45)

    local function addScr(t, p, url)
        makeBtn(scriptPanel, t, nil, 30, p).MouseButton1Click:Connect(function() loadstring(game:HttpGet(url))() end)
    end
    addScr("NOXIOUS", UDim2.new(0,10,0,10), "https://raw.githubusercontent.com/bookworming/bookshelf/refs/heads/main/shelf%203/boxten%20sex%20gui.lua")
    addScr("RIDDANCE", UDim2.new(0,10,0,45), "https://raw.githubusercontent.com/riddance-club/script/refs/heads/main/loader.lua")
    addScr("G0BBY", UDim2.new(0,10,0,80), "https://pastebin.com/raw/FBRnb7S7")
    makeBtn(scriptPanel, "COLORS", nil, 35, UDim2.new(0,10,0,145)).MouseButton1Click:Connect(function() colorPanel.Visible = not colorPanel.Visible end)

    local picker = Instance.new("ImageButton", colorPanel)
    picker.Size = UDim2.new(0, 150, 0, 100) picker.Position = UDim2.new(0, 135, 0, 10) picker.ZIndex = 2
    local g1 = Instance.new("UIGradient", picker) g1.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,0,0))
    local hueS = Instance.new("ImageButton", colorPanel)
    hueS.Size = UDim2.new(0, 150, 0, 20) hueS.Position = UDim2.new(0, 135, 0, 120) hueS.ZIndex = 2
    local g2 = Instance.new("UIGradient", hueS) g2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.2, Color3.new(1,1,0)),
        ColorSequenceKeypoint.new(0.4, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.6, Color3.new(0,1,1)),
        ColorSequenceKeypoint.new(0.8, Color3.new(0,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
    })

    local hexInput = Instance.new("TextBox", colorPanel)
    hexInput.Size = UDim2.new(0, 110, 0, 30) hexInput.Position = UDim2.new(0, 10, 0, 15) hexInput.BackgroundColor3 = Color3.fromRGB(45,45,45) hexInput.TextColor3 = Color3.new(1,1,1) hexInput.Text = "#A3A2A5" hexInput.TextScaled = true
    Instance.new("UICorner", hexInput) applyStroke(hexInput)

    local cH, cS, cV = 0, 0, 0.64
    local function update(fH)
        _G.PlatColor = Color3.fromHSV(cH, cS, cV)
        g1.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(cH, 1, 1))
        if not fH then hexInput.Text = "#".._G.PlatColor:ToHex():upper() end
    end

    hexInput.FocusLost:Connect(function()
        local s, res = pcall(function() return Color3.fromHex(hexInput.Text) end)
        if s then _G.PlatColor = res cH, cS, cV = Color3.toHSV(res) update(true) end
    end)

    hueS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local conn; conn = UIS.InputChanged:Connect(function(input)
                cH = math.clamp((input.Position.X - hueS.AbsolutePosition.X) / hueS.AbsoluteSize.X, 0, 1) update()
            end)
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then conn:Disconnect() end end)
        end
    end)

    picker.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local conn; conn = UIS.InputChanged:Connect(function(input)
                cS = math.clamp((input.Position.X - picker.AbsolutePosition.X) / picker.AbsoluteSize.X, 0, 1)
                cV = 1 - math.clamp((input.Position.Y - picker.AbsolutePosition.Y) / picker.AbsoluteSize.Y, 0, 1) update()
            end)
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then conn:Disconnect() end end)
        end
    end)

    makeBtn(colorPanel, "RESET", nil, 30, UDim2.new(0,10,0,55)).MouseButton1Click:Connect(function() 
        _G.PlatColor = Color3.fromRGB(163, 162, 165) cH=0 cS=0 cV=0.64 update() 
    end)
    makeBtn(colorPanel, "REMOVE", nil, 30, UDim2.new(0,10,0,95)).MouseButton1Click:Connect(function() if plat then plat:Destroy() plat = nil end end)

    local credit = Instance.new("TextLabel", colorPanel)
    credit.Size = UDim2.new(1, -20, 0, 20) credit.Position = UDim2.new(0, 10, 1, -25) credit.BackgroundTransparency = 1
    credit.Text = "@AYBAT_ATAYBEK" credit.TextColor3 = Color3.fromRGB(120, 120, 120) credit.TextScaled = true credit.FontFace = starbornFont

    close.MouseButton1Click:Connect(function() menu.Visible = false openCont.Visible = true openCont.Position = menu.Position end)
    open.MouseButton1Click:Connect(function() menu.Visible = true openCont.Visible = false menu.Position = openCont.Position end)
    lock.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        lock.TextLabel.Text = _G.GuiLocked and "UNFIX" or "FIXED"
        lock.BackgroundColor3 = _G.GuiLocked and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)

    upB.InputBegan:Connect(function(i) if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name:find("Touch") then vDir = 1 end end)
    upB.InputEnded:Connect(function() vDir = 0 end)
    dwB.InputBegan:Connect(function(i) if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name:find("Touch") then vDir = -1 end end)
    dwB.InputEnded:Connect(function() vDir = 0 end)
    scrB.MouseButton1Click:Connect(function() scriptPanel.Visible = not scriptPanel.Visible if not scriptPanel.Visible then colorPanel.Visible = false end end)

    MakeDraggable(close, menu) MakeDraggable(lock, menu) MakeDraggable(open, openCont)
end

RS.Heartbeat:Connect(ManagePlatform)
task.spawn(function() while true do pcall(CreateUI) task.wait(5) end end)
