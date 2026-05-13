-- ДИАГНОСТИКА: проверяем HTTP-запросы и API
local PlaceId = 18687417158

local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 350, 0, 300)
main.Position = UDim2.new(1, -360, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "Diagnostics"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local resultLabel = Instance.new("TextLabel", main)
resultLabel.Size = UDim2.new(1, -20, 0, 250)
resultLabel.Position = UDim2.new(0, 10, 0, 30)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.new(1, 1, 1)
resultLabel.Font = Enum.Font.Gotham
resultLabel.TextSize = 12
resultLabel.TextWrapped = true
resultLabel.TextXAlignment = Enum.TextXAlignment.Left
resultLabel.TextYAlignment = Enum.TextYAlignment.Top
resultLabel.Text = "Press TEST button..."

local testBtn = Instance.new("TextButton", main)
testBtn.Size = UDim2.new(0, 100, 0, 30)
testBtn.Position = UDim2.new(0.5, -50, 0, 285)
testBtn.Text = "TEST"
testBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
testBtn.TextColor3 = Color3.new(1, 1, 1)
testBtn.Font = Enum.Font.GothamBold
testBtn.TextSize = 14

testBtn.MouseButton1Click:Connect(function()
    local results = {}
    
    -- Тест 1: Проверяем, что вообще доступно
    local hasSyn = pcall(function() return syn.request end)
    local hasHttpGet = pcall(function() return game.HttpGet end)
    local hasRequest = pcall(function() return request end)
    
    table.insert(results, "syn.request: " .. tostring(syn and syn.request and "YES" or "NO"))
    table.insert(results, "game:HttpGet: " .. tostring(game and game.HttpGet and "YES" or "NO"))
    table.insert(results, "request: " .. tostring(request and "YES" or "NO"))
    table.insert(results, "")
    
    -- Тест 2: Пробуем все методы
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?limit=5"
    
    if syn and syn.request then
        local ok, res = pcall(function() return syn.request({Url = url, Method = "GET"}) end)
        if ok and res and res.Body then
            local body = res.Body:sub(1, 100)
            table.insert(results, "✅ syn.request WORKS!")
            table.insert(results, "Response: " .. body)
        else
            table.insert(results, "❌ syn.request failed: " .. tostring(res))
        end
    end
    
    if game and game.HttpGet then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then
            local body = res:sub(1, 100)
            table.insert(results, "✅ game:HttpGet WORKS!")
            table.insert(results, "Response: " .. body)
        else
            table.insert(results, "❌ HttpGet failed: " .. tostring(res))
        end
    end
    
    if not syn and not game.HttpGet then
        table.insert(results, "❌ No HTTP methods available!")
        table.insert(results, "Your executor blocks all web requests.")
        table.insert(results, "Try: KRNL, Fluxus, Solara, or Synapse X")
    end
    
    resultLabel.Text = table.concat(results, "\n")
end)

-- Запускаем тест автоматически при открытии
spawn(function()
    wait(0.5)
    testBtn.MouseButton1Click:Fire()
end)
