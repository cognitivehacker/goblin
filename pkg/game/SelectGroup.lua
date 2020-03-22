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
        local Xlenght = love.mouse.getX() - (self.x - x)
        local Ylenght = love.mouse.getY() - (self.y - y)

        self.boxes[1].width = Xlenght
        self.boxes[1].height = Ylenght

        print(self.x, self.y, self.boxes[1].width, self.boxes[1].height )
    end
end

function SelectGroup:invertSquareCoordinates(game)
    print(game)
    local x=game.camera.offsetX
    local y=game.camera.offsetY

    local Xlenght = love.mouse.getX() - (self.x - x)
    local Ylenght = love.mouse.getY() - (self.y - y)

    if Xlenght < 0 then
        self.x = self.x + Xlenght
        Xlenght = Xlenght * -1
    end

    if Ylenght < 0 then
        self.y = self.y + Ylenght
        Ylenght = Ylenght * -1
    end

    self.boxes[1].width = Xlenght
    self.boxes[1].height = Ylenght
end

function SelectGroup:draw(game)
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