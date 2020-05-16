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
		dead = false,
		editor = false,
		mapNum = 1
	}

	imageBank = {}
	startRoomX = 3 -- default 3
	startRoomY = 2 -- default 2
	player.map_x = startRoomX
	player.map_y = startRoomY

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
	hovered = ""

	xScale = love.graphics.getWidth() / 1600
	yScale =love.graphics.getHeight() / 900

	inventorySquare = love.graphics.newImage("graphics/ui/inventorySquare.png")
	inventorySquareSelected = love.graphics.newImage("graphics/ui/inventorySquareSelected.png")
	inventorySquareHovered = love.graphics.newImage("graphics/ui/inventorySquareHovered.png")
	minimapRoomRectangle = love.graphics.newImage("graphics/minimap_room.png")
	minimapBox = love.graphics.newImage("graphics/minimap_box.jpg")

	inventoryScale = 3
	inventoryHeight = inventorySquare:getHeight() * inventoryScale
	inventoryWidth = inventorySquare:getWidth() * inventoryScale

	hp_bar = hp_bar:new()
	full_heart = love.graphics.newImage("graphics/heart_full.png")
	empty_heart = love.graphics.newImage("graphics/heart_empty.png")
	half_heart = love.graphics.newImage("graphics/heart_half_full.png")

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

	congratulations_image = love.graphics.newImage("graphics/congratulations.png")

	prev_cells = {{}, {}}
	loadRooms()
	loadMap('maps/map1.json')
	tileMatrix = currentRoom.layout

	love.mouse.setVisible(false)

	cursorImage = love.graphics.newImage("graphics/mouse.png")
	dirtImage = love.graphics.newImage("graphics/dirt.jpg")
	grassImage = love.graphics.newImage("graphics/grass.png")
	greenImage = love.graphics.newImage("graphics/green.png")
	wateringcanImage = love.graphics.newImage("graphics/wateringcan.png")


	announcementText = ""
end

