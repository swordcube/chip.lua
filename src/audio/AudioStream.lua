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
--- @class chip.audio.AudioStream : chip.backend.RefCounted
---
--- A simple class for managing audio streams.
---
local AudioStream = RefCounted:extend("AudioStream", ...)

function AudioStream:constructor()
    AudioStream.super.constructor(self)

    self._data = nil --- @type love.Source
end

function AudioStream:getData()
    return self._data
end

---
--- @param  data  love.Source
---
function AudioStream:setData(data)
    self._data = data
end

function AudioStream:free()
    self._data:release()
    self._data = nil
end

return AudioStream