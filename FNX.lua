--==================================================
-- FNX HUD | Premium - COMMERCIAL RELEASE VERSION
--==================================================

-- 1. PREVENT DOUBLE EXECUTION
if getgenv().FNX_Loaded then
    if _G.XCHudCleanup then pcall(_G.XCHudCleanup) end
end
getgenv().FNX_Loaded = true

local connections = {}
local drawings = {}

-- Service References
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = workspace
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- Backup Lighting
local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness
local originalGlobalShadows = Lighting.GlobalShadows

-- Config Folder Setup
if makefolder and not isfolder("XCHudConfig") then
    pcall(makefolder, "XCHudConfig")
end

-- Cleanup Function
_G.XCHudCleanup = function()
    getgenv().FNX_Loaded = nil
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(connections)

    for _, drw in pairs(drawings) do
        pcall(function() 
            if drw.Remove then drw:Remove() elseif drw.Destroy then drw:Destroy() end 
        end)
    end
    table.clear(drawings)

    Lighting.Ambient = originalAmbient
    Lighting.Brightness = originalBrightness
    Lighting.GlobalShadows = originalGlobalShadows
    
    if RunService.Set3dRenderingEnabled then
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("ProHighlight")
            if hl then hl:Destroy() end
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root and root:GetAttribute("OriginalSize") then
                root.Size = root:GetAttribute("OriginalSize")
                root.Transparency = 1
            end
        end
    end
end

--==================================================
-- 2. NOTIFICATION SYSTEM (BOTTOM RIGHT MODIFIED)
--==================================================
local function showNotify(title, text, imageId)
    task.spawn(function()
        pcall(function()
            local ParentGui = LocalPlayer:WaitForChild("PlayerGui", 5)
            if not ParentGui then return end
            
            local oldGui = ParentGui:FindFirstChild("XC_Notification")
            if oldGui then oldGui:Destroy() end

            local gui = Instance.new("ScreenGui")
            gui.Name = "XC_Notification"
            gui.DisplayOrder = 9999999
            gui.ResetOnSpawn = false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromOffset(260, 60)
            frame.AnchorPoint = Vector2.new(1, 1) -- จุดอ้างอิงมุมขวาล่าง
            frame.Position = UDim2.new(1, 300, 1, -20) -- เริ่มต้นซ่อนอยู่นอกจอทางขวา
            frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            frame.BorderSizePixel = 0
            frame.ZIndex = 100
            frame.Parent = gui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = frame

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(40, 40, 40)
            stroke.Thickness = 1.5
            stroke.Parent = frame

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.fromOffset(36, 36)
            img.Position = UDim2.fromOffset(12, 12)
            img.BackgroundTransparency = 1
            img.Image = imageId or "rbxassetid://76267707023968"
            img.ZIndex = 101
            img.Parent = frame

            local tTitle = Instance.new("TextLabel")
            tTitle.Size = UDim2.new(1, -60, 0, 18)
            tTitle.Position = UDim2.fromOffset(56, 10)
            tTitle.BackgroundTransparency = 1
            tTitle.Text = title or "FNX Hud"
            tTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            tTitle.TextSize = 14
            tTitle.Font = Enum.Font.SourceSansBold
            tTitle.TextXAlignment = Enum.TextXAlignment.Left
            tTitle.ZIndex = 101
            tTitle.Parent = frame

            local tText = Instance.new("TextLabel")
            tText.Size = UDim2.new(1, -60, 0, 18)
            tText.Position = UDim2.fromOffset(56, 28)
            tText.BackgroundTransparency = 1
            tText.Text = text or ""
            tText.TextColor3 = Color3.fromRGB(0, 255, 150)
            tText.TextSize = 12
            tText.Font = Enum.Font.SourceSans
            tText.TextXAlignment = Enum.TextXAlignment.Left
            tText.ZIndex = 101
            tText.Parent = frame

            gui.Parent = ParentGui

            -- สไลด์เข้ามาที่มุมขวาล่าง
            local tweenIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -20, 1, -20)
            })
            tweenIn:Play()
            tweenIn.Completed:Wait()

            task.wait(2)

            -- สไลด์กลับออกไปทางขวา
            local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 300, 1, -20)
            })
            tweenOut:Play()
            tweenOut.Completed:Wait()

            gui:Destroy()
        end)
    end)
end

--==================================================
-- 3. WINDUI INITIALIZATION & THEME
--==================================================
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[FNX Hud] Failed to load UI Library!")
    return
