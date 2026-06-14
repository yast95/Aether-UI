--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              A E T H E R   U I  —  T H E M E S               ║
    ║                                                              ║
    ║  Advanced theme management system with:                      ║
    ║  - Light, Dark, and Auto modes                               ║
    ║  - Full custom theme support                                 ║
    ║  - Real-time theme switching                                 ║
    ║  - Theme serialization (JSON)                                ║
    ║  - Smooth color transitions                                  ║
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

--- Convert Color3 to Hex string
function ColorUtils.ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255))
end

--- Convert Hex string to Color3
function ColorUtils.FromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

--- Convert Color3 to HSV table {H, S, V}
function ColorUtils.ToHSV(color)
    local h, s, v = Color3.toHSV(color)
    return {H = h, S = s, V = v}
end

--- Convert HSV table to Color3
function ColorUtils.FromHSV(hsv)
    return Color3.fromHSV(hsv.H, hsv.S, hsv.V)
end

--- Linear interpolation between two colors
function ColorUtils.Lerp(colorA, colorB, t)
    return Color3.new(
        colorA.R + (colorB.R - colorA.R) * t,
        colorA.G + (colorB.G - colorA.G) * t,
        colorA.B + (colorB.B - colorA.B) * t
    )
end

--- Adjust brightness of a color (-1 to 1)
function ColorUtils.AdjustBrightness(color, amount)
    local h, s, v = Color3.toHSV(color)
    v = math.clamp(v + amount, 0, 1)
    return Color3.fromHSV(h, s, v)
end

--- Adjust saturation of a color (-1 to 1)
function ColorUtils.AdjustSaturation(color, amount)
    local h, s, v = Color3.toHSV(color)
    s = math.clamp(s + amount, 0, 1)
    return Color3.fromHSV(h, s, v)
end

--- Get complementary color
function ColorUtils.Complementary(color)
    local h, s, v = Color3.toHSV(color)
    return Color3.fromHSV((h + 0.5) % 1, s, v)
end

--- Generate analogous colors
function ColorUtils.Analogous(color, count)
    local h, s, v = Color3.toHSV(color)
    local colors = {}
    local step = 1 / count
    for i = 0, count - 1 do
        table.insert(colors, Color3.fromHSV((h + step * i) % 1, s, v))
    end
    return colors
end

--- Check luminance for contrast
function ColorUtils.GetLuminance(color)
    local r, g, b = color.R * 255, color.G * 255, color.B * 255
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255
end

--- Get contrasting text color (black or white) for a background
function ColorUtils.GetContrastColor(color)
    local luminance = ColorUtils.GetLuminance(color)
    return luminance > 0.5 and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(235, 235, 240)
end

--- Generate a gradient between two colors with N steps
function ColorUtils.GenerateGradient(colorA, colorB, steps)
    local gradient = {}
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        table.insert(gradient, ColorUtils.Lerp(colorA, colorB, t))
    end
    return gradient
end

--- Convert Color3 to RGB table {R, G, B}
function ColorUtils.ToRGB(color)
    return {
        R = math.floor(color.R * 255),
        G = math.floor(color.G * 255),
        B = math.floor(color.B * 255)
    }
end

--- Create Color3 from RGB table
function ColorUtils.FromRGB(rgb)
    return Color3.fromRGB(rgb.R or 0, rgb.G or 0, rgb.B or 0)
end

-- ═══════════════════════════════════════════════════════════════
-- PREDEFINED THEMES
-- ═══════════════════════════════════════════════════════════════

Themes.Presets = {}

