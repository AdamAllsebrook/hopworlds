local m = Object:extend()

function m:new()
    local w, h = love.graphics.getWidth() / 2, love.graphics.getHeight() / 4
    self.title = love.graphics.newText(fonts.big) ; self.title:addf(gamename, w, 'center')
    local t1 = love.graphics.newText(fonts.mid) ; t1:add('play')
    local t2 = love.graphics.newText(fonts.mid) ; t2:add('quit')
    local offon = {'off', 'on'}
    local t3 = love.graphics.newText(fonts.small) ; t3:add('sound ' .. offon[love.audio.getVolume() + 1])
    local t5 = love.graphics.newText(fonts.small) ; t5:add('music ' .. offon[music + 1])
    local t4 = love.graphics.newText(fonts.small) ; t4:add('fullscreen')
    self.choose = Choose({
        {name='play', img=t1, pos=Vector(w / 2 - 60, h + 50)},
        {name='quit', img=t2, pos=Vector(w / 2 + 20, h + 50)},
        {name='full', img=t4, pos=Vector(w*2,0) / 2 - Vector(192, -8)},
        {name='music', img=t5, pos=Vector(w*2,0) / 2 - Vector(128, -8)},
        {name='sound', img=t3, pos=Vector(w*2,0) / 2 - Vector(64, -8)},
    })
    self.prompt = love.graphics.newText(fonts.small)
    self.prompt:addf('right shoulder / left mouse', w, 'center')

end

function m:update(dt)
    self.choose:update(dt)
    if player.input:pressed('shoot') then
        local chosen = self.choose:choose()
        if chosen == 'play' then
            game = Game()
            game:start()
        elseif chosen == 'quit' then
            love.event.quit()
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
            menu = Menu()
        end
    end
end

function m:draw()
    love.graphics.push()
        love.graphics.scale(2, 2)
        love.graphics.draw(self.title, 0, love.graphics.getHeight() / 4 - 100)
        love.graphics.setColor(colours.grey)
        love.graphics.draw(self.prompt, 0, love.graphics.getHeight() / 2 - 32)
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
    self.choose:draw()
end

return m