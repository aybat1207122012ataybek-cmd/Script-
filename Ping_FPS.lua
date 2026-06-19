local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local stats = game:GetService("Stats")
local tweenService = game:GetService("TweenService")

local function getPing()
    local success, ping = pcall(function()
        local serverStats = stats.Network.ServerStatsItem
        local networkPing = serverStats:FindFirstChild("Network Ping")
        
        if networkPing then
            local val = networkPing:GetValue()
            if type(val) == "number" then
                return math.floor(val)
            else
                return tonumber(tostring(val):match("%d+")) or 0
            end
        end
        return 0
    end)
    
    return success and (ping or 0) or 0
end

local function createMonitor()
    if player.PlayerGui:FindFirstChild("TopbarStandard") then
        local topbar = player.PlayerGui.TopbarStandard
        if topbar and topbar:FindFirstChild("Holders") and topbar.Holders:FindFirstChild("Right") then
            local rightHolder = topbar.Holders.Right
            if rightHolder:FindFirstChild("FPSPingFrame") then return end
            
            local mainFrame = Instance.new("Frame")
            mainFrame.Name = "FPSPingFrame"
            mainFrame.Size = UDim2.new(0, 180, 0, 44)
            mainFrame.Position = UDim2.new(0, 10, 0, 0)
            mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
            mainFrame.BackgroundTransparency = 0.08
            mainFrame.Parent = rightHolder
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = mainFrame
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = Color3.new(1, 1, 1)
            text.Font = Enum.Font.BuilderSansBold
            text.TextSize = 12
            text.Text = "FPS: -- | Ping: --ms"
            text.Parent = mainFrame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Name = "ToggleBtn"
            toggleBtn.Size = UDim2.new(0, 30, 0, 30)
            toggleBtn.Position = UDim2.new(1, -35, 0.5, -15)
            toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.TextColor3 = Color3.new(1, 1, 1)
            toggleBtn.Font = Enum.Font.BuilderSansBold
            toggleBtn.TextSize = 18
            toggleBtn.Text = ""
            toggleBtn.BorderSizePixel = 0
            toggleBtn.Parent = mainFrame
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 5)
            toggleCorner.Parent = toggleBtn
            
            local isMinimized = false
            local originalSize = UDim2.new(0, 180, 0, 44)
            local minimizedSize = UDim2.new(0, 40, 0, 44)
            
            local function animateToggle()
                if isMinimized then
                    local openTween = tweenService:Create(
                        mainFrame,
                        TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                        {Size = originalSize}
                    )
                    openTween:Play()
                    
                    local textTween = tweenService:Create(
                        text,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        {TextTransparency = 0}
                    )
                    textTween:Play()
                    
                    isMinimized = false
                else
                    local textTween = tweenService:Create(
                        text,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {TextTransparency = 1}
                    )
                    textTween:Play()
                    
                    task.wait(0.1)
                    
                    local closeTween = tweenService:Create(
                        mainFrame,
                        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                        {Size = minimizedSize}
                    )
                    closeTween:Play()
                    
                    isMinimized = true
                end
            end
            
            toggleBtn.MouseButton1Click:Connect(animateToggle)
            
            local lastTime = tick()
            local frameCount = 0
            
            runService.RenderStepped:Connect(function()
                frameCount = frameCount + 1
                local now = tick()
                if now - lastTime >= 1 then
                    local fps = frameCount / (now - lastTime)
                    local ping = getPing()
                    text.Text = string.format("FPS: %.1f | Ping: %dms", fps, ping)
                    frameCount = 0
                    lastTime = now
                end
            end)
            
            return
        end
    end
    
    local coreGui = game:GetService("CoreGui")
    local topBarApp = coreGui:FindFirstChild("TopBarApp")
    if not topBarApp then return end
    
    local container = topBarApp:FindFirstChild("TopBarApp")
    if not container then return end
    if container:FindFirstChild("FPSPingFrame") then return end
    
    local frame1 = Instance.new("Frame")
    frame1.Name = "FPSPingFrame"
    frame1.Size = UDim2.new(1, 0, 0, 48)
    frame1.Position = UDim2.new(0, 0, 0, 10)
    frame1.BackgroundTransparency = 1
    frame1.Parent = container
    
    local frame2 = Instance.new("Frame")
    frame2.Size = UDim2.new(1, 0, 0, 44)
    frame2.Position = UDim2.new(0, 0, 0, 2)
    frame2.BackgroundTransparency = 1
    frame2.Parent = frame1
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = frame2
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 180, 0, 44)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    mainFrame.BackgroundTransparency = 0.08
    mainFrame.Parent = frame2
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = mainFrame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.BuilderSansBold
    text.TextSize = 12
    text.Text = "FPS: -- | Ping: --ms"
    text.Parent = mainFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleBtn.Position = UDim2.new(1, -35, 0.5, -15)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Font = Enum.Font.BuilderSansBold
    toggleBtn.TextSize = 18
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = mainFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggleBtn
    
    local isMinimized = false
    local originalSize = UDim2.new(0, 180, 0, 44)
    local minimizedSize = UDim2.new(0, 40, 0, 44)
    
    local function animateToggle()
        if isMinimized then
            local openTween = tweenService:Create(
                mainFrame,
                TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
                {Size = originalSize}
            )
            openTween:Play()
            
            local textTween = tweenService:Create(
                text,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {TextTransparency = 0}
            )
            textTween:Play()
            
            isMinimized = false
        else
            local textTween = tweenService:Create(
                text,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {TextTransparency = 1}
            )
            textTween:Play()
            
            task.wait(0.1)
            
            local closeTween = tweenService:Create(
                mainFrame,
                TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                {Size = minimizedSize}
            )
            closeTween:Play()
            
            isMinimized = true
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(animateToggle)
    
    local lastTime = tick()
    local frameCount = 0
    
    runService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 1 then
            local fps = frameCount / (now - lastTime)
            local ping = getPing()
            text.Text = string.format("FPS: %.1f | Ping: %dms", fps, ping)
            frameCount = 0
            lastTime = now
        end
    end)
end

createMonitor()
