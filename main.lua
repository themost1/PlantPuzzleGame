love.graphics.setDefaultFilter("nearest")
require ('plant')




function love.load()
	player = {
		x = 100,          -- initial position (must be =)
		y = 140,    -- initial position (must be =)
		scale = 0.40,         -- size (compared to original image)
		static_x = 100,       -- initial position (must be =)
		static_y = 140,    -- initial position (must be =)
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 4,       -- pixels of movement by frame
		tileSize = 80    -- pixels size for each tile (PlantSize)
	}
	aTileMatrix = { }
	for i = 1, 9 do
		aTileMatrix[i] = {}
		for j = 1,16 do
			plantObject = plant:new()
			if i % 2 == j % 2 then
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
	plantStartX = 100
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
    


	-- PRESS A KEY TO MOVE TO THE NEXT LOCATION
	if love.keyboard.isDown("up") and player.y==player.static_y then
		if ((player.static_y - plantSize) > (plantStartY/ 2)) then
				player.static_y = player.static_y - plantSize
		end
    end
	if love.keyboard.isDown("down") and player.y==player.static_y then
		if (player.static_y + plantSize) < (plantStartY / 2 + plantSize * 9) then
			player.static_y = player.static_y + plantSize
		end
    end
	if love.keyboard.isDown("left") and player.x==player.static_x then
		if (player.static_x - plantSize) > (plantStartX / 2) then
			player.static_x = player.static_x - plantSize
		end
	end
	if love.keyboard.isDown("right") and player.x==player.static_x then
		if (player.static_x + plantSize) < (plantStartX / 2 + plantSize * 16) then
			player.static_x = player.static_x + plantSize
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



