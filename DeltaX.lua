-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║   DELTA X – ПОЛНАЯ КАСТОМИЗАЦИЯ (цвета + внешние модули + картинка)      ║
-- ║   Читает USER_COLORS, image, sidebar_* из getgenv()                       ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

if getgenv().DeltaX_Full then return end
getgenv().DeltaX_Full = true

local function hex(c)
    if type(c) == "string" and c:sub(1,1) == "#" then
        return Color3.fromRGB(tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16))
    end
    return c
end

local user = getgenv()
local USER_COLORS = user.USER_COLORS or {}

local C = {
    bg_deep   = hex(USER_COLORS.bg_deep   or "#0A0812"),
    bg_panel  = hex(USER_COLORS.bg_panel  or "#1E1328"),
    bg_button = hex(USER_COLORS.bg_button or "#7B558A"),
    text_main = hex(USER_COLORS.text_main or "#D8C4E5"),
    text_dim  = hex(USER_COLORS.text_dim  or "#A48CB3"),
    accent    = hex(USER_COLORS.accent    or "#C5A0B0"),
}

-- Глобальные настройки (картинка, скрытие иконок)
user.image = user.image or "79894686093927"
user.sidebar_settings  = user.sidebar_settings  or ""
user.sidebar_scripthub = user.sidebar_scripthub or ""
user.sidebar_home      = user.sidebar_home      or ""
user.sidebar_executor  = user.sidebar_executor  or ""
user.sidebar_console   = user.sidebar_console   or ""

-- Шрифты
local FF_FREDOKA = pcall(function()
    return Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
end) and Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal) or nil
local FF_CODE = Enum.Font.RobotoMono

-- Защита color picker
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

-- Игнорируемые кнопки
local IGNORE_TEXTS = {"скрипт хаб", "главный дом", "облако скриптов"}
local function shouldIgnoreButton(obj)
    if not obj:IsA("TextButton") then return false end
    local txt = obj.Text:lower()
    for _, v in ipairs(IGNORE_TEXTS) do if txt:find(v) then return true end end
    return false
end

-- Чужой цвет
local function isForeignColor(color)
    if not color then return false end
    local r,g,b = color.R, color.G, color.B
    if b > r+0.08 and b > g+0.08 then return true end
    if math.abs(r-g)<0.1 and math.abs(g-b)<0.1 and r>0.12 and r<0.88 then return true end
    if r>0.85 and g>0.85 and b>0.85 then return true end
    return false
end

-- Поиск GUI Delta X
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

-- Покраска
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

-- Замена placeholder
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

-- Защита от сброса цветов
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

-- Watchdog
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

-- Внешние модули (кастомизация картинки, скрытие иконок и т.д.)
local function loadExternalModules()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau"))()
    end)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua'))()
    end)
end

-- Основной запуск
local function onGuiReady(gui)
    paintAll(gui)
    replaceEditByCao(gui)
    applyLocks(gui)
    startWatchdog(gui)

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

    task.spawn(loadExternalModules)
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
