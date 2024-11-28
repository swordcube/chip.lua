local gfx = love.graphics

---
--- @class chip.graphics.Text : chip.graphics.Sprite
---
local Text = Sprite:extend("Text", ...)

function Text:constructor(x, y, fieldWidth, contents)
    Text.super.constructor(self, x, y)

    ---
    --- @type chip.math.Point
    ---
    self.shadowOffset = Point:new(0, 0)

    ---
    --- @protected
    --- @type string
    ---
    self._font = nil

    ---
    --- @protected
    --- @type love.Font
    ---
    self._fontData = nil
    
    ---
    --- @protected
    --- @type string
    ---
    self._contents = contents
    
    ---
    --- @protected
    --- @type integer
    ---
    self._fieldWidth = fieldWidth or 0

    ---
    --- @protected
    --- @type integer
    ---
    self._size = 16

    ---
    --- @protected
    --- @type string
    ---
    self._alignment = "left"

    ---
    --- @protected
    --- @type number
    ---
    self._borderSize = 0

    ---
    --- @protected
    --- @type number
    ---
    self._borderQuality = 1

    ---
    --- @protected
    --- @type "outline"|"shadow"
    ---
    self._borderStyle = "outline"

    ---
    --- @protected
    --- @type chip.utils.Color
    ---
    self._borderColor = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type chip.utils.Color
    ---
    self._color = Color:new(Color.WHITE)

    ---
    --- @protected
    --- @type boolean
    ---
    self._dirty = true

    ---
    --- @protected
    --- @type love.Text?
    ---
    self._textObj = nil

    ---
    --- @protected
    --- @type love.Canvas?
    ---
    self._canvas = nil
end

---
--- @return string
---
function Text:getFont()
    return self._font
end

---
--- @param  font  string
---
function Text:setFont(font)
    self._font = font
    local fnt = Assets.getFont(self._font):getData(self._size)
    if not fnt then
        fnt = gfx.newFont(self._font, self._size, "light")
        Assets.getFont(self._font):setData(self._size, fnt)
    end
    self._fontData = fnt

    if self._textObj then
        self._textObj:setFont(self._fontData)
    else
        self._textObj = gfx.newTextBatch(self._fontData)
    end
    self._dirty = true
end

---
--- @return string
---
function Text:getContents()
    return self._contents
end

---
--- @param  contents  string
---
function Text:setContents(contents)
    self._contents = contents
    self._dirty = true
end

function Text:getFieldWidth()
    return self._fieldWidth
end

---
--- @param  width  number
---
function Text:setFieldWidth(width)
    self._fieldWidth = width
    self._dirty = true
end

function Text:getSize()
    return self._size
end

---
--- @param  size  integer
---
function Text:setSize(size)
    self._size = size
    if self._font then
        local fnt = Assets.getFont(self._font):getData(self._size)
        if not fnt then
            fnt = gfx.newFont(self._font, self._size, "light")
            Assets.getFont(self._font):setData(self._size, fnt)
        end
        self._fontData = fnt
        if self._textObj then
            self._textObj:setFont(self._fontData)
        else
            self._textObj = gfx.newTextBatch(self._fontData)
        end
    end
    self._dirty = true
end

function Text:getAlignment()
    return self._alignment
end

---
--- @param  alignment  string
---
function Text:setAlignment(alignment)
    self._alignment = alignment
    self._dirty = true
end

function Text:getBorderSize()
    return self._borderSize
end

---
--- @param  size  number
---
function Text:setBorderSize(size)
    self._borderSize = size
    self._dirty = true
end

function Text:getBorderStyle()
    return self._borderStyle
end

---
--- @param  style  "outline"|"shadow"
---
function Text:setBorderStyle(style)
    self._borderStyle = style
    self._dirty = true
end

function Text:getBorderColor()
    return self._borderColor
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setBorderColor(color)
    self._borderColor = Color:new(color)
    self._dirty = true
end

function Text:getColor()
    return self._color
end

---
--- @param  color  chip.utils.Color|integer
---
function Text:setColor(color)
    self._color = Color:new(color)
    self._dirty = true
end

function Text:getFrames()
    self:_regenTexture()
    return Text.super.getFrames(self)
