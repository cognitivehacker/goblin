local GameObject = {}

function GameObject:new(img, x, y, speed_x, speed_y, width, height)
    local o = o or {}
    self.__index = self
    setmetatable(o , self)
    
    o.img = img
    o.x = x
    o.y = y
    o.speed_x = speed_x
    o.speed_y = speed_y
    o.width = width or img:getWidth()
    o.height = height or img:getHeight()
    o.animation = GameObject.makeAnimation(0.5, img, o.width, o.height)
    return o
end

function GameObject.makeAnimation(duration, image, width, height)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end

return GameObject