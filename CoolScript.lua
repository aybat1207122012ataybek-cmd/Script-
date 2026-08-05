-- ═══════════════════════════════════════════════════════════════════════
--  ██████   АНТИ-СТИЛЛЕР, АНТИ-ЛОГГЕР, АНТИ-КИК  v22.0 Enhanced
--  (MAYFIVE HARDCORE) – интегрирован Dont Grab Me v5.2
-- ═══════════════════════════════════════════════════════════════════════

if getgenv().DIMSTAT_ANTILOGGER_LOADED then return end
getgenv().DIMSTAT_ANTILOGGER_LOADED = true

-- ═══════════════════════════ НАСТРОЙКИ ═══════════════════════════
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
getgenv()._useDontGrabMe = true          -- включить расширенную фильтрацию DGM

-- ═══════════════════════════ ИНИЦИАЛИЗАЦИЯ DGM (если включена) ═══════════
if getgenv()._useDontGrabMe then
    -- Защита от Ugc.httpget
    pcall(function() if Ugc and type(Ugc) == "userdata" and type(Ugc.httpget) ~= "function" then Ugc.httpget = function() return "" end end end)
    pcall(function() if _G.Ugc and type(_G.Ugc) == "userdata" and type(_G.Ugc.httpget) ~= "function" then _G.Ugc.httpget = function() return "" end end end)

    -- Инициализация данных DGM (если ещё не созданы)
    if not _G.DONT_GRAB_ME_DATA then
        _G.DONT_GRAB_ME_DATA = {
            blacklist = {
                "grabify.link","iplogger.org","iplogger.com","iplogger.ru",
                "yip.su","ipgraber.ru","2no.co","trackip.link","ip-tracker.org",
                "blasze.tk","iplis.ru","ezstats.click","webhook.le","leakix.net",
                "bmwforum.co","stopify.co","leancoding.co","browserleaks.com",
                "whoer.net","hookdeck.com","ngrok.io","ngrok.app","snyk.io",
                "ipwho.is","ipgeolocation.io","ipdata.co","ipstack.com",
                "ipregistry.co","ip-api.com","api.ipify.org","apiip.net",
                "ipinfo.io","ip2location.com","geoapify.com","iplocate.io",
                "hackertarget.com",
            },
            suspicious = {
                "myexternalip.com","icanhazip.com","wtfismyip.com","ipapi.co",
                "checkip.amazonaws.com","ipecho.net","ifconfig.me","ifconfig.co",
                "requestbin.net","bit.ly","tinyurl.com","t.co","goo.gl",
                "ow.ly","rb.gy","cutt.ly","shorturl.at",
            },
            whitelist = {
                "raw.githubusercontent.com","pastebin.com","paste.ee","github.com",
                "discord.com","cdn.discordapp.com","roblox.com","api.anthropic.com",
                "openai.com","api.openai.com","generativelanguage.googleapis.com",
                "aiplatform.googleapis.com","api.mistral.ai","api.groq.com",
                "api.deepseek.com","api.cohere.ai","api-inference.huggingface.co",
                "api.together.xyz","api.perplexity.ai",
            },
            stats = {blocked=0, suspicious=0, allowed=0},
            logFlags = {blocked=true, suspicious=true, allowed=false},
        }
        local d = _G.DONT_GRAB_ME_DATA
        for i,v in ipairs(d.blacklist)  do d.blacklist[i]  = string.lower(v) end
        for i,v in ipairs(d.suspicious) do d.suspicious[i] = string.lower(v) end
        for i,v in ipairs(d.whitelist)  do d.whitelist[i]  = string.lower(v) end
    end
end

-- ═══════════════════════════ ЗАГРУЗКА МОДУЛЕЙ ═══════════════════════════
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

-- ═══════════════════════════ ИНИЦИАЛИЗАЦИЯ ═══════════════════════════
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

-- ═══════════════════════════ ВОДЯНОЙ ЗНАК И TOUCH ZOOM ═══════════
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
local function startWatermarkWatchdog(gui) ... end  -- (без изменений)
local function looksLikeDeltaGui(gui) ... end
local function applyToAllDeltaGuis() ... end
task.spawn(function() while true do if applyToAllDeltaGuis() then break end task.wait(1) end end)
CoreGui.ChildAdded:Connect(function(child) ... end)
if not getgenv().TOUCH_ZOOM_LOADED then ... end  -- (без изменений)

