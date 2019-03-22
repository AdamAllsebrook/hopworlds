local p = Object:extend()

function p:new(last)
    local w, h = love.graphics.getWidth() / 2, love.graphics.getHeight() / 4
    self.last = last
    local t1 = love.graphics.newText(fonts.mid) ; t1:add('resume')
    local t2 = love.graphics.newText(fonts.mid) ; t2:add('menu')
    local offon = {'off', 'on'}
    local t3 = love.graphics.newText(fonts.small) ; t3:add('sound ' .. offon[love.audio.getVolume() + 1])
    local t5 = love.graphics.newText(fonts.small) ; t5:add('music ' .. offon[music + 1])    
    self.choose = Choose({
        {name='play', img=t1, pos=Vector(w / 2 - 80, h - 16)},
        {name='menu', img=t2, pos=Vector(w / 2 + 28, h - 16)},
        {name='music', img=t5, pos=Vector(w, h*2) - Vector(128, 32)},
        {name='sound', img=t3, pos=Vector(w, h*2) - Vector(64, 32)},
    })
end

function p:update(dt)
    self.choose:update(dt)
    if player.input:released('shoot') then
        local chosen = self.choose:choose()
        if chosen == 'play' then
            gamestate = self.last
        elseif chosen == 'menu' then 
            gamestate = 'menu'
            menu = Menu()
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
        end
    end
end

function p:draw()
    self.choose:draw()
end

return p