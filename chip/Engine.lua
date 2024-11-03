---
--- @class chip.Engine
---
local Engine = Class:extend("Engine", ...)

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

return Engine