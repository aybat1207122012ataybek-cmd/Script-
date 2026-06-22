
-- ╔══════════════════════════════════════════════╗
-- ║       DONT GRAB ME v5.1                    ║
-- ╚══════════════════════════════════════════════╝

pcall(function()
    if Ugc and type(Ugc) == "userdata" and type(Ugc.httpget) ~= "function" then
        Ugc.httpget = function() return "" end
    end
end)
pcall(function()
    if _G.Ugc and type(_G.Ugc) == "userdata" and type(_G.Ugc.httpget) ~= "function" then
        _G.Ugc.httpget = function() return "" end
    end
end)

pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)

if _G.DONT_GRAB_ME then return end
_G.DONT_GRAB_ME = true

local _warn              = warn or print
local _hookfunction      = hookfunction      or function(o, h) return o end
local _hookmetamethod    = hookmetamethod    or nil
local _newcclosure       = newcclosure       or function(fn) return fn end
local _getrawmeta        = getrawmetatable   or getmetatable
local _setreadonly       = setreadonly       or function() end
local _getnamecallmethod = getnamecallmethod or function() return nil end
local _getfenv           = getfenv
local _rawget            = rawget
local _pcall             = pcall
local _type              = type
local _tostring          = tostring
local _tonumber          = tonumber
local _ipairs            = ipairs
local _pairs             = pairs
local _string_format     = string.format
local _string_gsub       = string.gsub
local _string_find       = string.find
local _string_match      = string.match
local _string_sub        = string.sub
local _string_char       = string.char
local _string_lower      = string.lower
local _string_len        = string.len
local _string_gmatch     = string.gmatch
local _table_insert      = table.insert
local _table_remove      = table.remove

local HttpService    = game:GetService("HttpService")
local HttpServiceRef = HttpService

local WATCHED_METHODS = {
    HttpGet       = true,
    HttpGetAsync  = true,
    HttpPost      = true,
    HttpPostAsync = true,
    GetAsync      = true,
    PostAsync     = true,
}

if not _G.DONT_GRAB_ME_DATA then
    _G.DONT_GRAB_ME_DATA = {

        blacklist = {
            "grabify.link",
            "iplogger.org",
            "iplogger.com",
            "iplogger.ru",
            "yip.su",
            "ipgraber.ru",
            "2no.co",
            "trackip.link",
            "ip-tracker.org",
            "blasze.tk",
            "iplis.ru",
            "ezstats.click",
            "webhook.le",
            "leakix.net",
            "bmwforum.co",
            "stopify.co",
            "leancoding.co",
            "browserleaks.com",
            "whoer.net",
            "hookdeck.com",
            "ngrok.io",
            "ngrok.app",
            "snyk.io",
            "ipwho.is",
            "ipgeolocation.io",
            "ipdata.co",
            "ipstack.com",
            "ipregistry.co",
            "ip-api.com",
            "api.ipify.org",
            "apiip.net",
            "ipinfo.io",
            "ip2location.com",
            "geoapify.com",
            "iplocate.io",
            "hackertarget.com",
        },

        suspicious = {
            "myexternalip.com",
            "icanhazip.com",
            "wtfismyip.com",
            "ipapi.co",
            "checkip.amazonaws.com",
            "ipecho.net",
            "ifconfig.me",
            "ifconfig.co",
            "requestbin.net",
            "bit.ly",
            "tinyurl.com",
            "t.co",
            "goo.gl",
            "ow.ly",
            "rb.gy",
            "cutt.ly",
            "shorturl.at",
        },

        whitelist = {
            "raw.githubusercontent.com",
            "pastebin.com",
            "paste.ee",
            "github.com",
            "discord.com",
            "cdn.discordapp.com",
            "roblox.com",
            "api.anthropic.com",
            "openai.com",
            "api.openai.com",
            "generativelanguage.googleapis.com",
            "aiplatform.googleapis.com",
            "api.mistral.ai",
            "api.groq.com",
            "api.deepseek.com",
            "api.cohere.ai",
            "api-inference.huggingface.co",
            "api.together.xyz",
            "api.perplexity.ai",
        },

        stats = {
            blocked    = 0,
            suspicious = 0,
            allowed    = 0,
        },

        logFlags = {
            blocked    = true,
            suspicious = true,
            allowed    = false,
        },
    }

    local d = _G.DONT_GRAB_ME_DATA
    for i, v in _ipairs(d.blacklist)  do d.blacklist[i]  = _string_lower(v) end
    for i, v in _ipairs(d.suspicious) do d.suspicious[i] = _string_lower(v) end
    for i, v in _ipairs(d.whitelist)  do d.whitelist[i]  = _string_lower(v) end
