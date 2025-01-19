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
--- @class chip.input.keyboard.InputEventTextInput : chip.input.InputEvent
--- 
--- A class which represents a keyboard input event, but only
--- emitted when a key valid for typing into a text field is pressed.
---
local InputEventTextInput = InputEvent:extend("InputEventTextInput", ...)

---
--- @param  char  string
---
function InputEventTextInput:constructor(char)
    InputEventTextInput.super.constructor(self)

    ---
    --- @protected
    ---
    self._char = char --- @type string
end

function InputEventTextInput:getCharacter()
    return self._char
end

return InputEventTextInput