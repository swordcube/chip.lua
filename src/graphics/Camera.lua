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

local deg = math.deg
local rad = math.rad
local lerp = math.lerp

---
--- @class chip.graphics.Camera : chip.core.Actor2D
--- 
--- An object representing a camera, used for tracking
--- any given object, with smoothing properties, zooming, etc.
--- 
--- You may only have one active camera at a time, so if you want
--- zooming effects elsewhere, try using `CanvasLayer` instead.
---
local Camera = Actor2D:extend("Camera", ...)

---
--- The currently active camera.
---
Camera.currentCamera = nil --- @type chip.graphics.Camera

function Camera:constructor()
    Camera.super.constructor(self)

    self._x = Engine.gameWidth * 0.5
    self._y = Engine.gameHeight * 0.5

    ---
    --- @protected
    ---
    self._zoom = 1 --- @type number

    ---
    --- @protected
    ---
    self._rotation = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._smoothing = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._smoothedX = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._smoothedY = 0.0 --- @type number
end

---
--- Returns the X coordinate of the camera, as if it
--- had instantly snapped to it's destination.
---
function Camera:getTargetX()
    return self._x
end

---
--- Returns the Y coordinate of the camera, as if it
--- had instantly snapped to it's destination.
---
function Camera:getTargetY()
    return self._y
end

function Camera:snapToTargetPos()
    self._smoothedX = self._x
    self._smoothedY = self._y
end

function Camera:getX()
    if self._smoothing > 0.0 then
        return self._smoothedX
    end
    return self._x
end

function Camera:getY()
    if self._smoothing > 0.0 then
        return self._smoothedY
    end
    return self._y
end

function Camera:getZoom()
    return self._zoom
end

function Camera:setZoom(val)
    self._zoom = val
end

function Camera:getRotation()
    return self._rotation
end

function Camera:setRotation(val)
    self._rotation = val
end

function Camera:getRotationDegrees()
    return deg(self._rotation)
end

function Camera:setRotationDegrees(val)
    self._rotation = rad(val)
end

function Camera:getSmoothing()
    return self._smoothing
end

function Camera:setSmoothing(val)
    self._smoothing = val
end

function Camera:update(dt)
    Camera.super.update(self, dt)

    if self._smoothing > 0.0 then
        self._smoothedX = lerp(self._smoothedX, self._x, dt * self._smoothing)
        self._smoothedY = lerp(self._smoothedY, self._y, dt * self._smoothing)
    end
end

function Camera:makeCurrent()
    Camera.currentCamera = self
end

--- [ PRIVATE API ] ---

return Camera