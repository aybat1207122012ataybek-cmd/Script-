-- ═══════════════════════════════════════════════════════════════════════
--  ██████   АНТИ-СТИЛЛЕР, АНТИ-ЛОГГЕР, АНТИ-КИК  v21.2 Stable
--  (MAYFIVE HARDCORE) – полный код для GitHub
-- ═══════════════════════════════════════════════════════════════════════

if getgenv().DIMSTAT_ANTILOGGER_LOADED then return end
getgenv().DIMSTAT_ANTILOGGER_LOADED = true

-- Настройки
getgenv().savestats = true
getgenv().makestatsprogress = true
getgenv().image = "92183639335397"
getgenv().sidebar_settings = ""
getgenv().sidebar_scripthub = "77403645809985"
getgenv().sidebar_home = ""
getgenv().sidebar_executor = "103439923366302"
getgenv().sidebar_console = "79462817985070"

getgenv()._blockwebhook = true
getgenv()._strict = false
getgenv()._sanitize_ip = true
getgenv()._log_blocks = true
getgenv()._notifyAll = false
getgenv()._anti_kick = true

-- Загрузка внешних модулей
local HttpServiceRaw = game:GetService("HttpService")
pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau"))() end)
pcall(function()
    if hookfunction then
        local oldPrint = hookfunction(print, function() end)
        local oldWarn = hookfunction(warn, function() end)
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))() end)
        pcall(hookfunction, print, oldPrint)
        pcall(hookfunction, warn, oldWarn)
    else
        loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))()
    end
end)
_G.card = "Bassie"
pcall(function()
    local cfg = HttpServiceRaw:JSONDecode(game:HttpGet("https://pastebin.com/raw/3xHYFifb"))
    for _, char in ipairs(cfg.characters) do
        if char.name:lower() == "bassie" then loadstring(game:HttpGet(char.script))() break end
    end
end)

