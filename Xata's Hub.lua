local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local flying = false
local bodyGyro, bodyVelocity
local themeColor = Color3.fromRGB(255, 204, 0)
local flySpeed = 80

local r, g, b = 255/255, 204/255, 0/255

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlightMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local function roundify(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 300)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
-- цвет будет установлен позже через updateBorderColor()
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
roundify(mainFrame, 8)

local crownButton = Instance.new("TextButton")
crownButton.Size = UDim2.new(0, 40, 0, 40)
crownButton.Position = UDim2.new(0.5, -20, 0.5, -20)
crownButton.Text = "👑"
crownButton.TextColor3 = Color3.new(1, 1, 1)
crownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
crownButton.BorderSizePixel = 0
crownButton.Visible = false
crownButton.AutoButtonColor = true
crownButton.Parent = screenGui
roundify(crownButton, 20)

crownButton.MouseButton1Click:Connect(function()
	toggleMenu()
end)

local border = Instance.new("UIStroke")
border.Thickness = 2
border.Color = themeColor
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = mainFrame

-- Перетаскиваемое окно
local dragToggle = false
local dragInput, dragStart, startPos
-- Перетаскивание меню (работает только при зажатии фона)
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if input.Target:IsDescendantOf(mainFrame) and not input.Target:IsDescendantOf(settingsTab) and not input.Target:IsA("TextButton") then
			dragToggle = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragToggle then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Левый сайдбар
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 120, 1, 0)
leftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
leftPanel.BorderSizePixel = 0
leftPanel.Parent = mainFrame
roundify(leftPanel, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "👑 Xata's Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = leftPanel

-- Кнопки вкладок
local flyTabButton = Instance.new("TextButton")
flyTabButton.Size = UDim2.new(1, 0, 0, 30)
flyTabButton.Position = UDim2.new(0, 0, 0, 50)
flyTabButton.Text = "Fly"
flyTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
flyTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyTabButton.Font = Enum.Font.Gotham
flyTabButton.TextSize = 14
flyTabButton.Parent = leftPanel
roundify(flyTabButton, 6)

local settingsTabButton = Instance.new("TextButton")
settingsTabButton.Size = UDim2.new(1, 0, 0, 30)
settingsTabButton.Position = UDim2.new(0, 0, 0, 90)
settingsTabButton.Text = "Settings"
settingsTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTabButton.Font = Enum.Font.Gotham
settingsTabButton.TextSize = 14
settingsTabButton.Parent = leftPanel
roundify(settingsTabButton, 6)

-- Правая панель
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(1, -120, 1, 0)
rightPanel.Position = UDim2.new(0, 120, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
rightPanel.BorderSizePixel = 0
rightPanel.Parent = mainFrame
roundify(rightPanel, 8)

local flyTab = Instance.new("Frame")
flyTab.Size = UDim2.new(1, 0, 1, 0)
flyTab.BackgroundTransparency = 1
flyTab.Visible = true
flyTab.Name = "FlyTab"
flyTab.Parent = rightPanel

local settingsTab = Instance.new("Frame")
settingsTab.Size = UDim2.new(1, 0, 1, 0)
settingsTab.BackgroundTransparency = 1
settingsTab.Visible = false
settingsTab.Name = "SettingsTab"
settingsTab.Parent = rightPanel

flyTabButton.MouseButton1Click:Connect(function()
	flyTab.Visible = true
	settingsTab.Visible = false
end)
settingsTabButton.MouseButton1Click:Connect(function()
	flyTab.Visible = false
	settingsTab.Visible = true
end)

-- Кнопка включения полёта
local walkToggle = Instance.new("TextButton")
walkToggle.Size = UDim2.new(0, 160, 0, 32)
walkToggle.Position = UDim2.new(0, 200, 0, 20)
walkToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
walkToggle.Text = "Скорость: OFF"
walkToggle.TextScaled = false
walkToggle.Font = Enum.Font.GothamBold
walkToggle.TextSize = 16
walkToggle.TextColor3 = Color3.new(1, 1, 1)
walkToggle.Parent = flyTab
roundify(walkToggle, 6)
local walkToggleStroke = Instance.new("UIStroke", walkToggle)
walkToggleStroke.Color = themeColor
walkToggleStroke.Thickness = 2

local walkLabel = Instance.new("TextLabel")
walkLabel.Size = UDim2.new(0, 200, 0, 20)
walkLabel.Position = UDim2.new(0, 200, 0, 60)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "Скорость ходьбы"
walkLabel.TextColor3 = Color3.new(1, 1, 1)
walkLabel.Font = Enum.Font.Gotham
walkLabel.TextSize = 14
walkLabel.TextXAlignment = Enum.TextXAlignment.Left
walkLabel.Parent = flyTab

local walkSlider = Instance.new("TextButton")
walkSlider.Size = UDim2.new(0, 160, 0, 14)
walkSlider.Position = UDim2.new(0, 200, 0, 82)
walkSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
walkSlider.Text = ""
walkSlider.AutoButtonColor = false
walkSlider.Parent = flyTab
roundify(walkSlider, 6)

local walkFill = Instance.new("Frame")
walkFill.Size = UDim2.new(0.4, 0, 1, 0)
walkFill.BackgroundColor3 = themeColor
walkFill.BorderSizePixel = 0
walkFill.Parent = walkSlider
roundify(walkFill, 6)

local walkEnabled = false
local walkSpeed = 16

walkToggle.MouseButton1Click:Connect(function()
	walkEnabled = not walkEnabled
	walkToggle.Text = walkEnabled and "Скорость: ON" or "Скорость: OFF"
	if walkEnabled then
		local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then humanoid.WalkSpeed = walkSpeed end
	else
		local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
		if humanoid then humanoid.WalkSpeed = 16 end
	end
end)

walkSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = input.Position.X - walkSlider.AbsolutePosition.X
		local percent = math.clamp(pos / walkSlider.AbsoluteSize.X, 0, 1)
		walkFill.Size = UDim2.new(percent, 0, 1, 0)
		walkSpeed = math.floor(percent * 100)
		if walkEnabled then
			local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
			if humanoid then humanoid.WalkSpeed = walkSpeed end
		end
	end
end)

local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(0, 160, 0, 32)
flyToggle.Position = UDim2.new(0, 20, 0, 20)
flyToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
flyToggle.Text = "Полёт: OFF"
flyToggle.TextScaled = false
flyToggle.Font = Enum.Font.GothamBold
flyToggle.TextSize = 16
flyToggle.TextColor3 = Color3.new(1, 1, 1)
flyToggle.Parent = flyTab
roundify(flyToggle, 6)
local flyToggleStroke = Instance.new("UIStroke", flyToggle)
flyToggleStroke.Color = themeColor
flyToggleStroke.Thickness = 2

-- Кнопка бесконечного прыжка
local infiniteJumpEnabled = false

local infiniteJumpCheckbox = Instance.new("TextButton")
infiniteJumpCheckbox.Size = UDim2.new(0, 20, 0, 20)
infiniteJumpCheckbox.Position = UDim2.new(0, 20, 0, 110)
infiniteJumpCheckbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infiniteJumpCheckbox.Text = infiniteJumpEnabled and "✔" or ""
infiniteJumpCheckbox.TextColor3 = Color3.new(1, 1, 1)
infiniteJumpCheckbox.Font = Enum.Font.GothamBold
infiniteJumpCheckbox.TextSize = 16
infiniteJumpCheckbox.Parent = flyTab
roundify(infiniteJumpCheckbox, 4)
local infiniteJumpStroke = Instance.new("UIStroke", infiniteJumpCheckbox)
infiniteJumpStroke.Color = themeColor
infiniteJumpStroke.Thickness = 2

local infiniteJumpLabel = Instance.new("TextLabel")
infiniteJumpLabel.Size = UDim2.new(0, 200, 0, 20)
infiniteJumpLabel.Position = UDim2.new(0, 48, 0, 110)
infiniteJumpLabel.BackgroundTransparency = 1
infiniteJumpLabel.Text = "Бесконечный прыжок"
infiniteJumpLabel.TextColor3 = Color3.new(1, 1, 1)
infiniteJumpLabel.Font = Enum.Font.Gotham
infiniteJumpLabel.TextSize = 14
infiniteJumpLabel.TextXAlignment = Enum.TextXAlignment.Left
infiniteJumpLabel.Parent = flyTab

infiniteJumpCheckbox.MouseButton1Click:Connect(function()
	infiniteJumpEnabled = not infiniteJumpEnabled
	infiniteJumpCheckbox.Text = infiniteJumpEnabled and "✔" or ""
end)

UIS.JumpRequest:Connect(function()
	if infiniteJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Слайдер скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 200, 0, 20)
speedLabel.Position = UDim2.new(0, 20, 0, 60)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.Text = "Скорость полёта: 80"
speedLabel.Parent = flyTab

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0, 160, 0, 14)
speedSlider.Position = UDim2.new(0, 20, 0, 82)
speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedSlider.Text = ""
speedSlider.AutoButtonColor = false
speedSlider.Parent = flyTab
roundify(speedSlider, 6)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.4, 0, 1, 0)
sliderFill.BackgroundColor3 = themeColor
sliderFill.BorderSizePixel = 0
sliderFill.Parent = speedSlider
roundify(sliderFill, 6)

