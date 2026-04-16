
local HttpService = game:GetService("HttpService")
local fontFile = "MinecraftRUS.ttf"

if not isfile(fontFile) then 
    warn("Файл MinecraftRUS.ttf не найден в папке workspace!")
    return 
end

local configPath = "mc_pro_fixed.json"
writefile(configPath, HttpService:JSONEncode({
    name = "MC_Pro",
    faces = {{name = "Regular", weight = 400, style = "normal", assetId = getcustomasset(fontFile)}}
}))
local mcFont = Font.new(getcustomasset(configPath))

local ignore = {"Icons", "BuilderIcons", "Symbols", "CustomIcon"}
local function isIcon(obj)
    local f = tostring(obj.FontFace)
    for _, name in ipairs(ignore) do if f:find(name) then return true end end
    return false
end

local function apply(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    if isIcon(obj) or obj:GetAttribute("MC_Ok") then return end

    obj.FontFace = mcFont
    if not obj.TextScaled then
        obj.TextSize = obj.TextSize + 1
    end

    obj:SetAttribute("MC_Ok", true)

    obj:GetPropertyChangedSignal("FontFace"):Connect(function()
        if not isIcon(obj) then obj.FontFace = mcFont end
    end)
end

local function safeScan(folder)
    local descendants = folder:GetDescendants()
    for i, v in ipairs(descendants) do
        pcall(apply, v)
        if i % 150 == 0 then task.wait() end
    end
end

task.spawn(function()
    while task.wait(120) do
        collectgarbage("collect")
    end
end)

task.spawn(function()
    local pGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 10)
    if pGui then safeScan(pGui) end
    pcall(function() safeScan(game:GetService("CoreGui")) end)
end)

game.DescendantAdded:Connect(function(v)
    pcall(apply, v)
end)

print("хей... спасибо что юзаешь мой скрипт я рад этому <3")

