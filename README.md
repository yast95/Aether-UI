# AetherUI v2.0.0

## The Next Generation Lua UI Library

AetherUI is a modern, premium UI library for Lua (Roblox) featuring a **Liquid Glass** design language, advanced animations, and a complete component system. It surpasses existing libraries like WindUI, Rayfield, and Fluent UI in both visual quality and technical capabilities.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

### Design
- **Liquid Glass** design language with advanced transparency and blur effects
- GPU-friendly animations with hardware acceleration
- Dynamic shadows and depth effects
- 6 built-in themes: Dark, Light, Midnight, Ocean, Sunset, Forest
- Fully customizable themes with real-time switching
- Responsive and adaptable to different resolutions
- Rounded corners with configurable radius
- Modern gradients and glow effects

### Components
- **Window** — Draggable, resizable, with minimize/maximize/close
- **Tabs** — With icons and smooth transitions
- **Sections** — Grouped content with headers and descriptions
- **Button** — Primary, Secondary, Danger, Ghost, Success styles
- **Toggle** — Smooth animated switches
- **Slider** — With custom ranges, increments, and suffixes
- **Dropdown** — Single-select with search capability
- **Multi Dropdown** — Multi-select with checkboxes
- **Textbox** — With placeholders and callbacks
- **Label** — Default, Header, Subheader, Muted, Accent styles
- **Keybind** — With hold mode support
- **Color Picker** — HSV picker with hex input
- **Progress Bar** — Animated with percentage display
- **Search Bar** — With real-time filtering
- **Accordion** — Collapsible content sections
- **Notifications** — Info, Success, Warning, Error types
- **Dialogs** — Modal popups with custom buttons
- **Tooltips** — Contextual help text
- **Tables/Lists** — Sortable data display
- **Tree Views** — Hierarchical data structures

### Advanced Features
- **Animation System** — Tween-based, spring physics, sequencing
- **Theme Manager** — Light/Dark/Auto modes, custom themes, JSON import/export
- **Plugin System** — Extensible architecture
- **Hook System** — Event-driven callbacks
- **Sound Effects** — Optional audio feedback
- **Auto-Save** — Automatic configuration persistence
- **Keyboard Shortcuts** — Custom keybind registration
- **Vector Icons** — 100+ built-in icons

---

## Quick Start

```lua
local AetherUI = loadstring(game:HttpGet("URL_TO_AETHERUI"))()

-- Create the library
local UI = AetherUI.new()

-- Create a window
local Window = UI:CreateWindow({
    Title = "My Script",
    SubTitle = "v1.0",
    Width = 650,
    Height = 450,
})

-- Add a tab
local MainTab = Window:AddTab({
    Name = "Main",
    Icon = "Home"
})

-- Add a section
local Section = MainTab:AddSection({
    Name = "Features",
    Description = "Main script features",
    Icon = "Zap"
})

-- Add components
Section:AddButton({
    Name = "Execute",
    Style = "Primary",
    Callback = function()
        print("Button clicked!")
    end
})

Section:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(state)
        print("ESP:", state)
    end
})

Section:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Callback = function(value)
        print("Speed:", value)
    end
})
```

---

## API Reference

### AetherUI.new(config)

Creates a new AetherUI instance.

```lua
local UI = AetherUI.new({
    Window = {
        Title = "AetherUI",
        SubTitle = "v2.0.0",
        Width = 650,
        Height = 450,
        CornerRadius = 16,
        BlurEnabled = true,
        BlurIntensity = 0.15,
        ShadowEnabled = true,
        ShadowIntensity = 0.3,
        AnimationSpeed = 0.4,
        Draggable = true,
        Resizable = true,
        ToggleKey = Enum.KeyCode.RightShift,
    },
    Theme = {
        Mode = "Dark",           -- "Dark", "Light", "Auto", "Custom"
        AnimationsEnabled = true,
        AnimationSpeed = 0.35,
        SoundEnabled = false,
        SoundVolume = 0.3,
    },
    Notifications = {
        Position = "TopRight",   -- "TopRight", "TopLeft", "BottomRight", "BottomLeft"
        Duration = 4,
        MaxVisible = 5,
    },
    SaveConfig = true,
    ConfigFolder = "AetherUI_Configs",
})
```

