love.graphics.setDefaultFilter("nearest")
require ('plant')

function love.load()
	player = {
		x = 0,
		y = 0,
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 5
	}
	aTileMatrix = { }
	for i = 1, 9 do
		aTileMatrix[i] = {}
		for j = 1,16 do
			plantObject = plant:new()
			if i % 2 == 0 or i % 2 == 1 then
				plantObject = plant:new()
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
	plantStartY = 10
	plantScale = 2.5
end
 
function love.update(dt)
	if love.keyboard.isDown("up") then
        player.y = player.y - player.speed
    end 
    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed
    end
	if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
    end

end

function love.draw()
	for row = 1, 9 do
		for col = 1, 16 do
			plantObject = aTileMatrix[row][col]
			plantImage = plantObject:getImage()
			plantXScale = plantSize / plantImage:getWidth()
			plantYScale = plantSize / plantImage:getHeight()
			love.graphics.draw(plantImage, plantSize * col + plantStartX, plantSize * row + plantStartY, 0,
					plantXScale, plantYScale, 32)
		end
	end

	love.graphics.draw(player.sprite, player.x, player.y, 0, 1, 1, 0, 32)
end

function love.mousepressed(x, y, button, istouch)
	local tileY = 0
	local tileX = 0
	local plantScale = 4
	local plantHeight = plantImage:getHeight() * plantScale
	local plantWidth = plantImage:getWidth() * plantScale

	tileY = math.floor(y / plantHeight)
	tileX = math.floor(x / plantWidth)
	tilesPressed[tileY][tileX] = 1
end