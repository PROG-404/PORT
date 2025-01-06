--[[
    ProgLib Premium v4.0.0
    Advanced UI Library for Roblox
    
    @class ProgLib
    @author Professional Programming Team
--]]
    local ProgLib = require(path.to.ProgLib)
    local window = ProgLib.Window.Create({
        Title = "My Window",
        Theme = "Primary"
    })
]]

-- Cache frequently accessed services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local ProgLib = {
    Name = "ProgLib",
    Version = "4.0.0",
    Author = "Professional Programming Team",
    License = "MIT",
    
    Settings = {
        Theme = {
            Primary = {
                Main = Color3.fromRGB(25, 25, 30),
                Secondary = Color3.fromRGB(30, 30, 35),
                Accent = Color3.fromRGB(60, 145, 255),
                AccentDark = Color3.fromRGB(40, 125, 235),
                Text = Color3.fromRGB(255, 255, 255),
                SubText = Color3.fromRGB(200, 200, 200),
                Border = Color3.fromRGB(50, 50, 55),
                Background = Color3.fromRGB(20, 20, 25),
                Success = Color3.fromRGB(45, 200, 95),
                Warning = Color3.fromRGB(250, 180, 40),
                Error = Color3.fromRGB(250, 60, 60)
            },
            Dark = {
                Main = Color3.fromRGB(20, 20, 25),
                Secondary = Color3.fromRGB(25, 25, 30),
                Accent = Color3.fromRGB(50, 135, 245),
                AccentDark = Color3.fromRGB(30, 115, 225),
                Text = Color3.fromRGB(255, 255, 255),
                SubText = Color3.fromRGB(190, 190, 190),
                Border = Color3.fromRGB(45, 45, 50),
                Background = Color3.fromRGB(15, 15, 20),
                Success = Color3.fromRGB(35, 190, 85),
                Warning = Color3.fromRGB(240, 170, 30),
                Error = Color3.fromRGB(240, 50, 50)
            }
        },
        
        Animation = {
            TweenInfo = {
                Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                Long = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            },
            Effects = {
                Ripple = true,
                Spring = true,
                Fade = true
            }
        },
        
        Window = {
            DefaultSize = Vector2.new(650, 450),
            MinSize = Vector2.new(450, 350),
            MaxSize = Vector2.new(850, 650),
            TitleBarHeight = 35,
            TabBarWidth = 150,
            CornerRadius = 8,
            Shadow = true,
            AutoSave = true,
            SaveInterval = 60
        },
        
        Elements = {
            CornerRadius = UDim.new(0, 6),
            ButtonHeight = 32,
            InputHeight = 35,
            DropdownHeight = 32,
            SliderHeight = 35,
            ToggleSize = 24,
            CheckboxSize = 20,
            ScrollBarWidth = 3,
            TabButtonHeight = 36,
            SectionSpacing = 10,
            ElementSpacing = 8
        }
    },
    
    Core = {
        Cache = {
            Instances = {},
            Connections = {},
            Threads = {},
            Assets = {}
        },
        
        Debug = {
            Enabled = false,
            LogLevel = 2,
            LogToFile = false,
            LogPath = "ProgLib/logs/"
        }
    }
}


-- Event System
ProgLib.Events = {
    _handlers = {},
    
    on = function(eventName, handler)
        if not ProgLib.Events._handlers[eventName] then
            ProgLib.Events._handlers[eventName] = {}
        end
        table.insert(ProgLib.Events._handlers[eventName], handler)
    end,
    
    emit = function(eventName, ...)
        local handlers = ProgLib.Events._handlers[eventName]
        if handlers then
            for _, handler in ipairs(handlers) do
                task.spawn(handler, ...)
            end
        end
    end
}

-- State Management
ProgLib.State = {
    _state = {},
    _listeners = {},
    
    get = function(key)
        return ProgLib.State._state[key]
    end,
    
    set = function(key, value)
        local oldValue = ProgLib.State._state[key]
        ProgLib.State._state[key] = value
        
        local listeners = ProgLib.State._listeners[key]
        if listeners then
            for _, listener in ipairs(listeners) do
                task.spawn(listener, value, oldValue)
            end
        end
    end,
    
    onChange = function(key, callback)
        if not ProgLib.State._listeners[key] then
            ProgLib.State._listeners[key] = {}
        end
        table.insert(ProgLib.State._listeners[key], callback)
    end
}