### UI:CreateWindow(config)

Creates a new window and returns a Window object.

### Window:AddTab(config)

Adds a tab to the window.

```lua
local Tab = Window:AddTab({
    Name = "Main",
    Icon = "Home"  -- Optional icon name
})
```

### Window:Notify(config)

Shows a notification.

```lua
Window:Notify({
    Title = "Hello!",
    Content = "This is a notification",
    Type = "Info",        -- "Info", "Success", "Warning", "Error"
    Duration = 4,
    Icon = "Bell"         -- Optional
})
```

### Window:SetTitle(newTitle)

Changes the window title.

### Window:SetSize(width, height)

Resizes the window with animation.

### Tab:AddSection(config)

Adds a section to a tab.

```lua
local Section = Tab:AddSection({
    Name = "Features",
    Description = "Optional description",
    Icon = "Zap"           -- Optional
})
```

### Section:AddButton(config)

```lua
Section:AddButton({
    Name = "Click Me",
    Description = "Optional description",
    Style = "Primary",     -- "Primary", "Secondary", "Danger", "Ghost", "Success"
    Icon = "MousePointer", -- Optional
    Callback = function()
        print("Clicked!")
    end
})
```

### Section:AddToggle(config)

```lua
Section:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Callback = function(state)
        print("State:", state)
    end
})
```

Methods:
- `Toggle:GetState()` — Returns current state
- `Toggle:SetState(boolean)` — Sets the state

### Section:AddSlider(config)

```lua
Section:AddSlider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,         -- Step size
    Suffix = "%",          -- Display suffix
    Callback = function(value)
        print("Value:", value)
    end
})
```

Methods:
- `Slider:GetValue()` — Returns current value
- `Slider:SetValue(number)` — Sets the value

### Section:AddDropdown(config)

```lua
Section:AddDropdown({
    Name = "Select Mode",
    Options = {"Normal", "Fast", "Extreme"},
    Default = "Normal",
    Callback = function(selection)
        print("Selected:", selection)
    end
})
```

Methods:
- `Dropdown:GetSelected()` — Returns selected value
- `Dropdown:SetValue(value)` — Sets the selected value
- `Dropdown:Refresh(newOptions, keepSelected)` — Updates options

### Section:AddMultiDropdown(config)

```lua
Section:AddMultiDropdown({
    Name = "Select Features",
    Options = {"ESP", "Aimbot", "Triggerbot", "Chams"},
    Default = {"ESP"},
    Callback = function(selectedList)
        print("Selected:", table.concat(selectedList, ", "))
    end
})
```

Methods:
- `MultiDropdown:GetSelected()` — Returns table of selected values
- `MultiDropdown:SetSelected(values)` — Sets selected values

### Section:AddTextbox(config)

```lua
Section:AddTextbox({
    Name = "Username",
    Placeholder = "Enter username...",
    Default = "",
    ClearOnFocus = false,
    Callback = function(text)          -- Called on every change
        print("Typing:", text)
    end,
    FinishedCallback = function(text, enterPressed)  -- Called on focus lost
        print("Final:", text)
    end
})
```

Methods:
- `Textbox:GetText()` — Returns current text
- `Textbox:SetText(text)` — Sets the text

### Section:AddLabel(config)

```lua
Section:AddLabel({
    Text = "Hello World",
    Style = "Default",    -- "Default", "Header", "Subheader", "Muted", "Accent"
    Wrapped = false
})
```

### Section:AddKeybind(config)

```lua
Section:AddKeybind({
    Name = "Toggle",
    Default = Enum.KeyCode.F,
    Hold = false,         -- If true, callback receives boolean (pressed/released)
    Callback = function(keyOrHolding)
        print("Keybind triggered!")
    end
})
```

Methods:
- `Keybind:GetKey()` — Returns current KeyCode
- `Keybind:SetKey(KeyCode)` — Sets the keybind

### Section:AddColorPicker(config)

```lua
Section:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 50, 50),
    Callback = function(color)
        print("Color:", tostring(color))
    end
})
```

