---
--- @class chip.core.Group : chip.core.Actor
--- 
--- An object which represents a group of actors.
---
local Group = Actor:extend("Group", ...)

function Group:constructor()
    Group.super.constructor(self)

    ---
    --- A list of all members in this group.
    ---
    self.members = {} --- @type table<chip.core.Actor>

    ---
    --- The amount of members in this group.
    ---
    self.length = 0 --- @type integer
end

---
--- Updates all of this group's members.
--- 
--- @param  delta  number  The time since the last frame. (in seconds)
---
function Group:update(delta)
    for i = 1, self.length do
        local actor = self.members[i] --- @type chip.core.Actor
        if actor.exists and actor.active then
            actor:update(delta)
        end
    end
end

---
--- Draws all of this group's members to the screen.
---
function Group:draw()
    local cam = Camera.currentCamera
    if cam then
        cam:attach()
    end
    for i = 1, self.length do
        local actor = self.members[i] --- @type chip.core.Actor
        if actor.exists and actor.visible then
            if actor:is(CanvasLayer) then
                cam:detach()
                actor:draw()
                cam:attach()
            else
                actor:draw()
            end
        end
    end
    if cam then
        cam:detach()
    end
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
    if table.contains(self.members, actor) then
        print("This group already contains that actor!")
        return
    end
    self.length = self.length + 1
    table.insert(self.members, actor)
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
    if table.contains(self.members, actor) then
        print("This group already contains that actor!")
        return
    end
    self.length = self.length + 1
    table.insert(self.members, idx, actor)
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
    if not table.contains(self.members, actor) then
        print("This group does not contain that actor!")
        return
    end
    self.length = self.length - 1
    table.removeItem(self.members, actor)
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
    if not table.contains(self.members, actor) then
        print("This group does not contain that actor!")
        return
    end
    table.removeItem(self.members, actor)
    table.insert(self.members, idx, actor)
end

---
--- Frees all of this group's members.
---
function Group:free()
    for i = 1, self.length do
        local actor = self.members[i] --- @type chip.core.Actor
        actor:free()
    end
end

return Group