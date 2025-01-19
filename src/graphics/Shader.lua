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
--- @diagnostic disable: invisible
--- @class chip.graphics.Shader : chip.backend.RefCounted
--- 
--- A class representing a shader.
--- 
--- These can be applied to any actor that
--- is able to draw to the screen.
---
local Shader = RefCounted:extend("Shader", ...)

function Shader:constructor(pixelSource, vertexSource)
    Shader.super.constructor(self)

    if pixelSource and File.fileExists(pixelSource) then
        pixelSource = File.read(pixelSource)
    end
    if vertexSource and File.fileExists(vertexSource) then
        vertexSource = File.read(vertexSource)
    end

    ---
    --- @protected
    ---
    self._shader = gfx.newShader(pixelSource, vertexSource) --- @type love.Shader
end

---
--- Returns the internal LÖVE shader.
---
function Shader:getData()
    return self._shader
end

---
---Returns any warning and error messages from compiling the shader code. This can be used for debugging your shaders if there's anything the graphics hardware doesn't like.
---
--- @return string  warnings  Warning and error messages (if any).
---
function Shader:getWarnings()
    return self._shader:getWarnings()
end

---
--- Gets whether a uniform / extern variable exists in the Shader.
--- 
--- If a graphics driver's shader compiler determines that a uniform / extern variable doesn't affect the final output of the shader, it may optimize the variable out. This function will return false in that case.
---
--- @param  name     string       The name of the uniform variable.
--- @return boolean  hasUniform   Whether the uniform exists in the shader and affects its final output.
---
function Shader:hasUniform(name)
    return self._shader:hasUniform(name)
end

---
--- Sends one or more values to a special (''uniform'') variable inside the shader. Uniform variables have to be marked using the ''uniform'' or ''extern'' keyword, e.g.
--- 
--- ```glsl
--- uniform float time; // 'float' is the typical number type used in GLSL shaders.
--- uniform float varsvec2 light_pos;
--- uniform vec4 colors[4];
--- ```
--- 
--- The corresponding send calls would be
--- 
--- ```lua
--- shader:send('time', t)
--- shader:send('vars',a,b)
--- shader:send('light_pos', {light_x, light_y})
--- shader:send('colors', {r1, g1, b1, a1},  {r2, g2, b2, a2},  {r3, g3, b3, a3},  {r4, g4, b4, a4})
--- ```
--- 
--- Uniform / extern variables are read-only in the shader code and remain constant until modified by a Shader:send call. Uniform variables can be accessed in both the Vertex and Pixel components of a shader, as long as the variable is declared in each.
--- 
--- @overload fun(self: love.Shader, name: string, vector: table, ...)
--- @overload fun(self: love.Shader, name: string, matrix: table, ...)
--- @overload fun(self: love.Shader, name: string, texture: love.Texture)
--- @overload fun(self: love.Shader, name: string, boolean: boolean, ...)
--- @overload fun(self: love.Shader, name: string, matrixlayout: love.MatrixLayout, matrix: table, ...)
--- @overload fun(self: love.Shader, name: string, data: love.Data, offset?: number, size?: number)
--- @overload fun(self: love.Shader, name: string, data: love.Data, matrixlayout: love.MatrixLayout, offset?: number, size?: number)
--- @overload fun(self: love.Shader, name: string, matrixlayout: love.MatrixLayout, data: love.Data, offset?: number, size?: number)
--- 
--- @param name string # Name of the number to send to the shader.
--- @param number number # Number to send to store in the uniform variable.
--- @vararg number # Additional numbers to send if the uniform variable is an array.
--- 
function Shader:send(name, number, ...)
    self._shader:send(name, number, ...)
end

---
--- Sends one or more colors to a special (''extern'' / ''uniform'') vec3 or vec4 variable inside the shader. The color components must be in the range of 1. The colors are gamma-corrected if global gamma-correction is enabled.
--- 
--- Extern variables must be marked using the ''extern'' keyword, e.g.
--- 
--- ```glsl
--- extern vec4 Color;
--- ```
--- The corresponding sendColor call would be
--- 
--- ```lua
--- shader:sendColor('Color', {r, g, b, a})
--- ```
--- Extern variables can be accessed in both the Vertex and Pixel stages of a shader, as long as the variable is declared in each.
---
--- @param  name   string   The name of the color extern variable to send to in the shader.
--- @param  color  table    A table with red, green, blue, and optional alpha color components in the range of 1 to send to the extern as a vector.
--- @vararg table           Additional colors to send in case the extern is an array. All colors need to be of the same size (e.g. only vec3's).
---
function Shader:sendColor(name, color, ...)
    self._shader:sendColor(name, color, ...)
end

function Shader:free()
    self._shader:release()
    self._shader = nil
end

return Shader