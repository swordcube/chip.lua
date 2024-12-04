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
--- @diagnostic disable: invisible
--- @class chip.utils.SpriteUtil
---
local SpriteUtil = Class:extend("SpriteUtil", ...)

function SpriteUtil.makeRectangle(width, height, color)
    color = Color:new(color)
	local key = "#_RECTANGLE_"..width..":"..height..":"..tostring(color)
	if not Assets._textureCache[key] then
        local result = love.image.newImageData(width, height)
        if width == 1 and height == 1 then
            result:setPixel(
                0, 0,
                color.r, color.g, color.b, 1
            )
        end
        for x = 0, width - 1 do
            for y = 0, height - 1 do
                result:setPixel(
                    x, y,
                    color.r, color.g, color.b, 1
                )
            end
        end
        local newTexture = Texture:new() --- @type chip.graphics.Texture
        newTexture:setImage(love.graphics.newImage(result), result)
        Assets._textureCache[key] = newTexture
	end
	return Assets._textureCache[key]
end

function SpriteUtil.makeGradient(horizontal, fromColor, toColor, width, height)
    fromColor = Color:new(fromColor)
    toColor = Color:new(toColor)
    
    local key = "#_GRADIENT_" .. (horizontal and "H" or "V") .. tostring(fromColor) .. ":" .. tostring(toColor) .. ":" .. width .. ":" .. height
    if not Assets._textureCache[key] then
        local result = love.image.newImageData(width, height)
        for x = 0, width - 1 do
            for y = 0, height - 1 do
                local ratio = horizontal and (x / width) or (y / height)
                result:setPixel(
                    x, y,
                    math.lerp(fromColor.r, toColor.r, ratio),
                    math.lerp(fromColor.g, toColor.g, ratio),
                    math.lerp(fromColor.b, toColor.b, ratio),
                    math.lerp(fromColor.a, toColor.a, ratio)
                )
            end
        end
        local newTexture = Texture:new() --- @type chip.graphics.Texture
        newTexture:setImage(love.graphics.newImage(result), result)
        Assets._textureCache[key] = newTexture
    end
    return Assets._textureCache[key]
end

return SpriteUtil