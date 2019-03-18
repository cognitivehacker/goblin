local Bullet = require('Bullet')
local GameObject = require('GameObject')
local Animation = require('Animation')
local spritemap = require('spritemap')
local Game = require('Game')
local Box = require('Box')
local Goblin = require('Goblin')
local Enemy = require('Enemy')
local conf = require("gameconf")

local goblin

local bg = {
  x=0,
  y=0
}

local bullets_active = {}
local enemys_active = {}
local bulletImg
local xplosion
local world
local score = 0
local lifes = 5
local game

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  success = love.window.setMode( conf._WINDOW_WIDTH * conf._WINDOW_SCALLING_X, conf._WINDOW_HEIGHT * conf._WINDOW_SCALLING_Y, {fullscreen=conf._WINDOW_FULLSCREEN})
  love.graphics.setDefaultFilter("nearest", "nearest")
  goblinImage = love.graphics.newImage('images/sailfish.png')
  bulletImg = love.graphics.newImage('images/bullet.png')
  enemyImg = love.graphics.newImage('images/flyingalfa.png')
  bg.image = love.graphics.newImage('images/bg.png')
  lifeIcon = love.graphics.newImage("images/lifeicon.png")
  xplosion = love.graphics.newImage("images/xplosion.png")

  game = Game:new()

  goblin = Goblin:new {img=goblinImage, x=100, y=200, speed_x=0, speed_y=0, width=22, height=29, animation=0.2}
  goblin.animation = Animation:new(goblinImage, spritemap.goblin_stay.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
  goblin.alive = true
  goblin:setBox(Box:new({x=0,y=0, width=22,height=29}))
  game:addTimer(spawn, 0.3)
  game:observe(goblin)
end

function love.update(dt)
  if not  conf._GAME_RUNING then
    return
  end

  colide_bullet()
  colide_player()
  game:update(dt)
  game:animate(dt)
  game:runTimer(dt)

  scroll(dt)
end

function love.draw()
  love.graphics.scale(conf._WINDOW_SCALLING_X, conf._WINDOW_SCALLING_Y)
  love.graphics.draw(bg.image, bg.x, bg.y-320)
  love.graphics.draw(bg.image, bg.x, bg.y)

  game:draw()

  love.graphics.setFont(love.graphics.newFont(7))
  love.graphics.print("SCORE: " .. score, 10, 10)
  if not conf._GAME_RUNING then
    love.graphics.setFont(love.graphics.newFont(17))
    love.graphics.print("GAME OVER", conf._WINDOW_WIDTH / 2 -55, conf._WINDOW_HEIGHT / 2)
  end

  for l = 1, lifes do
    love.graphics.draw(lifeIcon, 100 + 9 * l, 10)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if not conf._GAME_CONTROLLS then
    return
  end

  if key == 'up' then
    goblin.speed_y = -1 * conf._GAME_SHIP_SPEED
  elseif key == 'down' then
    goblin.speed_y = 1 * conf._GAME_SHIP_SPEED
  elseif key == 'left' then
    goblin.animation = Animation:new(goblinImage, spritemap.goblin_turn_left.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
    goblin.speed_x = -1 * conf._GAME_SHIP_SPEED
  elseif key == 'right' then
    goblin.animation = Animation:new(goblinImage, spritemap.goblin_turn_right.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
    goblin.speed_x = 1 * conf._GAME_SHIP_SPEED
  elseif key == "return" then
    restart()
  elseif key == 'space' then
    if conf._GAME_CONTROLLS then
      shot()
    end
  end     
end

function love.keyreleased(key)
  if not conf._GAME_CONTROLLS then
    return
  end

  if key == 'up' then
    goblin.speed_y = 0
  elseif key == 'down' then
    goblin.speed_y = 0
  elseif key == 'left' then
    goblin.animation = Animation:new(goblinImage, spritemap.goblin_back.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
    goblin.speed_x = 0
  elseif key == 'right' then
    goblin.animation = Animation:new(goblinImage, spritemap.goblin_back_right.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
    goblin.speed_x = 0
  end        
end

function  scroll(dt)
  bg.y = bg.y + conf._GAME_BG_SPEED * dt
  if bg.y > conf._WINDOW_HEIGHT then
    bg.y = 0
  end
end

function shot()
  if #bullets_active < conf._GAME_CATRIDGE_SIZE then
    b = Bullet:new{img=bulletImg, x=goblin.x + goblin.width / 2 -1, y=goblin.y + 5, speed_y=conf._GAME_BULLET_SPEED}
    game:observe(b)
  end
end

-- this must be mooved to a timer architecture
function spawn(g)
  local x = math.random(0, conf._WINDOW_WIDTH - 16)
  local y = math.random(- 50, -16)
  b = Enemy:new{img=enemyImg, x=x, y=y, speed_x=0, speed_y=110, width=16, heigth=16, duration=0.5}
  b.animation = Animation:new(enemyImg, spritemap.flyingalpha.quads, 0.5, true)
  b:setBox(Box:new{width=16,height=16})
  table.insert(enemys_active, b)
  g:observe(b)
end

-- this must be moved to a colision detection system
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

-- this must be moved to a colision detection system
function colide_player()
  for i, e in ipairs(enemys_active) do
    if goblin:collide(e) then
      -- PLAYER HIT --
      conf._GAME_CONTROLLS = false
      goblin.animation = Animation:new(xplosion, spritemap.xplosion.quads, 1, false, function(a) 
          goblin.animation = Animation:new(goblinImage, spritemap.goblin_back.quads, conf._GAME_GOBLIN_ANIMATION_SPEED, false)
          conf._GAME_CONTROLLS = true
          goblin.invincible = false
        end)
      goblin.speed_x = 0
      goblin.speed_y = 0
      goblin.invincible = true
      lifes = lifes -1
      table.remove(enemys_active, i)
      e.dead = true
      if lifes <= 0 then
        goblin.alive = false
        conf._GAME_RUNING = false
        conf._GAME_CONTROLLS = true
      end
    end
  end
end

function restart()
  if not conf._GAME_RUNING then
    goblin.alive = true
    goblin.x = 100
    goblin.y = 200
    conf._GAME_RUNING = true
    enemys_active = {}
    bullets_active = {}
    score = 0
    lifes = 5
  end
end