local AnimationData = qrequire("chip.animation.AnimationData") --- @type chip.animation.AnimationData

---
--- @class chip.animation.AnimationController
---
local AnimationController = Class:extend("AnimationController", ...)

function AnimationController:constructor(parent)
    ---
    --- The attached sprite that utilizes this
    --- animation player.
    --- 
    --- @type chip.graphics.Sprite
    ---
    self.parent = parent
    
    ---
    --- The list of added animations.
    ---
    self.animations = {}

    ---
    --- The total number of frames in the parent
    --- sprite's texture.
    --- 
    --- @type integer
    ---
    self.numFrames = nil
    
    ---
    --- The name of the currently playing animation.
    ---
    --- ⚠️ **WARNING**: This can be `nil`!
    --- 
    --- @type string?
    ---
    self.name = nil
    
    ---
    --- The data of the currently playing animation.
    ---
    --- ⚠️ **WARNING**: This can be `nil`!
    --- 
    --- @type chip.animation.AnimationData
    ---
    self.curAnim = nil
    
    ---
    --- The function that gets ran when
    --- the current animation has finished playing.
    --- 
    --- @type function?
    ---
    self.onComplete = nil
    
    ---
    --- Whether or not the currently playing
    --- animation is reversed.
    ---
    self.reversed = false
    
    ---
    --- Whether or not the currently playing
    --- animation is finished.
    ---
    self.finished = false

    ---
    --- @protected
    --- @type number
    ---
    self._elapsedTime = 0.0
end

---
--- Resets this animation player and
--- destroys & removes all previously added animations.
---
function AnimationController:reset()
    self.animations = {}
    self.curAnim = nil
    self.onComplete = nil
    self.reversed = false
    self.finished = false
    self.name = nil
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
    if self.finished or self.curAnim == nil then
        return
    end

    self._elapsedTime = self._elapsedTime + delta

    if self._elapsedTime < (1 / self.curAnim.fps) then
        return
    end
    self._elapsedTime = 0

    if self.curAnim.curFrame < self.curAnim.frameCount then
        self.curAnim.curFrame = self.curAnim.curFrame + 1
        self.parent.frame = self.curAnim.frames[self.curAnim.curFrame]
        return
    end

    if self.curAnim.loop then
        self.curAnim.curFrame = 1
        self.parent.frame = self.curAnim.frames[self.curAnim.curFrame]
    else
        self.finished = true
        if self.onComplete then
            self.onComplete(self.name)
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
    local atlas = self.parent.frames
    if atlas == nil then
        return
    end
    local datas = {}
    for _, num in pairs(frames) do
        table.insert(datas, atlas.frames[num])
    end
    local anim = AnimationData:new(name, datas, fps, loop and loop or true)
    self.animations[name] = anim
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
    local atlas = self.parent.frames
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
    local anim = AnimationData:new(name, __frames, fps, loop and loop or true)
    self.animations[name] = anim
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
    local atlas = self.parent.frames
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
    self.animations[name] = anim
end

---
--- Returns whether or not any specified animation exists.
---
--- @param name string  The name of the animation to check.
---
function AnimationController:exists(name)
    return self.animations[name] ~= nil
end

---
--- Returns the data of any specified animation.
---
--- @param name string  The name of the animation to get the data of.
---
function AnimationController:getByName(name)
    return self.animations[name]
end

---
--- Removes any specified animation.
---
--- @param name string  The name of the animation to remove.
---
function AnimationController:remove(name)
    local anim = self.animations[name]
    if anim == nil then
        return
    end
    table.remove(self.animations, table.indexOf(anim))
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
    if self.name == name and not self.finished and not (force and force or false) then
        return true
    end

    self.name = name
    self.reversed = reversed and reversed or false
    self.finished = false
    self._elapsedTime = 0

    self.curAnim = self.animations[name]
    self.curAnim.curFrame = frame and frame or 1
    
    if self.parent == nil or self.curAnim == nil or self.curAnim.frames == nil or self.curAnim.frames[1] == nil then
        return false
    end
    self.parent.frame = self.curAnim.frames[self.curAnim.curFrame]
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
    local anim = self.animations[name]
    if anim == nil then
        return
    end
    anim.offset:set(x, y)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
---
function AnimationController:get_numFrames()
    if self.parent then
        return self.parent.numFrames
    end
    return 0.0
end

return AnimationController