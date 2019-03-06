local GameObject = require("GameObject")
local conf = require("gameconf")

local Goblin = GameObject:new({alive=true})

function Goblin:update(dt)
    self.y = self.y + (self.speed_y * dt)
    self.x = self.x + (self.speed_x * dt)
    
    if self.x + self.width >= conf._WINDOW_WIDTH then
        self.x = conf._WINDOW_WIDTH - self.width
    end
    
    if self.x < 0 then
        self.x = 0
    end
    
    if self.y < 0 then
        self.y = 0
    end
    
    if self.y + self.height >= conf._WINDOW_HEIGHT then
        self.y = conf._WINDOW_HEIGHT - self.height
    end
end

function Goblin:draw()
    if self:isAlive() then
        local quad = self.animation:getCurrentQuad()
        love.graphics.draw(self.animation.spriteSheet, quad, self.x, self.y, 0)
    end
end

function Goblin:isAlive()
    return self.alive
end

function Goblin:kill()
    self.alive = fale
end

return Goblin