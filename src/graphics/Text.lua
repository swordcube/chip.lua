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
    --- @type boolean
    ---
    self._dirty = true

    ---
    --- @protected
    --- @type love.Text?
    ---
    self._textObj = nil

    ---
    --- @protected
    --- @type love.Canvas?
    ---
    self._canvas = nil

    local tex = Texture:new() --- @type chip.graphics.Texture
    
    local imgData = love.image.newImageData(1, 1)
    tex:setImage(imgData)

    self:loadTexture(tex)
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
    self._font = font
    if self._dirty or (self._font ~= font) then
        local fnt = Assets.getFont(self._font):getData(self._size)
        if not fnt then
            fnt = gfx.newFont(self._font, self._size, "light")
            Assets.getFont(self._font):setData(self._size, fnt)
        end
        self._fontData = fnt
    
        if self._textObj then
            self._textObj:setFont(self._fontData)
        else
            self._textObj = gfx.newTextBatch(self._fontData)
        end
        self._dirty = true
    end
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
    self._dirty = self._dirty or (self._contents ~= contents)
    self._contents = contents
end

function Text:getFieldWidth()
    return self._fieldWidth
end

---
--- @param  width  number
---
function Text:setFieldWidth(width)
    self._dirty = self._dirty or (self._fieldWidth ~= width)
    self._fieldWidth = width
end

function Text:getSize()
    return self._size
end

---
--- @param  size  integer
---
function Text:setSize(size)
    self._size = size
    if self._dirty or (self._size ~= size) then
        if self._font then
            local fnt = Assets.getFont(self._font):getData(self._size)
            if not fnt then
                fnt = gfx.newFont(self._font, self._size, "light")
                Assets.getFont(self._font):setData(self._size, fnt)
            end
            self._fontData = fnt
            if self._textObj then
                self._textObj:setFont(self._fontData)
            else
                self._textObj = gfx.newTextBatch(self._fontData)
            end
        end
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
    self._dirty = self._dirty or (self._alignment ~= alignment)
    self._alignment = alignment
end

function Text:getBorderSize()
    return self._borderSize
end

---
--- @param  size  number
---
function Text:setBorderSize(size)
    self._dirty = self._dirty or (self._borderSize ~= size)
    self._borderSize = size
end

function Text:getBorderStyle()
    return self._borderStyle
end

---
--- @param  style  "outline"|"shadow"
---
function Text:setBorderStyle(style)
    self._dirty = self._dirty or (self._borderStyle ~= style)
    self._borderStyle = style
end

function Text:getBorderColor()
    return self._borderColor
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setBorderColor(color)
    self._dirty = self._dirty or (self._borderColor.r ~= color.r and self._borderColor.g ~= color.g and self._borderColor.b ~= color.b and self._borderColor.a ~= color.a)
    self._borderColor = Color:new(color)
end

function Text:getColor()
    return self._color
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setColor(color)
    self._dirty = self._dirty or (self._color.r ~= color.r and self._color.g ~= color.g and self._color.b ~= color.b and self._color.a ~= color.a)
    self._color = Color:new(color)
end

function Text:getFrames()
    self:_regenTexture()
    return Text.super.getFrames(self)
end

function Text:getFrameWidth()
    self:_regenTexture()
    return Text.super.getFrameWidth(self)
end

function Text:getFrameHeight()
    self:_regenTexture()
    return Text.super.getFrameHeight(self)
end

function Text:getFrame()
    self:_regenTexture()
    return Text.super.getFrame(self)
end

