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

local Ease = crequire("tweens.Ease") --- @type chip.tweens.Ease

local TweenManager = crequire("plugins.TweenManager") --- @type chip.plugins.TweenManager
local PropertyTweener = crequire("tweens.tweeners.PropertyTweener") --- @type chip.tweens.tweeners.PropertyTweener

---
--- A basic tween class.
--- 
--- Tweens will start automatically by themselves
--- during the next frame once created.
---
--- @class chip.tweens.Tween : chip.core.Actor
---
local Tween = Actor:extend("Tween", ...)

---
--- @param  manager  chip.plugins.TweenManager?  The manager that this tween belongs to. (default: `TweenManager.global`)
---
function Tween:constructor(manager)
    Tween.super.constructor(self)

    self:setVisibility(false)

    ---
    --- @protected
    ---
    self._paused = false

    ---
    --- @protected
    --- @type chip.plugins.TweenManager?
    ---
    self._manager = manager and manager or TweenManager.global

    ---
    --- @protected
    --- @type function
    ---
    self._ease = Ease.linear

    ---
    --- @protected
    --- @type number
    ---
    self._startDelay = 0.0

    ---
    --- @protected
    --- @type function?
    ---
    self._onComplete = nil

    ---
    --- @protected
    --- @type number
    ---
    self._progress = nil

    ---
    --- @protected
    --- @type chip.core.Group
    ---
    self._tweeners = Group:new()

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = nil

    ---
    --- @protected
    --- @type number
    ---
    self._cachedDuration = nil

    ---
    --- @protected
    ---
    self._started = false

    self._manager.list:add(self)
end

function Tween:getManager()
    return self._manager
end

---
--- @param  manager  chip.plugins.TweenManager
--- @return chip.tweens.Tween
---
function Tween:setManager(manager)
    self._manager = manager
    return self
end

function Tween:getStartDelay()
    return self._startDelay
end

---
--- @param  delay  number
--- @return chip.tweens.Tween
---
function Tween:setStartDelay(delay)
    self._startDelay = delay
    return self
end

function Tween:getEase()
    return self._ease
end

---
--- Sets the default easing of this tween to
--- a given easing function.
---
--- @param  ease  function  The easing function to provide to this Tween.
--- 
--- @return chip.tweens.Tween
---
function Tween:setEase(ease)
    self._ease = ease
    return self
end

function Tween:getCompletionCallback()
    return self._onComplete
end

---
--- @param  func  function
--- @return chip.tweens.Tween
---
function Tween:setCompletionCallback(func)
    self._onComplete = func
    return self
end

---
--- Tweens a specific property from a given object to a
--- new value over a given duration of time.
--- 
--- You can use this function as many times as you want
--- on just one tween, thus avoiding tween spamming.
---
--- @param  obj          table         The object to tween a property on.
--- @param  property     string        The name of the property to Tween.
--- @param  finalValue  number|table  The value that the property should tween towards.
--- @param  duration     number        The duration of the property Tween.
--- @param  ease         function?     The easing function to use on the property tween (default: `ease.linear`)
---
--- @return chip.tweens.tweeners.PropertyTweener
---
function Tween:tweenProperty(obj, property, finalValue, duration, ease)
    self._cachedDuration = nil

    local initialValue = obj["_" .. property]
    if initialValue == nil then
        initialValue = obj[property]
    end
    if type(finalValue) == "table" then
        initialValue = {}
        
        local prop = obj[property]
        for key, _ in pairs(finalValue) do
            initialValue[key] = prop[key]
        end
    end
    local tweener = PropertyTweener:new(self, obj, property, initialValue, finalValue, duration, ease and ease or self._ease)
    self._tweeners:add(tweener)

    return tweener
end

function Tween:setDelay(secs)
    self._startDelay = secs
    return self
end

---
--- Returns the total duration of this tween. (in seconds)
---
--- @return number
---
function Tween:getDuration()
    if self._cachedDuration then
        return self._cachedDuration + self._startDelay
    end
    local total = 0.0
    for i = 1, self._tweeners._length do
        ---
        --- @type chip.tweens.tweeners.Tweener
        ---
        local tweener = self._tweeners._members[i]
        local duration = tweener:getDuration()
        if duration > total then
            total = duration
        end
    end
    self._cachedDuration = total
    return total + self._startDelay
end

---
--- Returns the progress percentage of this Tween. Ranges from 0 to 1.
---
--- @return number
---
function Tween:getProgress()
    if self._elapsedTime <= self._startDelay then
        return 0.0
    end
    return (self._elapsedTime - self._startDelay) / (self:getDuration() - self._startDelay)
end

---
--- Restarts this Tween.
--- 
--- @return chip.tweens.Tween
---
function Tween:restart()
    self._elapsedTime = 0.0

    for i = 1, #self._tweeners do
        local tweener = self._tweeners._members[i]
        if tweener._elapsedTime then
            tweener._elapsedTime = 0.0
        end
    end
    return self
end

---
--- Stops this Tween.
--- 
--- @return chip.tweens.Tween
---
function Tween:stop()
    self._elapsedTime = 0.0
    self._cachedDuration = nil

    self._startDelay = 0.0
    self._manager.list:remove(self)

    return self
end

---
--- Returns whether or not this tween is paused.
---
function Tween:isPaused()
    return self._paused
end

---
--- Pauses this Tween.
--- 
--- @return chip.tweens.Tween
---
function Tween:pause()
    self._paused = true
    return self
end

---
--- Resumes this Tween.
--- 
--- @return chip.tweens.Tween
---
function Tween:resume()
    self._paused = false
    return self
end

---
--- Updates this Tween.
--- This function is automatically called by the tween manager.
---
function Tween:update(dt)
    if self._paused then
        return
    end
    if not self._started then
        self:restart()
        self._started = true
    end
    self._elapsedTime = self._elapsedTime + dt
    if self._elapsedTime >= self._startDelay then
        self._tweeners:update(dt)

        if self:getProgress() >= 1.0 then
            if self._onComplete then
                self._onComplete(self)
            end
            self:free()
        end
    end
end

function Tween:cancel()
    self:stop()

    for i = 1, self._tweeners._length do
        local obj = self._tweeners._members[i]
        if obj then
            if chip.config.debugMode then
                chip.log:verbose("Disposing object " .. tostring(obj))
            end
            obj:free()
            self._tweeners:remove(obj)
        end
    end
end

function Tween:free()
    self:stop()
    
    self._tweeners:free()
    self._tweeners = nil
    
    Tween.super.free(self)
end

-----------------------
--- [ Private API ] ---
-----------------------



return Tween