end

function Text:getFrameWidth()
    self:_regenTexture()
    return Text.super.getFrameWidth(self)
end

function Text:getFrameHeight()
    self:_regenTexture()
    return Text.super.getFrameHeight(self)
end

function Text:getFrame()
    self:_regenTexture()
    return Text.super.getFrame(self)
end

function Text:draw()
    self:_regenTexture()
    return Text.super.draw(self)
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Text:_regenTexture()
    if not self._dirty then
        return
    end
    if not self._font then
        return
    end
    self._dirty = false

    if self._fieldWidth > 0 then
        self._textObj:setf(self._contents, self._fieldWidth, self._alignment)
    else
        self._textObj:setf(self._contents, math.huge, self._alignment)
    end
    if self._canvas then
        self._canvas:release()
    end
    local padding = math.floor(self._borderSize) + 2
    self._canvas = gfx.newCanvas(
        self._textObj:getWidth() + padding + (self._borderStyle == "shadow" and self.shadowOffset.x or 0.0),
        self._textObj:getHeight() + padding + (self._borderStyle == "shadow" and self.shadowOffset.y or 0.0)
    )
    local prevCanvas = gfx.getCanvas()
    gfx.setCanvas(self._canvas)

    local tx, ty = padding * 0.5, padding * 0.5
    local pr, pg, pb, pa = gfx.getColor()

    if self._borderSize > 0 and self._borderColor.a > 0 then
        if self._borderStyle == "outline" then
            local iterations = math.round(self._borderSize * self._borderQuality)
            if iterations < 1 then
                iterations = 1
            end
            
            local delta = self._borderSize / iterations
            local curDelta = delta
        
            gfx.setColor(self._borderColor.r, self._borderColor.g, self._borderColor.b, self._borderColor.a)
        
            for _ = 1, iterations do
                -- upper-left
                gfx.draw(self._textObj, tx - curDelta, ty - curDelta, 0)
                
                -- upper-middle
                gfx.draw(self._textObj, tx, ty - curDelta, 0)
        
                -- upper-right
                gfx.draw(self._textObj, tx + curDelta, ty - curDelta, 0)
        
                -- middle-right
                gfx.draw(self._textObj, tx + curDelta, ty, 0)
        
                -- lower-right
                gfx.draw(self._textObj, tx + curDelta, ty + curDelta, 0)
        
                -- lower-middle
                gfx.draw(self._textObj, tx, ty + curDelta, 0)
        
                -- lower-left
                gfx.draw(self._textObj, tx - curDelta, ty + curDelta, 0)
                
                curDelta = curDelta + delta
            end
            
        elseif self.borderStyle == "shadow" then
            gfx.setColor(self._borderColor.r, self._borderColor.g, self._borderColor.b, self._borderColor.a)
            gfx.draw(
                self._textObj, 
                tx + (self.shadowOffset.x * self.borderSize), ty + (self.shadowOffset.y * self.borderSize), 0
            )
        end
    end
    
    gfx.setColor(self._color.r, self._color.g, self._color.b, self._color.a)
    gfx.draw(self._textObj, tx, ty, 0)
    
    gfx.setColor(pr, pg, pb, pa)
    gfx.setCanvas(prevCanvas)

    ---
    --- @type chip.graphics.Texture
    ---
    local tex = self:getTexture()
    if not tex then
        tex = Texture:new()
        tex:setImage(gfx.newImage(love.image.newImageData(1, 1)))
        self:loadTexture(tex)
    end
    local img = gfx.newImage(gfx.readbackTexture(self._canvas))
    tex:setImage(img)

    ---
    --- @type chip.animation.frames.FrameData
    ---
    local frame = self:getFrame()
    frame.width = tex.width
    frame.height = tex.height

    ---
    --- @type love.Quad
    ---
    local quad = frame.quad
    quad:setViewport(0, 0, tex.width, tex.height, tex.width, tex.height)
end

function Text:dispose()
    if self._canvas then
        self._canvas:release()
        self._canvas = nil
    end
    if self._textObj then
        self._textObj:release()
        self._textObj = nil
    end
    Text.super.dispose(self)
end

return Text