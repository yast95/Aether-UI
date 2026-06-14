--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    A E T H E R   U I                         ║
    ║         The Next Generation Lua UI Library                   ║
    ║                                                              ║
    ║  A modern, premium UI library featuring:                     ║
    ║  - Liquid Glass design language                              ║
    ║  - Advanced transparency & blur effects                      ║
    ║  - GPU-friendly animations                                   ║
    ║  - Complete theme system (Light/Dark/Custom)                 ║
    ║  - Modular, extensible architecture                          ║
    ║                                                              ║
    ║  Version: 2.0.0                                              ║
    ║  License: MIT                                                ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local AetherUI = {}
AetherUI.__index = AetherUI

-- Version info
AetherUI.Version = "2.0.0"
AetherUI.Name = "AetherUI"
AetherUI.Author = "Aether Studio"

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

-- Internal modules (loaded via LoadModules)
local Themes = nil
local Animations = nil
local Utils = nil
local Icons = nil
local Components = nil

-- ═══════════════════════════════════════════════════════════════
-- MODULE LOADING
-- ═══════════════════════════════════════════════════════════════

--- Load external module dependencies
function AetherUI.LoadModules(modules)
    Themes = modules.Themes or Themes
    Animations = modules.Animations or Animations
    Utils = modules.Utils or Utils
    Icons = modules.Icons or Icons
    Components = modules.Components or Components
end

--- Get loaded modules (for inspection/debugging)
function AetherUI.GetModules()
    return {
        Themes = Themes,
        Animations = Animations,
        Utils = Utils,
        Icons = Icons,
        Components = Components,
    }
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION & DEFAULTS
-- ═══════════════════════════════════════════════════════════════

AetherUI.DefaultConfig = {
    -- Window settings
    Window = {
        Title = "AetherUI",
        SubTitle = "v2.0.0",
        Width = 650,
        Height = 450,
        MinWidth = 400,
        MinHeight = 300,
        CornerRadius = 16,
        BlurEnabled = true,
        BlurIntensity = 0.15,
        ShadowEnabled = true,
        ShadowIntensity = 0.3,
        AnimationSpeed = 0.4,
        Draggable = true,
        Resizable = true,
        StartCentered = true,
        ToggleKey = Enum.KeyCode.RightShift,
    },
    
    -- Theme settings
    Theme = {
        Mode = "Dark",           -- "Dark", "Light", "Auto", "Custom"
        CustomTheme = nil,       -- Table with custom colors
        AnimationsEnabled = true,
        AnimationSpeed = 0.35,
        SoundEnabled = false,
        SoundVolume = 0.3,
        GlassEffect = true,
        GlassTransparency = 0.15,
        BlurRadius = 12,
    },
    
    -- Component defaults
    Components = {
        CornerRadius = 10,
        Padding = 12,
        Spacing = 8,
        ButtonHeight = 36,
        ToggleSize = 22,
        SliderHeight = 6,
        DropdownMaxHeight = 200,
    },
    
    -- Notification settings
    Notifications = {
        Position = "TopRight",   -- "TopRight", "TopLeft", "BottomRight", "BottomLeft"
        Duration = 4,
        MaxVisible = 5,
        Stacking = "Down",       -- "Down", "Up"
    },
    
    -- Saving/Loading
    SaveConfig = true,
    ConfigFolder = "AetherUI_Configs",
    AutoSaveInterval = 30,       -- seconds
}

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

function AetherUI.new(userConfig)
    local self = setmetatable({}, AetherUI)
    
    -- Merge user config with defaults
    self.Config = Utils and Utils.DeepMerge(AetherUI.DefaultConfig, userConfig or {}) 
        or AetherUI.DeepMergeTables(AetherUI.DefaultConfig, userConfig or {})
    
    -- State management
    self.Windows = {}
    self.ActiveWindow = nil
    self.Notifications = {}
    self.Plugins = {}
    self.Hooks = {}
    self.IsOpen = true
    
    -- Initialize systems
    self:InitializeSystems()
    
    -- Setup global toggle
    self:SetupToggleKey()
    
    -- Auto-save loop
    if self.Config.SaveConfig then
        self:StartAutoSave()
    end
    
    return self
end

