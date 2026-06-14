--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           A E T H E R   U I  —  C O M P O N E N T S          ║
    ║                                                              ║
    ║  Complete UI component library:                              ║
    ║  - Section                                                   ║
    ║  - Button                                                    ║
    ║  - Toggle                                                    ║
    ║  - Slider                                                    ║
    ║  - Dropdown                                                  ║
    ║  - Textbox                                                   ║
    ║  - Label                                                     ║
    ║  - Keybind                                                   ║
    ║  - ColorPicker                                               ║
    ║  - ProgressBar                                               ║
    ║  - SearchBar                                                 ║
    ║  - MultiDropdown                                             ║
    ║  - Accordion                                                 ║
    ║  - Tooltip                                                   ║
    ║  - ContextMenu                                               ║
    ║  - Table/List                                                ║
    ║  - TreeView                                                  ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Components = {}

-- ═══════════════════════════════════════════════════════════════
-- WINDOW & TAB WRAPPERS (delegates to AetherUI core)
-- Fix: ces fonctions étaient appelées mais jamais définies
-- ═══════════════════════════════════════════════════════════════

--- Crée une Window via le core AetherUI (évite le fallback silencieux)
function Components.CreateWindow(lib, config)
    return lib:CreateWindowInternal(config)
end

--- Crée un Tab via le core AetherUI
function Components.CreateTab(window, config)
    return window.Library:CreateTabInternal(window, config)
end

--- Table vide pour éviter le crash "attempt to index nil value 'WindowMethods'"
--- dans le metatable de CreateWindowInternal.
--- Les vraies méthodes (AddTab, Notify, SetTitle...) sont dans AetherUI.WindowMethods
--- et y restent — cette table sert uniquement de guard.
Components.WindowMethods = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function GetTheme(lib)
    return lib.CurrentTheme or {}
end

local function GetAnimations(lib)
    return lib.AnimationManager
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function CreatePadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or 0)
    pad.PaddingBottom = UDim.new(0, bottom or 0)
    pad.PaddingLeft = UDim.new(0, left or 0)
    pad.PaddingRight = UDim.new(0, right or 0)
    pad.Parent = parent
    return pad
end

local function CreateListLayout(parent, direction, alignment, padding)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = alignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, padding or 0)
    layout.Parent = parent
    return layout
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(80, 80, 90)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.Parent = parent
    return stroke
end

