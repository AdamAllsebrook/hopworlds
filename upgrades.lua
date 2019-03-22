local upgrades = {
    speedy = {desc='run faster', prereq={}, func=function (p) p.speed = p.speed * 1.2 end},
    speedier = {desc='run even faster', prereq={'speedy'}, func=function(p) p.speed = p.speed * 1.2 end},
    speediest = {desc='run the fastest', prereq={'speedier'}, func=function (p) p.speed = p.speed * 1.2 end},
    shooty = {desc='fire two bullets each shot', prereq={}, func=function (p) p.gun.stats.numBullets = p.gun.stats.numBullets + 1 end},
    shootier = {desc='fire three bullets each shot', prereq={'shooty'}, func=function (p) p.gun.stats.numBullets = p.gun.stats.numBullets + 1 end},
    shootiest = {desc='fire four bullets each shot', prereq={'shootier'}, func=function (p) p.gun.stats.numBullets = p.gun.stats.numBullets + 1 end},
    ['fire-ier'] = {desc='fire bullets faster', prereq={}, func=function (p) p.gun.stats.firerate = p.gun.stats.firerate + 8 end},
    ['fire-iest'] = {desc='fire bullets even faster', prereq={'fire-ier'}, func=function (p) p.gun.stats.firerate = p.gun.stats.firerate + 8 end},
    ['ammo-y'] = {desc='shoot more before reloading', prereq={}, func=function (p) p.gun.stats.clipSize = p.gun.stats.clipSize + 4 end},
    ['ammo-ier'] = {desc='shoot even more before reloading', prereq={'ammo-ier'}, func=function (p) p.gun.stats.clipSize = p.gun.stats.clipSize + 4 end},
    ['ammo-iest'] = {desc='shoot the most before reloading', prereq={'ammo-iest'}, func=function (p) p.gun.stats.clipSize = p.gun.stats.clipSize + 4 end},
    ['reload-ier'] = {desc='reload bullets faster', prereq={}, func=function (p) p.gun.stats.reloadTime = p.gun.stats.reloadTime / 2 end},
    ['reload-iest'] = {desc='reload bullets even faster', prereq={'reload-iest'}, func=function (p) p.gun.stats.reloadTime = p.gun.stats.reloadTime / 2 end},
    heartier = {desc='gain one max health', prereq={}, func=function (p) p.maxHealth = p.maxHealth + 1 end},
    heartiest = {desc='gain another max health', prereq={'heartier'}, func=function (p) p.maxHealth = p.maxHealth + 1 end},
    healthier = {desc='replenish one health', prereq={}, func=function (p) p.health = math.min(p.health + 1, p.maxHealth) end, repeating=true},
    picky = {desc='one more option when choosing upgrades', prereq={}, flag='picky'},
    explodier = {desc='enemies explode more often', prereq={}, flag='explodier'},
    explodiest = {desc='enemies explode even more often', prereq={'explodier'}, flag='explodiest'},
    shield = {desc='gain one temporary health', prereq={}, func=function (p) p.shield=true end},
    owie = {desc='shoot bullets when taking damage', prereq={}, flag='owie'},
    ouch = {desc='enemies shoot bullets when killed', prereq={}, flag='ouch'},
    feathery = {desc='take no damage when falling', prereq={}, func=function (p) p.noFall=true end},
    infinity = {desc='infinte bullets for one planet', prereq={'fire-ier'}, flag='infinity', repeating=true},
    many = {desc='fire five bullets each shot for one planet', prereq={'shootier'}, func=function (p) game.flags.many = p.gun.stats.numBullets p.gun.stats.numBullets =5 end, repeating=true},
	guarantee = {desc='every enemy explodes for one planet', prereq={'explodier'}, flag='guarantee', repeating=true}
}

local function setImages()
    local c
    local n ; local m
    local text
    for i, v in pairs(upgrades) do
        text = love.graphics.newText(fonts.mid)
        text2 = love.graphics.newText(fonts.small)
        text:addf(i, 128, 'center', 0, 0)
        text2:addf(v.desc, 100, 'center', 0, 0)
        c = love.graphics.newCanvas(128, text:getHeight() + text2:getHeight() + 40)
        love.graphics.setCanvas(c)
        love.graphics.draw(text)
        love.graphics.draw(text2, 14, 40)
        upgrades[i].img = c
        upgrades[i].name = i
    end
    love.graphics.setCanvas()
end

setImages()

Up = Object:extend()

function Up:new()
    if player.dead or player.health == 0 then
        game:die()
        return 
    end
    local options = self:getValid()
    self.options = {} ; local rn
    local num ; if game.flags.picky then num = 4 else num = 3 end
    for i = 1, num do 
        if player.health < player.maxHealth then
            rn = love.math.random(1, player.health + 2)
            if rn == 1 then
                for n = 1, #options do
                    if options[n] == 'healthier' then
                        rn = n
                    end
                end
            else
                rn = love.math.random(1, #options)
            end
        else
            rn = love.math.random(1, #options)
        end
        local w, h = upgrades.speedy.img:getWidth(), upgrades.speedy.img:getHeight()
        upgrades[options[rn]].pos = Vector(love.graphics.getWidth() / 4 - 130 - 65 * num + 130 * i, love.graphics.getHeight() / 4 - 50)
        table.insert(self.options, upgrades[options[rn]])
        table.remove(options, rn)
    end
    self.left = love.graphics.getWidth() / 4 - 130 - 65 * num + 130 - 20
    self.right = love.graphics.getWidth() / 4 - 130 - 65 * num + 130 * (num + 1) + 20
    self.top = love.graphics.getHeight() / 4 - 60
    self.h = 100
    self.choose = Choose(self.options)
end

function Up:getValid()
    local options = {}
    for i, v in pairs(upgrades) do
        if self:isValid(i, v) then
            table.insert(options, i)
        end
    end
    return options
end

function Up:isValid(i, v)
    if table.contains(player.upgrades, i) then return false end
    for _, p in ipairs(v.prereq) do
        if not table.contains(player.upgrades, p) then return false end
    end
    return true
end

function Up:update(dt)
    if player.input:pressed('pause') then game:pause() end
    self.choose:update()
    if player.input:pressed('shoot') then
        local chosen = self.choose:choose()
        if upgrades[chosen].func then upgrades[chosen].func(player) 
        elseif upgrades[chosen].flag then game.flags[upgrades[chosen].flag] = true end
        if not upgrades[chosen].repeating then table.insert(player.upgrades, chosen) end
        game:start()
    end
end

function Up:draw()
    love.graphics.push()
        love.graphics.scale(scale, scale)
        back:draw()
        love.graphics.pop()
    love.graphics.push()
        love.graphics.scale(2, 2)
        love.graphics.setColor(colours.blue)
        love.graphics.rectangle('fill', self.left, self.top, self.right - self.left, self.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
    self.choose:draw()
    love.graphics.scale(3, 3)
    game.health:draw(player.health, player.maxHealth, player.gun.bulletsLeft, player.gun.stats.clipSize)
end



return Up