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
--- @class chip.input.keyboard.InputEventKey : chip.input.InputEvent
--- 
--- A class which represents a keyboard input event.
---
local InputEventKey = InputEvent:extend("InputEventKey", ...)

---
--- @param  key        string
--- @param  pressed    boolean
--- @param  repeating  boolean
---
function InputEventKey:constructor(key, scancode, pressed, repeating)
    InputEventKey.super.constructor(self)

    ---
    --- @protected
    ---
    self._key = key --- @type string

    ---
    --- @protected
    ---
    self._scancode = scancode --- @type love.Scancode

    ---
    --- @protected
    ---
    self._pressed = pressed --- @type boolean

    ---
    --- @protected
    ---
    self._repeating = repeating --- @type boolean
end

function InputEventKey:getKey()
    return self._key
end

function InputEventKey:getScanCode()
    return self._scancode
end

function InputEventKey:isPressed()
    return self._pressed
end

function InputEventKey:isRepeating()
    return self._repeating
end

return InputEventKey