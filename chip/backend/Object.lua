---
--- @class chip.backend.Object
---
--- The base class for all objects.
---
local Object = Class:extend("Object", ...)

---
--- Frees this object from memory immediately.
--- 
--- NOTE: This object will immediately become unstable
--- after this is called!
---
function Object:free()
end

return Object