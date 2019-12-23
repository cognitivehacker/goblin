local copy = require("Helper").Copy

local ColisionGroup = {
    gameObjects={},
}

function ColisionGroup:new(o)
    cg = o or {}
    self.__index = self
    setmetatable(cg, self)
    return cg
end

function ColisionGroup:setGameObject(go)
    table.insert(self.gameObjects, go)
end

function ColisionGroup:selfColide(callback)
    local objects = copy(self.gameObjects)
    for i, u1 in pairs(objects) do
        table.remove(objects, i)
        for _, u2 in pairs(objects) do
            if  u1:collide(u2) then
                callback(u1, u2)
            end
        end
    end
end

function ColisionGroup:colideWithB(groupB, callback)
    for i, u1 in pairs(self.gameObjects) do
        for _, u2 in pairs(groupB) do
            if  u1:collide(u2) then
                callback(u1, u2)
            end
        end
    end
end



function ColisionGroup:colideSingle(go, callback)
    for i, u1 in pairs(self.gameObjects) do
        if  u1:collide(go) then
            callback(u1, go)
        end
    end
end

return ColisionGroup
