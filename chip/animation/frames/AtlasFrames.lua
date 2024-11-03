local File = qrequire("chip.utils.File") --- @type chip.utils.File
local FrameData = qrequire("chip.animation.frames.FrameData") --- @type chip.animation.frames.FrameData
local FrameCollection = qrequire("chip.animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection

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
			table.insert(atlas.frames, FrameData:new(
				node.att.name,
				tonumber(node.att.x), tonumber(node.att.y),
				node.att.frameX and tonumber(node.att.frameX) or 0,
				node.att.frameY and tonumber(node.att.frameY) or 0,
				tonumber(node.att.width), tonumber(node.att.height),
				atlas.texture
			))
        end
    end
	return atlas
end

return AtlasFrames