-- Theme Manager
ProgLib.ThemeManager = {
    _activeTheme = "Primary",
    _customThemes = {},
    
    createTheme = function(name, colors)
        assert(type(name) == "string", "Theme name must be a string")
        assert(type(colors) == "table", "Theme colors must be a table")
        
        local requiredColors = {"Main", "Secondary", "Accent", "Text"}
        for _, colorName in ipairs(requiredColors) do
            assert(colors[colorName], string.format("Theme must include %s color", colorName))
            assert(typeof(colors[colorName]) == "Color3", string.format("%s must be Color3", colorName))
        end
        
        ProgLib.ThemeManager._customThemes[name] = colors
        return colors
    end,
    
    setTheme = function(name)
        local theme = ProgLib.Settings.Theme[name] or ProgLib.ThemeManager._customThemes[name]
        assert(theme, "Theme not found: " .. tostring(name))
        
        ProgLib.ThemeManager._activeTheme = name
        ProgLib.Events.emit("themeChanged", name, theme)
        
        for _, instance in pairs(ProgLib.Core.Cache.Instances) do
            if instance:IsA("GuiObject") then
                local themeProps = instance:GetAttribute("ThemeProps")
                if themeProps then
                    for prop, colorKey in pairs(themeProps) do
                        instance[prop] = theme[colorKey]
                    end
                end
            end
        end
    end
}

-- Animation Manager  
ProgLib.AnimationManager = {
    _animations = {},
    
    register = function(name, animationConfig)
        ProgLib.AnimationManager._animations[name] = animationConfig
    end,
    
    play = function(instance, animationName, ...)
        local animation = ProgLib.AnimationManager._animations[animationName]
        if not animation then
            warn("Animation not found:", animationName)
            return
        end
        
        return animation(instance, ...)
    end
}

-- Register default animations
ProgLib.AnimationManager.register("fadeIn", function(instance, duration)
    duration = duration or 0.3
    instance.BackgroundTransparency = 1
    instance.Visible = true
    
    return ProgLib.Utils.Tween(instance, {
        BackgroundTransparency = 0
    }, {
        Time = duration,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    })
end)

-- Component System
ProgLib.Component = {
    _components = {},
    
    create = function(name, template)
        assert(type(name) == "string", "Component name must be a string")
        assert(type(template) == "table", "Component template must be a table")
        
        local component = {
            new = function(props)
                props = props or {}
                
                local instance = template.render(props)
                
                if template.mounted then
                    task.spawn(template.mounted, instance, props)
                end
                
                instance.Destroying:Connect(function()
                    if template.unmounted then
                        template.unmounted(instance, props)
                    end
                end)
                
                return instance
            end
        }
        
        ProgLib.Component._components[name] = component
        return component
    end
}
-- Config Management
ProgLib.ConfigManager = {
    _configPath = "ProgLib/configs/",
    
    saveConfig = function(name, data)
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if success then
            writefile(ProgLib.ConfigManager._configPath .. name .. ".json", encoded)
            return true
        end
        return false
    end,
    
    loadConfig = function(name)
        local path = ProgLib.ConfigManager._configPath .. name .. ".json"
        if isfile(path) then
            local content = readfile(path)
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if success then
                return decoded
            end
        end
        return nil
    end,
    
    autoSave = function(window, configName)
        if ProgLib.Settings.Window.AutoSave then
            local function saveWindowState()
                local state = {
                    position = {
                        X = window.GUI.Main.Position.X.Offset,
                        Y = window.GUI.Main.Position.Y.Offset
                    },
                    size = {
                        X = window.GUI.Main.Size.X.Offset,
                        Y = window.GUI.Main.Size.Y.Offset
                    },
                    activeTab = window.ActiveTab and window.ActiveTab.Name or nil
                }
                ProgLib.ConfigManager.saveConfig(configName, state)
            end
            
            local connection = game:GetService("RunService").Heartbeat:Connect(saveWindowState)
            table.insert(ProgLib.Core.Cache.Connections, connection)
        end
    end
}

