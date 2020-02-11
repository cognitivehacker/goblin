local Timer = require("pkg.Timer")
local Camera = require("pkg.Camera")
local Collision = require("pkg.Collision")

local Game = {
  gameObjects={},
  timers={},
  camera=nil,
  debug=false
}

-- update and draw all Game Objects
-- factory new Game Objects
function Game:new(o)
  local game = o or {}
  self.__index = self
  setmetatable(game, self)

  game.camera = Camera:new()
  game.camera.boundaryX = love.graphics.getWidth()
  game.camera.boundaryY = love.graphics.getHeight()

  return game
end

function Game:observe(go)
  table.insert(self.gameObjects, go)
end

function Game:observeMany(go)
  for _, g in ipairs(go) do
    table.insert(self.gameObjects, g)
  end
end

function Game:update(dt)
  for i, go in pairs(self.gameObjects) do
    if go:isDead() then
      table.remove(self.gameObjects, i)
    end
    go:update(dt, self)
  end
end

function Game:debug(debug)
  self.debug = debug
end

function Game:draw()
  for _, go in pairs(self.gameObjects) do
    if go:collide(self.camera) then
      go:draw(self)
    end
    if self.debug then
      -- love.graphics.rectangle('line', go.x, go.y, go.boxes[1].width, go.boxes[1].height)
    end
  end
end

function Game:addTimer(exec, seconds, times, onDead)
  local t = Timer:new{exec=exec, seconds=seconds, times=times, onDead=onDead}
  self:setTimer(t)
end

function Game:setTimer(t)
  table.insert(self.timers, t)
end

function Game:runTimer(dt)
  for i, t in ipairs(self.timers) do
    if t:isDead() then
      table.remove(self.timers, i)
      t:onDead(g, dt)
    end
    t:run(self, dt)
  end
end

function Game:animate(dt)
  for _, go in pairs(self.gameObjects) do
    if go.animation then
      go.animation:step(dt)
    end
  end
end

function Game:make(object)
  table.insert(self.gameObjects, object)

  return object
end

return Game