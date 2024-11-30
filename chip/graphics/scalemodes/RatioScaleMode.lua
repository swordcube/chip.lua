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

local BaseScaleMode = qrequire("chip.graphics.scalemodes.BaseScaleMode")

---
--- @class chip.graphics.scalemodes.RatioScaleMode : chip.graphics.scalemodes.BaseScaleMode
---
local RatioScaleMode = BaseScaleMode:extend("RatioScaleMode", ...)

function RatioScaleMode:constructor(fillScreen)
    RatioScaleMode.super.constructor(self, fillScreen)

    self.fillScreen = fillScreen and fillScreen or false
end

function RatioScaleMode:updateGameSize(width, height)
    local ratio = Engine.gameWidth / Engine.gameHeight
    local realRatio = width / height

    local scaleY = realRatio < ratio
    if self.fillScreen then
        scaleY = not scaleY
    end

    if scaleY then
        self.gameSize.x = width
        self.gameSize.y = math.floor(self.gameSize.x / ratio)
    else
        self.gameSize.y = height
        self.gameSize.x = math.floor(self.gameSize.y * ratio)
    end
end

return RatioScaleMode