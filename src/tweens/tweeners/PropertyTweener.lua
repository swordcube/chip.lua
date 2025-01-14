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

local min = math.min
local lerp = math.lerp

local Ease = crequire("tweens.Ease") --- @type chip.tweens.Ease
local Tweener = crequire("tweens.tweeners.Tweener") --- @type chip.tweens.tweeners.Tweener

---
--- @class chip.tweens.tweeners.PropertyTweener : chip.tweens.tweeners.Tweener
---
local PropertyTweener = Tweener:extend("PropertyTweener", ...)

function PropertyTweener:constructor(parent, object, property, initialValue, finalValue, duration, ease)
    PropertyTweener.super.constructor(self, parent)

    ---
    --- @protected
    --- @type table
    ---
    self._object = object

    ---
    --- @protected
    --- @type string
    ---
    self._property = property

    ---
    --- @protected
    --- @type number|table
    ---
    self._initialValue = initialValue

    ---
    --- @protected
    --- @type number|table
    ---
    self._finalValue = finalValue

    ---
    --- @protected
    --- @type function
    ---
    self._ease = ease

    ---
    --- @protected
    --- @type number
    ---
    self._startDelay = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = 0.0

    ---
    --- @protected
    --- @type number
    ---
    self._duration = duration

    ---
    --- @protected
    --- @type boolean
    ---
    self._started = false
end

function PropertyTweener:getObject()
    return self._object
end

function PropertyTweener:setObject(object)
    self._object = object
    return self
end

function PropertyTweener:getProperty()
    return self._property
end

function PropertyTweener:setProperty(property)
    self._property = property
    return self
end

function PropertyTweener:getInitialValue()
    return self._initialValue
end

function PropertyTweener:setInitialValue(initialValue)
    self._initialValue = initialValue
    return self
end

function PropertyTweener:getFinalValue()
    return self._finalValue
end

function PropertyTweener:setFinalValue(finalValue)
    self._finalValue = finalValue
    return self
end

function PropertyTweener:getDuration()
    return self._duration + self._startDelay
end

function PropertyTweener:setDuration(duration)
    self._duration = duration
    return self
end

function PropertyTweener:getProgress()
    if self._elapsedTime <= self._startDelay then
        return 0.0
    end
    return min((self._elapsedTime - self._startDelay) / self._duration, 1.0)
end

function PropertyTweener:getEase()
    return self._ease
end

function PropertyTweener:setEase(ease)
    self._ease = ease
    return self
end

function PropertyTweener:getStartDelay()
    return self._startDelay
end

function PropertyTweener:setStartDelay(secs)
    self._startDelay = secs
    return self
end

function PropertyTweener:update(dt)
    if self._parent._freed then
        self:free()
        self._parent._tweeners:remove(self)
        return
    end
    if self._duration <= 0.0 then
        return
    end
    self._elapsedTime = self._elapsedTime + dt
    local progress = self:getProgress()

    if self._elapsedTime >= self._startDelay then
        if not self._started then
            local obj = self._object
            local property = self._property

            local initialValue = obj["_" .. property]
            local finalValue = self._finalValue

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
            self._initialValue = initialValue
            self._started = true
        end
        local e = self._ease or (self._parent:getEase() and self._parent.ease or Ease.linear)
        if type(self._finalValue) == "table" then
            local prop = self._object[self._property]
            for key, value in pairs(self._finalValue) do
                if type(value) == "number" then
                    local val = lerp(self._initialValue[key], value, e(progress))
                    if prop["_" .. key] ~= nil then
                        prop["_" .. key] = val
                    else
                        prop[key] = val
                    end
                end
            end
        else
            local val = lerp(self._initialValue, self._finalValue, e(progress))
            if self._object["_" .. self._property] ~= nil then
                self._object["_" .. self._property] = val
            else
                self._object[self._property] = val
            end
        end
        if self._onUpdate then
            self._onUpdate(self)
        end
        if progress >= 1.0 then
            self._duration = 0.0
            self._elapsedTime = 0.0

            if self._onComplete then
                self._onComplete(self)
            end
        end
    else
        self._started = false
    end
end

return PropertyTweener