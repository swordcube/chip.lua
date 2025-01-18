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

local gfx = love.graphics
local utf8 = require("utf8")

local lastDrawTime = 0.0
local fpsGraphTimer = 0.0

local Graph = crequire("debug.Graph") --- @type chip.debug.Graph
local Script = crequire("utils.Script") --- @type chip.utils.Script

---
--- @class chip.debug.Debugger
---
local Debugger = {}

---
--- @protected
---
Debugger._visible = false

---
--- @protected
---
Debugger._isTyping = false

---
--- @protected
---
Debugger._fpsGraph = Graph:new("custom", 0, 0, 230, 50, 0.25, "") --- @type chip.debug.Graph

---
--- @protected
---
Debugger._tpsGraph = Graph:new("custom", 0, 0, 230, 50, 0.25, "") --- @type chip.debug.Graph

---
--- @protected
---
Debugger._typedScript = "" --- @type string

---
--- @protected
---
Debugger._cursorPos = 1 --- @type integer

function Debugger.isVisible()
    return Debugger._visible
end

---
--- @param  visible  boolean
---
function Debugger.setVisibility(visible)
    if not visible then
        MouseCursor.setVisibility(MouseCursor.isVisible())
    else
        Debugger._typedScript = ""
        Debugger._cursorPos = 1
    end
    Debugger.setTyping(false)
    Debugger._visible = visible

    love.keyboard.setTextInput(visible)
end

function Debugger.isTyping()
    return Debugger._isTyping
end

---
--- @param  isTyping  boolean
---
function Debugger.setTyping(isTyping)
    Debugger._isTyping = isTyping
end

function Debugger.init()
end

function Debugger.input(e)
    if not Engine.debugMode then
        return
    end
    if e:is(InputEventKey) then
        local ke = e --- @type chip.input.keyboard.InputEventKey
        if ke:isPressed() then
            if ke:getKey() == KeyCode.F12 then
                Debugger.setVisibility(not Debugger.isVisible())

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.LEFT then
                Debugger._cursorPos = math.max(1, Debugger._cursorPos - 1)

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.RIGHT then
                Debugger._cursorPos = math.min(utf8.len(Debugger._typedScript) + 1, Debugger._cursorPos + 1)
            
            elseif Debugger.isTyping() and ke:getKey() == KeyCode.BACKSPACE then
                Debugger._cursorPos = math.max(1, Debugger._cursorPos - 1)

                local lemon = Debugger._typedScript:split("")
                table.remove(lemon, Debugger._cursorPos)
                Debugger._typedScript = table.concat(lemon, "")
            
            elseif Debugger.isTyping() and ke:getKey() == KeyCode.ENTER then
                local script = Script:new(Debugger._typedScript)
                script:close()
                Debugger._typedScript = ""
                Debugger._cursorPos = 1
            end
        end
    end
    if e:is(InputEventTypeKey) then
        local ke = e --- @type chip.input.keyboard.InputEventTypeKey
        Debugger.setTyping(true)

        local lemon = Debugger._typedScript:split("")
        table.insert(lemon, Debugger._cursorPos, ke:getCharacter())

        Debugger._typedScript = table.concat(lemon, "")
        Debugger._cursorPos = Debugger._cursorPos + 1
    end
end

function Debugger.update(_)
    if not Debugger.isTyping() then
        fpsGraphTimer = fpsGraphTimer + love.timer.getDelta()
    end
    if Debugger.isVisible() then
        local cursorVisible = MouseCursor.isVisible()
        MouseCursor.setVisibility(true)
        MouseCursor._visible = cursorVisible
    end
end

function Debugger.getBoxDimensions(index)
    local bw, bh, bs = 250, 80, 10
    local ww, wh = gfx.getDimensions()
    return ww - (bw + bs), wh - ((bh + bs) * index), bw, bh, bs
end

function Debugger.drawBox(title, index)
    local bx, by, bw, bh, bs = Debugger.getBoxDimensions(index)

    gfx.setColor(0, 0, 0, 0.8)
    gfx.rectangle("fill", bx, by, bw, bh)
    gfx.setColor(1, 1, 1, 1)
    
    gfx.print(title, bx + 5, by + 2)
end

function Debugger.preDraw()
    if not Debugger.isTyping() then
        local drawDt = 1000000000 / (Native.getTicksNS() - lastDrawTime)
        if fpsGraphTimer > 0.1 then
            Debugger._fpsGraph:update(drawDt, 0.75 * love.timer.getDelta() + 0.25 * Engine.getCurrentFPS())
            Debugger._tpsGraph:update(drawDt, 0.75 * drawDt + 0.25 * Engine.getCurrentTPS())
            fpsGraphTimer = 0.0
        end
    end
end

function Debugger.drawScriptBox(bx, by, bw, bh)
    gfx.setColor(0, 0, 0, 0.8)
    gfx.rectangle("fill", bx, by, bw, bh)
    gfx.setColor(1, 1, 1, 1)

    local lemon = Debugger._typedScript:split("")
    table.insert(lemon, Debugger._cursorPos, ((math.floor(love.timer.getTime() * 4) % 2 == 0) and "|" or ""))

    gfx.print(table.concat(lemon, ""), bx, by)
end

function Debugger.drawGraphs()
    Debugger.drawBox("Frametime (" .. math.truncate(1 / Debugger._fpsGraph:average(), 4) .. "ms avg)", 1)
        
    local bx, by, bw, bh, bs = Debugger.getBoxDimensions(1)
    Debugger._fpsGraph.x = bx + bs
    Debugger._fpsGraph.y = by + (bs * 2)

    local color = Color.CYAN
    gfx.setColor(color.r, color.g, color.b, color.a)

    Debugger._fpsGraph:draw()
    gfx.setColor(1, 1, 1, 1)

    Debugger.drawBox("Ticktime (" .. math.truncate(1 / Debugger._tpsGraph:average(), 4) .. "ms avg)", 2)
    
    bx, by, bw, bh, bs = Debugger.getBoxDimensions(2)
    Debugger._tpsGraph.x = bx + bs
    Debugger._tpsGraph.y = by + (bs * 2)

    color = Color.LIME
    gfx.setColor(color.r, color.g, color.b, color.a)

    Debugger._tpsGraph:draw()
    gfx.setColor(1, 1, 1, 1)
end

function Debugger.draw()
    if Debugger._visible then
        local bh = 20
        Debugger.drawScriptBox(10, gfx.getHeight() - (bh + 10), gfx.getWidth() - 280, bh)
        Debugger.drawGraphs()
    end
    if not Debugger.isTyping() then
        lastDrawTime = Native.getTicksNS()
    end
end

return Debugger