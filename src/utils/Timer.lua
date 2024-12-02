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

local TimerManager = crequire("plugins.TimerManager") --- @type chip.plugins.TimerManager

---
--- A basic timer class.
---
--- @class chip.utils.Timer : chip.core.Actor
---
local Timer = Actor:extend("Timer", ...)

---
--- @param  manager  chip.plugins.TimerManager?  The manager that this timer belongs to. (default: `TimerManager.global`)
---
function Timer:constructor(manager)
    Timer.super.constructor(self)

    self.visible = false

    ---
    --- @protected
    --- @type boolean
    ---
    self._paused = false

    ---
    --- @protected
    --- @type chip.plugins.TimerManager?
    ---
    self._manager = manager and manager or TimerManager.global
    
    ---
    --- @protected
    ---
    self._elapsedTime = 0.0
    
    ---
    --- @protected
    ---
    self._duration = 0.0

    ---
    --- @protected
    --- @type function?
    ---
    self._onComplete = nil
    
    ---
    --- @protected
    ---
    self._loops = 1
    
    ---
    --- @protected
    ---
    self._loopsLeft = 1
end

---
--- Returns whether or not this timer is paused.
---
function Timer:isPaused()
    return self._paused
end

---
--- Pauses this timer.
--- 
--- @return chip.utils.Timer
---
function Timer:pause()
    self._paused = true
    return self
end

---
--- Resumes this timer.
--- 
--- @return chip.utils.Timer
---
function Timer:resume()
    self._paused = false
    return self
end

---
--- Returns the duration of this timer. (in seconds)
---
function Timer:getDuration()
    return self._duration
end

---
--- Sets the duration of this timer.
--- 
--- @param  duration  number  The new duration of the timer. (in seconds)
--- 
--- @return chip.utils.Timer
---
function Timer:setDuration(duration)
    self._duration = duration
    return self
end

---
--- Returns the amount of times that this timer will loop.
---
function Timer:getLoops()
    return self._loops
end

---
--- Sets the amount of times that this timer will loop.
--- 
--- @param  loops  integer  The new amount of times that this timer will loop.
--- 
--- @return chip.utils.Timer
---
function Timer:setLoops(loops)
    self._loops = loops
    return self
end

---
--- Returns the amount of loops left on this timer.
---
function Timer:getLoopsLeft()
    return self._loopsLeft
end

---
--- Sets the amount of loops left on this timer.
--- 
--- @param  loopsLeft  integer  The new amount of loops left on this timer.
--- 
--- @return chip.utils.Timer
---
function Timer:setLoopsLeft(loopsLeft)
    self._loopsLeft = loopsLeft
    return self
end

---
--- Returns the completion callback for this timer.
---
function Timer:getCompletionCallback()
    return self._onComplete
end

---
--- Sets the completion callback for this timer.
--- 
--- @param  callback  function  A function that gets called when the timer completes, once for each loop.
--- 
--- @return chip.utils.Timer
---
function Timer:setCompletionCallback(callback)
    self._onComplete = callback
    return self
end

---
--- Returns the amount of time that has elapsed since this timer started. (in seconds)
---
function Timer:getElapsedTime()
    return self._elapsedTime
end

---
--- Starts this timer with the given duration and completion callback.
---
--- @param  duration     number     The duration of the timer in seconds.
--- @param  onComplete  function?  A function that gets called when the timer completes, once for each loop.
--- @param  loops        integer?   An optional number of times to loop the timer.
--- 
--- @return chip.utils.Timer
---
function Timer:start(duration, onComplete, loops)
    self._duration = duration
    self._onComplete = onComplete

    self._loops = loops and loops or 1
    self._loopsLeft = self._loops

    self._manager.list:add(self)
    return self
end

---
--- Updates this timer.
--- This function is automatically called by the timer manager.
---
function Timer:update(dt)
    if self._paused then
        return
    end
    self._elapsedTime = self._elapsedTime + dt

    if self._elapsedTime >= self._duration then
        self._elapsedTime = 0.0

        if self._loops > 0 then
            self._loopsLeft = self._loopsLeft - 1
            
            if self._onComplete then
                self._onComplete(self)
            end

            if self._loopsLeft <= 0 then
                self:stop()
            end
        else
            if self._onComplete then
                self._onComplete(self)
            end
        end
    end
end

---
--- Stops this timer and resets its properties
--- 
--- @return chip.utils.Timer
---
function Timer:stop()
    self._elapsedTime = 0.0
    self._duration = 0.0

    self._loops = 1
    self._loopsLeft = 1

    self._onComplete = nil
    self._manager.list:remove(self)

    return self
end

---
--- Resets this timer with the given duration.
--- The timer will not be removed from the manager.
---
--- @param  duration  number  The new duration of the timer in seconds.
--- 
--- @return chip.utils.Timer
---
function Timer:reset(duration)
    self._duration = duration
    self._elapsedTime = 0.0
    self._loopsLeft = self._loops
    return self
end

function Timer:free()
    self:stop()
    Timer.super.free(self)
end

return Timer