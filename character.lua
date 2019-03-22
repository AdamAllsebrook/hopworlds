local p = Object:extend()


function p:new(pos, gun)
    self.pos = pos
    self.imgSize = Vector(16, 20)
    self.size = Vector(6, 13)
    self.rectOffset = Vector(5, 5)
    self.direction = 1
    self.gun = Gun(gun)
    self.gunOffset = Vector(8, 11)
    self.aim = Vector(1, 0)
    self.animfsm = fsm.create({
    initial = 'idle',
    events = {
        {name = 'move', from = 'idle', to = 'run'},
        {name = 'stop', from = 'run', to = 'idle'},
    }
    })
    self.health = 1
    self.timers = {invi=0, flash=0}
    self.tweens = {}
    self.falling = false
    self.scale = 1
    self.rot = 0
    self.dir = Vector(1, 0)
    self.masterGunOffset = Vector(self.gunOffset:unpack())
end

function p:makeRect()
    self.rect = world:rectangle(0, 0, self.size:unpack())
    self.feet = world:rectangle(0, self.size.y / 2, self.size.x, self.size.y / 3, {'feet'})
    self:moveRect()
end

function p:new2()
end

function p:moveRect()
    local pos = Vector(self.rect:bbox())
    self.rect:move((self.pos + self.rectOffset - pos):unpack())
    self.feet:move((self.pos + self.rectOffset - pos):unpack())
end

function p:shoot()
    local offset = -self.gun.stats.bulletsDifference * (self.gun.stats.numBullets - 1) / 2
    local random = love.math.random(-self.gun.stats.spread / 2, self.gun.stats.spread / 2)
    for i = 1, self.gun.stats.numBullets do
        local aim = self.aim:rotated((random + offset) * (math.pi / 180))
        offset = offset + self.gun.stats.bulletsDifference
        local gunOffset = Vector(self.gun.stats.len - self.gun.offset.x, 0):rotated(self.aim:angleTo(Vector(self.direction, 0)) * self.direction)
        local pos = self.pos - (Vector(self.imgSize.x, 0) / 2 * (self.direction - 1)) + (self.gun.offset + self.gunOffset + Vector(self.gun.stats.len - self.gun.offset.x, 0):rotated(self.aim:angleTo(Vector(1, 0)))) * self.direction
        local pos = Vector(self.pos.x - self.imgSize.x / 2 * (self.direction - 1) + (self.gun.offset.x + self.gunOffset.x + gunOffset.x) * self.direction, self.pos.y + self.gun.offset.y + self.gunOffset.y + gunOffset.y)
        local p = Projectile(pos, aim, self.gun.stats.speed)
        table.insert(p.rect.tags, self)
        objects[p] = p
    end
    self:onShoot()

    self.gunOffset = Vector(self.masterGunOffset:unpack())
    local offset = Vector(self.gunOffset:unpack())
    self.gunOffset = self.gunOffset + Vector(-2, 1)
    self.tweens.gunOffset = tween.new(.1, self.gunOffset, {x=offset.x, y=offset.y}, tween.easing.outCubic)
    
    self.sounds.shoot:stop()
    self.sounds.shoot:play()
end

function p:onPlanet(pos)
    local ok = false
    lastPos = Vector(self.pos:unpack())
    self.pos = pos
    self:moveRect()
    local collisions = world:collisions(self.feet, {'floor'})
    for _, __ in pairs(collisions) do
        ok = true
        break
    end
    self.pos = lastPos
    self:moveRect()
    return ok
end

function p:dieTween(func)
    love.timer.sleep(.01)
    screenShake:start(.2, 8)
    self.dead = true
    self.func = func
    self.timers.die = 0
    self.tweens.die = tween.new(.8, self.pos, {x=self.pos.x + self.dir.x * 64, y=self.pos.y + self.dir.y * 64}, tween.easing.outCubic)
    self.tweens.die2 = tween.new(.4, self, {rot=math.pi / 2 * self.dir.x / math.abs(self.dir.x)}, tween.easing.outCubic)
    self.tweens.die2:setFunc(function (self)
        self.func()
        self.tweens.die2 = nil
        end, self)
