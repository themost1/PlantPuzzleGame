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
	self.image = getNewImage(self.imageDir)
	self.seedImage = getNewImage(self.seedImageDir)
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

function plant:update(dt)
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
	seedImageDir = "graphics/plants/bamboo seed.png",
}

cactus = plant:new {
	name = "Cactus",
	id = "cactus",
	dmg = true,
	imageDir = "graphics/cactus.png",
	seedImageDir = "graphics/plants/cactus seed.png",
}

dragonfruit = plant:new {
	name = "Dragonfruit",
	id = "dragonfruit",
	imageDir = "graphics/dragonfruitbomb.png",
	seedImageDir = "graphics/plants/dragonfruit seed.png",
	explosionCounter = 0,
	explosionTimer = 0
}

function dragonfruit:onWater(row, col)
	self.watered = true
end

function dragonfruit:update(dt, row, col)
	if not self.watered then return end
	self.explosionTimer = self.explosionTimer + dt
	if self.explosionTimer > 0.05 then
		self.explosionTimer = self.explosionTimer - 0.05
		self.explosionCounter = self.explosionCounter + 1
		if self.explosionCounter >= 10 then
			for i = -1, 1 do
				for j = -1, 1 do
					if row+i >= 1 and row+i <= 9 and col+j >= 1 and col+j <= 16 and (i ==0 or j ==0) then
						local d = dirt:new()
						d:onLoad()
						tileMatrix[row+i][col+j] = d
					end
				end
			end
			return
		end
	end

	if self.explosionCounter > 0 then
		self.imageDir = "graphics/plants/dragonfruit/"
		self.imageDir = self.imageDir .. self.explosionCounter-1
		self.imageDir = self.imageDir .. ".png"
		self.image = getNewImage(self.imageDir)
	end

end

dandelion = plant:new {
	name = "Dandelion",
	id = "dandelion",
	imageDir = "graphics/dandelion.pixil-pixilart.png",
	seedImageDir = "graphics/plants/dandelion seed.png"
}

function dandelion:onWater(row, col)
	self.watered = true
	-- water everything around it
	for i = -1, 1 do
		for j = -1, 1 do
			if row+i >= 1 and row+i <= 9 and col+j >= 1 and col+j <= 16 and (i ~= 0 and j ~= 0) then
				t = tileMatrix[row+i][col+j]
				if not t.watered then
					t:onWater(row+i, col+j)
				end
			end
		end
	end
end

apple = plant:new {
	name = "Apple",
	id = "apple",
	imageDir = "graphics/plants/apple.png",
	seedImageDir = "graphics/plants/apple seed.png"
}
function apple:onEnter()
	if self.watered and not self.entered then
		hp_bar:onHeal()
		self.entered = true
		self.image = getNewImage("graphics/plants/apple_core.png")
	end
end



function plants:addPlant(toAdd)
	self[toAdd.id] = toAdd
end

plants:addPlant(plant)
plants:addPlant(dirt)
plants:addPlant(bamboo)
plants:addPlant(cactus)
plants:addPlant(dragonfruit)
plants:addPlant(dandelion)
plants:addPlant(apple)

return plants