--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║              A E T H E R   U I  —  U T I L S                 ║
    ║                                                              ║
    ║  Utility functions for:                                      ║
    ║  - Table manipulation                                        ║
    ║  - String formatting                                         ║
    ║  - Math helpers                                              ║
    ║  - UI helpers                                                ║
    ║  - Validation                                                ║
    ║  - File operations                                           ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Utils = {}

-- Services
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════════════════════
-- TABLE UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Deep copy a table
function Utils.DeepCopy(orig)
    local copy
    if typeof(orig) == "table" then
        copy = {}
        for k, v in next, orig, nil do
            copy[Utils.DeepCopy(k)] = Utils.DeepCopy(v)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

--- Deep merge two tables (override takes priority)
function Utils.DeepMerge(base, override)
    local result = Utils.DeepCopy(base)
    
    for k, v in pairs(override or {}) do
        if typeof(v) == "table" and typeof(result[k]) == "table" then
            result[k] = Utils.DeepMerge(result[k], v)
        else
            result[k] = v
        end
    end
    
    return result
end

--- Shallow copy a table
function Utils.ShallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--- Check if table contains a value
function Utils.TableContains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end
    return false
end

--- Find index of a value in a table
function Utils.TableIndexOf(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

--- Filter a table using a predicate function
function Utils.TableFilter(t, predicate)
    local result = {}
    for _, v in pairs(t) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

--- Map a function over a table
function Utils.TableMap(t, fn)
    local result = {}
    for k, v in pairs(t) do
        result[k] = fn(v, k)
    end
    return result
end

--- Flatten a nested table (one level)
function Utils.TableFlatten(t)
    local result = {}
    for _, v in ipairs(t) do
        if typeof(v) == "table" then
            for _, inner in ipairs(v) do
                table.insert(result, inner)
            end
        else
            table.insert(result, v)
        end
    end
    return result
end

--- Get table keys as array
function Utils.TableKeys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

--- Get table values as array
function Utils.TableValues(t)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

--- Count table entries
function Utils.TableCount(t)
    local count = 0
    for _ in pairs(t) do count += 1 end
    return count
end

--- Check if table is empty
function Utils.TableIsEmpty(t)
    return next(t) == nil
end

--- Sort table by key (returns new sorted table)
function Utils.TableSortByKey(t, comparator)
    comparator = comparator or function(a, b) return tostring(a) < tostring(b) end
    local sorted = {}
    for k, v in pairs(t) do
        table.insert(sorted, {Key = k, Value = v})
    end
    table.sort(sorted, function(a, b) return comparator(a.Key, b.Key) end)
    return sorted
end

--- Create a read-only proxy table
function Utils.ReadOnly(t)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = function(_, key, _)
            error("Attempt to modify read-only table: " .. tostring(key), 2)
        end,
        __metatable = false,
    }
    setmetatable(proxy, mt)
    return proxy
end

-- ═══════════════════════════════════════════════════════════════
-- STRING UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Format a number with commas
function Utils.FormatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

--- Format time (seconds) to readable string
function Utils.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%ds", math.floor(seconds))
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), math.floor(seconds % 60))
    else
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    end
end

