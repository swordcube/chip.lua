---
--- @class chip.utils.Assets
---
local Assets = Class:extend("Assets", ...)

---
--- @private
--- @type table<string, chip.graphics.Texture>
---
Assets._textureCache = {}

---
--- Returns a file path from a given asset ID.
---
--- @param  id  string
--- @return string
---
function Assets.getPath(id)
    -- TODO: the shit.
    return id
end

---
--- Loads a texture from a given asset ID.
---
--- @param  id  string
--- @return chip.graphics.Texture
---
function Assets.getTexture(id)
    if type(id) ~= "string" then
        return id
    end
    if Assets._textureCache[id] == nil then
        local newTexture = Texture:new() --- @type chip.graphics.Texture
        newTexture:setImage(love.graphics.newImage(Assets.getPath(id)))
        Assets._textureCache[id] = newTexture
    end
    return Assets._textureCache[id]
end

return Assets