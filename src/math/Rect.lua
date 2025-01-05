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

local round = math.round
local floor = math.floor

local deg = math.deg
local rad = math.rad

local sin = math.sin
local cos = math.cos

local abs = math.abs

---
--- @class chip.math.Rect
---
--- A basic class for storing a 2D rectangle.
---
local Rect = Class:extend("Rect", ...)

function Rect:constructor(x, y, width, height)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
    self.width = width and width or 0.0
    self.height = height and height or 0.0
end

---
--- Rounds the rectangle to the nearest whole number.
---
function Rect:round()
    return Rect:new(round(self.x), round(self.y), round(self.width), round(self.height))
end

---
--- Floors the rectangle to the nearest whole number.
---
function Rect:floor()
    return Rect:new(floor(self.x), floor(self.y), floor(self.width), floor(self.height))
end

---
--- Copies the components of the given rectangle to this rectangle.
--- 
--- @param  vec  chip.math.Rect  The rectangle to copy.
---
function Rect:copyFrom(vec)
    self.x = vec.x
    self.y = vec.y
    self.width = vec.width
    self.height = vec.height
    return self
end

function Rect:setPosition(x, y)
    self.x = x
    self.y = y
    return self
end

function Rect:setSize(width, height)
    self.width = width
    self.height = height
    return self
end

function Rect:getRotatedBounds(radians, origin, newRect)
    if not origin then
        origin = Point:new(0.0, 0.0)
    end
    if not newRect then
        newRect = Rect:new()
    end
    local degrees = deg(radians) % 360
    if degrees == 0 then
        return newRect:set(self.x, self.y, self.width, self.height)
    end
    if degrees < 0 then
        degrees = degrees + 360
    end
    radians = rad(degrees)
    
    local cos = cos(radians)
    local sin = sin(radians)

    local left = -origin.x
    local top = -origin.y
    local right = -origin.x + self.width
    local bottom = -origin.y + self.height

    if degrees < 90 then
        newRect.x = self.x + origin.x + cos * left - sin * bottom
        newRect.y = self.y + origin.y + sin * left + cos * top
    elseif degrees < 180 then
        newRect.x = self.x + origin.x + cos * right - sin * bottom
        newRect.y = self.y + origin.y + sin * left  + cos * bottom
    elseif degrees < 270 then
        newRect.x = self.x + origin.x + cos * right - sin * top
        newRect.y = self.y + origin.y + sin * right + cos * bottom
    else
        newRect.x = self.x + origin.x + cos * left - sin * top
        newRect.y = self.y + origin.y + sin * right + cos * top
    end
    local newHeight = abs(cos * self.height) + abs(sin * self.width)
    newRect.width = abs(cos * self.width) + abs(sin * self.height)
    newRect.height = newHeight
    return newRect
end

---
--- Sets the components of this rectangle to given values.
--- 
--- @param  x       number?  The new value for the X component
--- @param  y       number?  The new value for the Y component
--- @param  width   number?  The new value for the width
--- @param  height  number?  The new value for the height
---
function Rect:set(x, y, width, height)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
    self.width = width and width or 0.0
    self.height = height and height or 0.0
    return self
end

---
--- Adds 4 values to this rectangle.
---
function Rect:add(x, y, width, height)
    self.x = self.x + x
    self.y = self.y + y
    self.width = self.width + width
    self.height = self.height + height
    return self
end

---
--- Subtracts 4 values from this rectangle.
---
function Rect:subtract(x, y, width, height)
    self.x = self.x - x
    self.y = self.y - y
    self.width = self.width - width
    self.height = self.height - height
    return self
end

---
--- Multiplies 4 values to this rectangle.
---
function Rect:multiply(x, y, width, height)
    self.x = self.x * x
    self.y = self.y * y
    self.width = self.width * width
    self.height = self.height * height
    return self
end

---
--- Divides 4 values from this rectangle.
---
function Rect:divide(x, y, width, height)
    self.x = self.x / x
    self.y = self.y / y
    self.width = self.width / width
    self.height = self.height / height
    return self
end

---
--- Mods 4 values to this rectangle.
---
function Rect:modulo(x, y, width, height)
    self.x = self.x % x
    self.y = self.y % y
    self.width = self.width % width
    self.height = self.height % height
    return self
end

---
--- Pows 4 values to this rectangle.
---
function Rect:pow(x, y, width, height)
    self.x = self.x ^ x
    self.y = self.y ^ y
    self.width = self.width ^ width
    self.height = self.height ^ height
    return self
end

function Rect:getLeft()
    return self.x
end

function Rect:setLeft(value)
    self.width = self.width - (value - self.x)
    self.x = value
end

function Rect:getRight()
    return self.x + self.width
end

function Rect:setRight(value)
    self.width = value - self.x
end

function Rect:getTop()
    return self.y
end

function Rect:setTop(value)
    self.height = self.height - (value - self.y)
    self.y = value
end

function Rect:getBottom()
    return self.y + self.height
end

function Rect:setRight(value)
    self.height = value - self.y
end

function Rect:isEmpty()
    return self.width == 0 or self.height == 0
end

---
--- @param rect     chip.math.Rect  The rectangle to check intersection against
--- @param result?  chip.math.Rect  The resulting rectangle
---
--- @return chip.math.Rect
---
function Rect:intersection(rect, result)
    if not result then
        result = Rect:new()
    end
    local x0 = (self.x < rect.x) and rect.x or self.x
    local x1 = (self:getRight() > rect:getRight()) and rect:getRight() or self:getRight()
    local y0 = (self.y < rect.y) and rect.y or self.y
    local y1 = (self:getBottom() > rect:getBottom()) and rect:getBottom() or self:getBottom()
    
    if x1 <= x0 or y1 <= y0 then
        return result:set(0, 0, 0, 0)
    end
    return result:set(x0, y0, x1 - x0, y1 - y0)
end

---
--- Returns a string representation of this rectangle.
---
function Rect:__tostring()
    return "Rect(" .. self.x .. ", " .. self.y .. ", " .. self.width .. ", " .. self.height .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- Adds two rectangles and returns the result.
---
function Rect.__add(a, b)
    return a:add(b.x, b.y, b.width, b.height)
end

---
--- Subtracts two rectangles and returns the result.
---
function Rect.__sub(a, b)
    return a:subtract(b.x, b.y, b.width, b.height)
end

---
--- Multiplies two rectangles and returns the result.
---
function Rect.__mul(a, b)
    return a:multiply(b.x, b.y, b.width, b.height)
end

---
--- Divides two rectangles and returns the result.
---
function Rect.__div(a, b)
    return a:divide(b.x, b.y, b.width, b.height)
end

---
--- Negates a given rectangle and returns the result.
---
function Rect.__unm(a)
    a.x = -a.x
    a.y = -a.y
    a.width = -a.width
    a.height = -a.height
    return a
end

---
--- Modulos two rectangles and returns the result.
---
function Rect.__mod(a, b)
    return a:modulo(b.x, b.y, b.width, b.height)
end

---
--- Pows two rectangles and returns the result.
---
function Rect.__pow(a, b)
    return a:pow(b.x, b.y, b.width, b.height)
end

return Rect