function loadRooms()
	local read = util.readJSON('roomData/rooms.json', true)
	rooms = {}
	for i = 1, #read do
		rooms[#rooms + 1] = read[i]
		rooms[read[i].name] = read[i]
	end
end

function goToNextMap()
	player.mapNum = player.mapNum + 1
	if player.mapNum == 2 then
		loadMap('maps/map2.json')
	end
end

function loadMap(whichMap)
	local read = util.readJSON(whichMap, true)
	local mapLayout = read[1].layout
	map = {}

	for i = 1, #mapLayout do
		local mapRow = {}
		for j = 1, #mapLayout[i] do
			currentRoom = {}
			local roomId = mapLayout[i][j]
			if roomId ~= "" then
				currentRoom.name = rooms[mapLayout[i][j]].name

				local layout =  {}
				local testLayout = rooms[mapLayout[i][j]].layout
				for i2 = 1, #testLayout do
					local layoutRow = {}
					for j2 = 1, #testLayout[i2] do
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

				currentRoom.entered = false
				currentRoom.beaten = false
			end

			mapRow[#mapRow + 1] = currentRoom
		end
		map[#map+1] = mapRow
	end

	goToRoom(startRoomY, startRoomX, "")
end

function getNewRoomLayout(roomName)
	local testLayout = rooms[roomName].layout
	local layout =  {}
	for i2 = 1, #testLayout do
		local layoutRow = {}
		for j2 = 1, #testLayout[i2] do
			local addPlant = plants[testLayout[i2][j2]]:new()
			addPlant:onLoad()
			layoutRow[#layoutRow+1] = addPlant
		end
		layout[#layout+1] = layoutRow
	end

	return layout
end

function kill_player()
	announcementText = "You died :( Press r to restart the room!"
	player.dead = true
end

function goToTileLoc(row, col)
	player.x = plantStartX + (col-1)*plantSize
	player.y = plantStartY + (row-1)*plantSize
	player.static_x = player.x
	player.static_y = player.y
	hp_bar:fullHeal()
end

function restart_room()
	player.dead = false
	currentRoom.entered = false -- trigger giving necessary seeds/water in this room in gTR
	goToRoom(player.map_y, player.map_x, "")
	goToTileLoc(currentRoom.door1Y, currentRoom.door1X)
	announcementText = ""

	currentRoom.layout = getNewRoomLayout(currentRoom.name)
	tileMatrix = currentRoom.layout
end

function love.keypressed(key, scancode, isrepeat)
	if key == "r" then
		restart_room()
	elseif key == "1" then
		selected = "water"
	elseif key == "2" and #player.seeds >= 1 then
		selected = player.seeds[1]
	elseif key == "3" and #player.seeds >= 2 then
		selected = player.seeds[2]
	elseif key == "4" and #player.seeds >= 3 then
		selected = player.seeds[3]
	end

	if (selected == "water") then
		cursorImage = love.graphics.newImage("graphics/watering-can-pixilart.png")
	elseif selected ~= "" then
		cursorImage = love.graphics.newImage(plants[selected].imageDir)
	end
	if key == "e" then
		editor = not editor
	end
	if key == "s" and editor == true then
		save()
	end
end
function save()
	file = io.open("newMap.txt","w")
	for row = 1, #tileMatrix do
		s = ""
		for col = 1, #tileMatrix[row] do
			s = s .. '"' .. tileMatrix[row][col].name .. '"'
		end
		file:write(s)
	end
	file:close()
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
		--tileMatrix[cell[1]][cell[2]]:onEnter()
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
	if player.dead == false then
		if love.keyboard.isDown("up") and cell[1] > 1 then
			local obj = tileMatrix[cell[1]-1][cell[2]]
			if obj:isPassable() then
				up_allowed = 1
			end
		elseif love.keyboard.isDown("down") and cell[1] < 9 then
			local obj = tileMatrix[cell[1]+1][cell[2]]
			if obj:isPassable() then
				down_allowed = 1
			end
		elseif love.keyboard.isDown("left") and cell[2] > 1 then
			local obj = tileMatrix[cell[1]][cell[2]-1]
			if obj:isPassable() then
				left_allowed = 1
			end
		elseif love.keyboard.isDown("right") and cell[2] < 16 then
			local obj = tileMatrix[cell[1]][cell[2]+1]
			if obj:isPassable() then
				right_allowed = 1
			end
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
	local currLoc = getCurrentTile()
	if player.x>player.static_x then
		if player.x-player.static_x>=frame_speed then
			player.x = player.x - frame_speed
		else
			player.x = player.static_x
			tileMatrix[currLoc.y][currLoc.x]:onReach()
		end
	end
	-- move right
	if player.x<player.static_x then
		if player.static_x-player.x>=frame_speed then
			player.x = player.x + frame_speed
		else
			player.x = player.static_x
			tileMatrix[currLoc.y][currLoc.x]:onReach()
		end
	end
	-- move up
	if player.y>player.static_y then
		if player.y-player.static_y>=frame_speed then
			player.y = player.y - frame_speed
		else
			player.y = player.static_y
			tileMatrix[currLoc.y][currLoc.x]:onReach()
		end
	end
	-- move down
	if player.y<player.static_y then
		if player.static_y-player.y>=frame_speed then
			player.y = player.y + frame_speed
		else
			player.y = player.static_y
			tileMatrix[currLoc.y][currLoc.x]:onReach()
		end
	end

	-- step 5 - read the keyboard for new movement
	if player.state == 'still' then

		local movedThisTurn = false
		-- We restrict the player to stay within the bounds of the playable board
		-- PRESS A KEY TO MOVE TO THE NEXT LOCATION
		if love.keyboard.isDown("up") and up_allowed==1 then
			if ((player.static_y - plantSize) >= (plantStartY)) then
				player.static_y = player.static_y - plantSize
				movedThisTurn = true
			end

		elseif love.keyboard.isDown("down") and down_allowed==1 then
			if (player.static_y + plantSize) < (plantStartY + plantSize * 9) then
				player.static_y = player.static_y + plantSize
				movedThisTurn = true
			end

		elseif love.keyboard.isDown("left") and left_allowed==1 then
			if (player.static_x - plantSize) >= (plantStartX) then
				player.static_x = player.static_x - plantSize
				movedThisTurn = true
			end
		elseif love.keyboard.isDown("right") and right_allowed==1 then
			if (player.static_x + plantSize) < (plantStartX + plantSize * 16) then
				player.static_x = player.static_x + plantSize
				movedThisTurn = true
			end
	    end

	    if movedThisTurn then
	    	if player.mapNum == 2 then
	    		hp_bar:onWaterWalk()
	    	end

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
			end

			for i = 1, #tileMatrix do
				for j = 1, #tileMatrix[i] do
					tileMatrix[i][j]:preStep(i, j)
				end
			end
			for i = 1, #tileMatrix do
				for j = 1, #tileMatrix[i] do
					tileMatrix[i][j]:onStep(i, j)
				end
			end

			tileMatrix[cell[1]][cell[2]]:postEnter()
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
			player.x = player.static_x-80
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
			player.x = player.static_x+80
			-- reset lives
			hp_bar.hearts = {1,1,1,1,1}
			hp_bar.hp = 5
		end
	end

	--update plants
	for i = 1, #currentRoom.layout do
		for j = 1, #currentRoom.layout[i] do
			currentRoom.layout[i][j]:update(dt, i, j)
		end
	end


end

function goToRoom(row, col, dir)
	if map[row][col].entered == false then
		currentRoom.beaten = true
	end
	selected = ""

	currentRoom = map[row][col]
	aTileMatrix = currentRoom.layout
	tileMatrix = aTileMatrix

	if not currentRoom.entered then
		player.seeds = currentRoom.seeds
		player.water = currentRoom.water
		for seed = 1, #player.seeds do
			local thisSeed = player.seeds[seed]
			plants[thisSeed]:onLoad()
			plants[thisSeed].seeds = currentRoom.seedCounts[seed]
		end

		currentRoom.entered = true
	end
	door1_cell[1] = currentRoom.door1Y
	door1_cell[2] = currentRoom.door1X
	door1_direction = currentRoom.door1Direction
	door2_cell[1] = currentRoom.door2Y
	door2_cell[2] = currentRoom.door2X
	door2_direction = currentRoom.door2Direction
	cursorImage = love.graphics.newImage("graphics/mouse.png")
end

function drawMinimap()
	love.graphics.scale(1/xScale, 1/yScale)
	local minimapScale = 0.25
	local minimapX = love.graphics.getWidth() - minimapBox:getWidth() * minimapScale
	love.graphics.draw(minimapBox, minimapX, 0, 0, minimapScale, minimapScale)

	local roomRectLen = 12
	local roomRectHeight = 6
	local roomRectXScale = roomRectLen / minimapRoomRectangle:getWidth()
	local roomRectYScale = roomRectHeight / minimapRoomRectangle:getHeight()
	for i = 1, #map do
		for j = 1, #map[i] do
			if map[i][j] ~= nil and map[i][j].entered then
				if i ~= player.map_y or j ~= player.map_x then
					love.graphics.setColor(1, 0.5, 0.5)
				else
					love.graphics.setColor(0.5, 1, 0.5)
				end
				love.graphics.draw(minimapRoomRectangle, minimapX + (j) * roomRectLen + (j-1), (i) * roomRectHeight + (i-1), 0, roomRectXScale, roomRectYScale)
				love.graphics.setColor(1, 1, 1)
			end
		end
	end

	love.graphics.scale(xScale, yScale)
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
    	local wallXScale = plantSize / leftWall:getWidth()
		local wallYScale = plantSize / leftWall:getHeight()
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
		if (door1_cell[1] == row and door1_cell[2] == #tileMatrix[1]) or (door2_cell[1] == row and door2_cell[2] == #tileMatrix[row]) then
			shouldDrawWall = false
		else
			shouldDrawWall = true
		end
		if shouldDrawWall then
			love.graphics.draw(rightWall, startX, startY, 0,
					wallXScale, wallYScale, 0)
		else
			love.graphics.draw(doorRight, startX, startY, 0,
				wallXScale, wallYScale, 0)
		end
    end


	-- draw dirt beneath everything
	for row = 1, #tileMatrix do
		for col = 1, #tileMatrix[row] do
			local underImage = grassImage
			if player.mapNum == 2 then
				underImage = grassImage
			end
			local plantXScale = plantSize / underImage:getWidth()
			local plantYScale = plantSize / underImage:getHeight()
			local startX = plantSize * (col-1) + plantStartX
			local startY = plantSize * (row-1) + plantStartY
			love.graphics.draw(underImage, startX, startY, 0,
					plantXScale, plantYScale, 0)
		end
	end
	images = {}
	--draw plants
	for row = 1, #tileMatrix do
		for col = 1, #tileMatrix[row] do
			plantObject = tileMatrix[row][col]
			if(editor == true) then
				plantImage = plantObject:getEImage()
			else
				plantImage = plantObject:getImage()
			end
			plantXScale = plantSize / plantImage:getWidth()
			plantYScale = plantSize / plantImage:getHeight()
			local startX = plantSize * (col-1) + plantStartX
			local startY = plantSize * (row-1) + plantStartY
			love.graphics.draw(plantImage, startX + plantSize/2, startY + plantSize/2, plantObject.rotation,
					plantXScale, plantYScale, plantImage:getWidth()/2, plantImage:getHeight()/2)
			--highlight tile mouse is currently hovering over
			if mouseXScaled > startX and mouseYScaled > startY and mouseXScaled < startX + plantSize and mouseYScaled < startY + plantSize then
				love.graphics.draw(greenImage, startX, startY, 0,
					plantSize / greenImage:getWidth(), plantSize / greenImage:getHeight(), 0)
			end
		end
	end

	-- draw inventory
	invY = 0
	for col = 0, 9 do
		local invX = (inventoryWidth * col)
		local invSquareToDraw = inventorySquare
		if col == 0 then
			if selected == "water" then
				invSquareToDraw = inventorySquareSelected
			elseif hovered == "water" then
				invSquareToDraw = inventorySquareHovered
			end
		elseif col <= #player.seeds then
			local pName = player.seeds[col]
			if selected == pName then
				invSquareToDraw = inventorySquareSelected
			elseif hovered == pName then
				invSquareToDraw = inventorySquareHovered
			end
		end
		love.graphics.draw(invSquareToDraw, invX, invY, 0,
		inventoryWidth/inventorySquare:getWidth(), inventoryHeight/inventorySquare:getHeight() , 0)

		-- draw watering can in first slot, seeds in all else
		if col == 0 then
			local wateringcanScale = 1.5
			local wateringcanHeight = wateringcanImage:getHeight() * wateringcanScale
			local wateringcanWidth = wateringcanImage:getWidth() * wateringcanScale
			love.graphics.draw(wateringcanImage, 0 , invY, 0,
			wateringcanWidth/wateringcanImage:getWidth(), wateringcanHeight/wateringcanImage:getHeight(), 0)

			local waterCount = player.water
			love.graphics.print(""..waterCount, invX + 5, invY + 2, 0, 3, 3)
		elseif col <= #player.seeds then
			local plantToDraw = player.seeds[col]
			local seedImage = plants[plantToDraw]:getSeedImage()
			local invOffset = 20
			local seedscale1 = (inventoryWidth - 2 * invOffset) / seedImage:getWidth()
			local seedscale2 = (inventoryHeight - 2 * invOffset) / seedImage:getHeight()
			love.graphics.draw(seedImage, invX + invOffset, invY + invOffset, 0,
				seedscale1, seedscale2, 0)
			local thisSeedCount = plants[plantToDraw].seeds
			love.graphics.print(""..thisSeedCount, invX + 5, invY + 2, 0, 3, 3)
		end
	end
	--draw editor inventory
	if editor == true then
		invX = 1520
		if player.mapNum == 2 then
			allItems = {"grass", "fish", "coral", "oxyplant", "currentUp", "currentDown", "currentLeft", "currentRight"}
		else
			allItems = {"bamboo", "cactus", "apple", "grass", "dirt", "dandelion"}
		end
		for row = 0, #allItems - 1 do
			local invY = (inventoryHeight * row) + 100
			love.graphics.draw(inventorySquare, invX, invY, 0,
			inventoryWidth/inventorySquare:getWidth(), inventoryHeight/inventorySquare:getHeight() , 0)
			--[[if row == 4 or row == 0 then
				path = "graphics/" .. allItems[row+1] .. ".jpg"
			else
				path = "graphics/" .. allItems[row+1] .. ".png"
			end]]
			plant = plants[allItems[row+1]]:onLoad()
			currentImage = plants[allItems[row+1]]:getImage()
			--currentImage = love.graphics.newImage(path)
			local invOffset = 20
			local seedscale1 = (inventoryWidth - 2 * invOffset) / currentImage:getWidth()
			local seedscale2 = (inventoryHeight - 2 * invOffset) / currentImage:getHeight()
			love.graphics.draw(currentImage, invX+40, invY+40, plants[allItems[row+1]].rotation,
				seedscale1, seedscale2, currentImage:getWidth()/2, currentImage:getHeight()/2)
		end
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.print(announcementText, 100, 80, 0, 3, 3)
	love.graphics.setColor(1, 1, 1)



	love.graphics.draw(player.sprite, player.x, player.y, 0, player.scale, player.scale, 12, 32)

	-- draw the hearts representing HP; for now it is hard-coded
	for h = 1, 5 do
		local x = hp_bar.hearts[h]
		if x == 0 then
			love.graphics.draw(empty_heart, 800+plantSize*h, 40, 0, 5, 5, 0, 32)
		elseif x == 0.5 then
			love.graphics.draw(half_heart, 800+plantSize*h, 40, 0, 5, 5, 0, 32)
		else
			love.graphics.draw(full_heart, 800+plantSize*h, 40, 0, 5, 5, 0, 32)
		end
	end

	drawMinimap()

	love.graphics.scale(1/xScale, 1/yScale)
	if inventoryYPressed ~= nil then
		love.graphics.draw(cursorImage, mouseX, mouseY, plants[allItems[inventoryYPressed+1]].rotation, 40 / cursorImage:getWidth(), 40 / cursorImage:getHeight(), cursorImage:getWidth()/2, cursorImage:getHeight()/2)
	else
		love.graphics.draw(cursorImage, mouseX, mouseY, 0, 40 / cursorImage:getWidth(), 40 / cursorImage:getHeight(), cursorImage:getWidth()/2, cursorImage:getHeight()/2)
	end

	if currentRoom.name == "World2_Room0404" then
		love.graphics.draw(congratulations_image, 10, 10, 0, 0.5, 0.5)
	end
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
	--mouse press functionality for the editor
	if editor == true then
		if x >= 1520 then
			inventoryYPressed = math.floor((y- 100) / inventoryHeight)
			print(inventoryYPressed)
			path = plants[allItems[inventoryYPressed+1]]:getImageDir()
			selected = allItems[inventoryYPressed+1]
			cursorImage = love.graphics.newImage(path)
		end
		if tileY >= 1 and tileY <= 9 and tileX >= 1 and tileX <= 16 then
				local selectedPlant = plants[selected]
				local overTile = tileMatrix[tileY][tileX]
				print(tileMatrix[tileY][tileX])
				tileMatrix[tileY][tileX] = plants[selected]:new()
				tileMatrix[tileY][tileX]:onLoad()
				plantXScale = plantSize / cursorImage:getWidth()
				plantYScale = plantSize / cursorImage:getHeight()
				local startX = plantSize * (tileX-1) + plantStartX
				local startY = plantSize * (tileY-1) + plantStartY
				love.graphics.draw(cursorImage, startX, startY, 0,
						plantXScale, plantYScale, 0)
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

function love.mousemoved(x, y, dx, dy, istouch)
	x = x / xScale
	y = y / yScale
	-- set announcement text to description of hovered-over plant
	local potentialAT = ""
	if y <= inventoryHeight then
		local inventoryXPressed = math.floor(x / inventoryWidth)
		if (inventoryXPressed == 0) then
			hovered = "water"
			potentialAT = "Water: Water a plant"
		elseif inventoryXPressed <= #player.seeds then
			hovered = player.seeds[inventoryXPressed]
			potentialAT = plants[hovered].name..": "..plants[hovered].description
		end
	else
		hovered = ""
	end

	if (not player.dead) then
		announcementText = potentialAT
	end
end

function getNewImage(imName)
	if imageBank[imName] ~= nil then
		return imageBank[imName]
	else
		imageBank[imName] = love.graphics.newImage(imName)
		return imageBank[imName]
	end
end

function getCurrentTile()
	local currX = math.floor((player.x - plantStartX)/plantSize + 1 + 0.5)
	local currY = math.floor((player.y - plantStartY)/plantSize + 1 + 0.5)
	return {x = currX, y = currY}
end

function getStaticTile()
	local currX = math.floor((player.static_x - plantStartX)/plantSize + 1 + 0.5)
	local currY = math.floor((player.static_y - plantStartY)/plantSize + 1 + 0.5)
	return {x = currX, y = currY}
end
