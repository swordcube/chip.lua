local SpriteUtil = qrequire("chip.utils.SpriteUtil") --- @type chip.utils.SpriteUtil

local FrameCollection = qrequire("chip.animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection
local TileFrames = qrequire("chip.animation.frames.TileFrames") --- @type chip.animation.frames.TileFrames

local AnimationController = qrequire("chip.animation.AnimationController") --- @type chip.animation.AnimationController

---
--- @class chip.graphics.Sprite : chip.core.Actor2D
---
local Sprite = Actor2D:extend("Sprite", ...)

function Sprite:constructor(x, y)
    Sprite.super.constructor(self, x, y)

    self.frameWidth = nil
    self.frameHeight = nil

    ---
    --- The width of this actor. (in pixels)
    ---
    self.width = nil --- @type number

    ---
    --- The height of this actor. (in pixels)
    ---
    self.height = nil --- @type number

    ---
    --- The frame collection to used to render this sprite.
    ---
    --- @type chip.animation.frames.FrameCollection?
    ---
    self.frames = nil

    ---
    --- The texture attached to this sprite's frame collection.
    ---
    --- @type chip.graphics.Texture?
    ---
    self.texture = nil

    ---
    --- The total number of frames in the parent
    --- sprite's texture.
    --- 
    --- @type integer
    ---
    self.numFrames = nil

    ---
    --- The current frame to used to render this sprite.
    ---
    --- @type chip.animation.frames.FrameData?
    ---
    self.frame = nil

    ---
    --- The X and Y offset of this sprite. (not accounting for rotation)
    ---
    --- @type chip.math.Point
    ---
    self.offset = Point:new(0, 0)

    ---
    --- The X and Y offset of this sprite. (accounting for rotation)
    ---
    --- @type chip.math.Point
    ---
    self.frameOffset = Point:new(0, 0)

    ---
    --- The X and Y scale of this sprite.
    ---
    self.scale = Point:new(1, 1) --- @type chip.math.Point

    ---
    --- The X and Y rotation origin of this sprite
    ---
    self.origin = Point:new(0.5, 0.5) --- @type chip.math.Point

    ---
    --- Controls how much this sprite can scroll on a camera.
    ---
    --- @type chip.math.Point
    ---
    self.scrollFactor = Point:new(1, 1)

    ---
    --- The rotation of this sprite. (in radians)
    ---
    self.rotation = 0.0

    ---
    --- The rotation of this sprite. (in degrees)
    ---
    self.rotationDegrees = nil

    ---
    --- Controls whether or not this sprite is
    --- flipped on the X axis.
    ---
    --- @type boolean
    ---
    self.flipX = false

    ---
    --- Controls whether or not this sprite is
    --- flipped on the Y axis.
    ---
    --- @type boolean
    ---
    self.flipY = false

    ---
    --- The object responsible for controlling this sprite's animation.
    --- 
    --- @type chip.animation.AnimationController
    ---
    self.animation = AnimationController:new(self)

    ---
    --- @protected
    --- @type number
    ---
    self._rotation = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._cosRotation = 1.0

    ---
    --- @protected
    --- @type number
    ---
    self._sinRotation = 0.0

    ---
    --- @protected
    --- @type chip.animation.frames.FrameCollection?
    ---
    self._frames = nil

    ---
    --- @protected
    --- @type chip.animation.frames.FrameData?
    ---
    self._frame = nil
end

---
--- Loads a given texture onto this sprite.
--- 
--- @param  texture      chip.graphics.Texture?|string  The texture to load onto this sprite.
--- @param  animated     boolean?                      Whether or not the texture is animated.
--- @param  frameWidth   number?                       The width of each frame in the texture.
--- @param  frameHeight  number?                       The height of each frame in the texture.
--- 
--- @return chip.graphics.Sprite
---
function Sprite:loadTexture(texture, animated, frameWidth, frameHeight)
    animated = animated ~= nil and animated or false
    texture = Assets.getTexture(texture)

    if not texture then
        return self
    end
    frameWidth = frameWidth and frameWidth or 0
    frameHeight = frameHeight and frameHeight or 0

    if frameWidth == 0 then
        frameWidth = animated and texture.height or texture.width
        frameWidth = (frameWidth > texture.width) and texture.width or frameWidth
   
    elseif frameWidth > texture.width then
        print('frameWidth:' .. frameWidth .. ' is larger than the graphic\'s width:' .. texture.width)
    end

    if frameHeight == 0 then
        frameHeight = animated and frameWidth or texture.height
        frameHeight = (frameHeight > texture.height) and texture.height or frameHeight
    
    elseif frameHeight > texture.height then
        print('frameHeight:' ..frameHeight .. ' is larger than the graphic\'s height:' .. texture.height)
    end

    if animated then
        self.frames = TileFrames.fromTexture(texture, Point:new(frameWidth, frameHeight))
    else
        self.frames = FrameCollection.fromTexture(texture)
    end
    return self
end

---
--- Generates a texture of a given width and height
--- and fills it's pixels with a given color.
---
--- @param  width   integer                    The width of the generated texture. (in pixels)
--- @param  height  integer                    The height of the generated texture. (in pixels)
--- @param  color   chip.utils.Color|integer  The color of the pixels in the generated texture.
---
--- @return chip.graphics.Sprite
---
function Sprite:makeTexture(width, height, color)
    self.antialiasing = false
    self:loadTexture(SpriteUtil.makeRectangle(width, height, color))
    return self
end

---
--- Acts similarily to `makeTexture()`, but instead generating
--- a 1x1 texture with the given color, then setting this
--- sprite's scale to the given width and height.
--- 
--- This is preferred over `makeTexture()`, however it is still
--- available if you absolutely need to use it.
---
--- @param  width   integer                    The width of the sprite. (in pixels)
--- @param  height  integer                    The height of the sprite. (in pixels)
--- @param  color   chip.utils.Color|integer  The color of the generated texture.
---
--- @return chip.graphics.Sprite
---
function Sprite:makeSolid(width, height, color)
    self:makeTexture(1, 1, color)
    self.scale:set(width, height)
    return self
end

---
--- @param  width?   number
--- @param  height?  number
---
function Sprite:setGraphicSize(width, height)
    width = width or 0.0
    height = height or 0.0

    if width <= 0 and height <= 0 then
        return
    end
    local newScaleX = width / self.frameWidth
    local newScaleY = height / self.frameHeight
    self.scale:set(newScaleX, newScaleY)

    if width <= 0 then
        self.scale.x = newScaleY
    elseif height <= 0 then
        self.scale.y = newScaleX
    end
end

---
--- Updates this sprite.
---
function Sprite:update(delta)
    self.animation:update(delta)
end

---
--- Draws this sprite to the screen.
---
function Sprite:draw()
    if not self.frames or not self.frame or not self.frame.texture then
        return
    end
    local curAnim = self.animation.curAnim
    
    local ox, oy = self.origin.x * self.width, self.origin.y * self.height
    local rx, ry = (self.x - self.offset.x) + ox, (self.y - self.offset.y) + oy
 
    local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.scale.x < 0 and -1 or 1)
    local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.scale.x < 0 and -1 or 1)

    offx = offx - (self.frame.offset.x * (self.scale.x < 0 and -1 or 1))
    offy = offy - (self.frame.offset.y * (self.scale.y < 0 and -1 or 1))

    -- TODO: maybe have some kind of ParallaxLayer instead of this
    local cam = Camera.currentCamera
    if cam then
        offx = offx - ((cam.x - (Engine.gameWidth * 0.5)) * self.scrollFactor.x)
        offy = offy - ((cam.y - (Engine.gameHeight * 0.5)) * self.scrollFactor.y)
    end

    rx = rx + ((offx * math.abs(self.scale.x)) * self._cosRotation + (offy * math.abs(self.scale.y)) * -self._sinRotation)
    ry = ry + ((offx * math.abs(self.scale.x)) * self._sinRotation + (offy * math.abs(self.scale.y)) * self._cosRotation)

    local sx = self.scale.x * (self.flipX and -1.0 or 1.0)
    local sy = self.scale.y * (self.flipY and -1.0 or 1.0)
    love.graphics.draw(
        self.frame.texture.image, self.frame.quad, -- What's actually drawn to the screen
        rx, ry, -- X and Y coordinates
        self.rotation, -- Rotation (in radians)
        sx, sy, -- X and Y scaling
        ox, oy -- X and Y rotation origin
    )
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Sprite:get_frameWidth()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.width
    end
    return self.frame and self.frame.width or 0.0
