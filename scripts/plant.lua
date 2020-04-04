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
	seedImageDir = "graphics/seeds.png",
	imageDir = "graphics/grass.png",
	watered = true
}

function plant:onLoad()
	self.image = love.graphics.newImage(self.imageDir)
	self.seedImage = love.graphics.newImage(self.seedImageDir)
end

function plant:onClick(row,col)
	if(selected == "water") then
		self:onWater()
	end
end

function plant:getImage()
	if self.watered then
		return self.image
	else
		return self.seedImage
	end
end

function plant:getSeedImage()
	return self.seedImage
end

function plant:onWater(row, col)
	self.watered = true
end

function plant:onEnter()
	if self.dmg then
		hp_bar:onDamage()
	end
end

function plant:onPlant()
	self.watered = false
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
	imageDir = "graphics/bamboo_tile.png"
}

cactus = plant:new {
	name = "Cactus",
	id = "cactus",
	dmg = true,
	imageDir = "graphics/cactus.png"
}

dragonfruit = plant:new {
	name = "Dragonfruit",
	id = "dragonfruit",
	imageDir = "graphics/dragonfruitbomb.png"
}

dandelion = plant:new {
	name = "Dandelion",
	id = "dandelion",
	imageDir = "graphics/dandelion.pixil-pixilart.png"
}

function plants:addPlant(toAdd)
	self[toAdd.id] = toAdd
end

function dragonfruit:onWater(row, col)
	self.watered = true
	for i = -1, 1 do
		for j = -1, 1 do
			if row+i >= 1 and row+i <= 9 and col+j >= 1 and col+j <= 16 then
				d = dirt:new()
				d:onLoad()
				tileMatrix[row+i][col+j] = d
			end
		end
	end
end

function dandelion:onWater(row, col)
	self.watered = true
	-- water everything around it
	for i = -1, 1 do
		for j = -1, 1 do
			if row+i >= 1 and row+i <= 9 and col+j >= 1 and col+j <= 16 and (i ~=0 or j ~= 0) then
				tileMatrix[row+i][col+j]:onWater(row+i, col+j)
			end
		end
	end
	
end

plants:addPlant(plant)
plants:addPlant(dirt)
plants:addPlant(bamboo)
plants:addPlant(cactus)
plants:addPlant(dragonfruit)
plants:addPlant(dandelion)

return plants