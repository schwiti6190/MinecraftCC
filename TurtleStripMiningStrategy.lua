require("Class")
require("TurtleStrategy")
require("TurtleTaskModule")

TurtleStripMiningStrategy = Class(TurtleStrategy)
TurtleStripMiningStrategy.myStates = {
	LANE = {},
	TURN_LEFT = {},
	TURN_RIGHT = {},
	PLACE_TORCH = {},
	PLACE_CHEST = {}
}
TurtleStripMiningStrategy.TORCH_DISTANCE = 12
TurtleStripMiningStrategy.MIN_FUEL_LEVEL = 50

TurtleStripMiningStrategy.DROP_ITEMS_IGNORED = {
	[ItemNames.chest] = true,
	[ItemNames.torch] = true,
	[ItemNames.cobble] = true,
}
function TurtleStripMiningStrategy:init(laneLength, laneGap, numLanes)
	TurtleStrategy.init(self)
	self:initStates(TurtleStripMiningStrategy.myStates)
	self.state = self.states.LANE
	self.turnState = self.states.TURN_LEFT
	self.laneLength = laneLength
	self.laneGap = laneGap
	self.turtleTask = TurtleTaskModule()
	self.torchCounter = 1
	self.laneCounter = 0
	while self.laneCounter < numLanes do
		self:update()
	end
end

function TurtleStripMiningStrategy:update()
	if self.state == self.states.LANE then 
		self:createLane()
	elseif self.state == self.states.TURN_LEFT then 
		self:createLeftTurn()
	elseif self.state == self.states.TURN_RIGHT then 
		self:createRightTurn()
	end
end

function TurtleStripMiningStrategy:moveForward()
	if self.turtleTask:needsRefuel(self.MIN_FUEL_LEVEL) then 
		self.turtleTask:refuelAll()
	end
	self.turtleTask:digUp()
	self.turtleTask:moveForward(ItemNames.cobble)
	self.turtleTask:placeLeft(ItemNames.cobble)
	self.turtleTask:placeRight(ItemNames.cobble)
	if self.turtleTask:isFull() then 
		self:placeChestBelow()
		self.torchCounter = self.TORCH_DISTANCE
	end
	if self.torchCounter >= self.TORCH_DISTANCE then 
		self:placeTorchBehind()
		self.torchCounter = 0
	end
	self.torchCounter = self.torchCounter + 1
end

function TurtleStripMiningStrategy:createLane()
	for i=1, self.laneLength do 
		self:moveForward()
	end
	self.laneCounter = self.laneCounter + 1
	if self.turnState == self.states.TURN_LEFT then 
		self:changeState(self.states.TURN_LEFT)
		self:changeTurnState(self.states.TURN_RIGHT)
	else 
		self:changeState(self.states.TURN_RIGHT)
		self:changeTurnState(self.states.TURN_LEFT)
	end
end

function TurtleStripMiningStrategy:createLeftTurn()
	turtle.turnLeft()
	for i=1, self.laneGap do 
		self:moveForward()
	end
	turtle.turnLeft()
	self:changeState(self.states.LANE)
end

function TurtleStripMiningStrategy:createRightTurn()
	turtle.turnRight()
	for i=1, self.laneGap do 
		self:moveForward()
	end
	turtle.turnRight()
	self:changeState(self.states.LANE)
end

function TurtleStripMiningStrategy:placeTorchBehind()
	self.turtleTask.placeBackward(ItemNames.torch)
end

function TurtleStripMiningStrategy:placeChestBelow()
	self.turtleTask.placeDown(ItemNames.chest)
	self.turtleTask:dropDown(self.DROP_ITEMS_IGNORED)
	self.turtleTask:dropDown(nil, {[ItemNames.cobble] = true}, 64)
end

---@param newState table
function TurtleStripMiningStrategy:changeTurnState(newState)
    self:debug("Last turn state = %s, new turn state = %s", self.state.name, newState.name)
    self.turnState = newState
end

local function setup()
	local laneLength, laneGap, numLanes
	while true do
		print("Number of lanes: ")
		local numLanes = tonumber(read())
		print("Lane length: ")	
		local laneLength = tonumber(read())
		print("Lane gap: ")
		local laneGap = tonumber(read())
		if laneLength ~= nil or laneGap ~= nil or numLanes ~= nil then 
			break
		end
		print("You failed!")
	end
	TurtleStripMiningStrategy(laneLength, laneGap, numLanes)
end

setup()