-- ═══════════════════════════════════════════════════════════════════════
--  ANTI IP LOGGER + ANTI STEALER  |  v2.1.8  "Pickle Rick Edition"
-- ═══════════════════════════════════════════════════════════════════════
--
--  WHAT IT DOES
--   • ANTI IP LOGGER  - blocks requests to known IP-logger / grabber /
--     geolocation domains, and scrubs IP addresses out of responses.
--   • ANTI STEALER    - cookie guard, loadstring source scan, blocks
--     exfiltration to Discord webhooks and to relay endpoints.
--   • ANTI KICK       - blocks Player:Kick() and tells you to check your
--     inventory (stealers kick right after they take your items).
--   • ANTI ABUSE      - blocks scripts from calling ReportAbuse on you,
--     and from opening Robux purchase prompts you did not ask for.
--   • ANTI-AFK        - keeps you from being disconnected for idling.
--
--  QUICK START
--     loadstring(game:HttpGet("YOUR_URL_HERE"))()
--
--  CONFIGURATION (set these BEFORE loading the script)
--     getgenv()._whitelist = { "mysite.com" }   -- never block these
--     getgenv()._strict_webhook = true          -- block ALL webhooks
--     getgenv()._anti_afk = false               -- disable anti-afk
--     getgenv()._log_blocks = false             -- silence the console
--     -- full list of flags is in SECTION 1 below
--
--  UNLOADING
--     getgenv().AntiLoggerUnload()
--     Disables every check. Rejoin to fully remove installed hooks.
--
-- ═══════════════════════════════════════════════════════════════════════
--  WHAT THIS PROTECTS AGAINST - AND WHAT IT DOES NOT
-- ═══════════════════════════════════════════════════════════════════════
--  Read this before trusting it with a valuable account.
--
--  IT PROTECTS the network layer. Cookie theft, auth-token theft, IP
--  leaks, HWID leaks, webhook exfiltration - these travel over HTTP, and
--  HTTP is what this script controls.
--
--  IT DOES NOT PROTECT against in-game item theft, and no script can do
--  that generically. Item theft happens through the game's own
--  RemoteEvents - the exact same ones you use for a real trade. A call
--  saying "give item X to player Y" looks identical whether you meant it
--  or a stealer sent it. Telling them apart would require knowing every
--  individual game's logic.
--
--  OTHER KNOWN LIMITS:
--   • Domain blocking mostly stops already-known scripts. A fresh relay
--     domain takes a minute to set up.
--   • Anti-bypass is deliberately absent (it crashed Android clients),
--     so a script loaded AFTER this one can re-hook and disable it.
--   • Actors (parallel Luau) run in separate Lua states where these
--     hooks do not apply. The script warns you when it detects them.
--
--  Bottom line: this lowers your risk, it does not remove it. The rule
--  that actually keeps accounts safe is still "do not run scripts from
--  sources you do not trust."
--
-- ═══════════════════════════════════════════════════════════════════════
--  CHANGELOG
-- ═══════════════════════════════════════════════════════════════════════
--  v2.1.8
--   • All user-facing output is now English, and the "[AntiLogger]"
--     prefix was dropped.
--   • Console noise cut down: the kick report was a multi-line box that
--     replayed the whole log on every kick; it is now one line with the
--     last blocked action. The Actor warning went from 8 lines to 1.
--   • Added Anti-AFK via VirtualUser (getgenv()._anti_afk).
--   • Added getgenv().AntiLoggerUnload() to shut the script down.
--
--  v2.1.7
--   • Internal primitives (string.find, pcall, pairs...) are now taken
--     via clonefunction. Plain assignment did NOT protect them:
--     hookfunction patches functions in place, so a stealer loaded
--     BEFORE this script could hook string.find and silently disable all
--     detection - no errors, we would just report "clean" while data
--     leaked. Technique borrowed from HttpSpy.
--   • Added monitoring of game:GetObjects(), which was a completely
--     unwatched network path: it fetches assets by URL and on some
--     executors accepts plain http(s) addresses.
--   • Added Actor detection warning (see limits above).
--
--  v2.1.6 - false positive cleanup
--   • BLACKLIST no longer does bare substring matching on hosts.
--     "ipdata" was matching chipdatabase.com, "ipinfo" matched
--     shipinfo.com, "ipstack" matched shipstack.com - all legitimate
--     domains were being blocked. Matching now respects domain label
--     boundaries.
--   • Removed the "rap" field from sensitive-body detection and
--     rewrote the matcher. It searched raw body text, so "rap" matched
--     inside "wrapped" - a harmless webhook posting
--     {"event":"round wrapped up"} was blocked as a data leak. Matching
--     now only looks at FIELD NAMES, never at values.
--   • IPv4 octets are now range-checked, and version/build fields are
--     protected so "2.0.14.7" stays a version instead of becoming a
--     fake IP.
--   • IPv6 scrubbing was broken: the old pattern required 8 full groups,
--     so real addresses in shortened form ("2001:db8::1") were never
--     scrubbed at all. Now handles "::" form.
--   • Relay hosts are checked on GET too - exfiltration via query string
--     used to pass straight through.
--
--  v2.1.5
--   • Fixed false positives in games like "Steal a Brainrot": words in
--     the game's own title are no longer treated as evidence. Hard
--     signatures (cookie, authticket) are never suppressed this way.
--   • Webhooks are judged by CONTENT, not just destination. Plenty of
--     legitimate scripts post scores and stats to their own Discord;
--     blocking all of them was wrong. Now cookie/token/inventory = block,
--     score/time/level = allow. Use _strict_webhook to block everything.
--   • Added kick forensics and the Pickle Rick notification icon.
--
--  v2.1.4
--   • Closed the main hole: webhook relays. None of the analysed stealer
--     samples posted to discord.com directly - they all posted to their
--     own relay on free hosting (onrender.com, vercel.app), which then
--     forwarded to Discord. Those POSTs are now blocked.
--   • Added blocking of bare IPv4 endpoints (no domain to blacklist).
--
--  v2.1.3
--   • Added 242 exact domains from the curated part of Piperun's
--     IP-Logger Filter.
--
--  v2.1.2
--   • Fixed Robux prompt blocking, which blocked ALL purchases in ALL
--     games. Games legitimately call PromptPurchase from their own
--     LocalScripts when you click "buy"; checkcaller() returns false for
--     those. Now only non-game-script callers are blocked.
--   • sanitizeBody no longer rewrites responses from whitelisted hosts.
--
--  v2.1.1
--   • Removed anti-bypass entirely. It caused a hard client crash
--     (SIGSEGV) on Android: hooking hookfunction with hookfunction sends
--     some executors into native-level infinite recursion that pcall
--     cannot catch. If you are on v2.1.0, replace it.
--
-- ═══════════════════════════════════════════════════════════════════════
--  ARCHITECTURAL LIMITS (not bugs - inherent to any local script)
-- ═══════════════════════════════════════════════════════════════════════
--   • Anti-kick only blocks Kick() calls made from Lua. A server-side
--     kick (the game itself removing you) cannot be blocked - that is the
--     server's decision and a local hook has no say in it.
--   • sanitizeBody scrubs responses that have already ARRIVED. If a
--     malicious script managed to SEND your real IP before being blocked,
--     what already left cannot be recalled.
--   • Redirect chains, WebSocket payloads beyond the cookie signature,
--     heavily obfuscated or dynamically assembled code, and network APIs
--     the executor does not expose through standard functions can all
--     slip past the filter. No local anti-logger gives a full guarantee;
--     this is a limit of the approach, not of this version.
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
--  SECTION 0 — RE-EXECUTION GUARD
-- ═══════════════════════════════════════════════════════════════════════
if getgenv().__AntiLoggerUnifiedLoaded then
    warn("Already loaded; skipping re-execution to avoid stacking hooks.")
    return
end
getgenv().__AntiLoggerUnifiedLoaded = true

-- ═══════════════════════════════════════════════════════════════════════
--  SECTION 1 — SETTINGS
-- ═══════════════════════════════════════════════════════════════════════
getgenv()._blockwebhook = true
getgenv()._sanitize_ip = true
getgenv()._log_blocks = true
getgenv()._anti_kick = true
getgenv()._scan_loadstring = true
getgenv()._verbose_soft_warnings = false

-- v2.1.0 toggles
getgenv()._anti_reportabuse = true
getgenv()._anti_robux_prompt = true

