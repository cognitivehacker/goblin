
local GameObject = require('pkg.GameObject')
local Game = require('pkg.Game')
local Box = require('pkg.Box')
local collision = require('pkg.Collision')
local helper = require('pkg.Helper')
local SelectGroup = require('pkg.game.SelectGroup')
local gamehelper = require("pkg.game.RtsHelper")
local conf = require("pkg.game.gameconf")
local DominationPoint = require("pkg.game.DominationPoint")
local math = require("math")


local game
local selectArea

UNITS_COUNT = 18
MOOVING_SPEED = 4
UNIT_DIMENSIONS = 20
UNITS = {}
TEAM_BLUE = {}
TEAM_RED = {}
SELECTED_UNITS = {}
UNOVERLAP_SPEED = 0.2
DOM_POINTS = {}
TEAM_BLUE_CACHE = 0
shader = nil

love.graphics.clear = function() end

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

  -- Simple 3x3 box blur
  local shader_code = [[
  struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
  };

  extern Light lights[32];
  extern int num_lights;
  extern vec2 screen;

  const float constant = 1.0;
  const float linear = 0.09;
  const float quadratic = 0.032;  

  vec4 effect(vec4 color, Image image, vec2 uv, vec2 screen_coords) {
    vec4 pixel = Texel(image, uv);

    vec2 norm_screen = screen_coords / screen;
    vec3 diffuse = vec3(0);

    for (int i = 0 ; i < num_lights; i++ ) {
      Light light = lights[i];
      vec2 norm_pos = light.position / screen;

      float distance = length(norm_pos - norm_screen) * light.power;
      float attenuation = 1.0 / ( constant + linear * distance + quadratic * (distance * distance) );

      diffuse += light.diffuse * attenuation;  
    }
    diffuse = clamp(diffuse, 0.0, 1.0);
    return pixel * vec4(diffuse, 1.0);
  }
]]

  shader = love.graphics.newShader(shader_code)

  love.window.setMode( conf._WINDOW_WIDTH * conf._WINDOW_SCALLING_X, conf._WINDOW_HEIGHT * conf._WINDOW_SCALLING_Y, {fullscreen=conf._WINDOW_FULLSCREEN})
  game = Game:new()
  gamehelper.StarField(game, 700)

  selectArea = SelectGroup:new()
  selectArea:setBox(Box:new())
  UNITS, TEAM_RED, TEAM_BLUE = gamehelper.randomUnits(UNITS_COUNT)

  game:observe(selectArea)
  game:observeMany(UNITS)

  -- Domination Points
  table.insert(DOM_POINTS, DominationPoint:new{ x=100, y=500 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=700, y=100 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=100, y=100 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=700, y=500 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=400, y=300 })

  Agroup(70, 500, TEAM_BLUE)
  Agroup(400, 400, TEAM_RED)
  game:observeMany(DOM_POINTS)
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

  helper.ArrMap(DOM_POINTS, function(dp)
    dp.red_invasors = {}
    dp.blue_invasors = {}
    return dp
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

  -- DominationPoint Coliision
  collision.ColideWithB(UNITS, DOM_POINTS, function(u, dp)
    if u.tag == "red" then
      dp.red_invasors[u.id] = true
    else
      dp.blue_invasors[u.id] = true
    end

  end, function(u, dp)
    return collision.Euclidian(u, dp, 50)
  end)

  game:update(dt)
  game:animate(dt)
  game:runTimer(dt)
end

function love.draw()
  -- love.graphics.setShader(shader)
  love.graphics.setColor(0,0,0, 0.35)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  shader:send("num_lights", #TEAM_BLUE)
  shader:send("screen", {
    love.graphics.getWidth(),
    love.graphics.getHeight()
  })

  for i,u in pairs(TEAM_BLUE) do
    shader:send("lights["..i.."].position", {u.x, u.y})
    shader:send("lights["..i.."].diffuse", {1.0, 1.0, 1.0})
    shader:send("lights["..i.."].power", 1000)
  end
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