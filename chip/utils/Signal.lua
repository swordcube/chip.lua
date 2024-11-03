---
--- @class chip.utils.Signal 
---
local Signal = Class:extend("Signal", ...)

function Signal:constructor()
    ---
    --- @protected
    ---
    self._connected = {}

	---
    --- @protected
    ---
    self._connectedOnce = {}

	---
    --- @protected
    ---
    self._cancelled = false
end

-- This function is syntax sugar.
function Signal:type(...)
	return self
end

---
--- Connects a listener function to this signal.
---
--- @param  listener  function  The listener to connect to this signal.
--- @param  priority  integer?  The priority of the listener. Lower numbers are called first.
--- @param  once      boolean?  Whether or not the listener should only be called once.
---
function Signal:connect(listener, priority, once)
	if type(listener) ~= "function" or table.contains(self._connected, listener) then
		return
	end
	if priority then
		table.insert(self._connected, listener, priority)
	else
		table.insert(self._connected, listener)
	end
	if once then
		table.insert(self._connectedOnce, listener)
	end
end

---
--- Disconnects a listener function from this signal.
---
--- @param  listener  function  The listener to disconnect from this signal.
---
function Signal:disconnect(listener)
	if type(listener) ~= "function" or not table.contains(self._connected, listener) then
		return
	end
	if table.contains(self._connectedOnce, listener) then
		table.removeItem(self._connectedOnce, listener)
	end
	table.removeItem(self._connected, listener)
end

---
--- Emits/calls each listener functions connected
--- to this signal.
---
--- @param  ...  vararg  The parameters to call on each function.
---
function Signal:emit(...)
	self._cancelled = false
	local connectedOnce = {}
	for i = 1, #self._connected do
		if self._cancelled then
			break
		end
		local func = self._connected[i]
		if table.contains(self._connectedOnce, func) then
			table.insert(connectedOnce, func)
		end
		func(...)
	end
	for i = 1, #connectedOnce do
		self:disconnect(connectedOnce[i])
	end
end

---
--- Cancels all listener functions from this signal.
---
function Signal:cancel()
	self._cancelled = true
end

---
--- Removes all listener functions from this signal.
---
function Signal:reset()
	self._connected = {}
end

return Signal