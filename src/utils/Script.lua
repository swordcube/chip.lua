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

local unpack = table.unpack

---
--- @class chip.utils.Script
---
local Script = Class:extend("Script", ...)

function Script:constructor(code)
    self._code = code
    self._variables = {}
    self._closed = false
    
    local vars = self._variables
    vars.close = function()
        self:close()
    end
    local success, err = pcall(function()
        local chunk = loadstring(code)
        if chunk then
            local env = {Script = Script}
            for k, f in pairs(_G) do
                env[k] = f
            end
            env._G = _G
            vars.__getCurrentFile = function()
                return debug.getinfo(2, "S").source:sub(2)
            end
            vars.__getCurrentLine = function()
                return debug.getinfo(2, "l").currentline
            end
            setfenv(chunk, setmetatable(vars, {__index = env}))
            chunk()
        end
    end)
    if not success then
        self:close()
        Log.error(nil, nil, nil, "Failed to load script: " .. code .. ": " .. err)
    end
end

function Script:getCode()
    return self._code
end

function Script:getAllVariables()
    return self._variables
end

function Script:isClosed()
    return self._closed
end

function Script:getVariable(var)
    return self._variables[var]
end

function Script:setVariable(var, val)
    self._variables[var] = val
end

function Script:callMethod(method, args)
    local f = self._variables[method]
    if type(f) == "function" then
        local unpackedArgs = (args ~= nil) and unpack(args) or nil
        local success, result = pcall(f, unpackedArgs)
        if not success then
            local vars = self._variables
            Log.error(nil, vars.__getCurrentFile(), vars.__getCurrentLine(), result)
        end
        return success and result or nil
    end
    return nil
end

function Script:close()
    local chunk = self.chunk
    if chunk then
        setfenv(chunk, setmetatable({}, {
            __index = function() error("Tried to use a closed script") end,
            __newindex = function() error("Tried to use a closed script") end,
        }))
    end
    self._closed = true
end

return Script