-- Dark Theme (Default)
Themes.Presets.Dark = {
    Name = "Dark",
    Description = "Default dark theme with blue accents",
    Author = "Aether Studio",
    
    -- Base colors
    Background = Color3.fromRGB(22, 22, 28),
    BackgroundSecondary = Color3.fromRGB(28, 28, 36),
    BackgroundTertiary = Color3.fromRGB(35, 35, 45),
    
    -- Surface colors
    Surface = Color3.fromRGB(32, 32, 42),
    SurfaceHover = Color3.fromRGB(40, 40, 52),
    SurfaceActive = Color3.fromRGB(48, 48, 62),
    SurfaceGlass = Color3.fromRGB(38, 38, 50),
    
    -- Title bar
    TitleBar = Color3.fromRGB(28, 28, 36),
    TitleBarInactive = Color3.fromRGB(22, 22, 28),
    
    -- Tab colors
    TabActive = Color3.fromRGB(52, 52, 68),
    TabInactive = Color3.fromRGB(35, 35, 45),
    TabHover = Color3.fromRGB(45, 45, 58),
    
    -- Accent colors
    Accent = Color3.fromRGB(100, 150, 255),
    AccentLight = Color3.fromRGB(130, 175, 255),
    AccentDark = Color3.fromRGB(75, 115, 220),
    AccentGlow = Color3.fromRGB(100, 150, 255),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(230, 230, 240),
    TextSecondary = Color3.fromRGB(155, 155, 175),
    TextTertiary = Color3.fromRGB(100, 100, 120),
    TextDisabled = Color3.fromRGB(70, 70, 85),
    TextAccent = Color3.fromRGB(130, 175, 255),
    
    -- Button colors
    ButtonPrimary = Color3.fromRGB(100, 150, 255),
    ButtonPrimaryHover = Color3.fromRGB(120, 165, 255),
    ButtonPrimaryActive = Color3.fromRGB(80, 130, 240),
    ButtonSecondary = Color3.fromRGB(50, 50, 65),
    ButtonSecondaryHover = Color3.fromRGB(60, 60, 78),
    ButtonDanger = Color3.fromRGB(255, 85, 75),
    ButtonDangerHover = Color3.fromRGB(255, 105, 95),
    ButtonSuccess = Color3.fromRGB(80, 200, 120),
    ButtonGhost = Color3.fromRGB(45, 45, 58),
    
    -- Section colors
    SectionBg = Color3.fromRGB(28, 28, 36),
    SectionBorder = Color3.fromRGB(45, 45, 58),
    SectionHeader = Color3.fromRGB(35, 35, 45),
    
    -- Input colors
    InputBg = Color3.fromRGB(38, 38, 50),
    InputBorder = Color3.fromRGB(55, 55, 72),
    InputBorderFocus = Color3.fromRGB(100, 150, 255),
    InputBorderError = Color3.fromRGB(255, 85, 75),
    InputPlaceholder = Color3.fromRGB(100, 100, 120),
    
    -- Toggle colors
    ToggleOn = Color3.fromRGB(100, 150, 255),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(55, 55, 70),
    ToggleOffKnob = Color3.fromRGB(180, 180, 195),
    ToggleHover = Color3.fromRGB(70, 70, 88),
    
    -- Slider colors
    SliderTrack = Color3.fromRGB(45, 45, 58),
    SliderTrackHover = Color3.fromRGB(55, 55, 72),
    SliderFill = Color3.fromRGB(100, 150, 255),
    SliderFillHover = Color3.fromRGB(120, 165, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(220, 230, 255),
    
    -- Dropdown colors
    DropdownBg = Color3.fromRGB(38, 38, 50),
    DropdownBorder = Color3.fromRGB(55, 55, 72),
    DropdownItem = Color3.fromRGB(42, 42, 55),
    DropdownItemHover = Color3.fromRGB(55, 55, 72),
    DropdownItemSelected = Color3.fromRGB(52, 52, 68),
    
    -- Notification colors
    NotificationBg = Color3.fromRGB(35, 35, 48),
    NotificationBorder = Color3.fromRGB(50, 50, 65),
    
    -- Dialog colors
    DialogBg = Color3.fromRGB(38, 38, 50),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    -- Scrollbar
    ScrollBar = Color3.fromRGB(65, 65, 82),
    ScrollBarHover = Color3.fromRGB(85, 85, 105),
    ScrollBarTrack = Color3.fromRGB(35, 35, 45),
    
    -- Status colors
    Success = Color3.fromRGB(80, 200, 120),
    SuccessLight = Color3.fromRGB(120, 225, 155),
    Warning = Color3.fromRGB(255, 185, 60),
    WarningLight = Color3.fromRGB(255, 205, 100),
    Error = Color3.fromRGB(255, 85, 75),
    ErrorLight = Color3.fromRGB(255, 115, 105),
    Info = Color3.fromRGB(100, 150, 255),
    InfoLight = Color3.fromRGB(140, 180, 255),
    
    -- Special effects
    GlassTransparency = 0.12,
    GlassBlur = 16,
    GlowIntensity = 0.6,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    
    -- Animation
    AnimationSpeed = 0.35,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Light Theme
Themes.Presets.Light = {
    Name = "Light",
    Description = "Clean light theme with blue accents",
    Author = "Aether Studio",
    
    Background = Color3.fromRGB(248, 248, 252),
    BackgroundSecondary = Color3.fromRGB(240, 240, 246),
    BackgroundTertiary = Color3.fromRGB(232, 232, 240),
    
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceHover = Color3.fromRGB(245, 245, 250),
    SurfaceActive = Color3.fromRGB(235, 235, 242),
    SurfaceGlass = Color3.fromRGB(252, 252, 255),
    
    TitleBar = Color3.fromRGB(240, 240, 246),
    TitleBarInactive = Color3.fromRGB(232, 232, 240),
    
    TabActive = Color3.fromRGB(225, 225, 235),
    TabInactive = Color3.fromRGB(240, 240, 248),
    TabHover = Color3.fromRGB(232, 232, 242),
    
    Accent = Color3.fromRGB(75, 130, 245),
    AccentLight = Color3.fromRGB(105, 155, 255),
    AccentDark = Color3.fromRGB(55, 100, 220),
    AccentGlow = Color3.fromRGB(75, 130, 245),
    
    TextPrimary = Color3.fromRGB(35, 35, 45),
    TextSecondary = Color3.fromRGB(95, 95, 115),
    TextTertiary = Color3.fromRGB(145, 145, 165),
    TextDisabled = Color3.fromRGB(180, 180, 195),
    TextAccent = Color3.fromRGB(75, 130, 245),
    
    ButtonPrimary = Color3.fromRGB(75, 130, 245),
    ButtonPrimaryHover = Color3.fromRGB(95, 148, 255),
    ButtonPrimaryActive = Color3.fromRGB(55, 110, 230),
    ButtonSecondary = Color3.fromRGB(225, 225, 235),
    ButtonSecondaryHover = Color3.fromRGB(215, 215, 228),
    ButtonDanger = Color3.fromRGB(235, 75, 65),
    ButtonDangerHover = Color3.fromRGB(255, 95, 85),
    ButtonSuccess = Color3.fromRGB(55, 180, 95),
    ButtonGhost = Color3.fromRGB(232, 232, 242),
    
    SectionBg = Color3.fromRGB(252, 252, 255),
    SectionBorder = Color3.fromRGB(215, 215, 228),
    SectionHeader = Color3.fromRGB(240, 240, 248),
    
    InputBg = Color3.fromRGB(255, 255, 255),
    InputBorder = Color3.fromRGB(205, 205, 218),
    InputBorderFocus = Color3.fromRGB(75, 130, 245),
    InputBorderError = Color3.fromRGB(235, 75, 65),
    InputPlaceholder = Color3.fromRGB(155, 155, 172),
    
    ToggleOn = Color3.fromRGB(75, 130, 245),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(195, 195, 210),
    ToggleOffKnob = Color3.fromRGB(255, 255, 255),
    ToggleHover = Color3.fromRGB(175, 175, 195),
    
    SliderTrack = Color3.fromRGB(215, 215, 228),
    SliderTrackHover = Color3.fromRGB(200, 200, 215),
    SliderFill = Color3.fromRGB(75, 130, 245),
    SliderFillHover = Color3.fromRGB(95, 148, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(235, 242, 255),
    
    DropdownBg = Color3.fromRGB(255, 255, 255),
    DropdownBorder = Color3.fromRGB(205, 205, 218),
    DropdownItem = Color3.fromRGB(250, 250, 255),
    DropdownItemHover = Color3.fromRGB(235, 235, 245),
    DropdownItemSelected = Color3.fromRGB(225, 232, 255),
    
    NotificationBg = Color3.fromRGB(255, 255, 255),
    NotificationBorder = Color3.fromRGB(215, 215, 228),
    
    DialogBg = Color3.fromRGB(255, 255, 255),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(185, 185, 200),
    ScrollBarHover = Color3.fromRGB(160, 160, 178),
    ScrollBarTrack = Color3.fromRGB(232, 232, 240),
    
    Success = Color3.fromRGB(55, 180, 95),
    SuccessLight = Color3.fromRGB(95, 205, 130),
    Warning = Color3.fromRGB(230, 165, 35),
    WarningLight = Color3.fromRGB(245, 190, 75),
    Error = Color3.fromRGB(235, 75, 65),
    ErrorLight = Color3.fromRGB(255, 105, 95),
    Info = Color3.fromRGB(75, 130, 245),
    InfoLight = Color3.fromRGB(115, 160, 255),
    
    GlassTransparency = 0.08,
    GlassBlur = 12,
    GlowIntensity = 0.4,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.85,
    
    AnimationSpeed = 0.3,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Midnight Theme (Darker, purple-tinted)
Themes.Presets.Midnight = {
    Name = "Midnight",
    Description = "Deep dark theme with purple accents",
    Author = "Aether Studio",
    
    Background = Color3.fromRGB(15, 12, 22),
    BackgroundSecondary = Color3.fromRGB(20, 16, 30),
    BackgroundTertiary = Color3.fromRGB(28, 22, 40),
    
    Surface = Color3.fromRGB(25, 20, 38),
    SurfaceHover = Color3.fromRGB(35, 28, 50),
    SurfaceActive = Color3.fromRGB(42, 34, 60),
    SurfaceGlass = Color3.fromRGB(30, 24, 45),
    
    TitleBar = Color3.fromRGB(20, 16, 30),
    TitleBarInactive = Color3.fromRGB(15, 12, 22),
    
    TabActive = Color3.fromRGB(42, 32, 62),
    TabInactive = Color3.fromRGB(28, 22, 40),
    TabHover = Color3.fromRGB(35, 26, 52),
    
    Accent = Color3.fromRGB(155, 105, 245),
    AccentLight = Color3.fromRGB(175, 130, 255),
    AccentDark = Color3.fromRGB(130, 80, 220),
    AccentGlow = Color3.fromRGB(155, 105, 245),
    
    TextPrimary = Color3.fromRGB(235, 230, 245),
    TextSecondary = Color3.fromRGB(160, 150, 185),
    TextTertiary = Color3.fromRGB(110, 100, 135),
    TextDisabled = Color3.fromRGB(75, 68, 95),
    TextAccent = Color3.fromRGB(175, 130, 255),
    
    ButtonPrimary = Color3.fromRGB(155, 105, 245),
    ButtonPrimaryHover = Color3.fromRGB(170, 125, 255),
    ButtonPrimaryActive = Color3.fromRGB(135, 85, 230),
    ButtonSecondary = Color3.fromRGB(38, 30, 55),
    ButtonSecondaryHover = Color3.fromRGB(48, 38, 68),
    ButtonDanger = Color3.fromRGB(255, 75, 85),
    ButtonDangerHover = Color3.fromRGB(255, 100, 110),
    ButtonSuccess = Color3.fromRGB(85, 210, 130),
    ButtonGhost = Color3.fromRGB(35, 26, 52),
    
    SectionBg = Color3.fromRGB(22, 18, 35),
    SectionBorder = Color3.fromRGB(38, 30, 55),
    SectionHeader = Color3.fromRGB(28, 22, 42),
    
    InputBg = Color3.fromRGB(30, 24, 45),
    InputBorder = Color3.fromRGB(48, 38, 68),
    InputBorderFocus = Color3.fromRGB(155, 105, 245),
    InputBorderError = Color3.fromRGB(255, 75, 85),
    InputPlaceholder = Color3.fromRGB(100, 90, 125),
    
    ToggleOn = Color3.fromRGB(155, 105, 245),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(50, 40, 72),
    ToggleOffKnob = Color3.fromRGB(175, 168, 195),
    ToggleHover = Color3.fromRGB(62, 50, 88),
    
    SliderTrack = Color3.fromRGB(38, 30, 55),
    SliderTrackHover = Color3.fromRGB(50, 40, 72),
    SliderFill = Color3.fromRGB(155, 105, 245),
    SliderFillHover = Color3.fromRGB(170, 125, 255),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(230, 215, 255),
    
    DropdownBg = Color3.fromRGB(30, 24, 45),
    DropdownBorder = Color3.fromRGB(48, 38, 68),
    DropdownItem = Color3.fromRGB(35, 28, 52),
    DropdownItemHover = Color3.fromRGB(48, 38, 68),
    DropdownItemSelected = Color3.fromRGB(42, 32, 62),
    
    NotificationBg = Color3.fromRGB(28, 22, 42),
    NotificationBorder = Color3.fromRGB(42, 32, 62),
    
    DialogBg = Color3.fromRGB(30, 24, 45),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(55, 45, 78),
    ScrollBarHover = Color3.fromRGB(75, 62, 100),
    ScrollBarTrack = Color3.fromRGB(22, 18, 35),
    
    Success = Color3.fromRGB(85, 210, 130),
    SuccessLight = Color3.fromRGB(120, 230, 160),
    Warning = Color3.fromRGB(255, 180, 55),
    WarningLight = Color3.fromRGB(255, 200, 95),
    Error = Color3.fromRGB(255, 75, 85),
    ErrorLight = Color3.fromRGB(255, 105, 115),
    Info = Color3.fromRGB(155, 105, 245),
    InfoLight = Color3.fromRGB(185, 140, 255),
    
    GlassTransparency = 0.15,
    GlassBlur = 20,
    GlowIntensity = 0.7,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.65,
    
    AnimationSpeed = 0.4,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Ocean Theme (Teal/cyan accents)
Themes.Presets.Ocean = {
    Name = "Ocean",
    Description = "Dark theme with teal and cyan accents",
    Author = "Aether Studio",
    
    Background = Color3.fromRGB(12, 20, 28),
    BackgroundSecondary = Color3.fromRGB(16, 26, 36),
    BackgroundTertiary = Color3.fromRGB(22, 35, 48),
    
    Surface = Color3.fromRGB(20, 32, 44),
    SurfaceHover = Color3.fromRGB(28, 44, 60),
    SurfaceActive = Color3.fromRGB(35, 54, 72),
    SurfaceGlass = Color3.fromRGB(24, 38, 52),
    
    TitleBar = Color3.fromRGB(16, 26, 36),
    TitleBarInactive = Color3.fromRGB(12, 20, 28),
    
    TabActive = Color3.fromRGB(32, 52, 72),
    TabInactive = Color3.fromRGB(22, 35, 48),
    TabHover = Color3.fromRGB(28, 44, 60),
    
    Accent = Color3.fromRGB(45, 200, 190),
    AccentLight = Color3.fromRGB(65, 220, 210),
    AccentDark = Color3.fromRGB(35, 170, 160),
    AccentGlow = Color3.fromRGB(45, 200, 190),
    
    TextPrimary = Color3.fromRGB(225, 240, 245),
    TextSecondary = Color3.fromRGB(140, 165, 180),
    TextTertiary = Color3.fromRGB(95, 120, 138),
    TextDisabled = Color3.fromRGB(60, 80, 95),
    TextAccent = Color3.fromRGB(65, 220, 210),
    
    ButtonPrimary = Color3.fromRGB(45, 200, 190),
    ButtonPrimaryHover = Color3.fromRGB(60, 218, 208),
    ButtonPrimaryActive = Color3.fromRGB(35, 180, 170),
    ButtonSecondary = Color3.fromRGB(28, 44, 60),
    ButtonSecondaryHover = Color3.fromRGB(35, 54, 72),
    ButtonDanger = Color3.fromRGB(255, 85, 75),
    ButtonDangerHover = Color3.fromRGB(255, 108, 98),
    ButtonSuccess = Color3.fromRGB(80, 210, 130),
    ButtonGhost = Color3.fromRGB(24, 38, 52),
    
    SectionBg = Color3.fromRGB(18, 28, 40),
    SectionBorder = Color3.fromRGB(30, 48, 65),
    SectionHeader = Color3.fromRGB(22, 35, 50),
    
    InputBg = Color3.fromRGB(24, 38, 52),
    InputBorder = Color3.fromRGB(35, 54, 72),
    InputBorderFocus = Color3.fromRGB(45, 200, 190),
    InputBorderError = Color3.fromRGB(255, 85, 75),
    InputPlaceholder = Color3.fromRGB(90, 115, 132),
    
    ToggleOn = Color3.fromRGB(45, 200, 190),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(40, 58, 75),
    ToggleOffKnob = Color3.fromRGB(165, 180, 195),
    ToggleHover = Color3.fromRGB(50, 72, 92),
    
    SliderTrack = Color3.fromRGB(30, 48, 65),
    SliderTrackHover = Color3.fromRGB(40, 62, 82),
    SliderFill = Color3.fromRGB(45, 200, 190),
    SliderFillHover = Color3.fromRGB(60, 218, 208),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(215, 245, 242),
    
    DropdownBg = Color3.fromRGB(24, 38, 52),
    DropdownBorder = Color3.fromRGB(35, 54, 72),
    DropdownItem = Color3.fromRGB(28, 44, 58),
    DropdownItemHover = Color3.fromRGB(40, 62, 82),
    DropdownItemSelected = Color3.fromRGB(32, 52, 72),
    
    NotificationBg = Color3.fromRGB(22, 35, 48),
    NotificationBorder = Color3.fromRGB(35, 54, 72),
    
    DialogBg = Color3.fromRGB(24, 38, 52),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(45, 68, 88),
    ScrollBarHover = Color3.fromRGB(62, 90, 115),
    ScrollBarTrack = Color3.fromRGB(18, 28, 40),
    
    Success = Color3.fromRGB(80, 210, 130),
    SuccessLight = Color3.fromRGB(115, 230, 160),
    Warning = Color3.fromRGB(255, 180, 55),
    WarningLight = Color3.fromRGB(255, 200, 95),
    Error = Color3.fromRGB(255, 85, 75),
    ErrorLight = Color3.fromRGB(255, 108, 98),
    Info = Color3.fromRGB(45, 200, 190),
    InfoLight = Color3.fromRGB(75, 225, 215),
    
    GlassTransparency = 0.12,
    GlassBlur = 18,
    GlowIntensity = 0.55,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    
    AnimationSpeed = 0.35,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Sunset Theme (Warm orange/rose)
Themes.Presets.Sunset = {
    Name = "Sunset",
    Description = "Warm theme with orange and rose accents",
    Author = "Aether Studio",
    
    Background = Color3.fromRGB(28, 18, 18),
    BackgroundSecondary = Color3.fromRGB(35, 22, 22),
    BackgroundTertiary = Color3.fromRGB(45, 28, 28),
    
    Surface = Color3.fromRGB(42, 26, 26),
    SurfaceHover = Color3.fromRGB(52, 32, 32),
    SurfaceActive = Color3.fromRGB(62, 38, 38),
    SurfaceGlass = Color3.fromRGB(48, 30, 30),
    
    TitleBar = Color3.fromRGB(35, 22, 22),
    TitleBarInactive = Color3.fromRGB(28, 18, 18),
    
    TabActive = Color3.fromRGB(62, 38, 38),
    TabInactive = Color3.fromRGB(45, 28, 28),
    TabHover = Color3.fromRGB(52, 32, 32),
    
    Accent = Color3.fromRGB(255, 130, 100),
    AccentLight = Color3.fromRGB(255, 155, 125),
    AccentDark = Color3.fromRGB(230, 105, 78),
    AccentGlow = Color3.fromRGB(255, 130, 100),
    
    TextPrimary = Color3.fromRGB(245, 235, 230),
    TextSecondary = Color3.fromRGB(185, 160, 150),
    TextTertiary = Color3.fromRGB(135, 110, 102),
    TextDisabled = Color3.fromRGB(88, 70, 65),
    TextAccent = Color3.fromRGB(255, 155, 125),
    
    ButtonPrimary = Color3.fromRGB(255, 130, 100),
    ButtonPrimaryHover = Color3.fromRGB(255, 150, 120),
    ButtonPrimaryActive = Color3.fromRGB(235, 112, 85),
    ButtonSecondary = Color3.fromRGB(48, 30, 30),
    ButtonSecondaryHover = Color3.fromRGB(58, 36, 36),
    ButtonDanger = Color3.fromRGB(255, 65, 75),
    ButtonDangerHover = Color3.fromRGB(255, 88, 98),
    ButtonSuccess = Color3.fromRGB(95, 200, 120),
    ButtonGhost = Color3.fromRGB(42, 26, 26),
    
    SectionBg = Color3.fromRGB(32, 20, 20),
    SectionBorder = Color3.fromRGB(50, 32, 32),
    SectionHeader = Color3.fromRGB(40, 25, 25),
    
    InputBg = Color3.fromRGB(42, 26, 26),
    InputBorder = Color3.fromRGB(58, 36, 36),
    InputBorderFocus = Color3.fromRGB(255, 130, 100),
    InputBorderError = Color3.fromRGB(255, 65, 75),
    InputPlaceholder = Color3.fromRGB(125, 100, 92),
    
    ToggleOn = Color3.fromRGB(255, 130, 100),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(58, 38, 38),
    ToggleOffKnob = Color3.fromRGB(195, 178, 172),
    ToggleHover = Color3.fromRGB(72, 46, 46),
    
    SliderTrack = Color3.fromRGB(50, 32, 32),
    SliderTrackHover = Color3.fromRGB(62, 40, 40),
    SliderFill = Color3.fromRGB(255, 130, 100),
    SliderFillHover = Color3.fromRGB(255, 150, 120),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(255, 230, 222),
    
    DropdownBg = Color3.fromRGB(42, 26, 26),
    DropdownBorder = Color3.fromRGB(58, 36, 36),
    DropdownItem = Color3.fromRGB(48, 30, 30),
    DropdownItemHover = Color3.fromRGB(62, 40, 40),
    DropdownItemSelected = Color3.fromRGB(62, 38, 38),
    
    NotificationBg = Color3.fromRGB(38, 24, 24),
    NotificationBorder = Color3.fromRGB(55, 35, 35),
    
    DialogBg = Color3.fromRGB(42, 26, 26),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(72, 48, 48),
    ScrollBarHover = Color3.fromRGB(92, 62, 62),
    ScrollBarTrack = Color3.fromRGB(32, 20, 20),
    
    Success = Color3.fromRGB(95, 200, 120),
    SuccessLight = Color3.fromRGB(125, 220, 148),
    Warning = Color3.fromRGB(255, 185, 65),
    WarningLight = Color3.fromRGB(255, 205, 105),
    Error = Color3.fromRGB(255, 65, 75),
    ErrorLight = Color3.fromRGB(255, 90, 100),
    Info = Color3.fromRGB(255, 130, 100),
    InfoLight = Color3.fromRGB(255, 165, 138),
    
    GlassTransparency = 0.12,
    GlassBlur = 16,
    GlowIntensity = 0.5,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.7,
    
    AnimationSpeed = 0.35,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- Forest Theme (Green/nature)
Themes.Presets.Forest = {
    Name = "Forest",
    Description = "Dark theme with emerald green accents",
    Author = "Aether Studio",
    
    Background = Color3.fromRGB(14, 22, 16),
    BackgroundSecondary = Color3.fromRGB(18, 28, 20),
    BackgroundTertiary = Color3.fromRGB(24, 38, 28),
    
    Surface = Color3.fromRGB(22, 35, 26),
    SurfaceHover = Color3.fromRGB(30, 48, 35),
    SurfaceActive = Color3.fromRGB(38, 58, 42),
    SurfaceGlass = Color3.fromRGB(26, 42, 30),
    
    TitleBar = Color3.fromRGB(18, 28, 20),
    TitleBarInactive = Color3.fromRGB(14, 22, 16),
    
    TabActive = Color3.fromRGB(35, 55, 40),
    TabInactive = Color3.fromRGB(24, 38, 28),
    TabHover = Color3.fromRGB(30, 48, 35),
    
    Accent = Color3.fromRGB(75, 195, 130),
    AccentLight = Color3.fromRGB(100, 215, 155),
    AccentDark = Color3.fromRGB(55, 170, 108),
    AccentGlow = Color3.fromRGB(75, 195, 130),
    
    TextPrimary = Color3.fromRGB(230, 242, 235),
    TextSecondary = Color3.fromRGB(148, 175, 158),
    TextTertiary = Color3.fromRGB(102, 128, 112),
    TextDisabled = Color3.fromRGB(65, 85, 72),
    TextAccent = Color3.fromRGB(100, 215, 155),
    
    ButtonPrimary = Color3.fromRGB(75, 195, 130),
    ButtonPrimaryHover = Color3.fromRGB(95, 210, 148),
    ButtonPrimaryActive = Color3.fromRGB(58, 175, 115),
    ButtonSecondary = Color3.fromRGB(28, 44, 32),
    ButtonSecondaryHover = Color3.fromRGB(35, 55, 40),
    ButtonDanger = Color3.fromRGB(255, 85, 78),
    ButtonDangerHover = Color3.fromRGB(255, 108, 100),
    ButtonSuccess = Color3.fromRGB(75, 195, 130),
    ButtonGhost = Color3.fromRGB(26, 42, 30),
    
    SectionBg = Color3.fromRGB(20, 32, 24),
    SectionBorder = Color3.fromRGB(32, 50, 38),
    SectionHeader = Color3.fromRGB(24, 38, 28),
    
    InputBg = Color3.fromRGB(26, 42, 30),
    InputBorder = Color3.fromRGB(38, 58, 42),
    InputBorderFocus = Color3.fromRGB(75, 195, 130),
    InputBorderError = Color3.fromRGB(255, 85, 78),
    InputPlaceholder = Color3.fromRGB(95, 120, 105),
    
    ToggleOn = Color3.fromRGB(75, 195, 130),
    ToggleOnKnob = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(40, 62, 46),
    ToggleOffKnob = Color3.fromRGB(172, 188, 178),
    ToggleHover = Color3.fromRGB(50, 78, 56),
    
    SliderTrack = Color3.fromRGB(32, 50, 38),
    SliderTrackHover = Color3.fromRGB(42, 65, 48),
    SliderFill = Color3.fromRGB(75, 195, 130),
    SliderFillHover = Color3.fromRGB(95, 210, 148),
    SliderKnob = Color3.fromRGB(255, 255, 255),
    SliderKnobHover = Color3.fromRGB(222, 245, 232),
    
    DropdownBg = Color3.fromRGB(26, 42, 30),
    DropdownBorder = Color3.fromRGB(38, 58, 42),
    DropdownItem = Color3.fromRGB(30, 48, 35),
    DropdownItemHover = Color3.fromRGB(42, 65, 48),
    DropdownItemSelected = Color3.fromRGB(35, 55, 40),
    
    NotificationBg = Color3.fromRGB(24, 38, 28),
    NotificationBorder = Color3.fromRGB(38, 58, 42),
    
    DialogBg = Color3.fromRGB(26, 42, 30),
    DialogOverlay = Color3.fromRGB(0, 0, 0),
    
    ScrollBar = Color3.fromRGB(48, 75, 55),
    ScrollBarHover = Color3.fromRGB(65, 100, 75),
    ScrollBarTrack = Color3.fromRGB(20, 32, 24),
    
    Success = Color3.fromRGB(75, 195, 130),
    SuccessLight = Color3.fromRGB(105, 215, 155),
    Warning = Color3.fromRGB(255, 185, 60),
    WarningLight = Color3.fromRGB(255, 205, 100),
    Error = Color3.fromRGB(255, 85, 78),
    ErrorLight = Color3.fromRGB(255, 110, 102),
    Info = Color3.fromRGB(75, 195, 130),
    InfoLight = Color3.fromRGB(110, 215, 160),
    
    GlassTransparency = 0.12,
    GlassBlur = 16,
    GlowIntensity = 0.45,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.72,
    
    AnimationSpeed = 0.35,
    TransitionEasing = Enum.EasingStyle.Quart,
}

-- ═══════════════════════════════════════════════════════════════
-- THEME MANAGER CLASS
-- ═══════════════════════════════════════════════════════════════

function Themes.new(config)
    local self = setmetatable({}, Themes)
    
    self.Config = config or {}
    self.CurrentTheme = nil
    self.ThemeObjects = {} -- Objects that need theme updates
    self.Transitioning = false
    
    -- Initialize with default or configured theme
    local mode = self.Config.Mode or "Dark"
    if mode == "Auto" then
        mode = self:DetectSystemTheme()
    end
    
    self:SetTheme(mode, self.Config.CustomTheme)
    
    -- Watch for system theme changes if in Auto mode
    if self.Config.Mode == "Auto" then
        self:WatchSystemTheme()
    end
    
    return self
end

--- Detect system theme (placeholder for platform detection)
function Themes:DetectSystemTheme()
    -- In Roblox, default to Dark as there's no native system theme API
    -- Could be extended with user preference detection
    local hour = tonumber(os.date("%H"))
    if hour >= 6 and hour < 18 then
        return "Light"
    end
    return "Dark"
end

--- Watch for system theme changes
function Themes:WatchSystemTheme()
    task.spawn(function()
        while self.Config.Mode == "Auto" do
            task.wait(300) -- Check every 5 minutes
            local detected = self:DetectSystemTheme()
            if detected ~= self.CurrentTheme.Name then
                self:SetTheme(detected)
            end
        end
    end)
end

--- Set the current theme
function Themes:SetTheme(themeName, customOverrides)
    themeName = themeName or "Dark"
    
    -- Get base theme
    local baseTheme = Themes.Presets[themeName] or Themes.Presets.Dark
    
    -- Apply custom overrides
    if customOverrides then
        self.CurrentTheme = self:MergeThemes(baseTheme, customOverrides)
        self.CurrentTheme.Name = themeName .. " (Custom)"
    else
        -- Deep copy to avoid modifying preset
        self.CurrentTheme = self:CloneTheme(baseTheme)
    end
    
    -- Notify all registered objects
    self:UpdateThemeObjects()
    
    -- Trigger transition effect
    if not self.Transitioning then
        self:PlayTransitionEffect()
    end
    
    return self.CurrentTheme
end

--- Apply a fully custom theme
function Themes:SetCustomTheme(customTheme)
    if not customTheme then return end
    
    -- Merge with Dark as base to fill any missing values
    local base = Themes.Presets.Dark
    self.CurrentTheme = self:MergeThemes(base, customTheme)
    self.CurrentTheme.Name = customTheme.Name or "Custom"
    
    self.Config.CustomTheme = customTheme
    self:UpdateThemeObjects()
    self:PlayTransitionEffect()
    
    return self.CurrentTheme
end

--- Get current theme
function Themes:GetCurrentTheme()
    return self.CurrentTheme or Themes.Presets.Dark
end

--- Get a specific color from current theme
function Themes:GetColor(colorName)
    local theme = self:GetCurrentTheme()
    return theme[colorName] or theme.Accent or Color3.fromRGB(128, 128, 128)
end

--- Get a list of available preset names
function Themes:GetAvailablePresets()
    local names = {}
    for name, _ in pairs(Themes.Presets) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--- Get preset info
function Themes:GetPresetInfo(presetName)
    local preset = Themes.Presets[presetName]
    if not preset then return nil end
    return {
        Name = preset.Name,
        Description = preset.Description,
        Author = preset.Author,
    }
end

-- ═══════════════════════════════════════════════════════════════
-- THEME OBJECT REGISTRATION
-- ═══════════════════════════════════════════════════════════════

--- Register an object for theme updates
--- @param obj Instance The GUI object
--- @param propertyMap table Map of theme color names to object properties
function Themes:RegisterObject(obj, propertyMap)
    if not obj or not propertyMap then return end
    
    table.insert(self.ThemeObjects, {
        Object = obj,
        Properties = propertyMap,
    })
    
    -- Apply current theme immediately
    self:ApplyToObject(obj, propertyMap)
end

--- Unregister an object
function Themes:UnregisterObject(obj)
    for i, entry in ipairs(self.ThemeObjects) do
        if entry.Object == obj then
            table.remove(self.ThemeObjects, i)
            break
        end
    end
end

--- Apply theme to a single object
function Themes:ApplyToObject(obj, propertyMap)
    local theme = self:GetCurrentTheme()
    
    for themeColorName, targetProperty in pairs(propertyMap) do
        local color = theme[themeColorName]
        if color and obj[targetProperty] ~= nil then
            -- Smooth transition
            if self.Config.AnimationsEnabled ~= false then
                TweenService:Create(obj, TweenInfo.new(
                    self.Config.AnimationSpeed or 0.35,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ), {[targetProperty] = color}):Play()
            else
                obj[targetProperty] = color
            end
        end
    end
end

--- Update all registered objects with current theme
function Themes:UpdateThemeObjects()
    for _, entry in ipairs(self.ThemeObjects) do
        if entry.Object and entry.Object.Parent then
            self:ApplyToObject(entry.Object, entry.Properties)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- THEME MANIPULATION
-- ═══════════════════════════════════════════════════════════════

--- Clone a theme table (deep copy)
function Themes:CloneTheme(theme)
    local clone = {}
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            -- Color3 value
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

--- Merge two themes (override with priority)
function Themes:MergeThemes(base, override)
    local merged = self:CloneTheme(base)
    
    for k, v in pairs(override) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            merged[k] = Color3.new(v.R, v.G, v.B)
        elseif typeof(v) == "string" and k:match("Color$") then
            -- Hex color string
            merged[k] = ColorUtils.FromHex(v)
        else
            merged[k] = v
        end
    end
    
    return merged
end

--- Create a variant of current theme with adjusted brightness
function Themes:CreateBrightnessVariant(amount)
    local theme = self:CloneTheme(self:GetCurrentTheme())
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            theme[k] = ColorUtils.AdjustBrightness(v, amount)
        end
    end
    
    return theme
end

--- Create a variant with adjusted saturation
function Themes:CreateSaturationVariant(amount)
    local theme = self:CloneTheme(self:GetCurrentTheme())
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            theme[k] = ColorUtils.AdjustSaturation(v, amount)
        end
    end
    
    return theme
end

--- Generate a monochromatic theme from a base color
function Themes:GenerateFromColor(baseColor, mode)
    mode = mode or "Dark"
    local h, s, v = Color3.toHSV(baseColor)
    
    local theme = self:CloneTheme(Themes.Presets[mode] or Themes.Presets.Dark)
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

-- ═══════════════════════════════════════════════════════════════
-- TRANSITION EFFECTS
-- ═══════════════════════════════════════════════════════════════

function Themes:PlayTransitionEffect()
    self.Transitioning = true
    
    -- Could add a brief flash or color wash effect here
    -- For now, just flag and release
    task.delay(0.5, function()
        self.Transitioning = false
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SERIALIZATION
-- ═══════════════════════════════════════════════════════════════

--- Serialize theme to JSON-compatible table
function Themes:Serialize(theme)
    theme = theme or self:GetCurrentTheme()
    local serialized = {}
    
    for k, v in pairs(theme) do
        if typeof(v) == "table" and typeof(v.R) == "number" then
            -- Color3 to hex string
            serialized[k] = ColorUtils.ToHex(v)
        elseif typeof(v) == "EnumItem" then
            serialized[k] = tostring(v)
        elseif typeof(v) ~= "function" and typeof(v) ~= "Instance" then
            serialized[k] = v
        end
    end
    
    return serialized
end

--- Deserialize theme from JSON-compatible table
function Themes:Deserialize(data)
    if not data then return nil end
    
    local theme = {}
    
    for k, v in pairs(data) do
        if typeof(v) == "string" and v:match("^#%x%x%x%x%x%x$") then
            -- Hex string to Color3
            theme[k] = ColorUtils.FromHex(v)
        elseif typeof(v) == "string" and v:match("^Enum%.") then
            -- Enum string to EnumItem
            local enumParts = v:gsub("Enum.", ""):split(".")
            theme[k] = Enum[enumParts[1]][enumParts[2]]
        else
            theme[k] = v
        end
    end
    
    return theme
end

--- Save theme to JSON string
function Themes:ToJSON(theme)
    local serialized = self:Serialize(theme)
    return HttpService:JSONEncode(serialized)
end

--- Load theme from JSON string
function Themes:FromJSON(json)
    local data = HttpService:JSONDecode(json)
    return self:Deserialize(data)
end

--- Export theme to file
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

--- Import theme from file
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

-- ═══════════════════════════════════════════════════════════════
-- RETURN MODULE
-- ═══════════════════════════════════════════════════════════════

-- Attach ColorUtils to Themes for easy access
Themes.ColorUtils = ColorUtils

return Themes