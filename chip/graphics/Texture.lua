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
--- @diagnostic disable: invisible
--- @class chip.graphics.Texture : chip.backend.RefCounted
--- 
--- A class representing a texture/image.
--- 
--- You should load these from the `Assets` class
--- under the `chip.utils` package.
---
local Texture = RefCounted:extend("Texture", ...)

function Texture:constructor()
    Texture.super.constructor(self)

    ---
    --- The width of this texture. (in pixels)
    ---
    self.width = 0 --- @type integer

    ---
    --- The height of this texture. (in pixels)
    ---
    self.height = 0 --- @type integer

    ---
    --- @protected
    --- @type love.Image
    ---
    self._image = nil
end

function Texture:free()
    self._image:release()
    self._image = nil

    self.width = 0
    self.height = 0

    for key, value in pairs(Assets._textureCache) do
        if value == self then
            Assets._textureCache[key] = nil
        end
    end
end

function Texture:getImage()
    return self._image
end

---
--- @param  val  love.Image
---
function Texture:setImage(val)
    self._image = val
    self.width = val:getWidth()
    self.height = val:getHeight()
end

--- [ PRIVATE API ] ---

return Texture