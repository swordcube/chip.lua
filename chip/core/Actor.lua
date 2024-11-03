---
--- @class chip.core.Actor
---
--- A base class for all of your game objects.
---
local Actor = Object:extend("Actor", ...)

function Actor:constructor()
    ---
    --- Controls whether or not this actor
    --- is allowed to automatically be updated.
    ---
    self.active = true --- @type boolean

    ---
    --- Controls whether or not this actor
    --- is visible on-screen.
    ---
    self.visible = true --- @type boolean

    ---
    --- Controls whether or not this actor
    --- is considered existing.
    --- 
    --- Which means if set to `false`, this actor
    --- will no longer update or draw automatically,
    --- regardless of the `active` and `visible` flags.
    --- 
    --- You can recycle non-existing actors for later use
    --- to save on allocations and memory.
    ---
    self.exists = true --- @type boolean
end

---
--- Updates this actor.
--- 
--- @param  delta  number  The time since the last frame. (in seconds)
---
function Actor:update(delta)
end

---
--- Draws this actor to the screen.
---
function Actor:draw()
end

return Actor