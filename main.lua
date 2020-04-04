love.graphics.setDefaultFilter("nearest")
game_objects = require ('scripts.game_object')
plants = require ('scripts.plant')
util = require('scripts.util')

function love.load()
	player = {
		x = 160,          		-- initial position (must be =)
		y = 140,    			-- initial position (must be =)
		scale = 2,         	    -- size (compared to original image)
		static_x = 160,       	-- initial position (must be =)
		static_y = 140,    		-- initial position (must be =)
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 3,       		-- pixels of movement by frame
		tileSize = 80,   		-- pixels size for each tile (PlantSize)
		state = 'still', 		-- at the beginning the character is still
		map_x = 1,				-- coordinates of the first room (in the bigger map)
		map_y = 1,
		seeds = {},
		water = 0,
		stop_time = 0,          -- how many frames of stop after a new room is entered
	}

	-- ROOM/DOOR DYNAMIC (just for testing purpose)
	-- door location
	door1_cell = {0,1}
	door2_cell = {0,1}
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

	hp_bar = hp_bar:new()
	full_heart = love.graphics.newImage("graphics/heart_full.png")
	empty_heart = love.graphics.newImage("graphics/heart_empty.png")

	cornerWall1 = love.graphics.newImage("graphics/walls/corner1.png")
	cornerWall2 = love.graphics.newImage("graphics/walls/corner2.png")
	cornerWall3 = love.graphics.newImage("graphics/walls/corner3.png")
	cornerWall4 = love.graphics.newImage("graphics/walls/corner4.png")
	topWall = love.graphics.newImage("graphics/walls/top.png")
	bottomWall = love.graphics.newImage("graphics/walls/bottom.png")
	leftWall = love.graphics.newImage("graphics/walls/left.png")
	rightWall = love.graphics.newImage("graphics/walls/right.png")
	doorTop = love.graphics.newImage("graphics/walls/doortop.png")
	doorBottom = love.graphics.newImage("graphics/walls/doorbottom.png")
	doorLeft = love.graphics.newImage("graphics/walls/doorleft.png")
	doorRight = love.graphics.newImage("graphics/walls/doorright.png")

	prev_cells = {{}, {}}
	loadRooms()
	loadMap()
	tileMatrix = currentRoom.layout

	love.mouse.setVisible(false)
	cursorImage = love.graphics.newImage("graphics/mouse.png")
end

