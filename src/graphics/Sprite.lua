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

---@diagnostic disable: invisible

local gfx = love.graphics
local lmath = love.math

local gfxGetColor = gfx.getColor
local gfxSetColor = gfx.setColor

local gfxClear = gfx.clear
local gfxDraw = gfx.draw

local gfxPush = gfx.push
local gfxPop = gfx.pop
local gfxApplyTransform = gfx.applyTransform
local gfxTranslate = gfx.translate
local gfxRotate = gfx.rotate
local gfxRectangle = gfx.rectangle

local gfxSetStencilState = gfx.setStencilState
local gfxSetColorMask = gfx.setColorMask

local tblInsert = table.insert

local _linear_, _nearest_ = "linear", "nearest"

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local abs = math.abs
local atan2 = math.atan2
local deg = math.deg
local rad = math.rad

local stencilSprite = nil
local function stencil()
	if stencilSprite then
		gfxPush()
        gfxApplyTransform(stencilSprite._transform)
		gfxRectangle("fill", stencilSprite._clipRect.x, stencilSprite._clipRect.y, stencilSprite._clipRect.width, stencilSprite._clipRect.height)
		gfxPop()
	end
end
local function getChipImagePath(name)
    return Chip.classPath .. "/assets/images/" .. name
end

local Velocity = crequire("math.Velocity") --- @type chip.math.Velocity
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
    --- Controls how much velocity this sprite has.
    ---
    --- @type chip.math.Point
    ---
    self.velocity = Point:new()

    ---
    --- Controls how much acceleration this sprite has.
    ---
    --- @type chip.math.Point
    ---
    self.acceleration = Point:new()

    ---
    --- Controls the maximum velocity this sprite can have.
    ---
    --- @type chip.math.Point
    ---
    self.maxVelocity = Point:new()

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

    ---
    --- @protected
    --- @type boolean
    ---
    self._moves = true

    ---
    --- @protected
    --- @type chip.math.Rect?
    ---
    self._clipRect = nil

    self:loadTexture(getChipImagePath("missing.png"))
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

function Sprite:getClipRect()
    return self._clipRect
end

---
--- @param  rect  chip.math.Rect
---
function Sprite:setClipRect(rect)
    self._clipRect = rect
end

