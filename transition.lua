local t = Object:extend()
t.offset = 0

function t:start(out)
    if player.dead or player.health == 0 then
        game:die()
        return was
    end
    gamestate = 'transition'
    if out then
        self.offset = -2048
        self.tween = tween.new(.3, self, {offset=0}, tween.easing.outCubic)
        self.tween:setFunc(function ()
            gamestate = 'playing' end, {})
    else
        if game.flags.infinity then game.flags.infinity = nil end
		if game.flags.guarantee then game.flags.guarantee = nil end
		if game.flags.many then player.gun.stats.numBullets = game.flags.many ; game.flags.many = nil end
        self.tween = tween.new(.3, self, {offset=2048}, tween.easing.inCubic)
        self.tween:setFunc(function ()
            if game.numPlanets % 3 == 0 then
                game:upgrade()
            else
                game:start()
            end end, {})
    end
end

function t:update(dt)
    player.input:update()
    if player.input:pressed('pause') then game:pause() end
    self.tween:update(dt)
    screenShake:update(dt)
end

function t:draw()
    love.graphics.push()
        love.graphics.translate(-self.offset, 0)
        love.graphics.translate(screenShake:getShake())
        love.graphics.scale(scale, scale)
        back:draw()
        love.graphics.translate((-player.pos + Vector(love.graphics.getDimensions()) / 2 / scale):unpack())
        planet:draw()
        for _, o in pairs(objects) do o:draw() end   
        love.graphics.pop()
    love.graphics.scale(3, 3)
    game.health:draw(player.health, player.maxHealth, player.gun.bulletsLeft, player.gun.stats.clipSize)
end

return t