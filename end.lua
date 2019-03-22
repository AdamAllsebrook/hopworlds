local en = Object:extend()

function en:new()
    self.timer = .3
    local w, h = love.graphics.getWidth() / 2, love.graphics.getHeight() / 4
    local text
    if game.won then
        text = 'you escaped the hopworlds'
    else
        if not hi then hi = game.numPlanets end
        if game.numPlanets - 1 > hi then hi = game.numPlanets - 1 end
        text = 'you cleared ' .. tostring(game.numPlanets - 1) .. ' planet'
        if game.numPlanets ~= 2 then text = text .. 's' end
        text2 = 'your best is ' .. tostring(hi)
        self.hi = love.graphics.newText(fonts.mid) ; self.hi:addf(text2, w, 'center')
    end
    self.score = love.graphics.newText(fonts.mid) ; self.score:addf(text, w, 'center')
    local t0 = love.graphics.newText(fonts.mid) ; t0:add('endless')
    local t1 = love.graphics.newText(fonts.mid) ; t1:add('restart')
    local t2 = love.graphics.newText(fonts.mid) ; t2:add('menu')
    local offon = {'off', 'on'}
    local t3 = love.graphics.newText(fonts.small) ; t3:add('sound ' .. offon[love.audio.getVolume() + 1])
    local t4 = love.graphics.newText(fonts.small) ; t4:add('fullscreen')
    local t5 = love.graphics.newText(fonts.small) ; t5:add('music ' .. offon[music + 1])    
    if game.won then
        self.choose = Choose({
            {name='endless', img=t0, pos=Vector(w/2 - 150, h + 32)},
            {name='play', img=t1, pos=Vector(w/2 - 38, h + 32)},
            {name='menu', img=t2, pos=Vector(w/2 + 83, h + 32)},
            {name='full', img=t4, pos=Vector(w*2,h*4) / 2 - Vector(192, 32)},
            {name='music', img=t5, pos=Vector(w, h*2) - Vector(128, 32)},
            {name='sound', img=t3, pos=Vector(w, h*2) - Vector(64, 32)},
        })
    else
        self.choose = Choose({
            {name='play', img=t1, pos=Vector(w / 2 - 80, h + 32)},
            {name='menu', img=t2, pos=Vector(w / 2 + 28, h + 32)},
            {name='full', img=t4, pos=Vector(w,h*2) - Vector(192, 32)},
            {name='music', img=t5, pos=Vector(w, h*2) - Vector(128, 32)},
            {name='sound', img=t3, pos=Vector(w, h*2) - Vector(64, 32)},
        })
    end
end

function en:update(dt)
    if self.timer >= 0 then self.timer = self.timer - dt end
    if self.timer < 0 then
        self.choose:update(dt)
        if player.input:pressed('shoot') then
            local chosen = self.choose:choose()
            if chosen == 'play' then
                game = Game()
                game:start()
            elseif chosen == 'menu' then
                gamestate = 'menu'
                menu = Menu()
            elseif chosen == 'endless' then
                game.won = false
                game:start()
            elseif chosen == 'sound' then
                if love.audio.getVolume() == 1 then
                    love.audio.setVolume(0)
                    local t = love.graphics.newText(fonts.small) ; t:add('sound off')
                    self.choose.items[#self.choose.items].img = t
                elseif love.audio.getVolume() == 0 then
                    love.audio.setVolume(1)
                    local t = love.graphics.newText(fonts.small) ; t:add('sound on')
                    self.choose.items[#self.choose.items].img = t
                end
            elseif chosen == 'music' then
                if music == 1 then
                    loop:stop()
                    music = 0
                    local t = love.graphics.newText(fonts.small) ; t:add('music off')
                    self.choose.items[#self.choose.items - 1].img = t
                elseif music == 0 then
                    loop:play()
                    music = 1
                    local t = love.graphics.newText(fonts.small) ; t:add('music on')
                    self.choose.items[#self.choose.items - 1].img = t
                end
            elseif chosen == 'full' then
                love.window.setFullscreen(not love.window.getFullscreen())
                game.endScreen = en()
            end
        end
    end
end

function en:draw()
    love.graphics.push()
        love.graphics.scale(2, 2)
        love.graphics.draw(self.score, 0, love.graphics.getHeight() / 4 - 96)
        if self.hi then love.graphics.draw(self.hi, 0, love.graphics.getHeight() / 4 - 48) end
        love.graphics.pop()
    self.choose:draw()
end

return en