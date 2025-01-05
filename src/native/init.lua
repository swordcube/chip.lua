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
local _gcCount_ = "count"

local ffi = require("ffi")

local SDL3 = ffi.load("SDL3")

ffi.cdef [[\
	// sdl3 api
	typedef struct SDL_Window SDL_Window;
	SDL_Window *SDL_GL_GetCurrentWindow(void);

	bool SDL_ShowWindow(SDL_Window *window);
	bool SDL_HideWindow(SDL_Window *window);

	void SDL_DelayPrecise(uint64_t ns);
	uint64_t SDL_GetTicksNS(void);
]]

---
--- @class chip.Native
---
--- A class for easily accessing native system functionality.
---
local Native = {}
Native.ConsoleColor = {
	BLACK = 0,
	DARK_BLUE = 1,
	DARK_GREEN = 2,
	DARK_CYAN = 3,
	DARK_RED = 4,
	DARK_MAGENTA = 5,
	DARK_YELLOW = 6,
	LIGHT_GRAY = 7,
	GRAY = 8,
	BLUE = 9,
	GREEN = 10,
	CYAN = 11,
	RED = 12,
	MAGENTA = 13,
	YELLOW = 14,
	WHITE = 15,
	NONE = -1
}

function Native.askOpenFile(title, file_types)
	return ""
end
function Native.askSaveAsFile(title, file_types, initial_file)
	return ""
end
function Native.setCursor(type) end
function Native.setDarkMode(enable) end
function Native.forceWindowRedraw()
    -- Needed for dark mode to apply correctly
    -- on Windows 10, not needed on Windows 11
    local w, h, f = love.window.getMode()
    love.window.setMode(w, h, {
        borderless = true
    })
    love.window.setMode(w, h, f)
end
function Native.setConsoleColors(fg_color, bg_color) end
function Native.getProcessMemory()
	return collectgarbage(_gcCount_) + gfx.getStats().texturememory
end
function Native.showWindow()
	SDL3.SDL_ShowWindow(SDL3.SDL_GL_GetCurrentWindow())
end
function Native.hideWindow()
	SDL3.SDL_HideWindow(SDL3.SDL_GL_GetCurrentWindow())
end
function Native.nanoSleep(ns)
	SDL3.SDL_DelayPrecise(ns)
end
function Native.getTicksNS()
	return SDL3.SDL_GetTicksNS()
end

-----------------------------------------
-- Don't worry about the stuff below!! --
-----------------------------------------

local osNative = {}
local osName = love.system.getOS()

if osName == "Windows" then
	osNative = require((...) .. "." .. "Windows")
end

local retNative = {}
for key, value in pairs(Native) do
	if osNative[key] then
		retNative[key] = osNative[key]
	else
		retNative[key] = value
	end
end

return retNative