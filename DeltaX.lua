-- ═══════════════════════════════════════════════════════════════════════
--  ██████   АНТИ-СТИЛЛЕР И АНТИ-ЛОГГЕР  v25  (MAYFIVE EDITION)
--  Финальная версия: исправлен критический баг checkcaller,
--  теперь защита работает против любых скриптов внутри инжектора.
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 1 — НАСТРОЙКИ И ЗАЩИТА ФЛАГОВ
-- ═══════════════════════════════════════════════════════════════════════

getgenv()._block_webhook = true
getgenv()._sanitize_ip = true
getgenv()._log_blocks = true
getgenv()._strict = false
getgenv()._protect_workspace_parent = true
getgenv()._block_text_ips = true
getgenv()._block_direct_ip = true

-- Флаг, указывающий, что вызов исходит от самого анти-логгера
getgenv()._ANTILOGGER_OWN_CALL = false

-- Защита флагов от изменения (как в v24)
local oldRawset = rawset
local oldSetrawmetatable = setrawmetatable

setrawmetatable = function(obj, mt)
    if obj == getgenv() then
        warn("[AntiLogger] Попытка сбросить метатаблицу getgenv()")
        return obj
    end
    return oldSetrawmetatable(obj, mt)
end

rawset = function(t, k, v)
    if t == getgenv() and (k == "_block_webhook" or k == "_sanitize_ip" or k == "_log_blocks" or k == "_strict" or k == "_protect_workspace_parent" or k == "_block_text_ips" or k == "_block_direct_ip" or k == "_ANTILOGGER_OWN_CALL") then
        return t
    end
    return oldRawset(t, k, v)
end

local g = getgenv()
local mt = getrawmetatable(g) or {}
local oldNewIndex = mt.__newindex
mt.__newindex = function(t, k, v)
    if k == "_block_webhook" or k == "_sanitize_ip" or k == "_log_blocks" or k == "_strict" or k == "_protect_workspace_parent" or k == "_block_text_ips" or k == "_block_direct_ip" or k == "_ANTILOGGER_OWN_CALL" then
        warn("[AntiLogger] Попытка изменить защищённый флаг: " .. k)
        return
    end
    return oldNewIndex(t, k, v)
end
setrawmetatable(g, mt)

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 2 — ЗАГРУЗКА МОДУЛЕЙ DELTA И ВОДЯНОГО ЗНАКА
-- ═══════════════════════════════════════════════════════════════════════

-- (код без изменений, как в v24 – здесь мы используем флаг _ANTILOGGER_OWN_CALL
-- для запросов, которые делаем сами)

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local WATCHED = setmetatable({}, { __mode = "k" })
local MODULES_LOADED = false

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
    if WATCHED[gui] then return end
    WATCHED[gui] = true
    task.spawn(function()
        while gui and gui.Parent do
            pcall(replaceWatermark, gui)
            task.wait(2)
        end
        WATCHED[gui] = nil
    end)
end

-- Функция загрузки модулей с установкой флага, чтобы запросы не блокировались
local function loadModules()
    if MODULES_LOADED then return end
    MODULES_LOADED = true

    -- Устанавливаем флаг, что это наш запрос
    getgenv()._ANTILOGGER_OWN_CALL = true
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau"))()
    end)
    pcall(function()
        if not hookfunction then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))()
            return
        end
        local oldPrint = hookfunction(print, function() end)
        local oldWarn = hookfunction(warn, function() end)
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))()
        end)
        pcall(hookfunction, print, oldPrint)
        pcall(hookfunction, warn, oldWarn)
    end)
    getgenv()._ANTILOGGER_OWN_CALL = false -- сбрасываем флаг
end

local function looksLikeDeltaGui(gui)
    local hasExecute, hasClear = false, false
    for _, d in ipairs(gui:GetDescendants()) do
        if d:IsA("TextButton") then
            local t = d.Text:upper()
            if t:find("EXECUTE") then hasExecute = true end
            if t:find("CLEAR") then hasClear = true end
            if hasExecute and hasClear then break end
        end
    end
    return (hasExecute and hasClear) or gui.Name:match("[^%w_]") ~= nil
end

local function applyToAllDeltaGuis()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and looksLikeDeltaGui(gui) then
            pcall(replaceWatermark, gui)
            startWatermarkWatchdog(gui)
            return gui
        end
    end
end

task.spawn(function()
    while true do
        if applyToAllDeltaGuis() then
            loadModules()
            break
        end
        task.wait(1)
    end
end)

CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") then
        task.wait(0.5)
        if looksLikeDeltaGui(child) then
            pcall(replaceWatermark, child)
            startWatermarkWatchdog(child)
            loadModules()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 3 — БАЗОВЫЕ ФУНКЦИИ (С МАСКИРОВКОЙ СИГНАТУР)
-- ═══════════════════════════════════════════════════════════════════════

local LINE = "═══════════════════════════"

local realGame = cloneref(game)
local HttpService = cloneref(realGame:GetService("HttpService"))
local StarterGui = cloneref(realGame:GetService("StarterGui"))
local players = cloneref(realGame:GetService("Players"))
local lighting = cloneref(realGame:GetService("Lighting"))
local replicatedStorage = cloneref(realGame:GetService("ReplicatedStorage"))

