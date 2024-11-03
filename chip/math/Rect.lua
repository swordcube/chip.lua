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
    return Rect:new(math.round(self.x), math.round(self.y), math.round(self.width), math.round(self.height))
end

---
--- Floors the rectangle to the nearest whole number.
---
function Rect:floor()
    return Rect:new(math.floor(self.x), math.floor(self.y), math.floor(self.width), math.floor(self.height))
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