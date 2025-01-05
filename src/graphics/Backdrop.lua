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

---
--- @class chip.graphics.Backdrop : chip.graphics.Sprite
--- 
--- A simple class for creating scrolling & repeating backdrops.
---
local Backdrop = Sprite:extend("Backdrop", ...)

function Backdrop:constructor(x, y, repeatAmountX, repeatAmountY)
    Backdrop.super.constructor(self, x, y)

    self.repeatAmount = Point:new(repeatAmountX, repeatAmountY) --- @type chip.math.Point
    self.spacing = Point:new(0, 0) --- @type chip.math.Point
    self.velocity = Point:new(0, 0) --- @type chip.math.Point

    ---
    --- @protected
    ---
    self._backdropOffset = Point:new(0, 0) --- @type chip.math.Point

    ---
    --- @protected
    ---
    self._moves = false
end

function Backdrop:update(dt)
    local offset = self._backdropOffset
    offset:add(self.velocity.x * dt, self.velocity.y * dt)

    local width, height = self:getWidth() + self.spacing.x, self:getHeight() + self.spacing.y

    if offset.x < -width or offset.x > width then
        offset.x = 0
    end
    if offset.y < -height or offset.y > height then
        offset.y = 0
    end
    Backdrop.super.update(self, dt)
end

function Backdrop:draw()
    local superDraw = Backdrop.super.draw

    local prevX, prevY, offset = self._x, self._y, self._backdropOffset
    local repeatAmountX, repeatAmountY = math.floor(self.repeatAmount.x), math.floor(self.repeatAmount.y)
    
    for i = 1, repeatAmountX do
        for j = 1, repeatAmountY do
            self._x = prevX + offset.x + ((i - 1) * (self:getWidth() + self.spacing.x))
            self._y = prevY + offset.y + ((j - 1) * (self:getHeight() + self.spacing.y))
            superDraw(self)
        end
    end

    self._x, self._y = prevX, prevY
end

return Backdrop