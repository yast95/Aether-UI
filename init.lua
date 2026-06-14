--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           A E T H E R   U I  —  I N I T I A L I Z E R        ║
    ║                                                              ║
    ║  Loader that initializes all AetherUI modules in order:      ║
    ║  1. Utils      - Utility functions                           ║
    ║  2. Icons      - Icon registry                               ║
    ║  3. Themes     - Theme system with ColorUtils                ║
    ║  4. Animations - Animation system                            ║
    ║  5. Components - UI components                               ║
    ║  6. AetherUI   - Main library (integrates all above)         ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- Module paths configuration
-- Adjust these paths based on your environment
local ModulePaths = {
    Utils = script and script:FindFirstChild("Utils") or "Utils",
    Icons = script and script:FindFirstChild("Icons") or "Icons",
    Themes = script and script:FindFirstChild("Themes") or "Themes",
    Animations = script and script:FindFirstChild("Animations") or "Animations",
    Components = script and script:FindFirstChild("Components") or "Components",
    Core = script and script:FindFirstChild("AetherUI") or "AetherUI",
}

-- Loader function that handles different environments
local function LoadModule(path)
    if typeof(path) == "Instance" then
        -- Roblox environment
        return require(path)
    elseif typeof(path) == "string" then
        -- File system or URL-based environment
        -- Try require first (for bundled setups)
        local success, result = pcall(function()
            return require(path)
        end)
        if success then
            return result
        end
        
        -- Try loadstring for URL-based loading
        success, result = pcall(function()
            local url = path
            if not url:match("^https?://") and not url:match("^rbxassetid://") then
                -- Local file path
                return loadfile(path)()
            end
            return loadstring(game:HttpGet(url))()
        end)
        if success then
            return result
        end
        
        warn("[AetherUI] Failed to load module: " .. tostring(path))
        return nil
    end
    
    return nil
end

-- Load modules in dependency order
local Utils = LoadModule(ModulePaths.Utils)
local Icons = LoadModule(ModulePaths.Icons)
local Themes = LoadModule(ModulePaths.Themes)
local Animations = LoadModule(ModulePaths.Animations)
local Components = LoadModule(ModulePaths.Components)
local AetherUI = LoadModule(ModulePaths.Core)

-- Validate all modules loaded
local Modules = {
    {Name = "Utils", Module = Utils},
    {Name = "Icons", Module = Icons},
    {Name = "Themes", Module = Themes},
    {Name = "Animations", Module = Animations},
    {Name = "Components", Module = Components},
    {Name = "Core", Module = AetherUI},
}

local allLoaded = true
for _, mod in ipairs(Modules) do
    if mod.Module == nil then
        warn("[AetherUI] CRITICAL: Module '" .. mod.Name .. "' failed to load!")
        allLoaded = false
    end
end

if not allLoaded then
    warn("[AetherUI] Some modules failed to load. The library may not function correctly.")
end

-- Inject modules into AetherUI core
if AetherUI and AetherUI.LoadModules then
    AetherUI.LoadModules({
        Utils = Utils,
        Icons = Icons,
        Themes = Themes,
        Animations = Animations,
        Components = Components,
    })
else
    warn("[AetherUI] Core module does not have LoadModules function!")
end

-- Return the main AetherUI module
return AetherUI