---@diagnostic disable: invisible

--- [ BASIC LUA CONFIG ] ---

io.stdout:setvbuf("no") -- Allows console output to be shown immediately

--- [ SHORTCUTS TO LOVE2D FUNCS ] ---

local ev = love.event
local gfx = love.graphics
local tmr = love.timer
local window = love.window

--- [ STATIC STRINGS ] ---

local _gcStep_ = "step"
local _gcCount_ = "count"
local _gcCollect_ = "collect"

--- [ BASIC UTIL FUNCS ] ---

local classPath = ...

---
--- @param   modname  string
---
--- @return  any
--- @return  any  loaderdata
---
function qrequire(modname) -- qrequire = quick require
    if modname == nil or #modname == 0 then
        return require(classPath)
    end
    return require(classPath .. "." .. modname)
end

--- [ BACKEND IMPORTS ] ---

qrequire("chip.utils.lua.MathUtil")
qrequire("chip.utils.lua.StringUtil")
qrequire("chip.utils.lua.TableUtil")

qrequire("chip.libs.autobatch")

Class = qrequire("chip.libs.Classic") --- @type chip.libs.Class
Native = qrequire("chip.native") --- @type chip.Native

Json = qrequire("chip.libs.Json") --- @type chip.libs.Json
Xml = qrequire("chip.libs.Xml") --- @type chip.libs.Xml

Object = qrequire("chip.backend.Object") --- @type chip.backend.Object
RefCounted = qrequire("chip.backend.RefCounted") --- @type chip.backend.RefCounted

--- [ MATH IMPORTS ] ---

Point = qrequire("chip.math.Point") --- @type chip.math.Point
Rect = qrequire("chip.math.Rect") --- @type chip.math.Rect

--- [ CORE IMPORTS ] ---

Actor = qrequire("chip.core.Actor") --- @type chip.core.Actor
Actor2D = qrequire("chip.core.Actor2D") --- @type chip.core.Actor

Group = qrequire("chip.core.Group") --- @type chip.core.Group
Scene = qrequire("chip.core.Scene") --- @type chip.core.Scene

--- [ GRAPHICS IMPORTS ] ---

Texture = qrequire("chip.graphics.Texture") --- @type chip.graphics.Texture
Font = qrequire("chip.graphics.Font") --- @type chip.graphics.Font

Sprite = qrequire("chip.graphics.Sprite") --- @type chip.graphics.Sprite
Text = qrequire("chip.graphics.Text") --- @type chip.graphics.Text

Camera = qrequire("chip.graphics.Camera") --- @type chip.graphics.Camera
CanvasLayer = qrequire("chip.graphics.CanvasLayer") --- @type chip.graphics.CanvasLayer

BaseScaleMode = qrequire("chip.graphics.scalemodes.BaseScaleMode") --- @type chip.graphics.scalemodes.BaseScaleMode
RatioScaleMode = qrequire("chip.graphics.scalemodes.RatioScaleMode") --- @type chip.graphics.scalemodes.RatioScaleMode

--- [ AUDIO IMPORTS ] ---

AudioPlayer = qrequire("chip.audio.AudioPlayer") --- @type chip.audio.AudioPlayer

--- [ UTILITY IMPORTS ] ---

File = qrequire("chip.utils.File") --- @type chip.utils.File
Assets = qrequire("chip.utils.Assets") --- @type chip.utils.Assets

Bit = qrequire("chip.utils.Bit") --- @type chip.utils.Bit
Color = qrequire("chip.utils.Color") --- @type chip.utils.Color

Signal = qrequire("chip.utils.Signal") --- @type chip.utils.Signal

--- [ GAME IMPORTS ] ---

Engine = qrequire("chip.Engine") --- @type chip.Engine

--- [ CORE ] ---

local function busySleep(time) -- uses more cpu BUT results in more accurate fps
    if time <= 0 then
        return
    end
    local duration = os.clock() + time
    tmr.sleep(time)
    while os.clock() < duration do end
end
if (love.filesystem.isFused() or not love.filesystem.getInfo("assets")) and love.filesystem.mountFullPath then
    love.filesystem.mountFullPath(love.filesystem.getSourceBaseDirectory(), "")
end

---
--- @class chip.Chip
--- 
--- The class responsible for initializing
--- and handling the core of Chip.
--- 
--- You shouldn't have to use this class,
--- everything you need should be in Engine
--- or other classes throughout Chip.
---
local Chip = {}

---
--- @type string
---
Chip.classPath = classPath

