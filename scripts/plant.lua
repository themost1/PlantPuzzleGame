require('scripts.object')

local plants = {}
plant = object:new{
	name = "Base Plant",
	id = "grass",
	image = nil,
	watered = false,
	passable = true,
	dmg = false,
	seeds = 0,
	seedImage = nil,
	seedImageDir = "graphics/grass.png",
	imageDir = "graphics/grass.png"
}

function plant:onLoad()
	self.image = love.graphics.newImage(self.imageDir)
	self.seedImage = love.graphics.newImage(self.seedImageDir)
end

function plant:onClick()
	if(selected == "water") then
		self:onWater()
	end
end

function plant:getImage()
	return self.image
end

function plant:getSeedImage()
	return self.seedImage
end

function plant:onWater()
end

function plant:onEnter()
	if self.dmg then
		hp_bar:onDamage()
	end
end

function plant:canPlantOnTile(tile)
	if tile.id == "dirt" then
		return true
	else
		return false
	end
end

dirt = plant:new {
	name = "Dirt",
	id = "dirt",
	seedImageDir = "graphics/dirt.jpg",
	imageDir = "graphics/dirt.jpg"
}

bamboo = plant:new {
	name = "Bamboo",
	image = nil,
	passable = false,
	id = "bamboo",
	imageDir = "graphics/bamboo_tile.png",
	seedImageDir = "graphics/bamboo_tile.png"
}

cactus = plant:new {
	name = "Cactus",
	id = "cactus",
	dmg = true,
	imageDir = "graphics/cactus.png",
	seedImageDir = "graphics/cactus.png"
}

function plants:addPlant(toAdd)
	self[toAdd.id] = toAdd
end


plants:addPlant(plant)
plants:addPlant(dirt)
plants:addPlant(bamboo)
plants:addPlant(cactus)

return plants