--- Truncate string with ellipsis
function Utils.Truncate(str, maxLength, ellipsis)
    ellipsis = ellipsis or "..."
    if #str <= maxLength then return str end
    return str:sub(1, maxLength - #ellipsis) .. ellipsis
end

--- Pad string to specified length
function Utils.PadString(str, length, padChar, padLeft)
    padChar = padChar or " "
    local padLength = length - #str
    if padLength <= 0 then return str end
    local padding = string.rep(padChar, padLength)
    return padLeft and (padding .. str) or (str .. padding)
end

--- Convert string to Title Case
function Utils.TitleCase(str)
    return str:gsub("(%a)([%w_]*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

--- Split string by delimiter
function Utils.Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

--- Trim whitespace from string
function Utils.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

--- Check if string starts with prefix
function Utils.StartsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

--- Check if string ends with suffix
function Utils.EndsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

--- Generate a random string
function Utils.RandomString(length)
    length = length or 8
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

--- Generate a UUID v4 style string
function Utils.GenerateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return template:gsub("[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MATH UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Linear interpolation
function Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

--- Clamp value between min and max
function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Map a value from one range to another
function Utils.Map(value, fromMin, fromMax, toMin, toMax)
    return toMin + (value - fromMin) * ((toMax - toMin) / (fromMax - fromMin))
end

--- Round to nearest integer (or decimal places)
function Utils.Round(value, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(value * mult + 0.5) / mult
end

--- Check if value is approximately equal to target
function Utils.Approximately(a, b, epsilon)
    epsilon = epsilon or 0.0001
    return math.abs(a - b) < epsilon
end

--- Get sign of a number
function Utils.Sign(value)
    if value > 0 then return 1
    elseif value < 0 then return -1
    else return 0 end
end

--- Ping-pong value between 0 and 1
function Utils.PingPong(t)
    t = t % 2
    return 1 - math.abs(1 - t)
end

--- Smooth step interpolation (smoother than lerp)
function Utils.SmoothStep(t)
    t = Utils.Clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

--- Smoother step interpolation (even smoother)
function Utils.SmootherStep(t)
    t = Utils.Clamp(t, 0, 1)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

--- Generate a random number in range
function Utils.RandomRange(min, max)
    return min + math.random() * (max - min)
end

--- Generate a random integer in range
function Utils.RandomInt(min, max)
    return math.random(min, max)
end

--- Remap a 0-1 value with easing
--- FIXED: Replaced "Expo" with "Exponential" and "Circ" with "Circular" for Roblox compatibility
function Utils.Ease(t, easing)
    easing = easing or "Quart"
    
    if easing == "Linear" then
        return t
    elseif easing == "Quad" then
        return t * t
    elseif easing == "Cubic" then
        return t * t * t
    elseif easing == "Quart" then
        return t * t * t * t
    elseif easing == "Quint" then
        return t * t * t * t * t
    elseif easing == "Sine" then
        return 1 - math.cos(t * math.pi / 2)
    elseif easing == "Exponential" then
        return 2 ^ (10 * (t - 1))
    elseif easing == "Circular" then
        return 1 - math.sqrt(1 - t * t)
    elseif easing == "Back" then
        local c1 = 1.70158
        local c3 = c1 + 1
        return c3 * t * t * t - c1 * t * t
    elseif easing == "Bounce" then
        local function bounce(t)
            if t < 1 / 2.75 then
                return 7.5625 * t * t
            elseif t < 2 / 2.75 then
                t = t - 1.5 / 2.75
                return 7.5625 * t * t + 0.75
            elseif t < 2.5 / 2.75 then
                t = t - 2.25 / 2.75
                return 7.5625 * t * t + 0.9375
            else
                t = t - 2.625 / 2.75
                return 7.5625 * t * t + 0.984375
            end
        end
        return bounce(t)
    elseif easing == "Elastic" then
        local c4 = (2 * math.pi) / 3
        if t == 0 then return 0
        elseif t == 1 then return 1
        else return -2 ^ (10 * t - 10) * math.sin((t * 10 - 10.75) * c4) end
    else
        return t
    end
end

-- ═══════════════════════════════════════════════════════════════
-- UI UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Get text size with given font and size
function Utils.GetTextSize(text, fontSize, font, maxWidth)
    font = font or Enum.Font.Gotham
    maxWidth = maxWidth or math.huge
    
    local textSize = TextService:GetTextSize(
        text,
        fontSize,
        font,
        Vector2.new(maxWidth, math.huge)
    )
    
    return textSize
end

--- Create a rounded corner UICorner
function Utils.CreateCorner(radius, parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = typeof(radius) == "number" and UDim.new(0, radius) or radius
    if parent then corner.Parent = parent end
    return corner
end

--- Create a UIStroke with properties
function Utils.CreateStroke(props, parent)
    props = props or {}
    local stroke = Instance.new("UIStroke")
    stroke.Color = props.Color or Color3.fromRGB(80, 80, 90)
    stroke.Thickness = props.Thickness or 1
    stroke.Transparency = props.Transparency or 0.5
    stroke.ApplyStrokeMode = props.ApplyStrokeMode or Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = props.LineJoinMode or Enum.LineJoinMode.Round
    if parent then stroke.Parent = parent end
    return stroke
end

--- Create padding
function Utils.CreatePadding(parent, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    if parent then padding.Parent = parent end
    return padding
end

--- Create a list layout
function Utils.CreateListLayout(parent, props)
    props = props or {}
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = props.FillDirection or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top
    layout.SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder
    layout.Padding = props.Padding or UDim.new(0, 0)
    if parent then layout.Parent = parent end
    return layout
end

--- Create a grid layout
function Utils.CreateGridLayout(parent, props)
    props = props or {}
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = props.CellSize or UDim2.new(0, 100, 0, 100)
    layout.CellPadding = props.CellPadding or UDim2.new(0, 8, 0, 8)
    layout.FillDirection = props.FillDirection or Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = props.HorizontalAlignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Top
    layout.SortOrder = props.SortOrder or Enum.SortOrder.LayoutOrder
    if parent then layout.Parent = parent end
    return layout
end

--- Make a frame draggable
function Utils.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
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
            TweenService:Create(frame, TweenInfo.new(0.1), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
    
    return frame
end

--- Create a glass morphism effect on a frame
function Utils.ApplyGlassEffect(frame, transparency, blur)
    transparency = transparency or 0.15
    blur = blur or 12
    
    frame.BackgroundTransparency = 1 - transparency
    
    -- Add gradient overlay for glass effect
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 245, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.5, 0.88),
        NumberSequenceKeypoint.new(1, 0.92)
    })
    gradient.Rotation = 135
    gradient.Parent = frame
    
    return frame
end

--- Create a ripple effect (material design style)
function Utils.CreateRipple(button, clickPosition)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X - button.AbsolutePosition.X, 0, clickPosition.Y - button.AbsolutePosition.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = button
    
    local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

--- Tween multiple properties on an object
function Utils.Tween(obj, properties, duration, easingStyle, easingDirection, delay)
    duration = duration or 0.35
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    delay = delay or 0
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection, 0, false, delay)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

--- Chain multiple tweens together
function Utils.TweenChain(tweens)
    for i, tweenData in ipairs(tweens) do
        if i == 1 then
            Utils.Tween(tweenData.Object, tweenData.Properties, tweenData.Duration, 
                tweenData.EasingStyle, tweenData.EasingDirection)
        else
            task.delay(tweens[i-1].Duration or 0.35, function()
                Utils.Tween(tweenData.Object, tweenData.Properties, tweenData.Duration,
                    tweenData.EasingStyle, tweenData.EasingDirection)
            end)
        end
    end
end

--- Fade in an object
function Utils.FadeIn(obj, duration)
    duration = duration or 0.35
    obj.BackgroundTransparency = 1
    
    local targetTransparency = obj:GetAttribute("TargetTransparency") or 0
    Utils.Tween(obj, {BackgroundTransparency = targetTransparency}, duration)
    
    -- Fade in text if present
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            child.TextTransparency = 1
            Utils.Tween(child, {TextTransparency = 0}, duration)
        end
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            child.ImageTransparency = 1
            Utils.Tween(child, {ImageTransparency = 0}, duration)
        end
    end
end

--- Fade out an object
function Utils.FadeOut(obj, duration, destroyAfter)
    duration = duration or 0.3
    
    Utils.Tween(obj, {BackgroundTransparency = 1}, duration)
    
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            Utils.Tween(child, {TextTransparency = 1}, duration)
        end
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            Utils.Tween(child, {ImageTransparency = 1}, duration)
        end
    end
    
    if destroyAfter then
        task.delay(duration + 0.05, function()
            obj:Destroy()
        end)
    end
end

--- Scale an object in (pop animation)
function Utils.ScaleIn(obj, duration)
    duration = duration or 0.35
    obj.Size = UDim2.new(0, 0, 0, 0)
    Utils.Tween(obj, {Size = obj:GetAttribute("TargetSize") or UDim2.new(1, 0, 1, 0)}, 
        duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ═══════════════════════════════════════════════════════════════
-- VALIDATION UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Validate that value is a number within range
function Utils.ValidateNumber(value, min, max, default)
    local num = tonumber(value)
    if not num then return default end
    return Utils.Clamp(num, min or -math.huge, max or math.huge)
end

--- Validate that value is a string with minimum length
function Utils.ValidateString(value, minLength, maxLength, default)
    local str = tostring(value or default or "")
    if minLength and #str < minLength then return default or "" end
    if maxLength and #str > maxLength then return str:sub(1, maxLength) end
    return str
end

--- Validate that value is in an enum list
function Utils.ValidateEnum(value, validValues, default)
    for _, v in ipairs(validValues) do
        if v == value then return value end
    end
    return default
end

--- Validate a color value
function Utils.ValidateColor(value, default)
    if typeof(value) == "Color3" then
        return value
    elseif typeof(value) == "table" and value.R and value.G and value.B then
        return Color3.new(value.R, value.G, value.B)
    elseif typeof(value) == "string" and value:match("^#%x%x%x%x%x%x$") then
        local r = tonumber(value:sub(2, 3), 16) / 255
        local g = tonumber(value:sub(4, 5), 16) / 255
        local b = tonumber(value:sub(6, 7), 16) / 255
        return Color3.new(r, g, b)
    end
    return default or Color3.fromRGB(128, 128, 128)
end

--- Validate a KeyCode
function Utils.ValidateKeyCode(value, default)
    if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
        return value
    end
    return default or Enum.KeyCode.Unknown
end

-- ═══════════════════════════════════════════════════════════════
-- FILE OPERATIONS
-- ═══════════════════════════════════════════════════════════════

--- Save data to JSON file
function Utils.SaveJSON(filename, data)
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(data)
        if writefile then
            writefile(filename, json)
            return true
        end
        return false
    end)
    return success and result
end

--- Load data from JSON file
function Utils.LoadJSON(filename)
    local success, result = pcall(function()
        if readfile and isfile and isfile(filename) then
            local json = readfile(filename)
            return HttpService:JSONDecode(json)
        end
        return nil
    end)
    if success then return result end
    return nil
end

--- Check if file exists
function Utils.FileExists(filename)
    local exists = false
    pcall(function()
        if isfile then
            exists = isfile(filename)
        end
    end)
    return exists
end

--- Create folder if it doesn't exist
function Utils.CreateFolder(folderPath)
    pcall(function()
        if makefolder and not isfolder(folderPath) then
            makefolder(folderPath)
        end
    end)
end

--- List files in a folder
function Utils.ListFiles(folderPath)
    local files = {}
    pcall(function()
        if listfiles then
            for _, file in ipairs(listfiles(folderPath)) do
                table.insert(files, file)
            end
        end
    end)
    return files
end

-- ═══════════════════════════════════════════════════════════════
-- PERFORMANCE UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Debounce a function (prevent rapid successive calls)
function Utils.Debounce(fn, delay)
    delay = delay or 0.1
    local running = false
    
    return function(...)
        if running then return end
        running = true
        task.delay(delay, function()
            running = false
        end)
        fn(...)
    end
end

--- Throttle a function (limit execution rate)
function Utils.Throttle(fn, interval)
    interval = interval or 0.1
    local lastCall = 0
    
    return function(...)
        local now = tick()
        if now - lastCall >= interval then
            lastCall = now
            fn(...)
        end
    end
end

--- Run function on next heartbeat
function Utils.NextFrame(fn)
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        connection:Disconnect()
        fn()
    end)
end

--- Run function after delay
function Utils.Delay(seconds, fn)
    task.delay(seconds, fn)
end

--- Create a simple timer
function Utils.Timer()
    local timer = {
        StartTime = tick(),
        Elapsed = function(self)
            return tick() - self.StartTime
        end,
        Reset = function(self)
            self.StartTime = tick()
        end,
    }
    return timer
end

-- ═══════════════════════════════════════════════════════════════
-- DEVICE / PLATFORM UTILITIES
-- ═══════════════════════════════════════════════════════════════

--- Detect if running on mobile
function Utils.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

--- Detect if running on console
function Utils.IsConsole()
    return UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
end

--- Get screen resolution
function Utils.GetScreenResolution()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1920, 1080)
end

--- Calculate DPI scale factor
function Utils.GetDPIScale()
    local resolution = Utils.GetScreenResolution()
    local baseWidth = 1920
    return math.max(0.75, math.min(1.5, resolution.X / baseWidth))
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN MODULE
-- ═══════════════════════════════════════════════════════════════

return Utils
