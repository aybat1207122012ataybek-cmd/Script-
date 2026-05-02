-- ╔══════════════════════════════════════════════╗
-- ║         DANDY PLATFORM GUI  v4.5             ║
-- ║              by @AYBAT_ATAYBEK               ║
-- ╚══════════════════════════════════════════════╝

if not game:IsLoaded() then game.Loaded:Wait() end

-- ══════════════════════════════════════════
--  КОНСОЛЬ-ПРИВЕТСТВИЕ
-- ══════════════════════════════════════════
local function PrintWelcome()
    print([[
[AYBAT]-
                    ,,                     ,,                
                    ,,                   ,,"                 
                    ,,^                ,,,,                  
                    ,,,              ^,,,,                   
                    ,,,;           :,,,,:                    
                   ,,,,,          ,,,,,,                     
                   ,,,,,,      ,,,,,,,,                      
                   ,,,",,,,,,,,,,,  ,,,                      
  ,,"              ,,,  ",,,,,,,,;  ,,,"                     
    ,,,           ;,,, :,,,,,,,,,,,,,,,,,,;                  
      ,,,,        ,,,,,,,,,,!    :,,,,,,,,,,,,,,,,,,,,,,,,,,,
       ,,,,,,,,:,,,,,,,,             ",,,: ",:,,,,,,,,,      
         ,,,,,,,,,,,,,:               :,,,, ,,,,,            
           ,,,,  :,,,                   ,,,,,,"              
            ,,,, ,,,:                   ,,,,,,               
             ;,,,,,,                     ,,,,,,              
              :,,,,,                     ,,,,,,,             
               ,,,,,,                   ",,, ,,,,            
              ,,,:,,,!                  ,,,:  :,,,"          
           ,,,,,, ",,,"               ^,,,,,,,,,,,,,         
     ,,,,,,,,,,,:, :,,,,             ,,,,,,,,,,,,,,,,,       
,,,,,,,,,,,,,,,,,,,,,,,,,,,:"   ,",,,,,,,,,       ^,,,,:     
                  !,,,,,,,,,,,,,,,,,,; ,,,            ,,,    
                     :,,,  !,",,,,,," :,,,               ,,  
                      ,,,  ,,,,,,,,,,,",,"                   
                      ,,,,,,,,      ,,,,,^                   
                     ,,,,,,          ,,,,                    
                    ,,,,,I           ,,,,                    
                   :,,,"              ,,,                    
                  ",,"                ",,                    
                 ,,:                   ,,                    
                ,"                     ,,                    
                                       ;,                    
]])
    print("[AYBAT]- хей удачного вождение моим скриптом!(*^^*)")
end

PrintWelcome()

-- ══════════════════════════════════════════
--  КЭШ СТАНДАРТНОЙ БИБЛИОТЕКИ
-- ══════════════════════════════════════════
local mAbs   = math.abs
local mClamp = math.clamp
local mRound = math.round
local sFmt   = string.format
local sGsub  = string.gsub
local sSub   = string.sub

-- ══════════════════════════════════════════
--  СЕРВИСЫ
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local SP      = game:GetService("SoundService")
local Debris  = game:GetService("Debris")
local TweenS  = game:GetService("TweenService")
local lp      = Players.LocalPlayer

-- ══════════════════════════════════════════
--  СОСТОЯНИЯ
-- ══════════════════════════════════════════
_G.GuiLocked = false
_G.PlatColor = Color3.fromRGB(163, 162, 165)

local vDir = 0
local plat = nil

-- ══════════════════════════════════════════
--  ШРИФТ — AmaticSC Bold
-- ══════════════════════════════════════════
local mainFont = Font.new(
    "rbxasset://fonts/families/AmaticSC.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal
)

-- ══════════════════════════════════════════
--  TWEEN КОНСТАНТЫ
-- ══════════════════════════════════════════
local tweenPress   = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenRelease = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ══════════════════════════════════════════
--  ЗВУК КЛИКА
-- ══════════════════════════════════════════
local function PlayClick()
    local s = Instance.new("Sound", SP)
    s.SoundId = "rbxassetid://552900451"
    s.Volume  = 0.8
    s:Play()
    Debris:AddItem(s, 1)
end

-- ══════════════════════════════════════════
--  АНИМАЦИЯ КНОПКИ
-- ══════════════════════════════════════════
local DEBOUNCE = 0.12

