love.graphics.setDefaultFilter("nearest")

function love.load()
	player = {
		x = 0,
		y = 0,
		sprite = love.graphics.newImage("graphics/player.png"),
		speed = 5
	}
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
	love.graphics.draw(player.sprite, player.x, player.y, 0, 1, 1, 0, 32)
end