love.graphics.setDefaultFilter("nearest")

function love.load()
	player = {
		sprite = love.graphics.newImage("graphics/player.png")
	}
end
 
function love.update(dt)
end

function love.draw()
	love.graphics.draw(player.sprite, 0, 0, 0, 1, 1, 0, 32)
end