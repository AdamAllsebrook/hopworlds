local c = Object:extend()

--items: {{pos=Vector(), img=newImage()}}

function c:new(items)
    self.items = items
    self.on = 1
    self.pad = 8
end

function c:update(dt)
    player.input:update()
    if player.input:pressed('movel') then
        self:left()
    end
    if player.input:pressed('mover') then
        self:right()
    end
end

function c:left()
    if self.on == 1 then self.on = #self.items
    else self.on = self.on - 1 end
end

function c:right()
    if self.on == #self.items then self.on = 1
    else self.on = self.on + 1 end
end

function c:choose()
    return self.items[self.on].name
end

function c:draw()
    love.graphics.push()
    love.graphics.scale(2, 2)
    local x, y = love.mouse.getPosition()
    x = x / 2 ; y = y / 2
    for i, item in ipairs(self.items) do
        if player.input:getActiveDevice() ~= 'joy' then
            local w, h = item.img:getDimensions()
            if item.pos.x - self.pad <= x and x <= item.pos.x + w + self.pad and item.pos.y - self.pad <= y and y <= item.pos.y + h + self.pad then
                self.on = i
            end
            --love.graphics.rectangle('line', item.pos. x - self.pad, item.pos.y - self.pad, w + self.pad * 2, h + self.pad * 2)
        end
        if i ~= self.on then
            love.graphics.setColor(colours.grey)
            love.graphics.draw(item.img, item.pos.x, item.pos.y)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.draw(item.img, item.pos.x, item.pos.y)
        end
        --love.graphics.rectangle('line', item.pos.x, item.pos.y, item.img:getDimensions())
    end
    love.graphics.pop()
end

return c