-- Error Handler
ProgLib.ErrorHandler = {
    _errorHandlers = {},
    
    registerHandler = function(errorType, handler)
        ProgLib.ErrorHandler._errorHandlers[errorType] = handler
    end,
    
    handleError = function(err, context)
        local errorType = typeof(err)
        local handler = ProgLib.ErrorHandler._errorHandlers[errorType]
        
        if handler then
            return handler(err, context)
        else
            warn("[ProgLib] Unhandled error:", err)
            if ProgLib.Core.Debug.Enabled then
                error(err)
            end
        end
    end
}

-- Register default error handlers
ProgLib.ErrorHandler.registerHandler("string", function(err, context)
    warn(string.format("[ProgLib] Error in %s: %s", context or "unknown", err))
end)

-- Initialize Core Systems
function ProgLib:Initialize()
    if self.Settings.Window.AutoSave then
        local function ensureFolder(path)
            if not isfolder(path) then
                makefolder(path)
            end
        end
        
        ensureFolder("ProgLib")
        ensureFolder("ProgLib/configs")
        ensureFolder("ProgLib/logs")
    end
    
    if self.Core.Debug.LogToFile then
        local date = os.date("%Y-%m-%d_%H-%M-%S")
        self.Core.Debug.CurrentLog = "ProgLib/logs/" .. date .. ".log"
        writefile(self.Core.Debug.CurrentLog, "[ProgLib] Session started: " .. date .. "\n")
    end
    
    return self
end

return ProgLib:Initialize()


-- Utility Functions
ProgLib.Utils = {
    Create = function(class, properties, children)
        local instance = Instance.new(class)
        ProgLib.Core.Cache.Instances[instance] = true
        
        for prop, value in pairs(properties or {}) do
            if prop ~= "Parent" then
                instance[prop] = value
            end
        end
        
        if children then
            for _, child in ipairs(children) do
                child.Parent = instance
            end
        end
        
        if properties and properties.Parent then
            instance.Parent = properties.Parent
        end
        
        return instance
    end,
    
    Tween = function(instance, properties, tweenType)
        if not instance or not properties then return end
        
        local tweenInfoCache = {}
        return function(instance, properties, tweenType)
            local tweenInfo = tweenInfoCache[tweenType]
            if not tweenInfo then
                tweenInfo = ProgLib.Settings.Animation.TweenInfo[tweenType or "Normal"]
                tweenInfoCache[tweenType] = tweenInfo
            end
            
            local tween = TweenService:Create(instance, tweenInfo, properties)
            tween:Play()
            return tween
        end
    end,
    
    Ripple = function(button, properties)
        if not ProgLib.Settings.Animation.Effects.Ripple then return end
        
        task.spawn(function()
            local ripple = ProgLib.Utils.Create("Frame", {
                Name = "Ripple",
                Parent = button,
                BackgroundColor3 = properties.Color or Color3.new(1, 1, 1),
                BackgroundTransparency = properties.StartTransparency or 0.7,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = button.ZIndex + 1
            })
            
            local targetSize = UDim2.new(1.5, 0, 1.5, 0)
            
            ProgLib.Utils.Tween(ripple, {
                Size = targetSize,
                BackgroundTransparency = 1
            }, "Smooth").Completed:Connect(function()
                ripple:Destroy()
            end)
        end)
    end,
    
    MakeDraggable = function(window, dragObject)
        local dragging, dragInput, dragStart, startPos
        
        dragObject = dragObject or window.GUI.TitleBar
        
        local function update(input)
            local delta = input.Position - dragStart
            window.GUI.Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
        
        dragObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = window.GUI.Main.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        dragObject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end,
    
    MakeResizable = function(window)
        local resizing, resizeType
        local minSize = ProgLib.Settings.Window.MinSize
        local maxSize = ProgLib.Settings.Window.MaxSize
        local resizeArea = 5
        
        local function isInResizeRange(frame, position)
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            
            local right = position.X > framePos.X + frameSize.X - resizeArea
            local bottom = position.Y > framePos.Y + frameSize.Y - resizeArea
            
            return right or bottom, {
                Right = right,
                Bottom = bottom
            }
        end
        
        window.GUI.Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local inRange, rangeType = isInResizeRange(window.GUI.Main, input.Position)
                if inRange then
                    resizing = true
                    resizeType = rangeType
                end
            end
        end)
        
        window.GUI.Main.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
                resizeType = nil
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
                local delta = input.Position - window.GUI.Main.AbsolutePosition
                local newSize = Vector2.new(
                    resizeType.Right and math.clamp(delta.X, minSize.X, maxSize.X) or window.GUI.Main.Size.X.Offset,
                    resizeType.Bottom and math.clamp(delta.Y, minSize.Y, maxSize.Y) or window.GUI.Main.Size.Y.Offset
                )
                
                ProgLib.Utils.Tween(window.GUI.Main, {
                    Size = UDim2.new(0, newSize.X, 0, newSize.Y)
                }, "Quick")
            end
        end)
    end,
    
    Cleanup = function()
        for _, connection in pairs(ProgLib.Core.Cache.Connections) do
            connection:Disconnect()
        end
        
        for _, instance in pairs(ProgLib.Core.Cache.Instances) do
            instance:Destroy()
        end
        
        table.clear(ProgLib.Core.Cache.Connections)
        table.clear(ProgLib.Core.Cache.Instances)
        table.clear(ProgLib.Core.Cache.Threads)
        table.clear(ProgLib.Core.Cache.Assets)
    end
}

