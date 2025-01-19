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

local gfxGetColor = gfx.getColor
local gfxSetColor = gfx.setColor
local gfxDraw = gfx.draw

local gfxGetShader = gfx.getShader
local gfxSetShader = gfx.setShader

local tblInsert = table.insert

local _linear_, _nearest_ = "linear", "nearest"

local sqrt = math.sqrt
local abs = math.abs
local atan2 = math.atan2
local ceil = math.ceil
local lerp = math.lerp

local vertexFormat = {
    {format = "floatvec3", offset = 0,  arraylength = 0, location = 0},
    {format = "floatvec2", offset = 12, arraylength = 0, location = 1}
}

---
--- @class chip.graphics.TiledSprite : chip.graphics.Sprite
--- 
--- A simple class for creating repeatedly tiling sprites.
--- 
--- This is different from backdrops in the fact that it doesn't
--- include velocity or
---
local TiledSprite = Sprite:extend("TiledSprite", ...)

function TiledSprite:constructor(x, y)
    TiledSprite.super.constructor(self, x, y)

    local triangles = {}
    local tri = {0, 0, 0, 0, 0, 0}
    for _ = 1, 100000 do
        tblInsert(triangles, tri)
    end

    ---
    --- @protected
    ---
    self._mesh = gfx.newMesh(vertexFormat, triangles, "triangles", "stream") --- @type love.Mesh

    ---
    --- @protected
    ---
    self._horizontalLength = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._verticalLength = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._horizontalPadding = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._verticalPadding = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._horizontalRepeat = true --- @type boolean

    ---
    --- @protected
    ---
    self._verticalRepeat = true --- @type boolean
end

function TiledSprite:getHorizontalLength()
    return self._horizontalRepeat and self._horizontalLength or self:getWidth()
end

function TiledSprite:getVerticalLength()
    return self._verticalRepeat and self._verticalLength or self:getHeight()
end

function TiledSprite:getHorizontalPadding()
    return self._horizontalPadding
end

function TiledSprite:getVerticalPadding()
    return self._verticalPadding
end

function TiledSprite:isHorizontallyRepeating()
    return self._horizontalRepeat
end

function TiledSprite:isVerticallyRepeating()
    return self._verticalRepeat
end

---
--- @param  value  number  The horizontal length of the sprite.
---
function TiledSprite:setHorizontalLength(value)
    self._horizontalLength = value
end

---
--- @param  value  number  The vertical length of the sprite.
---
function TiledSprite:setVerticalLength(value)
    self._verticalLength = value
end

---
--- @param  value  number  How much pixels of padding is added to the UV horizontally.
---
function TiledSprite:setHorizontalPadding(value)
    self._horizontalLength = value
end

---
--- @param  value  number  How much pixels of padding is added to the UV vertically.
---
function TiledSprite:setVerticalPadding(value)
    self._verticalPadding = value
end

---
--- @param  value  boolean  Whether or not the sprite can repeat itself horizontally.
---
function TiledSprite:setHorizontalRepeat(value)
    self._horizontalRepeat = value
end

---
--- @param  value  boolean  Whether or not the sprite can repeat itself vertically.
---
function TiledSprite:setVerticalRepeat(value)
    self._verticalRepeat = value
end

function TiledSprite:update(dt)
    TiledSprite.super.update(self, dt)
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
function TiledSprite:getRenderingInfo(trans)
    local frames, frame = self._frames, self._frame

    local width, height = self:getWidth(), self:getHeight()
    local frameWidth, frameHeight = self:getFrameWidth(), self:getFrameHeight()
    
    if not frames or not frame or not frame.texture then
        return nil, 0, 0, 0, 0, nil
    end
    local curAnim = self.animation:getCurrentAnimation()

    local ox, oy = self.origin.x * (self._horizontalRepeat and self._horizontalLength * self.scale.x or width), self.origin.y * (self._verticalRepeat and self._verticalLength * self.scale.y or height)
    local ofx, ofy = self.origin.x * (self._horizontalRepeat and self._horizontalLength or frameWidth), self.origin.y * (self._verticalRepeat and self._verticalLength or frameHeight)
    local ofx2, ofy2 = self.origin.x * frameWidth, self.origin.y * frameHeight

    trans = trans or lmath.newTransform()
    trans:reset()

    local rx, ry = self._x - self.offset.x, self._y - self.offset.y
    
    local offx = ((curAnim and curAnim.offset.x or 0.0) - self.frameOffset.x) * (self.flipX and -1 or 1)
    local offy = ((curAnim and curAnim.offset.y or 0.0) - self.frameOffset.y) * (self.flipY and -1 or 1)

    offx = offx - frame.offset.x
    offy = offy - frame.offset.y

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
            trans:rotate(cam:getRotation())
            trans:translate(-w2, -h2)
        end
    end
    for i = 1, canvasCount do
        local canvas = canvases[canvasCount - i + 1] --- @type chip.graphics.CanvasLayer
        trans:translate(canvas:getX(), canvas:getY())
        trans:scale(canvas.scale.x, canvas.scale.y)
        trans:rotate(canvas.rotation)
    end
    trans:translate(rx, ry)

    trans:translate(ox, oy)
    trans:rotate(self._rotation)
    trans:translate(-ox, -oy)
    
    trans:translate(ofx2, ofy2)
    trans:scale(abs(sx), abs(sy))
    trans:translate(offx, offy)
    trans:translate(-ofx2, -ofy2)

    local v1, v2, _, rx, v5, v6, _, ry, v9, v10 = trans:getMatrix()

    local rw = (self._horizontalRepeat and self._horizontalLength or frameWidth) * sqrt((v1 * v1) + (v5 * v5) + (v9 * v9))
    local rh = (self._verticalRepeat and self._verticalLength or frameHeight) * sqrt((v2 * v2) + (v6 * v6) + (v10 * v10))
    local rotation = atan2(v5, v1) -- this is in radians

    local rect = self._rect:set(rx, ry, rw, rh) --- @type chip.math.Rect
    rect:getRotatedBounds(rotation, nil, rect)

    if self.scale.x < 0.0 then
        trans:translate(ofx2, 0)
        trans:scale(-1, 1)
        trans:translate(-ofx2, 0)
    end
    if self.flipX then
        trans:translate(ofx, 0)
        trans:scale(-1, 1)
        trans:translate(-ofx, 0)
    end
    if self.scale.y < 0.0 then
        trans:translate(0, ofy2)
        trans:scale(1, -1)
        trans:translate(0, -ofy2)
    end
    if self.flipY then
        trans:translate(0, ofy)
        trans:scale(1, -1)
        trans:translate(0, -ofy)
    end
    return trans, rect.x, rect.y, rect.width, rect.height, frame
