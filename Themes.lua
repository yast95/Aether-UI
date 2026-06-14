--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              A E T H E R   U I  —  T H E M E S  V 3           ║
    ║                                                              ║
    ║  Advanced theme management system with:                      ║
    ║  - Light, Dark, Auto modes + Modern presets                  ║
    ║  - Full custom theme support                                 ║
    ║  - Real-time theme switching                                 ║
    ║  - Theme serialization (JSON)                                ║
    ║  - Smooth color transitions                                  ║
    ║  - Fully customizable components                             ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Themes = {}
Themes.__index = Themes

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════
-- COLOR UTILITIES
-- ═══════════════════════════════════════════════════════════════

local ColorUtils = {}

function ColorUtils.ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255))
end

function ColorUtils.FromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

function ColorUtils.ToHSV(color)
    local h, s, v = Color3.toHSV(color)
    return {H = h, S = s, V = v}
end

function ColorUtils.FromHSV(hsv)
    return Color3.fromHSV(hsv.H, hsv.S, hsv.V)
end

function ColorUtils.Lerp(colorA, colorB, t)
    return Color3.new(
        colorA.R + (colorB.R - colorA.R) * t,
        colorA.G + (colorB.G - colorA.G) * t,
        colorA.B + (colorB.B - colorA.B) * t
    )
end

function ColorUtils.AdjustBrightness(color, amount)
    local h, s, v = Color3.toHSV(color)
    v = math.clamp(v + amount, 0, 1)
    return Color3.fromHSV(h, s, v)
end

function ColorUtils.AdjustSaturation(color, amount)
    local h, s, v = Color3.toHSV(color)
    s = math.clamp(s + amount, 0, 1)
    return Color3.fromHSV(h, s, v)
end

function ColorUtils.Complementary(color)
    local h, s, v = Color3.toHSV(color)
    return Color3.fromHSV((h + 0.5) % 1, s, v)
end

function ColorUtils.Analogous(color, count)
    local h, s, v = Color3.toHSV(color)
    local colors = {}
    local step = 1 / count
    for i = 0, count - 1 do
        table.insert(colors, Color3.fromHSV((h + step * i) % 1, s, v))
    end
    return colors
end

function ColorUtils.GetLuminance(color)
    local r, g, b = color.R * 255, color.G * 255, color.B * 255
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255
end

function ColorUtils.GetContrastColor(color)
    local luminance = ColorUtils.GetLuminance(color)
    return luminance > 0.5 and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(235, 235, 240)
end

function ColorUtils.GenerateGradient(colorA, colorB, steps)
    local gradient = {}
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        table.insert(gradient, ColorUtils.Lerp(colorA, colorB, t))
    end
    return gradient
end

function ColorUtils.ToRGB(color)
    return {
        R = math.floor(color.R * 255),
        G = math.floor(color.G * 255),
        B = math.floor(color.B * 255)
    }
end

function ColorUtils.FromRGB(rgb)
    return Color3.fromRGB(rgb.R or 0, rgb.G or 0, rgb.B or 0)
end

-- ═══════════════════════════════════════════════════════════════
-- PREDEFINED MODERN THEMES
-- ═══════════════════════════════════════════════════════════════

Themes.Presets = {}

