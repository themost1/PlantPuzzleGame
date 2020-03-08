require('scripts.object')

local plants = {}
plant = object:new{
	name = "Base Plant",
	id = "grass",
	image = nil,
	watered = false,
	passable = true,
	dmg = false
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

function plant:onEnter()
	if self.dmg then
		hp_bar:onDamage()
	end
end


bamboo = plant:new {
	name = "Bamboo",
	image = nil,
	passable = false,
	id = "bamboo"
}

cactus = plant:new {
	name = "Cactus",
	id = "cactus",
	dmg = true
}

function bamboo:onLoad()
	self.image = love.graphics.newImage("graphics/bamboo_tile.png")
end

function cactus:onLoad()
	self.image = love.graphics.newImage("graphics/cactus.png")
end


function plants:addPlant(toAdd)
	self[toAdd.id] = toAdd
end


plants:addPlant(plant)
plants:addPlant(bamboo)
plants:addPlant(cactus)

return plants