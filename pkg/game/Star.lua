local GameObject = require("pkg.GameObject")

local Star = GameObject:new({
    acc=0,
    acc_speed=0.01,
    acc_max=1,
    acc_min=0,
    paralax=0.02
})

function Star:update(dt)
    self.acc = self.acc + self.acc_speed
    self.x = self.x + self.acc_speed * 2
    if self.acc >= self.acc_max or self.acc <= self.acc_min then
        self.acc_speed = self.acc_speed * -1
    end
end

function Star:draw(dt, game)
    local offX = game.camera.offsetX
    local offY = game.camera.offsetY

    local ac = self.acc
    love.graphics.setColor(self.r*ac,self.g*ac,self.b*ac)
    love.graphics.rectangle("fill", self.x-offX*self.paralax, self.y-offY*self.paralax, 2*ac, 2*ac)
end

return Star