end

local function getDataSafe()
    local data = _G.DONT_GRAB_ME_DATA
    if _type(data)            ~= "table" then return nil end
    if _type(data.blacklist)  ~= "table" then return nil end
    if _type(data.whitelist)  ~= "table" then return nil end
    if _type(data.suspicious) ~= "table" then return nil end
    if _type(data.stats)      ~= "table" then return nil end
    if _type(data.logFlags)   ~= "table" then return nil end
    return data
end

local MAX_DECODE_ITER = 8

local function decodePercent(s)
    local prev
    local iter = 0
    repeat
        prev = s
        s = _string_gsub(s, "%%(%x%x)", function(hex)
            return _string_char(_tonumber(hex, 16))
        end)
        iter = iter + 1
    until s == prev or iter >= MAX_DECODE_ITER
    return s
end

local function validateHostname(hostname)
    if not hostname or hostname == "" then return nil end
    for i = 1, _string_len(hostname) do
        local byte = hostname:byte(i)
        local valid = (byte >= 48 and byte <= 57)
                   or (byte >= 65 and byte <= 90)
                   or (byte >= 97 and byte <= 122)
                   or byte == 45
                   or byte == 46
                   or byte == 91
                   or byte == 93
                   or byte == 58
        if not valid then return nil end
    end
    return hostname
end

local function normalizeHostname(hostname)
    if not hostname then return nil end
    local result = _string_match(hostname, "^(.-)%.+$") or hostname
    if result == "" then return nil end
    return result
end

local function extractHostname(url)
    if not url or _type(url) ~= "string" then return nil end

    local host

    host = _string_match(url, "^%a[%a%d+%-%.]*://([^/?#]*)")

    if not host then
        host = _string_match(url, "^//([^/?#]*)")
    end

    if not host then
        if _string_match(url, "^%a[%a%d+%-%.]-%:[^/]") then
            return nil
        end
        host = _string_match(url, "^([^/?#]+)")
    end

    if not host or host == "" then return nil end

    local atPos = _string_find(host, "@")
    if atPos then
        host = _string_sub(host, atPos + 1)
    end

    local ipv6 = _string_match(host, "^(%[.-%])")
    if ipv6 then
        local decoded = decodePercent(_string_lower(ipv6))
        local normalized = normalizeHostname(decoded)
        return validateHostname(normalized)
    end

    host = _string_match(host, "^([^:]+)") or host
    if host == "" then return nil end

    local decoded = decodePercent(host)

    local atPos2 = _string_find(decoded, "@")
    if atPos2 then
        decoded = _string_sub(decoded, atPos2 + 1)
        if _string_find(decoded, "@") then return nil end
        decoded = _string_match(decoded, "^([^:/?#]+)") or decoded
    end

    if decoded == "" then return nil end

    local lower = _string_lower(decoded)
    local normalized = normalizeHostname(lower)
    return validateHostname(normalized)
end

local function isRawIP(hostname)
    if not hostname then return false end
    if _string_match(hostname, "^%d+%.%d+%.%d+%.%d+$") then return true end
    if _string_match(hostname, "^%d+%.%d+%.%d+$")      then return true end
    if _string_match(hostname, "^%d+%.%d+$")            then return true end
    if _string_match(hostname, "^%[.+%]$") then
        local inner = _string_sub(hostname, 2, -2)
        if _string_find(inner, ":") then return true end
    end
    if _string_match(hostname, "^%d+$") then
        local n = _tonumber(hostname)
        if n and n >= 65536 and n <= 4294967295 then return true end
    end
    if _string_match(hostname, "^0[xX]%x+$") then return true end
    if _string_match(hostname, "^0%d%d%d+$")  then return true end
    return false
end

local function matchDomain(hostname, rule)
    if not hostname or not rule or rule == "" then return false end
    if hostname == rule then return true end
    if _string_sub(hostname, -(#rule + 1)) == "." .. rule then return true end
    return false
end

local function sanitizeDomain(domain)
    if _type(domain) ~= "string" then return nil end
    domain = _string_match(domain, "^%s*(.-)%s*$")
    if not domain then return nil end
    domain = _string_lower(domain)
    if domain == "" then return nil end
    if not _string_match(domain, "^[%a%d%.%-]+$") then return nil end
    if _string_sub(domain, 1, 1) == "." then return nil end
    if _string_sub(domain, -1)   == "." then return nil end
    if _string_find(domain, "%.%.") then return nil end
    return domain
end

local function notify(title, text)
    _pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = 5,
        })
    end)
