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
--- @class chip.animation.AnimationData
---
local AnimationData = Class:extend("AnimationData", ...)

---
---@param  name    string
---@param  frames  table<chip.animation.frames.FrameData>
---@param  fps     number
---@param  loop    boolean
---
function AnimationData:constructor(name, frames, fps, loop)
    self.name = name --- @type string
    self.fps = fps or 30.0 --- @type number
    self.loop = loop --- @type boolean
    self.curFrame = 1 --- @type integer
    self.frames = frames --- @type table<chip.animation.frames.FrameData>
    self.numFrames = #frames --- @type integer
    self.frameCount = self.numFrames --- @type integer
    self.offset = Point:new(0, 0) --- @type chip.math.Point
end

return AnimationData