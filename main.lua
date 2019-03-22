HC = require('m.HC')
Vector = require('m.hump.vector')
baton = require('m.baton')
Object = require('m.classic')
fsm = require('m.statemachine')
tween = require('m.tween')

require('util')

function love.load()
    gamename = 'hopworlds'
    love.window.setMode(1024, 640, {resizable=true, centered=true})
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setBackgroundColor(Clr('182141'))
    love.window.setTitle(gamename)

    cursorimg = love.graphics.newImage('gfx/cursor.png')
    local c = love.graphics.newCanvas(cursorimg:getDimensions())
    love.graphics.setCanvas(c)
    love.graphics.draw(cursorimg)
    love.graphics.setCanvas()
    cursorimg = c:newImageData()
    cursor = love.mouse.newCursor(cursorimg, (Vector(c:getDimensions()) / 2):unpack())
    love.mouse.setCursor(cursor)

    Anim = require('anim')
    Spritesheet = require('spritesheet')
    Gun = require('gun')
    Projectile = require('projectile')  
    HealthBar = require('healthBar')
    char = require('character')
    Planet = require('planet')
    Explosion = require('explosion')

    Transition = require('transition')
    Game = require('game')
    Choose = require('choose')
    Pause = require('pause')
    Menu = require('menu')
    End = require('end')
    Back = require('back')

    colours = {
        grey=Clr('5A6988'),
        blue = Clr('182141')
    }

    hi = love.filesystem.read('data.txt')
    if hi == 'nil' then hi = 0 else hi = tonumber(hi) end
    if not hi then hi = 0 end

    fonts = {
        small = love.graphics.newFont('gfx/m5x7.ttf', 16),
        mid = love.graphics.newFont('gfx/m5x7.ttf', 32),
        big = love.graphics.newFont('gfx/m5x7.ttf', 64),
        huge = love.graphics.newFont('gfx/m5x7.ttf', 128),
    }
    love.graphics.setFont(fonts.small)

    Upgrade = require('upgrades')

    --back = love.graphics.newImage('gfx/back.png')

    whiteShader = love.graphics.newShader[[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
          vec4 pixel = Texel(texture, texture_coords);
          if (pixel.a != 0.0){
              return vec4(1, 1, 1, 1);
          }
          return pixel * color;
        }
      ]]
      --[[
    shader = love.graphics.newShader[[
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords);
        vec4 mult = vec4(255, 255, 255, 255);
        return pixel * color * mult;
    }
    ]]
    --]]
    --if love.system.getOS() ~= 'Android' then shader = nil end

    scale = 4
    ts = 8
    tiles = Spritesheet(love.graphics.newImage('gfx/tiles.png'), 8, 8)
    transition = Transition()

    player = char.input
    
    --love.audio.setVolume(0)
    loop = love.audio.newSource('sfx/loop2.wav', 'static')
    loop:setVolume(.4)
    loop:setLooping(true)
    loop:play()
    music = 1

    menu = Menu()
    gamestate = 'menu'
end

function love.resize()
    if gamestate == 'menu' then menu = Menu() 
    elseif gamestate == 'end' then game.endScreen = End()
    end
end

function love.mousemoved()
    player.input._activeDevice = 'kbm'
end

function love.update(dt)
    love.mouse.setVisible(player.input:getActiveDevice() ~= 'joy') 
    if gamestate == 'playing' then
        game:update(dt)
    elseif gamestate == 'transition' then
        transition:update(dt) 
    elseif gamestate == 'upgrading' then
        game.up:update(dt)
    elseif gamestate == 'paused' then
        game.pauseMenu:update(dt) 
    elseif gamestate == 'menu' then
        menu:update(dt) 
    elseif gamestate == 'end' then
        game.endScreen:update(dt) 
    end
end

function love.draw()
    love.graphics.setShader(shader)
    if gamestate == 'playing' then
        game:draw()
    elseif gamestate == 'transition' then
        transition:draw() 
    elseif gamestate == 'upgrading' then
        game.up:draw()
    elseif gamestate == 'paused' then
        game.pauseMenu:draw() 
    elseif gamestate == 'menu' then
        menu:draw() 
    elseif gamestate == 'end' then
        game.endScreen:draw() 
    end
    love.graphics.setShader()
end

function love.quit()
    love.filesystem.write('data.txt', tostring(hi))
end