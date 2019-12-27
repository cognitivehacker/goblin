local math = require("math")
local helper = require("Helper")
local GameObject = require("GameObject")

local Unit = GameObject:new({
    alive=true,
    target=nil,
    T=0,
    hp=100
})

function Unit:update(dt)
    
    if self.hp <= 0 then
        self:kill()
    end
    
    if self.target then
        local x = self.x-self.target.x
        local y = self.y-self.target.y
        self.T = math.atan2(y,x)
        
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
    
    self:atack(dt)
end

function Unit:atack(dt)
    if self.atackTarget then
        local x = self.x-self.atackTarget.x
        local y = self.y-self.atackTarget.y
        self.T = math.atan2(y,x)

        self.atackTarget.hp = self.atackTarget.hp - 25 * dt
        if not self.atackTarget:isAlive() then self.atackTarget = nil end
    end
end

function Unit:draw()
    if not self.alive then return end

    if self.target then
        love.graphics.circle('line', self.target.x, self.target.y, 1)
    end

    if self.selected then
        love.graphics.circle("line", self.x, self.y-15, 1)
    end

    if self.atackTarget then
        love.graphics.print(self.atackTarget.id, self.x+10, self.y+10, 0, 0.6, 0.6)
    end

    love.graphics.print(self.id, self.x-3, self.y+6, 0, 0.8, 0.6)

    self:drawLife()
          
    if self.tag == "blue" then
        love.graphics.setColor(0, 0.56, 1)
    else
        love.graphics.setColor(0.8, 0, 1)
    end
    love.graphics.polygon("line", self:Polygon(12))
    love.graphics.polygon("line", self:Polygon(5))
    
    if self.tag == "blue" then
        love.graphics.setColor(0, 0, 0.2)
    else
        love.graphics.setColor(0.2, 0, 0)
    end
    love.graphics.circle("line", self.x, self.y, 70)

    -- for _, b in ipairs(self:getBoxes()) do
    --     love.graphics.rectangle('line', b.x+self.x, b.y+self.y, b.width, b.height)
    -- end
    love.graphics.setColor(255, 255, 255)
end

function Unit:drawLife()
    local b = self.boxes[1]
    
    local x1 = self.x+b.x
    local y1 = self.y+b.height


    local percent = (100*self.hp) / 500

    local x2 = x1 + percent
    local y2 = self.y+b.height

    love.graphics.setColor(0.8, 0.8, 0.3)
    love.graphics.line(x1, y1, x2, y2)
end

function Unit:isAlive()
    return self.alive
end

function Unit:kill()
    self.alive = false
    self.dead = true
end

function Unit:Polygon(size)
    size = size or 10

    local cost = math.cos(self.T)
    local sint = math.sin(self.T)
    local out = {}
    local vertices ={
        {-size, 0},
        {size, -size},
        {size/1.65, -size/2},
        {size*math.random(0.5, 0.83), 0},
        {size/1.65, size/2},
        {size, size}
    }

    vertices = helper.ArrMap(vertices, function(v)
        local x = v[1]
        local y = v[2]
        return {(x*cost - y*sint), (y*cost + x*sint)}
    end)

    for _, v in pairs(vertices) do 
        table.insert(out, self.x+v[1])
        table.insert(out, self.y+v[2])
    end

    return out
end

return Unit