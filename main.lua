love.graphics.setDefaultFilter("nearest")
require ('scripts.plant')

function love.load()
	player = {
		x = 160,          -- initial position (must be =)
		y = 140,    -- initial position (must be =)
		scale = 0.40,         -- size (compared to original image)
		static_x = 160,       -- initial position (must be =)
		static_y = 140,    -- initial position (must be =)
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 4,       -- pixels of movement by frame
		tileSize = 80,   -- pixels size for each tile (PlantSize)
		state = 'still'
	}
	aTileMatrix = { }
	for i = 1, 9 do
		aTileMatrix[i] = {}
		for j = 1,16 do
			plantObject = plant:new()
			if i % 2 == 0 and j % 2 == 0 then
				plantObject = bamboo:new()
			end
			plantObject:onLoad()
			aTileMatrix[i][j] = plantObject
		end
	end

	tilesPressed = { }
	for i = 1, 9 do
		local row = {}
		for j = 1, 16 do
			row[#row+1] = 0
		end
		tilesPressed[#tilesPressed+1] = row
	end

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

end


function love.update(dt)

	-- check what cell we currently are in
	-- cells go from (1,1) to (9,16)
	local cell = {1+(player.static_y-plantStartY)/plantSize,
		1+(player.static_x-plantStartX)/plantSize}

	-- before moving, check that you can actually pass the object in the cell :)

	if love.keyboard.isDown("up") and cell[1] > 1 then
		local obj = aTileMatrix[cell[1]-1][cell[2]]
		if not obj.passable then
			return
		end
	elseif love.keyboard.isDown("down") and cell[1] < 9 then
		local obj = aTileMatrix[cell[1]+1][cell[2]]
		if not obj.passable then
			return
		end
	elseif love.keyboard.isDown("left") and cell[2] > 1 then
		local obj = aTileMatrix[cell[1]][cell[2]-1]
		if not obj.passable then
			return
		end
	elseif love.keyboard.isDown("right") and cell[2] < 16 then
		local obj = aTileMatrix[cell[1]][cell[2]+1]
		if not obj.passable then
			return
		end
	end

	player.state = 'still'
	if player.x ~= player.static_x or player.y ~= player.static_y then
		player.state = 'moving'
	end 

	-- MOVE CONTINUOUSLY FROM THE CURRENT LOCATION TO THE FOLLOWING ONE

	if player.x>player.static_x then
		player.x = player.x - player.speed
	end
	if player.x<player.static_x then
		player.x = player.x + player.speed
	end
	if player.y>player.static_y then
		player.y = player.y - player.speed
	end
	if player.y<player.static_y then
		player.y = player.y + player.speed
	end


	if player.state == 'still' then
		-- We restrict the player to stay within the bounds of the playable board
		-- PRESS A KEY TO MOVE TO THE NEXT LOCATION
		if love.keyboard.isDown("up") and player.y==player.static_y then
			if ((player.static_y - plantSize) >= (plantStartY)) then
				player.static_y = player.static_y - plantSize
			end
	    --end
		elseif love.keyboard.isDown("down") and player.y==player.static_y then
			if (player.static_y + plantSize) < (plantStartY + plantSize * 9) then
				player.static_y = player.static_y + plantSize
			end
	    --end
		elseif love.keyboard.isDown("left") and player.x==player.static_x then
			if (player.static_x - plantSize) >= (plantStartX) then
				player.static_x = player.static_x - plantSize
			end
		--end
		elseif love.keyboard.isDown("right") and player.x==player.static_x then
			if (player.static_x + plantSize) < (plantStartX + plantSize * 16) then
				player.static_x = player.static_x + plantSize
			end
	    end
	end

end




function love.draw()
	love.graphics.scale(xScale, yScale)

	for row = 1, 9 do
		for col = 1, 16 do
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

	for col = 0, 9 do
		love.graphics.draw(inventorySquare, (inventoryWidth * col), 0, 0,
		inventoryWidth/inventorySquare:getWidth(), inventoryHeight/inventorySquare:getHeight() , 0)	
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
		local cursor = love.mouse.newCursor("graphics/wateringcan.png", 0, 0)
		love.mouse.setCursor(cursor)
	end

end



