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
--- A class that timers can attach to, which manages
--- updating them.
---
--- @class chip.plugins.TimerManager : chip.core.Actor
---
local TimerManager = Actor:extend("TimerManager", ...)

---
--- @type chip.plugins.TimerManager?
---
TimerManager.global = nil

function TimerManager:constructor()
    TimerManager.super.constructor(self)

    ---
    --- The list of all timers attached to this manager.
    --- 
    --- @type chip.core.Group
    ---
    self.list = Group:new()

    Engine.preSceneSwitch:connect(function()
        self:reset()
    end)
end

function TimerManager:reset()
    while self.list:getLength() > 0 do
        ---
        --- @type chip.utils.Timer
        ---
        local timer = self.list:getMembers()[1]
        timer:free()
    end
end

---
--- Pauses all current tweens in this timer manager.
--- Any new tweens given to this timer manager will still be ran.
---
function TimerManager:pause()
    local members = self.list:getMembers()
    for i = 1, self.list:getLength() do
        local timer = members[i] --- @type chip.utils.Timer
        timer:setUpdateMode("disabled")
    end
end

---
--- Resumes all current tweens in this timer manager.
---
function TimerManager:resume()
    local members = self.list:getMembers()
    for i = 1, self.list:getLength() do
        local timer = members[i] --- @type chip.utils.Timer
        timer:setUpdateMode("inherit")
    end
end

function TimerManager:update(dt)
    self.list:_update(dt)
end

return TimerManager