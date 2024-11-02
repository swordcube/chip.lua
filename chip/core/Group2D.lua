---
--- @class chip.core.Group2D : chip.core.Group
--- 
--- A group object which can be moved around on
--- the X and Y axis.
---
local Group2D = Group:extend("Group2D", ...)

-- TODO: add width and height to this

function Group2D:constructor()
    Group2D.super.constructor(self)

    ---
    --- The X coordinate of this actor on-screen. (in pixels)
    ---
    self.x = 0.0 --- @type number

    ---
    --- The Y coordinate of this actor on-screen. (in pixels)
    ---
    self.y = 0.0 --- @type number
end

---
--- Draws all of this group's members to the screen.
---
function Group2D:draw()
    -- TODO: the shit.
    Group2D.super.draw(self)
end

return Group2D