local Camera = {
  offsetX=0,
  offsetY=0,
  boundaryX=0,
  boundaryY=0,
}

function Camera:new(o)
  local cam = o or {}
  self.__index = self
  setmetatable(cam, self)

  return cam
end

function Camera:up(y)
  if self.offsetY <= 0 then return end

  y = y or 1
  self.offsetY = self.offsetY - y
end

function Camera:down(y)
  if self.offsetY >= self.boundaryY then return end

  y = y or 1
  self.offsetY = self.offsetY + y
end

function Camera:left(x)
  if self.offsetX <= 0 then return end

  x = x or 1
  self.offsetX = self.offsetX - x
end

function Camera:right(x)
  if self.offsetX >= self.boundaryX then return end

  x = x or 1
  self.offsetX = self.offsetX + x
end

return Camera