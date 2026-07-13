local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

getgenv().image = ""
getgenv().sidebar_settings = ""
getgenv().sidebar_scripthub = ""
getgenv().sidebar_home = ""
getgenv().sidebar_executor = ""
getgenv().sidebar_console = ""

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

local function startWatermarkWatchdog(gui)
    task.spawn(function()
        while gui and gui.Parent do
            pcall(replaceWatermark, gui)
            task.wait(2)
        end
    end)
end

local function loadModules()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau"))()
    end)
    pcall(function()
        if not hookfunction then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))()
            return
        end
        local oldPrint = hookfunction(print, function(...) end)
        local oldWarn = hookfunction(warn, function(...) end)
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/CustomDelta.lua"))()
        end)
        hookfunction(print, oldPrint)
        hookfunction(warn, oldWarn)
        if not ok then warn("Ошибка CustomDelta: ", err) end
    end)
end

local function applyToAllDeltaGuis()
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local hasExecute, hasClear = false, false
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextButton") then
                    local t = d.Text:upper()
                    if t:find("EXECUTE") then hasExecute = true end
                    if t:find("CLEAR") then hasClear = true end
                end
            end
            if hasExecute and hasClear or gui.Name:match("[^%w_]") then
                pcall(replaceWatermark, gui)
                startWatermarkWatchdog(gui)
                return gui
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if applyToAllDeltaGuis() then
            loadModules()
            break
        end
        task.wait(1)
    end
end)

CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") then
        task.wait(0.5)
        local hasExecute, hasClear = false, false
        for _, d in ipairs(child:GetDescendants()) do
            if d:IsA("TextButton") then
                local t = d.Text:upper()
                if t:find("EXECUTE") then hasExecute = true end
                if t:find("CLEAR") then hasClear = true end
            end
        end
        if hasExecute and hasClear or child.Name:match("[^%w_]") then
            pcall(replaceWatermark, child)
            startWatermarkWatchdog(child)
            loadModules()
        end
    end
end)

print("[AYBAT]: I'm femboy")
