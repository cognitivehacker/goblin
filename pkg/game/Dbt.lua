local helper = require("pkg.Helper")
local GameObject = require("pkg.GameObject")
local math = require("math")

local Dbt = GameObject:new({
  alive=true,
  target=nil,
  T=0,
  hp=100,
  atackRating=0
})

function Dbt:update(dt, game)
  

  local x = self.x-love.mouse.getX()
  local y = self.y-love.mouse.getY()
  self.T = math.atan2(y, x)
  print(self.T)    

  if self.target then
    
    local x = self.x-self.target.x
    local y = self.y-self.target.y
    local tx = self.target.x - self.x
    local ty = self.target.y - self.y
    local dist = math.sqrt(tx* tx + ty * ty);

    self.speed_x = (tx / dist)
    self.speed_y = (ty / dist)
    
    -- self.x = self.x + self.speed_x
    -- self.y = self.y + self.speed_y
    
    local distance = self:euclidian(self.target)
    
    if  distance < 1 then
      self.target=nil
    end
  end
end

function Dbt:draw(dt, game)

  love.graphics.setColor(1, 0, 1)

  love.graphics.polygon("line", self:Polygon(13))

  if self.target then
    love.graphics.circle('line', self.target.x, self.target.y, 3)
    love.graphics.circle('line', self.target.x, self.target.y, 0.5)
    -- love.graphics.line(self.x, self.y, self.target.x, self.target.y)
  end

  love.graphics.setColor(255, 255, 255)
  if self.selected then
    love.graphics.circle("line", self.x, self.y-15, 1)
  end
end


function Dbt:drawLife()
  local b = self.boxes[1]
  
  local x1 = self.x+b.x
  local y1 = self.y+b.height
  
  
  local percent = (100*self.hp) / 500
  
  local x2 = x1 + percent
  local y2 = self.y+b.height
  
  love.graphics.setColor(0.5, 1, 0)
  love.graphics.line(x1, y1, x2, y2)
end

function Dbt:isAlive()
  return self.alive
end

function Dbt:kill()
  self.alive = false
  self.dead = true
end

function Dbt:Polygon(size)
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

return Dbt