local Bullet = {}

function Bullet:new(img, x, y, speed_x, speed_y)
    local o = o or {}
    self.__index = self
    setmetatable(o , self)
    
    o.img = img
    o.x = x
    o.y = y
    o.speed_x = speed_x
    o.speed_y = speed_y

    return o
end

return Bullet