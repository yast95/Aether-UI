--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                 A E T H E R   U I  V 3                       ║
    ║        Modern, Fully Customizable UI Library                 ║
    ║                                                              ║
    ║  Modernized features:                                        ║
    ║  - Fully customizable components & theming                   ║
    ║  - Black liquid glass design option                          ║
    ║  - Advanced animation system                                 ║
    ║  - Complete theme management                                 ║
    ║  - Modular, extensible architecture                          ║
    ║                                                              ║
    ║  Version: 3.0.0                                              ║
    ║  License: MIT                                                ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local AetherUI = {}
AetherUI.__index = AetherUI

AetherUI.Version = "3.0.0"
AetherUI.Name = "AetherUI"
AetherUI.Author = "Aether Studio"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local Themes = nil
local Animations = nil
local Utils = nil
local Icons = nil
local Components = nil

function AetherUI.LoadModules(modules)
    Themes = modules.Themes or Themes
    Animations = modules.Animations or Animations
    Utils = modules.Utils or Utils
    Icons = modules.Icons or Icons
    Components = modules.Components or Components
end

function AetherUI.GetModules()
    return {
        Themes = Themes,
        Animations = Animations,
        Utils = Utils,
        Icons = Icons,
        Components = Components,
    }
end

AetherUI.DefaultConfig = {
    Window = {
        Title = "AetherUI v3",
        SubTitle = "Modern & Customizable",
        Width = 700,
        Height = 500,
        MinWidth = 400,
        MinHeight = 300,
        CornerRadius = 12,
        BlurEnabled = true,
        BlurIntensity = 0.15,
        ShadowEnabled = true,
        ShadowIntensity = 0.4,
        AnimationSpeed = 0.3,
        Draggable = true,
        Resizable = true,
        StartCentered = true,
        ToggleKey = Enum.KeyCode.RightShift,
    },
    
    Theme = {
        Mode = "BlackGlass",
        CustomTheme = nil,
        AnimationsEnabled = true,
        AnimationSpeed = 0.3,
        SoundEnabled = false,
        SoundVolume = 0.3,
        GlassEffect = true,
        GlassTransparency = 0.15,
        BlurRadius = 20,
    },
    
    Components = {
        CornerRadius = 8,
        Padding = 12,
        Spacing = 8,
        ButtonHeight = 36,
        ToggleSize = 24,
        SliderHeight = 6,
        DropdownMaxHeight = 250,
    },
    
    Notifications = {
        Position = "TopRight",
        Duration = 4,
        MaxVisible = 5,
        Stacking = "Down",
    },
    
    SaveConfig = true,
    ConfigFolder = "AetherUI_Configs",
    AutoSaveInterval = 30,
}

function AetherUI.new(userConfig)
    local self = setmetatable({}, AetherUI)
    
    self.Config = Utils and Utils.DeepMerge(AetherUI.DefaultConfig, userConfig or {})
        or AetherUI.DeepMergeTables(AetherUI.DefaultConfig, userConfig or {})
    
    self.Windows = {}
    self.ActiveWindow = nil
    self.Notifications = {}
    self.Plugins = {}
    self.Hooks = {}
    self.IsOpen = true
    
    self:InitializeSystems()
    self:SetupToggleKey()
    
    if self.Config.SaveConfig then
        self:StartAutoSave()
    end
    
    return self
end

