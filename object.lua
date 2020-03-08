object = {}
function object:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function object:instanceof(super)
	metatable = getmetatable(self)
	while metatable ~= nil do
		if metatable == super then return true end
		metatable = getmetatable(metatable)
	end
	return self==super
end

function object:super(func, ...)
	return getmetatable(self)[func](self,unpack(arg))
end