-- Window System
ProgLib.Window = {
    Create = function(config)
        assert(type(config) == "table", "Window config must be a table")
        assert(type(config.Title) == "string" or config.Title == nil, "Window title must be a string")
        
        if config.Size then
            assert(typeof(config.Size) == "Vector2", "Window size must be Vector2")
            config.Size = Vector2.new(
                math.clamp(config.Size.X, ProgLib.Settings.Window.MinSize.X, ProgLib.Settings.Window.MaxSize.X),
                math.clamp(config.Size.Y, ProgLib.Settings.Window.MinSize.Y, ProgLib.Settings.Window.MaxSize.Y)
            )
        end
        
        local window = {
            Title = config.Title or "ProgLib Window",
            Size = config.Size or ProgLib.Settings.Window.DefaultSize,
            Theme = config.Theme or "Primary",
            Position = config.Position,
            GUI = {},
            Tabs = {},
            ActiveTab = nil
        }
        
        -- Create window GUI
        window.GUI.Main = ProgLib.Utils.Create("Frame", {
            Name = "ProgLibWindow",
            Parent = ProgLib.Utils.Create("ScreenGui", {
                Name = "ProgLib_Interface",
                Parent = CoreGui,
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            }),
            Size = UDim2.new(0, window.Size.X, 0, window.Size.Y),
            Position = window.Position or UDim2.new(0.5, -window.Size.X/2, 0.5, -window.Size.Y/2),
            BackgroundColor3 = ProgLib.Settings.Theme[window.Theme].Main,
            BorderSizePixel = 0,
            ClipsDescendants = true
        }, {
            ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, ProgLib.Settings.Window.CornerRadius)
            })
        })
        
        -- Create title bar
        window.GUI.TitleBar = ProgLib.Utils.Create("Frame", {
            Name = "TitleBar",
            Parent = window.GUI.Main,
            Size = UDim2.new(1, 0, 0, ProgLib.Settings.Window.TitleBarHeight),
            BackgroundColor3 = ProgLib.Settings.Theme[window.Theme].Secondary,
            BorderSizePixel = 0
        }, {
            ProgLib.Utils.Create("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = window.Title,
                TextColor3 = ProgLib.Settings.Theme[window.Theme].Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            
            ProgLib.Utils.Create("Frame", {
                Name = "Controls",
                Size = UDim2.new(0, 90, 1, 0),
                Position = UDim2.new(1, -90, 0, 0),
                BackgroundTransparency = 1
            })
        })
        
        -- Add control buttons
        local function CreateControlButton(name, symbol)
            return ProgLib.Utils.Create("TextButton", {
                Name = name,
                Parent = window.GUI.TitleBar.Controls,
                Size = UDim2.new(0, 30, 1, 0),
                Position = name == "Close" and UDim2.new(1, -30, 0, 0) or 
                          name == "Minimize" and UDim2.new(0, 0, 0, 0) or 
                          UDim2.new(0.5, -15, 0, 0),
                BackgroundTransparency = 1,
                Text = symbol,
                TextColor3 = ProgLib.Settings.Theme[window.Theme].SubText,
                TextSize = 20,
                Font = Enum.Font.GothamBold
            })
        end
        
        local closeButton = CreateControlButton("Close", "×")
        local minimizeButton = CreateControlButton("Minimize", "−")
        local settingsButton = CreateControlButton("Settings", "⚙")
        
        -- Add content area
        window.GUI.Content = ProgLib.Utils.Create("Frame", {
            Name = "Content",
            Parent = window.GUI.Main,
            Size = UDim2.new(1, 0, 1, -ProgLib.Settings.Window.TitleBarHeight),
            Position = UDim2.new(0, 0, 0, ProgLib.Settings.Window.TitleBarHeight),
            BackgroundColor3 = ProgLib.Settings.Theme[window.Theme].Background,
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        
        -- Add tab container
        window.GUI.TabContainer = ProgLib.Utils.Create("Frame", {
            Name = "TabContainer",
            Parent = window.GUI.Content,
            Size = UDim2.new(0, ProgLib.Settings.Window.TabBarWidth, 1, 0),
            BackgroundColor3 = ProgLib.Settings.Theme[window.Theme].Secondary,
            BorderSizePixel = 0
        }, {
            ProgLib.Utils.Create("ScrollingFrame", {
                Name = "TabList",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = ProgLib.Settings.Elements.ScrollBarWidth,
                ScrollBarImageColor3 = ProgLib.Settings.Theme[window.Theme].Border,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            }, {
                ProgLib.Utils.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, ProgLib.Settings.Elements.ElementSpacing)
                })
            })
        })
        
        -- Add tab content area
        window.GUI.TabContent = ProgLib.Utils.Create("Frame", {
            Name = "TabContent",
            Parent = window.GUI.Content,
            Size = UDim2.new(1, -ProgLib.Settings.Window.TabBarWidth, 1, 0),
            Position = UDim2.new(0, ProgLib.Settings.Window.TabBarWidth, 0, 0),
            BackgroundTransparency = 1
        })
        
        -- Add window functionality
        function window:AddTab(tabConfig)
            return ProgLib.Tab.Create(self, tabConfig)
        end
        
        function window:Minimize()
            local minSize = ProgLib.Settings.Window.TitleBarHeight
            local isMinimized = window.GUI.Main.Size.Y.Offset <= minSize
            local targetSize = isMinimized and window.Size or UDim2.new(0, window.Size.X, 0, minSize)
            
            ProgLib.Utils.Tween(window.GUI.Main, {
                Size = targetSize
            }, "Smooth")
            
            ProgLib.Events.emit("windowMinimize", self, isMinimized)
        end
        
        -- Add control button events
        closeButton.MouseButton1Click:Connect(function()
            ProgLib.Utils.Tween(window.GUI.Main, {
                Size = UDim2.new(0, window.Size.X, 0, 0),
                BackgroundTransparency = 1
            }, "Smooth").Completed:Connect(function()
                window.GUI.Main.Parent:Destroy()
                ProgLib.Events.emit("windowClose", window)
            end)
        end)
        
        minimizeButton.MouseButton1Click:Connect(function()
            window:Minimize()
        end)
        
        -- Make window draggable and resizable
        ProgLib.Utils.MakeDraggable(window)
        ProgLib.Utils.MakeResizable(window)
        
        -- Setup auto-save if enabled
        if ProgLib.Settings.Window.AutoSave then
            ProgLib.ConfigManager.autoSave(window, "window_" .. window.Title)
        end
        
        return window
    end
}