-- Black Liquid Glass Theme (NEW)
Themes.Presets.BlackGlass = {
    Name = "Black Liquid Glass",
    Description = "Premium black liquid glass design with cyan accents",
    Author = "Aether Studio v3",
    
    Background = Color3.fromRGB(8, 8, 12),
    BackgroundSecondary = Color3.fromRGB(12, 12, 18),
    BackgroundTertiary = Color3.fromRGB(18, 18, 28),
    
    Surface = Color3.fromRGB(15, 15, 22),
    SurfaceHover = Color3.fromRGB(20, 20, 30),
    SurfaceActive = Color3.fromRGB(25, 25, 40),
    SurfaceGlass = Color3.fromRGB(18, 18, 26),
    
    TitleBar = Color3.fromRGB(12, 12, 18),
    TitleBarInactive = Color3.fromRGB(8, 8, 12),
    
    TabActive = Color3.fromRGB(25, 25, 40),
    TabInactive = Color3.fromRGB(18, 18, 28),
    TabHover = Color3.fromRGB(20, 20, 32),
    
    Accent = Color3.fromRGB(0, 200, 255),
    AccentLight = Color3.fromRGB(50, 220, 255),
    AccentDark = Color3.fromRGB(0, 160, 200),
    AccentGlow = Color3.fromRGB(0, 200, 255),
    
    TextPrimary = Color3.fromRGB(240, 240, 250),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextTertiary = Color3.fromRGB(110, 110, 130),
    TextDisabled = Color3.fromRGB(70, 70, 85),
    TextAccent = Color3.fromRGB(0, 200, 255),
    
    ButtonPrimary = Color3.fromRGB(0, 200, 255),
    ButtonPrimaryHover = Color3.fromRGB(50, 220, 255),
    ButtonPrimaryActive = Color3.fromRGB(0, 170, 220),
    ButtonSecondary = Color3.fromRGB(25, 25, 40),
    ButtonSecondaryHover = Color3.fromRGB(35, 35, 55),
    ButtonDanger = Color3.fromRGB(255, 60, 100),
    ButtonDangerHover = Color3.fromRGB(255, 90, 120),
    ButtonSuccess = Color3.fromRGB(0, 220, 100),
    ButtonGhost = Color3.fromRGB(20, 20, 32),
    
    SectionBg = Color3.fromRGB(12, 12, 18),
    SectionBorder = Color3.fromRGB(30, 30, 50),
    SectionHeader = Color3.fromRGB(18, 18, 28),
    
    InputBg = Color3.fromRGB(15, 15, 22),
    InputBorder = Color3.fromRGB(35, 35, 60),
    InputBorderFocus = Color3.fromRGB(0, 200, 255),
    InputBorderError = Color3.fromRGB(255, 60, 100),
    InputPlaceholder = Color3.fromRGB(100, 100, 120),
    
    ToggleOn = Color3.fromRGB(0, 200, 255),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(40, 40, 60),
    ToggleOffKnob = Color3.fromRGB(170, 170, 190),
    ToggleHover = Color3.fromRGB(55, 55, 80),
    
    SliderTrack = Color3.fromRGB(30, 30, 50),
    SliderTrackHover = Color3.fromRGB(40, 40, 65),
    SliderFill = Color3.fromRGB(0, 200, 255),
    SliderFillHover = Color3.fromRGB(50, 220, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(220, 240, 255),
    
    DropdownBg = Color3.fromRGB(15, 15, 22),
    DropdownBorder = Color3.fromRGB(35, 35, 60),
    DropdownItem = Color3.fromRGB(20, 20, 30),
    DropdownItemHover = Color3.fromRGB(30, 30, 50),
    DropdownItemSelected = Color3.fromRGB(25, 25, 40),
    
    NotificationBg = Color3.fromRGB(15, 15, 22),
    NotificationBorder = Color3.fromRGB(35, 35, 60),
    
    DialogBg = Color3.fromRGB(15, 15, 22),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(50, 50, 80),
    ScrollBarHover = Color3.fromRGB(70, 70, 110),
    ScrollBarTrack = Color3.fromRGB(18, 18, 28),
    
    Success = Color3.fromRGB(0, 220, 100),
    SuccessLight = Color3.fromRGB(50, 240, 150),
    Warning = Color3.fromRGB(255, 180, 50),
    WarningLight = Color3.fromRGB(255, 210, 100),
    Error = Color3.fromRGB(255, 60, 100),
    ErrorLight = Color3.fromRGB(255, 100, 130),
    Info = Color3.fromRGB(0, 200, 255),
    InfoLight = Color3.fromRGB(100, 230, 255),
    
    GlassTransparency = 0.15,
    GlassBlur = 20,
    GlowIntensity = 0.8,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.6,
    
    AnimationSpeed = 0.3,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Modern Dark Theme (Refined)
Themes.Presets.ModernDark = {
    Name = "Modern Dark",
    Description = "Sleek modern dark theme with vibrant accents",
    Author = "Aether Studio v3",
    
    Background = Color3.fromRGB(18, 18, 24),
    BackgroundSecondary = Color3.fromRGB(24, 24, 32),
    BackgroundTertiary = Color3.fromRGB(32, 32, 44),
    
    Surface = Color3.fromRGB(28, 28, 38),
    SurfaceHover = Color3.fromRGB(36, 36, 48),
    SurfaceActive = Color3.fromRGB(44, 44, 60),
    SurfaceGlass = Color3.fromRGB(34, 34, 46),
    
    TitleBar = Color3.fromRGB(24, 24, 32),
    TitleBarInactive = Color3.fromRGB(18, 18, 24),
    
    TabActive = Color3.fromRGB(48, 48, 66),
    TabInactive = Color3.fromRGB(32, 32, 44),
    TabHover = Color3.fromRGB(40, 40, 54),
    
    Accent = Color3.fromRGB(120, 180, 255),
    AccentLight = Color3.fromRGB(150, 200, 255),
    AccentDark = Color3.fromRGB(90, 150, 240),
    AccentGlow = Color3.fromRGB(120, 180, 255),
    
    TextPrimary = Color3.fromRGB(235, 235, 245),
    TextSecondary = Color3.fromRGB(165, 165, 185),
    TextTertiary = Color3.fromRGB(110, 110, 130),
    TextDisabled = Color3.fromRGB(75, 75, 90),
    TextAccent = Color3.fromRGB(150, 200, 255),
    
    ButtonPrimary = Color3.fromRGB(120, 180, 255),
    ButtonPrimaryHover = Color3.fromRGB(140, 200, 255),
    ButtonPrimaryActive = Color3.fromRGB(100, 160, 240),
    ButtonSecondary = Color3.fromRGB(44, 44, 60),
    ButtonSecondaryHover = Color3.fromRGB(54, 54, 74),
    ButtonDanger = Color3.fromRGB(255, 90, 90),
    ButtonDangerHover = Color3.fromRGB(255, 110, 110),
    ButtonSuccess = Color3.fromRGB(90, 220, 130),
    ButtonGhost = Color3.fromRGB(40, 40, 54),
    
    SectionBg = Color3.fromRGB(24, 24, 32),
    SectionBorder = Color3.fromRGB(48, 48, 66),
    SectionHeader = Color3.fromRGB(32, 32, 44),
    
    InputBg = Color3.fromRGB(34, 34, 46),
    InputBorder = Color3.fromRGB(54, 54, 72),
    InputBorderFocus = Color3.fromRGB(120, 180, 255),
    InputBorderError = Color3.fromRGB(255, 90, 90),
    InputPlaceholder = Color3.fromRGB(110, 110, 130),
    
    ToggleOn = Color3.fromRGB(120, 180, 255),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(54, 54, 72),
    ToggleOffKnob = Color3.fromRGB(180, 180, 200),
    ToggleHover = Color3.fromRGB(70, 70, 90),
    
    SliderTrack = Color3.fromRGB(48, 48, 66),
    SliderTrackHover = Color3.fromRGB(58, 58, 76),
    SliderFill = Color3.fromRGB(120, 180, 255),
    SliderFillHover = Color3.fromRGB(140, 200, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(225, 235, 255),
    
    DropdownBg = Color3.fromRGB(34, 34, 46),
    DropdownBorder = Color3.fromRGB(54, 54, 72),
    DropdownItem = Color3.fromRGB(40, 40, 54),
    DropdownItemHover = Color3.fromRGB(54, 54, 72),
    DropdownItemSelected = Color3.fromRGB(48, 48, 66),
    
    NotificationBg = Color3.fromRGB(32, 32, 44),
    NotificationBorder = Color3.fromRGB(48, 48, 66),
    
    DialogBg = Color3.fromRGB(34, 34, 46),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(70, 70, 90),
    ScrollBarHover = Color3.fromRGB(90, 90, 110),
    ScrollBarTrack = Color3.fromRGB(32, 32, 44),
    
    Success = Color3.fromRGB(90, 220, 130),
    SuccessLight = Color3.fromRGB(130, 240, 170),
    Warning = Color3.fromRGB(255, 180, 50),
    WarningLight = Color3.fromRGB(255, 210, 100),
    Error = Color3.fromRGB(255, 90, 90),
    ErrorLight = Color3.fromRGB(255, 130, 130),
    Info = Color3.fromRGB(120, 180, 255),
    InfoLight = Color3.fromRGB(150, 200, 255),
    
    GlassTransparency = 0.12,
    GlassBlur = 16,
    GlowIntensity = 0.6,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    
    AnimationSpeed = 0.3,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Modern Light Theme
Themes.Presets.ModernLight = {
    Name = "Modern Light",
    Description = "Clean modern light theme with smooth transitions",
    Author = "Aether Studio v3",
    
    Background = Color3.fromRGB(250, 250, 254),
    BackgroundSecondary = Color3.fromRGB(242, 242, 248),
    BackgroundTertiary = Color3.fromRGB(234, 234, 242),
    
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceHover = Color3.fromRGB(247, 247, 252),
    SurfaceActive = Color3.fromRGB(237, 237, 244),
    SurfaceGlass = Color3.fromRGB(254, 254, 255),
    
    TitleBar = Color3.fromRGB(242, 242, 248),
    TitleBarInactive = Color3.fromRGB(234, 234, 242),
    
    TabActive = Color3.fromRGB(227, 227, 237),
    TabInactive = Color3.fromRGB(242, 242, 250),
    TabHover = Color3.fromRGB(234, 234, 244),
    
    Accent = Color3.fromRGB(80, 140, 255),
    AccentLight = Color3.fromRGB(110, 160, 255),
    AccentDark = Color3.fromRGB(60, 120, 240),
    AccentGlow = Color3.fromRGB(80, 140, 255),
    
    TextPrimary = Color3.fromRGB(32, 32, 42),
    TextSecondary = Color3.fromRGB(100, 100, 120),
    TextTertiary = Color3.fromRGB(150, 150, 170),
    TextDisabled = Color3.fromRGB(185, 185, 200),
    TextAccent = Color3.fromRGB(80, 140, 255),
    
    ButtonPrimary = Color3.fromRGB(80, 140, 255),
    ButtonPrimaryHover = Color3.fromRGB(100, 160, 255),
    ButtonPrimaryActive = Color3.fromRGB(60, 120, 240),
    ButtonSecondary = Color3.fromRGB(227, 227, 237),
    ButtonSecondaryHover = Color3.fromRGB(217, 217, 230),
    ButtonDanger = Color3.fromRGB(240, 80, 80),
    ButtonDangerHover = Color3.fromRGB(255, 100, 100),
    ButtonSuccess = Color3.fromRGB(60, 190, 110),
    ButtonGhost = Color3.fromRGB(234, 234, 244),
    
    SectionBg = Color3.fromRGB(254, 254, 255),
    SectionBorder = Color3.fromRGB(217, 217, 230),
    SectionHeader = Color3.fromRGB(242, 242, 250),
    
    InputBg = Color3.fromRGB(255, 255, 255),
    InputBorder = Color3.fromRGB(207, 207, 220),
    InputBorderFocus = Color3.fromRGB(80, 140, 255),
    InputBorderError = Color3.fromRGB(240, 80, 80),
    InputPlaceholder = Color3.fromRGB(160, 160, 180),
    
    ToggleOn = Color3.fromRGB(80, 140, 255),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(197, 197, 212),
    ToggleOffKnob = Color3.fromRGB(255, 255, 255),
    ToggleHover = Color3.fromRGB(177, 177, 197),
    
    SliderTrack = Color3.fromRGB(217, 217, 230),
    SliderTrackHover = Color3.fromRGB(202, 202, 217),
    SliderFill = Color3.fromRGB(80, 140, 255),
    SliderFillHover = Color3.fromRGB(100, 160, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(237, 244, 255),
    
    DropdownBg = Color3.fromRGB(255, 255, 255),
    DropdownBorder = Color3.fromRGB(207, 207, 220),
    DropdownItem = Color3.fromRGB(252, 252, 255),
    DropdownItemHover = Color3.fromRGB(237, 237, 247),
    DropdownItemSelected = Color3.fromRGB(227, 234, 255),
    
    NotificationBg = Color3.fromRGB(255, 255, 255),
    NotificationBorder = Color3.fromRGB(217, 217, 230),
    
    DialogBg = Color3.fromRGB(255, 255, 255),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(187, 187, 202),
    ScrollBarHover = Color3.fromRGB(162, 162, 180),
    ScrollBarTrack = Color3.fromRGB(234, 234, 242),
    
    Success = Color3.fromRGB(60, 190, 110),
    SuccessLight = Color3.fromRGB(100, 210, 150),
    Warning = Color3.fromRGB(235, 170, 40),
    WarningLight = Color3.fromRGB(250, 195, 80),
    Error = Color3.fromRGB(240, 80, 80),
    ErrorLight = Color3.fromRGB(255, 110, 110),
    Info = Color3.fromRGB(80, 140, 255),
    InfoLight = Color3.fromRGB(120, 170, 255),
    
    GlassTransparency = 0.08,
    GlassBlur = 12,
    GlowIntensity = 0.4,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.85,
    
    AnimationSpeed = 0.25,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- ═══════════════════════════════════════════════════════════════
-- THEME MANAGER CLASS
-- ═══════════════════════════════════════════════════════════════

function Themes.new(config)
    local self = setmetatable({}, Themes)
    
    self.Config = config or {}
    self.CurrentTheme = nil
    self.ThemeObjects = {}
    self.Transitioning = false
    self.CustomOptions = config.CustomOptions or {}
    
    local mode = self.Config.Mode or "BlackGlass"
    if mode == "Auto" then
        mode = self:DetectSystemTheme()
    end
    
    self:SetTheme(mode, self.Config.CustomTheme)
    
    if self.Config.Mode == "Auto" then
        self:WatchSystemTheme()
    end
    
    return self
end

function Themes:DetectSystemTheme()
    local hour = tonumber(os.date("%H"))
    if hour >= 6 and hour < 18 then
        return "ModernLight"
    end
    return "ModernDark"
end

function Themes:WatchSystemTheme()
    task.spawn(function()
        while self.Config.Mode == "Auto" do
            task.wait(300)
            local detected = self:DetectSystemTheme()
            if detected ~= self.CurrentTheme.Name then
                self:SetTheme(detected)
            end
        end
    end)
end

function Themes:SetTheme(themeName, customOverrides)
    themeName = themeName or "ModernDark"
    
    local baseTheme = Themes.Presets[themeName] or Themes.Presets.ModernDark
    
    if customOverrides then
        self.CurrentTheme = self:MergeThemes(baseTheme, customOverrides)
        self.CurrentTheme.Name = themeName .. " (Custom)"
    else
        self.CurrentTheme = self:CloneTheme(baseTheme)
    end
    
    self:UpdateThemeObjects()
    
    if not self.Transitioning then
        self:PlayTransitionEffect()
    end
    
    return self.CurrentTheme
end

function Themes:SetCustomTheme(customTheme)
    if not customTheme then return end
    
    local base = Themes.Presets.ModernDark
    self.CurrentTheme = self:MergeThemes(base, customTheme)
    self.CurrentTheme.Name = customTheme.Name or "Custom"
    
    self.Config.CustomTheme = customTheme
    self:UpdateThemeObjects()
    self:PlayTransitionEffect()
    
    return self.CurrentTheme
end

function Themes:GetCurrentTheme()
    return self.CurrentTheme or Themes.Presets.ModernDark
end

function Themes:GetColor(colorName)
    local theme = self:GetCurrentTheme()
    return theme[colorName] or theme.Accent or Color3.fromRGB(128, 128, 128)
end

function Themes:GetAvailablePresets()
    local names = {}
    for name, _ in pairs(Themes.Presets) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function Themes:GetPresetInfo(presetName)
    local preset = Themes.Presets[presetName]
    if not preset then return nil end
    return {
        Name = preset.Name,
        Description = preset.Description,
        Author = preset.Author,
    }
end

function Themes:RegisterObject(obj, propertyMap)
    if not obj or not propertyMap then return end
    
    table.insert(self.ThemeObjects, {
        Object = obj,
        Properties = propertyMap,
    })
    
    self:ApplyToObject(obj, propertyMap)
end

function Themes:UnregisterObject(obj)
    for i, entry in ipairs(self.ThemeObjects) do
        if entry.Object == obj then
            table.remove(self.ThemeObjects, i)
            break
        end
    end
end

function Themes:ApplyToObject(obj, propertyMap)
    local theme = self:GetCurrentTheme()
    
    for themeColorName, targetProperty in pairs(propertyMap) do
        local color = theme[themeColorName]
        if color and obj[targetProperty] ~= nil then
            if self.Config.AnimationsEnabled ~= false then
                TweenService:Create(obj, TweenInfo.new(
                    self.Config.AnimationSpeed or 0.3,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ), {[targetProperty] = color}):Play()
            else
                obj[targetProperty] = color
            end
        end
    end
end

function Themes:UpdateThemeObjects()
    for _, entry in ipairs(self.ThemeObjects) do
        if entry.Object and entry.Object.Parent then
            self:ApplyToObject(entry.Object, entry.Properties)
        end
    end
end

function Themes:CloneTheme(theme)
    local clone = {}
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            clone[k] = Color3.new(v.R, v.G, v.B)
        elseif typeof(v) == "ColorSequence" then
            clone[k] = v
        elseif typeof(v) == "NumberSequence" then
            clone[k] = v
        elseif typeof(v) == "table" then
            clone[k] = self:CloneTheme(v)
        else
            clone[k] = v
        end
    end
    return clone
end

function Themes:MergeThemes(base, override)
    local merged = self:CloneTheme(base)
    
    for k, v in pairs(override) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            merged[k] = Color3.new(v.R, v.G, v.B)
        elseif typeof(v) == "string" and k:match("Color$") then
            merged[k] = ColorUtils.FromHex(v)
        else
            merged[k] = v
        end
    end
    
    return merged
end

function Themes:CreateBrightnessVariant(amount)
    local theme = self:CloneTheme(self:GetCurrentTheme())
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            theme[k] = ColorUtils.AdjustBrightness(v, amount)
        end
    end
    
    return theme
end

function Themes:CreateSaturationVariant(amount)
    local theme = self:CloneTheme(self:GetCurrentTheme())
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            theme[k] = ColorUtils.AdjustSaturation(v, amount)
        end
    end
    
    return theme
end

function Themes:GenerateFromColor(baseColor, mode)
    mode = mode or "ModernDark"
    local h, s, v = Color3.toHSV(baseColor)
    
    local theme = self:CloneTheme(Themes.Presets[mode] or Themes.Presets.ModernDark)
    theme.Accent = baseColor
    theme.AccentLight = Color3.fromHSV(h, math.clamp(s - 0.1, 0, 1), math.clamp(v + 0.1, 0, 1))
    theme.AccentDark = Color3.fromHSV(h, math.clamp(s + 0.1, 0, 1), math.clamp(v - 0.15, 0, 1))
    theme.AccentGlow = baseColor
    theme.ButtonPrimary = baseColor
    theme.ButtonPrimaryHover = theme.AccentLight
    theme.ButtonPrimaryActive = theme.AccentDark
    theme.ToggleOn = baseColor
    theme.SliderFill = baseColor
    theme.SliderFillHover = theme.AccentLight
    theme.Info = baseColor
    theme.InfoLight = theme.AccentLight
    theme.TextAccent = theme.AccentLight
    
    return theme
end

function Themes:PlayTransitionEffect()
    self.Transitioning = true
    task.delay(0.5, function()
        self.Transitioning = false
    end)
end

function Themes:Serialize(theme)
    theme = theme or self:GetCurrentTheme()
    local serialized = {}
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            serialized[k] = ColorUtils.ToHex(v)
        elseif typeof(v) == "EnumItem" then
            serialized[k] = tostring(v)
        elseif typeof(v) ~= "function" and typeof(v) ~= "Instance" then
            serialized[k] = v
        end
    end
    
    return serialized
end

function Themes:Deserialize(data)
    if not data then return nil end
    
    local theme = {}
    
    for k, v in pairs(data) do
        if typeof(v) == "string" and v:match("^#%x%x%x%x%x%x$") then
            theme[k] = ColorUtils.FromHex(v)
        elseif typeof(v) == "string" and v:match("^Enum%.") then
            local enumParts = v:gsub("Enum.", ""):split(".")
            theme[k] = Enum[enumParts[1]][enumParts[2]]
        else
            theme[k] = v
        end
    end
    
    return theme
end

function Themes:ToJSON(theme)
    local serialized = self:Serialize(theme)
    return HttpService:JSONEncode(serialized)
end

function Themes:FromJSON(json)
    local data = HttpService:JSONDecode(json)
    return self:Deserialize(data)
end

function Themes:ExportToFile(theme, filename)
    filename = filename or (theme.Name or "Custom") .. ".json"
    local json = self:ToJSON(theme)
    
    pcall(function()
        if writefile then
            writefile(filename, json)
        end
    end)
    
    return json
end

function Themes:ImportFromFile(filename)
    local json = nil
    
    pcall(function()
        if readfile and isfile and isfile(filename) then
            json = readfile(filename)
        end
    end)
    
    if json then
        return self:FromJSON(json)
    end
    
    return nil
end

Themes.ColorUtils = ColorUtils

return Themes
