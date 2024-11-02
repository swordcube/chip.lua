---
--- @class chip.core.Actor2D : chip.core.Actor
---
--- A base class for all of your 2D game objects.
--- Includes built in position and size properties.
---
local Actor2D = Actor:extend("Actor2D", ...)

function Actor2D:constructor(x, y)
    Actor2D.super.constructor(self)

    ---
    --- The X coordinate of this actor on-screen. (in pixels)
    ---
    self.x = 0.0 --- @type number

    ---
    --- The Y coordinate of this actor on-screen. (in pixels)
    ---
    self.y = 0.0 --- @type number

    ---
    --- The width of this actor. (in pixels)
    ---
    self.width = 0.0 --- @type number

    ---
    --- The height of this actor. (in pixels)
    ---
    self.height = 0.0 --- @type number
end

function Actor2D:setPosition(x, y)
    self.x = x or 0.0
    self.y = y or 0.0
    return self
end

return Actor2D