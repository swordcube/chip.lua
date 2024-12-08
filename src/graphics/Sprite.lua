--[[
    chip.lua: a simple 2D game framework built off of Love2D
    Copyright (C) 2024  swordcube

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local gfx = love.graphics
local lmath = love.math

local _linear_, _nearest_ = "linear", "nearest"

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local abs = math.abs
local atan2 = math.atan2
local deg = math.deg
local rad = math.rad

local SpriteUtil = crequire("utils.SpriteUtil") --- @type chip.utils.SpriteUtil

local FrameCollection = crequire("animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection
local TileFrames = crequire("animation.frames.TileFrames") --- @type chip.animation.frames.TileFrames

local AnimationController = crequire("animation.AnimationController") --- @type chip.animation.AnimationController

---
--- @class chip.graphics.Sprite : chip.core.Actor2D
---
local Sprite = Actor2D:extend("Sprite", ...)
Sprite.defaultAntialiasing = false

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

    ---
    --- @protected
    --- @type chip.utils.Color
    ---
    self._tint = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type number
    ---
    self._alpha = 1

    ---
    --- @protected
    --- @type boolean
    ---
    self._antialiasing = Sprite.defaultAntialiasing

    ---
    --- @protected
    --- @type love.Transform
    ---
    self._transform = lmath.newTransform()
end

function Sprite:isAntialiased()
    return self._antialiasing
end

function Sprite:setAntialiasing(antialiasing)
    self._antialiasing = antialiasing
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
    self._antialiasing = false
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
    local newScaleX = width / self:getFrameWidth()
    local newScaleY = height / self:getFrameHeight()
    self.scale:set(newScaleX, newScaleY)

    if width <= 0 then
        self.scale.x = newScaleY
    elseif height <= 0 then
        self.scale.y = newScaleX
    end
end

function Sprite:getTint()
    return self._tint
end

---
--- @param  tint   chip.utils.Color|integer
---
function Sprite:setTint(tint)
    self._tint = Color:new(tint)
end

function Sprite:getAlpha()
    return self._alpha
end

---
--- @param  alpha  number
---
function Sprite:setAlpha(alpha)
    self._alpha = alpha
end

---
--- Updates this sprite.
---
function Sprite:update(delta)
    self.animation:update(delta)
end

function Sprite:isOnScreen()
    local rect = self._rect
    local rx, ry, rw, rh = rect.x, rect.y, rect.width, rect.height
    return (
        (rx + rw) > 0 and rx < Engine.gameWidth and
        (ry + rh) > 0 and ry < Engine.gameHeight
    )
end

---
--- @param  axes  "x"|"y"|"xy"
---
function Sprite:screenCenter(axes)
    if axes:contains("x") then
        self:setX((Engine.gameWidth - self:getWidth()) * 0.5)
    end
    if axes:contains("y") then
        self:setY((Engine.gameHeight - self:getHeight()) * 0.5)
    end
end

---
--- @param  trans  love.Transform?  The transformation to modify, if unspecified, a new one is made.
---
--- @return love.Transform?                   trans  The modified transformation.
--- @return number                            rx     The rendered X coordinate of the sprite.
--- @return number                            ry     The rendered Y coordinate of the sprite.
--- @return number                            rw     The rendered width of the sprite.
--- @return number                            rh     The rendered height of the sprite.
--- @return chip.animation.frames.FrameData?  frame  The frame that is being rendered onto this sprite.
---
function Sprite:getRenderingInfo(trans)
    local frames, frame = self._frames, self._frame
    local width, height = self:getWidth(), self:getHeight()
    local frameWidth, frameHeight = self:getFrameWidth(), self:getFrameHeight()
    
    if not frames or not frame or not frame.texture then
        return nil, 0, 0, 0, 0, nil
    end
    local curAnim = self.animation.curAnim
    
    local ox, oy = self.origin.x * width, self.origin.y * height
    local otx, oty = self.origin.x * frameWidth, self.origin.y * frameHeight

    trans = trans or lmath.newTransform()
    trans:reset()

    local rx, ry = (self._x - self.offset.x) + ox, (self._y - self.offset.y) + oy
    
    local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.scale.x < 0 and -1 or 1)
    local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.scale.x < 0 and -1 or 1)

    offx = offx - (frame.offset.x * (self.scale.x < 0 and -1 or 1))
    offy = offy - (frame.offset.y * (self.scale.y < 0 and -1 or 1))

    local p = self._parent

    local canvases = {} --- @type table<chip.graphics.CanvasLayer>
    local isOnCanvasLayer = false

    while p do
        if p:is(CanvasLayer) then
            if not p:is(Scene) then
                isOnCanvasLayer = true
            end
            table.insert(canvases, p)
        end
        p = p._parent
    end
    if not isOnCanvasLayer then
        -- TODO: maybe have some kind of ParallaxLayer instead of this
        local cam = Camera.currentCamera
        if cam then
            rx = rx - ((cam:getX() - (Engine.gameWidth * 0.5)) * self.scrollFactor.x)
            ry = ry - ((cam:getY() - (Engine.gameHeight * 0.5)) * self.scrollFactor.y)
        end
    end
    rx = rx + ((offx * abs(self.scale.x)) * self._cosRotation + (offy * abs(self.scale.y)) * -self._sinRotation)
    ry = ry + ((offx * abs(self.scale.x)) * self._sinRotation + (offy * abs(self.scale.y)) * self._cosRotation)

    local sx = self.scale.x * (self.flipX and -1.0 or 1.0)
    local sy = self.scale.y * (self.flipY and -1.0 or 1.0)

    if not isOnCanvasLayer then
        local cam = Camera.currentCamera
        if cam then
            local w2 = Engine.gameWidth * 0.5
            local h2 = Engine.gameHeight * 0.5
            local zoom = cam:getZoom()
            
            trans:translate(
                -(w2 * (zoom - 1)),
                -(h2 * (zoom - 1))
            )
            trans:scale(zoom)
    
            trans:translate(w2, h2)
            trans:rotate(self:getRotation())
            trans:translate(-w2, -h2)
        end
    end
    local canvasCount = #canvases
    for i = 1, canvasCount do
        local canvas = canvases[canvasCount - i + 1] --- @type chip.graphics.CanvasLayer
        trans:translate(canvas:getX(), canvas:getY())

        local w2 = Engine.gameWidth * canvas.origin.x
        local h2 = Engine.gameHeight * canvas.origin.y
        trans:scale(canvas.scale.x, canvas.scale.y)
        
        trans:translate(w2, h2)
        trans:rotate(canvas.rotation)
        trans:translate(-w2, -h2)
    end
    trans:translate(rx - ox, ry - oy)
    trans:rotate(self._rotation)
    trans:scale(sx, sy)

    local v1, v2, _, rx, v5, v6, _, ry, v9, v10 = trans:getMatrix()

    local rw = self:getFrameWidth() * sqrt((v1 * v1) + (v5 * v5) + (v9 * v9))
    local rh = self:getFrameHeight() * sqrt((v2 * v2) + (v6 * v6) + (v10 * v10))
    local rotation = atan2(v5, v1) -- this is in radians

    local rect = self._rect:set(rx, ry, rw, rh) --- @type chip.math.Rect
    rect:getRotatedBounds(rotation, nil, rect)

    return trans, rect.x, rect.y, rect.width, rect.height, frame
end

---
--- Draws this sprite to the screen.
---
function Sprite:draw()
    local trans, _, _, _, _, frame = self:getRenderingInfo(self._transform)
    if not frame then
        return
    end
    if not self:isOnScreen() then
        return
    end
    local pr, pg, pb, pa = love.graphics.getColor()
    gfx.setColor(self._tint.r, self._tint.g, self._tint.b, self._alpha)

    local img = frame.texture:getImage()
    local prevFilterMin, prevFilterMag, prevFilterAns = img:getFilter()
    
    local filter = self._antialiasing and _linear_ or _nearest_
    img:setFilter(filter, filter, 4)
    
    gfx.draw(
        frame.texture:getImage(), frame.quad, -- What's actually drawn to the screen
        trans -- Transformation to apply to the sprite
    )
    img:setFilter(prevFilterMin, prevFilterMag, prevFilterAns)
    gfx.setColor(pr, pg, pb, pa)
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
    return self:getFrameWidth() * abs(self.scale.x)
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
    return self:getFrameHeight() * abs(self.scale.y)
end

function Sprite:getRotation()
    return self._rotation
end

function Sprite:setRotation(val)
    self._rotation = val

    self._cosRotation = cos(val)
    self._sinRotation = sin(val)

    return self._rotation
end

function Sprite:getRotationDegrees()
    return deg(self:getRotation())
end

function Sprite:setRotationDegrees(val)
    self:setRotation(rad(val))
end

function Sprite:getTexture()
    local frames = self:getFrames()
    if not frames then
        return nil
    end
    return frames:getTexture()
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
        return frames:getNumFrames()
    end
    return 0
end

function Sprite:getFrames()
    return self._frames
end

function Sprite:setFrames(val)
    if self._frames then
        self._frames:unreference()
    end
    self._frames = val

    if self._frames then
        self._frames:reference()
        self:setFrame(self._frames:getFrames()[1])
    end
    self.animation._animations = {}
    self.animation._curAnim = nil
end

function Sprite:free()
    self:setFrames(nil)
end

--- [ PRIVATE API ] ---

return Sprite