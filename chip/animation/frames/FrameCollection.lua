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
    table.insert(atlas._frames, FrameData:new(
        "#_TEXTURE_",
        0, 0, 0, 0,
        tex.width, tex.height,
        tex
    ))
    return atlas
end

function FrameCollection:dispose()
    for i = 1, #self._frames do
        ---
        --- @type chip.animation.frames.FrameData
        ---
        local frame = self._frames[i]
        frame:dispose()
    end
    self._frames = nil
end

function FrameCollection:getNumFrames()
    return #self.frames
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