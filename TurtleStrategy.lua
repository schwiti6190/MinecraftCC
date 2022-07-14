
require("Class")

ItemNames = {
    torch = "minecraft:torch",
    cobble = "minecraft:cobblestone",
    chest = "minecraft:chest",
    lavaBucket = "lava_bucket",
    lava = "lava"
}
 
ItemTags = {
    logs = "minecraft:logs",
    saplings = "minecraft:saplings"
}


---@class TurtleStrategy
TurtleStrategy = Class()

function TurtleStrategy:init()
	
end

---@param states table
function TurtleStrategy:initStates(states)
    if self.states == nil then self.states = {} end
    for key,state in pairs(states) do 
        self.states[key] = {name = tostring(key), properties = state}
    end
end

---@param newState table
function TurtleStrategy:changeState(newState)
    self:debug("Last state = %s, new state = %s", self.state.name, newState.name)
    self.state = newState
end

function TurtleStrategy:delete()

end

function TurtleStrategy:error(...)
    error(string.format(...))
end
 
function TurtleStrategy:debug(...)
    print(string.format(...))
end