if getgenv().__AntiLoggerUnifiedLoaded then
    warn("[AntiLogger] Уже загружен, повторный запуск пропущен (во избежание наслоения хуков).")
    return
end
getgenv().__AntiLoggerUnifiedLoaded = true

getgenv()._blockwebhook = true
getgenv()._sanitize_ip = true
getgenv()._log_blocks = true
getgenv()._anti_kick = true
getgenv()._scan_loadstring = true

getgenv()._whitelist = getgenv()._whitelist or {
    "roblox.com", "rbxcdn.com",
}

local cloneref = cloneref or clone_reference or function(o) return o end
local realGame = cloneref(game)
local HttpService = cloneref(game:GetService("HttpService"))
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local sfind, slower, smatch, gsub = string.find, string.lower, string.match, string.gsub
local rnd = math.random

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
    "hookbin", "pipedream", "webhook-test.com",
    "webhook.site", "webhook.in", "hook.io",
    "pushover.net", "ntfy.sh", "gotify.net", "matrix.org",
    "requestbin", "leancoding", "beeceptor", "requestcatcher", "run.mocky.io",
}

local SuspiciousTLDs = { "tk", "ml", "ga", "cf", "gq" }

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

local CodeBlacklistHard = {
    "getcookiesasync", "roblosecurity", "webhookrouter", "getdiscuser",
    "messagebusservice", "cmd.exe", ":5000/",
}

local CodeBlacklistSoft = {
    "stealer", "stolen", "ratt", "all your items", "linkingservice",
    "grabify", "iplogger", "ipify", "canihazip", "checkip", "externalip",
    "tobi's", "myip", "ipconfig", "trade", "gift", "mailbox",
}

local isBlocked

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
            warn("[AntiLogger] downloadImage: URL заблокирован фильтром, иконка не загружена: " .. tostring(url))
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
    MIN_HEIGHT = 55
}

local currentToast = nil

local function NotifyToast(config)
    config = config or {}

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

    container.Size = UDim2.new(1, CONFIG.WIDTH_OFFSET, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    bg.AutomaticSize = Enum.AutomaticSize.Y
    innerFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y

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

local function logBlock(tag, url)
    if not getgenv()._log_blocks then return end
    warn("╔══════════━━━ • ━━━═══════════╗")
    warn("[ BLOCK ] " .. tag)
    warn("Time : " .. os.date("%H:%M:%S"))
    warn("URL : " .. tostring(url))
    warn("Host : " .. getHost(urlDecode(url)))
    warn("╚══════════━━━ • ━━━═══════════╝")

    local notifTitle
    if tag == "STEALER" then
        notifTitle = "STEALER SIGNATURE — BLOCKED"
    elseif tag == "WEBHOOK" then
        notifTitle = "WEBHOOK SIGNATURE — BLOCKED"
    else
        notifTitle = "LOGGER SIGNATURE — BLOCKED"
    end

    NotifyToast({
        title = notifTitle,
        content = "Learn more in the console...",
        duration = 5,
        icon = "rbxassetid://109331116693769"
    })
end

local function logKick()
    if not getgenv()._log_blocks then return end
    warn("╔══════════━━━ • ━━━═══════════╗")
    warn("[BLOCK] Kick attempt")
    warn("╚══════════━━━ • ━━━═══════════╝")

    NotifyToast({
        title = "KICK ATTEMPT BLOCKED",
        content = "Learn more in the console...",
        duration = 5,
        icon = "rbxassetid://109331116693769"
    })
end

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

    if sfind(ul, COOKIE_SIG, 1, true) or sfind(ul, "roblosecurity", 1, true) or
       sfind(bl, COOKIE_SIG, 1, true) or sfind(bl, "roblosecurity", 1, true) then
        if not (host == "roblox.com" or host:sub(-11) == ".roblox.com") then
            return true, "STEALER"
        end
    end

    if isWhitelisted(host) then
        return false, nil
    end

    if getgenv()._blockwebhook and isPost then
        for _, pat in ipairs(WebhookPatterns) do
            local hostSuffix, pathSub = pat[1], pat[2]
            local hostMatches = (host == hostSuffix or host:sub(-(#hostSuffix + 1)) == "." .. hostSuffix)
            if hostMatches and (pathSub == "" or sfind(pl, pathSub, 1, true)) then
                return true, "WEBHOOK"
            end
        end
    end

    for _, p in ipairs(BLACKLIST) do
        if host == p or host:sub(-(#p + 1)) == "." .. p or sfind(host, p, 1, true) then
            return true, "LOGGER"
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

local function sanitizeBody(bodyStr)
    if type(bodyStr) ~= "string" or bodyStr == "" then return bodyStr end
    if not getgenv()._sanitize_ip then return bodyStr end
    local ipv4, ipv6 = fakeIPv4(), fakeIPv6()
    local out = bodyStr:gsub("%d+%.%d+%.%d+%.%d+", ipv4)
    out = out:gsub("%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+", ipv6)
    return out
end

if getgenv()._scan_loadstring and hookfunction and type(loadstring) == "function" then
    local origLoadstring
    origLoadstring = hookfunction(loadstring, newcclosure(function(code, chunkname)
        local codeStr = tostring(code):lower()

        for _, word in ipairs(CodeBlacklistHard) do
            if sfind(codeStr, word, 1, true) then
                warn("╔══════════━━━ • ━━━═══════════╗")
                warn("[ BLOCK ] LOADSTRING")
                warn("Time : " .. os.date("%H:%M:%S"))
                warn("Reason : hard signature \"" .. word .. "\"")
                warn("╚══════════━━━ • ━━━═══════════╝")
                NotifyToast({
                    title = "LOADSTRING BLOCKED",
                    content = "Learn more in the console...",
                    duration = 5,
                    icon = "rbxassetid://109331116693769"
                })
                return newcclosure(function() end)
            end
        end

        for _, word in ipairs(CodeBlacklistSoft) do
            if sfind(codeStr, word, 1, true) then
                warn("[AntiLogger] Внимание: loadstring содержит подозрительное слово \"" .. word .. "\" — код НЕ заблокирован, только предупреждение.")
                break
            end
        end

        return origLoadstring(code, chunkname)
    end))
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }
    local url = args[1]
    local body = args[2]

    if getgenv()._anti_kick and method == "Kick" and self == player and not checkcaller() then
        logKick()
        return
    end

    if method == "HttpGet" or method == "HttpGetAsync" or method == "GetAsync" then
        local blocked, tag = isBlocked(url, nil, nil, false)
        if blocked then
            logBlock(tag, url)
            return ""
        end
        local result = oldNamecall(self, ...)
        if type(result) == "string" then
            return sanitizeBody(result)
        end
        return result

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
            if newResult.Body then newResult.Body = sanitizeBody(newResult.Body) end
            if newResult.body then newResult.body = sanitizeBody(newResult.body) end
            return newResult
        end
        return result
    end

    return oldNamecall(self, ...)
end))

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
            if newResult.Body then newResult.Body = sanitizeBody(newResult.Body) end
            if newResult.body then newResult.body = sanitizeBody(newResult.body) end
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

warn("╔══════════━━━ • ━━━═══════════╗")
warn("Anti IP Logger + Anti Stealer loaded")
warn("• ANTI IP LOGGER : HTTP/WebSocket domain filter + response sanitize")
warn("• ANTI STEALER   : cookie guard, loadstring scan, anti-kick")
warn("╚══════════━━━ • ━━━═══════════╝")