function loadRooms()
	local read = util.readJSON('roomData/rooms.json', true)
	rooms = {}
	for i = 1, #read do
		rooms[#rooms + 1] = read[i]
		rooms[read[i].name] = read[i]
	end
end



function loadMap()
	local read = util.readJSON('maps/map1.json', true)
	local mapLayout = read[1].layout

	map = {}

	for i = 1, #mapLayout do
		local mapRow = {}
		for j = 1, #mapLayout[i] do
			currentRoom = {}
			local layout =  {}
			local testLayout = rooms[mapLayout[i][j]].layout
			for i2 = 1, #testLayout do
				local layoutRow = {}
				for j2 = 1, #testLayout[i] do
					local addPlant = plants[testLayout[i2][j2]]:new()
					addPlant:onLoad()
					layoutRow[#layoutRow+1] = addPlant
				end
				layout[#layout+1] = layoutRow
			end

			currentRoom.layout = layout
			currentRoom.seedCounts = rooms[mapLayout[i][j]].seedCounts
			currentRoom.seeds = rooms[mapLayout[i][j]].seeds

			currentRoom.door1X = rooms[mapLayout[i][j]].door1X
			currentRoom.door1Y = rooms[mapLayout[i][j]].door1Y
			currentRoom.door1Direction = rooms[mapLayout[i][j]].door1Direction
			currentRoom.door2X = rooms[mapLayout[i][j]].door2X
			currentRoom.door2Y = rooms[mapLayout[i][j]].door2Y
			currentRoom.door2Direction = rooms[mapLayout[i][j]].door2Direction

			currentRoom.water = rooms[mapLayout[i][j]].water

			mapRow[#mapRow + 1] = currentRoom
		end
		map[#map+1] = mapRow
	end

	goToRoom(1, 1)
end



function love.update(dt)

	-- MOVEMENT

	-- check what cell we currently are in
	-- cells go from (1,1) to (9,16)
	cell = {1+(player.static_y-plantStartY)/plantSize,
		1+(player.static_x-plantStartX)/plantSize}

	if prev_cells[2] == {} then
		prev_cells[2][1] = cell[1]
		prev_cells[2][2] = cell[2]
	end

	-- check if we changed cells
	if cell[1] ~= prev_cells[2][1] or cell[2] ~= prev_cells[2][2] then
		-- trigger onEnter()
		tileMatrix[cell[1]][cell[2]]:onEnter()
		-- update curr and prev cell
		prev_cells[1][1] = prev_cells[2][1]
		prev_cells[1][2] = prev_cells[2][2]
		prev_cells[2][1] = cell[1]
		prev_cells[2][2] = cell[2]
	end

	-- before moving, check that you can actually pass the object in the cell :)
	-- step 1 - initialize every direction as "not allowed"
	up_allowed=0
	down_allowed=0
	left_allowed=0
	right_allowed=0

	-- step 2 - check if the neighbour cells are "passable"
	if love.keyboard.isDown("up") and cell[1] > 1 then
		local obj = tileMatrix[cell[1]-1][cell[2]]
		if obj.passable then
			up_allowed = 1
		end
	elseif love.keyboard.isDown("down") and cell[1] < 9 then
		local obj = tileMatrix[cell[1]+1][cell[2]]
		if obj.passable then
			down_allowed = 1
		end
	elseif love.keyboard.isDown("left") and cell[2] > 1 then
		local obj = tileMatrix[cell[1]][cell[2]-1]
		if obj.passable then
			left_allowed = 1
		end
	elseif love.keyboard.isDown("right") and cell[2] < 16 then
		local obj = tileMatrix[cell[1]][cell[2]+1]
		if obj.passable then
			right_allowed = 1
		end
	end


	-- step 3 - declare if the player is still or moving
	player.state = 'still'
	if player.stop_time>0 then
		player.stop_time=player.stop_time-1   	-- if you entered a new room
		player.state = 'moving'
	else
		if player.x ~= player.static_x or player.y ~= player.static_y then
			player.state = 'moving'
		end 
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

		elseif love.keyboard.isDown("down") and down_allowed==1 then
			if (player.static_y + plantSize) < (plantStartY + plantSize * 9) then
				player.static_y = player.static_y + plantSize
			end

		elseif love.keyboard.isDown("left") and left_allowed==1 then
			if (player.static_x - plantSize) >= (plantStartX) then
				player.static_x = player.static_x - plantSize
			end
		elseif love.keyboard.isDown("right") and right_allowed==1 then
			if (player.static_x + plantSize) < (plantStartX + plantSize * 16) then
				player.static_x = player.static_x + plantSize
			end
	    end
	end

	-- step 6 - we can add here a mechanism that checks where is the door
	if player.state == 'still' then
	 	if love.keyboard.isDown("up") and ((cell[1] == (door1_cell[1]) and cell[2] == door1_cell[2] and door1_direction == "N") or (cell[1] == (door2_cell[1]) and cell[2] == door2_cell[2] and door2_direction == "N")) then
			player.map_y = player.map_y - 1
			goToRoom(player.map_y, player.map_x, "up")
			player.stop_time=50
			-- adjust y coordinates
			next_cell_y = 9
			player.static_y = plantStartY + (next_cell_y-1)*plantSize
			player.y = player.static_y+80
			hp_bar = hp_bar:new()
			-- reset lives
			hp_bar.hearts = {1,1,1,1,1}
			hp_bar.hp = 5
		end
	 	if love.keyboard.isDown("down") and ((cell[1] == (door1_cell[1]) and cell[2] == door1_cell[2] and door1_direction == "S") or (cell[1] == (door2_cell[1]) and cell[2] == door2_cell[2] and door2_direction == "S")) then
			player.map_y = player.map_y + 1
			goToRoom(player.map_y, player.map_x, "down")
			player.stop_time=50
			-- adjust y coordinates
			next_cell_y = 1
			player.static_y = plantStartY + (next_cell_y-1)*plantSize
			player.y = player.static_y-80
			-- reset lives
			hp_bar.hearts = {1,1,1,1,1}
			hp_bar.hp = 5
		end
	 	if love.keyboard.isDown("right") and ((cell[1] == door1_cell[1] and (cell[2]) == door1_cell[2] and door1_direction == "E") or (cell[1] == door2_cell[1] and (cell[2]) == door2_cell[2] and door2_direction == "E")) then
			player.map_x = player.map_x + 1
			goToRoom(player.map_y, player.map_x, "right")
			player.stop_time=50
			-- adjust x coordinates
			next_cell_x = 1
			player.static_x = plantStartX + (next_cell_x-1)*plantSize
			player.y = player.static_y+80
			-- reset lives
			hp_bar.hearts = {1,1,1,1,1}
			hp_bar.hp = 5
		end
	 	if love.keyboard.isDown("left") and ((cell[1] == door1_cell[1] and (cell[2]) == door1_cell[2] and door1_direction == "W") or (cell[1] == door2_cell[1] and (cell[2]) == door2_cell[2] and door2_direction == "W")) then
			player.map_x = player.map_x - 1
			goToRoom(player.map_y, player.map_x, "left")
			player.stop_time=50
			-- adjust x coordinates
			next_cell_x = 16
			player.static_x = plantStartX + (next_cell_x-1)*plantSize
			player.y = player.static_y-80
			-- reset lives
			hp_bar.hearts = {1,1,1,1,1}
			hp_bar.hp = 5
		end
	end


end

function goToRoom(row, col, dir)
	selected = ""

	currentRoom = map[row][col]
	aTileMatrix = currentRoom.layout
	tileMatrix = aTileMatrix
	player.seeds = currentRoom.seeds
	player.water = currentRoom.water
	for seed = 1, #player.seeds do
		local thisSeed = player.seeds[seed]
		plants[thisSeed]:onLoad()
		plants[thisSeed].seeds = currentRoom.seedCounts[seed]
	end
	door1_cell[1] = currentRoom.door1Y
	door1_cell[2] = currentRoom.door1X
	door1_direction = currentRoom.door1Direction
	door2_cell[1] = currentRoom.door2Y
	door2_cell[2] = currentRoom.door2X
	door2_direction = currentRoom.door2Direction

	-- move player to appropriate tile
	if dir == "up" then
	elseif dir == "down" then
	elseif dir == "left" then
	elseif dir == "right" then
	end
end


function love.draw()
	local mouseX, mouseY = love.mouse.getPosition()
	local mouseXScaled = mouseX / xScale
	local mouseYScaled = mouseY / yScale
	love.graphics.scale(xScale, yScale)

	-- set Background Color
	red = 98/255
    green = 168/255
    blue = 229/255
    alpha = 1/100
    love.graphics.setBackgroundColor( red, green, blue, alpha)

    -- two for-loops to draw walls around the sides
    local shouldDrawWall = true
    for col = 1, #tileMatrix[1] do
    	wallXScale = plantSize / topWall:getWidth()
		wallYScale = plantSize / topWall:getHeight()
		local startX = plantSize * (col-1) + plantStartX
		local startY = plantSize * -1 + plantStartY
		if (door1_cell[2] == col and door1_cell[1] == 1) or (door2_cell[2] == col and door2_cell[1] == 1) then
			shouldDrawWall = false
		else
			shouldDrawWall = true
		end
		if (shouldDrawWall) then
			love.graphics.draw(topWall, startX, startY, 0,
				wallXScale, wallYScale, 0)
		else
			love.graphics.draw(doorTop, startX, startY, 0,
				wallXScale, wallYScale, 0)
		end

		wallXScale = plantSize / bottomWall:getWidth()
		wallYScale = plantSize / bottomWall:getHeight()
		local startX = plantSize * (col-1) + plantStartX
		local startY = plantSize * (#tileMatrix) + plantStartY
		if (door1_cell[2] == col and door1_cell[1] == #tileMatrix) or (door2_cell[2] == col and door2_cell[1] == #tileMatrix) then
			shouldDrawWall = false
		else
			shouldDrawWall = true
		end
		if (shouldDrawWall) then
			love.graphics.draw(bottomWall, startX, startY, 0,
					wallXScale, wallYScale, 0)
		else
			love.graphics.draw(doorBottom, startX, startY, 0,
				wallXScale, wallYScale, 0)
		end
    end
    for row = 1, #tileMatrix do
    	wallXScale = plantSize / leftWall:getWidth()
		wallYScale = plantSize / leftWall:getHeight()
		local startX = plantSize * -1 + plantStartX
		local startY = plantSize * (row-1) + plantStartY
		if (door1_cell[1] == row and door1_cell[2] == 1) or (door2_cell[1] == row and door2_cell[2] == 1) then
			shouldDrawWall = false
		else
			shouldDrawWall = true
		end
		if shouldDrawWall then
			love.graphics.draw(leftWall, startX, startY, 0,
					wallXScale, wallYScale, 0)
		else
			love.graphics.draw(doorLeft, startX, startY, 0,
				wallXScale, wallYScale, 0)
		end

		wallXScale = plantSize / leftWall:getWidth()
		wallYScale = plantSize / leftWall:getHeight()
		local startX = plantSize * (#tileMatrix[row]) + plantStartX
		local startY = plantSize * (row-1) + plantStartY
		if (door1_cell[1] == row and door1_cell[2] == #tileMatrix[1]) or (door2_cell[1] == row and door2_cell[2] == #tileMatrix[1]) then
			shouldDrawWall = false
		else
			shouldDrawWall = true
		end
		if shouldDrawWall then
			love.graphics.draw(leftWall, startX, startY, 0,
					wallXScale, wallYScale, 0)
		else
			love.graphics.draw(doorRight, startX, startY, 0,
				wallXScale, wallYScale, 0)
		end
		love.graphics.draw(rightWall, startX, startY, 0,
				wallXScale, wallYScale, 0)
    end
	
	-- draw dirt beneath everything
	local dirtImage = love.graphics.newImage("graphics/dirt.jpg")
	for row = 1, #tileMatrix do
		for col = 1, #tileMatrix[row] do
			plantXScale = plantSize / dirtImage:getWidth()
			plantYScale = plantSize / dirtImage:getHeight()
			local startX = plantSize * (col-1) + plantStartX
			local startY = plantSize * (row-1) + plantStartY
			love.graphics.draw(dirtImage, startX, startY, 0,
					plantXScale, plantYScale, 0)
		end
	end

	--draw plants
	for row = 1, #tileMatrix do
		for col = 1, #tileMatrix[row] do
			plantObject = tileMatrix[row][col]
			plantImage = plantObject:getImage()
			plantXScale = plantSize / plantImage:getWidth()
			plantYScale = plantSize / plantImage:getHeight()
			local startX = plantSize * (col-1) + plantStartX
			local startY = plantSize * (row-1) + plantStartY
			love.graphics.draw(plantImage, startX, startY, 0,
					plantXScale, plantYScale, 0)
			if mouseXScaled > startX and mouseYScaled > startY and mouseXScaled < startX + plantSize and mouseYScaled < startY + plantSize then
				local greenImage = love.graphics.newImage("graphics/green.png")
				love.graphics.draw(greenImage, startX, startY, 0,
					plantSize / greenImage:getWidth(), plantSize / greenImage:getHeight(), 0)
			end
		end
	end

	-- draw inventory
	invY = 0
	for col = 0, 9 do
		local invX = (inventoryWidth * col)
		love.graphics.draw(inventorySquare, invX, invY, 0,
		inventoryWidth/inventorySquare:getWidth(), inventoryHeight/inventorySquare:getHeight() , 0)

		-- draw watering can in first slot, seeds in all else
		if col == 0 then
			wateringcan = love.graphics.newImage("graphics/wateringcan.png")
			local wateringcanScale = 1.5
			local wateringcanHeight = wateringcan:getHeight() * wateringcanScale
			local wateringcanWidth = wateringcan:getWidth() * wateringcanScale
			love.graphics.draw(wateringcan, 0 , invY, 0, 
			wateringcanWidth/wateringcan:getWidth(), wateringcanHeight/wateringcan:getHeight(), 0)
			local waterCount = player.water
			love.graphics.print(""..waterCount, invX + 5, invY + 2, 0, 3, 3)
		elseif col <= #player.seeds then
			local plantToDraw = player.seeds[col]
			local seedImage = plants[plantToDraw]:getImage()
			local invOffset = 20
			local seedscale1 = (inventoryWidth - 2 * invOffset) / seedImage:getWidth()
			local seedscale2 = (inventoryHeight - 2 * invOffset) / seedImage:getHeight()
			love.graphics.draw(seedImage, invX + invOffset, invY + invOffset, 0,
				seedscale1, seedscale2, 0)
			local thisSeedCount = plants[plantToDraw].seeds
			love.graphics.print(""..thisSeedCount, invX + 5, invY + 2, 0, 3, 3)
		end
	end



	love.graphics.draw(player.sprite, player.x, player.y, 0, player.scale, player.scale, 12, 32)

	-- draw the hearts representing HP; for now it is hard-coded
	for h = 1, 5 do
		local x = hp_bar.hearts[h]
		if x == 0 then
			love.graphics.draw(empty_heart, 800+plantSize*h, 40, 0, 5, 5, 0, 32)
		else
			love.graphics.draw(full_heart, 800+plantSize*h, 40, 0, 5, 5, 0, 32)
		end
	end

	love.graphics.scale(1/xScale, 1/yScale)
	love.graphics.draw(cursorImage, mouseX, mouseY, 0, 40 / cursorImage:getWidth(), 40 / cursorImage:getHeight(), 0, 0)
end





function love.mousepressed(x, y, button, istouch)
	-- print coordinates
	-- print("pressed: "..x.." "..y.." "..xScale.." "..yScale)
	print("x-y coordinates: "..x.." "..y)
	x = x / xScale 
	y = y / yScale

	local tileY = 0
	local tileX = 0

	local plantX = x - plantStartX
	local plantY = y - plantStartY

	tileY = math.ceil( plantY / plantSize )
	tileX = math.ceil( plantX / plantSize )

	if tileY >= 1 and tileY <= 9 and tileX >= 1 and tileX <= 16 then
		if selected ~= "water" and selected ~= "" then
			local selectedPlant = plants[selected]
			local overTile = tileMatrix[tileY][tileX]
			if selectedPlant:canPlantOnTile(overTile) and plants[selected].seeds > 0 then
				tileMatrix[tileY][tileX] = plants[selected]:new()
				tileMatrix[tileY][tileX]:onLoad()
				tileMatrix[tileY][tileX]:onPlant()
				plants[selected].seeds = plants[selected].seeds - 1
			end
		elseif selected == "water" and player.water > 0 then
			tileMatrix[tileY][tileX]:onWater(tileY, tileX)
			player.water = player.water - 1
		end
	end

	-- print door coordinates and character coordinates
	print("character coordinates: "..cell[1].." "..cell[2])
	print("door 1 coordinates: "..door1_cell[1].." "..door1_cell[2].." "..door1_direction)
	print("door 2 coordinates: "..door2_cell[1].." "..door2_cell[2].." "..door2_direction)
	--print("door coordinates: "..door_cell[1].." "..door_cell[2])
	--print(door_direction)


	if y <= inventoryHeight then
		local inventoryXPressed = math.floor(x / inventoryWidth)
		if (inventoryXPressed == 0) then
			selected = "water"
			cursorImage = love.graphics.newImage("graphics/watering-can-pixilart.png")
		elseif inventoryXPressed <= #player.seeds then
			selected = player.seeds[inventoryXPressed]
			cursorImage = love.graphics.newImage(plants[selected].imageDir)
		end
	end

end
