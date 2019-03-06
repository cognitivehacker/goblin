local GameObject = {
    img=nil,
    x=0,
    y=0,
    speed_x=0,
    speed_y=0,
    width=0,
    height=0,
    dead=false,
    duration=0,
    animation = nil
}

function GameObject:new(go)
    local go = go or {}
    
    self.__index = self
    setmetatable(go , self)
    
    return go
end

function GameObject:isDead()
    return self.dead
end

function GameObject:draw()
    love.graphics.draw(self.img, self.x, self.y)
end

function GameObject:colide(go)
    if
        self.x + self.width >= go.x
        and self.x <= go.x + go.width 
        and self.y > go.y
        and self.y < go.y + go.height
    then
        return true
    end
    
    return false
end

return GameObject