local function ApplyHoverEffect(button, normalColor, hoverColor, clickColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = normalColor
        }):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = clickColor
        }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateSection(tab, config)
    config = config or {}
    local lib = tab.Library
    local theme = GetTheme(lib)
    local name = config.Name or "Section"
    local description = config.Description or nil
    
    -- Section container
    local section = Instance.new("Frame")
    section.Name = "Section_" .. name
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = theme.SectionBg or Color3.fromRGB(30, 30, 38)
    section.BackgroundTransparency = 0.3
    section.BorderSizePixel = 0
    section.Parent = tab.Page
    
    local sectionCorner = CreateCorner(section, 12)
    local sectionStroke = CreateStroke(section, theme.SectionBorder or Color3.fromRGB(45, 45, 58), 1, 0.6)
    
    -- Section padding
    CreatePadding(section, 14, 14, 14, 14)
    
    local sectionLayout = CreateListLayout(section, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 10)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, description and 40 or 24)
    header.BackgroundTransparency = 1
    header.Parent = section
    
    -- Title icon
    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "SectionIcon"
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 0, 0, 2)
        icon.BackgroundTransparency = 1
        icon.Image = Icons and Icons.Get(config.Icon) or ""
        icon.ImageColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
        icon.Parent = header
    end
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "SectionTitle"
    title.Size = UDim2.new(1, config.Icon and -26 or 0, 0, 20)
    title.Position = UDim2.new(0, config.Icon and 26 or 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Description
    if description then
        local desc = Instance.new("TextLabel")
        desc.Name = "SectionDesc"
        desc.Size = UDim2.new(1, 0, 0, 16)
        desc.Position = UDim2.new(0, 0, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
        desc.TextSize = 11
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextWrapped = true
        desc.Parent = header
    end
    
    -- Divider line
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = theme.SectionBorder or Color3.fromRGB(45, 45, 58)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = section
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Parent = section
    
    local contentLayout = CreateListLayout(content, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8)
    
    -- Section object
    local sectionObj = {
        Type = "Section",
        Frame = section,
        Content = content,
        Tab = tab,
        Library = lib,
    }
    
    -- Section API methods
    function sectionObj:AddButton(btnConfig)
        return Components.CreateButton(sectionObj, btnConfig)
    end
    
    function sectionObj:AddToggle(toggleConfig)
        return Components.CreateToggle(sectionObj, toggleConfig)
    end
    
    function sectionObj:AddSlider(sliderConfig)
        return Components.CreateSlider(sectionObj, sliderConfig)
    end
    
    function sectionObj:AddDropdown(dropdownConfig)
        return Components.CreateDropdown(sectionObj, dropdownConfig)
    end
    
    function sectionObj:AddTextbox(textboxConfig)
        return Components.CreateTextbox(sectionObj, textboxConfig)
    end
    
    function sectionObj:AddLabel(labelConfig)
        return Components.CreateLabel(sectionObj, labelConfig)
    end
    
    function sectionObj:AddKeybind(keybindConfig)
        return Components.CreateKeybind(sectionObj, keybindConfig)
    end
    
    function sectionObj:AddColorPicker(colorConfig)
        return Components.CreateColorPicker(sectionObj, colorConfig)
    end
    
    function sectionObj:AddProgressBar(progressConfig)
        return Components.CreateProgressBar(sectionObj, progressConfig)
    end
    
    function sectionObj:AddSearchBar(searchConfig)
        return Components.CreateSearchBar(sectionObj, searchConfig)
    end
    
    function sectionObj:AddMultiDropdown(dropdownConfig)
        return Components.CreateMultiDropdown(sectionObj, dropdownConfig)
    end
    
    function sectionObj:AddAccordion(accordionConfig)
        return Components.CreateAccordion(sectionObj, accordionConfig)
    end
    
    return sectionObj
end

-- ═══════════════════════════════════════════════════════════════
-- BUTTON COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateButton(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Button"
    local description = config.Description or nil
    local style = config.Style or "Primary"  -- "Primary", "Secondary", "Danger", "Ghost", "Success"
    local icon = config.Icon or nil
    local callback = config.Callback or function() end
    
    -- Color mapping
    local styleColors = {
        Primary = {
            Bg = theme.ButtonPrimary or Color3.fromRGB(100, 150, 255),
            Hover = theme.ButtonPrimaryHover or Color3.fromRGB(120, 165, 255),
            Active = theme.ButtonPrimaryActive or Color3.fromRGB(80, 130, 240),
            Text = Color3.fromRGB(255, 255, 255)
        },
        Secondary = {
            Bg = theme.ButtonSecondary or Color3.fromRGB(50, 50, 65),
            Hover = theme.ButtonSecondaryHover or Color3.fromRGB(60, 60, 78),
            Active = theme.ButtonSecondary or Color3.fromRGB(40, 40, 52),
            Text = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
        },
        Danger = {
            Bg = theme.ButtonDanger or Color3.fromRGB(255, 85, 75),
            Hover = theme.ButtonDangerHover or Color3.fromRGB(255, 105, 95),
            Active = Color3.fromRGB(230, 65, 55),
            Text = Color3.fromRGB(255, 255, 255)
        },
        Ghost = {
            Bg = theme.ButtonGhost or Color3.fromRGB(45, 45, 58),
            Hover = theme.SurfaceHover or Color3.fromRGB(55, 55, 72),
            Active = theme.ButtonGhost or Color3.fromRGB(35, 35, 48),
            Text = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
        },
        Success = {
            Bg = theme.ButtonSuccess or Color3.fromRGB(80, 200, 120),
            Hover = Color3.fromRGB(95, 215, 138),
            Active = Color3.fromRGB(65, 180, 105),
            Text = Color3.fromRGB(255, 255, 255)
        },
    }
    
    local colors = styleColors[style] or styleColors.Primary
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Button_" .. text
    container.Size = UDim2.new(1, 0, 0, description and 56 or 38)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Button
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = colors.Bg
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = container
    
    local btnCorner = CreateCorner(button, 10)
    
    -- Button content layout
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.Parent = button
    
    -- Icon
    if icon then
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "BtnIcon"
        iconImg.Size = UDim2.new(0, 16, 0, 16)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = Icons and Icons.Get(icon) or icon
        iconImg.ImageColor3 = colors.Text
        iconImg.Parent = button
    end
    
    -- Button text
    local btnText = Instance.new("TextLabel")
    btnText.Name = "BtnText"
    btnText.Size = UDim2.new(0, 0, 1, 0)
    btnText.AutomaticSize = Enum.AutomaticSize.X
    btnText.BackgroundTransparency = 1
    btnText.Text = text
    btnText.TextColor3 = colors.Text
    btnText.TextSize = 13
    btnText.Font = Enum.Font.GothamSemibold
    btnText.Parent = button
    
    -- Description text
    if description then
        button.Size = UDim2.new(1, 0, 0, 38)
        button.Position = UDim2.new(0, 0, 0, 18)
        
        local descText = Instance.new("TextLabel")
        descText.Name = "BtnDescription"
        descText.Size = UDim2.new(1, 0, 0, 16)
        descText.BackgroundTransparency = 1
        descText.Text = description
        descText.TextColor3 = theme.TextTertiary or Color3.fromRGB(100, 100, 120)
        descText.TextSize = 10
        descText.Font = Enum.Font.Gotham
        descText.TextXAlignment = Enum.TextXAlignment.Left
        descText.Parent = container
    end
    
    -- Hover effects
    ApplyHoverEffect(button, colors.Bg, colors.Hover, colors.Active)
    
    -- Click ripple effect
    button.MouseButton1Click:Connect(function(x, y)
        -- Ripple
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        ripple.Parent = button
        
        TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.5, function()
            ripple:Destroy()
        end)
        
        -- Callback
        callback()
        
        -- Play sound if enabled
        if lib.Config.Theme.SoundEnabled then
            lib:PlaySound("rbxassetid://6895079853", 0.15)
        end
    end)
    
    -- Button object
    local btnObj = {
        Type = "Button",
        Frame = container,
        Button = button,
        Library = lib,
        SetText = function(self, newText)
            btnText.Text = newText
        end,
        SetCallback = function(self, newCallback)
            callback = newCallback
        end,
        SetEnabled = function(self, enabled)
            button.Active = enabled
            button.BackgroundTransparency = enabled and 0 or 0.5
        end,
    }
    
    return btnObj
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateToggle(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. text
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "ToggleLabel"
    label.Size = UDim2.new(1, -54, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Toggle background
    local toggleBg = Instance.new("TextButton")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 46, 0, 24)
    toggleBg.Position = UDim2.new(1, -50, 0.5, -12)
    toggleBg.BackgroundColor3 = default 
        and (theme.ToggleOn or Color3.fromRGB(100, 150, 255))
        or (theme.ToggleOff or Color3.fromRGB(55, 55, 70))
    toggleBg.Text = ""
    toggleBg.AutoButtonColor = false
    toggleBg.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(0, 25, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = default
        and (theme.ToggleOnKnob or Color3.fromRGB(255, 255, 255))
        or (theme.ToggleOffKnob or Color3.fromRGB(180, 180, 195))
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- State
    local state = default
    
    -- Toggle function
    local function updateToggle()
        state = not state
        
        -- Animate background
        TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state 
                and (theme.ToggleOn or Color3.fromRGB(100, 150, 255))
                or (theme.ToggleOff or Color3.fromRGB(55, 55, 70))
        }):Play()
        
        -- Animate knob
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(0, 25, 0, 3) or UDim2.new(0, 3, 0, 3),
            BackgroundColor3 = state
                and (theme.ToggleOnKnob or Color3.fromRGB(255, 255, 255))
                or (theme.ToggleOffKnob or Color3.fromRGB(180, 180, 195))
        }):Play()
        
        callback(state)
        
        -- Sound
        if lib.Config.Theme.SoundEnabled then
            lib:PlaySound("rbxassetid://6895079853", 0.1)
        end
    end
    
    toggleBg.MouseButton1Click:Connect(updateToggle)
    
    -- Toggle object
    local toggleObj = {
        Type = "Toggle",
        Frame = container,
        Library = lib,
        GetState = function() return state end,
        SetState = function(self, newState)
            if state ~= newState then
                updateToggle()
            end
        end,
    }
    
    return toggleObj
end