-- ═══════════════════════════ АНТИ-КИК ═══════════════════════════
local STATS = { blocked = 0, cookie = 0, webhook = 0, logger = 0, sanitized = 0, scanned = 0, kicksBlocked = 0 }
local function notifyBlock(kind) end
if getgenv()._anti_kick then ... end  -- (без изменений)

-- ═══════════════════════════ БАЗОВЫЕ ФУНКЦИИ ═══════════════════════════
local function urlDecode(s) ... end
local function getHost(url) ... end
local function fakeIP(v6) ... end
local function loadCustomAsset(fileName) ... end

-- ═══════════════════════════ УВЕДОМЛЕНИЕ (56×56) С АНИМАЦИЕЙ НАЖАТИЯ ═══════════
local lastNotificationTime = {}; local activeNotifications = {}
local function showCustomNotification(titleText, descriptionText, groupId) ... end

-- ═══════════════════════════ РАСШИРЕННЫЕ СПИСКИ (DGM) ═══════════════════
local function getDGMData()
    if not getgenv()._useDontGrabMe then return nil end
    local data = _G.DONT_GRAB_ME_DATA
    if type(data) ~= "table" or type(data.blacklist) ~= "table" or type(data.whitelist) ~= "table" or type(data.suspicious) ~= "table" then return nil end
    return data
end

