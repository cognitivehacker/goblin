local conf = require("gameconf")
local Star = require("Star")
local rand = require("math").random
local mr = require("Helper").MicroRand
local rtshelper = {}

function rtshelper.StarField(game, density)
    density = density or 50
    local width = conf._WINDOW_WIDTH
    local height = conf._WINDOW_HEIGHT

    for i=0, density do
        game:observe(Star:new{
            x=rand(0,width),
            y=rand(0,height),
            acc_min=mr(0, 50),
            acc_max=mr(0, 90),
            acc=mr(0, 100),
            acc_speed=mr(20, 30, 3),
            r=mr(80, 90),
            g=mr(50, 70),
            b=mr(50, 80),
        })
    end
    print (mr(1, 30, 3))
end

return rtshelper