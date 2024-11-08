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

function AnimationData:free()
    for i = 1, #self.frames do
        local frame = self.frames[i] --- @type chip.animation.frames.FrameData
        frame:free()
    end
end

return AnimationData