-- ═══════════════════════════════════════════════════════════════
-- SLIDER COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateSlider(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Slider"
    local min = config.Min or config.Minimum or 0
    local max = config.Max or config.Maximum or 100
    local default = config.Default or min
    local increment = config.Increment or config.Step or 1
    local suffix = config.Suffix or config.Prefix or ""
    local callback = config.Callback or function() end
    
    -- Clamp default
    default = math.clamp(default, min, max)
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. text
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label row
    local labelRow = Instance.new("Frame")
    labelRow.Name = "LabelRow"
    labelRow.Size = UDim2.new(1, 0, 0, 18)
    labelRow.BackgroundTransparency = 1
    labelRow.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Name = "SliderLabel"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = labelRow
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = suffix .. tostring(default)
    valueLabel.TextColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = labelRow
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 32)
    track.BackgroundColor3 = theme.SliderTrack or Color3.fromRGB(45, 45, 58)
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Slider fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = theme.SliderFill or Color3.fromRGB(100, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Slider knob
    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
    knob.BackgroundColor3 = theme.SliderKnob or Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Knob shadow
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Name = "KnobShadow"
    knobShadow.Size = UDim2.new(1, 8, 1, 8)
    knobShadow.Position = UDim2.new(0, -4, 0, -4)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://5554236805"
    knobShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    knobShadow.ImageTransparency = 0.7
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    knobShadow.Parent = knob
    
    -- State
    local currentValue = default
    local dragging = false
    
    local function updateSlider(input)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local rawValue = min + (max - min) * percent
        local steppedValue = math.floor(rawValue / increment + 0.5) * increment
        steppedValue = math.clamp(steppedValue, min, max)
        
        if steppedValue ~= currentValue then
            currentValue = steppedValue
            
            local fillPercent = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(fillPercent, 0, 1, 0)
            knob.Position = UDim2.new(fillPercent, -8, 0, -5)
            valueLabel.Text = suffix .. tostring(currentValue)
            
            callback(currentValue)
        end
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Hover effects
    track.MouseEnter:Connect(function()
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SliderTrackHover or Color3.fromRGB(55, 55, 72)
        }):Play()
    end)
    
    track.MouseLeave:Connect(function()
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SliderTrack or Color3.fromRGB(45, 45, 58)
        }):Play()
    end)
    
    knob.MouseEnter:Connect(function()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(knob.Position.X.Scale, -9, 0, -6),
            BackgroundColor3 = theme.SliderKnobHover or Color3.fromRGB(220, 230, 255)
        }):Play()
    end)
    
    knob.MouseLeave:Connect(function()
        if not dragging then
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(knob.Position.X.Scale, -8, 0, -5),
                BackgroundColor3 = theme.SliderKnob or Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    -- Slider object
    local sliderObj = {
        Type = "Slider",
        Frame = container,
        Library = lib,
        GetValue = function() return currentValue end,
        SetValue = function(self, value)
            value = math.clamp(value, min, max)
            currentValue = value
            local fillPercent = (value - min) / (max - min)
            fill.Size = UDim2.new(fillPercent, 0, 1, 0)
            knob.Position = UDim2.new(fillPercent, -8, 0, -5)
            valueLabel.Text = suffix .. tostring(value)
            callback(value)
        end,
    }
    
    return sliderObj
end

-- ═══════════════════════════════════════════════════════════════
-- DROPDOWN COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateDropdown(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Dropdown"
    local options = config.Options or config.Values or {}
    local default = config.Default or options[1] or nil
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. text
    container.Size = UDim2.new(1, 0, 0, 66)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    container.ClipsDescendants = false
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "DropdownLabel"
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Dropdown button
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "DropdownBtn"
    dropdownBtn.Size = UDim2.new(1, 0, 0, 36)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 22)
    dropdownBtn.BackgroundColor3 = theme.DropdownBg or Color3.fromRGB(38, 38, 50)
    dropdownBtn.Text = ""
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.Parent = container
    
    local btnCorner = CreateCorner(dropdownBtn, 10)
    local btnStroke = CreateStroke(dropdownBtn, theme.DropdownBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Selected text
    local selectedText = Instance.new("TextLabel")
    selectedText.Name = "SelectedText"
    selectedText.Size = UDim2.new(1, -40, 1, 0)
    selectedText.Position = UDim2.new(0, 12, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = default or "Select..."
    selectedText.TextColor3 = default and (theme.TextPrimary or Color3.fromRGB(230, 230, 235)) 
        or (theme.TextTertiary or Color3.fromRGB(100, 100, 120))
    selectedText.TextSize = 13
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = dropdownBtn
    
    -- Arrow icon
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -26, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://3926307975"
    arrow.ImageRectOffset = Vector2.new(324, 524)
    arrow.ImageRectSize = Vector2.new(36, 36)
    arrow.ImageColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
    arrow.Rotation = 0
    arrow.Parent = dropdownBtn
    
    -- Dropdown menu (scrollable)
    local menu = Instance.new("Frame")
    menu.Name = "DropdownMenu"
    menu.Size = UDim2.new(1, 0, 0, 0)
    menu.Position = UDim2.new(0, 0, 0, 60)
    menu.BackgroundColor3 = theme.DropdownBg or Color3.fromRGB(38, 38, 50)
    menu.BackgroundTransparency = 0
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 10
    menu.Parent = container
    
    local menuCorner = CreateCorner(menu, 10)
    local menuStroke = CreateStroke(menu, theme.DropdownBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Shadow for menu
    local menuShadow = Instance.new("ImageLabel")
    menuShadow.Name = "MenuShadow"
    menuShadow.Size = UDim2.new(1, 20, 1, 20)
    menuShadow.Position = UDim2.new(0, -10, 0, -10)
    menuShadow.BackgroundTransparency = 1
    menuShadow.Image = "rbxassetid://5554236805"
    menuShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    menuShadow.ImageTransparency = 0.6
    menuShadow.ScaleType = Enum.ScaleType.Slice
    menuShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    menuShadow.ZIndex = 9
    menuShadow.Parent = menu
    
    -- Scroll frame for options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Scroll"
    scrollFrame.Size = UDim2.new(1, -8, 1, -8)
    scrollFrame.Position = UDim2.new(0, 4, 0, 4)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = theme.ScrollBar or Color3.fromRGB(70, 70, 85)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ZIndex = 11
    scrollFrame.Parent = menu
    
    local scrollLayout = CreateListLayout(scrollFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)
    CreatePadding(scrollFrame, 4, 4, 4, 4)
    
    -- State
    local isOpen = false
    local selected = default
    local optionButtons = {}
    
    local function createOption(optionText, isSelected)
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = "Option_" .. optionText
        optionBtn.Size = UDim2.new(1, 0, 0, 30)
        optionBtn.BackgroundColor3 = isSelected 
            and (theme.DropdownItemSelected or Color3.fromRGB(52, 52, 68))
            or (theme.DropdownItem or Color3.fromRGB(42, 42, 55))
        optionBtn.Text = ""
        optionBtn.AutoButtonColor = false
        optionBtn.ZIndex = 12
        optionBtn.Parent = scrollFrame
        
        local optCorner = CreateCorner(optionBtn, 6)
        
        local optText = Instance.new("TextLabel")
        optText.Name = "OptionText"
        optText.Size = UDim2.new(1, -30, 1, 0)
        optText.Position = UDim2.new(0, 10, 0, 0)
        optText.BackgroundTransparency = 1
        optText.Text = optionText
        optText.TextColor3 = isSelected 
            and (theme.Accent or Color3.fromRGB(100, 150, 255))
            or (theme.TextPrimary or Color3.fromRGB(230, 230, 235))
        optText.TextSize = 12
        optText.Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham
        optText.TextXAlignment = Enum.TextXAlignment.Left
        optText.TextTruncate = Enum.TextTruncate.AtEnd
        optText.ZIndex = 13
        optText.Parent = optionBtn
        
        -- Checkmark for selected
        if isSelected then
            local checkmark = Instance.new("ImageLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(0, 14, 0, 14)
            checkmark.Position = UDim2.new(1, -22, 0.5, -7)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://3926305904"
            checkmark.ImageRectOffset = Vector2.new(312, 4)
            checkmark.ImageRectSize = Vector2.new(24, 24)
            checkmark.ImageColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
            checkmark.ZIndex = 13
            checkmark.Parent = optionBtn
        end
        
        -- Hover
        optionBtn.MouseEnter:Connect(function()
            if selected ~= optionText then
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = theme.DropdownItemHover or Color3.fromRGB(55, 55, 72)
                }):Play()
            end
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if selected ~= optionText then
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = theme.DropdownItem or Color3.fromRGB(42, 42, 55)
                }):Play()
            end
        end)
        
        -- Select
        optionBtn.MouseButton1Click:Connect(function()
            selected = optionText
            selectedText.Text = optionText
            selectedText.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
            
            -- Update all options
            for _, btn in ipairs(optionButtons) do
                btn.BackgroundColor3 = theme.DropdownItem or Color3.fromRGB(42, 42, 55)
                local txt = btn:FindFirstChild("OptionText")
                if txt then
                    txt.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
                    txt.Font = Enum.Font.Gotham
                end
                local check = btn:FindFirstChild("Checkmark")
                if check then check:Destroy() end
            end
            
            -- Highlight selected
            optionBtn.BackgroundColor3 = theme.DropdownItemSelected or Color3.fromRGB(52, 52, 68)
            optText.TextColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
            optText.Font = Enum.Font.GothamSemibold
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(0, 14, 0, 14)
            checkmark.Position = UDim2.new(1, -22, 0.5, -7)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://3926305904"
            checkmark.ImageRectOffset = Vector2.new(312, 4)
            checkmark.ImageRectSize = Vector2.new(24, 24)
            checkmark.ImageColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
            checkmark.ZIndex = 13
            checkmark.Parent = optionBtn
            
            -- Close menu
            isOpen = false
            TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
            task.delay(0.2, function()
                menu.Visible = false
            end)
            
            callback(optionText)
        end)
        
        table.insert(optionButtons, optionBtn)
        return optionBtn
    end
    
    -- Create option buttons
    for _, option in ipairs(options) do
        createOption(option, option == selected)
    end
    
    -- Toggle menu
    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            menu.Visible = true
            local targetHeight = math.min(#options * 32 + 8, 200)
            TweenService:Create(menu, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.25), {Rotation = 180}):Play()
        else
            TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
            task.delay(0.2, function()
                menu.Visible = false
            end)
        end
    end)
    
    -- Hover effect on button
    dropdownBtn.MouseEnter:Connect(function()
        TweenService:Create(dropdownBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SurfaceHover or Color3.fromRGB(48, 48, 62)
        }):Play()
    end)
    
    dropdownBtn.MouseLeave:Connect(function()
        TweenService:Create(dropdownBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.DropdownBg or Color3.fromRGB(38, 38, 50)
        }):Play()
    end)
    
    -- Dropdown object
    local dropdownObj = {
        Type = "Dropdown",
        Frame = container,
        Library = lib,
        GetSelected = function() return selected end,
        SetSelected = function(self, value)
            if table.find(options, value) then
                selected = value
                selectedText.Text = value
                callback(value)
            end
        end,
        Refresh = function(self, newOptions, keepSelected)
            options = newOptions
            selected = keepSelected and selected or nil
            
            -- Clear existing
            for _, btn in ipairs(optionButtons) do
                btn:Destroy()
            end
            optionButtons = {}
            
            -- Recreate
            for _, option in ipairs(options) do
                createOption(option, option == selected)
            end
            
            selectedText.Text = selected or "Select..."
        end,
    }
    
    return dropdownObj
