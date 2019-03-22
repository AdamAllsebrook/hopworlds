local b = Object:extend()

b.ss = Spritesheet(love.graphics.newImage('gfx/back.png'), 8, 8)

function b:new()
    self.size = Vector(love.graphics.getDimensions()) / scale / ts * 4
    self.img = {}
    for x = 1, self.size.x do
        table.insert(self.img, {})
        for y = 1, self.size.y do
            self.img[x][y] = love.math.random(1, 64)
        end
    end
    self.imgs = {}
    for i = 1, 4 do
        table.insert(self.imgs, self.ss:getImage(i - 1, 0))
    end
    self.start = player.pos
end

function b:draw()
    love.graphics.push()
    love.graphics.translate((-self.size * ts / 2 + (player.pos - self.start) / 16):unpack())
    for x = 1, self.size.x do
        for y = 1, self.size.y do
            if self.img[x][y] >= 4 then
                love.graphics.draw(self.ss.image, self.imgs[4], x * ts, y * ts)
            else
                love.graphics.draw(self.ss.image, self.imgs[self.img[x][y]], x * ts, y * ts)
            end
        end
    end
    love.graphics.pop()
end

return b