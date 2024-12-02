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
	typedef uint32_t SDL_DisplayID;
	typedef enum SDL_PixelFormat
	{
		SDL_PIXELFORMAT_UNKNOWN = 0,
		SDL_PIXELFORMAT_INDEX1LSB = 0x11100100u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_4321, 0, 1, 0), */
		SDL_PIXELFORMAT_INDEX1MSB = 0x11200100u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX1, SDL_BITMAPORDER_1234, 0, 1, 0), */
		SDL_PIXELFORMAT_INDEX2LSB = 0x1c100200u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_4321, 0, 2, 0), */
		SDL_PIXELFORMAT_INDEX2MSB = 0x1c200200u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX2, SDL_BITMAPORDER_1234, 0, 2, 0), */
		SDL_PIXELFORMAT_INDEX4LSB = 0x12100400u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_4321, 0, 4, 0), */
		SDL_PIXELFORMAT_INDEX4MSB = 0x12200400u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX4, SDL_BITMAPORDER_1234, 0, 4, 0), */
		SDL_PIXELFORMAT_INDEX8 = 0x13000801u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_INDEX8, 0, 0, 8, 1), */
		SDL_PIXELFORMAT_RGB332 = 0x14110801u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED8, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_332, 8, 1), */
		SDL_PIXELFORMAT_XRGB4444 = 0x15120c02u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_4444, 12, 2), */
		SDL_PIXELFORMAT_XBGR4444 = 0x15520c02u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_4444, 12, 2), */
		SDL_PIXELFORMAT_XRGB1555 = 0x15130f02u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_1555, 15, 2), */
		SDL_PIXELFORMAT_XBGR1555 = 0x15530f02u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_1555, 15, 2), */
		SDL_PIXELFORMAT_ARGB4444 = 0x15321002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_4444, 16, 2), */
		SDL_PIXELFORMAT_RGBA4444 = 0x15421002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_4444, 16, 2), */
		SDL_PIXELFORMAT_ABGR4444 = 0x15721002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_4444, 16, 2), */
		SDL_PIXELFORMAT_BGRA4444 = 0x15821002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_4444, 16, 2), */
		SDL_PIXELFORMAT_ARGB1555 = 0x15331002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_1555, 16, 2), */
		SDL_PIXELFORMAT_RGBA5551 = 0x15441002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_5551, 16, 2), */
		SDL_PIXELFORMAT_ABGR1555 = 0x15731002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_1555, 16, 2), */
		SDL_PIXELFORMAT_BGRA5551 = 0x15841002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_5551, 16, 2), */
		SDL_PIXELFORMAT_RGB565 = 0x15151002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_565, 16, 2), */
		SDL_PIXELFORMAT_BGR565 = 0x15551002u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED16, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_565, 16, 2), */
		SDL_PIXELFORMAT_RGB24 = 0x17101803u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_RGB, 0, 24, 3), */
		SDL_PIXELFORMAT_BGR24 = 0x17401803u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU8, SDL_ARRAYORDER_BGR, 0, 24, 3), */
		SDL_PIXELFORMAT_XRGB8888 = 0x16161804u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_8888, 24, 4), */
		SDL_PIXELFORMAT_RGBX8888 = 0x16261804u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBX, SDL_PACKEDLAYOUT_8888, 24, 4), */
		SDL_PIXELFORMAT_XBGR8888 = 0x16561804u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_8888, 24, 4), */
		SDL_PIXELFORMAT_BGRX8888 = 0x16661804u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRX, SDL_PACKEDLAYOUT_8888, 24, 4), */
		SDL_PIXELFORMAT_ARGB8888 = 0x16362004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_8888, 32, 4), */
		SDL_PIXELFORMAT_RGBA8888 = 0x16462004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_RGBA, SDL_PACKEDLAYOUT_8888, 32, 4), */
		SDL_PIXELFORMAT_ABGR8888 = 0x16762004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_8888, 32, 4), */
		SDL_PIXELFORMAT_BGRA8888 = 0x16862004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_BGRA, SDL_PACKEDLAYOUT_8888, 32, 4), */
		SDL_PIXELFORMAT_XRGB2101010 = 0x16172004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XRGB, SDL_PACKEDLAYOUT_2101010, 32, 4), */
		SDL_PIXELFORMAT_XBGR2101010 = 0x16572004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_XBGR, SDL_PACKEDLAYOUT_2101010, 32, 4), */
		SDL_PIXELFORMAT_ARGB2101010 = 0x16372004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ARGB, SDL_PACKEDLAYOUT_2101010, 32, 4), */
		SDL_PIXELFORMAT_ABGR2101010 = 0x16772004u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_PACKED32, SDL_PACKEDORDER_ABGR, SDL_PACKEDLAYOUT_2101010, 32, 4), */
		SDL_PIXELFORMAT_RGB48 = 0x18103006u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGB, 0, 48, 6), */
		SDL_PIXELFORMAT_BGR48 = 0x18403006u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGR, 0, 48, 6), */
		SDL_PIXELFORMAT_RGBA64 = 0x18204008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_RGBA, 0, 64, 8), */
		SDL_PIXELFORMAT_ARGB64 = 0x18304008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ARGB, 0, 64, 8), */
		SDL_PIXELFORMAT_BGRA64 = 0x18504008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_BGRA, 0, 64, 8), */
		SDL_PIXELFORMAT_ABGR64 = 0x18604008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYU16, SDL_ARRAYORDER_ABGR, 0, 64, 8), */
		SDL_PIXELFORMAT_RGB48_FLOAT = 0x1a103006u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGB, 0, 48, 6), */
		SDL_PIXELFORMAT_BGR48_FLOAT = 0x1a403006u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGR, 0, 48, 6), */
		SDL_PIXELFORMAT_RGBA64_FLOAT = 0x1a204008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_RGBA, 0, 64, 8), */
		SDL_PIXELFORMAT_ARGB64_FLOAT = 0x1a304008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ARGB, 0, 64, 8), */
		SDL_PIXELFORMAT_BGRA64_FLOAT = 0x1a504008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_BGRA, 0, 64, 8), */
		SDL_PIXELFORMAT_ABGR64_FLOAT = 0x1a604008u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF16, SDL_ARRAYORDER_ABGR, 0, 64, 8), */
		SDL_PIXELFORMAT_RGB96_FLOAT = 0x1b10600cu,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGB, 0, 96, 12), */
		SDL_PIXELFORMAT_BGR96_FLOAT = 0x1b40600cu,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGR, 0, 96, 12), */
		SDL_PIXELFORMAT_RGBA128_FLOAT = 0x1b208010u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_RGBA, 0, 128, 16), */
		SDL_PIXELFORMAT_ARGB128_FLOAT = 0x1b308010u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ARGB, 0, 128, 16), */
		SDL_PIXELFORMAT_BGRA128_FLOAT = 0x1b508010u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_BGRA, 0, 128, 16), */
		SDL_PIXELFORMAT_ABGR128_FLOAT = 0x1b608010u,
			/* SDL_DEFINE_PIXELFORMAT(SDL_PIXELTYPE_ARRAYF32, SDL_ARRAYORDER_ABGR, 0, 128, 16), */

		SDL_PIXELFORMAT_YV12 = 0x32315659u,      /**< Planar mode: Y + V + U  (3 planes) */
			/* SDL_DEFINE_PIXELFOURCC('Y', 'V', '1', '2'), */
		SDL_PIXELFORMAT_IYUV = 0x56555949u,      /**< Planar mode: Y + U + V  (3 planes) */
			/* SDL_DEFINE_PIXELFOURCC('I', 'Y', 'U', 'V'), */
		SDL_PIXELFORMAT_YUY2 = 0x32595559u,      /**< Packed mode: Y0+U0+Y1+V0 (1 plane) */
			/* SDL_DEFINE_PIXELFOURCC('Y', 'U', 'Y', '2'), */
		SDL_PIXELFORMAT_UYVY = 0x59565955u,      /**< Packed mode: U0+Y0+V0+Y1 (1 plane) */
			/* SDL_DEFINE_PIXELFOURCC('U', 'Y', 'V', 'Y'), */
		SDL_PIXELFORMAT_YVYU = 0x55595659u,      /**< Packed mode: Y0+V0+Y1+U0 (1 plane) */
			/* SDL_DEFINE_PIXELFOURCC('Y', 'V', 'Y', 'U'), */
		SDL_PIXELFORMAT_NV12 = 0x3231564eu,      /**< Planar mode: Y + U/V interleaved  (2 planes) */
			/* SDL_DEFINE_PIXELFOURCC('N', 'V', '1', '2'), */
		SDL_PIXELFORMAT_NV21 = 0x3132564eu,      /**< Planar mode: Y + V/U interleaved  (2 planes) */
			/* SDL_DEFINE_PIXELFOURCC('N', 'V', '2', '1'), */
		SDL_PIXELFORMAT_P010 = 0x30313050u,      /**< Planar mode: Y + U/V interleaved  (2 planes) */
			/* SDL_DEFINE_PIXELFOURCC('P', '0', '1', '0'), */
		SDL_PIXELFORMAT_EXTERNAL_OES = 0x2053454fu,     /**< Android video texture format */
			/* SDL_DEFINE_PIXELFOURCC('O', 'E', 'S', ' ') */

		/* Aliases for RGBA byte arrays of color data, for the current platform */
		// #if SDL_BYTEORDER == SDL_BIG_ENDIAN
		// SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_RGBA8888,
		// SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_ARGB8888,
		// SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_BGRA8888,
		// SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_ABGR8888,
		// SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_RGBX8888,
		// SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_XRGB8888,
		// SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_BGRX8888,
		// SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_XBGR8888
		// #else
		// SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888,
		// SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_BGRA8888,
		// SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_ARGB8888,
		// SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_RGBA8888,
		// SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_XBGR8888,
		// SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_BGRX8888,
		// SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_XRGB8888,
		// SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_RGBX8888
		// #endif
	} SDL_PixelFormat;

	typedef struct SDL_DisplayMode
	{
		SDL_DisplayID displayID;        /**< the display this mode is associated with */
		SDL_PixelFormat format;         /**< pixel format */
		int w;                          /**< width */
		int h;                          /**< height */
		float pixel_density;            /**< scale converting size to pixels (e.g. a 1920x1080 mode with 2.0 scale would have 3840x2160 pixels) */
		float refresh_rate;             /**< refresh rate (or 0.0f for unspecified) */
		int refresh_rate_numerator;     /**< precise refresh rate numerator (or 0 for unspecified) */
		int refresh_rate_denominator;   /**< precise refresh rate denominator */
	} SDL_DisplayMode;

	typedef struct SDL_Window SDL_Window;
	SDL_Window *SDL_GL_GetCurrentWindow(void);

	int SDL_GetDisplayForWindow(SDL_Window *window);
	const SDL_DisplayMode *SDL_GetDesktopDisplayMode(SDL_DisplayID displayIndex);
]]

---
--- @class chip.Native
---
--- A class for easily accessing native system functionality.
---
local Native = {}
Native.consoleColor = {
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
function Native.getMonitorRefreshRate()
	local displayID = SDL3.SDL_GetDisplayForWindow(SDL3.SDL_GL_GetCurrentWindow())
	local dm = SDL3.SDL_GetDesktopDisplayMode(displayID)
	return dm.refresh_rate
end
function Native.getScreenWidth()
	local displayID = SDL3.SDL_GetDisplayForWindow(SDL3.SDL_GL_GetCurrentWindow())
	local dm = SDL3.SDL_GetDesktopDisplayMode(displayID)
	return dm.w
end
function Native.getScreenHeight()
	local displayID = SDL3.SDL_GetDisplayForWindow(SDL3.SDL_GL_GetCurrentWindow())
	local dm = SDL3.SDL_GetDesktopDisplayMode(displayID)
	return dm.h
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