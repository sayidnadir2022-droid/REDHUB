local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

if pgui:FindFirstChild("RedHubFinal") then pgui.RedHubFinal:Destroy() end

local sg = Instance.new("ScreenGui", pgui)
sg.Name = "RedHubFinal"
sg.ResetOnSpawn = false

local selected = nil
local noclip, airwalk, infjump, flingEnabled, espEnabled, flyEnabled = false, false, false, false, false, false
local flyKey = Enum.KeyCode.C
local lastPart, currentHeight = nil, 0

local header = Instance.new("Frame", sg)
header.Size = UDim2.new(0, 450, 0, 30); header.Position = UDim2.new(0.5, -225, 0.3, 0)
header.BackgroundColor3 = Color3.fromRGB(200, 0, 0); header.Active = true; header.Draggable = true

-- Başlıkta "Red Hub" ve Seçili Oyuncu Göstergesi
local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -10, 1, 0); titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.new(1,1,1); titleLabel.TextSize = 14; titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Red Hub  ( Seçili: Yok )"

local main = Instance.new("Frame", header)
main.Size = UDim2.new(1, 0, 0, 420); main.Position = UDim2.new(0, 0, 1, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 2; main.BorderColor3 = Color3.fromRGB(200, 0, 0)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -120, 1, -20); container.Position = UDim2.new(0, 110, 0, 10); container.BackgroundTransparency = 1

local p1, p2, p3 = Instance.new("ScrollingFrame", container), Instance.new("ScrollingFrame", container), Instance.new("ScrollingFrame", container)

local function setupPage(f)
    f.Size = UDim2.new(1, 0, 1, 0); f.BackgroundTransparency = 1; f.Visible = false
    f.ScrollBarThickness = 4; f.CanvasSize = UDim2.new(0, 0, 0, 1200)
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 10); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
end
setupPage(p1); setupPage(p2); setupPage(p3); p1.Visible = true

local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 100, 1, 0); sideBar.BackgroundColor3 = Color3.fromRGB(25, 0, 0)

local function addTab(name, y, page)
    local b = Instance.new("TextButton", sideBar)
    b.Size = UDim2.new(0, 90, 0, 45); b.Position = UDim2.new(0.5, -45, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 0, 0); b.Text = name; b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() p1.Visible = false; p2.Visible = false; p3.Visible = false; page.Visible = true end)
end
addTab("PLAYER", 10, p1); addTab("SERVER", 65, p2); addTab("TROLL", 120, p3)

local function btn(txt, parent, func)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 280, 0, 35); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.MouseButton1Click:Connect(function() func(b) end); return b
end

local function addSlider(name, parent, min, max, def, func)
    local l = Instance.new("TextLabel", parent); l.Size = UDim2.new(0, 280, 0, 20); l.Text = name..": "..def; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
    local s = Instance.new("Frame", parent); s.Size = UDim2.new(0, 250, 0, 8); s.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    local knob = Instance.new("Frame", s); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 0, 0.5, -8); knob.BackgroundColor3 = Color3.new(1,0,0)
    s.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(move)
                if move.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((move.Position.X - s.AbsolutePosition.X) / s.AbsoluteSize.X, 0, 1)
                    knob.Position = UDim2.new(percent, -8, 0.5, -8)
                    local val = math.floor(min + (max - min) * percent)
                    l.Text = name..": "..val; func(val)
                end
            end)
            UserInputService.InputEnded:Connect(function(up) if up.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect() end end)
        end
    end)
end

addSlider("SPEED", p1, 16, 500, 16, function(v) if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end)
addSlider("JUMP", p1, 50, 1000, 50, function(v) if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = v end end)
btn("TELEPORT FORWARD (V)", p1, function() if player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame *= CFrame.new(0,0,-12) end end).BackgroundColor3 = Color3.fromRGB(150,0,0)
btn("CREATE/DELETE RED PART", p1, function(self)
    if lastPart then lastPart:Destroy(); lastPart = nil; self.Text = "CREATE RED PART" else
        lastPart = Instance.new("Part", workspace); lastPart.Size = Vector3.new(15,1,15); lastPart.Color = Color3.new(1,0,0); lastPart.Anchored = true
        lastPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-3.5,0); self.Text = "DELETE RED PART"
    end
end)
btn("NOCLIP: OFF", p1, function(self) noclip = not noclip; self.Text = "NOCLIP: "..(noclip and "ON" or "OFF") end)
btn("AIRWALK: OFF", p1, function(self) airwalk = not airwalk; self.Text = "AIRWALK: "..(airwalk and "ON" or "OFF"); if airwalk then currentHeight = player.Character.HumanoidRootPart.Position.Y end end)

