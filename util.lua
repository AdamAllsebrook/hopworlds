function limit(number, min, max)
	return math.min(math.max(number, min), max)
end

screenShake = {}
screenShake.t, screenShake.dur, screenShake.mag = 0, -1, 0

function screenShake:start(dur, mag)
	if mag >= self.mag or self.t >= self.dur then
		self.t, self.dur, self.mag = 0, dur or 1, mag
	end
end

function screenShake:update(dt)
	if self.t < self.dur then
		self.t = self.t + dt
	end
end

function screenShake:getShake()
	local dx, dy = 0, 0
	if self.t < self.dur then
		dx = love.math.random(-self.mag, self.mag)
		dy = love.math.random(-self.mag, self.mag)
	end
	return dx, dy
end

function table.clone(t)
	local new = {}
	for i, v in pairs(t) do
		new[i] = v
	end
	return new
end

function table.shareElement(a, b)
	if not b then
		return true
	end
	for _, u in ipairs(a) do
		for _, v in ipairs(b) do
			if u == v then
				return true
			end
		end
	end
	return false
end

function Clr(r, g, b, a)
	local self = {}
	if type(r) == "string" then
		local col = r
		r = tonumber(string.sub(col, 1, 2), 16)
		g = tonumber(string.sub(col, 3, 4), 16)
		b = tonumber(string.sub(col, 5, 6), 16)
		a = tonumber(string.sub(col, 7, 8) or "FF", 16)
	end
	self[1] = r / 255
	self[2] = g / 255
	self[3] = b / 255
	self[4] = (a or 255) / 255
	return self
end

function inherit(self, other)
	for i, v in pairs(other) do
		self[i] = v
	end
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end