end

-- ═══════════════════════════════════════════════════════════════
-- TEXTBOX COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateTextbox(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Textbox"
    local placeholder = config.Placeholder or "Enter text..."
    local default = config.Default or ""
    local clearOnFocus = config.ClearOnFocus or false
    local callback = config.Callback or function() end
    local finishedCallback = config.FinishedCallback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Textbox_" .. text
    container.Size = UDim2.new(1, 0, 0, 66)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "TextboxLabel"
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Textbox frame
    local textboxFrame = Instance.new("Frame")
    textboxFrame.Name = "TextboxFrame"
    textboxFrame.Size = UDim2.new(1, 0, 0, 36)
    textboxFrame.Position = UDim2.new(0, 0, 0, 22)
    textboxFrame.BackgroundColor3 = theme.InputBg or Color3.fromRGB(38, 38, 50)
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Parent = container
    
    local frameCorner = CreateCorner(textboxFrame, 10)
    local frameStroke = CreateStroke(textboxFrame, theme.InputBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Textbox
    local textbox = Instance.new("TextBox")
    textbox.Name = "Textbox"
    textbox.Size = UDim2.new(1, -20, 1, 0)
    textbox.Position = UDim2.new(0, 10, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.Text = default
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = theme.InputPlaceholder or Color3.fromRGB(100, 100, 120)
    textbox.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    textbox.TextSize = 13
    textbox.Font = Enum.Font.Gotham
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = clearOnFocus
    textbox.Parent = textboxFrame
    
    -- Events
    textbox.Focused:Connect(function()
        TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SurfaceHover or Color3.fromRGB(48, 48, 62)
        }):Play()
        TweenService:Create(frameStroke, TweenInfo.new(0.2), {
            Color = theme.InputBorderFocus or Color3.fromRGB(100, 150, 255),
            Transparency = 0.2
        }):Play()
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(textboxFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.InputBg or Color3.fromRGB(38, 38, 50)
        }):Play()
        TweenService:Create(frameStroke, TweenInfo.new(0.2), {
            Color = theme.InputBorder or Color3.fromRGB(55, 55, 72),
            Transparency = 0.5
        }):Play()
        
        finishedCallback(textbox.Text, enterPressed)
    end)
    
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        callback(textbox.Text)
    end)
    
    -- Textbox object
    local textboxObj = {
        Type = "Textbox",
        Frame = container,
        TextBox = textbox,
        Library = lib,
        GetText = function() return textbox.Text end,
        SetText = function(self, value)
            textbox.Text = value
        end,
    }
    
    return textboxObj
end

-- ═══════════════════════════════════════════════════════════════
-- LABEL COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateLabel(parent, config)
    config = config or {}
    if typeof(config) == "string" then
        config = {Text = config}
    end
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Text or config.Name or "Label"
    local style = config.Style or "Default"  -- "Default", "Header", "Subheader", "Muted", "Accent"
    
    local styleConfig = {
        Default = {
            TextSize = 13,
            Font = Enum.Font.Gotham,
            Color = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
        },
        Header = {
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            Color = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
        },
        Subheader = {
            TextSize = 14,
            Font = Enum.Font.GothamSemibold,
            Color = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
        },
        Muted = {
            TextSize = 12,
            Font = Enum.Font.Gotham,
            Color = theme.TextTertiary or Color3.fromRGB(100, 100, 120)
        },
        Accent = {
            TextSize = 13,
            Font = Enum.Font.GothamSemibold,
            Color = theme.Accent or Color3.fromRGB(100, 150, 255)
        },
    }
    
    local s = styleConfig[style] or styleConfig.Default
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Label_" .. text
    container.Size = UDim2.new(1, 0, 0, s.TextSize + 4)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "LabelText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = s.Color
    label.TextSize = s.TextSize
    label.Font = s.Font
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = config.Wrapped or false
    if config.Wrapped then
        container.AutomaticSize = Enum.AutomaticSize.Y
    end
    label.Parent = container
    
    -- Label object
    local labelObj = {
        Type = "Label",
        Frame = container,
        Label = label,
        Library = lib,
        SetText = function(self, newText)
            label.Text = newText
        end,
        SetColor = function(self, color)
            label.TextColor3 = color
        end,
    }
    
    return labelObj
end

