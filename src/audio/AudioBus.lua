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
--- @class chip.audio.AudioBus : chip.backend.Object
---
--- A simple class for managing audio buses.
---
local AudioBus = Object:extend("AudioBus", ...)

function AudioBus:constructor()
    AudioBus.super.constructor(self)

    ---
    --- @protected
    ---
    self._volume = 1 --- @type number

    ---
    --- @protected
    ---
    self._muted = false --- @type boolean
end

function AudioBus:getVolume()
    return self._volume
end

function AudioBus:setVolume(newVolume)
    self._volume = newVolume
end

function AudioBus:increaseVolume(by, decimals)
    if decimals and decimals > 0 then
        self._volume = math.clamp(math.truncate(self._volume + by, decimals), 0.0, 1.0)
    else
        self._volume = math.clamp(self._volume + by, 0.0, 1.0)
    end
end

function AudioBus:decreaseVolume(by, decimals)
    if decimals and decimals > 0 then
        self._volume = math.clamp(math.truncate(self._volume - by, decimals), 0.0, 1.0)
    else
        self._volume = math.clamp(self._volume - by, 0.0, 1.0)
    end
end

function AudioBus:isMuted()
    return self._muted
end

function AudioBus:setMuted(newValue)
    self._muted = newValue
end

AudioBus.master = AudioBus:new() --- @type chip.audio.AudioBus
return AudioBus