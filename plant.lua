require('object')

plant = object:new {
	name = "Base Plant",
	image = nil
}

function plant:getImage()
	return love.graphics.newImage("graphics/pngwave.png")
end