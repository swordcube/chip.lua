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

local _seconds_ = "seconds"

local max = math.max
local tblInsert = table.insert

local Engine = crequire("Engine") --- @type chip.Engine
local Signal = crequire("utils.Signal") --- @type chip.utils.Signal

---
--- @class chip.audio.AudioPlayer : chip.core.Actor
---
local AudioPlayer = Actor:extend("AudioPlayer", ...)

function AudioPlayer:constructor()
    AudioPlayer.super.constructor(self)

    self:setVisibility(false)
    self:setUpdateMode("always")

    ---
    --- The signal that is fired when the audio has finished playing.
    ---
    self.finished = Signal:new() --- @type chip.utils.Signal

    ---
    --- @protected
    ---
    self._volume = 1.0 --- @type number

    ---
    --- @protected
    ---
    self._pitch = 1.0 --- @type number

    ---
    --- @protected
    ---
    self._maxPolyphony = 1 --- @type integer

        ---
    --- @protected
    ---
    self._stream = nil --- @type chip.audio.AudioStream

    ---
    --- @protected
    ---
    self._sources = {false} --- @type table<love.Source>

    ---
    --- @protected
    ---
    self._curSource = 1 --- @type integer

    ---
    --- @protected
    ---
    self._filter = nil --- @type {type: love.FilterType, volume: number, highgain: number, lowgain: number}

    ---
    --- @protected
    ---
    self._bus = nil --- @type chip.audio.AudioBus

    ---
    --- @protected
    ---
    self._paused = false

    ---
    --- @protected
    ---
    self._looping = false

    ---
    --- @protected
    ---
    self._playing = false

    ---
    --- @protected
    ---
    self._isBGM = false

    ---
    --- @protected
    --- @type function
    ---
    self._onFocusLost = function()
        if not Engine.autoPause or not self._playing or self._paused then
            return
        end
        local sources = self._sources
        for i = 1, #sources do
            local source = sources[i] --- @type love.Source
            if source then
                source:pause()
            end
        end
    end

    ---
    --- @protected
    --- @type function
    ---
    self._onFocusGained = function()
        if not Engine.autoPause or not self._playing or self._paused then
            return
        end
        local sources = self._sources
        for i = 1, #sources do
            local source = sources[i] --- @type love.Source
            if source then
                source:play()
            end
        end
    end

    ---
    --- @protected
    ---
    self._fadeTween = nil --- @type chip.tweens.Tween?

    Engine.onFocusLost:connect(self._onFocusLost)
    Engine.onFocusGained:connect(self._onFocusGained)
end

---
--- Loads an audio stream into this player.
---
--- @param  data  chip.audio.AudioStream|string
--- 
--- @return chip.audio.AudioPlayer
---
function AudioPlayer:load(data)
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:stop()
        end
    end
    if self._stream then
        self._stream:unreference()
    end
    self._stream = Assets.getAudioStream(data)
    self._stream:reference()
    
    local masterBus = AudioBus.master
    local mult = masterBus:getVolume()
    if self._bus then
        mult = mult * self._bus:getVolume()
    end
    if masterBus:isMuted() then
        mult = 0
    end
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i]
        if source then
            source:release()
        end
        self._paused = false
        self._playing = false

        source = self._stream:getData():clone()
        source:setVolume(self._volume * mult)
        source:setPitch(max(self._pitch, 0.01))
        source:setLooping(self._looping)
    
        if self._filter then
            source:setFilter(self._filter)
        end
        sources[i] = source
    end
    self:kill()
    return self
end

