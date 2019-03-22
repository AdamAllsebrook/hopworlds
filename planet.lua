p = Object:extend()

p.types = {'grass', 'sand', 'snow', 'dirt', 'fire'}
p.enemies = {
    grass = {'orc'},
    sand =  {'cac'},
    snow =  {'pen'},
    dirt =  {'gol'},
    fire =  {'dev'},
}
p.size = Vector(80, 80)

function p:new()
    if game.numPlanets >= game.bossPlanet and game.numPlanets <= game.bossPlanet + 2 then
        self.type = 6
    else
        self.type = love.math.random(1, math.min(#self.types, math.ceil(game.numPlanets / 2)))
        while math.ceil(game.numPlanets / 2) > 1 and self.type == game.lastPlanet do
            self.type = love.math.random(1, math.min(#self.types, math.ceil(game.numPlanets / 2)))
        end
    end
    self.tiles = {}
    self.images = {}
    for i = 0, 5 do table.insert(self.images, tiles:getImage(i, self.type - 1)) end
    local map = self:generate()
    for x = 1, self.size.x do
        self.tiles[x] = {}
        for y = 1, self.size.y do
        if map[x][y] then self.tiles[x][y] = {rect=world:rectangle(x * ts, y * ts, ts, ts, {'floor'}), img=love.math.random(1, #self.images)} end
        end
    end
    if self.type == 6 then
        local e = char.Enemy(self:getRandomPos() * ts, 'boss')
        objects[e] = e
        game.numEnemies = 1
    else
        game.numEnemies = 0
        for i = 1, math.ceil(math.sqrt((game.numPlanets + 1) * 5/6)) do
            if not (i == 1 and self.type == 4) then
                local e = char.Enemy(self:getRandomPos() * ts, self.enemies[self.types[self.type]][love.math.random(1, #self.enemies[self.types[self.type]])])
                objects[e] = e
                game.numEnemies = game.numEnemies + 1
            end
        end
    end
    game.numPlanets = game.numPlanets + 1
    game.lastPlanet = self.type
end

function p:generate()
    love.graphics.origin()
    local c = love.graphics.newCanvas(self.size.x, self.size.y)
    love.graphics.setCanvas(c)
    local r = love.math.random(5, 11) ; local angle
    local pos = Vector(love.math.random(self.size.x / 2 - 3, self.size.x / 2 + 3), love.math.random(self.size.y / 2 - 2, self.size.y / 2 + 2))
    local i
    love.graphics.circle('fill', pos.x, pos.y, r)
    local circs = {{pos=pos, r=r}}
    for i = 1, 7 + math.ceil(math.pow(math.max(0, game.numPlanets - game.bossPlanet), 1/3)) do
        r = love.math.random(1 + i, 11)
        angle = love.math.random(0, 2*math.pi)
        i = love.math.random(#circs)
        pos = Vector(circs[i].pos.x + math.cos(angle) * circs[i].r, circs[i].pos.y + math.sin(angle) * circs[i].r)
        love.graphics.circle('fill', pos.x, pos.y, r)
        table.insert(circs, {pos=pos, r=r})
    end
    love.graphics.setCanvas()
    local data = c:newImageData()
    local map = {}
    local a
    for x = 1, self.size.x do
        map[x] = {}
        for y = 1, self.size.y do
            _, _, _, a = data:getPixel(x - 1, y - 1)
            if a ~= 0 then map[x][y] = true end
        end
    end
    return map
end

function p:getRandomPos()
    local x = 0 ; local y = 0 ; local r = 4
    while (not self.tiles[x] or not self.tiles[x][y]) and not (self.size.x / 2 - r <= x and x <= self.size.x / 2 + r and self.size.y / 2 - r <= y and y <= self.size.y / 2 + r) do
        x = love.math.random(1, self.size.x)
        y = love.math.random(1, self.size.y)
        if self.tiles[x] and not self.tiles[x][y + 1] then y = -1 end
    end
    return Vector(x, y)
end

function p:update(dt)
end

function p:draw()
    for x = 1, self.size.x do
        for y = 1, self.size.y do
            if self.tiles[x][y] then
                love.graphics.draw(tiles.image, self.images[self.tiles[x][y].img], x * ts, y * ts)
                if not self.tiles[x][y+1] then
                    love.graphics.draw(tiles.image, tiles:getImage(6, self.type - 1), x * ts, y * ts + ts)
                end
            end
        end
    end
end

return p