end

---
--- @param  frame   chip.animation.frames.FrameData
--- @param  hTiles  integer
--- @param  vTiles  integer
--- 
--- @return table
---
function TiledSprite:calculateVertices(frame, hTiles, vTiles)
    local vertices = {}

    local roundHTiles = self._horizontalRepeat and (ceil(hTiles) - 1) or 1
    local roundVTiles = self._verticalRepeat and (ceil(vTiles) - 1) or 1

    local uvOffsetX = self._horizontalPadding / frame.texture.width
    local uvOffsetY = self._verticalPadding / frame.texture.height
    
    local rightMult = 1.0
    local uvLeft, uvRight = frame:getUVX() + uvOffsetX, frame:getUVX() + frame:getUVWidth() - uvOffsetX
    for x = 0, roundHTiles do
        if x == roundHTiles and hTiles ~= (roundHTiles + 1) then
            rightMult = hTiles % 1
            uvRight = lerp(uvLeft, uvRight, rightMult)
        end
        local bottomMult = 1.0
        local uvTop, uvBottom = frame:getUVY() + uvOffsetY, frame:getUVY() + frame:getUVHeight() - uvOffsetY
        for y = 0, roundVTiles do
            if y == roundVTiles and hTiles ~= (roundVTiles + 1) then
                bottomMult = vTiles % 1
                uvBottom = lerp(uvTop, uvBottom, bottomMult)
            end
            table.insert(vertices, {
                x * frame.width, frame.height * y, 1,
                uvLeft, uvTop
            })
            table.insert(vertices, {
                (x * frame.width) + frame.width * rightMult, frame.height * y, 1,
                uvRight, uvTop
            })
            table.insert(vertices, {
                x * frame.width, frame.height * bottomMult + (frame.height * y), 1,
                uvLeft, uvBottom
            })
            table.insert(vertices, {
                x * frame.width, frame.height * bottomMult + (frame.height * y), 1,
                uvLeft, uvBottom
            })
            table.insert(vertices, {
                (x * frame.width) + frame.width * rightMult, frame.height * bottomMult + (frame.height * y), 1,
                uvRight, uvBottom
            })
            table.insert(vertices, {
                (x * frame.width) + frame.width * rightMult, frame.height * y, 1,
                uvRight, uvTop
            })
        end
    end
    return vertices
end

---
--- Draws this sprite to the screen.
---
function TiledSprite:draw()
    local trans, _, _, _, _, frame = self:getRenderingInfo(self._transform)
    if not frame or self._rect.width <= 0 or self._rect.height <= 0 or not self:isOnScreen() then
        return
    end
    local pr, pg, pb, pa = gfxGetColor()
    gfxSetColor(self._tint.r, self._tint.g, self._tint.b, self._alpha)

    local filter = self._antialiasing and _linear_ or _nearest_
    local img = frame.texture:getImage(filter)
    
    local vertices = self:calculateVertices(frame, self._horizontalLength / frame.width, self._verticalLength / frame.height)
    
    local mesh = self._mesh
    mesh:setDrawRange(1, #vertices)
    mesh:setVertices(vertices)
    mesh:setTexture(img)

    local prevShader = gfxGetShader()
    if self._shader then
        gfxSetShader(self._shader:getData())
    end
    gfxDraw(
        mesh, -- What's actually drawn to the screen
        trans -- Transformation to apply to the sprite
    )
    gfxSetShader(prevShader)
    gfxSetColor(pr, pg, pb, pa)
end

function TiledSprite:free()
    if self._mesh then
        self._mesh:release()
        self._mesh = nil
    end
    TiledSprite.super.free(self)
end

return TiledSprite