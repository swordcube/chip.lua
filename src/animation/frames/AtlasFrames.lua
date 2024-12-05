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

local File = crequire("utils.File") --- @type chip.utils.File
local FrameData = crequire("animation.frames.FrameData") --- @type chip.animation.frames.FrameData
local FrameCollection = crequire("animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection

---
--- @class chip.animation.frames.AtlasFrames : chip.animation.frames.FrameCollection
---
local AtlasFrames = FrameCollection:extend("AtlasFrames", ...)

---
--- Returns a frame collection from a sparrow atlas.
---
--- @param  texture  chip.graphics.Texture|string
--- @param  xml      string
---
--- @return chip.animation.frames.AtlasFrames
---
function AtlasFrames.fromSparrow(texture, xmlFile)
    ---
    --- @type chip.graphics.Texture?
    ---
    local tex = Assets.getTexture(texture)

    ---
    --- @type chip.animation.frames.AtlasFrames
    ---
	local atlas = AtlasFrames:new(tex)
	local xmlContent = File.exists(xmlFile) and File.read(xmlFile) or xmlFile

	local data = Xml.parse(xmlContent)
	for _, node in ipairs(data.TextureAtlas.children) do
        if node.name == "SubTexture" then
			table.insert(atlas:getFrames(), FrameData:new(
				node.att.name,
				tonumber(node.att.x), tonumber(node.att.y),
				node.att.frameX and tonumber(node.att.frameX) or 0,
				node.att.frameY and tonumber(node.att.frameY) or 0,
				tonumber(node.att.width), tonumber(node.att.height),
				atlas:getTexture()
			))
        end
    end
	return atlas
end

return AtlasFrames