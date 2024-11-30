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
--- @class chip.utils.File
---
local File = Class:extend("File", ...)

function File.save(filePath, content)
    local success, _ = love.filesystem.write(filePath, content)
    return success
end

function File.read(filePath)
    local contents, _ = love.filesystem.read(filePath)
    return contents
end

function File.fileExists(filePath)
    return love.filesystem.getInfo(filePath, "file") ~= nil
end

function File.dirExists(filePath)
    return love.filesystem.getInfo(filePath, "directory") ~= nil
end

function File.exists(filePath)
    return File.fileExists(filePath) or File.dirExists(filePath)
end

function File.getFilesInDir(directory)
    return love.filesystem.getDirectoryItems(directory)
end

function File.loadScriptChunk(file)
    return love.filesystem.load(file)
end

return File