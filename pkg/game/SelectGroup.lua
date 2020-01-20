math = require("math")
local GameObject = require("pkg.GameObject")

local SelectGroup = GameObject:new({
    alive=false,
    target=nil,
})

function SelectGroup:update(dt, game)
    local x=game.camera.offsetX
    local y=game.camera.offsetY
    
    if self:isAlive() then
        local width = love.mouse.getX() - (self.x - x)
        local height = love.mouse.getY() - (self.y - y)
        self.boxes[1].width = width
        self.boxes[1].height = height
    end
end

function SelectGroup:draw(dt, game)
    local x=game.camera.offsetX
    local y=game.camera.offsetY

    if self:isAlive() then
        love.graphics.setColor(0,0.8,1)
        love.graphics.rectangle('line', self.x-x, self.y-y, self.boxes[1].width, self.boxes[1].height)
        love.graphics.setColor(255,255,255)
    end
end

function SelectGroup:isAlive()
    return self.alive
end

function SelectGroup:kill()
    self.alive = false
end

return SelectGroup