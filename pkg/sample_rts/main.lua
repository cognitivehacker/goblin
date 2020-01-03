package.path = package.path .. ";../?.lua"

local Unit = require("Unit")
local GameObject = require('GameObject')
local SelectGroup = require('SelectGroup')
local Game = require('Game')
local Box = require('Box')
local collision = require('Collision')
local helper = require('Helper')
local gamehelper = require("RtsHelper")
local conf = require("gameconf")
local math = require("math")


local game
local selectArea

UNITS_COUNT = 20
MOOVING_SPEED = 4
UNIT_DIMENSIONS = 20
UNITS = {}
TEAM_BLUE = {}
TEAM_RED = {}
SELECTED_UNITS = {}
UNOVERLAP_SPEED = 0.2
EFFECT = nil
function Agroup(x, y, units)
  local LINE_SIZE = math.ceil(math.sqrt(#units))

  local group_w = LINE_SIZE * UNIT_DIMENSIONS + (LINE_SIZE * 4)
  local start_x = x - group_w / 2

  local group_h = (#units / LINE_SIZE) * #units
  local start_y = y - group_h / 2

  local count_l = 0
  local count_r = 0

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
  gamehelper.StarField(game, 700)

  selectArea = SelectGroup:new()
  selectArea:setBox(Box:new())
  UNITS, TEAM_RED, TEAM_BLUE = gamehelper.randomUnits(UNITS_COUNT)

  game:observe(selectArea)
  game:observeMany(UNITS)
end

function love.update(dt)
  TEAM_RED = helper.ArrFilter(TEAM_RED, RemoveDead)
  TEAM_BLUE = helper.ArrFilter(TEAM_BLUE, RemoveDead)
  UNITS = helper.ArrFilter(UNITS, RemoveDead)
  SELECTED_UNITS = helper.ArrFilter(SELECTED_UNITS, RemoveDead)
  helper.ArrMap(UNITS, function(u)
    u.atackTarget = nil
    return u
  end)

  --Unoverlap
  collision.SelfColide(UNITS, function(u1, u2)
    ColideUnoverlapX(u1, u2)
    ColideUnoverlapY(u1, u2)
  end)

  --Atack
  collision.ColideWithB(TEAM_BLUE, TEAM_RED, function(u1, u2)
      u1.atackTarget = u2
      u2.atackTarget = u1
  end, function(u1, u2)
    return collision.Euclidian(u1, u2, 100)
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
    SELECTED_UNITS = {}
    -- gamehelper.SelectUnits(TEAM_BLUE, selectArea)
    gamehelper.SelectUnits(UNITS, selectArea)
  end
end