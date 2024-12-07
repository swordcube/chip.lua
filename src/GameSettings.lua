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
--- @class chip.GameSettings
---
local GameSettings = {
    ---
    --- The width of the game area, in pixels.
    ---
    gameWidth = 640, --- @type integer

    ---
    --- The height of the game area, in pixels.
    ---
    gameHeight = 480, --- @type integer

    ---
    --- The target framerate of the game.
    ---
    targetFPS = 60, --- @type integer

    ---
    --- The initial scene to start your game with.
    ---
    initialScene = nil, --- @type chip.core.Actor?

    ---
    --- Controls whether or not a splash screen
    --- should be shown before the game starts.
    --- 
    --- This is used to show that the game is made in Love2D.
    ---
    showSplashScreen = true, --- @type boolean

    ---
    --- Controls whether or not the game should
    --- be run in debug mode.
    ---
    debugMode = false --- @type boolean
}
return GameSettings