local pTP = btn("TELEPORT TO PART", p1, function() if lastPart then player.Character.HumanoidRootPart.CFrame = lastPart.CFrame * CFrame.new(0,4,0) end end)
pTP.LayoutOrder = 100
local iJump = btn("INF JUMP: OFF", p1, function(self) infjump = not infjump; self.Text = "INF JUMP: "..(infjump and "ON" or "OFF") end)
iJump.LayoutOrder = 101

local flyContainer = Instance.new("Frame", p1)
flyContainer.Size = UDim2.new(0, 280, 0, 35); flyContainer.BackgroundTransparency = 1; flyContainer.LayoutOrder = 102

local flyBtn = Instance.new("TextButton", flyContainer)
flyBtn.Size = UDim2.new(0, 215, 1, 0); flyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
flyBtn.Text = "FLY: OFF"; flyBtn.TextColor3 = Color3.new(1,1,1)

local bindBtn = Instance.new("TextButton", flyContainer)
bindBtn.Size = UDim2.new(0, 60, 1, 0); bindBtn.Position = UDim2.new(0, 220, 0, 0)
bindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bindBtn.Text = "(C)"; bindBtn.TextColor3 = Color3.new(1,1,1)

local function toggleFly()
    flyEnabled = not flyEnabled
    flyBtn.Text = "FLY: "..(flyEnabled and "ON" or "OFF")
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if flyEnabled then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "RedFlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0, 0, 0)
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "RedFlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.CFrame = hrp.CFrame
        if hum then hum.PlatformStand = true end
        
        task.spawn(function()
            while flyEnabled and char and hrp and hrp.Parent do
                local cam = workspace.CurrentCamera
                local vel = Vector3.new(0, 0, 0)
                local speed = 50
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel -= cam.CFrame.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel += cam.CFrame.RightVector * speed end
                bv.Velocity = vel
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if hum then hum.PlatformStand = false end
        end)
    else
        if hrp:FindFirstChild("RedFlyVelocity") then hrp.RedFlyVelocity:Destroy() end
        if hrp:FindFirstChild("RedFlyGyro") then hrp.RedFlyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

flyBtn.MouseButton1Click:Connect(toggleFly)
bindBtn.MouseButton1Click:Connect(function()
    bindBtn.Text = "(...)"
    local connection
    connection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            flyKey = input.KeyCode
            bindBtn.Text = "("..flyKey.Name..")"
            connection:Disconnect()
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == flyKey then toggleFly() end
end)

local plFrame = Instance.new("Frame", p2); plFrame.Size = UDim2.new(1, 0, 0, 0); plFrame.BackgroundTransparency = 1; plFrame.LayoutOrder = 1
local plLayout = Instance.new("UIListLayout", plFrame); plLayout.Padding = UDim.new(0, 5)
plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() plFrame.Size = UDim2.new(1, 0, 0, plLayout.AbsoluteContentSize.Y) end)

local function updateList()
    for _,v in pairs(plFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pCont = Instance.new("Frame", plFrame); pCont.Size = UDim2.new(1, -10, 0, 30); pCont.BackgroundTransparency = 1
            local pL = Instance.new("UIListLayout", pCont); pL.FillDirection = Enum.FillDirection.Horizontal; pL.Padding = UDim.new(0, 5)
            local nB = Instance.new("TextButton", pCont); nB.Size = UDim2.new(0, 220, 1, 0); nB.BackgroundColor3 = Color3.fromRGB(35,35,35); nB.Text = p.DisplayName; nB.TextColor3 = Color3.new(1,1,1)
            nB.MouseButton1Click:Connect(function()
                selected = p
                titleLabel.Text = "Red Hub  ( Seçili: "..p.DisplayName.." )"
            end)
            local tB = Instance.new("TextButton", pCont); tB.Size = UDim2.new(0, 50, 1, 0); tB.BackgroundColor3 = Color3.fromRGB(120,0,0); tB.Text = "TP"; tB.TextColor3 = Color3.new(1,1,1)
            tB.MouseButton1Click:Connect(function() if p.Character then player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end)
        end
    end
end
updateList(); Players.PlayerAdded:Connect(updateList); Players.PlayerRemoving:Connect(updateList)

-- ESP / TRACER / SAĞLIK / MESAFE SİSTEMİ
local espBtn = btn("ESP & TRACER: OFF", p2, function(self)
    espEnabled = not espEnabled
    self.Text = "ESP & TRACER: "..(espEnabled and "ON" or "OFF")
    if not espEnabled then
        for _,v in pairs(sg:GetChildren()) do
            if v:IsA("Highlight") or v:IsA("BillboardGui") or v:IsA("LineHandleAdornee") or v.Name == "TracerLine" then v:Destroy() end
        end
    end
end)
espBtn.LayoutOrder = 100; espBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)

