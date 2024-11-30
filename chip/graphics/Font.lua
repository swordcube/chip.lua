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
--- @class chip.graphics.Font : chip.backend.RefCounted
--- 
--- A class representing a font.
--- 
--- You should load these from the `Assets` class
--- under the `chip.utils` package.
---
local Font = RefCounted:extend("Font", ...)

function Font:constructor()
    Font.super.constructor(self)

    ---
    --- @protected
    --- @type table<integer, love.Font>
    ---
    self._data = {}
end

function Font:getData(size)
    return self._data[size]
end

function Font:setData(size, data)
    self._data[size] = data
    self._data[size]:setFilter("nearest", "nearest", 4)
end

function Font:free()
    for _, value in pairs(self._data) do
        value:release()
    end
    self._data:release()
    self._data = nil

    for key, value in pairs(Assets._fontCache) do
        if value == self then
            Assets._fontCache[key] = nil
        end
    end
end

--- [ PRIVATE API ] ---

return Font