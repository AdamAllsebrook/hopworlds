local h = Object:extend()

h.hss = Spritesheet(love.graphics.newImage('gfx/health.png'), 16, 16)
h.bss = Spritesheet(love.graphics.newImage('gfx/bullets.png'), 7, 6)

function h:new(other, pos)
    self.pos = pos or Vector(10, 10)
    self.other = other or true
    self.upgrade = false
end

function h:draw(health, maxh, bul, maxb)
    local x
    for i = 0, maxh - 1 do
        x = self.pos.x + i * 16
        if i < health then n = 1 else n = 0 end
        if i == 0 then
            love.graphics.draw(self.hss.image, self.hss:getImage(0, n), x, self.pos.y)
        elseif i == maxh - 1 then
            love.graphics.draw(self.hss.image, self.hss:getImage(2, n), x, self.pos.y)
        else
            love.graphics.draw(self.hss.image, self.hss:getImage(1, n), x, self.pos.y)
        end
    end
    local t = love.graphics.newText(fonts.small)
    t:addf(tostring(health) .. '/' .. tostring(maxh), maxh * 16, 'center')
    love.graphics.draw(t, self.pos.x, self.pos.y + 1)
    if self.other then
        if player.shield then love.graphics.draw(self.hss.image, self.hss:getImage(3, 0), x + 16, self.pos.y) end
        for i = 0, maxb - 1 do  
            x = self.pos.x + i * 7
            if i < bul or gamestate == 'upgrading' then n = 1 else n = 0 end
            love.graphics.draw(self.bss.image, self.bss:getImage(0, n), x, self.pos.y + 15)
            local num
            if gamestate == 'upgrading' then num = game.numPlanets else num = game.numPlanets - 1 end
            love.graphics.print(tostring(num), love.graphics.getWidth() / 3 - 16, 0)
        end
    end
end

return h
