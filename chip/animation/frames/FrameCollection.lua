local FrameData = qrequire("chip.animation.frames.FrameData") --- @type chip.animation.frames.FrameData

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
    --- @type chip.graphics.Texture?
    ---
    self.texture = Assets.getTexture(texture)

    ---
    --- @type table<chip.animation.frames.FrameData>
    ---
    self.frames = frames and frames or {}

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
    table.insert(atlas.frames, FrameData:new(
        "#_TEXTURE_",
        0, 0, 0, 0,
        tex.width, tex.height,
        tex
    ))
    return atlas
end

function FrameCollection:dispose()
    for i = 1, #self.frames do
        ---
        --- @type chip.animation.frames.FrameData
        ---
        local frame = self.frames[i]
        frame:dispose()
    end
    self.frames = nil
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function FrameCollection:get_numFrames()
    return #self.frames
end

return FrameCollection