-- Включение полёта
local function toggleFly()
	flying = not flying
	flyToggle.Text = flying and "Полёт: ON" or "Полёт: OFF"

	if flying then
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.Parent = hrp

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Parent = hrp
	else
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVelocity then bodyVelocity:Destroy() end
	end
end

flyToggle.MouseButton1Click:Connect(toggleFly)

-- Изменение скорости
local dragging = false
speedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local pos = input.Position.X - speedSlider.AbsolutePosition.X
		local percent = math.clamp(pos / speedSlider.AbsoluteSize.X, 0, 1)
		sliderFill.Size = UDim2.new(percent, 0, 1, 0)
		flySpeed = math.floor(percent * 200)
		speedLabel.Text = "Скорость полёта: " .. flySpeed
	end
end)

-- Кнопка назначения клавиши для полёта
local bindKeyLabel = Instance.new("TextLabel")
bindKeyLabel.Size = UDim2.new(0, 260, 0, 20)
bindKeyLabel.Position = UDim2.new(0, 20, 0, 140)
bindKeyLabel.BackgroundTransparency = 1
bindKeyLabel.Text = "Клавиша полёта: [F]"
bindKeyLabel.TextColor3 = Color3.new(1, 1, 1)
bindKeyLabel.Font = Enum.Font.Gotham
bindKeyLabel.TextSize = 14
bindKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
bindKeyLabel.Parent = settingsTab