---
--- Updates this sprite.
---
function Sprite:update(dt)
    if self._moves then
        local v = self.velocity
        if v.x ~= 0 or v.y ~= 0 then
            local x = self._x
            local y = self._y
    
            local ax = self.acceleration.x
            local ay = self.acceleration.y
    
            local dvx, dvy = Velocity.getVelocityDelta(v.x, v.y, ax, ay, dt)
            self._x = x + ((v.x + dvx) * dt)
            self._y = y + ((v.y + dvy) * dt)
    
            v.x = v.x + (dvx * 2.0)
            v.y = v.y + (dvy * 2.0)
        end
    end
    self.animation:update(dt)
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
        self:setX((Engine.gameWidth - self:getFrameWidth()) * 0.5)
    end
    if axes:contains("y") then
        self:setY((Engine.gameHeight - self:getFrameHeight()) * 0.5)
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
    -- TODO: separate the transform updating into it's own function
    local frames, frame = self:getFrames(), self:getFrame()
    local frameWidth, frameHeight = self:getFrameWidth(), self:getFrameHeight()
    
    if not frames or not frame or not frame.texture then
        return nil, 0, 0, 0, 0, nil
    end
    local curAnim = self.animation:getCurrentAnimation()

    local ofx, ofy = abs(self.origin.x * frame.width), abs(self.origin.y * frame.height)
    local ofx2, ofy2 = abs(self.origin.x * frameWidth), abs(self.origin.y * frameHeight)
    
    if trans then
        trans:reset()
    
        local rx, ry = self._x - self.offset.x, self._y - self.offset.y
        
        local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.flipX and -1 or 1)
        local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.flipY and -1 or 1)
    
        local p = self._parent
    
        local canvases = {} --- @type table<chip.graphics.CanvasLayer>
    
        local canvasCount = 0
        local isOnCanvasLayer = false
    
        while p do
            if p:is(CanvasLayer) then
                if not p:is(Scene) then
                    isOnCanvasLayer = true
                end
                tblInsert(canvases, p)
                canvasCount = canvasCount + 1
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
        local sx = self.scale.x
        local sy = self.scale.y
    
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
        for i = 1, canvasCount do
            local canvas = canvases[canvasCount - i + 1] --- @type chip.graphics.CanvasLayer
            trans:translate(canvas:getX(), canvas:getY())
            trans:scale(canvas.scale.x, canvas.scale.y)
            trans:rotate(canvas.rotation)
        end
        -- TODO: resulting rect is slightly off
        -- when frame offset is more than 0 and the sprite is flipped

        trans:translate(rx, ry)

        trans:translate(ofx2, ofy2)
        trans:scale(abs(sx), abs(sy))
        
        trans:rotate(self._rotation)
        trans:translate(
            -(frame.offset.x * (sx < 0.0 and -1 or 1) * (self.flipX and -1 or 1)),
            -(frame.offset.y * (sy < 0.0 and -1 or 1) * (self.flipY and -1 or 1))
        )
        trans:translate(offx, offy)
        trans:translate(-ofx2, -ofy2)
    end
    local ot = trans
    if not trans then
        trans = self._transform
    end
    local v1, v2, _, rx, v5, v6, _, ry, v9, v10 = trans:getMatrix()
    
    local rw = frame.width * sqrt((v1 * v1) + (v5 * v5) + (v9 * v9))
    local rh = frame.height * sqrt((v2 * v2) + (v6 * v6) + (v10 * v10))
    local rotation = atan2(v5, v1) -- this is in radians
    
    local rect = self._rect:set(rx, ry, rw, rh) --- @type chip.math.Rect
    rect:getRotatedBounds(rotation, nil, rect)
   
    trans = ot
    if trans then
        if self.scale.x < 0.0 then
            trans:translate(ofx2, 0)
            trans:scale(-1, 1)
            trans:translate(-ofx2, 0)
        end
        if self.flipX then
            trans:translate(ofx2, 0)
            trans:scale(-1, 1)
            trans:translate(-ofx2, 0)
        end
        if self.scale.y < 0.0 then
            trans:translate(0, ofy2)
            trans:scale(1, -1)
            trans:translate(0, -ofy2)
        end
        if self.flipY then
            trans:translate(0, ofy2)
            trans:scale(1, -1)
            trans:translate(0, -ofy2)
        end
    end
    return trans, rx, ry, rw, rh, frame
end

---
--- Draws this sprite to the screen.
---
function Sprite:draw()
    local trans, _, _, _, _, frame = self:getRenderingInfo(self._transform)
    if not frame or not self:isOnScreen() then
        return
    end
    local pr, pg, pb, pa = gfxGetColor()
    gfxSetColor(self._tint.r, self._tint.g, self._tint.b, self._alpha)

    local filter = self._antialiasing and _linear_ or _nearest_
    local img = frame.texture:getImage(filter)
    
    if self._clipRect then
		stencilSprite = self
        gfxClear(false, true, false)

        gfxSetStencilState("replace", "always", 1)
        gfxSetColorMask(false)

        stencil()

        gfxSetStencilState("keep", "greater", 0)
        gfxSetColorMask(true)
	end
    gfxDraw(
        img, frame.quad, -- What's actually drawn to the screen
        trans -- Transformation to apply to the sprite
    )
    if self._clipRect then
        gfxClear(false, true, false)
		gfxSetStencilState()
	end
    gfxSetColor(pr, pg, pb, pa)
end

function Sprite:getFrameWidth()
    local curAnim = self.animation:getCurrentAnimation()
    if curAnim then
        local firstFrame = curAnim.frames[1]
        return firstFrame.width
    end
    local frame = self:getFrame()
    return frame and frame.width or 0.0
end

function Sprite:getWidth()
    return self:getFrameWidth() * abs(self.scale.x)
end

function Sprite:getFrameHeight()
    local curAnim = self.animation:getCurrentAnimation()
    if curAnim then
        local firstFrame = curAnim.frames[1]
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