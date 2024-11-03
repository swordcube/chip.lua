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