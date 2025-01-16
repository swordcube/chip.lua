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

local function getImagePath(name)
    return Chip.classPath .. "/assets/images/" .. name
end
local abs = math.abs

local mouse = love.mouse

---
--- @class chip.graphics.MouseCursor
---
local MouseCursor = {}

---
--- @protected
---
MouseCursor._sprite = nil --- @type chip.graphics.Sprite

---
--- @protected
---
MouseCursor._usingSystemCursor = false --- @type boolean

---
--- @protected
---
MouseCursor._visible = true --- @type boolean

---
--- @protected
---
MouseCursor._worldX = 0.0 --- @type number

---
--- @protected
---
MouseCursor._worldY = 0.0 --- @type number

---
--- @protected
---
MouseCursor._deltaX = 0.0 --- @type number

---
--- @protected
---
MouseCursor._deltaY = 0.0 --- @type number

---
--- @protected
---
MouseCursor._screenDeltaX = 0.0 --- @type number

---
--- @protected
---
MouseCursor._screenDeltaY = 0.0 --- @type number

---
--- @protected
---
MouseCursor._point = Point:new() --- @type chip.math.Point

function MouseCursor.init()
    MouseCursor._sprite = Sprite:new()
    MouseCursor._sprite.isOnScreen = function(_)
        return true
    end
    MouseCursor.loadDefaultTexture()
    MouseCursor.useSoftwareCursor()

    Engine.postUpdate:connect(MouseCursor._postUpdate)
    Engine.onInputReceived:connect(MouseCursor._input)
end

---
--- Returns the sprite used to draw the mouse
--- cursor to the screen.
--- 
--- You can use this to apply animation, fancy effects, etc
--- to the mouse cursor.
---
--- @return chip.graphics.Sprite
---
function MouseCursor.getSprite()
    return MouseCursor._sprite
end

---
--- Returns whether or not the mouse cursor
--- is displaying the OS cursor instead of a software cursor.
--- 
--- @return boolean
---
function MouseCursor.isSystemCursor()
    return MouseCursor._usingSystemCursor
end

---
--- Returns whether or not the mouse cursor
--- is displaying a software cursor instead of the OS cursor.
--- 
--- @return boolean
---
function MouseCursor.isSoftwareCursor()
    return not MouseCursor._usingSystemCursor
end

---
--- Stops displaying the software cursor and
--- starts displaying the OS cursor instead.
---
function MouseCursor.useSystemCursor()
    mouse.setVisible(MouseCursor._visible)
    MouseCursor._sprite:setVisibility(false)
    MouseCursor._usingSystemCursor = true
end

---
--- Stops displaying the OS cursor and
--- starts displaying the software cursor instead.
---
function MouseCursor.useSoftwareCursor()
    mouse.setVisible(false)
    MouseCursor._sprite:setVisibility(MouseCursor._visible)
    MouseCursor._usingSystemCursor = false
end

---
--- Loads a given texture onto the mouse cursor.
--- 
--- This only works if the software cursor is enabled.
--- 
--- @param  texture      chip.graphics.Texture?|string  The texture to load onto this sprite.
--- @param  animated     boolean?                       Whether or not the texture is animated.
--- @param  frameWidth   number?                        The width of each frame in the texture.
--- @param  frameHeight  number?                        The height of each frame in the texture.
---
function MouseCursor.loadTexture(texture, animated, frameWidth, frameHeight)
    MouseCursor._sprite:loadTexture(texture, animated, frameWidth, frameHeight)
end

function MouseCursor.loadDefaultTexture()
    MouseCursor._sprite:loadTexture(getImagePath("cursor.png"))
    MouseCursor._sprite.scale:set(1, 1)
    MouseCursor._sprite.origin:set()
end

function MouseCursor.isVisible()
    return MouseCursor._visible
end

function MouseCursor.setVisibility(visibility)
    MouseCursor._visible = visibility
    if MouseCursor.isSoftwareCursor() then
        MouseCursor._sprite:setVisibility(MouseCursor._visible)
    else
        mouse.setVisible(MouseCursor._visible)
    end
end

function MouseCursor.getScreenDeltaX()
    return MouseCursor._screenDeltaX
end

function MouseCursor.getScreenDeltaY()
    return MouseCursor._screenDeltaY
end

---
--- @param  vec  chip.math.Point?  The point to store the screen position in.
---
function MouseCursor.getScreenPosition(vec)
    if not vec then
        vec = Point:new()
    end
    return vec:set(mouse.getX(), mouse.getY())
end

