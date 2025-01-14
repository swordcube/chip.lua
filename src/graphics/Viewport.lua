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
local gfxRectangle = gfx.rectangle
local gfxGetScissor = gfx.getScissor
local gfxSetScissor = gfx.setScissor

local deg = math.deg
local rad = math.rad

local _fill_ = "fill"
local tblInsert = table.insert

---
--- @class chip.graphics.Viewport : chip.graphics.CanvasLayer
--- 
--- A canvas layer that clips all contents to it's size, along with
--- drawing a background color of the same size.
---
local Viewport = CanvasLayer:extend("Viewport", ...)

function Viewport:constructor(x, y, viewWidth, viewHeight)
    Viewport.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._viewWidth = viewWidth or 0.0 --- @type number

    ---
    --- @protected
    ---
    self._viewHeight = viewHeight or 0.0 --- @type number

    ---
    --- @protected
    ---
    self._clearColor = Color:new(Engine.clearColor) --- @type chip.utils.Color

    ---
    --- @protected
    ---
    self._bgSprite = Sprite:new() --- @type chip.graphics.Sprite
    self._bgSprite.origin:set()
    self._bgSprite:setVisibility(false) -- Don't automatically draw the bg sprite
    self._bgSprite:makeSolid(self._viewWidth, self._viewHeight, Color.WHITE)
    self._bgSprite:setTint(self._clearColor)
    self:add(self._bgSprite)
end

function Viewport:getClearColor()
    return self._clearColor
end

function Viewport:setClearColor(color)
    self._clearColor = Color:new(color)
    self._bgSprite:setTint(self._clearColor)
end

function Viewport:getWidth()
    return self._viewWidth
end

---
--- @param  viewWidth  number  The new width of the view.
---
function Viewport:setWidth(viewWidth)
    self._viewWidth = viewWidth
end

function Viewport:getHeight()
    return self._viewHeight
end

---
--- @param  viewHeight  number  The new height of the view.
---
function Viewport:setHeight(viewHeight)
    self._viewHeight = viewHeight
end

--- [ PRIVATE API ] ---

function Viewport:_draw()
    local vw, vh = self:getWidth(), self:getHeight()

    local bgSprite = self._bgSprite
    bgSprite:setGraphicSize(vw, vh)
    bgSprite:setAlpha(self._clearColor.a)
    bgSprite:draw()

    local psx, psy, psw, psh = gfxGetScissor()
    local _, rx, ry, rw, rh = bgSprite:getRenderingInfo()

    gfxSetScissor(
        (rx * Engine.scaleMode.scale.x) + Engine.scaleMode.offset.x, (ry * Engine.scaleMode.scale.x) + Engine.scaleMode.offset.y,
        rw * Engine.scaleMode.scale.x, rh * Engine.scaleMode.scale.y
    )
    Viewport.super._draw(self)
    gfxSetScissor(psx, psy, psw, psh)
end

return Viewport