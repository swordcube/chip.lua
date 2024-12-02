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

local CanvasLayer = crequire("graphics.CanvasLayer") --- @type chip.graphics.CanvasLayer

---
--- @class chip.core.Scene : chip.graphics.CanvasLayer
---
--- A class which represents a scene.
--- 
--- This could be a main menu, a level, a game over screen,
--- anything you want it to be!
---
local Scene = CanvasLayer:extend("Scene", ...)

---
--- Override this function to initialize your scene.
---
function Scene:init()
end

return Scene