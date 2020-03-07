love.graphics.setDefaultFilter("nearest")
plants = require ('scripts.plant')
util = require('scripts.util')

function love.load()
	player = {
		x = 160,          		-- initial position (must be =)
		y = 140,    			-- initial position (must be =)
		scale = 0.40,         	-- size (compared to original image)
		static_x = 160,       	-- initial position (must be =)
		static_y = 140,    		-- initial position (must be =)
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 3,       		-- pixels of movement by frame
		tileSize = 80,   		-- pixels size for each tile (PlantSize)
		state = 'still', 		-- at the beginning the character is still
		map_x = 1,				-- coordinates of the first room (in the bigger map)
		map_y = 1
	}

	-- ROOM/DOOR DYNAMIC (just for testing purpose)
	-- door location
	door_cell = {0,1}
	-- initialize the new_room as 0
	new_room=0


	plantSize = 80
	plantStartX = 160
	plantStartY = 140
	plantScale = 2.5

	selected = ""

	xScale = love.graphics.getWidth() / 1600
	yScale =love.graphics.getHeight() / 900

	inventorySquare = love.graphics.newImage("graphics/square (1).png")

	inventoryScale = 3
	inventoryHeight = inventorySquare:getHeight() * inventoryScale
	inventoryWidth = inventorySquare:getWidth() * inventoryScale

	loadMap()
	aTileMatrix = currentRoom.layout
	for i = 1, #aTileMatrix do
		for j = 1, #aTileMatrix[i] do
			print(aTileMatrix[i][j].id)
		end
	end
end



