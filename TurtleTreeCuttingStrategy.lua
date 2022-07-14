require("Class")
require("TurtleTaskModule")
require("TurtleStrategy")
 
---@class TurtleTreeCuttingStrategy : TurtleStrategy
TurtleTreeCuttingStrategy = Class(TurtleStrategy)
TurtleTreeCuttingStrategy.myStates = {
    PLANTING = {},
    CUTTING = {},
    WAITING = {},
    UNLOADING = {},
    IDLE = {}
}
TurtleTreeCuttingStrategy.WAIT_TIME = 60
function TurtleTreeCuttingStrategy:init()
    self:initStates(TurtleTreeCuttingStrategy.myStates)
    self.turtleTask = TurtleTaskModule()
    self.state = self.states.IDLE
    self.waitingIx = 0
    self.active = true
    if self:handleStart() then 
        while self.active do 
            self:update()
        end
    end
end

function TurtleTreeCuttingStrategy:update()
    if self.state == self.states.WAITING then 
        self:handleWaiting()
    elseif self.state == self.states.PLANTING then 
        if not self:handlePlating() then 
            self:debug("Error: no more saplings.")
        end
    elseif self.state == self.states.CUTTING then
        self:handleCutting()
    else
        if not self:handleUnloading() then 
            self:debug("Error: no more free space in the chest.")
        end
    end    
end
  

function TurtleTreeCuttingStrategy:handleStart()
    local hasBlock

    local hasBlock,itemDetails = turtle.inspect()
    if hasBlock then 
        if self then 
            self:changeState(self.states.CUTTING)
        elseif self:isSapling(itemDetails) then 
            self:changeState(self.states.WAITING)
        else 
            self:debug("Error: invalid block in front.")
            return false
        end
    else 
        self:changeState(self.states.PLANTING)
    end
    self:rotate180()
    if not self:placeChest() then 
        self:rotate180()
        self:debug("Error: no chest in inventory.")
        return false 
    end
    self:rotate180()
    return true
end
 
function TurtleTreeCuttingStrategy:handleCutting()
    self:moveForward()
    local ix = 0
    while true do 
        ix = ix + 1
        self:moveUp()
        local hasBlock,itemDetails = turtle.inspectUp()
        if not self:isLog(itemDetails) then
            break
        end
    end
    for i=1,ix do 
        self:moveDown()
    end
    self:moveBack()
    self:changeState(self.states.UNLOADING)
end
 
---@param itemDetails table
function TurtleTreeCuttingStrategy:isLog(itemDetails)
    return itemDetails and itemDetails.tags and itemDetails.tags[ItemTags.logs]
end
 
---@param itemDetails table
function TurtleTreeCuttingStrategy:isSapling(itemDetails)
    return itemDetails and itemDetails.tags and itemDetails.tags[ItemTags.saplings]
end
 
function TurtleTreeCuttingStrategy:handlePlating()
    if self:selectItemSlotByTag(ItemTags.saplings) then 
        self:place()
        self:changeState(self.states.WAITING)
    else 
        return false
    end
    return true
end
 
function TurtleTreeCuttingStrategy:handleUnloading()
    local itemsDropped = false
    self:rotate180()
    itemsDropped = self:dropItemByTag(ItemTags.logs)
    self:rotate180()
    self:changeState(self.states.PLANTING)
    return itemsDropped
end
 
function TurtleTreeCuttingStrategy:handleWaiting()
    local hasBlock,itemDetails = turtle.inspect()
    if not hasBlock then 
        self:changeState(self.states.PLANTING)
        self.waitingIx = 0
    else 
        if self:isLog(itemDetails) then 
            self:changeState(self.states.CUTTING)
            self.waitingIx = 0
        else 
            sleep(self.WAIT_TIME)
            self.waitingIx = self.waitingIx + 1
            self:debug("Waiting iteration: %d",self.waitingIx)
        end
    end
end
TurtleTreeCuttingStrategy()