---
--- @class chip.graphics.Sprite : chip.core.Actor2D
---
local Sprite = Actor2D:extend("Sprite", ...)

function Sprite:constructor()
    Sprite.super.constructor(self)

    self.width = nil
    self.height = nil

    ---
    --- The texture that this sprite will
    --- display to the screen.
    ---
    self.texture = nil --- @type chip.graphics.Texture

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

    ---
    --- The rotation of this sprite. (in degrees)
    ---
    self.rotationDegrees = nil
end

---
--- Draws this sprite to the screen.
---
function Sprite:draw()
    local ox, oy = self.origin.x * self.width, self.origin.y * self.height
    love.graphics.draw(
        self.texture.image, -- What's actually drawn to the screen
        self.x + ox, self.y + oy, -- X and Y coordinates
        self.rotation, -- Rotation (in radians)
        self.scale.x, self.scale.y, -- X and Y scaling
        ox, oy -- X and Y rotation origin
    )
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Sprite:get_width()
    return self.texture.width * math.abs(self.scale.x)
end

---
--- @protected
---
function Sprite:get_height()
    return self.texture.height * math.abs(self.scale.y)
end

---
--- @protected
---
function Sprite:get_rotationDegrees()
    return math.deg(self.rotation)
end

---
--- @protected
---
function Sprite:set_rotationDegrees(val)
    self.rotation = math.rad(val)
end

return Sprite