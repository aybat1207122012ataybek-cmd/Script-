-- Forsaken Server Finder (Казахстан, Алматы, без VPN)
local PlaceId = 18687417158
local MaxPing = 120              -- твой реальный пинг ~100, берём с запасом
local MinFreeSlots = 1           -- хотя бы 1 свободное место
local FetchLimit = 100

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- GUI
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 280, 0, 300)
main.Position = UDim2.new(1, -290, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Forsaken Finder"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 30)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
status.Text = "Status: Ready"

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0, 200)
scroll.Position = UDim2.new(0, 5, 0, 55)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
scroll.BorderSizePixel = 0

local refresh = Instance.new("TextButton", main)
refresh.Size = UDim2.new(0, 80, 0, 28)
refresh.Position = UDim2.new(0.5, -40, 0, 262)
refresh.Text = "REFRESH"
refresh.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
refresh.TextColor3 = Color3.new(1, 1, 1)
refresh.Font = Enum.Font.GothamBold
refresh.TextSize = 13

-- Функции
local function getServers()
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=" .. FetchLimit
    local ok, res = pcall(function()
        if syn and syn.request then
            return syn.request({Url = url, Method = "GET"})
        else
            return {Body = game:HttpGet(url)}
        end
    end)
    if not ok or not res or not res.Body then return {} end
    local data = HttpService:JSONDecode(res.Body)
    return data.data or {}
end

local function update()
    for _, c in ipairs(scroll:GetChildren()) do c:Destroy() end
    status.Text = "Fetching..."
    local servers = getServers()
    if #servers == 0 then
        status.Text = "No servers. Check PlaceId or internet."
        return
    end

    local good = {}
    for _, s in ipairs(servers) do
        local ping = s.ping or 999
        local free = (s.maxPlayers or 100) - (s.playing or 0)
        if ping <= MaxPing and free >= MinFreeSlots then
            table.insert(good, s)
        end
    end
    table.sort(good, function(a, b) return a.ping < b.ping end)

    local y = 0
    for _, s in ipairs(good) do
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, -10, 0, 40)
        f.Position = UDim2.new(0, 5, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(50, 50, 60)

        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(0, 140, 1, 0)
        t.Position = UDim2.new(0, 5, 0, 0)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.Gotham
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = string.format("%d ms | %d/%d", s.ping, s.playing, s.maxPlayers)

        -- Кнопка JOIN (пробует прямой телепорт)
        local joinBtn = Instance.new("TextButton", f)
        joinBtn.Size = UDim2.new(0, 45, 0, 22)
        joinBtn.Position = UDim2.new(1, -115, 0, 9)
        joinBtn.Text = "JOIN"
        joinBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        joinBtn.TextColor3 = Color3.new(1, 1, 1)
        joinBtn.Font = Enum.Font.GothamBold
        joinBtn.TextSize = 10
        joinBtn.MouseButton1Click:Connect(function()
            status.Text = "Joining..."
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, Players.LocalPlayer)
            end)
            if not ok then
                -- fallback: прямая ссылка
                local link = "roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. s.id
                pcall(function() setclipboard(link) end)
                status.Text = "Copied link! Paste in browser."
            end
        end)

        -- Кнопка COPY
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
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
    status.Text = "Found " .. #good .. " servers (ping<" .. MaxPing .. ")"
end

refresh.MouseButton1Click:Connect(update)
update()
