local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Настройки
_G.Crosshair, _G.Hitbox, _G.Esp, _G.Aimbot, _G.SpeedHack, _G.FullBright = false, false, false, false, false, false
_G.FOV = 50 
_G.MaxDistance = 400
_G.SpeedValue = 0.18 

-- 1. ГРАФИКА
local VisualGui = Instance.new("ScreenGui", game.CoreGui)
VisualGui.IgnoreGuiInset = true

local FOVFrame = Instance.new("Frame", VisualGui)
FOVFrame.BackgroundTransparency, FOVFrame.AnchorPoint = 1, Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
local StrokeFOV = Instance.new("UIStroke", FOVFrame)
StrokeFOV.Color, StrokeFOV.Thickness = Color3.new(1,1,1), 1
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

local CrosshairLines = {}
for i = 1, 4 do
    local line = Drawing.new("Line")
    line.Thickness, line.Transparency = 2, 1
    CrosshairLines[i] = line
end

-- 2. ИНТЕРФЕЙС
local MainGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size, ToggleBtn.Position, ToggleBtn.BackgroundColor3 = UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0.5, 0), Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3, ToggleBtn.Draggable = Color3.new(1,1,1), true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local ButtonStroke = Instance.new("UIStroke", ToggleBtn)
ButtonStroke.Thickness = 2

local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.Visible = UDim2.new(0, 280, 0, 240), UDim2.new(0.5, -140, 0.4, -100), Color3.fromRGB(15, 15, 15), true
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
local Title = Instance.new("TextLabel", MainFrame)
Title.Size, Title.BackgroundColor3, Title.Text = UDim2.new(1, 0, 0, 25), Color3.fromRGB(25, 25, 25), "ARTHURIO HUB"
Instance.new("UICorner", Title)

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    MainStroke.Color, ButtonStroke.Color, Title.TextColor3 = color, color, color
    FOVFrame.Visible, FOVFrame.Size = _G.Aimbot, UDim2.new(0, _G.FOV * 2, 0, _G.FOV * 2)
    ToggleBtn.Text = MainFrame.Visible and "CLOSE" or "OPEN"
    if _G.FullBright then Lighting.ClockTime = 12 end

    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local rotation = tick() * 5
    for i, line in pairs(CrosshairLines) do
        if _G.Crosshair then
            local angle = rotation + (i * (math.pi/2))
            line.From = center + (Vector2.new(math.cos(angle), math.sin(angle)) * 5)
            line.To = center + (Vector2.new(math.cos(angle), math.sin(angle)) * 15)
            line.Color, line.Visible = color, true
        else line.Visible = false end
    end
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

AddToggle("Crosshair", function(s) _G.Crosshair = s end)
AddToggle("Aimbot", function(s) _G.Aimbot = s end)
AddToggle("Full ESP", function(s) _G.Esp = s end)
AddToggle("Hitbox x15", function(s) _G.Hitbox = s end)
AddToggle("Safe Speed x1.3", function(s) _G.SpeedHack = s end)
AddToggle("Full Day", function(s) _G.FullBright = s end)

-- 3. ESP (ТВОЙ ОРИГИНАЛ)
local visuals = {}
local function removeVisuals(p)
    if visuals[p] then
        visuals[p].Box:Remove(); visuals[p].HP:Remove(); visuals[p].Text:Remove(); visuals[p] = nil
    end
end

local function updateEsp()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not visuals[p] then
                visuals[p] = {Box = Drawing.new("Square"), HP = Drawing.new("Line"), Text = Drawing.new("Text")}
                visuals[p].Box.Thickness, visuals[p].Box.Filled = 1, false
                visuals[p].Box.Color = Color3.new(1,0,0)
                visuals[p].HP.Thickness, visuals[p].Text.Size = 2, 10
                visuals[p].Text.Center, visuals[p].Text.Outline, visuals[p].Text.Color = true, true, Color3.new(1,1,1)
            end
            local v, char = visuals[p], p.Character
            if _G.Esp and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
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

RunService.RenderStepped:Connect(function()
    updateEsp()
    if _G.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local root, hum = LocalPlayer.Character.HumanoidRootPart, LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * _G.SpeedValue) end
    end
    -- Aim Logic
    local target = nil; local d = _G.FOV; local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
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
    local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or #UserInputService:GetNavigationGamepads() > 0
    if target and _G.Aimbot and isShooting then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    if _G.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then 
                p.Character.Head.Size, p.Character.Head.Transparency, p.Character.Head.CanCollide = Vector3.new(15,15,15), 1, false 
            end 
        end
    end
end)