-- ═══════════════════════════════════════════════════════════════
-- KEYBIND COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateKeybind(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Keybind"
    local default = config.Default or config.Key or Enum.KeyCode.Unknown
    local holdMode = config.Hold or false
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Keybind_" .. text
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "KeybindLabel"
    label.Size = UDim2.new(1, -100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Keybind button
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Name = "KeybindBtn"
    keybindBtn.Size = UDim2.new(0, 90, 0, 28)
    keybindBtn.Position = UDim2.new(1, -95, 0.5, -14)
    keybindBtn.BackgroundColor3 = theme.ButtonSecondary or Color3.fromRGB(50, 50, 65)
    keybindBtn.Text = default ~= Enum.KeyCode.Unknown and default.Name or "None"
    keybindBtn.TextColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
    keybindBtn.TextSize = 11
    keybindBtn.Font = Enum.Font.GothamSemibold
    keybindBtn.AutoButtonColor = false
    keybindBtn.Parent = container
    
    local btnCorner = CreateCorner(keybindBtn, 8)
    
    -- State
    local currentKey = default
    local isListening = false
    
    keybindBtn.MouseButton1Click:Connect(function()
        if isListening then return end
        isListening = true
        keybindBtn.Text = "..."
        keybindBtn.TextColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
        
        TweenService:Create(keybindBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.TabActive or Color3.fromRGB(55, 55, 68)
        }):Play()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isListening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    isListening = false
                    keybindBtn.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
                    keybindBtn.TextColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
                    TweenService:Create(keybindBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = theme.ButtonSecondary or Color3.fromRGB(50, 50, 65)
                    }):Play()
                    return
                end
                
                currentKey = input.KeyCode
                isListening = false
                keybindBtn.Text = currentKey.Name
                keybindBtn.TextColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
                TweenService:Create(keybindBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = theme.ButtonSecondary or Color3.fromRGB(50, 50, 65)
                }):Play()
                
                callback(currentKey)
            end
        elseif not gameProcessed and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
            if holdMode then
                callback(true)
            else
                callback()
            end
        end
    end)
    
    if holdMode then
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                callback(false)
            end
        end)
    end
    
    -- Keybind object
    local keybindObj = {
        Type = "Keybind",
        Frame = container,
        Library = lib,
        GetKey = function() return currentKey end,
        SetKey = function(self, keyCode)
            currentKey = keyCode
            keybindBtn.Text = keyCode ~= Enum.KeyCode.Unknown and keyCode.Name or "None"
        end,
    }
    
    return keybindObj
end

-- ═══════════════════════════════════════════════════════════════
-- COLOR PICKER COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateColorPicker(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Color Picker"
    local default = config.Default or Color3.fromRGB(100, 150, 255)
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "ColorPicker_" .. text
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "ColorLabel"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Color preview button
    local previewBtn = Instance.new("TextButton")
    previewBtn.Name = "ColorPreview"
    previewBtn.Size = UDim2.new(0, 36, 0, 28)
    previewBtn.Position = UDim2.new(1, -41, 0.5, -14)
    previewBtn.BackgroundColor3 = default
    previewBtn.Text = ""
    previewBtn.AutoButtonColor = false
    previewBtn.Parent = container
    
    local previewCorner = CreateCorner(previewBtn, 8)
    local previewStroke = CreateStroke(previewBtn, theme.InputBorder or Color3.fromRGB(55, 55, 72), 1, 0.3)
    
    -- Picker menu (hidden by default)
    local pickerMenu = Instance.new("Frame")
    pickerMenu.Name = "PickerMenu"
    pickerMenu.Size = UDim2.new(1, 0, 0, 0)
    pickerMenu.Position = UDim2.new(0, 0, 0, 40)
    pickerMenu.BackgroundColor3 = theme.SectionBg or Color3.fromRGB(30, 30, 38)
    pickerMenu.BackgroundTransparency = 0
    pickerMenu.BorderSizePixel = 0
    pickerMenu.Visible = false
    pickerMenu.ZIndex = 15
    pickerMenu.Parent = container
    
    local menuCorner = CreateCorner(pickerMenu, 12)
    local menuStroke = CreateStroke(pickerMenu, theme.SectionBorder or Color3.fromRGB(45, 45, 58), 1, 0.5)
    
    CreatePadding(pickerMenu, 12, 12, 12, 12)
    local menuLayout = CreateListLayout(pickerMenu, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 10)
    
    -- Saturation-Value picker
    local svPicker = Instance.new("Frame")
    svPicker.Name = "SVPicker"
    svPicker.Size = UDim2.new(1, 0, 0, 140)
    svPicker.BackgroundColor3 = default
    svPicker.BorderSizePixel = 0
    svPicker.Parent = pickerMenu
    
    local svCorner = CreateCorner(svPicker, 8)
    
    -- White gradient overlay
    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Parent = svPicker
    
    -- Black gradient overlay
    local blackOverlay = Instance.new("Frame")
    blackOverlay.Name = "BlackOverlay"
    blackOverlay.Size = UDim2.new(1, 0, 1, 0)
    blackOverlay.BackgroundTransparency = 0
    blackOverlay.BorderSizePixel = 0
    blackOverlay.Parent = svPicker
    
    local blackGradient = Instance.new("UIGradient")
    blackGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    blackGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGradient.Rotation = 90
    blackGradient.Parent = blackOverlay
    
    -- SV cursor
    local svCursor = Instance.new("Frame")
    svCursor.Name = "SVCursor"
    svCursor.Size = UDim2.new(0, 12, 0, 12)
    svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svCursor.BorderSizePixel = 0
    svCursor.Parent = svPicker
    
    local svCursorCorner = Instance.new("UICorner")
    svCursorCorner.CornerRadius = UDim.new(1, 0)
    svCursorCorner.Parent = svCursor
    
    local svCursorStroke = CreateStroke(svCursor, Color3.fromRGB(0, 0, 0), 2, 0.5)
    
    -- Hue slider
    local hueTrack = Instance.new("Frame")
    hueTrack.Name = "HueTrack"
    hueTrack.Size = UDim2.new(1, 0, 0, 16)
    hueTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueTrack.BorderSizePixel = 0
    hueTrack.Parent = pickerMenu
    
    local hueCorner = CreateCorner(hueTrack, 8)
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueTrack
    
    -- Hue cursor
    local hueCursor = Instance.new("Frame")
    hueCursor.Name = "HueCursor"
    hueCursor.Size = UDim2.new(0, 12, 1, 4)
    hueCursor.Position = UDim2.new(0, 0, 0, -2)
    hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueCursor.BorderSizePixel = 0
    hueCursor.Parent = hueTrack
    
    local hueCursorCorner = CreateCorner(hueCursor, 4)
    local hueCursorStroke = CreateStroke(hueCursor, Color3.fromRGB(0, 0, 0), 2, 0.5)
    
    -- Hex input
    local hexRow = Instance.new("Frame")
    hexRow.Name = "HexRow"
    hexRow.Size = UDim2.new(1, 0, 0, 28)
    hexRow.BackgroundTransparency = 1
    hexRow.Parent = pickerMenu
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Name = "HexLabel"
    hexLabel.Size = UDim2.new(0, 30, 1, 0)
    hexLabel.BackgroundTransparency = 1
    hexLabel.Text = "HEX"
    hexLabel.TextColor3 = theme.TextTertiary or Color3.fromRGB(100, 100, 120)
    hexLabel.TextSize = 11
    hexLabel.Font = Enum.Font.GothamSemibold
    hexLabel.Parent = hexRow
    
    local hexInput = Instance.new("TextBox")
    hexInput.Name = "HexInput"
    hexInput.Size = UDim2.new(1, -35, 1, 0)
    hexInput.Position = UDim2.new(0, 35, 0, 0)
    hexInput.BackgroundColor3 = theme.InputBg or Color3.fromRGB(38, 38, 50)
    hexInput.Text = string.format("#%02X%02X%02X", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255))
    hexInput.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    hexInput.TextSize = 12
    hexInput.Font = Enum.Font.Gotham
    hexInput.Parent = hexRow
    
    local hexCorner = CreateCorner(hexInput, 6)
    
    -- State
    local currentH, currentS, currentV = Color3.toHSV(default)
    local isMenuOpen = false
    local isDraggingSV = false
    local isDraggingHue = false
    
    local function updateColor()
        local newColor = Color3.fromHSV(currentH, currentS, currentV)
        previewBtn.BackgroundColor3 = newColor
        svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        hexInput.Text = string.format("#%02X%02X%02X", math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255))
        callback(newColor)
    end
    
    -- SV dragging
    svPicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSV = true
            local pos = Vector2.new(
                math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1),
                math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
            )
            currentS = pos.X
            currentV = 1 - pos.Y
            svCursor.Position = UDim2.new(pos.X, -6, pos.Y, -6)
            updateColor()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(
                math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1),
                math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
            )
            currentS = pos.X
            currentV = 1 - pos.Y
            svCursor.Position = UDim2.new(pos.X, -6, pos.Y, -6)
            updateColor()
        elseif isDraggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            currentH = pos
            hueCursor.Position = UDim2.new(pos, -6, 0, -2)
            svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            updateColor()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSV = false
            isDraggingHue = false
        end
    end)
    
    -- Hue dragging
    hueTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            local pos = math.clamp((input.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
            currentH = pos
            hueCursor.Position = UDim2.new(pos, -6, 0, -2)
            svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            updateColor()
        end
    end)
    
    -- Hex input
    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16) or 0
            local g = tonumber(hex:sub(3, 4), 16) or 0
            local b = tonumber(hex:sub(5, 6), 16) or 0
            local newColor = Color3.fromRGB(r, g, b)
            currentH, currentS, currentV = Color3.toHSV(newColor)
            svCursor.Position = UDim2.new(currentS, -6, 1 - currentV, -6)
            hueCursor.Position = UDim2.new(currentH, -6, 0, -2)
            svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            previewBtn.BackgroundColor3 = newColor
            callback(newColor)
        end
    end)
    
    -- Toggle menu
    previewBtn.MouseButton1Click:Connect(function()
        isMenuOpen = not isMenuOpen
        
        if isMenuOpen then
            pickerMenu.Visible = true
            TweenService:Create(pickerMenu, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, 220)
            }):Play()
            container.Size = UDim2.new(1, 0, 0, 260)
        else
            TweenService:Create(pickerMenu, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            container.Size = UDim2.new(1, 0, 0, 36)
            task.delay(0.2, function()
                pickerMenu.Visible = false
            end)
        end
    end)
    
    -- Color picker object
    local colorObj = {
        Type = "ColorPicker",
        Frame = container,
        Library = lib,
        GetColor = function() return Color3.fromHSV(currentH, currentS, currentV) end,
        SetColor = function(self, color)
            currentH, currentS, currentV = Color3.toHSV(color)
            previewBtn.BackgroundColor3 = color
            svPicker.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
            hexInput.Text = string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
            callback(color)
        end,
    }
    
    return colorObj