-- TROLL SEKMESİ (Fling)
local flingBtn
flingBtn = btn("FLING: OFF", p3, function(self)
    if not selected or not selected.Character then
        self.Text = "SELECT PLAYER!"
        task.wait(1)
        self.Text = "FLING: OFF"
        return
    end

    flingEnabled = not flingEnabled
    self.Text = "FLING: "..(flingEnabled and "ON" or "OFF")

    if flingEnabled then
        task.spawn(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myHRP = char.HumanoidRootPart
            local originalCFrame = myHRP.CFrame
            local startTime = tick()
            
            while flingEnabled and (tick() - startTime < 3) do
                task.wait()
                if selected and selected.Character and selected.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = selected.Character.HumanoidRootPart
                    myHRP.CFrame = targetHRP.CFrame
                    myHRP.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
                end
            end
            
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            myHRP.CFrame = originalCFrame
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            flingEnabled = false
            flingBtn.Text = "FLING: OFF"
        end)
    end
end)

btn("FIRE/SMOKE/SPARKLES", p3, function() if selected and selected.Character then Instance.new("Fire", selected.Character.HumanoidRootPart); Instance.new("Smoke", selected.Character.HumanoidRootPart); Instance.new("Sparkles", selected.Character.HumanoidRootPart) end end)

-- GELİŞMİŞ ESP DÖNGÜSÜ (Highlight + Sağlık + Mesafe + Çizgi/Tracer)
RunService.RenderStepped:Connect(function()
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            local myChar = player.Character
            local hlName = p.Name.."_ESP"
            local infoName = p.Name.."_Info"
            local tracerName = p.Name.."_Tracer"
            
            if espEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
                local hrp = char.HumanoidRootPart
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                -- 1. Highlight (Karakter Çerçevesi)
                if not sg:FindFirstChild(hlName) then
                    local hl = Instance.new("Highlight", sg)
                    hl.Name = hlName; hl.Adornee = char
                    hl.FillColor = Color3.new(1,0,0); hl.OutlineColor = Color3.new(1,1,1); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                
                -- 2. BillboardGui (Can ve Mesafe Bilgisi - Kahverengi tonlar ve detaylar)
                local infoGui = char:FindFirstChild(infoName)
                if not infoGui then
                    infoGui = Instance.new("BillboardGui", char)
                    infoGui.Name = infoName; infoGui.Size = UDim2.new(0, 150, 0, 50)
                    infoGui.StudsOffset = Vector3.new(0, 3, 0); infoGui.AlwaysOnTop = true
                    
                    local textLbl = Instance.new("TextLabel", infoGui)
                    textLbl.Name = "InfoText"; textLbl.Size = UDim2.new(1, 0, 1, 0)
                    textLbl.BackgroundTransparency = 1; textLbl.TextColor3 = Color3.fromRGB(139, 69, 19) -- Kahverengi
                    textLbl.TextSize = 13; textLbl.Font = Enum.Font.GothamBold
                    textLbl.TextStrokeTransparency = 0
                end
                
                if infoGui and infoGui:FindFirstChild("InfoText") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((hrp.Position - myChar.HumanoidRootPart.Position).Magnitude)
                    infoGui.InfoText.Text = p.Name.."\nCan: "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth).."\nMesafe: "..dist.." stud"
                end
                
                -- 3. Tracer Çizgisi (Kırmızı / Temsili renk)
                local tracer = workspace:FindFirstChild(tracerName)
                if not tracer and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    tracer = Instance.new("Part", workspace)
                    tracer.Name = tracerName; tracer.Anchored = true; tracer.CanCollide = false
                    tracer.Transparency = 0.5; tracer.Color = Color3.new(1, 0, 0); tracer.Size = Vector3.new(0.1, 0.1, 1)
                end
                if tracer and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local p1Pos = myChar.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
                    local p2Pos = hrp.Position
                    local distance = (p1Pos - p2Pos).Magnitude
                    tracer.CFrame = CFrame.new(p1Pos, p2Pos) * CFrame.new(0, 0, -distance / 2)
                    tracer.Size = Vector3.new(0.1, 0.1, distance)
                end
            else
                -- Kapatıldığında temizle
                local hl = sg:FindFirstChild(hlName); if hl then hl:Destroy() end
                if char and char:FindFirstChild(infoName) then char[infoName]:Destroy() end
                local tracer = workspace:FindFirstChild(tracerName); if tracer then tracer:Destroy() end
            end
        end
    end
end)

local airP = Instance.new("Part"); airP.Size = Vector3.new(12,1,12); airP.Transparency = 1; airP.Anchored = true
RunService.Stepped:Connect(function()
    if noclip and player.Character then for _,v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if airwalk and player.Character:FindFirstChild("HumanoidRootPart") then
        airP.Parent = workspace; airP.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position.X, currentHeight-3.5, player.Character.HumanoidRootPart.Position.Z)
    else airP.Parent = nil end
end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.V then player.Character.HumanoidRootPart.CFrame *= CFrame.new(0,0,-12) end end)
UserInputService.JumpRequest:Connect(function() if infjump then player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