---
--- Plays/resumes the audio stream attached to this player.
---
function AudioPlayer:play()
    if not self._parent and not self._isBGM then
        print("WARNING: An audio player needs a parent!")
        return
    end
    local sources = self._sources
    sources[self._curSource]:play()

    self._playing = true
    self._curSource = math.wrap(self._curSource + 1, 1, #sources)

    self:revive()
end

---
--- Pauses the audio stream attached to this player.
---
function AudioPlayer:pause()
    if not self._parent and not self._isBGM then
        print("WARNING: An audio player needs a parent!")
        return
    end
    self._paused = true
    self._playing = false

    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:pause()
        end
    end
    self:kill()
end

---
--- Resumes the audio stream attached to this player.
---
function AudioPlayer:resume()
    if not self._parent and not self._isBGM then
        print("WARNING: An audio player needs a parent!")
        return
    end
    self._paused = false
    self._playing = true

    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:play()
        end
    end
    self:revive()
end

---
--- Stops the audio stream attached to this player.
---
function AudioPlayer:stop()
    if not self._parent and not self._isBGM then
        print("WARNING: An audio player needs a parent!")
        return
    end
    self._playing = false

    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:stop()
        end
    end
    self:kill()
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
function AudioPlayer:setUpdateMode(value)
    if value ~= "always" then
        Log.warn(nil, nil, nil, "AudioPlayers must always be able to update!")
        value = "always"
    end
    self._updateMode = value
end

function AudioPlayer:isPlaying()
    return self._playing
end

function AudioPlayer:getPlaybackTime()
    local sources = self._sources
    local source = sources[self._curSource] --- @type love.Source
    return source:tell(_seconds_)
end

function AudioPlayer:seek(newTime)
    local sources = self._sources
    local source = sources[self._curSource] --- @type love.Source
    source:seek(newTime, _seconds_)
end

function AudioPlayer:getBus()
    return self._bus
end

---
--- @param  newBus  chip.audio.AudioBus
---
function AudioPlayer:setBus(newBus)
    if newBus == AudioBus.master then
        print("WARNING: Cannot use master bus twice for audio!")
        return
    end
    self._bus = newBus
end

function AudioPlayer:getVolume()
    return self._volume
end

---
--- @param  newVolume  number
---
function AudioPlayer:setVolume(newVolume)
    if not self._parent and not self._isBGM then
        print("WARNING: An audio player needs a parent!")
        return
    end
    self._volume = newVolume
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            local masterBus = AudioBus.master
            local mult = masterBus:getVolume()
            if self._bus then
                mult = mult * self._bus:getVolume()
            end
            if masterBus:isMuted() then
                mult = 0
            end
            source:setVolume(self._volume * mult)
        end
    end
end

function AudioPlayer:getPitch()
    return self._pitch
end

---
--- @param  newPitch  number
---
function AudioPlayer:setPitch(newPitch)
    self._pitch = newPitch
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:setPitch(max(self._pitch, 0.01))
        end
    end
end

function AudioPlayer:isLooping()
    return self._looping
end

---
--- @param  newLooping  boolean
---
function AudioPlayer:setLooping(newLooping)
    self._looping = newLooping
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:setLooping(self._looping)
        end
    end
end

function AudioPlayer:getFilter()
    return self._filter
end

---
--- @param  newFilter  {type: love.FilterType, volume: number, highgain: number, lowgain: number}
---
function AudioPlayer:setFilter(newFilter)
    self._filter = newFilter
    if self._source then
        self._source:setFilter(self._filter)
    end
end

---
--- Returns the amount of times this sound
--- can play on-top of itself.
--- 
--- @return integer
---
function AudioPlayer:getMaxPolyphony()
    return self._maxPolyphony
end

---
--- Sets the amount of times this sound
--- can play on-top of itself.
--- 
--- This is useful for sound effects that
--- would normally repeat several times in a short
--- span of time, such as menu scrolling.
--- 
--- For that use case, a value of `10` should be enough.
--- 
--- If you *absolutely need* anymore however, you can go up to `50`.
---
--- @param  newMaxPolyphony  integer
---
function AudioPlayer:setMaxPolyphony(newMaxPolyphony)
    self._maxPolyphony = math.clamp(newMaxPolyphony, 1, 50)
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i]
        if source then
            source:release()
        end
    end
    for _ = 1, self._maxPolyphony do
        tblInsert(sources, self._stream:getData():clone())
    end
end

---
--- Fades this audio player from a given
--- volume to another volume.
---
--- @param  from          number                      The volume to fade from.
--- @param  to            number                      The volume to fade to.
--- @param  duration      number                      The duration of the fade. (in seconds)
--- @param  tweenManager  chip.plugins.TweenManager?  The tween manager to use. (optional)
---
function AudioPlayer:fade(from, to, duration, tweenManager)
    if self._fadeTween then
        self._fadeTween:free()
    end
    self._fadeTween = Tween:new(tweenManager) --- @type chip.tweens.Tween
    
    self:setVolume(from)
    local sources = self._sources
    local sourceCount = #sources

    local pt = self._fadeTween:tweenProperty(self, "_volume", to, duration)
    pt:setUpdateCallback(function(_)
        for i = 1, sourceCount do
            local source = sources[i]
            if source then
                local masterBus = AudioBus.master
                local mult = masterBus:getVolume()
                if self._bus then
                    mult = mult * self._bus:getVolume()
                end
                if masterBus:isMuted() then
                    mult = 0
                end
                source:setVolume(self._volume * mult)
            end
        end
    end)
end

function AudioPlayer:update(_)
    local sources = self._sources
    local isAnySourcePlaying = false

    for i = 1, #sources do
        local source = sources[i]
        if source then
            local masterBus = AudioBus.master
            local mult = masterBus:getVolume()
            if self._bus then
                mult = mult * self._bus:getVolume()
            end
            if masterBus:isMuted() then
                mult = 0
            end
            source:setVolume(self._volume * mult)
            if source:isPlaying() then
                isAnySourcePlaying = true
            end
        end
    end
    if not self._looping and self._playing and not isAnySourcePlaying then
        self._playing = false
        self.finished:emit()
    end
end

function AudioPlayer:free()
    local sources = self._sources
    for i = 1, #sources do
        local source = sources[i] --- @type love.Source
        if source then
            source:stop()
            source:release()
        end
    end
    self._sources = nil

    Engine.onFocusLost:disconnect(self._onFocusLost)
    Engine.onFocusGained:disconnect(self._onFocusGained)

    AudioPlayer.super.free(self)
end

---
--- Returns a new audio player, which is automatically
--- added to the current scene, then removed
--- after it finishes playing.
--- 
--- This is mainly only useful for sound effects.
--- 
--- However for stuff like music, you should either
--- use the built-in `BGM` class, or make an audio player
--- and manage it yourself.
---
--- @param  data  chip.audio.AudioStream|string
---
function AudioPlayer.playSFX(data)
    local player = AudioPlayer:new():load(data) --- @type chip.audio.AudioPlayer
    Engine.currentScene:add(player)

    player.finished:connect(function()
        player:free()
    end)
    player:play()
    return player
end

return AudioPlayer