--[[
    chip.lua: a simple 2D game framework built off of Love2D
    Copyright (C) 2024  swordcube

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

---@diagnostic disable: invisible

--- [ BASIC LUA CONFIG ] ---

io.stdout:setvbuf("no") -- Allows console output to be shown immediately

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
function crequire(modname) -- crequire = quick require
    if modname == nil or #modname == 0 then
        return require(classPath)
    end
    return require(classPath .. ".src." .. modname)
end

--- [ BACKEND IMPORTS ] ---

crequire("utils.lua.MathUtil")
crequire("utils.lua.StringUtil")
crequire("utils.lua.TableUtil")

crequire("libs.autobatch")

Class = crequire("libs.Classic") --- @type chip.libs.Class
Native = crequire("native") --- @type chip.Native

Json = crequire("libs.Json") --- @type chip.libs.Json
Xml = crequire("libs.Xml") --- @type chip.libs.Xml

Object = crequire("backend.Object") --- @type chip.backend.Object
RefCounted = crequire("backend.RefCounted") --- @type chip.backend.RefCounted

--- [ MATH IMPORTS ] ---

Point = crequire("math.Point") --- @type chip.math.Point
Rect = crequire("math.Rect") --- @type chip.math.Rect

--- [ CORE IMPORTS ] ---

Actor = crequire("core.Actor") --- @type chip.core.Actor
Actor2D = crequire("core.Actor2D") --- @type chip.core.Actor

Group = crequire("core.Group") --- @type chip.core.Group
Scene = crequire("core.Scene") --- @type chip.core.Scene

--- [ GRAPHICS IMPORTS ] ---

Texture = crequire("graphics.Texture") --- @type chip.graphics.Texture
Shader = crequire("graphics.Shader") --- @type chip.graphics.Shader
Font = crequire("graphics.Font") --- @type chip.graphics.Font

Sprite = crequire("graphics.Sprite") --- @type chip.graphics.Sprite
Text = crequire("graphics.Text") --- @type chip.graphics.Text

Backdrop = crequire("graphics.Backdrop") --- @type chip.graphics.Backdrop
TiledSprite = crequire("graphics.TiledSprite") --- @type chip.graphics.TiledSprite

Camera = crequire("graphics.Camera") --- @type chip.graphics.Camera
CanvasLayer = crequire("graphics.CanvasLayer") --- @type chip.graphics.CanvasLayer

Viewport = crequire("graphics.Viewport") --- @type chip.graphics.Viewport
ProgressBar = crequire("graphics.ProgressBar") --- @type chip.graphics.ProgressBar
MouseCursor = crequire("graphics.MouseCursor") --- @type chip.graphics.MouseCursor

BaseScaleMode = crequire("graphics.scalemodes.BaseScaleMode") --- @type chip.graphics.scalemodes.BaseScaleMode
RatioScaleMode = crequire("graphics.scalemodes.RatioScaleMode") --- @type chip.graphics.scalemodes.RatioScaleMode

FlickerEffect = crequire("graphics.effects.FlickerEffect") --- @type chip.graphics.effects.FlickerEffect

--- [ AUDIO IMPORTS ] ---

AudioBus = crequire("audio.AudioBus") --- @type chip.audio.AudioBus

AudioStream = crequire("audio.AudioStream") --- @type chip.audio.AudioStream
AudioPlayer = crequire("audio.AudioPlayer") --- @type chip.audio.AudioPlayer

BGM = crequire("audio.BGM") --- @type chip.audio.BGM

--- [ PLUGIN IMPORTS ] ---

TimerManager = crequire("plugins.TimerManager") --- @type chip.plugins.TimerManager
TweenManager = crequire("plugins.TweenManager") --- @type chip.plugins.TweenManager

--- [ TWEEN IMPORTS ] ---

Ease = crequire("tweens.Ease") --- @type chip.tweens.Ease
Tween = crequire("tweens.Tween") --- @type chip.tweens.Tween

--- [ UTILITY IMPORTS ] ---

Pool = crequire("utils.Pool") --- @type chip.utils.Pool

File = crequire("utils.File") --- @type chip.utils.File
Assets = crequire("utils.Assets") --- @type chip.utils.Assets

Bit = crequire("utils.Bit") --- @type chip.utils.Bit
Color = crequire("utils.Color") --- @type chip.utils.Color

Signal = crequire("utils.Signal") --- @type chip.utils.Signal
Save = crequire("utils.Save") --- @type chip.utils.Save

Timer = crequire("utils.Timer") --- @type chip.utils.Timer
KeyCode = crequire("utils.KeyCode") --- @type chip.utils.KeyCode

--- [ DEBUG IMPORTS ] ---

Log = crequire("debug.Log") --- @type chip.debug.Log
Debugger = crequire("debug.Debugger") --- @type chip.debug.Debugger

--- [ INPUT IMPORTS ] ---

Input = crequire("input.Input") --- @type chip.input.Input
InputState = crequire("input.InputState") --- @type chip.input.InputState

InputEvent = crequire("input.InputEvent") --- @type chip.input.InputEvent
InputEventKey = crequire("input.keyboard.InputEventKey") --- @type chip.input.keyboard.InputEventKey
InputEventTextInput = crequire("input.keyboard.InputEventTextInput") --- @type chip.input.keyboard.InputEventTextInput

InputEventMouse = crequire("input.mouse.InputEventMouse") --- @type chip.input.mouse.InputEventMouse
InputEventMouseButton = crequire("input.mouse.InputEventMouseButton") --- @type chip.input.mouse.InputEventMouseButton
InputEventMouseMotion = crequire("input.mouse.InputEventMouseMotion") --- @type chip.input.mouse.InputEventMouseMotion
InputEventMouseScroll = crequire("input.mouse.InputEventMouseScroll") --- @type chip.input.mouse.InputEventMouseScroll

--- [ GAME IMPORTS ] ---

Engine = crequire("Engine") --- @type chip.Engine

--- [ CORE ] ---

function love.window.resize(width, height)
    local _, _, flags = love.window.getMode()
    love.window.setMode(width, height, flags)
end

--- [ SHORTCUTS TO LUA FUNCS ] ---

local max = math.max
local tblInsert = table.insert
local tblRemove = table.remove

--- [ SHORTCUTS TO LOVE2D FUNCS ] ---

local ev = love.event
local gfx = love.graphics
local tmr = love.timer
local window = love.window
local system = love.system

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
    if Engine.preUpdate._cancelled then
        return
    end
    MouseCursor._update()
    if Engine._requestedScene and Engine._canSwitchScene then
        Engine._switchScene()
    end
    BGM.update(dt)
    plugins:_update(dt)

    if Engine.currentScene then
        Engine.currentScene:_update(dt)
    end
    if Engine.debugMode then
        Debugger.update(dt)
    end
    Engine.postUpdate:emit()
end
local function draw()
    Engine.preDraw:emit()
    if Engine.preDraw._cancelled then
        return
    end
    if Engine.debugMode then
        Debugger.preDraw()
    end

    -- Draw current scene to the game area
    gfx.push()
    gfx.setScissor(
        Engine.scaleMode.offset.x, Engine.scaleMode.offset.y,
        Engine.scaleMode.gameSize.x, Engine.scaleMode.gameSize.y
    )
    gfx.translate(Engine.scaleMode.offset.x, Engine.scaleMode.offset.y)
    gfx.scale(Engine.scaleMode.scale.x, Engine.scaleMode.scale.y)
    
    local color = Engine.clearColor
    gfx.setColor(color.r, color.g, color.b, color.a)

    gfx.rectangle("fill", 0, 0, Engine.gameWidth, Engine.gameHeight)
    gfx.setColor(1, 1, 1, 1)
    
    Engine.preSceneDraw:emit()

    if not Engine.drawPluginsInFront then
        plugins:_draw()
    end
    if not Engine.preSceneDraw._cancelled then
        Engine.currentScene:_draw()
    end
    if Engine.drawPluginsInFront then
        plugins:_draw()
    end
    if not Engine.preSceneDraw._cancelled then
        Engine.postSceneDraw:emit()
    end

    gfx.setScissor()
    gfx.pop()
    
    Engine.postDraw:emit()

    if Engine.debugMode then
        Debugger.draw()
    end
    MouseCursor._draw()
end

local dt = 0
local drawTmr = 999999

local lastDraw = 0.0
local fpsTimer = 0.0

local drawsPassed = 0
local currentFPS = 0

local wasFocused = true
local monitorRefreshRate = 60.0

local function loop()
    local ticks = Native.getTicksNS()
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
    if wasFocused ~= focused then
        if focused then
            Engine.onFocusGained:emit()
        else
            Engine.onFocusLost:emit()
        end
        wasFocused = focused
    end
    local cap = ((focused or not Engine.autoPause) and (Engine.vsync and monitorRefreshRate or Engine.targetFPS) or 10)
    local capDt = (cap > 0) and 1 / cap or 0

    if tmr then
        dt = math.min(tmr.step(), math.max(capDt, 0.0416))
        Engine.deltaTime = dt * Engine.timeScale
    end
    if Engine.parallelUpdating then
        if focused or not Engine.autoPause then
            update(Engine.deltaTime)
            collectgarbage(_gcStep_)
        else
            love.timer.sleep(capDt)
            collectgarbage(_gcCollect_)
        end
    end
    drawTmr = drawTmr + dt
    
    if cap <= 0 or drawTmr >= capDt then
        if gfx and gfx.isActive() then
            gfx.origin()
            gfx.clear(gfx.getBackgroundColor())
            
            if not Engine.parallelUpdating then
                update(Engine.deltaTime)
            end
            draw()
    
            gfx.present()

            local drawDt = love.timer.getTime() - lastDraw
            drawsPassed = drawsPassed + 1
            
            fpsTimer = fpsTimer + drawDt
            if fpsTimer >= 1.0 then
                currentFPS = drawsPassed
                Engine._currentFPS = currentFPS

                drawsPassed = 0
                fpsTimer = fpsTimer % 1.0
            end
            lastDraw = love.timer.getTime()
        end
        drawTmr = 0
    end
    if Engine.parallelUpdating then
        if Engine.lowPowerMode then
            local eventDt = max(Native.getTicksNS() - ticks, 0.0)
            Native.nanoSleep(max((1000000000 - eventDt) / 1000, 0.0))
        end
    else
        local eventDt = max(Native.getTicksNS() - ticks, 0.0)
        Native.nanoSleep(max((1000000000 - eventDt) / cap, 0.0))
    end
end
local function run()
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
local function processInputEvent(event)
    Debugger.input(event)
    if Debugger.isVisible() then
        return
    end
    Engine.onInputReceived:emit(event)
    Engine.currentScene:_input(event)
end
local function textinput(char)
    local event = InputEventTextInput:new(char)
    processInputEvent(event)
    event:free()
end
local function keypressed(key, scancode, repeating)
    local event = InputEventKey:new(key, scancode, true, repeating)
    processInputEvent(event)
    event:free()
end
local function keyreleased(key, scancode)
    local event = InputEventKey:new(key, scancode, false, false)
    processInputEvent(event)
    event:free()
end
local function mousemoved(x, y, dx, dy, _)
    local event = InputEventMouseMotion:new(x, y, dx, dy)
    processInputEvent(event)
    event:free()
end
local function wheelmoved(x, y)
    local event = InputEventMouseScroll:new(x, y)
    processInputEvent(event)
    event:free()
end
local function mousepressed(x, y, button, _, _)
    local event = InputEventMouseButton:new(x, y, true, button)
    processInputEvent(event)
    event:free()
end
local function mousereleased(x, y, button, _, _)
    local event = InputEventMouseButton:new(x, y, false, button)
    processInputEvent(event)
    event:free()
end
local function resize(width, height)
    Engine.scaleMode:onMeasure(width, height)
    Engine.onWindowResize:emit(width, height)
end
local function quit()
    Engine.onQuit:emit()
    return Engine.onQuit._cancelled
end

---
--- Initializes chip with some given settings,
--- specific to your game!
---
--- @param  settings  chip.GameSettings
---
function Chip.init(settings)
    Log.luaPrint = print
    print = function(...)
        local source = debug.getinfo(2, "S").source
        if File.fileExists(source:sub(2)) then
            source = source:sub(2)
        end
        local curLine = debug.getinfo(2, "l").currentline
        Log.info(nil, source, curLine, ...)
    end
    love.load = function(args)
        if system.getOS() == "Windows" then
            Native.setDarkMode(true)
            Native.forceWindowRedraw()
        end
        local supportedFeatures = gfx.getSupported()
        if not supportedFeatures.glsl3 then
            -- Don't know if some Linux systems will end up
            -- displaying the error message inside the window or not
            if system.getOS() == "Windows" then
                Native.hideWindow()
            end
            Log.error(nil, nil, nil, "System is missing GLSL3 shader support")
            window.showMessageBox(
                "System is missing GLSL3 shader support",
                "This system is below the minimum system requirements for the game.\nIf your graphics drivers aren't up-to-date, try updating them and running the game again.",
                "error"
            )
            os.exit(1)
        end
        local prevWindowWidth, prevWindowHeight, flags = window.getMode()
        local screenWidth, screenHeight = window.getDesktopDimensions(flags.display)

        local scaleFactor = (screenWidth > screenHeight) and ((screenHeight * 0.8) / settings.gameHeight) or ((screenWidth * 0.8) / settings.gameWidth);
        if scaleFactor < 1 then
            local windowWidth = math.floor(scaleFactor * prevWindowWidth)
            local windowHeight = math.floor(scaleFactor * prevWindowHeight)
    
            love.window.resize(
                math.floor(scaleFactor * prevWindowWidth),
                math.floor(scaleFactor * prevWindowHeight)
            )
            love.window.setPosition(
                math.floor((screenWidth - windowWidth) * 0.5),
                math.floor((screenHeight - windowHeight) * 0.5)
            )
        end
        Engine.debugMode = settings.debugMode
        if table.contains(args, "-debug") or table.contains(args, "--debug") then
            Engine.debugMode = true
        end
        Log.outputLineNumbers = Engine.debugMode

        if (love.filesystem.isFused() or not love.filesystem.getInfo("icon.png", "file")) and love.filesystem.mountFullPath then
            local sourceBaseDir = os.getenv("OWD") -- use OWD for linux app image support
            if not sourceBaseDir then
                sourceBaseDir = love.filesystem.getSourceBaseDirectory()
            end
            love.filesystem.mountFullPath(sourceBaseDir, "")
        end
        if love.filesystem.getInfo("icon.png", "file") then
            window.setIcon(love.image.newImageData("icon.png"))
        end

        if settings.initialScene == nil then
            settings.initialScene = Scene:new()
        end
        TimerManager.global = TimerManager:new()
        Engine.plugins:add(TimerManager.global)

        TweenManager.global = TweenManager:new()
        Engine.plugins:add(TweenManager.global)

        Engine.gameWidth = settings.gameWidth
        Engine.gameHeight = settings.gameHeight
        
        Engine.targetFPS = settings.targetFPS

        Engine.scaleMode = RatioScaleMode:new()
        Engine.scaleMode:onMeasure(settings.gameWidth, settings.gameHeight)

        MouseCursor.init()
        Debugger.init()

        if settings.showSplashScreen and not Engine.debugMode then
            Engine.currentScene = crequire("SplashScene"):new(settings.initialScene)
        else
            Engine.currentScene = settings.initialScene
        end
        Input.init()
        Engine.currentScene:init()

        local _, _, wf = window.getMode()
        monitorRefreshRate = wf.refreshrate
        
        love.keyboard.setKeyRepeat(true)
    end
    love.run = run
    love.resize = resize

    love.textinput = textinput
    
    love.keypressed = keypressed
    love.keyreleased = keyreleased

    love.mousemoved = mousemoved
    love.wheelmoved = wheelmoved
    
    love.mousepressed = mousepressed
    love.mousereleased = mousereleased

    love.quit = quit
end

return Chip