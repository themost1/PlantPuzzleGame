local json = require('scripts.dkjson')

local P = {}
util = P

function P.printTable(tab)
	local state = {indent = true, keyorder = keyOrder}
	print(json.encode(tab, state))
end

function P.getOffsetByDir(dir)
	while (dir > 4) do dir = dir - 4 end
	if dir == 1 then return {y = -1, x = 0}
	elseif dir == 2 then return {y = 0, x = 1}
	elseif dir == 3 then return {y = 1, x = 0}
	else return {y = 0, x = -1} end
end

function P.readJSON(filePath, askForRooms)
	local str = love.filesystem.read(filePath)
	local obj, pos, err, roomsArray = json.decode(str, 1, nil, askForRooms and 'rooms' or nil)
	if err then
		print('Error:', err)
		return nil
	else
		return obj, roomsArray
	end
end

function P.writeJSON(filePath, data, state, directory)
	local usedSaveDir = saveDir
	if directory ~= nil then
		usedSaveDir = saveDir..'/'..directory
	end
	local str = json.encode(data, state)
	if not love.filesystem.exists(usedSaveDir) then
		love.filesystem.createDirectory(usedSaveDir)
	end
	love.filesystem.write(usedSaveDir..'/'..filePath, str)
end

return util