end

-- ═══════════════════════════════════════════════════════════════
-- PROGRESS BAR COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateProgressBar(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Progress"
    local showPercent = config.ShowPercentage ~= false
    local barColor = config.Color or theme.Accent or Color3.fromRGB(100, 150, 255)
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "ProgressBar_" .. text
    container.Size = UDim2.new(1, 0, 0, showPercent and 50 or 30)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "ProgressLabel"
    label.Size = UDim2.new(1, showPercent and -60 or 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Percentage label
    local percentLabel
    if showPercent then
        percentLabel = Instance.new("TextLabel")
        percentLabel.Name = "PercentLabel"
        percentLabel.Size = UDim2.new(0, 55, 0, 18)
        percentLabel.Position = UDim2.new(1, -55, 0, 0)
        percentLabel.BackgroundTransparency = 1
        percentLabel.Text = "0%"
        percentLabel.TextColor3 = theme.Accent or Color3.fromRGB(100, 150, 255)
        percentLabel.TextSize = 12
        percentLabel.Font = Enum.Font.GothamSemibold
        percentLabel.TextXAlignment = Enum.TextXAlignment.Right
        percentLabel.Parent = container
    end
    
    -- Track
    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, showPercent and 28 or 20)
    track.BackgroundColor3 = theme.SliderTrack or Color3.fromRGB(45, 45, 58)
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = "ProgressFill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = barColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Progress bar object
    local progressObj = {
        Type = "ProgressBar",
        Frame = container,
        Library = lib,
        GetProgress = function() return fill.Size.X.Scale end,
        SetProgress = function(self, percent)
            percent = math.clamp(percent, 0, 1)
            TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(percent, 0, 1, 0)
            }):Play()
            if percentLabel then
                percentLabel.Text = tostring(math.floor(percent * 100)) .. "%"
            end
        end,
        SetColor = function(self, color)
            barColor = color
            fill.BackgroundColor3 = color
        end,
    }
    
    return progressObj
end

-- ═══════════════════════════════════════════════════════════════
-- SEARCH BAR COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateSearchBar(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local placeholder = config.Placeholder or "Search..."
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "SearchBar"
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    
    -- Search frame
    local frame = Instance.new("Frame")
    frame.Name = "SearchFrame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = theme.InputBg or Color3.fromRGB(38, 38, 50)
    frame.BorderSizePixel = 0
    frame.Parent = container
    
    local frameCorner = CreateCorner(frame, 10)
    local frameStroke = CreateStroke(frame, theme.InputBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Search icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "SearchIcon"
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 10, 0.5, -9)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://3926307975"
    icon.ImageRectOffset = Vector2.new(964, 324)
    icon.ImageRectSize = Vector2.new(36, 36)
    icon.ImageColor3 = theme.TextTertiary or Color3.fromRGB(100, 100, 120)
    icon.Parent = frame
    
    -- Textbox
    local textbox = Instance.new("TextBox")
    textbox.Name = "SearchInput"
    textbox.Size = UDim2.new(1, -50, 1, 0)
    textbox.Position = UDim2.new(0, 34, 0, 0)
    textbox.BackgroundTransparency = 1
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = theme.InputPlaceholder or Color3.fromRGB(100, 100, 120)
    textbox.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    textbox.TextSize = 13
    textbox.Font = Enum.Font.Gotham
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame
    
    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "ClearBtn"
    clearBtn.Size = UDim2.new(0, 20, 0, 20)
    clearBtn.Position = UDim2.new(1, -26, 0.5, -10)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text = "×"
    clearBtn.TextColor3 = theme.TextTertiary or Color3.fromRGB(100, 100, 120)
    clearBtn.TextSize = 18
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Visible = false
    clearBtn.Parent = frame
    
    -- Events
    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        local hasText = #textbox.Text > 0
        clearBtn.Visible = hasText
        icon.ImageColor3 = hasText and (theme.Accent or Color3.fromRGB(100, 150, 255)) or (theme.TextTertiary or Color3.fromRGB(100, 100, 120))
        callback(textbox.Text)
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        textbox.Text = ""
        callback("")
    end)
    
    textbox.Focused:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SurfaceHover or Color3.fromRGB(48, 48, 62)
        }):Play()
        TweenService:Create(frameStroke, TweenInfo.new(0.2), {
            Color = theme.InputBorderFocus or Color3.fromRGB(100, 150, 255),
            Transparency = 0.2
        }):Play()
    end)
    
    textbox.FocusLost:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.InputBg or Color3.fromRGB(38, 38, 50)
        }):Play()
        TweenService:Create(frameStroke, TweenInfo.new(0.2), {
            Color = theme.InputBorder or Color3.fromRGB(55, 55, 72),
            Transparency = 0.5
        }):Play()
    end)
    
    -- Search bar object
    local searchObj = {
        Type = "SearchBar",
        Frame = container,
        TextBox = textbox,
        Library = lib,
        GetText = function() return textbox.Text end,
        SetText = function(self, value)
            textbox.Text = value
        end,
        Focus = function(self)
            textbox:CaptureFocus()
        end,
    }
    
    return searchObj