local function isDGMBlacklisted(host)
    local data = getDGMData()
    if not data then return false end
    for _, bad in ipairs(data.blacklist) do
        if host == bad or ssub(host, -(#bad+1)) == "."..bad then return true end
    end
    return false
end

local function isDGMWhitelisted(host)
    local data = getDGMData()
    if not data then return false end
    for _, safe in ipairs(data.whitelist) do
        if host == safe or ssub(host, -(#safe+1)) == "."..safe then return true end
    end
    return false
end

local function isDGMSuspicious(host)
    local data = getDGMData()
    if not data then return false end
    for _, sus in ipairs(data.suspicious) do
        if host == sus or ssub(host, -(#sus+1)) == "."..sus then return true end
    end
    return false
end

-- Вспомогательные функции из DGM
local function decodePercent(s) ... end
local function extractHostname(url) ... end
local function isRawIP(hostname) ... end
local function isWebhook(url) ... end
local function hasSuspiciousHeaders(headers) ... end
local LOCATION_FIELDS = { ... }  -- как в DGM
local function analyzeJsonResponse(body, url) ... end

-- ═══════════════════════════ ОСНОВНАЯ ЛОГИКА АНАЛИЗА ═══════════════════════
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

local function logCompact(tag, url, scriptName) ... end

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

local function analyzePre(url, body, isPost, headers)
    STATS.scanned = STATS.scanned + 1
    url = type(url) == "string" and url or ""
    local dUrl = urlDecode(url)
    local host = getHost(dUrl)
    local ul = slower(dUrl)
    local bl = slower(type(body) == "string" and urlDecode(body) or "")

    -- Проверка через DGM (если включена)
    if getgenv()._useDontGrabMe then
        if isWebhook(url) then return "block", "WEBHOOK BLOCKED" end
        local dgmHost = extractHostname(url)
        if dgmHost then
            if isDGMBlacklisted(dgmHost) then return "block", "LOGGER BLOCKED" end
            if isDGMSuspicious(dgmHost) then
                STATS.logger = STATS.logger + 1
                logCompact("SUSPICIOUS HOST", url, getCallingScript())
                -- не блокируем, но логируем
            end
            if isDGMWhitelisted(dgmHost) then return "allow" end
        end
        if headers and hasSuspiciousHeaders(headers) then
            STATS.logger = STATS.logger + 1
            return "block", "SUSPICIOUS HEADERS BLOCKED"
        end
    end

    -- Стандартные проверки
    if isIPInUrl(dUrl) then STATS.logger = STATS.logger + 1; return "block", "DIRECT IP BLOCKED" end
    if not sfind(ul, "^https://") and host ~= "" then STATS.logger = STATS.logger + 1; return "block", "UNSECURE HTTP BLOCKED" end
    if isPost and isSuspiciousBody(body) then STATS.logger = STATS.logger + 1; return "block", "SUSPICIOUS BODY BLOCKED" end

    local cookieHit = sfind(bl, COOKIE_SIG, 1, true) or sfind(ul, COOKIE_SIG, 1, true) or (REAL_COOKIE and type(body) == "string" and sfind(body, REAL_COOKIE, 1, true))
    if not cookieHit and headers then ... end
    if cookieHit and not isWhitelistedHost(host) then STATS.cookie = STATS.cookie + 1; return "block", "ROBLOSECURITY BLOCKED" end

    if getgenv()._strict and not isWhitelistedHost(host) then STATS.blocked = STATS.blocked + 1; return "block", "SUSPICIOUS HOST BLOCKED" end
    if getgenv()._blockwebhook and isPost and (... webhook check) then STATS.webhook = STATS.webhook + 1; return "block", "WEBHOOK BLOCKED" end
    if not getgenv()._strict and isWhitelistedHost(host) then STATS.allowed = STATS.allowed + 1; return "allow" end

    -- Чёрный список нашей базы
    if isBlacklistedHost(host) then STATS.logger = STATS.logger + 1; return "block", "LOGGER BLOCKED" end
    if matchBlacklistPatterns(dUrl) then STATS.logger = STATS.logger + 1; return "block", "LOGGER BLOCKED" end

    STATS.allowed = STATS.allowed + 1
    return "allow"
end

-- ═══════════════════════════ САНИТИЗАЦИЯ ОТВЕТОВ (с анализом JSON) ═══════════
local IPV4_PATTERN = "%d+%.%d+%.%d+%.%d+"
local IPV6_PATTERN = "[%x:]+::?[%x:]+"
local function containsIP(data) ... end
local function sanitizeResponse(resp) ... end

-- ═══════════════════════════ HTTP ХУКИ (включая DGM-хуки) ═══════════
local function getCallingScript() ... end
local DENIED = { ... }

local function handle(kind, isPost, url, body, headers, callReal, scriptName) ... end

if hookfunction and newcclosure then
    local wrapCC = newcclosure or function(f) return f end
    for method, verb in pairs({HttpGet="GET", HttpGetAsync="GET", HttpPost="POST", HttpPostAsync="POST"}) do ... end
    local httpService = cloneref(game:GetService("HttpService"))
    if httpService then
        if httpService.RequestAsync then
            local old = hookfunction(httpService.RequestAsync, wrapCC(function(self, options) ... end))
        end
        for method, _ in pairs({GetAsync="GET", PostAsync="POST", RequestAsync="REQUEST"}) do ... end
    end
end

-- Перехват executor-запросов (как в DGM)
if getgenv()._useDontGrabMe then
    local function hookExecutorRequest(fnName)
        local fn = nil
        pcall(function() fn = getNestedFn(fnName) end)
        if type(fn) ~= "function" then return end
        local old = fn
        local newFn = function(tbl, ...)
            local url = tbl and (tbl.Url or tbl.URL or tbl.url)
            if url and (isDGMBlacklisted(extractHostname(url)) or isWebhook(url)) then
                return DENIED
            end
            return old(tbl, ...)
        end
        pcall(hookfunction, fn, newcclosure(newFn))
    end
    hookExecutorRequest("http_request")
    hookExecutorRequest("request")
    if syn then hookExecutorRequest("syn.request") end
    if fluxus then hookExecutorRequest("fluxus.request") end
    if http then hookExecutorRequest("http.request") end
end

-- ═══════════════════════════ ДИНАМИЧЕСКОЕ УПРАВЛЕНИЕ СПИСКАМИ ═══════════
getgenv().AntiLogger = {
    addBlacklist = function(domain) ... end,
    addWhitelist = function(domain) ... end,
    removeBlacklist = function(domain) ... end,
    stats = function() ... end,
}

-- ═══════════════════════════ СТАТИСТИКА И ЗАВЕРШЕНИЕ ═══════════════════════
function getStats() ... end
local startTime = tick()
warn(LINE)
warn("Anti-Logger v22.0 Enhanced loaded")
warn("Dont Grab Me integration: " .. (getgenv()._useDontGrabMe and "ON" or "OFF"))
warn(LINE)
