local GameObject = require("pkg.GameObject")
local helper = require("pkg.Helper")

local Bullet = GameObject:new()

function Bullet:isDead()
  return self.dead
end

function Bullet:update(dt, game)
  if self.target then
    local x = self.x-self.target.x
    local y = self.y-self.target.y
    self.T = math.atan2(y,x)

    local tx = self.target.x - self.x
    local ty = self.target.y - self.y
    local dist = math.sqrt(tx* tx + ty * ty);

    local speed_x = (tx / dist) * self.speed_x
    local speed_y = (ty / dist) * self.speed_y

    self.x = self.x + speed_x
    self.y = self.y + speed_y

    local distance = self:euclidian(self.target)

    if  distance <= 8 then
      self.dead = true
    end
  end
end

function Bullet:draw(dt, game)
  if self.dead then return end
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.line(self:Polygon(4))
  
end

function Bullet:Polygon(size)
  size = size or 10
  
  local cost = math.cos(self.T)
  local sint = math.sin(self.T)
  local out = {}

  local vertices ={
    {0, 0},
    {-size, 0},
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

return Bullet