---
--- @class chip.backend.RefCounted : chip.backend.Object
---
--- The base class for all reference counted
--- objects, such as textures, audio, fonts, etc.
---
local RefCounted = Class:extend("RefCounted", ...)

function RefCounted:constructor()
    ---
    --- @protected
    --- @type integer
    ---
    self._references = 0
end

---
--- Adds a reference to this object.
--- 
--- Only use this if you know what you're doing!
---
function RefCounted:reference()
    self:_setReferences(self._references + 1)
end

---
--- Removes a reference from this object.
--- 
--- Only use this if you know what you're doing!
---
function RefCounted:unreference()
    self:_setReferences(self._references - 1)
end

function RefCounted:getReferences()
    return self._references
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function RefCounted:_setReferences(val)
    self._references = val
    if self._references <= 0 then
        self._references = 0
        self:free()
    end
end

return RefCounted