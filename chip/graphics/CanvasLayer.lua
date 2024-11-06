---
--- @class chip.graphics.CanvasLayer : chip.core.Group
--- 
--- A group object which can be moved around on
--- the X and Y axis.
---
local CanvasLayer = Group:extend("CanvasLayer", ...)

-- TODO: add width and height to this

function CanvasLayer:constructor()
    CanvasLayer.super.constructor(self)

    ---
    --- The X coordinate of this canvas layer on-screen. (in pixels)
    ---
    self.x = 0.0 --- @type number

    ---
    --- The Y coordinate of this canvas layer on-screen. (in pixels)
    ---
    self.y = 0.0 --- @type number

    ---
    --- The X and Y scale of this canvas layer.
    ---
    self.scale = Point:new(1, 1) --- @type chip.math.Point

    ---
    --- The X and Y rotation origin of this canvas layer.
    ---
    self.origin = Point:new(0.5, 0.5) --- @type chip.math.Point

    ---
    --- The zoom factor of this canvas layer.
    ---
    self.zoom = nil --- @type number

    ---
    --- The rotation of this canvas layer. (in radians)
    ---
    self.rotation = 0.0
end

---
--- Draws all of this canvas layer's members to the screen.
---
function CanvasLayer:draw()
    love.graphics.push()
	love.graphics.translate(self.x, self.y)

    local w2 = Engine.gameWidth * self.origin.x
    local h2 = Engine.gameHeight * self.origin.y
	love.graphics.scale(self.scale.x, self.scale.y)
    
    love.graphics.translate(w2, h2)
	love.graphics.rotate(self.rotation)
    love.graphics.translate(-w2, -h2)
    
    CanvasLayer.super.draw(self)

    love.graphics.pop()
end

function CanvasLayer:getRotationDegrees()
    return math.deg(self.rotation)
end

function CanvasLayer:setRotationDegrees(val)
    self.rotation = math.rad(val)
end

function CanvasLayer:getZoom()
    return (self.scale.x + self.scale.y) * 0.5
end

function CanvasLayer:setZoom(val)
    self.x = -((Engine.gameWidth * 0.5) * (val - 1))
    self.y = -((Engine.gameHeight * 0.5) * (val - 1))
    self.scale:set(val, val)
end

--- [ PRIVATE API ] ---


return CanvasLayer