function AetherUI:InitializeSystems()
    self.ThemeManager = Themes and Themes.new(self.Config.Theme) or {
        GetCurrentTheme = function() return {Background = Color3.fromRGB(18, 18, 24)} end,
        ApplyTheme = function() end,
    }
    
    self.AnimationManager = Animations and Animations.new(self.Config.Theme) or {
        Tween = function(_, obj, props, duration, easing)
            local tweenInfo = TweenInfo.new(duration or 0.3, easing or Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(obj, tweenInfo, props):Play()
        end,
        FadeIn = function(_, obj, duration)
            obj.BackgroundTransparency = 1
            local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            TweenService:Create(obj, tweenInfo, {BackgroundTransparency = obj:GetAttribute("TargetTransparency") or 0}):Play()
        end,
    }
    
    self.CurrentTheme = self.ThemeManager:GetCurrentTheme()
end

function AetherUI:CreateWindow(windowConfig)
    windowConfig = windowConfig or {}
    
    local config = {}
    for k, v in pairs(self.Config.Window) do config[k] = v end
    for k, v in pairs(windowConfig) do config[k] = v end
    
    local window = Components and Components.CreateWindow(self, config)
        or self:CreateWindowInternal(config)
    
    table.insert(self.Windows, window)
    self.ActiveWindow = window
    
    return window
end

function AetherUI:CreateWindowInternal(config)
    local guiParent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")
        or CoreGui
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AetherUI_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = guiParent
    
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
    
    if config.ShadowEnabled then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 40, 1, 40)
        shadow.Position = UDim2.new(0, -20, 0, -20)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = self.CurrentTheme.ShadowColor or Color3.fromRGB(0, 0, 0)
        shadow.ImageTransparency = 1 - config.ShadowIntensity
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = 0
        shadow.Parent = mainContainer
    end
    
    local glassBg = Instance.new("Frame")
    glassBg.Name = "GlassBackground"
    glassBg.Size = UDim2.new(1, 0, 1, 0)
    glassBg.BackgroundColor3 = self.CurrentTheme.Background or Color3.fromRGB(18, 18, 24)
    glassBg.BackgroundTransparency = config.BlurEnabled and (1 - config.BlurIntensity) or 0.1
    glassBg.BorderSizePixel = 0
    glassBg.Parent = mainContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, config.CornerRadius)
    corner.Parent = glassBg
    
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
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 48)
    titleBar.BackgroundColor3 = self.CurrentTheme.TitleBar or Color3.fromRGB(12, 12, 18)
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.Parent = glassBg
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, config.CornerRadius)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Name = "CornerFix"
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = titleBar.BackgroundColor3
    titleFix.BackgroundTransparency = titleBar.BackgroundTransparency
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 28, 0, 28)
    titleIcon.Position = UDim2.new(0, 14, 0, 10)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Image = Icons and Icons.Get("Aether") or ""
    titleIcon.ImageColor3 = self.CurrentTheme.Accent or Color3.fromRGB(0, 200, 255)
    titleIcon.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(0, 250, 1, 0)
    titleText.Position = UDim2.new(0, 50, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(235, 235, 245)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local subTitle = Instance.new("TextLabel")
    subTitle.Name = "SubTitle"
    subTitle.Size = UDim2.new(0, 150, 0, 16)
    subTitle.Position = UDim2.new(0, 50, 0, 24)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = config.SubTitle
    subTitle.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(160, 160, 180)
    subTitle.TextSize = 11
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextXAlignment = Enum.TextXAlignment.Left
    subTitle.Parent = titleBar
    
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.new(0, 90, 0, 36)
    controlsFrame.Position = UDim2.new(1, -100, 0, 6)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 6)
    controlsLayout.Parent = controlsFrame
    
    local btnMinimize = self:CreateControlButton(controlsFrame, "−", Color3.fromRGB(255, 180, 60))
    local btnMaximize = self:CreateControlButton(controlsFrame, "□", Color3.fromRGB(60, 200, 120))
    local btnClose = self:CreateControlButton(controlsFrame, "×", Color3.fromRGB(255, 80, 100))
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -68)
    contentFrame.Position = UDim2.new(0, 10, 0, 56)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = glassBg
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = contentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabContainer
    
    local tabPages = Instance.new("Frame")
    tabPages.Name = "TabPages"
    tabPages.Size = UDim2.new(1, 0, 1, -48)
    tabPages.Position = UDim2.new(0, 0, 0, 40)
    tabPages.BackgroundTransparency = 1
    tabPages.BorderSizePixel = 0
    tabPages.ClipsDescendants = true
    tabPages.Parent = contentFrame
    
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
    
    if config.Draggable then
        self:MakeDraggable(window, titleBar)
    end
    
    if config.Resizable then
        self:MakeResizable(window)
    end
    
    btnClose.MouseButton1Click:Connect(function()
        self:CloseWindow(window)
    end)
    
    btnMinimize.MouseButton1Click:Connect(function()
        self:MinimizeWindow(window)
    end)
    
    btnMaximize.MouseButton1Click:Connect(function()
        self:MaximizeWindow(window)
    end)
    
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainContainer.BackgroundTransparency = 1
    
    local enterTween = TweenService:Create(mainContainer, TweenInfo.new(
        config.AnimationSpeed or 0.3,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ), {
        Size = UDim2.new(0, config.Width, 0, config.Height),
        Position = config.StartCentered
            and UDim2.new(0.5, -config.Width/2, 0.5, -config.Height/2)
            or UDim2.new(0.1, 0, 0.1, 0),
    })
    enterTween:Play()
    
    setmetatable(window, {__index = function(_, key)
        local compMethod = Components and Components.WindowMethods and Components.WindowMethods[key]
        return compMethod or self.WindowMethods[key]
    end})
    
    return window
