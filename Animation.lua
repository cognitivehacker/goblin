local Animation = {}

function Animation:new(spriteSheet, quads, duration, loop, fn)
    local animation = {}
    self.__index = self
    setmetatable(animation , self)

    animation.spriteSheet = spriteSheet;
    animation.quads = {};

    for _, quad in ipairs(quads) do
        table.insert(animation.quads, love.graphics.newQuad(quad.x, quad.y, quad.width, quad.height, spriteSheet:getDimensions()))
    end

    animation.duration = duration
    animation.currentTime = 0
    animation.spriteNum = 1
    animation.loop = loop or false
    animation.fn = fn

    return animation
end

function Animation:step(dt)
    if self.spriteNum >= #self.quads and not self.loop then
        return
    end

    if self.fn and self:isFinished() then
        self:fn()
    end

    self.currentTime = self.currentTime + dt
    if self.currentTime >= self.duration then
        self.currentTime = self.currentTime - self.duration
    end

    self.spriteNum = math.floor(self.currentTime / self.duration * #self.quads) + 1
end

function Animation:getCurrentQuad()
    return self.quads[self.spriteNum]
end

function Animation:isFinished()
    return self.spriteNum >= #self.quads -1
end

return Animation