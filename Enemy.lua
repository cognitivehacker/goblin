local GameObject = require("GameObject")
local conf = require('gameconf')
local Enemy = GameObject:new({alive=true})

function Enemy:update(dt)
    self.y = self.y + (self.speed_y * dt)
    self.x = self.x + (self.speed_x * dt)
end

function Enemy:draw()
    local quad = self.animation:getCurrentQuad()
    love.graphics.draw(self.animation.spriteSheet, quad, self.x, self.y, 0)
end

function Enemy:isDead()
    return self.dead or self.y >= conf._WINDOW_HEIGHT
end

return Enemy