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
local function getChipImagePath(name)
    return Chip.classPath .. "/assets/images/" .. name
end

local FrameData = crequire("animation.frames.FrameData") --- @type chip.animation.frames.FrameData
local FrameCollection = crequire("animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection

---
--- @class chip.animation.frames.TileFrames : chip.animation.frames.FrameCollection
---
local TileFrames = FrameCollection:extend("TileFrames", ...)

---
--- @param  texture   chip.graphics.Texture
--- @param  tileSize  chip.math.Point
---
--- @return chip.animation.frames.TileFrames
---
function TileFrames.fromTexture(texture, tileSize)
    ---
    --- @type chip.graphics.Texture?
    ---
    local tex = Assets.getTexture(texture)
    if not tex then
        tex = Assets.getTexture(getChipImagePath("missing.png"))
        local atlas = TileFrames:new(tex) --- @type chip.animation.frames.TileFrames
        tblInsert(atlas:getFrames(), FrameData:new(
            "#_MISSING_TEXTURE_",
            0, 0, 0, 0,
            tex.width, tex.height,
            atlas:getTexture()
        ))
        return atlas
    end
    local atlas = TileFrames:new(tex) --- @type chip.animation.frames.TileFrames

    local numRows = tileSize.y == 0 and 1 or math.round((texture.height) / tileSize.y)
    local numCols = tileSize.x == 0 and 1 or math.round((texture.width) / tileSize.x)

    for j = 1, numRows do
        for i = 1, numCols do
            tblInsert(atlas:getFrames(), FrameData:new(
                "frame",
                (i - 1) * tileSize.x, (j - 1) * tileSize.y,
                0, 0, tileSize.x, tileSize.y,
                atlas:getTexture()
            ))
        end
    end

    return atlas
end

return TileFrames