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

local nativefs = qrequire("chip.libs.nativefs") --- @type chip.libs.nativefs

local fs = love.filesystem -- FREESTYLE ENGINE?!?!?!

---
--- @class chip.utils.Save
--- 
--- A simple class for storing and loading data.
---
local Save = Class:extend("Save", ...)

function Save:constructor()
    Save.super.constructor(self)

    self.data = {}

    self.name = ""
    self.dir = ""
end

function Save:bind(name, dir)
    self.name = name
    self.dir = dir

    local saveDir = fs.getAppdataDirectory() .. "/" .. dir
    local path = saveDir .. "/" .. name .. ".sav"

    if not nativefs.getInfo(saveDir, "directory") then
        nativefs.createDirectory(saveDir)
    end
    local info = nativefs.getInfo(path, "file")
    if info then
        success, result = pcall(Json.decode, love.data.decode("string", "hex", nativefs.read("string", path)))
        if success then
            self.data = result
        else
            print("Save data at " .. path .. " may be corrupted!")
            self.data = {}
        end
    end
end

function Save:flush()
    local saveDir = fs.getAppdataDirectory() .. "/" .. self.dir
    local path = saveDir .. "/" .. self.name .. ".sav"
    nativefs.write(path, love.data.encode("string", "hex", Json.encode(self.data)))
end

return Save