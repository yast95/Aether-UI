--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           A E T H E R   U I  —  E X A M P L E                ║
    ║                                                              ║
    ║  Comprehensive usage example showing all features:           ║
    ║  - Multiple themes                                           ║
    ║  - All component types                                       ║
    ║  - Advanced configuration                                    ║
    ║  - Animation usage                                           ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Load AetherUI
local AetherUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AetherStudio/AetherUI/main/AetherUI.lua"))()

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE 1: Basic Usage
-- ═══════════════════════════════════════════════════════════════

local function ExampleBasic()
    -- Create library with default config
    local UI = AetherUI.new()
    
    -- Create a window
    local Window = UI:CreateWindow({
        Title = "AetherUI Demo",
        SubTitle = "Basic Example",
        Width = 700,
        Height = 500,
    })
    
    -- Add tabs
    local MainTab = Window:AddTab({Name = "Main", Icon = "Home"})
    local SettingsTab = Window:AddTab({Name = "Settings", Icon = "Settings"})
    local VisualsTab = Window:AddTab({Name = "Visuals", Icon = "Eye"})
    
    -- Add components to Main tab
    local MainSection = MainTab:AddSection({
        Name = "Core Features",
        Description = "Essential UI components",
        Icon = "Zap"
    })
    
    MainSection:AddButton({
        Name = "Click Me!",
        Description = "A simple button with a description",
        Style = "Primary",
        Icon = "MousePointer",
        Callback = function()
            print("Button clicked!")
            Window:Notify({
                Title = "Success!",
                Content = "You clicked the button!",
                Type = "Success",
                Duration = 3
            })
        end
    })
    
    MainSection:AddButton({
        Name = "Danger Button",
        Style = "Danger",
        Callback = function()
            UI:CreateDialog({
                Title = "Are you sure?",
                Content = "This action cannot be undone.",
                Buttons = {
                    {
                        Text = "Cancel",
                        Callback = function() end
                    },
                    {
                        Text = "Delete",
                        Primary = true,
                        Callback = function()
                            print("Deleted!")
                        end
                    }
                }
            })
        end
    })
    
    MainSection:AddToggle({
        Name = "Enable Feature",
        Default = false,
        Callback = function(state)
            print("Feature enabled:", state)
        end
    })
    
    MainSection:AddSlider({
        Name = "Speed",
        Min = 0,
        Max = 100,
        Default = 50,
        Increment = 5,
        Suffix = "%",
        Callback = function(value)
            print("Speed:", value)
        end
    })
    
    MainSection:AddDropdown({
        Name = "Select Mode",
        Options = {"Normal", "Fast", "Extreme", "Custom"},
        Default = "Normal",
        Callback = function(selection)
            print("Selected mode:", selection)
        end
    })
    
    MainSection:AddTextbox({
        Name = "Username",
        Placeholder = "Enter your username...",
        Default = "Player123",
        Callback = function(text)
            print("Username:", text)
        end,
        FinishedCallback = function(text, enterPressed)
            if enterPressed then
                print("Final username:", text)
            end
        end
    })
    
    -- Settings tab
    local ThemeSection = SettingsTab:AddSection({
        Name = "Appearance",
        Icon = "Palette"
    })
    
    ThemeSection:AddDropdown({
        Name = "Theme",
        Options = {"Dark", "Light", "Midnight", "Ocean", "Sunset", "Forest"},
        Default = "Dark",
        Callback = function(theme)
            UI.ThemeManager:SetTheme(theme)
        end
    })
    
    ThemeSection:AddToggle({
        Name = "Animations",
        Default = true,
        Callback = function(enabled)
            UI.AnimationManager:SetEnabled(enabled)
        end
    })
    
    ThemeSection:AddToggle({
        Name = "Sound Effects",
        Default = false,
        Callback = function(enabled)
            UI.Config.Theme.SoundEnabled = enabled
        end
    })
    
    ThemeSection:AddSlider({
        Name = "Animation Speed",
        Min = 0.1,
        Max = 1,
        Default = 0.35,
        Increment = 0.05,
        Suffix = "s",
        Callback = function(value)
            UI.Config.Theme.AnimationSpeed = value
        end
    })
    
    -- Visuals tab
    local VisualSection = VisualsTab:AddSection({
        Name = "ESP Settings",
        Icon = "Eye"
    })
    
    VisualSection:AddToggle({
        Name = "Enable ESP",
        Default = true,
        Callback = function(state)
            print("ESP:", state)
        end
    })
    
    VisualSection:AddColorPicker({
        Name = "ESP Color",
        Default = Color3.fromRGB(255, 50, 50),
        Callback = function(color)
            print("ESP Color:", tostring(color))
        end
    })
    
    VisualSection:AddSlider({
        Name = "ESP Range",
        Min = 100,
        Max = 2000,
        Default = 500,
        Increment = 50,
        Suffix = " studs",
        Callback = function(value)
            print("Range:", value)
        end
    })
    
    VisualSection:AddDropdown({
        Name = "ESP Style",
        Options = {"Box", "Outline", "Filled", "Glow"},
        Default = "Box",
        Callback = function(style)
            print("ESP Style:", style)
        end
    })
    
    -- Keybind example
    local KeybindSection = MainTab:AddSection({
        Name = "Keybinds",
        Icon = "Keyboard"
    })
    
    KeybindSection:AddKeybind({
        Name = "Toggle UI",
        Default = Enum.KeyCode.RightShift,
        Callback = function()
            UI:ToggleUI()
        end
    })
    
    KeybindSection:AddKeybind({
        Name = "Quick Action",
        Default = Enum.KeyCode.F,
        Hold = true,
        Callback = function(holding)
            print("Quick action:", holding and "holding" or "released")
        end
    })
    
    return UI, Window
