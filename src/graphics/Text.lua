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

local gfxClear = gfx.clear
local gfxDraw = gfx.draw

local gfxPush = gfx.push
local gfxOrigin = gfx.origin
local gfxPop = gfx.pop
local gfxApplyTransform = gfx.applyTransform
local gfxTranslate = gfx.translate
local gfxRotate = gfx.rotate
local gfxRectangle = gfx.rectangle

local gfxSetStencilState = gfx.setStencilState
local gfxSetColorMask = gfx.setColorMask

local _linear_, _nearest_ = "linear", "nearest"
local FrameData = crequire("animation.frames.FrameData") --- @type chip.animation.frames.FrameData

local stencilSprite = nil
local function stencil()
	if stencilSprite then
		gfxPush()
        gfxApplyTransform(stencilSprite._transform)
		gfxTranslate(
            stencilSprite._clipRect.x + stencilSprite._clipRect.width * 0.5,
			stencilSprite._clipRect.y + stencilSprite._clipRect.height * 0.5
        )
		gfxRotate(stencilSprite._rotation)
		gfxTranslate(
            -stencilSprite._clipRect.width * 0.5,
			-stencilSprite._clipRect.height * 0.5
        )
		gfxRectangle("fill", 0, 0, stencilSprite._clipRect.width, stencilSprite._clipRect.height)
		gfxPop()
	end
end
local function getFontPath(name)
    return Chip.classPath .. "/assets/fonts/" .. name
end

---
--- @class chip.graphics.Text : chip.graphics.Sprite
---
local Text = Sprite:extend("Text", ...)

function Text:constructor(x, y, fieldWidth, contents, size)
    Text.super.constructor(self, x, y)

    ---
    --- @type chip.math.Point
    ---
    self.shadowOffset = Point:new(0, 0)

    ---
    --- @protected
    --- @type string
    ---
    self._font = nil

    ---
    --- @protected
    --- @type love.Font
    ---
    self._fontData = nil
    
    ---
    --- @protected
    --- @type string
    ---
    self._contents = contents
    
    ---
    --- @protected
    --- @type integer
    ---
    self._fieldWidth = fieldWidth or 0

    ---
    --- @protected
    --- @type integer
    ---
    self._size = size or 16

    ---
    --- @protected
    --- @type "left"|"center"|"right"|"justify"
    ---
    self._alignment = "left"

    ---
    --- @protected
    --- @type number
    ---
    self._borderSize = 0

    ---
    --- @protected
    --- @type integer
    ---
    self._borderPrecision = 8

    ---
    --- @protected
    --- @type "outline"|"shadow"
    ---
    self._borderStyle = "outline"

    ---
    --- @protected
    --- @type chip.utils.Color
    ---
    self._borderColor = Color:new(Color.BLACK)

    ---
    --- @protected
    --- @type chip.utils.Color
    ---
    self._color = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type love.Text?
    ---
    self._textObj = nil

    ---
    --- @protected
    --- @type boolean
    ---
    self._fastRendering = true

    ---
    --- @protected
    --- @type boolean
    ---
    self._dirty = false -- this only matters for slow rendering

    ---
    --- @protected
    --- @type love.Canvas?
    ---
    self._canvas = nil -- this only matters for slow rendering

    local tex = Texture:new() --- @type chip.graphics.Texture
    tex:setImage(love.image.newImageData(1, 1))

    self:loadTexture(tex)
    self:setFrame(FrameData:new("#_TEXT_", 0, 0, 0, 0, 16, 16, tex))

    self:setFont(getFontPath("nokiafc22.ttf"))
    self:setContents(contents or "")
end

---
--- @return string
---
function Text:getFont()
    return self._font
end

---
--- @param  font  string
---
function Text:setFont(font)
    if self._font ~= font then
        local fnt = Assets.getFont(font):getData(self._size)
        if not fnt then
            fnt = gfx.newFont(font, self._size, "light")
            Assets.getFont(font):setData(self._size, fnt)
        end
        self._fontData = fnt
    
        if self._textObj then
            self._textObj:setFont(self._fontData)
        else
            self._textObj = gfx.newTextBatch(self._fontData)
        end
        self._font = font
        if not self:isFastRendering() then
            self._dirty = true
        end
    end
    self:setContents(self._contents or "")
end

---
--- @return string
---
function Text:getContents()
    return self._contents
end