end

local SUSPICIOUS_HEADER_PATTERNS = {
    "^x%-forwarded%-for$",
    "^x%-real%-ip$",
    "^cf%-connecting%-ip$",
    "^x%-client%-ip$",
    "^true%-client%-ip$",
    "^ip$",
    "^ipaddress$",
    "^ip_address$",
    "^ipv4$",
    "^ipv6$",
    "^publicip$",
    "^public_ip$",
    "^remoteip$",
    "^remote_ip$",
}

local function hasSuspiciousHeaders(headers)
    if _type(headers) ~= "table" then return false end
    for key in _pairs(headers) do
        local lower = _string_lower(_tostring(key))
        for _, pattern in _ipairs(SUSPICIOUS_HEADER_PATTERNS) do
            if _string_match(lower, pattern) then
                return true
            end
        end
    end
    return false
end

local LOCATION_FIELDS = {
    country     = true, region      = true, city         = true,
    zip         = true, postal      = true, latitude     = true,
    longitude   = true, timezone    = true, isp          = true,
    asn         = true, country_code= true, region_code  = true,
    continent   = true, currency    = true, languages    = true,
    phone       = true, calling_code= true, ip           = true,
    ipaddress   = true, ip_address  = true, query        = true,
    origin      = true, ipv4        = true, ipv6         = true,
    publicip    = true, public_ip   = true,
}

local function analyzeJsonResponse(body, url)
    if _type(body) ~= "string" or body == "" then return end
    local ok, decoded = _pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not ok or _type(decoded) ~= "table" then return end
    for key in _pairs(decoded) do
        local lower = _string_lower(_tostring(key))
        if LOCATION_FIELDS[lower] then
            _warn(_string_format(
                "[DontGrabMe] SUSPICIOUS JSON response from %s (field: %s)",
                _tostring(url), lower
            ))
            notify("DontGrabMe: Подозрительный ответ", _tostring(url))
            return
        end
    end
end

local function isWebhook(url)
    if _type(url) ~= "string" then return false end
    local lower = _string_lower(url)
    if _string_find(lower, "discord%.com/api/webhooks", 1, true) then return true end
    if _string_find(lower, "guilded%.gg/api/webhooks",  1, true) then return true end
    return false
end

local function recordStat(category)
    local data = getDataSafe()
    if not data then return end
    data.stats[category] = (data.stats[category] or 0) + 1
end

local function Log(category, url)
    local data = getDataSafe()
    if not data then return end
    if not data.logFlags[category] then return end
    _warn(_string_format("[DontGrabMe] %s: %s", category:upper(), _tostring(url)))
end

local function checkURL(url)
    local data = getDataSafe()
    if not data then return "suspicious" end

    if isWebhook(url) then return "blocked" end

    local hostname = extractHostname(url)
    if not hostname then return "suspicious" end
    if isRawIP(hostname) then return "suspicious" end

    for _, bad in _ipairs(data.blacklist) do
        if matchDomain(hostname, bad) then return "blocked" end
    end

    for _, safe in _ipairs(data.whitelist) do
        if matchDomain(hostname, safe) then return "allowed" end
    end

    for _, sus in _ipairs(data.suspicious) do
        if matchDomain(hostname, sus) then return "suspicious" end
    end

    return "allowed"
end

local function handleCheck(url, headers)
    if not url or _type(url) ~= "string" then return "allowed" end

    if headers and hasSuspiciousHeaders(headers) then
        _warn("[DontGrabMe] SUSPICIOUS headers in request to: " .. _tostring(url))
        recordStat("suspicious")
        Log("suspicious", url)
    end

    local result = checkURL(url)
    recordStat(result)
    Log(result, url)

    if result == "blocked" then
        notify("DontGrabMe: Заблокировано",
            _tostring(extractHostname(url) or url))
    end

    return result
end

-- ══════════════════════════════════════════════
-- ХУК __NAMECALL
-- ══════════════════════════════════════════════
local mt          = _getrawmeta(game)
local oldNamecall = mt.__namecall
local namecallHookOk = false