-- v2.1.4: два новых переключателя, закрывающие реальные дыры, найденные при
-- разборе живых семплов стилеров (см. changelog в шапке).
--
-- _block_bare_ip — блокировать запросы, у которых хост это голый IPv4
-- (например http://93.183.83.94:8000/webhook/...). Легитимный трафик
-- игры практически никогда не ходит на сырой IP — там всегда домен.
-- А вот стилеры так делают часто: у сырого IP нет домена, который можно
-- было бы внести в блок-лист, и он не палится в чужих списках доменов.
getgenv()._block_bare_ip = true
--
-- _block_relay_hosts — блокировать POST на бесплатные хостинг-платформы
-- (vercel.app, onrender.com, workers.dev и т.п.). Это главный современный
-- обход: стилер НЕ шлёт данные напрямую на discord.com/api/webhooks
-- (это все блокируют), а шлёт на свой маленький релей, развёрнутый
-- бесплатно на Vercel/Render, а тот уже пересылает в Discord. Для нашего
-- хука это выглядит как обычный POST на незнакомый домен.
-- ВНИМАНИЕ: это эвристика, а не список known-bad. Часть легитимных
-- скриптов хостит свои API на тех же платформах. Если какой-то нужный
-- тебе скрипт перестал работать — добавь его домен в _whitelist ниже
-- или выключи этот переключатель.
getgenv()._block_relay_hosts = true

-- v2.1.5: новые переключатели
--
-- _strict_webhook — если true, блокируется ЛЮБОЙ webhook, даже безобидный.
-- По умолчанию false: многие нормальные скрипты шлют в свой Discord
-- рекорды и статистику, и блокировать их без разбора — значит ломать
-- легитимные скрипты. При false решение принимается по содержимому тела
-- (cookie/токен/инвентарь = блок, счёт и время = пропуск).
getgenv()._strict_webhook = false
--
-- _game_context_aware — не считать уликой слова, которые есть в названии
-- самой игры. Без этого «Steal a Brainrot» помечает почти любой скрипт,
-- потому что слово "steal" там в названии. Жёстких сигнатур
-- (cookie, authticket и т.п.) это послабление НЕ касается.
getgenv()._game_context_aware = true
--
-- _kick_forensics — при попытке кика показать, что скрипт делал
-- перед этим. Стилеры часто кикают сразу после кражи, чтобы жертва
-- не увидела пропажу и не успела отменить трейд.
getgenv()._kick_forensics = true
--
-- _warn_actor_risk — предупреждать, если в игре есть Actor'ы
-- (параллельный Luau). У Actor'ов свой Lua-стейт, наши хуки на них не
-- действуют, и скрипт внутри Actor'а может обойти защиту целиком.
-- Закрыть это без переписывания под actor-архитектуру нельзя, поэтому
-- хотя бы честно предупреждаем.
getgenv()._warn_actor_risk = true

-- v2.1.8: Anti-AFK. Keeps Roblox from disconnecting you for inactivity
-- by simulating a tiny input whenever the client reports you as idle.
-- Uses the standard VirtualUser approach.
--
-- Why this belongs in a security script: the 20-minute idle kick is one
-- of the moments people get logged out mid-session and then blindly
-- re-run whatever script they had loaded. Staying connected means fewer
-- reloads of untrusted code. It is also just convenient.
getgenv()._anti_afk = true

-- Иконка уведомлений: Огурчик Рик
getgenv()._icon_asset = getgenv()._icon_asset or "rbxassetid://83768500686029"

getgenv()._whitelist = getgenv()._whitelist or {
    "roblox.com", "rbxcdn.com",
}

getgenv()._loadstring_whitelist = getgenv()._loadstring_whitelist or {
}

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 2 — БАЗОВЫЕ УТИЛИТЫ
-- ═══════════════════════════════════════════════════════════════════════
local cloneref = cloneref or clone_reference or function(o) return o end
local realGame = cloneref(game)
local HttpService = cloneref(game:GetService("HttpService"))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Market = game:GetService("MarketplaceService")

-- ═══════════════════════════════════════════════════════════════════════
--  v2.1.7 — ЗАЩИТА СОБСТВЕННЫХ ПРИМИТИВОВ (приём взят из HttpSpy)
-- ═══════════════════════════════════════════════════════════════════════
-- ПРОБЛЕМА, которую это закрывает:
-- Раньше здесь было простое присваивание:
--     local sfind = string.find
-- Кажется, что взятие ссылки защищает. НЕ ЗАЩИЩАЕТ. hookfunction
-- патчит саму функцию НА МЕСТЕ, поэтому сохранённая ссылка указывает
-- на уже подменённую версию.
--
-- Что это значит на практике: если стилер запустился РАНЬШЕ нас и
-- сделал hookfunction(string.find, ...), заставив её врать на нужных
-- ему строках, — вся наша система обнаружения тихо перестаёт работать.
-- Никаких ошибок, просто isBlocked всегда возвращает false. Мы
-- показываем «всё чисто», пока данные утекают.
--
-- clonefunction создаёт НЕЗАВИСИМУЮ копию, на которую чужие хуки уже
-- не действуют. Именно поэтому HttpSpy оборачивает в clonefunction
-- вообще всё, что использует внутри.
--
-- Честная граница: если стилер запустился раньше нас, он мог захукать
-- и сам clonefunction. Полной гарантии тут быть не может — но это
-- поднимает планку с «тривиально обходится» до «нужно целиться
-- именно в нас».
local function safeClone(fn, fallback)
    if type(clonefunction) == "function" and type(fn) == "function" then
        local ok, cloned = pcall(clonefunction, fn)
        if ok and type(cloned) == "function" then
            return cloned
        end
    end
    return fallback or fn
end

local sfind  = safeClone(string.find)
local slower = safeClone(string.lower)
local smatch = safeClone(string.match)
local gsub   = safeClone(string.gsub)
local rnd    = safeClone(math.random)

-- Эти тоже критичны: на них держится вся логика проверок.
local _pcall   = safeClone(pcall)
local _pairs   = safeClone(pairs)
local _ipairs  = safeClone(ipairs)
local _type    = safeClone(type)
local _tostring = safeClone(tostring)
local _warn    = safeClone(warn)

local COOKIE_SIG = "warning:-do-not-share-this."

local function urlDecode(s)
    if type(s) ~= "string" then return s end
    local ok, out = pcall(function()
        return (gsub(s, "%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
    end)
    return ok and out or s
end

local function getHost(url)
    if type(url) ~= "string" then return "" end
    local rest = gsub(url, "^%w[%w%+%.%-]*://", "")
    local authority = smatch(rest, "^([^/?#]+)") or rest
    authority = smatch(authority, "@(.+)$") or authority
    local host = smatch(authority, "^([^:]+)") or authority
    host = gsub(host, "%.$", "")
    return slower(host)
end

local function isWhitelisted(host)
    if not host or host == "" then return false end
    for _, w in ipairs(getgenv()._whitelist or {}) do
        w = slower(w)
        if host == w or (#host > #w and host:sub(-(#w + 1)) == "." .. w) then
            return true
        end
    end
    return false
end

local function fakeIPv4()
    local a = rnd(1, 223); if a == 127 then a = 128 end
    return ("%d.%d.%d.%d"):format(a, rnd(0, 255), rnd(0, 255), rnd(1, 254))
end

local function fakeIPv6()
    return ("fd00:%x:%x:%x:%x:%x:%x:%x"):format(
        rnd(0, 0xffff), rnd(0, 0xffff), rnd(0, 0xffff), rnd(0, 0xffff),
        rnd(0, 0xffff), rnd(0, 0xffff), rnd(0, 0xffff)
    )
end

local function getCallingScriptName()
    if type(getcallingscript) ~= "function" then
        return "unknown (getcallingscript недоступен)"
    end
    local ok, scr = pcall(getcallingscript)
    if not ok or not scr then return "unknown" end
    local nameOk, fullName = pcall(function() return scr:GetFullName() end)
    if nameOk and fullName then return fullName end
    local n2ok, n2 = pcall(function() return scr.Name end)
    if n2ok and n2 then return tostring(n2) end
    return "unknown"
end

-- Отличаем вызов из НАСТОЯЩЕГО скрипта игры (обычный LocalScript,
-- который реально запарентен в дерево game — так вызывают
-- PromptPurchase и т.п. сами разработчики игр) от вызова из
-- инжектнутого/loadstring-кода (у такого либо нет реального Instance
-- за душой, либо checkcaller() уже вернул true раньше в этой же
-- цепочке проверок). Не идеальная защита (некоторые executor'ы могут
-- подделать Instance), но резко снижает число false positive на
-- легитимных покупках в играх.
local function isCallFromRealGameScript()
    if type(getcallingscript) ~= "function" then return false end
    local ok, scr = pcall(getcallingscript)
    if not ok or not scr then return false end
    local descOk, isDesc = pcall(function() return scr:IsDescendantOf(game) end)
    return descOk and isDesc == true
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 3 — СПИСКИ
-- ═══════════════════════════════════════════════════════════════════════
local BLACKLIST = {
    "grabify", "iplogger", "cliip", "blasze", "stopify", "goo.by", "2no.co",
    "yip.su", "leakix", "spylogger", "ip-tracker", "ip-track", "ip-grab",
    "ip-collect", "ip-sniff", "ip-harvest", "ip-capture", "ip-gather",
    "ip-api", "ipify", "apiip", "ipwho", "ipinfo", "ipgeolocation", "ipdata",
    "ipapi", "ipstack", "ip2location", "maxmind", "db-ip", "country.is",
    "ipxapi", "radar", "whoisxmlapi", "geoapify", "iplocate", "iptrackertool",
    "api-ninjas", "apifreaks", "geo.ipify", "findip", "freeipapi", "neutrinoapi",
    "hackertarget", "api.ip.sb", "ipinfodb", "getgeoapi", "geoplugin", "ipregistry",
    "abstractapi", "extreme-ip-lookup", "geolocation-db", "checkip.amazonaws",
    "api.myip", "wtfismyip", "icanhazip", "ifconfig", "ident.me", "httpbin.org",
    "abuseipdb", "virustotal", "otx.alienvault", "threatcrowd", "urlscan",
    "whatismyipaddress", "myip.ms", "ip-detect", "ipchicken", "ip-address.org",
    "ip-score", "ipqualityscore", "scamalytics", "ipscore", "ipintel",
    "ipblacklist", "dnslytics", "viewdns", "yougetsignal", "iplocation.net",
    "geotargeting", "geobytes", "geocode", "maps.googleapis",
    "nominatim.openstreetmap", "ipvigilante", "ip-geolocation.io", "ip-api.io",
    "ip-info.io", "ip-lookup.net", "ip-details.com", "ip-tracker.org",
    "iplogger.com.ua", "iplogger.org.ua", "iplogger.net", "ip-logger.com",
    "logip.net", "trackip.net", "ip-tracker.net", "ipgrabber", "ipgraber",
    "iplis.ru", "iplog.co", "maper.info", "ps3cfw.com", "wl.gl", "bc.ax",
    "ed.tc", "ezstat.ru", "02ip.ru", "browserleaks", "whoer", "ipleak",
    "canarytokens", "roproxy",
    "roware.space", "globalcheats.cc", "darkscripts", "egorikusa",
    "hookbin", "pipedream", "webhook-test.com",
    "webhook.site", "webhook.in", "hook.io",
    "pushover.net", "ntfy.sh", "gotify.net", "matrix.org",
    "requestbin", "leancoding", "beeceptor", "requestcatcher", "run.mocky.io",
}

local SuspiciousTLDs = { "tk", "ml", "ga", "cf", "gq" }

-- v2.1.6: ключи, которые достаточно специфичны, чтобы искать их ВНУТРИ
-- одной метки домена (ловит зеркала вида "iplogger-mirror.net",
-- "grabify2.xyz"). Сюда попадают только строки, которые не встречаются
-- как случайная подстрока обычных английских слов.
--
-- Специально НЕ включены короткие/общие фрагменты, из-за которых раньше
-- блокировались легитимные домены:
--   "ipdata"/"ipinfo"/"ipstack"/"ipapi"/"apiip"/"ipwho" — ловились в
--     chipdatabase.com, shipinfo.com, shipstack.com, worshipapi.com;
--   "radar"/"geocode"/"findip"/"ipscore"/"viewdns" — слишком общие слова.
-- Все они по-прежнему блокируются как ТОЧНЫЕ домены через BLACKLIST выше
-- (ipdata.co, ipinfo.io, ipstack.com и т.д. никуда не делись) — потеряна
-- только ловля их произвольных зеркал, что дешевле ложных блоков.
local BLACKLIST_LABEL_SUBSTRING = {
    "grabify", "iplogger", "ip-logger", "spylogger", "ipgrabber", "ipgraber",
    "iploggger", "blasze", "canarytoken", "webhook-test", "requestbin",
    "beeceptor", "requestcatcher", "hookbin", "pipedream", "webhook.site",
    "egorikusa", "darkscripts", "globalcheats", "roware",
}

-- Точные домены известных IP-логгеров/шортенеров/буттеров, взятые из
-- публичного фильтр-листа Piperun's IP-Logger Filter (github.com/piperun/
-- iploggerfilter), курируемая часть "Main"/"Standalones". Массовые списки
-- скомпрометированных сайтов 2020 года (разделы "Blazse Loggers" и
-- "PS3CFW Loggers", ~680 доменов) НЕ включены сюда намеренно — это старые,
-- давно не обновлявшиеся списки взломанных обычных сайтов (турагентства,
-- стоматологии, локальный бизнес и т.п.), собранные для контекста
-- ad-block'а в браузере, где цена ложной блокировки нулевая. В контексте
-- скрипта для Roblox эти конкретные домены почти наверняка никогда не
-- встретятся в реальном трафике — а раз так, овчинка выделки не стоит:
-- ежегодно часть таких доменов освобождается и перепродаётся не связанным
-- с логгерами владельцам, что превращает старый список в тихий источник
-- будущих false positive без реальной пользы взамен. Если хочешь — можно
-- добавить и их отдельным файлом, но по умолчанию оставлены только домены
-- из курируемой/актуальной части списка.
-- Проверяются точным совпадением хоста или его поддоменов, O(1) через hash-таблицу.
local EXACT_DOMAIN_SET = {
    ["5.gp"] = true,
    ["7.ly"] = true,
    ["adf.ly"] = true,
    ["adfly-bot.online"] = true,
    ["adfoc.us"] = true,
    ["ahref.tech"] = true,
    ["ajc1.cn"] = true,
    ["alanlindsay.net"] = true,
    ["ampnode.host"] = true,
    ["anonfiles.download"] = true,
    ["anonymousforum.pw"] = true,
    ["aruljohn.com"] = true,
    ["asianrbtrade.net"] = true,
    ["atharori.net"] = true,
    ["barefoot.pics"] = true,
    ["bathtub.pics"] = true,
    ["battlė.net"] = true,
    ["bbcbloggers.co.uk"] = true,
    ["bbcnews.today"] = true,
    ["bc.vc"] = true,
    ["bit.do"] = true,
    ["bitly-bot.com"] = true,
    ["biturl.io"] = true,
    ["bmwforum.co"] = true,
    ["boot4free.com"] = true,
    ["booter.icu"] = true,
    ["bootyou.net"] = true,
    ["bucks.as"] = true,
    ["bvog.com"] = true,
    ["catsnthing.com"] = true,
    ["catsnthings.fun"] = true,
    ["cheapcinema.club"] = true,
    ["cloudfsx.com"] = true,
    ["cnyc99.com"] = true,
    ["community.hackersclub.net"] = true,
    ["crabrave.pw"] = true,
    ["critical-boot.com"] = true,
    ["csgopot.zone"] = true,
    ["cubeupload.xyz"] = true,
    ["cur.lv"] = true,
    ["curiouscat.club"] = true,
    ["cutt.ly"] = true,
    ["cyberh1.xyz"] = true,
    ["dank.host"] = true,
    ["datasig.io"] = true,
    ["datauth.io"] = true,
    ["dateing.club"] = true,
    ["ddos.city"] = true,
    ["deviantartt.ga"] = true,
    ["deviantartt.ml"] = true,
    ["discordcrypt.xyz"] = true,
    ["discörd.com"] = true,
    ["disçordapp.com"] = true,
    ["disċordapp.com"] = true,
    ["downthe.design"] = true,
    ["dr.tl"] = true,
    ["dropbox.desi"] = true,
    ["dropboxx.cf"] = true,
    ["dropboxx.ga"] = true,
    ["dropboxx.lm"] = true,
    ["dxrbc.cn"] = true,
    ["exec-true.eu"] = true,
    ["exploit-db.xyz"] = true,
    ["files.uploads.ws"] = true,
    ["foot.wiki"] = true,
    ["fortnight.space"] = true,
    ["fortnite-stats.site"] = true,
    ["fortnitechat.site"] = true,
    ["fotocerdas.com"] = true,
    ["freeanonymous.host"] = true,
    ["freebooter.pro"] = true,
    ["freegiftcards.co"] = true,
    ["fuglekos.com"] = true,
    ["gamer.hair"] = true,
    ["gamer.tattoo"] = true,
    ["gamergirl.pro"] = true,
    ["gameskeys.shop"] = true,
    ["gaming-at-my.best"] = true,
    ["gamingfun.me"] = true,
    ["go.budurl.co"] = true,
    ["gtadb.net"] = true,
    ["gyazo.nl"] = true,
    ["gyazoo.ga"] = true,
    ["gyazoo.xyz"] = true,
    ["hackernews.online"] = true,
    ["hackforu.ms"] = true,
    ["hackfȯrums.com"] = true,
    ["hackfȯrums.net"] = true,
    ["hbotv.co"] = true,
    ["hdblog.tech"] = true,
    ["headshot.monster"] = true,
    ["hondachat.com"] = true,
    ["hostingonline.desi"] = true,
    ["hs.vc"] = true,
    ["hwhssc.cn"] = true,
    ["i.imger.me"] = true,
    ["iany.pl"] = true,
    ["ikwyd.com"] = true,
    ["imagehost.pics"] = true,
    ["imageshack.ml"] = true,
    ["imageshare.best"] = true,
    ["imagevault.cloud"] = true,
    ["imger.me"] = true,
    ["imghost.pics"] = true,
    ["imgurl.us"] = true,
    ["imgúr.com"] = true,
    ["ip-puller.com"] = true,
    ["ip-trap.com"] = true,
    ["ip.jlynx.net"] = true,
    ["ipddoser.xyz"] = true,
    ["iplo.ru"] = true,
    ["ipsnatcher.com"] = true,
    ["joinmy.site"] = true,
    ["l-imgur.pl"] = true,
    ["leakforum.ga"] = true,
    ["linkify.me"] = true,
    ["linkit.cf"] = true,
    ["login.anal-porn.info"] = true,
    ["lovebird.guru"] = true,
    ["maifile.cn"] = true,
    ["mailble.com"] = true,
    ["mapper.info"] = true,
    ["massive.boats"] = true,
    ["massive.mom"] = true,
    ["media.appspot.com"] = true,
    ["minecraft-skins.xyz"] = true,
    ["minecräft.com"] = true,
    ["mjzssc.cn"] = true,
    ["my-alts.eu"] = true,
    ["my.su"] = true,
    ["myiptest.com"] = true,
    ["mymassive.store"] = true,
    ["mymassive.top"] = true,
    ["mymassive.yachts"] = true,
    ["myprivate.pics"] = true,
    ["networkstresser.com"] = true,
    ["nnmssc.cn"] = true,
    ["noodshare.pics"] = true,
    ["orboot.pw"] = true,
    ["orcahub.com"] = true,
    ["otherhalf.life"] = true,
    ["ouo.io"] = true,
    ["oxystress.eu"] = true,
    ["panel.teamspeak.bz"] = true,
    ["parlament.usa.cc"] = true,
    ["paypal.sellbitcoins.com"] = true,
    ["photovault.pics"] = true,
    ["pichost.pics"] = true,
    ["picshost.pics"] = true,
    ["plz.life"] = true,
    ["postimage.co"] = true,
    ["printscr.ga"] = true,
    ["privatexmpp.me"] = true,
    ["prntsc.cf"] = true,
    ["progaming.monster"] = true,
    ["proxyfill.co"] = true,
    ["publicwiki.m"] = true,
    ["publicwiki.me"] = true,
    ["quickmessage.io"] = true,
    ["quickmessage.us"] = true,
    ["r1p.pw"] = true,
    ["restresser.com"] = true,
    ["rikiki.net"] = true,
    ["rëddït.com"] = true,
    ["sciencefuture.tk"] = true,
    ["screenshare.host"] = true,
    ["screenshare.pics"] = true,
    ["screenshot.best"] = true,
    ["sexy18.webcam"] = true,
    ["shareit.pics"] = true,
    ["shipment.website"] = true,
    ["shorte.st"] = true,
    ["shrekis.life"] = true,
    ["shört.co"] = true,
    ["skidpaste.org"] = true,
    ["skypecracker.xyz"] = true,
    ["skypegrab.net"] = true,
    ["slsh.us"] = true,
    ["snipe.blue"] = true,
    ["soo.gd"] = true,
    ["spoofing.host"] = true,
    ["spottyfly.com"] = true,
    ["spötify.com"] = true,
    ["starbucks.bio"] = true,
    ["starbucksisbadforyou.com"] = true,
    ["starbucksiswrong.com"] = true,
    ["steamtools.co"] = true,
    ["stock-images.0o.si"] = true,
    ["stonks.boats"] = true,
    ["stonks.fun"] = true,
    ["strawpoll.ga"] = true,
    ["strawpolll.ga"] = true,
    ["stresser.science"] = true,
    ["sugma.mom"] = true,
    ["särahah.eu"] = true,
    ["särahah.pl"] = true,
    ["sĸype.com"] = true,
    ["taveo.net"] = true,
    ["thisdomainislong.lol"] = true,
    ["tigercore.eu"] = true,
    ["tiny.cc"] = true,
    ["tldr.ly"] = true,
    ["tnfbc.cn"] = true,
    ["toes.beauty"] = true,
    ["toldyouso.lol"] = true,
    ["toldyouso.pics"] = true,
    ["toolce.cn"] = true,
    ["topcdn.biz"] = true,
    ["topstreaming.us"] = true,
    ["transferfiles.cloud"] = true,
    ["trulove.guru"] = true,
    ["ts3free.top"] = true,
    ["tvshare.co"] = true,
    ["twitch-stats.stream"] = true,
    ["twitte.ga"] = true,
    ["twiţter.com"] = true,
    ["vbooter.org"] = true,
    ["vdos-s.com"] = true,
    ["videoblog.tech"] = true,
    ["viphackforum.xyz"] = true,
    ["viphackforums.xyz"] = true,
    ["watches-my.stream"] = true,
    ["webprofile.me"] = true,
    ["wzurl.me"] = true,
    ["xda-developers.io"] = true,
    ["xda-developers.us"] = true,
    ["xxox.co.uk"] = true,
    ["youramonkey.com"] = true,
    ["yourmy.monster"] = true,
    ["youshouldclick.us"] = true,
    ["youutube.gq"] = true,
    ["yoütu.be"] = true,
    ["yoütübe.co"] = true,
    ["yoütübe.com"] = true,
    ["ythingy.com"] = true,
    ["yum.mom"] = true,
    ["yòutube.com"] = true,
    ["yȯutube.com"] = true,
    ["zjrbc.cn"] = true,
    ["zzb.bz"] = true,
    ["ìṃgur.com"] = true,
    ["ġooģle.com"] = true,
}

-- O(1)-проверка хоста и его родительских доменов по EXACT_DOMAIN_SET
-- (например host = "sub.grabify.link" должен матчиться на "grabify.link").
local function isExactBlacklisted(host)
    if not host or host == "" then return false end
    if EXACT_DOMAIN_SET[host] then return true end
    local rest = host
    while true do
        local dot = sfind(rest, ".", 1, true)
        if not dot then break end
        rest = rest:sub(dot + 1)
        if rest == "" then break end
        if EXACT_DOMAIN_SET[rest] then return true end
    end
    return false
end

local WebhookPatterns = {
    { "discord.com", "/api/webhooks" },
    { "discordapp.com", "/api/webhooks" },
    { "telegram.org", "/bot" },
    { "api.telegram.org", "/bot" },
    { "hooks.slack.com", "/services" },
    { "slack.com", "/services" },
    { "teams.microsoft.com", "/webhook" },
    { "guilded.gg", "/api/webhooks" },
    { "hooks.hyra.io", "" },
    { "hooks.guilded.gg", "" },
    { "zapier.com", "/hooks" },
    { "make.com", "/webhook" },
    { "n8n.cloud", "" },
    { "automate.io", "" },
    { "integromat.com", "" },
}

-- v2.1.4: суффиксы бесплатных хостинг-платформ, на которых стилеры
-- разворачивают webhook-релеи. В разобранных семплах живьём встретились
-- proxykoyeb.onrender.com, rubix-scanner.vercel.app и
-- proxy-plum-beta.vercel.app — все три просто пересылают собранные данные
-- в Discord, обходя блокировку самого discord.com/api/webhooks.
-- Проверяются ТОЛЬКО на POST-запросах (GET на такие домены безобиден:
-- на них часто лежат обычные сайты и статика).
local RelayHostSuffixes = {
    "vercel.app", "onrender.com", "koyeb.app", "workers.dev", "deno.dev",
    "replit.dev", "repl.co", "railway.app", "up.railway.app", "glitch.me",
    "fly.dev", "netlify.app", "pages.dev", "cyclic.app", "adaptable.app",
    "herokuapp.com", "trycloudflare.com", "loca.lt", "serveo.net",
    "ngrok.io", "ngrok-free.app", "ngrok.app", "telebit.io", "cloudno.de",
}

-- v2.1.4: точные exfil-эндпоинты, вытащенные из разобранных семплов.
-- Эти уже засвечены и, скорее всего, часть из них умрёт — но пока живы,
-- блокируются точным совпадением.
local KnownExfilHosts = {
    ["proxykoyeb.onrender.com"] = true,
    ["rubix-scanner.vercel.app"] = true,
    ["proxy-plum-beta.vercel.app"] = true,
    ["pastefy.app"] = true,
}

-- v2.1.5: поля, которые в теле запроса означают РЕАЛЬНУЮ утечку.
-- Идея: webhook сам по себе не преступление. Куча нормальных скриптов
-- шлёт в свой Discord рекорды, статистику фарма, «скрипт запущен» и т.п.
-- Отличается не адрес, а СОДЕРЖИМОЕ: рекорд — это счёт и время, а кража —
-- это cookie, токен авторизации или опись твоего инвентаря.
-- v2.1.6 (пункт 2 багрепорта): УБРАНО поле "rap".
-- Оно искалось как подстрока по всему телу, а "rap" ⊂ "wrapped",
-- "wrapper", "trap", "scrap", "grape". Живой ложняк:
--   {"event":"round wrapped up","score":120}
-- содержит "wrapped" → содержит "rap" → безобидный статус-webhook
-- блокировался как утечка. Специфичные "totalrap"/"limiteds"/"networth"
-- остались — они не встречаются в обычных словах.
local SensitiveBodyFields = {
    -- авторизация / захват аккаунта — это всегда красная линия
    "roblosec" .. "urity", "getauthticket", "authticket", "auth_ticket",
    ".robloxsecurity", "securitytoken", "x-csrf-token", "csrftoken",
    "cookie", "cookies", "sessionid", "session_id", "refreshtoken",
    "accesstoken", "access_token",
    -- идентификаторы устройства/сессии, по которым тебя связывают между акками
    "clientid", "client_id", "sessionlogid", "playsessionid",
    "hwid", "hardwareid", "machineid", "identityhash",
    -- опись имущества: типичная «витрина» стилера перед кражей
    "inventory", "backpack_items", "iteminventory", "ownedgamepasses",
    "collectibles", "limiteds", "totalrap", "networth",
}

-- Поля, характерные для БЕЗОБИДНЫХ webhook'ов (рекорды, лидерборды,
-- статистика). Наличие этих полей само по себе ничего не разрешает,
-- но помогает не считать подозрительным обычный пост про рекорд.
local BenignBodyFields = {
    "score", "highscore", "high_score", "record", "leaderboard",
    "time", "elapsed", "duration", "kills", "deaths", "wins", "losses",
    "level", "stage", "wave", "round", "checkpoint", "progress",
    "version", "status", "started", "finished", "completed",
}

-- v2.1.6 (пункт 2 багрепорта): РАНЬШЕ здесь был sfind по сырому телу —
-- принципиально хрупкий подход для JSON. Теперь ищем совпадения только
-- среди ИМЁН ПОЛЕЙ, а не в произвольном тексте:
--   • JSON-ключи:      "field":
--   • form-urlencoded: field=  /  &field=
-- Значения полей (там и живёт обычный человеческий текст вроде
-- "round wrapped up") больше не участвуют в проверке вообще.
local function countFieldHits(bodyStr, fields)
    if type(bodyStr) ~= "string" or bodyStr == "" then return 0, nil end
    local bl = bodyStr:lower()

    -- Собираем множество имён полей, реально присутствующих в теле.
    local presentKeys = {}
    -- JSON:  "key" :
    for k in bl:gmatch('"([^"]+)"%s*:') do
        presentKeys[k] = true
    end
    -- form-urlencoded:  key=  (в начале тела или после & / ?)
    for k in bl:gmatch('[&%?]([%w_%-%.]+)=') do
        presentKeys[k] = true
    end
    for k in bl:gmatch('^([%w_%-%.]+)=') do
        presentKeys[k] = true
    end

    local hits, firstHit = 0, nil
    for _, f in ipairs(fields) do
        -- точное совпадение имени поля
        if presentKeys[f] then
            hits = hits + 1
            firstHit = firstHit or f
        else
            -- либо имя поля содержит искомое как часть (userCookie,
            -- robloxSecurityToken и т.п.) — но проверяем ТОЛЬКО имена
            -- полей, не значения.
            for k in pairs(presentKeys) do
                if sfind(k, f, 1, true) then
                    hits = hits + 1
                    firstHit = firstHit or f
                    break
                end
            end
        end
    end
    return hits, firstHit
end

-- Решение по webhook'у: блокировать только если в теле есть чувствительные
-- данные. Пустое тело/рекорд/статистика — пропускаем.
-- Возвращает: shouldBlock (bool), reason (string|nil)
local function webhookBodyVerdict(bodyStr)
    local sensitive, which = countFieldHits(bodyStr, SensitiveBodyFields)
    if sensitive > 0 then
        return true, "чувствительное поле в теле: \"" .. tostring(which) ..
                     "\" (всего совпадений: " .. sensitive .. ")"
    end
    -- Тело есть, но чувствительного в нём нет — это, скорее всего,
    -- обычный рекорд/уведомление. Пропускаем.
    return false, nil
end

local LocationFields = {
    "country", "region", "city", "zip", "postal",
    "lat", "latitude", "lon", "longitude", "timezone",
    "isp", "org", "as", "asn", "country_code", "region_code",
    "continent", "continent_code", "ip", "ipaddress", "ip_address",
    "query", "origin", "ipv4", "ipv6", "publicip", "public_ip"
}

local SuspiciousHeaders = {
    "^x%-forwarded%-for", "^x%-real%-ip", "^cf%-connecting%-ip",
    "^x%-client%-ip", "^forwarded$", "^true%-client%-ip",
    "%-ip$", "^ip$", "^ipaddress$", "^ip_address$",
    "^publicip$", "^public_ip$", "^remoteip$", "^remote_ip$"
}

-- ВАЖНО: строки собраны через конкатенацию (".." вместо цельных литералов).
-- Если написать их одной строкой, наш ЖЕ файл (при повторном запуске
-- через loadstring, например если пользователь выполнит скрипт дважды в
-- одной сессии — второй запуск пройдёт уже ЧЕРЕЗ наш собственный
-- loadstring-хук) будет содержать точно такую подстроку в этой самой
-- таблице и заблокирует сам себя как "стилера". Конкатенация разбивает
-- совпадение на уровне исходного текста, runtime-значение не меняется.
local CodeBlacklistHard = {
    "getcookiesa" .. "sync",
    "roblosecur" .. "ity",
    "webhookrou" .. "ter",
    "getdiscu" .. "ser",
    "cmd" .. ".exe",
    ":50" .. "00/",
    "smallhitswebh" .. "ook",
    "__sab_run_on" .. "ce",
    "stealerst" .. "ock",
}

local CodeBlacklistSoft = {
    "stealer", "stolen", "ratt", "all your items", "linkingservice",
    "grabify", "iplogger", "ipify", "canihazip", "checkip", "externalip",
    "tobi's", "myip", "ipconfig", "trade", "mailbox",
    "discordid",
    -- v2.1.6 (пункт 3 багрепорта): было две записи, "usernames = {" и
    -- "usernames = ". Вторая — надмножество первой, то есть первая
    -- никогда не срабатывала уникально. При этом голое "usernames = "
    -- ловит любое объявление таблицы с таким именем, включая обычные
    -- списки админов в whitelist-скриптах:
    --     local usernames = { "Player1", "Player2" }
    -- Оставлена одна запись, суженная до паттерна, который характерен
    -- именно для сбора данных ПО ВСЕМ игрокам сервера.
    "getplayers()) do", "for _, plr in pairs(game.players",
    "discord.com/api/webhooks", "discordapp.com/api/webhooks",
}

local CodeSignaturePatterns = {
    { pattern = "webhook%s*=%s*[\"']", label = "webhook assignment", hard = false },
    { pattern = "%d+%.%d+%.%d+%.%d+:%d+/", label = "raw IP:port URL", hard = false },
}

local ENV_INJECTION_MARKERS = {
    "get" .. "fenv(",
    "_g" .. "." .. "scan",
    "_g" .. "." .. "join",
    "fenv" .. "." .. "webhook",
    "genv" .. "." .. "webhook",
    -- v2.1.4: ещё маркеры из разобранных семплов. Все 8 живых стилеров
    -- устроены одинаково: тонкий загрузчик прописывает конфиг в
    -- getfenv()/genv/_G, а потом делает loadstring(HttpGet(url))().
    -- В самом загрузчике вредоносного кода нет вообще — только URL,
    -- поэтому ловить его по «плохим словам» почти бесполезно, и основная
    -- защита всё равно сетевая (блокировка самого URL). Эти маркеры —
    -- дешёвое дополнение, а не основная линия обороны: любой из них
    -- обходится переименованием переменной.
    "genv" .. "." .. "scripturl",
    "fenv" .. "." .. "scripturl",
    "starscripts" .. "config",
    "genv" .. "." .. "discordid",
    "fenv" .. "." .. "username",
}

local isBlocked
local lastWebhookReason = nil
-- форвард-декларация: журнал активности определяется ниже (в разделе
-- анти-кика), но писать в него нужно уже отсюда, из logBlock.
local logActivity

-- ═══════════════════════════════════════════════════════════════════════
--  v2.1.5 — КОНТЕКСТ ИГРЫ (фикс ложняков на «Steal a Brainrot» и трейд-играх)
-- ═══════════════════════════════════════════════════════════════════════
-- Проблема: скрипт помечал подозрительными слова вроде "steal", "trade",
-- "brainrot". Но есть огромные легальные игры, где эти слова — просто
-- название и механика: Steal a Brainrot, Murder Mystery 2 (трейды),
-- Adopt Me (трейды), Pet Simulator. В таких играх ЛЮБОЙ нормальный
-- скрипт будет содержать эти слова, и он не стилер.
--
-- Решение: смотрим название текущей игры. Если слово встречается в
-- названии игры — оно перестаёт быть уликой ИМЕННО В ЭТОЙ ИГРЕ.
-- Важно: подавляются только «слабые» слова из soft-списка. Жёсткие
-- сигнатуры (cookie, authticket, известные exfil-домены) НЕ подавляются
-- никогда и ни в какой игре — иначе стилеру достаточно было бы
-- запуститься в игре с подходящим названием.
local GameContextWords = {}

do
    local ok = pcall(function()
        local name = ""
        pcall(function()
            local info = Market and Market:GetProductInfo(realGame.PlaceId)
            if info and info.Name then name = tostring(info.Name) end
        end)
        if name == "" then
            -- запасной вариант, если GetProductInfo недоступен/зафейлился
            pcall(function() name = tostring(realGame.Name or "") end)
        end
        name = name:lower()
        -- Слова, которые «прощаются», если они есть в названии игры
        local forgivable = {
            "steal", "stealer", "stealing", "brainrot", "trade", "trading",
            "rob", "robbery", "heist", "grab", "snatch", "loot", "mailbox",
            "murder", "kill", "hack", "obby", "simulator", "tycoon", "pet",
        }
        for _, w in ipairs(forgivable) do
            if sfind(name, w, 1, true) then
                GameContextWords[w] = true
            end
        end
        if next(GameContextWords) ~= nil and getgenv()._log_blocks then
            local list = {}
            for w in pairs(GameContextWords) do list[#list + 1] = w end
            warn(("Game context \"%s\": the words {%s} are not treated as evidence in this game.")
                 :format(name, table.concat(list, ", ")))
        end
    end)
    if not ok then GameContextWords = {} end
end

-- Слово подавлено контекстом игры?
local function isForgivenByGameContext(word)
    if not getgenv()._game_context_aware then return false end
    return GameContextWords[word:lower()] == true
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 4 — СКАЧИВАНИЕ ИЗОБРАЖЕНИЙ
-- ═══════════════════════════════════════════════════════════════════════
local imageCounter = 0

local function ensureFolder(path)
    pcall(function()
        if not isfolder(path) then
            makefolder(path)
        end
    end)
end

local function autoDeleteFile(filepath)
    task.delay(10, function()
        pcall(function()
            if isfile(filepath) then
                delfile(filepath)
            end
        end)
    end)
end

local function downloadImage(url)
    if isBlocked and type(isBlocked) == "function" then
        local blocked = isBlocked(url, nil, nil, false)
        if blocked then
            warn("downloadImage: URL blocked by filter, icon not loaded: " .. tostring(url))
            return nil
        end
    end

    local req = http_request or (syn and syn.request) or request
    if not req then return nil end

    local folderPath = "./temp/img"
    ensureFolder(folderPath)
    imageCounter = imageCounter + 1
    local filename = folderPath .. "/" .. imageCounter .. ".png"

    local success, res = pcall(function()
        return req({Url = url, Method = "GET"}).Body
    end)

    if success and res then
        pcall(function() writefile(filename, res) end)
        autoDeleteFile(filename)
        if getcustomasset then
            return getcustomasset(filename)
        elseif syn and syn.crypt and syn.crypt.customasset then
            return syn.crypt.customasset(filename)
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 5 — СИСТЕМА УВЕДОМЛЕНИЙ (NotifyToast)
-- ═══════════════════════════════════════════════════════════════════════
local CONFIG = {
    SLIDE_IN_TIME = 0.4,
    SLIDE_OUT_TIME = 0.05,
    SCALE_TIME = 0.11,
    SCALE_DOWN = 0.96,
    START_Y = -1,
    END_Y = 59,
    DEFAULT_DURATION = 2,
    BACKGROUND_COLOR = Color3.fromHex("#23262C"),
    TEXT_COLOR = Color3.fromRGB(247, 247, 248),
    WIDTH_OFFSET = -24,
    TITLE_SIZE = 20,
    SUBTITLE_SIZE = 15,
    ICON_SIZE = 40,
    ICON_TEXT_SIZE = 26,
    REMOVE_PREVIOUS = true,
    CORNER_RADIUS = 6,
    MIN_HEIGHT = 55,
    TOAST_HEIGHT_FULL = 77,
    TOAST_HEIGHT_SMALL = 55,
    DEFAULT_ICON = getgenv()._icon_asset or "rbxassetid://83768500686029",
}

local currentToast = nil
local _lastToastKey = nil
local _lastToastTime = 0

local function NotifyToast(config)
    config = config or {}

    local dedupKey = tostring(config.title) .. "||" .. tostring(config.content or config.subtitle)
    local now = tick()
    if dedupKey == _lastToastKey and (now - _lastToastTime) < 1 then
        return
    end
    _lastToastKey = dedupKey
    _lastToastTime = now

    if CONFIG.REMOVE_PREVIOUS and currentToast and currentToast.Parent then
        currentToast:Destroy()
    end

    local toastId = "Toast_" .. HttpService:GenerateGUID(false)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = toastId
    screenGui.DisplayOrder = 9
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.AutoLocalize = false
    screenGui.ResetOnSpawn = false
    screenGui.ScreenInsets = Enum.ScreenInsets.None
    screenGui.Parent = CoreGui

    currentToast = screenGui

    local container = Instance.new("TextButton")
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.Position = UDim2.new(0.5, 0, 0, CONFIG.START_Y)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.Parent = screenGui

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(400, math.huge)
    sizeConstraint.Parent = container

    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
    bg.BackgroundTransparency = 0
    bg.BorderSizePixel = 0
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS)
    corner.Parent = bg

    local innerFrame = Instance.new("Frame")
    innerFrame.BackgroundTransparency = 1
    innerFrame.Size = UDim2.new(1, 0, 1, 0)
    innerFrame.Parent = bg

    local hList = Instance.new("UIListLayout")
    hList.Padding = UDim.new(0, 12)
    hList.FillDirection = Enum.FillDirection.Horizontal
    hList.SortOrder = Enum.SortOrder.LayoutOrder
    hList.VerticalAlignment = Enum.VerticalAlignment.Center
    hList.Parent = innerFrame

    local msgFrame = Instance.new("Frame")
    msgFrame.BackgroundTransparency = 1
    msgFrame.Size = UDim2.new(1, 0, 1, 0)
    msgFrame.LayoutOrder = 2
    msgFrame.Parent = innerFrame

    local vList = Instance.new("UIListLayout")
    vList.Padding = UDim.new(0, 12)
    vList.SortOrder = Enum.SortOrder.LayoutOrder
    vList.VerticalAlignment = Enum.VerticalAlignment.Center
    vList.Parent = msgFrame

    local textFrame = Instance.new("Frame")
    textFrame.BackgroundTransparency = 1
    textFrame.Size = UDim2.new(1, -48, 0, 0)
    textFrame.AutomaticSize = Enum.AutomaticSize.Y
    textFrame.Parent = msgFrame

    local vList2 = Instance.new("UIListLayout")
    vList2.SortOrder = Enum.SortOrder.LayoutOrder
    vList2.VerticalAlignment = Enum.VerticalAlignment.Center
    vList2.Parent = textFrame

    local title = Instance.new("TextLabel")
    title.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)
    title.TextColor3 = CONFIG.TEXT_COLOR
    title.TextSize = CONFIG.TITLE_SIZE
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 0)
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.RichText = true
    title.LayoutOrder = 1
    title.Text = config.title or ""
    title.Parent = textFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json")
    subtitle.TextColor3 = CONFIG.TEXT_COLOR
    subtitle.TextSize = CONFIG.SUBTITLE_SIZE
    subtitle.TextWrapped = true
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, 0, 0, 0)
    subtitle.AutomaticSize = Enum.AutomaticSize.Y
    subtitle.RichText = true
    subtitle.LayoutOrder = 2
    subtitle.Text = config.content or config.subtitle or ""
    subtitle.Parent = textFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = innerFrame

    local scaler = Instance.new("UIScale")
    scaler.Scale = 1
    scaler.Parent = container

    local showIcon = config.icon and config.icon ~= ""
    local iconObj

    if showIcon then
        local isUrl = type(config.icon) == "string" and config.icon:match("^https?://")
        local isAsset = type(config.icon) == "string" and (config.icon:match("^rbxassetid://") or config.icon:match("^rbxasset://")) or type(config.icon) == "number"

        if isUrl then
            local asset = downloadImage(config.icon)
            if asset then
                iconObj = Instance.new("ImageLabel")
                iconObj.Image = asset
                iconObj.BackgroundTransparency = 1
                iconObj.Size = UDim2.new(0, CONFIG.ICON_SIZE, 0, CONFIG.ICON_SIZE)
                iconObj.LayoutOrder = 1
                iconObj.Parent = innerFrame
            end
        elseif isAsset then
            local id = type(config.icon) == "number" and "rbxassetid://" .. config.icon or config.icon
            iconObj = Instance.new("ImageLabel")
            iconObj.Image = id
            iconObj.BackgroundTransparency = 1
            iconObj.Size = UDim2.new(0, CONFIG.ICON_SIZE, 0, CONFIG.ICON_SIZE)
            iconObj.LayoutOrder = 1
            iconObj.Parent = innerFrame
        else
            iconObj = Instance.new("TextLabel")
            iconObj.FontFace = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Bold)
            iconObj.Text = config.icon
            iconObj.TextColor3 = CONFIG.TEXT_COLOR
            iconObj.TextSize = CONFIG.ICON_TEXT_SIZE
            iconObj.TextXAlignment = Enum.TextXAlignment.Center
            iconObj.TextYAlignment = Enum.TextYAlignment.Center
            iconObj.BackgroundTransparency = 1
            iconObj.Size = UDim2.new(0, CONFIG.ICON_SIZE, 0, CONFIG.ICON_SIZE)
            iconObj.LayoutOrder = 1
            iconObj.Parent = innerFrame
        end
    end

    local textOffset = showIcon and -48 or 0
    textFrame.Size = UDim2.new(1, textOffset, 0, 0)

    local hasTitle = title.Text ~= ""
    local hasSubtitle = subtitle.Text ~= ""
    local toastHeight = (hasTitle and hasSubtitle) and CONFIG.TOAST_HEIGHT_FULL or CONFIG.TOAST_HEIGHT_SMALL
    toastHeight = math.max(toastHeight, CONFIG.MIN_HEIGHT)

    container.Size = UDim2.new(1, CONFIG.WIDTH_OFFSET, 0, toastHeight)
    bg.Size = UDim2.new(1, 0, 1, 0)
    innerFrame.Size = UDim2.new(1, 0, 1, 0)
    msgFrame.Size = UDim2.new(1, 0, 1, 0)

    local minHeightConstraint = Instance.new("UISizeConstraint")
    minHeightConstraint.MinSize = Vector2.new(0, CONFIG.MIN_HEIGHT)
    minHeightConstraint.Parent = container

    task.wait()

    local actualHeight = container.AbsoluteSize.Y
    local dynamicShowY = CONFIG.END_Y / 2.818 + (actualHeight / 2)

    container.Position = UDim2.new(0.5, 0, 0, CONFIG.START_Y)

    TweenService:Create(container, TweenInfo.new(CONFIG.SLIDE_IN_TIME, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, 0, 0, dynamicShowY)
    }):Play()

    local function hideToast()
        TweenService:Create(container, TweenInfo.new(CONFIG.SLIDE_OUT_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0, CONFIG.START_Y)
        }):Play()
        task.delay(CONFIG.SLIDE_OUT_TIME, function()
            if currentToast == screenGui then currentToast = nil end
            screenGui:Destroy()
        end)
    end

    task.delay(config.duration or CONFIG.DEFAULT_DURATION, function()
        if screenGui and screenGui.Parent then hideToast() end
    end)

    container.MouseButton1Down:Connect(function()
        TweenService:Create(scaler, TweenInfo.new(CONFIG.SCALE_TIME), { Scale = CONFIG.SCALE_DOWN }):Play()
    end)

    container.MouseButton1Up:Connect(function()
        TweenService:Create(scaler, TweenInfo.new(CONFIG.SCALE_TIME), { Scale = 1 }):Play()
    end)

    container.MouseButton1Click:Connect(function()
        hideToast()
        if config.callback then config.callback() end
    end)

    container.MouseLeave:Connect(function()
        TweenService:Create(scaler, TweenInfo.new(CONFIG.SCALE_TIME), { Scale = 1 }):Play()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 6 — ЛОГИРОВАНИЕ + УВЕДОМЛЕНИЯ
-- ═══════════════════════════════════════════════════════════════════════
local function logBlock(tag, url)
    if logActivity then
        pcall(logActivity, tag, tostring(url))
    end
    if not getgenv()._log_blocks then return end
    local source = getCallingScriptName()

    local consoleTitle
    if tag == "STEALER" then
        consoleTitle = "STEALER - BLOCKED"
    elseif tag == "RELAY" then
        -- v2.1.4: отдельный заголовок, потому что это эвристика, а не
        -- известный плохой домен — пользователю важно понимать разницу,
        -- чтобы он мог занести домен в _whitelist, если это ложняк.
        consoleTitle = "WEBHOOK RELAY (heuristic) - BLOCKED"
    elseif tag == "BARE_IP" then
        consoleTitle = "RAW IP ENDPOINT - BLOCKED"
    else
        consoleTitle = "IP LOGGER - BLOCKED"
    end

    warn("╔═════════━━━ • ━━━═════════╗")
    warn("[ " .. consoleTitle .. " ]")
    warn("Time : " .. os.date("%H:%M:%S"))
    warn("URL : " .. tostring(url))
    warn("Host : " .. getHost(urlDecode(url)))
    warn("Source script : " .. source)
    if lastWebhookReason then
        warn("Reason : " .. lastWebhookReason)
        lastWebhookReason = nil
    end
    warn("╚═════════━━━ • ━━━═════════╝")

    NotifyToast({
        title = consoleTitle,
        content = "Learn more in the console...",
        duration = 5,
        icon = CONFIG.DEFAULT_ICON
    })
end

local function logKick()
    if not getgenv()._log_blocks then return end
    local source = getCallingScriptName()
    warn("╔═════════━━━ • ━━━═════════╗")
    warn("[ STEALER - BLOCKED ]")
    warn("Time : " .. os.date("%H:%M:%S"))
    warn("Source script : " .. source)
    warn("Reason : a stealer (or other Lua script) attempted to kick you")
    warn("╚═════════━━━ • ━━━═════════╝")

    NotifyToast({
        title = "STEALER - BLOCKED",
        content = "Learn more in the console...",
        duration = 5,
        icon = CONFIG.DEFAULT_ICON
    })
end

-- v2.1.0: лог для ReportAbuse-блока
local function logReportAbuse()
    if not getgenv()._log_blocks then return end
    local source = getCallingScriptName()
    warn("╔═════════━━━ • ━━━═════════╗")
    warn("[ REPORTABUSE - BLOCKED ]")
    warn("Time : " .. os.date("%H:%M:%S"))
    warn("Source script : " .. source)
    warn("Reason : script tried to call Players:ReportAbuse() on your behalf")
    warn("╚═════════━━━ • ━━━═════════╝")

    NotifyToast({
        title = "REPORTABUSE - BLOCKED",
        content = "A script tried to file a report using your account. Blocked.",
        duration = 6,
        icon = CONFIG.DEFAULT_ICON
    })
end

-- v2.1.0: лог для блока промпта покупки Robux, с деталями товара если получилось их узнать
local function logRobuxPrompt(methodName, productId, ownerName, price)
    if not getgenv()._log_blocks then return end
    local source = getCallingScriptName()
    warn("╔═════════━━━ • ━━━═════════╗")
    warn("[ ROBUX PROMPT - BLOCKED ]")
    warn("Time : " .. os.date("%H:%M:%S"))
    warn("Method : " .. tostring(methodName))
    warn("Product ID : " .. tostring(productId))
    warn("Owner : " .. tostring(ownerName))
    warn("Price (Robux) : " .. tostring(price))
    warn("Source script : " .. source)
    warn("Reason : script tried to open a Robux purchase prompt without your input")
    warn("╚═════════━━━ • ━━━═════════╝")

    NotifyToast({
        title = "ROBUX PROMPT - BLOCKED",
        content = "Source: " .. source .. " — details in console.",
        duration = 6,
        icon = CONFIG.DEFAULT_ICON
    })
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 7 — ПРОВЕРКА ЗАПРОСОВ
-- ═══════════════════════════════════════════════════════════════════════
local function hasSuspiciousHeaders(headers)
    if type(headers) ~= "table" then return false end
    for k in pairs(headers) do
        local lk = slower(tostring(k))
        for _, pat in ipairs(SuspiciousHeaders) do
            if smatch(lk, pat) then return true end
        end
    end
    return false
end

local function scanForLocationFields(t, depth)
    depth = depth or 0
    if depth > 4 or type(t) ~= "table" then return false end
    for k, v in pairs(t) do
        for _, field in ipairs(LocationFields) do
            if slower(tostring(k)) == field then return true end
        end
        if type(v) == "table" then
            if scanForLocationFields(v, depth + 1) then return true end
        end
    end
    return false
end

local function bodyLeaksLocationFields(body)
    if type(body) ~= "string" or body == "" then return false end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(decoded) ~= "table" then return false end
    return scanForLocationFields(decoded)
end

isBlocked = function(url, body, headers, isPost)
    if type(url) ~= "string" or url == "" then return false, nil end
    local dUrl = urlDecode(url)
    local host = getHost(dUrl)
    local path = smatch(dUrl, "://[^/]+(/[^?]*)") or ""
    local ul = slower(dUrl)
    local pl = slower(path)
    local bl = slower(type(body) == "string" and urlDecode(body) or "")

    -- ВАЖНО: сигнатура ROBLOX-cookie собрана через конкатенацию по той же
    -- причине, что и CodeBlacklistHard выше — иначе наш собственный
    -- исходник (если его повторно загрузят через loadstring уже после
    -- установки нашего же loadstring-хука) содержал бы это слово одной
    -- строкой и спалил бы сам себя как утечку cookie.
    local COOKIE_SIG_WORD_2 = "roblosecur" .. "ity"
    if sfind(ul, COOKIE_SIG, 1, true) or sfind(ul, COOKIE_SIG_WORD_2, 1, true) or
       sfind(bl, COOKIE_SIG, 1, true) or sfind(bl, COOKIE_SIG_WORD_2, 1, true) then
        if not (host == "roblox.com" or host:sub(-11) == ".roblox.com") then
            return true, "STEALER"
        end
    end

    if isWhitelisted(host) then
        return false, nil
    end

    if isExactBlacklisted(host) then
        return true, "LOGGER"
    end

    -- v2.1.4: точные exfil-эндпоинты из разобранных семплов стилеров
    if KnownExfilHosts[host] then
        return true, "STEALER"
    end

    -- v2.1.4: голый IPv4 вместо домена. Легитимный трафик игры так почти
    -- никогда не ходит, а стилеры используют это, чтобы у их эндпоинта
    -- вообще не было домена, который можно внести в блок-лист.
    if getgenv()._block_bare_ip then
        local a, b, c, d = smatch(host, "^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
        if a then
            a, b, c, d = tonumber(a), tonumber(b), tonumber(c), tonumber(d)
            if a <= 255 and b <= 255 and c <= 255 and d <= 255 then
                -- localhost/LAN не трогаем: некоторые executor'ы гоняют
                -- через них свои локальные сервисы.
                local isLocal = (a == 127) or (a == 10) or
                                (a == 192 and b == 168) or
                                (a == 172 and b >= 16 and b <= 31)
                if not isLocal then
                    return true, "BARE_IP"
                end
            end
        end
    end

    -- v2.1.4: POST на бесплатные хостинг-платформы — типичный webhook-релей.
    -- v2.1.6 (пункт 6 багрепорта): РАНЬШЕ проверка стояла под "and isPost",
    -- поэтому эксфильтрация через GET с данными в query string
    -- (host/path?cookie=...) проходила мимо полностью. Теперь принадлежность
    -- к релей-хосту определяется отдельно от метода запроса.
    if getgenv()._block_relay_hosts then
        local isRelayHost = false
        for _, suffix in ipairs(RelayHostSuffixes) do
            if host == suffix or host:sub(-(#suffix + 1)) == "." .. suffix then
                isRelayHost = true
                break
            end
        end

        if isRelayHost then
            -- v2.1.5: свой API на Vercel — не преступление; преступление —
            -- слать туда cookie или опись инвентаря.
            -- v2.1.6 (пункт 7): передаём УЖЕ декодированное тело (bl),
            -- а не сырое — иначе url-encoded поля ("session%5Fid")
            -- не распознавались. bl посчитан выше в этой же функции.
            local shouldBlock, why = webhookBodyVerdict(bl)

            -- Для GET тела нет — данные уезжают в query string.
            -- Сканируем её теми же критериями.
            if not shouldBlock and not isPost then
                local qs = pl:match("%?(.*)$")
                if qs then
                    shouldBlock, why = webhookBodyVerdict(qs)
                    if shouldBlock then
                        why = "GET query string → " .. tostring(why)
                    end
                end
            end

            if shouldBlock then
                lastWebhookReason = why
                return true, "RELAY"
            end
            if getgenv()._verbose_soft_warnings then
                warn(("Allowed request to relay platform (no sensitive data): %s (%s)")
                     :format(tostring(host), isPost and "POST" or "GET"))
            end
        end
    end

    if getgenv()._blockwebhook and isPost then
        for _, pat in ipairs(WebhookPatterns) do
            local hostSuffix, pathSub = pat[1], pat[2]
            local hostMatches = (host == hostSuffix or host:sub(-(#hostSuffix + 1)) == "." .. hostSuffix)
            if hostMatches and (pathSub == "" or sfind(pl, pathSub, 1, true)) then
                -- v2.1.5: РАНЬШЕ здесь стоял безусловный блок любого
                -- webhook'а. Это ломало нормальные скрипты, которые шлют
                -- в свой Discord рекорды/статистику — а таких много.
                -- Теперь решаем по содержимому: cookie/токен/опись
                -- инвентаря = блок, счёт и время = пропускаем.
                if getgenv()._strict_webhook then
                    -- Строгий режим для тех, кому спокойнее блокировать всё.
                    return true, "WEBHOOK"
                end
                -- v2.1.6 (пункт 7): декодированное тело вместо сырого.
                local shouldBlock, why = webhookBodyVerdict(bl)
                if shouldBlock then
                    lastWebhookReason = why
                    return true, "WEBHOOK"
                end
                -- Пропускаем, но отмечаем в консоли — пусть пользователь
                -- знает, что скрипт куда-то пишет, даже если безобидно.
                if getgenv()._verbose_soft_warnings then
                    warn("Allowed webhook (no sensitive data): " .. tostring(host))
                end
            end
        end
    end

    -- v2.1.6 (пункт 1 багрепорта): РАНЬШЕ здесь третьим условием стоял
    -- голый sfind(host, p, 1, true) — поиск подстроки где угодно в хосте,
    -- без привязки к границам поддомена. Это давало реальные коллизии с
    -- обычными словами внутри легитимных доменов:
    --   "ipdata"  ⊂ "chipdatabase.com"
    --   "ipinfo"  ⊂ "shipinfo.com"
    --   "ipstack" ⊂ "shipstack.com"
    --   "ipapi"   ⊂ "shipapi.com" / "worshipapi.com"
    -- Теперь совпадение возможно тремя способами, и все они уважают
    -- границы меток домена:
    --   1) хост равен ключу целиком;
    --   2) ключ — суффикс хоста ровно по границе точки;
    --   3) ключ равен ЦЕЛОЙ метке хоста — это важно для ключей,
    --      записанных без домена ("ipdata", "ipinfo", "ipstack"):
    --      "ipdata.co" и "api.ipdata.co" ловятся (метка == "ipdata"),
    --      а "chipdatabase.com" уже нет (метка "chipdatabase" ≠ "ipdata").
    local hostLabels = {}
    for label in host:gmatch("[^%.]+") do
        hostLabels[#hostLabels + 1] = label
    end

    for _, p in ipairs(BLACKLIST) do
        if host == p or host:sub(-(#p + 1)) == "." .. p then
            return true, "LOGGER"
        end
        for _, label in ipairs(hostLabels) do
            if label == p then
                return true, "LOGGER"
            end
        end
    end

    -- Отдельно — ключи, для которых совпадение внутри ОДНОЙ метки домена
    -- всё-таки осмысленно (например "iplogger" в "iplogger-mirror.net").
    -- Сюда попадают только достаточно длинные и специфичные строки,
    -- которые не встречаются в обычных английских словах. Проверка идёт
    -- по каждой метке отдельно, поэтому "shipinfo.com" больше не ловится.
    for _, label in ipairs(hostLabels) do
        for _, p in ipairs(BLACKLIST_LABEL_SUBSTRING) do
            if sfind(label, p, 1, true) then
                return true, "LOGGER"
            end
        end
    end

    for _, tld in ipairs(SuspiciousTLDs) do
        if host:sub(-(#tld + 1)) == "." .. tld then
            return true, "LOGGER"
        end
    end

    if hasSuspiciousHeaders(headers) then
        return true, "STEALER"
    end

    if bodyLeaksLocationFields(body) then
        return true, "LOGGER"
    end

    return false, nil
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 8 — САНИТАЙЗ ОТВЕТА
-- ═══════════════════════════════════════════════════════════════════════
local function sanitizeBody(bodyStr, host)
    if type(bodyStr) ~= "string" or bodyStr == "" then return bodyStr end
    if not getgenv()._sanitize_ip then return bodyStr end
    -- Не трогаем ответы от доверенных/белых доменов — это снижает
    -- риск случайно испортить легитимные данные (версии, координаты
    -- в игре и т.п.), которые совпадают с шаблоном "N.N.N.N", но не
    -- являются IP-адресом и пришли не от подозрительного источника.
    if host and isWhitelisted(host) then return bodyStr end

    local ipv4, ipv6 = fakeIPv4(), fakeIPv6()

    -- v2.1.6 (пункт 4б багрепорта): "2.0.14.7" по форме неотличим от IP —
    -- все октеты в диапазоне 0–255. Отличить можно только по КОНТЕКСТУ:
    -- если значение лежит под ключом вроде "version"/"build"/"sdk", это
    -- версия, а не адрес. Поэтому перед заменой прячем такие значения за
    -- временные плейсхолдеры, а после замены возвращаем как было.
    local VersionKeys = {
        "version", "ver", "build", "buildnumber", "build_number",
        "sdk", "sdkversion", "revision", "rev", "release",
        "clientversion", "client_version", "appversion", "app_version",
        "gameversion", "game_version", "placeversion", "schema",
    }
    local stash, stashN = {}, 0
    local work = bodyStr

    for _, key in ipairs(VersionKeys) do
        -- JSON:  "version": "2.0.14.7"   и   "version":"2.0.14.7"
        work = work:gsub('("' .. key .. '"%s*:%s*")([^"]*)(")', function(pre, val, post)
            if val:match("^[%d%.]+$") then
                stashN = stashN + 1
                -- Токен намеренно состоит только из букв и цифр: тогда он
                -- не содержит магических символов Lua-паттернов и его можно
                -- вернуть обратно обычным gsub без экранирования.
                local token = "VERSTASHTOKEN" .. stashN .. "ENDSTASH"
                stash[token] = val
                return pre .. token .. post
            end
            return pre .. val .. post
        end)
    end

    -- v2.1.6 (пункт 4 багрепорта): раньше подменялась ЛЮБАЯ
    -- последовательность "число.число.число.число", включая заведомо
    -- не-IP вроде "999.999.999.999". Теперь каждый октет валидируется
    -- по диапазону 0–255, и подмена происходит только если это
    -- действительно похоже на IPv4.
    local out = work:gsub("(%d+)%.(%d+)%.(%d+)%.(%d+)", function(a, b, c, d)
        for _, oct in ipairs({ a, b, c, d }) do
            if #oct > 3 then return nil end
            local n = tonumber(oct)
            if not n or n > 255 then return nil end
        end
        return ipv4
    end)

    -- v2.1.6 (пункт 5 багрепорта): старый паттерн
    --   "%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+"
    -- имел два независимых бага.
    --   а) Не ловил сокращённую форму с "::" — то есть реальные адреса
    --      вида "2001:db8::1" (а именно так IPv6 и пишется почти всегда)
    --      НЕ санитизировались вообще. Ровно противоположно задуманному.
    --   б) %x+ без ограничения длины группы ловил произвольные hex-строки
    --      (GUID'ы, хэши, идентификаторы вида "dead:beef:cafe:babe:...").
    -- Теперь: группа строго 1–4 hex-символа, поддержана "::"-форма,
    -- и результат дополнительно проверяется на правдоподобность.
    local function looksLikeIPv6(s)
        -- ровно один "::" максимум
        local dcount = select(2, s:gsub("::", ""))
        if dcount > 1 then return false end
        local groups, empty = 0, 0
        for g in s:gmatch("[^:]*") do
            if g == "" then
                empty = empty + 1
            else
                if #g > 4 then return false end
                groups = groups + 1
            end
        end
        if dcount == 0 then
            -- полная форма: ровно 8 групп
            return groups == 8
        end
        -- сокращённая форма: групп меньше 8, иначе "::" бессмысленно
        return groups >= 2 and groups < 8
    end

    -- Полная форма (8 групп по 1–4 hex)
    out = out:gsub("%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?:%x%x?%x?%x?",
        function(m)
            if looksLikeIPv6(m) then return ipv6 end
            return nil
        end)

    -- Сокращённая форма с "::" (например 2001:db8::1, fe80::1)
    out = out:gsub("%x%x?%x?%x?::[%x:]*%x", function(m)
        if looksLikeIPv6(m) then return ipv6 end
        return nil
    end)

    -- Возвращаем спрятанные версии на место.
    if stashN > 0 then
        for token, val in pairs(stash) do
            out = out:gsub(token, val)
        end
    end

    return out
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 9 — СКАНИРОВАНИЕ loadstring
-- ═══════════════════════════════════════════════════════════════════════
if getgenv()._scan_loadstring and hookfunction and type(loadstring) == "function" then
    local origLoadstring
    origLoadstring = hookfunction(loadstring, newcclosure(function(code, chunkname)
        local codeStr = tostring(code):lower()
        local source = getCallingScriptName()

        if type(code) == "string" then
            for _, w in ipairs(getgenv()._loadstring_whitelist or {}) do
                if type(w) == "string" and w ~= "" and sfind(codeStr, slower(w), 1, true) then
                    return origLoadstring(code, chunkname)
                end
            end
        end

        for _, word in ipairs(CodeBlacklistHard) do
            if sfind(codeStr, word, 1, true) then
                warn("╔═════════━━━ • ━━━═════════╗")
                warn("[ STEALER - BLOCKED ]")
                warn("Time : " .. os.date("%H:%M:%S"))
                warn("Source script : " .. source)
                warn("Reason : hard signature \"" .. word .. "\"")
                warn("╚═════════━━━ • ━━━═════════╝")
                NotifyToast({
                    title = "STEALER - BLOCKED",
                    content = "Learn more in the console...",
                    duration = 5,
                    icon = CONFIG.DEFAULT_ICON
                })
                return newcclosure(function() end)
            end
        end

        for _, word in ipairs(CodeBlacklistSoft) do
            if sfind(codeStr, word, 1, true) then
                -- v2.1.5: если слово есть в названии самой игры (например
                -- "steal" в «Steal a Brainrot»), это не улика — в такой
                -- игре его содержит любой нормальный скрипт.
                if isForgivenByGameContext(word) then
                    -- пропускаем это слово, ищем дальше
                else
                    if getgenv()._verbose_soft_warnings then
                        warn(("Notice: loadstring from \"%s\" contains suspicious word \"%s\". Code was NOT blocked; this is a warning only.")
                        :format(source, word))
                    end
                    break
                end
            end
        end

        for _, sig in ipairs(CodeSignaturePatterns) do
            local matched = smatch(codeStr, sig.pattern)
            if matched then
                if sig.hard then
                    warn("╔═════════━━━ • ━━━═════════╗")
                    warn("[ STEALER - BLOCKED ]")
                    warn("Time : " .. os.date("%H:%M:%S"))
                    warn("Source script : " .. source)
                    warn("Reason : pattern signature \"" .. sig.label .. "\"")
                    warn("╚═════════━━━ • ━━━═════════╝")
                    NotifyToast({
                        title = "STEALER - BLOCKED",
                        content = "Learn more in the console...",
                        duration = 5,
                        icon = CONFIG.DEFAULT_ICON
                    })
                    return newcclosure(function() end)
                else
                    if getgenv()._verbose_soft_warnings then
                        warn(("Notice: loadstring from \"%s\" contains suspicious pattern \"%s\". Code was NOT blocked; this is a warning only.")
                            :format(source, sig.label))
                    end
                end
            end
        end

        if sfind(codeStr, "webhook", 1, true) then
            for _, marker in ipairs(ENV_INJECTION_MARKERS) do
                if sfind(codeStr, marker, 1, true) then
                    if getgenv()._verbose_soft_warnings then
                        warn(("Notice: loadstring from \"%s\" contains a webhook plus marker \"%s\". Code was NOT blocked; this is a warning only.")
                            :format(source, marker))
                    end
                    break
                end
            end
        end

        return origLoadstring(code, chunkname)
    end))
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 10 — ПЕРЕХВАТ __namecall
-- ═══════════════════════════════════════════════════════════════════════
local oldNamecall
local namecallHookOk, namecallHookErr = pcall(function()
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }
    local url = args[1]
    local body = args[2]

    if method == "HttpGet" or method == "HttpGetAsync" or method == "GetAsync" then
        local blocked, tag = isBlocked(url, nil, nil, false)
        if blocked then
            logBlock(tag, url)
            return ""
        end
        local result = oldNamecall(self, ...)
        if type(result) == "string" then
            return sanitizeBody(result, getHost(urlDecode(url)))
        end
        return result

    -- v2.1.7: GetObjects — сетевой канал, который мы раньше не смотрели
    -- вообще. HttpSpy его мониторит, и не зря: game:GetObjects() тянет
    -- ассет по ссылке, и на части экзекьюторов принимает не только
    -- rbxassetid://, но и обычный http(s)-адрес. То есть это способ
    -- сходить в сеть в обход всех наших хуков на HttpGet/request.
    -- Проверяем той же логикой, что и обычные запросы.
    elseif method == "GetObjects" then
        if type(url) == "string" and (sfind(url, "http://", 1, true) or sfind(url, "https://", 1, true)) then
            local blocked, tag = isBlocked(url, nil, nil, false)
            if blocked then
                logBlock(tag, url)
                return {}
            end
            if getgenv()._verbose_soft_warnings then
                _warn("GetObjects called with an external URL: " .. _tostring(url))
            end
        end
        return oldNamecall(self, ...)

    elseif method == "HttpPost" or method == "HttpPostAsync" or method == "PostAsync" then
        local blocked, tag = isBlocked(url, body, nil, true)
        if blocked then
            logBlock(tag, url)
            return ""
        end
        return oldNamecall(self, ...)

    elseif method == "RequestAsync" and type(url) == "table" then
        local reqUrl = url.Url or url.url
        local reqBody = url.Body or url.body
        local reqHeaders = url.Headers or url.headers
        local reqMethod = string.upper(tostring(url.Method or "GET"))
        local isPost = (reqMethod ~= "GET")
        local blocked, tag = isBlocked(reqUrl, reqBody, reqHeaders, isPost)
        if blocked then
            logBlock(tag, reqUrl)
            return {
                Success = false,
                StatusCode = 403,
                StatusMessage = "Blocked",
                Body = "",
                Headers = {}
            }
        end
        local result = oldNamecall(self, ...)
        if type(result) == "table" then
            local newResult = {}
            for k, v in pairs(result) do newResult[k] = v end
            if newResult.Body then newResult.Body = sanitizeBody(newResult.Body, getHost(urlDecode(reqUrl))) end
            if newResult.body then newResult.body = sanitizeBody(newResult.body, getHost(urlDecode(reqUrl))) end
            return newResult
        end
        return result

    -- v2.1.0: ReportAbuse через __namecall (некоторые executor'ы роутят
    -- вызов именно через этот путь, а не только через прямой hookfunction
    -- на самой функции — перекрываем оба пути для надёжности)
    elseif method == "ReportAbuse" and getgenv()._anti_reportabuse and not checkcaller() then
        logReportAbuse()
        return
    end

    return oldNamecall(self, ...)
    end))
end)

if not namecallHookOk then
    warn("CRITICAL: failed to install the __namecall hook (Section 10). Error: " .. tostring(namecallHookErr))
end

-- ═══════════════════════════════════════════════════════════════════════
--  АНТИ-КИК
-- ═══════════════════════════════════════════════════════════════════════
local kickHookTarget -- ссылка на нашу же __namecall-обёртку в анти-кике (не используется активно после удаления anti-bypass в v2.1.1, оставлена на случай будущих защитных фич)
-- ═══════════════════════════════════════════════════════════════════════
--  v2.1.7 — ПРЕДУПРЕЖДЕНИЕ ОБ ACTOR'АХ (параллельный Luau)
-- ═══════════════════════════════════════════════════════════════════════
-- Это НЕ защита, а честное предупреждение о дыре, которую мы закрыть
-- не можем — но о которой пользователь должен знать.
--
-- В чём суть: Roblox умеет запускать скрипты внутри Actor-объектов
-- (параллельный Luau). У каждого Actor'а СВОЙ отдельный Lua-стейт со
-- своей копией метатаблиц. Наши хуки на game.__namecall и на request
-- поставлены в основном стейте и на код внутри Actor'а НЕ действуют.
--
-- То есть скрипт, запущенный внутри Actor'а, может спокойно ходить в
-- сеть мимо всей нашей защиты. Именно поэтому Sigma Spy не ставит хуки
-- напрямую, а генерирует отдельный код и запускает его В КАЖДОМ Actor'е
-- отдельно — это единственный рабочий способ покрыть их все.
--
-- Реализовать это здесь означало бы переписать половину скрипта под
-- actor-архитектуру, и для мобильных экзекьюторов (где у тебя и так
-- были краши) это лишний риск. Поэтому: обнаруживаем, что Actor'ы
-- используются, и честно предупреждаем.
local function checkActorEvasionRisk()
    if not getgenv()._warn_actor_risk then return end

    local ok = _pcall(function()
        local hasActorSupport = (type(getactors) == "function")
                             or (type(run_on_actor) == "function")
                             or (type(create_comm_channel) == "function")

        local actorCount = 0
        if type(getactors) == "function" then
            local ok2, actors = _pcall(getactors)
            if ok2 and type(actors) == "table" then
                actorCount = #actors
            end
        end

        if actorCount > 0 then
            -- v2.1.8: compressed from an 8-line box to one line.
            _warn(("Warning: %d Actor(s) detected in this game. Actors run in "
                .. "separate Lua states, so hooks do not apply inside them and a "
                .. "script running in one can bypass this protection. Be extra "
                .. "careful with scripts here.%s")
                :format(actorCount,
                    hasActorSupport and " (Your executor supports Actor access, so this vector is available here.)" or ""))
        end
    end)
    return ok
end

task.spawn(function()
    task.wait(3)   -- дать игре прогрузиться, Actor'ы появляются не сразу
    _pcall(checkActorEvasionRisk)
end)


-- ═══════════════════════════════════════════════════════════════════════
--  v2.1.5 — ЖУРНАЛ АКТИВНОСТИ ДЛЯ ФОРЕНЗИКИ КИКА
-- ═══════════════════════════════════════════════════════════════════════
-- Зачем: типичный сценарий стилера — «скрипт как будто грузится», в это
-- время он через RemoteEvent'ы игры отдаёт твои предметы, а потом кикает,
-- чтобы ты не увидел пропажу и не успел отменить трейд.
--
-- ЧЕСТНО О ГРАНИЦАХ: перехватить саму кражу предметов универсально
-- НЕВОЗМОЖНО. Кража идёт через обычные RemoteEvent'ы самой игры — те же
-- самые, которыми ты пользуешься, когда торгуешь по-настоящему. Со
-- стороны нашего хука вызов «отдать предмет игроку X» выглядит одинаково
-- и когда это твой осознанный трейд, и когда это стилер. Отличить их
-- можно было бы только зная логику каждой игры отдельно, а игр миллионы.
--
-- Что мы РЕАЛЬНО можем: вести короткий журнал подозрительной активности
-- и показать его в момент кика. Кик мы и так блокируем — значит у тебя
-- есть время прочитать журнал, проверить инвентарь и отменить трейд,
-- пока стилер думает, что ты уже вылетел.
local ACTIVITY_LOG_MAX = 25
local activityLog = {}

function logActivity(kind, detail)
    activityLog[#activityLog + 1] = {
        t = os.date("%H:%M:%S"),
        kind = tostring(kind),
        detail = tostring(detail),
    }
    if #activityLog > ACTIVITY_LOG_MAX then
        table.remove(activityLog, 1)
    end
end

local function dumpActivityLog()
    -- v2.1.8: was a multi-line box listing every logged entry, which
    -- flooded the console with old records on every kick attempt.
    -- Now it is a single compact line. The point of this feature is not
    -- to produce a report: it is to tell you, in the two seconds you
    -- have, that a kick was blocked and that you should check your
    -- inventory before the thief's trade goes through.
    local n = #activityLog
    if n == 0 then
        warn("Kick blocked. Nothing suspicious was recorded before it.")
        return
    end

    -- Only the most recent entry matters — that is what happened right
    -- before the kick.
    local last = activityLog[n]
    warn(("Kick blocked. CHECK YOUR INVENTORY AND PENDING TRADES NOW. Last blocked action: [%s] %s -> %s (%d recorded)")
        :format(last.t, last.kind, last.detail, n))
end

if getgenv()._anti_kick then
    local kickHookOk, kickHookErr = pcall(function()
        local p = game:GetService("Players").LocalPlayer
        local o = getrawmetatable(game)
        local s = o.__namecall
        local w = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if m == "Kick" and self == p then
                logKick()
                if getgenv()._kick_forensics then
                    pcall(dumpActivityLog)
                end
                return
            end
            return s(self, ...)
        end)
        setreadonly(o, false)
        o.__namecall = w
        setreadonly(o, true)
        kickHookTarget = w
    end)

    if not kickHookOk then
        warn("Failed to install the anti-kick hook. Error: " .. tostring(kickHookErr))
    end
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 11 — ХУКИ EXECUTOR-ФУНКЦИЙ
-- ═══════════════════════════════════════════════════════════════════════
local function wrapExecutorRequest(fn)
    if type(fn) ~= "function" then return fn end
    return function(opts, ...)
        if type(opts) ~= "table" then return fn(opts, ...) end
        local reqUrl = opts.Url or opts.URL or opts.url
        local reqBody = opts.Body or opts.body
        local reqHeaders = opts.Headers or opts.headers
        local reqMethod = string.upper(tostring(opts.Method or opts.method or "GET"))
        local isPost = (reqMethod ~= "GET")
        local blocked, tag = isBlocked(reqUrl, reqBody, reqHeaders, isPost)
        if blocked then
            logBlock(tag, reqUrl)
            return { Success = false, StatusCode = 403, StatusMessage = "Blocked", Body = "", Headers = {} }
        end
        local result = fn(opts, ...)
        if type(result) == "table" then
            local newResult = {}
            for k, v in pairs(result) do newResult[k] = v end
            local respHost = getHost(urlDecode(reqUrl))
            if newResult.Body then newResult.Body = sanitizeBody(newResult.Body, respHost) end
            if newResult.body then newResult.body = sanitizeBody(newResult.body, respHost) end
            return newResult
        end
        return result
    end
end

local HookStatus = {}

local function tryHookGlobal(name, getter, setter)
    local ok, fn = pcall(getter)
    if not ok or type(fn) ~= "function" then
        HookStatus[name] = "не найдена"
        return
    end
    local wrapped = wrapExecutorRequest(fn)
    local applied = pcall(setter, wrapped)
    if not applied then
        HookStatus[name] = "ошибка установки"
        return
    end
    local verifyOk, current = pcall(getter)
    if verifyOk and current == wrapped then
        HookStatus[name] = "ok"
    else
        HookStatus[name] = "не применилось (возможно readonly)"
    end
end

tryHookGlobal("request", function() return request end, function(w) getgenv().request = w; _G.request = w end)
tryHookGlobal("http_request", function() return http_request end, function(w) getgenv().http_request = w; _G.http_request = w end)
tryHookGlobal("syn.request", function() return syn and syn.request end, function(w) syn.request = w end)
tryHookGlobal("Fluxus.request", function() return Fluxus and Fluxus.request end, function(w) Fluxus.request = w end)
tryHookGlobal("KRNL_LOADED.request", function() return KRNL_LOADED and KRNL_LOADED.request end, function(w) KRNL_LOADED.request = w end)

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 12 — WEBSOCKET
-- ═══════════════════════════════════════════════════════════════════════
if type(WebSocket) == "table" and type(WebSocket.connect) == "function" then
    local origConnect = WebSocket.connect
    local function newConnect(url, ...)
        local blocked, tag = isBlocked(url, nil, nil, false)
        if blocked then
            logBlock(tag, url)
            return nil
        end
        local sock = origConnect(url, ...)
        if sock and type(sock) == "table" and type(sock.Send) == "function" then
            local origSend = sock.Send
            local function newSend(self, message)
                if type(message) == "string" and sfind(slower(message), COOKIE_SIG, 1, true) then
                    logBlock("STEALER", url)
                    return
                end
                return origSend(self, message)
            end
            pcall(function() sock.Send = newSend end)
        end
        return sock
    end
    pcall(function() WebSocket.connect = newConnect end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 13 — ANTI ROBUX/ABUSE (новое в v2.1.0)
--  Прямые hookfunction на ReportAbuse и всех промптах покупки — дублирует
--  проверку ReportAbuse из Раздела 10 (некоторые executor'ы вызывают метод
--  напрямую как функцию, минуя __namecall — перекрываем оба пути).
-- ═══════════════════════════════════════════════════════════════════════
local protectedFunctions = {} -- заполняется ниже, нужно для anti-bypass (Раздел 14)

if getgenv()._anti_reportabuse and type(hookfunction) == "function" then
    local ok, origReportAbuse = pcall(function()
        return hookfunction(Players.ReportAbuse, newcclosure(function(self, ...)
            if not checkcaller() then
                logReportAbuse()
                return
            end
            return protectedFunctions.ReportAbuse.orig(self, ...)
        end))
    end)
    if ok then
        protectedFunctions.ReportAbuse = { orig = origReportAbuse, wrapped = Players.ReportAbuse }
    else
        warn("Failed to hook ReportAbuse: " .. tostring(origReportAbuse))
    end
end

if getgenv()._anti_robux_prompt and type(hookfunction) == "function" then
    local robuxMethods = {
        "PromptPurchase", "PromptGamePassPurchase", "PromptProductPurchase",
        "PromptBundlePurchase", "PromptPremiumPurchase", "PromptSubscriptionPurchase",
        "PerformPurchase", "PerformPurchaseV2",
    }

    for _, methodName in ipairs(robuxMethods) do
        local target = Market[methodName]
        if type(target) == "function" then
            local ok, origFn = pcall(function()
                return hookfunction(target, newcclosure(function(self, ...)
                    -- checkcaller() == true: вызов пришёл с C-стороны (сам движок/executor).
                    -- isCallFromRealGameScript() == true: вызов пришёл из обычного
                    -- LocalScript, который реально лежит в дереве game — это штатный
                    -- способ, которым игры показывают магазин при клике "купить".
                    -- Блокируем ТОЛЬКО то, что не подходит ни под один из этих
                    -- случаев (типичный признак инжектнутого/loadstring-кода).
                    if checkcaller() or isCallFromRealGameScript() then
                        return protectedFunctions[methodName].orig(self, ...)
                    end

                    local args = { ... }
                    local productId = args[2] or args[1]
                    local ownerName, price = "unknown", "unknown"

                    pcall(function()
                        local info = Market:GetProductInfo(productId)
                        if info then
                            price = info.PriceInRobux or "unknown"
                            if info.CreatorTargetId then
                                local nameOk, n = pcall(function()
                                    return Players:GetNameFromUserIdAsync(info.CreatorTargetId)
                                end)
                                if nameOk then ownerName = n end
                            end
                        end
                    end)

                    logRobuxPrompt(methodName, productId, ownerName, price)
                    return
                end))
            end)
            if ok then
                protectedFunctions[methodName] = { orig = origFn, wrapped = target }
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
--  РАЗДЕЛ 14 — (убран в v2.1.1)
--  Здесь был Anti-Bypass: перехват hookfunction/clonefunction на самих
--  себе, чтобы защитить наши хуки от снятия. Убран после того, как
--  вызвал реальный краш клиента (SIGSEGV) на Android — стектрейс
--  показывал бесконечную рекурсию, характерную именно для самохука
--  hookfunction через hookfunction: на некоторых executor'ах внутренняя
--  реализация при установке хука сама обращается к hookfunction, а мы
--  к этому моменту уже подменили глобальную ссылку на свою версию —
--  получается зацикливание на нативном уровне, а не в Lua, которое
--  pcall не ловит и не может остановить. Выгода от этой защиты (блок
--  попыток снять другие наши хуки) не стоит риска краша всего клиента.
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
--  SECTION 15 — ANTI-AFK (v2.1.8)
-- ═══════════════════════════════════════════════════════════════════════
-- Roblox disconnects idle clients after ~20 minutes. VirtualUser is the
-- standard way around it: when the client fires Players.LocalPlayer.Idled,
-- we simulate a right-click at (0,0), which resets the idle timer without
-- affecting gameplay (button 2 at the origin does nothing in practice).
--
-- Notes on the reference implementation this was adapted from — it had
-- several issues worth avoiding:
--   • It used the deprecated :connect() (lowercase) instead of :Connect().
--   • It used wait()/spawn() instead of task.wait()/task.spawn().
--   • Its timer loop was "while true do if flag then ... wait(1) end end" —
--     when the flag was false the loop spun with NO yield at all, which
--     freezes the client. A wait must be unconditional in any while-true.
--   • It never disconnected anything, so re-running it stacked handlers.
-- This version connects once, stores the connection, and exposes cleanup.
if getgenv()._anti_afk then
    local antiAfkOk, antiAfkErr = pcall(function()
        local VirtualUser = game:GetService("VirtualUser")
        local plr = game:GetService("Players").LocalPlayer

        -- Drop any previous connection (safe re-execution).
        if getgenv().__AntiAfkConnection then
            pcall(function() getgenv().__AntiAfkConnection:Disconnect() end)
            getgenv().__AntiAfkConnection = nil
        end

        getgenv().__AntiAfkConnection = plr.Idled:Connect(function()
            -- Wrapped: on some executors VirtualUser is restricted and
            -- throwing here would spam the console every idle cycle.
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end)

    if not antiAfkOk then
        warn("Anti-AFK could not be enabled: " .. tostring(antiAfkErr))
    end
end

-- ═══════════════════════════════════════════════════════════════════════
--  SECTION 16 — UNLOAD (v2.1.8)
-- ═══════════════════════════════════════════════════════════════════════
-- Lets the user shut the script down without rejoining. Hooks themselves
-- cannot be fully reverted on most executors, but connections can be
-- dropped and every feature flag can be turned off, which stops all
-- blocking and logging behaviour.
getgenv().AntiLoggerUnload = function()
    local flags = {
        "_blockwebhook", "_sanitize_ip", "_anti_kick", "_log_blocks",
        "_anti_reportabuse", "_anti_robux_prompt", "_block_bare_ip",
        "_block_relay_hosts", "_strict_webhook", "_game_context_aware",
        "_kick_forensics", "_warn_actor_risk", "_anti_afk",
        "_verbose_soft_warnings",
    }
    for _, f in ipairs(flags) do
        getgenv()[f] = false
    end

    if getgenv().__AntiAfkConnection then
        pcall(function() getgenv().__AntiAfkConnection:Disconnect() end)
        getgenv().__AntiAfkConnection = nil
    end

    getgenv().__AntiLoggerUnifiedLoaded = nil
    warn("Unloaded. All checks are now disabled. Rejoin to fully remove installed hooks.")
end


-- ═══════════════════════════════════════════════════════════════════════
--  SECTION 17 — LOADING NOTIFICATIONS (v2.1.8)
-- ═══════════════════════════════════════════════════════════════════════
-- Two toasts on startup: "loaded" confirmation and a clickable Telegram
-- card. The second one copies the contact to clipboard on click, so the
-- channel stays reachable without the user having to retype anything.
task.wait(1)

NotifyToast({
    title = "ANTI IP LOGGER + ANTI STEALER",
    content = "Script loaded! ✓",
    duration = 5,
    icon = CONFIG.DEFAULT_ICON
})

task.wait(5)

NotifyToast({
    title = "My Telegram",
    content = "Click to copy: t.me/AYBAT_ATAYBEK",
    duration = 7,
    icon = CONFIG.DEFAULT_ICON,
    callback = function()
        if setclipboard then
            setclipboard("t.me/AYBAT_ATAYBEK")
        end
    end
})
