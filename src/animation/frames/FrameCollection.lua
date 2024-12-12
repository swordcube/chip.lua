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

local tblInsert = table.insert

local FrameData = crequire("animation.frames.FrameData") --- @type chip.animation.frames.FrameData

---
--- @class chip.animation.frames.FrameCollection : chip.backend.RefCounted
---
local FrameCollection = RefCounted:extend("FrameCollection", ...)

---
--- @param  texture  chip.graphics.Texture|string
--- @param  frames   table<chip.animation.frames.FrameData>?
---
function FrameCollection:constructor(texture, frames)
    FrameCollection.super.constructor(self)

    ---
    --- @protected
    --- @type chip.graphics.Texture?
    ---
    self._texture = Assets.getTexture(texture)

    ---
    --- @protected
    --- @type table<chip.animation.frames.FrameData>
    ---
    self._frames = frames and frames or {}

    ---
    --- The amount of frames in this frame collection.
    ---
    --- @type integer
    ---
    self.numFrames = nil
end

function FrameCollection.fromTexture(texture)
    ---
    --- @type chip.graphics.Texture?
    ---
    local tex = Assets.getTexture(texture)

    ---
    --- @type chip.animation.frames.FrameCollection
    ---
    local atlas = FrameCollection:new(tex)
    tblInsert(atlas:getFrames(), FrameData:new(
        "#_TEXTURE_",
        0, 0, 0, 0,
        tex.width, tex.height,
        tex
    ))
    return atlas
end

function FrameCollection:free()
    for i = 1, #self._frames do
        ---
        --- @type chip.animation.frames.FrameData
        ---
        local frame = self._frames[i]
        frame:free()
    end
    self._frames = nil
end

function FrameCollection:getNumFrames()
    return #self._frames
end

function FrameCollection:getTexture()
    return self._texture
end

function FrameCollection:getFrames()
    return self._frames
end

-----------------------
--- [ Private API ] ---
-----------------------

return FrameCollection