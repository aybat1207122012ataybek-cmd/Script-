-- Forsaken Server Link Finder
local PlaceId = 2316992690
local MaxPing = 140
local MinFreeSlots = 1
local FetchLimit = 100

local HttpService = game:GetService("HttpService")
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 280, 0, 260)
main.Position = UDim2.new(1, -290, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Forsaken Links"
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
scroll.Size = UDim2.new(1, -10, 0, 180)
scroll.Position = UDim2.new(0, 5, 0, 55)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
scroll.BorderSizePixel = 0

local refresh = Instance.new("TextButton", main)
refresh.Size = UDim2.new(0, 80, 0, 25)
refresh.Position = UDim2.new(0.5, -40, 0, 240)
refresh.Text = "REFRESH"
refresh.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
refresh.TextColor3 = Color3.new(1, 1, 1)
refresh.Font = Enum.Font.GothamBold
refresh.TextSize = 13

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
    if #servers == 0 then status.Text = "No servers" return end
    
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
        f.Size = UDim2.new(1, -10, 0, 35)
        f.Position = UDim2.new(0, 5, 0, y)
        f.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        
        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(0, 170, 1, 0)
        t.Position = UDim2.new(0, 5, 0, 0)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.new(1, 1, 1)
        t.Font = Enum.Font.Gotham
        t.TextSize = 11
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Text = string.format("%d ms | %d/%d", s.ping, s.playing, s.maxPlayers)
        
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 65, 0, 22)
        b.Position = UDim2.new(1, -70, 0, 6)
        b.Text = "COPY"
        b.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.MouseButton1Click:Connect(function()
            local link = "roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. s.id
            pcall(function() setclipboard(link) end)
            status.Text = "Copied!"
        end)
        y = y + 40
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
    status.Text = "Found " .. #good .. " servers"
end

refresh.MouseButton1Click:Connect(update)
update()
