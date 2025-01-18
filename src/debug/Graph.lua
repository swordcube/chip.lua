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

---
--- @class chip.debug.Graph
---
local Graph = Class:extend("Graph", ...)

function Graph:constructor(type, x, y, width, height, delay, label, font)
    if ({ mem = 0, fps = 0, custom = 0 })[type] == nil then
        error('Acceptable types: mem, fps, custom')
    end

    self.x = x or 0
    self.y = y or 0
    self.width = width or 50
    self.height = height or 30
    self.delay = delay or 0.5
    self.label = label or type
    self.font = font or love.graphics.newFont(8)
    self.data = {}
    self._max = 0
    self._time = 0
    self._type = type

    -- Build base data
    for i = 0, math.floor(self.width / 2) do
        table.insert(self.data, 0)
    end
end

function Graph:update(dt, val)
    local lastTime = self._time
    self._time = (self._time + dt) % self.delay

    -- Check if the minimum amount of time has past
    if dt > self.delay or lastTime > self._time then
        -- Fetch data if needed
        if val == nil then
            if self._type == 'fps' then
                -- Collect fps info and update the label
                val = 0.75 * 1 / dt + 0.25 * love.timer.getFPS()
                self.label = "FPS: " .. math.floor(val * 10) / 10
            elseif self._type == 'mem' then
                -- Collect memory info and update the label
                val = collectgarbage('count')
                self.label = "Memory (KB): " .. math.floor(val * 10) / 10
            else
                -- If the val is nil then we'll just skip this time
                return
            end
        end


        -- pop the old data and push new data
        table.remove(self.data, 1)
        table.insert(self.data, val)

        -- Find the highest value
        local max = 0
        for i = 1, #self.data do
            local v = self.data[i]
            if v > max then
                max = v
            end
        end

        self._max = max
    end
end

function Graph:average()
    local a = 0.0
    local len = #self.data
    for i = 1, len do
        a = a + self.data[i]
    end
    return a / len
end

function Graph:draw()
    -- Store the currently set font and change the font to our own
    local fontCache = love.graphics.getFont()
    love.graphics.setFont(self.font)

    local max = math.ceil(self._max / 10) * 10 + 20
    local len = #self.data
    local steps = self.width / len

    -- Build the line data
    local lineData = {}
    for i = 1, len do
        -- Build the X and Y of the point
        local x = steps * (i - 1) + self.x
        local y = self.height * (-self.data[i] / max + 1) + self.y

        -- Append it to the line
        table.insert(lineData, x)
        table.insert(lineData, y)
    end

    -- Draw the line
    love.graphics.line(unpack(lineData))

    -- Print the label
    if self.label ~= '' then
        love.graphics.print(self.label, self.x, self.y + self.height - self.font:getHeight())
    end

    -- Reset the font
    love.graphics.setFont(fontCache)
end

return Graph