---
--- @param  contents  string
---
function Text:setContents(contents)
    self._contents = contents
    local alignment = self._alignment
    if not self._contents:contains("\n") then
        alignment = "left"
    end
    if not self._textObj and self._fontData then
        self._textObj = gfx.newTextBatch(self._fontData)
    end
    if self._textObj then
        if self._fieldWidth > 0 then
            self._textObj:setf(self._contents, self._fieldWidth, alignment)
        else
            self._textObj:setf(self._contents, self._fontData:getWidth(self._contents), alignment)
        end
    end
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getFieldWidth()
    return self._fieldWidth
end

---
--- @param  width  number
---
function Text:setFieldWidth(width)
    self._fieldWidth = width
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getSize()
    return self._size
end

---
--- @param  size  integer
---
function Text:setSize(size)
    if self._size ~= size then
        if self._font then
            local fnt = Assets.getFont(self._font):getData(size)
            if not fnt then
                fnt = gfx.newFont(self._font, size, "light")
                Assets.getFont(self._font):setData(size, fnt)
            end
            self._fontData = fnt
            if self._textObj then
                self._textObj:setFont(self._fontData)
            else
                self._textObj = gfx.newTextBatch(self._fontData)
            end
        end
        self._size = size
    end
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getAlignment()
    return self._alignment
end

---
--- @param  alignment  "left"|"center"|"right"|"justify"
---
function Text:setAlignment(alignment)
    self._alignment = alignment
    if not self._contents:contains("\n") then
        alignment = "left"
    end
    if not self._textObj and self._fontData then
        self._textObj = gfx.newTextBatch(self._fontData)
    end
    if self._textObj then
        if self._fieldWidth > 0 then
            self._textObj:setf(self._contents, self._fieldWidth, alignment)
        else
            self._textObj:setf(self._contents, math.huge, alignment)
        end
    end
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getBorderSize()
    return self._borderSize
end

---
--- @param  size  number
---
function Text:setBorderSize(size)
    self._borderSize = size
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getBorderPrecision()
    return self._borderPrecision
end

---
--- @param  precision  number
---
function Text:setBorderPrecision(precision)
    self._borderPrecision = precision
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getBorderStyle()
    return self._borderStyle
end

---
--- @param  style  "outline"|"shadow"
---
function Text:setBorderStyle(style)
    self._borderStyle = style
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getBorderColor()
    return self._borderColor
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setBorderColor(color)
    self._borderColor = Color:new(color)
    if not self:isFastRendering() then
        self._dirty = true
    end
end

function Text:getColor()
    return self._color
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setColor(color)
    self._color = Color:new(color)
    if not self:isFastRendering() then
        self._dirty = true
    end
end

---
--- Returns whether or not fast rendering is enabled.
--- 
--- If your text *doesn't* change very often, then you
--- can disable this without much performance cost.
--- 
--- If fast rendering is left enabled, setting the alpha
--- value of the text may not affect the border correctly.
---
function Text:isFastRendering()
    return self._fastRendering
end

---
--- @param  fastRendering  boolean
---
function Text:setFastRendering(fastRendering)
    self._fastRendering = fastRendering
    self._dirty = not fastRendering

    if fastRendering and self._canvas then
        self._canvas:release()
        self._canvas = nil
    end
end

function Text:getFrame()
    -- this is very dumb and hacky
    -- do i give a shit?                    no
    local frame = self._frame
    frame.width = self:getFrameWidth()
    frame.height = self:getFrameHeight()
    return frame
end

function Text:getFrameWidth()
    local padding = math.floor(self._borderSize) + 2
    return self._textObj:getWidth() + padding + (self._borderStyle == "shadow" and self.shadowOffset.x or 0.0)
end

function Text:getFrameHeight()
    local padding = math.floor(self._borderSize) + 2
    return self._textObj:getHeight() + padding + (self._borderStyle == "shadow" and self.shadowOffset.y or 0.0)
end

---
--- Draws this sprite to the screen.
---
function Text:draw()
    local trans, _, _, _, _, frame = self:getRenderingInfo(self._transform)
    if not frame or not self:isOnScreen() then
        return
    end
    if self:isFastRendering() then
        self:_fastRender(trans)
    else
        if self._dirty then
            self:_regenTexture()
        end
        self:_slowRender()
    end
end

function Text:free()
    if self._textObj then
        self._textObj:release()
        self._textObj = nil
    end
    if self._canvas then
        self._canvas:release()
        self._canvas = nil
    end
    Text.super.free(self)
