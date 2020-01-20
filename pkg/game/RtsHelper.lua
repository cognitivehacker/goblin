local mr = require("pkg.Helper").MicroRand
local Box = require("pkg.Box")
local GameObject = require("pkg.GameObject")
local helper = require("pkg.Helper")
local collision = require("pkg.Collision")
local conf = require("pkg.game.gameconf")
local Star = require("pkg.game.Star")
local Unit = require("pkg.game.Unit")
local rand = require("math").random
local rtshelper = {}

CAM_SPEED = 40

function rtshelper.SelectUnits(units, selectArea)
  helper.ArrMap(units, function(u)
    u.selected = false
    return u
  end)

  collision.ColideSingle(units,  selectArea, function(u, go)
    u.selected = true
    table.insert(SELECTED_UNITS, u)
  end)
  selectArea.alive = false
end

function rtshelper.RemoveDead(u)
  return u:isDead()
end

function rtshelper.randomUnits(units_count)
  local team_blue = {}
  local team_red = {}
  local units = {}
  for i=1, units_count do
    local box = Box:new{width=UNIT_DIMENSIONS, height=UNIT_DIMENSIONS, x=-10, y=-10}
    local u = Unit:new{speed_x=MOOVING_SPEED, speed_y=MOOVING_SPEED, id=i}
    table.insert(units, u)
    u:setBox(box)

    if i % 2 == 0 then
      table.insert(team_blue, u)
      u.tag = "blue"
      u.x = math.random(1, conf._WINDOW_WIDTH / 2 - 35 )
      u.y = math.random(1, conf._WINDOW_HEIGHT)
    else
      table.insert(team_red, u)
      u.tag = "red"
      u.x = math.random(conf._WINDOW_WIDTH / 2 + 35, conf._WINDOW_WIDTH )
      u.y = math.random(conf._WINDOW_HEIGHT)
    end
  end
  return units, team_red, team_blue
end

function rtshelper.movecam(key, cam)
  if key == "w"then
    cam:up(CAM_SPEED)
  elseif key == "a" then
    cam:left(CAM_SPEED)
  elseif key == "s" then
    cam:down(CAM_SPEED)
  elseif key == "d" then
    cam:right(CAM_SPEED)
  end
end

function rtshelper.StarField(game, density, width, height)
  density = density or 50

  for i=0, density do
    game:observe(Star:new{
      x=rand(0,width),
      y=rand(0,height),
      acc_min=mr(0, 50),
      acc_max=mr(0, 90),
      acc=mr(0, 100),
      acc_speed=mr(20, 30, 3),
      r=mr(80, 90),
      g=mr(50, 70),
      b=mr(50, 80),
    })
  end
end

function rtshelper.Agroup(x, y, units)
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

function rtshelper.DetectColisionSideX(r1, r2)
  local ra1 = (r1.x + r1.width) / 2
  local ra2 = (r2.x + r2.width) / 2
  if ra1 < ra2 then
      return "right"
  end

  return "left"
end

function rtshelper.DetectColisionSideY(r1, r2)
  local ra1 = (r1.y + r1.height) / 2
  local ra2 = (r2.y + r2.height) / 2

  if ra1 < ra2 then
      return "up"
  end

  return "bottom"
end

function rtshelper.ColideUnoverlapX(u1, u2)
  local r1side = rtshelper.DetectColisionSideX(u1, u2)

  if r1side == "left" then
      u1.x = u1.x + math.random(0, UNOVERLAP_SPEED)
      u2.x = u2.x - math.random(0, UNOVERLAP_SPEED)
      return
  end

  u1.x = u1.x - math.random(0, UNOVERLAP_SPEED)
  u2.x = u2.x + math.random(0, UNOVERLAP_SPEED)
end

function rtshelper.ColideUnoverlapY(u1, u2)
  local r1side = rtshelper.DetectColisionSideY(u1, u2)

  if r1side == "up" then
      u1.y = u1.y - math.random(0, UNOVERLAP_SPEED)
      u2.y = u2.y + math.random(0, UNOVERLAP_SPEED)
      return
  end

  u1.y = u1.y + math.random(0, UNOVERLAP_SPEED)
  u2.y = u2.y - math.random(0, UNOVERLAP_SPEED)
end

return rtshelper