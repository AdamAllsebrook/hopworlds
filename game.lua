local game = Object:extend()
game.bossPlanet = 24

function game:new()
    world = HC.new()
    player = char.Player()
    self.numPlanets = 0
    self.lastPlanet = 0
    self.flags = {}
    self.health = HealthBar()

    gamestate = 'playing'
end

function game:start()
    bosshb = nil
    world:resetHash()
    player:spawn()

    back = Back()

    local trans = (gamestate == 'upgrading' or gamestate == 'transition')

    gamestate = 'playing'
    objects = {}
    planet = Planet()

    if trans then transition:start(true) end
end

function game:upgrade()
    self.up = Upgrade()
    gamestate = 'upgrading'
end

function game:pause()
    self.pauseMenu = Pause(gamestate)
    gamestate = 'paused'
end

function game:die()
    self.endScreen = End()
    gamestate = 'end'
end

function game:update(dt)
    if self.numEnemies <= 0 and self.numPlanets == self.bossPlanet + 3 then
        self.won = true
    end
    if self.numEnemies <= 0 and not player.teleporting then
        player:teleportTween(true)
    end
    planet:update(dt)
    for _, o in pairs(objects) do o:update(dt) end
    player:update(dt)
    screenShake:update(dt)
    if player.input:pressed('pause') then self:pause() end
end

function game:draw()
    love.graphics.push()
        love.graphics.translate(screenShake:getShake())
        love.graphics.scale(scale, scale)
        back:draw()
        love.graphics.translate((-player.pos + Vector(love.graphics.getDimensions()) / 2 / scale):unpack())
        planet:draw()
        for _, o in pairs(objects) do o:draw() end
        player:draw()
        love.graphics.pop()
    love.graphics.scale(3, 3)
    self.health:draw(player.health, player.maxHealth, player.gun.bulletsLeft, player.gun.stats.clipSize)
    if bosshb then bosshb[1]:draw(bosshb[2], bosshb[3], 0, 0) end
end

return game