end

WindUI:AddTheme({
    Name = "PureBlack",
    Accent = Color3.fromRGB(0, 0, 0),
    Outline = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255),
    PlaceholderText = Color3.fromRGB(150, 150, 150),
    Background = Color3.fromRGB(15, 15, 15),
    Item = Color3.fromRGB(25, 25, 25)
})

local Window = WindUI:CreateWindow({
    Title = "FNX Hud | Ultimate",
    Icon = "rbxassetid://76267707023968",
    Author = "by Start",
    Folder = "XCHudConfig",
    Size = UDim2.fromOffset(620, 480),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 600),
    ToggleKey = Enum.KeyCode.LeftShift,
    Transparent = true,
    Theme = "PureBlack",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false }
})

--==================================================
-- 4. GLOBAL CONFIG & STATES
--==================================================
_G.SilentAimEnabled = false
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.AimPart = "Head"
_G.FOV_Radius = 150
_G.FOV_Visible = false
_G.TracerEnabled = false
_G.EspEnabled = false
_G.TeamCheck = true
_G.WallCheck = true
_G.MaxDistance = 300
_G.HitboxEnabled = false
_G.HitboxSize = 3
_G.FullbrightEnabled = false
_G.InfJump = false
_G.Noclip = false
_G.AntiAFK = true
_G.AutoTranslateChat = false
_G.TargetLanguage = "th"
_G.KillAuraEnabled = false
_G.KillAuraRange = 15
_G.KillAuraTargetTeam = false
_G.CameraFOV = 70
_G.MaxZoomDistance = 128

local currentTarget = nil
local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
wallCheckParams.IgnoreWater = true

local hasDrawing = typeof(Drawing) == "table" and typeof(Drawing.new) == "function"

--==================================================
-- 5. DRAWING OVERLAYS SETUP
--==================================================
local Sides = 16
local fovLines = {}
local HeadSides = 12
local headRingLines = {}
local TracerLine

if hasDrawing then
    pcall(function()
        for i = 1, Sides do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 2
            line.Transparency = 1
            table.insert(fovLines, line)
            table.insert(drawings, line)
        end

        for i = 1, HeadSides do
            local line = Drawing.new("Line")
            line.Visible = false
            line.Thickness = 2
            line.Transparency = 1
            table.insert(headRingLines, line)
            table.insert(drawings, line)
        end

        TracerLine = Drawing.new("Line")
        TracerLine.Visible = false
        TracerLine.Thickness = 1.5
        TracerLine.Transparency = 1
        table.insert(drawings, TracerLine)
    end)
end

--==================================================
-- 6. HELPER FUNCTIONS
--==================================================
local function isTargetValid(part)
    if not part or not part.Parent then return false end
    local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isTeammate(player)
    if not _G.TeamCheck or not player then return false end
    return player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

local function isVisible(targetPart)
    if not _G.WallCheck then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return true end
    
    local origin = LocalPlayer.Character.Head.Position
    local direction = targetPart.Position - origin
    
    local ignoreList = {LocalPlayer.Character}
    if targetPart.Parent then table.insert(ignoreList, targetPart.Parent) end
    wallCheckParams.FilterDescendantsInstances = ignoreList
    
    local result = Workspace:Raycast(origin, direction, wallCheckParams)
    return result == nil
end

local function getSilentTarget()
    if not _G.SilentAimEnabled then return nil end
    local dist = math.huge
    local closest = nil
    local center = Camera.ViewportSize / 2
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return nil end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and not isTeammate(v) then
            local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = v.Character:FindFirstChild(_G.AimPart) or v.Character:FindFirstChild("Head")
                if part then
                    local distToPlayer = (part.Position - localRoot.Position).Magnitude
                    if distToPlayer <= _G.MaxDistance then
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis and isVisible(part) then
                            local screenPos = Vector2.new(pos.X, pos.Y)
                            local mag = (screenPos - center).Magnitude
                            if mag <= _G.FOV_Radius and mag < dist then
                                dist = mag
                                closest = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function translateText(str, targetLang)
    if not str or str == "" then return str end
    local success, result = pcall(function()
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=" 
                    .. targetLang .. "&dt=t&q=" .. HttpService:UrlEncode(str)
        local response = game:HttpGet(url)
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
            return decoded[1][1][1]
        end
    end)
    return success and result or str
end