function AetherUI:InitializeSystems()
    -- Initialize theme system
    self.ThemeManager = Themes and Themes.new(self.Config.Theme) or {
        GetCurrentTheme = function() return AetherUI.DarkTheme end,
        ApplyTheme = function() end,
    }
    
    -- Initialize animation system
    self.AnimationManager = Animations and Animations.new(self.Config.Theme) or {
        Tween = function(_, obj, props, duration, easing)
            local tweenInfo = TweenInfo.new(duration or 0.35, easing or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(obj, tweenInfo, props):Play()
        end,
        FadeIn = function(_, obj, duration)
            obj.BackgroundTransparency = 1
            local tweenInfo = TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(obj, tweenInfo, {BackgroundTransparency = obj:GetAttribute("TargetTransparency") or 0}):Play()
        end,
    }
    
    -- Current theme reference
    self.CurrentTheme = self.ThemeManager:GetCurrentTheme()
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

function AetherUI:CreateWindow(windowConfig)
    windowConfig = windowConfig or {}
    
    -- Merge with defaults
    local config = {}
    for k, v in pairs(self.Config.Window) do config[k] = v end
    for k, v in pairs(windowConfig) do config[k] = v end
    
    -- Create window using Components module
    local window = Components and Components.CreateWindow(self, config) 
        or self:CreateWindowInternal(config)
    
    table.insert(self.Windows, window)
    self.ActiveWindow = window
    
    return window
end

-- Internal window creation (fallback if Components module not loaded)
function AetherUI:CreateWindowInternal(config)
    local guiParent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") 
        or CoreGui
    
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AetherUI_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = guiParent
    
    -- Main container (shadow + blur background)
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, config.Width, 0, config.Height)
    mainContainer.Position = config.StartCentered 
        and UDim2.new(0.5, -config.Width/2, 0.5, -config.Height/2)
        or UDim2.new(0.1, 0, 0.1, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.BorderSizePixel = 0
    mainContainer.ClipsDescendants = true
    mainContainer.Parent = screenGui
    
    -- Shadow layer
    if config.ShadowEnabled then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 40, 1, 40)
        shadow.Position = UDim2.new(0, -20, 0, -20)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 1 - config.ShadowIntensity
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 0
        shadow.Parent = mainContainer
    end
    
    -- Glass background
    local glassBg = Instance.new("Frame")
    glassBg.Name = "GlassBackground"
    glassBg.Size = UDim2.new(1, 0, 1, 0)
    glassBg.BackgroundColor3 = self.CurrentTheme.Background or Color3.fromRGB(25, 25, 30)
    glassBg.BackgroundTransparency = config.BlurEnabled and (1 - config.BlurIntensity) or 0.1
    glassBg.BorderSizePixel = 0
    glassBg.Parent = mainContainer
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.CornerRadius)
    corner.Parent = glassBg
    
    -- Gradient overlay for glass effect
    if config.BlurEnabled then
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 240, 245)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.92),
            NumberSequenceKeypoint.new(0.5, 0.88),
            NumberSequenceKeypoint.new(1, 0.92)
        })
        gradient.Rotation = 135
        gradient.Parent = glassBg
    end
    
    -- Top bar / Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 42)
    titleBar.BackgroundColor3 = self.CurrentTheme.TitleBar or Color3.fromRGB(35, 35, 42)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = glassBg
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, config.CornerRadius)
    titleCorner.Parent = titleBar
    
    -- Fix bottom corners of title bar
    local titleFix = Instance.new("Frame")
    titleFix.Name = "CornerFix"
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = titleBar.BackgroundColor3
    titleFix.BackgroundTransparency = titleBar.BackgroundTransparency
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title icon
    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 24, 0, 24)
    titleIcon.Position = UDim2.new(0, 12, 0, 9)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Image = Icons and Icons.Get("Aether") or ""
    titleIcon.ImageColor3 = self.CurrentTheme.Accent or Color3.fromRGB(100, 150, 255)
    titleIcon.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0, 200, 1, 0)
    titleText.Position = UDim2.new(0, 42, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(230, 230, 230)
    titleText.TextSize = 15
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Subtitle
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(0, 100, 0, 16)
    subTitle.Position = UDim2.new(0, 42, 0, 22)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = config.SubTitle
    subTitle.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(150, 150, 150)
    subTitle.TextSize = 10
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Parent = titleBar
    
    -- Window controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.new(0, 80, 0, 30)
    controlsFrame.Position = UDim2.new(1, -85, 0, 6)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.Parent = controlsFrame
    
    -- Minimize button
    local btnMinimize = self:CreateControlButton(controlsFrame, "−", Color3.fromRGB(255, 200, 50))
    -- Maximize button  
    local btnMaximize = self:CreateControlButton(controlsFrame, "□", Color3.fromRGB(50, 200, 100))
    -- Close button
    local btnClose = self:CreateControlButton(controlsFrame, "×", Color3.fromRGB(255, 80, 70))
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -16, 1, -58)
    contentFrame.Position = UDim2.new(0, 8, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = glassBg
    
    -- Content layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame
    
    -- Tab system
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 36)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = contentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabContainer
    
    -- Tab content pages
    local tabPages = Instance.new("Frame")
    tabPages.Name = "TabPages"
    tabPages.Size = UDim2.new(1, 0, 1, -44)
    tabPages.Position = UDim2.new(0, 0, 0, 40)
    tabPages.BackgroundTransparency = 1
    tabPages.BorderSizePixel = 0
    tabPages.ClipsDescendants = true
    tabPages.Parent = contentFrame
    
    -- Window object
    local window = {
        Type = "Window",
        Config = config,
        ScreenGui = screenGui,
        MainContainer = mainContainer,
        GlassBackground = glassBg,
        TitleBar = titleBar,
        ContentFrame = contentFrame,
        TabContainer = tabContainer,
        TabPages = tabPages,
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false,
        IsMaximized = false,
        OriginalSize = UDim2.new(0, config.Width, 0, config.Height),
        OriginalPosition = mainContainer.Position,
        Library = self,
    }
    
    -- Draggable functionality
    if config.Draggable then
        self:MakeDraggable(window, titleBar)
    end
    
    -- Resizable functionality
    if config.Resizable then
        self:MakeResizable(window)
    end
    
    -- Control button functionality
    btnClose.MouseButton1Click:Connect(function()
        self:CloseWindow(window)
    end)
    
    btnMinimize.MouseButton1Click:Connect(function()
        self:MinimizeWindow(window)
    end)
    
    btnMaximize.MouseButton1Click:Connect(function()
        self:MaximizeWindow(window)
    end)
    
    -- Entrance animation
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.BackgroundTransparency = 1
    
    local enterTween = TweenService:Create(mainContainer, TweenInfo.new(
        config.AnimationSpeed or 0.4,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ), {
        Size = UDim2.new(0, config.Width, 0, config.Height),
        Position = config.StartCentered 
            and UDim2.new(0.5, -config.Width/2, 0.5, -config.Height/2)
            or UDim2.new(0.1, 0, 0.1, 0),
    })
    enterTween:Play()
    
    -- Return window API
    -- Fix: Components.WindowMethods pouvait être nil → crash "attempt to index nil"
    setmetatable(window, {__index = function(_, key)
        local compMethod = Components and Components.WindowMethods and Components.WindowMethods[key]
        return compMethod or self.WindowMethods[key]
    end})
    
    return window
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW METHODS
-- ═══════════════════════════════════════════════════════════════

