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
--- @class chip.input.InputEventMouseButton : chip.input.InputEventMouse
--- 
--- A class which represents a mouse button input event.
---
local InputEventMouseButton = InputEventMouse:extend("InputEventMouseButton", ...)

---
--- @param  x        number
--- @param  y        number
--- @param  pressed  boolean
--- @param  button   integer
---
function InputEventMouseButton:constructor(x, y, pressed, button)
    InputEventMouseButton.super.constructor(self, x, y)

    self._pressed = pressed
    self._button = button
end

function InputEventMouseButton:isPressed()
    return self._pressed
end

function InputEventMouseButton:getButton()
    if self._button == 1 then
        return "left"
    elseif self._button == 2 then
        return "right"
    elseif self._button == 3 then
        return "middle"
    end
    return "unknown"
end

return InputEventMouseButton