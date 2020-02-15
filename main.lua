love.graphics.setDefaultFilter("nearest")

function love.load()
	player = {
		x = 0,
		y = 0,
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 5
	}

	tilesPressed = { }
	for i = 1, 9 do
		local row = {}
		for j = 1, 16 do
			row[#row+1] = 0
		end
		tilesPressed[#tilesPressed+1] = row
	end

	dirtImage = love.graphics.newImage("graphics/dirt.jpg")
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
	local dirtScale = 1/4
	local dirtHeight = dirtImage:getHeight() * dirtScale
	local dirtWidth = dirtImage:getWidth() * dirtScale
	for row = 1, 9 do
		for col = 1, 16 do
			if tilesPressed[row][col] == 0 then
				love.graphics.draw(dirtImage, dirtWidth * col, dirtHeight * row, 0,
						dirtWidth/dirtImage:getWidth(), dirtHeight/dirtImage:getHeight(), 32)
			else
				--love.graphics.draw(dirtImage, dirtWidth * col, dirtHeight * row, 0, 1, 1, 0, 32)
			end
		end
	end

	love.graphics.draw(player.sprite, player.x, player.y, 0, 1, 1, 0, 32)
end

function love.mousepressed(x, y, button, istouch)
	local tileY = 0
	local tileX = 0
	local dirtScale = 1/4
	local dirtHeight = dirtImage:getHeight() * dirtScale
	local dirtWidth = dirtImage:getWidth() * dirtScale

	tileY = math.floor(y / dirtHeight)
	tileX = math.floor(x / dirtWidth)
	tilesPressed[tileY][tileX] = 1
end