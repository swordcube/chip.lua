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

local huge = math.huge
local tblInsert = table.insert
local tblRemoveItem = table.removeItem
local tblContains = table.contains

---
--- @class chip.core.Group : chip.core.Actor
--- 
--- An object which represents a group of actors.
---
local Group = Actor:extend("Group", ...)

function Group:constructor()
    Group.super.constructor(self)

    ---
    --- @protected
    ---
    self._members = {} --- @type table<any>

    ---
    --- @protected
    ---
    self._length = 0 --- @type integer
end

---
--- Returns a list of all members in this group.
---
function Group:getMembers()
    return self._members
end

---
--- Returns the amount of members in this group.
---
function Group:getLength()
    return self._length
end

---
--- @param  func      boolean
--- @param  recurse?  boolean
---
function Group:forEach(func, recurse)
    if recurse == nil then
        recurse = false
    end
    local members = self._members
    local length = self._length
    for i = 1, length do
        local actor = members[i] --- @type chip.core.Actor
        if actor then
            func(actor)
            if recurse and actor:is(Group) then
                actor:forEach(func, recurse)
            end
        end
    end
end

---
--- @param  func      boolean
--- @param  recurse?  boolean
---
function Group:forEachExisting(func, recurse)
    if recurse == nil then
        recurse = false
    end
    local members = self._members
    local length = self._length
    for i = 1, length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() then
            func(actor)
            if recurse and actor:is(Group) then
                actor:forEach(func, recurse)
            end
        end
    end
end

---
--- @param  func      boolean
--- @param  recurse?  boolean
---
function Group:forEachDead(func, recurse)
    if recurse == nil then
        recurse = false
    end
    local members = self._members
    local length = self._length
    for i = 1, length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and not actor:isExisting() then
            func(actor)
            if recurse and actor:is(Group) then
                actor:forEach(func, recurse)
            end
        end
    end
end

---
--- Checks if this group contains the given actor.
--- 
--- @param  actor  chip.core.Actor  The actor to check.
---
function Group:contains(actor)
    return tblContains(self._members, actor)
end

---
--- Adds an actor to this group.
--- 
--- @param  actor  chip.core.Actor  The actor to add.
---
function Group:add(actor)
    if actor == nil then
        print("Cannot add an invalid actor to this group!")
        return
    end
    if tblContains(self._members, actor) then
        print("This group already contains that actor!")
        return
    end
    actor._parent = self
    self._length = self._length + 1
    tblInsert(self._members, actor)
end

---
--- Inserts an actor at the specified index in this group.
--- 
--- @param  idx    integer          The index to insert the actor at.
--- @param  actor  chip.core.Actor  The actor to insert.
---
function Group:insert(idx, actor)
    if actor == nil then
        print("Cannot add an invalid actor to this group!")
        return
    end
    if tblContains(self._members, actor) then
        print("This group already contains that actor!")
        return
    end
    actor._parent = self
    self._length = self._length + 1
    tblInsert(self._members, idx, actor)
end

---
--- Removes an actor from this group.
--- 
--- @param  actor  chip.core.Actor  The actor to remove.
---
function Group:remove(actor)
    if actor == nil then
        print("Cannot remove an invalid actor from this group!")
        return
    end
    if not tblContains(self._members, actor) then
        print("This group does not contain that actor!")
        return
    end
    actor._parent = nil
    self._length = self._length - 1
    tblRemoveItem(self._members, actor)
end

---
--- Moves an actor in this group to the specified index.
--- 
--- @param  actor  chip.core.Actor  The actor to move.
--- @param  idx    integer          The index to move the actor to.
---
function Group:move(actor, idx)
    if actor == nil then
        print("Cannot move an invalid actor in this group!")
        return
    end
    if not tblContains(self._members, actor) then
        print("This group does not contain that actor!")
        return
    end
    tblRemoveItem(self._members, actor)
    tblInsert(self._members, idx, actor)
end

