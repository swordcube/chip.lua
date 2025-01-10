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
    --- @type number
    ---
    self._borderQuality = 1

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

    self:setFrame(FrameData:new("#_TEXT_", 0, 0, 0, 0, 16, 16, self:getTexture()))
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
            self._textObj:setf(self._contents, math.huge, alignment)
        end
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
end

function Text:getBorderSize()
    return self._borderSize
end

---
--- @param  size  number
---
function Text:setBorderSize(size)
    self._borderSize = size
end

function Text:getBorderStyle()
    return self._borderStyle
end

---
--- @param  style  "outline"|"shadow"
---
function Text:setBorderStyle(style)
    self._borderStyle = style
end

function Text:getBorderColor()
    return self._borderColor
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setBorderColor(color)
    self._borderColor = Color:new(color)
end

function Text:getColor()
    return self._color
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setColor(color)
    self._color = Color:new(color)
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
    local pr, pg, pb, pa = gfxGetColor()
    gfxSetColor(self._tint.r, self._tint.g, self._tint.b, self._alpha)
    
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

    if self._borderSize > 0 and self._borderColor.a > 0 then
        if self._borderStyle == "outline" then
            local iterations = math.round(self._borderSize * self._borderQuality)
            if iterations < 1 then
                iterations = 1
            end
            
            local delta = self._borderSize / iterations
            local curDelta = delta
            
            gfxSetColor(self._borderColor.r * tint.r, self._borderColor.g * tint.g, self._borderColor.b * tint.b, self._borderColor.a * self._alpha)
            
            for _ = 1, iterations do
                -- upper-left
                trans:translate(-curDelta, -curDelta)
                gfxDraw(self._textObj, trans)
                
                -- upper-middle
                trans:translate(curDelta, 0)
                gfxDraw(self._textObj, trans)
                
                -- upper-right
                trans:translate(curDelta, 0)
                gfxDraw(self._textObj, trans)
                
                -- middle-right
                trans:translate(0, curDelta)
                gfxDraw(self._textObj, trans)
                
                -- lower-right
                trans:translate(0, curDelta)
                gfxDraw(self._textObj, trans)
                
                -- lower-middle
                trans:translate(-curDelta, 0)
                gfxDraw(self._textObj, trans)
                
                -- lower-left
                trans:translate(-curDelta, 0)
                gfxDraw(self._textObj, trans)
                
                trans:translate(0, -curDelta)
                gfxDraw(self._textObj, trans)
                
                trans:translate(curDelta, 0)
                curDelta = curDelta + delta
            end
            
        elseif self.borderStyle == "shadow" then
            gfxSetColor(self._borderColor.r * tint.r, self._borderColor.g * tint.g, self._borderColor.b * tint.b, self._borderColor.a * self._alpha)

            trans:translate(self.shadowOffset.x * self.borderSize, self.shadowOffset.y * self.borderSize)
            gfxDraw(self._textObj, trans)
            trans:translate(-self.shadowOffset.x * self.borderSize, -self.shadowOffset.y * self.borderSize)
        end
        gfxSetColor(self._color.r * tint.r, self._color.g * tint.g, self._color.b * tint.b, self._color.a * self._alpha)
    else
        gfxSetColor(self._color.r * tint.r, self._color.g * tint.g, self._color.b * tint.b, self._color.a * self._alpha)
    end
    gfxDraw(self._textObj, trans)

    if self._clipRect then
        gfxClear(false, true, false)
		gfxSetStencilState()
	end
    gfxSetColor(pr, pg, pb, pa)
end

function Text:free()
    if self._textObj then
        self._textObj:release()
        self._textObj = nil
    end
    Text.super.free(self)
end

return Text