function loadMap()

	local rooms = util.readJSON('roomData/rooms.json', true)
	local testRoom = rooms[1]
	local testLayout = testRoom.layout

	currentRoom = {}
	local layout =  {}
	for i = 1, #testLayout do
		local layoutRow = {}
		for j = 1, #testLayout[i] do
			local addPlant = plants[testLayout[i][j]]:new()
			addPlant:onLoad()
			layoutRow[#layoutRow+1] = addPlant
		end
		layout[#layout+1] = layoutRow
	end

	currentRoom.layout = layout
end



function love.update(dt)

	-- MOVEMENT

	-- check what cell we currently are in
	-- cells go from (1,1) to (9,16)
	cell = {1+(player.static_y-plantStartY)/plantSize,
		1+(player.static_x-plantStartX)/plantSize}

	-- before moving, check that you can actually pass the object in the cell :)
	-- step 1 - initialize every direction as "not allowed"
	up_allowed=0
	down_allowed=0
	left_allowed=0
	right_allowed=0

	-- step 2 - check if the neighbour cells are "passable"
	if love.keyboard.isDown("up") and cell[1] > 1 then
		local obj = aTileMatrix[cell[1]-1][cell[2]]
		if obj.passable then
			up_allowed = 1
		end
	elseif love.keyboard.isDown("down") and cell[1] < 9 then
		local obj = aTileMatrix[cell[1]+1][cell[2]]
		if obj.passable then
			down_allowed = 1
		end
	elseif love.keyboard.isDown("left") and cell[2] > 1 then
		local obj = aTileMatrix[cell[1]][cell[2]-1]
		if obj.passable then
			left_allowed = 1
		end
	elseif love.keyboard.isDown("right") and cell[2] < 16 then
		local obj = aTileMatrix[cell[1]][cell[2]+1]
		if obj.passable then
			right_allowed = 1
		end
	end


	-- step 3 - declare if the player is still or moving
	player.state = 'still'
	if player.x ~= player.static_x or player.y ~= player.static_y then
		player.state = 'moving'
	end 

	-- step 4 - update player position (smooth movement)
	-- default: 100 x dt (seconds between frames)
	frame_speed = player.speed*dt*100
	-- move left
	if player.x>player.static_x then
		if player.x-player.static_x>=frame_speed then
			player.x = player.x - frame_speed
		else
			player.x = player.static_x
		end
	end
	-- move right
	if player.x<player.static_x then
		if player.static_x-player.x>=frame_speed then
			player.x = player.x + frame_speed
		else
			player.x = player.static_x
		end
	end
	-- move up
	if player.y>player.static_y then
		if player.y-player.static_y>=frame_speed then
			player.y = player.y - frame_speed
		else
			player.y = player.static_y
		end
	end
	-- move down
	if player.y<player.static_y then
		if player.static_y-player.y>=frame_speed then
			player.y = player.y + frame_speed
		else
			player.y = player.static_y
		end
	end

	-- step 5 - read the keyboard for new movement
	if player.state == 'still' then
		-- We restrict the player to stay within the bounds of the playable board
		-- PRESS A KEY TO MOVE TO THE NEXT LOCATION
		if love.keyboard.isDown("up") and up_allowed==1 then
			if ((player.static_y - plantSize) >= (plantStartY)) then
				player.static_y = player.static_y - plantSize
			end
	    --end
		elseif love.keyboard.isDown("down") and down_allowed==1 then
			if (player.static_y + plantSize) < (plantStartY + plantSize * 9) then
				player.static_y = player.static_y + plantSize
			end
	    --end
		elseif love.keyboard.isDown("left") and left_allowed==1 then
			if (player.static_x - plantSize) >= (plantStartX) then
				player.static_x = player.static_x - plantSize
			end
		--end
		elseif love.keyboard.isDown("right") and right_allowed==1 then
			if (player.static_x + plantSize) < (plantStartX + plantSize * 16) then
				player.static_x = player.static_x + plantSize
			end
	    end
	end

	-- step 6 - we can add here a mechanism that checks where is the door
	if player.state == 'still' then
	 	if love.keyboard.isDown("up") and cell[1] == (door_cell[1]+1) and cell[2] == door_cell[2] then
			new_room=1
		end
	 	if love.keyboard.isDown("down") and cell[1] == (door_cell[1]-1) and cell[2] == door_cell[2] then
			new_room=1
		end
	 	if love.keyboard.isDown("right") and cell[1] == door_cell[1] and (cell[2]+1) == door_cell[2] then
			new_room=1
		end
	 	if love.keyboard.isDown("left") and cell[1] == door_cell[1] and (cell[2]-1) == door_cell[2] then
			new_room=1
		end
	end


end




function love.draw()
	love.graphics.scale(xScale, yScale)

	for row = 1, #aTileMatrix do
		for col = 1, #aTileMatrix[row] do
			plantObject = aTileMatrix[row][col]
			plantImage = plantObject:getImage()
			plantXScale = plantSize / plantImage:getWidth()
			plantYScale = plantSize / plantImage:getHeight()
			local startX = plantSize * (col-1) + plantStartX
			local startY = plantSize * (row-1) + plantStartY
			love.graphics.draw(plantImage, startX, startY, 0,
					plantXScale, plantYScale, 0)
		end
	end

	if new_room==0 then
		for col = 0, 9 do
			love.graphics.draw(inventorySquare, (inventoryWidth * col), 0, 0,
			inventoryWidth/inventorySquare:getWidth(), inventoryHeight/inventorySquare:getHeight() , 0)	
		end
	end

	wateringcan = love.graphics.newImage("graphics/wateringcan.png")
	local wateringcanScale = 1.5
	local wateringcanHeight = wateringcan:getHeight() * wateringcanScale
	local wateringcanWidth = wateringcan:getWidth() * wateringcanScale
	love.graphics.draw(wateringcan, 0 , 0, 0, 
	wateringcanWidth/wateringcan:getWidth(), wateringcanHeight/wateringcan:getHeight(), 0)

	love.graphics.draw(player.sprite, player.x, player.y, 0, player.scale, player.scale, 0, 32)
end





function love.mousepressed(x, y, button, istouch)
	x = x / xScale 
	y = y / yScale

	local tileY = 0
	local tileX = 0

	local plantX = x - plantStartX
	local plantY = y - plantStartY
	print("pressed: "..x.." "..y.." "..xScale.." "..yScale)

	tileY = math.ceil( plantY / plantSize )
	tileX = math.ceil( plantX / plantSize )
	print(tileX .. " " .. tileY)

	if tileY >= 1 and tileY <= 9 and tileX >= 1 and tileX <= 16 then
		aTileMatrix[tileY][tileX]:onClick()
	end

	if x <= inventoryWidth and y <= inventoryHeight then
		selected = "water"
		local cursor = love.mouse.newCursor("graphics/watering-can-pixilart.png", 0, 0)
		love.mouse.setCursor(cursor)
	end

end