local function processNamecall(self, oldFn, ...)
    local method = _getnamecallmethod()

    if not WATCHED_METHODS[method] then
        local ok, result = _pcall(oldFn, self, ...)
        if not ok then
            _warn("[DontGrabMe] __namecall passthrough error: " .. _tostring(result))
            return nil
        end
        return result
    end

    if (method == "HttpGet" or method == "HttpGetAsync"
        or method == "HttpPost" or method == "HttpPostAsync")
        and typeof(self) == "Instance"
        and self == game
    then
        local args = {...}
        local url  = args[1]
        if handleCheck(url) == "blocked" then
            return "Blocked by DontGrabMe"
        end
    end

    if (method == "GetAsync" or method == "PostAsync")
        and typeof(self) == "Instance"
        and self == HttpServiceRef
    then
        local args = {...}
        local url  = args[1]
        if handleCheck(url) == "blocked" then
            return ""
        end
    end

    local ok, result = _pcall(oldFn, self, ...)
    if not ok then
        _warn("[DontGrabMe] __namecall error: " .. _tostring(result))
        return nil
    end
    return result
end

if _hookmetamethod then
    _pcall(function()
        local oldHmm = _hookmetamethod(game, "__namecall",
            _newcclosure(function(self, ...)
                return processNamecall(self, oldHmm, ...)
            end)
        )
        namecallHookOk = true
        _warn("[DontGrabMe] Hooked: __namecall (hookmetamethod)")
    end)
end

if not namecallHookOk then
    local hookOk = _pcall(function()
        _setreadonly(mt, false)
        mt.__namecall = _newcclosure(function(self, ...)
            return processNamecall(self, oldNamecall, ...)
        end)
        _setreadonly(mt, true)
    end)
    if hookOk then
        namecallHookOk = true
        _warn("[DontGrabMe] Hooked: __namecall (mt fallback)")
    else
        _warn("[DontGrabMe] Failed to hook: __namecall")
    end
end

-- ══════════════════════════════════════════════
-- ХУК RequestAsync
-- ══════════════════════════════════════════════
_pcall(function()
    local oldRA = _hookfunction(
        HttpService.RequestAsync,
        _newcclosure(function(self, options)
            local url     = options and (options.Url or options.URL or options.url)
            local headers = options and options.Headers
            local method  = options and (options.Method or options.method)
            local isGet   = not method
                         or _string_lower(_tostring(method)) == "get"

            if handleCheck(url, headers) == "blocked" then
                return {
                    Success    = false,
                    StatusCode = 403,
                    Body       = "Blocked by DontGrabMe",
                }
            end

            local response = oldRA(self, options)

            if isGet and _type(response) == "table" then
                analyzeJsonResponse(response.Body or response.body, url)
            end

            return response
        end)
    )
    _warn("[DontGrabMe] Hooked: HttpService.RequestAsync")
end)

-- ══════════════════════════════════════════════
-- ХУКИ EXECUTOR ФУНКЦИЙ
-- ══════════════════════════════════════════════
local function getNestedFn(path)
    local ok, env = _pcall(_getfenv, 0)
    if not ok or _type(env) ~= "table" then return nil end

    local parts = {}
    for part in _string_gmatch(path, "[^%.]+") do
        _table_insert(parts, part)
    end

    if #parts == 0 then return nil end

    local current = _rawget(env, parts[1])

    for i = 2, #parts do
        if _type(current) ~= "table" then return nil end
        local fOk, val = _pcall(function() return current[parts[i]] end)
        if not fOk then return nil end
        current = val
    end

    if _type(current) ~= "function" then return nil end
    return current
end

if _type(_G.DONT_GRAB_ME_HOOKS) ~= "table" then
    _G.DONT_GRAB_ME_HOOKS = {}
end

local function hookExecutorRequest(fnName)
    if _type(_G.DONT_GRAB_ME_HOOKS) ~= "table" then
        _G.DONT_GRAB_ME_HOOKS = {}
    end

    if _G.DONT_GRAB_ME_HOOKS[fnName] then
        _warn("[DontGrabMe] Already hooked: " .. fnName)
        return
    end

    local fn = nil
    _pcall(function() fn = getNestedFn(fnName) end)
    if _type(fn) ~= "function" then
        _warn("[DontGrabMe] Not found (skip): " .. fnName)
        return
    end

    local hookOk = _pcall(function()
        local old = _hookfunction(fn, _newcclosure(function(tbl)
            local url     = tbl and (tbl.Url or tbl.URL or tbl.url)
            local headers = tbl and (tbl.Headers or tbl.headers)
            local method  = tbl and (tbl.Method or tbl.method)
            local isGet   = not method
                         or _string_lower(_tostring(method)) == "get"

            if not url or _type(url) ~= "string" then
                return old(tbl)
            end

            if handleCheck(url, headers) == "blocked" then
                return {
                    Success    = false,
                    StatusCode = 403,
                    Body       = "Blocked by DontGrabMe",
                }
            end

            local response = old(tbl)

            if isGet and _type(response) == "table" then
                analyzeJsonResponse(response.Body or response.body, url)
            end

            return response
        end))
    end)

    if hookOk then
        _G.DONT_GRAB_ME_HOOKS[fnName] = true
        _warn("[DontGrabMe] Hooked: " .. fnName)
    else
        _warn("[DontGrabMe] Failed to hook: " .. fnName)
    end
