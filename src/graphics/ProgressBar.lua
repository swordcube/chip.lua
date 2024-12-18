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

local gfxGetColor = gfx.getColor
local gfxSetColor = gfx.setColor

local gfxClear = gfx.clear
local gfxPush = gfx.push
local gfxPop = gfx.pop

local gfxApplyTransform = gfx.applyTransform
local gfxTranslate = gfx.translate
local gfxRotate = gfx.rotate
local gfxRectangle = gfx.rectangle

local gfxSetStencilState = gfx.setStencilState
local gfxSetColorMask = gfx.setColorMask

local clamp = math.clamp

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

---@diagnostic disable: invisible

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
    self._canvas = nil --- @type love.Canvas

    ---
    --- @protected
    ---
    self._numDivisions = 100 --- @type integer

    ---
    --- @protected
    ---
    self._shownValue = 0.0 --- @type number
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
    self._value = clamp(value, self._minValue, self._maxValue)
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
     
    self._emptyColor = empty
    self._fillColor = fill

    return self
end

function ProgressBar:getNumDivisions()
    return self._numDivisions
end

---
--- @param  divisions  integer
---
--- @return chip.graphics.ProgressBar
---
function ProgressBar:setNumDivisions(divisions)
    self._numDivisions = divisions
    return self
end

function ProgressBar:getFrameWidth()
    return self._barWidth
end

function ProgressBar:getFrameHeight()
    return self._barHeight
end

---
--- Draws this sprite to the screen.
---
function ProgressBar:draw()
    local trans, _, _, _, _, _ = self:getRenderingInfo(self._transform)
    if not self:isOnScreen() then
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
    gfxPush()
    gfxApplyTransform(trans)
    
    gfxSetColor(self._emptyColor.r, self._emptyColor.g, self._emptyColor.b, self._emptyColor.a)
    gfxRectangle("fill", 0, 0, self._barWidth, self._barHeight)

    gfxSetColor(self._fillColor.r, self._fillColor.g, self._fillColor.b, self._fillColor.a)
    
    local barWidth = self._barWidth
    local barHeight = self._barHeight

    local fillWidth = barWidth * self:getProgress()
    local fillHeight = barHeight * self:getProgress()

    if self._fillDirection == "left_to_right" then
        gfxRectangle("fill", 0, 0, fillWidth, self._barHeight)
    
    elseif self._fillDirection == "right_to_left" then
        gfxRectangle("fill", barWidth - fillWidth, 0, fillWidth, self._barHeight)

    elseif self._fillDirection == "top_to_bottom" then
        gfxRectangle("fill", 0, 0, barWidth, fillHeight)
    
    elseif self._fillDirection == "bottom_to_top" then
        gfxRectangle("fill", 0, barHeight - fillHeight, barWidth, fillHeight)
    end
    if self._clipRect then
        gfxClear(false, true, false)
		gfxSetStencilState()
	end
    gfxSetColor(pr, pg, pb, pa)
    gfxPop()
end

--- [ PRIVATE API ] ---

return ProgressBar