end

-- ═══════════════════════════════════════════════════════════════
-- MULTI DROPDOWN COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateMultiDropdown(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local text = config.Name or config.Text or "Multi Dropdown"
    local options = config.Options or config.Values or {}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "MultiDropdown_" .. text
    container.Size = UDim2.new(1, 0, 0, 66)
    container.BackgroundTransparency = 1
    container.Parent = parent.Content or parent.Page
    container.ClipsDescendants = false
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "MultiDropdownLabel"
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Dropdown button
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Name = "MultiDropdownBtn"
    dropdownBtn.Size = UDim2.new(1, 0, 0, 36)
    dropdownBtn.Position = UDim2.new(0, 0, 0, 22)
    dropdownBtn.BackgroundColor3 = theme.DropdownBg or Color3.fromRGB(38, 38, 50)
    dropdownBtn.Text = ""
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.Parent = container
    
    local btnCorner = CreateCorner(dropdownBtn, 10)
    local btnStroke = CreateStroke(dropdownBtn, theme.DropdownBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Selected text
    local selectedText = Instance.new("TextLabel")
    selectedText.Name = "SelectedText"
    selectedText.Size = UDim2.new(1, -40, 1, 0)
    selectedText.Position = UDim2.new(0, 12, 0, 0)
    selectedText.BackgroundTransparency = 1
    selectedText.Text = #default > 0 and table.concat(default, ", ") or "Select options..."
    selectedText.TextColor3 = #default > 0 and (theme.TextPrimary or Color3.fromRGB(230, 230, 235)) 
        or (theme.TextTertiary or Color3.fromRGB(100, 100, 120))
    selectedText.TextSize = 13
    selectedText.Font = Enum.Font.Gotham
    selectedText.TextXAlignment = Enum.TextXAlignment.Left
    selectedText.TextTruncate = Enum.TextTruncate.AtEnd
    selectedText.Parent = dropdownBtn
    
    -- Arrow icon
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -26, 0.5, -8)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://3926307975"
    arrow.ImageRectOffset = Vector2.new(324, 524)
    arrow.ImageRectSize = Vector2.new(36, 36)
    arrow.ImageColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
    arrow.Rotation = 0
    arrow.Parent = dropdownBtn
    
    -- Dropdown menu
    local menu = Instance.new("Frame")
    menu.Name = "MultiDropdownMenu"
    menu.Size = UDim2.new(1, 0, 0, 0)
    menu.Position = UDim2.new(0, 0, 0, 60)
    menu.BackgroundColor3 = theme.DropdownBg or Color3.fromRGB(38, 38, 50)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 10
    menu.Parent = container
    
    local menuCorner = CreateCorner(menu, 10)
    local menuStroke = CreateStroke(menu, theme.DropdownBorder or Color3.fromRGB(55, 55, 72), 1, 0.5)
    
    -- Shadow
    local menuShadow = Instance.new("ImageLabel")
    menuShadow.Name = "MenuShadow"
    menuShadow.Size = UDim2.new(1, 20, 1, 20)
    menuShadow.Position = UDim2.new(0, -10, 0, -10)
    menuShadow.BackgroundTransparency = 1
    menuShadow.Image = "rbxassetid://5554236805"
    menuShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    menuShadow.ImageTransparency = 0.6
    menuShadow.ScaleType = Enum.ScaleType.Slice
    menuShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    menuShadow.ZIndex = 9
    menuShadow.Parent = menu
    
    -- Scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Scroll"
    scrollFrame.Size = UDim2.new(1, -8, 1, -8)
    scrollFrame.Position = UDim2.new(0, 4, 0, 4)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = theme.ScrollBar or Color3.fromRGB(70, 70, 85)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ZIndex = 11
    scrollFrame.Parent = menu
    
    local scrollLayout = CreateListLayout(scrollFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 2)
    CreatePadding(scrollFrame, 4, 4, 4, 4)
    
    -- State
    local isOpen = false
    local selected = {}
    for _, v in ipairs(default) do
        selected[v] = true
    end
    local optionButtons = {}
    
    local function createOption(optionText)
        local isSelected = selected[optionText] == true
        
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = "Option_" .. optionText
        optionBtn.Size = UDim2.new(1, 0, 0, 30)
        optionBtn.BackgroundColor3 = isSelected 
            and (theme.DropdownItemSelected or Color3.fromRGB(52, 52, 68))
            or (theme.DropdownItem or Color3.fromRGB(42, 42, 55))
        optionBtn.Text = ""
        optionBtn.AutoButtonColor = false
        optionBtn.ZIndex = 12
        optionBtn.Parent = scrollFrame
        
        local optCorner = CreateCorner(optionBtn, 6)
        
        -- Checkbox
        local checkbox = Instance.new("Frame")
        checkbox.Name = "Checkbox"
        checkbox.Size = UDim2.new(0, 16, 0, 16)
        checkbox.Position = UDim2.new(0, 8, 0.5, -8)
        checkbox.BackgroundColor3 = isSelected 
            and (theme.Accent or Color3.fromRGB(100, 150, 255))
            or (theme.InputBg or Color3.fromRGB(38, 38, 50))
        checkbox.BorderSizePixel = 0
        checkbox.ZIndex = 13
        checkbox.Parent = optionBtn
        
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 4)
        checkCorner.Parent = checkbox
        
        -- Checkmark
        if isSelected then
            local checkmark = Instance.new("ImageLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(1, -4, 1, -4)
            checkmark.Position = UDim2.new(0, 2, 0, 2)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://3926305904"
            checkmark.ImageRectOffset = Vector2.new(312, 4)
            checkmark.ImageRectSize = Vector2.new(24, 24)
            checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
            checkmark.ZIndex = 14
            checkmark.Parent = checkbox
        end
        
        local optText = Instance.new("TextLabel")
        optText.Name = "OptionText"
        optText.Size = UDim2.new(1, -40, 1, 0)
        optText.Position = UDim2.new(0, 30, 0, 0)
        optText.BackgroundTransparency = 1
        optText.Text = optionText
        optText.TextColor3 = isSelected 
            and (theme.Accent or Color3.fromRGB(100, 150, 255))
            or (theme.TextPrimary or Color3.fromRGB(230, 230, 235))
        optText.TextSize = 12
        optText.Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham
        optText.TextXAlignment = Enum.TextXAlignment.Left
        optText.TextTruncate = Enum.TextTruncate.AtEnd
        optText.ZIndex = 13
        optText.Parent = optionBtn
        
        -- Hover
        optionBtn.MouseEnter:Connect(function()
            if not selected[optionText] then
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = theme.DropdownItemHover or Color3.fromRGB(55, 55, 72)
                }):Play()
            end
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if not selected[optionText] then
                TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = theme.DropdownItem or Color3.fromRGB(42, 42, 55)
                }):Play()
            end
        end)
        
        -- Toggle selection
        optionBtn.MouseButton1Click:Connect(function()
            selected[optionText] = not selected[optionText]
            isSelected = selected[optionText]
            
            TweenService:Create(optionBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = isSelected 
                    and (theme.DropdownItemSelected or Color3.fromRGB(52, 52, 68))
                    or (theme.DropdownItem or Color3.fromRGB(42, 42, 55))
            }):Play()
            
            TweenService:Create(checkbox, TweenInfo.new(0.15), {
                BackgroundColor3 = isSelected 
                    and (theme.Accent or Color3.fromRGB(100, 150, 255))
                    or (theme.InputBg or Color3.fromRGB(38, 38, 50))
            }):Play()
            
            optText.TextColor3 = isSelected 
                and (theme.Accent or Color3.fromRGB(100, 150, 255))
                or (theme.TextPrimary or Color3.fromRGB(230, 230, 235))
            optText.Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham
            
            -- Checkmark
            if isSelected then
                local checkmark = Instance.new("ImageLabel")
                checkmark.Name = "Checkmark"
                checkmark.Size = UDim2.new(1, -4, 1, -4)
                checkmark.Position = UDim2.new(0, 2, 0, 2)
                checkmark.BackgroundTransparency = 1
                checkmark.Image = "rbxassetid://3926305904"
                checkmark.ImageRectOffset = Vector2.new(312, 4)
                checkmark.ImageRectSize = Vector2.new(24, 24)
                checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
                checkmark.ZIndex = 14
                checkmark.Parent = checkbox
            else
                local check = checkbox:FindFirstChild("Checkmark")
                if check then check:Destroy() end
            end
            
            -- Update selected text
            local selectedList = {}
            for opt, isSel in pairs(selected) do
                if isSel then
                    table.insert(selectedList, opt)
                end
            end
            
            selectedText.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "Select options..."
            selectedText.TextColor3 = #selectedList > 0 and (theme.TextPrimary or Color3.fromRGB(230, 230, 235)) 
                or (theme.TextTertiary or Color3.fromRGB(100, 100, 120))
            
            callback(selectedList)
        end)
        
        table.insert(optionButtons, optionBtn)
        return optionBtn
    end
    
    -- Create options
    for _, option in ipairs(options) do
        createOption(option)
    end
    
    -- Toggle menu
    dropdownBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            menu.Visible = true
            local targetHeight = math.min(#options * 32 + 8, 200)
            TweenService:Create(menu, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, targetHeight)
            }):Play()
            TweenService:Create(arrow, TweenInfo.new(0.25), {Rotation = 180}):Play()
        else
            TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
            task.delay(0.2, function()
                menu.Visible = false
            end)
        end
    end)
    
    -- Multi dropdown object
    local multiObj = {
        Type = "MultiDropdown",
        Frame = container,
        Library = lib,
        GetSelected = function()
            local selectedList = {}
            for opt, isSel in pairs(selected) do
                if isSel then
                    table.insert(selectedList, opt)
                end
            end
            return selectedList
        end,
        SetSelected = function(self, values)
            selected = {}
            for _, v in ipairs(values) do
                selected[v] = true
            end
            local selectedList = {}
            for opt, isSel in pairs(selected) do
                if isSel then
                    table.insert(selectedList, opt)
                end
            end
            selectedText.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "Select options..."
            callback(selectedList)
        end,
        Refresh = function(self, newOptions)
            options = newOptions
            selected = {}
            for _, btn in ipairs(optionButtons) do
                btn:Destroy()
            end
            optionButtons = {}
            for _, option in ipairs(options) do
                createOption(option)
            end
            selectedText.Text = "Select options..."
        end,
    }
    
    return multiObj
