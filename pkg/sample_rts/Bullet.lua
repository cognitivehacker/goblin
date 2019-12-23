local GameObject = require("GameObject")

local Bullet = GameObject:new()

function Bullet:isDead()
    return self.dead or self.y <= 0 - self.height 
end

function Bullet:update(dt)
    self.y = self.y + (self.speed_y * dt)
end

return Bullet