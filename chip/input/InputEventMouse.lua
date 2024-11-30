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

---
--- @class chip.input.InputEventMouse : chip.backend.Object
--- 
--- A class which represents a mouse input event.
---
local InputEventMouse = Object:extend("InputEventMouse", ...)

---
--- @param  x  number
--- @param  y  number
---
function InputEventMouse:constructor(x, y)
    InputEventMouse.super.constructor(self)

    self._x = x
    self._y = y
end

function InputEventMouse:getX()
    return self._x
end

function InputEventMouse:getY()
    return self._y
end

return InputEventMouse