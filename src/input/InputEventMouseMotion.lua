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
--- @class chip.input.InputEventMouseMotion : chip.input.InputEventMouse
--- 
--- A class which represents a mouse button input event.
---
local InputEventMouseMotion = InputEventMouse:extend("InputEventMouseMotion", ...)

---
--- @param  x   number
--- @param  y   number
--- @param  dx  number
--- @param  dy  number
---
function InputEventMouseMotion:constructor(x, y, dx, dy)
    InputEventMouseMotion.super.constructor(self, x, y)

    self._dx = dx
    self._dy = dy
end

function InputEventMouseMotion:getDeltaX()
    return self._dx
end

function InputEventMouseMotion:getDeltaY()
    return self._dy
end

return InputEventMouseMotion