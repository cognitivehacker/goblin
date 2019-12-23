local copy = require("Helper").Copy

local DistanceGroup = {
    gameObjects={},
}

function DistanceGroup:new(o)
    local cg = o or {}
    self.__index = self
    setmetatable(cg, self)
    return cg
end

function DistanceGroup:setGameObject(go)
    table.insert(self.gameObjects, go)
end

function DistanceGroup:selfColide(callback, radius)
    radius = radius or 0
    local gObjects = self.gameObjects
    for i = 1, #gObjects do
        for j = i+1, #gObjects do
            if  gObjects[i]:euclidian(gObjects[j]) <= radius then
                callback(gObjects[i], gObjects[j])
            end
        end
    end
end

function DistanceGroup:colideWithB(groupB, callback, radius)
    radius = radius or 0

    for _, u1 in pairs(self.gameObjects) do
        for _, u2 in pairs(groupB) do
            if  u1:euclidian(u2) > radius then
                callback(u1, u2)
            end
        end
    end
end

return DistanceGroup