local function animBtn(btn)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position    = UDim2.new(0.5, 0, 0.5, 0)

    local tweenDown = TweenS:Create(btn, tweenPress, {
        BackgroundTransparency = 0.05,
        Size = UDim2.new(0.84, 0, 0.84, 0),
    })
    local tweenUp = TweenS:Create(btn, tweenRelease, {
        BackgroundTransparency = 0.4,
        Size = UDim2.new(1, 0, 1, 0),
    })

    local pressing = false
    local lastTime = 0

    local function onPress()
        local now = tick()
        if pressing or (now - lastTime) < DEBOUNCE then return end
        pressing = true
        tweenUp:Cancel()
        tweenDown:Play()
    end

    local function onRelease()
        if not pressing then return end
        pressing = false
        lastTime = tick()
        tweenDown:Cancel()
        tweenUp:Play()
    end

    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            onPress()
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            onRelease()
        end
    end)
    btn.MouseLeave:Connect(onRelease)
end

-- ══════════════════════════════════════════
--  ПЛАТФОРМА
-- ══════════════════════════════════════════
local lastRootY   = nil
local platOffset  = -3.5

local TELEPORT_DELTA = 8
local PLAT_FOOT_OFF  = 3.5

local function ManagePlatform()
    local char = lp.Character
    if not char then lastRootY = nil; return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then lastRootY = nil; return end

    local rootY = root.Position.Y

    if vDir == 0 and (not plat or not plat.Parent) then
        lastRootY = rootY
        return
    end

    if not plat or not plat.Parent then
        plat              = Instance.new("Part")
        plat.Name         = "BasePart"
        plat.Parent       = workspace
        plat.Size         = Vector3.new(14, 1, 14)
        plat.Anchored     = true
        plat.CanCollide   = true
        plat.Transparency = 0.5
        plat.CFrame = CFrame.new(
            root.Position.X,
            rootY - PLAT_FOOT_OFF,
            root.Position.Z
        )
        platOffset = -PLAT_FOOT_OFF
        lastRootY  = rootY
        return
    end

    plat.Color = _G.PlatColor

    local currentOffset = plat.Position.Y - rootY

    if lastRootY and mAbs(rootY - lastRootY) > TELEPORT_DELTA then
        plat.CFrame = CFrame.new(
            root.Position.X,
            rootY + platOffset,
            root.Position.Z
        )
        lastRootY = rootY
        return
    end

    platOffset = currentOffset
    lastRootY  = rootY

    local targetY = plat.Position.Y + (vDir * 0.8)

    if (rootY - targetY) > 5 then
        targetY = rootY - PLAT_FOOT_OFF
    end

    plat.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
end

-- ══════════════════════════════════════════
--  UI ХЕЛПЕРЫ
-- ══════════════════════════════════════════
local function applyBg(obj)
    obj.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    obj.BackgroundTransparency = 1

    local bgImg = Instance.new("ImageLabel", obj)
    bgImg.Size                   = UDim2.new(1, 0, 1, 0)
    bgImg.Image                  = "rbxassetid://114452497059751"
    bgImg.BackgroundTransparency = 1
    bgImg.ZIndex                 = 1
    Instance.new("UICorner", bgImg).CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke", obj)
    s.Thickness       = 2.2
    s.Color           = Color3.new(0, 0, 0)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode    = Enum.LineJoinMode.Round

    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 10)
end

local function makeBtn(parent, txt, img, sizeY, pos)
    local isPanel = (parent.Name == "scriptPanel")
    local w       = isPanel and 100 or 70

    local f = Instance.new("Frame", parent)
    f.Size     = UDim2.new(0, w, 0, sizeY)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    applyBg(f)

    local b = Instance.new("ImageButton", f)
    b.Size                   = UDim2.new(1, 0, 1, 0)
    b.AnchorPoint            = Vector2.new(0.5, 0.5)
    b.Position               = UDim2.new(0.5, 0, 0.5, 0)
    b.BackgroundTransparency = 0.4
    b.BackgroundColor3       = Color3.fromRGB(30, 30, 30)
    b.ZIndex                 = 2
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    if img then b.Image = "rbxassetid://" .. img end

    if txt then
        local t = Instance.new("TextLabel", b)
        t.Size                   = UDim2.new(1, -4, 1, 0)
        t.Position               = UDim2.new(0, 2, 0, 0)
        t.BackgroundTransparency = 1
        t.Text                   = txt
        t.TextColor3             = Color3.new(1, 1, 1)
        t.TextScaled             = true
        t.ZIndex                 = 3
        t.FontFace               = mainFont
        t.Name                   = "TextLabel"
        t.TextStrokeColor3       = Color3.new(0, 0, 0)
        t.TextStrokeTransparency = 0.4
    end

    b.MouseButton1Click:Connect(PlayClick)
    animBtn(b)
    return b
