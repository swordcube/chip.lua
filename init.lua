--- [ BASIC UTIL FUNCS ] ---

local classPath = ...

---
--- @return  any
--- @return  any  loaderdata
---
local function qrequire(modname) -- qrequire = quick require
    return require(classPath .. "." .. modname)
end

--- [ BACKEND IMPORTS ] ---

qrequire("chip.utils.lua.MathUtil")
qrequire("chip.utils.lua.StringUtil")
qrequire("chip.utils.lua.TableUtil")

Class = qrequire("chip.libs.Classic") --- @type chip.libs.Class
Native = qrequire("chip.native") --- @type chip.Native

Object = qrequire("chip.backend.Object") --- @type chip.libs.Class

--- [ MATH IMPORTS ] ---

Point = qrequire("chip.math.Point") --- @type chip.math.Point
Rect = qrequire("chip.math.Rect") --- @type chip.math.Rect

--- [ CORE IMPORTS ] ---

Actor = qrequire("chip.core.Actor") --- @type chip.core.Actor
Actor2D = qrequire("chip.core.Actor2D") --- @type chip.core.Actor

Group = qrequire("chip.core.Group") --- @type chip.core.Group
Scene = qrequire("chip.core.Scene") --- @type chip.core.Scene

--- [ GRAPHICS IMPORTS ] ---

Sprite = qrequire("chip.graphics.Sprite") --- @type chip.graphics.Sprite

--- [ GAME IMPORTS ] ---

Engine = qrequire("chip.Engine") --- @type chip.Engine

--- [ CORE ] ---

local function busySleep(time) -- uses more cpu BUT results in more accurate fps
    if time <= 0 then
        return
    end
    local duration = os.clock() + time
    love.timer.sleep(time * 0.9875)
    while os.clock() < duration do end
end
if (love.filesystem.isFused() or not love.filesystem.getInfo("assets")) and love.filesystem.mountFullPath then
    love.filesystem.mountFullPath(love.filesystem.getSourceBaseDirectory(), "")
end

---
--- @class chip.Core
--- 
--- The class responsible for initializing
--- and handling the core of Chip.
--- 
--- You shouldn't have to use this class,
--- everything you need should be in Engine
--- or other classes throughout Chip.
---
local Core = Class:extend("Core", ...)

---
--- Initializes chip with some given settings,
--- specific to your game!
---
--- @param  settings  chip.GameSettings
---
function Core.init(settings)
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

    love.run = function()
        if love.math then
            love.math.setRandomSeed(os.time())
        end
        if love.load then
            love.load(love.arg.parseGameArguments(arg), arg)
        end
        if love.timer then
            love.timer.step()
        end
    
        local dt = 0.0

        return function()
            if love.event then
                love.event.pump()
                for name, a, b, c, d, e, f in love.event.poll() do
                    if name == "quit" then
                        if not love.quit or not love.quit() then
                            return a or 0
                        end
                    end
                    love.handlers[name](a,b,c,d,e,f)
                end
            end
            
            local focused = love.window.hasFocus()
            
            local cap = (focused and Engine.targetFPS or 10)
            local capDt = (cap > 0) and 1 / cap or 0

            if love.timer then
                dt = math.min(love.timer.step(), math.max(capDt, 0.0416))
                Engine.deltaTime = dt
            end

            if love.update then
                love.update(dt)
            end

            if love.graphics and love.graphics.isActive() then
                love.graphics.origin()
                love.graphics.clear(love.graphics.getBackgroundColor())
                
                if love.draw then
                    love.draw()
                end

                love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 3)
                love.graphics.present()
            end

            if focused then
                collectgarbage("step")
            else
                collectgarbage("collect")
            end
            busySleep(capDt)
        end
    end
    love.update = function(dt)
        Engine.currentScene:update(dt)
    end
    love.draw = function()
        Engine.currentScene:draw()
    end

    Native.setDarkMode(true)
    Native.forceWindowRedraw()

    if settings.initialScene == nil then
        settings.initialScene = Scene:new()
    end
    Engine.targetFPS = settings.targetFPS

    Engine.currentScene = settings.initialScene
    Engine.currentScene:init()
end

return Core