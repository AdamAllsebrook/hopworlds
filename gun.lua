Gun = Object:extend()

Gun.ss = Spritesheet(love.graphics.newImage('gfx/guns.png'), 10, 5)
Gun.offset = Vector(2, 2.5)

Gun.bounce = {
    idle = {Vector(0, 0), Vector(0, 0), Vector(0, 1), Vector(0, 1)},
    run = {Vector(0, 0), Vector(0, -1), Vector(0, -2), Vector(0, 0), Vector(0, 0), Vector(0, -1), Vector(0, -2), Vector(0, 0)}
}

function Gun:new(name)
    name = name

    self.stats = table.clone(require("guns/" .. name))

    self:reset()

    self.image = self.ss:getImage(self.stats.image.x, self.stats.image.y)
end

function Gun:reset()
    self.holdTimer = 0
    self.reloadTimer = 0
    self.bulletsLeft = self.stats.clipSize
end

function Gun:update(dt, shoot)
    if shoot == 1 then
        self.reloadTimer = 0
        if self.holdTimer <= 0 and self.bulletsLeft > 0 then
            self.holdTimer = 1 / self.stats.firerate
            if not (game.flags.infinity and self.stats.infin) then self.bulletsLeft = self.bulletsLeft - self.stats.numBullets end
            return true
        else
            self.holdTimer = self.holdTimer - dt
        end
    else
        self.holdTimer = 0
        if self.reloadTimer >= self.stats.reloadTime then
            self.reloadTimer = 0
            self.bulletsLeft = math.min(self.bulletsLeft + 1, self.stats.clipSize)
        else
            self.reloadTimer = self.reloadTimer + dt
        end
    end
end

function Gun:draw(pos, rot, anim, frame)
    love.graphics.push()
        if frame then love.graphics.translate(self.bounce[anim][frame]:unpack()) end
        love.graphics.translate((pos + self.offset):unpack())
        love.graphics.rotate(rot)
        love.graphics.translate((-pos - self.offset):unpack())
        love.graphics.draw(self.ss.image, self.image, pos.x, pos.y)
        love.graphics.pop()
end


return Gun
