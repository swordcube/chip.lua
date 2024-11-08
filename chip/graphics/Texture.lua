---
--- @diagnostic disable: invisible
--- @class chip.graphics.Texture : chip.backend.RefCounted
--- 
--- A class representing a texture/image.
--- 
--- You should load these from the `Assets` class
--- under the `chip.utils` package.
---
local Texture = RefCounted:extend("RefCounted", ...)

function Texture:constructor()
    Texture.super.constructor(self)

    ---
    --- The width of this texture. (in pixels)
    ---
    self.width = 0 --- @type integer

    ---
    --- The height of this texture. (in pixels)
    ---
    self.height = 0 --- @type integer

    ---
    --- @protected
    --- @type love.Image
    ---
    self._image = nil
end

function Texture:free()
    self._image:release()
    self._image = nil

    self.width = 0
    self.height = 0

    for key, value in pairs(Assets._textureCache) do
        if value == self then
            Assets._textureCache[key] = nil
        end
    end
end

function Texture:getImage()
    return self._image
end

---
--- @param  val  love.Image
---
function Texture:setImage(val)
    self._image = val
    self.width = val:getWidth()
    self.height = val:getHeight()
end

--- [ PRIVATE API ] ---

return Texture