end

hookExecutorRequest("http_request")
hookExecutorRequest("request")
hookExecutorRequest("syn.request")
hookExecutorRequest("fluxus.request")
hookExecutorRequest("http.request")

-- ══════════════════════════════════════════════
-- ПУБЛИЧНЫЙ API
-- ══════════════════════════════════════════════
_G.DontGrabMe = {

    addBlacklist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _warn("[DontGrabMe] addBlacklist: некорректный домен")
            return
        end
        for _, v in _ipairs(data.blacklist) do
            if v == clean then return end
        end
        _table_insert(data.blacklist, 1, clean)
        _warn("[DontGrabMe] Blacklist +: " .. clean)
    end,

    addWhitelist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _warn("[DontGrabMe] addWhitelist: некорректный домен")
            return
        end
        for _, v in _ipairs(data.blacklist) do
            if matchDomain(clean, v) or matchDomain(v, clean) then
                _warn("[DontGrabMe] addWhitelist: отклонено — "
                    .. clean .. " конфликтует с blacklist")
                return
            end
        end
        for _, v in _ipairs(data.whitelist) do
            if v == clean then return end
        end
        _table_insert(data.whitelist, clean)
        _warn("[DontGrabMe] Whitelist +: " .. clean)
    end,

    addSuspicious = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _warn("[DontGrabMe] addSuspicious: некорректный домен")
            return
        end
        for _, v in _ipairs(data.suspicious) do
            if v == clean then return end
        end
        _table_insert(data.suspicious, clean)
        _warn("[DontGrabMe] Suspicious +: " .. clean)
    end,

    removeBlacklist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then return end
        for i, v in _ipairs(data.blacklist) do
            if v == clean then
                _table_remove(data.blacklist, i)
                _warn("[DontGrabMe] Blacklist -: " .. clean)
                return
            end
        end
    end,

    removeWhitelist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then return end
        for i, v in _ipairs(data.whitelist) do
            if v == clean then
                _table_remove(data.whitelist, i)
                _warn("[DontGrabMe] Whitelist -: " .. clean)
                return
            end
        end
    end,

    removeSuspicious = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then return end
        for i, v in _ipairs(data.suspicious) do
            if v == clean then
                _table_remove(data.suspicious, i)
                _warn("[DontGrabMe] Suspicious -: " .. clean)
                return
            end
        end
    end,

    setLog = function(category, state)
        local data = getDataSafe()
        if not data then return end
        if data.logFlags[category] ~= nil then
            data.logFlags[category] = state
        end
    end,

    stats = function()
        local data = getDataSafe()
        if not data then
            _warn("[DontGrabMe] Данные недоступны")
            return
        end
        _warn(_string_format(
            "[DontGrabMe] Blocked: %d | Suspicious: %d | Allowed: %d",
            data.stats.blocked,
            data.stats.suspicious,
            data.stats.allowed
        ))
    end,

    unload = function()
        if namecallHookOk and not _hookmetamethod then
            _pcall(function()
                local mt2 = _getrawmeta(game)
                _setreadonly(mt2, false)
                mt2.__namecall = oldNamecall
                _setreadonly(mt2, true)
                _warn("[DontGrabMe] __namecall восстановлен")
            end)
        elseif namecallHookOk and _hookmetamethod then
            _warn("[DontGrabMe] hookmetamethod-хук не восстанавливается (ограничение executor API)")
        end
        _G.DONT_GRAB_ME = nil
        _warn("[DontGrabMe] Выгружен.")
        _warn("[DontGrabMe] Данные списков сохранены.")
    end,
}

_warn("[DontGrabMe v5.1] Активен.")
_warn("[DontGrabMe] DontGrabMe.stats() — статистика.")

