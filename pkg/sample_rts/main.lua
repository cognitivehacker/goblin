package.path = package.path .. ";../?.lua"

local Unit = require("Unit")
local GameObject = require('GameObject')
local SelectGroup = require('SelectGroup')
local Game = require('Game')
local Box = require('Box')
local ColisionGroup = require('ColisionGroup')
local DistanceGroup = require('DistanceGroup')
local conf = require("gameconf")
local math = require("math")


local game
local unitColision
local unitAtakGroup
local selectArea

UNITS_COUNT = 9
MOOVING_SPEED = 20
UNIT_DIMENSIONS = 20
UNITS = {}


function Agroup(x, y)
  local LINE_SIZE = math.ceil(math.sqrt(#UNITS))

  local group_w = LINE_SIZE * UNIT_DIMENSIONS + (LINE_SIZE * 4)
  local start_x = x - group_w / 2

  local group_h = (#UNITS / LINE_SIZE) * #UNITS
  local start_y = y - group_h / 2

  local count_l = 0
  local count_r = 0

  for _, u in ipairs(UNITS) do
    local t = GameObject:new()
    count_l = count_l + 1
    t.x = start_x + count_l * UNIT_DIMENSIONS
    t.y = start_y + count_r * UNIT_DIMENSIONS
    u.target = t
    if count_l == LINE_SIZE then
      count_l = 0
      count_r = count_r + 1
    end
  end
end

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end

  love.window.setMode( conf._WINDOW_WIDTH * conf._WINDOW_SCALLING_X, conf._WINDOW_HEIGHT * conf._WINDOW_SCALLING_Y, {fullscreen=conf._WINDOW_FULLSCREEN})
  game = Game:new()
  unitColision = ColisionGroup:new()
  unitAtakGroup = DistanceGroup:new()

  selectArea =  SelectGroup:new()
  selectArea:setBox(Box:new())

  game:observe(selectArea)
  for i =1, UNITS_COUNT, 1 do
    local lx = math.random(1, conf._WINDOW_WIDTH)
    local ly = math.random(1, conf._WINDOW_HEIGHT)
    local box = Box:new{width=UNIT_DIMENSIONS, height=UNIT_DIMENSIONS, x=-10, y=-10}
    local u = Unit:new{x=lx, y=ly, speed_x=MOOVING_SPEED, speed_y=MOOVING_SPEED}
    UNITS[u] = 1
    u:setBox(box)
    game:observe(u)
    unitColision:setGameObject(u)
    unitAtakGroup:setGameObject(u)
  end
end

function love.update(dt)
  if not  conf._GAME_RUNING then
    return
  end

  UNITS = {}

  for _, u in ipairs(game.gameObjects) do
    u.selected = false
  end

  unitColision:colideSingle(selectArea, function(u, go)
    u.selected = true
    table.insert(UNITS, u)
  end)

unitAtakGroup:selfColide(function (u1, u2)
    print("coliding", u2.x, u2.y)
    u1:atack(u2)
end, 50)

  game:update(dt)
  game:animate(dt)

  game:runTimer(dt)
end

function love.draw()
  love.graphics.scale(conf._WINDOW_SCALLING_X, conf._WINDOW_SCALLING_Y)
  game:draw()
end


function love.mousepressed(x, y, button, istouch)
  if button == 1 then
    if not selectArea:isAlive() then
      selectArea.x = x
      selectArea.y = y
      selectArea.alive = true
    end
  end
end

function love.mousereleased(x, y, button, istouch)
  if button == 2 then
    Agroup(x, y)
  elseif button == 1 then
    selectArea.alive = false
  end
end