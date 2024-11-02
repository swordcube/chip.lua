--- [ CORE IMPORTS ] ---

Class = require("chip.libs.Class") --- @type chip.libs.Class

--- [ GRAPHICS IMPORTS ] ---

Sprite = require("chip.graphics.Sprite") --- @type chip.graphics.Sprite

--- [ CORE ] ---

---
--- The class responsible for initializing
--- the core of Chip.
---
--- @class chip.Core
---
local Core = Class:extend("Core", ...)

---
--- Initializes chip with some given settings,
--- specific to your game!
---
--- @param  settings  chip.GameSettings
---
function Core.init(settings)

end

return Core