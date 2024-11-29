local tmr = love.timer

---
--- @class chip.Engine
---
local Engine = {}

---
--- The width of the game area. (in pixels)
---
Engine.gameWidth = 640 --- @type integer

---
--- The height of the game area. (in pixels)
---
Engine.gameHeight = 480 --- @type integer

---
--- The object responsible for scaling the game
--- to the window as it's resized.
---
Engine.scaleMode = nil --- @type chip.graphics.scalemodes.BaseScaleMode?

---
--- The currently active scene.
---
Engine.currentScene = nil --- @type chip.core.Scene

---
--- The time since the last frame. (in seconds)
---
Engine.deltaTime = 0.0 --- @type number

---
--- The target framerate of the game.
---
Engine.targetFPS = 60 --- @type integer

---
--- Whether or not the framerate of the game
--- should match the monitor that the window
--- is currently within.
---
Engine.vsync = true

---
--- A list of every added plugin.
--- 
--- Plugins are responsible for running some of
--- your game related stuff in the background automatically.
---
Engine.plugins = {}

---
--- Controls whether or not plugins should
--- be drawn in front of the game.
---
Engine.drawPluginsInFront = true --- @type boolean

---
--- A signal that is fired before the game updates.
---
Engine.preUpdate = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game updates
---
Engine.postUpdate = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the game
--- is drawn to the screen.
---
Engine.preDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the current
--- scene or any plugin is drawn to the screen.
---
Engine.preSceneDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the current
--- scene or any plugin drawn to the screen.
---
Engine.postSceneDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game
--- is drawn to the screen.
---
Engine.postDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the game
--- switches scenes.
---
Engine.preSceneSwitch = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game
--- switches scenes.
---
Engine.postSceneSwitch = Signal:new() --- @type chip.utils.Signal

---
--- Adds a plugin to the engine.
---
--- @param  plugin  chip.core.Actor  The plugin to add.
---
function Engine.addPlugin(plugin)
    if table.contains(Engine.plugins, plugin) then
        return
    end
    table.insert(Engine.plugins, plugin)
end

---
--- Removes a plugin from the engine.
---
--- @param  plugin  chip.core.Actor  The plugin to remove.
---
function Engine.removePlugin(plugin)
    table.removeItem(Engine.plugins, plugin)
end

---
--- Returns the amount of frames drawn
--- to the screen in the last second.
---
--- @return integer
---
function Engine.getCurrentFPS()
    return Engine._currentFPS
end

---
--- Returns the amount of ticks/update calls
--- ran in the last second.
---
--- @return integer
---
function Engine.getCurrentTPS()
    -- This only works because we're not limiting FPS
    -- via sleeping, since that's too inaccurate.

    -- Instead we are using a simple timer and an if
    -- statement to do the job, so this effectively
    -- returns into a ticks per second counter.
    
    return tmr.getFPS()
end

---
--- @param  newScene  chip.core.Scene
---
function Engine.switchScene(newScene)
    Engine._requestedScene = newScene
end

--- [ PRIVATE API ] ---

---
--- @protected
--- @type chip.core.Scene?
---
Engine._requestedScene = nil

---
--- @protected
--- @type integer
---
Engine._currentFPS = 0

return Engine