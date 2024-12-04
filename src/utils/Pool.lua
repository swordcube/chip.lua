--[[
    chip.lua: a simple 2D game framework built off of Love2D
    Copyright (C) 2024  swordcube

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

---
--- @class chip.utils.Pool
---
local Pool = Class:extend("Pool", ...)

function Pool:constructor(class)
	self._pooledClass = class
	self._pool = {}

	self.count = 1
end

function Pool:get()
	if self.count == 1 then
		return self._pooledClass:new()
	end
	self.count = self.count - 1
	return self._pool[self.count]
end

function Pool:put(obj)
	if obj == nil then
		return
	end
	local i = table.indexOf(self._pool, obj)
	if i == -1 or i >= self.count then
		if obj.destroy ~= nil then
			obj:destroy()
		end
		self._pool[self.count] = obj
		self.count = self.count + 1
	end
end

function Pool:putUnsafe(obj)
	if obj == nil then
		return
	end
	if obj.destroy ~= nil then
		obj:destroy()
	end
	self._pool[self.count] = obj
	self.count = self.count + 1
end

function Pool:preAllocate(objAmount)
	while objAmount > 0 do
		objAmount = objAmount - 1
		self._pool[self.count] = self._pooledClass:new()
		self.count = self.count + 1
	end
end

function Pool:clear()
	self.count = 0
	self._pool = {}
end

return Pool