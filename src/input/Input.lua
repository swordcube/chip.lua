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

local tblInsert = table.insert

---
--- @class chip.input.Input
---
local Input = {}

---
--- @protected
--- @type table<string, boolean>
---
Input._keysJustPressed = {}

---
--- @protected
--- @type table<string, boolean>
---
Input._keysPressed = {}

---
--- @protected
--- @type table<string, boolean>
---
Input._keysJustReleased = {}

---
--- @protected
--- @type table<"left"|"right"|"middle"|"unknown", boolean>
---
Input._mouseButtonsJustPressed = {}

---
--- @protected
--- @type table<"left"|"right"|"middle"|"unknown", boolean>
---
Input._mouseButtonsPressed = {}

---
--- @protected
--- @type table<"left"|"right"|"middle"|"unknown", boolean>
---
Input._mouseButtonsJustReleased = {}

---
--- @protected
--- @type boolean
---
Input._mouseJustMoved = false

---
--- @protected
--- @type table<string>
---
Input._keyCodes = {}

---
--- @protected
--- @type number
---
Input._horizontalMouseWheel = 0.0

---
--- @protected
--- @type number
---
Input._verticalMouseWheel = 0.0

function Input.init()
    Engine.onInputReceived:connect(Input._processEvent)
    Engine.postUpdate:connect(Input._postUpdate)

    for _, value in pairs(KeyCode) do
        tblInsert(Input._keyCodes, value)
    end
end

---
--- @param  key  string
---
function Input.wasKeyJustPressed(key)
    return Input._keysJustPressed[key]
end

---
--- @param  key  string
---
function Input.isKeyPressed(key)
    return Input._keysPressed[key]
end

---
--- @param  key  string
---
function Input.wasKeyJustReleased(key)
    return Input._keysJustReleased[key]
end

---
--- @param  button  "left"|"right"|"middle"|"unknown"
---
function Input.wasMouseJustPressed(button)
    return Input._mouseButtonsJustPressed[button]
end

---
--- @param  button  "left"|"right"|"middle"|"unknown"
---
function Input.isMousePressed(button)
    return Input._mouseButtonsPressed[button]
end

---
--- @param  button  "left"|"right"|"middle"|"unknown"
---
function Input.wasMouseJustReleased(button)
    return Input._mouseButtonsJustReleased[button]
end

---
--- @return number
---
function Input.getMouseWheelX()
    return Input._horizontalMouseWheel
end

---
--- @return number
---
function Input.getMouseWheelY()
    return Input._verticalMouseWheel
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function Input._processEvent(event)
    if event:is(InputEventKey) then
        local event = event --- @type chip.input.InputEventKey

        local key = event:getKey() --- @type string
        local pressed = event:isPressed() --- @type boolean

        if pressed then
            Input._keysJustPressed[key] = true
        else
            Input._keysJustReleased[key] = true
        end
        Input._keysPressed[key] = pressed
    end
    if event:is(InputEventMouseMotion) then
        Input._mouseJustMoved = true
    end
    if event:is(InputEventMouseScroll) then
        local event = event --- @type chip.input.InputEventMouseScroll

        Input._horizontalMouseWheel = event:getX()
        Input._verticalMouseWheel = event:getY()
    end
    if event:is(InputEventMouseButton) then
        local event = event --- @type chip.input.InputEventMouseButton

        local button = event:getButton() --- @type "left"|"right"|"middle"|"unknown"
        local pressed = event:isPressed() --- @type boolean

        if pressed then
            Input._mouseButtonsJustPressed[button] = true
        else
            Input._mouseButtonsJustReleased[button] = true
        end
        Input._mouseButtonsPressed[button] = pressed
    end
end

---
--- @protected
---
function Input._postUpdate()
    local keyCodes = Input._keyCodes
    for i = 1, #keyCodes do
        local key = keyCodes[i] --- @type string
        if Input._keysJustPressed[key] then
            Input._keysJustPressed[key] = false
        end
        if Input._keysJustReleased[key] then
            Input._keysJustReleased[key] = false
        end
    end
    local mouseButtons = {"left", "right", "middle", "unknown"}
    for i = 1, #mouseButtons do
        local button = mouseButtons[i] --- @type "left"|"right"|"middle"|"unknown"
        if Input._mouseButtonsJustPressed[button] then
            Input._mouseButtonsJustPressed[button] = false
        end
        if Input._mouseButtonsJustReleased[button] then
            Input._mouseButtonsJustReleased[button] = false
        end
    end
    Input._mouseJustMoved = false
    Input._horizontalMouseWheel = 0.0
    Input._verticalMouseWheel = 0.0
end

return Input