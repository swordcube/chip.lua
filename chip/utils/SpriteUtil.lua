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
        for x = 0, width - 1 do
            for y = 0, height - 1 do
                result:setPixel(
                    x, y,
                    color.r, color.g, color.b, 1
                )
            end
        end
        local newTexture = Texture:new() --- @type chip.graphics.Texture
        newTexture:setImage(love.graphics.newImage(result))
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
        newTexture:setImage(love.graphics.newImage(result))
        Assets._textureCache[key] = newTexture
    end
    return Assets._textureCache[key]
end

return SpriteUtil