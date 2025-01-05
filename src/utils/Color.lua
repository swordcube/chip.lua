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

local lerp = math.lerp

local Bit = crequire("utils.Bit") --- @type chip.utils.Bit

---
--- A simple class storing RGBA values for a color.
---
--- @class chip.utils.Color
---
local Color = Class:extend("Color", ...)

function Color:constructor(data)
	---
	--- The value of the red channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.r = 0.0

	---
	--- The value of the green channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.g = 0.0

	---
	--- The value of the blue channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.b = 0.0

	---
	--- The value of the alpha channel for this color.
	--- Ranges from 0.0 to 1.0.
	---
	self.a = 0.0

    if data then
        local t = type(data)
        if t == "string" then
            self.r, self.g, self.b, self.a = self.intToRGB(tonumber(data:replace("#", "0x")))
        elseif t == "number" or t == "integer" then
            self.r, self.g, self.b, self.a = self.intToRGB(data)
        elseif t == "table" then
            self.r, self.g, self.b, self.a = data.r, data.g, data.b, data.a
        else
            print("Cannot convert type: " .. t .. " into a color!")
        end
    end
end

function Color:interpolate(other, ratio)
	return Color:new({
		r = lerp(self.r, other.r, ratio),
		g = lerp(self.g, other.g, ratio),
		b = lerp(self.b, other.b, ratio),
		a = lerp(self.a, other.a, ratio)
	})
end

function Color:copyFrom(other)
    self.r = other.r
    self.g = other.g
    self.b = other.b
    self.a = other.a
    return self
end

function Color.intToRGB(int)
	return
		Bit.band(Bit.rshift(int, 16), 0xFF) / 255,
		Bit.band(Bit.rshift(int, 8), 0xFF) / 255,
		Bit.band(int, 0xFF) / 255,
		Bit.band(Bit.rshift(int, 24), 0xFF) / 255
end

function Color.intToRGB255(int)
	return
		Bit.band(Bit.rshift(int, 16), 0xFF),
		Bit.band(Bit.rshift(int, 8), 0xFF),
		Bit.band(int, 0xFF),
		Bit.band(Bit.rshift(int, 24), 0xFF)
end

function Color:__tostring()
	return "color (r: " .. self.r .. ", g: " .. self.g .. ", b: " .. self.b .. ", a: " .. self.a .. ")"
end

Color.TRANSPARENT = Color:new(0x00000000)
Color.WHITE       = Color:new(0xFFFFFFFF)
Color.GRAY        = Color:new(0xFF808080)
Color.BLACK       = Color:new(0xFF000000)
Color.RED         = Color:new(0xFFFF0000)
Color.ORANGE      = Color:new(0xFFFFA500)
Color.YELLOW      = Color:new(0xFFFFFF00)
Color.LIME        = Color:new(0xFF00FF00)
Color.GREEN       = Color:new(0xFF008000)
Color.CYAN        = Color:new(0xFF00FFFF)
Color.BLUE        = Color:new(0xFF0000FF)
Color.PURPLE      = Color:new(0xFF800080)
Color.MAGENTA     = Color:new(0xFFFF00FF)
Color.PINK        = Color:new(0xFFFFC0CB)
Color.BROWN       = Color:new(0xFF8B4513)

return Color