function Text:draw()
    self:_regenTexture()
    return Text.super.draw(self)
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Text:_regenTexture()
    if not self._dirty then
        return
    end
    if not self._font then
        return
    end
    self._dirty = false

    local alignment = self._alignment
    if not self._contents:contains("\n") then
        alignment = "left"
    end
    if self._fieldWidth > 0 then
        self._textObj:setf(self._contents, self._fieldWidth, alignment)
    else
        self._textObj:setf(self._contents, math.huge, alignment)
    end
    if self._canvas then
        self._canvas:release()
    end
    local padding = math.floor(self._borderSize) + 2
    self._canvas = gfx.newCanvas(
        self._textObj:getWidth() + padding + (self._borderStyle == "shadow" and self.shadowOffset.x or 0.0),
        self._textObj:getHeight() + padding + (self._borderStyle == "shadow" and self.shadowOffset.y or 0.0)
    )
    local prevCanvas = gfx.getCanvas()
    gfx.setCanvas(self._canvas)

    local tx, ty = padding * 0.5, padding * 0.5
    local pr, pg, pb, pa = gfx.getColor()

    local prevBlendMode, prevAlphaMode = gfx.getBlendMode()
    gfx.push()
    gfx.origin()

    local sx, sy, sw, sh = gfx.getScissor()
    gfx.setScissor()

    if self._borderSize > 0 and self._borderColor.a > 0 then
        gfx.setBlendMode("alpha", "premultiplied")
        if self._borderStyle == "outline" then
            local iterations = math.round(self._borderSize * self._borderQuality)
            if iterations < 1 then
                iterations = 1
            end
            
            local delta = self._borderSize / iterations
            local curDelta = delta
            
            gfx.setColor(self._borderColor.r, self._borderColor.g, self._borderColor.b, self._borderColor.a)
        
            for _ = 1, iterations do
                -- upper-left
                gfx.draw(self._textObj, tx - curDelta, ty - curDelta, 0)
                
                -- upper-middle
                gfx.draw(self._textObj, tx, ty - curDelta, 0)
        
                -- upper-right
                gfx.draw(self._textObj, tx + curDelta, ty - curDelta, 0)
        
                -- middle-right
                gfx.draw(self._textObj, tx + curDelta, ty, 0)
        
                -- lower-right
                gfx.draw(self._textObj, tx + curDelta, ty + curDelta, 0)
        
                -- lower-middle
                gfx.draw(self._textObj, tx, ty + curDelta, 0)
        
                -- lower-left
                gfx.draw(self._textObj, tx - curDelta, ty + curDelta, 0)
                
                curDelta = curDelta + delta
            end
            
        elseif self.borderStyle == "shadow" then
            gfx.setColor(self._borderColor.r, self._borderColor.g, self._borderColor.b, self._borderColor.a)
            gfx.draw(
                self._textObj,
                tx + (self.shadowOffset.x * self.borderSize), ty + (self.shadowOffset.y * self.borderSize), 0
            )
        end
        gfx.setBlendMode(prevBlendMode, prevAlphaMode)
        gfx.setColor(self._color.r, self._color.g, self._color.b, self._color.a)
    else
        gfx.setBlendMode("alpha", "premultiplied")
        gfx.setColor(self._color.r, self._color.g, self._color.b, self._color.a)
    end
    gfx.draw(self._textObj, tx, ty, 0)
    gfx.setColor(pr, pg, pb, pa)

    gfx.setBlendMode(prevBlendMode, prevAlphaMode)
    gfx.pop()

    gfx.setCanvas(prevCanvas)

    ---
    --- @type chip.graphics.Texture?
    ---
    local tex = self:getTexture()
    tex:setImage(gfx.readbackTexture(self._canvas))

    ---
    --- @type chip.animation.frames.FrameData
    ---
    local frame = self:getFrame()
    frame.width = tex.width
    frame.height = tex.height

    ---
    --- @type love.Quad
    ---
    local quad = frame.quad
    quad:setViewport(0, 0, tex.width, tex.height, tex.width, tex.height)
end

function Text:free()
    if self._canvas then
        self._canvas:release()
        self._canvas = nil
    end
    if self._textObj then
        self._textObj:release()
        self._textObj = nil
    end
    Text.super.free(self)
end

return Text