AetherUI.WindowMethods = {}

function AetherUI.WindowMethods:AddTab(tabConfig)
    return Components and Components.CreateTab(self, tabConfig)
        or self.Library:CreateTabInternal(self, tabConfig)
end

function AetherUI.WindowMethods:Notify(notifyConfig)
    return self.Library:CreateNotification(notifyConfig)
end

function AetherUI.WindowMethods:Show()
    self.MainContainer.Visible = true
    self.Library.AnimationManager:FadeIn(self.MainContainer, 0.3)
end

function AetherUI.WindowMethods:Hide()
    local tween = TweenService:Create(self.MainContainer, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        self.MainContainer.Visible = false
    end)
end

function AetherUI.WindowMethods:SetTitle(newTitle)
    self.Config.Title = newTitle
    local titleText = self.TitleBar:FindFirstChild("TitleText")
    if titleText then
        titleText.Text = newTitle
    end
end

function AetherUI.WindowMethods:SetSize(width, height)
    self.Config.Width = width
    self.Config.Height = height
    TweenService:Create(self.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Size = UDim2.new(0, width, 0, height)
    }):Play()
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW CONTROLS
-- ═══════════════════════════════════════════════════════════════

function AetherUI:CreateControlButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = "Control" .. text
    btn.Size = UDim2.new(0, 20, 0, 20)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    local symbol = Instance.new("TextLabel")
    symbol.Name = "Symbol"
    symbol.Size = UDim2.new(1, 0, 1, 0)
    symbol.BackgroundTransparency = 1
    symbol.Text = text
    symbol.TextColor3 = Color3.fromRGB(40, 40, 40)
    symbol.TextSize = 12
    symbol.Font = Enum.Font.GothamBold
    symbol.Parent = btn
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    return btn
end

