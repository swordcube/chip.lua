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

local AnimationData = qrequire("chip.animation.AnimationData") --- @type chip.animation.AnimationData

---
--- @class chip.animation.AnimationController
---
local AnimationController = Class:extend("AnimationController", ...)

function AnimationController:constructor(parent)
    ---
    --- @protected
    --- @type chip.graphics.Sprite
    ---
    self._parent = parent
    
    self._animations = {}
    
    ---
    --- @protected
    --- @type string?
    ---
    self._name = nil

    --- 
    --- @protected
    --- @type chip.animation.AnimationData?
    ---
    self._curAnim = nil
    
    ---
    --- The function that gets ran when
    --- the current animation has finished playing.
    --- 
    --- @type function?
    ---
    self._onComplete = nil
    
    ---
    --- Whether or not the currently playing
    --- animation is reversed.
    ---
    self._reversed = false
    
    ---
    --- Whether or not the currently playing
    --- animation is finished.
    ---
    self._finished = false

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = 0.0
end

---
--- Returns a map of all added animations.
--- 
--- @return table<string, chip.animation.AnimationData?>
---
function AnimationController:getAnimationList()
    return self._animations
end

---
--- The data of the currently playing animation.
---
--- ⚠️ **WARNING**: This can be `nil`!
--- 
--- @return chip.animation.AnimationData?
---
function AnimationController:getCurrentAnimation()
    return self._curAnim
end

---
--- Returns the name of the currently playing animation.
---
--- ⚠️ **WARNING**: This can be `nil`!
--- 
--- @return string?
---
function AnimationController:getCurrentAnimationName()
    if self._curAnim ~= nil then
        return self._curAnim.name
    end
    return nil
end

---
--- Returns the animation with the given name.
--- 
--- @param  name  string  The name of the animation to return.
--- 
--- @return chip.animation.AnimationData?
---
function AnimationController:getAnimationByName(name)
    return self._animations[name]
end

---
--- Sets the function that gets ran when
--- the current animation has finished playing.
--- 
--- @param  func  function  The function to run on completion.
---
function AnimationController:setCompletionCallback(func)
    self._onComplete = func
end

---
--- Returns whether or not the current animation is reversed.
---
function AnimationController:isReversed()
    return self._reversed
end

---
--- Returns whether or not the current animation is finished.
---
function AnimationController:isFinished()
    return self._finished
end

---
--- Resets this animation player and
--- destroys & removes all previously added animations.
---
function AnimationController:reset()
    self._animations = {}
    self._curAnim = nil
    self._onComplete = nil
    self._reversed = false
    self._finished = false
end

---
--- Updates the currently playing animation.
---
--- This shouldn't be called explicitly as it is already
--- called automatically by the engine.
---
--- @param delta number  The time between the last and current frame.
---
function AnimationController:update(delta)
    if self._finished or self._curAnim == nil then
        return
    end

    self._elapsedTime = self._elapsedTime + delta

    if self._elapsedTime < (1 / self._curAnim.fps) then
        return
    end
    self._elapsedTime = 0

    if self._curAnim.curFrame < self._curAnim.frameCount then
        self._curAnim.curFrame = self._curAnim.curFrame + 1
        self._parent:setFrame(self._curAnim.frames[self._curAnim.curFrame])
        return
    end

    if self._curAnim.loop then
        self._curAnim.curFrame = 1
        self._parent:setFrame(self._curAnim.frames[self._curAnim.curFrame])
    else
        self._finished = true
        if self._onComplete then
            self._onComplete(self.name)
        end
    end
end

