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