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

local pi = math.pi
local b1 = 1 / 2.75
local b2 = 2 / 2.75
local b3 = 1.5 / 2.75
local b4 = 2.5 / 2.75
local b5 = 2.25 / 2.75
local b6 = 2.625 / 2.75
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local pow = math.pow

---
--- A list of easing functions for tweening.
---
--- @class chip.tweens.Ease
--- @see   flixel.tweens.FlxEase  https://github.com/HaxeFlixel/flixel/blob/master/flixel/tweens/FlxEase.hx
---
local Ease = {}

function Ease.linear(t)
    return t
end

function Ease.quadIn(t)
    return t * t
end

function Ease.quadOut(t)
    return -t * (t - 2)
end

function Ease.quadInOut(t)
    if t <= .5 then
        return t * t * 2
    else
        t = t - 1
        return 1 - t * t * 2
    end
end

function Ease.cubeIn(t)
    return t * t * t
end

function Ease.cubeOut(t)
    t = t - 1
    return 1 + t * t * t
end

function Ease.cubeInOut(t)
    if t <= .5 then
        return t * t * t * 4
    else
        t = t - 1
        return 1 + t * t * t * 4
    end
end

function Ease.quartIn(t)
    return t * t * t * t
end

function Ease.quartOut(t)
    t = t - 1
    return 1 - t * t * t * t
end

function Ease.quartInOut(t)
    if t <= .5 then
        return t * t * t * t * 8
    else
        t = t * 2 - 2
        return (1 - t * t * t * t) / 2 + .5
    end
end

function Ease.quintIn(t)
    return t * t * t * t * t
end

function Ease.quintOut(t)
    t = t - 1
    return t * t * t * t * t + 1
end

function Ease.quintInOut(t)
    t = t * 2
    if t < 1 then
        return (t * t * t * t * t) / 2
    else
        t = t - 2
        return (t * t * t * t * t + 2) / 2
    end
end

function Ease.sineIn(t)
    return -cos(pi / 2 * t) + 1
end

function Ease.sineOut(t)
    return sin(pi / 2 * t)
end

function Ease.sineInOut(t)
    return -cos(pi * t) / 2 + .5
end

function Ease.bounceIn(t)
    t = 1 - t
    if t < b1 then return 1 - 7.5625 * t * t end
    if t < b2 then return 1 - (7.5625 * (t - b3) * (t - b3) + .75) end
    if t < b4 then return 1 - (7.5625 * (t - b5) * (t - b5) + .9375) end
    return 1 - (7.5625 * (t - b6) * (t - b6) + .984375)
end

function Ease.bounceOut(t)
    if t < b1 then return 7.5625 * t * t end
    if t < b2 then return 7.5625 * (t - b3) * (t - b3) + .75 end
    if t < b4 then return 7.5625 * (t - b5) * (t - b5) + .9375 end
    return 7.5625 * (t - b6) * (t - b6) + .984375
end

function Ease.bounceInOut(t)
    if t < .5 then
        t = 1 - t * 2
        if t < b1 then return (1 - 7.5625 * t * t) / 2 end
        if t < b2 then return (1 - (7.5625 * (t - b3) * (t - b3) + .75)) / 2 end
        if t < b4 then return (1 - (7.5625 * (t - b5) * (t - b5) + .9375)) / 2 end
        return (1 - (7.5625 * (t - b6) * (t - b6) + .984375)) / 2
    else
        t = t * 2 - 1
        if t < b1 then return (7.5625 * t * t) / 2 + .5 end
        if t < b2 then return (7.5625 * (t - b3) * (t - b3) + .75) / 2 + .5 end
        if t < b4 then return (7.5625 * (t - b5) * (t - b5) + .9375) / 2 + .5 end
        return (7.5625 * (t - b6) * (t - b6) + .984375) / 2 + .5
    end
end

function Ease.circIn(t)
    return -(sqrt(1 - t * t) - 1)
end

function Ease.circOut(t)
    return sqrt(1 - (t - 1) * (t - 1))
end

function Ease.circInOut(t)
    if t <= .5 then
        return (sqrt(1 - t * t * 4) - 1) / -2
    else
        return (sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2
    end
end

function Ease.expoIn(t)
    return pow(2, 10 * (t - 1))
end

function Ease.expoOut(t)
    return -pow(2, -10 * t) + 1
end

function Ease.expoInOut(t)
    if t < .5 then
        return pow(2, 10 * (t * 2 - 1)) / 2
    else
        return (-pow(2, -10 * (t * 2 - 1)) + 2) / 2
    end
end

function Ease.backIn(t)
    return t * t * (2.70158 * t - 1.70158)
end

function Ease.backOut(t)
    t = t - 1
    return 1 - t * t * (-2.70158 * t - 1.70158)
end

function Ease.backInOut(t)
    t = t * 2
    if t < 1 then return t * t * (2.70158 * t - 1.70158) / 2 end
    t = t - 2
    return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + .5
end

return Ease
