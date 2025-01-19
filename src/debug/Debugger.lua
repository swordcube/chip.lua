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
Debugger._fpsGraph = Graph:new("custom", 0, 0, 230, 50, 0.0, "") --- @type chip.debug.Graph

---
--- @protected
---
Debugger._tpsGraph = Graph:new("custom", 0, 0, 230, 50, 0.0, "") --- @type chip.debug.Graph

---
--- @protected
---
Debugger._memGraph = Graph:new("custom", 0, 0, 230, 50, 0.0, "") --- @type chip.debug.Graph

---
--- @protected
---
Debugger._typedCommand = "" --- @type string

---
--- @protected
---
Debugger._commandHistory = {} --- @type table<string>

---
--- @protected
---
Debugger._cursorPos = 1 --- @type integer

---
--- @protected
---
Debugger._logs = {} --- @type table

---
--- @protected
---
Debugger._logOffsetY = 0.0 --- @type number

---
--- @protected
---
Debugger._mode = 0 --- @type integer

function Debugger.isVisible()
    return Debugger._mode > 1
end

function Debugger.getMode()
    return Debugger._mode
end

---
--- @param  mode  integer
---
function Debugger.setMode(mode)
    if mode == 0 then
        MouseCursor.setVisibility(MouseCursor.isVisible())
    else
        Debugger._typedCommand = ""
        Debugger._cursorPos = 1
    end
    Debugger.setTyping(false)
    Debugger._mode = mode

    love.keyboard.setTextInput(Debugger._mode > 1)
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
    debuggerIcons = {
        info = gfx.newImage(getImagePath("debugger/info.png")),
        warning = gfx.newImage(getImagePath("debugger/warning.png")),
        error = gfx.newImage(getImagePath("debugger/error.png")),
    }
    debuggerFonts = {
        log = gfx.newFont(14, "light")
    }
end

