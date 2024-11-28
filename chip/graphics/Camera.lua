local gfx = love.graphics

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
    --- @protected
    ---
    self._zoom = 1 --- @type number

    ---
    --- @protected
    ---
    self._rotation = 0.0 --- @type number
end

function Camera:getZoom()
    return self._zoom
end

function Camera:setZoom(val)
    self._zoom = val
end

function Camera:getRotation()
    return self._rotation
end

function Camera:setRotation(val)
    self._rotation = val
end

function Camera:getRotationDegrees()
    return math.deg(self._rotation)
end

function Camera:setRotationDegrees(val)
    self._rotation = math.rad(val)
end

function Camera:attach()
    local w2 = Engine.gameWidth * 0.5
    local h2 = Engine.gameHeight * 0.5
    local zoom = self:getZoom()

    gfx.push()
	gfx.translate(
        -(self.x - w2) - (w2 * (zoom - 1)),
        -(self.y - h2) - (h2 * (zoom - 1))
    )
	gfx.scale(zoom)

    gfx.translate(w2, h2)
	gfx.rotate(self:getRotation())
    gfx.translate(-w2, -h2)
end

function Camera:detach()
    gfx.pop()
end

--- [ PRIVATE API ] ---

return Camera