-- Return initialized library
return ProgLib


-- ElementSystem: Enhanced UI Elements with Values
local ElementSystem = {
    _elements = {},
    _values = {},
    
    createToggleWithValue = function(parent, config)
        config = config or {}
        local elementId = HttpService:GenerateGUID()
        
        local container = ProgLib.Utils.Create("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Name = "ToggleWithValue_" .. elementId
        })
        
        -- Create Toggle Button
        local toggle = ProgLib.Utils.Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Secondary,
            Text = config.Text or "Toggle",
            TextColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            AutoButtonColor = false
        }, {
            ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })
        
        -- Create Value Input
        local valueFrame = ProgLib.Utils.Create("Frame", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Background,
            BackgroundTransparency = 0.5
        }, {
            ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            
            ProgLib.Utils.Create("TextBox", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(config.DefaultValue or ""),
                TextColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Text,
                PlaceholderText = "Enter value...",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ClearTextOnFocus = false
            })
        })
        
        -- Hide value frame initially
        valueFrame.Visible = false
        
        -- Toggle functionality
        local enabled = false
        
        local function updateToggle()
            AnimationSystem.tween(toggle, {
                BackgroundColor3 = enabled and 
                    ThemeSystem._themes[ThemeSystem._activeTheme].Accent or 
                    ThemeSystem._themes[ThemeSystem._activeTheme].Secondary
            }, TweenInfo.new(0.2))
            
            -- Show/Hide value frame with animation
            if enabled then
                valueFrame.Visible = true
                valueFrame.BackgroundTransparency = 1
                AnimationSystem.tween(valueFrame, {
                    BackgroundTransparency = 0.5
                }, TweenInfo.new(0.2))
            else
                AnimationSystem.tween(valueFrame, {
                    BackgroundTransparency = 1
                }, TweenInfo.new(0.2)).Completed:Connect(function()
                    valueFrame.Visible = false
                end)
            end
            
            if config.OnToggle then
                config.OnToggle(enabled, valueFrame.TextBox.Text)
            end
        end
        
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            updateToggle()
            EffectSystem.ripple(toggle)
        end)
        
        -- Value changed handler
        valueFrame.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
            local value = valueFrame.TextBox.Text
            ElementSystem._values[elementId] = value
            
            if config.OnValueChanged then
                config.OnValueChanged(value)
            end
        end)
        
        -- Store element reference
        ElementSystem._elements[elementId] = {
            Container = container,
            Toggle = toggle,
            ValueFrame = valueFrame,
            Config = config
        }
        
        return {
            getId = function()
                return elementId
            end,
            
            getValue = function()
                return valueFrame.TextBox.Text
            end,
            
            setValue = function(value)
                valueFrame.TextBox.Text = tostring(value)
            end,
            
            setEnabled = function(state)
                enabled = state
                updateToggle()
            end,
            
            isEnabled = function()
                return enabled
            end,
            
            destroy = function()
                container:Destroy()
                ElementSystem._elements[elementId] = nil
                ElementSystem._values[elementId] = nil
            end
        }
    end,
    
    createButtonWithValue = function(parent, config)
        config = config or {}
        local elementId = HttpService:GenerateGUID()
        
        local container = ProgLib.Utils.Create("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1,
            Name = "ButtonWithValue_" .. elementId
        })
        
        -- Create Button
        local button = ProgLib.Utils.Create("TextButton", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Accent,
            Text = config.Text or "Button",
            TextColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            AutoButtonColor = false
        }, {
            ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })
        
        -- Create Value Display
        local valueDisplay = ProgLib.Utils.Create("TextLabel", {
            Parent = container,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Background,
            BackgroundTransparency = 0.5,
            Text = tostring(config.DefaultValue or ""),
            TextColor3 = ThemeSystem._themes[ThemeSystem._activeTheme].Text,
            Font = Enum.Font.Gotham,
            TextSize = 12
        }, {
            ProgLib.Utils.Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            })
        })
        
        -- Button click handler
        button.MouseButton1Click:Connect(function()
            EffectSystem.ripple(button)
            
            if config.OnClick then
                local result = config.OnClick()
                if result then
                    valueDisplay.Text = tostring(result)
                    ElementSystem._values[elementId] = result
                end
            end
        end)
        
        -- Store element reference
        ElementSystem._elements[elementId] = {
            Container = container,
            Button = button,
            ValueDisplay = valueDisplay,
            Config = config
        }
        
        return {
            getId = function()
                return elementId
            end,
            
            getValue = function()
                return valueDisplay.Text
            end,
            
            setValue = function(value)
                valueDisplay.Text = tostring(value)
                ElementSystem._values[elementId] = value
            end,
            
            destroy = function()
                container:Destroy()
                ElementSystem._elements[elementId] = nil
                ElementSystem._values[elementId] = nil
            end
        }
    end
}
