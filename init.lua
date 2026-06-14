--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           A E T H E R   U I  —  I N I T I A L I Z E R        ║
    ║                                                              ║
    ║  Loader qui initialise tous les modules AetherUI dans        ║
    ║  l'ordre correct :                                           ║
    ║  1. Utils      - Fonctions utilitaires                       ║
    ║  2. Icons      - Registre d'icônes                           ║
    ║  3. Themes     - Système de thèmes                           ║
    ║  4. Animations - Système d'animations                        ║
    ║  5. Components - Composants UI                               ║
    ║  6. AetherUI   - Bibliothèque principale                     ║
    ║                                                              ║
    ║  Supporte 3 modes de chargement :                            ║
    ║  • URL (executor) : init("https://...")                      ║
    ║  • Roblox Studio  : require(script.Parent.AetherUI)          ║
    ║  • Require local  : require("AetherUI")                      ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURATION
-- Change BASE_URL pour pointer vers ton hébergeur (GitHub raw, etc.)
-- ═══════════════════════════════════════════════════════════════

local BASE_URL = "https://raw.githubusercontent.com/TON_USER/AetherUI/main/AetherUI/"

local MODULE_NAMES = {
    "Utils",
    "Icons",
    "Themes",
    "Animations",
    "Components",
    "AetherUI",
}

-- ═══════════════════════════════════════════════════════════════
-- DÉTECTION D'ENVIRONNEMENT
-- ═══════════════════════════════════════════════════════════════

local function IsRobloxStudio()
    local ok, rs = pcall(function() return game:GetService("RunService") end)
    return ok and rs:IsStudio()
end

local function CanHttpGet()
    local ok = pcall(function()
        game:GetService("HttpService").HttpEnabled
    end)
    return ok
end

-- ═══════════════════════════════════════════════════════════════
-- LOADERS
-- ═══════════════════════════════════════════════════════════════

--- Charge un module via URL (executor / HttpGet)
local function LoadFromURL(name)
    local url = BASE_URL .. name .. ".lua"
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if ok then
        return result
    end
    warn("[AetherUI] Échec chargement URL → " .. url .. " | " .. tostring(result))
    return nil
end

--- Charge un module via script enfant (Roblox Studio / ModuleScript)
local function LoadFromScript(name)
    if not script then return nil end
    local child = script:FindFirstChild(name) or script.Parent:FindFirstChild(name)
    if not child then return nil end
    local ok, result = pcall(require, child)
    if ok then return result end
    warn("[AetherUI] Échec require script → " .. name .. " | " .. tostring(result))
    return nil
end

--- Charge un module via require local (chemin string)
local function LoadFromRequire(name)
    local ok, result = pcall(require, name)
    if ok then return result end
    return nil
end

--- Routine principale de chargement avec fallbacks
local function LoadModule(name)
    local loaded = nil

    -- 1) Priorité : URL si BASE_URL est configurée et qu'on peut HttpGet
    if BASE_URL ~= "" and not IsRobloxStudio() then
        loaded = LoadFromURL(name)
        if loaded then return loaded end
    end

    -- 2) Script enfant (Roblox Studio / ServerScriptService)
    loaded = LoadFromScript(name)
    if loaded then return loaded end

    -- 3) require local (si le fichier est sur le path)
    loaded = LoadFromRequire(name)
    if loaded then return loaded end

    warn("[AetherUI] CRITIQUE : module '" .. name .. "' introuvable !")
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- CHARGEMENT ORDONNÉ
-- ═══════════════════════════════════════════════════════════════

local Utils      = LoadModule("Utils")
local Icons      = LoadModule("Icons")
local Themes     = LoadModule("Themes")
local Animations = LoadModule("Animations")
local Components = LoadModule("Components")
local AetherUI   = LoadModule("AetherUI")

-- ═══════════════════════════════════════════════════════════════
-- VALIDATION
-- ═══════════════════════════════════════════════════════════════

local Modules = {
    { Name = "Utils",      Module = Utils      },
    { Name = "Icons",      Module = Icons      },
    { Name = "Themes",     Module = Themes     },
    { Name = "Animations", Module = Animations },
    { Name = "Components", Module = Components },
    { Name = "AetherUI",   Module = AetherUI   },
}

local allLoaded = true
for _, mod in ipairs(Modules) do
    if mod.Module == nil then
        warn("[AetherUI] CRITIQUE : module '" .. mod.Name .. "' non chargé !")
        allLoaded = false
    end
end

if not allLoaded then
    warn("[AetherUI] Certains modules ont échoué. La bibliothèque peut être instable.")
end

-- ═══════════════════════════════════════════════════════════════
-- INJECTION DES DÉPENDANCES
-- ═══════════════════════════════════════════════════════════════

if AetherUI and AetherUI.LoadModules then
    AetherUI.LoadModules({
        Utils      = Utils,
        Icons      = Icons,
        Themes     = Themes,
        Animations = Animations,
        Components = Components,
    })
else
    warn("[AetherUI] Le module Core ne possède pas de fonction LoadModules !")
end

-- ═══════════════════════════════════════════════════════════════
-- RETOUR
-- ═══════════════════════════════════════════════════════════════

return AetherUI