end

function p:onHit()
end
function p:onShoot()
end

function p:preUpdate(dt)
end
function p:update3(dt)
end
function p:draw2(dt)
end

function p:update(dt)
    for i, timer in pairs(self.timers) do
        if timer > 0 then self.timers[i] = timer - dt end
    end
    for _, tween in pairs(self.tweens) do tween:update(dt) end

    if self.timers.wait and self.timers.wait <= 0 then self.waiting = false end

    if self.falling and self.sounds.fall then self.sounds.fall:play() end
    
    if not (self.falling or self.teleporting or self.waiting or self.dead) then
        self:preUpdate(dt)
        self.anims[self.animfsm.current]:update(dt)

        local aim =  self:getAim()
        if not (aim.x == 0 and aim.y == 0) then
            self.aim = aim
            if aim.x ~= 0 then self.direction = aim.x / math.abs(aim.x) end
        end

        local delta = self:getMove()
        self.pos = self.pos + delta * dt * self.speed
        if delta.x == 0 and delta.y == 0 then
            self.animfsm:stop()
        else
            self.animfsm:move()
        end
        self:moveRect()

        if self.timers.invi <= 0 then
            local collisions = world:collisions(self.rect, {'damage'})
            for other, _ in pairs(collisions) do
                if not table.contains(other.tags, self) and not (self.a and table.contains(other.tags, self.a)) and not (self.b and table.contains(other.tags, self.b)) then
                    if not (table.contains(other.tags, 'explosion') and self.noExplode) then
                        if self.shield then self.shield = false else self.health = self.health - 1 end
                        self.timers.invi = self.inviTimer
                        self.timers.flash = 0.08
                        self:onHit()
                        if other.owner.delta then
                            if other.owner.delta.x == 0 then other.owner.delta.x = 0.01 end ; if other.owner.delta.y == 0 then other.owner.delta.y = .01 end
                            self.dir = other.owner.delta:normalized()
                        end
                        if not other.owner:is(Explosion) then other.owner:die() end
                        break
                    end
                end
            end
        end
        if self.health <= 0 then self:die() return end

        if self.gun:update(dt, self:getShoot()) then
            self:shoot()
        end

        if not self:onPlanet(self.pos) then
            self.tweens.scale = tween.new(.3, self, {scale=0.01}, tween.easing.outCubic)
            self.tweens.scale:setFunc(self.spawn, self)
            self.anims.run.frame = 1
            self.falling = true
        end
    end
    if self.dead then
        if not self:onPlanet(self.pos) then 
            self.tweens.scale = tween.new(.3, self, {scale=0.01}, tween.easing.outCubic)
            self.falling = true
        end
    end
    self:update3(dt)
end

function p:draw()
    if self.teleporting then
        love.graphics.push()
            love.graphics.translate(self.pos.x + self.imgSize.x / 2, 0)
            love.graphics.scale(self.teleportsx, 1)
            love.graphics.translate(-self.pos.x - self.imgSize.x / 2, 0)
            love.graphics.draw(self.teleport, self.pos.x, self.pos.y + 16 - 256)
            love.graphics.pop()
    else 
        love.graphics.push()
        love.graphics.translate(self.pos.x + self.imgSize.x / 2, self.pos.y + self.imgSize.y / 2)
        love.graphics.scale(self.direction * self.scale, 1 * self.scale)
        love.graphics.rotate(self.rot)
        love.graphics.translate(-self.pos.x - self.imgSize.x / 2, -self.pos.y - self.imgSize.y / 2)
        if self.timers.flash > 0 then love.graphics.setShader(whiteShader) end
        love.graphics.draw(self.ss.image, self.anims[self.animfsm.current]:get(), self.pos:unpack())
        love.graphics.setShader(shader)
        self.gun:draw(self.pos + self.gunOffset, self.aim:angleTo(Vector(self.direction, 0)) * self.direction, self.animfsm.current, self.anims[self.animfsm.current]:getFrame())
        love.graphics.pop()
  end
 -- self.rect:draw('fill')
    self:draw2()
end

