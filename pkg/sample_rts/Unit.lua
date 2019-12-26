math = require("math")
local GameObject = require("GameObject")

local Unit = GameObject:new({
    alive=true,
    target=nil,
    hp=100
})

function Unit:update(dt)
    self:atack(dt)

    if self.hp <= 0 then
        self:kill()
    end

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

function Unit:atack(dt)
    if self.atackTarget then
        self.atackTarget.hp = self.atackTarget.hp - 90 * dt
        if not self.atackTarget:isAlive() then self.atackTarget = nil end
    end
end

function Unit:draw()
    if not self.alive then return end

    if self.target then
        love.graphics.circle('line', self.target.x, self.target.y, 2)
    end

    for _, b in ipairs(self:getBoxes()) do 
        if self.atackTarget then 
            love.graphics.setColor(255, 0, 0)
        elseif self.selected then
            love.graphics.setColor(255, 80, 0)
        end

        love.graphics.rectangle('line', b.x+self.x, b.y+self.y, b.width, b.height)
        self:drawLife()
        love.graphics.setColor(255, 255, 255)
    end
end

function Unit:drawLife()
    local b = self.boxes[1]
    
    local x1 = self.x+b.x
    local y1 = self.y+b.height


    local percent = (100*self.hp) / 500

    local x2 = x1 + percent
    local y2 = self.y+b.height

    love.graphics.setColor(255, 0, 0)
    love.graphics.line(x1, y1, x2, y2)
end

function Unit:isAlive()
    return self.alive
end

function Unit:kill()
    self.alive = false
    self.dead = true
end

return Unit