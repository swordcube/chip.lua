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
    self._visible = true --- @type boolean

    ---
    --- @protected
    ---
    self._exists = true --- @type boolean

    ---
    --- @protected
    ---
    self._updateMode = "inherit" --- @type "always"|"inherit"|"disabled"
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
--- This depends on this actor's update mode:
--- - `always`: Always update (unless the game is unfocused with auto pause enabled)
--- - `inherit`: Inherit whether or not the parent is allowed to update (unless the game is unfocused with auto pause enabled)
--- - `disabled`: Never update
---
function Actor:isActive()
    if self._updateMode == "always" then
        return true
        
    elseif self._updateMode == "inherit" then
        -- Return true as fallback as if this actor has
        -- no parent, you're probably manually updating it anyways

        -- Which isn't recommended, but still allowed
        local p = self._parent
        if not p then
            return true
        end
        local active = false
        while p do
            if p:isActive() then
                active = true
                break
            end
            p = p._parent
        end
        return active
    end
    return false
end

---
--- Controls whether or not this actor
--- is allowed to automatically be updated.
--- 
--- @deprecated
--- @param  value  boolean
---
function Actor:setActive(value)
    self._updateMode = value and "inherit" or "disabled"
end

---
--- Returns the current update mode.
---
function Actor:getUpdateMode()
    return self._updateMode
end

---
--- Sets the current update mode to a given value.
--- 
--- This controls when this actor is allowed to
--- automatically update itself:
--- - `always`: Always update (unless the game is unfocused with auto pause enabled)
--- - `inherit`: Inherit whether or not the parent is allowed to update (unless the game is unfocused with auto pause enabled)
--- - `disabled`: Never update
--- 
--- @param  value  "always"|"inherit"|"disabled"
---
function Actor:setUpdateMode(value)
    self._updateMode = value
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
--- @param  dt  number  The time since the last frame. (in seconds)
---
function Actor:update(dt)
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
    Actor.super.free(self)
end

return Actor