local plugins = Engine.plugins
local function update(dt)
    Engine.preUpdate:emit()
    if Engine._requestedScene then
        Engine.preSceneSwitch:emit()
        
        Engine.currentScene = Engine._requestedScene
        Engine.currentScene:init()
        
        Engine._requestedScene = nil
        Engine.postSceneSwitch:emit(Engine.currentScene)
    end
    for i = 1, #plugins do
        local plugin = plugins[i] --- @type chip.core.Actor
        plugin:update(dt)
    end
    Engine.currentScene:update(dt)
    Engine.postUpdate:emit()
end
local function draw()
    Engine.preDraw:emit()

    -- Draw current scene to the game area
    gfx.push()
    gfx.setScissor(
        Engine.scaleMode.offset.x, Engine.scaleMode.offset.y,
        Engine.scaleMode.gameSize.x, Engine.scaleMode.gameSize.y
    )
    gfx.translate(Engine.scaleMode.offset.x, Engine.scaleMode.offset.y)
    gfx.scale(Engine.scaleMode.scale.x, Engine.scaleMode.scale.y)

    Engine.preSceneDraw:emit()

    if not Engine.drawPluginsInFront then
        for i = 1, #Engine.plugins do
            local plugin = Engine.plugins[i] --- @type chip.core.Actor
            plugin:draw()
        end
    end
    Engine.currentScene:draw()

    if Engine.drawPluginsInFront then
        for i = 1, #Engine.plugins do
            local plugin = Engine.plugins[i] --- @type chip.core.Actor
            plugin:draw()
        end
    end
    Engine.postSceneDraw:emit()
    
    gfx.setScissor()
    gfx.pop()

    Engine.postDraw:emit()
end

local dt = 0
local drawTmr = 999999

local lastDraw = 0.0
local fpsTimer = 0.0

local drawsPassed = 0
local currentFPS = 0

local function loop()
    if ev then
        ev.pump()
        for name, a, b, c, d, e, f in ev.poll() do
            if name == "quit" then
                if not love.quit or not love.quit() then
                    return a or 0
                end
            end
            love.handlers[name](a,b,c,d,e,f)
        end
    end
    
    local focused = window.hasFocus()
    
    local cap = (focused and (Engine.vsync and Native.getMonitorRefreshRate() or Engine.targetFPS) or 10)
    local capDt = (cap > 0) and 1 / cap or 0

    if tmr then
        dt = math.min(tmr.step(), math.max(capDt, 0.0416))
        Engine.deltaTime = dt
    end
    if focused then
        update(dt)
    else
        love.timer.sleep(capDt)
    end
    drawTmr = drawTmr + dt
    
    if cap <= 0 or drawTmr >= capDt then
        if gfx and gfx.isActive() then
            gfx.origin()
            gfx.clear(gfx.getBackgroundColor())
            
            draw()
    
            gfx.present()

            local drawDt = os.clock() - lastDraw
            drawsPassed = drawsPassed + 1
            
            fpsTimer = fpsTimer + drawDt
            if fpsTimer >= 1.0 then
                currentFPS = drawsPassed
                Engine._currentFPS = currentFPS

                drawsPassed = 0
                fpsTimer = fpsTimer % 1.0
            end
            lastDraw = os.clock()
        end
        drawTmr = drawTmr % capDt
        love.timer.sleep(dt < 0.001 and 0.001 or 0)
    end
    if focused then
        collectgarbage(_gcStep_)
    else
        collectgarbage(_gcCollect_)
    end
end

---
--- Initializes chip with some given settings,
--- specific to your game!
---
--- @param  settings  chip.GameSettings
---
function Chip.init(settings)
    local luaPrint = print
    print = function(...)
        local str = ""
        local argCount = select("#", ...)
        for i = 1, argCount do
            str = str .. tostring(select(i, ...))
            if i < argCount then
                str = str .. ", "
            end
        end
        local curFile = debug.getinfo(2, "S").source:sub(2)
        local curLine = debug.getinfo(2, "l").currentline
        luaPrint(curFile .. ":" .. curLine .. ": " .. str)
    end

    love.load = function()
        Native.setDarkMode(true)
        Native.forceWindowRedraw()

        if settings.initialScene == nil then
            settings.initialScene = Scene:new()
        end
        Engine.gameWidth = settings.gameWidth
        Engine.gameHeight = settings.gameHeight

        Engine.targetFPS = settings.targetFPS

        Engine.scaleMode = RatioScaleMode:new()
        Engine.scaleMode:onMeasure(settings.gameWidth, settings.gameHeight)

        Engine.currentScene = settings.initialScene
        Engine.currentScene:init()
    end
    love.resize = function(width, height)
        Engine.scaleMode:onMeasure(width, height)
    end
    love.run = function()
        if love.math then
            love.math.setRandomSeed(os.time())
        end
        if love.load then
            love.load(love.arg.parseGameArguments(arg), arg)
        end
        if tmr then
            tmr.step()
        end
        return loop
    end
end

return Chip