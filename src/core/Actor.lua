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
--- @class chip.core.Actor : chip.backend.Object
---
--- A base class for all of your game objects.
---
local Actor = Object:extend("Actor", ...)

function Actor:constructor()
    ---
    --- @protected
    ---
    self._parent = nil --- @type chip.core.Group|chip.graphics.CanvasLayer

    ---
    --- @protected
    ---
    self._active = true --- @type boolean

    ---
    --- @protected
    ---
    self._visible = true --- @type boolean

    ---
    --- @protected
    ---
    self._exists = true --- @type boolean
end

---
--- Returns the parent of this actor.
---
function Actor:getParent()
    return self._parent
end

---
--- Returns whether or not this actor
--- is allowed to automatically be updated.
---
function Actor:isActive()
    return self._active
end

---
--- Controls whether or not this actor
--- is allowed to automatically be updated.
---
function Actor:setActive(value)
    self._active = value
end

---
--- Returns whether or not this actor
--- is visible on-screen.
---
function Actor:isVisible()
    return self._visible
end

---
--- Controls whether or not this actor
--- is visible on-screen.
---
function Actor:setVisibility(value)
    self._visible = value
end

---
--- Returns whether or not this actor
--- is considered to be existing.
--- 
--- Which means if this actor is killed, then it will
--- will no longer update or draw automatically,
--- regardless of the `active` and `visible` flags.
--- 
--- You can recycle non-existing actors for later use
--- to save on allocations and memory.
---
function Actor:isExisting()
    return self._exists
end

---
--- Marks this actor as non-existent.
--- 
--- You can recycle non-existing actors in groups
--- for later use to save on allocations and memory.
---
function Actor:kill()
    self._exists = false
end

---
--- Marks this actor as existent.
---
function Actor:revive()
    self._exists = true
end

---
--- Updates this actor.
--- 
--- @param  delta  number  The time since the last frame. (in seconds)
---
function Actor:update(delta)
end

---
--- Draws this actor to the screen.
---
function Actor:draw()
end

---
--- The function that gets called when
--- any actor receives an input event.
--- 
--- @param  event  chip.input.InputEvent
---
function Actor:input(event)
end

---
--- Frees this object from memory immediately.
--- 
--- NOTE: This object will immediately become unstable
--- after this is called!
---
function Actor:free()
    if self._parent then
        self._parent:remove(self)
    end
end

return Actor