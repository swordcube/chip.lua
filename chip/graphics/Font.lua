---
--- @diagnostic disable: invisible
--- @class chip.graphics.Font : chip.backend.RefCounted
--- 
--- A class representing a font.
--- 
--- You should load these from the `Assets` class
--- under the `chip.utils` package.
---
local Font = RefCounted:extend("Font", ...)

function Font:constructor()
    Font.super.constructor(self)

    ---
    --- @protected
    --- @type table<integer, love.Font>
    ---
    self._data = {}
end

function Font:getData(size)
    return self._data[size]
end

function Font:setData(size, data)
    self._data[size] = data
    self._data[size]:setFilter("nearest", "nearest", 4)
end

function Font:free()
    for _, value in pairs(self._data) do
        value:release()
    end
    self._data:release()
    self._data = nil

    for key, value in pairs(Assets._fontCache) do
        if value == self then
            Assets._fontCache[key] = nil
        end
    end
end

--- [ PRIVATE API ] ---

return Font