--==================================================
-- 7. HOOKS & SYSTEM EVENTS
--==================================================
if hookmetamethod and getnamecallmethod and checkcaller then
    pcall(function()
        local oldnc
        oldnc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if not checkcaller() and _G.SilentAimEnabled and currentTarget and self == Workspace then
                if method == "Raycast" and args[1] and args[2] then
                    local dir = currentTarget.Position - args[1]
                    if dir.Magnitude > 0 then
                        args[2] = dir.Unit * args[2].Magnitude
                        return oldnc(self, unpack(args))
                    end
                elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhiteList") and args[1] then
                    local dir = currentTarget.Position - args[1].Origin
                    if dir.Magnitude > 0 then
                        args[1] = Ray.new(args[1].Origin, dir.Unit * args[1].Direction.Magnitude)
                        return oldnc(self, unpack(args))
                    end
                end
            end
            return oldnc(self, ...)
        end))
    end)
end

-- Anti AFK
table.insert(connections, LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end))

-- Chat Translator
task.spawn(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.OnIncomingMessage = function(message)
            if _G.AutoTranslateChat and message.TextSource then
                local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
                if sender and sender ~= LocalPlayer then
                    local translated = translateText(message.Text, _G.TargetLanguage)
                    message.Text = "[" .. sender.DisplayName .. "]: " .. translated
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(connections, p.Chatted:Connect(function(msg)
                    if _G.AutoTranslateChat then
                        local translated = translateText(msg, _G.TargetLanguage)
                        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                            Text = "[Translated] " .. p.DisplayName .. ": " .. translated,
                            Color = Color3.fromRGB(0, 255, 150),
                            Font = Enum.Font.SourceSansBold,
                        })
                    end
                end))
            end
        end
    end
end)

-- ESP Setup
local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        if not char then return end
        local hl = char:FindFirstChild("ProHighlight") or Instance.new("Highlight")
        hl.Name = "ProHighlight"
        hl.Adornee = char
        hl.FillTransparency = 0.5
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(0, 0, 0)
        hl.Enabled = false
        hl.Parent = char
    end
    if player.Character then setupChar(player.Character) end
    table.insert(connections, player.CharacterAdded:Connect(setupChar))
end

for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
table.insert(connections, Players.PlayerAdded:Connect(applyESP))

--==================================================
-- 8. MAIN RENDER LOOP & COMBAT LOGIC
--==================================================
local hue = 0
local ringAngle = 0
local targetCheckTimer = 0
local slowUpdateTimer = 0

