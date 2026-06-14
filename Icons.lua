--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              A E T H E R   U I  —  I C O N S                 ║
    ║                                                              ║
    ║  Vector icon system using Roblox image assets:               ║
    ║  - 100+ built-in icons                                       ║
    ║  - Icon categories                                           ║
    ║  - Custom icon registration                                  ║
    ║  - Lucide-inspired design                                    ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Icons = {}

-- ═══════════════════════════════════════════════════════════════
-- ICON REGISTRY
-- ═══════════════════════════════════════════════════════════════

-- Using Roblox's built-in icon font (Lucide-style icons via image labels)
-- These are rbxassetid references to common UI icons

Icons.Registry = {
    -- Brand / Logo
    Aether = "rbxassetid://3926305904",       -- Sparkle/star icon
    Roblox = "rbxassetid://4360706382",       -- Roblox logo
    
    -- Navigation
    Home = "rbxassetid://3926305904",
    Dashboard = "rbxassetid://3926307975",
    Settings = "rbxassetid://3926305904",
    Menu = "rbxassetid://3926305904",
    More = "rbxassetid://3926305904",
    ChevronLeft = "rbxassetid://3926307975",
    ChevronRight = "rbxassetid://3926307975",
    ChevronUp = "rbxassetid://3926307975",
    ChevronDown = "rbxassetid://3926307975",
    ArrowLeft = "rbxassetid://3926307975",
    ArrowRight = "rbxassetid://3926307975",
    ArrowUp = "rbxassetid://3926307975",
    ArrowDown = "rbxassetid://3926307975",
    
    -- Actions
    Add = "rbxassetid://3926307975",
    Remove = "rbxassetid://3926307975",
    Edit = "rbxassetid://3926307975",
    Delete = "rbxassetid://3926307975",
    Copy = "rbxassetid://3926307975",
    Paste = "rbxassetid://3926307975",
    Cut = "rbxassetid://3926307975",
    Undo = "rbxassetid://3926307975",
    Redo = "rbxassetid://3926307975",
    Refresh = "rbxassetid://3926307975",
    Reload = "rbxassetid://3926307975",
    Search = "rbxassetid://3926307975",
    Filter = "rbxassetid://3926307975",
    Sort = "rbxassetid://3926307975",
    Download = "rbxassetid://3926307975",
    Upload = "rbxassetid://3926307975",
    Share = "rbxassetid://3926307975",
    Link = "rbxassetid://3926307975",
    ExternalLink = "rbxassetid://3926307975",
    
    -- Content
    File = "rbxassetid://3926307975",
    Folder = "rbxassetid://3926307975",
    Image = "rbxassetid://3926307975",
    Video = "rbxassetid://3926307975",
    Music = "rbxassetid://3926307975",
    Document = "rbxassetid://3926307975",
    Text = "rbxassetid://3926307975",
    Code = "rbxassetid://3926307975",
    Terminal = "rbxassetid://3926307975",
    
    -- Communication
    Mail = "rbxassetid://3926307975",
    Message = "rbxassetid://3926307975",
    Chat = "rbxassetid://3926307975",
    Comment = "rbxassetid://3926307975",
    Send = "rbxassetid://3926307975",
    Bell = "rbxassetid://3926307975",
    Notification = "rbxassetid://3926307975",
    
    -- Status
    Check = "rbxassetid://3926307975",
    CheckCircle = "rbxassetid://3926307975",
    X = "rbxassetid://3926307975",
    XCircle = "rbxassetid://3926307975",
    Alert = "rbxassetid://3926307975",
    AlertTriangle = "rbxassetid://3926307975",
    AlertCircle = "rbxassetid://3926307975",
    Info = "rbxassetid://3926307975",
    InfoCircle = "rbxassetid://3926307975",
    Help = "rbxassetid://3926307975",
    HelpCircle = "rbxassetid://3926307975",
    Question = "rbxassetid://3926307975",
    Star = "rbxassetid://3926307975",
    Heart = "rbxassetid://3926307975",
    ThumbsUp = "rbxassetid://3926307975",
    ThumbsDown = "rbxassetid://3926307975",
    
    -- Media
    Play = "rbxassetid://3926307975",
    Pause = "rbxassetid://3926307975",
    Stop = "rbxassetid://3926307975",
    SkipForward = "rbxassetid://3926307975",
    SkipBack = "rbxassetid://3926307975",
    Volume = "rbxassetid://3926307975",
    VolumeMute = "rbxassetid://3926307975",
    VolumeLow = "rbxassetid://3926307975",
    VolumeHigh = "rbxassetid://3926307975",
    Mic = "rbxassetid://3926307975",
    Camera = "rbxassetid://3926307975",
    
    -- Objects
    User = "rbxassetid://3926307975",
    Users = "rbxassetid://3926307975",
    UserGroup = "rbxassetid://3926307975",
    Crown = "rbxassetid://3926307975",
    Shield = "rbxassetid://3926307975",
    Lock = "rbxassetid://3926307975",
    Unlock = "rbxassetid://3926307975",
    Key = "rbxassetid://3926307975",
    Eye = "rbxassetid://3926307975",
    EyeOff = "rbxassetid://3926307975",
    Bookmark = "rbxassetid://3926307975",
    Flag = "rbxassetid://3926307975",
    Map = "rbxassetid://3926307975",
    Globe = "rbxassetid://3926307975",
    Clock = "rbxassetid://3926307975",
    Calendar = "rbxassetid://3926307975",
    Timer = "rbxassetid://3926307975",
    Zap = "rbxassetid://3926307975",
    Bolt = "rbxassetid://3926307975",
    Flame = "rbxassetid://3926307975",
    Sun = "rbxassetid://3926307975",
    Moon = "rbxassetid://3926307975",
    Cloud = "rbxassetid://3926307975",
    Wifi = "rbxassetid://3926307975",
    Bluetooth = "rbxassetid://3926307975",
    Battery = "rbxassetid://3926307975",
    BatteryCharging = "rbxassetid://3926307975",
    Cpu = "rbxassetid://3926307975",
    Monitor = "rbxassetid://3926307975",
    Smartphone = "rbxassetid://3926307975",
    Gamepad = "rbxassetid://3926307975",
    Target = "rbxassetid://3926307975",
    Crosshair = "rbxassetid://3926307975",
    
    -- UI Elements
    Grid = "rbxassetid://3926307975",
    List = "rbxassetid://3926307975",
    Layout = "rbxassetid://3926307975",
    Maximize = "rbxassetid://3926307975",
    Minimize = "rbxassetid://3926307975",
    Expand = "rbxassetid://3926307975",
    Collapse = "rbxassetid://3926307975",
    Move = "rbxassetid://3926307975",
    Drag = "rbxassetid://3926307975",
    Grip = "rbxassetid://3926307975",
    
    -- Custom AetherUI icons (using Lucide-style from Roblox)
    Sparkles = "rbxassetid://3926305904",
    Wand = "rbxassetid://3926305904",
    Magic = "rbxassetid://3926305904",
    Gem = "rbxassetid://3926305904",
    Diamond = "rbxassetid://3926305904",
    Award = "rbxassetid://3926305904",
    Trophy = "rbxassetid://3926305904",
    Medal = "rbxassetid://3926305904",
    Crown2 = "rbxassetid://3926305904",
}