function MouseCursor.getScreenX()
    return mouse.getX()
end

function MouseCursor.getScreenY()
    return mouse.getY()
end

---
--- @param  accountForCamera  boolean?          Whether or not to account for the currently active camera.
--- @param  vec               chip.math.Point?  The point to store the world position in.
---
function MouseCursor.getWorldPosition(accountForCamera, vec)
    if accountForCamera == nil then
        accountForCamera = true
    end
    if not vec then
        vec = Point:new()
    end
    local ww = love.graphics.getWidth()
    local wh = love.graphics.getHeight()

    local gw = Engine.gameWidth
    local gh = Engine.gameHeight

    local cam = Camera.currentCamera --- @type chip.graphics.Camera?
    if not accountForCamera then
        cam = nil
    end
    local scale = math.min(ww / gw, wh / gh) * (cam and cam.zoom or 1.0)
    return vec:set(
        ((mouse.getX() - (ww - scale * gw) * 0.5) / scale) + (cam and cam:getX() or 0.0),
        ((mouse.getY() - (wh - scale * gh) * 0.5) / scale) + (cam and cam:getY() or 0.0)
    )
end

---
--- @param  accountForCamera  boolean?  Whether or not to account for the currently active camera.
---
function MouseCursor.getWorldX(accountForCamera)
    if accountForCamera == nil then
        accountForCamera = true
    end
    return MouseCursor.getWorldPosition(accountForCamera, MouseCursor._point).x
end

---
--- @param  accountForCamera  boolean?  Whether or not to account for the currently active camera.
---
function MouseCursor.getWorldY(accountForCamera)
    if accountForCamera == nil then
        accountForCamera = true
    end
    return MouseCursor.getWorldPosition(accountForCamera, MouseCursor._point).y
end

---
--- @param  object            chip.graphics.Sprite
--- @param  accountForCamera  boolean?  Whether or not to account for the currently active camera.
---
function MouseCursor.overlaps(object, accountForCamera)
    local p = object:getParent()
    local ox, oy = object:getX() - object.offset.x - object:getFrame().offset.x, object:getY() - object.offset.y - object:getFrame().offset.y

    local curAnim = object.animation:getCurrentAnimation()
    ox = ox - (((object.frameOffset.x + (curAnim and curAnim.offset.x or 0.0))) * object.scale.x)
    oy = oy - (((object.frameOffset.y + (curAnim and curAnim.offset.y or 0.0))) * object.scale.y)

    local isOnCanvasLayer = false
    while p do
        if p:is(CanvasLayer) then
            ox = ox + p:getX()
            oy = oy + p:getY()
            if not p:is(Scene) then
                isOnCanvasLayer = true
            end
        end
        p = p:getParent()
    end
    if accountForCamera == nil then
        accountForCamera = not isOnCanvasLayer
    end
    local wp = MouseCursor.getWorldPosition(accountForCamera, MouseCursor._point)
    return (
        object:isVisible() and
        wp.x >= ox and wp.x <= ox + object:getFrame().width * abs(object.scale.x) and
        wp.y >= oy and wp.y <= oy + object:getFrame().height * abs(object.scale.y)
    )
end

---
--- @protected
---
function MouseCursor._update()
    local sprite = MouseCursor._sprite
    sprite:setPosition(mouse.getPosition())
end

---
--- @protected
---
function MouseCursor._postUpdate()
    local p = MouseCursor.getWorldPosition()
    MouseCursor._worldX = p.x
    MouseCursor._worldY = p.y

    MouseCursor._screenDeltaX = 0.0
    MouseCursor._screenDeltaY = 0.0
end

---
--- @protected
---
function MouseCursor._draw()
    local oldCamera = Camera.currentCamera
    Camera.currentCamera = nil

    if MouseCursor._sprite:isVisible() then
        MouseCursor._sprite:draw()
    end
    Camera.currentCamera = oldCamera
end

---
--- @protected
---
function MouseCursor._input(e)
    if e:is(InputEventMouseMotion) then
        local me = e --- @type chip.input.mouse.InputEventMouseMotion
        MouseCursor._deltaX = MouseCursor.getWorldX() - MouseCursor._worldX
        MouseCursor._deltaY = MouseCursor.getWorldY() - MouseCursor._worldY

        MouseCursor._worldX = MouseCursor.getWorldX()
        MouseCursor._worldY = MouseCursor.getWorldY()

        MouseCursor._screenDeltaX = me:getDeltaX()
        MouseCursor._screenDeltaY = me:getDeltaY()
    end
end

return MouseCursor