inh = {
    player = {},
    enemy = {},
}

--player
inh.player.input = baton.new({
  controls = {
    movel = {'key:a', 'axis:leftx-'},
    mover = {'key:d', 'axis:leftx+'},
    moveu = {'key:w', 'axis:lefty-'},
    moved = {'key:s', 'axis:lefty+'},
    aiml = {'key:left', 'axis:rightx-'},
    aimr = {'key:right', 'axis:rightx+'},
    aimu = {'key:up', 'axis:righty-'},
    aimd = {'key:down', 'axis:righty+'},
    shoot = {'mouse:1', 'button:rightshoulder'},
    pause = {'key:escape', 'button:start'},
  },
  pairs = {
    move = {'movel', 'mover', 'moveu', 'moved'},
    aim = {'aiml', 'aimr', 'aimu', 'aimd'}
  },
  joystick = love.joystick.getJoysticks()[1],
})

inh.player.ss = Spritesheet(love.graphics.newImage('gfx/player.png'), 16, 20)

inh.player.anims = {
    idle = Anim(inh.player.ss:getAnimation(0, 0, 4), 10, true),
    run = Anim(inh.player.ss:getAnimation(0, 1, 8), 14, true),
}

inh.player.teleport = love.graphics.newImage('gfx/teleport.png')

inh.player.speed = 100
inh.player.inviTimer = 0.3
inh.player.maxHealth = 3
inh.player.health = inh.player.maxHealth
inh.player.teleportsx = 1
inh.player.noExplode = true
inh.player.isplayer = true

function inh.player:new2()
    self.upgrades = {}
    self.sounds = {
        shoot = love.audio.newSource('sfx/shoot.wav', 'static'),
        damage = love.audio.newSource('sfx/damage.wav', 'static'),
        telein = love.audio.newSource('sfx/teleport in.wav', 'static'),
        fall = love.audio.newSource('sfx/fall.wav', 'static'),
        die = love.audio.newSource('sfx/die.wav', 'static'),
    }
end

function inh.player:spawn()
    self.scale = 1
    self:resetPos()
    self.tweens = {}
    if self.falling and not self.noFall then self.health = self.health - 1 end
    self.falling = false
    self:teleportTween()
    self.gun:reset()
    screenShake:start(.15, 3)
end

function inh.player:teleportTween(finished)
    self.teleporting = true
    self.tweens.teleport = tween.new(0.05, self, {teleportsx=1.2}, tween.easing.outQuartic)
    self.tweens.teleport:setFunc(function (self)
        self.tweens.teleport = tween.new(.2, self, {teleportsx=0.05}, tween.easing.inCubic)
        
        self.sounds.telein:stop()
        self.sounds.telein:play()
        if game.won then
            self.tweens.teleport:setFunc(function (self)
                game:die() end, self)
        elseif finished then
            self.tweens.teleport:setFunc(function (self)
                self.tweens.teleport = nil
                self.teleporting = false
                transition:start()
            end, self)
        else
            self.tweens.teleport:setFunc(function (self)
                self.tweens.teleport = nil
                self.teleporting = false
            end, self)
        end
            
    end, self)
end

function inh.player:resetPos()
    self.pos = Vector((Planet.size * ts / 2):unpack())
    self:moveRect()
end

function inh.player:preUpdate(dt)
    self.input:update()
end

function inh.player:getShoot()
    return self.input:get('shoot')
end

function inh.player:getAim()
    if self.input:getActiveDevice() == 'joy' then
        return Vector(self.input:get('aim'))
    else
        local mpos = Vector(love.mouse.getPosition()) / scale
        local center = Vector(love.graphics.getWidth(), love.graphics.getHeight()) / scale / 2
        return (mpos - center):normalized()
    end
end

function inh.player:getMove()
    return Vector(self.input:get('move'))
end

function inh.player:onHit()
    screenShake:start(0.1, 5)
    if game.flags.owie then
        for i = 0, 2 * math.pi, math.pi / 4 do
            local p = Projectile(self.pos + self.imgSize / 2, Vector.fromPolar(i, 1), self.gun.stats.speed)
            objects[p] = p
        end
    end
    if self.health > 0 then
        self.sounds.damage:play()
    else
        self.sounds.die:play()
    end
