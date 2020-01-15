local GameObject = require("pkg.GameObject")

local Cam = GameObject:new{
    x=0,
    y=0,
}

function Cam:update()
    self.x = self.x + 1
    self.y = self.y + 1
end

return Cam