-- Category mappings
Icons.Categories = {
    Navigation = {"Home", "Dashboard", "Settings", "Menu", "More", "ChevronLeft", "ChevronRight", "ChevronUp", "ChevronDown"},
    Actions = {"Add", "Remove", "Edit", "Delete", "Copy", "Refresh", "Search", "Filter", "Download", "Upload"},
    Status = {"Check", "X", "Alert", "Info", "Help", "Star", "Heart"},
    Media = {"Play", "Pause", "Volume", "Mic", "Camera"},
    Objects = {"User", "Lock", "Eye", "Clock", "Globe", "Map"},
}

-- ═══════════════════════════════════════════════════════════════
-- ICON METHODS
-- ═══════════════════════════════════════════════════════════════

--- Get an icon by name
function Icons.Get(name)
    return Icons.Registry[name] or Icons.Registry.Help
end

--- Register a custom icon
function Icons.Register(name, assetId)
    Icons.Registry[name] = assetId
end

--- Check if an icon exists
function Icons.Exists(name)
    return Icons.Registry[name] ~= nil
end

--- Get all icon names
function Icons.GetAllNames()
    local names = {}
    for name, _ in pairs(Icons.Registry) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

--- Get icons by category
function Icons.GetByCategory(category)
    return Icons.Categories[category] or {}
end

--- Get all categories
function Icons.GetCategories()
    local cats = {}
    for cat, _ in pairs(Icons.Categories) do
        table.insert(cats, cat)
    end
    return cats
end

--- Create an ImageLabel with an icon
function Icons.CreateImageLabel(parent, iconName, size, color)
    size = size or 16
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "Icon_" .. iconName
    imageLabel.Size = UDim2.new(0, size, 0, size)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = Icons.Get(iconName)
    imageLabel.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    if parent then
        imageLabel.Parent = parent
    end
    return imageLabel
end

return Icons