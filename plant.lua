require('object')

plant = object:new{
	name = "Base Plant",
	image = nil,
	watered = false,
	passable = true
}

function plant:onLoad()
	self.image = love.graphics.newImage("graphics/grass.png")
end

function plant:onClick()
	if(selected == "water") then
		self:onWater()
	end
end

function plant:getImage()
	return self.image
end

function plant:onWater()
end


bamboo = plant:new {
	name = "Bamboo",
	image = nil,
	passable = false
}

function bamboo:onLoad()
	self.image = love.graphics.newImage("graphics/bamboo_tile.png")
end