function AetherUI:MakeDraggable(window, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.MainContainer.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
           or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(window.MainContainer, TweenInfo.new(0.1), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

function AetherUI:MakeResizable(window)
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 16, 0, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.AutoButtonColor = false
    resizeHandle.Parent = window.GlassBackground
    
    -- Resize icon (diagonal lines)
    local resizeIcon = Instance.new("ImageLabel")
    resizeIcon.Name = "ResizeIcon"
    resizeIcon.Size = UDim2.new(0, 12, 0, 12)
    resizeIcon.Position = UDim2.new(0, 2, 0, 2)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Image = "rbxassetid://3926305904"
    resizeIcon.ImageRectOffset = Vector2.new(84, 324)
    resizeIcon.ImageRectSize = Vector2.new(36, 36)
    resizeIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
    resizeIcon.ImageTransparency = 0.5
    resizeIcon.Parent = resizeHandle
    
    local resizing = false
    local resizeStart, startSize
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = window.MainContainer.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.max(window.Config.MinWidth, startSize.X + delta.X)
            local newHeight = math.max(window.Config.MinHeight, startSize.Y + delta.Y)
            window.MainContainer.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

function AetherUI:CloseWindow(window)
    -- Close animation
    TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(
            window.MainContainer.Position.X.Scale, 
            window.MainContainer.Position.X.Offset + window.MainContainer.AbsoluteSize.X / 2,
            window.MainContainer.Position.Y.Scale,
            window.MainContainer.Position.Y.Offset + window.MainContainer.AbsoluteSize.Y / 2
        ),
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.35, function()
        window.ScreenGui:Destroy()
        for i, w in ipairs(self.Windows) do
            if w == window then
                table.remove(self.Windows, i)
                break
            end
        end
        if self.ActiveWindow == window then
            self.ActiveWindow = self.Windows[#self.Windows]
        end
    end)
end

function AetherUI:MinimizeWindow(window)
    if window.IsMinimized then
        -- Restore
        TweenService:Create(window.MainContainer, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = window.OriginalSize,
            BackgroundTransparency = 0
        }):Play()
        window.GlassBackground.Visible = true
        window.IsMinimized = false
    else
        -- Minimize
        window.OriginalSize = window.MainContainer.Size
        TweenService:Create(window.MainContainer, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 200, 0, 42),
            BackgroundTransparency = 0.3
        }):Play()
        window.IsMinimized = true
    end
end

function AetherUI:MaximizeWindow(window)
    if window.IsMaximized then
        -- Restore
        TweenService:Create(window.MainContainer, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = window.OriginalSize,
            Position = window.OriginalPosition
        }):Play()
        window.IsMaximized = false
    else
        -- Maximize
        window.OriginalSize = window.MainContainer.Size
        window.OriginalPosition = window.MainContainer.Position
        TweenService:Create(window.MainContainer, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10)
        }):Play()
        window.IsMaximized = true
    end
end

-- ═══════════════════════════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:CreateTabInternal(window, tabConfig)
    tabConfig = tabConfig or {}
    local tabName = tabConfig.Name or "Tab"
    local tabIcon = tabConfig.Icon or nil
    
    -- Tab button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. tabName
    tabBtn.Size = UDim2.new(0, 0, 1, -4)
    tabBtn.AutomaticSize = Enum.AutomaticSize.X
    tabBtn.BackgroundColor3 = self.CurrentTheme.TabInactive or Color3.fromRGB(45, 45, 55)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = window.TabContainer
    
    local tabBtnPadding = Instance.new("UIPadding")
    tabBtnPadding.PaddingLeft = UDim.new(0, 14)
    tabBtnPadding.PaddingRight = UDim.new(0, 14)
    tabBtnPadding.Parent = tabBtn
    
    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 8)
    tabBtnCorner.Parent = tabBtn
    
    -- Tab button content
    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBtnLayout.Padding = UDim.new(0, 6)
    tabBtnLayout.Parent = tabBtn
    
    -- Icon
    if tabIcon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "TabIcon"
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.BackgroundTransparency = 1
        icon.Image = Icons and Icons.Get(tabIcon) or tabIcon
        icon.ImageColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(150, 150, 150)
        icon.Parent = tabBtn
    end
    
    -- Tab text
    local tabText = Instance.new("TextLabel")
    tabText.Name = "TabText"
    tabText.Size = UDim2.new(0, 0, 1, 0)
    tabText.AutomaticSize = Enum.AutomaticSize.X
    tabText.BackgroundTransparency = 1
    tabText.Text = tabName
    tabText.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(150, 150, 150)
    tabText.TextSize = 12
    tabText.Font = Enum.Font.GothamSemibold
    tabText.Parent = tabBtn
    
    -- Tab page
    local tabPage = Instance.new("ScrollingFrame")
    tabPage.Name = "Page_" .. tabName
    tabPage.Size = UDim2.new(1, 0, 1, 0)
    tabPage.BackgroundTransparency = 1
    tabPage.BorderSizePixel = 0
    tabPage.ScrollBarThickness = 3
    tabPage.ScrollBarImageColor3 = self.CurrentTheme.ScrollBar or Color3.fromRGB(80, 80, 90)
    tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabPage.Visible = false
    tabPage.Parent = window.TabPages
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.FillDirection = Enum.FillDirection.Vertical
    pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = tabPage
    
    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 8)
    pagePadding.PaddingBottom = UDim.new(0, 8)
    pagePadding.PaddingLeft = UDim.new(0, 8)
    pagePadding.PaddingRight = UDim.new(0, 8)
    pagePadding.Parent = tabPage
    
    -- Tab object
    local tab = {
        Type = "Tab",
        Name = tabName,
        Button = tabBtn,
        Page = tabPage,
        Window = window,
        Sections = {},
        Library = self,
    }
    
    -- Tab activation
    tabBtn.MouseButton1Click:Connect(function()
        window.Library:ActivateTab(window, tab)
    end)
    
    -- Hover effects
    tabBtn.MouseEnter:Connect(function()
        if window.ActiveTab ~= tab then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.8
            }):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if window.ActiveTab ~= tab then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    table.insert(window.Tabs, tab)
    
    -- Auto-activate first tab
    if #window.Tabs == 1 then
        self:ActivateTab(window, tab)
    end
    
    -- Tab API
    function tab:AddSection(sectionConfig)
        return Components and Components.CreateSection(tab, sectionConfig)
            or window.Library:CreateSectionInternal(tab, sectionConfig)
    end
    
    function tab:AddButton(config)
        return Components and Components.CreateButton(tab, config)
            or window.Library:CreateButtonInternal(tab, config)
    end
    
    function tab:AddToggle(config)
        return Components and Components.CreateToggle(tab, config)
            or window.Library:CreateToggleInternal(tab, config)
    end
    
    function tab:AddSlider(config)
        return Components and Components.CreateSlider(tab, config)
            or window.Library:CreateSliderInternal(tab, config)
    end
    
    function tab:AddDropdown(config)
        return Components and Components.CreateDropdown(tab, config)
            or window.Library:CreateDropdownInternal(tab, config)
    end
    
    function tab:AddTextbox(config)
        return Components and Components.CreateTextbox(tab, config)
            or window.Library:CreateTextboxInternal(tab, config)
    end
    
    function tab:AddLabel(config)
        return Components and Components.CreateLabel(tab, config)
            or window.Library:CreateLabelInternal(tab, config)
    end
    
    function tab:AddKeybind(config)
        return Components and Components.CreateKeybind(tab, config)
            or window.Library:CreateKeybindInternal(tab, config)
    end
    
    function tab:AddColorPicker(config)
        return Components and Components.CreateColorPicker(tab, config)
            or window.Library:CreateColorPickerInternal(tab, config)
    end
    
    return tab
