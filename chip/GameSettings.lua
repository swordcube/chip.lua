---
--- @class chip.GameSettings
---
local GameSettings = {
    ---
    --- The width of the game area, in pixels.
    ---
    width = 640, --- @type integer

    ---
    --- The height of the game area, in pixels.
    ---
    height = 480, --- @type integer

    ---
    --- The target framerate of the game.
    ---
    targetFPS = 60, --- @type integer

    ---
    --- The initial scene to start your game with.
    ---
    initialScene = nil --- @type chip.core.Node?
}
return GameSettings