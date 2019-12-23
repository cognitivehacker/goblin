math = require("math")
local GameObject = require("GameObject")

local Unit = GameObject:new({
    alive=true,
    target=nil,
    hp=100
})

function Unit:update(dt)
    if self.target then
        local tx = self.target.x - self.x
        local ty = self.target.y - self.y
        local dist = math.sqrt(tx* tx + ty * ty);

        self.speed_x = (tx / dist)
        self.speed_y = (ty / dist)

        self.x = self.x + self.speed_x
        self.y = self.y + self.speed_y

        local distance = self:euclidian(self.target)

        if  distance < 1 then
            self.target=nil
        end
    end
end

function Unit:atack(u2)
    u2.hp = u2.hp - 0.6
    if u2.hp <= 0 then
        u2.alive=false
    end
end

function Unit:draw()
    if not self.alive then return end

    if self.target then
        love.graphics.circle('line', self.target.x, self.target.y, 2)
    end

    for _, b in ipairs(self:getBoxes()) do 
        if self.selected then
            love.graphics.setColor(255, 80, 0)
        end
        love.graphics.rectangle('line', b.x+self.x, b.y+self.y, b.width, b.height)
        love.graphics.setColor(255, 255, 255)
    end
end

function Unit:isAlive()
    return self.alive
end

function Unit:kill()
    self.alive = false
end

return Unit