end

function AetherUI:ActivateTab(window, tab)
    if window.ActiveTab == tab then return end
    
    -- Deactivate current
    if window.ActiveTab then
        local current = window.ActiveTab
        TweenService:Create(current.Button, TweenInfo.new(0.25), {
            BackgroundTransparency = 1,
            BackgroundColor3 = self.CurrentTheme.TabInactive or Color3.fromRGB(45, 45, 55)
        }):Play()
        current.Button:FindFirstChild("TabText").TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(150, 150, 150)
        
        -- Fade out page
        TweenService:Create(current.Page, TweenInfo.new(0.2), {
            ScrollBarImageTransparency = 1
        }):Play()
        current.Page.Visible = false
    end
    
    -- Activate new
    window.ActiveTab = tab
    TweenService:Create(tab.Button, TweenInfo.new(0.25), {
        BackgroundTransparency = 0.15,
        BackgroundColor3 = self.CurrentTheme.TabActive or Color3.fromRGB(60, 60, 75)
    }):Play()
    tab.Button:FindFirstChild("TabText").TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(230, 230, 230)
    
    -- Fade in page
    tab.Page.Visible = true
    tab.Page.ScrollBarImageTransparency = 0
    tab.Page.CanvasPosition = Vector2.new(0, 0)
    
    -- Page entrance animation
    if self.Config.Theme.AnimationsEnabled then
        tab.Page.Position = UDim2.new(0.02, 0, 0, 0)
        TweenService:Create(tab.Page, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function AetherUI.DeepMergeTables(base, override)
    local result = {}
    for k, v in pairs(base) do
        if typeof(v) == "table" and typeof(override[k]) == "table" then
            result[k] = AetherUI.DeepMergeTables(v, override[k])
        else
            result[k] = override[k] ~= nil and override[k] or v
        end
    end
    for k, v in pairs(override) do
        if base[k] == nil then
            result[k] = v
        end
    end
    return result
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE KEY MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

function AetherUI:SetupToggleKey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.Config.Window.ToggleKey then
            self:ToggleUI()
        end
    end)
end

