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
local clamp = math.clamp

---
--- @class chip.graphics.ProgressBar : chip.graphics.Sprite
--- 
--- A simple class for creating rectangular progress bars.
---
local ProgressBar = Sprite:extend("ProgressBar", ...)

function ProgressBar:constructor(x, y)
    ProgressBar.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._shape = "rectangle" --- @type "rectangle"|"circle"

    ---
    --- @protected
    ---
    self._fillDirection = "left_to_right" --- @type "left_to_right"|"right_to_left"|"top_to_bottom"|"bottom_to_top"

    ---
    --- @protected
    ---
    self._barWidth = 100.0 --- @type number

    ---
    --- @protected
    ---
    self._barHeight = 20.0 --- @type number

    ---
    --- @protected
    ---
    self._minValue = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._maxValue = 1.0 --- @type number

    ---
    --- @protected
    ---
    self._value = 0.5 --- @type number

    ---
    --- @protected
    ---
    self._emptyColor = Color.BLACK --- @type chip.utils.Color

    ---
    --- @protected
    ---
    self._fillColor = Color.WHITE --- @type chip.utils.Color

    ---
    --- @protected
    ---
    self._dirty = true --- @type boolean

    ---
    --- @protected
    ---
    self._canvas = nil --- @type love.Canvas

    local tex = Texture:new() --- @type chip.graphics.Texture
    
    local imgData = love.image.newImageData(1, 1)
    tex:setImage(gfx.newImage(imgData), imgData)

    self:loadTexture(tex)
end

function ProgressBar:getShape()
    return self._shape
end

---
--- @param  shape  "rectangle"|"circle"
--- 
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setShape(shape)
    self._shape = shape
    self._dirty = self._dirty or (self._shape ~= shape)
    return self
end

function ProgressBar:getFillDirection()
    return self._fillDirection
end

---
--- @param  fillDirection  "left_to_right"|"right_to_left"|"top_to_bottom"|"bottom_to_top"
--- 
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setFillDirection(fillDirection)
    self._dirty = self._dirty or (self._fillDirection ~= fillDirection)
    self._fillDirection = fillDirection
    return self
end

function ProgressBar:getBarWidth()
    return self._barWidth
end

function ProgressBar:getBarHeight()
    return self._barHeight
end

---
--- @param  width   number
--- @param  height  number
---
--- @return chip.graphics.ProgressBar
---
function ProgressBar:resize(width, height)
    self._dirty = self._dirty or (self._barWidth ~= width or self._barHeight ~= height)
    self._barWidth = width
    self._barHeight = height
    return self
end

---
--- @return number  min  The minimum value that this progress bar can go-to.
--- @return number  max  The maximum value that this progress bar can go-to.
---
function ProgressBar:getBounds()
    return self._minValue, self._maxValue
end

---
--- @param  min  number
--- @param  max  number
---
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setBounds(min, max)
    self._dirty = self._dirty or (self._minValue ~= min or self._maxValue ~= max)
    self._minValue = min
    self._maxValue = max
    self._value = clamp(self._value, min, max)
    return self
end

function ProgressBar:getValue()
    return self._value
end

---
--- @return  number  progress  The total progress value of the bar. (from 0.0 to 1.0)
---
function ProgressBar:getProgress()
    return self._value / self._maxValue
end

---
--- @param  value  number  The new value of the bar.
---
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setValue(value)
    local newValue = clamp(value, self._minValue, self._maxValue)
    self._dirty = self._dirty or (self._value ~= newValue)
    
    self._value = newValue
    return self
end

function ProgressBar:getEmptyColor()
    return self._emptyColor
end

function ProgressBar:getFillColor()
    return self._fillColor
end