Methods:
- `ColorPicker:GetColor()` — Returns current Color3
- `ColorPicker:SetColor(Color3)` — Sets the color

### Section:AddProgressBar(config)

```lua
Section:AddProgressBar({
    Name = "Loading",
    ShowPercentage = true,
    Color = Color3.fromRGB(100, 150, 255)
})
```

Methods:
- `ProgressBar:SetProgress(0-1)` — Sets the progress

### Section:AddSearchBar(config)

```lua
Section:AddSearchBar({
    Placeholder = "Search...",
    Callback = function(text)
        print("Search:", text)
    end
})
```

### Section:AddAccordion(config)

```lua
local Accordion = Section:AddAccordion({
    Title = "Advanced Settings",
    DefaultOpen = false
})

Accordion.Content:AddToggle({Name = "Setting 1"})
Accordion.Content:AddSlider({Name = "Setting 2", Min = 0, Max = 100})
```

Methods:
- `Accordion:Toggle()` — Toggles open/close
- `Accordion:Open()` — Opens
- `Accordion:Close()` — Closes

---

## Themes

### Built-in Themes

| Theme | Description |
|-------|-------------|
| **Dark** | Default dark theme with blue accents |
| **Light** | Clean light theme |
| **Midnight** | Deep dark with purple accents |
| **Ocean** | Dark with teal/cyan accents |
| **Sunset** | Warm orange and rose tones |
| **Forest** | Dark with emerald green accents |

### Switching Themes

```lua
-- Switch to a preset theme
UI.ThemeManager:SetTheme("Ocean")

-- Auto-detect system theme
UI.ThemeManager:SetTheme("Auto")
```

### Creating Custom Themes

```lua
local UI = AetherUI.new({
    Theme = {
        Mode = "Custom",
        CustomTheme = {
            Background = Color3.fromRGB(20, 20, 25),
            Accent = Color3.fromRGB(255, 100, 200),
            TextPrimary = Color3.fromRGB(230, 230, 235),
            -- ... all theme colors
        }
    }
})
```

### Theme from Color

```lua
local customTheme = UI.ThemeManager:GenerateFromColor(Color3.fromRGB(255, 100, 200), "Dark")
UI.ThemeManager:SetCustomTheme(customTheme)
```

### Saving/Loading Themes

```lua
-- Export to JSON
local json = UI.ThemeManager:ExportToFile(nil, "mytheme.json")

-- Import from JSON
local theme = UI.ThemeManager:ImportFromFile("mytheme.json")
UI.ThemeManager:SetCustomTheme(theme)
```

---

## Animations

### Built-in Animations

```lua
-- Tween
UI.AnimationManager:Tween(object, {BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)

-- Fade In/Out
UI.AnimationManager:FadeIn(object, 0.4)
UI.AnimationManager:FadeOut(object, 0.3, true)  -- true = destroy after

-- Scale
UI.AnimationManager:ScaleIn(object, 0.4)

-- Slide
UI.AnimationManager:SlideIn(object, "Left", 50, 0.4)
UI.AnimationManager:SlideOut(object, "Right", 50, 0.3)

-- Bounce & Elastic
UI.AnimationManager:BounceIn(object, 0.6)
UI.AnimationManager:ElasticIn(object, 0.8)

-- Pulse
UI.AnimationManager:Pulse(object, 1.05, 0.4)

-- Shake
UI.AnimationManager:Shake(object, 5, 0.4)

-- Float/Bob
UI.AnimationManager:Float(object, 5, 2)

-- Rotate
UI.AnimationManager:Rotate(object, 360, true)

-- Parallax (mouse-based)
UI.AnimationManager:Parallax(object, 0.02)
```

### Spring Physics

```lua
UI.AnimationManager:Spring(object, {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}, {
    Tension = 300,
    Friction = 30
})
```

### Sequences

```lua
UI.AnimationManager:Sequence({
    {
        Tween = {
            Object = obj1,
            Properties = {Position = UDim2.new(0, 100, 0, 0)},
            Duration = 0.4
        }
    },
    {
        Delay = 0.1,
        Tween = {
            Object = obj2,
            Properties = {BackgroundTransparency = 0},
            Duration = 0.3
        }
    },
    {
        Action = function()
            print("Sequence complete!")
        end
    }
})
```

