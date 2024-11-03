---
--- @class chip.backend.RefCounted : chip.backend.Object
---
--- The base class for all reference counted
--- objects, such as textures, audio, fonts, etc.
---
local RefCounted = Class:extend("RefCounted", ...)

function RefCounted:constructor()
    ---
    --- @type integer
    ---
    --- The amount of references this object has.
    --- 
    --- If this value gets below 1, this object will
    --- automatically free itself from memory.
    ---
    self.references = nil

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
    self.references = self.references + 1
end

---
--- Removes a reference from this object.
--- 
--- Only use this if you know what you're doing!
---
function RefCounted:unreference()
    self.references = self.references - 1
end

--- [ PRIVATE API ] ---

function RefCounted:get_references()
    return self._references
end

function RefCounted:set_references(val)
    self._references = val
    if self._references <= 0 then
        self._references = 0
        self:free()
    end
end

return RefCounted