-- Инициализация сервисов
local LINE = string.rep("═", 27)
local cloneref = cloneref or function(o) return o end
local realGame = cloneref(game)
local HttpService = cloneref(game:GetService("HttpService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local sfind, slower, smatch, gsub, ssub = string.find, string.lower, string.match, string.gsub, string.sub
local rnd = math.random

-- Водяной знак и touch zoom
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local WATCHED = setmetatable({}, { __mode = "k" })

local function replaceWatermark(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextBox") then
            local ok, val = pcall(function() return obj.PlaceholderText end)
            if ok and val and (val == "Edit by Cáo Mod" or val:find("Edit by") or val:find("Cáo Mod")) then
                obj.PlaceholderText = "Thank you for using Delta <3\nby AYBAT_ATAYBEK"
            end
        end
    end
end
local function startWatermarkWatchdog(gui)
    if WATCHED[gui] then return end; WATCHED[gui] = true
    task.spawn(function() while gui and gui.Parent do pcall(replaceWatermark, gui) task.wait(2) end; WATCHED[gui] = nil end)
end
local function looksLikeDeltaGui(gui)
    local hasExecute, hasClear = false, false
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") then
            local t = d.Text:upper()
            if t:find("EXECUTE") then hasExecute = true elseif t:find("CLEAR") then hasClear = true end
            if hasExecute and hasClear then break end
        end
    end
    return (hasExecute and hasClear) or gui.Name:match("[^%w_]") ~= nil
end
local function applyToAllDeltaGuis()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and looksLikeDeltaGui(gui) then pcall(replaceWatermark, gui) startWatermarkWatchdog(gui) return gui end
    end
end
task.spawn(function() while true do if applyToAllDeltaGuis() then break end task.wait(1) end end)
CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") then task.wait(0.5) if looksLikeDeltaGui(child) then pcall(replaceWatermark, child) startWatermarkWatchdog(child) end end
end)
if not getgenv().TOUCH_ZOOM_LOADED then
    getgenv().TOUCH_ZOOM_LOADED = true
    if UIS.TouchEnabled then
        local touchData = { touch1 = nil, touch2 = nil, pos1 = nil, pos2 = nil, lastDistance = 0 }
        local ZOOM_SENSITIVITY = 0.5; local MIN_ZOOM, MAX_ZOOM = 10, 120; local MIN_ZOOM_DELTA = 10; local ZOOM_SPEED_MULTIPLIER = 0.05
        local function getDistance(p1, p2) if not p1 or not p2 then return 0 end; local dx, dy = p1.x - p2.x, p1.y - p2.y; return math.sqrt(dx * dx + dy * dy) end
        local function applyZoom(delta) if math.abs(delta) <= MIN_ZOOM_DELTA then return end; local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = math.clamp(cam.FieldOfView - (delta * ZOOM_SPEED_MULTIPLIER * ZOOM_SENSITIVITY), MIN_ZOOM, MAX_ZOOM) end end
        local function onTouchInput(input, inputType)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            if inputType == "began" then
                if not touchData.touch1 then touchData.touch1, touchData.pos1 = input, input.Position
                elseif not touchData.touch2 then touchData.touch2, touchData.pos2 = input, input.Position; touchData.lastDistance = getDistance(touchData.pos1, touchData.pos2) end
            elseif inputType == "changed" then
                if touchData.touch1 == input then touchData.pos1 = input.Position end
                if touchData.touch2 == input then touchData.pos2 = input.Position end
                if touchData.touch2 and touchData.pos1 and touchData.pos2 then
                    local dist = getDistance(touchData.pos1, touchData.pos2)
                    if math.abs(dist - touchData.lastDistance) > 0.1 then applyZoom(dist - touchData.lastDistance); touchData.lastDistance = dist end
                end
            elseif inputType == "ended" then
                if touchData.touch1 == input then touchData.touch1, touchData.pos1 = touchData.touch2, touchData.pos2; touchData.touch2, touchData.pos2 = nil, nil
                elseif touchData.touch2 == input then touchData.touch2, touchData.pos2 = nil, nil end
                if not touchData.touch1 then touchData.lastDistance = 0 end
            end
        end
        UIS.InputBegan:Connect(function(input, gp) if not gp then onTouchInput(input, "began") end end)
        UIS.InputChanged:Connect(function(input, gp) if not gp then onTouchInput(input, "changed") end end)
        UIS.InputEnded:Connect(function(input) onTouchInput(input, "ended") end)
    end
end

-- Анти-кик
local STATS = { blocked = 0, cookie = 0, webhook = 0, logger = 0, sanitized = 0, scanned = 0, kicksBlocked = 0 }
local function notifyBlock(kind) end
if getgenv()._anti_kick then
    local p = player
    pcall(function()
        local kickOld = p.Kick; local destroyOld = p.Destroy
        if hookfunction then
            hookfunction(p.Kick, newcclosure(function(self, ...)
                if self == p and not checkcaller() then STATS.kicksBlocked = STATS.kicksBlocked + 1; notifyBlock("KICK BLOCKED"); return end
                return kickOld(self, ...)
            end))
            hookfunction(p.Destroy, newcclosure(function(self, ...)
                if self == p and not checkcaller() then STATS.kicksBlocked = STATS.kicksBlocked + 1; notifyBlock("KICK BLOCKED"); return end
                return destroyOld(self, ...)
            end))
        else
            p.Kick = function(self, ...) if self == p and not checkcaller() then STATS.kicksBlocked = STATS.kicksBlocked + 1; notifyBlock("KICK BLOCKED"); return end; return kickOld(self, ...) end
            p.Destroy = function(self, ...) if self == p and not checkcaller() then STATS.kicksBlocked = STATS.kicksBlocked + 1; notifyBlock("KICK BLOCKED"); return end; return destroyOld(self, ...) end
        end
    end)
end

-- Базовые функции
local function urlDecode(s)
    if type(s) ~= "string" then return s end
    local ok, out = pcall(function() return (gsub(s, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)) end)
    return ok and out or s
end
local function getHost(url)
    if type(url) ~= "string" then return "" end
    local rest = gsub(url, "^%w[%w%+%.%-]*://", ""); local authority = smatch(rest, "^([^/?#]+)") or rest
    authority = smatch(authority, "@(.+)$") or authority; local host = smatch(authority, "^([^:]+)") or authority
    host = gsub(host, "%.$", ""); return slower(host)
end
local function fakeIP(v6)
    if v6 then return ("fd00:%x:%x:%x:%x:%x:%x:%x"):format(rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff)) end
    local a = rnd(1,223); if a == 127 then a = 128 end
    return ("%d.%d.%d.%d"):format(a, rnd(0,255), rnd(0,255), rnd(0,254))
end
local function loadCustomAsset(fileName) if getcustomasset then return getcustomasset(fileName) else return "rbxasset://" .. fileName end end

-- Уведомление (56×56) с анимацией нажатия
local lastNotificationTime = {}; local activeNotifications = {}
local function removeNotification(gui) for i, v in ipairs(activeNotifications) do if v == gui then table.remove(activeNotifications, i); break end end end
local function showCustomNotification(titleText, descriptionText, groupId)
    if getgenv()._silent then return end; local now = tick()
    if lastNotificationTime[groupId] and (now - lastNotificationTime[groupId]) < 3 then return end; lastNotificationTime[groupId] = now
    if #activeNotifications >= 5 then pcall(function() activeNotifications[1]:Destroy() end) end
    local playerGui = player:WaitForChild("PlayerGui"); local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AntiLogger_" .. groupId .. "_" .. now; screenGui.DisplayOrder = 9
    screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; screenGui.Parent = playerGui
    table.insert(activeNotifications, screenGui)
    local WIDTH, HEIGHT = 340, 85; local toastFrame = Instance.new("Frame")
    toastFrame.Name = "Toast"; toastFrame.Size = UDim2.new(0, WIDTH, 0, HEIGHT); toastFrame.AnchorPoint = Vector2.new(1, 0)
    toastFrame.Position = UDim2.new(1, WIDTH, 0, 5); toastFrame.BackgroundTransparency = 1; toastFrame.Parent = screenGui
    local clickArea = Instance.new("TextButton"); clickArea.Size = UDim2.new(1, 0, 1, 0); clickArea.BackgroundTransparency = 1
    clickArea.Text = ""; clickArea.AutoButtonColor = false; clickArea.Parent = toastFrame
    local background = Instance.new("ImageLabel"); background.AnchorPoint = Vector2.new(0.5, 0.5); background.BackgroundTransparency = 1
    background.Image = "rbxassetid://88739436092554"; background.Position = UDim2.new(0.5, 0, 0.5, 0)
    background.Size = UDim2.new(1.058, 0, 1.028, 0); background.ZIndex = 1; background.Parent = toastFrame
    local contentContainer = Instance.new("Frame"); contentContainer.Size = UDim2.new(0.9, 0, 0.8, 0)
    contentContainer.Position = UDim2.new(0.05, 0, 0.1, 0); contentContainer.BackgroundTransparency = 1; contentContainer.Parent = background
    local contentLayout = Instance.new("UIListLayout"); contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center; contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.Padding = UDim.new(0, 12); contentLayout.Parent = contentContainer
    local icon = Instance.new("ImageLabel"); icon.Size = UDim2.new(0, 56, 0, 56); icon.BackgroundTransparency = 1
    icon.Image = loadCustomAsset("Unverified.png"); icon.ScaleType = Enum.ScaleType.Fit; icon.ZIndex = 2; icon.Parent = contentContainer
    local textContainer = Instance.new("Frame"); textContainer.Size = UDim2.new(1, -68, 0, 1); textContainer.BackgroundTransparency = 1; textContainer.Parent = contentContainer
    local textLayout = Instance.new("UIListLayout"); textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.VerticalAlignment = Enum.VerticalAlignment.Center; textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder; textLayout.Parent = textContainer
    local title = Instance.new("TextLabel"); title.Size = UDim2.new(1, 0, 0, 26); title.BackgroundTransparency = 1
    title.Font = Enum.Font.FredokaOne; title.RichText = true; title.Text = titleText; title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true; title.TextXAlignment = Enum.TextXAlignment.Left; title.TextYAlignment = Enum.TextYAlignment.Bottom; title.ZIndex = 2; title.Parent = textContainer
    Instance.new("UIStroke", title).Thickness = 1.46
    local description = Instance.new("TextLabel"); description.Size = UDim2.new(1, 0, 0, 36); description.BackgroundTransparency = 1
    description.Font = Enum.Font.FredokaOne; description.RichText = true; description.Text = descriptionText; description.TextColor3 = Color3.new(1, 1, 1)
    description.TextTransparency = 0.5; description.TextScaled = true; description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top; description.ZIndex = 2; description.Parent = textContainer
    local descStroke = Instance.new("UIStroke", description); descStroke.Thickness = 1.1; descStroke.Transparency = 0.5
    local scale = Instance.new("UIScale"); scale.Scale = 1; scale.Parent = toastFrame
    toastFrame.Position = UDim2.new(1, WIDTH, 0, 5); scale.Scale = 0.9
    TweenService:Create(toastFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -10, 0, 5)}):Play()
    TweenService:Create(scale, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    clickArea.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
    end)
    clickArea.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
    end)
    local function closeNotification()
        TweenService:Create(toastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, WIDTH, 0, 5)}):Play()
        TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9}):Play()
        task.wait(0.4)
        pcall(function() screenGui:Destroy() end)
        removeNotification(screenGui)
    end
    clickArea.MouseButton1Click:Connect(closeNotification)
    task.delay(5, closeNotification)
