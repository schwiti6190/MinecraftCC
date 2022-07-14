require("Class")

---@class TurtleTaskModule
TurtleTaskModule = Class()
TurtleTaskModule.FORWARD_DELAY = 0.1
function TurtleTaskModule:init()
	
end

function TurtleTaskModule:delete()

end

function TurtleTaskModule:rotate180()
	turtle.turnLeft()
	turtle.turnLeft()
end

function TurtleTaskModule:digUp()
	while turtle.detectUp() do 
        turtle.digUp()
		sleep(TurtleTaskModule.FORWARD_DELAY)
    end
end

function TurtleTaskModule:moveForward(itemToPlaceDown)
	while not turtle.forward() do 
        turtle.dig()
		sleep(TurtleTaskModule.FORWARD_DELAY)
    end
	if itemToPlaceDown then 
		self:placeDown(itemToPlaceDown)
	end
end

function TurtleTaskModule:moveBackward(...)
	self:rotate180()
	self:moveForward(...)
	self:rotate180()
end

function TurtleTaskModule:moveLeft(...)
	turtle.turnLeft()
	self:moveForward(...)
	turtle.turnRight()
end

function TurtleTaskModule:moveRight(...)
	turtle.turnRight()
	self:moveForward(...)
	turtle.turnLeft()
end

function TurtleTaskModule:moveUp()
	self:digUp()
end

function TurtleTaskModule:moveDown(itemToPlaceDown)
	while not turtle.down() do 
        turtle.digDown()
		sleep(TurtleTaskModule.FORWARD_DELAY)
    end
	if itemToPlaceDown then 
		self:placeDown(itemToPlaceDown)
	end
end

function TurtleTaskModule:selectItemSlot(itemName)
	local ix = 0
    for i=1,16 do 
        local detail = turtle.getItemDetail(i)
        if detail and detail.name == itemName then 
            ix = i 
            break
        end
    end
    if ix>0 then 
        turtle.select(ix)
        return true
    end
    self:error("No item with name %s found.", itemName)
    return false	
end

function TurtleTaskModule:place(item, placeFunc)
	if self:selectItemSlot(item) then 
		placeFunc()
	end
end

function TurtleTaskModule:placeForward(item, isDiggingAllowed)
	if isDiggingAllowed then
		turtle.dig()
	end
	self:place(item, turtle.place)
end

function TurtleTaskModule:placeBackward(item, isDiggingAllowed)
	self:rotate180()
	self:placeForward(item, isDiggingAllowed)
	self:rotate180()
end

function TurtleTaskModule:placeLeft(item, isDiggingAllowed)
	turtle.turnLeft()
	self:placeForward(item, isDiggingAllowed)
	turtle.turnRight()
end

function TurtleTaskModule:placeRight(item, isDiggingAllowed)
	turtle.turnRight()
	self:placeForward(item, isDiggingAllowed)
	turtle.turnLeft()
end

function TurtleTaskModule:placeDown(item, isDiggingAllowed)
	if isDiggingAllowed then
		turtle.digDown()
	end
	self:place(item, turtle.placeDown)
end

function TurtleTaskModule:placeUp(item, isDiggingAllowed)
	if isDiggingAllowed then
		turtle.digUp()
	end
	self:place(item, turtle.placeUp)
end

function TurtleTaskModule:drop(dropFunc, itemsToIgnore, allowedItems, numLeftover)
	local numItems = self:getAllNumberOfItems()
	for i=1,16 do 
		local detail = turtle.getItemDetail(i)
		if allowedItems == nil or allowedItems[detail.name] then 
			if itemsToIgnore == nil or not itemsToIgnore[detail.name] then 
				turtle.select(i)
				if numLeftover then 
					local diff = numItems[detail.name] - numLeftover
					if diff > 0 then 
						dropFunc(diff)
					end
				else
					dropFunc()
				end
			end
		end
	end
end

function TurtleTaskModule:dropForward(...)
	self:drop(turtle.drop, ...)
end

function TurtleTaskModule:dropBackward(...)
	self:rotate180()
	self:drop(turtle.drop, ...)
	self:rotate180()
end

function TurtleTaskModule:dropLeft(...)
	turtle.turnLeft()
	self:drop(turtle.drop, ...)
	turtle.turnRight()
end

function TurtleTaskModule:dropRight(...)
	turtle.turnRight()
	self:drop(turtle.drop, ...)
	turtle.turnLeft()
end

function TurtleTaskModule:dropDown(...)
	self:drop(turtle.dropDown, ...)
end

function TurtleTaskModule:dropUp(...)
	self:drop(turtle.dropUp, ...)
end

function TurtleTaskModule:needsRefuel(threshold)
	threshold = threshold or 0
	return turtle.getFuelLevel() <= threshold
end

function TurtleTaskModule:refuelAll()
	for i=1, 16 do 
		turtle.select(i)
		turtle.refuel()
	end
end


function TurtleTaskModule:isFull()
	for i = 1, 16 do 
		if turtle.getItemCount(i) <= 0 then 
			return false
		end
	end
	return true
end

function TurtleTaskModule:getNumberOfItems(itemName)
	local num = 0
	for i=1, 16 do 
		local detail = turtle.getItemDetail(i)
		if detail and detail.name == itemName then 
			num = num + turtle.getItemCount(i)
		end
	end
	return num
end

function TurtleTaskModule:getAllNumberOfItems()
	local numItems = {}
	for i=1, 16 do 
		local detail = turtle.getItemDetail(i)
		if detail then 
			if numItems[detail.name] == nil then 
				numItems[detail.name] = 0
			end
			numItems[detail.name] = numItems[detail.name] + turtle.getItemCount(i)
		end
	end	
	return numItems
end

function TurtleTaskModule:inspect(inspectFunc, itemName, itemTag)
	local hasBlock, itemDetails = inspectFunc()
	if hasBlock then 
		if itemName ~= nil and itemDetails.name then 
			return itemDetails.name == itemName, itemDetails
		elseif itemTag ~=nil and itemDetails and itemDetails.tags then 
			return itemDetails.itemDetails.tags and itemDetails.tags[itemTag], itemDetails
		end
		return false, itemDetails
	end
	return false, false
end

function TurtleTaskModule:inspectForward(...)
	return self:inspect(turtle.inspect, ...)
end

function TurtleTaskModule:inspectBackward(...)
	self:rotate180()
	local found, foundBlock = self:inspect(turtle.inspect, ...)
	self:rotate180()
	return found, foundBlock
end

function TurtleTaskModule:inspectLeft(...)
	turtle.turnLeft()
	local found, foundBlock = self:inspect(turtle.inspect, ...)
	turtle.turnRight()
	return found, foundBlock
end

function TurtleTaskModule:inspectRight(...)
	turtle.turnRight()
	local found, foundBlock = self:inspect(turtle.inspect, ...)
	turtle.turnLeft()
	return found, foundBlock
end

function TurtleTaskModule:inspectUp(...)
	return self:inspect(turtle.inspectUp, ...)
end

function TurtleTaskModule:inspectDown(...)
	return self:inspect(turtle.inspectDown, ...)
end

function TurtleTaskModule:error(...)
    error(string.format(...))
end
 
function TurtleTaskModule:debug(...)
    print(string.format(...))
end