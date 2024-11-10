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

    ---
    --- @protected
    --- @type chip.math.Rect
    ---
    self._rect = Rect:new()

    ---
    --- @protected
    --- @type chip.math.Point
    ---
    self._scaledOrigin = Point:new()
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
        self:setFrames(TileFrames.fromTexture(texture, Point:new(frameWidth, frameHeight)))
    else
        self:setFrames(FrameCollection.fromTexture(texture))
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
--- @param  newRect  chip.math.Rect
---
function Sprite:getScreenBounds(newRect)
    if not newRect then
        newRect = Rect:new()
    end
    local camX, camY = 0, 0
    local parentX, parentY = 0, 0
    if self._parent:is(CanvasLayer) then
        parentX = self._parent.x
        parentY = self._parent.y
    else
        local cam = Camera.currentCamera
        if cam then
            camX = cam.x - (Engine.gameWidth * 0.5)
            camY = cam.y - (Engine.gameHeight * 0.5)
        end
    end
    newRect:setPosition(self.x + parentX, self.y + parentY)
    self._scaledOrigin:set(self:getWidth() * self.origin.x, self:getHeight() * self.origin.y)

    newRect.x = newRect.x + (-((camX + parentX) * self.scrollFactor.x) - self.offset.x + (self:getFrameWidth() * self.origin.x) - self._scaledOrigin.x)
    newRect.y = newRect.y + (-((camY + parentY) * self.scrollFactor.y) - self.offset.y + (self:getFrameHeight() * self.origin.y) - self._scaledOrigin.y)

    newRect:setSize(self:getFrameWidth() * self.scale.x, self:getFrameHeight() * self.scale.y)
    return newRect:getRotatedBounds(self._rotation, self._scaledOrigin, newRect)
end

function Sprite:isOnScreen()
    local parentScale = Point:new(1, 1) --- @type chip.math.Point
    local cam, camZoomX, camZoomY = Camera.currentCamera, 1, 1
    if cam then
        camZoomX, camZoomY = cam:getZoom(), cam:getZoom()
    end
    if self._parent:is(CanvasLayer) then
        parentScale:set(self._parent.scale.x, self._parent.scale.y)
    end
    local bounds = self:getScreenBounds(self._rect)
    local camWidth = Engine.gameWidth * (1 - camZoomX)
    local camHeight = Engine.gameHeight * (1 - camZoomY)
    return 
        (bounds.x + bounds.width) > -(Engine.gameWidth + camWidth) and 
        bounds.x < ((Engine.gameWidth / camZoomX) + camWidth) and
        (bounds.y + bounds.height) > -(Engine.gameHeight + camHeight) and
        bounds.y < ((Engine.gameHeight / camZoomY) + camHeight)
end

---
--- Draws this sprite to the screen.
---
function Sprite:draw()
    if not self:isOnScreen() then
        return
    end
    local frames, frame = self._frames, self._frame
    local width, height = self:getWidth(), self:getHeight()
    
    if not frames or not frame or not frame.texture then
        return
    end
    local curAnim = self.animation.curAnim
    
    local ox, oy = self.origin.x * width, self.origin.y * height
    local rx, ry = (self.x - self.offset.x) + ox, (self.y - self.offset.y) + oy
 
    local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.scale.x < 0 and -1 or 1)
    local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.scale.x < 0 and -1 or 1)

    offx = offx - (frame.offset.x * (self.scale.x < 0 and -1 or 1))
    offy = offy - (frame.offset.y * (self.scale.y < 0 and -1 or 1))

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
        frame.texture:getImage(), frame.quad, -- What's actually drawn to the screen
        rx, ry, -- X and Y coordinates
        self:getRotation(), -- Rotation (in radians)
        sx, sy, -- X and Y scaling
        ox, oy -- X and Y rotation origin
    )
end

function Sprite:getFrameWidth()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.width
    end
    local frame = self:getFrame()
    return frame and frame.width or 0.0
end

function Sprite:getWidth()
    return self:getFrameWidth() * math.abs(self.scale.x)
end

function Sprite:getFrameHeight()
    if self.animation.curAnim then
        local firstFrame = self.animation.curAnim.frames[1]
        return firstFrame.height
    end
    local frame = self:getFrame()
    return frame and frame.height or 0.0
end

function Sprite:getHeight()
    return self:getFrameHeight() * math.abs(self.scale.y)
end

function Sprite:getRotation()
    return self._rotation
end

function Sprite:setRotation(val)
    self._rotation = val

    self._cosRotation = math.cos(val)
    self._sinRotation = math.sin(val)

    return self._rotation
end

function Sprite:getRotationDegrees()
    return math.deg(self:getRotation())
end

function Sprite:setRotationDegrees(val)
    self:setRotation(math.rad(val))
end

function Sprite:getTexture()
    local frames = self:getFrames()
    if not frames then
        return nil
    end
    return frames.texture
end

function Sprite:getFrame()
    return self._frame
end

function Sprite:setFrame(val)
    self._frame = val
end

function Sprite:getNumFrames()
    local frames = self:getFrames()
    if frames then
        return frames.numFrames
    end
    return 0
end

function Sprite:getFrames()
    return self._frames
end

function Sprite:setFrames(val)
    if val then
        local texture = self:getTexture()
        if texture then -- prevent texture from getting destroyed too early
            texture:reference()
        end
        for i = 1, #self.animation._animations do
            local anim = self.animation._animations[i] --- @type chip.animation.AnimationData
            anim:free()
        end
        if texture then
            texture:unreference()
        end
        
        if self._frames then
            self._frames:unreference()
        end
        self._frames = val
        self._frames:reference()
        
        self:setFrame(self._frames:getFrames()[1])

        self.animation._animations = {}
        self.animation._curAnim = nil
    end
end

--- [ PRIVATE API ] ---

return Sprite