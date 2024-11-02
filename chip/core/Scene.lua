---
--- @class chip.core.Scene : chip.core.Group
---
--- A class which represents a scene.
--- 
--- This could be a main menu, a level, a game over screen,
--- anything you want it to be!
---
local Scene = Group:extend("Scene", ...)

---
--- Override this function to initialize your scene.
---
function Scene:init()
end

return Scene