local bindKeyButton = Instance.new("TextButton")
bindKeyButton.Size = UDim2.new(0, 100, 0, 20)
bindKeyButton.Position = UDim2.new(0, 260, 0, 140)
bindKeyButton.Text = "Назначить"
bindKeyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
bindKeyButton.TextColor3 = Color3.new(1, 1, 1)
bindKeyButton.Font = Enum.Font.Gotham
bindKeyButton.TextSize = 14
bindKeyButton.Parent = settingsTab
roundify(bindKeyButton, 4)

local flyKey = Enum.KeyCode.F
local bindingKey = false

bindKeyButton.MouseButton1Click:Connect(function()
	bindKeyButton.Text = "..."
	bindingKey = true
end)

UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and bindingKey then
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			flyKey = input.KeyCode
			bindKeyLabel.Text = "Клавиша полёта: [" .. input.KeyCode.Name .. "]"
			bindKeyButton.Text = "Назначить"
			bindingKey = false
		end
	elseif not gpe and input.KeyCode == flyKey then
		toggleFly()
	end
end)

-- RGB-слайдеры для настройки цвета рамки
local function createSlider(name, yPos, default, callback)
	local label = Instance.new("TextLabel")
	label.Text = name
	label.Position = UDim2.new(0, 20, 0, yPos)
	label.Size = UDim2.new(0, 260, 0, 20)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Parent = settingsTab

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 260, 0, 6)
	bar.Position = UDim2.new(0, 20, 0, yPos + 20)
	bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	bar.BorderSizePixel = 0
	bar.Parent = settingsTab

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(default, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(default, -6, 0.5, -6)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = bar
	roundify(knob, 6)

	local dragging = false
	local knobDragging = false
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			knobDragging = true
		end
	end)
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			knobDragging = false
			local mouse = input.Position.X
			local rel = math.clamp((mouse - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -6, 0.5, -6)
			callback(rel)
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse = input.Position.X
			local rel = math.clamp((mouse - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, -6, 0.5, -6)
			callback(rel)
		end
	end)
end

local r, g, b = 255/255, 204/255, 0/255
local function updateBorderColor()
	local newColor = Color3.fromRGB(r * 255, g * 255, b * 255)
	-- mainFrame.BackgroundColor3 = newColor
	border.Color = newColor
	flyToggleStroke.Color = newColor
	sliderFill.BackgroundColor3 = newColor
end

createSlider("R", 20, r, function(val) r = val updateBorderColor() end)
createSlider("G", 60, g, function(val) g = val updateBorderColor() end)
createSlider("B", 100, b, function(val) b = val updateBorderColor() end)

-- Выбор цвета темы
local themeOptions = {"Жёлтый", "Зелёный", "Синий"}
local themeColors = {
	["Жёлтый"] = {r = 1, g = 0.8, b = 0},
	["Зелёный"] = {r = 0, g = 1, b = 0.5},
	["Синий"] = {r = 0, g = 0.6, b = 1}
}

local themeDropdown = Instance.new("TextButton")
themeDropdown.Size = UDim2.new(0, 260, 0, 24)
themeDropdown.Position = UDim2.new(0, 20, 0, 140)
themeDropdown.Text = "Тема: Жёлтый"
themeDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
themeDropdown.TextColor3 = Color3.new(1, 1, 1)
themeDropdown.Font = Enum.Font.Gotham
roundify(themeDropdown, 4)
themeDropdown.TextSize = 14
themeDropdown.Parent = settingsTab

local dropdownOpen = false
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 260, 0, #themeOptions * 22)
dropdownFrame.Position = UDim2.new(0, 20, 0, 164)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.Visible = false
dropdownFrame.Parent = settingsTab
roundify(dropdownFrame, 4)

for i, themeName in ipairs(themeOptions) do
	local option = Instance.new("TextButton")
	option.Size = UDim2.new(1, 0, 0, 22)
	option.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
	option.Text = themeName
	option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	option.TextColor3 = Color3.new(1, 1, 1)
	option.Font = Enum.Font.Gotham
	option.TextSize = 14
	option.Parent = dropdownFrame

	option.MouseButton1Click:Connect(function()
		dropdownOpen = false
		dropdownFrame.Visible = false
		themeDropdown.Text = "Тема: " .. themeName
		local col = themeColors[themeName]
		r = col.r
		g = col.g
		b = col.b
		updateBorderColor()
	end)
end

themeDropdown.MouseButton1Click:Connect(function()
	dropdownOpen = not dropdownOpen
	dropdownFrame.Visible = dropdownOpen
end)

-- Доп. слайдер для изменения цвета фона меню
local function updateBackgroundColor(val)
	local darkness = math.floor(val * 100)
	mainFrame.BackgroundColor3 = Color3.fromRGB(darkness, darkness, darkness)
	crownButton.BackgroundColor3 = Color3.fromRGB(darkness, darkness, darkness)
end

-- удалён ползунок BG (фона меню)

-- Переключение видимости меню с анимацией по клавише End
local TweenService = game:GetService("TweenService")
local menuVisible = true
local savedPosition = mainFrame.Position

local function toggleMenu()
	menuVisible = not menuVisible
	if menuVisible then
		mainFrame.Position = savedPosition
		mainFrame.Visible = true
		mainFrame.BackgroundTransparency = 0
		mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		mainFrame:TweenSize(UDim2.new(0, 500, 0, 300), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		updateBorderColor()
		crownButton.Visible = false
		for _, v in ipairs(mainFrame:GetDescendants()) do
			if v:IsA("GuiObject") then
				TweenService:Create(v, TweenInfo.new(0.2), {Transparency = 0}):Play()
			end
		end
		mainFrame.Size = UDim2.new(0, 500, 0, 300)
		mainFrame.Position = savedPosition
		mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		mainFrame.BackgroundTransparency = 0
	else
		for _, v in ipairs(mainFrame:GetDescendants()) do
			if v:IsA("GuiObject") then
				TweenService:Create(v, TweenInfo.new(0.2), {Transparency = 1}):Play()
			end
		end
		mainFrame.BackgroundTransparency = 0
		mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		-- отключаем сворачивание до размера короны и сохраняем вид
		mainFrame.Visible = false
		savedPosition = mainFrame.Position
		savedPosition = mainFrame.Position
		mainFrame.Visible = false
		crownButton.Position = savedPosition
		crownButton.Visible = true
	end
end

UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.End then
		toggleMenu()
	end
end)

-- Полёт
RunService.Heartbeat:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera
		bodyGyro.CFrame = cam.CFrame
		local direction = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then direction += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then direction += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end
		bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.zero
	end
end)
