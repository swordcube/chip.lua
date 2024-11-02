---
--- @class chip.graphics.Sprite : chip.core.Actor2D
---
local Sprite = Actor2D:extend("Sprite", ...)

function Sprite:constructor()
    Sprite.super.constructor(self)

    ---
    --- The texture that this sprite will
    --- display to the screen.
    ---
    self.texture = nil --- @type love.Image

    ---
    --- The X and Y scale of this sprite.
    ---
    self.scale = Point:new(1, 1) --- @type chip.math.Point

    ---
    --- The X and Y rotation origin of this sprite
    ---
    self.origin = Point:new(0.5, 0.5) --- @type chip.math.Point

    ---
    --- The rotation of this sprite. (in radians)
    ---
    self.rotation = 0.0
end

function Sprite:draw()
    love.graphics.draw(
        self.texture, -- What's actually drawn to the screen
        self.x, self.y, -- X and Y coordinates
        self.rotation, -- Rotation (in radians)
        self.scale.x, self.scale.y, -- X and Y scaling
        self.origin.x, self.origin.y -- X and Y rotation origin
    )
end

return Sprite