function AetherUI:ToggleUI()
    self.IsOpen = not self.IsOpen
    for _, window in ipairs(self.Windows) do
        if self.IsOpen then
            window.MainContainer.Visible = true
            TweenService:Create(window.MainContainer, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = window.OriginalSize,
                BackgroundTransparency = 0
            }):Play()
        else
            TweenService:Create(window.MainContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.3, function()
                if not self.IsOpen then
                    window.MainContainer.Visible = false
                end
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:CreateNotification(config)
    config = config or {}
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local notifyType = config.Type or "Info"  -- "Info", "Success", "Warning", "Error"
    local duration = config.Duration or self.Config.Notifications.Duration
    local icon = config.Icon or nil
    
    local typeColors = {
        Info = Color3.fromRGB(100, 150, 255),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 60),
        Error = Color3.fromRGB(255, 90, 80),
    }
    local accentColor = typeColors[notifyType] or typeColors.Info
    
    -- Notification container
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "AetherNotification"
    notifyGui.ResetOnSpawn = false
    notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifyGui.DisplayOrder = 1000
    notifyGui.Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    -- Calculate position based on config
    local position = self.Config.Notifications.Position
    local isRight = position:match("Right") ~= nil
    local isBottom = position:match("Bottom") ~= nil
    
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Name = "Notification"
    notifyFrame.Size = UDim2.new(0, 300, 0, 0)
    notifyFrame.AutomaticSize = Enum.AutomaticSize.Y
    notifyFrame.BackgroundColor3 = self.CurrentTheme.NotificationBg or Color3.fromRGB(40, 40, 48)
    notifyFrame.BackgroundTransparency = 0.05
    notifyFrame.BorderSizePixel = 0
    notifyFrame.Parent = notifyGui
    
    -- Position
    local xOffset = isRight and -20 or 20
    local yOffset = isBottom and -20 or 20
    notifyFrame.Position = UDim2.new(isRight and 1 or 0, xOffset, isBottom and 1 or 0, yOffset)
    notifyFrame.AnchorPoint = Vector2.new(isRight and 1 or 0, isBottom and 1 or 0)
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notifyFrame
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notifyFrame
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar
    
    -- Content padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = notifyFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 6)
    layout.Parent = notifyFrame
    
    -- Title row
    local titleRow = Instance.new("Frame")
    titleRow.Name = "TitleRow"
    titleRow.Size = UDim2.new(1, 0, 0, 20)
    titleRow.BackgroundTransparency = 1
    titleRow.Parent = notifyFrame
    
    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleLayout.Padding = UDim.new(0, 8)
    titleLayout.Parent = titleRow
    
    if icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "NotifyIcon"
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = Icons and Icons.Get(icon) or icon
        iconImg.ImageColor3 = accentColor
        iconImg.Parent = titleRow
    end
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "NotifyTitle"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleRow
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "NotifyContent"
    contentLabel.Size = UDim2.new(1, -8, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(170, 170, 180)
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notifyFrame
    
    -- Progress bar (auto-dismiss)
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BackgroundTransparency = 0.3
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notifyFrame
    
    -- Store notification
    local notification = {
        Frame = notifyFrame,
        Gui = notifyGui,
        StartTime = tick(),
        Duration = duration,
    }
    table.insert(self.Notifications, notification)
    
    -- Entrance animation
    notifyFrame.BackgroundTransparency = 1
    local targetTransparency = 0.05
    
    if isRight then
        notifyFrame.Position = UDim2.new(1, 50, notifyFrame.Position.Y.Scale, notifyFrame.Position.Y.Offset)
    else
        notifyFrame.Position = UDim2.new(0, -50, notifyFrame.Position.Y.Scale, notifyFrame.Position.Y.Offset)
    end
    
    TweenService:Create(notifyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(isRight and 1 or 0, xOffset, notifyFrame.Position.Y.Scale, notifyFrame.Position.Y.Offset),
        BackgroundTransparency = targetTransparency
    }):Play()
    
    -- Progress bar animation
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()
    
    -- Auto dismiss
    task.delay(duration, function()
        self:DismissNotification(notification)
    end)
    
    return notification
end

