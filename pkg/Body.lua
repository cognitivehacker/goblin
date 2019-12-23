local Body = {
  x = 0,
  y = 0,
}

function Body:new(o)
  local b = o or {}
  self.__index = self
  setmetatable(b, self)
  b.boxes = {}

  return b
end

function Body:setBox(b)
  table.insert(self.boxes, b)
end

function Body:getBoxes()
  return self.boxes
end

function Body:euclidian(bodyB)
  return math.sqrt(((bodyB.x - self.x) ^ 2) + ((bodyB.y - self.y) ^ 2));
end

function Body:collide(bodyB)
  if self.invincible or b.invincible then return false end
  for  _, a in ipairs(self:getBoxes()) do         
    for _, b in ipairs(bodyB:getBoxes()) do
      if a.x + self.x < bodyB.x + b.x + b.width 
      and self.x + a.x + a.width > b.x + bodyB.x 
      and a.y + self.y < b.y + b.height + bodyB.y
      and a.height + a.y + self.y  > b.y + bodyB.y
      then
        return true;
      end
    end
  end
  return false;
end

return Body