local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Настройки
_G.Wallbang, _G.Hitbox, _G.Esp, _G.SilentAim, _G.Aimbot, _G.SpeedHack = false, false, false, false, false, false
_G.FOV = 80
_G.MaxDistance = 300
_G.SpeedValue = 0.28 -- Значение для скорости x1.5 (безопасно)

-- 1. ГРАФИКА
local VisualGui = Instance.new("ScreenGui", game.CoreGui)
VisualGui.IgnoreGuiInset = true

local FOVFrame = Instance.new("Frame", VisualGui)
FOVFrame.BackgroundTransparency, FOVFrame.AnchorPoint = 1, Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
local StrokeFOV = Instance.new("UIStroke", FOVFrame)
StrokeFOV.Color, StrokeFOV.Thickness = Color3.new(1,1,1), 1
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

local Snapline = Drawing.new("Line")
Snapline.Thickness, Snapline.Color, Snapline.Visible = 1.5, Color3.new(0, 1, 0), false

-- 2. ИНТЕРФЕЙС (Full RGB Border)
local MainGui = Instance.new("ScreenGui", game.CoreGui)

local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size, ToggleBtn.Position, ToggleBtn.BackgroundColor3 = UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0.5, 0), Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local ButtonStroke = Instance.new("UIStroke", ToggleBtn)
ButtonStroke.Thickness = 2

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.Visible = UDim2.new(0, 280, 0, 200), UDim2.new(0.5, -140, 0.4, -100), Color3.fromRGB(15, 15, 15), true
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
local Title = Instance.new("TextLabel", MainFrame)
Title.Size, Title.BackgroundColor3, Title.Text = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), "ARTHURIO HUB"
Instance.new("UICorner", Title)

-- RGB ЦИКЛ
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    MainStroke.Color, ButtonStroke.Color, Title.TextColor3 = color, color, color
    FOVFrame.Visible, FOVFrame.Size = _G.SilentAim or _G.Aimbot, UDim2.new(0, _G.FOV * 2, 0, _G.FOV * 2)
    ToggleBtn.Text = MainFrame.Visible and "CLOSE" or "OPEN"
end)

local Container = Instance.new("Frame", MainFrame)
Container.Size, Container.Position, Container.BackgroundTransparency = UDim2.new(1, -10, 1, -35), UDim2.new(0, 5, 0, 30), 1
Instance.new("UIGridLayout", Container).CellSize = UDim2.new(0, 130, 0, 35)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function AddToggle(text, callback)
    local btn = Instance.new("TextButton", Container)
    btn.BackgroundColor3, btn.Text, btn.TextColor3 = Color3.fromRGB(35, 35, 35), text, Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.BackgroundColor3 = enabled and Color3.fromRGB(30, 60, 45) or Color3.fromRGB(35, 35, 35)
        callback(enabled)
    end)
end

AddToggle("Silent Aim", function(s) _G.SilentAim = s end)
AddToggle("Hard AimLock", function(s) _G.Aimbot = s end)
AddToggle("Full ESP", function(s) _G.Esp = s end)
AddToggle("Hitbox x15", function(s) _G.Hitbox = s end)
AddToggle("Wallbang", function(s) _G.Wallbang = s end)
AddToggle("Safe Speed x1.5", function(s) _G.SpeedHack = s end)

-- 3. ЛОГИКА ESP (С ПОЛНОЙ ОЧИСТКОЙ)
local visuals = {}
local function removeVisuals(player)
    if visuals[player] then
        visuals[player].Box:Remove(); visuals[player].HP:Remove(); visuals[player].Text:Remove(); visuals[player] = nil
    end
end

local function updateEsp()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not visuals[p] then
                visuals[p] = {Box = Drawing.new("Square"), HP = Drawing.new("Line"), Text = Drawing.new("Text")}
                visuals[p].Box.Thickness, visuals[p].Box.Filled, visuals[p].Box.Color = 1, false, Color3.new(1,0,0)
                visuals[p].HP.Thickness, visuals[p].Text.Size = 2, 10
                visuals[p].Text.Center, visuals[p].Text.Outline, visuals[p].Text.Color = true, true, Color3.new(1,1,1)
            end
            local v, char = visuals[p], p.Character
            if _G.Esp and char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local hrp, hum = char.HumanoidRootPart, char.Humanoid
                local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                if on then
                    local sX, sY = 2000/pos.Z, 3000/pos.Z
                    v.Box.Size, v.Box.Position, v.Box.Visible = Vector2.new(sX, sY), Vector2.new(pos.X-sX/2, pos.Y-sY/2), true
                    v.HP.From, v.HP.To = Vector2.new(pos.X-sX/2-4, pos.Y+sY/2), Vector2.new(pos.X-sX/2-4, pos.Y+sY/2-(sY*(hum.Health/hum.MaxHealth)))
                    v.HP.Color, v.HP.Visible = Color3.fromHSV(hum.Health/hum.MaxHealth*0.3, 1, 1), true
                    v.Text.Position, v.Text.Text, v.Text.Visible = Vector2.new(pos.X, pos.Y+sY/2+2), p.Name.." ["..math.floor(pos.Z).."m]", true
                else v.Box.Visible, v.HP.Visible, v.Text.Visible = false, false, false end
            else v.Box.Visible, v.HP.Visible, v.Text.Visible = false, false, false end
        end
    end
end
Players.PlayerRemoving:Connect(removeVisuals)

-- 4. ОБНОВЛЕНИЕ КАДРА
RunService.RenderStepped:Connect(function()
    updateEsp()
    -- Safe Speed (CFrame)
    if _G.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local root, hum = LocalPlayer.Character.HumanoidRootPart, LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * _G.SpeedValue) end
    end
    -- Aim Logic
    local target, d = nil, _G.FOV; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            if (head.Position - LocalPlayer.Character.Head.Position).Magnitude <= _G.MaxDistance then
                local pos, on = Camera:WorldToViewportPoint(head.Position)
                if on then
                    local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if m < d then target = head; d = m end
                end
            end
        end
    end
    if target and (_G.SilentAim or _G.Aimbot) then
        local p = Camera:WorldToViewportPoint(target.Position)
        Snapline.From, Snapline.To, Snapline.Visible = center, Vector2.new(p.X, p.Y), true
    else Snapline.Visible = false end
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then p.Character.Head.Size, p.Character.Head.Transparency, p.Character.Head.CanCollide = Vector3.new(15,15,15), 1, false end end
    end
end)

-- 5. AIM-ON-FIRE
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        if _G.Aimbot or _G.SilentAim then
            local target = nil; local d = _G.FOV; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                    local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if on then
                        local m = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if m < d then target = p.Character.Head; d = m end
                    end
                end
            end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
        end
    end
end)

-- 6. WALLBANG
workspace.ChildAdded:Connect(function(child)
    if _G.Wallbang and child:IsA("BasePart") then
        task.wait()
        if (child.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 20 then
            local conn; conn = RunService.Stepped:Connect(function() if child and child.Parent then child.CanCollide = false else conn:Disconnect() end end)
        end
    end
end)
