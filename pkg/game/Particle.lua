local rand = require("math").random
local GameObject = require("pkg.GameObject")

local Particle = GameObject:new({
    x=nil,
    y=nil,
    speed_x=nil,
    speed_y=nil,
    time=100,
    rgb=nil,
    tpercent=1,
})

function Particle:update(dt)
    self.time = self.time - dt * 300
    self.tpercent = self.time / 100

    self.x = self.x + self.speed_x
    self.y = self.y + self.speed_y

    self.speed_x = self.speed_x * self.tpercent
    self.speed_y = self.speed_y * self.tpercent

    if self.time <= 0 then
        self.dead = true
    end
end

function Particle:draw(dt, game)
    local x = game.camera.offsetX
    local y = game.camera.offsetY

    love.graphics.setColor(self.rgb[1]*self.tpercent, self.rgb[2]*self.tpercent, self.rgb[3]*self.tpercent)
    love.graphics.rectangle('line', self.x-x, self.y-y, 1, 1)
end


function Particle.Explode(count, game, x, y, rgb)
    local threshold = 20
    for i=0, count do
      local p=Particle:new{x=x, y=y, speed_x=rand(-threshold, threshold), speed_y=rand(-threshold, threshold), rgb=rgb}
      game:observe(p)
    end
  end

return Particle