local renderConn = RunService.RenderStepped:Connect(function(deltaTime)
    pcall(function()
        targetCheckTimer = targetCheckTimer + deltaTime
        if targetCheckTimer >= 0.03 then
            targetCheckTimer = 0
            currentTarget = getSilentTarget()
        end
        
        if not isTargetValid(currentTarget) then
            currentTarget = nil
        end

        slowUpdateTimer = slowUpdateTimer + deltaTime
        if slowUpdateTimer >= 0.1 then
            slowUpdateTimer = 0

            if _G.FullbrightEnabled then
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.Brightness = 2
                Lighting.GlobalShadows = false
            else
                Lighting.Ambient = originalAmbient
                Lighting.Brightness = originalBrightness
                Lighting.GlobalShadows = originalGlobalShadows
            end

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not isTeammate(p) then
                        local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            if not rootPart:GetAttribute("OriginalSize") then
                                rootPart:SetAttribute("OriginalSize", rootPart.Size)
                            end

                            if _G.HitboxEnabled then
                                rootPart.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                                rootPart.Transparency = 0.7
                            else
                                local orig = rootPart:GetAttribute("OriginalSize")
                                rootPart.Size = orig or Vector3.new(2, 2, 1)
                                rootPart.Transparency = 1
                            end
                        end
                    end

                    local highlight = p.Character:FindFirstChild("ProHighlight")
                    if highlight then
                        highlight.Enabled = _G.EspEnabled and not isTeammate(p)
                    end
                end
            end
        end

        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed ~= _G.WalkSpeed then hum.WalkSpeed = _G.WalkSpeed end
                if hum.UseJumpPower and hum.JumpPower ~= _G.JumpPower then hum.JumpPower = _G.JumpPower end
            end
        end

        if hasDrawing then
            local center = Camera.ViewportSize / 2
            
            if _G.FOV_Visible then
                hue = (hue + 0.005) % 1
                for i = 1, Sides do
                    local a1 = ((i - 1) / Sides) * math.pi * 2
                    local a2 = (i / Sides) * math.pi * 2
                    local p1 = center + Vector2.new(math.cos(a1) * _G.FOV_Radius, math.sin(a1) * _G.FOV_Radius)
                    local p2 = center + Vector2.new(math.cos(a2) * _G.FOV_Radius, math.sin(a2) * _G.FOV_Radius)
                    local line = fovLines[i]
                    if line then
                        line.Visible = true
                        line.From = p1
                        line.To = p2
                        line.Color = Color3.fromHSV((hue + i / Sides) % 1, 1, 1)
                    end
                end
            else
                for _, line in pairs(fovLines) do line.Visible = false end
            end

            if currentTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                ringAngle = ringAngle + 0.15
                local headPart = currentTarget.Parent:FindFirstChild("Head") or currentTarget
                local headPos = headPart.Position
                local radius = 1.15
                
                local lookVector = (LocalPlayer.Character.Head.Position - headPos).Unit
                local rightVector = lookVector:Cross(Vector3.new(0, 1, 0))
                rightVector = rightVector.Magnitude == 0 and Vector3.new(1, 0, 0) or rightVector.Unit
                local upVector = rightVector:Cross(lookVector).Unit

                for i = 1, HeadSides do
                    local a1 = ((i - 1) / HeadSides) * math.pi * 2 + ringAngle
                    local a2 = (i / HeadSides) * math.pi * 2 + ringAngle
                    
                    local p3D1 = headPos + (rightVector * math.cos(a1) + upVector * math.sin(a1)) * radius + (lookVector * 0.5)
                    local p3D2 = headPos + (rightVector * math.cos(a2) + upVector * math.sin(a2)) * radius + (lookVector * 0.5)
                    
                    local screen1, vis1 = Camera:WorldToViewportPoint(p3D1)
                    local screen2, vis2 = Camera:WorldToViewportPoint(p3D2)
                    
                    local rLine = headRingLines[i]
                    if rLine then
                        if vis1 and vis2 then
                            rLine.Visible = true
                            rLine.From = Vector2.new(screen1.X, screen1.Y)
                            rLine.To = Vector2.new(screen2.X, screen2.Y)
                            rLine.Color = Color3.fromHSV(hue, 1, 1)
                        else
                            rLine.Visible = false
                        end
                    end
                end
            else
                for _, rLine in pairs(headRingLines) do rLine.Visible = false end
            end

            if _G.TracerEnabled and currentTarget then
                local pos, vis = Camera:WorldToViewportPoint(currentTarget.Position)
                if vis then
                    TracerLine.Visible = true
                    TracerLine.From = center
                    TracerLine.To = Vector2.new(pos.X, pos.Y)
                    TracerLine.Color = Color3.fromHSV(hue, 1, 1)
                else
                    TracerLine.Visible = false
                end
            else
                if TracerLine then TracerLine.Visible = false end
            end
        end
    end)
end)
table.insert(connections, renderConn)

-- Kill Aura Loop
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if _G.KillAuraEnabled and LocalPlayer.Character then
                local myChar = LocalPlayer.Character
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local tool = myChar:FindFirstChildOfClass("Tool")
                
                if myRoot and tool then
                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart")
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        local isEnemy = _G.KillAuraTargetTeam or not isTeammate(p)
                        if p ~= LocalPlayer and p.Character and isEnemy then
                            local targetHum = p.Character:FindFirstChildOfClass("Humanoid")
                            local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                            
                            if targetHum and targetHum.Health > 0 and targetRoot then
                                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                                if dist <= (_G.KillAuraRange or 15) then
                                    tool:Activate()
                                    if handle and firetouchinterest then
                                        firetouchinterest(handle, targetRoot, 0)
                                        task.wait()
                                        firetouchinterest(handle, targetRoot, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Jump & Noclip Connections
table.insert(connections, UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end))

table.insert(connections, RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end))

-- Respawn Connection
table.insert(connections, LocalPlayer.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 10)
    if hum then
        task.wait(0.2)
        hum.WalkSpeed = _G.WalkSpeed
        if hum.UseJumpPower then hum.JumpPower = _G.JumpPower end
    end
    task.wait(0.3)
    if _G.CameraFOV then workspace.CurrentCamera.FieldOfView = _G.CameraFOV end
    if _G.MaxZoomDistance then LocalPlayer.MaxZoomDistance = _G.MaxZoomDistance end
end))

--==================================================
-- 9. UI TABS SETUP
--==================================================