end

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

function AetherUI:CreateControlButton(parent, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = "Control" .. text
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.4
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local symbol = Instance.new("TextLabel")
    symbol.Name = "Symbol"
    symbol.Size = UDim2.new(1, 0, 1, 0)
    symbol.BackgroundTransparency = 1
    symbol.Text = text
    symbol.TextColor3 = Color3.fromRGB(240, 240, 245)
    symbol.TextSize = 13
    symbol.Font = Enum.Font.GothamBold
    symbol.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.4
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
            TweenService:Create(window.MainContainer, TweenInfo.new(0.08), {
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
    resizeHandle.Size = UDim2.new(0, 18, 0, 18)
    resizeHandle.Position = UDim2.new(1, -18, 1, -18)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.AutoButtonColor = false
    resizeHandle.Parent = window.GlassBackground
    
    local resizeIcon = Instance.new("ImageLabel")
    resizeIcon.Name = "ResizeIcon"
    resizeIcon.Size = UDim2.new(0, 14, 0, 14)
    resizeIcon.Position = UDim2.new(0, 2, 0, 2)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Image = "rbxassetid://3926305904"
    resizeIcon.ImageRectOffset = Vector2.new(84, 324)
    resizeIcon.ImageRectSize = Vector2.new(36, 36)
    resizeIcon.ImageColor3 = Color3.fromRGB(150, 150, 170)
    resizeIcon.ImageTransparency = 0.4
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
        TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = window.OriginalSize,
            BackgroundTransparency = 0
        }):Play()
        window.GlassBackground.Visible = true
        window.IsMinimized = false
    else
        window.OriginalSize = window.MainContainer.Size
        TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 220, 0, 48),
            BackgroundTransparency = 0.3
        }):Play()
        window.IsMinimized = true
    end
end

function AetherUI:MaximizeWindow(window)
    if window.IsMaximized then
        TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = window.OriginalSize,
            Position = window.OriginalPosition
        }):Play()
        window.IsMaximized = false
    else
        window.OriginalSize = window.MainContainer.Size
        window.OriginalPosition = window.MainContainer.Position
        TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10)
        }):Play()
        window.IsMaximized = true
    end
end

