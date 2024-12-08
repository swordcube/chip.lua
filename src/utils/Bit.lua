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

local fmod = math.fmod
local floor = math.floor

---
--- @class chip.utils.Bit
---
local Bit = Class:extend("Bit", ...)

function Bit.lshift(x, by)
    return x * 2 ^ by
end

function Bit.rshift(x, by)
    return floor(x / 2 ^ by)
end

function Bit.band(x, y)
    local p = 1
    local result = 0
    while x > 0 and y > 0 do
        local rx = x % 2
        local ry = y % 2
        if rx == 1 and ry == 1 then
            result = result + p
        end
        p = p * 2
        x = floor(x / 2)
        y = floor(y / 2)
    end
    return result
end

function Bit.bor(x, y)
    local p = 1
    local result = 0
    while x > 0 or y > 0 do
        local rx = x % 2
        local ry = y % 2
        if rx == 1 or ry == 1 then
            result = result + p
        end
        p = p * 2
        x = floor(x / 2)
        y = floor(y / 2)
    end
    return result
end

function Bit.to_hex(num)
    local hexstr = '0123456789abcdef'
    local s = ''
    while num > 0 do
        local mod = fmod(num, 16)
        s = hexstr:sub(mod+1, mod+1) .. s
        num = floor(num / 16)
    end
    if s == '' then s = '0' end
    return s
end

function Bit.to_Bit(num)
    num = Bit.band(num, 0xffffffff)
    if num >= 0x80000000 then
      num = num - 0x100000000
    end
    return num
end

return Bit