-- TAB 1: MAIN
local MainTab = Window:Tab({ Title = "Main", Icon = "settings" })
MainTab:Section({ Title = "Targeting Rules" })
MainTab:Toggle({
    Title = "Team Check",
    Default = true,
    Callback = function(Value) _G.TeamCheck = Value end,
})
MainTab:Toggle({
    Title = "Wall Check",
    Default = true,
    Callback = function(Value) _G.WallCheck = Value end,
})
MainTab:Slider({
    Title = "Max Distance",
    Step = 10,
    Value = { Min = 50, Max = 1000, Default = 300 },
    Callback = function(Value) _G.MaxDistance = Value end,
})

-- TAB 2: COMBAT
local CombatTab = Window:Tab({ Title = "Combat", Icon = "swords" })
CombatTab:Section({ Title = "Kill Aura System" })
CombatTab:Toggle({
    Title = "Enable Kill Aura",
    Default = false,
    Callback = function(Value) 
        _G.KillAuraEnabled = Value 
        showNotify("Combat", "Kill Aura: " .. (Value and "Enabled" or "Disabled"))
    end,
})
CombatTab:Slider({
    Title = "Aura Distance (ระยะฟัน)",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(Value) _G.KillAuraRange = Value end,
})
CombatTab:Toggle({
    Title = "Target Teammates (ตีเพื่อนในทีม)",
    Default = false,
    Callback = function(Value) _G.KillAuraTargetTeam = Value end,
})

-- TAB 3: SILENTAIM
local SilentAimTab = Window:Tab({ Title = "SilentAim", Icon = "sword" })
SilentAimTab:Section({ Title = "Silent Aim Control" })
SilentAimTab:Toggle({
    Title = "Enable SilentAim",
    Default = false,
    Callback = function(Value) 
        _G.SilentAimEnabled = Value 
        showNotify("SilentAim", "Status: " .. (Value and "Enabled" or "Disabled"))
    end,
})
SilentAimTab:Dropdown({
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head",
    Callback = function(Value) _G.AimPart = Value end,
})

-- TAB 4: FOV
local FOVTab = Window:Tab({ Title = "FOV", Icon = "circle" })
FOVTab:Section({ Title = "FOV Settings" })
FOVTab:Toggle({
    Title = "Show FOV Circle",
    Default = false,
    Callback = function(Value) _G.FOV_Visible = Value end,
})
FOVTab:Slider({
    Title = "FOV Radius",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 150 },
    Callback = function(Value) _G.FOV_Radius = Value end,
})

-- TAB 5: VISUALS
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
VisualsTab:Section({ Title = "ESP & Tracers" })
VisualsTab:Toggle({
    Title = "Enable ESP Highlight",
    Default = false,
    Callback = function(Value) 
        _G.EspEnabled = Value 
        showNotify("Visuals", "ESP Highlight: " .. (Value and "ON" or "OFF"))
    end,
})
VisualsTab:Toggle({
    Title = "Enable Target Tracer",
    Default = false,
    Callback = function(Value) _G.TracerEnabled = Value end,
})

-- TAB 6: MOVEMENT
local MoveTab = Window:Tab({ Title = "Movement", Icon = "zap" })
MoveTab:Section({ Title = "Movement Modifications" })
MoveTab:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 150, Default = 16 },
    Callback = function(Value) _G.WalkSpeed = Value end,
})
MoveTab:Slider({
    Title = "JumpPower",
    Step = 5,
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(Value) _G.JumpPower = Value end,
})
MoveTab:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value) _G.InfJump = Value end,
})
MoveTab:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(Value) _G.Noclip = Value end,
})

-- TAB 7: CAMERA
local CameraTab = Window:Tab({ Title = "Camera", Icon = "compass" })
CameraTab:Section({ Title = "Camera & Environment" })
CameraTab:Slider({
    Title = "Camera FOV",
    Step = 1,
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(Value) 
        _G.CameraFOV = Value
        workspace.CurrentCamera.FieldOfView = Value 
    end,
})
CameraTab:Slider({
    Title = "Max Zoom Distance",
    Step = 100,
    Value = { Min = 128, Max = 5000, Default = 128 },
    Callback = function(Value) 
        _G.MaxZoomDistance = Value
        LocalPlayer.MaxZoomDistance = Value 
    end,
})

