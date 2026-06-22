-- === ПРИНУДИТЕЛЬНАЯ ЗАГЛУШКА, которая выполняется раньше любой другой логики ===
-- Используем pcall, чтобы подавить любые ошибки, и задаём Ugc.httpget напрямую
pcall(function()
    -- Пытаемся найти Ugc как глобальную переменную (именно так она задана в Delta X)
    if Ugc and type(Ugc) == "userdata" then
        Ugc.httpget = function(url) return "" end
    end
end)
-- Альтернативная попытка: возможно, Ugc лежит в _G
pcall(function()
    if _G.Ugc and type(_G.Ugc) == "userdata" then
        _G.Ugc.httpget = function(url) return "" end
    end
end)

-- Теперь выполняем ваш оригинальный скрипт (абсолютно без изменений)
local DontGrabMeScript = [=[
-- ╔══════════════════════════════════════════════╗
-- ║          DONT GRAB ME v4.0                  ║
-- ╚══════════════════════════════════════════════╝

if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv().DONT_GRAB_ME then return end
getgenv().DONT_GRAB_ME = true

local _hookfunction      = hookfunction      or function(o, h) return o end
local _newcclosure       = newcclosure       or function(fn) return fn end
local _getrawmeta        = getrawmetatable   or getmetatable
local _setreadonly       = setreadonly       or function() end
local _rconsoleprint     = rconsoleprint     or print
local _getnamecallmethod = getnamecallmethod or function() return nil end
local _getfenv           = getfenv
local _rawget            = rawget
local _pcall             = pcall
local _type              = type
local _tostring          = tostring
local _tonumber          = tonumber
local _ipairs            = ipairs
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

local HttpService = game:GetService("HttpService")

if not getgenv().DONT_GRAB_ME_DATA then
    getgenv().DONT_GRAB_ME_DATA = {

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
        },

        suspicious = {
            "ipinfo.io",
            "api.ipify.org",
            "ip-api.com",
            "myexternalip.com",
            "icanhazip.com",
            "wtfismyip.com",
            "ipapi.co",
            "checkip.amazonaws.com",
            "ipecho.net",
            "ifconfig.me",
            "ifconfig.co",
            "requestbin.net",
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

    local d = getgenv().DONT_GRAB_ME_DATA
    for i, v in _ipairs(d.blacklist)  do d.blacklist[i]  = _string_lower(v) end
    for i, v in _ipairs(d.suspicious) do d.suspicious[i] = _string_lower(v) end
    for i, v in _ipairs(d.whitelist)  do d.whitelist[i]  = _string_lower(v) end
end

local function getDataSafe()
    local data = getgenv().DONT_GRAB_ME_DATA
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
        if not valid then
            return nil
        end
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
        if _string_find(decoded, "@") then
            return nil
        end
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
    if _string_match(hostname, "^%d+%.%d+%.%d+$") then return true end
    if _string_match(hostname, "^%d+%.%d+$") then return true end

    if _string_match(hostname, "^%[.+%]$") then
        local inner = _string_sub(hostname, 2, -2)
        if _string_find(inner, ":") then return true end
    end

    if _string_match(hostname, "^%d+$") then
        local n = _tonumber(hostname)
        if n and n >= 65536 and n <= 4294967295 then return true end
    end

    if _string_match(hostname, "^0[xX]%x+$") then return true end
    if _string_match(hostname, "^0%d%d%d+$") then return true end

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
    if _string_sub(domain, -1) == "." then return nil end
    if _string_find(domain, "%.%.") then return nil end
    return domain
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
    _rconsoleprint(_string_format(
        "[DontGrabMe] %s: %s\n",
        category:upper(),
        _tostring(url)
    ))
end

local function checkURL(url)
    local data = getDataSafe()
    if not data then return "suspicious" end

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

local function handleCheck(url)
    if not url or _type(url) ~= "string" then return "allowed" end
    local result = checkURL(url)
    recordStat(result)
    Log(result, url)
    return result
end

-- ХУК __NAMECALL
local mt = _getrawmeta(game)
local oldNamecall = mt.__namecall
local namecallHookOk = false

do
    local hookOk = _pcall(function()
        _setreadonly(mt, false)
        mt.__namecall = _newcclosure(function(self, ...)
            local ok, result = _pcall(function()
                local method = _getnamecallmethod()
                if method == "HttpGet" or method == "HttpGetAsync" then
                    -- ИСПРАВЛЕНИЕ: проверяем что self == game
                    -- без этого хук ломал :HttpGet() на других объектах
                    if self == game then
                        local args = {...}
                        local url = args[1]
                        if handleCheck(url) == "blocked" then
                            return "Blocked by DontGrabMe"
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            if not ok then
                return oldNamecall(self, ...)
            end
            return result
        end)
        _setreadonly(mt, true)
    end)

    if hookOk then
        namecallHookOk = true
        _rconsoleprint("[DontGrabMe] __namecall hook установлен\n")
    else
        _rconsoleprint("[DontGrabMe] __namecall hook недоступен\n")
    end
end

-- ХУК RequestAsync
local function tryHookRequestAsync()
    if typeof(HttpService.RequestAsync) ~= "function" then return end
    local ok = _pcall(function()
        local oldRA = _hookfunction(
            HttpService.RequestAsync,
            _newcclosure(function(self, options)
                local url = options and options.Url
                if handleCheck(url) == "blocked" then
                    return {
                        Success    = false,
                        StatusCode = 403,
                        Body       = "Blocked by DontGrabMe",
                    }
                end
                return oldRA(self, options)
            end)
        )
    end)
    if not ok then
        _rconsoleprint("[DontGrabMe] RequestAsync hook недоступен\n")
    end
end

tryHookRequestAsync()

-- ХУКИ EXECUTOR ФУНКЦИЙ
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
        local fieldOk, val = _pcall(function()
            return current[parts[i]]
        end)
        if not fieldOk then return nil end
        current = val
    end

    if _type(current) ~= "function" then return nil end
    return current
end

if _type(getgenv().DONT_GRAB_ME_HOOKS) ~= "table" then
    getgenv().DONT_GRAB_ME_HOOKS = {}
end

local function hookExecutorRequest(fnName)
    if _type(getgenv().DONT_GRAB_ME_HOOKS) ~= "table" then
        getgenv().DONT_GRAB_ME_HOOKS = {}
    end

    if getgenv().DONT_GRAB_ME_HOOKS[fnName] then return end

    local fn = nil
    local ok = _pcall(function()
        fn = getNestedFn(fnName)
    end)

    if not ok or _type(fn) ~= "function" then return end

    local hookOk = _pcall(function()
        local old = _hookfunction(fn, _newcclosure(function(tbl)
            local url = tbl and (tbl.Url or tbl.URL or tbl.url)
            if not url or _type(url) ~= "string" then
                return old(tbl)
            end
            if handleCheck(url) == "blocked" then
                return {
                    Success    = false,
                    StatusCode = 403,
                    Body       = "Blocked by DontGrabMe",
                }
            end
            return old(tbl)
        end))
    end)

    if hookOk then
        getgenv().DONT_GRAB_ME_HOOKS[fnName] = true
        _rconsoleprint("[DontGrabMe] Hooked: " .. fnName .. "\n")
    else
        _rconsoleprint("[DontGrabMe] Не удалось захукать: " .. fnName .. "\n")
    end
end

hookExecutorRequest("http_request")
hookExecutorRequest("request")
hookExecutorRequest("syn.request")
hookExecutorRequest("fluxus.request")
hookExecutorRequest("http.request")

-- ПУБЛИЧНЫЙ API
getgenv().DontGrabMe = {

    addBlacklist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _rconsoleprint("[DontGrabMe] addBlacklist: некорректный домен\n")
            return
        end
        for _, v in _ipairs(data.blacklist) do
            if v == clean then return end
        end
        _table_insert(data.blacklist, 1, clean)
        _rconsoleprint("[DontGrabMe] Blacklist +: " .. clean .. "\n")
    end,

    addWhitelist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _rconsoleprint("[DontGrabMe] addWhitelist: некорректный домен\n")
            return
        end
        for _, v in _ipairs(data.blacklist) do
            if matchDomain(clean, v) or matchDomain(v, clean) then
                _rconsoleprint("[DontGrabMe] addWhitelist: отклонено — "
                    .. clean .. " конфликтует с blacklist\n")
                return
            end
        end
        for _, v in _ipairs(data.whitelist) do
            if v == clean then return end
        end
        _table_insert(data.whitelist, clean)
        _rconsoleprint("[DontGrabMe] Whitelist +: " .. clean .. "\n")
    end,

    addSuspicious = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then
            _rconsoleprint("[DontGrabMe] addSuspicious: некорректный домен\n")
            return
        end
        for _, v in _ipairs(data.suspicious) do
            if v == clean then return end
        end
        _table_insert(data.suspicious, clean)
        _rconsoleprint("[DontGrabMe] Suspicious +: " .. clean .. "\n")
    end,

    removeBlacklist = function(domain)
        local data = getDataSafe()
        if not data then return end
        local clean = sanitizeDomain(domain)
        if not clean then return end
        for i, v in _ipairs(data.blacklist) do
            if v == clean then
                _table_remove(data.blacklist, i)
                _rconsoleprint("[DontGrabMe] Blacklist -: " .. clean .. "\n")
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
                _rconsoleprint("[DontGrabMe] Whitelist -: " .. clean .. "\n")
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
                _rconsoleprint("[DontGrabMe] Suspicious -: " .. clean .. "\n")
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
            _rconsoleprint("[DontGrabMe] Данные недоступны\n")
            return
        end
        _rconsoleprint(_string_format(
            "[DontGrabMe] Blocked: %d | Suspicious: %d | Allowed: %d\n",
            data.stats.blocked,
            data.stats.suspicious,
            data.stats.allowed
        ))
    end,

    unload = function()
        if namecallHookOk then
            local ok = _pcall(function()
                local mt2 = _getrawmeta(game).
                _setreadonly(mt2, false)
                mt2.__namecall = oldNamecall
                _setreadonly(mt2, true)
            end)
            if ok then
                _rconsoleprint("[DontGrabMe] __namecall восстановлен\n")
            else
                _rconsoleprint("[DontGrabMe] Не удалось восстановить __namecall\n")
            end
        end
        getgenv().DONT_GRAB_ME = nil
        _rconsoleprint("[DontGrabMe] Выгружен.\n")
        _rconsoleprint("[DontGrabMe] hookfunction-хуки активны (ограничение executor API).\n")
        _rconsoleprint("[DontGrabMe] Данные списков сохранены.\n")
    end,
}

_rconsoleprint("[DontGrabMe v4.0] Активен.\n")
_rconsoleprint("[DontGrabMe] DontGrabMe.stats() — статистика.\n")
]=]

-- Запускаем основной код через loadstring (безопасно, т.к. среда уже исправлена)
local success, err = pcall(function()
    loadstring(DontGrabMeScript)()
end)

if not success then
    -- Если даже это не помогло, выведем ошибку
    warn("DontGrabMe не запущен: " .. tostring(err))
end
