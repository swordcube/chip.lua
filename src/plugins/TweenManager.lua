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
--- A class that tweens can attach to, which manages
--- updating them.
---
--- @class chip.plugins.TweenManager : chip.core.Actor
---
local TweenManager = Actor:extend("TweenManager", ...)

---
--- @type chip.plugins.TweenManager?
---
TweenManager.global = nil

function TweenManager:constructor(resetOnSceneSwitch)
    TweenManager.super.constructor(self)

    ---
    --- The list of all tweens attached to this manager.
    --- 
    --- @type chip.core.Group
    ---
    self.list = Group:new()

    if resetOnSceneSwitch == nil then
        resetOnSceneSwitch = true
    end
    if resetOnSceneSwitch then
        Engine.preSceneSwitch:connect(function()
            self:reset()
        end)
    end
end

function TweenManager:reset()
    while self.list:getLength() > 0 do
        ---
        --- @type chip.tweens.Tween
        ---
        local tween = self.list:getMembers()[1]
        tween:free()
    end
end

function TweenManager:update(dt)
    self.list:update(dt)
end

return TweenManager