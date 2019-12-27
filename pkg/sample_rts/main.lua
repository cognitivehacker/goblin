package.path = package.path .. ";../?.lua"

local Unit = require("Unit")
local GameObject = require('GameObject')
local SelectGroup = require('SelectGroup')
local Game = require('Game')
local Box = require('Box')
local collision = require('Collision')
local helper = require('Helper')
local conf = require("gameconf")
local math = require("math")


local game
local selectArea

UNITS_COUNT = 10
MOOVING_SPEED = 20
UNIT_DIMENSIONS = 20
UNITS = {}
TEAM_BLUE = {}
TEAM_RED = {}
SELECTED_UNITS = {}
UNOVERLAP_SPEED = 0.3

function Agroup(x, y, units)
  local LINE_SIZE = math.ceil(math.sqrt(#units))

  local group_w = LINE_SIZE * UNIT_DIMENSIONS + (LINE_SIZE * 4)
  local start_x = x - group_w / 2

  local group_h = (#units / LINE_SIZE) * #units
  local start_y = y - group_h / 2

  local count_l = 0
  local count_r = 0

  -- table.sort(units, function (u1, u2)
  --   local distance1 = helper.Euclid(u1, {x=x, y=y})
  --   local distance2 = helper.Euclid(u2, {x=x, y=y})
  --   return distance1 > distance2
  -- end)

  for _, u in ipairs(units) do
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

function RemoveDead(u)
  return u:isDead()
end

function DetectColisionSideX(r1, r2)
  local ra1 = (r1.x + r1.width) / 2
  local ra2 = (r2.x + r2.width) / 2
  if ra1 < ra2 then
      return "right"
  end

  return "left"
end

function DetectColisionSideY(r1, r2)
  local ra1 = (r1.y + r1.height) / 2
  local ra2 = (r2.y + r2.height) / 2

  if ra1 < ra2 then
      return "up"
  end

  return "bottom"
end

function ColideUnoverlapX(u1, u2)
  local r1side = DetectColisionSideX(u1, u2)

  if r1side == "left" then
      u1.x = u1.x + math.random(0, UNOVERLAP_SPEED)
      u2.x = u2.x - math.random(0, UNOVERLAP_SPEED)
      return
  end

  u1.x = u1.x - math.random(0, UNOVERLAP_SPEED)
  u2.x = u2.x + math.random(0, UNOVERLAP_SPEED)
end

function ColideUnoverlapY(u1, u2)
  local r1side = DetectColisionSideY(u1, u2)

  if r1side == "up" then
      u1.y = u1.y - math.random(0, UNOVERLAP_SPEED)
      u2.y = u2.y + math.random(0, UNOVERLAP_SPEED)
      return
  end

  u1.y = u1.y + math.random(0, UNOVERLAP_SPEED)
  u2.y = u2.y - math.random(0, UNOVERLAP_SPEED)
end

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end

  love.window.setMode( conf._WINDOW_WIDTH * conf._WINDOW_SCALLING_X, conf._WINDOW_HEIGHT * conf._WINDOW_SCALLING_Y, {fullscreen=conf._WINDOW_FULLSCREEN})
  game = Game:new()

  selectArea = SelectGroup:new()
  selectArea:setBox(Box:new())

  game:observe(selectArea)
  for i=1, UNITS_COUNT do
    local box = Box:new{width=UNIT_DIMENSIONS, height=UNIT_DIMENSIONS, x=-10, y=-10}
    local u = Unit:new{speed_x=MOOVING_SPEED, speed_y=MOOVING_SPEED, id=i}
    table.insert(UNITS, u)
    u:setBox(box)
    game:observe(u)

    if i % 2 == 0 then 
      table.insert(TEAM_BLUE, u)
      u.tag = "blue"
      u.x = math.random(1, conf._WINDOW_WIDTH / 2 - 35 )
      u.y = math.random(1, conf._WINDOW_HEIGHT)
    else
      table.insert(TEAM_RED, u)
      u.tag = "red"
      u.x = math.random(conf._WINDOW_WIDTH / 2 + 35, conf._WINDOW_WIDTH )
      u.y = math.random(conf._WINDOW_HEIGHT)
    end
  end
end

function love.update(dt)
  TEAM_RED = helper.ArrFilter(TEAM_RED, RemoveDead)
  TEAM_BLUE = helper.ArrFilter(TEAM_BLUE, RemoveDead)
  UNITS = helper.ArrFilter(UNITS, RemoveDead)
  UNITS = helper.ArrMap(UNITS, function(u)
    u.atackTarget = nil
    return u
  end)

  if not  conf._GAME_RUNING then
    return
  end

  SELECTED_UNITS = {}

  -- Select
  collision.ColideSingle(UNITS,  selectArea, function(u, go)
    u.selected = true
    table.insert(SELECTED_UNITS, u)
  end)

  --Unoverlap
  collision.SelfColide(UNITS, function(u1, u2)
    ColideUnoverlapX(u1, u2)
    ColideUnoverlapY(u1, u2)
  end)
  print("Selected: ", #SELECTED_UNITS)
  --Atack
  collision.ColideWithB(TEAM_BLUE, TEAM_RED, function(u1, u2)
      u1.atackTarget = u2
      u2.atackTarget = u1
      print("Coliding atack: ", u1.id, u2.id)
  end, function(u1, u2)
    return collision.Euclidian(u1, u2, 70)
  end)

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
    Agroup(x, y, SELECTED_UNITS)
  elseif button == 1 then
    UNITS = helper.ArrMap(UNITS, function(u)
      u.selected = false
      return u
    end)
    selectArea.alive = false
  end
end