---
--- @param  empty  chip.utils.Color|integer
--- @param  fill   chip.utils.Color|integer
---
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setColors(empty, fill)
    empty = Color:new(empty)
    fill = Color:new(fill)

    self._dirty = self._dirty or (self._emptyColor.r ~= empty.r and self._emptyColor.g ~= empty.g and self._emptyColor.b ~= empty.b and self._emptyColor.a ~= empty.a) or (self._fillColor.r ~= fill.r and self._fillColor.g ~= fill.g and self._fillColor.b ~= fill.b and self._fillColor.a ~= fill.a)
     
    self._emptyColor = empty
    self._fillColor = fill

    return self
end

function ProgressBar:getFrames()
    self:_regenTexture()
    return ProgressBar.super.getFrames(self)
end

function ProgressBar:getFrameWidth()
    self:_regenTexture()
    return ProgressBar.super.getFrameWidth(self)
end

function ProgressBar:getFrameHeight()
    self:_regenTexture()
    return ProgressBar.super.getFrameHeight(self)
end

function ProgressBar:getFrame()
    self:_regenTexture()
    return ProgressBar.super.getFrame(self)
end

function ProgressBar:draw()
    self:_regenTexture()
    return ProgressBar.super.draw(self)
end

function ProgressBar:draw()
    self:_regenTexture()
    ProgressBar.super.draw(self)
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function ProgressBar:_regenTexture()
    if not self._dirty then
        return
    end
    self._dirty = false
    
    if self._canvas and (self._canvas:getWidth() ~= self._barWidth or self._canvas:getHeight() ~= self._barHeight) then
        self._canvas:release()
    end
    local shape = self._shape
    self._canvas = gfx.newCanvas(self._barWidth, self._barHeight)

    local prevCanvas = gfx.getCanvas()
    gfx.setCanvas(self._canvas)

    local pr, pg, pb, pa = gfx.getColor()
    gfx.push()
    gfx.origin()

    local sx, sy, sw, sh = gfx.getScissor()
    gfx.setScissor()

    if shape == "rectangle" then
        gfx.setColor(self._emptyColor.r, self._emptyColor.g, self._emptyColor.b, self._emptyColor.a)
        gfx.rectangle("fill", 0, 0, self._barWidth, self._barHeight)
    
        gfx.setColor(self._fillColor.r, self._fillColor.g, self._fillColor.b, self._fillColor.a)
        
        local barWidth = self._barWidth
        local barHeight = self._barHeight

        local fillWidth = barWidth * self:getProgress()
        local fillHeight = barHeight * self:getProgress()

        if self._fillDirection == "left_to_right" then
            gfx.rectangle("fill", 0, 0, fillWidth, self._barHeight)
        
        elseif self._fillDirection == "right_to_left" then
            gfx.rectangle("fill", barWidth - fillWidth, 0, fillWidth, self._barHeight)

        elseif self._fillDirection == "top_to_bottom" then
            gfx.rectangle("fill", 0, 0, barWidth, fillHeight)
        
        elseif self._fillDirection == "bottom_to_top" then
            gfx.rectangle("fill", 0, barHeight - fillHeight, barWidth, fillHeight)
        end
        
    elseif shape == "circle" then
        gfx.setColor(self._emptyColor.r, self._emptyColor.g, self._emptyColor.b, self._emptyColor.a)
        
        local barWidth = self._barWidth
        local barHeight = self._barHeight
        
        if barWidth > barHeight then
            gfx.push()
            gfx.scale(1, barHeight / barWidth)
            
            gfx.arc("fill", 0, 0, barWidth, 0, math.pi * self:getProgress() * 2)
            gfx.pop()
        else
            gfx.push()
            gfx.scale(barWidth / barHeight, 1)
            
            gfx.arc("fill", 0, 0, barHeight, 0, math.pi * self:getProgress() * 2)
            gfx.pop()
        end
    end
    gfx.setScissor(sx, sy, sw, sh)
    gfx.setColor(pr, pg, pb, pa)

    gfx.pop()
    gfx.setCanvas(prevCanvas)

    ---
    --- @type chip.graphics.Texture?
    ---
    local tex = self:getTexture()
    local imgData = gfx.readbackTexture(self._canvas)

    local img = gfx.newImage(imgData)
    tex:setImage(img, imgData)

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

return ProgressBar