end

function inh.player:onShoot()
    screenShake:start(0.1, 2)
    love.timer.sleep(.02)
end

function inh.player:die()
    self:dieTween(function () game:die() end)
end

function Player()
    local player = p(Vector((Planet.size * ts / 2):unpack()), 'player')
    inherit(player, inh.player)
    player:new2()
    player:makeRect()
    return player
end

--enemy
inh.enemy.inviTimer = 0

inh.enemy.ss = Spritesheet(love.graphics.newImage('gfx/enemies.png'), 16, 20)

function inh.enemy:new2()
    self.states = fsm.create({
        initial = 'shooting',
        events = {
            {name='move', from='shooting', to='moving'},
            {name='shoot', from='moving', to='shooting'}
        }
    })
    self.goTo = self.pos
    self.gun.bulletsLeft = love.math.random(-2, 0)--0--love.math.random(0, self.gun.stats.clipSize - 1)
    --self.timers.wait = love.math.random(.1, .3)
    --self.waiting = true
    self.sounds = {
        damage = love.audio.newSource('sfx/enemy damage.wav', 'static'),
        shoot = love.audio.newSource('sfx/shoot.wav', 'static'),
        explode = love.audio.newSource('sfx/explode.wav', 'static'),
        die = love.audio.newSource('sfx/enemydie.wav', 'static'),
    }
    self.sounds.shoot:setVolume(.6)
end

function inh.enemy:spawn()
    if self.falling then self:die() end
end

function inh.enemy:preUpdate(dt)
    if self.states.current == 'shooting' and self.gun.bulletsLeft <= 0 then
        self.states:move()
        self.goTo = self:getRandomPos()
    elseif self.states.current == 'moving' and self.gun.bulletsLeft == self.gun.stats.clipSize then
        self.states:shoot()
    end
end

function inh.enemy:getRandomPos()
    local ok = false ; local pos ; local r ; local angle
    while not ok do
        r = love.math.random(50, 200)
        angle = love.math.random(0, 2 * math.pi)
        pos = self.pos + Vector(math.cos(angle), math.sin(angle)) * r
        if self:onPlanet(pos) then ok = true end
    end
    return pos
end

function inh.enemy:getMove()
    if self.states.current == 'moving' and not (self.timers.flash > 0) then
        local delta =  self.goTo - self.pos
        if delta:len() > 3 then return delta:normalized()
        else self.goTo = self:getRandomPos() return Vector(0, 0) end
    else
        return Vector(0, 0)
    end
end

function inh.enemy:getAim()
    return (player.pos - self.pos):normalized()
end

function inh.enemy:getShoot()
    if self.states.current == 'shooting' and not self.waiting then return 1
    else return 0 end
end

function inh.enemy:onHit()
    self.sounds.damage:stop()
    self.sounds.damage:play()
end

function inh.enemy:die()
    if self.falling and not self.dead then
        self.dead = true
        game.numEnemies = game.numEnemies - 1
    else
        self:dieTween(function () game.numEnemies = game.numEnemies - 1 end)
    end
    local n ; if game.flags.guarantee then n = 4 elseif game.flags.explodiest then n = 3 elseif game.flags.explodier then n = 2 else n = 1 end
    local rn = love.math.random(1, 4)
    if rn <= n and not self.falling then 
        local e = Explosion(self.pos + self.imgSize / 2)
        self.sounds.explode:play()
        objects[e] = e
    end
    if game.flags.ouch then
        for i = 0, 2 * math.pi, math.pi / 2 do
            local p = Projectile(self.pos + self.imgSize / 2, Vector.fromPolar(i, 1), self.gun.stats.speed)
            objects[p] = p
        end
    end
    self.sounds.die:play()
end

--enemy types
inh.orc = {
    speed = 60,
    gunOffset = Vector(10, 9),
    health = 3,
}
function inh.orc:new3()
    self.anims = {
    idle = Anim(inh.enemy.ss:getAnimation(0, 0, 4), 8, true, 2),
    run = Anim(inh.enemy.ss:getAnimation(0, 1, 8), 10, true),
    }
    self.size = Vector(11, 18)
    self.rectOffset = Vector(2, 1)
