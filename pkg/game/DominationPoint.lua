local GameObject = require("pkg.GameObject")
local gamehelper = require("pkg.game.RtsHelper")
local Box = require("pkg.Box")
local Unit = require("pkg.game.Unit")
local DominationPoint = GameObject:new({
  alive=true,
  state="stopped",
  tag=nil,
  radius=50,
  red_invasors={},
  blue_invasors={},
  dominationLoad=0,
  isDominating=false,
  dominationTime=100,
  totalTime=100,
  timeBarSize=100,
  spawnTime=100,
  spawnTotalTime=100,
})

function DominationPoint:update(dt, game)
  local blue, red = self:getInvasorsSize()
  local majoriti = nil

  if self.tag then
    self.spawnTime = self.spawnTime - dt * 30
  end

  if self.spawnTime <= 0 and self.tag and self.state == "stopped" then
    self:spawn(game)
  end

  if blue > red then
    majoriti = "blue"
  elseif red > blue then
    majoriti = "red"
  end

  self.state = "stopped"
  if (red > 0 and blue > 0)
  or (red == 0 and blue == 0)
  then
    self.state = "stopped"
  elseif (self.tag ~= "red" and red > blue)
  or (self.tag ~= "blue" and blue > red) then
    self.state = "dominating"
  elseif majoriti == self.tag and self.dominationTime < self.totalTime then
    self.state = "recovering"
  end

  if self.state == "dominating" then
    self.dominationTime = self.dominationTime - dt * 10
  elseif self.state == "recovering" then
    self.dominationTime = self.dominationTime + dt * 10
  end

  if self.dominationTime <= 0 then
      self:shiftTag(blue, red)
  end
end

function DominationPoint:spawn(game)
  self.spawnTime = self.spawnTotalTime
  local box = Box:new{width=UNIT_DIMENSIONS, height=UNIT_DIMENSIONS, x=-10, y=-10}
  local u = Unit:new{x=self.x, y=self.y, tag=self.tag, id=math.random(1000)}
  u:setBox(box)

  table.insert(UNITS, u)

  if u.tag == "red" then
    table.insert(TEAM_RED, u)
    u.color = gamehelper.RED_COLOR
  else
    table.insert(TEAM_BLUE, u)
    u.color = gamehelper.BLUE_COLOR
  end

  game:observe(u)
end

function DominationPoint:shiftTag(blue, red)
  self.isDominating = false
  self.dominationTime = 100
  self.tag = blue > red and "blue" or "red"
end

function DominationPoint:draw(game)
  local offX = game.camera.offsetX
  local offY = game.camera.offsetY

  if not self.tag then
    love.graphics.setColor(1, 1, 1)
  elseif self.tag == "blue" then
    love.graphics.setColor(0, 0.56, 1)
  else
    love.graphics.setColor(0.8, 0, 1)
  end

  love.graphics.circle("line", self.x-offX, self.y-offY, self.radius)
  self:drawTime({x=offX,y=offY})
end

function DominationPoint:drawTime(offset)
  local percent = ((self.dominationTime * 100) / self.totalTime) / 100
  local x = self.x - 50
  love.graphics.line(x-offset.x, self.y-offset.y, x + (self.timeBarSize * percent)-offset.x, self.y-offset.y)
end

function DominationPoint:getInvasorsSize()
  local blue, red = 0, 0
  for i, _ in pairs(self.blue_invasors) do
    blue = blue +1
  end
  for i, _ in pairs(self.red_invasors) do
    red = red +1
  end
  return blue, red
end


return DominationPoint