end

-- ═══════════════════════════════════════════════════════════════
-- ACCORDION COMPONENT
-- ═══════════════════════════════════════════════════════════════

function Components.CreateAccordion(parent, config)
    config = config or {}
    local lib = parent.Library
    local theme = GetTheme(lib)
    local title = config.Title or "Accordion"
    local defaultOpen = config.DefaultOpen or false
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Accordion_" .. title
    container.Size = UDim2.new(1, 0, 0, 0)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.BackgroundColor3 = theme.SectionBg or Color3.fromRGB(30, 30, 38)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent.Content or parent.Page
    
    local containerCorner = CreateCorner(container, 10)
    
    -- Header button
    local header = Instance.new("TextButton")
    header.Name = "AccordionHeader"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = container
    
    CreatePadding(header, 0, 0, 12, 12)
    
    local headerLayout = CreateListLayout(header, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, 8)
    
    -- Arrow icon
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "AccordionArrow"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://3926307975"
    arrow.ImageRectOffset = Vector2.new(324, 524)
    arrow.ImageRectSize = Vector2.new(36, 36)
    arrow.ImageColor3 = theme.TextSecondary or Color3.fromRGB(155, 155, 175)
    arrow.Rotation = defaultOpen and 180 or 0
    arrow.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "AccordionTitle"
    titleLabel.Size = UDim2.new(1, -24, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.TextPrimary or Color3.fromRGB(230, 230, 235)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Content (collapsible)
    local content = Instance.new("Frame")
    content.Name = "AccordionContent"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 36)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Visible = defaultOpen
    content.Parent = container
    
    local contentLayout = CreateListLayout(content, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, 8)
    CreatePadding(content, 4, 8, 4, 4)
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -16, 0, 1)
    divider.Position = UDim2.new(0, 8, 0, 34)
    divider.BackgroundColor3 = theme.SectionBorder or Color3.fromRGB(45, 45, 58)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = container
    
    -- Toggle function
    local isOpen = defaultOpen
    
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        TweenService:Create(arrow, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Rotation = isOpen and 180 or 0
        }):Play()
        
        if isOpen then
            content.Visible = true
        else
            task.delay(0.25, function()
                if not isOpen then
                    content.Visible = false
                end
            end)
        end
    end)
    
    -- Hover effect
    header.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SurfaceHover or Color3.fromRGB(40, 40, 52)
        }):Play()
    end)
    
    header.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.SectionBg or Color3.fromRGB(30, 30, 38)
        }):Play()
    end)
    
    -- Accordion object
    local accordionObj = {
        Type = "Accordion",
        Frame = container,
        Content = content,
        Library = lib,
        IsOpen = function() return isOpen end,
        Toggle = function(self)
            header.MouseButton1Click:Fire()
        end,
        Open = function(self)
            if not isOpen then self:Toggle() end
        end,
        Close = function(self)
            if isOpen then self:Toggle() end
        end,
    }
    
    return accordionObj
end

return Components