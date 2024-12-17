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

local gfx = love.graphics
local _linear_ = "linear"

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
    --- 
    --- The image drawn via Sprites when they
    --- have antialiasing enabled on them.
    ---
    self._smoothImage = nil --- @type love.Image

    ---
    --- @protected
    --- 
    --- The image drawn via Sprites when they
    --- have antialiasing disabled on them.
    ---
    self._roughImage = nil --- @type love.Image

    ---
    --- @protected
    --- @type love.ImageData
    ---
    self._imageData = nil
end

function Texture:free()
    self._imageData:release()
    self._imageData = nil

    self._smoothImage:release()
    self._smoothImage = nil

    self._roughImage:release()
    self._roughImage = nil

    self.width = 0
    self.height = 0

    for key, value in pairs(Assets._textureCache) do
        if value == self then
            Assets._textureCache[key] = nil
        end
    end
end

---
--- @param  filter  "linear"|"nearest"
---
function Texture:getImage(filter)
    if filter == _linear_ then
        return self._smoothImage
    end
    return self._roughImage
end

---
--- @param  imageData  love.ImageData
---
function Texture:setImage(imageData)
    if self._smoothImage then
        self._smoothImage:release()
    end
    if self._roughImage then
        self._roughImage:release()
    end
    self._smoothImage = gfx.newImage(imageData)
    self._smoothImage:setFilter("linear", "linear", 4)

    self._roughImage = gfx.newImage(imageData)
    self._roughImage:setFilter("nearest", "nearest", 4)

    self._imageData = imageData

    self.width = self._imageData:getWidth()
    self.height = self._imageData:getHeight()
end

--- [ PRIVATE API ] ---

return Texture