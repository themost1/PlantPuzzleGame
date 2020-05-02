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
	watered = true,
	description = "Plant this and see",
	rotation = 0
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
function plant:getEImage()
	return self.image
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

function plant:onReach()
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
function plant:isPassable()
	return true
end

function plant:update(dt)
end

function plant:onStep(row, col)
end
function plant:preStep(row, col)
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
	description = "Block movement"
}
function bamboo:isPassable()
	if self.watered == false then
		return true
	else
		return false
	end
end

cactus = plant:new {
	name = "Cactus",
	id = "cactus",
	dmg = true,
	imageDir = "graphics/cactus.png",
	seedImageDir = "graphics/plants/cactus seed.png",
	description = "Take damage on entry"
}

dragonfruit = plant:new {
	name = "Dragonfruit",
	id = "dragonfruit",
	imageDir = "graphics/dragonfruitbomb.png",
	seedImageDir = "graphics/plants/dragonfruit seed.png",
	explosionCounter = 0,
	explosionTimer = 0,
	description = "Explode!"
}

function dragonfruit:onWater(row, col)
	print("watering dfruit")
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
	seedImageDir = "graphics/plants/dandelion seed.png",
	description = "Water diagonal plants too!"
}

function dandelion:onWater(row, col)
	self.watered = true
	print("aaa")
	-- water everything around it
	for i = -1, 1 do
		for j = -1, 1 do
			if row+i >= 1 and row+i <= 9 and col+j >= 1 and col+j <= 16 and (i ~= 0 and j ~= 0) then
				t = tileMatrix[row+i][col+j]
				print(t.name.." "..row+i.." "..col+j)
				if not t.watered then
					t:onWater(row+i, col+j)
				end
				tileMatrix[row+i][col+j] = t
			end
		end
	end
end

apple = plant:new {
	name = "Apple",
	id = "apple",
	imageDir = "graphics/plants/apple.png",
	seedImageDir = "graphics/plants/apple seed.png",
	description = "Gain health"
}
function apple:onEnter()
	if self.watered and not self.entered then
		hp_bar:onHeal()
		self.entered = true
		self.image = getNewImage("graphics/plants/apple_core.png")
	end
end

portalPlant = plant:new {
	name = "Portal Plant",
	id = "portalPlant",
	imageDir = "graphics/plants/portalPlant.png",
	seedImageDir = "graphics/plants/dandelion seed.png",
}
function portalPlant:onEnter()
	goToNextMap()
end
function portalPlant:update(dt)
	self.rotation = self.rotation + 100
end

function plants:addPlant(toAdd)
	self[toAdd.id] = toAdd
end

currentUp = plant:new {
	name = "Up-Current",
	id = "currentUp",
	imageDir = "graphics/plants/waterCurrent.png",
	rotation = 0
}
function currentUp:onReach()
	local ct = getCurrentTile()
	if self.rotation == 0 then
		ct.y = ct.y - 1
	elseif self.rotation < 3.14/2 + 0.1 then
		ct.x = ct.x + 1
	elseif self.rotation < 3.14 + 0.1 then
		ct.y = ct.y + 1
	else
		ct.x = ct.x - 1
	end

	if not (ct.y >= 1 and ct.y <= #tileMatrix and ct.x >= 1 and ct.x <= #tileMatrix[ct.y]) then
		return
	elseif tileMatrix[ct.y][ct.x]:isPassable() == false then
		return
	end

	if self.rotation == 0 then
		player.static_y = player.static_y - plantSize
	elseif self.rotation < 3.14/2 + 0.1 then
		player.static_x = player.static_x + plantSize
	elseif self.rotation < 3.14 + 0.1 then
		player.static_y = player.static_y + plantSize
	else
		player.static_x = player.static_x - plantSize
	end
end

currentDown = currentUp:new {
	id = "currentDown",
	rotation = 3.14
}
currentLeft = currentUp:new {
	id = "currentLeft",
	rotation = 3.14 * 3/2
}
currentRight = currentUp:new {
	id = "currentRight",
	rotation = 3.14 * 1/2
}

oxyplant = plant:new {
	name = "Oxyplant",
	id = "oxyplant",
	imageDir = "graphics/plants/oxyplant.png",
	description = "Refills full health"
}
function oxyplant:onEnter()
	hp_bar:fullHeal()
	player.dead = false
	if string.find(announcementText, "died") ~= nil then
		announcementText = ""
	end
end

coral = plant:new {
	name = "Coral",
	id = "coral",
	description = "Blocks movement (and currents); can plant on top of a current",
	passable = false,
	imageDir = "graphics/plants/coral.png",
	seedImageDir = "graphics/plants/coral.png",
	watered = true
}
function coral:isPassable()
	return false
end
function coral:canPlantOnTile(tile)
	if tile.id == "dirt" then
		return true
	elseif tile.id == "currentUp" or tile.id == "currentDown" or tile.id == "currentLeft" or tile.id == "currentRight" then
		return true
	else
		return false
	end
end

fish = plant:new {
	name = "Fish",
	id = "fish",
	imageDir = "graphics/fishUp.png",
	moveDir = "up",
	row = -1,
	col = -1,
	moved = false
}
function fish:preStep()
	self.moved = false
end
function fish:onStep(row, col)
	if self.moved then return end
	self.row = row
	self.col = col

	if self.moveDir == "up" then
		local grass = plants.grass:new()
		grass:onLoad()
		tileMatrix[row-1][col] = self
		tileMatrix[row][col] = grass
		self.row = row-1
		if self.row - 1 <= 0 or tileMatrix[self.row-1][col].id ~= "grass" then
			self.moveDir = "down"
		end
	elseif self.moveDir == "down" then
		local grass = plants.grass:new()
		grass:onLoad()
		tileMatrix[row][col] = grass
		tileMatrix[row+1][col] = self
		self.row = row+1
		if self.row +1 > #tileMatrix or tileMatrix[self.row+1][col].id ~= "grass" then
			self.moveDir = "up"
		end
	end

	self.moved = true
	self:updateImage()
end
function fish:updateImage()
	if self.moveDir == "up" then
		self.imageDir = "graphics/fishUp.png"
	elseif self.moveDir == "down" then
		self.imageDir = "graphics/fishDown.png"
	end

	self.image = getNewImage(self.imageDir)
end



plants:addPlant(plant)
plants:addPlant(dirt)
plants:addPlant(bamboo)
plants:addPlant(cactus)
plants:addPlant(dragonfruit)
plants:addPlant(dandelion)
plants:addPlant(apple)
plants:addPlant(portalPlant)
plants:addPlant(currentUp)
plants:addPlant(currentDown)
plants:addPlant(currentLeft)
plants:addPlant(currentRight)
plants:addPlant(currentRight)
plants:addPlant(oxyplant)
plants:addPlant(coral)
plants:addPlant(fish)

return plants
