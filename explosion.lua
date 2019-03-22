e = Object:extend()
e.r = 16
e.t = 0.1
e.ss = Spritesheet(love.graphics.newImage('gfx/explosion.png'), 32, 32)

function e:new(pos)
    self.pos = pos
    self.rect = world:circle(self.pos.x, self.pos.y, self.r, {'explosion'})
    self.rect.owner = self
    self.timer = 0
    screenShake:start(.1, 10)
    love.timer.sleep(.03)
end

function e:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.t then table.insert(self.rect.tags, 'damage') end
    if self.timer > self.t * 2 then self:die() end
end

function e:die()
    objects[self] = nil
    world:remove(self.rect)
end

function e:draw()
    local image
    if self.timer < self.t then 
        image = self.ss:getImage(0, 0)
    else
        image = self.ss:getImage(1, 0)
    end
    love.graphics.draw(self.ss.image, image, self.pos.x - self.r, self.pos.y - self.r)
end

return e