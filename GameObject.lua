local Body = require("Body")

local GameObject = Body:new({
img = nil,
x = 0,
invincible=false,
y = 0,
speed_x = 0,
speed_y = 0,
width = 0,
height = 0,
dead = false,
duration = 0,
animation = nil})

function GameObject:isDead()
  return self.dead
end

function GameObject:draw()
  love.graphics.draw(self.img, self.x, self.y)
end

return GameObject