function Debugger.addLog(log)
    if log.type ~= "info" then
        Debugger.setMode(2)
    end
    Debugger._logOffsetY = 0
    table.insert(Debugger._logs, 1, log)
    if #Debugger._logs > 1000 then
        table.remove(Debugger._logs, #Debugger._logs)
    end
end

function Debugger.input(e)
    if not Engine.debugMode then
        return
    end
    if e:is(InputEventKey) then
        local ke = e --- @type chip.input.keyboard.InputEventKey
        if ke:isPressed() then
            if ke:getKey() == KeyCode.F12 then
                Debugger.setMode((Debugger.getMode() + 1) % 3)

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.LEFT then
                Debugger._cursorPos = math.max(1, Debugger._cursorPos - 1)

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.RIGHT then
                Debugger._cursorPos = math.min(utf8.len(Debugger._typedCommand) + 1, Debugger._cursorPos + 1)
            
            elseif Debugger.isTyping() and ke:getKey() == KeyCode.BACKSPACE then
                Debugger._cursorPos = math.max(1, Debugger._cursorPos - 1)

                local lemon = Debugger._typedCommand:split("")
                table.remove(lemon, Debugger._cursorPos)
                Debugger._typedCommand = table.concat(lemon, "")
            
            elseif Debugger.isTyping() and ke:getKey() == KeyCode.ENTER then
                local script = Script:new(Debugger._typedCommand) --- @type chip.utils.Script
                script:setVariable("cls", function()
                    Debugger._logs = {}
                end)
                script:setVariable("hide", function()
                    Timer:new():start(0.001, function(_)
                        Debugger.setMode(0)
                    end)
                end)
                script:run()
                script:close()

                table.insert(Debugger._commandHistory, Debugger._typedCommand)
                if #Debugger._commandHistory > 30 then
                    table.remove(Debugger._commandHistory, 1)
                end
                Debugger._typedCommand = ""
                Debugger._cursorPos = 1

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.UP then
                if #Debugger._commandHistory > 0 then
                    local index = table.indexOf(Debugger._commandHistory, Debugger._typedCommand)
                    if index == -1 then
                        index = #Debugger._commandHistory
                    end
                    index = math.wrap(index - 1, 1, #Debugger._commandHistory)

                    Debugger._typedCommand = Debugger._commandHistory[index]
                    Debugger._cursorPos = utf8.len(Debugger._typedCommand) + 1
                end

            elseif Debugger.isTyping() and ke:getKey() == KeyCode.DOWN then
                if #Debugger._commandHistory > 0 then
                    local index = table.indexOf(Debugger._commandHistory, Debugger._typedCommand)
                    if index == -1 then
                        index = #Debugger._commandHistory
                    end
                    index = math.wrap(index + 1, 1, #Debugger._commandHistory)

                    Debugger._typedCommand = Debugger._commandHistory[index]
                    Debugger._cursorPos = utf8.len(Debugger._typedCommand) + 1
                end
            end
        end
    end
    if e:is(InputEventTextInput) then
        local ke = e --- @type chip.input.keyboard.InputEventTextInput
        Debugger.setTyping(true)

        local lemon = Debugger._typedCommand:split("")
        table.insert(lemon, Debugger._cursorPos, ke:getCharacter())

        Debugger._typedCommand = table.concat(lemon, "")
        Debugger._cursorPos = Debugger._cursorPos + 1
    end
    if e:is(InputEventMouseScroll) then
        local me = e --- @type chip.input.mouse.InputEventMouseScroll
        Debugger._logOffsetY = Debugger._logOffsetY + (me:getY() * 30)
    end
end

function Debugger.update(_)
    fpsGraphTimer = fpsGraphTimer + love.timer.getDelta()
    if Debugger.isVisible() then
        local cursorVisible = MouseCursor.isVisible()
        MouseCursor.setVisibility(true)
        MouseCursor._visible = cursorVisible
    end
    local maxY = (30 * (#Debugger._logs)) - (gfx.getHeight() - 50)
    if Debugger._logOffsetY > maxY then
        Debugger._logOffsetY = maxY
    end
    if Debugger._logOffsetY < 0 then
        Debugger._logOffsetY = 0
    end
end

function Debugger.getBoxDimensions(index, bottom)
    if bottom == nil then
        bottom = true
    end
    local bw, bh, bs = 250, 80, 10
    local ww, wh = gfx.getDimensions()
    return ww - (bw + bs), bottom and wh - ((bh + bs) * index) or ((bh + bs) * (index - 1)) + bs, bw, bh, bs
end

function Debugger.drawBox(title, index, bottom)
    if bottom == nil then
        bottom = true
    end
    local bx, by, bw, bh, bs = Debugger.getBoxDimensions(index, bottom)

    gfx.setColor(0, 0, 0, 0.8)
    gfx.rectangle("fill", bx, by, bw, bh)
    gfx.setColor(1, 1, 1, 1)
    
    gfx.print(title, bx + 5, by + 2)
end

function Debugger.preDraw()
    local drawDt = 1000000000 / (Native.getTicksNS() - lastDrawTime)
    if fpsGraphTimer > 0.25 then
        Debugger._fpsGraph:update(drawDt, 0.75 * love.timer.getDelta() + 0.25 * Engine.getCurrentFPS())
        Debugger._tpsGraph:update(drawDt, 0.75 * drawDt + 0.25 * Engine.getCurrentTPS())
        Debugger._memGraph:update(drawDt, Native.getProcessMemory())
        fpsGraphTimer = 0.0
    end
end

function Debugger.drawLogs()
    gfx.setScissor(10, 10, gfx.getWidth() - 280, gfx.getHeight() - 50)

    local logs = Debugger._logs
    for i = 1, #logs do
        local log = logs[i]
        local bx, by, bw, bh = 10, (gfx.getHeight() - ((30 * (i - 1)) + 70)) + Debugger._logOffsetY, gfx.getWidth() - 280, 30
        if by < -60 then
            goto continue
        end
        gfx.setColor(0, 0, 0, 0.8)
        gfx.rectangle("fill", bx, by, bw, bh)
        gfx.setColor(1, 1, 1, 1)

        gfx.draw(debuggerIcons[log.type], bx + 6, by + 6, 0, 0.7, 0.7)
        gfx.print(log.text, debuggerFonts.log, bx + 30, by + 4)

        ::continue::
    end
    gfx.setScissor()
end

function Debugger.drawScriptBox(bx, by, bw, bh)
    gfx.setColor(0, 0, 0, 0.8)
    gfx.rectangle("fill", bx, by, bw, bh)
    gfx.setColor(1, 1, 1, 1)

    local lemon = Debugger._typedCommand:split("")
    table.insert(lemon, Debugger._cursorPos, ((math.floor(love.timer.getTime() * 4) % 2 == 0) and "|" or ""))

    gfx.print(table.concat(lemon, ""), bx, by)
end

function Debugger.drawGraphs()
    -- [ TOP BOXES ] --
    Debugger.drawBox("Memory Usage (" .. math.truncate(Debugger._memGraph:average() / 1048576, 2) .. "mb avg)", 1, false)

    local bx, by, bw, bh, bs = Debugger.getBoxDimensions(1, false)
    Debugger._memGraph.x = bx + bs
    Debugger._memGraph.y = by + (bs * 2)

    local color = Color.PINK
    gfx.setColor(color.r, color.g, color.b, color.a)

    Debugger._memGraph:draw()
    gfx.setColor(1, 1, 1, 1)

    -- [ BOTTOM BOXES ] --
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
    if Debugger.getMode() > 1 then
        local bh = 20
        Debugger.drawScriptBox(10, gfx.getHeight() - (bh + 10), gfx.getWidth() - 280, bh)
        Debugger.drawLogs()
    end
    if Debugger.getMode() ~= 0 then
        Debugger.drawGraphs()
    end
    lastDrawTime = Native.getTicksNS()
end

return Debugger