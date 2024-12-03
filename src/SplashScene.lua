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

local function getFontPath(name)
    return Chip.classPath .. "/assets/fonts/" .. name
end

local loveStripColors = {0xFFe74a99, 0xFF27aae1}

---
--- @class chip.SplashScene : chip.core.Scene
---
local SplashScene = Scene:extend("SplashScene", ...)

---
--- @param  initialScene  chip.core.Scene
---
function SplashScene:constructor(initialScene)
    SplashScene.super.constructor(self)
    self.initialScene = initialScene --- @type chip.core.Scene
end

function SplashScene:init()
    self.bg = Sprite:new() --- @type chip.graphics.Sprite
    self.bg:makeSolid(Engine.gameWidth, Engine.gameHeight, 0xFF17171a)
    self.bg:screenCenter("xy")
    self:add(self.bg)

    self.backdrop = Backdrop:new(0, 0, math.floor(Engine.gameWidth / 64), math.floor(Engine.gameHeight / 64)) --- @type chip.graphics.Backdrop
    self.backdrop:loadTexture(getImagePath("love_logo_heart_small.png"))
    self.backdrop.spacing:set(20, 20)
    self.backdrop.velocity:set(-60, -60)
    self.backdrop:setAntialiasing(true)
    self.backdrop:setAlpha(0.05)
    self.backdrop:kill()
    self:add(self.backdrop)

    self.strips = Sprite:new() --- @type chip.graphics.Sprite
    self.strips:loadTexture(getImagePath("love_strips.png"))
    self.strips:setGraphicSize(0.0001, Engine.gameHeight * 3)
    self.strips:screenCenter("xy")
    self:add(self.strips)

    self.logoBG = Sprite:new() --- @type chip.graphics.Sprite
    self.logoBG:loadTexture(getImagePath("love_logo_bg.png"))
    self.logoBG.scale:set(4, 4)
    self.logoBG:screenCenter("xy")
    self.logoBG:setAntialiasing(true)
    self.logoBG:setVisibility(false)
    -- self.logoBG:setAlpha(0.45)
    self.logoBG:setRotationDegrees(45)
    self:add(self.logoBG)

    self.heart = Sprite:new() --- @type chip.graphics.Sprite
    self.heart:loadTexture(getImagePath("love_logo_heart.png"))
    self.heart:screenCenter("xy")
    self.heart:setAntialiasing(true)
    self.heart:setVisibility(false)
    self.heart.offset.y = -5
    self:add(self.heart)

    self.madeWith = Text:new() --- @type chip.graphics.Text
    self.madeWith:setSize(24)
    self.madeWith:setFont(getFontPath("handy-andy.otf"))
    self.madeWith:setContents("made with")
    self.madeWith:screenCenter("xy")
    self.madeWith:setY(self.madeWith:getY() + 130)
    self.madeWith:setAntialiasing(true)
    self.madeWith:setVisibility(false)
    self:add(self.madeWith)

    self.logo = Sprite:new() --- @type chip.graphics.Sprite
    self.logo:loadTexture(getImagePath("love_logo.png"))
    self.logo.scale:set(0.3, 0.3)
    self.logo:screenCenter("xy")
    self.logo:setY(self.logo:getY() + 170)
    self.logo:setAntialiasing(true)
    self.logo:setVisibility(false)
    self:add(self.logo)

    local t = Timer:new() --- @type chip.utils.Timer
    t:start(0.25, function(_)
        local t2 = Tween:new() --- @type chip.tweens.Tween
        local pt = t2:tweenProperty(self.strips.scale, "x", (Engine.gameWidth / self.strips:getFrameWidth()) * 1.25, 0.7, Ease.cubeOut)
        pt:setUpdateCallback(function(_)
            self.strips:screenCenter("xy")
        end)
        local t4 = Tween:new() --- @type chip.tweens.Tween
        t4:tweenProperty(self.strips, "rotation", math.rad(90), 0.7, Ease.cubeIn)
        t4:setCompletionCallback(function(_)
            self.strips:setVisibility(false)
            self.logoBG:setVisibility(true)

            self.backdrop:revive()

            local t5 = Tween:new() --- @type chip.tweens.Tween
            local pt = t5:tweenProperty(self.logoBG, "scale", Point:new(0.5, 0.5), 0.7, Ease.cubeIn)
            pt:setUpdateCallback(function(_)
                self.logoBG:screenCenter("xy")
            end)
            pt:setCompletionCallback(function(_)
                local t6 = Tween:new() --- @type chip.tweens.Tween
                local pt = t6:tweenProperty(self.logoBG, "scale", Point:new(0.3, 0.3), 0.7, Ease.backOut)
                pt:setUpdateCallback(function(_)
                    self.logoBG:screenCenter("xy")
                    self.heart:screenCenter("xy")
                end)
                self.heart:setVisibility(true)
                
                self.heart.scale:set(0.1, 0.6)
                t6:tweenProperty(self.heart, "scale", Point:new(0.3, 0.3), 0.5, Ease.backOut)
                
                self.heart:setAlpha(0.001)
                t6:tweenProperty(self.heart, "alpha", 1, 0.15, Ease.cubeOut)
                
                local t = Timer:new() --- @type chip.utils.Timer
                t:start(0.25, function(_)
                    self.madeWith:setVisibility(true)
                    self.madeWith.scale:set(0.1, 1.5)

                    self.madeWith:setAlpha(0.001)
                    t6:tweenProperty(self.madeWith, "alpha", 1, 0.15, Ease.cubeOut)

                    local pt = t6:tweenProperty(self.madeWith, "scale", Point:new(1, 1), 0.5, Ease.backOut)
                    pt:setUpdateCallback(function(_)
                        self.madeWith.y = (self.madeWith:getHeight() - self.madeWith:getFrameHeight()) * 0.5
                        self.madeWith:screenCenter("x")
                    end)
                    local t = Timer:new() --- @type chip.utils.Timer
                    t:start(0.25, function(_)
                        self.logo:setVisibility(true)
                        self.logo.scale:set(0.1, 0.6)

                        local t7 = Tween:new() --- @type chip.tweens.Tween
                        local pt = t7:tweenProperty(self.logo, "scale", Point:new(0.3, 0.3), 0.5, Ease.backOut)
                        pt:setUpdateCallback(function(_)
                            self.logo.offset.y = (self.logo:getHeight() - (self.logo:getFrameHeight() * 0.3)) * 0.5
                            self.logo:screenCenter("x")
                        end)
                        self.logo:setAlpha(0.001)
                        t7:tweenProperty(self.logo, "alpha", 1, 0.15, Ease.cubeOut)
                    end)
                end)
            end)
            t5:tweenProperty(self.logoBG, "rotation", math.rad(360), 0.7, Ease.cubeOut):setCompletionCallback(function(_)
                self.logoBG:setRotation(0)
            end)
        end)
    end)
    local t = Timer:new() --- @type chip.utils.Timer
    t:start(4, function(_)
        local pinkStrip = Sprite:new() --- @type chip.graphics.Sprite
        pinkStrip:makeSolid(Engine.gameWidth, Engine.gameHeight / 2, loveStripColors[1])
        pinkStrip:setPosition(-pinkStrip:getWidth(), 0)
        self:add(pinkStrip)

        local blueStrip = Sprite:new() --- @type chip.graphics.Sprite
        blueStrip:makeSolid(Engine.gameWidth, Engine.gameHeight / 2, loveStripColors[2])
        blueStrip:setPosition(blueStrip:getWidth(), blueStrip:getHeight())
        self:add(blueStrip)

        local t2 = Tween:new() --- @type chip.tweens.Tween
        t2:tweenProperty(pinkStrip, "x", 0, 0.35, Ease.cubeIn)
        t2:tweenProperty(blueStrip, "x", 0, 0.35, Ease.cubeIn)
        
        local t3 = Timer:new()
        t3:start(0.4, function(_)
            self.backdrop:kill()
            self.bg:kill()
            self.logoBG:kill()
            self.heart:kill()
            self.madeWith:kill()
            self.logo:kill()

            local tweenManager = TweenManager:new(false) --- @type chip.plugins.TweenManager
            
            local pinkStrip = Sprite:new() --- @type chip.graphics.Sprite
            pinkStrip:makeSolid(Engine.gameWidth, Engine.gameHeight / 2, loveStripColors[1])
            pinkStrip:setPosition(0, 0)
            
            local blueStrip = Sprite:new() --- @type chip.graphics.Sprite
            blueStrip:makeSolid(Engine.gameWidth, Engine.gameHeight / 2, loveStripColors[2])
            blueStrip:setPosition(0, blueStrip:getHeight())

            local function update()
                tweenManager:update(Engine.deltaTime)
            end
            local function draw(_)
                pinkStrip:draw()
                blueStrip:draw()
            end
            Engine.postUpdate:connect(update)
            Engine.postSceneDraw:connect(draw)
            Engine.switchScene(self.initialScene)

            local t2 = Tween:new(tweenManager) --- @type chip.tweens.Tween
            t2:tweenProperty(pinkStrip, "x", pinkStrip:getWidth(), 0.35, Ease.cubeOut)
            t2:tweenProperty(blueStrip, "x", -blueStrip:getWidth(), 0.35, Ease.cubeOut)
            t2:setCompletionCallback(function(_)
                Engine.postUpdate:disconnect(update)
                Engine.postSceneDraw:disconnect(draw)

                pinkStrip:free()
                blueStrip:free()
            end)
        end)
    end)
end

return SplashScene