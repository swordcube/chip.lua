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
--- @class chip.graphics.CanvasLayer : chip.core.Group
--- 
--- A group object which can be moved around on
--- the X and Y axis.
---
local CanvasLayer = Group:extend("CanvasLayer", ...)

-- TODO: add width and height to this

function CanvasLayer:constructor()
    CanvasLayer.super.constructor(self)

    ---
    --- @protected
    ---
    self._x = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._y = 0.0 --- @type number

    ---
    --- The X and Y scale of this canvas layer.
    ---
    self.scale = Point:new(1, 1) --- @type chip.math.Point

    ---
    --- The X and Y rotation origin of this canvas layer.
    ---
    self.origin = Point:new(0.5, 0.5) --- @type chip.math.Point

    ---
    --- The zoom factor of this canvas layer.
    ---
    self.zoom = nil --- @type number

    ---
    --- The rotation of this canvas layer. (in radians)
    ---
    self.rotation = 0.0
end

---
--- Returns the X coordinate of this canvas layer on-screen. (in pixels)
---
function CanvasLayer:getX()
    return self._x
end

---
--- Sets the X coordinate of this canvas layer.
--- 
--- @param  x  number  The new X coordinate of this canvas layer on-screen. (in pixels)
---
function CanvasLayer:setX(x)
    self._x = x
end

---
--- Returns the Y coordinate of this canvas layer on-screen. (in pixels)
---
function CanvasLayer:getY()
    return self._y
end

---
--- Sets the Y coordinate of this canvas layer.
--- 
--- @param  y  number  The new Y coordinate of this canvas layer on-screen. (in pixels)
---
function CanvasLayer:setY(y)
    self._y = y
end

function CanvasLayer:setPosition(x, y)
    self._x = x or 0.0
    self._y = y or 0.0
    return self
end

---
--- @param  axes  "x"|"y"|"xy"?
---
function CanvasLayer:screenCenter(axes)
    if not axes then
        axes = "xy"
    end
    if axes:contains("x") then
        self:setX((Engine.gameWidth - self:getWidth()) * 0.5)
    end
    if axes:contains("y") then
        self:setY((Engine.gameHeight - self:getHeight()) * 0.5)
    end
end

---
--- Draws all of this canvas layer's members to the screen.
---
function CanvasLayer:draw()
    gfx.push()
	gfx.translate(self._x, self._y)

    local w2 = Engine.gameWidth * self.origin.x
    local h2 = Engine.gameHeight * self.origin.y
	gfx.scale(self.scale.x, self.scale.y)
    
    gfx.translate(w2, h2)
	gfx.rotate(self.rotation)
    gfx.translate(-w2, -h2)
    
    CanvasLayer.super.draw(self)

    gfx.pop()
end

function CanvasLayer:getRotationDegrees()
    return math.deg(self.rotation)
end

function CanvasLayer:setRotationDegrees(val)
    self.rotation = math.rad(val)
end

function CanvasLayer:getZoom()
    return (self.scale.x + self.scale.y) * 0.5
end

function CanvasLayer:setZoom(val)
    self._x = -((Engine.gameWidth * 0.5) * (val - 1))
    self._y = -((Engine.gameHeight * 0.5) * (val - 1))
    self.scale:set(val, val)
end

--- [ PRIVATE API ] ---


return CanvasLayer