end

---
--- @protected
---
function Sprite:get_width()
    return self.frameWidth * math.abs(self.scale.x)
end

---
--- @protected
---
function Sprite:get_frameHeight()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.height
    end
    return self.frame and self.frame.height or 0.0
end

---
--- @protected
---
function Sprite:get_height()
    return self.frameHeight * math.abs(self.scale.y)
end

---
--- @protected
---
function Sprite:get_rotation()
    return self._rotation
end

---
--- @protected
---
function Sprite:set_rotation(val)
    self._rotation = val

    self._cosRotation = math.cos(val)
    self._sinRotation = math.sin(val)

    return self._rotation
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

---
--- @protected
---
function Sprite:get_texture()
    if not self.frames then
        return nil
    end
    return self.frames.texture
end

---
--- @protected
---
function Sprite:get_frame()
    return self._frame
end

---
--- @protected
---
function Sprite:get_numFrames()
    if self.frames then
        return self.frames.numFrames
    end
    return 0
end

---
--- @protected
---
function Sprite:set_frame(val)
    self._frame = val
end

---
--- @protected
---
function Sprite:get_frames()
    return self._frames
end

---
--- @protected
---
function Sprite:set_frames(val)
    if val then
        if self.texture then -- prevent texture from getting destroyed too early
            self.texture:reference()
        end
        for i = 1, #self.animation.animations do
            local anim = self.animation.animations[i] --- @type chip.animation.AnimationData
            anim:free()
        end
        if self.texture then
            self.texture:unreference()
        end
        
        if self._frames then
            self._frames:unreference()
        end
        self._frames = val
        self._frames:reference()
        
        self.frame = self._frames.frames[1]

        self.animation.animations = {}
        self.animation.curAnim = nil
    end
    return self._frames
end

return Sprite