---
--- Adds a new animation to the sprite.
---
--- @param name   string    What this animation should be called (e.g. `"run"`).
--- @param frames table     An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`).
--- @param fps    number    The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop   boolean?  Whether or not the animation is looped or just plays once.
---
function AnimationController:add(name, frames, fps, loop)
    local atlas = self._parent:getFrames()
    if atlas == nil then
        return
    end
    local datas = {}
    for _, num in pairs(frames) do
        table.insert(datas, atlas.frames[num])
    end
    local anim = AnimationData:new(name, datas, fps, loop and loop or true)
    self._animations[name] = anim
end

---
--- Adds a new animation to the sprite.
---
--- @param name   string    What this animation should be called (e.g. `"run"`).
--- @param prefix string    Common beginning of image names in atlas (e.g. `"tiles-"`).
--- @param fps    number    The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop   boolean?  Whether or not the animation is looped or just plays once.
---
function AnimationController:addByPrefix(name, prefix, fps, loop)
    local atlas = self._parent:getFrames()
    if atlas == nil then
        return
    end
    local __frames = {}
    for _, data in ipairs(atlas:getFrames()) do
        if string.startsWith(data.name, prefix) then
            table.insert(__frames, data)
        end
    end
    if #__frames == 0 then
        print("Failed to add animation called " .. name .. " since no frames were found")
        return
    end
    local anim = AnimationData:new(name, __frames, fps, loop and loop or true)
    self._animations[name] = anim
end

---
--- Adds a new animation to the sprite.
---
--- @param name    string   What this animation should be called (e.g. `"run"`).
--- @param prefix  string   Common beginning of image names in atlas (e.g. `"tiles-"`).
--- @param indices table    An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`)
--- @param fps     number   The speed in frames per second that the animation should play at (e.g. `30` fps).
--- @param loop    boolean  Whether or not the animation is looped or just plays once.
---
function AnimationController:addByIndices(name, prefix, indices, fps, loop)
    local atlas = self._parent:getFrames()
    if atlas == nil then
        return
    end
    local __frames = {}
    for _, data in ipairs(atlas.frames) do
        if string.startsWith(data.name, prefix) then
            table.insert(__frames, data)
        end
    end
    if #__frames == 0 then
        print("Failed to add animation called " .. name .. " since no frames were found")
        return
    end
    local datas = {}
    for _, num in ipairs(indices) do
        table.insert(datas, __frames[num])
    end
    local anim = AnimationData:new(name, datas, fps, loop and loop or true)
    self._animations[name] = anim
end

---
--- Returns whether or not any specified animation exists.
---
--- @param name string  The name of the animation to check.
---
function AnimationController:exists(name)
    return self._animations[name] ~= nil
end

---
--- Returns the data of any specified animation.
---
--- @param name string  The name of the animation to get the data of.
---
function AnimationController:getByName(name)
    return self._animations[name]
end

---
--- Removes any specified animation.
---
--- @param name string  The name of the animation to remove.
---
function AnimationController:remove(name)
    local anim = self._animations[name]
    if anim == nil then
        return
    end
    table.remove(self._animations, table.indexOf(anim))
    anim:destroy()
end

---
--- Plays any specified animation if it exists.
---
--- Returns a boolean of `true` on success, and `false` on failure,
--- And a string containing the error if this fails.
---
--- @param  name     string    The name of the animation to play.
--- @param  force    boolean?  Whether or not to forcefully restart the animation.
--- @param  reversed boolean?  Whether or not to play the animation in reverse.
--- @param  frame    integer?  The starting frame to play of the animation.
---
--- @return boolean
---
function AnimationController:play(name, force, reversed, frame)
    if not self:exists(name) then
        print("Animation called "..name.." doesn't exist!")
        return false
    end
    if self:getCurrentAnimationName() == name and not self._finished and not (force and force or false) then
        return true
    end
    self._reversed = reversed and reversed or false
    self._finished = false
    self._elapsedTime = 0

    self._curAnim = self._animations[name]
    self._curAnim.curFrame = frame and frame or 1
    
    if self._parent == nil or self._curAnim == nil or self._curAnim.frames == nil or self._curAnim.frames[1] == nil then
        return false
    end
    self._parent:setFrame(self._curAnim.frames[self._curAnim.curFrame])
    return true
end

---
--- Set an offset for a specified animation.
---
--- Useful for spritesheets generated with software that have
--- wonky offsets for spritesheets.
---
--- @param name string  The name of the animation to offset.
--- @param x    number  The X offset to set on the animation.
--- @param y    number  The Y offset to set on the animation.
---
function AnimationController:setOffset(name, x, y)
    local anim = self._animations[name]
    if anim == nil then
        return
    end
    anim.offset:set(x, y)
end

---
--- The total number of frames in the parent
--- sprite's texture.
--- 
--- @return integer
---
function AnimationController:getNumFrames()
    if self._parent then
        return self._parent:getNumFrames()
    end
    return 0.0
end

-----------------------
--- [ Private API ] ---
-----------------------

return AnimationController