end

local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if _G.GuiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    handle.InputEnded:Connect(function() dragging = false end)
    UIS.WindowFocusReleased:Connect(function() dragging = false end)
end

local function toHex(c)
    return sFmt("#%02X%02X%02X",
        mRound(c.R * 255),
        mRound(c.G * 255),
        mRound(c.B * 255)
    )
end

local function fromHex(hex)
    hex = sGsub(hex, "#", "")
    if #hex ~= 6 then return nil end
    local r = tonumber(sSub(hex, 1, 2), 16)
    local g = tonumber(sSub(hex, 3, 4), 16)
    local b = tonumber(sSub(hex, 5, 6), 16)
    if not r or not g or not b then return nil end
    return Color3.fromRGB(r, g, b)
end

-- ══════════════════════════════════════════
--  ГЛАВНЫЙ UI
-- ══════════════════════════════════════════
local function CreateUI()
    local pg = lp:WaitForChild("PlayerGui", 20)
    if pg:FindFirstChild("Dandy_V45") then return end

    local sg = Instance.new("ScreenGui", pg)
    sg.Name         = "Dandy_V45"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999

    local menu = Instance.new("Frame", sg)
    menu.Size               = UDim2.new(0, 75, 0, 320)
    menu.Position           = UDim2.new(0.05, 0, 0.2, 0)
    menu.BackgroundTransparency = 1

    local openCont = Instance.new("Frame", sg)
    openCont.Size               = UDim2.new(0, 70, 0, 45)
    openCont.Visible            = false
    openCont.BackgroundTransparency = 1

    local scriptPanel = Instance.new("Frame", menu)
    scriptPanel.Name     = "scriptPanel"
    scriptPanel.Size     = UDim2.new(0, 120, 0, 195)
    scriptPanel.Position = UDim2.new(1, 10, 0, 70)
    scriptPanel.Visible  = false
    applyBg(scriptPanel)

    local colorPanel = Instance.new("Frame", scriptPanel)
    colorPanel.Name     = "colorPanel"
    colorPanel.Size     = UDim2.new(0, 320, 0, 160)
    colorPanel.Position = UDim2.new(1, 10, 0, 0)
    colorPanel.Visible  = false
    applyBg(colorPanel)

    local close = makeBtn(menu, "ЗАКРЫТЬ", nil,          30, UDim2.new(0,0,0,0))
    local lock  = makeBtn(menu, "ФИКСИР.", nil,          30, UDim2.new(0,0,0,35))
    local scrB  = makeBtn(menu, "СКРИПТ",  nil,          40, UDim2.new(0,0,0,70))
    local upB   = makeBtn(menu, nil, "100779215956277",  55, UDim2.new(0,0,0,115))
    local dwB   = makeBtn(menu, nil, "88901857737780",   55, UDim2.new(0,0,0,175))
    local open  = makeBtn(openCont, "ОТКРЫТЬ", nil,      45)

    -- ══ COLOUR PICKER ══
    local pickerFrame = Instance.new("Frame", colorPanel)
    pickerFrame.Size             = UDim2.new(0, 140, 0, 100)
    pickerFrame.Position         = UDim2.new(0, 160, 0, 15)
    pickerFrame.BackgroundColor3 = Color3.new(1, 0, 0)
    pickerFrame.BorderSizePixel  = 0
    pickerFrame.ZIndex           = 5
    Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 8)
    local pickerStroke = Instance.new("UIStroke", pickerFrame)
    pickerStroke.Color           = Color3.new(0, 0, 0)
    pickerStroke.Thickness       = 2.2
    pickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local whiteLayer = Instance.new("Frame", pickerFrame)
    whiteLayer.Size             = UDim2.new(1, 0, 1, 0)
    whiteLayer.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteLayer.BorderSizePixel  = 0
    whiteLayer.ZIndex           = 6
    Instance.new("UICorner", whiteLayer).CornerRadius = UDim.new(0, 8)
    local gWhite = Instance.new("UIGradient", whiteLayer)
    gWhite.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })

    local blackLayer = Instance.new("Frame", pickerFrame)
    blackLayer.Size             = UDim2.new(1, 0, 1, 0)
    blackLayer.BackgroundColor3 = Color3.new(0, 0, 0)
    blackLayer.BorderSizePixel  = 0
    blackLayer.ZIndex           = 7
    Instance.new("UICorner", blackLayer).CornerRadius = UDim.new(0, 8)
    local gBlack = Instance.new("UIGradient", blackLayer)
    gBlack.Rotation = 90
    gBlack.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })

    local picker = Instance.new("ImageButton", pickerFrame)
    picker.Size                   = UDim2.new(1, 0, 1, 0)
    picker.BackgroundTransparency = 1
    picker.ZIndex                 = 9
    picker.Image                  = ""
    Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)

    local pickDot = Instance.new("Frame", pickerFrame)
    pickDot.Size             = UDim2.new(0, 10, 0, 10)
    pickDot.AnchorPoint      = Vector2.new(0.5, 0.5)
    pickDot.BackgroundColor3 = Color3.new(1, 1, 1)
    pickDot.ZIndex           = 10
    pickDot.BorderSizePixel  = 0
    Instance.new("UICorner", pickDot).CornerRadius = UDim.new(1, 0)
    local dotStroke = Instance.new("UIStroke", pickDot)
    dotStroke.Color     = Color3.new(0, 0, 0)
    dotStroke.Thickness = 1.5

    local hueS = Instance.new("ImageButton", colorPanel)
    hueS.Size             = UDim2.new(0, 140, 0, 15)
    hueS.Position         = UDim2.new(0, 160, 0, 125)
    hueS.ZIndex           = 5
    hueS.BackgroundColor3 = Color3.new(1, 1, 1)
    hueS.BorderSizePixel  = 0
    Instance.new("UICorner", hueS).CornerRadius = UDim.new(0, 6)
    local hueStroke = Instance.new("UIStroke", hueS)
    hueStroke.Color           = Color3.new(0, 0, 0)
    hueStroke.Thickness       = 2.2
    hueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local g2 = Instance.new("UIGradient", hueS)
    g2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)),
        ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)),
        ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
        ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)),
        ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
        ColorSequenceKeypoint.new(1,    Color3.new(1,0,0)),
    })

    local cH, cS, cV = Color3.toHSV(_G.PlatColor)

    local hexBox = Instance.new("TextBox", colorPanel)
    hexBox.Size                   = UDim2.new(0, 105, 0, 28)
    hexBox.Position               = UDim2.new(0, 15, 0, 95)
    hexBox.BackgroundColor3       = Color3.fromRGB(20, 20, 20)
    hexBox.BackgroundTransparency = 0.3
    hexBox.Text                   = toHex(_G.PlatColor)
    hexBox.TextColor3             = Color3.new(1, 1, 1)
    hexBox.TextScaled             = true
    hexBox.FontFace               = mainFont
    hexBox.ZIndex                 = 5
    hexBox.ClearTextOnFocus       = false
    Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)
    local hexStroke = Instance.new("UIStroke", hexBox)
    hexStroke.Color     = Color3.new(0, 0, 0)
    hexStroke.Thickness = 1.5

    local function updateColor()
        _G.PlatColor                 = Color3.fromHSV(cH, cS, cV)
        pickerFrame.BackgroundColor3 = Color3.fromHSV(cH, 1, 1)
        pickDot.Position             = UDim2.new(cS, 0, 1 - cV, 0)
        hexBox.Text                  = toHex(_G.PlatColor)
    end

    hexBox.FocusLost:Connect(function()
        local col = fromHex(hexBox.Text)
        if col then
            _G.PlatColor = col
            cH, cS, cV  = Color3.toHSV(col)
            pickerFrame.BackgroundColor3 = Color3.fromHSV(cH, 1, 1)
            pickDot.Position             = UDim2.new(cS, 0, 1 - cV, 0)
            hexBox.Text                  = toHex(col)
        else
            hexBox.Text = toHex(_G.PlatColor)
        end
    end)

    local function setupPicker(obj, func)
        local active = false
        local function proc()
            local mp = UIS:GetMouseLocation() - obj.AbsolutePosition - Vector2.new(0, 36)
            func(
                mClamp(mp.X / obj.AbsoluteSize.X, 0, 1),
                mClamp(mp.Y / obj.AbsoluteSize.Y, 0, 1)
            )
        end
        obj.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                active = true
                proc()
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                active = false
            end
        end)
        RS.RenderStepped:Connect(function()
            if active and colorPanel.Visible then
                proc()
                updateColor()
            end
        end)
    end

    setupPicker(hueS,   function(x) cH = x end)
    setupPicker(picker, function(x, y) cS = x; cV = 1 - y end)

    -- ══ СКРИПТЫ ══
    local function addScr(t, p, url)
        makeBtn(scriptPanel, t, nil, 30, p).MouseButton1Click:Connect(function()
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet(url))()
                end)
            end)
        end)
    end
    addScr("NOXIOUS",  UDim2.new(0,10,0,10), "https://raw.githubusercontent.com/bookworming/bookshelf/refs/heads/main/shelf%203/boxten%20sex%20gui.lua")
    addScr("RIDDANCE", UDim2.new(0,10,0,45), "https://raw.githubusercontent.com/riddance-club/script/refs/heads/main/loader.lua")
    addScr("G0BBY",    UDim2.new(0,10,0,80), "https://pastebin.com/raw/FBRnb7S7")

    makeBtn(scriptPanel, "ЦВЕТА", nil, 35, UDim2.new(0,10,0,145)).MouseButton1Click:Connect(function()
        colorPanel.Visible = not colorPanel.Visible
    end)

    makeBtn(colorPanel, "СБРОС", nil, 35, UDim2.new(0,10,0,55)).MouseButton1Click:Connect(function()
        _G.PlatColor = Color3.fromRGB(163, 162, 165)
        cH, cS, cV  = Color3.toHSV(_G.PlatColor)
        updateColor()
    end)

    local credit = Instance.new("TextLabel", colorPanel)
    credit.Size                   = UDim2.new(0, 130, 0, 20)
    credit.Position               = UDim2.new(0, 15, 1, -25)
    credit.BackgroundTransparency = 1
    credit.Text                   = "@AYBAT_ATAYBEK"
    credit.TextColor3             = Color3.fromRGB(180, 180, 180)
    credit.TextScaled             = true
    credit.FontFace               = mainFont
    credit.TextStrokeColor3       = Color3.new(0, 0, 0)
    credit.TextStrokeTransparency = 0.5
    credit.ZIndex                 = 5

    local function showMenu()
        menu.Visible     = true
        openCont.Visible = false
        menu.Position    = openCont.Position
        menu.Size        = UDim2.new(0, 75, 0, 0)
        TweenS:Create(menu, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 75, 0, 320)
        }):Play()
    end

    local function hideMenu()
        TweenS:Create(menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 75, 0, 0)
        }):Play()
        task.delay(0.2, function()
            menu.Visible      = false
            openCont.Visible  = true
            openCont.Position = menu.Position
            menu.Size         = UDim2.new(0, 75, 0, 320)
        end)
    end

    close.MouseButton1Click:Connect(hideMenu)
    open.MouseButton1Click:Connect(showMenu)

    lock.MouseButton1Click:Connect(function()
        _G.GuiLocked = not _G.GuiLocked
        local tl = lock:FindFirstChildOfClass("TextLabel")
        if tl then tl.Text = _G.GuiLocked and "ОТКРЕП." or "ФИКСИР." end
        lock.BackgroundColor3 = _G.GuiLocked
            and Color3.fromRGB(120, 0, 0)
            or  Color3.fromRGB(30, 30, 30)
    end)

    scrB.MouseButton1Click:Connect(function()
        scriptPanel.Visible = not scriptPanel.Visible
        colorPanel.Visible  = false
    end)

    local function setupFlight(btn, dir)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                vDir = dir
            end
        end)
        btn.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                vDir = 0
            end
        end)
        btn.MouseLeave:Connect(function() vDir = 0 end)
    end

    setupFlight(upB,  1)
    setupFlight(dwB, -1)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if menu.Visible then hideMenu() else showMenu() end
        end
    end)

    MakeDraggable(close, menu)
    MakeDraggable(lock,  menu)
    MakeDraggable(open,  openCont)

    updateColor()
end

-- ══════════════════════════════════════════
--  ЗАПУСК
-- ══════════════════════════════════════════
RS.Heartbeat:Connect(ManagePlatform)

task.spawn(function()
    while true do
        pcall(CreateUI)
        task.wait(5)
    end
end)
