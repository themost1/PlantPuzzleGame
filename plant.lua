require('object')

plant = object:new {
	name = "Base Plant",
	image = nil
}

function plant:onLoad()
	self.image = love.graphics.newImage("graphics/pngwave.png")
end

function plant:onClick()
	self.image = love.graphics.newImage("graphics/bamboo.png")
end

function plant:getImage()
	return self.image
end



bamboo = plant:new {
	name = "Bamboo",
	image = nil
}

function bamboo:onLoad()
	self.image = love.graphics.newImage("graphics/bamboo.png")
end