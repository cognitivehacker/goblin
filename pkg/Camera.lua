local Box = require("pkg.Box")

local Camera = {
  offsetX=0,
  offsetY=0,
  x=0,
  y=0,
  width=0,
  height=0,
  boundaryX=0,
  boundaryY=0,
  boxes={},
  offsetSize=400,
}

function Camera:new(o)
  local cam = o or {}
  self.__index = self
  setmetatable(cam, self)

  cam.width = love.graphics.getWidth()
  cam.height = love.graphics.getHeight()

  table.insert(self.boxes, Box:new{x=self.x-self.offsetSize, y=self.y-self.offsetSize, width=cam.width+self.offsetSize*2, height=cam.height+self.offsetSize*2})

  return cam
end

function Camera:getBoxes()
  return self.boxes
end

function Camera:up(y)
  if self.offsetY <= 0 then return end

  y = y or 1
  self.offsetY = self.offsetY - y
  self.y = self.offsetY
end

function Camera:down(y)
  if self.offsetY >= self.boundaryY then return end

  y = y or 1
  self.offsetY = self.offsetY + y
  self.y = self.offsetY
end

function Camera:left(x)
  if self.offsetX <= 0 then return end

  x = x or 1
  self.offsetX = self.offsetX - x
  self.x = self.offsetX
end

function Camera:right(x)
  if self.offsetX >= self.boundaryX then return end

  x = x or 1
  self.offsetX = self.offsetX + x
  self.x = self.offsetX
end

return Camera