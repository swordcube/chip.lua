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

local tmr = love.timer

local Color = crequire("utils.Color") --- @type chip.utils.Color
local Signal = crequire("utils.Signal") --- @type chip.utils.Signal

---
--- @class chip.Engine
---
local Engine = {}

---
--- The background color of the game.
---
Engine.clearColor = Color.BLACK --- @type chip.utils.Color

---
--- The width of the game area. (in pixels)
---
Engine.gameWidth = 640 --- @type integer

---
--- The height of the game area. (in pixels)
---
Engine.gameHeight = 480 --- @type integer

---
--- The object responsible for scaling the game
--- to the window as it's resized.
---
Engine.scaleMode = nil --- @type chip.graphics.scalemodes.BaseScaleMode?

---
--- The currently active scene.
---
Engine.currentScene = nil --- @type chip.core.Scene

---
--- The time since the last frame. (in seconds)
---
Engine.deltaTime = 0.0 --- @type number

---
--- The target framerate of the game.
---
Engine.targetFPS = 60 --- @type integer

---
--- Whether or not the framerate of the game
--- should match the monitor that the window
--- is currently within.
---
Engine.vsync = true

---
--- A list of every added plugin.
--- 
--- Plugins are responsible for running some of
--- your game related stuff in the background automatically.
---
Engine.plugins = Group:new() --- @type chip.core.Group

---
--- Controls whether or not plugins should
--- be drawn in front of the game.
---
Engine.drawPluginsInFront = true --- @type boolean

---
--- A signal that is fired before the game updates.
---
Engine.preUpdate = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game updates
---
Engine.postUpdate = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the game
--- is drawn to the screen.
---
Engine.preDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the current
--- scene or any plugin is drawn to the screen.
---
Engine.preSceneDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the current
--- scene or any plugin drawn to the screen.
---
Engine.postSceneDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game
--- is drawn to the screen.
---
Engine.postDraw = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired before the game
--- switches scenes.
---
Engine.preSceneSwitch = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired after the game
--- switches scenes.
---
Engine.postSceneSwitch = Signal:new():type(Scene) --- @type chip.utils.Signal

---
--- A signal that is fired when an input
--- event is received.
---
Engine.onInputReceived = Signal:new():type(InputEvent) --- @type chip.utils.Signal

---
--- A signal that is fired when the
--- game window is resized.
---
Engine.onWindowResize = Signal:new():type("number", "number") --- @type chip.utils.Signal

---
--- A signal that is fired when the
--- game window loses focus.
---
Engine.onFocusLost = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired when the
--- game window loses focus.
---
Engine.onFocusGained = Signal:new() --- @type chip.utils.Signal

---
--- A signal that is fired when the
--- game is about to quit.
---
Engine.onQuit = Signal:new() --- @type chip.utils.Signal

---
--- Whether or not debug mode is enabled.
---
Engine.debugMode = false --- @type boolean

---
--- Returns the amount of frames drawn
--- to the screen in the last second.
---
--- @return integer
---
function Engine.getCurrentFPS()
    return Engine._currentFPS
end

---
--- Returns the amount of ticks/update calls
--- ran in the last second.
---
--- @return integer
---
function Engine.getCurrentTPS()
    -- This only works because we're not limiting FPS
    -- via sleeping, since that's too inaccurate.

    -- Instead we are using a simple timer and an if
    -- statement to do the job, so this effectively
    -- returns into a ticks per second counter.
    
    return tmr.getFPS()
end

---
--- @param  newScene  chip.core.Scene
---
function Engine.switchScene(newScene)
    Engine._requestedScene = newScene
end

--- [ PRIVATE API ] ---

---
--- @protected
--- @type chip.core.Scene?
---
Engine._requestedScene = nil

---
--- @protected
--- @type integer
---
Engine._currentFPS = 0

---
--- @protected
---
function Engine._switchScene()
    Engine.preSceneSwitch:emit()

    if Engine.currentScene then
        Engine.currentScene:free()
    end
    Camera.currentCamera = nil
    
    Engine.currentScene = Engine._requestedScene
    Engine._requestedScene = nil
    
    Engine.currentScene:init()
    Engine.postSceneSwitch:emit(Engine.currentScene)
end

return Engine