function AetherUI:DismissNotification(notification)
    -- Exit animation
    local isRight = self.Config.Notifications.Position:match("Right") ~= nil
    
    TweenService:Create(notification.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(
            isRight and 1 or 0, 
            isRight and 50 or -50,
            notification.Frame.Position.Y.Scale,
            notification.Frame.Position.Y.Offset
        ),
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.35, function()
        notification.Gui:Destroy()
        for i, n in ipairs(self.Notifications) do
            if n == notification then
                table.remove(self.Notifications, i)
                break
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- DIALOG / POPUP SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:CreateDialog(config)
    config = config or {}
    local title = config.Title or "Dialog"
    local content = config.Content or ""
    local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
    
    -- Darken background
    local dialogGui = Instance.new("ScreenGui")
    dialogGui.Name = "AetherDialog"
    dialogGui.ResetOnSpawn = false
    dialogGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    dialogGui.DisplayOrder = 2000
    dialogGui.Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Parent = dialogGui
    
    -- Dialog frame
    local dialogFrame = Instance.new("Frame")
    dialogFrame.Name = "Dialog"
    dialogFrame.Size = UDim2.new(0, 380, 0, 0)
    dialogFrame.AutomaticSize = Enum.AutomaticSize.Y
    dialogFrame.Position = UDim2.new(0.5, -190, 0.5, -100)
    dialogFrame.BackgroundColor3 = self.CurrentTheme.DialogBg or Color3.fromRGB(45, 45, 55)
    dialogFrame.BackgroundTransparency = 0.02
    dialogFrame.BorderSizePixel = 0
    dialogFrame.Parent = overlay
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 16)
    dialogCorner.Parent = dialogFrame
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 20)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.PaddingLeft = UDim.new(0, 24)
    padding.PaddingRight = UDim.new(0, 24)
    padding.Parent = dialogFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 14)
    layout.Parent = dialogFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "DialogTitle"
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = dialogFrame
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "DialogContent"
    contentLabel.Size = UDim2.new(1, 0, 0, 0)
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(170, 170, 180)
    contentLabel.TextSize = 13
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = dialogFrame
    
    -- Buttons row
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "Buttons"
    buttonsFrame.Size = UDim2.new(1, 0, 0, 36)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = dialogFrame
    
    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    buttonsLayout.Padding = UDim.new(0, 10)
    buttonsLayout.Parent = buttonsFrame
    
    -- Create buttons
    for i, btnConfig in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = "DialogBtn_" .. btnConfig.Text
        btn.Size = UDim2.new(0, 0, 1, 0)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = btnConfig.Primary and (self.CurrentTheme.Accent or Color3.fromRGB(100, 150, 255))
            or (self.CurrentTheme.ButtonSecondary or Color3.fromRGB(60, 60, 72))
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = buttonsFrame
        
        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 16)
        btnPadding.PaddingRight = UDim.new(0, 16)
        btnPadding.Parent = btn
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        local btnText = Instance.new("TextLabel")
        btnText.Name = "BtnText"
        btnText.Size = UDim2.new(1, 0, 1, 0)
        btnText.BackgroundTransparency = 1
        btnText.Text = btnConfig.Text
        btnText.TextColor3 = btnConfig.Primary and Color3.fromRGB(255, 255, 255)
            or (self.CurrentTheme.TextPrimary or Color3.fromRGB(230, 230, 230))
        btnText.TextSize = 13
        btnText.Font = Enum.Font.GothamSemibold
        btnText.Parent = btn
        
        -- Hover
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        -- Click
        btn.MouseButton1Click:Connect(function()
            -- Close dialog
            TweenService:Create(overlay, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(dialogFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -190, 0.5, -80),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.3, function()
                dialogGui:Destroy()
            end)
            
            if btnConfig.Callback then
                btnConfig.Callback()
            end
        end)
    end
    
    -- Entrance animations
    TweenService:Create(overlay, TweenInfo.new(0.25), {
        BackgroundTransparency = 0.5
    }):Play()
    
    dialogFrame.BackgroundTransparency = 1
    dialogFrame.Position = UDim2.new(0.5, -190, 0.45, -100)
    TweenService:Create(dialogFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -190, 0.5, -100),
        BackgroundTransparency = 0.02
    }):Play()
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG SAVE/LOAD
-- ═══════════════════════════════════════════════════════════════

function AetherUI:StartAutoSave()
    task.spawn(function()
        while true do
            task.wait(self.Config.AutoSaveInterval)
            if #self.Windows > 0 then
                self:SaveConfig()
            end
        end
    end)
end

function AetherUI:SaveConfig()
    local configData = {
        Theme = self.Config.Theme.Mode,
        CustomTheme = self.Config.Theme.CustomTheme,
        AnimationSpeed = self.Config.Theme.AnimationSpeed,
        SoundEnabled = self.Config.Theme.SoundEnabled,
        WindowSizes = {},
    }
    
    for i, window in ipairs(self.Windows) do
        configData.WindowSizes[i] = {
            Width = window.Config.Width,
            Height = window.Config.Height,
        }
    end
    
    -- Save to file (would use writefile in executor environments)
    local json = HttpService:JSONEncode(configData)
    pcall(function()
        if writefile then
            writefile(self.Config.ConfigFolder .. "/config.json", json)
        end
    end)
    
    return json
end

function AetherUI:LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(self.Config.ConfigFolder .. "/config.json") then
            local json = readfile(self.Config.ConfigFolder .. "/config.json")
            local data = HttpService:JSONDecode(json)
            
            if data then
                if data.Theme then
                    self.Config.Theme.Mode = data.Theme
                end
                if data.CustomTheme then
                    self.Config.Theme.CustomTheme = data.CustomTheme
                end
                if data.AnimationSpeed then
                    self.Config.Theme.AnimationSpeed = data.AnimationSpeed
                end
                if data.SoundEnabled ~= nil then
                    self.Config.Theme.SoundEnabled = data.SoundEnabled
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PLUGIN SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:RegisterPlugin(pluginName, pluginData)
    self.Plugins[pluginName] = pluginData
    
    if pluginData.Init then
        pluginData.Init(self)
    end
    
    -- Trigger hook
    self:TriggerHook("PluginLoaded", pluginName, pluginData)
    
    return pluginData