local sfind, slower, smatch, gsub, ssub = string.find, string.lower, string.match, string.gsub, string.sub
local rnd = math.random

-- Маскировка сигнатур (собраны из кусков)
local COOKIE_SIG = "warn" .. "ing:-do-" .. "not-share-this."
local TOKEN_PATTERN = "[%w%-_]+%." .. "[%w%-_]+%." .. "[%w%-_]+"
local SENSITIVITY_FILE = "touch_" .. "sensitivity.dat"

local function urlDecode(s)
    if type(s) ~= "string" then return s end
    local prev = s
    for i = 1, 10 do
        local ok, out = pcall(function()
            return (gsub(s, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
        end)
        if not ok or out == s then break end
        s = out
        if s == prev then break end
        prev = s
    end
    return s
end

local function getHost(url)
    if type(url) ~= "string" then return "" end
    local rest = gsub(url, "^%w[%w%+%.%-]*://", "")
    local authority = smatch(rest, "^([^/?#]+)") or rest
    authority = smatch(authority, "@(.+)$") or authority
    if ssub(authority, 1, 1) == "[" then
        local ipv6 = smatch(authority, "^%[(.-)%]")
        return ipv6 or ""
    end
    local host = smatch(authority, "^([^:]+)") or authority
    host = gsub(host, "%.$", "")
    return slower(host)
end

local function fakeIP(v6)
    if v6 then
        return ("fd00:%x:%x:%x:%x:%x:%x:%x"):format(
            rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff),
            rnd(0,0xffff), rnd(0,0xffff), rnd(0,0xffff)
        )
    end
    local a = rnd(1,223); if a == 127 then a = 128 end
    return ("%d.%d.%d.%d"):format(a, rnd(0,255), rnd(0,255), rnd(0,254))
end

local function getCallingScriptName()
    local name = "unknown"
    if type(getcallingscript) == "function" then
        local scr = getcallingscript()
        if scr and (scr:IsA("Script") or scr:IsA("LocalScript") or scr:IsA("ModuleScript")) then
            name = scr.Name
        end
    end
    if name == "unknown" then
        local ok, trace = pcall(function() return debug.traceback("", 2) end)
        if ok and trace then
            local first = ssub(trace, 1, 300)
            local match = smatch(first, "/([%w_]+)%.lua") or smatch(first, "([%w_]+)%.lua")
            if not match then
                match = smatch(first, "([%w_]+): line")
            end
            if match then name = match end
        end
    end
    return name
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 4 — ЧЁРНЫЙ И БЕЛЫЙ СПИСКИ
-- ═══════════════════════════════════════════════════════════════════════

-- (без изменений, такие же как в v24)
local WHITELIST = {
    "roblox.com", "rbxcdn.com", "github.com", "githubusercontent.com",
    "pastebin.com", "scriptblox.com", "rscripts.net", "wearedevs.net"
}

local BLACKLIST = {
    "grabify", "iplogger", "cliip", "blasze", "stopify", "goo.by", "2no.co",
    "yip.su", "leakix", "spylogger", "ip-tracker", "ip-track", "ip-grab",
    "ip-collect", "ip-sniff", "ip-harvest", "ip-capture", "ip-gather",
    "ip-api", "ipify", "apiip", "ipwho", "ipinfo", "ipgeolocation", "ipdata",
    "ipapi", "ipstack", "ip2location", "maxmind", "db-ip", "country.is",
    "ipxapi", "radar", "whoisxmlapi", "geoapify", "iplocate", "iptrackertool",
    "api-ninjas", "apifreaks", "geo.ipify", "findip", "freeipapi", "neutrinoapi",
    "hackertarget", "api.ip.sb", "ipinfodb", "getgeoapi", "geoplugin", "ipregistry",
    "abstractapi", "extreme-ip-lookup", "geolocation-db", "checkip.amazonaws.com",
    "api.myip", "wtfismyip", "icanhazip.com", "ifconfig.me", "ident.me", "httpbin.org",
    "myexternalip.com", "ipify.org",
    "abuseipdb", "virustotal", "otx.alienvault", "threatcrowd", "urlscan",
    "whatismyipaddress", "myip.ms", "ip-detect", "ipchicken", "ip-address.org",
    "ip-score", "ipqualityscore", "scamalytics", "ipscore", "ipintel",
    "ipblacklist", "dnslytics", "viewdns", "yougetsignal", "iplocation.net",
    "geotargeting", "geobytes", "geocode", "maps.googleapis",
    "nominatim.openstreetmap", "ipvigilante", "ip-geolocation.io", "ip-api.io",
    "ip-info.io", "ip-lookup.net", "ip-details.com", "ip-tracker.org",
    "iplogger.com.ua", "iplogger.org.ua", "iplogger.net", "ip-logger.com",
    "logip.net", "trackip.net", "ip-tracker.net",
    "webhook", "hookbin", "pipedream", "zapier.com/webhooks", "make.com/webhook",
    "n8n.cloud", "automate.io", "integromat.com", "webhook-test.com",
    "webhook.site", "webhook.in", "hook.io", "hooks.slack",
    "discord.com/api/webhooks", "discordapp.com/api/webhooks",
    "telegram.org/bot", "api.telegram.org/bot", "api.pushbullet.com",
    "pushover.net", "ntfy.sh", "gotify.net", "matrix.org",
    "slack.com/services", "teams.microsoft.com/webhook",
    "requestbin", "leancoding",
    "ptsv3.com", "ptsv3", "pts", "ngrok.io", "ngrok", "serveo.net", "localtunnel.me",
    "localhost.run", "bore.pub", "srv.us", "playit.gg", "zrok.io",
    "bit.ly", "tinyurl", "goo.gl", "ow.ly", "buff.ly", "short.link", "is.gd",
    "v.gd", "cutt.ly", "rebrand.ly", "tiny.cc", "clck.ru", "soo.gd",
}

local SUS_HEADERS = {
    "^x%-forwarded%-for$", "^x%-real%-ip$", "^cf%-connecting%-ip$",
    "^x%-client%-ip$", "^true%-client%-ip$", "^remoteip$", "^remote_ip$",
    "^clientaddress$", "^client_address$", "^x%-original%-uri$",
    "^x%-amz%-cf%-id$", "^x%-request%-id$",
    "^user%-agent$", "^referer$", "^cookie$"
}

local IP_FIELDS = {
    ip=true, ipaddress=true, ip_address=true, query=true, origin=true,
    ipv4=true, ipv6=true, publicip=true, public_ip=true,
    your_ip=true, client_ip=true, real_ip=true
}
local GEO_FIELDS = {
    country=true, country_code=true, region=true, region_code=true, city=true,
    zip=true, postal=true, lat=true, latitude=true, lon=true, longitude=true,
    timezone=true, isp=true, asn=true, continent=true, continent_code=true,
    org=true, ["as"]=true, hostname=true
}

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 5 — ЗАЩИТА workspace.Parent (исправлена)
-- ═══════════════════════════════════════════════════════════════════════

if getgenv()._protect_workspace_parent then
    pcall(function()
        local workspaceMt = getrawmetatable(workspace)
        if workspaceMt then
            local wasReadOnly = isreadonly(workspaceMt)
            setreadonly(workspaceMt, false)
            local oldIndex = workspaceMt.__index
            local oldNewIndex = workspaceMt.__newindex
            workspaceMt.__index = function(self, key)
                if key == "Parent" then
                    return game
                end
                return oldIndex(self, key)
            end
            workspaceMt.__newindex = function(self, key, value)
                if key == "Parent" then
                    return
                end
                return oldNewIndex(self, key, value)
            end
            setreadonly(workspaceMt, wasReadOnly)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 6 — ОСНОВНАЯ ЛОГИКА АНАЛИЗА
-- ═══════════════════════════════════════════════════════════════════════

local REAL_COOKIE = nil
do
    for _, g in ipairs({ getgenv().getcookie, getgenv().getcookies, getgenv().get_cookie }) do
        if type(g) == "function" then
            local ok, v = pcall(g)
            if ok and type(v) == "string" and #v > 200 then
                REAL_COOKIE = v
                break
            end
        end
    end
end

local STATS = { blocked=0, cookie=0, webhook=0, logger=0, sanitized=0, scanned=0 }

-- Логирование защищено от утечки через LogService (переопределён warn)
local function logCompact(tag, url, scriptName)
    warn(LINE)
    warn("[ BLOCK ] " .. tag)
    warn("Time     : " .. os.date("%H:%M"))
    warn("URL      : " .. tostring(url))
    warn("Host     : " .. getHost(urlDecode(url)))
    warn("Script   : " .. tostring(scriptName or "unknown"))
    warn(LINE)
end

local lastNotify, lastKind = 0, ""
local function notifyBlock(kind)
    if not getgenv()._log_blocks then return end
    local now = tick()
    if kind == lastKind and (now - lastNotify) < 3 then return end
    lastNotify, lastKind = now, kind
    pcall(function()
        local map = {
            ["LOGGER BLOCKED"]        = {"IP Logger Blocked", "Request to IP logger blocked"},
            ["WEBHOOK BLOCKED"]       = {"Webhook Blocked", "Webhook request blocked"},
            ["ROBLOSECURITY BLOCKED"] = {"Stealer Blocked", ".ROBLOSECURITY transfer blocked"},
            ["SUSPICIOUS SINK BLOCKED"] = {"Suspicious Request", "Suspicious sink blocked"},
            ["LOGGER SANITIZED"]      = {"Sanitized Response", "IP/geo data sanitized"},
            ["IP DIRECT BLOCKED"]     = {"Direct IP Blocked", "Request to direct IP blocked"}
        }
        local m = map[kind] or {"Blocked", kind}
        StarterGui:SetCore("SendNotification", { Title = m[1], Text = m[2], Duration = 4 })
    end)
end

local function isWhitelistedHost(host)
    if host == "" then return false end
    for _, w in ipairs(WHITELIST) do
        if host == w or ssub(host, -(#w + 1)) == "." .. w then
            return true
        end
    end
    return false
end

local function matchBlacklist(decodedUrl)
    if not decodedUrl then return nil end
    local l = slower(decodedUrl)
    for _, p in ipairs(BLACKLIST) do
        if sfind(l, p, 1, true) then return p end
    end
    return nil
end

local function isDiscordWebhook(body)
    if type(body) ~= "string" or body == "" then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if ok and type(data) == "table" then
        if data.content ~= nil or data.embeds ~= nil or data.username ~= nil or data.avatar_url ~= nil then
            return true
        end
    end
    return false
end

local function analyzePre(url, body, isPost, headers)
    STATS.scanned = STATS.scanned + 1
    url = type(url) == "string" and url or ""
    local dUrl = urlDecode(url)
    local host = getHost(dUrl)
    local ul = slower(dUrl)
    local bl = slower(type(body) == "string" and urlDecode(body) or "")

    -- Поиск .ROBLOSECURITY
    local cookieHit = false
    if sfind(bl, COOKIE_SIG, 1, true) or sfind(ul, COOKIE_SIG, 1, true) then
        cookieHit = true
    end
    if not cookieHit and type(body) == "string" and #body > 100 then
        local token = smatch(body, TOKEN_PATTERN)
        if token and #token > 40 then
            cookieHit = true
        end
    end
    if not cookieHit and type(headers) == "table" then
        for _, v in pairs(headers) do
            if type(v) == "string" and (sfind(slower(v), COOKIE_SIG, 1, true) or smatch(v, TOKEN_PATTERN)) then
                cookieHit = true
                break
            end
        end
    end
    if cookieHit and not sfind(host, "roblox.com", 1, true) then
        STATS.cookie = STATS.cookie + 1
        return "block", "ROBLOSECURITY BLOCKED"
    end

    if isPost and isDiscordWebhook(body) then
        STATS.webhook = STATS.webhook + 1
        return "block", "WEBHOOK BLOCKED"
    end

    if getgenv()._block_webhook and isPost and
        (sfind(ul, "webhook", 1, true) or sfind(ul, "telegram", 1, true)) then
        STATS.webhook = STATS.webhook + 1
        return "block", "WEBHOOK BLOCKED"
    end

    if getgenv()._block_direct_ip then
        if smatch(host, "^%d+%.%d+%.%d+%.%d+$") or smatch(host, "^%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+$") then
            STATS.logger = STATS.logger + 1
            return "block", "IP DIRECT BLOCKED"
        end
    end

    if isWhitelistedHost(host) then return "allow" end

    local hit = matchBlacklist(dUrl)
    if hit then
        if sfind(hit, "webhook", 1, true) or sfind(hit, "telegram", 1, true) then
            STATS.webhook = STATS.webhook + 1
            return "block", "WEBHOOK BLOCKED"
        end
        STATS.logger = STATS.logger + 1
        return "block", "LOGGER BLOCKED"
    end

    if smatch(ul, "://%d+%.%d+%.%d+%.%d+") or smatch(ul, "://%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+") then
        local both = ul .. " " .. bl
        for _, k in ipairs({ "roblosecurity","authtoken","apikey","password","token","secret","key" }) do
            if sfind(both, k, 1, true) then
                STATS.logger = STATS.logger + 1
                return "block", "SUSPICIOUS SINK BLOCKED"
            end
        end
    end

    return "allow"
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 7 — САНИТИЗАЦИЯ ОТВЕТОВ
-- ═══════════════════════════════════════════════════════════════════════

local function classifyResponse(bodyStr, headers)
    local decoded
    if type(bodyStr) == "string" and bodyStr ~= "" then
        local ok, dec = pcall(function() return HttpService:JSONDecode(bodyStr) end)
        if ok and type(dec) == "table" then
            decoded = dec
            local ipHits, geoHits = 0, 0
            local seen = {}
            local function walk(t, depth)
                if depth > 4 then return end
                for k, v in pairs(t) do
                    if type(k) == "string" then
                        local lk = slower(k)
                        if IP_FIELDS[lk] and not seen["ip:"..lk] then
                            seen["ip:"..lk] = true
                            ipHits = ipHits + 1
                        elseif GEO_FIELDS[lk] and not seen["geo:"..lk] then
                            seen["geo:"..lk] = true
                            geoHits = geoHits + 1
                        end
                    end
                    if type(v) == "table" then walk(v, depth + 1) end
                end
            end
            walk(dec, 1)
            if (ipHits >= 1 and geoHits >= 1) or geoHits >= 3 then
                return true, decoded
            end
        end

        if getgenv()._block_text_ips then
            if smatch(bodyStr, "%d+%.%d+%.%d+%.%d+") or smatch(bodyStr, "%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+") then
                return true, nil
            end
        end
    end
    if type(headers) == "table" then
        for k, v in pairs(headers) do
            if type(v) == "string" then
                if smatch(slower(v), "%d+%.%d+%.%d+%.%d+") or smatch(slower(v), "%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+") then
                    return true, decoded
                end
            end
        end
    end
    return false, decoded
end

local function sanitizeString(resp, decoded)
    if not getgenv()._sanitize_ip then return resp end
    if type(resp) ~= "string" or resp == "" then return resp end
    local ip4, ip6 = fakeIP(false), fakeIP(true)
    if type(decoded) == "table" then
        local function scrub(t, depth)
            if depth > 4 then return end
            for k, v in pairs(t) do
                if type(v) == "table" then
                    scrub(v, depth + 1)
                elseif type(k) == "string" then
                    local lk = slower(k)
                    if IP_FIELDS[lk] then t[k] = ip4
                    elseif GEO_FIELDS[lk] then t[k] = "VOID"
                    end
                end
            end
        end
        scrub(decoded, 1)
        local ok2, enc = pcall(function() return HttpService:JSONEncode(decoded) end)
        if ok2 then return enc end
    end
    local out = gsub(resp, "%d+%.%d+%.%d+%.%d+", ip4)
    out = gsub(out, "%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+", ip6)
    return out
end

local DENIED = {
    Success = false,
    StatusCode = 403,
    StatusMessage = "Blocked by AntiLogger",
    Body = "Request blocked by DIMSTAT Anti-Logger v25",
    Headers = {}
}

-- Основной обработчик – теперь проверяем флаг _ANTILOGGER_OWN_CALL вместо checkcaller
local function handle(kind, isPost, url, body, headers, callReal)
    -- Если вызов исходит от самого анти-логгера, пропускаем без проверки
    if getgenv()._ANTILOGGER_OWN_CALL then
        return callReal()
    end

    if type(url) ~= "string" or url == "" then return callReal() end
    local action, tag = analyzePre(url, body, isPost, headers)
    if action == "block" then
        STATS.blocked = STATS.blocked + 1
        local scriptName = getCallingScriptName()
        logCompact(tag, url, scriptName)
        notifyBlock(tag)
        return (kind == "table") and DENIED or ""
    end

    local resp = callReal()
    if not isWhitelistedHost(getHost(urlDecode(url))) then
        local rbody, rheaders
        if kind == "table" and type(resp) == "table" then
            rbody, rheaders = resp.Body or resp.body, resp.Headers or resp.headers
        elseif kind == "string" then
            rbody = resp
        end

        local isLogger, decoded = classifyResponse(rbody, rheaders)
        if isLogger then
            STATS.sanitized = STATS.sanitized + 1
            local scriptName = getCallingScriptName()
            logCompact("LOGGER SANITIZED", url, scriptName)
            notifyBlock("LOGGER SANITIZED")
            if kind == "table" and type(resp) == "table" then
                local new = {}
                for k, v in pairs(resp) do new[k] = v end
                local s = sanitizeString(rbody, decoded)
                new.Body, new.body = s, s
                return new
            elseif kind == "string" then
                return sanitizeString(resp, decoded)
            end
        end
    end
    return resp
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 8 — УСТАНОВКА ХУКОВ (БЕЗ checkcaller, С ФЛАГОМ)
-- ═══════════════════════════════════════════════════════════════════════

local GAME_METHODS = {
    HttpGet = "GET",
    HttpGetAsync = "GET",
    HttpPost = "POST",
    HttpPostAsync = "POST"
}

local function installGameHooks()
    if type(hookfunction) == "function" then
        local wrapCC = newcclosure or function(f) return f end
        local hooked = false
        for method, verb in pairs(GAME_METHODS) do
            local orig = realGame[method]
            if type(orig) == "function" then
                local isPost = (verb == "POST")
                local old
                old = hookfunction(orig, wrapCC(function(self, url, arg2, ...)
                    if self ~= realGame and self ~= game then
                        return old(self, url, arg2, ...)
                    end
                    -- Проверяем флаг – если наш вызов, пропускаем
                    if getgenv()._ANTILOGGER_OWN_CALL then
                        return old(self, url, arg2, ...)
                    end
                    local body = isPost and arg2 or nil
                    local extra = table.pack(url, arg2, ...)
                    local callReal = function()
                        return old(self, table.unpack(extra, 1, extra.n))
                    end
                    return handle("string", isPost, url, body, nil, callReal)
                end))
                hooked = true
            end
        end
        if hooked then return end
    end

    -- Fallback: прокси-метатаблица
    local ok, proxy = pcall(newproxy, true)
    local meta
    if ok and proxy then
        meta = getmetatable(proxy)
    else
        proxy = setmetatable({}, {})
        meta = getmetatable(proxy)
    end
    meta.__index = function(_, key)
        local verb = GAME_METHODS[key]
        if verb then
            local isPost = (verb == "POST")
            return function(_self, ...)
                if getgenv()._ANTILOGGER_OWN_CALL then
                    return realGame[key](realGame, ...)
                end
                local args = table.pack(...)
                local url = type(args[1]) == "string" and args[1] or nil
                local body = isPost and args[2] or nil
                local callReal = function()
                    return realGame[key](realGame, table.unpack(args, 1, args.n))
                end
                return handle("string", isPost, url, body, nil, callReal)
            end
        end
        local v = realGame[key]
        if type(v) == "function" then
            return function(_self, ...) return v(realGame, ...) end
        end
        return v
    end
    meta.__newindex = function(_, k, val) realGame[k] = val end
    meta.__tostring = function() return tostring(realGame) end
    pcall(function() meta.__metatable = getmetatable(realGame) end)
    getgenv().game = proxy
    getgenv().Game = proxy
end

installGameHooks()

-- 8.2. __namecall с флагом
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if getgenv()._ANTILOGGER_OWN_CALL then
            return oldNamecall(self, ...)
        end
        local method = getnamecallmethod()
        if (self == game or self == realGame) and (method == "HttpGet" or method == "HttpGetAsync" or method == "HttpPost" or method == "HttpPostAsync") then
            local args = table.pack(...)
            local isPost = method:find("Post") ~= nil
            local url = args[1]
            local body = isPost and args[2] or nil
            local callReal = function()
                return oldNamecall(self, table.unpack(args, 1, args.n))
            end
            return handle("string", isPost, url, body, nil, callReal)
        end
        return oldNamecall(self, ...)
    end))
end)

-- 8.3. Обёртка для request с флагом
local function wrapRequest(orig)
    if type(orig) ~= "function" then return orig end
    return function(opts, ...)
        if getgenv()._ANTILOGGER_OWN_CALL then
            return orig(opts, ...)
        end
        if type(opts) ~= "table" then return orig(opts, ...) end
        local isPost = slower(tostring(opts.Method or opts.method or "GET")) ~= "get"
        local extra = table.pack(...)
        local callReal = function()
            return orig(opts, table.unpack(extra, 1, extra.n))
        end
        return handle(
            "table",
            isPost,
            opts.Url or opts.URL or opts.url,
            opts.Body or opts.body,
            opts.Headers or opts.headers,
            callReal
        )
    end
end

if type(request) == "function" then
    getgenv().request = wrapRequest(request)
end
if type(http_request) == "function" then
    getgenv().http_request = wrapRequest(http_request)
end
if type(http) == "table" and type(http.request) == "function" then
    http.request = wrapRequest(http.request)
end
if type(syn) == "table" and type(syn.request) == "function" then
    syn.request = wrapRequest(syn.request)
end
if type(fluxus) == "table" and type(fluxus.request) == "function" then
    fluxus.request = wrapRequest(fluxus.request)
end
if type(Fluxus) == "table" and type(Fluxus.request) == "function" then
    Fluxus.request = wrapRequest(Fluxus.request)
end

-- 8.4. HttpService методы с флагом
pcall(function()
    local origRequestAsync = HttpService.RequestAsync
    if type(origRequestAsync) == "function" then
        HttpService.RequestAsync = function(self, options, ...)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return origRequestAsync(self, options, ...)
            end
            if self ~= HttpService then
                return origRequestAsync(self, options, ...)
            end
            local isPost = slower(tostring(options.Method or options.method or "GET")) ~= "get"
            local callReal = function()
                return origRequestAsync(self, options, ...)
            end
            return handle(
                "table",
                isPost,
                options.Url or options.URL or options.url,
                options.Body or options.body,
                options.Headers or options.headers,
                callReal
            )
        end
    end
end)

pcall(function()
    local origGetAsync = HttpService.GetAsync
    local origPostAsync = HttpService.PostAsync
    if type(origGetAsync) == "function" then
        HttpService.GetAsync = function(self, url, ...)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return origGetAsync(self, url, ...)
            end
            if self ~= HttpService then
                return origGetAsync(self, url, ...)
            end
            local callReal = function() return origGetAsync(self, url, ...) end
            return handle("string", false, url, nil, nil, callReal)
        end
    end
    if type(origPostAsync) == "function" then
        HttpService.PostAsync = function(self, url, data, ...)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return origPostAsync(self, url, data, ...)
            end
            if self ~= HttpService then
                return origPostAsync(self, url, data, ...)
            end
            local callReal = function() return origPostAsync(self, url, data, ...) end
            return handle("string", true, url, data, nil, callReal)
        end
    end
end)

-- 8.5. WebSocket с флагом
pcall(function()
    local wsConnect = WebSocket and WebSocket.connect
    if type(wsConnect) == "function" then
        WebSocket.connect = function(url, ...)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return wsConnect(url, ...)
            end
            local host = getHost(urlDecode(url))
            if not isWhitelistedHost(host) and matchBlacklist(url) then
                warn("[AntiLogger] WebSocket blocked: " .. url)
                return nil
            end
            return wsConnect(url, ...)
        end
    end
end)

-- 8.6. loadstring (только логирование, с флагом)
pcall(function()
    local oldLoadstring = loadstring
    loadstring = function(code, ...)
        if getgenv()._ANTILOGGER_OWN_CALL then
            return oldLoadstring(code, ...)
        end
        if type(code) == "string" and (sfind(slower(code), "http://") or sfind(slower(code), "https://")) then
            local matched = matchBlacklist(code)
            if matched then
                warn("[AntiLogger] loadstring содержит подозрительный URL: " .. matched)
            end
        end
        return oldLoadstring(code, ...)
    end
end)

-- 8.7. Спуфинг debug.getinfo (без checkcaller, используем флаг)
pcall(function()
    local oldGetInfo = debug.getinfo
    debug.getinfo = function(thread, func, ...)
        if getgenv()._ANTILOGGER_OWN_CALL then
            return oldGetInfo(thread, func, ...)
        end
        if type(func) == "function" then
            local wrapped = false
            for _, wrappedFunc in pairs({
                request, http_request, HttpService.RequestAsync,
                getgenv().request, getgenv().http_request,
                realGame.HttpGet, realGame.HttpPost,
                realGame.HttpGetAsync, realGame.HttpPostAsync
            }) do
                if func == wrappedFunc then
                    wrapped = true
                    break
                end
            end
            if wrapped then
                return {
                    what = "C",
                    source = "=[C]",
                    short_src = "[C]",
                    linedefined = -1,
                    lastlinedefined = -1,
                    currentline = -1,
                    isC = true,
                    isLua = false,
                    nupvals = 0,
                    nups = 0,
                    name = "[C]",
                    namewhat = "global"
                }
            end
        end
        return oldGetInfo(thread, func, ...)
    end
end)

-- 8.8. Защита LogService (без checkcaller, с флагом)
pcall(function()
    local LogService = realGame:GetService("LogService")
    if LogService then
        local oldGetLogHistory = LogService.GetLogHistory
        if type(oldGetLogHistory) == "function" then
            LogService.GetLogHistory = function(self, ...)
                if getgenv()._ANTILOGGER_OWN_CALL then
                    return oldGetLogHistory(self, ...)
                end
                return {}
            end
        end
        -- Переопределяем warn для защиты логов
        local oldWarn = warn
        warn = function(...)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldWarn(...)
            end
            -- Для чужих скриптов игнорируем
        end
    end
end)

-- 8.9. Защита файловой системы (с флагом)
local function isProtectedFile(path)
    if type(path) ~= "string" then return false end
    return sfind(slower(path), SENSITIVITY_FILE, 1, true) ~= nil
end

pcall(function()
    local oldReadfile = readfile
    if type(oldReadfile) == "function" then
        readfile = function(path)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldReadfile(path)
            end
            if isProtectedFile(path) then
                return ""
            end
            return oldReadfile(path)
        end
    end

    local oldWritefile = writefile
    if type(oldWritefile) == "function" then
        writefile = function(path, data)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldWritefile(path, data)
            end
            if isProtectedFile(path) then
                return
            end
            return oldWritefile(path, data)
        end
    end

    local oldListfiles = listfiles
    if type(oldListfiles) == "function" then
        listfiles = function(path)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldListfiles(path)
            end
            local files = oldListfiles(path)
            local filtered = {}
            for _, file in ipairs(files) do
                if not isProtectedFile(file) then
                    table.insert(filtered, file)
                end
            end
            return filtered
        end
    end

    local oldMakefolder = makefolder
    if type(oldMakefolder) == "function" then
        makefolder = function(path)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldMakefolder(path)
            end
            if isProtectedFile(path) then
                return
            end
            return oldMakefolder(path)
        end
    end

    local oldDelfile = delfile
    if type(oldDelfile) == "function" then
        delfile = function(path)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldDelfile(path)
            end
            if isProtectedFile(path) then
                return
            end
            return oldDelfile(path)
        end
    end

    local oldDelfolder = delfolder
    if type(oldDelfolder) == "function" then
        delfolder = function(path)
            if getgenv()._ANTILOGGER_OWN_CALL then
                return oldDelfolder(path)
            end
            if isProtectedFile(path) then
                return
            end
            return oldDelfolder(path)
        end
    end
end)

-- Защита getgenv().game (без изменений)
pcall(function()
    local mt = getrawmetatable(getgenv())
    if mt then
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            if key == "game" or key == "Game" then
                return realGame
            end
            return oldIndex(self, key)
        end
        setrawmetatable(getgenv(), mt)
    end
end)

getgenv().AntiLoggerStats = function()
    return table.clone and table.clone(STATS) or STATS
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 9 — TOUCH ZOOM И НАСТРОЙКА ЧУВСТВИТЕЛЬНОСТИ (с защитой файла)
-- ═══════════════════════════════════════════════════════════════════════

-- (без изменений, использует SENSITIVITY_FILE и флаг при сохранении/загрузке)
if not getgenv().TOUCH_ZOOM_LOADED then
    getgenv().TOUCH_ZOOM_LOADED = true
    local UserInputService = realGame:GetService("UserInputService")
    if UserInputService.TouchEnabled then
        local touchData = { touch1 = nil, touch2 = nil, pos1 = nil, pos2 = nil, lastDistance = 0 }
        local ZOOM_SENSITIVITY = 0.5
        local MIN_ZOOM, MAX_ZOOM = 10, 120
        local MIN_ZOOM_DELTA = 10
        local ZOOM_SPEED_MULTIPLIER = 0.05

        local function getDistance(p1, p2)
            if not p1 or not p2 then return 0 end
            local dx, dy = p1.x - p2.x, p1.y - p2.y
            return math.sqrt(dx * dx + dy * dy)
        end
        local function applyZoom(delta)
            if math.abs(delta) <= MIN_ZOOM_DELTA then return end
            local cam = workspace.CurrentCamera
            if cam then
                cam.FieldOfView = math.clamp(
                    cam.FieldOfView - (delta * ZOOM_SPEED_MULTIPLIER * ZOOM_SENSITIVITY),
                    MIN_ZOOM,
                    MAX_ZOOM
                )
            end
        end
        local function onTouchInput(input, inputType)
            if input.UserInputType ~= Enum.UserInputType.Touch then return end
            if inputType == "began" then
                if not touchData.touch1 then
                    touchData.touch1, touchData.pos1 = input, input.Position
                elseif not touchData.touch2 then
                    touchData.touch2, touchData.pos2 = input, input.Position
                    touchData.lastDistance = getDistance(touchData.pos1, touchData.pos2)
                end
            elseif inputType == "changed" then
                if touchData.touch1 == input then touchData.pos1 = input.Position end
                if touchData.touch2 == input then touchData.pos2 = input.Position end
                if touchData.touch2 and touchData.pos1 and touchData.pos2 then
                    local dist = getDistance(touchData.pos1, touchData.pos2)
                    if math.abs(dist - touchData.lastDistance) > 0.1 then
                        applyZoom(dist - touchData.lastDistance)
                        touchData.lastDistance = dist
                    end
                end
            elseif inputType == "ended" then
                if touchData.touch1 == input then
                    touchData.touch1, touchData.pos1 = touchData.touch2, touchData.pos2
                    touchData.touch2, touchData.pos2 = nil, nil
                elseif touchData.touch2 == input then
                    touchData.touch2, touchData.pos2 = nil, nil
                end
                if not touchData.touch1 then touchData.lastDistance = 0 end
            end
        end
        UserInputService.InputBegan:Connect(function(input, gp)
            if not gp then onTouchInput(input, "began") end
        end)
        UserInputService.InputChanged:Connect(function(input, gp)
            if not gp then onTouchInput(input, "changed") end
        end)
        UserInputService.InputEnded:Connect(function(input)
            onTouchInput(input, "ended")
        end)
    end
end

do
    local SENSITIVITY_DEFAULT = 1.5
    local currentSens = SENSITIVITY_DEFAULT
    local sensHooked = false

    local function saveSens(val)
        getgenv()._ANTILOGGER_OWN_CALL = true
        pcall(function()
            writefile(SENSITIVITY_FILE, tostring(val))
        end)
        getgenv()._ANTILOGGER_OWN_CALL = false
    end

    local function loadSens()
        getgenv()._ANTILOGGER_OWN_CALL = true
        local ok, data = pcall(function()
            if isfile(SENSITIVITY_FILE) then
                return readfile(SENSITIVITY_FILE)
            end
            return nil
        end)
        getgenv()._ANTILOGGER_OWN_CALL = false
        if ok and data then
            local num = tonumber(data)
            if num and num > 0 then
                currentSens = num
            end
        end
    end

    loadSens()

    local function setSensitivity(value)
        value = tonumber(value) or SENSITIVITY_DEFAULT
        if value < 0.1 then value = 0.1 end
        if value > 10 then value = 10 end
        currentSens = value
        saveSens(value)
    end

    getgenv().setSensitivity = setSensitivity

    local UserInputService = realGame:GetService("UserInputService")
    pcall(function()
        local mt = getrawmetatable(UserInputService)
        if mt then
            local oldIndex = mt.__index
            mt.__index = function(self, key)
                if key == "MouseDelta" and UserInputService.TouchEnabled then
                    local orig = oldIndex(self, key)
                    if type(orig) == "Vector2" then
                        return orig * currentSens
                    end
                    return orig
                end
                return oldIndex(self, key)
            end
            setrawmetatable(UserInputService, mt)
            sensHooked = true
        end
    end)

    if not sensHooked then
        pcall(function()
            local player = realGame:GetService("Players").LocalPlayer
            local playerScripts = player:FindFirstChild("PlayerScripts")
            if playerScripts then
                local playerModule = playerScripts:FindFirstChild("PlayerModule")
                if playerModule then
                    local cameraModule = playerModule:FindFirstChild("CameraModule")
                    if cameraModule then
                        local cameraInput = cameraModule:FindFirstChild("CameraInput")
                        if cameraInput then
                            local module = require(cameraInput)
                            if module and module.getRotation then
                                local orig = module.getRotation
                                module.getRotation = function(disableRotation)
                                    local rot = orig(disableRotation)
                                    if UserInputService.TouchEnabled then
                                        return rot * currentSens
                                    end
                                    return rot
                                end
                                sensHooked = true
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 10 — ЗАГРУЗКА ВНЕШНИХ МОДУЛЕЙ (BASSIE — ПОСЛЕДНИМ)
-- ═══════════════════════════════════════════════════════════════════════

_G.card = "Bassie"
getgenv()._ANTILOGGER_OWN_CALL = true
pcall(function()
    local cfg = HttpService:JSONDecode(
        realGame:HttpGet("https://pastebin.com/raw/3xHYFifb")
    )
    for _, char in ipairs(cfg.characters) do
        if char.name:lower() == "bassie" then
            loadstring(realGame:HttpGet(char.script))()
            break
        end
    end
end)
getgenv()._ANTILOGGER_OWN_CALL = false

-- ═══════════════════════════════════════════════════════════════════════
--  ФИНАЛЬНЫЙ ВЫВОД
-- ═══════════════════════════════════════════════════════════════════════

local LINE_FINAL = "═══════════════════════════"
local status = (getgenv().setSensitivity and "available (setSensitivity(value))") or "unavailable"

print(LINE_FINAL)
print("Anti-Logger v25 (MAYFIVE) loaded")
print("Protection: IP loggers, webhooks, stealers, bypasses, text-IP, WebSocket, IPv6, direct IP, __namecall, Discord payload, debug.spoof, log.stealth, file.protect, sig.mask, OWN_CALL flag")
print("Sensitivity: " .. status)
print(LINE_FINAL)
