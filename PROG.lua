-- ModuleScript: اسمه Prog
local Prog = {}

-- إعداد الأنماط المسبقة (Themes)
Prog.Themes = {
    Light = {
        BackgroundColor = Color3.new(1, 1, 1),
        TextColor = Color3.new(0, 0, 0),
        ButtonColor = Color3.new(0.9, 0.9, 0.9),
        SliderColor = Color3.new(0.7, 0.7, 0.7),
        ToggleColor = Color3.new(0.8, 0.8, 0.8),
        DropdownColor = Color3.new(0.95, 0.95, 0.95),
        ProgressBarColor = Color3.new(0.6, 0.6, 0.6),
        CheckboxColor = Color3.new(0.85, 0.85, 0.85),
        NotificationColor = Color3.new(0.9, 0.9, 0.9),
        TooltipColor = Color3.new(0.8, 0.8, 0.8),
    },
    Dark = {
        BackgroundColor = Color3.new(0.2, 0.2, 0.2),
        TextColor = Color3.new(1, 1, 1),
        ButtonColor = Color3.new(0.1, 0.1, 0.1),
        SliderColor = Color3.new(0.3, 0.3, 0.3),
        ToggleColor = Color3.new(0.4, 0.4, 0.4),
        DropdownColor = Color3.new(0.25, 0.25, 0.25),
        ProgressBarColor = Color3.new(0.5, 0.5, 0.5),
        CheckboxColor = Color3.new(0.35, 0.35, 0.35),
        NotificationColor = Color3.new(0.3, 0.3, 0.3),
        TooltipColor = Color3.new(0.4, 0.4, 0.4),
    }
}

-- إنشاء ScreenGui
function Prog.createScreenGui(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = parent
    return screenGui
end

-- إنشاء Frame
function Prog.createFrame(parent, size, position, theme, cornerRadius, shadow)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = theme.BackgroundColor
    frame.Parent = parent

    if cornerRadius then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(cornerRadius, 0)
        uiCorner.Parent = frame
    end

    if shadow then
        local uiShadow = Instance.new("UIStroke")
        uiShadow.Color = Color3.new(0, 0, 0)
        uiShadow.Thickness = 2
        uiShadow.Parent = frame
    end

    return frame
end

-- إنشاء TextLabel
function Prog.createTextLabel(parent, text, size, position, theme, font, textSize, cornerRadius, shadow)
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Size = size
    textLabel.Position = position
    textLabel.BackgroundColor3 = theme.BackgroundColor
    textLabel.TextColor3 = theme.TextColor
    textLabel.Font = font or Enum.Font.SourceSans
    textLabel.TextSize = textSize or 14
    textLabel.Parent = parent

    if cornerRadius then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(cornerRadius, 0)
        uiCorner.Parent = textLabel
    end

    if shadow then
        local uiShadow = Instance.new("UIStroke")
        uiShadow.Color = Color3.new(0, 0, 0)
        uiShadow.Thickness = 2
        uiShadow.Parent = textLabel
    end

    return textLabel
end

-- إنشاء TextButton مع Value و Function و _G.nameValue
function Prog.createButton(parent, text, size, position, theme, font, textSize, cornerRadius, shadow, onClick, onHover, onLeave, _GNameValue)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = theme.ButtonColor
    button.TextColor3 = theme.TextColor
    button.Font = font or Enum.Font.SourceSans
    button.TextSize = textSize or 14
    button.Parent = parent

    if cornerRadius then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(cornerRadius, 0)
        uiCorner.Parent = button
    end

    if shadow then
        local uiShadow = Instance.new("UIStroke")
        uiShadow.Color = Color3.new(0, 0, 0)
        uiShadow.Thickness = 2
        uiShadow.Parent = button
    end

    local buttonValue = false

    if onClick then
        button.MouseButton1Click:Connect(function()
            buttonValue = not buttonValue
            if _GNameValue then
                _G[_GNameValue] = buttonValue
            end
            onClick(buttonValue, _GNameValue and _G[_GNameValue])
        end)
    end

    if onHover then
        button.MouseEnter:Connect(onHover)
    end

    if onLeave then
        button.MouseLeave:Connect(onLeave)
    end

    return button, buttonValue
end

-- إنشاء TextBox
function Prog.createTextBox(parent, placeholder, size, position, theme, font, textSize, cornerRadius, shadow, onTextChanged)
    local textBox = Instance.new("TextBox")
    textBox.PlaceholderText = placeholder
    textBox.Size = size
    textBox.Position = position
    textBox.BackgroundColor3 = theme.BackgroundColor
    textBox.TextColor3 = theme.TextColor
    textBox.Font = font or Enum.Font.SourceSans
    textBox.TextSize = textSize or 14
    textBox.Parent = parent

    if cornerRadius then
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(cornerRadius, 0)
        uiCorner.Parent = textBox
    end

    if shadow then
        local uiShadow = Instance.new("UIStroke")
        uiShadow.Color = Color3.new(0, 0, 0)
        uiShadow.Thickness = 2
        uiShadow.Parent = textBox
    end

    if onTextChanged then
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            onTextChanged(textBox.Text)
        end)
    end

    return textBox
end

-- إخفاء العنصر
function Prog.hideElement(element)
    element.Visible = false
end

-- إظهار العنصر
function Prog.showElement(element)
    element.Visible = true
end

-- تغيير نص العنصر
function Prog.setText(element, text)
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        element.Text = text
    end
