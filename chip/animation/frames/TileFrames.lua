local FrameData = qrequire("chip.animation.frames.FrameData") --- @type chip.animation.frames.FrameData
local FrameCollection = qrequire("chip.animation.frames.FrameCollection") --- @type chip.animation.frames.FrameCollection

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

    ---
    --- @type chip.animation.frames.TileFrames
    ---
    local atlas = TileFrames:new(tex)

    local numRows = tileSize.y == 0 and 1 or math.round((texture.height) / tileSize.x)
    local numCols = tileSize.x == 0 and 1 or math.round((texture.width) / tileSize.y)

    for j = 1, numRows do
        for i = 1, numCols do
            table.insert(atlas.frames, FrameData:new(
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