end

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE 2: Advanced Configuration
-- ═══════════════════════════════════════════════════════════════

local function ExampleAdvanced()
    -- Create library with custom configuration
    local UI = AetherUI.new({
        Window = {
            Title = "My Custom UI",
            SubTitle = "Advanced Configuration",
            Width = 800,
            Height = 600,
            CornerRadius = 20,
            BlurEnabled = true,
            BlurIntensity = 0.2,
            ShadowEnabled = true,
            ShadowIntensity = 0.4,
            AnimationSpeed = 0.5,
            ToggleKey = Enum.KeyCode.Insert,
        },
        Theme = {
            Mode = "Ocean",
            AnimationsEnabled = true,
            AnimationSpeed = 0.4,
            SoundEnabled = true,
            SoundVolume = 0.2,
            GlassEffect = true,
            GlassTransparency = 0.1,
        },
        Notifications = {
            Position = "TopRight",
            Duration = 5,
            MaxVisible = 3,
        },
        SaveConfig = true,
        ConfigFolder = "MyScript_Configs",
    })
    
    -- Create main window
    local Window = UI:CreateWindow()
    
    -- Create a complex tab structure
    local CombatTab = Window:AddTab({Name = "Combat", Icon = "Crosshair"})
    local MovementTab = Window:AddTab({Name = "Movement", Icon = "Zap"})
    local VisualTab = Window:AddTab({Name = "Visual", Icon = "Eye"})
    local MiscTab = Window:AddTab({Name = "Misc", Icon = "Grid"})
    local ConfigTab = Window:AddTab({Name = "Config", Icon = "Save"})
    
    -- Combat tab with accordions
    local AimbotAccordion = CombatTab:AddAccordion({
        Title = "Aimbot Settings",
        DefaultOpen = true
    })
    
    AimbotAccordion.Content:AddToggle({
        Name = "Enabled",
        Default = false,
        Callback = function(v) print("Aimbot:", v) end
    })
    
    AimbotAccordion.Content:AddSlider({
        Name = "Smoothness",
        Min = 1,
        Max = 100,
        Default = 50,
        Suffix = "%"
    })
    
    AimbotAccordion.Content:AddDropdown({
        Name = "Target Part",
        Options = {"Head", "Torso", "HumanoidRootPart"},
        Default = "Head"
    })
    
    local SilentAimAccordion = CombatTab:AddAccordion({
        Title = "Silent Aim"
    })
    
    SilentAimAccordion.Content:AddToggle({
        Name = "Enabled",
        Default = false
    })
    
    SilentAimAccordion.Content:AddSlider({
        Name = "Hit Chance",
        Min = 1,
        Max = 100,
        Default = 80,
        Suffix = "%"
    })
    
    -- Movement tab
    local FlySection = MovementTab:AddSection({Name = "Flight"})
    FlySection:AddToggle({Name = "Fly Enabled"})
    FlySection:AddSlider({Name = "Fly Speed", Min = 10, Max = 200, Default = 50, Suffix = "sps"})
    FlySection:AddKeybind({Name = "Fly Key", Default = Enum.KeyCode.F})
    
    local SpeedSection = MovementTab:AddSection({Name = "Speed"})
    SpeedSection:AddToggle({Name = "Speed Enabled"})
    SpeedSection:AddSlider({Name = "Speed Multiplier", Min = 1, Max = 10, Default = 2, Increment = 0.5, Suffix = "x"})
    
    -- Config tab
    local ThemeSection = ConfigTab:AddSection({Name = "Theme"})
    
    local themes = {"Dark", "Light", "Midnight", "Ocean", "Sunset", "Forest"}
    ThemeSection:AddDropdown({
        Name = "Select Theme",
        Options = themes,
        Default = "Ocean",
        Callback = function(themeName)
            UI.ThemeManager:SetTheme(themeName)
        end
    })
    
    -- Save/Load buttons
    ThemeSection:AddButton({
        Name = "Save Configuration",
        Style = "Success",
        Icon = "Save",
        Callback = function()
            UI:SaveConfig()
            Window:Notify({
                Title = "Config Saved",
                Content = "Your settings have been saved!",
                Type = "Success"
            })
        end
    })
    
    ThemeSection:AddButton({
        Name = "Load Configuration",
        Style = "Secondary",
        Icon = "Download",
        Callback = function()
            UI:LoadConfig()
            Window:Notify({
                Title = "Config Loaded",
                Content = "Your settings have been loaded!",
                Type = "Info"
            })
        end
    })
    
    -- Show initial notification
    task.delay(1, function()
        Window:Notify({
            Title = "AetherUI Loaded",
            Content = "Press " .. UI.Config.Window.ToggleKey.Name .. " to toggle the UI",
            Type = "Info",
            Duration = 5
        })
    end)
    
    return UI, Window
