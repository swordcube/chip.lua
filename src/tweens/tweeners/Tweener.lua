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
--- A basic tween class.
---
--- @class chip.tweens.tweeners.Tweener : chip.core.Actor
---
local Tweener = Actor:extend("Tweener", ...)

function Tweener:constructor(parent)
    Tweener.super.constructor(self)

    self:setVisibility(false)

    ---
    --- @protected
    --- @type chip.tweens.Tween
    ---
    self._parent = parent

    ---
    --- @protected
    --- @type function?
    ---
    self._onUpdate = nil

    ---
    --- @protected
    --- @type function?
    ---
    self._onComplete = nil
end

function Tweener:getParent()
    return self._parent
end

function Tweener:setParent(parent)
    self._parent = parent
end

function Tweener:getUpdateCallback()
    return self._onUpdate
end

---
--- @param  func  function
--- @return chip.tweens.tweeners.Tweener
---
function Tweener:setUpdateCallback(func)
    self._onUpdate = func
    return self
end

function Tweener:getCompletionCallback()
    return self._onComplete
end

---
--- @param  func  function
--- @return chip.tweens.tweeners.Tweener
---
function Tweener:setCompletionCallback(func)
    self._onComplete = func
    return self
end

return Tweener