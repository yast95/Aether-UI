--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           A E T H E R   U I  —  A N I M A T I O N S          ║
    ║                                                              ║
    ║  GPU-friendly animation system featuring:                    ║
    ║  - Tween-based animations (hardware accelerated)             ║
    ║  - Custom easing functions                                   ║
    ║  - Animation sequencing & chaining                           ║
    ║  - Spring physics simulations                                ║
    ║  - Parallax effects                                          ║
    ║  - Scroll-triggered animations                               ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Animations = {}
Animations.__index = Animations

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════
-- EASING FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

Animations.Easings = {}

--- Linear (no easing)
Animations.Easings.Linear = function(t)
    return t
end

--- Quadratic ease-in
Animations.Easings.QuadIn = function(t)
    return t * t
end

--- Quadratic ease-out
Animations.Easings.QuadOut = function(t)
    return 1 - (1 - t) * (1 - t)
end

--- Quadratic ease-in-out
Animations.Easings.QuadInOut = function(t)
    return t < 0.5 and 2 * t * t or 1 - math.pow(-2 * t + 2, 2) / 2
end

--- Cubic ease-in
Animations.Easings.CubicIn = function(t)
    return t * t * t
end

--- Cubic ease-out
Animations.Easings.CubicOut = function(t)
    return 1 - math.pow(1 - t, 3)
end

--- Cubic ease-in-out
Animations.Easings.CubicInOut = function(t)
    return t < 0.5 and 4 * t * t * t or 1 - math.pow(-2 * t + 2, 3) / 2
end

--- Quartic ease-in
Animations.Easings.QuartIn = function(t)
    return t * t * t * t
end

--- Quartic ease-out
Animations.Easings.QuartOut = function(t)
    return 1 - math.pow(1 - t, 4)
end

--- Quartic ease-in-out
Animations.Easings.QuartInOut = function(t)
    return t < 0.5 and 8 * t * t * t * t or 1 - math.pow(-2 * t + 2, 4) / 2
end

--- Quintic ease-in
Animations.Easings.QuintIn = function(t)
    return t * t * t * t * t
end

--- Quintic ease-out
Animations.Easings.QuintOut = function(t)
    return 1 - math.pow(1 - t, 5)
end

--- Sine ease-in
Animations.Easings.SineIn = function(t)
    return 1 - math.cos(t * math.pi / 2)
end

--- Sine ease-out
Animations.Easings.SineOut = function(t)
    return math.sin(t * math.pi / 2)
end

--- Sine ease-in-out
Animations.Easings.SineInOut = function(t)
    return -(math.cos(math.pi * t) - 1) / 2
end

--- Exponential ease-in
Animations.Easings.ExpoIn = function(t)
    return t == 0 and 0 or math.pow(2, 10 * (t - 1))
end

--- Exponential ease-out
Animations.Easings.ExpoOut = function(t)
    return t == 1 and 1 or 1 - math.pow(2, -10 * t)
end

--- Circular ease-in
Animations.Easings.CircIn = function(t)
    return 1 - math.sqrt(1 - math.pow(t, 2))
end

--- Circular ease-out
Animations.Easings.CircOut = function(t)
    return math.sqrt(1 - math.pow(t - 1, 2))
end

