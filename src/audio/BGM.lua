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

---@diagnostic disable: invisible

local TweenManager = crequire("plugins.TweenManager") --- @type chip.plugins.TweenManager

---
--- @class chip.audio.BGM
---
local BGM = {}

local player = AudioPlayer:new() --- @type chip.audio.AudioPlayer
player._isBGM = true

---
--- The audio player used to play background music
---
BGM.audioPlayer = player

---
--- @protected
---
BGM._tweenManager = TweenManager:new() --- @type chip.plugins.TweenManager

---
--- @param  stream   chip.audio.AudioStream|string
---
function BGM.load(stream)
    if not stream then
        print("WARNING: Cannot play invalid stream for BGM!")
        return
    end
    player:setPitch(1.0)
    player:setVolume(1.0)
    player:load(stream)
end

---
--- @param  stream   chip.audio.AudioStream|string?
--- @param  looping  boolean?
---
function BGM.play(stream, looping)
    if looping == nil then
        looping = true
    end
    if stream then
        BGM.load(stream)
    end
    player:setLooping(looping)
    player:play()
end

function BGM.pause()
    player:pause()
end

function BGM.resume()
    player:resume()
end

function BGM.stop()
    player:stop()
end

function BGM.isPlaying()
    return player:isPlaying()
end

function BGM.update(dt)
    BGM._tweenManager:update(dt)
    if not player:isExisting() or not player:isActive() then
        return
    end
    player:update(dt)
end

function BGM.fade(from, to, duration)
    player:fade(from, to, duration, BGM._tweenManager)
end

function BGM.free()
    player:free()
end

return BGM