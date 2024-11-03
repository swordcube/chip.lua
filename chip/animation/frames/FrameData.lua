---
--- @class chip.animation.frames.FrameData
---
local FrameData = Class:extend("FrameData", ...)

---
--- @param  name     string                 The name of this frame.
--- @param  x        number                 The X coordinate of this frame. (in pixels)
--- @param  y        number                 The Y coordinate of this frame. (in pixels)
--- @param  offsetX  number                 The offset of this frame. (x axis, in pixels)
--- @param  offsetY  number                 The offset of this frame. (y axis, in pixels)
--- @param  width    number                 The width of this frame. (in pixels)
--- @param  height   number                 The height of this frame. (in pixels)
--- @param  texture  chip.graphics.Texture  The texture to use for this frame.
---
function FrameData:constructor(name, x, y, offsetX, offsetY, width, height, texture)
    self.name = name --- @type string
    self.x = x or 0.0 --- @type number
    self.y = y or 0.0 --- @type number

    self.offset = Point:new(offsetX and offsetX or 0.0, offsetY and offsetY or 0.0) --- @type chip.math.Point
    
    self.width = width or 0.0 --- @type number
    self.height = height or 0.0 --- @type number

    self.texture = texture --- @type chip.graphics.Texture
    self.texture:reference()
    
    self.quad = love.graphics.newQuad(self.x, self.y, self.width, self.height, self.texture.width, self.texture.height) --- @type love.Quad
end

function FrameData:free()
    self.quad:release()
    self.quad = nil

    self.texture:unreference()
    self.texture = nil
end

return FrameData