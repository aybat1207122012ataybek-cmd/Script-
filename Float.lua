-- Forsaken Finder v4.1 (фикс Bad API + лагов)
local PlaceId = 18687417158
local InitialMaxPing = 120
local MaxPingStep = 20
local MaxPingLimit = 350
local MinFreeSlots = 1
local FetchLimit = 100

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- GUI
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 300, 0, 320)
main.Position = UDim2.new(1, -310, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Forsaken Finder v4.1"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -10, 0, 35)
status.Position = UDim2.new(0, 5, 0, 30)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
status.TextWrapped = true
status.Text = "Ready"

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0, 195)
scroll.Position = UDim2.new(0, 5, 0, 70)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6

local refreshBtn = Instance.new("TextButton", main)
refreshBtn.Size = UDim2.new(0, 80, 0, 28)
refreshBtn.Position = UDim2.new(0, 10, 0, 275)
refreshBtn.Text = "REFRESH"
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 12

local bestBtn = Instance.new("TextButton", main)
bestBtn.Size = UDim2.new(0, 90, 0, 28)
bestBtn.Position = UDim2.new(1, -100, 0, 275)
bestBtn.Text = "JOIN BEST"
bestBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 0)
bestBtn.TextColor3 = Color3.new(1, 1, 1)
bestBtn.Font = Enum.Font.GothamBold
bestBtn.TextSize = 12

local function tryFetch(url)
    -- syn.request
    if syn and syn.request then
        local ok, res = pcall(function()
            return syn.request({Url = url, Method = "GET", Headers = {["Content-Type"] = "application/json"}})
        end)
        if ok and res and res.Body and #res.Body > 10 then
            return res.Body
        end
    end
    -- request (legacy)
    if request then
        local ok, res = pcall(function()
            return request({Url = url, Method = "GET"})
        end)
        if ok and res and res.Body and #res.Body > 10 then
            return res.Body
        end
    end
    -- game:HttpGet
    if game and game.HttpGet then
        local ok, res = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and res and #res > 10 then
            return res
        end
    end
    return nil
end

local function getColor(ping)
    if ping < 100 then return Color3.fromRGB(40, 120, 40)
    elseif ping < 150 then return Color3.fromRGB(160, 130, 30)
    else return Color3.fromRGB(120, 40, 40) end
end

local function clearScroll()
    for _, c in ipairs(scroll:GetChildren()) do
        c:Destroy()
    end
end

local function update()
    clearScroll()
    status.Text = "Fetching servers..."
    
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=" .. FetchLimit
    local body = tryFetch(url)
    if not body then
        status.Text = "HTTP request blocked! Change executor."
        return
    end
    
    -- Безопасный парсинг JSON
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" or not data.data then
        -- Проверим, не пришёл ли ответ с ошибкой
        if body:find("error") or body:find("TooManyRequests") then
            status.Text = "Roblox API rate limited. Wait 30s."
        else
            status.Text = "Bad API response. Raw: " .. string.sub(body, 1, 80)
        end
        return
    end

    local allServers = data.data
    if #allServers == 0 then
        status.Text = "0 servers from API. Try again later."
        return
    end

    -- Автоподбор порога
    local currentMaxPing = InitialMaxPing
    local filtered = {}
    while #filtered == 0 and currentMaxPing <= MaxPingLimit do
        filtered = {}
        for _, s in ipairs(allServers) do
            local ping = s.ping or 999
            local free = (s.maxPlayers or 100) - (s.playing or 0)
            if ping <= currentMaxPing and free >= MinFreeSlots then
                table.insert(filtered, s)
            end
        end
        if #filtered == 0 then
            currentMaxPing = currentMaxPing + MaxPingStep
        end
    end

    -- Сортировка
    table.sort(filtered, function(a, b) return (a.ping or 999) < (b.ping or 999) end)

    -- Строим список без лагов: создаём элементы пачками с задержкой
    local y = 0
    local index = 0
    local function addNext()
        index = index + 1
        if index > #filtered then
            scroll.CanvasSize = UDim2.new(0, 0, 0, y)
            if #filtered > 0 then
                status.Text = string.format("Showing %d servers (ping≤%d ms, API total: %d)", #filtered, currentMaxPing, #allServers)
            else
                status.Text = string.format("0 servers (max ping tried: %d)", currentMaxPing)
            end
            return
        end

        local s = filtered[index]
        local ping = s.ping or 999
        local playing = s.playing or 0
        local maxPlayers = s.maxPlayers or 100
        local free = maxPlayers - playing

        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -10, 0, 40)
        f.Position = UDim2.new(0, 5, 0, y)
        f.BackgroundColor3 = getColor(ping)

        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(0, 150, 1, 0)
        t.Position = UDim2.new(0, 5, 0, 0)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.Gotham
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = string.format("%d ms | %d/%d (%d free)", ping, playing, maxPlayers, free)

        local joinBtn = Instance.new("TextButton", f)
        joinBtn.Size = UDim2.new(0, 45, 0, 22)
        joinBtn.Position = UDim2.new(1, -115, 0, 9)
        joinBtn.Text = "JOIN"
        joinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        joinBtn.TextColor3 = Color3.new(1, 1, 1)
        joinBtn.Font = Enum.Font.GothamBold
        joinBtn.TextSize = 10
        joinBtn.MouseButton1Click:Connect(function()
            status.Text = "Joining..."
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, Players.LocalPlayer)
            end)
            if not ok then
                local link = "roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. s.id
                pcall(function() setclipboard(link) end)
                status.Text = "Teleport blocked. Link copied!"
            end
        end)

        local copyBtn = Instance.new("TextButton", f)
        copyBtn.Size = UDim2.new(0, 55, 0, 22)
        copyBtn.Position = UDim2.new(1, -65, 0, 9)
        copyBtn.Text = "COPY"
        copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.TextSize = 10
        copyBtn.MouseButton1Click:Connect(function()
            local link = "roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. s.id
            pcall(function() setclipboard(link) end)
            status.Text = "Link copied!"
        end)

        y = y + 45
        -- Задержка между созданием элементов, чтобы не лагало
        wait(0.01)
        addNext()
    end

    -- Кнопка JOIN BEST
    bestBtn.MouseButton1Click:Connect(function()
        if #filtered > 0 then
            local best = filtered[1]
            status.Text = "Joining best server..."
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, best.id, Players.LocalPlayer)
            end)
            if not ok then
                local link = "roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. best.id
                pcall(function() setclipboard(link) end)
                status.Text = "Copied best link! Paste in browser."
            end
        else
            status.Text = "No servers to join."
        end
    end)

    -- Запускаем построение списка
    addNext()
end

refreshBtn.MouseButton1Click:Connect(function()
    -- Отключаем кнопки на время обновления, чтобы избежать двойных запросов
    refreshBtn.Active = false
    bestBtn.Active = false
    update()
    wait(1)
    refreshBtn.Active = true
    bestBtn.Active = true
end)

-- Первичное обновление
spawn(function()
    wait(1)
    update()
end)
