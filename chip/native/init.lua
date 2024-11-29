local gfx = love.graphics
local _gcCount_ = "count"

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
	return 60 --- placeholder
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