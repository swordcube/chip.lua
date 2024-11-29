-- thx raltyro for giving me this <3
local Native = {}

local ffi = require("ffi")

local comdlg32 = ffi.load("comdlg32")
local dwmapi = ffi.load("dwmapi")
local kernel32 = ffi.load("kernel32")

ffi.cdef [[\
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

return Native