function AetherUI:CreateTabInternal(window, tabConfig)
    tabConfig = tabConfig or {}
    local tabName = tabConfig.Name or "Tab"
    local tabIcon = tabConfig.Icon or nil
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. tabName
    tabBtn.Size = UDim2.new(0, 0, 1, -6)
    tabBtn.AutomaticSize = Enum.AutomaticSize.X
    tabBtn.BackgroundColor3 = self.CurrentTheme.TabInactive or Color3.fromRGB(32, 32, 44)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = window.TabContainer
    
    local tabBtnPadding = Instance.new("UIPadding")
    tabBtnPadding.PaddingLeft = UDim.new(0, 16)
    tabBtnPadding.PaddingRight = UDim.new(0, 16)
    tabBtnPadding.Parent = tabBtn
    
    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 8)
    tabBtnCorner.Parent = tabBtn
    
    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBtnLayout.Padding = UDim.new(0, 6)
    tabBtnLayout.Parent = tabBtn
    
    if tabIcon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "TabIcon"
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.BackgroundTransparency = 1
        icon.Image = Icons and Icons.Get(tabIcon) or tabIcon
        icon.ImageColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(160, 160, 180)
        icon.Parent = tabBtn
    end
    
    local tabText = Instance.new("TextLabel")
    tabText.Name = "TabText"
    tabText.Size = UDim2.new(0, 0, 1, 0)
    tabText.AutomaticSize = Enum.AutomaticSize.X
    tabText.BackgroundTransparency = 1
    tabText.Text = tabName
    tabText.TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(160, 160, 180)
    tabText.TextSize = 13
    tabText.Font = Enum.Font.GothamSemibold
    tabText.Parent = tabBtn
    
    local tabPage = Instance.new("ScrollingFrame")
    tabPage.Name = "Page_" .. tabName
    tabPage.Size = UDim2.new(1, 0, 1, 0)
    tabPage.BackgroundTransparency = 1
    tabPage.BorderSizePixel = 0
    tabPage.ScrollBarThickness = 3
    tabPage.ScrollBarImageColor3 = self.CurrentTheme.ScrollBar or Color3.fromRGB(70, 70, 90)
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
    
    local tab = {
        Type = "Tab",
        Name = tabName,
        Button = tabBtn,
        Page = tabPage,
        Window = window,
        Sections = {},
        Library = self,
    }
    
    tabBtn.MouseButton1Click:Connect(function()
        window.Library:ActivateTab(window, tab)
    end)
    
    tabBtn.MouseEnter:Connect(function()
        if window.ActiveTab ~= tab then
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.8
            }):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if window.ActiveTab ~= tab then
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 1
            }):Play()
        end
    end)
    
    table.insert(window.Tabs, tab)
    
    if #window.Tabs == 1 then
        self:ActivateTab(window, tab)
    end
    
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
    
    if window.ActiveTab then
        local current = window.ActiveTab
        TweenService:Create(current.Button, TweenInfo.new(0.2), {
            BackgroundTransparency = 1,
            BackgroundColor3 = self.CurrentTheme.TabInactive or Color3.fromRGB(32, 32, 44)
        }):Play()
        current.Button:FindFirstChild("TabText").TextColor3 = self.CurrentTheme.TextSecondary or Color3.fromRGB(160, 160, 180)
        
        TweenService:Create(current.Page, TweenInfo.new(0.2), {
            ScrollBarImageTransparency = 1
        }):Play()
        current.Page.Visible = false
    end
    
    window.ActiveTab = tab
    TweenService:Create(tab.Button, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.12,
        BackgroundColor3 = self.CurrentTheme.TabActive or Color3.fromRGB(48, 48, 66)
    }):Play()
    tab.Button:FindFirstChild("TabText").TextColor3 = self.CurrentTheme.TextPrimary or Color3.fromRGB(235, 235, 245)
    
    tab.Page.Visible = true
    tab.Page.ScrollBarImageTransparency = 0
    tab.Page.CanvasPosition = Vector2.new(0, 0)
    
    if self.Config.Theme.AnimationsEnabled then
        tab.Page.Position = UDim2.new(0.02, 0, 0, 0)
        TweenService:Create(tab.Page, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end

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
            TweenService:Create(window.MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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

function AetherUI:CreateNotification(config)
    config = config or {}
    -- Notification implementation would go here
end

function AetherUI:StartAutoSave()
    -- Auto-save implementation would go here
end

return AetherUI
