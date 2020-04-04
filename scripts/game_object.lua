require('scripts.object')

hp_bar = object:new {
	hearts = {1,1,1,1,1},
	hp = 5
}

function hp_bar:onDamage()
	print("damage")
	if self.hp > 0 then
		self.hearts[self.hp] = 0
		self.hp = self.hp - 1
		if self.hp == 0 then
			-- you are now dead
			-- TODO: respawn or trigger death animation or w/e
			kill_player()
		end
	end
end

function hp_bar:onHeal()
	if self.hp < 5 then
		self.hearts[self.hp+1] = 1
		self.hp = self.hp + 1
	end
end