end

--- [ PRIVATE API ] ---

---
--- @protected
--- @param  trans  love.Transform
---
function Text:_fastRender(trans)
    local pr, pg, pb, pa = gfxGetColor()
    if self._clipRect then
        stencilSprite = self
        gfxClear(false, true, false)

        gfxSetStencilState("replace", "always", 1)
        gfxSetColorMask(false)

        stencil()

        gfxSetStencilState("keep", "greater", 0)
        gfxSetColorMask(true)
    end
    local tint = self._tint
    local padding = math.floor(self._borderSize) + 2
    
    local tx, ty = padding * 0.5, padding * 0.5
    trans:translate(tx, ty)

    local filter = self._antialiasing and _linear_ or _nearest_
    self._fontData:setFilter(filter, filter, 4)

    local alignment = self._alignment
    if not self._contents:contains("\n") then
        alignment = "left"
    end
    if self._textObj then
        if self._fieldWidth > 0 then
            self._textObj:setf(self._contents, self._fieldWidth, alignment)
        else
            self._textObj:setf(self._contents, self._fontData:getWidth(self._contents), alignment)
        end
    end
    if self._borderSize > 0 and self._borderColor.a > 0 then
        if self._borderStyle == "outline" then
            gfxSetColor(self._borderColor.r * tint.r, self._borderColor.g * tint.g, self._borderColor.b * tint.b, self._borderColor.a * self._alpha)
            
            local step = (2 * math.pi) / self._borderPrecision
            for i = 1, self._borderPrecision do
                local dx = math.cos(i * step) * self._borderSize
                local dy = math.sin(i * step) * self._borderSize

                local fdx, fdy = math.round(dx), math.round(dy)
                trans:translate(fdx, fdy)
                gfxDraw(self._textObj, trans)
                trans:translate(-fdx, -fdy)
            end

        elseif self.borderStyle == "shadow" then
            gfxSetColor(self._borderColor.r * tint.r, self._borderColor.g * tint.g, self._borderColor.b * tint.b, self._borderColor.a * self._alpha)

            trans:translate(self.shadowOffset.x * self.borderSize, self.shadowOffset.y * self.borderSize)
            gfxDraw(self._textObj, trans)
            trans:translate(-self.shadowOffset.x * self.borderSize, -self.shadowOffset.y * self.borderSize)
        end
    end
    gfxSetColor(self._color.r * tint.r, self._color.g * tint.g, self._color.b * tint.b, self._color.a * self._alpha)
    gfxDraw(self._textObj, trans)

    if self._clipRect then
        gfxClear(false, true, false)
        gfxSetStencilState()
    end
    gfxSetColor(pr, pg, pb, pa)
end

---
--- @protected
--- @param  trans  love.Transform
---
function Text:_slowRender()
    Text.super.draw(self)
end

---
--- @protected
---
function Text:_regenTexture()
    if not self._dirty then
        return
    end
    self._dirty = false

    if self._canvas then
        self._canvas:release()
        self._canvas = nil
    end
    local trans = self._transform
    local oldTrans = self._transform:clone()
    
    local tr, tg, tb, a, cr = self._tint.r, self._tint.g, self._tint.b, self._alpha, self._clipRect
    self._tint.r, self._tint.g, self._tint.b, self._alpha, self._clipRect = 1, 1, 1, 1, nil

    local prevCanvas = gfx.getCanvas()
    self._canvas = gfx.newCanvas(self:getFrameWidth(), self:getFrameHeight())
    gfx.setCanvas(self._canvas)

    gfxPush()
    gfxOrigin()

    local sx, sy, sw, sh = gfx.getScissor()
    gfx.setScissor()

    trans:reset()
    self:_fastRender(trans) -- what if i     cheat
    self._tint.r, self._tint.g, self._tint.b, self._alpha, self._clipRect = tr, tg, tb, a, cr

    trans:setMatrix(oldTrans:getMatrix())
    gfx.setCanvas(prevCanvas)

    gfx.setScissor(sx, sy, sw, sh)
    gfxPop()

    local texture = self:getTexture()
    texture:setImage(gfx.readbackTexture(self._canvas))

    local frame = self:getFrame()
    frame.width = texture.width
    frame.height = texture.height
    frame.quad:setViewport(0, 0, texture.width, texture.height, texture.width, texture.height)
end

return Text