--- Back ease-out (overshoot)
Animations.Easings.BackOut = function(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

--- Back ease-in-out
Animations.Easings.BackInOut = function(t)
    local c1 = 1.70158
    local c2 = c1 * 1.525
    return t < 0.5 
        and (math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
        or (math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2
end

--- Elastic ease-out
Animations.Easings.ElasticOut = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    local c4 = (2 * math.pi) / 3
    return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1
end

--- Bounce ease-out
Animations.Easings.BounceOut = function(t)
    local n1, d1 = 7.5625, 2.75
    if t < 1 / d1 then
        return n1 * t * t
    elseif t < 2 / d1 then
        t = t - 1.5 / d1
        return n1 * t * t + 0.75
    elseif t < 2.5 / d1 then
        t = t - 2.25 / d1
        return n1 * t * t + 0.9375
    else
        t = t - 2.625 / d1
        return n1 * t * t + 0.984375
    end
end

--- Smooth step (cubic hermite)
Animations.Easings.SmoothStep = function(t)
    return t * t * (3 - 2 * t)
end

--- Smoother step (quintic hermite)
Animations.Easings.SmootherStep = function(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Map easing names to Enum.EasingStyle
Animations.EasingMap = {
    Linear = Enum.EasingStyle.Linear,
    Quad = Enum.EasingStyle.Quad,
    Cubic = Enum.EasingStyle.Cubic,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Sine = Enum.EasingStyle.Sine,
    Expo = Enum.EasingStyle.Expo,
    Circ = Enum.EasingStyle.Circ,
    Back = Enum.EasingStyle.Back,
    Bounce = Enum.EasingStyle.Bounce,
    Elastic = Enum.EasingStyle.Elastic,
}

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

function Animations.new(config)
    local self = setmetatable({}, Animations)
    
    self.Config = config or {}
    self.Enabled = self.Config.AnimationsEnabled ~= false
    self.DefaultDuration = self.Config.AnimationSpeed or 0.35
    self.DefaultEasing = self.Config.TransitionEasing or Enum.EasingStyle.Quart
    self.DefaultDirection = Enum.EasingDirection.Out
    
    -- Active animations tracking
    self.ActiveTweens = {}
    self.RunningLoops = {}
    self.SpringConnections = {}
    
    return self
end

-- ═══════════════════════════════════════════════════════════════
-- CORE TWEEN METHODS
-- ═══════════════════════════════════════════════════════════════

--- Create and play a tween with the animation system
function Animations:Tween(object, properties, duration, easingStyle, easingDirection, delay)
    if not self.Enabled then
        -- Apply properties instantly if animations disabled
        for prop, value in pairs(properties) do
            object[prop] = value
        end
        return nil
    end
    
    duration = duration or self.DefaultDuration
    easingStyle = easingStyle or self.DefaultEasing
    easingDirection = easingDirection or self.DefaultDirection
    delay = delay or 0
    
    -- Cancel any existing tween on this object for these properties
    self:CancelTweenForObject(object)
    
    local tweenInfo = TweenInfo.new(
        duration,
        easingStyle,
        easingDirection,
        0,           -- Repeat count
        false,       -- Reverses
        delay
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    
    -- Track the tween
    local tweenId = HttpService:GenerateGUID(false)
    self.ActiveTweens[tweenId] = tween
    
    tween.Completed:Connect(function()
        self.ActiveTweens[tweenId] = nil
    end)
    
    tween:Play()
    return tween
end

--- Cancel all tweens for an object
function Animations:CancelTweenForObject(object)
    for id, tween in pairs(self.ActiveTweens) do
        if tween.Instance == object then
            tween:Cancel()
            self.ActiveTweens[id] = nil
        end
    end
end

--- Cancel all active tweens
function Animations:CancelAllTweens()
    for id, tween in pairs(self.ActiveTweens) do
        tween:Cancel()
        self.ActiveTweens[id] = nil
    end
end

--- Tween with promise-like completion callback
function Animations:TweenAsync(object, properties, duration, easingStyle, easingDirection, delay)
    local completed = false
    local tween = self:Tween(object, properties, duration, easingStyle, easingDirection, delay)
    
    if not tween then return end
    
    tween.Completed:Connect(function()
        completed = true
    end)
    
    return function()
        while not completed do
            task.wait()
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- PRESET ANIMATIONS
-- ═══════════════════════════════════════════════════════════════

--- Fade in animation
function Animations:FadeIn(object, duration, delay)
    local targetTransparency = object:GetAttribute("TargetTransparency") or 0
    
    -- Handle different object types
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        return self:Tween(object, {TextTransparency = 0}, duration, nil, nil, delay)
    elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
        return self:Tween(object, {ImageTransparency = targetTransparency}, duration, nil, nil, delay)
    else
        return self:Tween(object, {BackgroundTransparency = targetTransparency}, duration, nil, nil, delay)
    end
end

--- Fade out animation
function Animations:FadeOut(object, duration, delay, destroyAfter)
    duration = duration or 0.3
    
    local tween = self:Tween(object, {BackgroundTransparency = 1}, duration, nil, nil, delay)
    
    -- Fade out text
    for _, child in ipairs(object:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            self:Tween(child, {TextTransparency = 1}, duration, nil, nil, delay)
        end
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            self:Tween(child, {ImageTransparency = 1}, duration, nil, nil, delay)
        end
    end
    
    if destroyAfter and tween then
        tween.Completed:Connect(function()
            object:Destroy()
        end)
    end
    
    return tween
end

--- Scale in (pop) animation
function Animations:ScaleIn(object, duration, delay)
    duration = duration or 0.4
    
    object.Size = UDim2.new(0, 0, 0, 0)
    
    return self:Tween(object, {
        Size = object:GetAttribute("TargetSize") or UDim2.new(1, 0, 1, 0)
    }, duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out, delay)
end

--- Scale out animation
function Animations:ScaleOut(object, duration, delay, destroyAfter)
    duration = duration or 0.3
    
    local tween = self:Tween(object, {
        Size = UDim2.new(0, 0, 0, 0)
    }, duration, Enum.EasingStyle.Quart, Enum.EasingDirection.In, delay)
    
    if destroyAfter and tween then
        tween.Completed:Connect(function()
            object:Destroy()
        end)
    end
    
    return tween
end

--- Slide in from direction
function Animations:SlideIn(object, direction, distance, duration, delay)
    direction = direction or "Left"
    duration = duration or 0.4
    distance = distance or 50
    
    local targetPosition = object.Position
    local startPosition
    
    if direction == "Left" then
        startPosition = targetPosition + UDim2.new(0, -distance, 0, 0)
    elseif direction == "Right" then
        startPosition = targetPosition + UDim2.new(0, distance, 0, 0)
    elseif direction == "Up" then
        startPosition = targetPosition + UDim2.new(0, 0, 0, -distance)
    elseif direction == "Down" then
        startPosition = targetPosition + UDim2.new(0, 0, 0, distance)
    end
    
    object.Position = startPosition
    return self:Tween(object, {Position = targetPosition}, duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, delay)
end

--- Slide out in direction
function Animations:SlideOut(object, direction, distance, duration, delay, destroyAfter)
    direction = direction or "Left"
    duration = duration or 0.3
    distance = distance or 50
    
    local targetPosition
    
    if direction == "Left" then
        targetPosition = object.Position + UDim2.new(0, -distance, 0, 0)
    elseif direction == "Right" then
        targetPosition = object.Position + UDim2.new(0, distance, 0, 0)
    elseif direction == "Up" then
        targetPosition = object.Position + UDim2.new(0, 0, 0, -distance)
    elseif direction == "Down" then
        targetPosition = object.Position + UDim2.new(0, 0, 0, distance)
    end
    
    local tween = self:Tween(object, {Position = targetPosition}, duration, Enum.EasingStyle.Quart, Enum.EasingDirection.In, delay)
    
    if destroyAfter and tween then
        tween.Completed:Connect(function()
            object:Destroy()
        end)
    end
    
    return tween
end

--- Bounce in animation
function Animations:BounceIn(object, duration, delay)
    duration = duration or 0.6
    
    object.Size = UDim2.new(0, 0, 0, 0)
    
    return self:Tween(object, {
        Size = object:GetAttribute("TargetSize") or UDim2.new(1, 0, 1, 0)
    }, duration, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, delay)
end

--- Elastic snap animation
function Animations:ElasticIn(object, duration, delay)
    duration = duration or 0.8
    
    object.Size = UDim2.new(0, 0, 0, 0)
    
    return self:Tween(object, {
        Size = object:GetAttribute("TargetSize") or UDim2.new(1, 0, 1, 0)
    }, duration, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, delay)
end

--- Pulse animation (scale up and down)
function Animations:Pulse(object, scale, duration)
    scale = scale or 1.05
    duration = duration or 0.4
    
    local originalSize = object.Size
    local targetSize = UDim2.new(
        originalSize.X.Scale * scale,
        originalSize.X.Offset,
        originalSize.Y.Scale * scale,
        originalSize.Y.Offset
    )
    
    local tween1 = self:Tween(object, {Size = targetSize}, duration / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    if tween1 then
        tween1.Completed:Connect(function()
            self:Tween(object, {Size = originalSize}, duration / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        end)
    end
    
    return tween1
end

--- Shake animation
function Animations:Shake(object, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.4
    
    local originalPosition = object.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            object.Position = originalPosition
            connection:Disconnect()
            return
        end
        
        local progress = elapsed / duration
        local decay = 1 - progress
        local offsetX = (math.random() - 0.5) * 2 * intensity * decay
        local offsetY = (math.random() - 0.5) * 2 * intensity * decay
        
        object.Position = originalPosition + UDim2.new(0, offsetX, 0, offsetY)
    end)
    
    return connection
end

--- Glow pulse (for accent elements)
function Animations:GlowPulse(object, propertyName, minValue, maxValue, duration)
    propertyName = propertyName or "BackgroundColor3"
    minValue = minValue or 0.5
    maxValue = maxValue or 1
    duration = duration or 1.5
    
    local startTime = tick()
    local originalValue = object[propertyName]
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        local t = (math.sin((tick() - startTime) / duration * math.pi * 2) + 1) / 2
        
        if typeof(originalValue) == "Color3" then
            -- For colors, blend between dim and bright
            local h, s, v = Color3.toHSV(originalValue)
            v = minValue + (maxValue - minValue) * t
            object[propertyName] = Color3.fromHSV(h, s, v)
        else
            object[propertyName] = minValue + (maxValue - minValue) * t
        end
    end)
    
    table.insert(self.RunningLoops, connection)
    return connection
end

-- ═══════════════════════════════════════════════════════════════
-- SPRING PHYSICS
-- ═══════════════════════════════════════════════════════════════

--- Create a spring animation
function Animations:Spring(object, targetProperties, springConfig)
    springConfig = springConfig or {}
    local tension = springConfig.Tension or 300
    local friction = springConfig.Friction or 30
    local mass = springConfig.Mass or 1
    
    -- Current values
    local current = {}
    local velocity = {}
    
    for prop, target in pairs(targetProperties) do
        current[prop] = object[prop]
        velocity[prop] = 0
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        local allSettled = true
        
        for prop, target in pairs(targetProperties) do
            local displacement = target - current[prop]
            local springForce = -tension * displacement
            local dampingForce = -friction * velocity[prop]
            local acceleration = (springForce + dampingForce) / mass
            
            velocity[prop] = velocity[prop] + acceleration * dt
            current[prop] = current[prop] + velocity[prop] * dt
            
            -- Check if settled
            if math.abs(displacement) > 0.001 or math.abs(velocity[prop]) > 0.001 then
                allSettled = false
            end
            
            object[prop] = current[prop]
        end
        
        if allSettled then
            connection:Disconnect()
            -- Snap to final values
            for prop, target in pairs(targetProperties) do
                object[prop] = target
            end
        end
    end)
    
    table.insert(self.SpringConnections, connection)
    return connection
end

--- Create an overshoot spring (bouncy)
function Animations:BouncySpring(object, targetProperties, bounciness)
    bounciness = bounciness or 0.6
    return self:Spring(object, targetProperties, {
        Tension = 400,
        Friction = 20 * (1 - bounciness),
        Mass = 1
    })
end

-- ═══════════════════════════════════════════════════════════════
-- ANIMATION SEQUENCES
-- ═══════════════════════════════════════════════════════════════

--- Create an animation sequence (chain animations)
function Animations:Sequence(sequence)
    local totalDelay = 0
    
    for _, step in ipairs(sequence) do
        local delay = totalDelay + (step.Delay or 0)
        
        task.delay(delay, function()
            if step.Action then
                step.Action()
            elseif step.Tween then
                self:Tween(
                    step.Tween.Object,
                    step.Tween.Properties,
                    step.Tween.Duration,
                    step.Tween.EasingStyle,
                    step.Tween.EasingDirection
                )
            end
        end)
        
        totalDelay = totalDelay + (step.Duration or 0.35) + (step.Delay or 0)
    end
    
    return totalDelay
end

--- Run animations in parallel
function Animations:Parallel(animations)
    local tweens = {}
    
    for _, anim in ipairs(animations) do
        if anim.Tween then
            table.insert(tweens, self:Tween(
                anim.Tween.Object,
                anim.Tween.Properties,
                anim.Tween.Duration,
                anim.Tween.EasingStyle,
                anim.Tween.EasingDirection,
                anim.Tween.Delay
            ))
        elseif anim.Action then
            task.spawn(anim.Action)
        end
    end
    
    return tweens
end

--- Stagger animation (apply same animation with incremental delay)
function Animations:Stagger(objects, tweenConfig, staggerDelay)
    staggerDelay = staggerDelay or 0.05
    
    local tweens = {}
    for i, obj in ipairs(objects) do
        local delay = (i - 1) * staggerDelay
        table.insert(tweens, self:Tween(
            obj,
            tweenConfig.Properties,
            tweenConfig.Duration,
            tweenConfig.EasingStyle,
            tweenConfig.EasingDirection,
            delay
        ))
    end
    
    return tweens
end

-- ═══════════════════════════════════════════════════════════════
-- CONTINUOUS ANIMATIONS
-- ═══════════════════════════════════════════════════════════════

--- Create a looping animation
function Animations:Loop(object, fromProperties, toProperties, duration, easingStyle)
    duration = duration or 2
    easingStyle = easingStyle or Enum.EasingStyle.Sine
    
    -- Set initial state
    for prop, value in pairs(fromProperties) do
        object[prop] = value
    end
    
    local function playLoop()
        if not object or not object.Parent then return end
        
        local tween = self:Tween(object, toProperties, duration, easingStyle, Enum.EasingDirection.Out)
        if tween then
            tween.Completed:Connect(function()
                if not object or not object.Parent then return end
                
                local reverseTween = self:Tween(object, fromProperties, duration, easingStyle, Enum.EasingDirection.In)
                if reverseTween then
                    reverseTween.Completed:Connect(function()
                        task.spawn(playLoop)
                    end)
                end
            end)
        end
    end
    
    playLoop()
end

--- Create a rotating animation
function Animations:Rotate(object, speed, clockwise)
    speed = speed or 360 -- degrees per second
    clockwise = clockwise ~= false
    
    local direction = clockwise and 1 or -1
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        object.Rotation = (object.Rotation + speed * dt * direction) % 360
    end)
    
    table.insert(self.RunningLoops, connection)
    return connection
end

--- Create a floating/bobbing animation
function Animations:Float(object, amplitude, speed)
    amplitude = amplitude or 5
    speed = speed or 2
    
    local basePosition = object.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        local offset = math.sin((tick() - startTime) * speed) * amplitude
        object.Position = basePosition + UDim2.new(0, 0, 0, offset)
    end)
    
    table.insert(self.RunningLoops, connection)
    return connection
end

--- Parallax effect based on mouse position
function Animations:Parallax(object, intensity)
    intensity = intensity or 0.02
    
    local userInputService = game:GetService("UserInputService")
    local camera = workspace.CurrentCamera
    
    if not camera then return end
    
    local viewportCenter = camera.ViewportSize / 2
    local basePosition = object.Position
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        local mousePos = userInputService:GetMouseLocation()
        local offset = (mousePos - viewportCenter) * intensity
        
        object.Position = basePosition + UDim2.new(0, offset.X, 0, offset.Y)
    end)
    
    table.insert(self.RunningLoops, connection)
    return connection
end

--- Typewriter text effect
function Animations:Typewriter(textLabel, text, speed, onComplete)
    speed = speed or 0.03
    textLabel.Text = ""
    textLabel.MaxVisibleGraphemes = 0
    
    task.spawn(function()
        for i = 1, utf8.len(text) do
            if not textLabel or not textLabel.Parent then return end
            textLabel.MaxVisibleGraphemes = i
            task.wait(speed)
        end
        textLabel.MaxVisibleGraphemes = -1
        if onComplete then onComplete() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SCROLL ANIMATIONS
-- ═══════════════════════════════════════════════════════════════

--- Smooth scroll to position
function Animations:SmoothScroll(scrollingFrame, targetPosition, duration)
    duration = duration or 0.5
    
    return self:Tween(scrollingFrame, {
        CanvasPosition = targetPosition
    }, duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

--- Scroll to child element
function Animations:ScrollToElement(scrollingFrame, element, duration)
    duration = duration or 0.4
    
    local elementPosition = element.AbsolutePosition - scrollingFrame.AbsolutePosition
    local targetPos = Vector2.new(0, elementPosition.Y + scrollingFrame.CanvasPosition.Y)
    
    return self:SmoothScroll(scrollingFrame, targetPos, duration)
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════

--- Stop all running animations and loops
function Animations:Cleanup()
    self:CancelAllTweens()
    
    for _, connection in ipairs(self.RunningLoops) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self.RunningLoops = {}
    
    for _, connection in ipairs(self.SpringConnections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    self.SpringConnections = {}
end

--- Enable/disable animations globally
function Animations:SetEnabled(enabled)
    self.Enabled = enabled
    if not enabled then
        self:CancelAllTweens()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- RETURN MODULE
-- ═══════════════════════════════════════════════════════════════

return Animations