local conf = require("gameconf")
local Star = require("Star")
local Unit = require("Unit")
local Box = require("Box")
local rand = require("math").random
local mr = require("Helper").MicroRand
local collision = require("Collision")
local helper = require("Helper")
local rtshelper = {}

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

function rtshelper.StarField(game, density)
  density = density or 50
  local width = conf._WINDOW_WIDTH
  local height = conf._WINDOW_HEIGHT
  
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

return rtshelper