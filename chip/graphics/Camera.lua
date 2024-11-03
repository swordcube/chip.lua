---
--- @class chip.graphics.Camera : chip.core.Actor2D
--- 
--- An object representing a camera, used for tracking
--- any given object, with smoothing properties, zooming, etc.
--- 
--- You may only have one active camera at a time, so if you want
--- zooming effects elsewhere, try using `CanvasLayer` instead.
---
local Camera = Actor2D:extend("Camera", ...)

---
--- The currently active camera.
---
Camera.currentCamera = nil --- @type chip.graphics.Camera

function Camera:constructor()
    Camera.super.constructor(self)

    self.x = Engine.gameWidth * 0.5
    self.y = Engine.gameHeight * 0.5

    ---
    --- The zoom factor of this camera.
    ---
    self.zoom = 1 --- @type number

    ---
    --- The rotation of this camera. (in radians)
    ---
    self.rotation = 0.0

    ---
    --- The rotation of this camera. (in degrees)
    ---
    self.rotationDegrees = nil
end

function Camera:attach()
    local w2 = Engine.gameWidth * 0.5
    local h2 = Engine.gameHeight * 0.5

    love.graphics.push()
	love.graphics.translate(
        -(self.x - w2) - (w2 * (self.zoom - 1)),
        -(self.y - h2) - (h2 * (self.zoom - 1))
    )
	love.graphics.scale(self.zoom)

    love.graphics.translate(w2, h2)
	love.graphics.rotate(self.rotation)
    love.graphics.translate(-w2, -h2)
end

function Camera:detach()
    love.graphics.pop()
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Camera:get_rotationDegrees()
    return math.deg(self.rotation)
end

---
--- @protected
---
function Camera:set_rotationDegrees(val)
    self.rotation = math.rad(val)
end

return Camera