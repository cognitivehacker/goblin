local helper = require("pkg.Helper")
local Particle = require("pkg.game.Particle")
local GameObject = require("pkg.GameObject")
local Bullet = require("pkg.game.Bullet")
local math = require("math")

local Unit = GameObject:new({
  alive=true,
  target=nil,
  T=0,
  hp=100,
  atackRating=0,
  color=nil,
  selected=false
})

function Unit:update(dt, game)
  if self.hp <= 0 then
    self:kill(game)
  end

  if self.target then

    local x = self.x-self.target.x
    local y = self.y-self.target.y
    local tx = self.target.x - self.x
    local ty = self.target.y - self.y
    local dist = math.sqrt(tx* tx + ty * ty);
    self.T = math.atan2(y,x)

    self.speed_x = (tx / dist)
    self.speed_y = (ty / dist)

    self.x = self.x + self.speed_x
    self.y = self.y + self.speed_y

    local distance = self:euclidian(self.target)

    if  distance < 1 then
      self.target=nil
    end
  end

  if self.atackTarget then
    self:atack(dt, game)
  end
end

function Unit:atack(dt, game)
  local x = self.x-self.atackTarget.x
  local y = self.y-self.atackTarget.y
  self.T = math.atan2(y,x)

  if self.atackRating >= 0.35 then
    game:observe(Bullet:new{target=self.atackTarget, x=self.x, y=self.y-6, speed_x=8, speed_y=8})
    self.atackRating = 0
    self.atackTarget.hp = self.atackTarget.hp - 10
  end
  self.atackRating = self.atackRating + dt

  if not self.atackTarget:isAlive() then self.atackTarget = nil end
end

function Unit:draw(game)
  love.graphics.setLineWidth(1)

  if not self.alive then return end

  -- if self.atackTarget then
  --   love.graphics.print(self.atackTarget.id, self.x+10, self.y+10, 0, 0.6, 0.6)
  -- end

  self:drawLife()

  love.graphics.setColor(self.color[1], self.color[2], self.color[3])

  love.graphics.polygon("line", self:Polygon(6))
  love.graphics.polygon("line", self:Polygon(4))
  
  -- love.graphics.print(string.format("%2d , %2d", self.x, self.y), self.x-5, self.y+5)
  if self.selected then
    love.graphics.circle('line', self.x, self.y-15, 3)
  end

  if self.target and self.selected then
    love.graphics.circle('line', self.target.x, self.target.y, 3)
    love.graphics.circle('line', self.target.x, self.target.y, 0.5)
  end

  if self.tag == "blue" then
    love.graphics.setColor(0, 0, 0.13)
  else
    love.graphics.setColor(0.13, 0, 0)
  end

  love.graphics.setColor(255, 255, 255)
end

function Unit:drawLife()
  local b = self.boxes[1]

  local x1 = self.x - 10
  local y1 = self.y+15

  local percent = (100*self.hp) / 500
  
  local x2 = x1 + percent
  local y2 = self.y+15
  
  love.graphics.setColor(0.5, 1, 0)
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.line(x1, y1, x2, y2)
end

function Unit:isAlive()
  return self.alive
end

function Unit:kill(game)
  Particle.Explode(50, game, self.x, self.y, self.color)
  self.alive = false
  self.dead = true
end

function Unit:Polygon(size)
  size = size or 10
  
  local cost = math.cos(self.T)
  local sint = math.sin(self.T)
  local out = {}
  local vertices ={
    {-size, 0},
    {size, -size},
    {size/1.65, -size/2},
    {size*math.random(0.5, 0.83), 0},
    {size/1.65, size/2},
    {size, size}
  }

  helper.ArrMap(vertices, function(v)
    local x = v[1]
    local y = v[2]
    return {(x*cost - y*sint), (y*cost + x*sint)}
  end)

  for _, v in pairs(vertices) do 
    table.insert(out, self.x+v[1])
    table.insert(out, self.y+v[2])
  end
  
  return out
end


function Unit:__tostring()
  return "<Unit ID:"..self.id.." HP:"..self.hp.." TAG:"..self.tag.." X:"..self.x.." Y:"..self.y..">"
end
return Unit