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
--- @class chip.graphics.scalemodes.BaseScaleMode
---
local BaseScaleMode = Class:extend("BaseScaleMode", ...)

function BaseScaleMode:constructor()
    ---
    --- @type chip.math.Point
    ---
    self.deviceSize = Point:new()

    ---
    --- @type chip.math.Point
    ---
    self.gameSize = Point:new()

    ---
    --- @type chip.math.Point
    ---
    self.scale = Point:new()

    ---
    --- @type chip.math.Point
    ---
    self.offset = Point:new()

    ---
    --- @type "left"|"center"|"right"
    ---
    self.horizontalAlign = "center"

    ---
    --- @type "top"|"center"|"bottom"
    ---
    self.verticalAlign = "center"
end

function BaseScaleMode:onMeasure(width, height)
    self:updateGameSize(width, height)
    self:updateDeviceSize(width, height)
    self:updateScaleOffset()
end

function BaseScaleMode:updateGameSize(width, height)
    self.gameSize:set(width, height)
end

function BaseScaleMode:updateDeviceSize(width, height)
    self.deviceSize:set(width, height)
end

function BaseScaleMode:updateScaleOffset()
    self.scale.x = self.gameSize.x / Engine.gameWidth
    self.scale.y = self.gameSize.y / Engine.gameHeight
    self:updateOffsetX()
    self:updateOffsetY()
end

function BaseScaleMode:updateOffsetX()
    if self.horizontalAlign == "left" then
        self.offset.x = 0
    
    elseif self.horizontalAlign == "center" then
        self.offset.x = math.ceil((self.deviceSize.x - self.gameSize.x) * 0.5)
    
    elseif self.horizontalAlign == "right" then
        self.offset.x = self.deviceSize.x - self.gameSize.x
    end
end

function BaseScaleMode:updateOffsetY()
    if self.verticalAlign == "top" then
        self.offset.y = 0
    
    elseif self.verticalAlign == "center" then
        self.offset.y = math.ceil((self.deviceSize.y - self.gameSize.y) * 0.5)
    
    elseif self.verticalAlign == "bottom" then
        self.offset.y = self.deviceSize.y - self.gameSize.y
    end
end

return BaseScaleMode