---

## Dialogs

```lua
UI:CreateDialog({
    Title = "Confirm Action",
    Content = "Are you sure you want to proceed?",
    Buttons = {
        {
            Text = "Cancel",
            Callback = function()
                print("Cancelled")
            end
        },
        {
            Text = "Confirm",
            Primary = true,
            Callback = function()
                print("Confirmed!")
            end
        }
    }
})
```

---

## Notifications

```lua
Window:Notify({
    Title = "Title",
    Content = "Message content here",
    Type = "Info",        -- "Info", "Success", "Warning", "Error"
    Duration = 4,
    Icon = "Bell"
})
```

---

## Keyboard Shortcuts

```lua
-- Register global shortcuts
UI:RegisterShortcut(Enum.KeyCode.F1, function()
    print("F1 pressed!")
end, "Show help")

-- Window toggle (built-in)
-- Press RightShift (default) to toggle UI visibility

-- Change toggle key
local UI = AetherUI.new({
    Window = {
        ToggleKey = Enum.KeyCode.Insert
    }
})
```

---

## Plugin System

```lua
-- Register a plugin
UI:RegisterPlugin("MyPlugin", {
    Name = "My Plugin",
    Version = "1.0",
    Init = function(ui)
        print("Plugin loaded!")
    end,
    -- Your plugin data and functions
})

-- Access plugin
local plugin = UI:GetPlugin("MyPlugin")
```

---

## Hooks

```lua
-- Add a hook
UI:AddHook("ThemeChanged", function(newTheme)
    print("Theme changed to:", newTheme.Name)
end)

-- Available hooks:
-- "ThemeChanged", "WindowCreated", "WindowClosed", 
-- "TabChanged", "PluginLoaded"
```

---

## Configuration Save/Load

```lua
-- Auto-save is enabled by default (saves every 30 seconds)

-- Manual save
UI:SaveConfig()

-- Manual load
UI:LoadConfig()

-- Config is saved as JSON in the ConfigFolder
```

---

## Project Structure

```
AetherUI/
├── AetherUI.lua      -- Main library file
├── Themes.lua        -- Theme system
├── Animations.lua    -- Animation system
├── Utils.lua         -- Utility functions
├── Icons.lua         -- Icon registry
├── Components.lua    -- UI components
├── Example.lua       -- Usage examples
└── README.md         -- Documentation
```

---

## Architecture

```
AetherUI (Main Library)
├── ThemeManager
│   ├── Presets (Dark, Light, Midnight, Ocean, Sunset, Forest)
│   ├── Custom Themes
│   └── ColorUtils
├── AnimationManager
│   ├── Tweens
│   ├── Springs
│   ├── Sequences
│   └── Continuous (Float, Rotate, Parallax)
├── Window[]
│   ├── Tabs[]
│   │   ├── Sections[]
│   │   │   ├── Buttons[]
│   │   │   ├── Toggles[]
│   │   │   ├── Sliders[]
│   │   │   ├── Dropdowns[]
│   │   │   ├── Textboxes[]
│   │   │   ├── Labels[]
│   │   │   ├── Keybinds[]
│   │   │   ├── ColorPickers[]
│   │   │   ├── ProgressBars[]
│   │   │   ├── SearchBars[]
│   │   │   ├── MultiDropdowns[]
│   │   │   └── Accordions[]
│   │   └── Notifications[]
│   └── Dialogs[]
├── Plugins[]
└── Hooks[]
```

---

## Performance Tips

1. **Disable animations** for maximum performance:
   ```lua
   UI.AnimationManager:SetEnabled(false)
   ```

2. **Use appropriate component counts** — avoid creating hundreds of components in a single tab

3. **Clean up unused notifications** — they auto-dismiss but keeping MaxVisible low helps

4. **Limit continuous animations** — Float, Rotate, and Parallax use Heartbeat connections

---

## License

MIT License — See LICENSE file for details.

---

## Credits

- **Aether Studio** — Design & Development
- Inspired by WindUI, Rayfield, and Fluent UI

---

*Built with precision. Designed for excellence.*