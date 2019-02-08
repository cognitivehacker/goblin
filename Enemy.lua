local Enemy = {}

function Enemy:new(img, x, y, speed_x, speed_y)
    local o = o or {}
    self.__index = self
    setmetatable(o , self)
    
    o.img = img
    o.x = x
    o.y = y
    o.speed_x = speed_x
    o.speed_y = speed_y
    o.width = img:getWidth()
    o.height = img:getHeight()

    return o
end

return Enemy