end

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE 3: Custom Theme Creation
-- ═══════════════════════════════════════════════════════════════

local function ExampleCustomTheme()
    local UI = AetherUI.new({
        Theme = {
            Mode = "Custom",
            CustomTheme = {
                -- Define your own colors
                Background = Color3.fromRGB(10, 10, 15),
                Accent = Color3.fromRGB(255, 100, 200),
                AccentLight = Color3.fromRGB(255, 140, 220),
                TextPrimary = Color3.fromRGB(240, 240, 245),
                TextSecondary = Color3.fromRGB(160, 160, 180),
                ButtonPrimary = Color3.fromRGB(255, 100, 200),
                ToggleOn = Color3.fromRGB(255, 100, 200),
                SliderFill = Color3.fromRGB(255, 100, 200),
            }
        }
    })
    
    local Window = UI:CreateWindow({
        Title = "Custom Theme UI",
        SubTitle = "Pink Accent"
    })
    
    local Tab = Window:AddTab({Name = "Home", Icon = "Home"})
    
    local Section = Tab:AddSection({Name = "Custom Themed"})
    Section:AddButton({Name = "Pink Button!", Style = "Primary"})
    Section:AddToggle({Name = "Pink Toggle"})
    Section:AddSlider({Name = "Pink Slider", Min = 0, Max = 100, Default = 50})
    
    return UI, Window
