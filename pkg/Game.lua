Timer = require("Timer")

local Game = {}

-- update and draw all Game Objects
-- factory new Game Objects
function Game:new(o)
  local game = o or {}
  self.__index = self
  setmetatable(game, self)

  game.gameObjects = {}
  game.timers = {}
  return game
end

function Game:observe(go)
  table.insert(self.gameObjects, go)
end

function Game:update(dt)
  for i, go in pairs(self.gameObjects) do
    if go:isDead() then
      table.remove(self.gameObjects, i)
    end

    go:update(dt)
  end
end

function Game:draw()
  for i, go in pairs(self.gameObjects) do
    go:draw(i)
  end
end

function Game:addTimer(exec, seconds, times, onDead)
  t = Timer:new{exec=exec, seconds=seconds, times=times, onDead=onDead}
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
  for i, go in pairs(self.gameObjects) do
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