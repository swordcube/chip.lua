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
--- @private
--- @type table<string, chip.audio.AudioStream>
---
Assets._audioStreamCache = {}

---
--- Loads a texture from a given asset path.
---
--- @param  path  string
--- @return chip.graphics.Texture
---
function Assets.getTexture(path)
    if type(path) ~= "string" then
        return path
    end
    if Assets._textureCache[path] == nil then
        local newTexture = Texture:new() --- @type chip.graphics.Texture

        local imageData = love.image.newImageData(path)
        newTexture:setImage(imageData)

        Assets._textureCache[path] = newTexture
    end
    return Assets._textureCache[path]
end

---
--- Loads a font from a given asset path.
---
--- @param  path  string
--- @return chip.graphics.Font
---
function Assets.getFont(path)
    if type(path) ~= "string" then
        return path
    end
    if Assets._fontCache[path] == nil then
        local newFont = Font:new() --- @type chip.graphics.Font
        Assets._fontCache[path] = newFont
    end
    return Assets._fontCache[path]
end

---
--- Loads an audio stream from a given asset path.
---
--- @param  path  string
--- @return chip.audio.AudioStream
---
function Assets.getAudioStream(path)
    if type(path) ~= "string" then
        return path
    end
    if Assets._audioStreamCache[path] == nil then
        local newStream = AudioStream:new() --- @type chip.audio.AudioStream
        newStream:setData(love.audio.newSource(path, "static"))
        Assets._audioStreamCache[path] = newStream
    end
    return Assets._audioStreamCache[path]
end

return Assets