---
--- @param  class    chip.core.Actor
--- @param  factory  function?
--- @param  revive   boolean?
---
--- @return any
---
function Group:recycle(class, factory, revive)
    revive = (revive ~= nil) and revive or true
    for i = 1, self._length do
        local actor = self._members[i] --- @type chip.core.Actor
        if not actor:isExisting() and actor:is(class) then
            if revive then
                actor:revive()
            end
            return actor
        end
    end
    if factory then
        local actor = factory()
        self:add(actor)
        return actor
    end
    local actor = class:new()
    self:add(actor)
    return actor
end

function Group:findMinX()
    return self._length == 0 and self._x or self:_findMinXHelper()
end

function Group:findMaxX()
    return self._length == 0 and self._x or self:_findMaxXHelper()
end

function Group:findMinY()
    return self._length == 0 and self._y or self:_findMinYHelper()
end

function Group:findMaxY()
    return self._length == 0 and self._y or self:_findMaxYHelper()
end

function Group:getWidth()
    if self._length == 0 then
        return 0
    end
    return self:_findMaxXHelper() - self:_findMinXHelper()
end

function Group:getHeight()
    if self._length == 0 then
        return 0
    end
    return self:_findMaxYHelper() - self:_findMinYHelper()
end

---
--- Frees all of this group's members.
---
function Group:free()
    for i = 1, self._length do
        local actor = self._members[i] --- @type chip.core.Actor
        if actor then
            actor._parent = nil
            actor:free()
        end
    end
    Group.super.free(self)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
--- Updates all of this group's members.
--- 
--- @param  dt  number  The time since the last frame. (in seconds)
---
function Group:_update(dt)
    if self:isActive() then
        self:update(dt)
    end
    local members = self._members
    local length = self._length
    for i = 1, length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() and actor:isActive() then
            if actor:is(Group) then
                actor:_update(dt)
            else
                actor:update(dt)
            end
        end
    end
end

---
--- @protected
---
--- Draws all of this group's members to the screen.
---
function Group:_draw()
    if self:isVisible() then
        self:draw()
    end
    local members = self._members
    local length = self._length
    for i = 1, length do
        local actor = members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() and actor:isVisible() then
            if actor:is(Group) then
                actor:_draw()
            else
                actor:draw()
            end
        end
    end
end

---
--- @protected
---
--- The function that gets called when
--- this group receives an input event.
--- 
--- @param  event  chip.input.InputEvent
---
function Group:_input(event)
    if self:isActive() then
        self:input(event)
    end
    for i = 1, self._length do
        local actor = self._members[i] --- @type chip.core.Actor
        if actor and actor:isExisting() and actor:isActive() then
            if actor:is(Group) then
                actor:_input(event)
            else
                actor:input(event)
            end
        end
    end
end

---
--- @protected
---
function Group:_findMinXHelper()
    local value = huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local minX = 0.0
            if member:is(Group) then
                minX = member:findMinX()
            else
                minX = member:getX()
            end
            if minX < value then
                value = minX
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMaxXHelper()
    local value = -huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local maxX = 0.0
            if member:is(Group) then
                maxX = member:findMaxX()
            else
                maxX = member:getX() + member:getWidth()
            end
            if maxX > value then
                value = maxX
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMinYHelper()
    local value = huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local minY = 0.0
            if member:is(Group) then
                minY = member:findMinY()
            elseif member:is(Actor2D) then
                minY = member:getY()
            end
            if minY < value then
                value = minY
            end
        end
    end
    return value
end

---
--- @protected
---
function Group:_findMaxYHelper()
    local value = -huge
    for i = 1, self._length do
        local member = self._members[i]
        if member then
            local maxY = 0.0
            if member:is(Group) then
                maxY = member:findMaxY()
            elseif member:is(Actor2D) then
                maxY = member:getY() + member:getHeight()
            end
            if maxY > value then
                value = maxY
            end
        end
    end
    return value
end

return Group