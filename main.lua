local Bullet = require('Bullet')
local GameObject = require('GameObject')

_WINDOW_FULLSCREEN = false
_WINDOW_WIDTH = 240
_WINDOW_HEIGHT = 320
_WINDOW_SCALLING_X = 3
_WINDOW_SCALLING_Y = 3

_GAME_SHIP_SPEED = 120
_GAME_CATRIDGE_SIZE = 3
_GAME_ENEMY_SLOT_SIZE = 50
_GAME_ENEMY_SPEED = 150
_GAME_BG_SPEED = 100
_GAME_RUNING = true

local goblin = {
    x=100,
    y=100,
    width=16,
    height=16,
    speed_y=0,
    speed_x=0,
    alive=true
}

local bg = {
    x=0,
    y=0
}

local bullets_active = {}
local enemys_active = {}
local bulletImg

local score = 0

function love.load()
    success = love.window.setMode( _WINDOW_WIDTH * _WINDOW_SCALLING_X, _WINDOW_HEIGHT * _WINDOW_SCALLING_Y, {fullscreen=_WINDOW_FULLSCREEN})
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    goblin.image = love.graphics.newImage('images/goblin.png')
    bulletImg = love.graphics.newImage('images/bullet.png')
    enemyImg = love.graphics.newImage('images/flyingalfa.png')
    bg.image = love.graphics.newImage('images/bg.png')
end

function love.update(dt)
    if not  _GAME_RUNING then
        return
    end

   goblin_move(dt)
   spawn()
   colide_bullet()
   colide_player()

   -- UPDATE BULLETS --
   for i, b in ipairs(bullets_active) do
        b.y = b.y + b.speed_y * dt
        if b.y <= 0 then
            table.remove(bullets_active, i)
        end
    end

    -- UPDATE ENEMYS --
    for i, e in ipairs(enemys_active) do
        e.y = e.y + e.speed_y * dt
        if e.y - e.height > _WINDOW_HEIGHT then
            table.remove(enemys_active, i)
        end

        e.animation.currentTime = e.animation.currentTime + dt
        if e.animation.currentTime >= e.animation.duration then
            e.animation.currentTime = e.animation.currentTime - e.animation.duration
        end
    end
    print(enemys_active[1].animation.currentTime)
    scroll(dt)
end
    
function love.draw()
    love.graphics.scale(_WINDOW_SCALLING_X, _WINDOW_SCALLING_Y)
    love.graphics.draw(bg.image, bg.x, bg.y-320)
    love.graphics.draw(bg.image, bg.x, bg.y)
    if goblin.alive then
        love.graphics.draw(goblin.image, goblin.x, goblin.y)
    end

    for i, b in ipairs(bullets_active) do
        love.graphics.draw(b.img, b.x, b.y)
    end

    for i, e in ipairs(enemys_active) do
        local spriteNum = math.floor(e.animation.currentTime / e.animation.duration * #e.animation.quads) + 1
        love.graphics.draw(e.animation.spriteSheet, e.animation.quads[spriteNum], e.x, e.y, 0)
    end
    
    love.graphics.setFont(love.graphics.newFont(7))
    love.graphics.print("SCORE: " .. score, 10, 10)
    if not _GAME_RUNING then
        love.graphics.print("GAME OVER", _WINDOW_WIDTH / 2 -20, _WINDOW_HEIGHT / 2)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'up' then
        goblin.speed_y = -1 * _GAME_SHIP_SPEED
    elseif key == 'down' then
        goblin.speed_y = 1 * _GAME_SHIP_SPEED
    elseif key == 'left' then
        goblin.speed_x = -1 * _GAME_SHIP_SPEED
    elseif key == 'right' then
        goblin.speed_x = 1 * _GAME_SHIP_SPEED
    end        
end

function love.keyreleased(key)
    if key == 'up' then
        goblin.speed_y = 0
    elseif key == 'down' then
        goblin.speed_y = 0
    elseif key == 'left' then
        goblin.speed_x = 0
    elseif key == 'right' then
        goblin.speed_x = 0
    elseif key == 'space' then
        shot()
    end        
end
function  scroll(dt)
    bg.y = bg.y + _GAME_BG_SPEED * dt
    if bg.y > _WINDOW_HEIGHT then
        bg.y = 0
    end
end
function shot()
    if #bullets_active < _GAME_CATRIDGE_SIZE then
        b = Bullet:new(bulletImg, goblin.x + goblin.width / 2, goblin.y, 0, -150)
        table.insert(bullets_active, b)
    end
end

function spawn()
    if #enemys_active < _GAME_ENEMY_SLOT_SIZE then
        local x = math.random(0, _WINDOW_WIDTH - 16)
        local y = math.random(- 1800, -16)
        b = GameObject:new(enemyImg, x, y, 0,  math.random(_GAME_ENEMY_SPEED-50, _GAME_ENEMY_SPEED+50), 16, 16)
        table.insert(enemys_active, b)
    end
end

function colide_bullet()
    for i, e in ipairs(enemys_active) do
        for j, b in ipairs(bullets_active) do
            if b.x >= e.x and b.x <= e.x + e.width 
            and b.y > e.y and b.y < e.y + e.height then
                -- ENEMY HIT --
                score = score + 10
                table.remove(bullets_active, j)
                table.remove(enemys_active, i)
            end
        end
    end
end

function colide_player()
    for i, e in ipairs(enemys_active) do
        if goblin.x + goblin.width >= e.x and goblin.x <= e.x + e.width 
        and goblin.y > e.y and goblin.y < e.y + e.height then
            -- PLAYER HIT --
            goblin.alive = false
            _GAME_RUNING = false
        end
    end
end

function goblin_move(dt)
    goblin.y = goblin.y + (goblin.speed_y * dt)
    goblin.x = goblin.x + (goblin.speed_x * dt)
    
    if goblin.x + goblin.width >= _WINDOW_WIDTH then
        goblin.x = _WINDOW_WIDTH - goblin.width
    end

    if goblin.x < 0 then
        goblin.x = 0
    end

    if goblin.y < 0 then
        goblin.y = 0
    end

    if goblin.y + goblin.height >= _WINDOW_HEIGHT then
        goblin.y = _WINDOW_HEIGHT - goblin.height
    end
end