end

inh.dev = {
    speed = 80,
    gunOffset = Vector(7, 11),
    health = 3,
}
function inh.dev:new3()
    self.anims = {
    idle = Anim(inh.enemy.ss:getAnimation(0, 2, 4), 10, true, 1),
    run = Anim(inh.enemy.ss:getAnimation(0, 3, 8), 12, true),
    }
    self.size = Vector(7, 15)
    self.rectOffset = Vector(4, 4)
end

inh.cac = {
    speed = 60,
    gunOffset = Vector(10, 8),
    health = 3,
}
function inh.cac:new3()
    self.anims = {
    idle = Anim(inh.enemy.ss:getAnimation(0, 4, 4), 10, true, 2),
    run = Anim(inh.enemy.ss:getAnimation(0, 5, 4), 14, true),
    }
    self.size = Vector(8, 16)
    self.rectOffset = Vector(5, 3)
end

inh.pen = {
    speed = 70,
    gunOffset = Vector(10, 12),
    health = 2,
}
function inh.pen:new3()
    self.anims = {
    idle = Anim(inh.enemy.ss:getAnimation(0, 6, 4), 10, true, 1),
    run = Anim(inh.enemy.ss:getAnimation(0, 7, 8), 14, true),
    }
    self.size = Vector(8, 16)
    self.rectOffset = Vector(4, 4)
end

inh.gol = {
    speed = 65,
    gunOffset = Vector(10, 7),
    health = 4,
}

function inh.gol:new3()
    self.anims = {
        idle = Anim(inh.enemy.ss:getAnimation(0, 8, 4), 10, true, 2),
        run = Anim(inh.enemy.ss:getAnimation(0, 9, 8), 14, true),
        }
    self.size = Vector(9, 17)
    self.rectOffset = Vector(4, 3)
end


inh.boss = {
    speed = 90,
    gunOffset = Vector(8, 11),
    maxHealth = 10,
    health = 10,
    ss1 = Spritesheet(love.graphics.newImage('gfx/boss.png'), 16, 20),
    ss2 = Spritesheet(love.graphics.newImage('gfx/boss.png'), 16, 26),
    ss3 = Spritesheet(love.graphics.newImage('gfx/boss.png'), 16, 32),
    teleport = love.graphics.newImage('gfx/teleport.png'),
    teleportsx = 1
}

function inh.boss:new3()
    self.boss = true
    self.imgSize = Vector(16, 26)
    if game.numPlanets == game.bossPlanet then
        self.ss = self.ss1
        self.anims = {
            idle = Anim(self.ss1:getAnimation(0, 0, 4), 10, true, 2),
            run = Anim(self.ss1:getAnimation(0, 1, 8), 14, true),
            }
        self.size = Vector(6, 13)
        self.rectOffset = Vector(5, 5)
    elseif game.numPlanets == game.bossPlanet + 1 then
        self.maxHealth = 15
        self.health = 15
        self.ss = self.ss2
        self.anims = {
            idle = Anim(self.ss2:getAnimation(0, 2, 4), 10, true, 2),
            run = Anim(self.ss2:getAnimation(0, 3, 8), 14, true),
            }
        self.size = Vector(7, 20)
        self.rectOffset = Vector(4, -2)
        self.gunOffset = Vector(7, 8)
    elseif game.numPlanets == game.bossPlanet + 2 then
        self.maxHealth = 20
        self.health = 20
        self.ss = self.ss3
        self.anims = {
            idle = Anim(self.ss3:getAnimation(0, 4, 4), 10, true, 2),
            run = Anim(self.ss3:getAnimation(0, 5, 8), 14, true),
            }
        self.size = Vector(7, 26)
        self.rectOffset = Vector(5, -8)
        self.gunOffset = Vector(7, 8)
    end

    if game.numPlanets >= game.bossPlanet + 1 then
        self.a = p(self.pos, 'boss2')
        self.a.rect = self.rect
        self.a.rectOffset = self.rectOffset
        self.a.gunOffset = Vector(3, 13)
        self.a.masterGunOffset = Vector(2, 13)
        self.a.anims = {
            idle = Anim(self.ss3:getAnimation(100, 100, 4), 10, true, 2),
            run = Anim(self.ss3:getAnimation(100, 100, 8), 14, true),
            }
        self.a.ss = self.ss
        self.a.sounds = self.sounds
    end
    if game.numPlanets >= game.bossPlanet + 2 then
        self.b = p(self.pos, 'boss3')
        self.b.rect = self.rect
        self.b.rectOffset = self.rectOffset
        self.b.gunOffset = Vector(8, 18)
        self.b.masterGunOffset = Vector(8, 18)
        self.b.anims = {
            idle = Anim(self.ss3:getAnimation(100, 100, 4), 10, true, 2),
            run = Anim(self.ss3:getAnimation(100, 100, 8), 14, true),
            }
        self.b.ss = self.ss
        self.b.sounds = self.sounds
    end
    self.masterGunOffset = Vector(self.gunOffset:unpack())
    bosshb = {HealthBar(false, Vector(love.graphics.getWidth() / 6 - self.maxHealth * 8, 36)), self.health, self.maxHealth}