end

-- Белый и чёрный списки
local WHITELIST_BASES = {
    "roblox.com", "rbxcdn.com", "github.com", "githubusercontent.com",
    "pastebin.com", "scriptblox.com", "rscripts.net", "wearedevs.net",
    "api.lua.expert", "lua.expert"
}
local function isWhitelistedHost(host)
    if host == "" then return false end
    for _, base in ipairs(WHITELIST_BASES) do
        if host == base or ssub(host, -(#base + 1)) == "." .. base then return true end
    end
    return false
end
local BLACKLIST = {}
local BLACKLIST_DOMAINS = {
    "grabify.link", "iplogger.org", "cliip.com", "blasze.tk", "stopify.co",
    "goo.by", "2no.co", "yip.su", "leakix.net", "spylogger.net",
    "ip-tracker.org", "ip-tracker.net", "logip.net", "trackip.net",
    "iplogger.com.ua", "iplogger.org.ua", "iplogger.net", "ip-logger.com",
    "leancoding.co", "requestbin.net",
    "ip-api.com", "ipify.org", "api.ipify.org", "ipwho.is", "ipinfo.io",
    "ipgeolocation.io", "ipdata.co", "ipapi.co", "ipstack.com",
    "ip2location.com", "maxmind.com", "db-ip.com", "country.is",
    "ipxapi.com", "radar.io", "whoisxmlapi.com", "geoapify.com",
    "iplocate.com", "iptrackertool.com", "api-ninjas.com", "apifreaks.com",
    "geo.ipify.org", "findip.net", "freeipapi.com", "neutrinoapi.com",
    "hackertarget.com", "api.ip.sb", "ipinfodb.com", "getgeoapi.com",
    "geoplugin.net", "ipregistry.co", "abstractapi.com", "extreme-ip-lookup.com",
    "geolocation-db.com", "checkip.amazonaws.com", "api.myip.com",
    "wtfismyip.com", "icanhazip.com", "ifconfig.me", "ident.me",
    "httpbin.org", "abuseipdb.com", "virustotal.com", "otx.alienvault.com",
    "threatcrowd.com", "urlscan.io", "whatismyipaddress.com", "myip.ms",
    "ip-detect.com", "ipchicken.com", "ip-address.org", "ip-score.com",
    "ipqualityscore.com", "scamalytics.com", "ipscore.com", "ipintel.com",
    "ipblacklist.com", "dnslytics.com", "viewdns.info", "yougetsignal.com",
    "iplocation.net", "geotargeting.com", "geobytes.com", "geocode.com",
    "nominatim.openstreetmap.org", "ipvigilante.com",
    "ip-geolocation.io", "ip-api.io", "ip-info.io", "ip-lookup.net",
    "ip-details.com", "ngrok.io", "trycloudflare.com", "tunnelmole.com",
    "serveo.net", "localhost.run", "bit.ly", "tinyurl.com", "ow.ly",
    "is.gd", "cutt.ly", "tiny.one", "shorturl.at", "rebrand.ly",
    "rb.gy", "buff.ly", "discord.gg", "t.me", "webhook.site",
    "webhook.in", "hookbin.com", "pipedream.com", "zapier.com",
    "make.com", "n8n.cloud", "automate.io", "integromat.com",
    "slack.com", "teams.microsoft.com", "pushbullet.com", "pushover.net",
    "ntfy.sh", "gotify.net", "matrix.org", "discord.com/api/webhooks",
    "discordapp.com/api/webhooks", "telegram.org/bot", "api.telegram.org"
}
for _, domain in ipairs(BLACKLIST_DOMAINS) do BLACKLIST[domain] = true end
local function isBlacklistedHost(host) return BLACKLIST[host] == true end
local function matchBlacklistPatterns(url)
    local patterns = {
        "%.grabify%.", "%.iplogger%.", "%.webhook%.", "%.hookbin%.",
        "%.pipedream%.", "%.zapier%.", "%.integromat%.", "%.automate%.io",
        "api%.telegram%.org/bot", "discord%.com/api/webhooks", "discordapp%.com/api/webhooks",
        "discord%.gg/", "t%.me/", "bit%.ly", "tinyurl%.com", "ow%.ly",
        "is%.gd", "cutt%.ly", "tiny%.one", "shorturl%.at", "rebrand%.ly",
        "rb%.gy", "buff%.ly", "ngrok%.io", "trycloudflare%.com",
        "tunnelmole%.com", "serveo%.net", "localhost%.run",
        "whook", "hook"
    }
    local l = slower(url)
    for _, p in ipairs(patterns) do if smatch(l, p) then return true end end
    return false
end

-- Основная логика анализа
local REAL_COOKIE = nil
do
    for _, g in ipairs({ getgenv().getcookie, getgenv().getcookies, getgenv().get_cookie }) do
        if type(g) == "function" then
            local ok, v = pcall(g)
            if ok and type(v) == "string" and #v > 200 then REAL_COOKIE = v; break end
        end
    end
end
local COOKIE_SIG = "warning:-do-not-share-this."

local function logCompact(tag, url, scriptName)
    warn(LINE)
    warn("[ BLOCK ] " .. tag)
    warn("Time     : " .. os.date("%H:%M"))
    warn("URL      : " .. tostring(url))
    warn("Host     : " .. getHost(urlDecode(url)))
    warn("Script   : " .. tostring(scriptName or "unknown"))
    warn(LINE)
end

function notifyBlock(kind)
    if not getgenv()._log_blocks then return end
    local title, desc, showGui = "", "", false
    if kind == "ROBLOSECURITY BLOCKED" then
        title, desc, showGui = "STEALER DETECTED", "Learn more in the console...", true
    elseif kind == "KICK BLOCKED" then
        title, desc, showGui = "KICK ATTEMPT BLOCKED", "Learn more in the console...", true
    elseif kind == "WEBHOOK BLOCKED" then
        title, desc, showGui = "WEBHOOK BLOCKED", "Learn more in the console...", true
    else
        title, desc = "IP LOGGER DETECTED", "Learn more in the console..."
        showGui = getgenv()._notifyAll
    end
    if showGui then showCustomNotification(title, desc, kind) end
end

local function isIPInUrl(url) return smatch(slower(url), "://%d+%.%d+%.%d+%.%d+") ~= nil end
local function isSuspiciousBody(body)
    if type(body) ~= "string" then return false end
    if #body > 100 and smatch(body, "^[0-9A-Fa-f]+$") then return true end
    return false
end

local function analyzePre(url, body, isPost, headers)
    STATS.scanned = STATS.scanned + 1
    url = type(url) == "string" and url or ""
    local dUrl = urlDecode(url)
    local host = getHost(dUrl)
    local ul = slower(dUrl)
    local bl = slower(type(body) == "string" and urlDecode(body) or "")

    if isIPInUrl(dUrl) then STATS.logger = STATS.logger + 1; return "block", "DIRECT IP BLOCKED" end
    if not sfind(ul, "^https://") and host ~= "" then STATS.logger = STATS.logger + 1; return "block", "UNSECURE HTTP BLOCKED" end
    if isPost and isSuspiciousBody(body) then STATS.logger = STATS.logger + 1; return "block", "SUSPICIOUS BODY BLOCKED" end

    local cookieHit = sfind(bl, COOKIE_SIG, 1, true) or sfind(ul, COOKIE_SIG, 1, true) or (REAL_COOKIE and type(body) == "string" and sfind(body, REAL_COOKIE, 1, true))
    if not cookieHit and headers then
        for _, v in pairs(headers) do
            if type(v) == "string" and sfind(slower(v), COOKIE_SIG, 1, true) then cookieHit = true; break end
        end
    end
    if cookieHit and not isWhitelistedHost(host) then STATS.cookie = STATS.cookie + 1; return "block", "ROBLOSECURITY BLOCKED" end

    if getgenv()._strict and not isWhitelistedHost(host) then STATS.blocked = STATS.blocked + 1; return "block", "SUSPICIOUS HOST BLOCKED" end

    if getgenv()._blockwebhook and isPost and (sfind(ul, "webhook", 1, true) or sfind(ul, "telegram", 1, true) or sfind(ul, "whook", 1, true) or sfind(ul, "hook", 1, true)) then
        STATS.webhook = STATS.webhook + 1; return "block", "WEBHOOK BLOCKED"
    end

    if not getgenv()._strict and isWhitelistedHost(host) then STATS.allowed = STATS.allowed + 1; return "allow" end

    if isBlacklistedHost(host) then STATS.logger = STATS.logger + 1; return "block", "LOGGER BLOCKED" end
    if matchBlacklistPatterns(dUrl) then STATS.logger = STATS.logger + 1; return "block", "LOGGER BLOCKED" end

    STATS.allowed = STATS.allowed + 1
    return "allow"
end

-- Санитизация ответов
local IPV4_PATTERN = "%d+%.%d+%.%d+%.%d+"
local IPV6_PATTERN = "[%x:]+::?[%x:]+"

local function containsIP(data)
    if type(data) == "string" then return smatch(data, IPV4_PATTERN) ~= nil or smatch(data, IPV6_PATTERN) ~= nil
    elseif type(data) == "table" then for _, v in pairs(data) do if containsIP(v) then return true end end end
    return false
end

local function sanitizeResponse(resp)
    if not getgenv()._sanitize_ip then return resp end
    if type(resp) ~= "string" or resp == "" then return resp end

    if not containsIP(resp) then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(resp) end)
        if ok and type(decoded) == "table" and not containsIP(decoded) then return resp end
    end

    local ip4 = fakeIP(false); local ip6 = fakeIP(true)
    local ok, decoded = pcall(function() return HttpService:JSONDecode(resp) end)
    if ok and type(decoded) == "table" then
        local function deepSanitize(t, depth)
            if depth > 5 or type(t) ~= "table" then return end
            for k, v in pairs(t) do
                if type(v) == "string" then t[k] = gsub(v, IPV4_PATTERN, ip4); t[k] = gsub(t[k], IPV6_PATTERN, ip6)
                elseif type(v) == "table" then deepSanitize(v, depth+1) end
            end
        end
        deepSanitize(decoded, 1)
        local encOk, enc = pcall(function() return HttpService:JSONEncode(decoded) end)
        if encOk then return enc end
    end
    resp = gsub(resp, IPV4_PATTERN, ip4); resp = gsub(resp, IPV6_PATTERN, ip6)
    return resp
end

-- HTTP хуки
local function getCallingScript()
    if getcallingscript then
        local scr = getcallingscript()
        if scr and (scr:IsA("Script") or scr:IsA("LocalScript") or scr:IsA("ModuleScript")) then return scr.Name end
    end
    return "unknown"
end

local DENIED = { Success = false, StatusCode = 403, StatusMessage = "Blocked by AntiLogger", Body = "Request blocked by DIMSTAT Anti-Logger v21.2", Headers = {} }

local function handle(kind, isPost, url, body, headers, callReal, scriptName)
    if type(url) ~= "string" or url == "" then return callReal() end
    local action, tag = analyzePre(url, body, isPost, headers)
    if action == "block" then
        STATS.blocked = STATS.blocked + 1; logCompact(tag, url, scriptName); notifyBlock(tag)
        return (kind == "table") and DENIED or ""
    end

    local resp = callReal()
    local rbody = (kind == "table" and type(resp) == "table") and (resp.Body or resp.body) or resp
    if containsIP(rbody) then
        STATS.sanitized = STATS.sanitized + 1; notifyBlock("LOGGER SANITIZED")
        if kind == "table" and type(resp) == "table" then
            local new = {}
            for k, v in pairs(resp) do new[k] = v end
            new.Body = sanitizeResponse(rbody); new.body = new.Body
            return new
        else return sanitizeResponse(rbody) end
    end
    return resp
end

if hookfunction and newcclosure then
    local wrapCC = newcclosure or function(f) return f end
    for method, verb in pairs({HttpGet="GET", HttpGetAsync="GET", HttpPost="POST", HttpPostAsync="POST"}) do
        local orig = realGame[method]
        if type(orig) == "function" then
            local isPost = (verb == "POST")
            local old
            old = hookfunction(orig, wrapCC(function(self, url, arg2, ...)
                if self ~= realGame and self ~= game then return old(self, url, arg2, ...) end
                local body = isPost and arg2 or nil
                local extra = table.pack(arg2, ...)
                local callReal = function() return old(self, table.unpack(extra, 1, extra.n)) end
                return handle("string", isPost, url, body, nil, callReal, getCallingScript())
            end))
        end
    end

    local httpService = cloneref(game:GetService("HttpService"))
    if httpService then
        if httpService.RequestAsync then
            local old = hookfunction(httpService.RequestAsync, wrapCC(function(self, args)
                local url = args.Url or args.URL or ""
                if isBlacklistedHost(getHost(url)) or matchBlacklistPatterns(url) then return DENIED end
                return old(self, args)
            end))
        end
        for method, _ in pairs({GetAsync="GET", PostAsync="POST", RequestAsync="REQUEST"}) do
            local orig = httpService[method]
            if type(orig) == "function" then
                local old
                old = hookfunction(orig, wrapCC(function(self, ...)
                    local args = table.pack(...)
                    local url, body, headers, isPost, kind
                    if method == "RequestAsync" then
                        local opts = args[1]
                        if type(opts) == "table" then
                            url = opts.Url; body = opts.Body; headers = opts.Headers
                            isPost = slower(tostring(opts.Method or "GET")) ~= "get"
                            kind = "table"
                        else return old(self, ...) end
                    else
                        url = args[1]; body = args[2]; isPost = (method == "PostAsync"); kind = "string"
                    end
                    if type(url) ~= "string" or url == "" then return old(self, ...) end
                    local callReal = function() return old(self, table.unpack(args, 1, args.n)) end
                    return handle(kind, isPost, url, body, headers, callReal, getCallingScript())
                end))
            end
        end
    end
end

-- Статистика и завершение
function getStats()
    return {
        uptime = string.format("%.2f сек", tick() - (startTime or tick())),
        blocked = STATS.blocked, allowed = STATS.allowed, scanned = STATS.scanned,
        kicksBlocked = STATS.kicksBlocked, errors = STATS.errors or 0,
        lastBlockedURL = STATS.lastBlockedURL or "", lastBlockedScript = STATS.lastBlockedScript or ""
    }
end
local startTime = tick()

warn(LINE)
warn("Anti-Logger v21.2 Stable loaded")
warn("All core protections active")
warn(LINE)
