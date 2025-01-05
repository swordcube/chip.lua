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

local Pool = crequire("utils.Pool") --- @type chip.utils.Pool

---
--- @class chip.graphics.effects.FlickerEffect
---
local FlickerEffect = Class:extend("Flicker", ...)

---
--- @protected
--- @type chip.utils.Pool?
---
FlickerEffect._pool = Pool:new(FlickerEffect)

---
--- @protected
--- @type table<chip.core.Actor, chip.graphics.effects.FlickerEffect>
---
FlickerEffect._boundObjects = {}

---
--- @param  object              chip.core.Actor
--- @param  duration            number
--- @param  interval            number?
--- @param  endVisibility       boolean?
--- @param  forceRestart        boolean?
--- @param  completionCallback  function?
--- @param  progressCallback    function?
---
function FlickerEffect.flicker(object, duration, interval, endVisibility, forceRestart, completionCallback, progressCallback)
    if endVisibility == nil then
        endVisibility = true
    end
    if forceRestart == nil then
        forceRestart = true
    end
    if FlickerEffect.isFlickering(object) then
        if forceRestart then
            FlickerEffect.stopFlickering(object)
        else
            return FlickerEffect._boundObjects[object]
        end
    end
    if interval <= 0 then
        interval = Engine.deltaTime
    end
    local flicker = FlickerEffect._pool:get()
    flicker:start(object, duration, interval, endVisibility, completionCallback, progressCallback)

    FlickerEffect._boundObjects[object] = flicker
    return flicker
end

function FlickerEffect.isFlickering(object)
    return FlickerEffect._boundObjects[object] ~= nil
end

function FlickerEffect.stopFlickering(object)
    local boundFlicker = FlickerEffect._boundObjects[object]
    if boundFlicker then
        boundFlicker:stop()
    end
end

function FlickerEffect:constructor()
    ---
    --- @type chip.core.Actor
    ---
    self.object = nil

    ---
    --- @type number
    ---
    self.duration = nil

    ---
    --- @type number
    ---
    self.interval = nil

    ---
    --- @type boolean
    ---
    self.endVisibility = nil

    ---
    --- @type boolean
    ---
    self.forceRestart = nil

    ---
    --- @type function?
    ---
    self.completionCallback = nil

    ---
    --- @type function?
    ---
    self.progressCallback = nil

    ---
    --- @type chip.utils.Timer
    ---
    self.timer = nil
end

---
--- @param  object              chip.core.Actor
--- @param  duration            number
--- @param  interval            number?
--- @param  endVisibility       boolean?
--- @param  completionCallback  function?
--- @param  progressCallback    function?
---
function FlickerEffect:start(object, duration, interval, endVisibility, completionCallback, progressCallback)
    if endVisibility == nil then
        endVisibility = true
    end
    if not interval then
        interval = Engine.deltaTime
    end
    self.object = object
    self.duration = duration
    self.interval = interval
    self.endVisibility = endVisibility
    self.completionCallback = completionCallback
    self.progressCallback = progressCallback

    local function progFunc(tmr)
        self:_flickerProgress(tmr)
    end
    self.timer = Timer:new():start(self.interval, progFunc, math.round(self.duration / self.interval))
end

function FlickerEffect:stop()
    self.timer:stop()
    self.object:setVisibility(true)
    self:_release()
end

---
--- @protected
---
function FlickerEffect:_release()
    FlickerEffect._boundObjects[self.object] = nil
    FlickerEffect._pool:put(self)
end

---
--- @protected
--- @param  tmr  chip.utils.Timer
---
function FlickerEffect:_flickerProgress(tmr)
    self.object:setVisibility(not self.object:isVisible())
    if self.progressCallback then
        self.progressCallback(self)
    end
    if tmr:getLoops() > 0 and tmr:getLoopsLeft() == 0 then
        self.object:setVisibility(self.endVisibility)
        if self.completionCallback then
            self.completionCallback(self)
        end
        if self.timer == tmr then
            self:_release()
        end
    end
end

return FlickerEffect