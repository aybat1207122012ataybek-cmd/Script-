if getgenv().DeltaX_NightGarden then return end
getgenv().DeltaX_NightGarden = true

local function hex(c)
    return Color3.fromRGB(tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16))
end

local C = {
    bg_deep      = hex("#0A0812"),
    bg_panel     = hex("#1E1328"),
    bg_button    = hex("#7B558A"),
    btn_hover    = hex("#A683B5"),
    btn_press    = hex("#5E3D6E"),
    bg_editor    = hex("#050308"),
    text_main    = hex("#D8C4E5"),
    text_dim     = hex("#A48CB3"),
    accent       = hex("#C5A0B0"),
}

local FF_FREDOKA = pcall(function()
    return Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end) and Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) or nil
local FF_CODE = Enum.Font.RobotoMono

local COLOR_KEYS  = {"hue","saturation","spectrum","rainbow","gradient","colorbar","huebar"}
local SLIDER_KEYS = {"slider","thumb","knob","handle","dragger"}
local function hasUIGradient(obj) return obj:FindFirstChildOfClass("UIGradient") ~= nil end
local function isColorPicker(obj)
    local n = obj.Name:lower()
    for _, k in ipairs(COLOR_KEYS)  do if n:find(k) then return true end end
    for _, k in ipairs(SLIDER_KEYS) do if n:find(k) then return true end end
    if hasUIGradient(obj) then return true end
    if obj:IsA("ImageLabel") and obj.Image ~= "" then
        local ok, sz = pcall(function() return obj.AbsoluteSize end)
        if ok and (sz.X > 200 or sz.Y > 20) then return true end
    end
    return false
end
local function shouldSkip(obj)
    if isColorPicker(obj) then return true end
    local p = obj.Parent; if p and isColorPicker(p) then return true end
    return false
end

local IGNORE_TEXTS = {"скрипт хаб", "главный дом", "облако скриптов"}
local function shouldIgnoreButton(obj)
    if not obj:IsA("TextButton") then return false end
    local txt = obj.Text:lower()
    for _, v in ipairs(IGNORE_TEXTS) do if txt:find(v) then return true end end
    return false
end

local function isForeignColor(color)
    if not color then return false end
    local r,g,b = color.R, color.G, color.B
    if b > r+0.08 and b > g+0.08 then return true end
    if math.abs(r-g)<0.1 and math.abs(g-b)<0.1 and r>0.12 and r<0.88 then return true end
    if r>0.85 and g>0.85 and b>0.85 then return true end
    return false
end

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local function FindDeltaGui()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local hasExecute, hasClear = false, false
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextButton") then
                    local t = d.Text:upper()
                    if t:find("EXECUTE") then hasExecute = true end
                    if t:find("CLEAR")   then hasClear   = true end
                end
            end
            if hasExecute and hasClear then return gui end
            if gui.Name:match("[^%w_]") then return gui end
        end
    end
    return nil
end

local function paintOne(obj)
    if not obj:IsA("GuiObject") then return end
    if shouldSkip(obj) or shouldIgnoreButton(obj) then return end

    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        obj.AutoButtonColor = false
        obj.BackgroundColor3 = C.bg_button
        if obj:IsA("TextButton") then
            obj.TextColor3 = C.text_main
            if FF_FREDOKA then pcall(function() obj.FontFace = FF_FREDOKA end) end
        end
    elseif obj:IsA("TextBox") then
        obj.BackgroundColor3 = C.bg_panel
        obj.TextColor3 = C.text_main
        if FF_FREDOKA then pcall(function() obj.FontFace = FF_FREDOKA end) end
    elseif obj:IsA("TextLabel") then
        obj.TextColor3 = C.text_main
        if FF_FREDOKA then pcall(function() obj.FontFace = FF_FREDOKA end) end
    elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
        local n = obj.Name:lower()
        if n:find("console") or n:find("output") or n:find("log") then
            obj.BackgroundColor3 = C.bg_panel
        elseif n:find("tab") or n:find("bar") or n:find("header") then
            obj.BackgroundColor3 = C.bg_panel
        else
            obj.BackgroundColor3 = C.bg_deep
        end
        if obj:IsA("ScrollingFrame") then
            pcall(function()
                obj.ScrollBarImageColor3 = C.accent
                obj.ScrollBarThickness = 4
            end)
        end
    elseif obj:IsA("ImageLabel") and obj.Image ~= "" then
        local ok, sz = pcall(function() return obj.AbsoluteSize end)
        if ok and sz.X <= 48 and sz.Y <= 48 then
            obj.ImageColor3 = C.accent
            obj.BackgroundTransparency = 1
        end
    end
    for _, ch in ipairs(obj:GetChildren()) do
        if ch:IsA("UIStroke") then ch.Color = C.accent end
    end
