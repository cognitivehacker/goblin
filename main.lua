local Game = require('pkg.Game')
local Box = require('pkg.Box')
local collision = require('pkg.Collision')
local helper = require('pkg.Helper')
local SelectGroup = require('pkg.game.SelectGroup')
local gamehelper = require("pkg.game.RtsHelper")
local conf = require("pkg.game.gameconf")
local DominationPoint = require("pkg.game.DominationPoint")


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
SHADER = nil
CANVAS_LIGHT = nil

-- love.graphics.clear = function() end

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  love.keyboard.setKeyRepeat( true )

  -- Simple light shader
  local shader_code = [[
  struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
  };

  extern Light lights[332];
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

  CANVAS_LIGHT = love.graphics.newCanvas(conf._WINDOW_WIDTH, conf._WINDOW_HEIGHT)

  SHADER = love.graphics.newShader(shader_code)

  love.window.setMode( conf._WINDOW_WIDTH * conf._WINDOW_SCALLING_X, conf._WINDOW_HEIGHT * conf._WINDOW_SCALLING_Y, {fullscreen=conf._WINDOW_FULLSCREEN})
  game = Game:new()
  gamehelper.StarField(game, 1000, 1200, 1200)

  selectArea = SelectGroup:new()
  selectArea:setBox(Box:new())

  game:observe(selectArea)
  game:observeMany(UNITS)

  -- Domination Points
  table.insert(DOM_POINTS, DominationPoint:new{ x=100, y=1000 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=1400, y=100 })
  table.insert(DOM_POINTS, DominationPoint:new{ x=100, y=100, tag="red"})
  table.insert(DOM_POINTS, DominationPoint:new{ x=1400, y=1000, tag="blue" })
  table.insert(DOM_POINTS, DominationPoint:new{ x=800, y=600, tag='blue' })

  game:observeMany(DOM_POINTS)
end

function love.update(dt)
  TEAM_RED = helper.ArrFilter(TEAM_RED, gamehelper.RemoveDead)
  TEAM_BLUE = helper.ArrFilter(TEAM_BLUE, gamehelper.RemoveDead)
  UNITS = helper.ArrFilter(UNITS, gamehelper.RemoveDead)
  SELECTED_UNITS = helper.ArrFilter(SELECTED_UNITS, gamehelper.RemoveDead)
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
    gamehelper.ColideUnoverlapX(u1, u2)
    gamehelper.ColideUnoverlapY(u1, u2)
  end)

  --Unoverlap
  collision.SelfColide(UNITS, function(u1, u2)
    gamehelper.ColideUnoverlapX(u1, u2)
    gamehelper.ColideUnoverlapY(u1, u2)
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

function love.draw(dt)
  -- love.graphics.setCanvas(CANVAS_LIGHT)

  -- love.graphics.setShader(SHADER)
  -- love.graphics.setColor(0,0,0, 0.005)
  -- love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  -- SHADER:send("num_lights", #UNITS)
  -- SHADER:send("screen", {
  --   love.graphics.getWidth(),
  --   love.graphics.getHeight()
  -- })

  -- for i=1, #UNITS do
  --   SHADER:send("lights["..i.."].diffuse", {0, 0, 0})
  -- end

  -- for i,u in pairs(SELECTED_UNITS) do
  --   SHADER:send("lights["..i.."].position", {u.x-game.camera.offsetX, u.y-game.camera.offsetY})
  --   SHADER:send("lights["..i.."].diffuse", {0, 1.0, 1.0})
  --   SHADER:send("lights["..i.."].power", 850)
  -- end

  -- love.graphics.scale(conf._WINDOW_SCALLING_X, conf._WINDOW_SCALLING_Y)
  -- game:draw(dt)

  -- love.graphics.setCanvas()
  -- love.graphics.setShader()

  -- love.graphics.draw(CANVAS_LIGHT, 0, 0)
  game:draw(dt)
end

function love.mousepressed(x, y, button, istouch)
  if button == 1 then
    if not selectArea:isAlive() then
      local offsetx = game.camera.offsetX
      local offsety = game.camera.offsetY
      selectArea.x = x + offsetx
      selectArea.y = y + offsety
      selectArea.alive = true
    end
  end
end

function love.mousereleased(x, y, button, istouch)
  if button == 2 then
    gamehelper.Agroup(x+game.camera.offsetX, y+game.camera.offsetY, SELECTED_UNITS)
  elseif button == 1 then
    SELECTED_UNITS = {}
    -- gamehelper.SelectUnits(TEAM_BLUE, selectArea)
    print(game)
    selectArea:invertSquareCoordinates(game)
    gamehelper.SelectUnits(UNITS, selectArea)
  end
end

function love.keypressed(key, scancode, isrepeat)
  gamehelper.movecam(key, game.camera)
end