end

function AetherUI:GetPlugin(pluginName)
    return self.Plugins[pluginName]
end

-- ═══════════════════════════════════════════════════════════════
-- HOOK SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:AddHook(eventName, callback)
    if not self.Hooks[eventName] then
        self.Hooks[eventName] = {}
    end
    table.insert(self.Hooks[eventName], callback)
end

function AetherUI:TriggerHook(eventName, ...)
    if self.Hooks[eventName] then
        for _, callback in ipairs(self.Hooks[eventName]) do
            task.spawn(callback, ...)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SOUND EFFECTS
-- ═══════════════════════════════════════════════════════════════

function AetherUI:PlaySound(soundId, volume)
    if not self.Config.Theme.SoundEnabled then return end
    
    volume = volume or self.Config.Theme.SoundVolume
    
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = volume
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SHORTCUT SYSTEM
-- ═══════════════════════════════════════════════════════════════

function AetherUI:RegisterShortcut(keyCode, callback, description)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == keyCode then
            callback()
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN LIBRARY
-- ═══════════════════════════════════════════════════════════════

-- Predefined themes
AetherUI.DarkTheme = {
    Name = "Dark",
    Background = Color3.fromRGB(22, 22, 28),
    TitleBar = Color3.fromRGB(30, 30, 38),
    TabActive = Color3.fromRGB(55, 55, 68),
    TabInactive = Color3.fromRGB(40, 40, 50),
    Accent = Color3.fromRGB(100, 150, 255),
    AccentLight = Color3.fromRGB(130, 175, 255),
    TextPrimary = Color3.fromRGB(230, 230, 235),
    TextSecondary = Color3.fromRGB(150, 150, 165),
    TextTertiary = Color3.fromRGB(100, 100, 115),
    ButtonPrimary = Color3.fromRGB(100, 150, 255),
    ButtonSecondary = Color3.fromRGB(55, 55, 68),
    ButtonHover = Color3.fromRGB(75, 120, 230),
    SectionBg = Color3.fromRGB(30, 30, 38),
    SectionBorder = Color3.fromRGB(45, 45, 58),
    InputBg = Color3.fromRGB(38, 38, 48),
    InputBorder = Color3.fromRGB(55, 55, 70),
    ToggleOn = Color3.fromRGB(100, 150, 255),
    ToggleOff = Color3.fromRGB(55, 55, 68),
    SliderTrack = Color3.fromRGB(45, 45, 58),
    SliderFill = Color3.fromRGB(100, 150, 255),
    DropdownBg = Color3.fromRGB(38, 38, 48),
    NotificationBg = Color3.fromRGB(35, 35, 45),
    DialogBg = Color3.fromRGB(40, 40, 52),
    ScrollBar = Color3.fromRGB(70, 70, 85),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(255, 90, 80),
    Info = Color3.fromRGB(100, 150, 255),
}

AetherUI.LightTheme = {
    Name = "Light",
    Background = Color3.fromRGB(245, 245, 250),
    TitleBar = Color3.fromRGB(235, 235, 242),
    TabActive = Color3.fromRGB(220, 220, 232),
    TabInactive = Color3.fromRGB(235, 235, 242),
    Accent = Color3.fromRGB(80, 130, 240),
    AccentLight = Color3.fromRGB(110, 155, 250),
    TextPrimary = Color3.fromRGB(40, 40, 50),
    TextSecondary = Color3.fromRGB(100, 100, 120),
    TextTertiary = Color3.fromRGB(150, 150, 165),
    ButtonPrimary = Color3.fromRGB(80, 130, 240),
    ButtonSecondary = Color3.fromRGB(220, 220, 232),
    ButtonHover = Color3.fromRGB(60, 110, 220),
    SectionBg = Color3.fromRGB(250, 250, 255),
    SectionBorder = Color3.fromRGB(210, 210, 225),
    InputBg = Color3.fromRGB(255, 255, 255),
    InputBorder = Color3.fromRGB(200, 200, 215),
    ToggleOn = Color3.fromRGB(80, 130, 240),
    ToggleOff = Color3.fromRGB(200, 200, 215),
    SliderTrack = Color3.fromRGB(210, 210, 225),
    SliderFill = Color3.fromRGB(80, 130, 240),
    DropdownBg = Color3.fromRGB(255, 255, 255),
    NotificationBg = Color3.fromRGB(255, 255, 255),
    DialogBg = Color3.fromRGB(250, 250, 255),
    ScrollBar = Color3.fromRGB(180, 180, 195),
    Success = Color3.fromRGB(60, 180, 100),
    Warning = Color3.fromRGB(230, 160, 40),
    Error = Color3.fromRGB(230, 70, 60),
    Info = Color3.fromRGB(80, 130, 240),
}

return AetherUI