end

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE 4: Notification Demo
-- ═══════════════════════════════════════════════════════════════

local function ExampleNotifications(UI, Window)
    local Tab = Window:AddTab({Name = "Notifications", Icon = "Bell"})
    local Section = Tab:AddSection({Name = "Test Notifications"})
    
    Section:AddButton({
        Name = "Success Notification",
        Style = "Success",
        Callback = function()
            Window:Notify({
                Title = "Operation Complete",
                Content = "Your settings have been saved successfully!",
                Type = "Success",
                Duration = 4
            })
        end
    })
    
    Section:AddButton({
        Name = "Warning Notification",
        Style = "Primary",
        Callback = function()
            Window:Notify({
                Title = "Warning",
                Content = "You are approaching the rate limit. Please slow down.",
                Type = "Warning",
                Duration = 5
            })
        end
    })
    
    Section:AddButton({
        Name = "Error Notification",
        Style = "Danger",
        Callback = function()
            Window:Notify({
                Title = "Connection Failed",
                Content = "Could not connect to the server. Please try again later.",
                Type = "Error",
                Duration = 6
            })
        end
    })
    
    Section:AddButton({
        Name = "Multiple Notifications",
        Callback = function()
            for i = 1, 3 do
                task.delay(i * 0.3, function()
                    Window:Notify({
                        Title = "Notification " .. i,
                        Content = "This is notification number " .. i,
                        Type = i == 1 and "Info" or i == 2 and "Success" or "Warning",
                        Duration = 3
                    })
                end)
            end
        end
    })
end

-- ═══════════════════════════════════════════════════════════════
-- EXAMPLE 5: Dynamic UI Updates
-- ═══════════════════════════════════════════════════════════════

local function ExampleDynamicUI()
    local UI = AetherUI.new()
    local Window = UI:CreateWindow({Title = "Dynamic UI"})
    
    local Tab = Window:AddTab({Name = "Dynamic"})
    local Section = Tab:AddSection({Name = "Live Updates"})
    
    -- Progress bar that updates over time
    local ProgressBar = Section:AddProgressBar({
        Name = "Loading",
        ShowPercentage = true
    })
    
    -- Simulate loading
    task.spawn(function()
        local progress = 0
        while progress < 1 do
            progress = math.min(progress + math.random() * 0.1, 1)
            ProgressBar:SetProgress(progress)
            task.wait(0.2)
        end
        Window:Notify({
            Title = "Complete!",
            Content = "Loading finished successfully!",
            Type = "Success"
        })
    end)
    
    -- Search bar with filtering
    local SearchBar = Section:AddSearchBar({
        Placeholder = "Search items...",
        Callback = function(text)
            print("Searching for:", text)
        end
    })
    
    return UI, Window
end

-- ═══════════════════════════════════════════════════════════════
-- RUN EXAMPLES
-- ═══════════════════════════════════════════════════════════════

-- Uncomment the example you want to run:

-- Example 1: Basic usage
-- local UI, Window = ExampleBasic()

-- Example 2: Advanced configuration
-- local UI, Window = ExampleAdvanced()

-- Example 3: Custom theme
-- local UI, Window = ExampleCustomTheme()

-- Example 4: Notifications (requires UI and Window from another example)
-- ExampleNotifications(UI, Window)

-- Example 5: Dynamic UI
-- local UI, Window = ExampleDynamicUI()

print([[
    ╔══════════════════════════════════════════════════════════════╗
    ║              AetherUI Examples Loaded!                       ║
    ║                                                              ║
    ║  Uncomment one of the example functions above to test it.    ║
    ║  Or call: ExampleBasic(), ExampleAdvanced(), etc.            ║
    ╚══════════════════════════════════════════════════════════════╝
]])