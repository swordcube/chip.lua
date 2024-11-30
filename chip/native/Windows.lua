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

-- thx raltyro for giving me this <3
local Native = {}

local ffi = require("ffi")

local comdlg32 = ffi.load("comdlg32")
local dwmapi = ffi.load("dwmapi")
local kernel32 = ffi.load("kernel32")
local SDL3 = ffi.load("SDL3")

ffi.cdef [[\
	// windows api
	typedef void* HWND;
	typedef const char* LPCSTR;
	typedef char* LPSTR;
	typedef int BOOL;
	typedef unsigned int DWORD;
	typedef void* HINSTANCE;
	typedef unsigned short WORD;
	typedef long long LPARAM;
	typedef const void* LPCVOID;

	typedef struct {
		DWORD     lStructSize;
		HWND      hwndOwner;
		HINSTANCE hInstance;
		LPCSTR    lpstrFilter;
		LPSTR     lpstrCustomFilter;
		DWORD     nMaxCustFilter;
		DWORD     nFilterIndex;
		LPSTR     lpstrFile;
		DWORD     nMaxFile;
		LPSTR     lpstrFileTitle;
		DWORD     nMaxFileTitle;
		LPCSTR    lpstrInitialDir;
		LPCSTR    lpstrTitle;
		DWORD     Flags;
		WORD      nFileOffset;
		WORD      nFileExtension;
		LPCSTR    lpstrDefExt;
		LPARAM    lCustData;
		LPCVOID   lpfnHook;
		LPCSTR    lpTemplateName;
		void*     pvReserved;
		DWORD     dwReserved;
		DWORD     FlagsEx;
	} WINDOWDIALOGUE;

	BOOL GetSaveFileNameA(WINDOWDIALOGUE *lpofn);
	BOOL GetOpenFileNameA(WINDOWDIALOGUE *lpofn);


	typedef int BOOL;
	typedef long LONG;
	typedef uint32_t UINT;
	typedef int HRESULT;
	typedef unsigned int DWORD;
	typedef const void* PVOID;
	typedef const void* LPCVOID;
	typedef const char* LPCSTR;
	typedef DWORD HMENU;
	typedef struct HWND HWND;
	typedef void* HANDLE;
    typedef HANDLE HCURSOR;

	typedef size_t SIZE_T;

	typedef struct tagRECT {
		union{
			struct{
				LONG left;
				LONG top;
				LONG right;
				LONG bottom;
			};
			struct{
				LONG x1;
				LONG y1;
				LONG x2;
				LONG y2;
			};
			struct{
				LONG x;
				LONG y;
			};
		};
	} RECT, *PRECT,  *NPRECT,  *LPRECT;

	typedef struct _PROCESS_MEMORY_COUNTERS {
		DWORD  cb;
		DWORD  PageFaultCount;
		SIZE_T PeakWorkingSetSize;
		SIZE_T WorkingSetSize;
		SIZE_T QuotaPeakPagedPoolUsage;
		SIZE_T QuotaPagedPoolUsage;
		SIZE_T QuotaPeakNonPagedPoolUsage;
		SIZE_T QuotaNonPagedPoolUsage;
		SIZE_T PagefileUsage;
		SIZE_T PeakPagefileUsage;
	} PROCESS_MEMORY_COUNTERS;

	typedef const PROCESS_MEMORY_COUNTERS* PPROCESS_MEMORY_COUNTERS;

	HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
	HWND FindWindowExA(HWND hwndParent, HWND hwndChildAfter, LPCSTR lpszClass, LPCSTR lpszWindow);
	HWND GetActiveWindow(void);
	LONG SetWindowLongA(HWND hWnd, int nIndex, LONG dwNewLong);
	BOOL ShowWindow(HWND hWnd, int nCmdShow);
	BOOL UpdateWindow(HWND hWnd);

	HRESULT DwmGetWindowAttribute(HWND hwnd, DWORD dwAttribute, PVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, LPCVOID pvAttribute, DWORD cbAttribute);
	HRESULT DwmFlush();

	HCURSOR LoadCursorA(HANDLE hInstance, const char* lpCursorName);
    HCURSOR SetCursor(HCURSOR hCursor);

	HANDLE GetStdHandle(DWORD nStdHandle);
	BOOL SetConsoleTextAttribute(HANDLE hConsoleOutput, WORD wAttributes);

	HANDLE GetCurrentProcess();
	BOOL K32GetProcessMemoryInfo(HANDLE hProcess, PPROCESS_MEMORY_COUNTERS ppsmemCounters, DWORD cb);

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

--local Rect = ffi.metatype("RECT", {})
local function toInt(v) return v and 1 or 0 end

local function getWindowHandle(title)
	local window = ffi.C.FindWindowA(nil, title)
	if window == nil then
		window = ffi.C.GetActiveWindow()
		window = ffi.C.FindWindowExA(window, nil, nil, title)
	end
	return window
end
local function getActiveWindow() return ffi.C.GetActiveWindow() or getWindowHandle(love.window.getTitle()) end

local function openDialogue(title, fileTypes, initialFile)
	local ofn = ffi.new("WINDOWDIALOGUE")
	ofn.lStructSize = ffi.sizeof("WINDOWDIALOGUE")

	if not fileTypes then 
		ofn.lpstrFilter = "All Files\0*.*"
	else
		local filters = ""
		for _, type in ipairs(fileTypes) do filters = filters .. type[1] .. "\0" .. type[2] .. "\0" end
		ofn.lpstrFilter = filters
	end

	ofn.lpstrFile, ofn.nMaxFile = initialFile and ffi.new("char[260]", initialFile) or ffi.new("char[260]"), 260
	ofn.lpstrFileTitle, ofn.nMaxFileTitle = ffi.new("char[260]"), 260
	ofn.lpstrTitle = title
	ofn.Flags = 0x00000002

	return ofn
end

Native.defaultCursorType = "ARROW"
Native.cursorType = {
	ARROW = 32512,
	IBEAM = 32513,
	WAIT = 32514,
	CROSS = 32515,
	UPARROW = 32516,
	SIZENWSE = 32642,
	SIZENESW = 32643,
	SIZEWE = 32644,
	SIZENS = 32645,
	SIZEALL = 32646,
	NO = 32648,
	HAND = 32649,
	APPSTARTING = 32650,
	HELP = 32651,
	PIN = 32671,
	PERSON = 32672
}
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
Native.STD_INPUT_HANDLE = ffi.cast("DWORD", -10)
Native.STD_OUTPUT_HANDLE = ffi.cast("DWORD", -11)
Native.STD_ERROR_HANDLE = ffi.cast("DWORD", -12)
Native.INVALID_HANDLE_VALUE = ffi.cast("HANDLE", -1)

function Native.askOpenFile(title, file_types)
	local dialogue = openDialogue(title or "Open File", file_types)
	if comdlg32.GetOpenFileNameA(dialogue) == 1 then return ffi.string(dialogue.lpstrFile) end
end

function Native.askSaveAsFile(title, file_types, initial_file)
	local dialogue = openDialogue(title or "Save As", file_types, "")
	if comdlg32.GetSaveFileNameA(dialogue) == 1 then return ffi.string(dialogue.lpstrFile) end
end

function Native.setCursor(type)
	local cursorType = Native.cursorType[type:upper()]
	if cursorType then
		ffi.C.SetCursor(ffi.C.LoadCursorA(nil, ffi.cast("const char*", cursorType)))
	end
end

function Native.setDarkMode(enable)
	local window = getActiveWindow()
	local darkMode = ffi.new("int[1]", toInt(enable))

	if dwmapi.DwmSetWindowAttribute(window, 19, darkMode, 4) ~= 0 then
		dwmapi.DwmSetWindowAttribute(window, 20, darkMode, 4)
	end
end

function Native.setConsoleColors(fg_color, bg_color)
	if fg_color == nil or fg_color == Native.consoleColor.NONE then
		fg_color = Native.consoleColor.LIGHT_GRAY
	end
	if bg_color == nil or bg_color == Native.consoleColor.NONE then
		bg_color = Native.consoleColor.BLACK
	end
	local console = ffi.C.GetStdHandle(Native.STD_OUTPUT_HANDLE)
	ffi.C.SetConsoleTextAttribute(console, (bg_color * 16) + fg_color)
end

local pmc_size = ffi.sizeof('PROCESS_MEMORY_COUNTERS')

function Native.getProcessMemory()
	local ppsmemCounters = ffi.new('PROCESS_MEMORY_COUNTERS[1]')
	ffi.C.K32GetProcessMemoryInfo(ffi.C.GetCurrentProcess(), ppsmemCounters, pmc_size)
	return tonumber(ppsmemCounters[0].WorkingSetSize) / 1.5
end

function Native.getMonitorRefreshRate()
	local displayID = SDL3.SDL_GetDisplayForWindow(SDL3.SDL_GL_GetCurrentWindow())
	local dm = SDL3.SDL_GetDesktopDisplayMode(displayID)
	return dm.refresh_rate
end

return Native