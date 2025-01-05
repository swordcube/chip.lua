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
--- @class chip.debug.Log
--- 
--- A class built for logging info to the console
--- alongside the built-in debugger UI.
---
local Log = {}

---
--- A reference to the original lua print function,
--- just in case you want to use it later.
---
Log.luaPrint = nil --- @type function

---
--- Enable this if you are debugging your game
--- and require line numbers to be output to the console.
--- 
--- Otherwise leave this off as this info is likely
--- not useful to the players.
---
--- @type boolean
---
Log.outputLineNumbers = false

---
--- @param  chunks           table
--- @param  endWithNewLine?  boolean
---
function Log.output(chunks, endWithNewLine)
    if endWithNewLine == nil then
        endWithNewLine = true
    end
    for i = 1, #chunks do
        local chunk = chunks[i] --- @type table
        Native.setConsoleColors(chunk.fgColor, chunk.bgColor)
        
        io.stdout:write(chunk.text)
        io.stdout:flush()

        Native.setConsoleColors()
    end
    if endWithNewLine then
        io.stdout:write("\n")
        io.stdout:flush()
    end
end

function Log.stringifyVarArg(...)
    local str = ""
    local argCount = select("#", ...)
    for i = 1, argCount do
        str = str .. tostring(select(i, ...))
        if i < argCount then
            str = str .. ", "
        end
    end
    return str
end

---
---@param  ...  unknown  The info to output to the log, this can be multiple things, like so: `Log.info("info1", 2)`
---
function Log.info(prefixChunk, fileName, lineNumber, ...)
    local curFile = fileName and fileName or debug.getinfo(2, "S").source:sub(2)
    local curLine = lineNumber and lineNumber or debug.getinfo(2, "l").currentline

    local chunks = {}
    tblInsert(chunks, {
        text = "(i) ",
        fgColor = Native.ConsoleColor.BLUE,
    })
    if Log.outputLineNumbers then
        tblInsert(chunks, {
            text = curFile .. ":" .. curLine .. ": ",
            fgColor = Native.ConsoleColor.CYAN,
        })
    end
    if prefixChunk then
        tblInsert(chunks, prefixChunk)
    end
    tblInsert(chunks, {
        text = Log.stringifyVarArg(...),
        fgColor = Native.ConsoleColor.LIGHT_GRAY,
    })
    Log.output(chunks)
end

---
---@param  ...  unknown  The info to output to the log, this can be multiple things, like so: `Log.info("info1", 2)`
---
function Log.warn(prefixChunk, fileName, lineNumber, ...)
    local curFile = fileName and fileName or debug.getinfo(2, "S").source:sub(2)
    local curLine = lineNumber and lineNumber or debug.getinfo(2, "l").currentline

    local chunks = {}
    tblInsert(chunks, {
        text = "/!\\ ",
        fgColor = Native.ConsoleColor.YELLOW,
    })
    if Log.outputLineNumbers then
        tblInsert(chunks, {
            text = curFile .. ":" .. curLine .. ": ",
            fgColor = Native.ConsoleColor.CYAN,
        })
    end
    if prefixChunk then
        tblInsert(chunks, prefixChunk)
    end
    tblInsert(chunks, {
        text = Log.stringifyVarArg(...),
        fgColor = Native.ConsoleColor.LIGHT_GRAY,
    })
    Log.output(chunks)
end

---
---@param  ...  unknown  The info to output to the log, this can be multiple things, like so: `Log.info("info1", 2)`
---
function Log.error(prefixChunk, fileName, lineNumber, ...)
    local curFile = fileName and fileName or debug.getinfo(2, "S").source:sub(2)
    local curLine = lineNumber and lineNumber or debug.getinfo(2, "l").currentline

    local chunks = {}
    tblInsert(chunks, {
        text = "(X) ",
        fgColor = Native.ConsoleColor.RED,
    })
    if Log.outputLineNumbers then
        tblInsert(chunks, {
            text = curFile .. ":" .. curLine .. ": ",
            fgColor = Native.ConsoleColor.CYAN,
        })
    end
    if prefixChunk then
        tblInsert(chunks, prefixChunk)
    end
    tblInsert(chunks, {
        text = Log.stringifyVarArg(...),
        fgColor = Native.ConsoleColor.LIGHT_GRAY,
    })
    Log.output(chunks)
end

return Log