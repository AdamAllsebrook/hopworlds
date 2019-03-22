p = Object:extend()

p.image = love.graphics.newImage('gfx/bullet.png')
p.colours = {
	light={Clr('FFFFFF'), Clr('FEE761'), Clr('FEAE34'), Clr('F77622')},
	dark ={Clr('FF0044'), Clr('E43B44'), Clr('A22633'), Clr('8E0232')}
}
p.r = 3

function p:new(pos, delta, speed)
	self.pos = pos
	self.delta = delta
	self.speed = speed
	self.rect = world:circle(pos.x, pos.y, self.r - 1, {'damage'})
	self.rect.owner = self
	self.trails = {}
	self.timer = 0
end

function p:update(dt)
	local lastPos = {x=self.pos.x, y=self.pos.y}
	if #self.trails >= 3 then table.remove(self.trails, 1) end ; table.insert(self.trails, {x=self.pos.x, y=self.pos.y})
	self.pos = self.pos + self.delta * dt * self.speed
	if #self.trails >= 3 then table.remove(self.trails, 1) end ; table.insert(self.trails, {x=(lastPos.x + self.pos.x) / 2, y=(lastPos.y + self.pos.y) / 2})
	self.rect:moveTo(self.pos:unpack())
	self.timer = self.timer + dt
	if self.timer > 10 then self:die() end
end

function p:die()
	world:remove(self.rect)
	objects[self] = nil
end

function p:draw()
	local col = 'light'
	for i, pos in ipairs(self.trails) do
		love.graphics.setColor(self.colours[col][5 - i])
		love.graphics.draw(self.image, pos.x - self.r, pos.y - self.r)
	end
	love.graphics.setColor(self.colours[col][1])
	love.graphics.draw(self.image, self.pos.x - self.r, self.pos.y - self.r)
	love.graphics.setColor(1, 1, 1)
end

return p