end

local function paintAll(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        pcall(paintOne, obj)
    end
end

local function replaceEditByCao(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextBox") then
            local ok, pt = pcall(function() return obj.PlaceholderText end)
            if ok and pt == "Edit by Cáo Mod" then
                obj.PlaceholderText = "Thank you for using Delta <3\nby AYBAT_ATAYBEK"
                obj.PlaceholderColor3 = C.text_dim
                obj.Font = FF_CODE
                obj.TextSize = 14
                obj.MultiLine = true
                obj.ClearTextOnFocus = false
                obj.TextXAlignment = Enum.TextXAlignment.Left
                obj.TextYAlignment = Enum.TextYAlignment.Top
            end
        end
    end
end

local locked = {}
local function lockObject(obj)
    if not obj:IsA("GuiObject") then return end
    if shouldSkip(obj) or shouldIgnoreButton(obj) then return end
    if locked[obj] then return end
    locked[obj] = true

    obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
        if shouldSkip(obj) then return end
        local ok, bg = pcall(function() return obj.BackgroundColor3 end)
        if ok and isForeignColor(bg) then
            task.defer(function()
                pcall(function()
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        obj.BackgroundColor3 = C.bg_button
                    elseif obj:IsA("TextBox") then
                        obj.BackgroundColor3 = C.bg_panel
                    elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                        local n = obj.Name:lower()
                        obj.BackgroundColor3 = (n:find("console") or n:find("output")) and C.bg_panel or C.bg_deep
                    end
                end)
            end)
        end
    end)

    if obj:IsA("TextButton") or obj:IsA("TextLabel") or obj:IsA("TextBox") then
        obj:GetPropertyChangedSignal("TextColor3"):Connect(function()
            local ok, tx = pcall(function() return obj.TextColor3 end)
            if ok and isForeignColor(tx) then
                task.defer(function() pcall(function() obj.TextColor3 = C.text_main end) end)
            end
        end)
    end
end

local function applyLocks(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        pcall(lockObject, obj)
    end
end

local function startWatchdog(gui)
    task.spawn(function()
        while gui and gui.Parent do
            task.wait(0.8)
            for _, obj in ipairs(gui:GetDescendants()) do
                if shouldSkip(obj) or shouldIgnoreButton(obj) then continue end
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local ok, bg = pcall(function() return obj.BackgroundColor3 end)
                    if ok and isForeignColor(bg) then
                        pcall(function() obj.BackgroundColor3 = C.bg_button end)
                    end
                end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    local ok, tx = pcall(function() return obj.TextColor3 end)
                    if ok and isForeignColor(tx) then
                        pcall(function() obj.TextColor3 = C.text_main end)
                    end
                end
            end
        end
    end)
end

local function loadExternalModules()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau"))()
    end)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua'))()
    end)
end

getgenv().image              = "79894686093927"
getgenv().sidebar_settings   = ""
getgenv().sidebar_scripthub  = ""
getgenv().sidebar_home       = ""
getgenv().sidebar_executor   = ""
getgenv().sidebar_console    = ""

local function onGuiReady(gui)
    -- Загружаем внешние модули сначала
    task.spawn(loadExternalModules)
    
    -- Даём им время на полную загрузку (1.5 секунды)
    task.wait(1.5)
    
    -- Теперь применяем покраску и замену placeholder
    paintAll(gui)
    replaceEditByCao(gui)
    applyLocks(gui)
    startWatchdog(gui)
    
    -- Повторная покраска через 0.5 секунды для подстраховки
    task.delay(0.5, function()
        if gui and gui.Parent then
            paintAll(gui)
            replaceEditByCao(gui)
        end
    end)

    -- Следим за новыми объектами
    gui.DescendantAdded:Connect(function(obj)
        task.defer(function()
            pcall(paintOne, obj)
            if obj:IsA("TextBox") then
                local ok, pt = pcall(function() return obj.PlaceholderText end)
                if ok and pt == "Edit by Cáo Mod" then
                    obj.PlaceholderText = "Thank you for using Delta <3\nby AYBAT_ATAYBEK"
                    obj.PlaceholderColor3 = C.text_dim
                end
            end
            pcall(lockObject, obj)
            for _, ch in ipairs(obj:GetDescendants()) do
                pcall(paintOne, ch)
                pcall(lockObject, ch)
            end
        end)
    end)
end

local deltaGui = FindDeltaGui()
local startTime = os.clock()
while not deltaGui and os.clock() - startTime < 15 do
    task.wait(0.3)
    deltaGui = FindDeltaGui()
end

if deltaGui then
    task.spawn(onGuiReady, deltaGui)
else
    warn("Delta X GUI not found")
end
