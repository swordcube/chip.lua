---
--- @class chip.math.Point
---
--- A basic class for storing a 2D point.
---
local Point = Class:extend("Point", ...)

function Point:constructor(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
end

---
--- Rounds the point to the nearest whole number.
---
function Point:round()
    return Point:new(math.round(self.x), math.round(self.y))
end

---
--- Floors the point to the nearest whole number.
---
function Point:floor()
    return Point:new(math.floor(self.x), math.floor(self.y))
end

---
--- Copies the components of the given point to this point.
--- 
--- @param  vec  flora.math.Point  The point to copy.
---
function Point:copyFrom(vec)
    self.x = vec.x
    self.y = vec.y
    return self
end

---
--- Sets the components of this point to given values.
--- 
--- @param  x  number?  The new value for the X component
--- @param  y  number?  The new value for the Y component
---
function Point:set(x, y)
    self.x = x and x or 0.0
    self.y = y and y or 0.0
    return self
end

---
--- Adds two values to this point.
---
function Point:add(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

---
--- Subtracts two values from this point.
---
function Point:subtract(x, y)
    self.x = self.x - x
    self.y = self.y - y
    return self
end

---
--- Multiplies two values to this point.
---
function Point:multiply(x, y)
    self.x = self.x * x
    self.y = self.y * y
    return self
end

---
--- Divides two values from this point.
---
function Point:divide(x, y)
    self.x = self.x / x
    self.y = self.y / y
    return self
end

---
--- Mods two values to this point.
---
function Point:modulo(x, y)
    self.x = self.x % x
    self.y = self.y % y
    return self
end

---
--- Pows two values to this point.
---
function Point:pow(x, y)
    self.x = self.x ^ x
    self.y = self.y ^ y
    return self
end

---
--- Returns a string representation of this point.
---
function Point:__tostring()
    return "Point(" .. self.x .. ", " .. self.y .. ")"
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- Adds two points and returns the result.
---
function Point.__add(a, b)
    return a:add(b.x, b.y)
end

---
--- Subtracts two points and returns the result.
---
function Point.__sub(a, b)
    return a:subtract(b.x, b.y)
end

---
--- Multiplies two points and returns the result.
---
function Point.__mul(a, b)
    return a:multiply(b.x, b.y)
end

---
--- Divides two points and returns the result.
---
function Point.__div(a, b)
    return a:divide(b.x, b.y)
end

---
--- Negates two points and returns the result.
---
function Point.__unm(a)
    a.x = -a.x
    a.y = -a.y
    return a
end

---
--- Modulos two points and returns the result.
---
function Point.__mod(a, b)
    return a:modulo(b.x, b.y)
end

---
--- Pows two points and returns the result.
---
function Point.__pow(a, b)
    return a:pow(b.x, b.y)
end

return Point