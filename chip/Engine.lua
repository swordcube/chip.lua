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

return Engine