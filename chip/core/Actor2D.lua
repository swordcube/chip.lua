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
--- @class chip.core.Actor2D : chip.core.Actor
---
--- A base class for all of your 2D game objects.
--- 
--- Includes built-in X and Y coordinate properties.
---
local Actor2D = Actor:extend("Actor2D", ...)

function Actor2D:constructor(x, y)
    Actor2D.super.constructor(self)

    ---
    --- The X coordinate of this actor on-screen. (in pixels)
    ---
    self.x = x or 0.0 --- @type number

    ---
    --- The Y coordinate of this actor on-screen. (in pixels)
    ---
    self.y = y or 0.0 --- @type number
end

function Actor2D:setPosition(x, y)
    self.x = x or 0.0
    self.y = y or 0.0
    return self
end

return Actor2D