end

function inh.boss:update3(dt)
    if self.a then
        self.a.pos = self.pos
        self.a.direction = self.direction
        self.a.aim = self.aim
        if self.a.gun:update(dt, self:getShoot()) then self.a:shoot() end
    end
    if self.b then
        self.b.pos = self.pos
        self.b.direction = self.direction
        self.b.aim = self.aim
        if self.b.gun:update(dt, self:getShoot()) then self.a:shoot() end
    end
    bosshb[2] = self.health
end

function inh.boss:draw2()
    if not self.teleporting then
        if self.a then
            self.a:draw()
        end
        if self.b then
            self.b:draw()
        end
    end
end

function inh.boss:die()
    if self.falling then self.scale = 1 self.tweens.scale = nil self.falling = false 
      self.teleporting = true
        self.tweens.teleport = tween.new(0.05, self, {teleportsx=1.2}, tween.easing.outQuartic)
        self.tweens.teleport:setFunc(function (self)
            self.tweens.teleport = tween.new(.2, self, {teleportsx=0.05}, tween.easing.inCubic)
            
            player.sounds.telein:stop()
            player.sounds.telein:play()
            self.tweens.teleport:setFunc(function (self)
                self.tweens.teleport = nil
                self.teleporting = false
            end, self)
          end, self)
          self.pos = planet:getRandomPos() * ts
          return
          end
    if game.numPlanets == game.bossPlanet + 3 then
        screenShake:start(.5, 10)
        inh.enemy.die(self)
        game.numEnemies = game.numEnemies + 1
        self.tweens.die = tween.new(1, {x=0}, {x=1})
        self.tweens.die:setFunc(function (self)
            game.numEnemies = game.numEnemies - 1 end, self)
        player.timers.invi = 1
    else
        self.teleporting = true
        self.tweens.teleport = tween.new(0.05, self, {teleportsx=1.2}, tween.easing.outQuartic)
        self.tweens.teleport:setFunc(function (self)
            self.tweens.teleport = tween.new(.2, self, {teleportsx=0.05}, tween.easing.inCubic)
            
            player.sounds.telein:stop()
            player.sounds.telein:play()
            self.tweens.teleport:setFunc(function (self)
                self.tweens.teleport = nil
                self.teleporting = false
                game.numEnemies = game.numEnemies - 1
            end, self)
                
        end, self)
    end
end


local weapons = {
    orc='pistol',
    dev='hell pistol',
    cac='blaster',
    pen='burst rifle',
    gol='shotgun',
    boss='boss1'
}

function Enemy(pos, name)
    local enemy = p(pos, weapons[name])
    inherit(enemy, inh.enemy)
    inherit(enemy, inh[name])
    enemy:new2()
    enemy:new3()
    enemy:makeRect()
    return enemy
end


return {Char=p, Player=Player, Enemy=Enemy, input={input=inh.player.input}}