-- TAB 8: TRANSLATOR
local TransTab = Window:Tab({ Title = "Translator", Icon = "globe" })
TransTab:Section({ Title = "Chat Translator" })
TransTab:Toggle({
    Title = "Auto Translate Chat",
    Default = false,
    Callback = function(Value) _G.AutoTranslateChat = Value end,
})
TransTab:Dropdown({
    Title = "Target Language",
    Values = {"Thai", "English"},
    Default = "Thai",
    Callback = function(Value)
        _G.TargetLanguage = (Value == "Thai") and "th" or "en"
    end,
})

-- TAB 9: FPS BOOST
local FPSTab = Window:Tab({ Title = "FPS Boost", Icon = "activity" })
FPSTab:Section({ Title = "Performance Boost" })
FPSTab:Button({
    Title = "Full FPS Boost",
    Callback = function()
        pcall(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            showNotify("FPS Boost", "Performance Mode Activated!")
        end)
    end,
})
FPSTab:Slider({
    Title = "Max FPS Cap",
    Step = 10,
    Value = { Min = 30, Max = 240, Default = 60 },
    Callback = function(Value)
        if setfpscap then pcall(setfpscap, Value) end
    end,
})
FPSTab:Toggle({
    Title = "Disable 3D Rendering",
    Default = false,
    Callback = function(Value)
        if RunService.Set3dRenderingEnabled then
            pcall(function() RunService:Set3dRenderingEnabled(not Value) end)
        end
    end,
})

-- TAB 10: SERVER & CONFIG
local ServerTab = Window:Tab({ Title = "Server & Config", Icon = "layers" })
ServerTab:Section({ Title = "Server Management" })
ServerTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})
ServerTab:Button({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
            for _, s in pairs(servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})
ServerTab:Toggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(Value) _G.AntiAFK = Value end,
})

ServerTab:Section({ Title = "Configuration" })
ServerTab:Button({
    Title = "Save Config",
    Callback = function()
        pcall(function()
            local configData = {
                WalkSpeed = _G.WalkSpeed,
                JumpPower = _G.JumpPower,
                FOV_Radius = _G.FOV_Radius,
                AimPart = _G.AimPart,
                TeamCheck = _G.TeamCheck,
                WallCheck = _G.WallCheck,
                EspEnabled = _G.EspEnabled,
                AutoTranslateChat = _G.AutoTranslateChat,
            }
            if writefile then
                writefile("XCHudConfig/XCHud_Config.json", HttpService:JSONEncode(configData))
                showNotify("Config", "Saved successfully!")
            end
        end)
    end,
})
ServerTab:Button({
    Title = "Load Config",
    Callback = function()
        pcall(function()
            if isfile and readfile and isfile("XCHudConfig/XCHud_Config.json") then
                local loadedData = HttpService:JSONDecode(readfile("XCHudConfig/XCHud_Config.json"))
                _G.WalkSpeed = loadedData.WalkSpeed or _G.WalkSpeed
                _G.JumpPower = loadedData.JumpPower or _G.JumpPower
                _G.FOV_Radius = loadedData.FOV_Radius or _G.FOV_Radius
                _G.AimPart = loadedData.AimPart or _G.AimPart
                _G.TeamCheck = loadedData.TeamCheck
                _G.WallCheck = loadedData.WallCheck
                _G.EspEnabled = loadedData.EspEnabled
                _G.AutoTranslateChat = loadedData.AutoTranslateChat
                showNotify("Config", "Loaded successfully!")
            end
        end)
    end,
})

--==================================================
-- 10. UI STYLING & FORCE BLACK BORDER
--==================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    
    local function applyBlack(v)
        if v:IsA("UIGradient") then
            v.Enabled = false
        elseif v:IsA("UIStroke") then
            v.Color = Color3.fromRGB(0, 0, 0)
        end
    end

    local function fixFNX()
        for _, desc in pairs(CoreGui:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text:find("FNX") then
                local scriptGui = desc:FindFirstAncestorOfClass("ScreenGui")
                if scriptGui then
                    scriptGui.ResetOnSpawn = false
                    for _, v in pairs(scriptGui:GetDescendants()) do
                        applyBlack(v)
                    end
                    
                    scriptGui.DescendantAdded:Connect(function(v)
                        task.defer(function() applyBlack(v) end)
                    end)
                    return true
                end
            end
        end
        return false
    end

    for i = 1, 15 do
        if fixFNX() then break end
        task.wait(0.3)
    end
end)

showNotify("FNX Hud", "Script loaded successfully!", "rbxassetid://76267707023968")