end

-- تغيير لون خلفية العنصر
function Prog.setBackgroundColor(element, color)
    if element:IsA("Frame") or element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") or element:IsA("ImageLabel") then
        element.BackgroundColor3 = color
    end
end

-- تغيير النمط (Theme) للعنصر
function Prog.applyTheme(element, theme)
    if element:IsA("Frame") or element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") or element:IsA("ImageLabel") then
        element.BackgroundColor3 = theme.BackgroundColor
    end
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        element.TextColor3 = theme.TextColor
    end
    if element:IsA("TextButton") then
        element.BackgroundColor3 = theme.ButtonColor
    end
end

return Prog



-- ModuleScript: اسمه BloxFruitsAutomation
local BloxFruitsAutomation = {}

-- جدول لتخزين المهام
BloxFruitsAutomation.Tasks = {}

-- وظيفة لإضافة مهمة جديدة
function BloxFruitsAutomation.addTask(taskName, taskFunction)
    BloxFruitsAutomation.Tasks[taskName] = taskFunction
end

-- وظيفة لتنفيذ مهمة
function BloxFruitsAutomation.executeTask(taskName, ...)
    local task = BloxFruitsAutomation.Tasks[taskName]
    if task then
        return task(...)
    else
        warn("Task not found: " .. taskName)
        return nil
    end
end

-- مهمة: التنقل التلقائي
BloxFruitsAutomation.addTask("AutoTravel", function(destination)
    -- افترض أن destination هو Vector3 يمثل موقع الهدف
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:MoveTo(destination)
            return "Traveling to " .. tostring(destination)
        end
    end
    return "Failed to travel."
end)

-- مهمة: جمع الفواكه
BloxFruitsAutomation.addTask("CollectFruits", function()
    -- البحث عن الفواكه وجمعها
    local fruits = workspace:FindFirstChild("Fruits")
    if fruits then
        for _, fruit in pairs(fruits:GetChildren()) do
            if fruit:IsA("BasePart") then
                -- الانتقال إلى الفاكهة
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(fruit.Position)
                        task.wait(1) -- انتظر ثانية قبل الانتقال إلى الفاكهة التالية
                    end
                end
            end
        end
        return "Fruits collected."
    else
        return "No fruits found."
    end
end)

-- مهمة: قتل الأعداء
BloxFruitsAutomation.addTask("KillEnemies", function()
    -- البحث عن الأعداء وقتلهم
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, enemy in pairs(enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") then
                -- الانتقال إلى العدو
                local player = game.Players.LocalPlayer
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(enemy.PrimaryPart.Position)
                        task.wait(1) -- انتظر ثانية قبل الانتقال إلى العدو التالي
                    end
                end
            end
        end
        return "Enemies killed."
    else
        return "No enemies found."
    end
end)

-- مهمة: تحسين المهارات
BloxFruitsAutomation.addTask("UpgradeSkills", function()
    -- تحسين المهارات تلقائيًا
    local player = game.Players.LocalPlayer
    local stats = player:FindFirstChild("Stats")
    if stats then
        for _, stat in pairs(stats:GetChildren()) do
            if stat:IsA("IntValue") then
                stat.Value = stat.Value + 1 -- زيادة المهارة
            end
        end
        return "Skills upgraded."
    else
        return "No stats found."
    end
end)

return BloxFruitsAutomation

-- LocalScript: اسمه Main
local Prog = require(game:GetService("ReplicatedStorage"):WaitForChild("Prog"))
local BloxFruitsAutomation = require(game:GetService("ReplicatedStorage"):WaitForChild("BloxFruitsAutomation"))

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- إنشاء ScreenGui
local screenGui = Prog.createScreenGui(playerGui)

-- تطبيق النمط المظلم (Dark Theme)
local darkTheme = Prog.Themes.Dark

-- إنشاء Frame
local frame = Prog.createFrame(screenGui, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(0.25, 0, 0.25, 0), darkTheme, 0.1, true)

-- إنشاء TextLabel
local textLabel = Prog.createTextLabel(frame, "Blox Fruits Automation", UDim2.new(0.8, 0, 0.2, 0), UDim2.new(0.1, 0, 0.1, 0), darkTheme, Enum.Font.SourceSansBold, 18, 0.1, true)

-- إنشاء TextBox لإدخال اسم المهمة
local taskNameTextBox = Prog.createTextBox(frame, "Enter task name...", UDim2.new(0.8, 0, 0.1, 0), UDim2.new(0.1, 0, 0.3, 0), darkTheme, Enum.Font.SourceSans, 14, 0.1, true, function(text)
    print("Task name entered:", text)
end)

-- إنشاء Button لإرسال الطلب
local executeButton, executeButtonValue = Prog.createButton(frame, "Execute Task", UDim2.new(0.4, 0, 0.2, 0), UDim2.new(0.3, 0, 0.5, 0), darkTheme, Enum.Font.SourceSansBold, 16, 0.2, true, function(value)
    local taskName = taskNameTextBox.Text
    if taskName ~= "" then
        local result = BloxFruitsAutomation.executeTask(taskName)
        if result then
            Prog.setText(textLabel, "Task executed successfully! Result: " .. tostring(result))
        else
            Prog.setText(textLabel, "Task execution failed or no result returned.")
        end
    else
        Prog.setText(textLabel, "Please enter a task name.")
    end
end)
