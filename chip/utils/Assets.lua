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
--- @private
--- @type table<string, chip.graphics.Font>
---
Assets._fontCache = {}

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

---
--- Loads a font from a given asset ID.
---
--- @param  id  string
--- @return chip.graphics.Font
---
function Assets.getFont(id)
    if type(id) ~= "string" then
        return id
    end
    if Assets._fontCache[id] == nil then
        local newFont = Font:new() --- @type chip.graphics.Font
        Assets._fontCache[id] = newFont
    end
    return Assets._fontCache[id]
end

return Assets