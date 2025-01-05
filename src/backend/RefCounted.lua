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
--- @class chip.backend.RefCounted : chip.backend.Object
---
--- The base class for all reference counted
--- objects, such as textures, audio, fonts, etc.
---
local RefCounted = Class:extend("RefCounted", ...)

function RefCounted:constructor()
    ---
    --- @protected
    --- @type integer
    ---
    self._references = 0
end

---
--- Adds a reference to this object.
--- 
--- Only use this if you know what you're doing!
---
function RefCounted:reference()
    self:_setReferences(self._references + 1)
end

---
--- Removes a reference from this object.
--- 
--- Only use this if you know what you're doing!
---
function RefCounted:unreference()
    self:_setReferences(self._references - 1)
end

function RefCounted:getReferences()
    return self._references
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function RefCounted:_setReferences(val)
    self._references = val
    if self._references <= 0 then
        self._references = 0
        self:free()
    end
end

return RefCounted